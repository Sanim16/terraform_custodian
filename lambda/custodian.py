import sys
import subprocess
import os

def lambda_handler(event, context):
    # Check if 'custodian' is available in the path
    try:
        import c7n  # Import to check if it's available
        print("Cloud Custodian (c7n) package is available.")
    except ImportError as e:
        print(f"Error importing c7n: {e}")
        raise

    try:
        import c7n  # Import to check if it's available
        print("2nd attempt Cloud Custodian (c7n) package is available.")
        # Now try to run the 'custodian' executable
        subprocess.run([
        "custodian", "run", "--region", "us-east-1",
        "/var/task/custodian-policy.yml"])
    except subprocess.CalledProcessError as e:
        print(f"Error running subprocess: {e}")
        raise
    except FileNotFoundError as e:
        print(f"File not found: {e}")
        raise
