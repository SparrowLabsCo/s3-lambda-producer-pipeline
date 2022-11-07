import { S3Event } from 'aws-lambda';
import { Kafka } from 'kafkajs'
import { Logger } from '@aws-lambda-powertools/logger'
import { LambdaInterface } from '@aws-lambda-powertools/commons';

let logger = new Logger({ serviceName: "s3-terraform-lambda" });

let broker: string = process.env.KAFKA_BROKERS ?? "localhost:9098";

const client: Kafka = new Kafka({
    clientId: "s3-terraform-lambda",
    brokers: [broker]
})

const producer = client.producer({
    maxInFlightRequests: 1,
    idempotent: true,
    transactionalId: "s3-producer",
    allowAutoTopicCreation: true
})

class IndexLambda implements LambdaInterface {
    // Decorate your handler class method
    @logger.injectLambdaContext()
    public async handler(event: S3Event, context: any): Promise<void> {
        logger.info("executing function")
        logger.info(`Event: ${JSON.stringify(event)}`);
    
        event.Records.forEach(async element => {
            await producer.send(
                {
                    topic: 's3-events',
                    messages: [{
                        key: element.s3.object.key,
                        value: JSON.stringify(element)
                    }]
                }
            )
        });
    }
}

const functionExport = new IndexLambda();
export const handler = functionExport.handler.bind(functionExport);