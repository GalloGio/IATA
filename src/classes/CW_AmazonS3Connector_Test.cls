@isTest
public with sharing class CW_AmazonS3Connector_Test {
	@isTest
	static void awsS3GetObject_testCallout() {
		Test.startTest();

		// Set mock callout class
		Test.setMock(HttpCalloutMock.class, new CW_AmazonMockHttpResponseGenerator('API_GetObject', 'OK'));

		HttpResponse res = CW_AmazonS3Connector.awsS3GetObject('key', 'named credential');

		String contentType = res.getHeader('Content-Type');
		System.assert(contentType == 'application/json');
		String actualValue = res.getBody();
		String results = res.getBody();

		System.assertEquals(200, res.getStatusCode());

		Test.stopTest();
	}

	@isTest
	static void listObjectsV2_testCallout() {
		Map<String, String> mapKey = new Map<String, String>();
		String namedCredential = 'namedCredential';

		Test.startTest();

		// Set mock callout class
		Test.setMock(HttpCalloutMock.class, new CW_AmazonMockHttpResponseGenerator('API_ListObjectsV2', 'OK'));

		CW_AmazonS3Wrappers.ListObjectsV2Output res = CW_AmazonS3Connector.listObjectsV2(mapKey, namedCredential);
		//System.assertEquals(actualValue, expectedValue);

		Test.stopTest();
	}

	@isTest
	static void listObjectsV2_Error_testCallout() {
		Map<String, String> queryParams = new Map<String, String>();
		String namedCredential = 'namedCredential';

		Test.startTest();

		// Set mock callout class
		Test.setMock(HttpCalloutMock.class, new CW_AmazonMockHttpResponseGenerator('API_ListObjectsV2_Error', 'OK'));

		HttpResponse response = CW_AmazonS3Connector.awsS3ListObjectsV2(queryParams, namedCredential);
		XmlStreamReader reader = new XmlStreamReader(response.getBody());

		CW_AmazonS3Wrappers.ErrorResponse res = CW_AmazonS3Wrappers.parseError(reader);
		//CW_AmazonS3Wrappers.ListObjectsV2Output res = CW_AmazonS3Connector.listObjectsV2(mapKey,namedCredential);
		//System.assertEquals(actualValue, expectedValue);

		Test.stopTest();
	}
}