@isTest
public class WrapperAttachTest {


	@testSetup
	public static void loadTestCredentials() {
		
		list<Amazon_Cred__c> listAmazonCred =  new list<Amazon_Cred__c>{
			new Amazon_Cred__c(
				name = 'GenericAttach',
				Prod_Configuration__c = 'GenericAttach-prod' ,
				Dev_Configuration__c = 'GenericAttach-dev'
			),
			new Amazon_Cred__c(
				name = 'RecycleBin',
				Prod_Configuration__c = 'RecycleBin-prod' ,
				Dev_Configuration__c = 'RecycleBin-dev'
			)
		};
		insert listAmazonCred;
	
		list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
			new AWSKey__c(
				name = 'GenericAttach-prod',
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'
			),
			new AWSKey__c(
				name = 'GenericAttach-dev' ,
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'
			),
			new AWSKey__c(
				name = 'RecycleBin-prod',
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'
			),
			new AWSKey__c(
				name = 'RecycleBin-dev' ,
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'
			)
		};
		insert AWS_KEYs;
	}
	
	public static AmazonFile createAmazonFile(Case cse) {
		
		String filename = 'testname';
		
		AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = filename,
			Case__c = cse.Id
		);
		insert aFile;
		
		aFile = [Select isPublic__c, SystemModstamp, Size_MB__c, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, 
                 		Full_Name_Unique__c, File_Identifier__c, Description__c, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, 
                 		ConnectionReceivedId, Case__c, CreatedBy.Name, File_Identifier_picklist__c, Review_Status__c, Source__c, RecordTypeId, 
                 		RecordType.DeveloperName, Internal_Comments__c, Document_Date__c, Category__c, Subcategory__c, Expiry_Date__c, Expired__c, SAP_Number__c, Skip_Validation__c, EF_Private__c,
                 		AMS_Updated_By__c, AMS_Updated_Date__c
                 From AmazonFile__c where id = :aFile.Id];
		
		list<AmazonRest.S3File> s3Files = AmazonRest.getListFiles(filename,AmazonCredentials.getCredentials('GenericAttach') );
		
		return new AmazonFile(s3Files[0], aFile);
	}

	public static AmazonFile createAmazonFile(ISSP_External_Report__c er, String filename) {

		AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = filename,
			sObject_Id__c = er.Id,
			isPublic__c = True
		);
		insert aFile;
		
		aFile = [Select isPublic__c, SystemModstamp, Size_MB__c, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, 
                 		Full_Name_Unique__c, File_Identifier__c, Description__c, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, 
                 		ConnectionReceivedId, Case__c, CreatedBy.Name, File_Identifier_picklist__c, Review_Status__c, Source__c, RecordTypeId, 
                 		RecordType.DeveloperName, Internal_Comments__c, Document_Date__c, Category__c, Subcategory__c, Expiry_Date__c, Expired__c, SAP_Number__c, Skip_Validation__c, EF_Private__c,
                 		AMS_Updated_By__c, AMS_Updated_Date__c
                 From AmazonFile__c where id = :aFile.Id];
		
		list<AmazonRest.S3File> s3Files = AmazonRest.getListFiles(filename,AmazonCredentials.getCredentials('GenericAttach') );
		
		return new AmazonFile(s3Files[0], aFile);
	}
	
	public static Attachment createAttachment(Case cse) {
		Attachment att = new Attachment(
			ParentId = cse.Id,
			Name = 'testname',
			Body = Blob.ValueOf('test')
		);
		insert att;
		
		att = [Select SystemModstamp, ParentId, OwnerId, Name, LastModifiedDate, LastModifiedById, IsPrivate, IsPartnerShared, IsDeleted, Id, Description, CreatedDate, CreatedById, ContentType, ConnectionSentId, ConnectionReceivedId, BodyLength, Body, createdBy.Name
			From Attachment where id = :att.Id];
		
		ISSPAttachmentPermission__c permission = new ISSPAttachmentPermission__c(
			AttachmentId__c = cse.Id,
			ShowToPortalUsers__c = true 
		);
		insert permission;
		return att;
	}
	
	static testMethod void testCreateFromAttachment() {
		Case cse = new Case();
		insert cse;
		
		Attachment att = createAttachment(cse);
		ISSPAttachmentPermission__c permission = [Select Id, ShowToPortalUsers__c, AttachmentId__c from ISSPAttachmentPermission__c where AttachmentId__c = :cse.id];
		
		
		Test.startTest();
		WrapperAttach attach = new WrapperAttach(att, permission);
		System.assert(attach.isPublic);
		
		//test change permission
		attach.changePermission(true);
		permission = [Select ShowToPortalUsers__c from ISSPAttachmentPermission__c where id = :permission.Id];
		System.assert(permission.ShowToPortalUsers__c);
		attach.changePermission();
		permission = [Select ShowToPortalUsers__c from ISSPAttachmentPermission__c where id = :permission.Id];
		System.assert(!permission.ShowToPortalUsers__c);
		
		System.assert(attach.getIsSalesforce());
		System.assert(!attach.getIsAmazon());
		System.assert(!attach.getIsArchived());
		System.assert(attach.viewFile()!=null);
		
		//transfer is only valid in Amazon
		System.assert(attach.transfer(null)==null);
		
		// move to bucket is only valid in Amazon
		System.assert(attach.moveToBucket()==false);
		
		attach.description = 'description';
		attach.updateAttach();
		
		Test.stopTest();
		
	}
	
	static testMethod void testCreateFromArchived() {
		Case cse = new Case();
		insert cse;
		
		Archived_Attachment__c att = new Archived_Attachment__c(
			Case__c = cse.Id,
			Bucket__c = 'bucket',
			Name = 'testname',
			BodyLength__c = 10
		);
		insert att;
		
		att = [Select SystemModstamp, Original_Creation_Date__c, OriginalCreatedBy__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, Description__c, CurrencyIsoCode, CreatedDate, CreatedById, ContentType__c, ConnectionSentId, ConnectionReceivedId, Case__c, Bucket__c, BodyLength__c, ArchivedMessage__c, AWS_S3_URL__c, createdBy.Name, Internal_Comments__c
			From Archived_Attachment__c where id = :att.id];
		
		
		Test.startTest();
		WrapperAttach attach = new WrapperAttach(att);
		System.assert(!attach.isPublic);
		
		attach.changePermission(true);
		attach.changePermission();
		
		System.assert(!attach.getIsSalesforce());
		System.assert(attach.getIsArchived());
		System.assert(!attach.getIsAmazon());
		System.assert(attach.viewFile()!=null);
		
		//transfer is only valid in Amazon
		System.assert(attach.transfer(null)==null);
		
		// move to bucket is only valid in Amazon
		System.assert(attach.moveToBucket()==false);
		
		attach.description = 'description';
		attach.updateAttach();
		
		Test.stopTest();
	}
	
	static testMethod void testCreateFromAmazon() {
		Case cse = new Case();
		insert cse;
		AmazonFile amazonFile = createAmazonFile(cse);
		Case cse2 = new Case();
		insert cse2;
		
		Test.startTest();
		WrapperAttach attach = new WrapperAttach(amazonFile);
		System.assert(!attach.isPublic);
		
		attach.changePermission(true);
		attach.changePermission();
		
		System.assert(!attach.getIsSalesforce());
		System.assert(!attach.getIsArchived());
		System.assert(attach.getIsAmazon());
		System.assert(attach.viewFile()==null);
		
		AmazonRest.TESTSTRING = 'OK';
		AmazonFile copied = attach.transfer(cse2.Id);
		System.assert(copied != null);
		
		Boolean result = attach.moveToBucket();
		System.assert(result);
		
		attach.description = 'description';
		//attach.updateAttach();
		
		Test.stopTest();
		
	}
	
	static testMethod void testGetAttachments() {
		Case cse = new Case();
		insert cse;
		
		createAttachment(cse);
		createAmazonFile(cse);
		
		Test.startTest();
		list<WrapperAttach> listAttachments1 = WrapperAttach.getListAttachments(cse.Id);
		list<WrapperAttach> listAttachments2 = WrapperAttach.getListAttachmentsForPortal(cse.Id);
		Test.stopTest();
	}
	
	static testMethod void testgetAmazonAttachment() {
		AmazonFile__c aFile = AmazonFileTest.createAmazonAttachment();
		
		Test.startTest();
		WrapperAttach result = WrapperAttach.getAmazonAttachment(aFile.Case__c, aFile.Full_Name_Unique__c);
		Test.stopTest();
	}
	
}