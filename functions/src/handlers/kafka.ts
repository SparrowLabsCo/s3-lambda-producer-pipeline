import { Context, S3Event } from 'aws-lambda';
import { Logger } from '@aws-lambda-powertools/logger'
import { LambdaInterface } from '@aws-lambda-powertools/commons';
import { logLevel, Partitioners } from 'kafkajs';
const { Kafka } = require('kafkajs')
const { awsIamAuthenticator, Type } = require('@jm18457/kafkajs-msk-iam-authentication-mechanism')

let logger = new Logger({ serviceName: "s3-terraform-lambda" });

let broker: string = process.env.KAFKA_BROKERS ?? "localhost:9098";

const client = new Kafka({
    logLevel: logLevel.DEBUG,
    clientId: "s3-terraform-lambda",
    brokers: [broker],
    ssl: true,
    sasl: {
        mechanism: Type,
        authenticationProvider: awsIamAuthenticator(process.env.REGION, process.env.TTL)
    }
})

const admin = client.admin()

class KafkaLambda implements LambdaInterface {
    // Decorate your handler class method
    @logger.injectLambdaContext()
    public async handler(event: S3Event, context: Context): Promise<void> {
 
        logger.info(`Function Executed`);
    
        try {

           
            await admin.connect()
            var cluster: any = await admin.describeCluster()
            var brokerList = cluster.brokers.map((c:any) => ({ host: `${c.host}:${c.port}` })).flatMap((x:any)=>x.host)
            await admin.disconnect()

            logger.info(`Broker Info: ${JSON.stringify(brokerList)}`);
          
            event.Records.forEach(async element => {
                logger.info(`S3 Record: ${JSON.stringify(element)}`);
               
            });

        } catch (err: unknown) {
            logger.error(`ERROR: ${JSON.stringify(err)}`);
          
        }
       

    }
}

const functionExport = new KafkaLambda();
export const handler = functionExport.handler.bind(functionExport);