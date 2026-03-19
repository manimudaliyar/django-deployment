# django-deployment

![Docker](https://img.shields.io/badge/Docker-Multi--Stage-2496ED?logo=docker)
![Python](https://img.shields.io/badge/Python-3.10-3776AB?logo=python)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform)
![AWS ECS](https://img.shields.io/badge/AWS-ECS_Fargate-FF9900?logo=amazonaws)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=githubactions)
![License](https://img.shields.io/badge/License-MIT-green)

> End-to-end deployment of a Django app on AWS ECS Fargate — containerized with
> multi-stage Docker builds, provisioned with Terraform, and deployed via GitHub Actions.
> No manual steps. No hardcoded secrets. Plan before every apply.

---

## Architecture

```bash
Developer Push
      │
      ▼
GitHub Actions CI (django-app/** changes)
  ├── Run tests
  ├── Build Docker image (multi-stage)
  ├── Push to ECR
  └── ECS update-service (rolling deploy)
      │
      ▼
GitHub Actions CD (terraform-aws-infra/** changes)
  ├── terraform plan
  └── terraform apply (manual approval required)
      │
      ▼
AWS Infrastructure
  ┌─────────────────────────────────────┐
  │            VPC (10.0.0.0/16)        │
  │                                     │
  │  Public Subnets (AZ-a, AZ-b)        │
  │  ┌─────────────────────────────┐    │
  │  │   Application Load Balancer │    │
  │  │       (port 80)             │    │
  │  └────────────┬────────────────┘    │
  │               │                     │
  │  Private Subnets (AZ-a, AZ-b)       │
  │  ┌────────────▼────────────────┐    │
  │  │     ECS Fargate Tasks       │    │
  │  │   Django + Gunicorn :8000   │    │
  │  └─────────────────────────────┘    │
  │                                     │
  │  NAT Gateways → ECR, Secrets,       │
  │                 CloudWatch          │
  └─────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| App | Django 5.1.1, Gunicorn |
| Containerization | Docker (multi-stage build) |
| Registry | AWS ECR |
| CI/CD | GitHub Actions (OIDC auth) |
| Infrastructure | Terraform |
| Compute | AWS ECS Fargate |
| Networking | VPC, ALB, NAT Gateway, Security Groups |
| Secrets | AWS Secrets Manager |
| Observability | CloudWatch Logs |

---

## Endpoints

| Endpoint | Response |
| --- | --- |
| `/` | `{"message": "Simple Django deployment demo"}` |
| `/health/` | `{"status": "ok"}` |

---

## Project Structure

```bash
django-deployment/
├── django-app/
│   ├── app/
│   │   ├── config/         # Django settings, urls, wsgi
│   │   ├── core/           # App views, tests
│   │   └── manage.py
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── docker-compose.yml
│   └── requirements.txt
├── terraform-aws-infra/
│   ├── bootstrap/          # OIDC provider and GHA role — apply once, never destroy
│   ├── backend/            # S3 + DynamoDB for remote state — apply once, never destroy
│   ├── modules/
│   │   ├── vpc/            # VPC, subnets, IGW, NAT Gateways
│   │   ├── security/       # ALB and ECS security groups
│   │   ├── iam/            # ECS execution and task roles
│   │   ├── alb/            # ALB, target group, listener
│   │   ├── ecs/            # ECS cluster, task definition, service
│   │   └── secrets/        # Secrets Manager secret and version
│   ├── main.tf
│   ├── variables.tf
│   ├── backend.tf
│   └── terraform.tfvars
└── .github/
    └── workflows/
        ├── ci-cd.yml       # Test, build, push to ECR, deploy to ECS
        └── infra.yml       # Terraform plan and apply
```

---

## Docker Architecture

Two stage build:

| Stage | Purpose |
| --- | --- |
| Builder | Installs Python dependencies using full base image |
| Runtime | Copies only required artifacts into a slim image |

Security practices:

- Non-root user (`django-user`) via `groupadd` and `useradd`

- No secrets baked into the image — injected at runtime via environment variables
- `.dockerignore` keeps build context minimal
- 60% smaller final image size vs single-stage build

---

## Terraform Infrastructure

Six modules, each self-contained with its own inputs and outputs:

| Module | Resources |
| --- | --- |
| `vpc` | VPC, 2 public subnets, 2 private subnets, IGW, 2 NAT Gateways, route tables |
| `security` | ALB security group, ECS security group |
| `iam` | ECS task execution role, ECS task role, Secrets Manager policy |
| `alb` | Application Load Balancer, target group, HTTP listener |
| `ecs` | ECS cluster, task definition, Fargate service, CloudWatch log group |
| `secrets` | Secrets Manager secret and secret version |

Remote state stored in S3 with DynamoDB state locking.

---

## CI/CD Pipeline

Two separate workflows, each triggered only when relevant files change:

**`ci-cd.yml`** — triggered on push to `main` when `django-app/**` changes

```bash
test → build → push to ECR → ecs update-service
```

**`infra.yml`** — triggered on push to `main` when `terraform-aws-infra/**` changes

```bash
terraform plan → manual approval → terraform apply
```

Key design decisions:

- Path-based triggers — infra pipeline only runs on infra changes, app pipeline only runs on app changes
- OIDC authentication between GitHub Actions and AWS — no long-lived access keys stored in GitHub Secrets
- Image URI passed automatically from CI to ECS via `aws ecs update-service --force-new-deployment`
- Terraform never needs to know the image URI for redeployments — ECS and Terraform are separate concerns
- Secret values passed to Terraform at apply time via `-var` flag from GitHub Secrets — never stored in tfvars
- Terraform outputs (cluster name, service name) stored as GitHub repository variables after apply
- Plan before every apply — non-negotiable

---

## Secrets Management

Django secrets are stored in AWS Secrets Manager and fetched by ECS tasks at runtime.

```bash
GitHub Secrets (DJANGO_SECRET_KEY)
        ↓
-var flag at terraform apply
        ↓
AWS Secrets Manager
        ↓
ECS Task fetches at runtime via task role
```

Secret values are never stored in `tfvars` or committed to the repository.

---

## First Time Setup

This project requires a one-time manual bootstrap before the pipelines can run:

```bash
1. cd bootstrap/ → terraform init → terraform apply
   Copy gha-oidc-role-arn → store as GitHub variable AWS_ROLE_TO_ASSUME

2. cd backend/ → terraform init → terraform apply
   Creates S3 bucket and DynamoDB table for remote state

3. Trigger ci-cd.yml manually via workflow_dispatch (deploy: false)
   Builds and pushes image to ECR without deploying

4. Trigger infra.yml manually via workflow_dispatch
   Provide the ECR image URI from step 3 as input

5. Approve the apply in GitHub Environments → production
   Infrastructure is provisioned, app is live
```

From this point forward all deployments are automated on push.

---

## Run Locally (without Docker)

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cd app
python manage.py runserver
```

---

## Run Locally (with Docker)

```bash
# Create .env file with:
# DJANGO_SECRET_KEY=unsafe-dev-secret-key
# DJANGO_DEBUG=false
# DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1

docker compose up --build
```

App will be available at `http://localhost:8000`

---

## Environment Variables

| Variable | Description | Default |
| --- | --- | --- |
| `DJANGO_SECRET_KEY` | Django secret key | `unsafe-dev-secret-key` |
| `DJANGO_DEBUG` | Debug mode | `false` |
| `DJANGO_ALLOWED_HOSTS` | Allowed hosts | `*` |

---

## Author

**Manibharati Mudaliyar**
[LinkedIn](https://linkedin.com/in/mmudaliyar) · [GitHub](https://github.com/manimudaliyar)
