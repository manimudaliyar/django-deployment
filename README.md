# Simple Django App

A very small Django app for deployment demos.

## Endpoints

- `/` → `{"message": "Simple Django deployment demo"}`
- `/health/` → `{"status": "ok"}`

## Project structure

```text
.
├── app/
│   ├── config/
│   ├── core/
│   └── manage.py
└── requirements.txt
```

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cd app
python manage.py runserver
```


## Run tests

```bash
cd app
python manage.py test
```
