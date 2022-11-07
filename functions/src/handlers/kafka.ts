import { Context, S3Event } from 'aws-lambda';
import { Logger } from '@aws-lambda-powertools/logger'
import { LambdaInterface } from '@aws-lambda-powertools/commons';
const { Kafka } = require('kafkajs')
const { awsIamAuthenticator, Type } = require('@jm18457/kafkajs-msk-iam-authentication-mechanism')

let logger = new Logger({ serviceName: "s3-terraform-lambda" });

let broker: string = process.env.KAFKA_BROKERS ?? "localhost:9098";

const client = new Kafka({
    clientId: "s3-terraform-lambda",
    brokers: [broker],
    ssl: true,
    sasl: {
        mechanism: Type,
        authenticationProvider: awsIamAuthenticator(process.env.REGION, process.env.TTL)
    }
})

const producer = client.producer({
    //maxInFlightRequests: 1,
    //idempotent: true,
    //npm transactionalId: "s3-producer",
    allowAutoTopicCreation: true
})

class KafkaLambda implements LambdaInterface {
    // Decorate your handler class method
    @logger.injectLambdaContext()
    public async handler(event: S3Event, context: Context): Promise<void> {
 
        logger.info(`Function Executed`);
    
        try {
            await producer.connect()

            var element = event.Records[0];

            var result = await producer.send(
                {
                    topic: 's3-events',
                    messages: [{
                        //key: element.s3.object.key,
                        value: JSON.stringify(element.s3.object)
                    }]
                }
            )

            logger.info(`Event sent. ${result}`);
            /*event.Records.forEach(async element => {
                logger.info(`Streaming: ${JSON.stringify(element)}`);
               
            });*/
            
        } catch (err: unknown) {
            logger.error(`ERROR: ${JSON.stringify(err)}`);
          
        }
       

    }
}

const functionExport = new KafkaLambda();
export const handler = functionExport.handler.bind(functionExport);