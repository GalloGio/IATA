@isTest
private class IEC_Evt_Renew_ProcessPmt_Batch_Test {
	private static List<Account> lstAccount;
	private static List<Contact> lstContact;
	private static List<IEC_Event_Subscription__c> lstSubscription;
	private static List<Order> lstOrder;
	private static List<OrderItem> lstOrderItem;
	private static IEC_Event_Release__c oEventRelease, oEventRelease2;
	private static Set<Id> setOrderId;

	private static void InitializeData()
	{
		 //-- Generate Setting 
        delete [select Id from Apex_Setting__c where Name like 'IEC evt renewal%'];
        List<Apex_Setting__c> lstSetting = new List<Apex_Setting__c>();
        lstSetting.add(new Apex_Setting__c(Name='IEC evt renewal batch size for taxes', Number_1__c=1));
        lstSetting.add(new Apex_Setting__c(Name='IEC evt renewal processPmt batch size', Number_1__c=5));
        upsert lstSetting;
        
		/* Possible scenarios and generated errors in the batch are as follows
			[0] ERROR - Tax and Shipping have not been calculated on the order
			[1] ERROR - Zuora Billing Account\'s default payment method is not set to credit card while trying to pay with credit card
			[2] ERROR - Zuora Billing Account was not found for order.
			[3] ERROR - Event release only supports payment types of ICH or Credit Card
			[4] ERROR - No default payment type defined on the Bill-To Account
			[5] SUCCESS - Paid with ICH
			[6] SUCCESS - Paid with Credit Card
		*/

        TestDataGenerator.generateISOCountryState();
		
	    /*****************************************
	    **	Create Accounts
	    *****************************************/
        lstAccount = TestDataGenerator.generateAccounts(7, false);
        for (Account oAccount : lstAccount)
        {
        	oAccount.Default_Payment_Type__c = 'Credit Card';
        	oAccount.Customer_Type__c = 'Member Airline';
        }

		// Make one account with non-supported default payment to test validation
        lstAccount[3].Default_Payment_Type__c = 'Bank Transfer';
        
        // Make one account with no default payment to test validation
        lstAccount[4].Default_Payment_Type__c = null;
        
        // Make one account paid by ICH to test ICH payment
        lstAccount[5].Default_Payment_Type__c = 'ICH';
        
        insert lstAccount;
        
        /*****************************************
	    **	Create Contacts
	    *****************************************/
        lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 7, false);
        
        // Assign a contact for each generated account
        for (integer i = 0; i < lstContact.size(); i++)
        {
        	lstContact[i].AccountId = lstAccount[i].Id;
        }
        insert lstContact;
        
        /*****************************************
	    **	Create Zuora Billing Accounts
	    *****************************************/
        List<Zuora__CustomerAccount__c> lstZAccount = new List<Zuora__CustomerAccount__c>
        { 
	        IECTestUtil.createSampleBillingAccount(lstAccount[1], lstContact[1])
	        , IECTestUtil.createSampleBillingAccount(lstAccount[6], lstContact[6])
        };
        insert lstZAccount;
        
        /*****************************************
	    **	Create Zuora Paymen Method
	    *****************************************/
	    Zuora__PaymentMethod__c zPaymentMethod_CC = new Zuora__PaymentMethod__c (
	    	Zuora__Type__c = 'CreditCard'
	    	, Zuora__External_Id__c = TestDataGenerator.generateZuoraFakeId()
	    	, Zuora__BillingAccount__c = lstZAccount[1].Id
	    );
	    insert zPaymentMethod_CC;
	    
        // Set the default payment on one of the zAccounts to CreditCard
        lstZAccount[1].Zuora__Default_Payment_Method__c = zPaymentMethod_CC.Id;
        update lstZAccount[1];
        
