import { S3Event } from 'aws-lambda';
import { Kafka } from 'kafkajs'

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

exports.handler = async (event: S3Event) => {
    console.log("executing function")
    console.log(`Event: ${JSON.stringify(event)}`);

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
   
};