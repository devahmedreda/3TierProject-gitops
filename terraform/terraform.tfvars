########################################
# Terraform Variable Values
########################################

region             = "us-east-1"
project_name       = "taskmaster"
cluster_name       = "taskmaster-eks"
cluster_version    = "1.29"
vpc_cidr           = "10.0.0.0/16"
node_instance_type = "t3.medium"
node_desired_size  = 2
node_min_size      = 1
node_max_size      = 3
