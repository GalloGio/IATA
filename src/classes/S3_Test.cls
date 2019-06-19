@isTest
private class S3_Test {
    
 	public static testmethod void generalTest() {
 		s3.ListBucketResponse_element lbre = new s3.ListBucketResponse_element();
 	 	s3.ListBucketResult lbr = new s3.ListBucketResult();
 	 	s3.ListAllMyBucketsList lambl = new s3.ListAllMyBucketsList();
 		s3.metadataEntry me = new s3.metadataEntry();
	  s3.ListAllMyBucketsEntry lambe = new s3.ListAllMyBucketsEntry();   
 		s3.ListAllMyBucketsResult lambr = new s3.ListAllMyBucketsResult();
 		s3.CreateBucketResult cbr = new s3.CreateBucketResult();
 		s3.listEntry le = new s3.listEntry();
 		s3.DeleteObject_element  doe = new s3.DeleteObject_element();
 		s3.CanonicalUser co = new s3.CanonicalUser();
 		s3.DeleteBucketResponse_element dbr = new s3.DeleteBucketResponse_element();
 		s3.PrefixEntry pe = new s3.PrefixEntry();
 		s3.status status = new s3.status();
 		s3.ListAllMyBucketsResponse_element labre = new s3.ListAllMyBucketsResponse_element();
 		s3.CreateBucketResponse_element cbre = new s3.CreateBucketResponse_element();
 	}
 
  
	public static testmethod void makePutObjectInlineRequestTest(){
  	S3.AmazonS3 S3 = new S3.AmazonS3();
  	S3.secret = '42';
  	system.assert( S3.signature('encode',system.now() ) != null);
  	try{
  		S3.PutObjectInline_ACL('bucket','key',null,'datatesting',6,'public-read','keyid',System.now(),'sig','cred', 'ownerid') ;
  	}catch(Exception ex){
		  system.debug('Exception: ' + ex.getMessage());
    }
  }

  public static testmethod void listBucketTest() {
  	S3.AmazonS3 sss = new S3.AmazonS3();
  	sss.secret = '42';
  	system.assert( sss.signature('encode',system.now() ) != null);

  	// This causes a fake response to be generated
    Test.setMock(WebServiceMock.class, new WebServiceS3Mock('ListBucketResponse_element'));
  	sss.ListBucket( '','','', 3,'','key',system.now(),'sig','cred');
  }
 
  public static testmethod void listAllMyBucketsTest() {
  	S3.AmazonS3 S3 = new S3.AmazonS3();
  	S3.secret = '42';
  	system.assert( S3.signature('encode',system.now() ) != null);

  	// This causes a fake response to be generated
    Test.setMock(WebServiceMock.class, new WebServiceS3Mock('ListAllMyBucketsResponse_element'));
    S3.ListAllMyBuckets('key',system.now(),'sig');
  }  
   
  public static testmethod void createBucketTest() {
  	S3.AmazonS3 S3 = new S3.AmazonS3();
  	S3.secret = '42';
  	system.assert( S3.signature('encode',system.now() ) != null);
  	s3.AccessControlList acl = new s3.AccessControlList();
  	
    // This causes a fake response to be generated
    Test.setMock(WebServiceMock.class, new WebServiceS3Mock('CreateBucketResponse_element'));
    S3.CreateBucket('bucket',acl,'key',system.now(),'sig');
    
	}  
   
  public static testmethod void deleteTest() {
  	S3.AmazonS3 S3 = new S3.AmazonS3();
  	S3.secret = '42';
  	system.assert( S3.signature('encode',system.now() ) != null);
  	
    // This causes a fake response to be generated
    Test.setMock(WebServiceMock.class, new WebServiceS3Mock('DeleteBucketResponse_element'));
    S3.DeleteBucket('bucket','key',system.now(),'sig','cred');

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