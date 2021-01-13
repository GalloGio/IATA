@isTest
public class IEC_REST_Zuora_TaxShipping_Test {
	public static Contact oContact;
	public static List<Zuora.zObject> lstRatePlan;
	public static Map<String, List<Zuora.zObject>> mapRatePlanCharge;
	public static String sSource;

	private static void Init()
	{
		/**************************************
		** Initialize Custom Settings
		**************************************/
        insert new Apex_Setting__c(Name='Zuora Outbound IP Address2', Text_1__c=',192.0.0.1,');
			
		/**************************************
		** Initialize Account/Contact/Location
		**************************************/
        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
        oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
		IECAddress__c oAddress = TestDataGenerator.generateAddresses(1, true)[0];

		// Generate Sold to Location and update Account
		Location__c oLocSoldTo = TestDataGenerator.generateLocations('Sold To', oAddress.Id, oAccount.Id, null);

		oAccount.SoldTo_Location__c = oLocSoldTo.Id;
		update oAccount;
		
		// Generate Bill/Ship to Location and update Contact
		Location__c oLocBillTo = TestDataGenerator.generateLocations('Bill To', oAddress.Id, oAccount.Id, oContact.Id);
		Location__c oLocShipTo = TestDataGenerator.generateLocations('Ship To', oAddress.Id, oAccount.Id, oContact.Id);

		oContact.BillTo_Location__c = oLocBillTo.Id;
		oContact.ShipTo_Location__c = oLocShipTo.Id;
		update oContact;

		/**************************************
		** Prepare fake Zuora Callout returns
		**************************************/
        lstRatePlan = new List<Zuora.zObject>();
		mapRatePlanCharge = new Map<String, List<Zuora.zObject>>();
		
        // Add Tax product rate plan and charge
        Zuora.zObject zRatePlanTax = new Zuora.zObject('RatePlan');
        zRatePlanTax.setValue('Id', TestDataGenerator.generateZuoraFakeId());
        zRatePlanTax.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora tax Plan id'));
        lstRatePlan.add(zRatePlanTax);
        
        Zuora.zObject zRatePlanChargeTax = new Zuora.zObject('RatePlanCharge');
        zRatePlanChargeTax.setValue('Id', TestDataGenerator.generateZuoraFakeId());
        zRatePlanChargeTax.setValue('RatePlanId', zRatePlanTax.getValue('Id'));
        zRatePlanChargeTax.setValue('Price', 13);
        zRatePlanChargeTax.setValue('Quantity', 1);
        mapRatePlanCharge.put((String) zRatePlanTax.getValue('Id'), new List<Zuora.zObject> {zRatePlanChargeTax});
        
		// Add Shipping product rate plan and charge
        Zuora.zObject zRatePlanShip = new Zuora.zObject('RatePlan');
        zRatePlanShip.setValue('Id', TestDataGenerator.generateZuoraFakeId());
        zRatePlanShip.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora shipping Plan id'));
        lstRatePlan.add(zRatePlanShip);

        Zuora.zObject zRatePlanChargeShip = new Zuora.zObject('RatePlanCharge');
        zRatePlanChargeShip.setValue('Id', TestDataGenerator.generateZuoraFakeId());
        zRatePlanChargeShip.setValue('RatePlanId', zRatePlanShip.getValue('Id'));
        zRatePlanChargeShip.setValue('Price', 10);
        zRatePlanChargeShip.setValue('Quantity', 1);
        mapRatePlanCharge.put((String) zRatePlanShip.getValue('Id'), new List<Zuora.zObject> {zRatePlanChargeShip});

		// Add Main product rate plan and charge
        Zuora.zObject zRatePlanMain = new Zuora.zObject('RatePlan');
        zRatePlanMain.setValue('Id', TestDataGenerator.generateZuoraFakeId());
        zRatePlanMain.setValue('ProductRatePlanId', TestDataGenerator.generateZuoraFakeId());
        lstRatePlan.add(zRatePlanMain);

        Zuora.zObject zRatePlanChargeMain = new Zuora.zObject('RatePlanCharge');
        zRatePlanChargeMain.setValue('Id', TestDataGenerator.generateZuoraFakeId());
        zRatePlanChargeMain.setValue('RatePlanId', zRatePlanMain.getValue('Id'));
        zRatePlanChargeMain.setValue('Price', 100);
        zRatePlanChargeMain.setValue('Quantity', 1);
        mapRatePlanCharge.put((String) zRatePlanMain.getValue('Id'), new List<Zuora.zObject> {zRatePlanChargeMain});
        
		/********************************************************
		** Initialize Product2 and ZProducts and related objects
		********************************************************/
		Product2 oProduct = TestDataGenerator.generateProducts(1, false)[0];
		oProduct.SAP_Material_Number__c = 'TESTPRODCODE';
		oProduct.Charge_Shipping__c = true;
		insert oProduct;
		
		zqu__ProductRatePlan__c zRatePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate Plan', false, oProduct);
		zRatePlan.zqu__ZuoraId__c = (String) zRatePlanMain.getValue('ProductRatePlanId');
		insert zRatePlan;
	}
        