        /*****************************************
	    **	Create Event Release
	    *****************************************/
	    //-- Generate Product
	    Product2 oProduct = TestDataGenerator.generateProductsWithPrice(1)[0];
		oProduct.Sell_through_eCommerce__c = true; 
		oProduct.Inventory_Status__c = 'In stock';
		//oProduct.SAP_Material_Number__c = '8888-98';
		//oProduct.Activity_Code__c = '8888';
		oProduct.Activity_Code__c = oProduct.SAP_Material_Number__c.left(4);
		oProduct.Line_of_Business__c = 'Publications';
        oProduct.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Product2', 'Publication');
 		update oProduct;
 		

		//Create IEC_Event_Subscription__c
		lstSubscription = new List<IEC_Event_Subscription__c>();
		for (integer i = 0; i < lstContact.size(); i++)
			lstSubscription.add(new IEC_Event_Subscription__c(Subscriber__c=lstContact[i].Id, Product__c=oProduct.Id, Start_Date__c=Date.today().addDays(-20), Quantity__c=1, Active__c=true));
		insert lstSubscription;
		
	    oEventRelease = TestDataGenerator.generateEventRelease(oProduct.Id, 'Member Airline', true);
	    oEventRelease2 = TestDataGenerator.generateEventRelease(oProduct.Id, 'Member Airline', true);
        
        IECAddress__c oAddress = TestDataGenerator.generateAddresses(1, true)[0];
        
        Location__c locSoldTo = TestDataGenerator.generateLocations(IECConstants.SOLDTO, oAddress.Id, lstAccount[0].Id, NULL, '321231');
        Location__c locBillTo = TestDataGenerator.generateLocations(IECConstants.BILLTO, oAddress.Id, lstAccount[0].Id, lstContact[0].Id, '123123');
        Location__c locShipTo = TestDataGenerator.generateLocations(IECConstants.SHIPTO, oAddress.Id, lstAccount[0].Id, lstContact[0].Id, '456654');
        /*****************************************
	    **	Create Orders
	    *****************************************/
        lstOrder = TestDataGenerator.generateOrder(7, lstAccount[0].Id, lstContact[0].Id, lstContact[0].Id, false);
        for (integer i = 0; i < lstOrder.size(); i++)
        {
        	lstOrder[i].Type = 'Event Auto-Renew';
	        lstOrder[i].Source__c = 'Inbound call';
	        lstOrder[i].Order_Channel__c = 'Central Direct Sales';
	        
	        lstOrder[i].AccountId = lstAccount[i].Id;
	        lstOrder[i].BillToAccount__c = lstAccount[i].Id;
	        lstOrder[i].BillToContactId = lstContact[i].Id;
	        lstOrder[i].ShipToContactId = lstContact[i].Id;

	        lstOrder[i].IEC_Event_Release__c = oEventRelease.Id;
	        lstOrder[i].IEC_Event_Subscription__c = lstSubscription[i].Id;
	        lstOrder[i].SoldTo_Location__c = locSoldTo.Id;
	        lstOrder[i].BillTo_Location__c = locBillTo.Id;
	        lstOrder[i].ShipTo_Location__c = locShipTo.Id;
        }
        lstOrder[0].IEC_Event_Subscription__c = null;
        lstOrder[1].IEC_Event_Subscription__c = null;
        insert lstOrder;
        
        /*****************************************
	    **	Create Order Items
	    *****************************************/
	    setOrderId = new Set<Id>();
	    delete [select Id from PricebookEntry where Product2Id = :oProduct.Id];
        lstOrderItem = TestDataGenerator.generateOrderItem(lstOrder[0].Id, new List<Product2>{oProduct}, false);
        for (integer i = 0; i < lstAccount.size() - 1; i++)
            lstOrderItem.add(lstOrderItem[0].clone(false, true));
        for (integer i = 0; i < lstOrderItem.size(); i++)
        {
        	setOrderId.add(lstOrder[i].Id);
        	lstOrderItem[i].OrderId = lstOrder[i].Id;
        	lstOrderItem[i].Tax__c = 1000;
        	lstOrderItem[i].Freight_Charge__c = 0;
        }
        
        // Make one order item without taxes and shipping to test validation
        lstOrderItem[0].Tax__c = null;
    	lstOrderItem[0].Freight_Charge__c = null;
    	
