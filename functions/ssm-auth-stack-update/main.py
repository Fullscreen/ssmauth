import boto3
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

 #The lambda_handler Python function gets called when you run your AWS Lambda function.
def lambda_handler(event, context):
    logger.info("%s - %s", event, context)
    ssmClient = boto3.client('ssm')
    cmd_str = "/usr/local/bin/iam_user_sync.rb IAMGROUPSYOUALWAYSWANT1 IAMGROUPSYOUALWAYSWANT2 " + event['iamgroup']

    response = ssmClient.send_command(
        DocumentName = 'AWS-RunShellScript',
        TimeoutSeconds = 240,
        Comment = 'SSMAuthManagment',
        Parameters = {
            'commands': [ cmd_str ]
        },
        Targets=[
                {
                    'Key': 'tag:' + 'aws:cloudformation:stack-name',
                    'Values': [event['stack_name'],]
                },
            ]
    )
    logger.info(response)