	/****************************************************************************************************
		Created by CGI, Samy 2016-04-06
			Cover code of method "updateTaxAndShipping"
	****************************************************************************************************/
    @isTest (seeAllData=true)
    static void test_updateTaxAndShipping()
    {
        List<String> returnData = new List<String>();
        String responseMsg;

        Init();
        
        TestDataGenerator.generateSFDC_SAP_Mapping(true);

        //*** test
        Test.startTest();
            Test.setMock(WebServiceMock.class, new SAP_Freight_and_Tax_Mock());
            
            // Initialize the Tax & Shipping webservice to work successfully
            returnData.clear();
            returnData.add('TESTPRODCODE');
            returnData.add('5');
            returnData.add('10');
            SAP_Freight_and_Tax_Mock.returnError = null;
            SAP_Freight_and_Tax_Mock.returnOK = JSON.serialize(returnData);
            
			RestRequest req = new RestRequest();
			RestResponse res = new RestResponse();
			
			req.remoteAddress = '192.0.0.1';
			req.requestURI = '/services/apexrest/Zuora/updateTaxAndShipping';  //Request URL
			req.httpMethod = 'POST';//HTTP Request Type
			req.requestBody = Blob.valueOf(
				'<?xml version="1.0" encoding="UTF-8"?><callout><parameter name="zAmendmentDate">04/13/2017</parameter>'
					+ '<parameter name="zAccountID">2c92c0f950a292810150aeff183d1c67</parameter>'
					+ '<parameter name="zSubscriptionName">TEST-001</parameter>'
					+ '<parameter name="zSubscriptionID">2c92c0f9540e2d91015410bd69194c1a</parameter>'
					+ '<parameter name="zEventCategory">UpcomingRenewal</parameter>'
					+ '</callout>');
			RestContext.request = req;
			RestContext.response = res;
			
            IEC_REST_Zuora_TaxShipping.updateTaxAndShipping();

            System.assertEquals('Tax and Shipping have been updated successfully.', RestContext.response.responseBody.toString());
            System.assertEquals(200, RestContext.response.statusCode, 'Response must return an OK result.');
        Test.stopTest();
    }
    
    // Test method to cover error handling path
    @isTest (seeAllData=true)
    static void test_updateTaxAndShipping_ErrorHandling()
    {
        List<String> returnData = new List<String>();
        String responseMsg;

        TestDataGenerator.generateSFDC_SAP_Mapping(true);

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.remoteAddress = '192.0.0.1';
		req.requestURI = '/services/apexrest/Zuora/updateTaxAndShipping';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf(
			'<?xml version="1.0" encoding="UTF-8"?><callout><parameter name="zAmendmentDate">04/13/2017</parameter>'
				+ '<parameter name="zAccountID">2c92c0f950a292810150aeff183d1c67</parameter>'
				+ '<parameter name="zSubscriptionName">TEST-001</parameter>'
				+ '<parameter name="zSubscriptionID">2c92c0f9540e2d91015410bd69194c1a</parameter>'
				+ '<parameter name="zEventCategory">UpcomingRenewal</parameter>'
				+ '</callout>');
		RestContext.request = req;
		RestContext.response = res;

        //*** test
        Test.startTest();
/* Error Validation is skipped since we are using a AWS Gateway to authenticate the user before calling the function
// Error 00: Call is not made from Zuora
            IEC_REST_Zuora_TaxShipping.updateTaxAndShipping();

            System.assertEquals('Webservice cannot be initiated unless connections issued from Zuora servers.', RestContext.response.responseBody.toString());
            System.assertEquals(424, RestContext.response.statusCode, 'Response must return an error result.');
*/        
			insert new Apex_Setting__c(Name='Zuora Outbound IP Address2', Text_1__c=',' + req.remoteAddress + ',');

    		/**************************************
			** Initialize Account/Contact/Location
			**************************************/
	        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
	        oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, false)[0];
	        
// Error 01: Contact Id cannot be null
            IEC_REST_Zuora_TaxShipping.updateTaxAndShipping();

