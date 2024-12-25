variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "subnet_ranges" {
  description = "List of CIDR ranges for subnets"
  type        = list(string)
}

variable "general_pool_machine_type" {
  description = "Machine type for the general workload node pool"
  type        = string
}

variable "general_pool_node_count" {
  description = "Number of nodes in the general workload node pool"
  type        = number
}

variable "cpu_pool_machine_type" {
  description = "Machine type for the CPU-intensive node pool"
  type        = string
}

variable "cpu_pool_node_count" {
  description = "Number of nodes in the CPU-intensive node pool"
  type        = number
}