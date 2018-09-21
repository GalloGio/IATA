@isTest
private class AMS_OSCAR_RollbackTest {

	@testSetup static void setup() {
		/*** Set IATA ISO Country ***/
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Wakanda';
		country.ISO_Code__c = 'XW';
		country.ISO_Code_Numeric__c = 11;
		insert country;

		/*** Set IATA ISO State ***/
		IATA_ISO_State__c state = new IATA_ISO_State__c();
		state.Name = 'WAKA';
		state.ISO_Code__c = 'XW';
		state.IATA_ISO_Country__c = country.Id;
		insert state;

		/*** Set HO Account ***/
		Account ho = createAccount(null, 'P', 'HO', country, state, 'HO');
		insert ho;
		

		/*** Set BR Account ***/
		Account br = createAccount(null, 'P', 'BR', country, state, 'BR');
		insert br;

		/*** Set Hierarchy ***/	
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c= 'Hierarchy');
		insert hierarchy;

		/*** Set Relations ***/
		AMS_Agencies_relationhip__c relation = new AMS_Agencies_relationhip__c(Hierarchy__c= hierarchy.Id, Parent_Account__c= ho.Id, Child_Account__c= br.Id);
		insert relation;

		/*** Set Contact ***/
		Contact con = new Contact();
		con.FirstName = 'FirstName';
		con.LastName = 'LastName';
		con.Financial_Assessment_Contact__c = true;
		con.Email = 'ownercontact@mail.com';
		insert con;

