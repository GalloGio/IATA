@isTest
private class HttpCallTest {
    
    @isTest static void testBuildParam() {
        // arrange
        String paramName = 'someKey';
        String paramValue = 'someValue';
        String paramPair = paramName + '=' + paramValue;

        // act
        String firstParam = HttpCall.buildParam('', paramValue, paramName);
        String secondParam = HttpCall.buildParam(firstParam, paramValue, paramName);

        // assert
        System.assertEquals('?' + paramPair, firstParam);
        System.assertEquals('&' + paramPair, secondParam);

		String Paramff = HttpCall.buildParam('', true, '');
        String Paramfg = HttpCall.buildParam('', 1, '');		
    }
    
    @isTest static void testInvoke() {
        // arrange
        String responseBody = 'some-response';
        HttpResponseGenerator generator = new HttpResponseGenerator();
        generator.nextBody = responseBody;
        System.Test.setMock(HttpCalloutMock.class, generator);

        String method = 'GET';
        String body = 'some-request';
        String endPoint = 'http://example.org';
        String path = '/';
        HttpCall httpCall = new HttpCall(endPoint, path, body, method);

        // act
        Map<String, Object> response = httpCall.invoke();

        // assert
        System.assertEquals(endPoint + path, generator.lastRequest.getEndpoint());
        System.assertEquals(method, generator.lastRequest.getMethod());
        System.assertEquals(body, generator.lastRequest.getBody());
        System.assertEquals(responseBody, response.get('httpResponseStr'));
        System.assertEquals(true, response.get('isSuccess'));
        System.assertEquals('application/json', generator.lastRequest.getHeader('Accept'));
        System.assertEquals('application/json', generator.lastRequest.getHeader('Content-Type'));
        System.assertEquals(null, generator.lastRequest.getHeader('Authorization'));
    }
    
    @isTest static void testCustomHeaders() {
        // arrange
        String responseBody = 'some-response';
        HttpResponseGenerator generator = new HttpResponseGenerator();
        generator.nextBody = responseBody;
        System.Test.setMock(HttpCalloutMock.class, generator);

        String method = 'GET';
        String body = 'some-request';
        String endPoint = 'http://example.org';
        String path = '/';
        HttpCall httpCall = new HttpCall(endPoint, path, body, method);
        httpCall.accept = 'some-accept';
        httpCall.contentType = 'some-contentType';
        httpCall.authHeader = 'Some: auth-header';

        // act
        Map<String, Object> response = httpCall.invoke();

        // assert
        System.assertEquals(httpCall.accept, generator.lastRequest.getHeader('Accept'));
        System.assertEquals(httpCall.contentType, generator.lastRequest.getHeader('Content-Type'));
        System.assertEquals(httpCall.authHeader, generator.lastRequest.getHeader('Authorization'));
    }
    
}