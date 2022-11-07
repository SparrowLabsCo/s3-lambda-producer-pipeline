import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { handler } from '../../handlers/greeter';
import { event, badEvent } from '../events/greeter'

describe('Unit test for greeter handler', function () {
    it('verifies successful response', async () => {
        
        const result: APIGatewayProxyResult = await handler(event);

        expect(result).not.toBeNull
        expect(result.statusCode).toEqual(200);
        expect(result.body).toEqual(
            JSON.stringify({
                message: 'hello octonauts',
            }),
        );
    });

    it('verifies error response', async () => {
        
        const result: APIGatewayProxyResult = await handler(badEvent);

        expect(result).not.toBeNull
        expect(result.statusCode).toEqual(500);
        expect(result.body).toEqual(
            JSON.stringify({
                message: 'Event payload was not found.',
            }),
        );
    });
});
