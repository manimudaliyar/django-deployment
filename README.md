# django-deployment

![Docker](https://img.shields.io/badge/Docker-Multi--Stage-2496ED?logo=docker) ![Python](https://img.shields.io/badge/Python-3.10-3776AB?logo=python) ![AWS ECR](https://img.shields.io/badge/AWS-ECR-FF9900?logo=amazonaws) ![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=githubactions) ![License](https://img.shields.io/badge/License-MIT-green)

> End-to-end production deployment of a Django app on AWS — containerized with multi-stage Docker builds, served via Gunicorn, and deployed to ECS on EC2 using Terraform, GitHub Actions, and a full production-grade AWS networking stack.

---

## Tech Stack

- **App** — Django 5.1.1, Gunicorn
- **Containerization** — Docker (multi-stage build)
- **CI/CD** — GitHub Actions
- **Infrastructure** — Terraform (VPC, ALB, ASG, ECR, IAM, CloudWatch)
- **Deployment** — AWS ECS on EC2

---

## Endpoints

| Endpoint | Response |
|---|---|
| `/` | `{"message": "Simple Django deployment demo"}` |
| `/health/` | `{"status": "ok"}` |

---

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

---

## Docker Architecture

The Dockerfile uses a multi-stage build:

| Stage | Purpose |
|---|---|
| **Builder** | Installs Python dependencies using full base image |
| **Runtime** | Copies only required artifacts into a slim image |

Security practices applied:
- App runs as a **non-root user** (`django-user`) — created via `groupadd` and `useradd` with explicit `chown` on `/app`
- No secrets baked into the image — all config injected via environment variables at runtime
- `.dockerignore` used to keep build context minimal

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
# Create .env file with the following:
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

## CI/CD Pipeline

> Coming soon — GitHub Actions workflow for automated testing, Docker build, push to ECR and ECS deployment.

---

## Infrastructure

> Coming soon — Terraform modules for AWS infrastructure provisioning.

---

## Author

**Manibharati Mudaliyar**  
[LinkedIn](https://linkedin.com/in/mmudaliyar) · [GitHub](https://github.com/manimudaliyar)