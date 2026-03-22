# =============================================================================
# Dockerfile: Django Application
# =============================================================================
# Multi-stage build to produce a minimal, secure production image.
#
# Stage 1 — builder:
#   Uses full Python 3.10 base image to install dependencies.
#   Heavy build tools stay in this stage and never reach production.
#
# Stage 2 — runtime:
#   Uses python:3.10-slim for a minimal final image (~60% smaller).
#   Copies only installed packages and the gunicorn binary from builder.
#   Runs as a non-root user (django-user) for security.
#
# Security practices:
#   - Non-root user via groupadd and useradd with explicit chown on /app
#   - No secrets baked into the image — injected at runtime via environment variables
#   - --no-cache-dir keeps the builder stage lean
#
# Runtime:
#   Gunicorn serves the Django app on port 8000
#   Entry point: config.wsgi:application
# =============================================================================

# Use an official Python runtime as a parent image
FROM python:3.10 AS builder

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Use a smaller base image for the final stage
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the installed packages from the builder stage
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

# Copy the rest of the application code into the container
COPY . .

# Create a non-root user to run the application
RUN groupadd --system django && useradd --system --group django --create-home django-user \
    && chown -R django-user:django /app

# Switch to the non-root user
USER django-user

# Set the working directory to the app directory
WORKDIR /app/app

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "config.wsgi:application"]
