import { Context, S3Event } from 'aws-lambda';
import { StartCrawlerRequest, StartCrawlerResponse} from 'aws-sdk/clients/glue';
import { Glue } from 'aws-sdk';

import { Logger } from '@aws-lambda-powertools/logger'
import { LambdaInterface } from '@aws-lambda-powertools/commons';

let logger = new Logger({ serviceName: "s3-terraform-lambda" });

const glue = new Glue();

class IndexLambda implements LambdaInterface {

    
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

        const response = glue.startCrawler(request)

        logger.info(` ${JSON.stringify(response)}`)
    }
}

const functionExport = new IndexLambda();
export const handler = functionExport.handler.bind(functionExport);