            System.assertEquals('CRM Contact Id cannot be null.', RestContext.response.responseBody.toString());
            System.assertEquals(424, RestContext.response.statusCode, 'Response must return an error result.');

	        insert oContact;

			IECAddress__c oAddress = TestDataGenerator.generateAddresses(1, true)[0];
	
			// Generate Sold to Location and update Account
			Location__c oLocSoldTo = TestDataGenerator.generateLocations('Sold To', oAddress.Id, oAccount.Id, null);
	
			oAccount.SoldTo_Location__c = oLocSoldTo.Id;
			update oAccount;
			
			// Generate Bill/Ship to Location and update Contact
			Location__c oLocBillTo = TestDataGenerator.generateLocations('Bill To', oAddress.Id, oAccount.Id, oContact.Id);
			Location__c oLocShipTo = TestDataGenerator.generateLocations('Ship To', oAddress.Id, oAccount.Id, oContact.Id);
	
			oContact.BillTo_Location__c = oLocBillTo.Id;
			oContact.ShipTo_Location__c = oLocShipTo.Id;
			update oContact;

// Error 02: Cannot find rateplan for subscription
            IEC_REST_Zuora_TaxShipping.updateTaxAndShipping();

            System.assertEquals('Could not query Zuora RatePlans from Subscription.', RestContext.response.responseBody.toString());
            System.assertEquals(424, RestContext.response.statusCode, 'Response must return an error result.');

			/**************************************
			** Prepare fake Zuora Callout returns
			**************************************/
	        lstRatePlan = new List<Zuora.zObject>();
			mapRatePlanCharge = new Map<String, List<Zuora.zObject>>();
			
	        // Add Tax product rate plan and charge
	        Zuora.zObject zRatePlanTax = new Zuora.zObject('RatePlan');
	        zRatePlanTax.setValue('Id', TestDataGenerator.generateZuoraFakeId());
	        zRatePlanTax.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora tax Plan id'));
	        lstRatePlan.add(zRatePlanTax);
	        
	        Zuora.zObject zRatePlanChargeTax = new Zuora.zObject('RatePlanCharge');
	        zRatePlanChargeTax.setValue('Id', TestDataGenerator.generateZuoraFakeId());
	        zRatePlanChargeTax.setValue('RatePlanId', zRatePlanTax.getValue('Id'));
	        zRatePlanChargeTax.setValue('Price', 13);
	        zRatePlanChargeTax.setValue('Quantity', 1);
	        mapRatePlanCharge.put((String) zRatePlanTax.getValue('Id'), new List<Zuora.zObject> {zRatePlanChargeTax});
	        
			// Add Shipping product rate plan and charge
	        Zuora.zObject zRatePlanShip = new Zuora.zObject('RatePlan');
	        zRatePlanShip.setValue('Id', TestDataGenerator.generateZuoraFakeId());
	        zRatePlanShip.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora shipping Plan id'));
	        lstRatePlan.add(zRatePlanShip);
	
	        Zuora.zObject zRatePlanChargeShip = new Zuora.zObject('RatePlanCharge');
	        zRatePlanChargeShip.setValue('Id', TestDataGenerator.generateZuoraFakeId());
	        zRatePlanChargeShip.setValue('RatePlanId', zRatePlanShip.getValue('Id'));
	        zRatePlanChargeShip.setValue('Price', 10);
	        zRatePlanChargeShip.setValue('Quantity', 1);
	        mapRatePlanCharge.put((String) zRatePlanShip.getValue('Id'), new List<Zuora.zObject> {zRatePlanChargeShip});

// Error 03: Cannot find main product rateplan
            IEC_REST_Zuora_TaxShipping.updateTaxAndShipping();

