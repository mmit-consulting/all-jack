aws_region = "us-east-1"

vpc_cidr_block = "10.103.0.0/16"

azs = [
  "us-east-1a",
  "us-east-1b"
]

public_subnets = [
  "10.103.101.0/24", # serverless dev public 1a
  "10.103.102.0/24", # serverless prod public 1a
  "10.103.103.0/24", # serverless prod public 1b
]

private_subnets = [
  "10.103.1.0/24", # serverless dev private 1a
  "10.103.2.0/24", # serverless prod private 1a
  "10.103.3.0/24", # serverless prod private 1b
]

tags = {
  application  = "vpcnetwork"
  owner        = "jmezinko"
  name         = "ecom-serverless"
  environment  = "prod"
  department   = "infrastructure"
  businessunit = "midwesttape"
}


#### Security Group ####

security_groups = [
  {
    name        = "serverless-dev"
    description = "Security group for serverless dev"

    ingress = [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]

    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  },

  {
    name        = "serverless-prod"
    description = "Security group for serverless prod"

    ingress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]

    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
]
