/**
 * This class contains unit tests for class trgHndlrIECAddress
 */
@isTest(SeeAllData=true)
private class trgHndlrIECAddress_tst {
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
}