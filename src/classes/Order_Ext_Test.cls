@isTest
private class Order_Ext_Test
{
	public static List<Account> accounts;
    public static List<Contact> sfContacts;
    public static Location__c locSoldTo, locBillTo, locShipTo;

	private static void generateAccountsContacts()
	{
		TestDataGenerator.generateApexSetting();
        TestDataGenerator.generateISOCountryState();

        String ClientType = IECConstants.Account_ClientType_MemberAirline;
        accounts = TestDataGenerator.generateAccounts(2, false);
        accounts[0].RecordTypeId = IECUserManager.getAccountRecordTypeForIEC(ClientType);
        accounts[0].Membership_status__c = IECConstants.Account_MembershipStatus_IATAMember;
        accounts[0].ICH_Member__c = true;
        accounts[1].RecordTypeId = IECUserManager.getAccountRecordTypeForIEC(ClientType);
        accounts[1].Membership_status__c = IECConstants.Account_MembershipStatus_IATAMember;
        accounts[1].ICH_Member__c = true;
        insert accounts;
        accounts[1].ParentId = accounts[0].Id; //accounts[0] is the Parent Account
        update accounts; 

        sfContacts = TestDataGenerator.generateContacts(accounts[0].Id, 2, false);
        sfContacts.addAll(TestDataGenerator.generateContacts(accounts[1].Id, 2, false));
        insert sfContacts;
        
        //*** for Utility.sendBulkEmails method
        List<EmailTemplate> lstTemplate = [select Id from EmailTemplate limit 1];
        List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
        listCS.add(new Apex_Setting__c(Name='ContactId to populate email Template', Text_1__c=sfContacts[0].Id));
        listCS.add(new Apex_Setting__c(Name='Order sold templateId for client', Text_1__c=lstTemplate[0].Id));
        listCS.add(new Apex_Setting__c(Name='Order in process templateId for client', Text_1__c=lstTemplate[0].Id));
        listCS.add(new Apex_Setting__c(Name='Order templateId for special shipping', Text_1__c=lstTemplate[0].Id));
        insert listCS;
        
        //address & location
        List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
        locSoldTo = TestDataGenerator.generateLocations('Sold To', lstAddress[0].Id, accounts[0].Id, null, 'ST-' + String.valueOf(lstAddress[0].Id).right(5));
        locBillTo = TestDataGenerator.generateLocations('Bill To', lstAddress[0].Id, accounts[0].Id, sfContacts[2].Id, 'BT-' + String.valueOf(lstAddress[0].Id).right(5));
        locShipTo = TestDataGenerator.generateLocations('Ship To', lstAddress[0].Id, accounts[0].Id, sfContacts[2].Id, 'SH-' + String.valueOf(lstAddress[0].Id).right(5));

        List<User> sfPortalUsers = new List<User>();
        sfPortalUsers.add(TestDataGenerator.generatePortalUser('ISS Portal', sfContacts[0].Id, false));
        sfPortalUsers.add(TestDataGenerator.generatePortalUser('ISS Portal', sfContacts[1].Id, false));
        sfPortalUsers.add(TestDataGenerator.generatePortalUser('ISS Portal', sfContacts[2].Id, false));
        insert sfPortalUsers;
	} //*** end of "generateAccountsContacts"

	private static void generateProducts()
	{
		//-- Products 
        List<Product2> products = TestDataGenerator.generateProducts(3,false);
		List<zqu__ZProduct__c> zProducts = TestDataGenerator.generateZProducts(3, true);
		List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
		List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();
		List<PricebookEntry> lst_pbe = new List<PricebookEntry>();

		for(Integer x = 0; x < products.size(); x++)
		{
			Product2 prod = products[x]; 
			zqu__ZProduct__c zprod = zProducts[x];
			zRatePlans.addAll(TestDataGenerator.generateZRatePlans(zprod.Id,1,false)); //1 rate plan per product
			prod.SAP_Status_Code__c = 'A';
			prod.Post_to_Ecommerce_Date__c = System.today().addDays(-7);
			prod.ZProduct__c = zprod.Id;
		}

		insert zRatePlans;

		//Create Unit Price Charge & Discount for each Plan 
		for(zqu__ProductRatePlan__c rp : zRatePlans)
		{
			//Unit Price & Discount
			List<zqu__ProductRatePlanCharge__c> charges = TestDataGenerator.generateZCharges(rp.Id, 2, false);
			charges[0].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
			charges[1].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT;
			zCharges.addAll(charges);
		}

		insert zCharges;
		insert products;

		//-- Create PriceBookEntries for each product 		
		for(Product2 p : products)
		{
			lst_pbe.add(new PricebookEntry(
				Pricebook2Id = Test.getStandardPricebookId(),
				Product2Id = p.Id,
				UnitPrice = 20
			));
		}
		insert lst_pbe;

	}


