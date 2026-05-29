import boto3

ec2 = boto3.client("ec2")

TAG_KEY = "AutoStop"
TAG_VALUE = "Homework18"


def lambda_handler(event, context):
    response = ec2.describe_instances(
        Filters=[
            {
                "Name": f"tag:{TAG_KEY}",
                "Values": [TAG_VALUE]
            },
            {
                "Name": "instance-state-name",
                "Values": ["running"]
            }
        ]
    )

    instance_ids = []

    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            instance_ids.append(instance["InstanceId"])

    if instance_ids:
        ec2.stop_instances(InstanceIds=instance_ids)
        return {
            "statusCode": 200,
            "body": f"Stopped instances: {instance_ids}"
        }

    return {
        "statusCode": 200,
        "body": "No running instances found with tag AutoStop=Homework18"
    }