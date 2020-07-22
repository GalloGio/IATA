@isTest
global class CW_AmazonMockHttpResponseGenerator implements HttpCalloutMock {
	private String endPoint;
	private String statusCode;

	global CW_AmazonMockHttpResponseGenerator(String endPoint, String statusCode) {
		this.endPoint = endPoint;
		this.statusCode = statusCode;
	}

	global HTTPResponse respond(HTTPRequest req) {
		String bodyMock = '';

		if (endPoint.contains('API_GetObject')) {
			bodyMock = '{"example":"test","x-amz-id-2": "eftixk72aD6Ap51TnqcoF8eFidJG9Z/2mkiDFu8yU9AS1ed4OpIszj7UDNEHGran","x-amz-request-id": "318BC8BC148832E5","Date": "Mon, 3 Oct 2016 22:32:00 GMT","Last-Modified": "Wed, 12 Oct 2009 17:50:00 GMT","ETag": "fba9dede5f27731c9771645a39863328","Content-Length": "434234"}';
		} else if (endPoint.contains('API_ListObjectsV2')) {
			bodyMock = '<?xml version="1.0" encoding="UTF-8"?><ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>bucket</Name><Prefix/><ContinuationToken>1ueGcxLPRx1Tr/XYExHnhbYLgveDs2J/wm36Hy4vbOwM=</ContinuationToken><NextContinuationToken>1ueGcxLPRx1Tr/XYExHnhbYLgveDs2J/wm36Hy4vbOwM=</NextContinuationToken><KeyCount>205</KeyCount><MaxKeys>1000</MaxKeys><Delimiter>/</Delimiter><IsTruncated>false</IsTruncated><Contents><Key>my-image.jpg</Key><LastModified>2009-10-12T17:50:30.000Z</LastModified><ETag>"fba9dede5f27731c9771645a39863328"</ETag><Size>434234</Size><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>Result.json</Key><LastModified>2009-10-12T17:50:30.000Z</LastModified><Owner><DisplayName>string</DisplayName><ID>string</ID></Owner><ETag>"fba9dede5f27731c9771645a39863328"</ETag><Size>534234</Size><StorageClass>STANDARD</StorageClass></Contents><CommonPrefixes><Prefix>photos/</Prefix></CommonPrefixes></ListBucketResult>';
		} else if (endPoint.contains('API_ListObjectsV2_Error')) {
			bodyMock = '<?xml version="1.0" encoding="UTF-8"?><Error><Code>NoSuchKey</Code><Message>The resource you requested does not exist</Message><Resource>/mybucket/myfoto.jpg</Resource><RequestId>4442587FB7D0A2F9</RequestId></Error>';
		}

		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(bodyMock);
		res.setStatusCode(statusCode.equals('OK') ? 200 : 401);
		return res;
	}
}