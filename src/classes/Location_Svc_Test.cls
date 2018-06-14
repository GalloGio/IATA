@isTest
private class Location_Svc_Test {

	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Build test data
	****************************************************************************************************/
	@testSetup static void setup()
	{
		TestDataGenerator.generateApexSetting();
		
		List<IATA_ISO_Country__c> lstCountryState = TestDataGenerator.generateISOCountryState();
		IATA_ISO_Country__c countryCanada;
		IATA_ISO_State__c stateOntario, stateQuebec;
		for (IATA_ISO_Country__c country : lstCountryState)
			if (country.ISO_Code__c == 'CA')
			{
				countryCanada = country;
				for (IATA_ISO_State__c state : country.IATA_ISO_States__r)
					if (state.ISO_Code__c == 'CA-ON')
						stateOntario = state;
					else if (state.ISO_Code__c == 'QC')
						stateQuebec = state;
				break;
			}
		
		Account accountHQ1 = new Account(Name = 'Test HQ 1', Sector__c = 'Test', Category__c = 'Test', VAT_Number__c = '123'
		                               , BillingStreet ='Billing Street 1', BillingCity= 'Billing City 1', BillingPostalCode ='H0H0H0'
		                               , IATA_ISO_Country__c = countryCanada.Id , IATA_ISO_Billing_State__c = stateQuebec.Id
		                               , IATA_ISO_Shipping_Country__c = countryCanada.Id);
		Account accountHQ2 = new Account(Name = 'Test HQ 2', Sector__c = 'Test', Category__c = 'Test', VAT_Number__c = '123'
		                               , BillingStreet ='Billing Street 1', BillingCity= 'Billing City 1', BillingPostalCode ='H0H0H0'
		                               , IATA_ISO_Country__c = countryCanada.Id , IATA_ISO_Billing_State__c = stateQuebec.Id
		                               , ShippingStreet ='Shipping Street 1', ShippingCity = 'Shipping City 1', ShippingPostalCode ='H0H0H0'
		                               , IATA_ISO_Shipping_State__c = stateQuebec.Id, IATA_ISO_Shipping_Country__c = countryCanada.Id);
		Account accountHQ3 = new Account(Name = 'Test HQ 3', Sector__c = 'Test', Category__c = 'Test', VAT_Number__c = '123'
		                               , BillingStreet ='Billing Street 3', BillingCity= 'Billing City 3', BillingPostalCode ='H0H0H0'
		                               , IATA_ISO_Country__c = countryCanada.Id , IATA_ISO_Billing_State__c = stateQuebec.Id);
		Account accountHQ4 = new Account(Name = 'Test HQ 4', Sector__c = 'Test', Category__c = 'Test', VAT_Number__c = '123'
		                               , BillingStreet ='Billing Street 3', BillingCity= 'Billing City 3', BillingPostalCode ='H0H0H0'
		                               , IATA_ISO_Country__c = countryCanada.Id , IATA_ISO_Billing_State__c = stateQuebec.Id);
		insert new List<Account>{accountHQ1, accountHQ2, accountHQ3, accountHQ4};
		Account accountBranch1 = new Account(Name = 'Test Branch 1', Sector__c = 'Test', Category__c = 'Test', VAT_Number__c = '123', ParentId = accountHQ1.Id
		                                   , BillingStreet ='Billing Street 2', BillingCity= 'Billing City 2', BillingPostalCode ='H0H0H0'
		                                   , IATA_ISO_Country__c = countryCanada.Id , IATA_ISO_Billing_State__c = stateOntario.Id
		                                   , ShippingStreet ='Shipping Street 2', ShippingCity = 'Shipping City 2', ShippingPostalCode ='H0H0H0'
		                                   , IATA_ISO_Shipping_State__c = stateOntario.Id, IATA_ISO_Shipping_Country__c = countryCanada.Id);
		insert accountBranch1;
	
		List<Contact> lstContact = new List<Contact>();
		lstContact.add(new Contact(AccountId = accountHQ1.Id, FirstName = '1-FirstName', LastName = 'LastName', Email = 'test1@test.com', phone='111-111-1111'));
		lstContact.add(new Contact(AccountId = accountHQ2.Id, FirstName = '1-FirstName', LastName = 'LastName', Email = 'test3@test.com', phone='333-333-3333'));
		lstContact.add(new Contact(AccountId = accountBranch1.Id, FirstName = '1-FirstName', LastName = 'LastName', Email = 'test2@test.com', phone='222-222-2222'));
		lstContact.add(new Contact(AccountId = accountBranch1.Id, FirstName = '2-FirstName', LastName = 'LastName', Email = 'test2@test.com', phone='222-222-2222'));
		lstContact.add(new Contact(AccountId = accountHQ3.Id, FirstName = '1-FirstName', LastName = 'LastName', Email = 'test2@test.com', phone='222-222-2222'));
		lstContact.add(new Contact(AccountId = accountHQ3.Id, FirstName = '2-FirstName', LastName = 'LastName', Email = 'test2@test.com', phone='222-222-2222'));
		lstContact.add(new Contact(AccountId = accountHQ4.Id, FirstName = '1-FirstName', LastName = 'LastName', Email = 'test2@test.com', phone='222-222-2222'));
		insert lstContact;

		List<IECAddress__c> lstAddress = new List<IECAddress__c>();
		lstAddress.add(new IECAddress__c(Street__c = '1-' + accountHQ1.BillingStreet, City__c = accountHQ1.BillingCity, ISO_Country__c = accountHQ1.IATA_ISO_Country__c, ISO_State__c = accountHQ1.IATA_ISO_Billing_State__c, ZipCode__c = accountHQ1.BillingPostalCode));
		lstAddress.add(new IECAddress__c(Street__c = '2-' + accountBranch1.BillingStreet, City__c = accountBranch1.BillingCity, ISO_Country__c = accountBranch1.IATA_ISO_Country__c, ISO_State__c = accountBranch1.IATA_ISO_Billing_State__c, ZipCode__c = accountBranch1.BillingPostalCode));
		lstAddress.add(new IECAddress__c(Street__c = '3-' + accountBranch1.ShippingStreet, City__c = accountBranch1.ShippingCity, ISO_Country__c = accountBranch1.IATA_ISO_Country__c, ISO_State__c = accountBranch1.IATA_ISO_Shipping_State__c, ZipCode__c = accountBranch1.ShippingPostalCode));
		lstAddress.add(new IECAddress__c(Street__c = '4-' + accountHQ2.BillingStreet, City__c = accountHQ2.BillingCity, ISO_Country__c = accountHQ2.IATA_ISO_Country__c, ISO_State__c = accountHQ2.IATA_ISO_Billing_State__c, ZipCode__c = accountHQ2.BillingPostalCode));
		lstAddress.add(new IECAddress__c(Street__c = '5-' + accountHQ2.ShippingStreet, City__c = accountHQ2.ShippingCity, ISO_Country__c = accountHQ2.IATA_ISO_Country__c, ISO_State__c = accountHQ2.IATA_ISO_Shipping_State__c, ZipCode__c = accountHQ2.ShippingPostalCode));
		insert lstAddress;
	} //*** end of "setup"


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Return a map of accounts by name
	****************************************************************************************************/
	static Map<String, Account> getAccount()
	{
		Map<String, Account> mapAccountName_Account = new Map<String, Account>();
		for (Account a : [select Id, Name, (select Id, Name, Email, Phone from Contacts order by FirstName) from Account])
			mapAccountName_Account.put(a.Name, a);
		return mapAccountName_Account;
	}


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Return list of addresses in system
	****************************************************************************************************/
	static List<IECAddress__c> getAddress()
	{
		return [select Id, Street__c, City__c, ISO_Country__c, ISO_Country__r.ISO_Code__c, ISO_State__c, ISO_State__r.ISO_Code__c, ZipCode__c from IECAddress__c order by Street__c];
	}


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Cover method setLocationAccountId
	****************************************************************************************************/
	static testMethod void test_setLocationAccountId()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		Account accountHQ1 = mapAccountName_Account.get('Test HQ 1');
		Account accountBranch1 = mapAccountName_Account.get('Test Branch 1');
		List<Contact> lstContact;
		List<IECAddress__c> lstAddress = getAddress();
		Integer i1;

