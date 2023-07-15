resource "null_resource" "get_nlb_hostname" {
  provisioner "local-exec" {
    command = "kubectl get service django-app-service -n django-school-management-system --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}' | awk '{print $0\":8000\"}' >> ${path.module}/lb_hostname.txt"
  }
}
