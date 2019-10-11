@isTest
private class KanbanBoardControllerTest {
	
	@testSetup static void testSetup() {

		//create the custom setting value for KanbanColumns__c
		KanbanColumns__c cs = new KanbanColumns__c(Name='CaseEU261', Headers__c='Closed;Escalated Externally;In progress;New;Pending customer;Resolved');
		insert cs;

		//create an iso country
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Portugal';
		country.ISO_Code__c = 'PT';
		insert country;

		//create an account
		Account acc = new Account();
		acc.Name = 'Account Test';
		acc.IATA_ISO_Country__c = country.Id;
		insert acc;

		//create 2 contacts
		List<Contact> cons = new List<Contact>();
		Contact con1 = new Contact();
		con1.FirstName = 'First';
		con1.LastName = 'Last';
		con1.Email = 'first.last.kanbanTest@test.eu261';
		con1.AccountId = acc.Id;
		cons.add(con1);

		Contact con2 = new Contact();
		con2.FirstName = 'First';
		con2.LastName = 'Last2';
		con2.Email = 'first.last2.kanbanTest@test.eu261';
		con2.AccountId = acc.Id;
		cons.add(con2);
		
		insert cons;

		//create a user for each contact
		Profile pro = [SELECT Id, Name FROM Profile WHERE Name = 'Partner Community User'];

		List<User> usrs = new List<User>();

        User u = new User();
        u.FirstName = cons.get(0).FirstName;
        u.LastName = cons.get(0).LastName;
        u.Alias = cons.get(0).LastName;
        u.Email = cons.get(0).Email;
        u.Username = cons.get(0).Email;
        u.CommunityNickname = cons.get(0).LastName;
        u.ProfileId = pro.Id;
        u.TimeZoneSidKey = 'Europe/Brussels';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US'; 
        u.ContactId = cons.get(0).Id;
        usrs.add(u);

        User u2 = new User();
        u2.FirstName = cons.get(1).FirstName;
        u2.LastName = cons.get(1).LastName;
        u2.Alias = cons.get(1).LastName;
        u2.Email = cons.get(1).Email;
        u2.Username = cons.get(1).Email;
        u2.CommunityNickname = cons.get(1).LastName;
        u2.ProfileId = pro.Id;
        u2.TimeZoneSidKey = 'Europe/Brussels';
        u2.LocaleSidKey = 'en_US';
        u2.EmailEncodingKey = 'ISO-8859-1';
        u2.LanguageLocaleKey = 'en_US'; 
        u2.ContactId = cons.get(1).Id;
        usrs.add(u2);

        insert usrs;

		//create two cases with the record type ClaimEU261
		List<Case> csList = new List<Case>();
		
		Case cs1 = new Case();
		cs1.Subject = 'test 1 ClaimEU261';
		cs1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261');
		cs1.AccountId = acc.Id;
		cs1.ContactId = cons.get(0).Id;
		cs1.OwnerId = usrs.get(0).Id;
		cs1.Status = 'New';
		csList.add(cs1);

		Case cs2 = new Case();
		cs2.Subject = 'test 2 ClaimEU261';
		cs2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261');
		cs2.AccountId = acc.Id;
		cs2.ContactId = cons.get(0).Id;
		cs2.OwnerId = usrs.get(0).Id;
		cs2.Status = 'New';
		csList.add(cs2);

		//create a case with another record type
		Case cs3 = new Case();
		cs3.Subject = 'test 3 ClaimEU261';
		cs3.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
		cs3.AccountId = acc.Id;
		cs3.ContactId = cons.get(0).Id;
		cs3.OwnerId = usrs.get(0).Id;
		cs3.Status = 'New';
		csList.add(cs3);

		insert csList;

	}
	
	@isTest static void getAllClaimEU261Cases() {
		//get all the cases in the wrapper
		Test.startTest();
		KanbanBoardController.kanbanWrap kanbanWrapData = KanbanBoardController.getKanbanWrap('Case', new List<String>{'CaseNumber', 'Contact.Name', 'Contact.Id', 'Subject', 'Status'}, 'Status', 'CaseEU261', '');
		Test.stopTest();

		System.assertEquals(6, kanbanWrapData.pickVals.size());
		System.assertEquals(2, kanbanWrapData.records.size());
	}

	@isTest static void getClaimEU261CasesFromSearch() {
		//try to search for a specific case
		Case cs = [SELECT Id, CaseNumber FROM Case WHERE RecordTypeId =:RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261') LIMIT 1];

		Test.startTest();
		KanbanBoardController.kanbanWrap kanbanWrapData = KanbanBoardController.getKanbanWrap('Case', new List<String>{'CaseNumber', 'Contact.Name', 'Contact.Id', 'Subject', 'Status'}, 'Status', 'CaseEU261', cs.CaseNumber);
		Test.stopTest();

		System.assertEquals(6, kanbanWrapData.pickVals.size());
		System.assertEquals(1, kanbanWrapData.records.size());
	}

	@isTest static void updateCaseSuccess() {
		//try to update a case with the respective owner
		User usr = [SELECT Id FROM User WHERE Username = 'first.last.kanbanTest.test.eu261@partner.iata.org' LIMIT 1];
		Case cs = [SELECT Id FROM Case WHERE RecordTypeId =:RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261') LIMIT 1];

		String result = '';

		Test.startTest();
		System.runAs(usr) {
			result = KanbanBoardController.getUpdateStage(cs.Id, 'Status', 'In progress');
		}
		Test.stopTest();
		
		System.assertEquals('Success', result);
	}

	@isTest static void updateCaseError() {
		//try to update a case with another community user (not the owner) from the same account
		User usr = [SELECT Id FROM User WHERE Username = 'first.last2.kanbanTest.test.eu261@partner.iata.org' LIMIT 1];
		Case cs = [SELECT Id FROM Case WHERE RecordTypeId =:RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261') LIMIT 1];

		String result = '';

		Test.startTest();
		
		try{
			System.runAs(usr) {
				result = KanbanBoardController.getUpdateStage(cs.Id, 'Status', 'In progress');
				System.assert(false); //the action is supposed to throw an error
			}
		} catch (Exception e) {
			System.assert(true); //the action is supposed to throw an error
		}

		Test.stopTest();
	}
	
}