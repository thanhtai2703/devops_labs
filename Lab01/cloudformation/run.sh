#!/bin/bash
# Đọc biến từ .env
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | xargs)
else
  echo "Không tìm thấy file .env."
  exit 1
fi

# import các biến môi trường từ .env
# Định nghĩa tên file và tên stack
#VPC
VPC_STACK_FILE="vpc-cloudformation.yaml"
VPC_STACK_NAME="${STACK_NAME_PREFIX}-vpc-stack"
#EC2
EC2_STACK_FILE="ec2-cloudformation.yaml"
EC2_STACK_NAME="${STACK_NAME_PREFIX}-ec2-stack"

# Apply vpc.yaml
echo "Bắt đầu triển khai Giai đoạn 1: ${VPC_STACK_NAME}..."
aws cloudformation deploy \
  --template-file ${VPC_STACK_FILE} \
  --stack-name ${VPC_STACK_NAME} \
  --capabilities CAPABILITY_IAM

if [ $? -ne 0 ]; then
  echo "triển khai thất bại."
  exit 1
fi

echo "Hoàn thành triển khai VPC"

# Apply ec2.yaml
echo "🚀 Bắt đầu triển khai Giai đoạn 2: ${EC2_STACK_NAME}..."
aws cloudformation deploy \
  --template-file ${EC2_STACK_FILE} \
  --stack-name ${EC2_STACK_NAME} \
  --parameter-overrides \
      UserIP="${MY_IP}" \
      KeyPairName="${MY_KEY}" \
  --capabilities CAPABILITY_IAM

if [ $? -ne 0 ]; then
  echo "triển khai thất bại."
  exit 1
fi

echo "Hoàn thành triển khai EC2"

# Lấy Outputs của EC2 Stack
echo "Đang lấy IP của máy chủ..."
aws cloudformation describe-stacks \
  --stack-name ${EC2_STACK_NAME} \
  --query "Stacks[0].Outputs" \
  --output table