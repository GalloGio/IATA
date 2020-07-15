@isTest
private class Term_And_Condition_SvcTest {
	
	@testSetup
	static void setup(){
		Id BYPASSTB_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Term_and_Condition__c', 'NOT_Bypass_Trigger_Behavior');
		Term_And_Condition__c tC1 = new Term_And_Condition__c(
			Name = 'Term and Condition 1 Test Draft',
			RecordTypeId = BYPASSTB_RT,
			Effective_Start_Date__c = Date.today(),
			Status__c = 'Draft',
			Attachment_Changed__c = false
		);
		insert tC1;

		User u = new User(
			Alias = 'tnCUser',
			Email = 'tnCUser' + Datetime.now().getTime() + '@test.tc',
			EmailEncodingKey = 'UTF-8',
			FirstName = 'TnC',
			LastName = 'User',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = 'tnCUser' + Datetime.now().getTime() + '@test.tc',
			License_Cost_Center__c = 'IDS005CH01'
		);
		insert u;
		insert new Apex_Setting__c(Name='RT valid to reopen attachment trigger', Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
                                           +  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application');

		System.runAs(u){
			EmailTemplate eT = new EmailTemplate(
				isActive = true,
				Name = 'Term and Condition 1 Test Email Template',
				DeveloperName = 'Term_and_Condition_1_Test_Email_Template',
				TemplateType = 'text',
				FolderId = UserInfo.getUserId()
			);
			insert eT;

			Apex_Setting__c a = new Apex_Setting__c(
				Name = 'TPL_TnC_CHANGED', 
				Text_1__c = eT.Id
			);
			insert a;
		}

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Term and Condition 1 Account';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		Contact c = new Contact(
			FirstName = 'Term and Condition 1',
			LastName = 'Contact',
			Email = 'term_an_condition_contact' + Datetime.now().getTime() + '@test.tc',
			AccountId = account.Id
		);
		insert c;

		Product2 p = new Product2(
			Name = 'Term and Condition 1 Product2',
			isActive = true
		);
		insert p;

		Id standardPbId = Test.getStandardPricebookId();

		PricebookEntry standardPbE = new PricebookEntry(
			Pricebook2Id = standardPbId,
			Product2Id = p.Id,
			UnitPrice = 18.03,
			IsActive = true
		);
		insert standardPbE;

		Pricebook2 pb = new Pricebook2(
			Name = 'Term and Condition 1 Pricebook2',
			isActive = true
		);
		insert pb;

		PricebookEntry pbE = new PricebookEntry(
			Pricebook2Id = pb.Id,
			Product2Id = p.Id,
			UseStandardPrice = false,
			isActive = true,
			UnitPrice = 18.03
		);
		insert pbE;

		Order o = new Order(
			IEC_Payment_Date__c = Date.today().addDays(3),
			AccountId = account.Id,
			EffectiveDate = Date.today(),
			Status = 'New',
			Pricebook2Id = pb.Id,
			BillToContactId = c.Id
		);
		insert o;

		OrderItem oI = new OrderItem(
			OrderId = o.Id,
			Auto_Renew__c = true,
			Accepted_Term_Condition__c = tC1.Id,
			UnitPrice = 18.03,
			PricebookEntryId = pbE.Id,
			Quantity = 1
		);
		insert oI;
	}
	
	@isTest
	static void validateTnC_BeforeInsert_Pass_test(){
		Id BYPASSTB_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Term_and_Condition__c', 'NOT_Bypass_Trigger_Behavior');
		Term_And_Condition__c tC = new Term_And_Condition__c(
			Name = 'Term and Condition validateTnC_BeforeInsert', 
			RecordTypeId = BYPASSTB_RT,
			Effective_Start_Date__c = Date.today().addDays(3),
			Status__c = 'Draft'
		);
		
		Boolean resultPass = true;
		
		Test.startTest();
		try{
			insert tC;
		} catch(Exception ex){
			resultPass = false;
		}
		Test.stopTest();
		
		System.assert(resultPass); //there are no errors, expected result
	}