		/*** Set Owners ***/
		List<AMS_Account_Role__c> owners = new List<AMS_Account_Role__c>();
		AMS_Account_Role__c ownerHO = new AMS_Account_Role__c();
		ownerHO.Account__c = ho.Id;
		ownerHO.RecordTypeId = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();
		ownerHO.Contact__c = con.Id;
		ownerHO.Percentage__c = 100;
		AMS_Account_Role__c ownerBR = ownerHO.clone();
		ownerBR.Account__c = br.Id;
		owners.add(ownerHO);
		owners.add(ownerBR);
		insert owners;
	}	

	private static Account createAccount(Id parentId, String locationClass, String locationType, IATA_ISO_Country__c country, IATA_ISO_State__c state, String code) {
		Account acc = new Account();
		acc.Top_Parent__c = parentId;
		acc.ParentId = parentId;
		acc.Name = 'Agency Name ' + code;
		acc.Legal_name__c = 'Agency Legal Name ' + code;
		acc.TradeName__c = 'Agency Trade Name ' + code;
		acc.IATACode__c = '1233456';
		acc.Company_Type__c = 'A';
		acc.Short_Name__c = 'Agency Short Name ' + code;
		acc.Location_Type__c = locationType;
		acc.Location_Class__c = locationClass;
		acc.License_Number__c = 'L-123456';
		acc.VAT_Number__c = 'V123456';
		acc.VAT_Number_2__c = 'V1234567';
		acc.GDS__c = 'ABAC';
		acc.IATA_ISO_Country__c = country.Id;
		acc.BillingStreet = 'BStreet';
		acc.BillingCity = 'BCity';
		acc.BillingCountry = 'Wakanda';
		acc.BillingPostalCode = 'WK1234';
		acc.IATA_ISO_Billing_State__c = state.Id;
		acc.Iso_State__c = state.Id;
		acc.IATA_ISO_Shipping_Country__c = country.Id;
		acc.IATA_ISO_Shipping_State__c = state.Id;
		acc.ShippingStreet = 'SStreet';
		acc.ShippingCity = 'SCity';
		acc.ShippingCountry = 'Wakanda';
		acc.ShippingPostalCode = 'WK1234';
		acc.Email__c = code + 'homail@mail.com';
		acc.Website = 'www.' + code + '.com';
		acc.Phone = '123456789';
		acc.Fax = '123456789';
		acc.In_a_Airport__c = false;
		acc.Mobile__c = '123456789';
		acc.Abbreviated_name__c = code;
		acc.Remittance_frequency__c = 'M';
		acc.Status__c = 'Approved';
		acc.Reason__c = '91-ACCREDITED-MEETS-STANDARDS';
		acc.Sector__c = 'Travel Agent';
		acc.Category__c = 'IATA Passenger Sales Agent';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();

		return acc;
	}



	/*
	 *	Test creation of savepoints
	*/
	@isTest static void testMethod1() {
		/*** Set OSCAR ***/
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(); 
		oscar.Name = '123456789';
		oscar.RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();
		oscar.Account__c = [SELECT Id FROM Account WHERE Location_Type__c = 'HO' LIMIT 1].Id;
		oscar.Type_of_change__c = 'Ownership to non-IATA Agent';
		insert oscar;

		Test.startTest();
		AMS_OSCAR_Savepoint svp = new AMS_OSCAR_Savepoint(new List<AMS_OSCAR__c>{oscar});
		svp.createSavepoint();
		svp.deletePreviousSavepoint();
		svp.createSavepoint();
		List<Technical_Logs__c> backupData = [SELECT Log__c, Status__c FROM Technical_Logs__c];
		Integer accountRecords = 0;
		Integer ownersRecords = 0;
		Integer relationRecords = 0;

		for(Technical_Logs__c data : backupData) {
			if(data.Status__c == 'Account') accountRecords++;
			if(data.Status__c == 'Owner') ownersRecords++;
			if(data.Status__c == 'Relation') relationRecords++;
		}

		System.assertEquals(2, accountRecords);
		System.assertEquals(1, relationRecords);
		System.assertEquals(2, ownersRecords);
		System.assertEquals(6 ,backupData.size());

		Test.stopTest();
	}

	/*
	 * Test Minor Change, only one account rollback
	*/
	@isTest static void testMethod2() {
		/*** Set OSCAR ***/
		Account acc = [SELECT Id, Name, TradeName__c FROM Account WHERE Location_Type__c = 'BR' LIMIT 1];
		String tradeName = acc.TradeName__c;
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(); 
		oscar.Name = '123456789';
		oscar.RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();
		oscar.Account__c = acc.Id;
		oscar.Type_of_change__c = 'Minor Change';
		insert oscar;

		Test.startTest();
		AMS_OSCAR_Savepoint svp = new AMS_OSCAR_Savepoint(new List<AMS_OSCAR__c>{oscar});
		svp.createSavepoint();

		acc.TradeName__c = 'New Trade Name';
		update acc;

		AMS_OSCAR_Rollback rbk = new AMS_OSCAR_Rollback(new List<AMS_OSCAR__c>{oscar});
		rbk.rollbackOSCAR();
		acc = [SELECT Id, Name, TradeName__c FROM Account WHERE Id = :acc.Id];

		System.assertEquals(tradeName, acc.TradeName__c);

		Test.stopTest();
	}	

	/*
	 * Test Hierarchy change
	*/
	@isTest static void testMethod3() {
		Account acc = [SELECT Id, Name, TradeName__c, ParentId, Top_Parent__c, Location_Type__c FROM Account WHERE Location_Type__c = 'BR' LIMIT 1];
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(); 
		oscar.Name = '123456789';
		oscar.RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();
		oscar.Account__c = acc.Id;
		oscar.Type_of_change__c = 'Ownership to non-IATA Agent';
		insert oscar;

		Test.startTest();
		AMS_OSCAR_Savepoint svp = new AMS_OSCAR_Savepoint(new List<AMS_OSCAR__c>{oscar});
		svp.createSavepoint();

		Id parentId = acc.ParentId;

		acc.ParentId = null;
		acc.Top_Parent__c = null;
		acc.Location_Type__c = 'HO';

		update acc;

		delete [SELECT Id FROM AMS_Agencies_Hierarchy__c];

		AMS_OSCAR_Rollback rbk = new AMS_OSCAR_Rollback(new List<AMS_OSCAR__c>{oscar});
		rbk.rollbackOSCAR();

		List<AMS_Agencies_Hierarchy__c> hierarchies = [SELECT Id FROM AMS_Agencies_Hierarchy__c];

		system.assertEquals(1, hierarchies.size());

		List<AMS_Agencies_relationhip__c> relations = [SELECT Id, Child_Account__c, Parent_Account__c 
													   FROM AMS_Agencies_relationhip__c
													   WHERE Hierarchy__c = :hierarchies[0].Id];

		system.assertEquals(1, relations.size());	
		system.assertEquals(parentId, relations[0].Parent_Account__c);	
		system.assertEquals(acc.Id,  relations[0].Child_Account__c);	

		Test.stopTest();
	}
}