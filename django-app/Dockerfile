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

# Set the working directory to the app directory
WORKDIR /app/app

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "config.wsgi:application"]

