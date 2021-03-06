@IsTest
private class AddressRoleBusinessContextEventHdlTest {
	@TestSetup static void generateTestData(){
		User admin = TestUtilities.createAdminUser();

		CustomPermission cp = [SELECT Id FROM CustomPermission WHERE DeveloperName='E_F_Account_Flow_Creation'];
		PermissionSet pS = new PermissionSet(Name ='Test', Label ='Test');
		insert pS;
		SetupEntityAccess sep = new SetupEntityAccess(ParentId =pS.Id, SetupEntityId=cp.Id);
		insert sep;
		PermissionSetAssignment pSA = new PermissionSetAssignment(PermissionSetId = pS.Id, AssigneeId = admin.Id);
		insert pSA;

		System.runAs(admin){
			IATA_ISO_Country__c iataIsoCountry = new IATA_ISO_Country__c(Name = 'Canada', ISO_Code__c = 'CA', ISO_Code_Numeric__c = 999, Region__c = 'Americas', Sub_Region__c = 'Can-Ber', ISS_Office_Location__c = 'Canada');
			insert iataIsoCountry;

			Account account = new Account(
					RecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Others').getRecordTypeId(),
					Name = 'test account',
					Sector__c = 'IATA',
					Category__c = 'IATA HEAD OFFICE',
					CurrencyIsoCode = 'USD',
					Business_Street__c = '42 Edmond',
					Business_City_Name__c = 'Montreal',
					Business_Postal_Code__c = 'h1v1f8',
					Business_State_Name__c = 'Quebec',
					IATA_ISO_Country__c = iataIsoCountry.Id,
					Legal_name__c = 'test account',
					VAT_Number__c = 'vatnum'
			);
			insert account;

			Account_Role__c accR = new Account_Role__c(
					RecordTypeId = Account_Role__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId(),
					Account__c = account.Id,
					CurrencyIsoCode = 'USD',
					Functional_Role__c = 'E&F',
					Flow_Status__c = 'Pending'
			);
			insert accR;

			Address__c businessAddress = [SELECT Id FROM Address__c WHERE Is_Business_Address__c = true AND Account__c = :account.Id LIMIT 1];

			Address_Role__c addrR = [SELECT Id FROM Address_Role__c WHERE Address__c = :businessAddress.Id AND Role_Type__c = 'Business' LIMIT 1];

			Business_Context__c bC = new Business_Context__c(
					Business_Context__c = 'E&F',
					CurrencyIsoCode = 'USD',
					Name = 'E&F - E&F Standard',
					Sub_Context__c = 'E&F Standard'
			);
			insert bC;

			Address_Role_Business_Context__c addrBC = new Address_Role_Business_Context__c(
					Address_Role__c = addrR.Id,
					Business_Context__c = bC.Id,
					Account_Activation_Context_Status__c = 'Pending'
			);
			insert addrBC;
		}
	}

	@IsTest
	static void testCreateIntegrationLogWhenEventIsPublishedInTheFlow() {
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin){
			Address_Role_Business_Context__c arbc = [SELECT Id, Account_Activation_Context_Status__c, Address_Role__r.Role_Type__c FROM Address_Role_Business_Context__c LIMIT 1];
			CustomerSyncUtils.createIntegrationLogs(new Map<Id, SObject>{
				arbc.id => arbc
			});
			AddressRoleBusinessContext__e event = new AddressRoleBusinessContext__e(RecordType__c = 'MASTER', RecordId__c = arbc.Id, EventType__c = 'Insert');

			Test.startTest();
			Database.SaveResult result = EventBus.publish(event);
			Test.stopTest();

			System.assertEquals(true, result.isSuccess());
			List<Integration_Log__c> integrationLogs = [SELECT Id, External_Transaction_Id__c FROM Integration_Log__c WHERE RecordId__c = :arbc.Id];
			System.assertEquals(1, integrationLogs.size());
			System.assertNotEquals(null, integrationLogs[0].External_Transaction_Id__c);
		}
	}
}