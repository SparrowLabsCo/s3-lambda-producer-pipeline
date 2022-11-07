import { Context, S3Event } from 'aws-lambda';
import { Logger } from '@aws-lambda-powertools/logger'
import { LambdaInterface } from '@aws-lambda-powertools/commons';
const { Kafka, AuthenticationMechanisms } = require('kafkajs')
const { Mechanism, Type } = require('@jm18457/kafkajs-msk-iam-authentication-mechanism')
AuthenticationMechanisms[Type] = () => Mechanism

AuthenticationMechanisms[Type] = () => Mechanism

let logger = new Logger({ serviceName: "s3-terraform-lambda" });

let broker: string = process.env.KAFKA_BROKERS ?? "localhost:9098";

const client = new Kafka({
    clientId: "s3-terraform-lambda",
    brokers: [broker],
  ssl: true,
  sasl: {
    mechanism: Type,
    region: process.env.REGION,
    ttl: process.env.TTL
  }
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
    public async handler(event: S3Event, context: Context): Promise<void> {
        logger.info("executing function")
        logger.info(`Event: ${JSON.stringify(event)}`);
    
        await producer.connect()
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