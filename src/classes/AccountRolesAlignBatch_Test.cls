@isTest
private class AccountRolesAlignBatch_Test {

	@testSetup
	static void setup(){

		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'United States', ISO_Code__c = 'US');
		insert isoc;

		IATA_ISO_State__c isoState = new IATA_ISO_State__c(Name = 'New York', IATA_ISO_Country__c = isoc.Id, ISO_Code__c = 'NY');
		insert isoState;

		Account acc = new Account(Name = 'Test Account');
		insert acc;
		Account acc2 = new Account(Name = 'Test Account2');
		insert acc2;

		Contact c = new Contact(LastName = 'Doe', AccountId = acc.Id, Email = 'doetest@test.com');
		insert c;

		Contact c2 = new Contact(LastName = 'Don', AccountId = acc.Id, Email = 'dontest@test.com');
		insert c2;

		String RECTYPE_Master_AccRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
		Account_Role__c accRole = new Account_Role__c(Account__c = acc.Id, Account_Role_Name__c = 'Training',Functional_Role__c = 'Training', RecordTypeId = RECTYPE_Master_AccRole );
		insert accRole;

		Id accContactRole_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Master');
		Account_Contact_Role__c acr = new Account_Contact_Role__c(Account_Role__c = accRole.Id, Contact__c = c2.Id, Service_Rendered__c = 'Other', RecordTypeId = accContactRole_RT, Contact_Role_Name__c = 'Trainee', Functional_Role__c =  'Training');
		insert acr;

		String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Training_Contact_Role_Details__c', 'Yardstick_Trainee');
		Training_Contact_Role_Details__c tcrd = new Training_Contact_Role_Details__c(Account_Contact_Role__c = acr.Id, RecordTypeId = RECTYPE_Trainee_YASContDet);
		insert tcrd;

		Portal_Applications__c pa = new Portal_Applications__c(Name = 'Training Platform (LMS)');
		insert pa;

		Term_and_Condition__c tos = new Term_and_Condition__c(NewGenApp_PortalService__c = pa.Id, Is_Latest__c = true, Status__c = 'Final', Effective_Start_Date__c = Date.today());
		insert tos;

	}

	@isTest
	static void testChangeContactAccount(){
		Account acc2 = [SELECT Id, Name FROM Account WHERE Name = 'Test Account2' LIMIT 1];
		Contact contact = [SELECT Id, Name, Email,AccountId FROM Contact WHERE LastName = 'Don' LIMIT 1];

		test.startTest();

		contact.AccountId = acc2.Id;
		update contact;

		system.assert(contact.AccountId == acc2.Id);

		test.stopTest();
	}

	@isTest
	static void testChangeContactAccount_switchAccountRoles(){
		Account acc2 = [SELECT Id, Name FROM Account WHERE Name = 'Test Account2' LIMIT 1];
		Contact contact = [SELECT Id, Name, Email,AccountId FROM Contact WHERE LastName = 'Don' LIMIT 1];

		test.startTest();

		contact.AccountId = acc2.Id;
		
		Map<Id,sObject> contactMap = new Map<Id,sObject>();
		contactMap.put(contact.Id, contact);

		AccountRolesAlignBatch.switchAccountRoles(contactMap);

		Account_Contact_Role__c acr = [SELECT Id,Account_Role__c,Account_Role__r.Account__c,Contact__c
			FROM Account_Contact_Role__c
			WHERE Contact__c = :contact.Id
			AND Contact_Role_Name__c = 'Trainee'
			AND Functional_Role__c =  'Training' LIMIT 1];

		system.assert(acr.Account_Role__r.Account__c == acc2.Id);

		test.stopTest();
	}
	
	@isTest
	static void testChangeContactAccount_switchAccountRoles_Invocable(){
		Account acc2 = [SELECT Id, Name FROM Account WHERE Name = 'Test Account2' LIMIT 1];
		Contact contact = [SELECT Id, Name, Email,AccountId FROM Contact WHERE LastName = 'Don' LIMIT 1];

		test.startTest();

		contact.AccountId = acc2.Id;
		
		List<Contact> contactList = new List<Contact>();
		contactList.add(contact);

		AccountRolesAlignBatch.switchAccountRoles(contactList);

		Account_Contact_Role__c acr = [SELECT Id,Account_Role__c,Account_Role__r.Account__c,Contact__c
			FROM Account_Contact_Role__c
			WHERE Contact__c = :contact.Id
			AND Contact_Role_Name__c = 'Trainee'
			AND Functional_Role__c =  'Training' LIMIT 1];

		system.assert(acr.Account_Role__r.Account__c == acc2.Id);

		test.stopTest();
	}
}