        insert lstOrderItem;

	}
	
	// Cover code of batch "IEC_Evt_Renew_ProcessPmt_Batch"
    @isTest (seeAllData=true)
    static void test_Batch() {

    	
    	InitializeData();

		Test.startTest();
		IEC_Evt_Renew_ProcessPmt_Batch batch = new IEC_Evt_Renew_ProcessPmt_Batch(oEventRelease.Id);
		Database.ExecuteBatch(batch,7);
		Test.stopTest();

		// Run the asserts after the STOPTEST to make sure the batch has finished
		List<IEC_Event_Release_Log__c> lstLog = [SELECT Id, Order__c FROM IEC_Event_Release_Log__c WHERE IEC_Event_Release__c = :oEventRelease.Id AND Order__c IN :setOrderId];
		//System.assertEquals(5, lstLog.size(), 'Five errors should be generated based on the document scenarios in the InitializeData function.');
		
		Set<Id> setOrdersWithError = new Set<Id>();
		for (IEC_Event_Release_Log__c oLog : lstLog)
		{
			setOrdersWithError.add(oLog.Order__c);
		}
		//System.assertEquals(5, setOrdersWithError.size(), 'Five orders caused these errors.');
		//System.assertEquals(false, setOrdersWithError.contains(lstOrder[5].Id), 'Order #6 shouldn\'t cause errors.');
		//System.assertEquals(false, setOrdersWithError.contains(lstOrder[6].Id), 'Order #7 shouldn\'t cause errors.');

		try {
			delete [select Id from IEC_Event_Release_Log__c where IEC_Event_Release__c = :oEventRelease.Id];
			insert new IEC_Event_Release_Log__c(IEC_Event_Release__c=oEventRelease.Id, Subscription__c=lstSubscription[0].Id, Order__c=lstOrder[0].Id);
			IEC_Evt_Renew_SOAP.reprocessError(oEventRelease.Id);
			insert new IEC_Event_Release_Log__c(IEC_Event_Release__c=oEventRelease.Id, Subscription__c=lstSubscription[1].Id);
			IEC_Evt_Renew_SOAP.reprocessError(oEventRelease.Id);
		} catch(Exception ex) { system.assert(false, 'IEC_Evt_Renew_SOAP.reprocessError: ' + ex); }
		
		//Cover the Update Release button function on event release object
		try {
			IEC_Evt_Renew_SOAP.eventRegenerateRelease(oEventRelease2.Id);
		} catch(Exception ex) { system.assert(false, 'IEC_Evt_Renew_SOAP.eventRegenerateRelease: ' + ex); }
    }

    @isTest (seeAllData=true)
    static void test_IEC_Evt_Renew_SOAP() {
    	
    	InitializeData();

    	IEC_Event_Release__c eveRelease = [Select id,Product_Number__c,Released__c from IEC_Event_Release__c where id =:oEventRelease.Id];
		
		//Cover the Update Release button function on event release object
		IEC_Evt_Renew_SOAP.eventRegenerateRelease(eveRelease.Id);

		Test.startTest();
		IEC_Evt_Renew_ProcessPmt_Batch batch = new IEC_Evt_Renew_ProcessPmt_Batch(eveRelease.Id);
		Database.ExecuteBatch(batch,7);
		Test.stopTest();

		eveRelease = [Select id,Product_Number__c,Released__c,Last_Version__c,Swapped_Product__c, Customer_Type__c, Product__c, Processing_Status__c
						 from IEC_Event_Release__c where id =:oEventRelease.Id];
		System.assertEquals(true, eveRelease.Released__c, 'When the batch process is done, the release would be released');

		//Cover IEC_EventRelease_Svc method generateAutoRenewals
		IEC_EventRelease_Svc.generateAutoRenewals(new List<IEC_Event_Release__c>{eveRelease}, new Map<Id,IEC_Event_Release__c>(new List<IEC_Event_Release__c>{eveRelease}));
		IEC_EventRelease_Svc.preventDeletion(new List<IEC_Event_Release__c>{eveRelease});

		System.assertEquals(null, eveRelease.Processing_Status__c);
    }
    	
}
