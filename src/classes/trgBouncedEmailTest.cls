@isTest
private class trgBouncedEmailTest {

	static testMethod void myUnitTest1() {
		// TO DO: implement unit test
		ID IFAPcaseRecordTypeID = TestClass_SetupVariables.IFAPcaseRecordTypeID;
		ID ExternalCasesInvoicesWorksID = TestClass_SetupVariables.ExternalCasesInvoicesWorksID;

		insert new UtilityCS__c(Name='IFAP Bypass Rules', Value__c='Test');
		IATA_ISO_Country__c ic = new IATA_ISO_Country__c(Name = 'Canada', AIMS_Area_Name__c = 'Canada' , ISO_Code__c = 'CA', AIMS_Area_ID__c = '1');
		insert ic;

		// create test account
		Account account1 = new Account();
		account1.Name = 'Test account';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		account1.IATACode__c = '1234567';
		account1.Type = 'IATA Passenger Sales Agent';
		insert account1;

		// create test contact
		Contact contact1 = new Contact();
		contact1.FirstName = 'Dummy';
		contact1.LastName = 'Contact';
		contact1.Type_of_Contact__c = 'IFAP Contact';
		contact1.AccountId = account1.Id;
		contact1.Email = 'some@email.org';
		contact1.Financial_Assessment_Contact__c = true;
		insert contact1;

		// create parent case of type IFAP
		Case caseParent = new Case();
		caseParent.ContactId = contact1.Id;
		caseParent.AccountId = account1.Id;
		caseParent.Subject = 'Test Case 1';
		caseParent.Description = 'Test Case 1';
		caseParent.RecordTypeId = IFAPcaseRecordTypeID;
		caseParent.Status = 'Agent Notified (Mail)';
		caseParent.Origin = 'Agent Financial Review Notification';
		caseParent.FA_Letter_Sent__c = false;
		caseParent.IFAP_Financial_Year__c = '2012';
		//caseParent.Financial_Review_Type__c = 'Annual';
		caseParent.Financial_Review_Type__c = 'Adhoc';
		caseParent.IFAP_Financial_Year__c = '2012';
		caseParent.Deadline_Date__c = Date.today().addDays(30);
		caseParent.IFAP_Area__c = 'Area 1';
		insert caseParent;

		Test.startTest();
		EmailMessage emailme = new EmailMessage();
		emailme.ParentId = caseParent.Id;
		emailme.HtmlBody = 'mailbox full';
		emailme.Subject = 'Undeliverable';
		insert emailme;
		Test.stopTest();

	}

	static testMethod void myUnitTest2() {
		ID IFAPcaseRecordTypeID = TestClass_SetupVariables.IFAPcaseRecordTypeID;
		ID ExternalCasesInvoicesWorksID = TestClass_SetupVariables.ExternalCasesInvoicesWorksID;

		insert new UtilityCS__c(Name='IFAP Bypass Rules', Value__c='Test');
		IATA_ISO_Country__c ic = new IATA_ISO_Country__c(Name = 'Canada', AIMS_Area_Name__c = 'Canada' , ISO_Code__c = 'CA', AIMS_Area_ID__c = '1');
		insert ic;

		// create test account
		Account account1 = new Account();
		account1.Name = 'Test account';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		account1.IATACode__c = '1234567';
		account1.Type = 'IATA Passenger Sales Agent';
		insert account1;

		// create test contact
		Contact contact1 = new Contact();
		contact1.FirstName = 'Dummy';
		contact1.LastName = 'Contact';
		contact1.Type_of_Contact__c = 'IFAP Contact';
		contact1.AccountId = account1.Id;
		contact1.Email = 'some@email.org';
		contact1.Financial_Assessment_Contact__c = true;
		insert contact1;



		// create parent case of type IFAP
		Case caseParent1 = new Case();
		caseParent1.ContactId = contact1.Id;
		caseParent1.AccountId = account1.Id;
		caseParent1.Subject = 'Test Case 1';
		caseParent1.Description = 'Test Case 1';
		caseParent1.RecordTypeId = ExternalCasesInvoicesWorksID;
		caseParent1.Status = 'Agent Notified (Mail)';
		caseParent1.Origin = 'Agent Financial Review Notification';
		caseParent1.FA_Letter_Sent__c = false;
		caseParent1.IFAP_Financial_Year__c = '2012';
		//caseParent.Financial_Review_Type__c = 'Annual';
		caseParent1.Financial_Review_Type__c = 'Adhoc';
		caseParent1.IFAP_Financial_Year__c = '2012';
		caseParent1.Deadline_Date__c = Date.today().addDays(30);
		caseParent1.IFAP_Area__c = 'Area 1';
		insert caseParent1;

		Test.startTest();

		EmailMessage emailme1 = new EmailMessage();
		emailme1.ParentId = caseParent1.Id;
		emailme1.HtmlBody = 'mailbox full';
		emailme1.Subject = 'Undeliverable';
		insert emailme1;

		EmailMessage emailme2 = new EmailMessage();
		emailme2.ParentId = caseParent1.Id;
		emailme2.HtmlBody = 'mailbox full';
		emailme2.Subject = 'Undeliverable';
		insert emailme2;

		EmailMessage emailme3 = new EmailMessage();
		emailme3.ParentId = caseParent1.Id;
		emailme3.HtmlBody = 'mailbox full';
		emailme3.Subject = 'Undeliverable';

		Test.stopTest();

		/* Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		 User u = new User(alias = clsUtility.createAlias('TestFirstName', 'TestLastName'),
						 email = 'email@email.com', License_Cost_Center__c='ISF005CH01',
						 emailencodingkey = 'UTF-8',
						 firstname = 'TestFirstName',
						 lastname = 'TestFirstName',
						 languagelocalekey = 'en_US',
						 localesidkey = 'en_US',
						 contactId = contact1.Id,
						 timezonesidkey = 'America/New_York',
						 username = 'email@email.com',
						 CommunityNickname = 'emailE',
						 ProfileId = p.Id,
						 IsActive = true);
		 insert u;
		 if(true)
		 {
			 System.runAs (u) {
				 Case case4 = caseParent1.Clone(false, true);
				 insert case4;
			 }
		 }
		 */
	}
}
