output "alb-dns-name" {
  value = aws_alb.django-alb.dns_name
}

output "alb-target-group-arn" {
  value = aws_alb_target_group.django-alb-tg.arn
}