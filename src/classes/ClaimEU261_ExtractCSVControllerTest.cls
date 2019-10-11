@isTest
private class ClaimEU261_ExtractCSVControllerTest {
	
	@testSetup static void testSetup() {
		//create an iso country
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Portugal';
		country.ISO_Code__c = 'PT';
		insert country;

		//create 2 accounts
		List<Account> accts = new List<Account>();
		Account acc = new Account();
		acc.Name = 'Account Test';
		acc.IATA_ISO_Country__c = country.Id;
		accts.add(acc);

		Account acc1 = new Account();
		acc1.Name = 'Account Test 1';
		acc1.IATA_ISO_Country__c = country.Id;
		accts.add(acc1);

		insert accts;

		//create contact
		Contact con1 = new Contact();
		con1.FirstName = 'First';
		con1.LastName = 'Last';
		con1.Email = 'first.last.kanbanTest@test.eu261';
		con1.AccountId = accts.get(0).Id;
		insert con1;

		//create a user for each contact
		Profile pro = [SELECT Id, Name FROM Profile WHERE Name = 'Partner Community User'];

        User u = new User();
        u.FirstName = con1.FirstName;
        u.LastName = con1.LastName;
        u.Alias = con1.LastName;
        u.Email = con1.Email;
        u.Username = con1.Email;
        u.CommunityNickname = con1.LastName;
        u.ProfileId = pro.Id;
        u.TimeZoneSidKey = 'Europe/Brussels';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US'; 
        u.ContactId = con1.Id;
        insert u;

		//create two cases with the record type ClaimEU261
		List<Case> csList = new List<Case>();
		
		Case cs1 = new Case();
		cs1.Subject = 'test 1 ClaimEU261';
		cs1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261');
		cs1.AccountId = accts.get(0).Id;
		cs1.ContactId = con1.Id;
		cs1.OwnerId = u.Id;
		cs1.Status = 'New';
		csList.add(cs1);

		Case cs2 = new Case();
		cs2.Subject = 'test 2 ClaimEU261';
		cs2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261');
		cs2.AccountId = accts.get(0).Id;
		cs2.ContactId = con1.Id;
		cs2.OwnerId = u.Id;
		cs2.Status = 'New';
		csList.add(cs2);

		//create a case with another record type
		Case cs3 = new Case();
		cs3.Subject = 'test 3 ClaimEU261';
		cs3.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261');
		cs3.AccountId = accts.get(1).Id;
		cs3.OwnerId = UserInfo.getUserId();
		cs3.Status = 'New';
		csList.add(cs3);

		insert csList;
	}

	@isTest static void updateCaseSuccess() {
		//get the 2 cases created for the contact's account
		User usr = [SELECT Id FROM User WHERE Email = 'first.last.kanbanTest@test.eu261' LIMIT 1];

		List<Case> caseList = new List<Case>();

		Test.startTest();
		System.runAs(usr) {
			caseList = ClaimEU261_ExtractCSVController.getListEU261Cases();
		}
		Test.stopTest();
		
		System.assertEquals(2, caseList.size());
	}
}