@isTest
public class PortalServicesStartupHotlistCtrlTest {
	
	@TestSetup
	static void testSetup(){
		Id accountAirlineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Id SHDetailProviderRT = RecordTypeSingleton.getInstance().getRecordTypeId('SH_Account_Role_Detail__c', 'Provider');
		Id SHDetailConsumerRT = RecordTypeSingleton.getInstance().getRecordTypeId('SH_Account_Role_Detail__c', 'Consumer');
		Id SHDetailProAndConsRT = RecordTypeSingleton.getInstance().getRecordTypeId('SH_Account_Role_Detail__c', 'Consumer_and_Provider');
		Id accountRoleRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');
	   
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', ANG_Enable_NewGen__c = true);
		insert country;
		Account newAcc1 = new Account(Name='Account Test Airline 1', Site = 'Site Test 1', Sector__c = 'Airline',IATACode__c = '123', RecordTypeId = accountAirlineRT);
		Account newAcc2 = new Account(Name='Account Test Airline 2', Site = 'Site Test 2', Sector__c = 'Airline',IATACode__c = '1234', RecordTypeId = accountAirlineRT);
		Account newAcc3 = new Account(Name='Account Test Airline 3', Site = 'Site Test 3', Sector__c = 'Airline',IATACode__c = '12345', RecordTypeId = accountAirlineRT);
		Account newAcc4 = new Account(Name='Account Test Airline 4', Site = 'Site Test 4', Sector__c = 'Airline',IATACode__c = '1234', RecordTypeId = accountAirlineRT);
		Account newAcc5 = new Account(Name='Account Test Airline 5', Site = 'Site Test 5', Sector__c = 'Airline',IATACode__c = '123456', RecordTypeId = accountAirlineRT);
		Account newAcc6 = new Account(Name='Account Test Airline 6', Site = 'Site Test 6', Sector__c = 'Other',IATACode__c = '1234567');
		insert new List<Account>{newAcc1, newAcc2, newAcc3, newAcc4, newAcc5, newAcc6};
		
		Contact newCon1 = new Contact(AccountId = newAcc1.Id, FirstName = 'John', LastName = 'Doe', Email = 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		Contact newCon2 = new Contact(AccountId = newAcc2.Id, FirstName = 'John 1', LastName = 'Doe 1', Email = 'testemailNEW@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		Contact newCon3 = new Contact(AccountId = newAcc3.Id, FirstName = 'Jane', LastName = 'Doe 1', Email = 'janedoetest@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		Contact newCon4 = new Contact(AccountId = newAcc4.Id, FirstName = 'John', LastName = 'Doe', Email = 'testemail4@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		Contact newCon5 = new Contact(AccountId = newAcc5.Id, FirstName = 'John', LastName = 'Doe', Email = 'testemail5@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		Contact newCon6 = new Contact(AccountId = newAcc6.Id, FirstName = 'John', LastName = 'Doe', Email = 'testemail6@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		insert new List<Contact>{newCon1, newCon2, newCon3, newCon4, newCon5, newCon6};
		
		Account_Role__c ar1 = new Account_Role__c(Account__c = newAcc1.Id,Account_Name__c = 'Test Role 1', Functional_Role__c = 'Startup Hotlist', RecordtypeId = accountRoleRecordTypeId);
		Account_Role__c ar2 = new Account_Role__c(Account__c = newAcc2.Id,Account_Name__c = 'Test Role 2', Functional_Role__c = 'Startup Hotlist', RecordtypeId = accountRoleRecordTypeId);
		Account_Role__c ar3 = new Account_Role__c(Account__c = newAcc3.Id,Account_Name__c = 'Test Role 3', Functional_Role__c = 'Startup Hotlist', RecordtypeId = accountRoleRecordTypeId);
		Account_Role__c ar4 = new Account_Role__c(Account__c = newAcc4.Id,Account_Name__c = 'Test Role 4', Functional_Role__c = 'Startup Hotlist', RecordtypeId = accountRoleRecordTypeId);
		insert new List<Account_Role__c>{ar1, ar2, ar3, ar4};
		
		SH_Account_Role_Detail__c SHDetail1 = new SH_Account_Role_Detail__c(Account_Role__c = ar1.Id,Company_name__c = 'Test Provider',
																			  Funding_Stage__c = 'Seed',Focus_Areas__c = 'Marketing',
																			  Tags_of_categories__c = 'Health',Technology__c = 'IOT',
																			  Logo_File_Id__c = 'test', Published__c = true,
																			  RecordTypeId = SHDetailProviderRT, Status__c='Submitted');
		SH_Account_Role_Detail__c SHDetail2 = new SH_Account_Role_Detail__c(Account_Role__c = ar2.Id,Company_name__c = 'Test Consumer',
																			  Published__c = true, RecordTypeId = SHDetailConsumerRT, Status__c='Submitted');  
		SH_Account_Role_Detail__c SHDetail3 = new SH_Account_Role_Detail__c(Account_Role__c = ar3.Id,Company_name__c = 'Test Consumer & Provider',
																			  Published__c = true, RecordTypeId = SHDetailProAndConsRT, Status__c='Approved');
		SH_Account_Role_Detail__c SHDetail4 = new SH_Account_Role_Detail__c(Account_Role__c = ar4.Id,Company_name__c = 'Account Test Airline 4',
																			  Funding_Stage__c = 'Seed',Focus_Areas__c = 'Marketing', Legal_Name__c = 'ABC', Also_Known_As__c = 'ABC', Location__c = country.Id, Company_Description__c = 'ABC',Founding_Date__c = 2018, Number_Of_Employees__c = '1-10', Funding_Amount__c = 123, Investors__c = 'ABC',Industry_Perspectives__c = 'ABC', Description__c = 'ABC', Solution__c = 'ABC', Competitive_Advantage__c = 'ABC', Competition_Competitors__c = 'ABC', Recent_News__c = 'ABC', Tags_of_categories__c = 'Health',Technology__c = 'IOT',
																			  Logo_File_Id__c = 'test', RecordTypeId = SHDetailProviderRT, Status__c='Draft');

		insert new List<SH_Account_Role_Detail__c>{SHDetail1, SHDetail2, SHDetail3, SHDetail4};
	}
	
	@isTest 
	static void testTabs() {
		List<Contact> contacts = [SELECT AccountId, FirstName,LastName, Email, User_Portal_Status__c, Status__c FROM Contact];
		User newUser1 = ISSP_ObjectFactory.createPortalUser(contacts[0]);
		User newUser2 = ISSP_ObjectFactory.createPortalUser(contacts[1]);
		User newUser3 = ISSP_ObjectFactory.createPortalUser(contacts[2]);
		Test.startTest();
		System.runAs(newUser1){
			List<PortalServicesStartupHotlistCtrl.TabWrapper> tw1 = PortalServicesStartupHotlistCtrl.getStartupHotlistTabs();
			System.assertEquals(tw1.get(0).tabIsHidden,true);
			System.assertEquals(tw1.get(0).tabIsActive,false);
			System.assertEquals(tw1.get(1).tabIsHidden,false);
			System.assertEquals(tw1.get(1).tabIsActive,true);
		}
		System.runAs(newUser2){
			List<PortalServicesStartupHotlistCtrl.TabWrapper> tw2 = PortalServicesStartupHotlistCtrl.getStartupHotlistTabs();
			System.assertEquals(tw2.get(0).tabIsHidden,false);
			System.assertEquals(tw2.get(0).tabIsActive,true);
			System.assertEquals(tw2.get(1).tabIsHidden,true);
			System.assertEquals(tw2.get(1).tabIsActive,false);
		}
		System.runAs(newUser3){
			List<PortalServicesStartupHotlistCtrl.TabWrapper> tw3 = PortalServicesStartupHotlistCtrl.getStartupHotlistTabs();
			System.assertEquals(tw3.get(0).tabIsHidden,false);
			System.assertEquals(tw3.get(0).tabIsActive,true);
			System.assertEquals(tw3.get(1).tabIsHidden,false);
			System.assertEquals(tw3.get(1).tabIsActive,false);
		}
		Test.stopTest();	
	}
	
	@isTest 
	static void testSearchProviders() {
		PortalServicesStartupHotlistCtrl.filterWrapper fw = new PortalServicesStartupHotlistCtrl.filterWrapper();       
		fw.fundingStage = 'Seed';
		fw.technologies = new List<String>{'IOT'};
		fw.focusAreas = new List<String>{'Marketing'};
		fw.categories = new List<String>{'Health'};

		String filters = JSON.serialize(fw);
		
		Test.startTest();
		List<PortalServicesStartupHotlistCtrl.ProviderWrapper> p1 = PortalServicesStartupHotlistCtrl.getLstProviders('Test',filters); 
		System.assertEquals(p1.size(),1);
		Test.stopTest();
	}
	
	@isTest 
	static void testProviderLogo() {
		List<Contact> contacts = [SELECT AccountId, FirstName,LastName, Email, User_Portal_Status__c, Status__c FROM Contact];
		SH_Account_Role_Detail__c provider = [SELECT Id FROM SH_Account_Role_Detail__c WHERE Company_name__c = 'Test Provider' LIMIT 1];       
		
		Test.startTest();
		User newUser1 = ISSP_ObjectFactory.createPortalUser(contacts[0]);
		User newUser2 = ISSP_ObjectFactory.createPortalUser(contacts[1]);
			
		System.runAs(newUser1){
			String logo1 = PortalServicesStartupHotlistCtrl.getProviderImgURLById('');
			String logo2 = PortalServicesStartupHotlistCtrl.getProviderImgURLById(provider.Id);
				
			System.assert(logo1.contains('test'));
			System.assert(logo2.contains('test'));
		}
		
		Test.stopTest();

	}
	
	@isTest 
	static void testFieldLists() {
		List<Contact> contacts = [SELECT AccountId, FirstName,LastName, Email, User_Portal_Status__c, Status__c FROM Contact];
		SH_Account_Role_Detail__c provider = [SELECT Id FROM SH_Account_Role_Detail__c WHERE Company_name__c = 'Test Provider' LIMIT 1];       
		
		Test.startTest();
		User newUser1 = ISSP_ObjectFactory.createPortalUser(contacts[0]);
			
		System.runAs(newUser1){
			List<SH_Account_Role_Detail__c> details = PortalServicesStartupHotlistCtrl.getProviderFieldLists(provider.Id,'Technology__c');
			System.assertEquals(details.size(),1);
		}
		
		Test.stopTest();

	}
	
	@isTest 
	static void testGetProviderCards() {  
		List<Contact> contacts = [SELECT AccountId, FirstName,LastName, Email, User_Portal_Status__c, Status__c FROM Contact];
		SH_Account_Role_Detail__c provider = [SELECT Id, Status__c, Published__c FROM SH_Account_Role_Detail__c WHERE Company_name__c = 'Account Test Airline 4' LIMIT 1];       
		Test.startTest();
	   
		User newUser1 = ISSP_ObjectFactory.createPortalUser(contacts[3]);
			
		System.runAs(newUser1){
			PortalWrapperClasses.ListCardsAndPropertiesWrapper lcpw = PortalServicesStartupHotlistCtrl.getProviderPropertiesAndEditCardsList();
			PortalWrapperClasses.ListCardsAndPropertiesWrapper lcpw1 = PortalServicesStartupHotlistCtrl.getProviderPropertiesAndCardsList();
			
			Map<String, String> answer = (Map<String, String>) JSON.deserialize( lcpw.extraDetails, Map<String, String>.class);
			System.assertEquals(answer.get('editStatus'),'Draft');
			System.assertEquals(lcpw.lstCards.size(),1);
			answer = (Map<String, String>) JSON.deserialize( lcpw1.extraDetails, Map<String, String>.class);
			System.assertEquals(answer.get('viewStatus'),'None');
			System.assertEquals(lcpw1.lstCards,null);

			provider.Status__c = 'Submitted';
			update provider;

			PortalWrapperClasses.ListCardsAndPropertiesWrapper lcpw2 = PortalServicesStartupHotlistCtrl.getProviderPropertiesAndEditCardsList();
			PortalWrapperClasses.ListCardsAndPropertiesWrapper lcpw3 = PortalServicesStartupHotlistCtrl.getProviderPropertiesAndCardsList();
			
			answer = (Map<String, String>) JSON.deserialize( lcpw2.extraDetails, Map<String, String>.class);
			System.assertEquals(answer.get('editStatus'),'Submitted');
			System.assertEquals(lcpw2.lstCards.size(),1);
			answer = (Map<String, String>) JSON.deserialize( lcpw3.extraDetails, Map<String, String>.class);
			System.assertEquals(answer.get('viewStatus'),'None');
			System.assertEquals(lcpw3.lstCards,null);

			provider.Status__c = 'Approved';
			provider.Published__c = true;
			update provider;

			PortalWrapperClasses.ListCardsAndPropertiesWrapper lcpw4 = PortalServicesStartupHotlistCtrl.getProviderPropertiesAndEditCardsList();
			PortalWrapperClasses.ListCardsAndPropertiesWrapper lcpw5 = PortalServicesStartupHotlistCtrl.getProviderPropertiesAndCardsList();
			PortalWrapperClasses.ListCardsAndPropertiesWrapper lcpw6 = PortalServicesStartupHotlistCtrl.getProviderDetailsPropertiesAndCardsList(provider.Id);

			answer = (Map<String, String>) JSON.deserialize( lcpw4.extraDetails, Map<String, String>.class);
			System.assertEquals(answer.get('editStatus'),'Approved');
			System.assertEquals(lcpw4.lstCards.size(),1);
			answer = (Map<String, String>) JSON.deserialize( lcpw5.extraDetails, Map<String, String>.class);
			System.assertEquals(answer.get('viewStatus'),'Published');
			System.assertEquals(lcpw5.lstCards.size(),4);
			System.assertEquals(lcpw6.extraDetails,null);
			System.assertEquals(lcpw6.lstCards.size(),4);
		}
		
		Test.stopTest();
	}
	@isTest 
	static void testCreateAccountRoleAndAccountRoleDetailsAirline() {
		Portal_Applications__c pa = new Portal_Applications__c(Name = 'Startup Hotlist', Functional_Role__c = 'Startup Hotlist');
		insert pa;
		Contact con = [SELECT Id, AccountId, FirstName,LastName, Email, User_Portal_Status__c, Status__c FROM Contact WHERE Email = 'testemail4@csp.testclass' LIMIT 1];
		User newUser1 = ISSP_ObjectFactory.createPortalUser(con);
		Test.startTest();
		System.runAs(newUser1){
			Portal_Application_Right__c par = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = pa.Id, Right__c = 'Access Granted');
			insert par;
		}
		Test.stopTest();
		List<Account_Role__c> arList = [SELECT Id FROM Account_Role__c WHERE Account__c = :con.AccountId AND Functional_Role__c = 'Startup Hotlist'];
		System.assertEquals(1, arList.size());
		List<SH_Account_Role_Detail__c> ardList = [SELECT Id FROM SH_Account_Role_Detail__c WHERE Account_Role__r.Account__c = :con.AccountId];
		System.assertEquals(1, ardList.size());
		List<PermissionSetAssignment> psList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'SH_Portal_Users' and Assignee.ContactId = :con.Id];
		System.assertEquals(1, psList.size());
	}
	@isTest 
	static void testCreateAccountRoleAndAccountRoleDetailsProvider() {
		Portal_Applications__c pa = new Portal_Applications__c(Name = 'Startup Hotlist',Functional_Role__c = 'Startup Hotlist');
		insert pa;
		Contact con = [SELECT Id, AccountId, FirstName,LastName, Email, User_Portal_Status__c, Status__c FROM Contact WHERE Email = 'testemail6@csp.testclass' LIMIT 1];
		User newUser1 = ISSP_ObjectFactory.createPortalUser(con);
		Test.startTest();
		System.runAs(newUser1){
			Portal_Application_Right__c par = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = pa.Id, Right__c = 'Access Granted');
			insert par;
		}
		Test.stopTest();
		List<Account_Role__c> arList = [SELECT Id FROM Account_Role__c WHERE Account__c = :con.AccountId AND Functional_Role__c = 'Startup Hotlist'];
		System.assertEquals(1, arList.size());
		List<SH_Account_Role_Detail__c> ardList = [SELECT Id FROM SH_Account_Role_Detail__c WHERE Account_Role__r.Account__c = :con.AccountId];
		System.assertEquals(1, ardList.size());
		List<PermissionSetAssignment> psList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'SH_Portal_Users' and Assignee.ContactId = :con.Id];
		System.assertEquals(1, psList.size());
	}

