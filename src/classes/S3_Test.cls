@isTest
private class S3_Test {

 	public static testmethod void generalTest() {
 		s3.metadataEntry me = new s3.metadataEntry();
 		s3.DeleteObject_element  doe = new s3.DeleteObject_element();
 		s3.status status = new s3.status();
 	}

	

	public static testmethod void deleteObjectTest() {
		S3.AmazonS3 S3 = new S3.AmazonS3();
		S3.secret = '42';
		system.assert( S3.signature('encode',system.now() ) != null);
		s3.AccessControlList acl = new s3.AccessControlList();

		Test.startTest();

		// This causes a fake response to be generated
		Test.setMock(WebServiceMock.class, new WebServiceS3Mock('DeleteObjectResponse_element'));

		S3.DeleteObject('object','key', 'AWSAccessKeyId', system.now(),'sig', 'credentials');

		Test.stopTest();

	}

	public static testmethod void copyObjectTest() {
		S3.AmazonS3 S3 = new S3.AmazonS3();
		S3.secret = '42';
		system.assert( S3.signature('encode',system.now() ) != null);
		s3.AccessControlList acl = new s3.AccessControlList();

		Test.startTest();

		// This causes a fake response to be generated
		Test.setMock(WebServiceMock.class, new WebServiceS3Mock('CopyObjectResponse_element'));

		S3.CopyObject('bucket','key', 'destBucket', 'DestinationKey', 'MetadataDirective', null, null, system.now(),
														system.now(), null, null, 'StorageClass', 'AWSAccessKeyId', system.now(), 'Signature', 'Credential');

		Test.stopTest();

	}

	public class WebServiceS3Mock implements WebServiceMock{

		private String responseType = 'S3.';

		public WebServiceS3Mock(String className){
				this.responseType += className;
		}

		public void doInvoke(
					 Object stub,
					 Object request,
					 Map<String, Object> response,
					 String endpoint,
					 String soapAction,
					 String requestName,
					 String responseNS,
					 String responseName,
					 String responseType) {

				Object responseElement = Type.forName(responseType).newInstance();
				response.put('response_x', responseElement);
	 }

	}

}
