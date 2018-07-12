@isTest
private class AMS_AccountRoleHelperTest {
	
	@testSetup
	private static void createData() {
		Id agencyRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		
		Account a = new Account(Name = 'Test Account', RecordTypeId = agencyRecTypeId);
		insert a;

		AMS_Person__c p1 = new AMS_Person__c(Name = 'AAA', Legacy_System__c = 'AIMS');
		AMS_Person__c p2 = new AMS_Person__c(Name = 'BBB1', Legacy_System__c = 'AIMS');
		AMS_Person__c p3 = new AMS_Person__c(Name = 'BBB2', Legacy_System__c = 'AIMS');
		AMS_Person__c p4 = new AMS_Person__c(Name = 'CCC', Legacy_System__c = 'AIMS');
		insert new List<AMS_Person__c>{p1, p2, p3, p4};
	}
	
	@isTest
	private static void test_aimsOwnerMerge() {
		Account a = [SELECT Id FROM Account];
		List<AMS_Person__c> persons = [SELECT Id, Name FROM AMS_Person__c ORDER BY Name ASC];

		Id ownerRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

		Test.startTest();

			AMS_Account_Role__c owner1 = new AMS_Account_Role__c(RecordTypeId = ownerRecTypeId, Account__c = a.Id, Person__c = persons[0].Id, Owner_Sequence__c = 1, Percentage__c = 1);
			insert owner1;

			AMS_Account_Role__c owner2 = new AMS_Account_Role__c(RecordTypeId = ownerRecTypeId, Account__c = a.Id, Person__c = persons[1].Id, Owner_Sequence__c = 2);
			insert owner2;

			AMS_Account_Role__c owner3 = new AMS_Account_Role__c(RecordTypeId = ownerRecTypeId, Account__c = a.Id, Person__c = persons[2].Id, Owner_Sequence__c = 3, Percentage__c = 1);
			insert owner3;

			AMS_Account_Role__c owner4 = new AMS_Account_Role__c(RecordTypeId = ownerRecTypeId, Account__c = a.Id, Person__c = persons[3].Id, Owner_Sequence__c = 4, Percentage__c = 1);
			insert owner4;

			AMS_Account_Role__c owner5 = new AMS_Account_Role__c(RecordTypeId = ownerRecTypeId, Account__c = a.Id, Owner_Name__c = 'DDD1', Legacy_System__c = 'AIMS1', Legacy_External_ID__c = 'AIMS', Owner_Sequence__c = 5);
			insert owner5;

			AMS_Account_Role__c owner6 = new AMS_Account_Role__c(RecordTypeId = ownerRecTypeId, Account__c = a.Id, Owner_Name__c = 'DDD2', Legacy_System__c = 'AIMS1', Legacy_External_ID__c = 'AIMS', Owner_Sequence__c = 6, Percentage__c = 1);
			insert owner6;

		Test.stopTest();

	}
	
}