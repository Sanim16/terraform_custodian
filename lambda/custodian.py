import os
import boto3
import tempfile
import logging
from c7n.commands import run
from c7n.config import Config

# Set up logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function that downloads a Cloud Custodian policy from S3
    and executes it using the Custodian API.
    """

    s3 = boto3.client("s3")

    # Read environment variables from Terraform
    bucket = os.environ["POLICY_S3_BUCKET"]
    key = os.environ["POLICY_S3_KEY"]

    # Temporary working directory
    tmp_dir = tempfile.gettempdir()
    local_policy = os.path.join(tmp_dir, os.path.basename(key))

    # Download the policy YAML from S3
    try:
        logger.info(f"Downloading policy from s3://{bucket}/{key}")
        s3.download_file(bucket, key, local_policy)
    except Exception as e:
        logger.error(f"Error downloading policy: {e}")
        return {"statusCode": 500, "body": f"Error downloading policy: {e}"}

    # Prepare Custodian configuration
    output_dir = os.path.join(tmp_dir, "out")
    os.makedirs(output_dir, exist_ok=True)

    default_c7n_config = {
        "skip_validation": True,
        "vars": None,
        "debug": True,
        "output_dir": output_dir,
        "configs": [local_policy],
    }

    run_config = Config.empty(**default_c7n_config)

    try:
        logger.info(f"Running Cloud Custodian policy: {local_policy}")
        run(run_config)
        logger.info("Policy executed successfully.")
        return {
            "statusCode": 200,
            "body": f"Policy {key} executed successfully.",
        }

    except Exception as e:
        logger.error(f"Error running policy: {e}")
        return {
            "statusCode": 500,
            "body": f"Error executing policy: {str(e)}",
        }
