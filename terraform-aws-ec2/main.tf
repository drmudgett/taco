provider "aws" {
  version = "~> 2.9.0"
  region  = "${var.aws_region}"

  allowed_account_ids = ["${var.aws_account_id}"]
}

locals {
  service_name = "${var.prefix == "" ? "" : "${var.prefix}-"}${var.environment}-${var.app_id}-${var.application_name}"

  ebs_iops = "${var.ebs_volume_type == "io1" ? var.ebs_iops : "0"}"

  iac_tags = {
    iac                           = "terraform"
    module                        = "aws-ec2-instance-tf"
    app-id                        = "${var.app_id}"
    environment                   = "${lower(var.environment)}"
    development-team-email        = "${lower(var.development_team_email)}"
    infrastructure-team-email     = "${lower(var.infrastructure_team_email)}"
    infrastructure-engineer-email = "${lower(var.infrastructure_engineer_email)}"
    devops-support                = "${var.devops_support_access ? "true" : "false"}"
  }
}

data "aws_subnet" "main" {
  id = "${var.subnet_id}"
}

data "aws_ami" "linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Windows Reference:  https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/windows-ami-version-history.html#amis-2019
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "template_file" "ssm_policy" {
  template = "${file("${path.module}/files/ssm-policy.json")}"

  vars {
    aws_region = "${var.aws_region}"
  }
}

resource "aws_iam_instance_profile" "main" {
  name = "profile-${local.service_name}"
  role = "${aws_iam_role.main.name}"

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "aws_iam_role" "main" {
  name        = "role-${local.service_name}"
  description = "Role for ${local.service_name}"
  path        = "/iac/ec2/"

  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_role_policy" "ssm-attach" {
  count  = "${var.attach_ssm_policy}"
  name   = "${"policy-ssm-${var.aws_region}"}"
  policy = "${data.template_file.ssm_policy.rendered}"
  role   = "${aws_iam_role.main.name}"
}

resource "aws_security_group" "main" {
  description = "Security group for ${local.service_name}"
  name        = "securitygroup-${local.service_name}"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "jumpbox_windows" {
  count             = "${var.create_jumpbox ? 1 : 0}"
  type              = "ingress"
  from_port         = "${var.operating_system == "linux2" ? 22 : 3389}"
  to_port           = "${var.operating_system == "linux2" ? 22 : 3389}"
  protocol          = "tcp"
  cidr_blocks       = [${var.allowed_sg_inbound_cidr_list}]
  security_group_id = "${aws_security_group.main.id}"
}

resource "aws_security_group_rule" "allow_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.main.id}"
}

resource "aws_security_group_rule" "allow_inbound_security_group" {
  count                    = "${(var.allow_inbound_security_group == "") ? 0 : 1}"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.main.id}"
  from_port                = "${var.inbound_security_group_port}"
  to_port                  = "${var.inbound_security_group_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.allow_inbound_security_group}"
}

resource "aws_instance" "main" {
  count                = "${1 - var.use_spot}"
  iam_instance_profile = "${aws_iam_instance_profile.main.name}"

  ami = "${
    var.ami_override != "" ?
    var.ami_override :
    var.operating_system == "windows" ?
    data.aws_ami.windows.id :
    data.aws_ami.linux2.id
  }"

  instance_type                        = "${var.instance_type}"
  tenancy                              = "default"
  monitoring                           = "${var.detailed_monitoring}"
  disable_api_termination              = "${var.disable_api_termination}"
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = "${var.key_pair}"

  ebs_optimized = "${var.ebs_optimized}"

  root_block_device {
    volume_type = "${var.volume_type}"
    volume_size = "${var.volume_size}"
  }

  vpc_security_group_ids      = ["${aws_security_group.main.id}"]
  subnet_id                   = "${var.subnet_id}"
  private_ip                  = "${var.private_ip}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${var.user_data}"

  tags = "${
    merge(
      var.app_tags,
      local.iac_tags,
      map(
        "Name", "${local.service_name}"
      )
  )}"
}

resource "aws_spot_instance_request" "main" {
  count                = "${var.use_spot ? 1 : 0}"
  iam_instance_profile = "${aws_iam_instance_profile.main.name}"

  ami = "${
    var.ami_override != "" ?
    var.ami_override :
    var.operating_system == "windows" ?
    data.aws_ami.windows.id :
    data.aws_ami.linux2.id
  }"

  instance_type                        = "${var.instance_type}"
  tenancy                              = "default"
  monitoring                           = "${var.detailed_monitoring}"
  disable_api_termination              = "${var.disable_api_termination}"
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = "${var.key_pair}"

  ebs_optimized = "${var.ebs_optimized}"

  root_block_device {
    volume_type = "${var.volume_type}"
    volume_size = "${var.volume_size}"
  }

  vpc_security_group_ids      = ["${aws_security_group.main.id}"]
  subnet_id                   = "${var.subnet_id}"
  private_ip                  = "${var.private_ip}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${var.user_data}"

  tags = "${
    merge(
      var.app_tags,
      local.iac_tags,
      map(
        "Name", "${local.service_name}"
      )
  )}"
}

resource "aws_ebs_volume" "main" {
  count             = "${var.ebs_volume_count}"
  availability_zone = "${data.aws_subnet.main.availability_zone}"
  size              = "${var.ebs_volume_size}"
  iops              = "${local.ebs_iops}"
  type              = "${var.ebs_volume_type}"
  tags              = "${merge(var.app_tags, local.iac_tags)}"
}

resource "aws_volume_attachment" "default" {
  count       = "${var.ebs_volume_count}"
  device_name = "${element(var.ebs_device_name, count.index)}"
  volume_id   = "${element(aws_ebs_volume.main.*.id, count.index)}"
  instance_id = "${aws_instance.main.id}"
}

