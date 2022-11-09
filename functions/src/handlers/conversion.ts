import { Context, S3Event } from 'aws-lambda';
//import { StartJobRunRequest, StartJobRunResponse } from 'aws-sdk/clients/glue';
import { Glue } from 'aws-sdk';
import "source-map-support/register";

import { Logger } from '@aws-lambda-powertools/logger'
import { LambdaInterface } from '@aws-lambda-powertools/commons';

let logger = new Logger({ serviceName: "s3-terraform-lambda" });

const glue = new Glue();

class ConversionLambda implements LambdaInterface {

    
    // Decorate your handler class method
    @logger.injectLambdaContext()
    public async handler(event: S3Event, context: Context): Promise<void> {
        
       
        //const start: StartJobRunRequest = {};

        try {
            logger.info(`Crawler Completed: ${JSON.stringify(event)}`);
        } catch (e: unknown) {
            logger.error(`${JSON.stringify(e)}`)
        }

        logger.info("Exiting.")

    }
}

const functionExport = new ConversionLambda();
export const handler = functionExport.handler.bind(functionExport);