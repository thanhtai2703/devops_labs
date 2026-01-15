#!/bin/bash

# Script to deploy CodePipeline infrastructure using CloudFormation
# This creates CodeCommit repo, CodeBuild, and CodePipeline

set -e

STACK_NAME="cfn-codepipeline-stack"
TEMPLATE_FILE="pipeline.yaml"
PARAMETERS_FILE="pipeline-parameters.json"
REGION="${AWS_REGION:-us-east-1}"

echo "=================================================="
echo "Deploying CodePipeline Infrastructure"
echo "=================================================="
echo ""

# Check if parameters file exists
if [ ! -f "$PARAMETERS_FILE" ]; then
  echo "❌ Error: $PARAMETERS_FILE not found"
  echo "Please copy pipeline-parameters.example.json to pipeline-parameters.json"
  echo "and fill in your values."
  exit 1
fi

echo "📋 Stack Name: $STACK_NAME"
echo "📄 Template: $TEMPLATE_FILE"
echo "⚙️  Parameters: $PARAMETERS_FILE"
echo "🌍 Region: $REGION"
echo ""

# Deploy the stack
echo "🚀 Deploying CloudFormation stack..."
aws cloudformation deploy \
  --template-file "$TEMPLATE_FILE" \
  --stack-name "$STACK_NAME" \
  --parameter-overrides file://"$PARAMETERS_FILE" \
  --capabilities CAPABILITY_IAM \
  --region "$REGION"

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Stack deployed successfully!"
  echo ""
  echo "=================================================="
  echo "Getting Stack Outputs..."
  echo "=================================================="
  
  # Get stack outputs
  aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs' \
    --output table
    
  echo ""
  echo "=================================================="
  echo "Next Steps:"
  echo "=================================================="
  echo "1. Configure Git credentials for CodeCommit"
  echo "2. Clone the repository using the CloneUrlHttp"
  echo "3. Push your code to trigger the pipeline"
  echo ""
else
  echo ""
  echo "❌ Stack deployment failed!"
  exit 1
fi
