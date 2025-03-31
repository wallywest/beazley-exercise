locals {
    namespace = "three-tier"
    environment = "production"
    tags = {
        Terraform = "true"
        Environment = local.environment
    }
  cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name = "${local.namespace}-${local.environment}-sg"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = []
  ingress_rules       = []
  egress_rules        = ["all-all"]

  tags = local.tags
}

module "server" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${local.namespace}-${local.environment}-server"
  instance_type = "t3.nano"
  ami           = data.aws_ssm_parameter.al2.value
  subnet_id              = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids = [module.security_group.security_group_id]

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.tags
}


# module "database" {
#   source  = "terraform-aws-modules/rds-aurora/aws"
#   name = "${local.namespace}-${local.environment}-db"
#   engine                      = "aurora-postgresql"
#   engine_version              = "16"
#   master_username             = "pg_admin"
#   instance_class = "db.t3.medium" 
#   cluster_monitoring_interval = 30

#   # Disable creation of security group - provide a security group
#   create_security_group = true

#   instances = {
#     one = {}
#   }

#   vpc_id               = module.vpc.vpc_id
#   db_subnet_group_name = module.vpc.database_subnet_group_name

#   security_group_rules = {
#     vpc_ingress = {
#       cidr_blocks = module.vpc.private_subnets_cidr_blocks
#     }
#     egress_example = {
#       type        = "egress"
#       cidr_blocks = module.vpc.private_subnets_cidr_blocks
#       description = "Egress to corporate printer closet"
#     }
#   }

#   apply_immediately   = true
#   skip_final_snapshot = true


#   enabled_cloudwatch_logs_exports = ["postgresql"]
#   create_cloudwatch_log_group     = true


#   create_db_parameter_group      = true
#   db_parameter_group_name        = "${local.namespace}-${local.environment}-db-parameter-group"
#   db_parameter_group_family      = "aurora-postgresql16"
#   db_parameter_group_description = "DB parameter group"

#   tags = local.tags
# }

# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "9.14.0"

#   name = "${local.namespace}-${local.environment}-alb"

#   vpc_id = module.vpc.vpc_id
#   subnets = module.vpc.public_subnets

#   enable_deletion_protection = false

#   target_groups = {
#     instance = {
#         name_prefix = "server"
#         protocol = "HTTP"
#         port = 80
#         target_type = "instance"
#         target_id = module.server.id
#     }
#   }

#   # Security Group
#   security_group_ingress_rules = {
#     all_http = {
#       from_port   = 80
#       to_port     = 82
#       ip_protocol = "tcp"
#       description = "HTTP web traffic"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#     all_https = {
#       from_port   = 443
#       to_port     = 445
#       ip_protocol = "tcp"
#       description = "HTTPS web traffic"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#   }
#   security_group_egress_rules = {
#     all = {
#       ip_protocol = "-1"
#       cidr_ipv4   = module.vpc.vpc_cidr_block
#     }
#   }
# }


# resource aws_security_group_rule "allow_ingress_alb" {
#     description = "allow ingress from alb to instance"
#     security_group_id = module.security_group.security_group_id
#     source_security_group_id = module.alb.security_group_id

#     type = "ingress"

#     from_port         = 80
#     to_port           = 80
#     protocol          = "tcp"
# }
