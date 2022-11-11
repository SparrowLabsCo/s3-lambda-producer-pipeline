import { Context, S3Event } from 'aws-lambda';
import { StartJobRunRequest, StartJobRunResponse } from 'aws-sdk/clients/glue';
import { Glue } from 'aws-sdk';
import "source-map-support/register";

import { Logger } from '@aws-lambda-powertools/logger'
import { LambdaInterface } from '@aws-lambda-powertools/commons';

let logger = new Logger({ serviceName: "s3-terraform-lambda.conversion" });

const glue = new Glue();


let jobName: string = process.env.JOB_NAME ?? "null";


class ConversionLambda implements LambdaInterface {

    
    // Decorate your handler class method
    @logger.injectLambdaContext()
    public async handler(event: S3Event, context:Context): Promise<void> {
        
       
        try {
            logger.info(`Crawler Completed: ${JSON.stringify(event)}`);

            const start: StartJobRunRequest = { JobName: jobName, Timeout: 10};
            const response: StartJobRunResponse = await glue.startJobRun(start).promise();
            
            logger.info(`Started Job: ${response.JobRunId}`);
            
        } catch (e: unknown) {
            logger.error(`${JSON.stringify(e)}`)
        }

        logger.info("Exiting.")

    }
}

const functionExport = new ConversionLambda();
export const handler = functionExport.handler.bind(functionExport);