module "rds_postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.13" # Use the latest stable version

  #   maintenance_window = "Mon:00:00-Mon:03:00"
  #   backup_window      = "03:00-06:00"

  identifier               = local.name
  engine                   = "postgres"
  engine_version           = "14" # Specify your desired PostgreSQL version
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  family                   = "postgres14"  # DB parameter group
  major_engine_version     = "14"          # DB option group
  instance_class           = "db.t3.micro" # Choose an appropriate instance class

  allocated_storage     = 20
  max_allocated_storage = 50

  db_name  = "custodian"
  username = "custodian"
  password = "your_secure_password" # Use a secure method for managing secrets
  port     = "5432"

  vpc_security_group_ids = [module.security_group.security_group_id]
  db_subnet_group_name   = module.vpc.database_subnet_group

  tags = {
    Environment       = "Development"
    Project           = "MyApplication"
    Custodian         = "Present"
    CustodianOffHours = "on"
  }
}