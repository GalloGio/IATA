@IsTest
private class FlowUpdateAccountRoleWithoutSharingTest {
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

			Account acc = new Account(
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
			insert acc;

			Account_Role__c accR = new Account_Role__c(
					RecordTypeId = Account_Role__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId(),
					Account__c = acc.Id,
					CurrencyIsoCode = 'USD',
					Functional_Role__c = 'E&F'
			);
			insert accR;
		}
	}

	@IsTest
	static void testUpdateAccountRoleWithoutSharing() {
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin) {
			Account account = [SELECT Id FROM Account WHERE Name = 'test account' LIMIT 1];

			Account_Role__c accountRoleEF = [SELECT Id FROM Account_Role__c WHERE Account__c = :account.Id AND Functional_Role__c = 'E&F' LIMIT 1];

			List<FlowUpdateAccountRoleWithoutSharing.Request> requests = new List<FlowUpdateAccountRoleWithoutSharing.Request>();
			FlowUpdateAccountRoleWithoutSharing.Request request = new FlowUpdateAccountRoleWithoutSharing.Request();
			request.accountRoleId = accountRoleEF.Id;
			request.flowStatus = 'Pending';
			requests.add(request);

			Test.startTest();
			FlowUpdateAccountRoleWithoutSharing.execute(requests);
			Test.stopTest();
			Account_Role__c accountRoleEfAfter = [SELECT Flow_Status__c FROM Account_Role__c WHERE Id = :accountRoleEF.Id];
			System.assertEquals('Pending', accountRoleEfAfter.Flow_Status__c);

		}
	}
}