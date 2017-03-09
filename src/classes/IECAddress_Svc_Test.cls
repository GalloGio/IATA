@isTest(SeeAllData=false)
private class IECAddress_Svc_Test 
{
	/****************************************************************************************************
	    Created by Thai 2016-12-15
	        Cover method syncCustomerWithSAP that indirectly covers methods setCalloutHeader,
	        getRequestType, getSAPPaymentType, getSAPRegion, getSAPVATNumber, getSAPPaymentType, 
	        syncCustomerMasterWithSAP, createNewIECAddress
	        and classes Location_Queue, Location_Batch
	****************************************************************************************************/
	@isTest static void test_syncCustomerWithSAP()
	{
		Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
		
		//*** cover creation scenarios
		Test.startTest();
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
			
			Account accountHQ1 = new Account(Name = 'Test HQ 1', Sector__c = 'Test', Category__c = 'Test'
			                               , BillingStreet ='Billing Street 1', BillingCity= 'Billing City 1', BillingPostalCode ='H0H0H0'
			                               , IATA_ISO_Country__c = countryCanada.Id , IATA_ISO_Billing_State__c = stateQuebec.Id);
			insert accountHQ1;
			Account accountHQ2 = new Account(Name = 'Test HQ 2', Sector__c = 'Test', Category__c = 'Test'
			                               , BillingStreet ='Billing Street 2', BillingCity= 'Billing City 2', BillingPostalCode ='H0H0H0'
			                               , IATA_ISO_Country__c = countryCanada.Id , IATA_ISO_Billing_State__c = stateOntario.Id
			                               , ShippingStreet ='Shipping Street 2', ShippingCity = 'Shipping City 2', ShippingPostalCode ='H0H0H0'
			                               , IATA_ISO_Shipping_State__c = stateOntario.Id);
			insert accountHQ2;
			
			List<Contact> lstContact = TestDataGenerator.generateContacts(accountHQ1.Id, 1, false);
			lstContact.addAll(TestDataGenerator.generateContacts(accountHQ2.Id, 1, false));
			insert lstContact;

			List<IECAddress__c> lstAddress = new List<IECAddress__c>();
			lstAddress.add(IECAddress_Svc.createNewIECAddress(accountHQ1.BillingStreet, accountHQ1.BillingCity, accountHQ1.IATA_ISO_Country__c, accountHQ1.IATA_ISO_Billing_State__c, accountHQ1.BillingPostalCode));
			lstAddress.add(IECAddress_Svc.createNewIECAddress(accountHQ2.BillingStreet, accountHQ2.BillingCity, accountHQ2.IATA_ISO_Country__c, accountHQ2.IATA_ISO_Billing_State__c, accountHQ2.BillingPostalCode));
			lstAddress.add(IECAddress_Svc.createNewIECAddress(accountHQ2.ShippingStreet, accountHQ2.ShippingCity, accountHQ2.IATA_ISO_Country__c, accountHQ2.IATA_ISO_Shipping_State__c, accountHQ2.ShippingPostalCode));

			SAP_CustomerMaster_Mock.returnError = null;
			SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'Sold1', 'Bill1', 'Ship1'});
			List<Location__c> lstLocation = new List<Location__c>();
			lstLocation.add(new Location__c(Type__c = 'Sold To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id));
			lstLocation.add(new Location__c(Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c='test1@test.com', Phone__c = '111-111-1111', VAT_Number__c = '123'));
			lstLocation.add(new Location__c(Type__c = 'Ship To', Address__c = lstAddress[0].Id, Account__c = accountHQ1.Id, Contact__c = lstContact[0].Id, Email__c='test1@test.com', Phone__c = '111-111-1111', VAT_Number__c = 'CA123'));
			lstLocation.add(new Location__c(Type__c = 'Sold To', Address__c = lstAddress[1].Id, Account__c = accountHQ2.Id));
			lstLocation.add(new Location__c(Type__c = 'Bill To', Address__c = lstAddress[1].Id, Account__c = accountHQ2.Id, Contact__c = lstContact[1].Id, Email__c='test1@test.com', Phone__c = '111-111-1111', VAT_Number__c = '123'));
			lstLocation.add(new Location__c(Type__c = 'Ship To', Address__c = lstAddress[2].Id, Account__c = accountHQ2.Id, Contact__c = lstContact[1].Id, Email__c='test1@test.com', Phone__c = '111-111-1111', VAT_Number__c = 'CA123'));
			insert lstLocation;
		Test.stopTest();
		system.assert(6 == [select count()
		                    from Location__c
		                    where (Id = :lstLocation[0].Id and SAP_Id__c = 'Sold1') or (Id = :lstLocation[3].Id and SAP_Id__c = 'Sold1')
		                       or (Id = :lstLocation[1].Id and SAP_Id__c = 'Bill1') or (Id = :lstLocation[2].Id and SAP_Id__c = 'Ship1')
		                       or (Id = :lstLocation[4].Id and SAP_Id__c = 'Bill1') or (Id = :lstLocation[5].Id and SAP_Id__c = 'Ship1')], 'Wrong count');

		//*** cover update scenario for sold to
		IECAddress_Svc.syncCustomerWithSAP(Location_Sel.getLocationToSyncSAP(new List<Id>{lstLocation[0].Id}, null, null, null, null).values(), null, true);

		SAP_CustomerMaster_Mock.returnError = 'test error';
		SAP_CustomerMaster_Mock.returnOK = null;
		List<Location__c> lstLocation2 = new List<Location__c>();
		lstLocation2.add(new Location__c(Id = lstLocation[0].Id));   //*** error of no sold to when update bill/ship to
		lstLocation2.add(new Location__c(Id = lstLocation[1].Id, Address__c = lstAddress[1].Id));
		lstLocation2.add(new Location__c(Id = lstLocation[2].Id, Address__c = lstAddress[1].Id));
		lstLocation2.add(new Location__c(Id = lstLocation[3].Id, Address__c = lstAddress[0].Id, Active__c = false));
		lstLocation2.add(new Location__c(Id = lstLocation[4].Id, Address__c = lstAddress[0].Id, Active__c = false));   //*** error on update because no SAP Id
		lstLocation2.add(new Location__c(Id = lstLocation[5].Id, Address__c = lstAddress[0].Id, Active__c = false));
		update lstLocation2;

		//*** cover scenario not to send deactivation of sold to
		IECAddress_Svc.syncCustomerWithSAP(Location_Sel.getLocationToSyncSAP(new List<Id>{lstLocation[3].Id}, null, null, null, null).values(), null, true);

		//*** cover error scenarios -> cannot assert because executed in future -> other signature of syncCustomerMasterWithSAP
		Set<Id> setSoldToId = new Set<Id>{lstLocation2[0].Id, lstLocation2[3].Id};
		Set<Id> setBillShipToId = new Set<Id>{lstLocation2[1].Id, lstLocation2[2].Id, lstLocation2[4].Id, lstLocation2[5].Id};
		IECAddress_Svc.syncCustomerMasterWithSAP(setBillShipToId, setSoldToId);
		IECAddress_Svc.syncCustomerMasterWithSAP(new List<Location__c>());

		//*** cover error scenarios -> no need to assert -> force commit
		List<Id> lstLocationId = new List<Id>(setSoldToId);
		lstLocationId.addAll(setBillShipToId);
		List<Location__c> lstLocation3 = Location_Sel.getLocationToSyncSAP(lstLocationId, null, null, null, null).values();
		IECAddress_Svc.syncCustomerWithSAP(lstLocation3, null, true);
	} //*** end of "test_syncCustomerWithSAP"


	/****************************************************************************************************
	    Created by Thai 2016-12-15
	        Cover method syncCustomerWithSAP that indirectly covers methods setCalloutHeader,
	        getRequestType, getSAPPaymentType, getSAPRegion, getSAPVATNumber, getSAPPaymentType, 
	        syncCustomerMasterWithSAP
	        and classes Location_Queue, Location_Batch
	****************************************************************************************************/
	@isTest static void test_miscMethods()
	{
		TestDataGenerator.generateApexSetting();
		
		List<IATA_ISO_Country__c> lstCountryState = TestDataGenerator.generateISOCountryState();
		IATA_ISO_Country__c countryCanada, countryChile;
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
			}
			else if (country.ISO_Code__c == 'CL')
				countryChile = country;
		
		//*** cover method "newAddress"
		IECAddress__c address1 = IECAddress_Svc.newAddress('Street', 'City', countryCanada.ISO_Code__c, stateQuebec.ISO_Code__c, 'H0H0H0');
		
		//*** cover method "newAddressForSAPSync"
		IECAddress__c address2 = IECAddress_Svc.newAddressForSAPSync('Street1~~for~~test coverage', 'City', countryCanada.ISO_Code__c, stateQuebec.ISO_Code__c, 'H0H0H0');
		insert address2;
		IECAddress__c address3 = IECAddress_Svc.newAddressForSAPSync('Street1~~for~~test coverage', 'City', countryChile.ISO_Code__c, null, null);
		insert address3;
		
		Boolean check;
		List<Account> lstAccount = TestDataGenerator.generateAccounts(1, true);
		List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 1, true);
		Location__c location0 = TestDataGenerator.generateLocations('Sold To', address1.Id, lstAccount[0].Id, null);
		Location__c location1 = TestDataGenerator.generateLocations('Bill To', address1.Id, lstAccount[0].Id, lstContact[0].Id);
		Location__c location2 = TestDataGenerator.generateLocations('Other', address2.Id, null, null);
		Address_DTO addressDTO1 = Address_DTO.format2DTO(location1.Id);
		Address_DTO addressDTO2 = Address_DTO.format2DTO(location2.Id);
		
		//*** cover methods "syncIECAddressWithSAP", "syncIECAddressWithZuora"
		IECAddress_Svc.syncIECAddressWithSAP(new Set<Id>{location1.Address__c});
		IECAddress_Svc.syncIECAddressWithZuora(new Set<Id>{location1.Address__c});
		
		//*** cover method "isAddressChanged" for type "IECAddress__c"
		check = IECAddress_Svc.isAddressChanged(address1, null);
		system.assert(check == true, 'Wrong value');
		check = IECAddress_Svc.isAddressChanged(null, address2);
		system.assert(check == true, 'Wrong value');
		check = IECAddress_Svc.isAddressChanged(address1, address2);
		system.assert(check == true, 'Wrong value');
		address1 = null;
		address2 = null;
		check = IECAddress_Svc.isAddressChanged(address1, address2);
		system.assert(check == false, 'Wrong value');
		
		//*** cover method "isAddressChanged" for type "Address_DTO"
		check = IECAddress_Svc.isAddressChanged(addressDTO1, null);
		system.assert(check == true, 'Wrong value');
		check = IECAddress_Svc.isAddressChanged(null, addressDTO2);
		system.assert(check == true, 'Wrong value');
		check = IECAddress_Svc.isAddressChanged(addressDTO1, addressDTO2);
		system.assert(check == true, 'Wrong value');
		addressDTO1 = null;
		addressDTO2 = null;
		check = IECAddress_Svc.isAddressChanged(addressDTO1, addressDTO2);
		system.assert(check == false, 'Wrong value');
		
		//*** cover methods in "Location_Batch": class is not used anymore -> no assert
		Database.executeBatch(new Location_Batch(new Set<Id>{location1.Id}));
		Database.executeBatch(new Location_Batch(new Set<Id>{location1.Id}, new Set<Id>{location0.Id}));
		
		//*** cover methods in "IECAddress_Sel"
		IECAddress_Sel selector = new IECAddress_Sel();
		List<IECAddress__c> lstCheck = new List<IECAddress__c>();
		lstCheck = selector.getFullAddress(address3.Street__c);
		system.assert(lstCheck.size() == 0, 'Wrong count: ' + lstCheck);
		lstCheck = selector.getAddress(address3.Street__c, address3.City__c, countryChile.ISO_Code__c, null, address3.ZipCode__c);
		system.assert(lstCheck.size() == 1, 'Wrong count: ' + lstCheck);
		lstCheck = selector.getAddressByIsoIds(address3.Street__c, address3.City__c, countryChile.Id, null, address3.ZipCode__c);
		system.assert(lstCheck.size() == 1, 'Wrong count: ' + lstCheck);
		lstCheck = selector.getAddresses(new Set<Id>{address3.Id});
		system.assert(lstCheck.size() == 1, 'Wrong count: ' + lstCheck);
		system.assert(IECAddress_Sel.getAutocompleteAddresses(address3.Street__c).size() == 2, 'Wrong count');
		system.assert(IECAddress_Sel.getAutocompleteAddresses(address3.Street__c, 'zz', 'zz').size() == 0, 'Wrong count');
	} //*** end of "test_miscMethods"

} //*** end of class