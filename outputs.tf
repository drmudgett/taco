output "instance_id" {
  value = "${element(concat(aws_instance.main.*.id, aws_spot_instance_request.main.*.id), 0)}"
}

output "instance_arn" {
  value = "${element(concat(aws_instance.main.*.arn, aws_spot_instance_request.main.*.id), 0)}"
}

output "instance_az" {
  value = "${element(concat(aws_instance.main.*.availability_zone, aws_spot_instance_request.main.*.id), 0)}"
}

output "private_ip" {
  value = "${element(concat(aws_instance.main.*.private_ip, aws_spot_instance_request.main.*.id), 0)}"
}

# output "vpc_security_group_ids" {
#   value = "${element(concat(aws_instance.windows.*.vpc_security_group_ids, aws_instance.linux2.*.vpc_security_group_ids, list("")), 0)}"
# }

output "subnet_id" {
  value = "${element(concat(aws_instance.main.*.subnet_id, aws_spot_instance_request.main.*.subnet_id), 0)}"
}
