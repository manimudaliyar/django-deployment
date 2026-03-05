# Django Deployment — E2E DevOps Project

A simple Django app used to demonstrate an end-to-end production deployment workflow on AWS.

## Tech Stack

- **App** — Django 5.1.1, Gunicorn
- **Containerization** — Docker (multi-stage build)
- **CI/CD** — GitHub Actions
- **Infrastructure** — Terraform (VPC, ALB, ASG, ECR, IAM, CloudWatch)
- **Deployment** — AWS ECS on EC2

## Endpoints

| Endpoint | Response |
|---|---|
| `/` | `{"message": "Simple Django deployment demo"}` |
| `/health/` | `{"status": "ok"}` |

## Project Structure

```
django-app/
├── app/
│   ├── config/         # Django settings, urls, wsgi
│   ├── core/           # App views, tests
│   └── manage.py
├── Dockerfile
├── .dockerignore
├── docker-compose.yml
└── requirements.txt
```

## Run Locally (without Docker)

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cd app
python manage.py runserver
```

## Run Locally (with Docker)

```bash
# Create .env file with the following:
# DJANGO_SECRET_KEY=unsafe-dev-secret-key
# DJANGO_DEBUG=false
# DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1

docker compose up --build
```

App will be available at `http://localhost:8000`

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `DJANGO_SECRET_KEY` | Django secret key | `unsafe-dev-secret-key` |
| `DJANGO_DEBUG` | Debug mode | `false` |
| `DJANGO_ALLOWED_HOSTS` | Allowed hosts | `*` |

## CI/CD Pipeline

> Coming soon — GitHub Actions workflow for automated testing, Docker build, push to ECR and ECS deployment.

## Infrastructure

> Coming soon — Terraform modules for AWS infrastructure provisioning.
