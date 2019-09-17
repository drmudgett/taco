# ---------------------------------------------------------------------------------------------------------------------
# Required variables for AWS
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created."
}

variable "aws_account_id" {
  description = "The AWS account to deploy into."
}

# ---------------------------------------------------------------------------------------------------------------------
# Standard Module Required Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "app_id" {
  description = "Core ID of the application."
}

variable "application_name" {
  description = "The name of the application, whether it be a service, website, api, etc."
}

variable "environment" {
  description = "The environment name in which the infrastructure is located. (e.g. dev, test, beta, prod)"
}

variable "development_team_email" {
  description = "The development team email address that is responsible for this resource(s)."
}

variable "infrastructure_team_email" {
  description = "The infrastructure team email address that is responsible for this resource(s)."
}

variable "infrastructure_engineer_email" {
  description = "The infrastructure engineer email address that is responsible for this resource(s)."
}

# ---------------------------------------------------------------------------------------------------------------------
# Infrastructure Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "prefix" {
  description = "Prefix for resource names such as 'blue or green'. This is prefixed to cluster and service names."
  default     = ""
}

variable "ami_override" {
  description = "Use this variable if you want to specify a specific AMI image Id."
  default     = ""
}

variable "vpc_id" {
  description = "VPC Id"
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in."
}

variable "private_ip" {
  description = "If you wish to statically assign an IP for the machine.  This needs to be an IP address that resides in the subnet you have choosen."
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC. Boolean value. (Default: false)"
  default     = false
}

variable "allowed_sg_inbound_cidr_list" {
  description = "CIDR ranges of allowed IPs"
  type        = "list"
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it"
  default     = false
}

variable "detailed_monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled."
  default     = false
}

variable "inbound_security_group_port" {
  description = "The port you want to allow inbound access on the security group."
}

variable "allow_inbound_security_group" {
  description = "The security group you want to allow inbound access to talk to this instance."
}

variable "instance_type" {
  description = "The Instance Type."
}

variable "volume_size" {
  description = "The size of the volume in gibibytes (GiB)."
}

variable "volume_type" {
  description = "The type of volume. Can be 'standard', 'gp2', 'io1', 'sc1', or 'st1'. (Default: 'gp2')."
  default     = "gp2"
}

variable "ebs_volume_count" {
  description = "Count of EBS volumes that will be attached to the instance"
  default     = 0
}

variable "ebs_device_name" {
  type        = "list"
  description = "Name of the EBS device to mount"
  default     = ["/dev/xvdb", "/dev/xvdc", "/dev/xvdd", "/dev/xvde", "/dev/xvdf", "/dev/xvdg", "/dev/xvdh", "/dev/xvdi", "/dev/xvdj", "/dev/xvdk", "/dev/xvdl", "/dev/xvdm", "/dev/xvdn", "/dev/xvdo", "/dev/xvdp", "/dev/xvdq", "/dev/xvdr", "/dev/xvds", "/dev/xvdt", "/dev/xvdu", "/dev/xvdv", "/dev/xvdw", "/dev/xvdx", "/dev/xvdy", "/dev/xvdz"]
}

variable "ebs_volume_type" {
  description = "The type of EBS volume. Can be standard, gp2 or io1"
  default     = "gp2"
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in gigabytes"
  default     = 10
}

variable "ebs_iops" {
  description = "Amount of provisioned IOPS. This must be set with a volume_type of io1"
  default     = 0
}

variable "delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination (Default: true)."
  default     = true
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection."
  default     = false
}

variable "operating_system" {
  description = "Select the operating system you are looking to deploy.  (Available options: linux2, windows)"
}

variable "user_data" {
  description = "Any User Data code that you want to attach to this instance to have the server run on instance creation."
  default     = ""
}

variable "attach_ssm_policy" {
  default     = true
  description = "Default policy for Amazon EC2 Role for Simple Systems Manager service role."
}

variable "create_jumpbox" {
  default     = false
  description = "Set to true to add a rule to the security group to allow SSH or RDP from QL IP's"
}

variable "use_spot" {
  default     = false
  description = "Set to create an EC2 instance from a spot request to save lots of money"
}

# ---------------------------------------------------------------------------------------------------------------------
# Infrastructure Tags
# ---------------------------------------------------------------------------------------------------------------------

variable "devops_support_access" {
  description = "Optional - Defaults to false.  True will grant DevOps Suppport access to this instance(s) via Session Manager."
  default     = false
}

variable "app_tags" {
  type    = "map"
  default = {}
}

variable "key_pair" {
  description = "Select a keypair to assign to the instance during creation"
  default     = ""
}
