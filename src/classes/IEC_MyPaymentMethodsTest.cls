@isTest
private class IEC_MyPaymentMethodsTest {
	
	@isTest (SeeAllData=true)
	static void test_payment_methods() 
	{
		Test.setCurrentPage(Page.IEC_MyPaymentMethods);

		IEC_MyPaymentMethodsController ctrl; 

		User usr = IECTestUtil.createSampleGuestUserAndLogin();

        Contact oContact = [SELECT Id, AccountId FROM Contact WHERE Id = :usr.contactId LIMIT 1][0];
				
        List<Location__c> LocationList = [SELECT Id, Contact__r.OwnerId, Contact__r.Name, Type__c, Account__c, Account_Contact_ID__c, Account_Contact_Address_ID__c
                                        FROM Location__c
                                        WHERE Account__c = :oContact.AccountId];

        oContact.BillTo_Location__c = LocationList[1].Id;
		oContact.ShipTo_Location__c = LocationList[2].Id;
		update oContact;
		        
		System.runAs(usr) {
	    	//Instantiate Controller
	    	ctrl = new IEC_MyPaymentMethodsController();	

	    	ctrl.onLoadAction();

	    	String extraParamString = ctrl.getExtraParamString();

	    	//-- Load Customer credit cards
	    	ctrl.refreshCreditCards();
	        
	        System.assert(ctrl.creditCards.size() >0);
	        System.assertEquals(ctrl.defaultPaymentMethodId, null);

	        // Test 002: add new credit card  failled 
	        System.currentPageReference().getParameters().put('errMsg', 'ERROR_OCCUR');
	        ctrl.sErrorMsgFromHPM ='ERROR_OCCUR';
	        ctrl.displayCallBackfailure();
	        //System.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), 'ERROR_OCCUR'));

	        // Test 003: add success credit card
	        IECTestUtil.createSampleZuoraPaymentMethod('555', (String) ctrl.loggedCustomer.zAccount.getValue('Id'), 2016, 1);
	        ctrl.refreshCreditCards();
	        ctrl.newCreditCardPaymentId = ctrl.creditCards[ctrl.creditCards.size()-1].zId;
	        ctrl.addCreditCard();

	        // Select 1st card for edit 
	        ctrl.selectedCreditCardId = ctrl.creditCards[0].zId;
	        System.currentPageReference().getParameters().put('zId', ctrl.creditCards[0].zId);
	        ctrl.setSelectedCreditCard();
	        System.assertNotEquals(ctrl.selectedCreditCard, null);

	        // Edit 1st credit card  City, Country and Expiration Date 
	        ctrl.selectedCreditCard.city = 'Montreal';
	        List<SelectOption> availableCountries = ctrl.getAvailableCountries();
	        ctrl.selectedCreditCard.country = availableCountries[0].getValue();
	        List<SelectOption> availableYears = ctrl.availableYears; 
	        ctrl.selectedCreditCard.expirationYear = Integer.valueOf(availableYears[1].getValue()); 
	        List<SelectOption> availableMonths = ctrl.availableMonths;
        	ctrl.selectedCreditCard.expirationMonth = Integer.valueOf(availableMonths[11].getValue());
        	System.assertEquals(availableMonths.size(),12);
	        ctrl.editCreditCard();

	        // Set default payment method
	        ctrl.defaultPaymentMethodId = ctrl.creditCards[0].zId;
	        ctrl.setDefaultPaymentMethod();

	        // Remove Credit Card 
        	System.currentPageReference().getParameters().put('zId', ctrl.creditCards[1].zId);
	        ctrl.setSelectedCreditCard();
	        ctrl.removeCreditCard();

	        //-- Add vblank credit card 
	        ctrl.newCreditCardPaymentId = ''; 
	        ctrl.addCreditCard();

	       	//-- Load with invalid billing 
	       	ctrl.hasValidBillingAddress=false;
	       	ctrl.onLoadAction();

        }
	}
	
	@isTest (SeeAllData=true)
	static void test_no_zaccount()
	{
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr)
		{
			IEC_MyPaymentMethodsController ctrl = new IEC_MyPaymentMethodsController();	

	    	ctrl.onLoadAction();
	    	ctrl.refreshCreditCards();

			//--Add credit Card without zAccount 
			try{
				ctrl.newCreditCardPaymentId = ctrl.creditCards[ctrl.creditCards.size()-1].zId;
		        ctrl.recreateZuoraAccount = true;
		       	ctrl.addCreditCard();
	       	}catch(Exception ex){
	       		
	       	}
		        
       	}
	}

	@isTest (SeeAllData=true)
	static void test_not_connected()
	{
		Test.setCurrentPage(Page.IEC_MyPaymentMethods);
		IEC_MyPaymentMethodsController ctrl= new IEC_MyPaymentMethodsController();  
		ctrl.onLoadAction();
	}
}