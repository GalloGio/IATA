@isTest
private class Order_Ext_Test
{
	public static List<Account> accounts;
    public static List<Contact> sfContacts;
    public static Location__c locSoldTo, locBillTo, locShipTo;

	private static void generateAccountsContacts()
	{
		TestDataGenerator.generateApexSetting();
        IATA_ISO_Country__c countryCanada;
        IATA_ISO_State__c stateQuebec;
        for (IATA_ISO_Country__c country : TestDataGenerator.generateISOCountryState())
            if (country.ISO_Code__c == 'CA')
            {
                for (IATA_ISO_State__c state : country.IATA_ISO_States__r)
                    if (state.ISO_Code__c == 'QC')
                    {
                        stateQuebec = state;
                        break;
                    }
                countryCanada = country;
                break;
            }

        String ClientType = IECConstants.Account_ClientType_MemberAirline;
        accounts = TestDataGenerator.generateAccounts(2, false);
        accounts[0].RecordTypeId = IECUserManager.getAccountRecordTypeForIEC(ClientType);
        accounts[0].Membership_status__c = IECConstants.Account_MembershipStatus_IATAMember;
        accounts[0].ICH_Member__c = true;
        accounts[0].Payment_Term__c = '0011';
        accounts[0].IATA_ISO_Country__c = countryCanada.Id;
        accounts[0].IATA_ISO_Billing_State__c = stateQuebec.Id;
        accounts[0].IATA_ISO_Shipping_State__c = stateQuebec.Id;
        accounts[1].RecordTypeId = IECUserManager.getAccountRecordTypeForIEC(ClientType);
        accounts[1].Membership_status__c = IECConstants.Account_MembershipStatus_IATAMember;
        accounts[1].ICH_Member__c = true;
        accounts[1].Payment_Term__c = '0011';
        accounts[1].IATA_ISO_Country__c = countryCanada.Id;
        accounts[1].IATA_ISO_Billing_State__c = stateQuebec.Id;
        accounts[1].IATA_ISO_Shipping_State__c = stateQuebec.Id;
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
        //locShipTo = TestDataGenerator.generateLocations('Ship To', lstAddress[0].Id, accounts[0].Id, sfContacts[2].Id, 'SH-' + String.valueOf(lstAddress[0].Id).right(5));

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
        //Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, lstAddresses[1].Id, accounts[1].Id, sfContacts[0].Id);

        //Create ShipTo Location
        //Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, lstAddresses[2].Id, accounts[1].Id, sfContacts[1].Id);

        //*** create new order
        Test.setCurrentPageReference(new PageReference('/apex/Order?retURL=' + Order.SObjectType.getDescribe().getKeyPrefix() + '&save_new=1&contactID=' + sfContacts[0].Id));
        ext = new Order_Ext(new ApexPages.StandardController(new Order()));
Test.startTest();        
		Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
		SAP_CustomerMaster_Mock.returnError = null;
		SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'sold3', 'bill3', 'ship3'});
        ext.pageLoad();
        system.assert(ext.allowEditSave, 'Wrong allowEditSave: ' + ext.allowEditSave);
        Contact oContact = [select BillTo_Location__c, BillTo_Location__r.Address__c, ShipTo_Location__c, ShipTo_Location__r.Address__c from Contact where Id = :sfContacts[0].Id limit 1];
        system.assertEquals(ext.vfOrder.BillTo_Location__c, oContact.BillTo_Location__c);
        system.assertEquals(ext.vfOrder.ShipTo_Location__c, oContact.ShipTo_Location__c);

        //set the contact default location
        //Contact contact = sfContacts[0];
        //contact.BillTo_Location__c = billToLocation.Id;
        //contact.ShipTo_Location__c = shipToLocation.Id;
        //update contact;

        //Set the BillTo Contact
        ext.vfOrder.BillTo_Location__c = null;
        ext.vfOrder.BillTo_Address__c = null;
        ext.vfOrder.BillToContactId = sfContacts[0].Id;
        ext.getContactLocations();
        system.assertEquals(ext.vfOrder.AccountId,accounts[0].Id);
        system.assertEquals(ext.vfOrder.BillTo_Location__c, oContact.BillTo_Location__c);
        system.assertEquals(ext.vfOrder.BillTo_Address__c, oContact.BillTo_Location__r.Address__c);

        //Cover Edit Address on order readonly page
        ext.getBillToLocations();
        ext.editAddressOrderReadOnly();

        //Cover Cancel
        ext.CancelAddressOrderReadOnly();

        //Cover save billing address
        Integer intMsgCount = ApexPages.getMessages().size();
        ext.street = ext.vfOrder.BillingStreet + '111';
        ApexPages.currentPage().getParameters().put('billToautocomplete', ext.street);
        ext.saveAddressOrderReadOnly();   //*** success part for changing address within same country/province
        system.assertNotEquals([select Address__c from Location__c where Id = :oContact.BillTo_Location__c][0].Address__c, oContact.BillTo_Location__r.Address__c);
        ext.billToLocation.Phone__c = null;
        ext.billToLocation.Email__c = null;
        ext.street = null;
        ApexPages.currentPage().getParameters().put('billToautocomplete', ext.street);
        ext.city = null;
        ext.zipCode = null;
        ext.billToZipCodeRequired = true;
        ext.selectedCountryIsoCode = null;
        ext.listBillingState = new List<SelectOption>{new SelectOption('99', 'dummy')};
        ext.selectedStateIsoCode = null;
        ext.saveAddressOrderReadOnly();   //*** error part
        system.assert(ApexPages.getMessages().size() == intMsgCount + 7, 'Should have ' + (intMsgCount + 7) + ': ' + ApexPages.getMessages());
        ext.billToLocation.Phone__c = '111-111-1111';
        ext.billToLocation.Email__c = 'test@test.com';
        ext.street = '~~~ street';
        ApexPages.currentPage().getParameters().put('billToautocomplete', ext.street);
        ext.city = '~~~ city';
        ext.selectedCountryIsoCode = 'US';
        ext.vfOrder.BillingCountryCode__c = 'US';
        ext.vfOrder.BillingStateCode__c = 'US-AK';
        ext.changeBillToCountry(true);
        ext.changeBillToCountryUsingLocation(true);
        ext.selectedStateIsoCode = 'US-AK';
        ext.vfOrder.BillingStateCode__c = 'US-AK';
        ext.billToZipCodeRequired = false;
        ext.saveAddressOrderReadOnly();   //*** success part for changing country/province but return error because have DML during test
        system.assert(ApexPages.getMessages().size() == intMsgCount + 8, 'Should have ' + (intMsgCount + 8) + ': ' + ApexPages.getMessages());

        //Set the ShipTo Contact
        ext.vfOrder.ShipTo_Location__c = null;
        ext.vfOrder.ShipTo_Address__c = null;
        ext.vfOrder.ShipToContactId = sfContacts[0].Id;
        ext.getContactShipToLocations();
        system.assertEquals(ext.vfOrder.ShipTo_Location__c, oContact.ShipTo_Location__c);
        system.assertEquals(ext.vfOrder.ShipTo_Address__c, oContact.ShipTo_Location__r.Address__c);

        //Cover add shipTo address
        ext.addShpAddressOrder();
        system.assert(String.isBlank(ext.selectedShipToLocation), 'selectedShipToLocation should be blank: ' + ext.selectedShipToLocation);

        //Cover Cancel
        ext.CancelAddressOrder();
        system.assert(!String.isBlank(ext.selectedShipToLocation), 'selectedShipToLocation should NOT be blank');

        //Cover new shipping address already exist
        List<SelectOption> lstShipToLocation = ext.getShipToLocations();
        ext.selectedShipToLocation = lstShipToLocation[1].getValue();
        ext.shipToContactDetails();
        intMsgCount = ApexPages.getMessages().size();
        ext.selectedShipToLocation = '';
        ApexPages.currentPage().getParameters().put('autoCompShipToLoading', ext.shipStreet);
        ext.saveAddressOrder();
        system.assert(ApexPages.getMessages().size() == intMsgCount + 1, 'Should have ' + (intMsgCount + 1) + ': ' + ApexPages.getMessages());

        //Cover Edit Shipping Address
        ext.selectedShipToLocation = oContact.ShipTo_Location__c;
        ext.editShpAddressOrder();
        ext.shipCity = ext.vfOrder.ShippingCity + '222';
        ApexPages.currentPage().getParameters().put('autoCompShipToLoading', ext.shipStreet);
        ext.saveAddressOrder();   //*** success part for changing address within same country/province
        system.assertNotEquals([select Address__c from Location__c where Id = :oContact.ShipTo_Location__c][0].Address__c, oContact.BillTo_Location__r.Address__c);
        ApexPages.currentPage().getParameters().put('vatNumber','BE0400853488');
        ApexPages.currentPage().getParameters().put('autoCompShipToLoading','3042 vale');
        ext.vfOrder.ShipToContact_Name__c = null;
        ext.vfOrder.ShipToContact_Phone__c = null;
        ext.vfOrder.ShipToContact_Email__c = null;
        ext.shipStreet = null;
        ApexPages.currentPage().getParameters().put('autoCompShipToLoading', ext.shipStreet);
        ext.shipCity = null;
        ext.selectedShipCountryIsoCode = null;
        ext.listShippingState = new List<SelectOption>{new SelectOption('99', 'dummy')};
        ext.selectedShipStateIsoCode = null;
        ext.shipToZipCodeRequired = true;
        ext.shipZipCode = null;
        intMsgCount = ApexPages.getMessages().size();
        ext.saveAddressOrder();   //*** error part - be noticed that only error on attention is raised because others were in billing section
        system.assert(ApexPages.getMessages().size() == intMsgCount + 1, 'Should have ' + (intMsgCount + 1) + ': ' + ApexPages.getMessages());
        ext.vfOrder.ShipToContact_Name__c = 'test';
        ext.vfOrder.ShipToContact_Phone__c = '111-111-1111';
        ext.vfOrder.ShipToContact_Email__c = 'test@test.com';
        ext.shipStreet = '~~~ shipping street';
        ApexPages.currentPage().getParameters().put('autoCompShipToLoading', ext.shipStreet);
        ext.shipCity = '~~~ shipping city';
        ext.selectedShipCountryIsoCode = 'US';
        ext.vfOrder.ShippingStateCode__c = 'US-AK';
        ext.changeShipToCountryUsingLocation(true);
        ext.selectedShipStateIsoCode = 'US-AK';
        ext.shipToZipCodeRequired = false;
        ext.saveAddressOrder();   //*** success part for changing country/province but return error because have DML during test

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
        system.assertNotEquals(ext.listBillingState.size(), 0);

        //Cover the AutoComplete
        List<IECAddress__c> lstIECAddresses = [select id, Full_Address__c from IECAddress__c where Id = :oContact.BillTo_Location__r.Address__c];
        if(lstIECAddresses != null && lstIECAddresses.size() > 0){
            ext.fullAddress = lstIECAddresses[0].Full_Address__c;

            ext.listBillingState = new List<SelectOption>();
            ext.autoCompleteBillToAddresses();
            system.assertNotEquals(ext.listBillingState.size(), 0);

            ext.listShippingState = new List<SelectOption>();
            ext.autoCompleteShipToAddresses();
            system.assertNotEquals(ext.listShippingState.size(), 0);

            Order_Ext.getAddresses(lstIECAddresses[0].Full_Address__c);
        }
        
        //*** cover the rest of buildCountryStatePicklist
        Test.setCurrentPageReference(new PageReference('/apex/Order'));
        ext = new Order_Ext(new ApexPages.StandardController(ext.vfOrder));
        ext.pageLoad();

        Test.stopTest();

    } //*** end of "test_Order_Header"

    @isTest
    static void test_Order_Header2()
    {
        //-- Generate Test Data 
        generateAccountsContacts();
        TestDataGenerator.generatePaymentThreshold();
        locShipTo = TestDataGenerator.generateLocations('Ship To', locBillTo.Address__c, accounts[0].Id, sfContacts[2].Id, 'SH-' + String.valueOf(locBillTo.Address__c).right(5));
        insert new Apex_Setting__c(Name='Payment Terms for Bill me later', Text_1__c='0011,0016');

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
            ext.paymentType = 'Credit Card Deferred';
            ext.payOrder();
            //system.assert(ApexPages.getMessages().size() == 3 && ext.isPaying, 'Should be no other error: ' + ApexPages.getMessages());
        Test.stopTest();
            //*** cover payment type not allowed in "buildPaymentTypePicklist"
            update new OrderItem(Id=listOrderItem[0].Id, UnitPrice = 999999);
            ext.payOrder_Prepare();
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


	@isTest (SeeAllData=true)
	static void test_pageLoad_for_SAP_Partners()
	{
		//*** create lstAccount and contacts
		List<Account> lstAccount = TestDataGenerator.generateAccounts(1, true);
		List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 1, true);

		//*** create locations
		Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
		SAP_CustomerMaster_Mock.returnError = 'test';
		SAP_CustomerMaster_Mock.returnOK = null;
		List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
		Map<String, Location__c> mapLocation = new Map<String, Location__c>();
		mapLocation.put('sold1', new Location__c(Active__c = true, Type__c = 'Sold To', SAP_Id__c = null, Address__c = lstAddress[0].Id, Account__c = lstAccount[0].Id));
		mapLocation.put('bill1', new Location__c(Active__c = true, Type__c = 'Bill To', SAP_Id__c = null, Address__c = lstAddress[0].Id, Account__c = lstAccount[0].Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		mapLocation.put('ship1', new Location__c(Active__c = true, Type__c = 'Ship To', SAP_Id__c = null, Address__c = lstAddress[0].Id, Account__c = lstAccount[0].Id, Contact__c = lstContact[0].Id, Email__c = lstContact[0].Email, Phone__c = lstContact[0].Phone));
		insert mapLocation.values();

		//*** prepare correct structure
		lstContact[0].BillTo_Location__c = mapLocation.get('bill1').Id;
		lstContact[0].ShipTo_Location__c = mapLocation.get('ship1').Id;
		update lstContact[0];
		lstAccount[0].SoldTo_Location__c = mapLocation.get('sold1').Id;
		update lstAccount[0];

		//*** create orders
		List<Order> lstOrder = TestDataGenerator.generateOrder(1, lstAccount[0].Id, lstContact[0].Id, lstContact[0].Id, false);
		lstOrder[0].SoldTo_Location__c = mapLocation.get('sold1').Id;
		lstOrder[0].BillTo_Location__c = mapLocation.get('bill1').Id;
		lstOrder[0].ShipTo_Location__c = mapLocation.get('ship1').Id;
		insert lstOrder;

		Order_Ext ext;
		Integer errCount;
		Test.startTest();
			//*** error on creation of partners
			Test.setCurrentPageReference(new PageReference('/apex/Order?id=' + lstOrder[0].Id));
			ext = new Order_Ext(new ApexPages.StandardController(lstOrder[0]));
			errCount = ApexPages.getMessages().size();
			Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
			SAP_CustomerMaster_Mock.returnError = 'error';
			SAP_CustomerMaster_Mock.returnOK = null;
			ext.pageLoad();
			system.assert(ApexPages.getMessages().size() == errCount + 3, 'Should have ' + (errCount + 3) + ' messages: ' + ApexPages.getMessages());

			//*** success on creation of partners
			Test.setCurrentPageReference(new PageReference('/apex/Order?id=' + lstOrder[0].Id));
			ext = new Order_Ext(new ApexPages.StandardController(lstOrder[0]));
			Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
			SAP_CustomerMaster_Mock.returnError = null;
			SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'sold1', 'bill1', 'ship1'});
			ext.pageLoad();
			system.assert(3 == [select count() from Location__c where Account__c = :lstAccount[0].Id and SAP_Id__c != null], 'Locations should have SAP Id');

		Test.stopTest();
	} //*** end of "test_pageLoad_for_SAP_Partners"


	static testMethod void test_saveOrder()
	{
		//-- Generate Test Data 
		generateAccountsContacts(); 
		insert new Apex_Setting__c(Name='Quote Nb Days Valid', Number_1__c=10);

		Test.setCurrentPageReference(new PageReference('/apex/Order?retURL=' + Order.SObjectType.getDescribe().getKeyPrefix() + '&save_new=1&contactID=' + sfContacts[0].Id));
		Order_Ext ext = new Order_Ext(new ApexPages.StandardController(new Order()));
		ext.pageLoad();

		//*** missing/wrong information
		Integer errCount = ApexPages.getMessages().size(), locationCount;
		ext.vfOrder.AccountId = null;
		ext.vfOrder.BillTo_Location__c = null;
		ext.vfOrder.ShipTo_same_BillTo__c = false;
		ext.selectedShipToLocation = '';
		ext.vfOrder.ShipToAccount_Name__c = null;
		ext.vfOrder.ShipToContact_Name__c = null;
		ext.vfOrder.ShipToContact_Phone__c = null;
		ext.vfOrder.ShipToContact_Email__c = null;
		ext.saveOrder();
		system.assert(ApexPages.getMessages().size() == errCount + 1, 'Should have ' + (errCount + 1) + ' messages: ' + ApexPages.getMessages());
		ext.vfOrder.AccountId = accounts[0].Id;
		ext.vfOrder.BillToContactId = sfContacts[2].Id;
		ext.vfOrder.BillTo_Location__c = locBillTo.Id;
		ext.selectedShipToLocation = locBillTo.Id;
		ext.saveOrder();
		system.assert(ApexPages.getMessages().size() == errCount + 2, 'Should have ' + (errCount + 2) + ' messages: ' + ApexPages.getMessages());

		//*** success - billing is same as shipping and no ship to location
		ext.vfOrder.Type = 'Quote';
		ext.vfOrder.AccountId = accounts[0].Id;
		ext.vfOrder.BillToContactId = sfContacts[2].Id;
		ext.vfOrder.BillTo_Location__c = locBillTo.Id;
		ext.selectedShipToLocation = null;
		ext.vfOrder.ShipTo_same_BillTo__c = true;
		ext.vfOrder.BillToAccount_Name__c = 'account';
		ext.vfOrder.BillToContact_Name__c = 'contact';
		ext.vfOrder.BillToContact_Email__c = 'test@test.com';
		ext.vfOrder.BillToContact_Phone__c = '111-111-1111';
		ext.vfOrder.EffectiveDate = system.today();
		ext.vfOrder.Shipping_Instruction__c = 'special shipping';
		//*** skip locationCount and assert because error "Too many query rows" in production
		//locationCount = [select count() from Location__c];
		ext.saveOrder();
		//system.assert([select count() from Location__c] == locationCount + 1, 'Should have ' + (locationCount + 1) + ' locations: ' + ApexPages.getMessages());

		Test.startTest();
			//*** success - billing is same as shipping and have ship to location
			Test.setCurrentPageReference(new PageReference('/apex/Order?id=' + ext.vfOrder.Id + '&retURL=/' + Order.SObjectType.getDescribe().getKeyPrefix()));
			ext = new Order_Ext(new ApexPages.StandardController(ext.vfOrder));
			ext.pageLoad();
			Id idShipToLocation = ext.vfOrder.ShipTo_Location__c;
			ext.selectedShipStateIsoCode = null;
			ext.saveOrder();
			ext.vfOrder.ShipTo_Location__c = null;
			ext.saveOrder();

			//*** success - billing is different than shipping
			update new Account(Id=ext.vfOrder.AccountId, SoldTo_Location__c=null);
			ext.vfOrder.ShipTo_same_BillTo__c = false;
			ext.vfOrder.ShipTo_Location__c = idShipToLocation;
			ext.saveOrder();

			//*** generate exception
			ext.vfOrder.EffectiveDate = null;
			try { ext.saveOrder(); } catch (Exception e) {}

			//*** test methods "cancelOrder_Prepare" & "cancelOrder"
			ext.cancelOrder_Prepare();
			system.assert(ext.isCancelling, 'Wrong isCancelling');
			ext.vfOrder.EffectiveDate = system.today();
			ext.cancelOrder();  // nothing to assert for this method
		Test.stopTest();
	} //*** end of "test_saveOrder"


}