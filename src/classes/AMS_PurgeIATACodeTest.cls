@isTest
private class AMS_PurgeIATACodeTest {
	
	@testSetup static void setup(){

		Date myDate1 = Date.newInstance(2016, 2, 17);
		Date myDate2 = Date.newInstance(2016, 2, 17);

        ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Portugal');
        insert portugal;


		// create test account1
		Account account1 = new Account();
		account1.Name = 'Test account 1';
		account1.IATACode__c = '1234567';
		account1.Type = 'IATA Cargo Agent';
		account1.BillingCity = 'Lisboa';
		account1.BillingCountry = 'Portugal';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		account1.Accreditation_date__c = myDate1;
		account1.recordTypeId = rtAgency;
		account1.IATA_ISO_Country__c = portugal.Id;
		account1.Location_Class__c = 'C';
		account1.Purge_Flag__c = false;

		insert account1;

		// create test account1
		Account account2 = new Account();
		account2.Name = 'Test account 2';
		account2.IATACode__c = '12345689111';
		account2.Type = 'IATA Cargo Agent';
		account2.BillingCity = 'Lisboa';
		account2.BillingCountry = 'Portugal';
		account2.BillingStreet = 'some street 2';
		account2.Location_Type__c = 'HO';
		account2.Accreditation_date__c = myDate2;
		account2.recordTypeId = rtAgency;
		account2.IATA_ISO_Country__c = portugal.Id;
		account2.Location_Class__c = 'C';
		account2.Purge_Flag__c = false;

		insert account2;

		GDP_Products_Account_View__c gdp = new GDP_Products_Account_View__c(IATA_Code__c = '1234567');
		GDP_Products_Account_View__c gdp2 = new GDP_Products_Account_View__c(IATA_Code__c = '12345689111');

		insert gdp;
		insert gdp2;

	}

	@isTest static void runProcessForIatacodePurge() {
		
		Test.startTest();

		List<Account> accts = [SELECT Id, Name, Accreditation_date__c, Status__c , Location_Class__c, IATACode__c from Account];

		Set<Id> accountsToPurge = new Set<Id>{accts.get(0).Id, accts.get(1).Id};

		AMS_PurgeAccountBatch pab = new AMS_PurgeAccountBatch(accountsToPurge);

    	Id aMS_PurgeAccountBatchId = Database.executeBatch(pab,200);

		Test.stopTest();

		accts = [SELECT Id, Accreditation_date__c, Status__c , Location_Class__c, IATACode__c, NAme from Account];

		System.assertEquals('X1234567',accts.get(0).IATACode__c );
		
		List<GDP_Products_Account_View__c> gdps = [select Id, IATA_Code__c from GDP_Products_Account_View__c];

		System.assertEquals('X1234567', gdps.get(0).IATA_Code__c);
	}

	

	@isTest static void aMS_PurgeIATACodeControllerTest() {

		PageReference pageRef = Page.AMS_PurgeIATACodePage;

        Test.setCurrentPageReference(pageRef);

        AMS_PurgeIATACodeController controller = new AMS_PurgeIATACodeController();

        Test.startTest();
        
        //AMS_VoucherManagerPage page = new AMS_VoucherManagerPage(sc);
        
        controller.checkBatchStatus();

        controller.contentFile = Blob.valueOf('Id,IATACode__c,C_Code__c,A_Code__c,N_Code__c,Site,Name,Location_Type__c,Location_Class__c,Expiry_Date__c,Accreditation_date__c,Not to Purge SFDC,Not to Purge External\n0013E0000000000001,00000000012,,,,,Account A Portugal,HO,C,,Wed Jan 01 00:00:00 GMT 2014,,');

        controller.fetchSOQLObjects();

        controller.ReadFile();

        controller.runPurgeProcess();

        List<String> notesTest = controller.noteListFullPurge;
		List<String> notesTest2 = controller.noteListLitePurge;
		List<String> notesTest3 = controller.noteListUpload;

        Test.stopTest();

	}
	
}