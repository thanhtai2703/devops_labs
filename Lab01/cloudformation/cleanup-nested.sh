#!/bin/bash

# Đọc biến từ .env
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | xargs)
else
  echo "❌ Không tìm thấy file .env."
  exit 1
fi

STACK_NAME="${STACK_NAME_PREFIX}-main-stack"
BUCKET_NAME="${S3_BUCKET_NAME}"

echo "🗑️  Bước 1: Xóa CloudFormation stack..."
aws cloudformation delete-stack --stack-name "${STACK_NAME}"
echo "⏳ Đợi stack bị xóa hoàn toàn..."
aws cloudformation wait stack-delete-complete --stack-name "${STACK_NAME}"
echo "✅ Stack đã xóa."

echo ""
echo "🗑️  Bước 2: Xóa templates từ S3 bucket..."
aws s3 rm "s3://${BUCKET_NAME}/modules/" --recursive

echo ""
echo "🗑️  Bước 3: Xóa S3 bucket (nếu muốn)..."
read -p "Bạn có muốn xóa bucket ${BUCKET_NAME}? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  aws s3 rb "s3://${BUCKET_NAME}" --force
  echo "✅ Bucket đã xóa."
else
  echo "ℹ️  Giữ lại bucket: ${BUCKET_NAME}"
fi

echo ""
echo "✅ Dọn dẹp hoàn tất!"
