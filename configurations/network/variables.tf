variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    cidr_block = string
    tags       = map(string)
  }))
  default = {
    stack-dep-vpc = {
      cidr_block = "10.0.0.0/16"
      tags       = { Environment = "Production" }
    }
  }
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    vpc_key                 = string
    cidr_block              = string
    map_public_ip_on_launch = bool
    tags                    = map(string)
  }))
  default = {
    public-subnet-1 = {
      vpc_key                 = "stack-dep-vpc"
      cidr_block              = "10.0.1.0/24"
      map_public_ip_on_launch = true
      tags                    = { Type = "Public" }
    },
    public-subnet-2 = {
      vpc_key                 = "stack-dep-vpc"
      cidr_block              = "10.0.2.0/24"
      map_public_ip_on_launch = true
      tags                    = { Type = "Public" }
    }
  }
}
