import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { Utils } from '../../handlers/utils';

describe('Unit test for simple handler', function () {
    it('verifies result', () => {
        
        let h = new Utils.handler();
        let result = h.hello();

        console.log(result)
        expect(result).not.toBeNull
        
        expect(result).toEqual(
            {
                message: 'hello',
            },
        );
    });
});
