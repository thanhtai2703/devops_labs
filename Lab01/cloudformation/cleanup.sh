#!/bin/bash
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | xargs)
else
  echo "Không tìm thấy file .env."
  exit 1
fi
# Lấy tên từ các biến đã được export
VPC_STACK_NAME="${STACK_NAME_PREFIX}-vpc-stack"
EC2_STACK_NAME="${STACK_NAME_PREFIX}-ec2-stack"

echo "Bắt đầu xóa EC2 ${EC2_STACK_NAME}..."
aws cloudformation delete-stack --stack-name ${EC2_STACK_NAME}
aws cloudformation wait stack-delete-complete --stack-name ${EC2_STACK_NAME}
echo "đã xóa."

echo "Bắt đầu xóa VPC ${VPC_STACK_NAME}..."
aws cloudformation delete-stack --stack-name ${VPC_STACK_NAME}
aws cloudformation wait stack-delete-complete --stack-name ${VPC_STACK_NAME}
echo "đã xóa."

echo "Dọn dẹp hoàn tất!"