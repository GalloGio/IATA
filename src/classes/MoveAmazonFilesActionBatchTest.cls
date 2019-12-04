@isTest
public class MoveAmazonFilesActionBatchTest {

	@TestSetup
	static void setup(){

		list<Amazon_Cred__c> listAmazonCred =  new list<Amazon_Cred__c>{
			new Amazon_Cred__c(
				name = 'GenericAttach',
				Dev_Configuration__c = 'GenericAttach-dev'
			),
			new Amazon_Cred__c(
				name = 'RecycleBin',
				Dev_Configuration__c = 'RecycleBin-dev'
			)
		};
		insert listAmazonCred;
	
		list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
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

		Case cse = new Case();
		insert cse;
	}
	
	@isTest static void moveAmazonFileSuccessTest(){

		Case cse = [SELECT Id FROM Case LIMIT 1];

		List<WrapperAttach> wrapAttachmentsLst = WrapperAttach.getListAttachments(cse.Id);

		Case newCase = new Case();
		insert newCase;

		List<AmazonFile__c> insertFiles = new List<AmazonFile__c>();
		Map<WrapperAttach,Id> filesToMoveMap = new Map<WrapperAttach,Id>();

		for(WrapperAttach wa : wrapAttachmentsLst){
			filesToMoveMap.put(wa, newCase.Id);
			insertFiles.add(wa.fileAmazon.amazonFile);
		}
		
		//For testing purposes we force the insert
		insert insertFiles;

		Test.startTest();

		Database.executeBatch(new MoveAmazonFilesActionBatch(filesToMoveMap));

		Test.stopTest();
		
		List<AmazonFile__c> deletedFiles = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE Case__c = :cse.Id];
		System.assert(deletedFiles.size()==0, 'The files must be deleted from the original case ('+ cse.Id + ')');

		List<AmazonFile__c> files = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE Case__c = :newCase.Id];
		System.assert(files.size()==insertFiles.size(), 'The files must be present on the new case ('+ newCase.Id + ')');

	}

	@isTest static void moveAmazonFileGeneralFailTest(){

		Case cse = [SELECT Id FROM Case LIMIT 1];

		List<WrapperAttach> wrapAttachmentsLst = WrapperAttach.getListAttachments(cse.Id);

		Case newCase = new Case();
		insert newCase;

		Map<WrapperAttach,Id> filesToMoveMap = new Map<WrapperAttach,Id>();

		for(WrapperAttach wa : wrapAttachmentsLst){
			filesToMoveMap.put(wa, newCase.Id);
		}

		Test.startTest();

		Database.executeBatch(new MoveAmazonFilesActionBatch(filesToMoveMap));

		Test.stopTest();

		List<AmazonFile__c> files = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE Case__c = :newCase.Id];
		System.assert(files.size()==0, 'The files must NOT be present on the new case ('+ newCase.Id + ')');

		List<Technical_Logs__c> logs = [SELECT Id, Log__c, Operation__c, Status__c, Record__c FROM Technical_Logs__c];
		System.assert(logs.size()==1, 'Must have one technical log record');

	}

	@isTest static void moveAmazonFileForceS3FailTest(){

		Case cse = [SELECT Id FROM Case LIMIT 1];

		List<WrapperAttach> wrapAttachmentsLst = WrapperAttach.getListAttachments(cse.Id);

		Case newCase = new Case();
		insert newCase;

		List<AmazonFile__c> insertFiles = new List<AmazonFile__c>();
		Map<WrapperAttach,Id> filesToMoveMap = new Map<WrapperAttach,Id>();

		for(WrapperAttach wa : wrapAttachmentsLst){
			filesToMoveMap.put(wa, newCase.Id);
			insertFiles.add(wa.fileAmazon.amazonFile);
		}

		insert insertFiles;

		Test.startTest();
		
		MoveAmazonFilesActionBatch mafab = new MoveAmazonFilesActionBatch(filesToMoveMap);
		
		//Force an error while trying to move the file on S3
		AmazonRest.TESTRESULT = 'NOK';

		Database.executeBatch(mafab);

		Test.stopTest();

		List<AmazonFile__c> files = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE Case__c = :newCase.Id];
		System.assert(files.size()==0, 'The files must NOT be present on the new case ('+ newCase.Id + ')');

		List<Technical_Logs__c> logs = [SELECT Id, Log__c, Operation__c, Status__c, Record__c FROM Technical_Logs__c];
		System.assert(logs.size()==2, 'Must have two technical log records');

	}

}