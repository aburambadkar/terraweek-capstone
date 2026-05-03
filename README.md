# TerraWeek Capstone — AWS Infrastructure with Terraform

A modular, workspace-driven Terraform project that provisions a production-style AWS environment consisting of a VPC, Security Group, and EC2 instance. Built as the capstone project for TerraWeek, demonstrating real-world Terraform patterns including reusable modules, remote state management, environment isolation via workspaces, and deployment guardrails.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    AWS (us-east-1)                  │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │                    VPC                       │   │
│  │  ┌─────────────┐      ┌─────────────┐        │   │
│  │  │ Public x3   │      │ Private x3  │        │   │
│  │  │  Subnets    │      │  Subnets    │        │   │
│  │  │             │      │             │        │   │
│  │  │  ┌───────┐  │      │             │        │   │
│  │  │  │  EC2  │  │      │             │        │   │
│  │  │  └───────┘  │      │             │        │   │
│  │  │      │      │      │      │      │        │   │
│  │  │  [Security  │      │  [NAT GW]   │        │   │
│  │  │   Group]    │      │      │      │        │   │
│  │  └──────┬──────┘      └──────┬──────┘        │   │
│  │         │                    │               │   │
│  │    [Internet Gateway]────────┘               │   │
│  └─────────┼────────────────────────────────────┘   │
│            │                                        │
└────────────┼────────────────────────────────────────┘
          Internet                               
```

**What gets created per environment:**
- 1 VPC with DNS support enabled
- 3 public subnets + 3 private subnets (one per AZ)
- 1 Internet Gateway (public subnet egress)
- 1 NAT Gateway + Elastic IP (private subnet egress)
- 2 route tables with associations
- 1 Security Group (SSH / port 22 only, locked to a specific IP)
- 1 EC2 instance in the first public subnet, attached to the key pair

---

## Project Structure

```
terraweek-capstone/
├── backend.tf                  # Terraform version + S3 backend (partial config)
├── main.tf                     # Root module — wires the three child modules
├── variables.tf                # Root input variables
├── locals.tf                   # env local + workspace/tfvars guardrail
├── outputs.tf                  # Root outputs (VPC, SG, EC2 IDs and IPs)
├── provider.tf                 # AWS provider + default tags
│
├── backend/
│   └── config.hcl              # S3 backend config (bucket, key, region, locking)
│
├── env/
│   ├── dev.tfvars              # Dev variable values
│   ├── staging.tfvars          # Staging variable values
│   └── prod.tfvars             # Prod variable values
│
├── modules/
│   ├── vpc/                    # VPC, subnets, IGW, NAT GW, route tables
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security-grp/           # Security group with dynamic ingress rules
│   │   ├── main.tf
│   │   ├── variable.tf
│   │   └── outputs.tf
│   └── ec2/                    # EC2 instance
│       ├── main.tf
│       ├── variable.tf
│       └── outputs.tf
│
└── scripts/
    └── bootstrap-backend.sh    # One-time S3 bucket setup script
```

---

## Key Design Decisions

### Reusable Modules
Each AWS concern (networking, security, compute) is a self-contained module with its own inputs and outputs. The root module wires them together, passing outputs from one as inputs to the next (e.g. VPC ID and subnet IDs flow into the Security Group and EC2 modules).

### Workspace-Based Environment Isolation
Terraform workspaces (`dev`, `staging`, `prod`) are used to isolate state within a single S3 bucket. The state key path is automatically namespaced by workspace:

| Workspace | State Path |
|-----------|-----------|
| dev       | `env:/dev/terraform.tfstate` |
| staging   | `env:/staging/terraform.tfstate` |
| prod      | `env:/prod/terraform.tfstate` |

All resources are tagged with `Environment = terraform.workspace` automatically via the AWS provider's `default_tags`.

### Workspace / tfvars Guardrail
Each `env/*.tfvars` file declares an `environment` variable that must match the active workspace. If they don't match — e.g. accidentally passing `staging.tfvars` on the `dev` workspace — Terraform aborts at plan time with a clear error:

```
WORKSPACE MISMATCH: var.environment is "staging" but the active
workspace is "dev". Run: terraform workspace select staging
```

This prevents silent infrastructure changes to the wrong environment.

### Native S3 State Locking
State locking uses S3's native conditional writes (`use_lockfile = true`) introduced in Terraform 1.10, eliminating the need for a DynamoDB table.

### Non-Overlapping VPC CIDRs
Each environment uses a distinct `/16` block to allow future VPC peering without conflicts:

| Environment | VPC CIDR |
|-------------|----------|
| dev         | `10.0.0.0/16` |
| staging     | `10.1.0.0/16` |
| prod        | `10.2.0.0/16` |

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.10
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured (`aws configure`)
- An AWS key pair created in the target region (used for EC2 SSH access)

---

## First-Time Setup

### 1. Create the S3 backend bucket

```bash
chmod +x scripts/bootstrap-backend.sh
./scripts/bootstrap-backend.sh
```

This creates the `terraweek-capstone-tfstate` S3 bucket with versioning, AES-256 encryption, and public access blocked.

### 2. Initialise Terraform

```bash
terraform init -backend-config=backend/config.hcl
```

### 3. Create workspaces

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

---

## Deploying an Environment

```bash
# Select the target workspace
terraform workspace select dev

# Preview changes
terraform plan -var-file=env/dev.tfvars

# Apply
terraform apply -var-file=env/dev.tfvars
```

Repeat with `staging` or `prod` as needed, substituting the workspace name and tfvars file.

---

## Tearing Down

```bash
terraform workspace select dev
terraform destroy -var-file=env/dev.tfvars
```

---

## Outputs

After a successful apply, Terraform prints:

| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the VPC |
| `public_subnet_ids` | IDs of the 3 public subnets |
| `private_subnet_ids` | IDs of the 3 private subnets |
| `nat_gateway_ip` | Public IP of the NAT Gateway |
| `security_group_id` | ID of the Security Group |
| `ec2_instance_id` | ID of the EC2 instance |
| `ec2_public_ip` | Public IP of the EC2 instance |

SSH into the instance:
```bash
ssh -i ~/.ssh/akshada-terraweek-capstone.pem ec2-user@<ec2_public_ip>
```

---

## Environment Comparison

| Setting | dev | staging | prod |
|---------|-----|---------|------|
| VPC CIDR | `10.0.0.0/16` | `10.1.0.0/16` | `10.2.0.0/16` |
| Instance type | `t3.micro` | `t3.small` | `t3.medium` |
| SSH access | Admin IP | Admin IP | Admin IP |
