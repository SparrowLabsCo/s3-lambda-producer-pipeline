import { Context, Callback, S3Event } from 'aws-lambda';

exports.handler = async (event: S3Event) => {
    console.log("executing function")
    console.log(`Event: ${JSON.stringify(event)}`);
};