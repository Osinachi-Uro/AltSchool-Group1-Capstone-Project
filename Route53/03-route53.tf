# Create hostedzone
resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}


resource "null_resource" "get_nlb_hostname" {
  provisioner "local-exec" {
    command = "kubectl get service django-app-service -n django-school-management-system --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}' | awk '{print $0\":8000\"}' >> ${path.module}/lb_hostname.txt"
  }
}

data "local_file" "lb_hostname"{
  filename = "${path.module}/lb_hostname.txt"
  depends_on = [
    null_resource.get_nlb_hostname
  ]
}

output "load_balancer_name" {
  value = data.local_file.lb_hostname.content
}

# IF YOU WANT TO USE type = "CNAME"
resource "aws_route53_record" "eks_lb_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "schoolapp.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [data.local_file.lb_hostname.content]

  depends_on = [
    null_resource.get_nlb_hostname,
    data.local_file.lb_hostname
  ]

}

# # IF YOU WANT TO USE type = "A"
# data "aws_lb" "eks_lb" {
#   name   = data.local_file.lb_hostname.content
#   region = var.region

#   depends_on = [
#     null_resource.get_nlb_hostname,
#     data.local_file.lb_hostname
#   ]

# }


# # IF YOU WANT TO USE type = "A"
# resource "aws_route53_record" "eks_lb_record" {
#   zone_id = aws_route53_zone.hosted_zone.zone_id
#   name    = "schoolapp.${var.domain_name}"
#   ttl     = "300"
#   type    = "A"

#   alias {
#     name                   = data.aws_lb.eks_lb.name
#     zone_id                = data.aws_lb.eks_lb.zone_id
#     evaluate_target_health = false
#   }

#   depends_on = [
#     null_resource.get_nlb_hostname,
#     data.local_file.lb_hostname,
#     data.aws_lb.eks_lb
#   ]

# }



# Create ACM certificate
resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = "schoolapp.${var.domain_name}"
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation record
resource "aws_route53_record" "acm_validation" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = aws_acm_certificate.acm_certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.acm_certificate.domain_validation_options.0.resource_record_type
  ttl     = 300
  records = [aws_acm_certificate.acm_certificate.domain_validation_options.0.resource_record_value]

  depends_on = [
    aws_route53_record.eks_lb_record
  ]
}

# Certificate validation
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [aws_route53_record.acm_validation.fqdn]
}