		//*** cover insert scenario
		List<Location__c> lstLocation = new List<Location__c>();
		lstContact = accountHQ1.Contacts;
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Ship To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		lstContact = accountBranch1.Contacts;
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Bill To', Address__c = lstAddress[1].Id, Account__c = accountBranch1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Ship To', Address__c = lstAddress[1].Id, Account__c = accountBranch1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		insert lstLocation;
		for (i1 = 0; i1 < lstLocation.size(); i1++)
			lstLocation[i1].Account__c = null;
		Location_Svc.setLocationAccountId(lstLocation, null, true);
		for (i1 = 0; i1 < lstLocation.size(); i1++)
			system.assert(lstLocation[i1].Account__c == accountHQ1.Id, 'Wrong account ' + lstLocation[i1].Account__c);

		//*** cover update scenario
		Map<Id, Location__c> mapOldLocation = new Map<Id, Location__c>();
		lstLocation[2].Id = lstLocation[0].Id;   mapOldLocation.put(lstLocation[0].Id, lstLocation[0]);
		lstLocation[3].Id = lstLocation[1].Id;   mapOldLocation.put(lstLocation[1].Id, lstLocation[1]);
		lstLocation.remove(1);
		lstLocation.remove(0);
		Location_Svc.setLocationAccountId(lstLocation, mapOldLocation, false);
	} //*** end of "test_setLocationAccountId"


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Cover method SendLocationToSAP
	****************************************************************************************************/
	static testMethod void test_SendLocationToSAP()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		Account accountHQ1 = mapAccountName_Account.get('Test HQ 1');
		List<Contact> lstContact = accountHQ1.Contacts;
		List<IECAddress__c> lstAddress = getAddress();

		//*** no assert needed
		List<Location__c> lstLocation = new List<Location__c>();
		Location_Svc.SendLocationToSAP(lstLocation);
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		insert lstLocation;
		Location_Svc.SendLocationToSAP(lstLocation);
	} //*** end of "test_SendLocationToSAP"


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Cover method locationToCreate
	****************************************************************************************************/
	static testMethod void test_locationToCreate()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		Account accountHQ1 = mapAccountName_Account.get('Test HQ 1');
		List<Contact> lstContact = accountHQ1.Contacts;
		List<IECAddress__c> lstAddress = getAddress();

		List<Location__c> lstLocation = new List<Location__c>();
		Location_Svc.SendLocationToSAP(lstLocation);
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		insert lstLocation;
		List<Location__c> lstLocationNew = Location_Svc.locationToCreate(lstLocation);
		system.assert(lstLocationNew.size() > 0, 'Wrong count');
	} //*** end of "test_locationToCreate"


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Cover method syncLocationsWithZuora
	****************************************************************************************************/
	static testMethod void test_syncLocationsWithZuora()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		Account accountHQ1 = mapAccountName_Account.get('Test HQ 1');
		List<Contact> lstContact = accountHQ1.Contacts;
		List<IECAddress__c> lstAddress = getAddress();

		//*** no assert needed
		List<Location__c> lstLocation = new List<Location__c>();
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		insert lstLocation;
		Location_Svc.syncLocationsWithZuora(new Set<Id>{lstLocation[0].Id});
	} //*** end of "test_syncLocationsWithZuora"


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Cover method syncLocationsUpdateWithExternalSystems and syncLocationsUpdateWithNewOrders
	****************************************************************************************************/
	static testMethod void test_syncLocationsUpdateWithExternalSyst()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		Account accountHQ1 = mapAccountName_Account.get('Test HQ 1');
		List<Contact> lstContact = accountHQ1.Contacts;
		List<IECAddress__c> lstAddress = getAddress();

		//*** no assert needed
		List<Location__c> lstLocation = new List<Location__c>();
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		insert lstLocation;
		lstLocation.add(lstLocation[0].clone(true, true));
		lstLocation[0].Address__c = lstAddress[1].Id;
		Location_Svc.syncLocationsUpdateWithExternalSystems(lstLocation, new Map<Id, Location__c>{lstLocation[0].Id => lstLocation[1]});
		
		Location_Svc.syncLocationsUpdateWithNewOrders(new Map<Id, Location__c>{lstLocation[0].Id => lstLocation[0]}, new Map<Id, Location__c>{lstLocation[0].Id => lstLocation[0]});
	} //*** end of "test_syncLocationsUpdateWithExternalSyst"


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Cover method IsLocationValid
	****************************************************************************************************/
	static testMethod void test_IsLocationValid()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		Account accountHQ1 = mapAccountName_Account.get('Test HQ 1');
		Account accountHQ2 = mapAccountName_Account.get('Test HQ 2');
		List<Contact> lstContact;
		List<IECAddress__c> lstAddress = getAddress();

		//*** no assert needed
		List<Location__c> lstLocation1 = new List<Location__c>(), lstLocation2 = new List<Location__c>();
		lstLocation1.add(new Location__c(Active__c = true, Type__c = 'Sold To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id));
		lstLocation1.add(new Location__c(Active__c = true, Type__c = 'Sold To', Address__c = lstAddress[0].Id, Account__c = accountHQ2.Id));
		lstContact = accountHQ1.Contacts;
		lstLocation1.add(new Location__c(Active__c = true, Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		lstLocation1.add(new Location__c(Active__c = true, Type__c = 'Ship To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		lstContact = accountHQ2.Contacts;
		lstLocation1.add(new Location__c(Active__c = true, Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ2.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		lstLocation1.add(new Location__c(Active__c = true, Type__c = 'Ship To', Address__c = lstAddress[0].Id, Account__c = accountHQ2.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		lstLocation2 = lstLocation1.deepClone();
		Location_Svc.IsLocationValid(lstLocation1);   //*** success part
		insert lstLocation1;
		Location_Svc.IsLocationValid(lstLocation2);   //*** error part
	} //*** end of "test_IsLocationValid"


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Cover method forbidSAPLocationDeletion
	****************************************************************************************************/
	static testMethod void test_forbidSAPLocationDeletion()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		Account accountHQ1 = mapAccountName_Account.get('Test HQ 1');
		List<Contact> lstContact = accountHQ1.Contacts;
		List<IECAddress__c> lstAddress = getAddress();

		//*** no assert needed
		List<Location__c> lstLocation = new List<Location__c>();
		lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'test', Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		insert lstLocation;
		Location_Svc.forbidSAPLocationDeletion(lstLocation);
		
	} //*** end of "test_forbidSAPLocationDeletion"


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Cover method validateOneActiveBillTo
	****************************************************************************************************/
	static testMethod void test_validateOneActiveBillTo()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		Account accountHQ1 = mapAccountName_Account.get('Test HQ 1');
		List<Contact> lstContact = accountHQ1.Contacts;
		List<IECAddress__c> lstAddress = getAddress();

		//*** no assert needed
		List<Location__c> lstLocation = new List<Location__c>();
		lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'test', Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		insert lstLocation;
		lstLocation = lstLocation.deepClone();
		Location_Svc.validateOneActiveBillTo(lstLocation);
	} //*** end of "test_validateOneActiveBillTo"


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Cover method createLocation
	****************************************************************************************************/
	static testMethod void test_createLocation()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		Account accountHQ1 = mapAccountName_Account.get('Test HQ 1');
		List<Contact> lstContact = accountHQ1.Contacts;
		List<IECAddress__c> lstAddress = getAddress();

		Location__c location = Location_Svc.createLocation(accountHQ1.Id, lstAddress[0].Id, lstContact[0].Id, lstContact[0].Email, lstContact[0].Phone, null, 'Bill To');
		system.assert(location != null, 'Something wrong');
	} //*** end of "test_createLocation"


	/****************************************************************************************************
	    Created by Thai 2016-12-16
	        Cover method initializeDefaultLocations that indirectly covers method formatAddressToQuery
	****************************************************************************************************/
	static testMethod void test_initializeDefaultLocations()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		List<IECAddress__c> lstAddress = getAddress();
		Account selectAccount;
		List<Contact> lstContact;
		List<SObject> lstSObject = new List<SObject>();
		List<String> lstResult;
		
		//*** cover scenarios where some partner already exists
		selectAccount = mapAccountName_Account.get('Test HQ 3');
		lstContact = selectAccount.Contacts;
		List<Location__c> lstLocation = new List<Location__c>();
		lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Sold2', Type__c = 'Sold To', Address__c = lstAddress[0].Id, Account__c = selectAccount.Id));
		lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Bill2', Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = selectAccount.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Ship2', Type__c = 'Ship To', Address__c = lstAddress[0].Id, Account__c = selectAccount.Id, Contact__c = lstContact[1].Id, Email__c = lstContact[1].Email, Phone__c = lstContact[1].Phone));
		insert lstLocation;
		lstSObject.add(new Account(Id = selectAccount.Id, SoldTo_Location__c = lstLocation[0].Id));
		lstSObject.add(new Contact(Id = lstContact[0].Id, BillTo_Location__c = lstLocation[1].Id));
		lstSObject.add(new Contact(Id = lstContact[1].Id, ShipTo_Location__c = lstLocation[2].Id));
		update lstSObject;

		Test.startTest();
			Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
			SAP_CustomerMaster_Mock.returnError = null;
			SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'Sold1', 'Bill1', 'Ship1'});

			//*** cover success part
			List<Id> lstContactId = new List<Id>();
			for (Account a : mapAccountName_Account.values())
				if (a.Name != 'Test HQ 4')
					for (Contact c : a.Contacts)
						lstContactId.add(c.Id);

			lstResult = Location_Svc.initializeDefaultLocations(lstContactId);

			for (Integer i1 = 0; i1 < lstResult.size(); i1++)
				system.assert(lstResult[i1] == null, 'Something wrong: ' + lstResult[i1]);
			String data = '';
			for (Location__c l : [select Id, Account_Name__c, Contact_First_Name__c, Type__c, SAP_Id__c from Location__c])
				data += '\n' + l.Account_Name__c + '--' + l.Contact_First_Name__c + '--' + l.Type__c + '--' + l.SAP_Id__c;
			system.assert(12 == [select count()
			                     from Location__c
			                     where (Account__c != null and Type__c = 'Sold To' and SAP_Id__c = 'Sold1')
			                        or (Account__c != null and Type__c = 'Bill To' and SAP_Id__c = 'Bill1' and Contact__c != null)
			                        or (Account__c != null and Type__c = 'Ship To' and SAP_Id__c = 'Ship1' and Contact__c != null)], 'Wrong count' + data);

			//*** cover no treatment needed because had all partners
			lstResult = Location_Svc.initializeDefaultLocations(new List<Id>{lstContactId[0]});
			system.assert(lstResult[0] == null, 'Something wrong: ' + lstResult[0]);

			//*** cover error part
			delete [select Id from IEC_Error_Log__c];
			SAP_CustomerMaster_Mock.returnError = 'test';
			SAP_CustomerMaster_Mock.returnOK = null;
			selectAccount = mapAccountName_Account.get('Test HQ 4');
			lstContact = selectAccount.Contacts;
			lstResult = Location_Svc.initializeDefaultLocations(new List<Id>{lstContact[0].Id, lstContactId[0]});   //*** error for sold to and mixed with no treatment needed
			system.assert(1 == [select count() from IEC_Error_Log__c], 'Wrong count ' + [select count() from IEC_Error_Log__c]);
			lstLocation = [select Id from Location__c where Type__c = 'Sold To' and Account__c = :selectAccount.Id];
			update new Location__c(Id = lstLocation[0].Id, SAP_Id__c = 'Sold2');
			lstResult = Location_Svc.initializeDefaultLocations(new List<Id>{lstContact[0].Id});   //*** error for bill & ship to
			system.assert(3 == [select count() from IEC_Error_Log__c], 'Wrong count ' + [select count() from IEC_Error_Log__c]);
		Test.stopTest();
	} //*** end of "test_initializeDefaultLocations"


	/****************************************************************************************************
	    Created by Thai 2017-01-27
	        Cover methods in class "Location_Sel"
	****************************************************************************************************/
	static testMethod void test_Location_Sel()
	{
		Map<String, Account> mapAccountName_Account = getAccount();
		Account accountHQ1 = mapAccountName_Account.get('Test HQ 1');
		List<Contact> lstContact = accountHQ1.Contacts;
		List<IECAddress__c> lstAddress = getAddress();

		List<Location__c> lstLocation = new List<Location__c>();
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Sold To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id));
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		lstLocation.add(new Location__c(Active__c = true, Type__c = 'Ship To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		insert lstLocation;

		Order oOrder = TestDataGenerator.generateOrder(1, accountHQ1.Id, lstContact[0].Id, lstContact[0].Id, false)[0];
		oOrder.SoldTo_Location__c = lstLocation[0].Id;
		oOrder.BillTo_Location__c = lstLocation[1].Id;
		oOrder.ShipTo_Location__c = lstLocation[2].Id;
		insert oOrder;

		Location_Sel selector = new Location_Sel();
		Set<Id> setObjectId = new Set<Id>();
		setObjectId.add(accountHQ1.Id);
		system.assert(selector.getSoldToAccountLocation(setObjectId).size() == 1, 'Wrong count');
		setObjectId.clear();
		for (Contact c : lstContact)
			setObjectId.add(c.Id);
		system.assert(selector.getContactsLocations(setObjectId).size() == 2, 'Wrong count');
		system.assert(selector.getContactsBillToLocations(setObjectId).size() == 1, 'Wrong count');
		system.assert(selector.getSoldToLocationByContactId(setObjectId).size() == 1, 'Wrong count');
		system.assert(Location_Sel.getActiveBillToByContact(setObjectId).size() == 1, 'Wrong count');
		system.assert(Location_Sel.getLocationsByContactIdAndType(lstContact[0].Id, 'Bill To').size() == 1, 'Wrong count');
		system.assert(Location_Sel.getLocationByContact(lstContact[0].Id, 'Bill To').size() == 1, 'Wrong count');
		setObjectId.clear();
		setObjectId.add(lstLocation[0].Id);
		system.assert(selector.getLocations(setObjectId).size() == 1, 'Wrong count');
		system.assert(selector.getLocationById(setObjectId).size() == 1, 'Wrong count');
		system.assert(selector.getLocationByAddressId(lstAddress[0].Id).size() == 1, 'Wrong count');
		system.assert(selector.getBillToLocationsByAccountContactId(new Set<String>{String.valueOf(accountHQ1.Id).left(15) + '|' + String.valueOf(lstContact[0].Id).left(15)}).size() == 1, 'Wrong count');
		system.assert(selector.getOrdersLocations(new List<Order>{oOrder}).size() == 3, 'Wrong count');
		system.assert(Location_Sel.getLocationToSyncSAP(null, null, null, null, true).size() == 3, 'Wrong count');
		system.assert(Location_Sel.getLocationToSyncSAP(new List<Id>{lstLocation[0].Id}, null, null, null, null).size() == 1, 'Wrong count');
		system.assert(Location_Sel.getLocationToSyncSAP(null, new List<Id>{accountHQ1.Id}, null, null, null).size() == 3, 'Wrong count');
		system.assert(Location_Sel.getLocationToSyncSAP(null, null, new List<Id>{lstContact[0].Id}, null, null).size() == 2, 'Wrong count');
		system.assert(Location_Sel.getLocationToSyncSAP(null, null, null, 'Bill To', null).size() == 1, 'Wrong count');
	} //*** end of "test_Location_Sel"


}