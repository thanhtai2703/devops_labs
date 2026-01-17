# Lab01

Deploy AWS infrastructure using Terraform or CloudFormation.

## Terraform

### Deploy:

1. **Configure variables**:
   Edit terraform.tfvars with your IP and key name
2. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
3. **Get outputs**:
   ```bash
   terraform output
   ```

### Cleanup:

```bash
terraform destroy
```

---

## Option 2: CloudFormation

### Deploy:

1. **Create `.env` file**:
   ```bash
   cd cloudformation
   cat > .env << EOF
   MY_IP="YOUR_IP/32"
   MY_KEY="YOUR_KEY_PAIR"
   S3_BUCKET_NAME="unique-bucket-name"
   PROJECT_NAME="myproject"
   STACK_NAME_PREFIX="cloudformation"
   AWS_REGION="us-east-1"
   EOF
   ```
2. **Deploy infrastructure**:
   ```bash
   ./deploy.sh
   ```

### Cleanup:

```bash
./cleanup.sh
```

---
