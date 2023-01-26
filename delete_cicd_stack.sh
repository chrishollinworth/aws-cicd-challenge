S3_BUCKET_NAME=$(aws cloudformation describe-stacks --stack-name account-setup --query Stacks[].Outputs[] --region us-west-2 --output json | jq -r '.[].OutputValue')
aws s3 rm s3://$S3_BUCKET_NAME --recursive
aws s3api delete-bucket --bucket $S3_BUCKET_NAME --region us-east-1

STACK_ID1=$(aws cloudformation describe-stacks --stack-name account-setup --region us-west-2 | jq -r '.Stacks[].StackId')
STACK_ID2=$(aws cloudformation describe-stacks --stack-name cicd-tooling --region us-west-2 | jq -r '.Stacks[].StackId')
aws cloudformation delete-stack --stack-name account-setup --region us-west-2
aws cloudformation delete-stack --stack-name cicd-tooling --region us-west-2
aws cloudformation wait stack-delete-complete --stack-name $STACK_ID1 --region us-west-2
aws cloudformation wait stack-delete-complete --stack-name $STACK_ID2 --region us-west-2
