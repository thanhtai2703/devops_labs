# PowerShell script to deploy CodePipeline infrastructure
# This creates CodeCommit repo, CodeBuild, and CodePipeline

$ErrorActionPreference = "Stop"

$STACK_NAME = "cfn-codepipeline-stack"
$TEMPLATE_FILE = "pipeline.yaml"
$PARAMETERS_FILE = "pipeline-parameters.json"
$REGION = if ($env:AWS_REGION) { $env:AWS_REGION } else { "us-east-1" }

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Deploying CodePipeline Infrastructure" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if parameters file exists
if (-not (Test-Path $PARAMETERS_FILE)) {
    Write-Host "❌ Error: $PARAMETERS_FILE not found" -ForegroundColor Red
    Write-Host "Please copy pipeline-parameters.example.json to pipeline-parameters.json" -ForegroundColor Yellow
    Write-Host "and fill in your values." -ForegroundColor Yellow
    exit 1
}

Write-Host "📋 Stack Name: $STACK_NAME"
Write-Host "📄 Template: $TEMPLATE_FILE"
Write-Host "⚙️  Parameters: $PARAMETERS_FILE"
Write-Host "🌍 Region: $REGION"
Write-Host ""

# Deploy the stack
Write-Host "🚀 Deploying CloudFormation stack..." -ForegroundColor Green

aws cloudformation deploy `
  --template-file $TEMPLATE_FILE `
  --stack-name $STACK_NAME `
  --parameter-overrides file://$PARAMETERS_FILE `
  --capabilities CAPABILITY_IAM `
  --region $REGION

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Stack deployed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Getting Stack Outputs..." -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    
    # Get stack outputs
    aws cloudformation describe-stacks `
      --stack-name $STACK_NAME `
      --region $REGION `
      --query 'Stacks[0].Outputs' `
      --output table
      
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "1. Configure Git credentials for CodeCommit"
    Write-Host "2. Clone the repository using the CloneUrlHttp"
    Write-Host "3. Push your code to trigger the pipeline"
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "❌ Stack deployment failed!" -ForegroundColor Red
    exit 1
}
