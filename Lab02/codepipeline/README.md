# Lab02 - AWS CodePipeline for CloudFormation Infrastructure

Automated CI/CD pipeline using AWS CodePipeline to deploy CloudFormation infrastructure.

## 📁 Project Structure

```
Lab02/codepipeline/
├── pipeline.yaml                    # CodePipeline CloudFormation template
├── pipeline-parameters.json         # Pipeline configuration parameters
├── deploy-pipeline.ps1              # PowerShell deployment script
├── deploy-pipeline.sh               # Bash deployment script
├── push-to-codecommit.ps1          # Script to push code to CodeCommit
├── monitor-pipeline.ps1            # Pipeline monitoring script
└── README.md                        # This file

Note: CloudFormation templates are in ../Lab01/cloudformation/
      and will be pushed to CodeCommit during deployment
```

## 🚀 Deployment Steps

### 1. Configure Parameters

Edit `pipeline-parameters.json` with your values:

```json
{
  "UserIP": "YOUR_PUBLIC_IP/32",           // Your public IP for SSH access
  "KeyPairName": "YOUR_EC2_KEYPAIR",       // Your EC2 key pair name
  "S3BucketName": "your-unique-bucket-name" // Unique S3 bucket name
}
```

**Get your IP and KeyPairs:**
```powershell
# Get your public IP
(Invoke-WebRequest -Uri "https://api.ipify.org").Content

# List available EC2 key pairs
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName'
```

### 2. Deploy Pipeline Infrastructure

**PowerShell:**
```powershell
.\deploy-pipeline.ps1
```

**Bash:**
```bash
./deploy-pipeline.sh
```

This creates:
- CodeCommit repository
- CodeBuild project with cfn-lint
- CodePipeline (4 stages)
- S3 buckets for artifacts and templates
- IAM roles and permissions

### 3. Push Code to CodeCommit

**Note:** The code is already in CodeCommit from initial setup. To make changes:

```powershell
# Clone repository from CodeCommit
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/cfn-infrastructure-repo

# Make changes
cd cfn-infrastructure-repo
# Edit files...

# Push changes
git add .
git commit -m "Your changes"
git push origin main
```

This will automatically trigger the pipeline.

### 4. Monitor Pipeline Execution

**Option A - AWS Console:**
```
https://console.aws.amazon.com/codesuite/codepipeline/pipelines/cfn-pipeline-pipeline/view
```

**Option B - PowerShell Script:**
```powershell
.\monitor-pipeline.ps1
```

**Option C - AWS CLI:**
```powershell
aws codepipeline get-pipeline-state --name cfn-pipeline-pipeline
```

## 📊 Pipeline Stages

### Stage 1: Source (CodeCommit)
- Monitors repository for changes
- Triggers automatically on code push
- Pulls latest code

### Stage 2: Build (CodeBuild)
- Validates CloudFormation templates with **cfn-lint**
- Checks syntax and best practices
- Fails pipeline if validation errors found

### Stage 3: Upload Templates
- Uploads templates to S3 bucket
- Makes them available for nested stack deployment

### Stage 4: Deploy (CloudFormation)
- Creates main CloudFormation stack
- Deploys nested stacks:
  - **VPC Module**: VPC, Subnets, IGW, NAT Gateway, Route Tables
  - **Security Groups Module**: Public/Private security groups
  - **EC2 Module**: Public and Private EC2 instances

## ✅ Verify Deployment

### Check Pipeline Status
```powershell
aws codepipeline get-pipeline-state --name cfn-pipeline-pipeline --query 'stageStates[*].[stageName,latestExecution.status]' --output table
```

### Check Deployed Infrastructure
```powershell
# Stack outputs
aws cloudformation describe-stacks --stack-name cfn-pipeline-infrastructure --query 'Stacks[0].Outputs' --output table

# VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=cfn-pipeline-vpc"

# NAT Gateway
aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=cfn-pipeline-nat-gw"

# EC2 Instances
aws ec2 describe-instances --filters "Name=tag:Name,Values=cfn-pipeline-*"
```

### SSH to Public EC2
```powershell
# Get public IP
$publicIp = aws cloudfor:

1. Clone repository from CodeCommit (if not already cloned):
```powershell
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/cfn-infrastructure-repo
cd cfn-infrastructure-repo
```

2. Make changes to templates and push:
```powershell
# Edit templates in Lab01/cloudformation/

## 🔄 Update Infrastructure

To update infrastructure, modify templates and push:

```powershell
cd cfn-infrastructure-repo
# Make changes to templates
git add .
git commit -m "Updated infrastructure"
git push origin main
```

Pipeline will automatically:
1. Detect the push
2. Validate with cfn-lint
3. Upload updated templates
4. Update CloudFormation stack

## 🧹 Cleanup

### Delete Infrastructure Stack
```powershell
aws cloudformation delete-stack --stack-name cfn-pipeline-infrastructure
aws cloudformation wait stack-delete-complete --stack-name cfn-pipeline-infrastructure
```

### Delete Pipeline Stack
```powershell
aws cloudformation delete-stack --stack-name cfn-codepipeline-stack
aws cloudformation wait stack-delete-complete --stack-name cfn-codepipeline-stack
```

### Delete S3 Buckets
```powershell
# Get bucket names
$artifactBucket = aws cloudformation describe-stack-resource --stack-name cfn-codepipeline-stack --logical-resource-id ArtifactBucket --query 'StackResourceDetail.PhysicalResourceId' --output text
$templatesBucket = "cfn-templates-bucket-2026-v2" # or your bucket name

# Empty and delete
aws s3 rm s3://$artifactBucket --recursive
aws s3 rb s3://$artifactBucket
aws s3 rm s3://$templatesBucket --recursive
aws s3 rb s3://$templatesBucket
```

## 📋 Lab Requirements Met

✅ CloudFormation deployment with VPC, Route Tables, NAT Gateway, EC2, Security Groups  
✅ CodeBuild integration with cfn-lint validation  
✅ CodePipeline automation from CodeCommit  
✅ Nested CloudFormation stacks for modularity  
✅ Automated build and deploy workflow  

## 🛠️ Troubleshooting

### Pipeline Fails at Deploy Stage
- Check if stack exists in ROLLBACK_COMPLETE state
- Delete failed stack: `aws cloudformation delete-stack --stack-name cfn-pipeline-infrastructure`
- Retry pipeline

### cfn-lint Validation Fails
- Check CodeBuild logs for specific errors
- Fix CloudFormation template syntax
- Push corrected templates

### Access Denied Errors
- Verify IAM roles have correct permissions
- Check S3 bucket policies
- Ensure CloudFormation role can access S3 templates

## 📚 Resources

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/)
- [cfn-lint Documentation](https://github.com/aws-cloudformation/cfn-lint)
- [CloudFormation Nested Stacks](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html)