            System.assertEquals('Unable to locate the main product in the specified subscription.', RestContext.response.responseBody.toString());
            System.assertEquals(424, RestContext.response.statusCode, 'Response must return an error result.');

			// Add Main product rate plan and charge
	        Zuora.zObject zRatePlanMain = new Zuora.zObject('RatePlan');
	        zRatePlanMain.setValue('Id', TestDataGenerator.generateZuoraFakeId());
	        zRatePlanMain.setValue('ProductRatePlanId', TestDataGenerator.generateZuoraFakeId());
	        lstRatePlan.add(zRatePlanMain);
	
	        Zuora.zObject zRatePlanChargeMain = new Zuora.zObject('RatePlanCharge');
	        zRatePlanChargeMain.setValue('Id', TestDataGenerator.generateZuoraFakeId());
	        zRatePlanChargeMain.setValue('RatePlanId', zRatePlanMain.getValue('Id'));
	        zRatePlanChargeMain.setValue('Price', 100);
	        zRatePlanChargeMain.setValue('Quantity', 1);
	        mapRatePlanCharge.put((String) zRatePlanMain.getValue('Id'), new List<Zuora.zObject> {zRatePlanChargeMain});

// Error 04: Cannot find SAP Code for product
            IEC_REST_Zuora_TaxShipping.updateTaxAndShipping();

            System.assert(RestContext.response.responseBody.toString().contains('Unable to locate a SAP Product Code for the product on the subscription. ProductRatePlanId:'));
            System.assertEquals(424, RestContext.response.statusCode, 'Response must return an error result.');
	        
// Error 05: Cannot find Product2 for specified SAP Code
            IEC_REST_Zuora_TaxShipping.updateTaxAndShipping();

            //System.assert(RestContext.response.responseBody.toString().contains('Unable to locate a Salesforce Product for the product code on the ZProduct. Product Code:'));
            //System.assertEquals(424, RestContext.response.statusCode, 'Response must return an error result.');
			
            /********************************************************
			** Initialize Product2 and related objects
			********************************************************/
			Product2 oProduct = TestDataGenerator.generateProducts(1, false)[0];
			oProduct.SAP_Material_Number__c = 'TESTPRODCODE';
			oProduct.Charge_Shipping__c = true;
			insert oProduct;
			
			zqu__ProductRatePlan__c zRatePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate Plan', false, oProduct);
			zRatePlan.zqu__ZuoraId__c = (String) zRatePlanMain.getValue('ProductRatePlanId');
			insert zRatePlan;

            Test.setMock(WebServiceMock.class, new SAP_Freight_and_Tax_Mock());

            // Initialize the Tax & Shipping webservice to fail
            returnData.clear();
            returnData.add('error');
            returnData.add('501');
            returnData.add('error 501');
            SAP_Freight_and_Tax_Mock.returnError = JSON.serialize(returnData);

// Error 06: Tax Webservice fails
            IEC_REST_Zuora_TaxShipping.updateTaxAndShipping();

            System.assert(RestContext.response.responseBody.toString().contains('Error returned from Tax & Shipping webservice.'));
            //System.assertEquals(424, RestContext.response.statusCode, 'Response must return an error result.');
            
// Misc Coverage
            
            // Set the orderid to any not-null values to skip tax and shipping calculation, and set the event to be SubscriptionCreated
			RestContext.request.requestBody = Blob.valueOf(
				'<?xml version="1.0" encoding="UTF-8"?><callout><parameter name="zAmendmentDate">04/13/2017</parameter>'
					+ '<parameter name="zAccountID">2c92c0f950a292810150aeff183d1c67</parameter>'
					+ '<parameter name="zSubscriptionName">TEST-001</parameter>'
					+ '<parameter name="zSubscriptionID">2c92c0f9540e2d91015410bd69194c1a</parameter>'
					+ '<parameter name="zEventCategory">SubscriptionCreated</parameter>'
					+ '</callout>');

	        sSource = 'Salesforce';
	        
            IEC_REST_Zuora_TaxShipping.updateTaxAndShipping();

            System.assertEquals('Tax and Shipping have been updated successfully.', RestContext.response.responseBody.toString());
            System.assertEquals(200, RestContext.response.statusCode, 'Response must return an OK result.');
        Test.stopTest();
    }
}