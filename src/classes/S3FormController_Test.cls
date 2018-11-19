@isTest
private class S3FormController_Test {

	public static testmethod void saveTest() {
		
		AWS_S3_Object__c a = new AWS_S3_Object__c();
		
		S3FormController s3 = new S3FormController(
			new ApexPages.StandardController( a ) );
		
		AWSKey__c testKey = new AWSKey__c(name='test keys',key__c='key',secret__c='secret');
        insert testKey;

		s3.AWSCredentialName = testKey.name;
		s3.constructor();
		
		system.debug( s3.secret + ' '+ s3.key ); 
		system.debug( s3.getpolicy() ); 
		system.debug( s3.getSignedPolicy() ); 
		system.debug( s3.getHexPolicy() ); 
		
		PageReference pageRef = Page.news3object;
		pageRef.getParameters().put('urlParam','https://na22.salseforce.com/services/soap/14.0/c/');
        Test.setCurrentPage(pageRef);
        
		s3.save1();
		s3.page2onLoad(); 
		
		system.debug( s3.getBucketOptions() );
		
	}
	
	public static testmethod void badKeyNameTest() {
		AWS_S3_Object__c a = new AWS_S3_Object__c();
		S3FormController s3 = new S3FormController(new ApexPages.StandardController( a ) );
		s3.AWSCredentialName = 'bad key name';
		s3.constructor();
	}
	
}