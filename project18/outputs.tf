output "deployed_version" {
  description = "Version deployed by the pipeline"
  value       = var.app_version
}

output "manifest_file" {
  description = "Release manifest written by the apply job"
  value       = local_file.release_manifest.filename
}