	@isTest 
	static void testGetLabelPicklistValuesAndSelected() {
		SH_Account_Role_Detail__c provider = [SELECT Id,Company_name__c, Status__c, Published__c FROM SH_Account_Role_Detail__c WHERE Company_name__c = 'Account Test Airline 4' LIMIT 1];
		Test.startTest();
		PortalServicesStartupHotlistCtrl.PicklistPropertiesWrapper ppw = PortalServicesStartupHotlistCtrl.getLabelPicklistValuesAndSelected('SH_Account_Role_Detail__c','Funding_Stage__c',provider.Id);
		Test.stopTest();
	}

	@isTest 
	static void testAttachment() {
		SH_Account_Role_Detail__c provider = [SELECT Id,Company_name__c, Status__c, Published__c FROM SH_Account_Role_Detail__c WHERE Company_name__c = 'Account Test Airline 4' LIMIT 1];
		final Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
		String sbase64 = EncodingUtil.base64Encode(beforeblob);

		Test.startTest();
		String fileUploaded = PortalServicesStartupHotlistCtrl.uploadFile(sbase64, 'test.txt', provider.Id);
		String logoId = PortalServicesStartupHotlistCtrl.saveLogoId(provider.Id, fileUploaded);
		Test.stopTest();
		List<ContentVersion> cvlList = [SELECT Id FROM ContentVersion WHERE Id = :fileUploaded];
		System.assertEquals(cvlList.size(), 1);
		System.assertEquals(logoId, provider.Id);
	}

