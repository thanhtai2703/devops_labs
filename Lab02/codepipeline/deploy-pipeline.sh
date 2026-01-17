#!/bin/bash

set -e

STACK_NAME="cfn-codepipeline-stack"
TEMPLATE_FILE="pipeline.yaml"
PARAMETERS_FILE="pipeline-parameters.json"
REGION="${AWS_REGION:-us-east-1}"

if [ ! -f "$PARAMETERS_FILE" ]; then
  echo "✗ Error: $PARAMETERS_FILE not found"
  exit 1
fi

aws cloudformation deploy \
  --template-file "$TEMPLATE_FILE" \
  --stack-name "$STACK_NAME" \
  --parameter-overrides file://"$PARAMETERS_FILE" \
  --capabilities CAPABILITY_IAM \
  --region "$REGION"

if [ $? -eq 0 ]; then
  aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs' \
    --output table
  echo "✓ Pipeline infrastructure deployed successfully"
else
  echo "✗ Pipeline deployment failed"
  exit 1
fi
