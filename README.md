# Node.js Application Deployment on AWS ECS (EC2) using Terraform & GitHub Actions

## Overview

This project demonstrates a **production-style CI/CD deployment** of a **Node.js application** on **AWS Elastic Container Service (ECS) using EC2 launch type**, with the entire infrastructure managed through **Terraform** and application deployments automated using **GitHub Actions**.

The application is containerized using Docker, stored in Amazon ECR, and deployed to an ECS EC2 cluster backed by an Auto Scaling Group. The GitHub Actions pipeline builds the Docker image, pushes it to ECR, and triggers a Terraform deployment to roll out the new version.

---

## High-Level Architecture

The solution consists of the following components:

- Custom VPC with public and private subnets across multiple AZs
- Internet Gateway and NAT Gateways for controlled outbound access
- Application Load Balancer (ALB) for traffic distribution
- ECS Cluster using **EC2 capacity providers**
- Auto Scaling Group with Launch Template for ECS container instances
- Amazon ECR for Docker image storage
- Amazon EFS for shared persistent storage
- GitHub Actions for CI/CD automation
- Terraform as the single source of truth for infrastructure

---

## Networking Infrastructure

- **VPC**
  - CIDR block: `10.0.0.0/16`

- **Subnets**
  - Public Subnet A (`us-west-2a`) – `10.0.1.0/24`
  - Private Subnet A (`us-west-2a`) – `10.0.2.0/24`
  - Public Subnet B (`us-west-2b`) – `10.0.3.0/24`
  - Private Subnet B (`us-west-2b`) – `10.0.4.0/24`

- **Routing**
  - Internet Gateway attached to VPC
  - NAT Gateways in public subnets
  - Public route table routes traffic to IGW
  - Private route tables route traffic through NAT Gateways

---

## Node.js Application & Docker Configuration

- Simple Node.js HTTP application
- Application listens on **port 5000**
- `node_modules` excluded from the repository
- Dockerfile highlights:
  - Base image: `node:18-alpine`
  - Working directory: `/usr/src/app`
  - Dependencies installed using `npm install`
  - Application files copied during build
  - Container exposes port `5000`
  - Application started using `node index.js`

---

## AWS Credentials & Security

- AWS credentials stored securely as **GitHub Actions secrets**:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- Credentials are injected into the pipeline using `configure-aws-credentials@v2`
- No secrets are hard-coded or exposed in logs

---

## Elastic File System (EFS)

- EFS file system created with encryption enabled
- Access Point configured with:
  - POSIX UID/GID: `1000`
  - Permissions: `0755`
- Mount targets created in **private subnets** across both AZs
- Used by ECS tasks for shared persistent storage

---

## Load Balancer & Compute Infrastructure

### Application Load Balancer
- Internet-facing ALB
- IPv4 addressing
- Listener on **HTTP port 80**
- Forwards traffic to ECS target group
- No static target registration (targets are auto-registered by ECS)

### EC2 Launch Template
- Amazon Linux 2023 ECS-optimized AMI
- Instance type: `t3.micro`
- Attached security group for ECS instances
- Used by Auto Scaling Group

### Auto Scaling Group
- Desired capacity: 2
- Minimum: 1, Maximum: 3
- Deployed in private subnets
- Integrated with ALB target group

---

## Amazon ECR

- Docker image repository created:
  - Name: `task13/zaeem`
  - Tag mutability: Mutable
  - Encryption: AES-256
- Images are tagged using **Git commit SHA** for traceability

---

## ECS Configuration

### ECS Cluster
- Launch type: **EC2**
- Capacity provider backed by Auto Scaling Group
- Container Insights enabled

### Task Definition
- Family: `Task13-ECS-TD-Zaeem`
- CPU: 2 vCPU
- Memory: 4 GB
- Container:
  - Name: `NodeJS-App`
  - Image pulled from ECR
  - Port mapping: `5000/TCP`
- IAM task role and execution role configured
- EFS volume mounted via access point

### ECS Service
- Launch type: EC2
- Desired tasks: 2
- Scheduling strategy: Replica
- Deployment type: Rolling updates
- Integrated with ALB and target group

---

## CI/CD Pipeline (GitHub Actions + Terraform)

The GitHub Actions workflow is triggered on every push to the `main` branch and performs the following steps:

1. Checkout source code
2. Configure AWS credentials
3. Authenticate Docker with Amazon ECR
4. Build Docker image using Dockerfile
5. Push image to ECR with commit SHA as tag
6. Store image tag as a variable for Terraform
7. Setup Terraform on the runner
8. Initialize Terraform in `./Terraform` directory
9. Run `terraform apply -auto-approve` with the new image tag
10. Terraform updates the ECS task definition and service
11. ECS performs a rolling deployment of the new version

Terraform remains the **only tool responsible for infrastructure changes**, ensuring zero configuration drift.

---

## Deployment Verification

- Verify ECS service shows the desired number of running tasks
- Confirm new task definition revision is active
- Access the application using the **ALB DNS name**
- Ensure healthy targets are registered in the target group

---

## Rollback Strategy

### Fast Rollback
- Update ECS service to a previous task definition revision from the AWS Console

### Clean Rollback (Recommended)
- Revert to a previous stable Git commit
- Push changes to `main`
- GitHub Actions triggers Terraform deployment automatically

---

## Key Learnings

- Terraform should be the single source of truth for ECS infrastructure
- CI/CD pipelines should never mutate Terraform-managed resources directly
- ECS EC2 target groups auto-register instances dynamically
- EFS provides shared persistent storage for ECS tasks
- Image tagging using commit SHAs enables clean rollbacks and traceability
- Separating infrastructure and application deployment simplifies operations

---

## Technologies Used

- AWS ECS (EC2 launch type)
- Amazon ECR
- Amazon EFS
- Application Load Balancer
- Auto Scaling Group
- Docker
- Terraform
- GitHub Actions
- Node.js

---

## Author

**Zaeem Attique Ashar**  
Cloud Intern