	@isTest
	static void validateTnC_BeforeInsert_ErrorDate_test(){
		Id BYPASSTB_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Term_and_Condition__c', 'NOT_Bypass_Trigger_Behavior');
		Term_And_Condition__c tC = new Term_And_Condition__c(
			Name = 'Term and Condition validateTnC_BeforeInsert', 
			RecordTypeId = BYPASSTB_RT,
			Effective_Start_Date__c = Date.today().addDays(-3),
			Status__c = 'Draft'
		);
		
		Boolean resultError = false;
		String errorStr = '';
		
		Test.startTest();
		try{
			insert tC;
		} catch(Exception ex){
			errorStr = ex.getMessage();
			resultError = true;
		}
		Test.stopTest();
		
		System.assert(resultError); //there are errors
		System.assert(errorStr.contains('Effective Date cannot be in the past')); //expected result
		System.assert(!errorStr.contains('Status cannot be Final unless the T&C has an attachment')); //This error should not be one of the errors
	}

	@isTest
	static void validateTnC_BeforeInsert_ErrorStatus_test(){
		Id BYPASSTB_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Term_and_Condition__c', 'NOT_Bypass_Trigger_Behavior');
		Term_And_Condition__c tC = new Term_And_Condition__c(
			Name = 'Term and Condition validateTnC_BeforeInsert', 
			RecordTypeId = BYPASSTB_RT,
			Effective_Start_Date__c = Date.today().addDays(3),
			Status__c = 'Final'
		);
		
		Boolean resultError = false;
		String errorStr = '';
		
		Test.startTest();
		try{
			insert tC;
		} catch(Exception ex){
			errorStr = ex.getMessage();
			resultError = true;
		}
		Test.stopTest();
		
		System.assert(resultError); //there are errors
		System.assert(errorStr.contains('Status cannot be Final unless the T&C has an attachment')); //expected result
		System.assert(!errorStr.contains('Effective Date cannot be in the past')); //This error should not be one of the errors
	}

	@isTest
	static void validateTnC_BeforeUpdate_PassVN2_test(){
		Term_And_Condition__c tC = [SELECT Id, Version_Number__c, Attachment_Changed__c FROM Term_And_Condition__c WHERE Name = 'Term and Condition 1 Test Draft' LIMIT 1];
		
		Boolean resultPass = true;

		tC.Version_Number__c = 2;
		
		Test.startTest();
		try{
			update tC;
		} catch(Exception ex){
			resultPass = false;
		}
		Test.stopTest();

		Term_And_Condition__c tCResult = [SELECT Version_Number__c, Attachment_Changed__c FROM Term_And_Condition__c WHERE Id = :tC.Id LIMIT 1];
		
		System.assert(resultPass); //there are no errors
		System.assert(tCResult.Attachment_Changed__c); //expected result
		System.assertNotEquals(tC.Attachment_Changed__c, tCResult.Attachment_Changed__c);//the field was updated
	}

	@isTest
	static void validateTnC_BeforeUpdate_PassVN1_test(){
		Term_And_Condition__c tC = [SELECT Id, Version_Number__c, Attachment_Changed__c FROM Term_And_Condition__c WHERE Name = 'Term and Condition 1 Test Draft' LIMIT 1];
		
		Boolean resultPass = true;

		tC.Version_Number__c = 1;
		
		Test.startTest();
		try{
			update tC;
		} catch(Exception ex){
			resultPass = false;
		}
		Test.stopTest();

		Term_And_Condition__c tCResult = [SELECT Version_Number__c, Attachment_Changed__c FROM Term_And_Condition__c WHERE Id = :tC.Id LIMIT 1];
		
		System.assert(resultPass); //there are no errors
		System.assert(!tCResult.Attachment_Changed__c); //expected result
		System.assertEquals(tC.Attachment_Changed__c, tCResult.Attachment_Changed__c);//the field was not updated
	}

	@isTest
	static void validateTnC_BeforeUpdate_ErrorDate_test(){
		Term_And_Condition__c tC = [SELECT Id, Effective_Start_Date__c FROM Term_And_Condition__c WHERE Name = 'Term and Condition 1 Test Draft' LIMIT 1];
		
		Boolean resultError = false;
		String errorStr = '';

		tc.Effective_Start_Date__c = Date.today().addDays(-2);
		
		Test.startTest();
		try{
			update tC;
		} catch(Exception ex){
			errorStr = ex.getMessage();
			resultError = true;
		}
		Test.stopTest();

		Term_And_Condition__c tCResult = [SELECT Effective_Start_Date__c FROM Term_And_Condition__c WHERE Id = :tC.Id LIMIT 1];
		
		System.assert(resultError); //there are errors
		System.assert(errorStr.contains('Effective Date cannot be in the past')); //expected result
		System.assert(!errorStr.contains('Status cannot be Final unless the T&C has an attachment')); //This error should not be one of the errors
		System.assertNotEquals(tC.Effective_Start_Date__c, tCResult.Effective_Start_Date__c); //the field was not updated due the errors
	}

