@isTest(SeeAllData=true)
private class IECAddress_Svc_Test 
{
	
	@isTest static void test_syncCustomerMasterWithSAP() 
	{
		TestDataGenerator.generateApexSetting();
		
		TestDataGenerator.generateISOCountryState();

		//Generate Test Data 
		List<Account> accounts = TestDataGenerator.generateAccounts(1, true);
		List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id, 3, true);
		List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(3,true);

		Test.startTest();
			Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());

			//Create Sold To Location 
			Location__c sold_to_location = TestDataGenerator.generateLocations('Sold To',addresses[0].Id,accounts[0].Id, null);

			//Create Bill To Location 
			Location__c bill_to_location = TestDataGenerator.generateLocations('Bill To',addresses[1].Id,accounts[0].Id, contacts[1].Id);
			
			//Create Ship To Location 
			Location__c ship_to_location = TestDataGenerator.generateLocations('Ship To',addresses[2].Id,accounts[0].Id, contacts[2].Id);

			//Deactivate BillTo 
			bill_to_location.Active__c = false;
			update bill_to_location;

			//Update Ship To 
			ship_to_location.Contact__c = contacts[1].Id;
			update ship_to_location;

			//-- getAddressByIsoIds
			List<IECAddress__c> existingAddresses = new IECAddress_Sel().getAddressByIsoIds(addresses[0].Street__c,addresses[0].City__c, addresses[0].ISO_Country__c, addresses[0].ISO_State__c,addresses[0].ZipCode__c);
			

			//-- Validate isAddressChanged
			Address_DTO adr1 = Address_DTO.format2DTO(ship_to_location);
			Address_DTO adr2 = Address_DTO.format2DTO(ship_to_location);

			Boolean changed = IECAddress_Svc.isAddressChanged(adr1, adr2);
			Boolean changed2 = IECAddress_Svc.isAddressChanged(addresses[0], addresses[1]);
			System.assert(changed==false);


			//---updateAddress
			try{
				Location__c updatedAddress = IECAddress_Svc.updateAddress(addresses[0].Street__c,addresses[0].City__c, addresses[0].ISO_Country__c, addresses[0].ISO_State__c,addresses[0].ZipCode__c, null, contacts[0], 'Bill To');
			}catch(Exception ex){}


			//--createNewIECAddress
			IECAddress__c newAdress = IECAddress_Svc.createNewIECAddress(addresses[0].Street__c,addresses[0].City__c, addresses[0].ISO_Country__c, addresses[0].ISO_State__c,addresses[0].ZipCode__c);
			IECAddress__c newAdress2 = IECAddress_Svc.newAddress(addresses[0].Street__c,addresses[0].City__c, addresses[0].ISO_Country__c, addresses[0].ISO_State__c,addresses[0].ZipCode__c);
		Test.stopTest();
	}
	
	
}