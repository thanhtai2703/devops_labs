# 📋 How to Check if Pipeline is Working

## ✅ Pipeline Successfully Started!

### Current Status:
- ✅ **Source Stage**: SUCCEEDED (Code pulled from CodeCommit)
- ⏳ **Build Stage**: IN PROGRESS (Running cfn-lint validation)
- ⚪ **UploadTemplates Stage**: Waiting
- ⚪ **Deploy Stage**: Waiting

---

## 🔍 How to Monitor Pipeline Execution

### 1. **AWS Console (Recommended)**
Open this URL in your browser:
```
https://console.aws.amazon.com/codesuite/codepipeline/pipelines/cfn-pipeline-pipeline/view
```

**What to look for:**
- ✅ Green checkmarks = Stage succeeded
- ⏳ Blue spinning = Stage in progress
- ❌ Red X = Stage failed (check logs)

---

### 2. **AWS CLI - Quick Status**
```powershell
# Check overall pipeline status
aws codepipeline get-pipeline-state --name cfn-pipeline-pipeline --query 'stageStates[*].[stageName,latestExecution.status]' --output table

# Get latest execution details
aws codepipeline list-pipeline-executions --pipeline-name cfn-pipeline-pipeline --max-items 1
```

---

### 3. **Check Each Stage**

#### **Build Stage (cfn-lint validation)**
```powershell
# Get latest build ID
$buildId = aws codebuild list-builds-for-project --project-name cfn-pipeline-build --query 'ids[0]' --output text

# View build logs
aws codebuild batch-get-builds --ids $buildId --query 'builds[0].logs.deepLink' --output text
```

**What it does:**
- Installs cfn-lint and taskcat
- Validates CloudFormation templates for syntax errors
- Checks for best practices violations

---

#### **UploadTemplates Stage**
```powershell
# Check if templates uploaded to S3
aws s3 ls s3://cfn-templates-bucket-2026-v2/templates/ --recursive
```

**What it does:**
- Extracts templates from source artifact
- Uploads to S3 bucket for nested stack deployment

---

#### **Deploy Stage (CloudFormation)**
```powershell
# Check infrastructure stack status
aws cloudformation describe-stacks --stack-name cfn-pipeline-infrastructure --query 'Stacks[0].[StackStatus,StackStatusReason]' --output table

# Watch stack events (live)
aws cloudformation describe-stack-events --stack-name cfn-pipeline-infrastructure --max-items 20 --query 'StackEvents[*].[Timestamp,ResourceType,LogicalResourceId,ResourceStatus]' --output table
```

**What it does:**
- Creates main CloudFormation stack
- Deploys nested stacks (VPC, Security Groups, EC2)
- Provisions: VPC, Subnets, IGW, NAT Gateway, Route Tables, SGs, EC2 instances

---

## ✅ Success Indicators

### Pipeline Success:
```
Source → Build → UploadTemplates → Deploy
  ✅      ✅           ✅             ✅
```

### Infrastructure Deployed:
```powershell
# Get infrastructure stack outputs
aws cloudformation describe-stacks --stack-name cfn-pipeline-infrastructure --query 'Stacks[0].Outputs' --output table
```

**Expected Outputs:**
- VPC ID
- Public/Private Subnet IDs
- Security Group IDs
- **Public EC2 IP** (you can SSH to this)
- Private EC2 IP

---

## ❌ Failure Scenarios

### Build Stage Failed (cfn-lint errors)
```powershell
# View build logs
$buildId = aws codebuild list-builds-for-project --project-name cfn-pipeline-build --query 'ids[0]' --output text
aws codebuild batch-get-builds --ids $buildId
```

**Common causes:**
- CloudFormation syntax errors
- Invalid parameter references
- Missing required properties

---

### Deploy Stage Failed
```powershell
# Check stack failure reason
aws cloudformation describe-stacks --stack-name cfn-pipeline-infrastructure --query 'Stacks[0].StackStatusReason' --output text

# View failed resource
aws cloudformation describe-stack-events --stack-name cfn-pipeline-infrastructure --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]' --output table
```

**Common causes:**
- Missing EC2 KeyPair
- Invalid IP address format
- IAM permission issues
- Resource limits exceeded

---

## 🧪 Verify Deployed Infrastructure

### 1. Check VPC and Subnets
```powershell
# List VPCs created by the stack
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=cfn-pipeline-vpc" --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table
```

### 2. Check NAT Gateway
```powershell
# Verify NAT Gateway is available
aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=cfn-pipeline-nat-gw" --query 'NatGateways[*].[NatGatewayId,State,SubnetId]' --output table
```

### 3. Check EC2 Instances
```powershell
# List EC2 instances
aws ec2 describe-instances --filters "Name=tag:Name,Values=cfn-pipeline-public-ec2" --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,PrivateIpAddress]' --output table
```

### 4. Test SSH Access
```powershell
# Get public EC2 IP
$publicIp = aws cloudformation describe-stacks --stack-name cfn-pipeline-infrastructure --query 'Stacks[0].Outputs[?OutputKey==`PublicEC2IP`].OutputValue' --output text

# SSH to public instance (replace YOUR_KEY.pem)
ssh -i YOUR_KEY.pem ec2-user@$publicIp
```

---

## 📊 Continuous Monitoring

### Auto-refresh pipeline status (every 30 seconds)
```powershell
while ($true) {
    Clear-Host
    Write-Host "Pipeline Status - $(Get-Date)" -ForegroundColor Cyan
    aws codepipeline get-pipeline-state --name cfn-pipeline-pipeline --query 'stageStates[*].[stageName,latestExecution.status]' --output table
    Start-Sleep -Seconds 30
}
```

Press `Ctrl+C` to stop monitoring.

---

## 🎯 Expected Timeline

| Stage | Duration | Status Check |
|-------|----------|--------------|
| Source | 10-30 sec | Pull code from CodeCommit |
| Build | 2-4 min | cfn-lint validation |
| Upload | 10-20 sec | Upload templates to S3 |
| Deploy | 8-12 min | Create VPC, NAT Gateway, EC2 |

**Total**: ~10-17 minutes for complete deployment

---

## 🔄 Trigger Pipeline Again

### Make a code change and push:
```powershell
cd cfn-infrastructure-repo
# Make changes to templates
git add .
git commit -m "Updated CloudFormation templates"
git push origin main
```

Pipeline will automatically trigger on push!

---

## 🧹 Cleanup (After Testing)

### Delete Infrastructure Stack:
```powershell
aws cloudformation delete-stack --stack-name cfn-pipeline-infrastructure
```

### Delete Pipeline Stack:
```powershell
aws cloudformation delete-stack --stack-name cfn-codepipeline-stack
```

### Delete S3 Buckets:
```powershell
# Empty and delete artifact bucket
aws s3 rm s3://ARTIFACT_BUCKET_NAME --recursive
aws s3 rb s3://ARTIFACT_BUCKET_NAME

# Empty and delete templates bucket
aws s3 rm s3://cfn-templates-bucket-2026-v2 --recursive
aws s3 rb s3://cfn-templates-bucket-2026-v2
```
