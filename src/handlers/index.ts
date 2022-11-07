import { Context, S3Event } from 'aws-lambda';
import { Logger } from '@aws-lambda-powertools/logger'
import { LambdaInterface } from '@aws-lambda-powertools/commons';

let logger = new Logger({ serviceName: "s3-terraform-lambda" });

class IndexLambda implements LambdaInterface {
    // Decorate your handler class method
    @logger.injectLambdaContext()
    public async handler(event: S3Event, context: Context): Promise<void> {
        logger.info("executing function")
        logger.info(`Event: ${JSON.stringify(event)}`);
    
        event.Records.forEach(async element => {
            logger.info(`S3 Record: ${JSON.stringify(
                {
                    topic: 's3-events',
                    messages: [{
                        key: element.s3.object.key,
                        value: JSON.stringify(element)
                    }]
                })}`
            )
        });
    }
}

const functionExport = new IndexLambda();
export const handler = functionExport.handler.bind(functionExport);