<details>
<summary>📦 Click here for installation instructions</summary>

#### Install Terraform
```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

#### Install AWS CLI
```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
</details>

### Configure AWS Credentials

```bash
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY_ID
# AWS Secret Access Key: YOUR_SECRET_ACCESS_KEY
# Default region name: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

---

## 📁 Project Structure

```
eks-cluster-terraform/
├── terraform/                     # Terraform infrastructure code
│   ├── main.tf                    # Main configuration
│   ├── vpc.tf                     # VPC and networking
│   ├── eks.tf                     # EKS cluster setup
│   ├── rds.tf                     # RDS MySQL database
│   ├── iam.tf                     # IAM roles and policies (IRSA/Pod Identity)
│   ├── secrets-manager.tf         # AWS Secrets Manager
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output values
│   ├── terraform.tfvars.example   # Example variable values
│   ├── backend.tf                 # Remote state configuration
│   └── env                        # Hosts environment specific files
```

## 🚀 Getting Started
### Step 1: Configure Terraform Variables

1. Edit **terraform/variables.tf** and update values according to the target AWS account resources.
2. In **terraform/env** create a folder ENV_FOLDER for the target environment.
3. Copy dev/backend.tf & dev/main.tf into your new folder
3. Edit variable values in main.tf accoring to your AWS account & resources
4. Edit backend.tf so that the terraform state is remotely backed in an s3 bucket

### Step 2: Initialize Terraform

```bash
cd terraform/env/ENV_FOLDER
terraform init
```

## 📦 Deployment Steps

### Phase 1: Deploy AWS Infrastructure

#### Step 1: Review the Deployment Plan

```bash
terraform plan
```
#### Step 2: Apply the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm.
#### Step 2: Access the Application

```bash
# Get the Load Balancer URL
APP_URL=$(kubectl get ingress -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://$APP_URL"
```


Open the URL in your browser to access the project management application!

---
