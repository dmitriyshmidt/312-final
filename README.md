# Minecraft Server on AWS with Terraform and Bash

## Overview
This project provisions and configures a Minecraft server on AWS using Terraform and a Bash script. The goal is to demonstrate infrastructure as code (IaC), automation, and service management. This should all be done without manual steps taken or AWS console usage by a user. This is my final project for CS-312.

---

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) - configure this with the data found in **AWS Details** in your Learner Lab
- **AWS IAM credentials** with EC2 and VPC permissions
- An existing **AWS EC2 key pair**
- A **Unix-based shell** (macOS, WSL, or Linux)
- Optional: [`nmap`](https://nmap.org/) (for verifying port accessibility)

---

## Project Structure

Below is a basic depiction of the project pipeline:

1. **User Input** via `terraform.tfvars`
2. → **Terraform** provisions:
    - EC2 instance (Amazon Linux 2023)
    - Security group (ports 22 and 25565)
3. → **Provisioner** uploads and runs `setup_mc.sh`
4. → **Bash Script** installs:
    - Java 21 (Amazon Corretto)
    - Minecraft server 1.21.5
    - systemd service for auto-start
5. → **Minecraft Server** runs on port 25565
6. → **Connect** using EC2 public IP

## Setup 

### 1. Clone the repository

```bash
git clone https://github.com/dmitriyshmidt/312-final.git # Clone the repo to a local machine (I used VSCode WSL)
cd 312-final/terraform # Move into the Terraform directory within the project repository
```

### 2. Edit the `terraform.tfvars.example` file name and contents

1. Edit the file name to `terraform.tfvars` so that Terraform recognizes it

```bash
mv terraform.tfvars.example terraform.tfvars # Rename the file
```

2. Edit the contents... add the actual key name, vpc id, subnet id, and the path to your private key

```hcl
aws_region = "us-east-1"
key_name = "your-key-name"
vpc_id = "vpc-xxxxxxxx"
subnet_id = "subnet-yyyyyyyy"
private_key_path = "/path/to/your/key.pem"
```

### 3. Initialize and apply Terraform

```bash
terraform init # Initializes the working directory and downloads provider plugins
terraform apply # Provisions the infrastructure defined in your .tf files
```

> **Note**: Running `terraform apply` will create AWS resources. Remember to run `terraform destroy` when you're done to avoid unnecessary charges.

### 4. Connect to the Minecraft Server

At this point, you should be able to join the server in Minecraft. To do this, open Minecraft and then navigate to **Multiplayer**. Select **Add Server**, then add a server name and enter the IP address provided in the output from applying Terraform in part 3. Save this by selecting **Done**, then select your new server and select **Join Server**.
