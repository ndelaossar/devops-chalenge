locals {
  region      = "us-east-1"
  cidr_block  = local.cidr_blocks_envs["${terraform.workspace}"]
  cidr_blocks_envs = {
    "dev" = "10.0.0.0/16" ,
    "qa" = "10.1.0.0/16"
  }
  azs         = slice(data.aws_availability_zones.available.names, 0, 3)
  common_tags = {
    "Environment" = terraform.workspace
    "Project" = "Devops Challenge"
  }

   user_data = <<-EOT
    yum update -y && yum install nginx
    echo "Hello Terraform!" > /var/www/html/index.html
  EOT

}