	@isTest
	static void validateTnC_BeforeUpdate_ErrorStatus_test(){
		Term_And_Condition__c tC = [SELECT Id, Status__c FROM Term_And_Condition__c WHERE Name = 'Term and Condition 1 Test Draft' LIMIT 1];
		
		Boolean resultError = false;
		String errorStr = '';

		tc.Status__c = 'Final';
		
		Test.startTest();
		try{
			update tC;
		} catch(Exception ex){
			errorStr = ex.getMessage();
			resultError = true;
		}
		Test.stopTest();

		Term_And_Condition__c tCResult = [SELECT Status__c FROM Term_And_Condition__c WHERE Id = :tC.Id LIMIT 1];
		
		System.assert(resultError); //there are errors
		System.assert(errorStr.contains('Status cannot be Final unless the T&C has an attachment')); //expected result
		System.assert(!errorStr.contains('Effective Date cannot be in the past')); //This error should not be one of the errors
		System.assertNotEquals(tC.Status__c, tCResult.Status__c); //the field was not updated due the errors
	}

	@isTest
	static void notifyAutoRenewCustomers_AfterUpdate_Email_test(){
		Term_And_Condition__c tC = [SELECT Id, Status__c, Version_Number__c FROM Term_And_Condition__c WHERE Name = 'Term and Condition 1 Test Draft' LIMIT 1];

		Attachment att = new Attachment(
			ParentId = tC.Id,
			Name = 'Term_and_Condition_1_Attachment.pdf',
			Body = Blob.valueOf('Term and Condition 1 Test Body')
		);
		insert att;

		// to be able to enter in the method notifyAutoRenewCustomers
		tC.Status__c = 'Final';
		tC.Version_Number__c = 2; //make Attachment_Changed__c = true
		
		Test.startTest();
			update tC;
			Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(1, invocations);
	}

	@isTest
	static void notifyAutoRenewCustomers_AfterUpdate_NoEmail_test(){
		Term_And_Condition__c tC = [SELECT Id, Status__c, Version_Number__c FROM Term_And_Condition__c WHERE Name = 'Term and Condition 1 Test Draft' LIMIT 1];

		Contact c = [SELECT Id, EmailBouncedDate, EmailBouncedReason FROM Contact WHERE FirstName = 'Term and Condition 1' LIMIT 1];
		c.EmailBouncedDate = Datetime.now();
		c.EmailBouncedReason = 'If the contact has the email bounced, the class Term_And_Condition_Svc will not send an email.';
		update c;

		Attachment att = new Attachment(
			ParentId = tC.Id,
			Name = 'Term_and_Condition_1_Attachment.pdf',
			Body = Blob.valueOf('Term and Condition 1 Test Body')
		);
		insert att;

		// to be able to enter in the method notifyAutoRenewCustomers
		tC.Status__c = 'Final';
		tC.Version_Number__c = 2; //make Attachment_Changed__c = true
		
		Test.startTest();
			update tC;
			Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(0, invocations);
	}

	@isTest
	static void getFinalTerms_AfterUpdate_NoNotifyAutoRenewCustomers_test(){
		Term_And_Condition__c tC = [SELECT Id, Status__c, Version_Number__c FROM Term_And_Condition__c WHERE Name = 'Term and Condition 1 Test Draft' LIMIT 1];

		Attachment att = new Attachment(
			ParentId = tC.Id,
			Name = 'Term_and_Condition_1_Attachment.pdf',
			Body = Blob.valueOf('Term and Condition 1 Test Body')
		);
		insert att;

		// not able to enter in the method notifyAutoRenewCustomers because it is not Final, so there is no email
		tC.Version_Number__c = 2;
		
		Test.startTest();
			update tC;
			Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(0, invocations);
	}
}