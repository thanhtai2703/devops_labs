
# Đọc biến từ .env
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | xargs)
else
  exit 1
fi
STACK_NAME="${STACK_NAME_PREFIX}-main-stack"
BUCKET_NAME="${S3_BUCKET_NAME}"
REGION="${AWS_REGION:-us-east-1}"
echo "Tạo S3 bucket để lưu nested stack templates..."
if aws s3 ls "s3://${BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
  echo "Tạo bucket mới: ${BUCKET_NAME}"
  if [ "$REGION" = "us-east-1" ]; then
    aws s3 mb "s3://${BUCKET_NAME}"
  fi
else
  echo "Bucket đã tồn tại: ${BUCKET_NAME}"
fi
echo ""
echo "Upload nested stack templates lên S3..."
aws s3 cp modules/ "s3://${BUCKET_NAME}/modules/" --recursive
echo "Upload hoàn tất!"
echo "Deploy main stack với nested stacks..."
aws cloudformation deploy \
  --template-file main.yaml \
  --stack-name "${STACK_NAME}" \
  --parameter-overrides \
      ProjectName="${PROJECT_NAME}" \
      UserIP="${MY_IP}" \
      KeyPairName="${MY_KEY}" \
      TemplatesBucketURL="https://${BUCKET_NAME}.s3.amazonaws.com" \
  --capabilities CAPABILITY_IAM
if [ $? -ne 0 ]; then
  echo "Triển khai thất bại."
  exit 1
fi
echo ""
echo "Triển khai hoàn tất!"
echo ""
aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query 'Stacks[0].Outputs' \
  --output table
