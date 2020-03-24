@isTest
public class FSM_WebserviceTest {

	private static Case createCase() {
		EmailTemplate__c template = new EmailTemplate__c();
		insert template;

		Case caseObj = new Case();
		caseObj.Reminder_EmailTemplate__c = template.id;
		caseObj.Financial_Security_Amount_2__c = 100;
		caseObj.CurrencyISOCode = 'EUR';
		caseObj.FS_Letter_Sent__c = false;
		caseObj.FS_Deadline_Date__c = Date.today();
		insert caseObj;
		return caseObj;
	}

	static testMethod void sendFSRequestedLetter_ErrorTest1() {
		Test.StartTest();
		String result = FSM_Webservice.sendFSRequestedLetter('');
		Test.StopTest();

		System.assert(result != '');
	}

	static testMethod void sendFSRequestedLetter_ErrorTest2() {
		Case caseObj = createCase();
		caseObj.Reminder_EmailTemplate__c = null;
		update caseObj;

		Test.StartTest();
		String result = FSM_Webservice.sendFSRequestedLetter('');
		Test.StopTest();

		System.assert(result != '');
	}

	static testMethod void sendFSRequestedLetter_TestCargo() {
		Case caseObj = createCase();

		Account account = new Account( Name='AccountName', Industry= FSM_Webservice.CARGO );
		insert account;

		caseObj.AccountId = account.Id;
		update caseObj;

		Test.StartTest();
		String result = FSM_Webservice.sendFSRequestedLetter(caseObj.Id);
		Test.StopTest();

		caseObj = [Select FS_Deadline_Date__c from Case where Id = :caseObj.Id];
		System.assert(result != '');
		System.assert( caseObj.FS_Deadline_Date__c == Date.today().addDays(60) );
	}

	static testMethod void sendFSRequestedLetter_TestPax() {
		Case caseObj = createCase();

		Account account = new Account( Name='AccountName', Industry= FSM_Webservice.PAX );
		insert account;

		caseObj.AccountId = account.Id;
		update caseObj;

		Test.StartTest();
		String result = FSM_Webservice.sendFSRequestedLetter(caseObj.Id);
		Test.StopTest();

		caseObj = [Select FS_Deadline_Date__c from Case where Id = :caseObj.Id];
		System.assert(result != '');
		System.assert( caseObj.FS_Deadline_Date__c == Date.today().addDays(30) );
	}

	static testMethod void sendListFSRequestedLetterEmailTestOk() {

		IATA_ISO_Country__c ct1 = new IATA_ISO_Country__c (
			Name = 'Portugal', 
			ISO_Code__c = 'PT', 
			AIMS_Area_ID__c = '2'
		);
		insert ct1;

		Account acc = new Account(
			Name = 'Test Agency',
			IATA_ISO_Country__c = ct1.Id,
			IATACode__c = '1234567'
		);
		insert acc;

		Contact con = new Contact(
			AccountId = acc.Id,
			LastName = 'test',
			Email = 'testContact@test.com',
			IDcard_Email__c = 'test@test.com'
		);
		insert con;

		User usr = [Select id from User where Id = :UserInfo.getUserId()];
		EmailTemplate__c template = new EmailTemplate__c(
			Name = 'Test_Template',
			Greeting_Line__c = 'test1',
			Body_Section_1__c = 'test2',
			Body_Section_2__c = 'test3',
			Body_Section_3__c = 'test4', 
			Signature_Details__c = 'test5', 
			Text_1__c = 'test'
		);

		System.RunAs(usr) {
			insert template; 
		}

		Case cs1 = new Case();
		cs1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
		cs1.Reminder_EmailTemplate__c = template.Id; 
		cs1.Subject = 'Case ID Card Test';
		cs1.AccountId = acc.Id;
		cs1.ContactId = con.Id;
		insert cs1;

		FSM_Webservice controller = new FSM_Webservice();
		Test.startTest();
		String result = FSM_Webservice.sendFSRequestedLetter(cs1.Id);
		Test.stopTest();

		System.assertEquals(Label.Send_FS_Request_Letter_Ok, result);

	}

	static testMethod void sendListFSRequestedLetterEmailTestError() {

		IATA_ISO_Country__c ct1 = new IATA_ISO_Country__c (
			Name = 'Portugal', 
			ISO_Code__c = 'PT', 
			AIMS_Area_ID__c = '2'
		);
		insert ct1;

		Account acc = new Account(
			Name = 'Test Agency',
			IATA_ISO_Country__c = ct1.Id,
			IATACode__c = '1234567'
		);
		insert acc;

		Contact con = new Contact(
			AccountId = acc.Id,
			LastName = 'test',
			Email = 'testContact@test.com',
			IDcard_Email__c = 'test@test.com'
		);
		insert con;

		Case cs1 = new Case();
		cs1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
		cs1.Subject = 'Case ID Card Test';
		cs1.AccountId = acc.Id;
		cs1.ContactId = con.Id;
		insert cs1;

		FSM_Webservice controller = new FSM_Webservice();
		Test.startTest();
		String result = FSM_Webservice.sendFSRequestedLetter(cs1.Id);
		Test.stopTest();

		System.assertEquals(Label.Send_FS_Request_Letter_Error, result);

	}

}
