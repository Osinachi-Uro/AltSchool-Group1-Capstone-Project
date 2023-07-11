# Create hostedzone
resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

# Attached the subdomain and shows the ALB
resource "aws_route53_record" "schoolapp" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "schoolapp.${var.domain_name}"
  type    = "A"

}
