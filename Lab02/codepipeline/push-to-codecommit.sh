#!/bin/bash

set -e

REPO_URL="https://git-codecommit.us-east-1.amazonaws.com/v1/repos/cfn-infrastructure-repo"
REPO_DIR="cfn-infrastructure-repo"

git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

cd $REPO_DIR

if [ ! -d ".git" ]; then
    git init
fi

git add .
git commit -m "Initial commit: CloudFormation nested stacks with VPC, NAT Gateway, EC2, and Security Groups" 2>/dev/null || true

if ! git remote | grep -q "origin"; then
    git remote add origin $REPO_URL
fi

git branch -M main
git push -u origin main

if [ $? -eq 0 ]; then
    cd ..
    echo "✓ Code pushed to CodeCommit successfully - Pipeline triggered"
else
    cd ..
    echo "✗ Failed to push code to CodeCommit"
    exit 1
fi
