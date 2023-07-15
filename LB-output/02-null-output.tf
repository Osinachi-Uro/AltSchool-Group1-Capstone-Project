data "local_file" "lb_hostname"{
  filename = "${path.module}/lb_hostname.txt"
  depends_on = [
    null_resource.get_nlb_hostname
  ]
}

output "load_balancer_name" {
  value = data.local_file.lb_hostname.content
}
