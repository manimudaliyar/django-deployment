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
```
Developer Push
      │
      ▼
GitHub Actions CI
  ├── Run tests
  ├── Build Docker image (multi-stage)
  └── Push to ECR
      │
      ▼
GitHub Actions CD (Terraform)
  ├── terraform plan
  └── terraform apply
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
|---|---|
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
|---|---|
| `/` | `{"message": "Simple Django deployment demo"}` |
| `/health/` | `{"status": "ok"}` |

---

## Project Structure
```
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
│   ├── modules/
│   │   ├── vpc/            # VPC, subnets, IGW, NAT Gateways
│   │   ├── security/       # ALB and ECS security groups
│   │   ├── iam/            # ECS execution and task roles
│   │   ├── alb/            # ALB, target group, listener
│   │   └── ecs/            # ECS cluster, task definition, service
│   ├── backend/            # S3 + DynamoDB for remote state
│   ├── main.tf
│   ├── variables.tf
│   ├── backend.tf
│   └── terraform.tfvars
└── .github/
    └── workflows/
        ├── ci-cd.yml       # Test, build, push to ECR
        └── infra.yml       # Terraform plan and apply
```

---

## Docker Architecture

Two stage build:

| Stage | Purpose |
|---|---|
| Builder | Installs Python dependencies using full base image |
| Runtime | Copies only required artifacts into a slim image |

Security practices:
- Non-root user (`django-user`) via `groupadd` and `useradd`
- No secrets baked into the image — injected at runtime via environment variables
- `.dockerignore` keeps build context minimal
- 60% smaller final image size vs single-stage build

---

## Terraform Infrastructure

Five modules, each self-contained with its own inputs and outputs:

| Module | Resources |
|---|---|
| `vpc` | VPC, 2 public subnets, 2 private subnets, IGW, 2 NAT Gateways, route tables |
| `security` | ALB security group, ECS security group |
| `iam` | ECS task execution role, ECS task role, Secrets Manager policy |
| `alb` | Application Load Balancer, target group, HTTP listener |
| `ecs` | ECS cluster, task definition, Fargate service, CloudWatch log group |

Remote state stored in S3 with DynamoDB state locking.

---

## CI/CD Pipeline

> Pipeline design is complete. Full end-to-end automation is in progress.

Two separate workflows:

**`ci-cd.yml`** — triggered on push to `main`
```
test → build → push to ECR
```

**`infra.yml`** — triggered via `workflow_dispatch`
```
terraform plan → (manual approval) → terraform apply
```

Planned integrations:
- OIDC authentication between GitHub Actions and AWS — no long-lived access keys
- Image URI passed automatically from CI to Terraform at deploy time
- Path-based triggers to run infra pipeline only on Terraform changes

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
|---|---|---|
| `DJANGO_SECRET_KEY` | Django secret key | `unsafe-dev-secret-key` |
| `DJANGO_DEBUG` | Debug mode | `false` |
| `DJANGO_ALLOWED_HOSTS` | Allowed hosts | `*` |

---

## Author

**Manibharati Mudaliyar**
[LinkedIn](https://linkedin.com/in/mmudaliyar) · [GitHub](https://github.com/manimudaliyar)