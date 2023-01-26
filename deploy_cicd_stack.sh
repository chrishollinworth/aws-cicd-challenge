S3_BUCKET_NAME_PREFIX=cicd2023
S3_KEY=code_artifacts.zip
STACK_ID=$(aws cloudformation create-stack --stack-name account-setup --template-body file://cicd_infra/account_setup.yaml --parameters ParameterKey=S3BucketNamePrefix,ParameterValue=$S3_BUCKET_NAME_PREFIX ParameterKey=S3BucketKey,ParameterValue=$S3_KEY --region us-west-2 --capabilities CAPABILITY_IAM | jq -r '.StackId')
aws cloudformation wait stack-create-complete --stack-name $STACK_ID --region us-west-2
S3_BUCKET=$(aws cloudformation describe-stacks --stack-name account-setup --query Stacks[].Outputs[] --region us-west-2 --output json | jq -r '.[].OutputValue')
cd test_template
zip -r -D $S3_KEY ./*
cd ..
aws s3api put-object --bucket $S3_BUCKET --key $S3_KEY --body test_template/code_artifacts.zip
aws cloudformation package --template-file cicd_infra/cicd_infra.yaml --s3-bucket $S3_BUCKET --output-template-file cicd_infra/cicd_infra_output.yaml --force-upload --region us-west-2
aws cloudformation deploy --stack-name cicd-tooling --template-file cicd_infra/cicd_infra_output.yaml --region us-west-2 --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM