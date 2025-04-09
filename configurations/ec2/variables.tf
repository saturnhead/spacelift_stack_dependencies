variable "instances" {
  type = map(object({
    instance_type = optional(string, "t2.micro")
    tags          = optional(map(string), {})
    subnet_name   = string
  }))
  default = {
    instance1 = {
      tags        = { "Env" : "dev" }
      subnet_name = "public-subnet-1"
    }
    instance2 = {
      tags        = { "Env" : "dev" }
      subnet_name = "public-subnet-1"
    }
    instance3 = {
      tags        = { "Env" : "qa" }
      subnet_name = "public-subnet-2"
    }
    instance4 = {
      tags        = { "Env" : "prod" }
      subnet_name = "public-subnet-2"
    }
  }
}

variable "subnets" {
  type = map(string)
}
