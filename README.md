# AWS S3 to AWS Lambda

The Terraform template deploys a Lambda function, an S3 bucket and the IAM resources required to run the application. A Lambda function consumes <code>ObjectCreated</code> events from an Amazon S3 bucket. The Lambda code checks the uploaded file and logs the event.

## Notes

1.  This blueprint will create a vpc as part of the deployment unless `vpc_id` is passsd as a variable to terraform commands.

## Deployment Instructions

1. From the command line, initialize terraform to download and install the providers defined in the configuration:
    ```
    terraform init
    ```
1. From the command line, apply the configuration in the main.tf file:
    ```
    terraform apply
    ```
1. Note the outputs from the deployment process. These contain the resource names and/or ARNs which are used for testing.

## How it works

When we upload an object to S3, this will trigger the Lambda function which will output the event as a log.

## Testing

After deployment, create a folder named patients and upload a CSV formatted file to the S3. Go to the CloudWatch Logs for the deployed Lambda function. You will see the event is logged out containing the Object data.  Go to the AWS Glue catalog to see the crawler status and tables created


