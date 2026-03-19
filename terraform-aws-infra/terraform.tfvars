vpc-cidr-block = "10.0.0.0/16"
environment = "Dev"
project-owner = "Manibharati Mudaliyar"
subnet-index-public = 1
subnet-index-public-2 = 2
subnet-index-private = 11
subnet-index-private-2 = 12
availability-zone = "ap-south-1a"
availability-zone-2 = "ap-south-1b"
aws-region = "ap-south-1"
retention-in-days = 3
ecs-task-cpu = 256
ecs-task-memory = 512
# django-container-image = "" # Provide the ECR image URI for the Django container here, e.g., "123456789012.dkr.ecr.ap-south-1.amazonaws.com/my-django-app:latest"
container-port = 8000
desired-count = 1
# django-secret-key = "" # Provide a secure random string for the Django secret key, e.g., "s3cr3t_k3y_f0r_dj4ng0"
# Never set this here. Always pass via: terraform apply -var="django-secret-key=${{ secrets.DJANGO_SECRET_KEY }}"