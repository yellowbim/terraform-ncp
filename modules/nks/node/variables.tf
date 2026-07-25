variable "cluster_uuid" {
  description = "NKS cluster UUID where node pools will be created"
  type        = string
}

# variable "subnet_nos" {
#   description = "Map of subnet name to subnet number (used by node pools)"
#   type        = map(string)
# }

variable "node_pools" {
  description = <<DESC
NKS node pool definitions.

Key is the logical node pool name (e.g. service, milvus).
Value defines node pool configuration.

Required fields:
- name            : Node pool name in NKS
- subnet_name     : Subnet name to place nodes
- instance_type   : NCP server spec code
- node_count      : Initial node count

Optional fields:
- labels                  : Kubernetes node labels (map)
- enable_autoscaling      : Enable cluster autoscaler
- autoscaling_min_size    : Minimum node count
- autoscaling_max_size    : Maximum node count
- taints                  : Kubernetes node taints
DESC

  type = map(object({
    name             = string
    subnet_name      = string
    storage_size     = string
    software_code    = string
    server_spec_code = string
    node_count       = number

    labels = optional(map(string))

    enable_autoscaling   = optional(bool)
    autoscaling_min_size = optional(number)
    autoscaling_max_size = optional(number)

    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
  }))
}
