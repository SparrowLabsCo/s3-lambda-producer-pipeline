import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { hasUncaughtExceptionCaptureCallback } from 'process';

/**
 *
 * Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format
 * @param {Object} event - API Gateway Lambda Proxy Input Format
 *
 * Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
 * @returns {Object} object - API Gateway Lambda Proxy Output Format
 *
 */

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    console.log(`Greeter Event: ${JSON.stringify(event)}`);

    let response: APIGatewayProxyResult;
   
    try {
        if(event.body == null)
            throw new Error("Event payload as not found.");
        
        response = {
            statusCode: 200,
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ message: "hello octonauts" })
        };
    } catch (err: unknown) {
        console.log(err);
        response = {
            statusCode: 500,
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                message: err instanceof Error ? err.message : 'some error happened',
            }),
        };
    }

    return response;
};