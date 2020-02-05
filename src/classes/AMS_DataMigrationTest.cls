@isTest
private class AMS_DataMigrationTest {

	static {
		//initilize static variables
	}

	public static void triggers(Boolean enable){
		AMS_Trigger_Execution_Manager__c manager = AMS_Trigger_Execution_Manager__c.getInstance();
		System.debug(loggingLevel.Debug, '____ [cls AMS_DataMigrationTest - triggers] manager - ' + manager);
		manager.All__c = !enable;
		upsert manager;
	}

	@testSetup static void createData() {
		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
		insert isoc;

		Account a1 = new Account(Name='Test1 Parent Agency',IATA_ISO_Country__c = isoc.id);
		Account a2 = new Account(Name='Test1 Child Agency',IATA_ISO_Country__c = isoc.id);
		List<Account> accountList = new List<Account>{a1, a2};
		insert accountList;

		AMS_Address__c add1 = new AMS_Address__c(
			Address_Type__c = 'Primary',
			Country__c = isoc.id,
			AMS_ZipCode__c = '10100',
			City__c = 'Torino',
			Address_1__c = 'Corso',
			Address_2__c = 'via',
			Address_3__c = 'viale'
		);
		insert add1;


		AMS_Agency__c ag1 = new AMS_Agency__c(Name='Test1 Agency', IATAcode__c = '1234567', Account__c = a1.Id, Country__c =isoc.Id, Primary_Address__c = add1.Id);
		AMS_Agency__c ag2 = new AMS_Agency__c(Name='Test2 Agency', IATAcode__c = '1234568', Account__c = a2.Id, Country__c =isoc.Id, A_Code__c = '1234');
		List<AMS_Agency__c> agencyList = new List<AMS_Agency__c>{ag1, ag2};
		insert agencyList;

		AMS_Person__c p1 = new AMS_Person__c(Name='Test1 Employee');
		AMS_Person__c p2 = new AMS_Person__c(Name='Test2 Employee');
		List<AMS_Person__c> personList = new List<AMS_Person__c>{p1, p2};
		insert personList;

		AMS_Employee__c e1 = new AMS_Employee__c(Name='Test1 Employee', Person__c = p1.Id, Agency__c = ag1.Id);
		AMS_Employee__c e2 = new AMS_Employee__c(Name='Test2 Employee', Person__c = p2.Id);
		List<AMS_Employee__c> employeeList = new List<AMS_Employee__c>{e1, e2};
		insert employeeList;

		AMS_Owner__c o1 = new AMS_Owner__c(Name = 'Test Owner', Person__c = p1.Id);
		insert o1;

		AMS_Agency_Ownership__c ow1 = new AMS_Agency_Ownership__c(Agency__c = ag1.Id, AMS_Agency_Owner__c = o1.Id);
		insert ow1;

		AMS_Agencies_Hierarchy__c ah1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test Hierarchy');
		insert ah1;

		AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id, Parent_Agency__c = ag1.Id, Child_agency__c = ag2.Id);

		triggers(false); //disable triggers so we can create a relationship without account
		insert ar1;
		triggers(true);
	}

	static testMethod void test_AgencyAccountParent() {
		System.assert(AMS_DataMigration.process(null, 'AMS_Agencies_relationhip__c', 'agency_account_parent', '1', true, null, null));
	}

	static testMethod void test_AgencyAccountChild() {
		Id agencyRelationshipId = [SELECT Id FROM AMS_Agencies_relationhip__c LIMIT 1][0].Id;
		AMS_DataMigration.process(agencyRelationshipId, 'AMS_Agencies_relationhip__c', 'agency_account_child', '1', true, null, null);
	}

	static testMethod void test_Primary_Address() {
		System.assert(AMS_DataMigration.process(null, 'AMS_Agency__c', 'primary_address', '1', true, null, null));


		Id agencyId = [SELECT Id FROM AMS_Agency__c LIMIT 1][0].Id;
		AMS_DataMigration.process(agencyId, 'AMS_Agency__c', 'primary_address', '1', true, null, null);
	}

	/*static testMethod void test_AccountRoleE() {
		System.assert(AMS_DataMigration.process(null, 'AMS_Employee__c', 'account_role_e', '2', true, null, null));


		Id employeeId = [SELECT Id FROM AMS_Employee__c WHERE Agency__c = '' LIMIT 1][0].Id;
		AMS_DataMigration.process(employeeId, 'AMS_Employee__c', 'account_role_e', '2', true, null, null);
	}

	static testMethod void test_AccountRoleO() {
		System.assert(AMS_DataMigration.process(null, 'AMS_Agency_Ownership__c', 'account_role_o', '1', true, null, null));

		Id ownershipId = [SELECT Id FROM AMS_Agency_Ownership__c LIMIT 1][0].Id;
		AMS_DataMigration.process(ownershipId, 'AMS_Agency_Ownership__c', 'account_role_o', '1', true, null, null);
	}*/

	static testMethod void test_AccountRole() {
		System.assert(AMS_DataMigration.process(null, 'AMS_Agency_Ownership__c', 'account_role', '1', true, null, null));

		Id ownershipId = [SELECT Id FROM AMS_Agency_Ownership__c LIMIT 1][0].Id;
		AMS_DataMigration.process(ownershipId, 'AMS_Agency_Ownership__c', 'account_role', '1', true, null, null);
	}

	static testMethod void test_AccountDirty() {
		AMS_DataMigration.process(null, 'AMS_Agency__c', 'account_dirty', '1', true, null, null);

		Id agencyId = [SELECT Id FROM AMS_Agency__c LIMIT 1][0].Id;
		AMS_DataMigration.process(agencyId, 'AMS_Agency__c', 'account_dirty', '1', true, null, null);
	}

}
