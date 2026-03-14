# IAM roles and policies for ECS task execution and task role

# Policy document for ECS task execution role trust relationship
data "aws_iam_policy_document" "ecs-trust-policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Policy document for ECS task role to allow access to Secrets Manager
data "aws_iam_policy_document" "secrets-manager-policy" {
  statement {
    effect = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs-execution-role" {
    name = "${var.environment}-ecs-execution-role"
    assume_role_policy = data.aws_iam_policy_document.ecs-trust-policy.json
    tags = merge(
        local.common_tags,
        {
        Name = "${var.environment}-ecs-execution-role"
        }
    )
}

# IAM role for ECS task role
resource "aws_iam_role" "ecs-task-role" {
    name = "${var.environment}-ecs-task-role"
    assume_role_policy = data.aws_iam_policy_document.ecs-trust-policy.json
    tags = merge(
        local.common_tags,
        {
        Name = "${var.environment}-ecs-task-role"
        }
    )
}

# Attach the AmazonECSTaskExecutionRolePolicy to the ECS execution role
resource "aws_iam_role_policy_attachment" "execution-role-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role = aws_iam_role.ecs-execution-role.name
}

# Create a custom policy for Secrets Manager access and attach it to the ECS task role
resource "aws_iam_policy" "secrets-manager-policy" {
  name = "${var.environment}-secrets-manager-policy"
  policy = data.aws_iam_policy_document.secrets-manager-policy.json
}

# Attach the custom Secrets Manager policy to the ECS task role
resource "aws_iam_role_policy_attachment" "task-role-attachment" {
    role = aws_iam_role.ecs-task-role.name
    policy_arn = aws_iam_policy.secrets-manager-policy.arn
}