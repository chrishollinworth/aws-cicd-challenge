import boto3
import os
import zipfile

import cfnresponse

codecommit_client = boto3.client("codecommit")
s3_client = boto3.client("s3")


def handler(event, context):

    if event['RequestType'] == 'Delete' or event['RequestType'] == 'Update':
        result = cfnresponse.SUCCESS
        return cfnresponse.send(event, context, result, {})

    responseData = {}
    repository_name = event['ResourceProperties']['RepositoryName']
    repository_branches = event['ResourceProperties']['BranchesToCreate']
    code_artifact_bucket_name = event['ResourceProperties']['CodeArtifactsBucketName']
    code_artifact_bucket_key = event['ResourceProperties']['CodeArtifactsBucketKey']

    if event['RequestType'] == 'Create':
        try:
            zip_path = f"/tmp/{code_artifact_bucket_key}"
            code_artifacts_path = "/tmp/code_artifacts/"
            s3_client.download_file(
                code_artifact_bucket_name, code_artifact_bucket_key, zip_path)
            zip = zipfile.ZipFile(zip_path, 'r')
            zip.extractall(code_artifacts_path)
            zip.close()

            initialCommit = None
            for branch in repository_branches.split(','):
                if branch == 'development':
                    for filename in os.listdir(code_artifacts_path):
                        file = open(f"{code_artifacts_path}{filename}", "rb")
                        file_content = file.read()
                        if initialCommit is None:
                            initialCommit = codecommit_client.put_file(
                                repositoryName=repository_name, branchName=branch, fileContent=file_content, filePath=filename)
                        else:
                            commit = codecommit_client.put_file(
                                repositoryName=repository_name, branchName=branch, fileContent=file_content, filePath=filename, parentCommitId=initialCommit['commitId'])

            for branch in repository_branches.split(','):
                if branch != 'development':
                    codecommit_client.create_branch(
                        repositoryName=repository_name, branchName=branch, commitId=commit['commitId'])

            print("branches created")
            responseData['Data'] = "Branches created"
            cfnresponse.send(event, context, cfnresponse.SUCCESS, responseData)
        except Exception as e:
            print("There was an error creating branches")
            responseData['Data'] = e
            cfnresponse.send(event, context, cfnresponse.FAILED, responseData)
    return
