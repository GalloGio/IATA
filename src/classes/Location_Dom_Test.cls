@isTest
private class Location_Dom_Test {

     // Test address update to sync with SAP based on the new structure of using the LOCATION object
     // No asserts in this test method because this is a sync to SAP and there is nothing to check once the data is sent to SAP
     static testMethod void testSAPSync() {
     	TestDataGenerator.generateApexSetting();
     	TestDataGenerator.generateISOCountryState();
     	
     	// Manually add setting to avoid skipping the after trigger update
     	insert new Apex_Setting__c(Name='Execute Trigger Location', Number_1__c = 1);
     	
 		// Prepare data
     	Account oAccount = IECTestUtil.createSampleAccount();
     	oAccount.RecordTypeId = Utility.getTextSetting('Account Record Type IDs to sync to SAP').split(',')[0];
    	insert oAccount;
    	
    	// Create multiple records of Contacts/Address/Location to test batch processing
    	Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
    	
    	IECAddress__c oAddress = new IECAddress__c(
	     	Street__c = '12 main street'
	     	, City__c = 'Montreal'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'QC')
	     	, ZipCode__c = 'h1q2w3');
		insert oAddress;
		
     	Test.startTest();
     	
     		//Test 01: Create the location object, which would trigger a sync to SAP for new Account
	    	Location__c oLocation = new Location__c(
		     		Address__c = oAddress.Id
		     		, Account__c = oAccount.Id
		     		, Type__c = 'Sold To'
		     		, Active__c = true);
	     	insert oLocation;
     	
			// Test 02: make an update to one of the fields on the account to trigger a sync to SAP     		
     		oAccount.Name = 'TestNewSAP';
	     	update oAccount;
	     	
	     	// Test 03: make an update to the address object
	     	oAddress.State__c = 'ON';
	     	update oAddress;
	     	
