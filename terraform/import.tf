# Terraform variables for handling existing resources
variable "import_existing_resources" {
  description = "Whether to import existing resources instead of creating new ones"
  type        = bool
  default     = true
}

variable "existing_resources" {
  description = "Map of existing resource names to import"
  type = object({
    ecs_task_execution_role_exists = bool
    ecs_task_role_exists           = bool
    ecs_auto_scaling_role_exists   = bool
    vpc_flow_log_role_exists       = bool
    mongo_url_secret_exists        = bool
    db_name_secret_exists          = bool
    backend_ecr_exists             = bool
    frontend_ecr_exists            = bool
    alb_exists                     = bool
    backend_tg_exists              = bool
    frontend_tg_exists             = bool
  })
  default = {
    ecs_task_execution_role_exists = true
    ecs_task_role_exists           = true
    ecs_auto_scaling_role_exists   = true
    vpc_flow_log_role_exists       = true
    mongo_url_secret_exists        = true
    db_name_secret_exists          = true
    backend_ecr_exists             = true
    frontend_ecr_exists            = true
    alb_exists                     = true
    backend_tg_exists              = true
    frontend_tg_exists             = true
  }
}
