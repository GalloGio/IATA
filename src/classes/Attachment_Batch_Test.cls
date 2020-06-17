@isTest
private class Attachment_Batch_Test {
   
	@isTest static void test_Attachment_Batch() {

		TestDataGenerator.generateApexSetting();
        insert new Apex_Setting__c(Name='RT valid to reopen attachment trigger', Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
                                           +  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application');
		//Create Order with Attachments
		Account account = TestDataGenerator.generateAccounts(1, true)[0];
		Contact contact = TestDataGenerator.generateContacts(account.Id, 1, true)[0];

		//Create Attachments
		List<Attachment> attachments = new List<Attachment>();
		for(Order order : TestDataGenerator.generateOrder(10, account.Id, contact.Id, contact.Id, true)){
			Attachment attachment = TestDataGenerator.createAttachment(order.Id, order.Id, 'test content');
			attachments.add(attachment);
		}

		System.assertEquals(attachments.size(),10);

		//Test the schedule and the batch
		Test.startTest();
		Attachment_Sch.scheduleDeleteSAPInvoices('0 0 20 * * ?');
		Test.stopTest();
		System.assertEquals(attachments.size(),10);

	}
	@isTest static void test_Attachment_case() {
		
        Account accountA = new Account(Name = 'Test');
        insert accountA;
        Contact contactA = new Contact(LastName = 'Test Contact', Email='test@gmail.com', AccountId = accountA.Id);
        insert contactA;
		//Create Case
		Case case1 = new Case(ContactId= ContactA.Id, AccountId = accountA.Id, Status = 'Open', Origin = 'Airline Participation', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope'));
        insert case1;
        
       
        
        //Close the case
		case1.Status = 'Closed';
        update case1;
        
		Test.startTest();
        insert new Apex_Setting__c(Name='RT valid to reopen attachment trigger', Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
                                           +  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application');
        //Create Attachment to reopening the case
		Attachment attachment = TestDataGenerator.createAttachment(case1.Id, 'attachmentCase', 'test content');
		Test.stopTest();
	}

}