	     	// Test 04: Replace location's address with a new one
	     	IECAddress__c oAddress2 = new IECAddress__c(
	     		Street__c = '1 test street'
		     	, City__c = 'Toronto'
		     	, Address_Type__c = 'SoldTo'
		     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
		     	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'ON')
		     	, ZipCode__c = 'A9A9A9');
			insert oAddress2;
			
			oLocation.Address__c = oAddress2.Id;
			update oLocation;

			//Cover sync to SAP when some field changed on the contact
			oContact.Email = 'testSAPSync@test.com';
			update oContact;
	    
	    Test.stopTest();
	    
	    delete oLocation;   //cover deletion
     }
     
     // Test location after update when address field is replaced by another to sync with Zuora
     // No asserts in this test method because this is a sync to Zuora and there is nothing to check once the data is sent to Zuora
     @isTest (SeeAllData=true)
     static void testZuoraSync() {
 		// Prepare data
     	Account oAccount = IECTestUtil.createSampleAccount();
     	//oAccount.RecordTypeId = Utility.getTextSetting('Account Record Type IDs to sync to SAP').split(',')[0];
    	insert oAccount;
    	
    	// Create multiple records of Contacts/Address/Location to test batch processing
    	Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
    	
    	Zuora__CustomerAccount__c zAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
    	insert zAccount;

    	set<Id> addressIds = new set<Id>();
    	
		TestDataGenerator.generateISOCountryState();
    	IECAddress__c oAddress = new IECAddress__c(
	     	Street__c = '12 main street'
	     	, City__c = 'Montreal'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ZipCode__c = 'h1q2w3');
		insert oAddress;
		addressIds.add(oAddress.Id);
		
		IECAddress__c oAddress2 = new IECAddress__c(
     		Street__c = '1 test street'
	     	, City__c = 'Toronto'
	     	, Address_Type__c = 'Billing2'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ZipCode__c = 'A9A9A9');
		insert oAddress2;
		addressIds.add(oAddress2.Id);
	
    	Location__c oLocation = new Location__c(
	     		Address__c = oAddress.Id
	     		, Account__c = oAccount.Id
	     		, Contact__c = oContact.Id
	     		, Type__c = 'Bill To'
	     		, Active__c = true);
     	insert oLocation;

     	Test.startTest();
			// Test 01: make an update to the address field to trigger a sync to Zuora     		
     		oLocation.Address__c = oAddress2.Id;
			update oLocation;

			//Test the ContactAddressZSync
			ContactAddressZSync_Batch batch = new ContactAddressZSync_Batch(addressIds,'IECAddress');
			Database.ExecuteBatch(batch);

	    Test.stopTest();
     }
     
     // Test location after update when address field is replaced by another to sync with Order
     @isTest
     static void testOrderSync() {
     	TestDataGenerator.generateApexSetting();
     	TestDataGenerator.generateISOCountryState();
     	
     	// Manually add setting to avoid skipping the after trigger update
     	insert new Apex_Setting__c(Name='Execute Trigger Location', Number_1__c = 1);
     	
 		// Prepare data
     	Account oAccount = IECTestUtil.createSampleAccount();
    	insert oAccount;
    	
    	Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
    	
    	IECAddress__c oAddress = new IECAddress__c(
	     	Street__c = '12 main street'
	     	, City__c = 'Montreal'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'QC')
	     	, ZipCode__c = 'h1q2w3');
		insert oAddress;
		
		IECAddress__c oAddress2 = new IECAddress__c(
     		Street__c = '1 test street'
	     	, City__c = 'Toronto'
	     	, Address_Type__c = 'Billing2'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'ON')
	     	, ZipCode__c = 'A9A9A9');
		insert oAddress2;
	
		// Create Bill/Ship to locations
    	List<Location__c> lstLocation = new List<Location__c>();
    	lstLocation.add(new Location__c(
	     		Address__c = oAddress.Id
	     		, Account__c = oAccount.Id
	     		, Contact__c = oContact.Id
	     		, Type__c = 'Bill To'
	     		, Active__c = true));
	     lstLocation.add(new Location__c(
	     		Address__c = oAddress.Id
	     		, Account__c = oAccount.Id
	     		, Contact__c = oContact.Id
	     		, Type__c = 'Ship To'
	     		, Active__c = true));
     	insert lstLocation;

    	List<Order> lstOrder = TestDataGenerator.generateOrder(2, oAccount.Id, oContact.Id, oContact.Id, false);
    	// Set billing address for first order
    	lstOrder[0].BillTo_Location__c = lstLocation[0].Id;
    	lstOrder[0].BillTo_Address__c =  oAddress.Id;

    	// Set shipping address for second order
    	lstOrder[1].ShipTo_Location__c = lstLocation[1].Id;
    	lstOrder[1].ShipTo_Address__c =  oAddress.Id;
    	
    	insert lstOrder;

     	Test.startTest();
			// Test 01: make an update to the address field to trigger a sync to Order object     		
     		lstLocation[0].Address__c = oAddress2.Id;
     		lstLocation[1].Address__c = oAddress2.Id;
			update lstLocation;
			
			for (Order ord : Order_Sel.getNewOrdersByLocation(new Set<Id> {lstLocation[0].Id, lstLocation[1].Id}))
			{
				if (ord.BillTo_Address__c != null)
					System.assertEquals(ord.BillTo_Address__c, oAddress.Id, 'Billing address must be updated to the new address');

				//if (ord.ShipTo_Address__c != null)
				//	System.assertEquals(ord.ShipTo_Address__c, oAddress2.Id, 'Shipping address must be updated to the new address');
			}
	    Test.stopTest();
     }
     
     // Test location validation to prevent multiple soldto location
     @isTest
     static void testMultipleSoldTo() {
     	TestDataGenerator.generateApexSetting();
     	TestDataGenerator.generateISOCountryState();
     	
     	// Manually add setting to avoid skipping the after trigger update
     	insert new Apex_Setting__c(Name='Execute Trigger Location', Number_1__c = 1);
     	
 		// Prepare data
     	Account oAccount = IECTestUtil.createSampleAccount();
    	insert oAccount;
    	
    	Account oAccount2 = IECTestUtil.createSampleAccount();
    	insert oAccount2;
    	
    	IECAddress__c oAddress = new IECAddress__c(
	     	Street__c = '12 main street'
	     	, City__c = 'Montreal'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'QC')
	     	, ZipCode__c = 'h1q2w3');
		insert oAddress;
		
		IECAddress__c oAddress2 = new IECAddress__c(
	     	Street__c = '12 test street'
	     	, City__c = 'Toronto'
	     	, Address_Type__c = 'SoldTo'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'ON')
	     	, ZipCode__c = 'A9A9A9A');
		insert oAddress2;
		
     	Test.startTest();
			// Test 01: First time address should not cause any exception
			try
			{
				List<Location__c> lstLocation = new List<Location__c>(); 
	     		lstLocation.add(new Location__c(
		     		Address__c = oAddress.Id
		     		, Account__c = oAccount.Id
		     		, Type__c = 'Sold To'
		     		, Active__c = true));
		    	lstLocation.add(new Location__c(
		     		Address__c = oAddress2.Id
		     		, Account__c = oAccount2.Id
		     		, Type__c = 'Sold To'
		     		, Active__c = true));
		     	insert lstLocation;
			}
			catch (Exception e)
			{
	     		System.assert(false, 'Location records must be created without exceptions.');
			}
			
			// Test 02: Try to insert a second sold-to address
			try
			{
				List<Location__c> lstLocation = new List<Location__c>(); 
	     		lstLocation.add(new Location__c(
		     		Address__c = oAddress.Id
		     		, Account__c = oAccount.Id
		     		, Type__c = 'Sold To'
		     		, Active__c = true));
		    	lstLocation.add(new Location__c(
		     		Address__c = oAddress2.Id
		     		, Account__c = oAccount2.Id
		     		, Type__c = 'Sold To'
		     		, Active__c = true));
		     	insert lstLocation;
	     		System.assert(false, 'Location records must raise an error since it is not allowed to have multiple sold-to location per account.');
			}
			catch (Exception e) {}
	    Test.stopTest();
     }
     
     // Test location validation to prevent multiple billing location
     @isTest
     static void testMultipleBillTo() {
     	TestDataGenerator.generateApexSetting();
     	TestDataGenerator.generateISOCountryState();
     	
     	// Manually add setting to avoid skipping the after trigger update
     	insert new Apex_Setting__c(Name='Execute Trigger Location', Number_1__c = 1);
     	
 		// Prepare data
     	Account oAccount = IECTestUtil.createSampleAccount();
    	insert oAccount;
    	
    	Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
    	
    	IECAddress__c oAddress = new IECAddress__c(
	     	Street__c = '12 main street'
	     	, City__c = 'Montreal'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'QC')
	     	, ZipCode__c = 'h1q2w3');
		insert oAddress;
		
		IECAddress__c oAddress2 = new IECAddress__c(
	     	Street__c = '12 test street'
	     	, Address_Type__c = 'Billing2'
	     	, City__c = 'Toronto'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'ON')
	     	, ZipCode__c = 'A9A9A9A');
		insert oAddress2;
		
     	Test.startTest();
			// Test 01: First time address should not cause any exception
			try
			{
		    	insert new Location__c(
		     		Address__c = oAddress.Id
		     		, Account__c = oAccount.Id
		     		, Contact__c = oContact.Id
		     		, Type__c = 'Bill To'
		     		, Active__c = true);
			}
			catch (Exception e)
			{
	     		System.assert(false, 'Location records must be created without exceptions.');
			}
			
			// Test 02: Try to insert a second billing address
			try
			{
		    	insert new Location__c(
		     		Address__c = oAddress2.Id
		     		, Account__c = oAccount.Id
		     		, Contact__c = oContact.Id
		     		, Type__c = 'Bill To'
		     		, Active__c = true);
	     		System.assert(false, 'Location records must raise an error since it is not allowed to have multiple bill-to location per contact.');
			}
			catch (Exception e) {}
	    Test.stopTest();
     }
     
     // Test location validation to prevent multiple billing location
     @isTest
     static void testMultipleShipTo() {
     	TestDataGenerator.generateApexSetting();
     	TestDataGenerator.generateISOCountryState();
     	
     	// Manually add setting to avoid skipping the after trigger update
     	insert new Apex_Setting__c(Name='Execute Trigger Location', Number_1__c = 1);
     	
 		// Prepare data
     	Account oAccount = IECTestUtil.createSampleAccount();
    	insert oAccount;
    	
    	Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
    	
    	IECAddress__c oAddress = new IECAddress__c(
	     	Street__c = '12 main street'
	     	, City__c = 'Montreal'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'QC')
	     	, ZipCode__c = 'h1q2w3');
		insert oAddress;
		
		IECAddress__c oAddress2 = new IECAddress__c(
	     	Street__c = '12 test street'
	     	, City__c = 'Toronto'
	     	, Address_Type__c = 'Shipping'
	     	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
	     	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'ON')
	     	, ZipCode__c = 'A9A9A9A');
		insert oAddress2;
		
     	Test.startTest();
			// Test 01: First time address should not cause any exception
			try
			{
		    	insert new Location__c(
		     		Address__c = oAddress.Id
		     		, Account__c = oAccount.Id
		     		, Contact__c = oContact.Id
		     		, Type__c = 'Ship To'
		     		, Active__c = true);
			}
			catch (Exception e)
			{
	     		System.assert(false, 'Location records must be created without exceptions.');
			}
			
			// Test 02: Second time with different address should not cause any exception
			try
			{
		    	insert new Location__c(
		     		Address__c = oAddress2.Id
		     		, Account__c = oAccount.Id
		     		, Contact__c = oContact.Id
		     		, Type__c = 'Ship To'
		     		, Active__c = true);
			}
			catch (Exception e)
			{
	     		System.assert(false, 'Location records must be created without exceptions.');
			}
			
			// Test 03: Try to insert a second billing address
			try
			{
		    	insert new Location__c(
		     		Address__c = oAddress.Id
		     		, Account__c = oAccount.Id
		     		, Contact__c = oContact.Id
		     		, Type__c = 'Ship To'
		     		, Active__c = true);
	     		System.assert(false, 'Location records must raise an error since it is not allowed to have multiple ship-to location with the same account/contact/address combination.');
			}
			catch (Exception e) {}
	    Test.stopTest();
     }
}