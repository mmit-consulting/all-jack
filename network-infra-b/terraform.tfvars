aws_region = "us-east-1"

vpc_cidr_block = "10.103.0.0/16"

azs = [
  "us-east-1a",
  "us-east-1b"
]

public_subnet_names = [
  "serverless-dev-public-us-east-1a",
  "serverless-prod-public-us-east-1a",
  "serverless-prod-public-us-east-1b"
]

private_subnet_names = [
  "serverless-dev-private-us-east-1a",
  "serverless-prod-private-us-east-1a",
  "serverless-prod-private-us-east-1b"
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
    name        = "MWT-RDP"
    description = "RDP to MWT IPs"

    ingress = [
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["24.52.124.0/24"]
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
    name        = "default"
    description = "default VPC security group"

    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.223.0.0/16"]
      },
      {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["10.223.0.0/16"]
      },
      {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["10.224.0.0/16"]
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["10.224.0.0/16"]
      },
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.224.0.0/16"]
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["10.223.0.0/16"]
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
    name        = "mwt-datacenter"
    description = "allow all traffic to the mwt datacenter subnet"

    ingress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.223.0.0/16"]
      },
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.224.0.0/16"]
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