	@isTest 
	static void testSaveProviderProfileSubmit() {
		SH_Account_Role_Detail__c provider = [SELECT Id, Company_name__c, Status__c, Funding_Stage__c, Focus_Areas__c, Published__c, Tags_of_categories__c, Technology__c, Logo_File_Id__c FROM SH_Account_Role_Detail__c WHERE Company_name__c = 'Account Test Airline 4' LIMIT 1];

		Test.startTest();
		String submitString = PortalServicesStartupHotlistCtrl.saveProviderProfile(JSON.serialize(provider), '');
		Test.stopTest();
		System.assertEquals(String.valueOf(provider.Id), submitString);
	}
	@isTest 
	static void testSaveProviderProfileSave() {
		SH_Account_Role_Detail__c provider = [SELECT Id, Company_name__c, Status__c, Funding_Stage__c, Focus_Areas__c, Published__c, Tags_of_categories__c, Technology__c, Logo_File_Id__c FROM SH_Account_Role_Detail__c WHERE Company_name__c = 'Account Test Airline 4' LIMIT 1];

		provider.Status__c = 'Approved';
		update provider;
		Test.startTest();
		String submitString = PortalServicesStartupHotlistCtrl.saveProviderProfile(JSON.serialize(provider), 'save');
		Test.stopTest();
		System.assertNotEquals(String.valueOf(provider.Id), submitString);
	}
}