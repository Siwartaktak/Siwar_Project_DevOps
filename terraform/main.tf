terraform {
  required_version = ">= 1.0"
}

resource "local_file" "status" {
  filename = "${path.module}/deployment-status.txt"
  content  = "Deployed at: ${timestamp()}"
}

output "status" {
  value = "Terraform deployment successful"
}
