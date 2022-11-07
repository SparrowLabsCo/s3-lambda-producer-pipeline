import { Context, S3Event, S3EventRecord } from 'aws-lambda'
import { mock } from 'jest-mock-extended'
import { Kafka, Producer } from 'kafkajs'

jest.mock('aws-sdk')

it('should send a Kafka message', async () => {
  
    const fnContextMock = mock<Context>()
    const s3EventPayloadMock = mock<S3Event>()
    const records: [S3EventRecord] = [
        {
            eventVersion:"2.1",
            eventSource:"aws:s3",
            awsRegion:"us-east-1",
            eventTime:"2022-11-07T15:40:29.620Z",
            eventName:"ObjectCreated:Put",
            userIdentity:{
                principalId:"AWS:AROAJU7AHL2F6GSCD34RQ:jceanfaglione"
            },
            requestParameters:{
                sourceIPAddress:"47.197.145.174"
            },
            responseElements:{
                "x-amz-request-id":"Y7633F0YACNVV0R3",
                "x-amz-id-2":""
            },
            s3:{
                s3SchemaVersion:"1.0",
                configurationId:"00000001",
                bucket:{
                    name:"input-bucket-default-4yeyjcy3",
                    ownerIdentity:{
                        principalId:"AKISKLHMCZ000"
                    },
                    arn:"arn:aws:s3:::input-bucket-default"
                },
                object:{
                    key:"patients.csv",
                    size:310009,
                    eTag:"53719ff91e7f6e63390acd23aa80bf81",
                    sequencer:"00636926ED5D2370EA"
                }
            }
        }];

    s3EventPayloadMock.Records = records;
   
    const kafkaConnectSpy = jest.spyOn(Kafka.prototype.producer({
        maxInFlightRequests: 1,
        idempotent: true,
        transactionalId: "s3-producer",
        allowAutoTopicCreation: true
    }), 'connect')

    const { handler } = await import('../../handlers/index')

    await handler(s3EventPayloadMock,fnContextMock)

    expect(kafkaConnectSpy).toHaveBeenCalled()
})