	static testMethod void test_Order_Header()
	{
        //-- Generate Test Data 
        generateAccountsContacts(); 

         //*** view new order
        Test.setCurrentPageReference(new PageReference('/apex/Order'));
        Order_Ext ext = new Order_Ext(new ApexPages.StandardController(new Order()));
        ext.pageLoad();
        system.assert(ext.allowEditSave, 'Wrong allowEditSave: ' + ext.allowEditSave);

        //Create SoldTo Location
        List<IECAddress__c> lstAddresses = TestDataGenerator.generateAddresses(3,true);
        Location__c soldToLocation = TestDataGenerator.generateLocations(IECConstants.SOLDTO, lstAddresses[0].Id, accounts[1].Id, null);
        soldToLocation.VAT_Number__c = 'FR92384753760';
        update soldToLocation;

        //Location__c soldToLocationAcc1 = TestDataGenerator.generateLocations(IECConstants.SOLDTO, lstAddresses[0].Id, accounts[0].Id, null);
        //soldToLocationAcc1.VAT_Number__c = 'FR61420495178';
        //update soldToLocationAcc1;

        //Create billTo Location
        Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, lstAddresses[1].Id, accounts[1].Id, sfContacts[0].Id);

        //Create ShipTo Location
        Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, lstAddresses[2].Id, accounts[1].Id, sfContacts[1].Id);

        //*** create new order
        Test.setCurrentPageReference(new PageReference('/apex/Order?retURL=' + Order.SObjectType.getDescribe().getKeyPrefix() + '&save_new=1&contactID=' + sfContacts[0].Id));
        ext = new Order_Ext(new ApexPages.StandardController(new Order()));
