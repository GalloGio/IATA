/**
 * This class contains unit tests for class trgHndlrIECAddress
 */
@isTest(SeeAllData=true)
private class trgHndlrIECAddress_tst {
		 /* Commented by Samy Saied (2016-02-29) for using the new Location model instead of only iecaddress
		 static testMethod void testAddress() {
		 	try {
		 		// Prepare data
			 	Account oAccount = IECTestUtil.createSampleAccount();
				insert oAccount;

				Contact oContact = IECTestUtil.createSampleContact(oAccount);
				insert oContact;

			 	Zuora__CustomerAccount__c oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
			 	insert oBillingAccount;

			 	IECAddress__c oBillingAddress = new IECAddress__c();
			 	oBillingAddress.Address_Type__c = IECConstants.IECAddress_AddressType_Billing;
			 	oBillingAddress.Contact__c = oContact.Id;
			 	oBillingAddress.Street__c = '12 main street';
			 	oBillingAddress.City__c = 'Montreal';
			 	oBillingAddress.Country__c = 'Canada';
			 	oBillingAddress.State__c = 'QC';
			 	oBillingAddress.ZipCode__c = 'h1q2w3';
			 	insert oBillingAddress;

			 	// modify the state
			 	oBillingAddress.State__c = 'ON';
			 	update oBillingAddress;

			 	system.assert(true, 'testAddress should not throw any exception');

			 	IECAddress__c oBillingAddress2 = new IECAddress__c();
			 	oBillingAddress2.Address_Type__c = IECConstants.IECAddress_AddressType_Billing;
			 	oBillingAddress2.Contact__c = oContact.Id;
			 	oBillingAddress2.Street__c = '12 main street';
			 	oBillingAddress2.City__c = 'Montreal';
			 	oBillingAddress2.Country__c = 'Canada';
			 	oBillingAddress2.State__c = 'QC';
			 	oBillingAddress2.ZipCode__c = 'h1q2w3';
			 	try {
			 		insert oBillingAddress2;
			 	}
			 	catch (Exception e) {
			 		System.assert(e.getMessage().contains(Label.IEC_Error_OnlyOneAddressPerType));
			 	}
		 	}
		 	catch (Exception ex) {
		 		system.assert(false, 'testAddress should not throw any exception');
		 	}
		 }
		 */

		 // Test address update to sync with zuora based on the new structure of using the LOCATION object
		 // No asserts in this test method because this is a sync to Zuora and there is nothing to check once the data is sent to Zuora
		 static testMethod void testAddressUpdate() {
 		// Prepare data
		 	Account oAccount = IECTestUtil.createSampleAccount();
			insert oAccount;

			// Create multiple records of Contacts/Address/Location to test batch processing
			List<Contact> lstContact = TestDataGenerator.generateContacts(oAccount.Id, 5, true);
			TestDataGenerator.generateISOCountryState();

			List<Zuora__CustomerAccount__c> lstZAccount = new List<Zuora__CustomerAccount__c>();
			List<IECAddress__c> lstAddress = new List<IECAddress__c>();
			List<Location__c> lstLocation = new List<Location__c>();

			for (Contact oContact : lstContact)
			{
		 		lstZAccount.add(IECTestUtil.createSampleBillingAccount(oAccount, oContact));

			 	lstAddress.add(new IECAddress__c(
				 	Address_Type__c = IECConstants.IECAddress_AddressType_Billing
				 	, Contact__c = oContact.Id
				 	, Street__c = '12 main street'
				 	, City__c = 'Montreal'
				 	, ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
				 	, ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'QC')
				 	, ZipCode__c = 'h1q2w3'
			 	));
			}

		 	insert lstZAccount;
		 	insert lstAddress;

		 	for (integer i=0; i < lstAddress.size(); i++)
 		{
			 	lstLocation.add(new Location__c(
			 		Address__c = lstAddress[i].Id
			 		, Contact__c = lstContact[i].Id
			 		, Account__c = oAccount.Id
			 		, Type__c = 'Bill To'
			 		, Active__c = true
			 		, SAP_Id__c = '312645987'
			 	));
 		}
		 	insert lstLocation;

		 	for (integer i=0; i < lstContact.size(); i++)
			{
		 		lstContact[i].BillTo_Location__c = lstLocation[i].Id;
		 		lstContact[i].ShipTo_Location__c = lstLocation[i].Id;
 		}
 		update lstContact;

		 	Test.startTest();

		 		for (IECAddress__c oAddress : lstAddress)
 			{
				 	// modify the state
				 	//oAddress.ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'ON');
				 	oAddress.Street__c = 'new street';
 			}

			 	update lstAddress;

			Test.stopTest();
		 }
}
