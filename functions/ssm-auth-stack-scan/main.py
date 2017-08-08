import boto3
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
	client = boto3.client('cloudformation')
	lclient = boto3.client('lambda')
	response = client.list_stacks(
		StackStatusFilter=[
	        'CREATE_COMPLETE','UPDATE_COMPLETE'
	    ]
	)
	logger.info("%s - %s", event, context)
	for entry in response["StackSummaries"]:
		stack = client.describe_stacks(StackName=entry["StackName"])
		outputs = stack.get('Stacks')[0].get('Outputs')
		if outputs is not None and len(outputs) > 0:
			for out in outputs:
				if out.get('OutputKey') == "OutputInstanceIAMGroup":
					json_params = {
					"stack_name": entry['StackName'],
					"iamgroup": out.get('OutputValue')
					}
                    logger.info("Updating Stack:\t%s" % entry['StackName'])
					resp = lclient.invoke(
					FunctionName='TODO:YOURCOOLNAMEDFUNCTIONHERE',
					InvocationType='Event',
					Payload=json.dumps(json_params)
					)

	logger.info("Finished Scan of Stacks")