Test.startTest();        
        ext.pageLoad();
        system.assert(ext.allowEditSave, 'Wrong allowEditSave: ' + ext.allowEditSave);

        //set the contact default location
        Contact contact = sfContacts[0];
        contact.BillTo_Location__c = billToLocation.Id;
        contact.ShipTo_Location__c = shipToLocation.Id;
        update contact;

        //Set the BillTo Contact
        ext.vfOrder.BillToContactId = sfContacts[0].Id;
        ext.getContactLocations();
        system.assertEquals(ext.vfOrder.AccountId,accounts[0].Id);

        //Cover Edit Address on order readonly page
        ext.editAddressOrderReadOnly();

        //Cover Cancel
        ext.CancelAddressOrderReadOnly();

        //Cover save billing address
        ext.saveAddressOrderReadOnly();

        //Cover add shipTo address
        ext.addShpAddressOrder();

        //Cover Save ShipToAddress
        //ext.saveAddressOrder();

        ext.getBillToLocations();
        ext.shipToContactDetails();

        
        //Cover the AutoComplete
        List<IECAddress__c> lstIECAddresses = [select id, Full_Address__c from IECAddress__c limit 1];
        if(lstIECAddresses != null && lstIECAddresses.size() > 0){
            ext.fullAddress = lstIECAddresses[0].Full_Address__c;
            ext.autoCompleteBillToAddresses();
            ext.autoCompleteShipToAddresses();
            Order_Ext.getAddresses(lstIECAddresses[0].Full_Address__c);
        }
        

        //Cover Edit Shipping Address
        ext.editShpAddressOrder();
        ApexPages.currentPage().getParameters().put('vatNumber','BE0400853488');
        ApexPages.currentPage().getParameters().put('autoCompShipToLoading','3042 vale');
        ext.selectedShipCountryIsoCode = 'BF';
        ext.shipCity = 'Ouaga';
        ext.saveAddressOrder();

        ext.selectedShipToLocation = ext.vfOrder.ShipTo_Location__c;
        ext.saveAddressOrder();

        ext.editShipToAddressOrderReadOnly();

        ext.CancelAddressOrder();

        
        
        //*** test method "changeBillToCountry"
        ext.vfOrder.BillingCountryCode__c = 'ZZ';
        ext.changeBillToCountry();
        system.assert(ext.vfOrder.BillingCountryCode__c == null, 'Wrong BillingCountryCode__c: ' + ext.vfOrder.BillingCountryCode__c);
        ext.vfOrder.BillingCountry = 'Mexico';
        ext.vfOrder.BillingCountryCode__c = null;
        ext.vfOrder.BillingStateCode__c = 'ZZ';
        ext.changeBillToCountry(true);
        system.assert(ext.vfOrder.BillingCountryCode__c != null && ext.vfOrder.BillingStateCode__c == null, 'Wrong BillingCountryCode__c and BillingStateCode__c');
        
        //*** test method "changeBillToState"
        ext.vfOrder.BillingCountryCode__c = 'CA';
        ext.changeBillToCountry();
        ext.vfOrder.BillingState = null;
        ext.vfOrder.BillingStateCode__c = '';
        
        //*** test method "changeShipToCountry"
        ext.vfOrder.ShippingCountryCode__c = 'ZZ';
        
        
        //*** test method "saveOrder"
        ext.vfOrder.AccountId = null;
        //ext.refreshSoldToInfo();
        ext.vfOrder.BillToContactId = null;
        
        ext.vfOrder.ShipTo_same_BillTo__c = true;
        //ext.vfOrder.Is_New_Bill_To__c = true;
        ext.saveOrder();
        //system.assert(ApexPages.getMessages().size() == 2, 'Should have 2 errors: ' + ApexPages.getMessages());
        ext.vfOrder.ShipTo_same_BillTo__c = false;
        //ext.vfOrder.Is_New_Bill_To__c = false;
        //ext.vfOrder.Is_New_Ship_To__c = true;
        ext.saveOrder();
        //system.assert(ApexPages.getMessages().size() == 2, 'Should have 2 errors: ' + ApexPages.getMessages());
        Test.setCurrentPageReference(new PageReference('/apex/Order?retURL=' + Order.SObjectType.getDescribe().getKeyPrefix() + '&save_new=1&accountID=' + accounts[0].Id));
        ext = new Order_Ext(new ApexPages.StandardController(new Order()));
        ext.pageLoad();
        ext.vfOrder.BillToContactId = sfContacts[0].Id;
        //ext.refreshBillToInfo();
        ext.vfOrder.BillToContact_Email__c = 'test@test.com';
        ext.vfOrder.BillToContact_Phone__c = '111-111-1111';
        ext.vfOrder.ShipTo_same_BillTo__c = true;
        ext.vfOrder.EffectiveDate = null;
        ext.saveOrder();
        //system.assert(ApexPages.getMessages().size() == 5, 'Should have 5 errors: ' + ApexPages.getMessages());
        ext.vfOrder.EffectiveDate = system.today();
        ext.vfOrder.Shipping_Instruction__c = 'special shipping';
        ext.saveOrder();
        //system.assert(ApexPages.getMessages().size() == 5, 'Should be no other error: ' + ApexPages.getMessages());
        
        //*** edit an order
        Test.setCurrentPageReference(new PageReference('/apex/Order?id=' + ext.vfOrder.Id + '&retURL=/' + Order.SObjectType.getDescribe().getKeyPrefix()));
        ext = new Order_Ext(new ApexPages.StandardController(ext.vfOrder));
        ext.pageLoad();
        ext.vfOrder.BillingState = 'ZZZ';
        ext.vfOrder.BillingStateCode__c = 'ZZZ';
        ext.vfOrder.ShippingState = 'ZZZ';
        ext.vfOrder.ShippingStateCode__c = 'ZZZ';
        ext.saveOrder();
        //system.assert(ext.vfOrder.Is_New_Shipping_Address__c, 'Wrong Is_New_Shipping_Address__c');
        
        //*** test methods "cancelOrder_Prepare" & "cancelOrder"
        ext.cancelOrder_Prepare();
        system.assert(ext.isCancelling, 'Wrong isCancelling');
        //ext.cancelOrder();  // nothing to assert for this method

        //*** cover the rest of buildCountryStatePicklist
        Test.setCurrentPageReference(new PageReference('/apex/Order'));
        ext = new Order_Ext(new ApexPages.StandardController(ext.vfOrder));
        ext.pageLoad();

        Test.stopTest();
        /*delete [select Id from IATA_ISO_Country__c];
        ext = new Order_Ext(new ApexPages.StandardController(ext.vfOrder));*/

    } //*** end of "test_Order_Header"

    @isTest(SeeAllData = true)
    static void test_Order_Header2()
    {
        //-- Generate Test Data 
        generateAccountsContacts();
        TestDataGenerator.generatePaymentThreshold();

        //*** generate order for payment and tax
        List<Order> listOrder = TestDataGenerator.generateOrder(3, accounts[0].Id, sfContacts[2].Id, sfContacts[2].Id, false);
        for (Integer i1 = 0; i1 < listOrder.size(); i1++) {
            listOrder[i1].Type = 'Order';
            listOrder[i1].Source__c = 'Inbound call';
            listOrder[i1].Order_Channel__c = 'Central Direct Sales';
            listOrder[i1].SoldTo_Location__c = locSoldTo.Id;
            listOrder[i1].BillTo_Location__c = locBillTo.Id;
            listOrder[i1].ShipTo_Location__c = locShipTo.Id;
            listOrder[i1].BillTo_Address__c = locBillTo.Address__c;
            listOrder[i1].ShipTo_Address__c = locShipTo.Address__c;
        }
        listOrder[0].Type = 'No conversion';
        insert listOrder;
        List<OrderItem> listOrderItem = TestDataGenerator.generateOrderItem(listOrder[1].Id, 1, false);
        listOrderItem.addAll(TestDataGenerator.generateOrderItem(listOrder[2].Id, 1, false));
        insert listOrderItem;
        TestDataGenerator.generateSFDC_SAP_Mapping(true);
        List<String> returnData = new List<String>();

        //*** cover methods "getFreight_Tax", "callSAP_Freight_Tax", "payOrder_Prepare" and "payOrder"
        Integer initCount = ApexPages.getMessages().size();
        Test.startTest();
            Test.setMock(WebServiceMock.class, new SAP_Freight_and_Tax_Mock());
            Test.setCurrentPageReference(new PageReference('/apex/Order?id=' + listOrder[0].Id));
            Order_Ext ext = new Order_Ext(new ApexPages.StandardController(listOrder[0]));
            ext.pageLoad();
            ext.getFreight_Tax();
            system.assert(ApexPages.getMessages().size() == initCount + 1, 'Should have 1 error: ' + ApexPages.getMessages());
            ext.payOrder_Prepare();  // error of no product
            system.assert(ApexPages.getMessages().size() == initCount + 2, 'Should have 2 errors: ' + ApexPages.getMessages());
            Test.setCurrentPageReference(new PageReference('/apex/Order?id=' + listOrder[1].Id));
            ext = new Order_Ext(new ApexPages.StandardController(listOrder[1]));
            ext.pageLoad();
            ext.payOrder_Prepare();  // error of missing shipping & tax
            system.assert(ApexPages.getMessages().size() == initCount + 3, 'Should have 3 errors: ' + ApexPages.getMessages());
            listOrderItem = [select Id, Product_Number__c, Quantity, Charge_Shipping__c, SubTotal__c from OrderItem where Id = :listOrderItem[0].Id];
            returnData.clear();
            returnData.add(listOrderItem[0].Product_Number__c);
            returnData.add('100');
            returnData.add('1000');
            SAP_Freight_and_Tax_Mock.returnError = null;
            SAP_Freight_and_Tax_Mock.returnOK = JSON.serialize(returnData);
            ext.getFreight_Tax();
            system.assert(ApexPages.getMessages().size() == initCount + 3, 'Should be no other error: ' + ApexPages.getMessages());
            ext.payOrder_Prepare();
            system.assert(ApexPages.getMessages().size() == initCount + 3 && ext.isPaying, 'Should be no other error: ' + ApexPages.getMessages());
            ext.paymentType = 'Bank Transfer';
            ext.payOrder();
            //system.assert(ApexPages.getMessages().size() == 3 && ext.isPaying, 'Should be no other error: ' + ApexPages.getMessages());
        Test.stopTest();
    } //*** end of "test_Order_Header2"


    @isTest(SeeAllData = true)
    static void test_Order_Items()
    {
        //-- Generate Test Data 
        TestDataGenerator.generateApexSetting();
        TestDataGenerator.generateISOCountryState();

        //Account & Contact
        Account sfAccount = TestDataGenerator.generateAccounts(1, true)[0];
        Contact sfContact = TestDataGenerator.generateContacts(sfAccount.Id, 1, true)[0];

        //address & location
        List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
        Location__c locSoldTo2 = TestDataGenerator.generateLocations('Sold To', lstAddress[0].Id, sfAccount.Id, null, 'ST-' + String.valueOf(lstAddress[0].Id).right(5));
        Location__c locBillTo2 = TestDataGenerator.generateLocations('Bill To', lstAddress[0].Id, sfAccount.Id, sfContact.Id, 'BT-' + String.valueOf(lstAddress[0].Id).right(5));
        Location__c locShipTo2 = TestDataGenerator.generateLocations('Ship To', lstAddress[0].Id, sfAccount.Id, sfContact.Id, 'SH-' + String.valueOf(lstAddress[0].Id).right(5));

        //DirectSale Products & Prices 
        List<Product2> products = TestDataGenerator.generateDirectSaleProductsWithPrice(3);
        
        //Order
        Order sfOrder = TestDataGenerator.generateOrder(1, sfAccount.Id, sfContact.Id, sfContact.Id, true)[0];
        OrderItem sfOrderItem = TestDataGenerator.generateOrderItem(sfOrder.Id, 1, true)[0];
        
        sfOrder.SoldTo_Location__c = locSoldTo2.Id;
        sfOrder.BillTo_Location__c = locBillTo2.Id;
        sfOrder.ShipTo_Location__c = locShipTo2.Id;
        sfOrder.BillTo_Address__c = locBillTo2.Address__c;
        sfOrder.ShipTo_Address__c = locShipTo2.Address__c;
        
        // Insert a non-compliant country that is the same as the one defined on the order to test for non-compliance
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(ISO_Code__c='CA', Is_Non_Compliant__c = true);
    	upsert country ISO_Code__c;

        // Set the country to the same country used for non-compliance test
        sfOrder.BillingCountryCode__c = 'CA';
        sfOrder.ShippingCountryCode__c = 'CA';
        update sfOrder;

        //Goto order Page
        ApexPages.StandardController ctrl = new ApexPages.StandardController(sfOrder);
        Order_Ext ext = new Order_Ext(ctrl);
        ext.pageLoad();
        ApexPages.currentPage().getParameters().put('id',sfOrder.Id);

        ext.initOrderItems();


        //No Item added in the order
        System.assertEquals(1, ext.orderProducts.size());

        
        // orderitems are not compliant
        //System.assertEquals(false, ext.bAreProductsCompliant);  -> to fix when Samy complete the new structure

        // Add 1st product
        ext.addProducts();

        ApexPages.currentPage().getParameters().put('productsNumbers',products[0].SAP_Material_Number__c);
        ext.addProductsToOrder();

        //--Remove product 
        ext.removeProductsFromOrder();

        ext.hideAddProductsSection();
        ext.selectedProductsIdsStr = products[1].SAP_Material_Number__c;
        ext.addSelectedProducts();

        ext.selectMore();

        Test.startTest();   //*** to bypass nb of queries

        ApexPages.currentPage().getParameters().put('orderItemId',sfOrderItem.Id);
        ext.resendOrderItemLink();
        ext.selectOrderItemToEdit();
        
        PriceDetail_DTO priceDetail = new PriceDetail_DTO();
        priceDetail.unitPrice = 20;
        priceDetail.discountName = 'coupon123';
        List<PriceDetail_DTO> lstPriceDetail = new List<PriceDetail_DTO>();
        lstPriceDetail.add(priceDetail);

        PriceInfo_DTO priceInfo = new PriceInfo_DTO();
        priceInfo.couponPrice = lstPriceDetail;

        ext.orderProducts[0].couponCode = 'coupon123';
        ext.orderItemToEdit.couponCode = ext.orderProducts[0].couponCode;
        ext.orderItemToEdit.PriceInfo = priceInfo;

        SalesOrderProduct_DTO dto = new SalesOrderProduct_DTO();
        dto.orderItemId = ext.orderProducts[0].orderItemId;       
        System.assertNotEquals(null,dto.orderItemId);

        ext.selectedShipToLocation = sfOrder.ShipTo_Location__c;
        sfOrder.BillTo_Location__c = ext.selectedShipToLocation;

        ext.listCountry = new List<SelectOption>();
        ext.listCountry.add(new SelectOption('CA', 'Canada'));

        ext.listBillingState = new List<SelectOption>();
        ext.listBillingState.add(new SelectOption('QC', 'Quebec'));
        ext.listShippingState = new List<SelectOption>();
        ext.listShippingState.add(new SelectOption('QC', 'Quebec'));

        ext.changeBillToCountryUsingLocation();
        ext.changeShipToCountryUsingLocation();

        ext.shipToContactDetails();

        ext.saveProduct();
        ext.saveSelectedProducts();

        ext.cancelOrder();
        ext.deleteProduct();

        ext.showAddProductsSection();

        ext.changeBillToState();

        ext.createSalesContract();

        try{
            ext.createSalesOrder();
            ext.createSalesContract();
        }catch(Exception ex){

        }
            
        Test.stopTest();
    }
}