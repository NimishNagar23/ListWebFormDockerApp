output "lb_dns_name" {
  value = aws_lb.main.dns_name
}

output "target_group_arn_backend" {
  value = aws_lb_target_group.backend.arn
}

output "target_group_arn_frontend" {
  value = aws_lb_target_group.frontend.arn
}
