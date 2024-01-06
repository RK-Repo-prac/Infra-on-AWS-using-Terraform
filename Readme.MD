Here is a more comprehensive README explaining each component in more detail:

# Terraform AWS Infrastructure Project

This project leverages Terraform to deploy a networking infrastructure and sample web application on AWS. 

## Why Terraform

Terraform allows us to manage infrastructure as code. Key benefits:

- **Infrastructure as Code**: The infrastructure is defined via code (`.tf` files) enabling version control, reuse, and collaboration
- **Execution Plans**: Terraform creates an execution plan before applying changes, allowing verification before altering infrastructure
- **State Management**: Terraform maintains state to consistently manage infrastructure changes 

## Components

### VPC 

The **VPC** resource defines a new VPC with a `10.1.0.0/16` CIDR block to host our infrastructure.

A VPC forms an isolated network environment and provides control over settings like IP ranges, subnets, route tables, etc. This new custom VPC gives us an empty network sandbox to build our infrastructure in.

### Public Subnets

2 new **public subnets** are created within our VPC:
    
- `10.1.0.0/24` in availability zone `us-east-1a`  
- `10.1.1.0/24` in availability zone `us-east-1b`

Public subnets have a route table that targets an internet gateway to allow outbound internet connectivity. We distribute the subnets across zones for high availability. 

### Internet Gateway

An **internet gateway** resource is created and attached to the VPC.

This powers outbound connectivity for public subnets and allows our infrastructure to connect with external services.

### Route Table
    
A custom **route table** is created targeting the internet gateway. 

The route table routes all external traffic `0.0.0.0/0` to the internet gateway, enabling internet access.

**Associations** connect this route table to each public subnet.

### Security Group

A **security group** resource permits:  

- SSH ingress from `0.0.0.0/0` (port 22)
- HTTP ingress from `0.0.0.0/0` (port 80)  

This allows external traffic to reach the EC2 instances via SSH and HTTP.

### S3 Bucket

An **S3 bucket** to store web assets. The user data scripts do not utilize this currently but can be configured to sync content.

### EC2 Instances

**EC2 instance** resources create Ubuntu 20.04 t2.micro instances in each public subnet.

The instances run Apache and deploy an `index.html` page showing the instance ID, powered by **user data** scripts.

#### user_data.sh

This script:

- Updates `apt` and installs `apache2`
- Prints out the instance ID 
- Deploys an `index.html` page that displays the instance ID
- Starts Apache and enables it to run on boot
          
The user data executes on instance first boot to automatically configure our web server.

### Application Load Balancer 

An **ALB** resource distributes traffic across EC2 instances. Listen rules forward HTTP requests to the EC2 target group.

This provides high availability for the sample web app across 2 AZs.   

The **output** exports the DNS name to access the ALB endpoint.

