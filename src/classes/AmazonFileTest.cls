@istest
public class AmazonFileTest {


	public static AmazonFile__c createAmazonAttachment() {
		Case cse = new Case();
		insert cse;

		AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = 'test name',
			Case__c = cse.Id
		);
		insert aFile;

		aFile = [Select isPublic__c, SystemModstamp, Size_MB__c, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, Full_Name_Unique__c, File_Identifier__c, Description__c, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Case__c
			From AmazonFile__c where id = :aFile.Id];

		return aFile;
	}

	private static void loadCredentials() {
		Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		Amazon_Cred__c GenericAttach =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		Amazon_Cred__c recycleBin =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		List<Amazon_Cred__c> creds = new List<Amazon_Cred__c>();
		creds.add(Amazon_Cred);
		creds.add(GenericAttach);
		creds.add(recycleBin);
		insert creds;


		list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
			new AWSKey__c(
				name = 'adevconf',
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd')
		};
		insert AWS_KEYs;
	}

	@testSetup
	private static void initialize() {
		EF_AttachmentListController.runningForEF = false;
		loadCredentials();
	}

	static testMethod void testwithS3File(){

		String FileName = 'IFAP/afile';
		list<AmazonRest.S3File> s3Files = AmazonRest.getListFiles(FileName,AmazonCredentials.getCredentials('IFAP') );

		AmazonXMLParser.ListEntry entry = new AmazonXMLParser.ListEntry();
		entry.key = 'key';
		entry.LastModified = Date.today();
		AmazonRest.S3File s3File = new AmazonRest.S3File(entry, AmazonCredentials.getCredentials('IFAP'));

		Test.startTest();
		AmazonFile amazonFile = new AmazonFile(s3Files[0], null);
		amazonFile.getSize();
		amazonFile.getName();
		amazonFile.getDescription();
		amazonFile.getFullName();
		amazonFile.getLastModified();
		amazonFile.getLastModifiedDate();
		amazonFile.getCreatedDate();
		amazonFile.getCreatedById();
		amazonFile.getIsPublic();
		amazonFile.getFileIdentifier();
		amazonFile.getSource();
		amazonFile.getFileIdentifierPick();
		amazonFile.getReviewStatus();
		amazonFile.getRecordTypeId();
		amazonFile.getRecordTypeDeveloperName();
		amazonFile.getCreatedBy();
		amazonFile.getId();
		amazonFile.deleteFile();
		amazonFile.deleteAmazonFile();

		Test.StopTest();
	}

	static testMethod void testwithAmazonFile(){
		AmazonCredentials cred = AmazonCredentials.getCredentials('IFAP');
		String FileName = 'IFAP/afile';
		list<AmazonRest.S3File> s3Files = AmazonRest.getListFiles(FileName,cred );

		AmazonFile__c aFile = createAmazonAttachment();

		Test.startTest();
		AmazonFile amazonFile = new AmazonFile(null, aFile);
		amazonFile.changePermission(true);
		System.assert(amazonFile.amazonFile.isPublic__c);
		amazonFile.changePermission();
		System.assert(!amazonFile.amazonFile.isPublic__c);
		AmazonRest.TESTSTRING = 'OK';
		amazonFile.copyFile(cred, cred, 'destination/');
		amazonFile.deleteAmazonFile();
		Test.StopTest();

		list<AmazonFile__c> listaFile = [Select Id From AmazonFile__c where id = :aFile.Id];
		System.assert(listaFile.isEmpty());
	}

	static testMethod void testgetFiles(){
		AmazonCredentials cred = AmazonCredentials.getCredentials('IFAP');
		AmazonFile__c aFile = createAmazonAttachment();
		AmazonXMLParser.ListEntry s3Entry = new AmazonXMLParser.ListEntry();
		s3Entry.key= aFile.Full_Name_Unique__c;
		list<AmazonRest.S3File> listS3Files = new list<AmazonRest.S3File>{new AmazonRest.S3File(s3Entry, cred)};

		Test.startTest();
		EF_AttachmentListController.runningForEF = false;
		list<AmazonFile> result = AmazonFile.getFiles(aFile.Case__c, listS3Files);
		Test.stopTest();

		System.assert(result.size() == 1);
	}

	static testMethod void testgetFile(){
		AmazonCredentials cred = AmazonCredentials.getCredentials('IFAP');
		AmazonFile__c aFile = createAmazonAttachment();
		AmazonXMLParser.ListEntry s3Entry = new AmazonXMLParser.ListEntry();
		s3Entry.key= aFile.Full_Name_Unique__c;
		list<AmazonRest.S3File> listS3Files = new list<AmazonRest.S3File>{new AmazonRest.S3File(s3Entry, cred)};

		Test.startTest();
		AmazonFile result = AmazonFile.getFile(aFile.Case__c, aFile.Full_Name_Unique__c, cred);
		Test.stopTest();
	}

}
