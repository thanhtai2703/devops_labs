# PowerShell script to push code to CodeCommit and trigger the pipeline

$ErrorActionPreference = "Stop"

$REPO_URL = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/cfn-infrastructure-repo"
$REPO_DIR = "cfn-infrastructure-repo"
$REGION = "us-east-1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Push Code to CodeCommit Repository" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Configure Git credentials for CodeCommit
Write-Host "🔧 Step 1: Configuring Git credentials for CodeCommit..." -ForegroundColor Yellow
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
Write-Host "✅ Git credentials configured`n" -ForegroundColor Green

# Step 2: Initialize git in the repository folder
Write-Host "📦 Step 2: Initializing Git repository..." -ForegroundColor Yellow
Set-Location $REPO_DIR

if (-not (Test-Path ".git")) {
    git init
    Write-Host "✅ Git initialized" -ForegroundColor Green
} else {
    Write-Host "✅ Git already initialized" -ForegroundColor Green
}

# Step 3: Add all files
Write-Host "`n📝 Step 3: Adding files to Git..." -ForegroundColor Yellow
git add .
Write-Host "✅ Files added`n" -ForegroundColor Green

# Step 4: Check what will be committed
Write-Host "📋 Files to be committed:" -ForegroundColor Cyan
git status --short

# Step 5: Commit
Write-Host "`n💾 Step 4: Creating commit..." -ForegroundColor Yellow
git commit -m "Initial commit: CloudFormation nested stacks with VPC, NAT Gateway, EC2, and Security Groups"
Write-Host "✅ Commit created`n" -ForegroundColor Green

# Step 6: Add remote and push
Write-Host "🚀 Step 5: Pushing to CodeCommit..." -ForegroundColor Yellow
if (-not (git remote | Select-String "origin")) {
    git remote add origin $REPO_URL
    Write-Host "✅ Remote 'origin' added" -ForegroundColor Green
}

git branch -M main
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Code pushed successfully!`n" -ForegroundColor Green
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "What Happens Next?" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "1. CodePipeline will automatically detect the push" -ForegroundColor White
    Write-Host "2. Source stage: Pull code from CodeCommit" -ForegroundColor White
    Write-Host "3. Build stage: Run cfn-lint validation" -ForegroundColor White
    Write-Host "4. Upload stage: Upload templates to S3" -ForegroundColor White
    Write-Host "5. Deploy stage: Deploy CloudFormation stack`n" -ForegroundColor White
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Monitor the Pipeline:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "🌐 Pipeline Console:" -ForegroundColor Yellow
    Write-Host "   https://console.aws.amazon.com/codesuite/codepipeline/pipelines/cfn-pipeline-pipeline/view`n" -ForegroundColor White
    
    Write-Host "📟 Or use AWS CLI:" -ForegroundColor Yellow
    Write-Host "   aws codepipeline get-pipeline-state --name cfn-pipeline-pipeline`n" -ForegroundColor White
    
    Set-Location ..
} else {
    Write-Host "`n❌ Push failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}
