import { Context, S3Event } from 'aws-lambda';
import { StartCrawlerRequest } from 'aws-sdk/clients/glue';
import { Glue } from 'aws-sdk';
import "source-map-support/register";

import { Logger } from '@aws-lambda-powertools/logger'
import { LambdaInterface } from '@aws-lambda-powertools/commons';

let logger = new Logger({ serviceName: "s3-terraform-lambda.crawler" });

const glue = new Glue();

class CrawlerLambda implements LambdaInterface {

    
    // Decorate your handler class method
    @logger.injectLambdaContext()
    public async handler(event: S3Event, context: Context): Promise<void> {
        
        logger.info(`Function Executed: ${JSON.stringify(event)}`);
    
        if(event.Records.length > 0){
            event.Records.forEach(async element => {
                logger.info(`S3 Record: ${JSON.stringify(element)}`)
            });
        }

        const request: StartCrawlerRequest = {
            Name: process.env.CRAWLER_NAME ?? ""
        }


        try {
            const r = await glue.startCrawler(request).promise();

            logger.info(` ${JSON.stringify(r)}`)
        } catch (e: unknown) {
            logger.error(`${JSON.stringify(e)}`)
        }

        logger.info("Exiting.")

    }
}

const functionExport = new CrawlerLambda();
export const handler = functionExport.handler.bind(functionExport);