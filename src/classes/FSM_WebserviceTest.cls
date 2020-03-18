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

}
