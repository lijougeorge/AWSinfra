output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "efs_mount_target_id" {
  value = [for mt in values(aws_efs_mount_target.efs_mount_target) : mt.id]
}

output "efs_dns" {
  value = aws_efs_file_system.efs.dns_name
}