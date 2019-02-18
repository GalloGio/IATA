@isTest
private class AWS_S3_ExampleControllerTest {

	private static String createTestCredentials() {

		AWSKey__c testKey = new AWSKey__c(name = 'test keys', key__c = 'key', secret__c = 'secret');
		insert testKey;
		return testKey.name;

	}

	
	@isTest
	private static void test1() {

		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		c.getPolicy();
		system.assert( c.allBuckets == null );

		c.AWSCredentialName = 'does not exist';
		c.constructor();

	}

	@isTest
	private static void test2() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		try {
			system.debug ( c.getFolders() );
			//system.assert( c.docs != null );
			system.debug ( c.getAccessTypes() );
		} catch (Exception ex) {
		}
		//c.allbuckets = new string[]{'f','b'};
		//system.debug( c.allBuckets );
		//c.getBucketNames();


	}

	@isTest
	private static void test3() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		c.createBucket();
	}

	@isTest
	private static void test4() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		c.deleteBucket();
	}

	@isTest
	private static void test5() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		c.deleteObject();
	}

	@isTest
	private static void test6() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		c.listBucket();
	}

	@isTest
	private static void test7() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();

		try {
			c.make_sig( 'foo');
		} catch (Exception ex) {
		}
		//c.redirectToS3Key();
	}

	@isTest
	private static void test8() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		try {
			c.getHexPolicy( );
			c.getSignedPolicy();
		} catch (Exception ex) {
		}
	}

	@isTest
	private static void test9() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName =createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		try 	{
			c.getBucketNames( );
		} catch (exception ee ) {
		}
	}

	@isTest
	private static void test10() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		try {
			c.syncForceDoc();
		} catch (Exception ex) {
		}
	}

	@isTest
	private static void test11() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		c.updateBucketToUpload();
	}

	@isTest
	private static void test12() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		c.updateFolderId();
	}

	@isTest
	private static void test13() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		PageReference pageRef = Page.AWS_S3_Examples;

		pageRef.getParameters().put('filename', 'foo');
		Test.setCurrentPage(pageRef);
		c.bucketToList = 'testBucket';
		try {
			c.redirectToS3Key();
		} catch (Exception ex) {
		}

	}

	@isTest
	private static void test14() {
		AWS_S3_ExampleController c = new AWS_S3_ExampleController();
		String credName = createTestCredentials();
		c.AWSCredentialName = credName;
		c.constructor();
		c.updateAccessTypeSelected();
		try {
			c.syncFilesystemDoc();
		} catch (Exception ex) {
		}
	}
	
}