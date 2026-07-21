# Path 2 — Containerized CI/CD: CodePipeline → ECR → ECS Fargate

The same delivery problem as Path 1 — a Java Spring Boot application, AWS-native services, Terraform only — solved with containers. The application is packaged into a Docker image, stored in ECR, and deployed to ECS Fargate behind an Application Load Balancer through CodePipeline's native ECS deploy action. Second of three parallel implementations of the same delivery problem built to compare orchestration approaches.

## Architecture

````mermaid
flowchart LR
    GH[GitHub<br>cicd-challenge-app] -->|push to main| CP[CodePipeline]
    CP --> CB[CodeBuild<br>Maven + docker build/push]
    CB -->|image: commit hash + latest| ECR[(ECR<br>container registry)]
    CB -->|imagedefinitions.json| CP
    CP -->|native ECS deploy action| ECS[ECS Fargate<br>rolling service update]
    ECR -->|pull hash-tagged image| ECS
    Internet((internet)) --> ALB[ALB<br>health checks on /health]
    ALB --> ECS
````

- **Three real stages.** Source → Build → Deploy, where Deploy is a first-class CodePipeline action, not a shell script embedded in `post_build`. This is the deliberate contrast with Path 1: the orchestrator is genuinely load-bearing here.
- **Immutable artifact model.** Every image is tagged with its short commit hash; `imagedefinitions.json` always references the hash, never `latest`. The task definition revision history doubles as a deployment ledger — what's running always has a git answer.
- Terraform only, remote state in S3 with native locking, region eu-west-1. Network layer comes from a shared module (`modules/network`) also used by Path 1 — shared code, fully separate state per path.

## Highlights

**Zero-downtime deployment, fixing Path 1's named limitation.** ECS rolling updates start the new task, wait for it to pass ALB target-group health checks on `/health`, and only then drain the old one. Path 1's `systemctl restart` gap — brief downtime on every deploy, no health awareness — is closed by architecture rather than scripting.

**A scoped execution role, and a deliberately absent task role.** The task execution role (assumed by the ECS agent to pull the image and write logs) is hand-scoped to this repository and log group, replacing the AWS-managed policy's `Resource: *`. The task role — the application's own AWS identity — is omitted entirely: the app calls no AWS APIs, so no role until a need exists.

**An IAM failure diagnosed by receipt, not guesswork.** The first deployment failed with a generic "insufficient permissions to access ECS." CloudTrail Event history named the real cause: the deploy action's `RegisterTaskDefinition` call requires `ecs:TagResource` when the task definition carries tags. The denial event, with exact action and resource ARN, turned an opaque error into a one-line fix.

**Build validated layer by layer before automation.** The Dockerfile was proven locally, the ECR auth/push chain tested with a manually pushed image, and the app run on Fargate against that image — before CodeBuild or the pipeline existed. When the pipeline's first run failed, the suspect list was already three layers shorter.

**`latest` rides along but never drives.** Each build pushes hash + `latest` tags on the same image. The moving `latest` pointer exists for human convenience; deployment references are pinned to the hash so task restarts and rollbacks resolve to the same image every time.

## Known limitations

- HTTP only — no :443 listener or certificate (production would add ACM + a redirect)
- Tasks run in public subnets with public IPs to avoid NAT gateway costs — production shape is private subnets with VPC endpoints for ECR/logs
- ECR tags are MUTABLE (required by the moving `latest`); the hardened variant is IMMUTABLE tags or deploy-by-digest
- The pipeline role's ECS permissions use `Resource: *` — several of the required actions resist resource scoping
- No notifications or alarms yet — the EventBridge → SNS layer and an ECS alarm (successor to Path 1's EC2 status check) are planned

## Repository layout

````
modules/
└── network/          # VPC, public subnets, IGW, routing — shared with Path 1
path2/
├── providers.tf      # AWS provider, S3 backend with native locking, path2 state key
├── variables.tf      # name prefix, path tag, region, desired task count
├── network.tf        # Network module call, task security group, ALB security group
├── ecr.tf            # Repository, scan on push, keep-last-5 lifecycle policy
├── ecs.tf            # Cluster, log group, scoped execution role, task definition, service
├── alb.tf            # ALB, target group (ip target type, /health checks), listener
├── storage.tf        # Pipeline artifact bucket
├── codestar.tf       # GitHub connection
├── codebuild.tf      # Privileged build project, scoped ECR-push role
├── codepipeline.tf   # Three-stage pipeline and its IAM role
└── output.tf         # ALB DNS name, ECR repo URL, network IDs
````

App repository: [cicd-challenge-app](https://github.com/MarkOfV/cicd-challenge-app) — shared with Path 1; adds `Dockerfile` (Corretto 8 base) and `buildspec-path2.yml` (build, tag, push, emit imagedefinitions.json).

## Deploying it yourself

1. Create an S3 bucket for Terraform state and set it in `providers.tf`
2. `terraform init && terraform apply` from `path2/`
3. Authorize the CodeStar connection in the AWS console (one-time manual OAuth step — Terraform cannot do this)
4. Push to the app repo's `main` branch — the pipeline builds the image and rolls it out; the app answers at the ALB DNS name (`terraform output alb_dns_name`), endpoints `/` and `/health`
5. Cost note: Fargate and the ALB bill while running; `terraform apply -var="task_desired_count=0"` stops the task, `terraform destroy` removes everything
````
````
