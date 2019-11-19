@IsTest
private class FlowGetBusinessContextsInvocableTest {

	@TestSetup static void generateTestData(){
		User admin = TestUtilities.createAdminUser();

		//permissions
		CustomPermission cp = [SELECT Id FROM CustomPermission WHERE DeveloperName='E_F_Account_Flow_Creation'];
		PermissionSet pS = new PermissionSet(Name ='Test', Label ='Test');
		insert pS;
		SetupEntityAccess sep = new SetupEntityAccess(ParentId =pS.Id, SetupEntityId=cp.Id);
		insert sep;
		PermissionSetAssignment pSA = new PermissionSetAssignment(PermissionSetId = pS.Id, AssigneeId = admin.Id);
		insert pSA;

		System.runAs(admin){

			//metadatas
			//Functional_Role__mdt : must exist in org (Label = 'E&F', DeveloperName = 'EAF')
			//Business_Context_Configuration__mdt : must exist in org (Label = 'E&F Account Flow Creation', DeveloperName = 'E_F_Account_Flow_Creation', Account_Create_Permission_Name__c = 'E_F_Account_Flow_Creation')
			//Sales_Area_Mapping__mdt : must exist in org

			//datas
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

	@IsTest static void testGetBusinessContextsInvocableEF(){
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin){
			Account account = [SELECT Id FROM Account WHERE Name = 'test account' LIMIT 1];

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
					Business_Context__c = bC.Id
			);
			insert addrBC;

			List<FlowGetBusinessContextsInvocable.Request> requests = new List<FlowGetBusinessContextsInvocable.Request>();
			FlowGetBusinessContextsInvocable.Request request = new FlowGetBusinessContextsInvocable.Request();
			request.accountId = account.Id;
			requests.add(request);

			Test.startTest();
			List<FlowGetBusinessContextsInvocable.Response> responses = FlowGetBusinessContextsInvocable.execute(requests);
			Test.stopTest();

			System.assertEquals(true, responses[0].businessContextAvailable.contains('E&F'));
		}
	}

	@IsTest static void testGetBusinessContextsInvocableEFAfterFlowLaunched(){
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin){
			Account account = [SELECT Id FROM Account WHERE Name = 'test account' LIMIT 1];

			Account_Role__c accountRoleEF = [SELECT Id FROM Account_Role__c WHERE Account__c = :account.Id AND Functional_Role__c = 'E&F' LIMIT 1];
			update new Account_Role__c(Id = accountRoleEF.Id, Flow_Status__c = 'Pending');

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

			List<FlowGetBusinessContextsInvocable.Request> requests = new List<FlowGetBusinessContextsInvocable.Request>();
			FlowGetBusinessContextsInvocable.Request request = new FlowGetBusinessContextsInvocable.Request();
			request.accountId = account.Id;
			requests.add(request);

			Test.startTest();
			List<FlowGetBusinessContextsInvocable.Response> responses = FlowGetBusinessContextsInvocable.execute(requests);
			Test.stopTest();

			System.assertEquals(false, responses[0].businessContextAvailable.contains('E&F')); //since accR.Flow_Status__c == 'Pending'
		}
	}

}