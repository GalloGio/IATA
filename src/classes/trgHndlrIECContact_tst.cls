/**
 * This class contains unit tests for class trgHndlrIECContact
 */
@isTest(SeeAllData=true)
private class trgHndlrIECContact_tst {

		static testMethod void testContact() {

		 	try {

		 		// Prepare data
			 	Account oAccount = IECTestUtil.createSampleAccount();
				insert oAccount;

				Contact oContact = IECTestUtil.createSampleContact(oAccount);
				insert oContact;

			 	Zuora__CustomerAccount__c oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
			 	insert oBillingAccount;

			 	/* Commented by Samy Saied (2016-02-29) for using the new Location model instead of only iecaddress
			 	And also the code that is referencing the IECAddress in the contact trigger is already commented.
			 	IECAddress__c oBillingAddress = new IECAddress__c();
			 	oBillingAddress.Address_Type__c = IECConstants.IECAddress_AddressType_Billing;
			 	oBillingAddress.Contact__c = oContact.Id;
			 	oBillingAddress.Street__c = '12 main street';
			 	oBillingAddress.City__c = 'Montreal';
			 	oBillingAddress.Country__c = 'Canada';
			 	oBillingAddress.State__c = 'QC';
			 	oBillingAddress.ZipCode__c = 'h1q2w3';
			 	insert oBillingAddress;
			 	*/

			 	// modify the contact
			 	oContact.FirstName = 'Johnny';
			 	update oContact;

			 	system.assert(true, 'testContact should not throw any exception');
		 	}
		 	catch (Exception ex) {
		 		system.assert(false, 'testContact should not throw any exception');
		 	}
		}
}
