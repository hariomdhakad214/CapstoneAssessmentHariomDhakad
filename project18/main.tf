# Credential-free resources, so the pipeline can run a real apply without any cloud secrets
resource "local_file" "release_manifest" {
  filename = "${path.module}/release.txt"
  content  = "app_version=${var.app_version}\nenvironment=${var.environment}\n"
}

resource "terraform_data" "deployment" {
  input = var.app_version

  provisioner "local-exec" {
    command = "echo Deploying version ${self.input} to ${var.environment}"
  }
}
