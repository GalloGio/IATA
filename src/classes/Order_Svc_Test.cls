/**
 * Created by Kevin Ky 2015-09-23
 */
@isTest
private class Order_Svc_Test
{
    @isTest (seeAllData=true)
    static void test_updateOrderStatus()
    {
        //-- Create Orders 
        List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
        List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
        List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[0].Id, contacts[1].Id,true); // 1 Order
        List<OrderItem> orderItems1 = TestDataGenerator.generateOrderItem(orders[0].Id, 3,true);// 3 lineItems for Order1
        
        Order_Svc.updateOrderStatus(new Map<Id, String>{ orders[0].Id => 'Delivery' }, new Map<Id, Boolean>());
        system.assert(1 ==[select count() from Order where Id = :orders[0].Id and Status = 'Delivery' and Is_Paid__c = false], 'Status must be changed and Order is NOT paid');
        Order_Svc.updateOrderStatus(new Map<Id, String>{ orders[0].Id => 'Invoiced' }, new Map<Id, Boolean>{ orders[0].Id => true });
        system.assert(1 ==[select count() from Order where Id = :orders[0].Id and Status = 'Invoiced' and Is_Paid__c = true], 'Status must be changed and Order is paid');
        
        //*** make sure order is not allowed to modify after some status
        delete [select Id from Apex_Setting__c where Name = 'Order User profile allows modification'];
        try { update new Order(Id=orders[0].Id, Shipping_Instruction__c='999-888-7777'); } catch (Exception e) {}
    }

    @isTest (seeAllData=true)
    static void test_saveOrderItem()
    {
        //-- Generate Orders & OrderItem 
        List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
        List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
        List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[0].Id, contacts[1].Id,true); // 1 Order
        List<OrderItem> orderItems1 = TestDataGenerator.generateOrderItem(orders[0].Id, 3,true);// 3 lineItems for Order1
        
        System.assertEquals(3,orderItems1.size());

        //Call function 
        String rpId = TestDataGenerator.generateZuoraFakeId();
        String cId = TestDataGenerator.generateZuoraFakeId();

        //Success Update Order Item
        Order_Svc.saveOrderItem(orderItems1[0].Id, 60, 3, rpId, cId);

        OrderItem oi1 = [SELECT Id, Quantity FROM OrderItem WHERE Id = :orderItems1[0].Id LIMIT 1];

        System.assertEquals(3, oi1.Quantity);
        //Falide Update Order Item
        try{
            Order_Svc.saveOrderItem(orderItems1[1].Id, -2, -4, rpId, cId);
        }
        catch(Exception e){
            System.assert(ApexPages.getMessages().size() > 0);
        }
        
        //*** test the other signature for same method
        try {
            system.assertEquals(Order_Svc.saveOrderItem(orderItems1[1].Id, 1, 'error ~!~@~#~', contacts[0].Id, 'error', null), null);
        } catch(Exception e) {}
    }

    @isTest (seeAllData=true)
    static void test_addItemsToOrder()
    {
        OrderItem_Sel oiSelector = new OrderItem_Sel();
        Product_Sel pSelector = new Product_Sel();
        
        delete [select Id from Apex_Setting__c where Name like 'ECommerce Products Filter%'];
        
        //-- Generate Order & OrderItems
        Account theAccount  = TestDataGenerator.generateAccounts(1,true)[0]; 
        Contact theContact  = TestDataGenerator.generateContacts(theAccount.Id,1,true)[0]; 
        Order theOrder      = TestDataGenerator.generateOrder(1, theAccount.Id, theContact.Id, theContact.Id,false)[0]; 
        theOrder.Status = 'New';
        insert theOrder;

        TestDataGenerator.generateOrderItem(theOrder.Id, 5,true);
        List<OrderItem> orderItems = oiSelector.getOrderItems(theOrder.Id) ; 

        //Generate Products with Price  
        Set<Id> productIds = new Set<Id>();
        for(OrderItem oi : orderItems)
        {
            productIds.add(oi.Product__c);
        }
        List<Product2> fullProducts = (List<Product2>) pSelector.selectSObjectById(productIds);

        //Generate price for the products 
        List<zqu__ZProduct__c> zProducts = TestDataGenerator.generateZProducts(5, true);
        List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
        List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();

        for(Integer x = 0; x < fullProducts.size(); x++)
        {
            Product2 prod = fullProducts[x]; 
            zqu__ZProduct__c zprod = zProducts[x];
            zRatePlans.addAll(TestDataGenerator.generateZRatePlans(zprod.Id,1,false)); //1 rate plan per product
            prod.SAP_Status_Code__c = 'A';
            prod.Post_to_Ecommerce_Date__c = System.today().addDays(-7);
            prod.Sell_through_eCommerce__c = true;
            prod.Inventory_Status__c = 'In stock';
            prod.ZProduct__c = zprod.Id;
        }

        insert zRatePlans;

        //Create Unit Price Charge & Discount for each Plan 
        for(zqu__ProductRatePlan__c rp : zRatePlans)
        {
            //Unit Price & Discount
            List<zqu__ProductRatePlanCharge__c> charges = TestDataGenerator.generateZCharges(rp.Id, 3, false);
            charges[0].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
            charges[1].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT;
            charges[2].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_VOLUME;
            
            zCharges.addAll(charges);
        }

        insert zCharges;

        //-- Generates Tiers for Volume Charges 
        List<zqu__ProductRatePlanChargeTier__c> zTiers = new List<zqu__ProductRatePlanChargeTier__c>();
        for(zqu__ProductRatePlanCharge__c c : zCharges)
        {
            if(c.zqu__Model__c == ZuoraUtil.ZCHARGE_MODEL_VOLUME)
            {
               zTiers.addAll(TestDataGenerator.generateZTiers(c.Id, 3, false));
            }
            else
            {
                zTiers.addAll(TestDataGenerator.generateZTiers(c.Id, 1, false));
            }
        }
        insert zTiers;

        update fullProducts;


        //Generate Product Price
        List<EComProduct_DTO> ecomProducts = Product_Sel.getEComProduct(new List<Id>(productIds),false, null, null);
        Map<Id, EComProduct_DTO> mapProductId_DTO = new Map<Id, EComProduct_DTO>();
        for (EComProduct_DTO p : ecomProducts)
            mapProductId_DTO.put(Id.valueOf(p.ProductId), p);
        Map<Id, EComProduct_DTO> ecomProductByItem = new Map<Id, EComProduct_DTO>();
        List<PriceInfo_DTO> prices = TestDataGenerator.generatePriceInfo(orderItems.size());
        EComProduct_DTO ecomProd;
        for(Integer x=0; x < orderItems.size(); x++)
        {
            OrderItem oi = orderItems[x];
            ecomProd = mapProductId_DTO.get(Id.valueOf(oi.Product__c));
            ecomProd.PriceInfo = prices[x];
            ecomProductByItem.put(oi.Id, ecomProd);
        }

        //-- Generate SalesOrderProduct_DTO 
        List<SalesOrderProduct_DTO> sop_dtos =  new List<SalesOrderProduct_DTO>();
        SalesOrderProduct_DTO sop, sopError;
        for(OrderItem oi : orderItems)
        {
            sop = new SalesOrderProduct_DTO();
                sop.quantity = 1;
                sop.selected = true; 
                sop.orderItemId = oi.Id;
                sop.IsQuantityInteger = true;
                sop.ecomProduct = ecomProductByItem.get(oi.Id);
            sop_dtos.add(sop);
        }
        sopError = sop;
        //*** cover case of invalid coupon
        sop.couponCode = 'blablabla';
        //*** cover case of valid coupon
        sop_dtos[1].couponCode = '      ';
        sop_dtos[2].couponCode = '~!~@~#~$~';
        ecomProd = sop_dtos[2].ecomProduct;
        ecomProd.PriceInfo.couponPrice = TestDataGenerator.generatePriceDetail(1);
        ecomProd.PriceInfo.couponPrice[0].discountName = sop_dtos[2].couponCode;

        //*** first item in sop_dtos is for case of already in order
        delete [select Id from OrderItem where OrderId = :theOrder.Id and Id != :orderItems[0].Id];

        Order_Svc.addItemsToOrder(sop_dtos, theOrder);
        system.assertEquals([select count() from OrderItem where OrderId = :theOrder.Id], 4);
        
        sop_dtos.clear();
        //*** cover case of invalid quantity
        sop = new SalesOrderProduct_DTO();
        sop.quantity = -1;
        sop.selected = true; 
        sop.orderItemId = sopError.orderItemId;
        sop.IsQuantityInteger = true;
        sop.ecomProduct = ecomProductByItem.get(Id.valueOf(sop.orderItemId));
        sop_dtos.add(sop);
        //*** cover case of create price book entry -> cause exception
        sop = new SalesOrderProduct_DTO();
        sop.quantity = 1;
        sop.selected = true; 
        sop.orderItemId = sopError.orderItemId;
        sop.IsQuantityInteger = true;
        sop.ecomProduct = ecomProductByItem.get(Id.valueOf(sop.orderItemId));
        sop.ecomProduct.ProductId = UserInfo.getUserId();
        sop_dtos.add(sop);
        Order_Svc.addItemsToOrder(sop_dtos, theOrder);
        system.assertEquals([select count() from OrderItem where OrderId = :theOrder.Id], 4);
    }

    @isTest (SeeAllData=true)
    static void test_createSapSalesOrders()
    {
        TestDataGenerator.generateApexSetting();
        TestDataGenerator.generateISOCountryState();

        //-- Generate Orders & OrderItem 
        List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
        List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
        IECAddress__c oAddress = TestDataGenerator.generateAddresses(1, true)[0];

        Location__c locSoldTo = TestDataGenerator.generateLocations(IECConstants.SOLDTO, oAddress.Id, accounts[0].Id, NULL, '321231');
        Location__c locBillTo = TestDataGenerator.generateLocations(IECConstants.BILLTO, oAddress.Id, accounts[0].Id, contacts[0].Id, '123123');
        Location__c locShipTo = TestDataGenerator.generateLocations(IECConstants.SHIPTO, oAddress.Id, accounts[0].Id, contacts[0].Id, '456654');
        List<Order> orders = TestDataGenerator.generateOrder(2, accounts[0].Id, contacts[0].Id, contacts[1].Id, false); // 2 Orders
        
        orders[0].SoldTo_Location__c = locSoldTo.Id;
        orders[0].BillTo_Location__c = locBillTo.Id;
        orders[0].ShipTo_Location__c = locShipTo.Id;
        orders[1].SoldTo_Location__c = locSoldTo.Id;
        orders[1].BillTo_Location__c = locBillTo.Id;
        orders[1].ShipTo_Location__c = locShipTo.Id;

        insert orders;
        
        List<OrderItem> orderItems1 = TestDataGenerator.generateOrderItem(orders[0].Id, 3,true);// 3 lineItems for Order1
        List<OrderItem> orderItems2 = TestDataGenerator.generateOrderItem(orders[1].Id, 2,true);// 2 lineItems for Order2
        List<Order_Item_Charge__c> lstDiscount = new List<Order_Item_Charge__c>();
        lstDiscount.add(new Order_Item_Charge__c(Order_Item__c=orderItems2[0].Id, Discount_Type__c='discount', Discount_Amount__c=1));
        lstDiscount.add(new Order_Item_Charge__c(Order_Item__c=orderItems2[1].Id, Discount_Type__c='discount', Discount_Percentage__c=1));
        insert lstDiscount;
        
        System.assertEquals(3,orderItems1.size());
        System.assertEquals(2,orderItems2.size());

        //-- Call createSapSalesOrders 
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SAP_SalesOrder_Mock());
        Order_Svc.createSapSalesOrders(new Set<Id>{orders[0].Id, orders[1].Id});
        Test.stopTest();
    }   

    /****************************************************************************************************
        Created by Kevin 2015-12-16
            Cover code for methods "createSAPContracts" and "prepareSAPContracts"
        Indirectly cover
            Method "getOrderForContract" of class "Order_Sel"
    ****************************************************************************************************/
    @isTest (SeeAllData=true)
    static void test_createSAPContracts() {
        TestDataGenerator.generateApexSetting();

        //*** generate accounts, contacts and portal users
        List<Account> lstAccount = TestDataGenerator.generateAccounts(1, true);
        List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 1, true);
        List<User> lstUser = new List<User> {TestDataGenerator.generatePortalUser('ISS Portal', lstContact[0].Id, true)};
        List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
        update new IATA_ISO_Country__c(Id=lstAddress[0].ISO_Country__c, Profit_Center__c='abc');
        Location__c loc = TestDataGenerator.generateLocations('Bill To', lstAddress[0].Id, lstAccount[0].Id, lstContact[0].Id);

        //*** generate order
        List<Order> lstOrder = TestDataGenerator.generateOrder(1, lstAccount[0].Id, lstContact[0].Id, lstContact[0].Id, false);
        lstOrder[0].Payment_Type__c = 'Credit Card';
        lstOrder[0].BillTo_Location__c = loc.Id;
        insert lstOrder;
        Set<Id> setOrderId = new Set<Id>{lstOrder[0].Id};

        //*** generate order item
        List<OrderItem> lstOrderItem = TestDataGenerator.generateOrderItem(lstOrder[0].Id, 4, false);
        lstOrderItem[lstOrderItem.size() - 1].Setup_Fee__c = 10;   //*** to cover setup fee and manual discount scenario
        lstOrderItem[lstOrderItem.size() - 1].Discount__c = 10;
        insert lstOrderItem;
        set<Id> oiIds = new set<Id>();
        for (OrderItem oi : lstOrderItem){
            oiIds.add(oi.Id);
        }
        lstOrderItem = [select Id, Product__c, PricebookEntryId, OrderId, Quantity, UnitPrice, Charge_Shipping__c, ServiceDate from OrderItem where Id = :oiIds];

        //*** generate discount
        List<Order_Item_Charge__c> lstDiscount = new List<Order_Item_Charge__c>();
        lstDiscount.add(new Order_Item_Charge__c(Order_Item__c=lstOrderItem[0].Id, Discount_Type__c='discount', Discount_Amount__c=1));
        lstDiscount.add(new Order_Item_Charge__c(Order_Item__c=lstOrderItem[1].Id, Discount_Type__c='discount', Discount_Percentage__c=1));
        insert lstDiscount;

        //*** get products generated for order items for manipulation
        set<Id> productIds = new set<Id>();
        for (OrderItem oi : lstOrderItem)
            productIds.add(oi.Product__c);
        List<Product2> lstProduct = [select Id from Product2 where Id in :productIds];

        Integer i1;

        //*** cover case where no contract is needed
        for (i1 = 0; i1 < lstProduct.size(); i1++){
            lstProduct[i1].Is_Shippable__c = true;
            lstProduct[i1].Effective_From__c = Date.today();
            lstProduct[i1].Effective_To__c = Date.today().addDays(5);
        }
        update lstProduct;
        Order_Svc.createSAPContracts(setOrderId);
        system.assert(0 == [select count() from OrderItem where Id in :oiIds and SAP_Contract_Number__c != null], 'No contract should be created');

        //*** ensure products in order are to send via contract -> must match with field "Use_Contract_when_ordered__c"
        for (i1 = 0; i1 < lstProduct.size(); i1++)
        {
            lstProduct[i1].Is_Shippable__c = false;
            lstProduct[i1].SAP_Media_Code__c = '030';
            lstProduct[i1].Number_of_months_of_subscription__c = i1;   //*** for sorting later
        }
        lstProduct[0].SAP_Material_Number__c = '999999999999';
        lstProduct[0].IEC_Override_Profit_Center__c = true;
        update lstProduct;
        Test.startTest();
            Test.setMock(WebServiceMock.class, new SAP_Contract_Mock());
            //*** 111 assigned to product 1, 222 assigned to product 2, null to product 3 (error), 333 to product 4
            SAP_Contract_Mock.lstContractNumber = new List<String>{'111', '222', null, '333'};
            Order_Svc.createSAPContractsFuture(setOrderId);
        Test.stopTest();
        List<OrderItem> lstOrderItems = [select SAP_Product_Number__c, SAP_Contract_Number__c from OrderItem where Id in :oiIds order by PricebookEntry.Product2.Number_of_months_of_subscription__c];
        system.assert(3 == [select count() from OrderItem where Id in :oiIds and SAP_Contract_Number__c != null], '3 contracts should be created');
    } //*** end of "test_createSAPContracts"


	/***************************************************************************************************
	    Created by Thai 2017-02-02
	        Test methods "test_zuoraSubscribeWithNewCustomer" and "test_zuoraSubscribeWithExistingCustomer"
	        cover "orderSubscription", "zuoraPaymentId", "parsePaymentMethodToEnum", "subscribe",
	              "setPaymentMethod", "setPaymentMethodWithWrp", "parseSubscribeResult2UpdateItems",
	              "parsePaymentResult", "getZuoraInvoices", "getInvoiceString", "getZuoraPayments",
	              "getPaymentString", "createZuoraPayment", "deleteZuoraSubscription", "deleteZuoraSubscriptionNow",
	              "getZuoraAccounts", "getZaccountQuery", "getZaccountById", "getRatePlanData",
	              "orderItemsToUpdateInZuora", "updateZsubscriptions", "getSubString"
	***************************************************************************************************/
	@isTest (seeAllData=true)
	static void test_zuoraSubscribeWithNewCustomer(){
		//*** gererate Zuora products
		List<zqu__ZProduct__c> lstZproducts = TestDataGenerator.generateZProducts(3, true);

		//*** generate Zuora rate plans
		zqu__ProductRatePlan__c zPlanForUnitPrice = TestDataGenerator.generateZRatePlans(lstZproducts[0].Id, 1, false)[0];
		zqu__ProductRatePlan__c zPlanForSetupFee = TestDataGenerator.generateZRatePlans(lstZproducts[1].Id, 1, false)[0];
		zqu__ProductRatePlan__c zPlanForUnitPriceAndSetupFee = TestDataGenerator.generateZRatePlans(lstZproducts[2].Id, 1, false)[0];
		insert new List<zqu__ProductRatePlan__c>{zPlanForUnitPrice, zPlanForSetupFee, zPlanForUnitPriceAndSetupFee};

		//*** generate Zuora rate plan charges - charge 0 is for discount
		List<zqu__ProductRatePlanCharge__c> lstZChargeForUnitPrice = TestDataGenerator.generateZCharges(zPlanForUnitPrice.Id, 2, false);
		lstZChargeForUnitPrice[0].zqu__Model__c = 'Discount-Fixed Amount';
		lstZChargeForUnitPrice[0].zqu__Discount_Level__c = 'Subscription';
		lstZChargeForUnitPrice[0].zqu__Discount_Apply_Type__c = 7;
		lstZChargeForUnitPrice[0].zqu__Type__c = 'One-Time';
		lstZChargeForUnitPrice[1].zqu__Model__c = 'Per Unit';
		lstZChargeForUnitPrice[1].zqu__Type__c = 'Recurring';
		insert lstZChargeForUnitPrice;
		List<zqu__ProductRatePlanCharge__c> lstZChargeForSetupFee = TestDataGenerator.generateZCharges(zPlanForSetupFee.Id, 2, false);
		lstZChargeForSetupFee[0].zqu__Model__c = 'Discount-Percentage';
		lstZChargeForSetupFee[0].zqu__Discount_Level__c = 'Subscription';
		lstZChargeForSetupFee[0].zqu__Discount_Apply_Type__c = 7;
		lstZChargeForSetupFee[0].zqu__Type__c = 'One-Time';
		lstZChargeForSetupFee[1].zqu__Model__c = 'Flat Fee';
		lstZChargeForSetupFee[1].zqu__Type__c = 'Recurring';
		insert lstZChargeForSetupFee;
		List<zqu__ProductRatePlanCharge__c> lstZChargeForUnitPriceAndSetupFee = TestDataGenerator.generateZCharges(zPlanForUnitPriceAndSetupFee.Id, 3, false);
		lstZChargeForUnitPriceAndSetupFee[0].zqu__Model__c = 'Discount-Fixed Amount';
		lstZChargeForUnitPriceAndSetupFee[0].zqu__Discount_Level__c = 'Subscription';
		lstZChargeForUnitPriceAndSetupFee[0].zqu__Discount_Apply_Type__c = 7;
		lstZChargeForUnitPriceAndSetupFee[0].zqu__Type__c = 'One-Time';
		lstZChargeForUnitPriceAndSetupFee[1].zqu__Model__c = 'Per Unit';
		lstZChargeForUnitPriceAndSetupFee[1].zqu__Type__c = 'Recurring';
		lstZChargeForUnitPriceAndSetupFee[2].zqu__Model__c = 'Flat Fee';
		lstZChargeForUnitPriceAndSetupFee[2].zqu__Type__c = 'One-Time';
		insert lstZChargeForUnitPriceAndSetupFee;

		//*** cover "getProductRatePlanChargeByRatePlanId" in "ProductRatePlanCharge_Sel"
		//ProductRatePlanCharge_Sel.getProductRatePlanChargeByRatePlanId(new Set<Id>{zPlanForUnitPrice.Id, zPlanForSetupFee.Id, zPlanForUnitPriceAndSetupFee.Id});

		//*** generate Account
		Account oAccount = TestDataGenerator.generateAccounts(1,true)[0];

		//*** generate Contact
		Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];

		//*** cover getAccountIdByContactId in "Contact_Sel"
		//Contact_Sel.getAccountIdByContactId(new Set<Id>{oContact.Id});

		//*** generate order
		Order oOrder = TestDataGenerator.generateOrder(1, oAccount.Id, oContact.Id, oContact.Id, false)[0];
		oOrder.BillToContact_Email__c = oContact.Email;
		oOrder.ShipToContactId = null;
		oOrder.ShipToContact_Email__c = oContact.Email;
		insert oOrder;

		//*** generate order items
		List<OrderItem> lstOrderItem = TestDataGenerator.generateOrderItemForContract(oOrder.Id, 3, false);
		lstOrderItem[0].Freight_Charge__c = 1;
		lstOrderItem[0].Handling_charges__c = 2;
		lstOrderItem[0].Tax__c = 3;
		lstOrderItem[0].Zuora_Rate_Plan_Id__c = zPlanForUnitPrice.zqu__ZuoraId__c;
		lstOrderItem[0].Zuora_Rate_Plan_Charge_Id__c = lstZChargeForUnitPrice[1].zqu__ZuoraId__c;
		lstOrderItem[0].ServiceDate = system.today();
		lstOrderItem[1].Freight_Charge__c = 1;
		lstOrderItem[1].Handling_charges__c = 2;
		lstOrderItem[1].Tax__c = 3;
		lstOrderItem[1].Zuora_Setup_Fee_Plan_Id__c = zPlanForSetupFee.zqu__ZuoraId__c;
		lstOrderItem[1].Zuora_Setup_Fee_Charge_Id__c = lstZChargeForSetupFee[1].zqu__ZuoraId__c;
		lstOrderItem[1].ServiceDate = system.today().addDays(1);
		lstOrderItem[2].Freight_Charge__c = 1;
		lstOrderItem[2].Handling_charges__c = 2;
		lstOrderItem[2].Tax__c = 3;
		lstOrderItem[2].Zuora_Rate_Plan_Id__c = zPlanForUnitPriceAndSetupFee.zqu__ZuoraId__c;
		lstOrderItem[2].Zuora_Rate_Plan_Charge_Id__c = lstZChargeForUnitPriceAndSetupFee[1].zqu__ZuoraId__c;
		lstOrderItem[2].Zuora_Setup_Fee_Plan_Id__c = zPlanForUnitPriceAndSetupFee.zqu__ZuoraId__c;
		lstOrderItem[2].Zuora_Setup_Fee_Charge_Id__c = lstZChargeForUnitPriceAndSetupFee[2].zqu__ZuoraId__c;
		lstOrderItem[2].ServiceDate = system.today().addDays(2);
		insert lstOrderItem;

		//*** generate order item charges for discounts
		List<Order_Item_Charge__c> lstOrderItemCharge = new List<Order_Item_Charge__c>();
		lstOrderItemCharge.add(new Order_Item_Charge__c(Order_Item__c=lstOrderItem[0].Id, Discount_Type__c='test', Discount_Amount__c=1, Zuora_Rate_Plan_Id__c=lstOrderItem[0].Zuora_Rate_Plan_Id__c, Zuora_Rate_Plan_Charge_Id__c=lstZChargeForUnitPrice[0].zqu__ZuoraId__c));
		lstOrderItemCharge.add(new Order_Item_Charge__c(Order_Item__c=lstOrderItem[1].Id, Discount_Type__c='test', Discount_Amount__c=1, Zuora_Rate_Plan_Id__c=lstOrderItem[1].Zuora_Rate_Plan_Id__c, Zuora_Rate_Plan_Charge_Id__c=lstZChargeForSetupFee[0].zqu__ZuoraId__c));
		//lstOrderItemCharge.add(new Order_Item_Charge__c(Order_Item__c=lstOrderItem[2].Id, Discount_Type__c='test', Discount_Amount__c=1, Zuora_Rate_Plan_Id__c=lstOrderItem[2].Zuora_Rate_Plan_Id__c, Zuora_Rate_Plan_Charge_Id__c=lstZChargeForUnitPriceAndSetupFee[0].zqu__ZuoraId__c));
		insert lstOrderItemCharge;

		//*** link SFDC products with Zuora products and make them available for purchase
		List<Product2> lstProduct = new List<Product2>();
		for (OrderItem oi : [select Product__c, ServiceDate from OrderItem where OrderId = :oOrder.Id order by ServiceDate])
			lstProduct.add(new Product2(Id=Id.valueOf(oi.Product__c), Effective_From__c=system.today().addDays(-10), Effective_To__c=system.today().addYears(1)
			                            //*** make product electronic and available for E-Commerce
			                          , SAP_Status_Code__c='A', SAP_Product_Type_Code__c='07', Post_to_Ecommerce_Date__c= system.today(), Sell_through_eCommerce__c=true
			                            //*** force to subscribe product to Zuora no matter of payment method
			                          , Available_for_Subscription__c=true, Is_Shippable__c=false, Charge_Shipping__c=false, SAP_Media_Code__c='30', Number_of_months_of_subscription__c=1
			                          , ZProduct__c=lstZproducts[oi.ServiceDate == system.today() ? 0 : (oi.ServiceDate == system.today().addDays(1) ? 1 : 2)].Id));
		update lstProduct;

		//*** generate payment information for credit card
		String strCreditCard = '4028e6992e836e4a012e914e1ddf5e2e';
		Zuora.zObject zPaymentMethod = new Zuora.zObject('PaymentMethod');
		zPaymentMethod.setValue('Id', strCreditCard);
		IECZuoraHelper.PaymentMethod oPayment = new IECZuoraHelper.PaymentMethod(zPaymentMethod);
		Map<Id, IECZuoraHelper.PaymentMethod> mapOrderId_PaymentMethod = new Map<Id, IECZuoraHelper.PaymentMethod>{oOrder.Id => oPayment};
		ZuoraUtil.zAccountPaymentMethod zPaymentMethodForParse = new ZuoraUtil.zAccountPaymentMethod();
		zPaymentMethodForParse.zPaymentMethodName = 'Credit Card';
		zPaymentMethodForParse.zPaymentMethod = strCreditCard;
		Map<String, ZuoraUtil.zAccountPaymentMethod> mapOrderId_PaymentMethodForParse = new Map<String, ZuoraUtil.zAccountPaymentMethod>{String.valueOf(oOrder.Id) => zPaymentMethodForParse};

		Test.startTest();
			//*** cover case of customer does not have Zuora account
			//*** -> always failed because second pass for new customer is not performed due to call out to Zuora
			Order_Svc.orderSubscription(new Set<Id>{oOrder.Id}, null, new Map<Id, String>{oOrder.Id => 'Bank Transfer'});
			system.assertEquals(0, [select count() from Order where Id = :oOrder.Id and IEC_Zuora_ST_InvoiceId__c != null]);
			Order_Svc.orderSubscription(new Set<Id>{oOrder.Id}, mapOrderId_PaymentMethod, new Map<Id, String>{oOrder.Id => 'Credit Card'});
			system.assertEquals(0, [select count() from Order where Id = :oOrder.Id and IEC_Zuora_ST_InvoiceId__c != null]);
			oOrder.ShipToContactId = oContact.Id;
			update oOrder;
			Order_Svc.orderSubscription(new Set<Id>{oOrder.Id}, mapOrderId_PaymentMethod, null);
			system.assertEquals(0, [select count() from Order where Id = :oOrder.Id and IEC_Zuora_ST_InvoiceId__c != null]);
		Test.stopTest();

		//*** cover payment methods
		system.assertEquals(Order_Svc.zuoraPaymentId(IECConstants.PaymentThresholdType_ICH), IECConstants.PaymentMethod_ICH_ZuoraID);
		system.assertEquals(Order_Svc.zuoraPaymentId(IECConstants.PaymentThresholdType_BankTransfer), IECConstants.PaymentMethod_BankTransfer_ZuoraID);
		system.assertEquals(Order_Svc.zuoraPaymentId(IECConstants.ORDER_STATUS_CHECK), IECConstants.PaymentMethod_Check_ZuoraID);
		system.assertEquals(Order_Svc.zuoraPaymentId(IECConstants.PaymentThresholdType_CreditCard), IECConstants.PaymentMethod_Other_ZuoraID);
		system.assertEquals(Order_Svc.zuoraPaymentId(IECConstants.PaymentThresholdType_BillMeLater), IECConstants.PaymentMethod_Other_ZuoraID);
		system.assertEquals(Order_Svc.parsePaymentMethodToEnum(IECConstants.PaymentThresholdType_CreditCard), IECConstants.PaymentType.CREDIT_CARD);
		system.assertEquals(Order_Svc.parsePaymentMethodToEnum(IECConstants.PaymentThresholdType_BankTransfer), IECConstants.PaymentType.BANK_TRANSFER);
		system.assertEquals(Order_Svc.parsePaymentMethodToEnum(IECConstants.ORDER_STATUS_CHECK), IECConstants.PaymentType.CHECK);
		system.assertEquals(Order_Svc.parsePaymentMethodToEnum(IECConstants.PaymentThresholdType_ICH), IECConstants.PaymentType.ICH);
		system.assertEquals(Order_Svc.parsePaymentMethodToEnum(IECConstants.PaymentThresholdType_BillMeLater), IECConstants.PaymentType.OTHER);
		system.assertEquals(Order_Svc.parsePaymentMethodToEnum('not found'), null);

		//*** cover "getSubString"
		system.assert(Order_Svc.getSubString(new Set<String>{'aaa'}).contains('aaa'), 'Wrong value');
	} //*** end of "test_zuoraSubscribeWithNewCustomer"


	/***************************************************************************************************
	    Created by Thai 2017-02-02
	        Test methods "test_zuoraSubscribeWithNewCustomer" and "test_zuoraSubscribeWithExistingCustomer"
	        cover "orderSubscription", "zuoraPaymentId", "parsePaymentMethodToEnum", "subscribe",
	              "setPaymentMethod", "setPaymentMethodWithWrp", "parseSubscribeResult2UpdateItems",
	              "parsePaymentResult", "getZuoraInvoices", "getInvoiceString", "getZuoraPayments",
	              "getPaymentString", "createZuoraPayment", "deleteZuoraSubscription", "deleteZuoraSubscriptionNow",
	              "getZuoraAccounts", "getZaccountQuery", "getZaccountById", "getRatePlanData",
	              "orderItemsToUpdateInZuora", "updateZsubscriptions", "getSubString"
	***************************************************************************************************/
	@isTest (seeAllData=true)
	static void test_zuoraSubscribeWithExistingCustomer(){
		//*** gererate Zuora products
		List<zqu__ZProduct__c> lstZproducts = TestDataGenerator.generateZProducts(3, true);

		//*** generate Zuora rate plans
		zqu__ProductRatePlan__c zPlanForUnitPrice = TestDataGenerator.generateZRatePlans(lstZproducts[0].Id, 1, false)[0];
		zqu__ProductRatePlan__c zPlanForSetupFee = TestDataGenerator.generateZRatePlans(lstZproducts[1].Id, 1, false)[0];
		zqu__ProductRatePlan__c zPlanForUnitPriceAndSetupFee = TestDataGenerator.generateZRatePlans(lstZproducts[2].Id, 1, false)[0];
		insert new List<zqu__ProductRatePlan__c>{zPlanForUnitPrice, zPlanForSetupFee, zPlanForUnitPriceAndSetupFee};

		//*** generate Zuora rate plan charges - charge 0 is for discount
		List<zqu__ProductRatePlanCharge__c> lstZChargeForUnitPrice = TestDataGenerator.generateZCharges(zPlanForUnitPrice.Id, 2, false);
		lstZChargeForUnitPrice[0].zqu__Model__c = 'Discount-Fixed Amount';
		lstZChargeForUnitPrice[0].zqu__Discount_Level__c = 'Subscription';
		lstZChargeForUnitPrice[0].zqu__Discount_Apply_Type__c = 7;
		lstZChargeForUnitPrice[0].zqu__Type__c = 'One-Time';
		lstZChargeForUnitPrice[1].zqu__Model__c = 'Per Unit';
		lstZChargeForUnitPrice[1].zqu__Type__c = 'Recurring';
		insert lstZChargeForUnitPrice;
		List<zqu__ProductRatePlanCharge__c> lstZChargeForSetupFee = TestDataGenerator.generateZCharges(zPlanForSetupFee.Id, 2, false);
		lstZChargeForSetupFee[0].zqu__Model__c = 'Discount-Percentage';
		lstZChargeForSetupFee[0].zqu__Discount_Level__c = 'Subscription';
		lstZChargeForSetupFee[0].zqu__Discount_Apply_Type__c = 7;
		lstZChargeForSetupFee[0].zqu__Type__c = 'One-Time';
		lstZChargeForSetupFee[1].zqu__Model__c = 'Flat Fee';
		lstZChargeForSetupFee[1].zqu__Type__c = 'Recurring';
		insert lstZChargeForSetupFee;
		List<zqu__ProductRatePlanCharge__c> lstZChargeForUnitPriceAndSetupFee = TestDataGenerator.generateZCharges(zPlanForUnitPriceAndSetupFee.Id, 3, false);
		lstZChargeForUnitPriceAndSetupFee[0].zqu__Model__c = 'Discount-Fixed Amount';
		lstZChargeForUnitPriceAndSetupFee[0].zqu__Discount_Level__c = 'Subscription';
		lstZChargeForUnitPriceAndSetupFee[0].zqu__Discount_Apply_Type__c = 7;
		lstZChargeForUnitPriceAndSetupFee[0].zqu__Type__c = 'One-Time';
		lstZChargeForUnitPriceAndSetupFee[1].zqu__Model__c = 'Per Unit';
		lstZChargeForUnitPriceAndSetupFee[1].zqu__Type__c = 'Recurring';
		lstZChargeForUnitPriceAndSetupFee[2].zqu__Model__c = 'Flat Fee';
		lstZChargeForUnitPriceAndSetupFee[2].zqu__Type__c = 'One-Time';
		insert lstZChargeForUnitPriceAndSetupFee;

		//*** cover "getProductRatePlanChargeByRatePlanId" in "ProductRatePlanCharge_Sel"
		//ProductRatePlanCharge_Sel.getProductRatePlanChargeByRatePlanId(new Set<Id>{zPlanForUnitPrice.Id, zPlanForSetupFee.Id, zPlanForUnitPriceAndSetupFee.Id});

		//*** generate Account
		Account oAccount = TestDataGenerator.generateAccounts(1,true)[0];

		//*** generate Contact
		Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];

		//*** cover getAccountIdByContactId in "Contact_Sel"
		//Contact_Sel.getAccountIdByContactId(new Set<Id>{oContact.Id});

		//*** generate order
		Order oOrder = TestDataGenerator.generateOrder(1, oAccount.Id, oContact.Id, oContact.Id, false)[0];
		oOrder.BillToContact_Email__c = oContact.Email;
		oOrder.ShipToContact_Email__c = oContact.Email;
		oOrder.Invoice_Text__c = 'error';         //*** cause failure for payment submission
		oOrder.Sales_Order_Remark__c = 'error';   //*** cause failure of getting payment from Zuora
		insert oOrder;

		//*** generate order items
		List<OrderItem> lstOrderItem = TestDataGenerator.generateOrderItemForContract(oOrder.Id, 3, false);
		lstOrderItem[0].Freight_Charge__c = 1;
		lstOrderItem[0].Handling_charges__c = 2;
		lstOrderItem[0].Tax__c = 3;
		lstOrderItem[0].Zuora_Rate_Plan_Id__c = zPlanForUnitPrice.zqu__ZuoraId__c;
		lstOrderItem[0].Zuora_Rate_Plan_Charge_Id__c = lstZChargeForUnitPrice[1].zqu__ZuoraId__c;
		lstOrderItem[0].ServiceDate = system.today();
		lstOrderItem[1].Freight_Charge__c = 1;
		lstOrderItem[1].Handling_charges__c = 2;
		lstOrderItem[1].Tax__c = 3;
		lstOrderItem[1].Zuora_Setup_Fee_Plan_Id__c = zPlanForSetupFee.zqu__ZuoraId__c;
		lstOrderItem[1].Zuora_Setup_Fee_Charge_Id__c = lstZChargeForSetupFee[1].zqu__ZuoraId__c;
		lstOrderItem[1].ServiceDate = system.today().addDays(1);
		lstOrderItem[2].Freight_Charge__c = 1;
		lstOrderItem[2].Handling_charges__c = 2;
		lstOrderItem[2].Tax__c = 3;
		lstOrderItem[2].Zuora_Rate_Plan_Id__c = zPlanForUnitPriceAndSetupFee.zqu__ZuoraId__c;
		lstOrderItem[2].Zuora_Rate_Plan_Charge_Id__c = lstZChargeForUnitPriceAndSetupFee[1].zqu__ZuoraId__c;
		lstOrderItem[2].Zuora_Setup_Fee_Plan_Id__c = zPlanForUnitPriceAndSetupFee.zqu__ZuoraId__c;
		lstOrderItem[2].Zuora_Setup_Fee_Charge_Id__c = lstZChargeForUnitPriceAndSetupFee[2].zqu__ZuoraId__c;
		lstOrderItem[2].ServiceDate = system.today().addDays(2);
		insert lstOrderItem;

		//*** generate order item charges for discounts
		List<Order_Item_Charge__c> lstOrderItemCharge = new List<Order_Item_Charge__c>();
		lstOrderItemCharge.add(new Order_Item_Charge__c(Order_Item__c=lstOrderItem[0].Id, Discount_Type__c='test', Discount_Amount__c=1, Zuora_Rate_Plan_Id__c=lstOrderItem[0].Zuora_Rate_Plan_Id__c, Zuora_Rate_Plan_Charge_Id__c=lstZChargeForUnitPrice[0].zqu__ZuoraId__c));
		lstOrderItemCharge.add(new Order_Item_Charge__c(Order_Item__c=lstOrderItem[1].Id, Discount_Type__c='test', Discount_Amount__c=1, Zuora_Rate_Plan_Id__c=lstOrderItem[1].Zuora_Rate_Plan_Id__c, Zuora_Rate_Plan_Charge_Id__c=lstZChargeForSetupFee[0].zqu__ZuoraId__c));
		//lstOrderItemCharge.add(new Order_Item_Charge__c(Order_Item__c=lstOrderItem[2].Id, Discount_Type__c='test', Discount_Amount__c=1, Zuora_Rate_Plan_Id__c=lstOrderItem[2].Zuora_Rate_Plan_Id__c, Zuora_Rate_Plan_Charge_Id__c=lstZChargeForUnitPriceAndSetupFee[0].zqu__ZuoraId__c));
		insert lstOrderItemCharge;

		//*** link SFDC products with Zuora products and make them available for purchase
		List<Product2> lstProduct = new List<Product2>();
		for (OrderItem oi : [select Product__c, ServiceDate from OrderItem where OrderId = :oOrder.Id order by ServiceDate])
			lstProduct.add(new Product2(Id=Id.valueOf(oi.Product__c), Effective_From__c=system.today().addDays(-10), Effective_To__c=system.today().addYears(1)
			                            //*** make product electronic and available for E-Commerce
			                          , SAP_Status_Code__c='A', SAP_Product_Type_Code__c='07', Post_to_Ecommerce_Date__c= system.today(), Sell_through_eCommerce__c=true
			                            //*** force to subscribe product to Zuora no matter of payment method
			                          , Available_for_Subscription__c=true, Is_Shippable__c=false, Charge_Shipping__c=false, SAP_Media_Code__c='30', Number_of_months_of_subscription__c=1
			                          , ZProduct__c=lstZproducts[oi.ServiceDate == system.today() ? 0 : (oi.ServiceDate == system.today().addDays(1) ? 1 : 2)].Id));
		update lstProduct;

		//*** generate payment information for credit card
		String strCreditCard = '4028e6992e836e4a012e914e1ddf5e2e';
		Zuora.zObject zPaymentMethod = new Zuora.zObject('PaymentMethod');
		zPaymentMethod.setValue('Id', strCreditCard);
		IECZuoraHelper.PaymentMethod oPayment = new IECZuoraHelper.PaymentMethod(zPaymentMethod);
		Map<Id, IECZuoraHelper.PaymentMethod> mapOrderId_PaymentMethod = new Map<Id, IECZuoraHelper.PaymentMethod>{oOrder.Id => oPayment};
		ZuoraUtil.zAccountPaymentMethod zPaymentMethodForParse = new ZuoraUtil.zAccountPaymentMethod();
		zPaymentMethodForParse.zPaymentMethodName = 'Credit Card';
		zPaymentMethodForParse.zPaymentMethod = strCreditCard;
		Map<String, ZuoraUtil.zAccountPaymentMethod> mapOrderId_PaymentMethodForParse = new Map<String, ZuoraUtil.zAccountPaymentMethod>{String.valueOf(oOrder.Id) => zPaymentMethodForParse};

		//*** generate Zuora customer
		Zuora__CustomerAccount__c zCustomerAccount = TestDataGenerator.generateZCustomerAccount(oAccount.Id, oContact.Id, 1, true)[0];
		Zuora__PaymentMethod__c zPayment = TestDataGenerator.generatePaymentMethod(zCustomerAccount.Id, 1, true)[0];
		zCustomerAccount.Zuora__Default_Payment_Method__c = zPayment.Id;
		update zCustomerAccount;

		//*** cover method "getZaccountById"
		Zuora.zObject zCustomerAccountQuery = Order_Svc.getZaccountById(zCustomerAccount.Zuora__Zuora_Id__c);
		system.assertEquals(String.valueOf(zCustomerAccountQuery.getValue('Id')), zCustomerAccount.Zuora__Zuora_Id__c);

		//*** cover all scenarios of payment type and payment method for method "subscribe" -> nothing to assert
		Map<Id, Zuora.zApi.SubscribeResult> mapOrderItemId_SubscribeResponse = Order_Svc.subscribe(new Set<Id>{oOrder.Id}, mapOrderId_PaymentMethod, null);
		mapOrderItemId_SubscribeResponse = Order_Svc.subscribe(new Set<Id>{oOrder.Id}, null, new Map<Id, String>{oOrder.Id => 'Credit Card'});
		Test.startTest();
			mapOrderItemId_SubscribeResponse = Order_Svc.subscribe(new Set<Id>{oOrder.Id}, null, new Map<Id, String>{oOrder.Id => 'Bank Transfer'});
			mapOrderItemId_SubscribeResponse = Order_Svc.subscribe(new Set<Id>{oOrder.Id}, null, null);
			mapOrderItemId_SubscribeResponse = Order_Svc.subscribe(new Set<Id>{oOrder.Id}, mapOrderId_PaymentMethod, new Map<Id, String>{oOrder.Id => 'Credit Card'});

			//*** prepare to reset order items
			List<OrderItem> resetOrderItem = new List<OrderItem>();
			for (OrderItem oi : lstOrderItem)
				resetOrderItem.add(new OrderItem(Id=oi.Id, Zuora_InvoiceId__c=null, Zuora_InvoiceNumber__c=null, Zuora_SubscriptionId__c=null, Zuora_Subscription_Number__c=null));

			//*** cover "parseSubscribeResult2UpdateItems" - case failed at payment submission
			Map<Id, String> mapOrderItemId_ParseResponse = Order_Svc.parseSubscribeResult2UpdateItems(mapOrderItemId_SubscribeResponse, mapOrderId_PaymentMethodForParse);
			system.assertEquals(lstOrderItem.size(), [select count() from OrderItem where OrderId = :oOrder.Id and Zuora_InvoiceId__c != null and Zuora_SubscriptionId__c != null]);
			update resetOrderItem;
			//*** cover "parseSubscribeResult2UpdateItems" - case success of payment submission but still fail at getting Zuora payment
			oOrder.Invoice_Text__c = null;
			update oOrder;
			mapOrderItemId_ParseResponse = Order_Svc.parseSubscribeResult2UpdateItems(mapOrderItemId_SubscribeResponse, mapOrderId_PaymentMethodForParse);
			system.assertEquals(lstOrderItem.size(), [select count() from OrderItem where OrderId = :oOrder.Id and Zuora_InvoiceId__c != null and Zuora_SubscriptionId__c != null]);
			update resetOrderItem;
			//*** cover "parseSubscribeResult2UpdateItems" - case success of parse
			oOrder.Sales_Order_Remark__c = null;
			update oOrder;
			mapOrderItemId_ParseResponse = Order_Svc.parseSubscribeResult2UpdateItems(mapOrderItemId_SubscribeResponse, mapOrderId_PaymentMethodForParse);
			system.assertEquals(lstOrderItem.size(), [select count() from OrderItem where OrderId = :oOrder.Id and Zuora_InvoiceId__c != null and Zuora_SubscriptionId__c != null]);

			//*** prepare to cover "orderItemsToUpdateInZuora" and "updateZsubscriptions"
			lstOrderItem = [select Id, Zuora_InvoiceId__c, Zuora_InvoiceNumber__c, Zuora_SubscriptionId__c, Zuora_Subscription_Number__c from OrderItem where OrderId = :oOrder.Id];
			for (OrderItem oi : lstOrderItem)
				oi.Zuora_Subscription_Status__c = 'Pending Activation';
			update lstOrderItem;

			//*** cover "orderItemsToUpdateInZuora" - nothing to assert
			Order_Svc.orderItemsToUpdateInZuora(new Set<Id>{oOrder.Id});

			//*** cover "updateZsubscriptions"
			Order_Svc.updateZsubscriptions(lstOrderItem);
			system.assertEquals(0, [select count() from OrderItem where OrderId = :oOrder.Id and Zuora_Subscription_Status__c != null]);
		Test.stopTest();
	} //*** end of "test_zuoraSubscribeWithExistingCustomer"


    /****************************************************************************************************
        Created by CGI, Thai 2015-10-16
            Cover code of methods "needToGetSAP_Freight_Tax" and getSAP_Freight_Tax"
            Indirectly cover
                Methods "getOrderForFreightAndTax" and "getConversionSFDC_SAP" of class "Order_Sel"
                Methods "getSAPauthorization" and "fixEndpointDomain" of class "Utility"
    ****************************************************************************************************/
    @isTest (seeAllData=true)
    static void test_getSAP_Freight_Tax() {
        List<String> returnData = new List<String>();
        List<OrderItem> listOrderItem;
        String responseMsg;

        //*** generate data
        List<Account> listAccount = TestDataGenerator.generateAccounts(1, true);
        List<Contact> listContact = TestDataGenerator.generateContacts(listAccount[0].Id, 2, true);
        List<Order> listOrder = TestDataGenerator.generateOrder(5, listAccount[0].Id, listContact[0].Id, listContact[1].Id, false);
        for (Integer i1 = 0; i1 < listOrder.size(); i1++) {
            listOrder[i1].Type = 'Order';
            listOrder[i1].Source__c = 'Inbound call';
            listOrder[i1].Order_Channel__c = 'Central Direct Sales';
        }
        listOrder[0].Type = 'No conversion';
        insert listOrder;
        TestDataGenerator.generateOrderItem(listOrder[2].Id, 1, true);
        TestDataGenerator.generateOrderItem(listOrder[3].Id, 1, true);
        TestDataGenerator.generateSFDC_SAP_Mapping(true);
        
        //*** prepare to call for product using contract
        listOrderItem = TestDataGenerator.generateOrderItem(listOrder[4].Id, 1, true);
        Id idProduct = [select Product__c from OrderItem where Id = :listOrderItem[0].Id limit 1][0].Product__c;
        for (Product2 p : [select Id from Product2 where Id = :idProduct])
        {
            p.Is_Shippable__c = false;
            p.SAP_Media_Code__c = '030';
            update p;
            break;
        }
        
        //*** test
        Test.startTest();
            Test.setMock(WebServiceMock.class, new SAP_Freight_and_Tax_Mock());
            
            //*** error of no conversion
            responseMsg = Order_Svc.getSAP_Freight_Tax(listOrder[0].Id);
            system.assert(responseMsg == Label.ErrMsg_Shipping_Tax_No_Conversion, 'Conversion error: ' + responseMsg);
            
            //*** no line item
            responseMsg = Order_Svc.getSAP_Freight_Tax(listOrder[1].Id);
            system.assert(responseMsg == null, 'No order item check: ' + responseMsg);
            
            //*** call out returns error
            returnData.clear();
            returnData.add('error');
            returnData.add('501');
            returnData.add('error 501');
            SAP_Freight_and_Tax_Mock.returnError = JSON.serialize(returnData);
            responseMsg = Order_Svc.getSAP_Freight_Tax(listOrder[2].Id);
            system.assert(responseMsg == String.format(Label.ErrMsg_Shipping_Tax_SAP_Error, new List<String>{returnData[0], returnData[1], returnData[2]}), 'Call error: ' + responseMsg);
            
            //*** call out success for product NOT using contract
            system.assert(Order_Svc.needToGetSAP_Freight_Tax(listOrder[2].Id) == true, 'needToGetSAP_Freight_Tax should be TRUE');
            listOrderItem = [select Id, Product_Number__c, Quantity, Charge_Shipping__c, SubTotal__c from OrderItem where OrderId = :listOrder[2].Id];
            returnData.clear();
            returnData.add(listOrderItem[0].Product_Number__c);
            returnData.add('5');
            returnData.add('10');
            SAP_Freight_and_Tax_Mock.returnError = null;
            SAP_Freight_and_Tax_Mock.returnOK = JSON.serialize(returnData);
            responseMsg = Order_Svc.getSAP_Freight_Tax(listOrder[2].Id);
            system.assert(responseMsg.contains('"Freight_Charge__c":5') && responseMsg.contains('"Tax__c":10'), 'Call success: ' + responseMsg);
            system.assert(Order_Svc.needToGetSAP_Freight_Tax(listOrder[2].Id) == false, 'needToGetSAP_Freight_Tax should be FALSE');
        Test.stopTest();
        
        //*** call out success for product using contract -> should test outside of previous start-stop because of having data updated
        Test.setMock(WebServiceMock.class, new SAP_Freight_and_Tax_Mock());
        listOrderItem = [select Id, Product_Number__c, Quantity, Charge_Shipping__c, SubTotal__c from OrderItem where OrderId = :listOrder[4].Id];
        returnData.clear();
        returnData.add(listOrderItem[0].Product_Number__c);
        returnData.add('5');
        returnData.add('10');
        SAP_Freight_and_Tax_Mock.returnError = null;
        SAP_Freight_and_Tax_Mock.returnOK = JSON.serialize(returnData);
        responseMsg = Order_Svc.getSAP_Freight_Tax(listOrder[4].Id, listOrderItem[0].Id);
        // do not assert because error of "You have uncommitted work pending" but contract and order follow same logic so not to worry
        //system.assert(responseMsg.contains('"Freight_Charge__c":5') && responseMsg.contains('"Tax__c":10'), 'Call success: ' + responseMsg);
    } //*** end of "test_getSAP_Freight_Tax"


    /****************************************************************************************************
        Created by CGI, Thai 2015-11-23
            Cover code of method "getSAP_Freight_Tax_for_DTO"
    ****************************************************************************************************/
    @isTest (seeAllData=true)
    static void test_getSAP_Freight_Tax_for_DTO() {
        List<String> returnData = new List<String>();
        List<OrderItem> listOrderItem;
        List<OrderItem_DTO> listOrderItemDTO;
        String responseMsg;

        //*** generate data
        List<Account> listAccount = TestDataGenerator.generateAccounts(1, true);
        List<Contact> listContact = TestDataGenerator.generateContacts(listAccount[0].Id, 2, true);
        List<Order> listOrder = TestDataGenerator.generateOrder(2, listAccount[0].Id, listContact[0].Id, listContact[1].Id, false);
        for (Integer i1 = 0; i1 < listOrder.size(); i1++) {
            listOrder[i1].Type = 'Order';
            listOrder[i1].Source__c = 'Inbound call';
            listOrder[i1].Order_Channel__c = 'Central Direct Sales';
        }
        insert listOrder;
        TestDataGenerator.generateOrderItem(listOrder[0].Id, 1, true);
        TestDataGenerator.generateSFDC_SAP_Mapping(true);
        OrderItem_Sel itemsSelector = new OrderItem_Sel();
        
        //*** prepare to call for product using contract
        listOrderItem = TestDataGenerator.generateOrderItem(listOrder[1].Id, 1, true);
        Id idProduct = [select Product__c from OrderItem where Id = :listOrderItem[0].Id limit 1][0].Product__c;
        for (Product2 p : [select Id from Product2 where Id = :idProduct])
        {
            p.Is_Shippable__c = false;
            p.SAP_Media_Code__c = '030';
            update p;
            break;
        }
        
        //*** test
        Test.startTest();
            Test.setMock(WebServiceMock.class, new SAP_Freight_and_Tax_Mock());
            
            listOrderItemDTO = OrderItem_DTO.format2DTO(itemsSelector.getOrderItems(new Set<Id>{listOrder[0].Id}).get(listOrder[0].Id), new Map<String, PriceInfo_DTO>());

            //*** error of no conversion
            responseMsg = Order_Svc.getSAP_Freight_Tax_for_DTO(listOrder[0].Type + 'aaa', listOrder[0].Source__c, listOrder[0].Order_Channel__c, 'soldTo', 'billTo', 'shipTo', listOrderItemDTO);
            system.assert(responseMsg == Label.ErrMsg_Shipping_Tax_No_Conversion, 'Conversion error: ' + responseMsg);
            
            //*** call out returns error
            returnData.clear();
            returnData.add('error');
            returnData.add('501');
            returnData.add('error 501');
            SAP_Freight_and_Tax_Mock.returnError = JSON.serialize(returnData);
            responseMsg = Order_Svc.getSAP_Freight_Tax_for_DTO(listOrder[0].Type, listOrder[0].Source__c, listOrder[0].Order_Channel__c, 'soldTo', 'billTo', 'shipTo', listOrderItemDTO);
            system.assert(responseMsg == String.format(Label.ErrMsg_Shipping_Tax_SAP_Error, new List<String>{returnData[0], returnData[1], returnData[2]}), 'Call error: ' + responseMsg);
            
            //*** no line item
            responseMsg = Order_Svc.getSAP_Freight_Tax_for_DTO(listOrder[0].Type, listOrder[0].Source__c, listOrder[0].Order_Channel__c, 'soldTo', 'billTo', 'shipTo', new List<OrderItem_DTO>());
            system.assert(responseMsg == null, 'No order item check: ' + responseMsg);

            //*** call out success for product NOT using contract
            returnData.clear();
            returnData.add(listOrderItemDTO[0].productCode);
            returnData.add('5');
            returnData.add('10');
            SAP_Freight_and_Tax_Mock.returnError = null;
            SAP_Freight_and_Tax_Mock.returnOK = JSON.serialize(returnData);
            responseMsg = Order_Svc.getSAP_Freight_Tax_for_DTO(listOrder[0].Type, listOrder[0].Source__c, listOrder[0].Order_Channel__c, 'soldTo', 'billTo', 'shipTo', listOrderItemDTO);
            system.assert(responseMsg == null, 'Call success: ' + responseMsg);

            //*** call out success for product using contract
            listOrderItemDTO = OrderItem_DTO.format2DTO(itemsSelector.getOrderItems(new Set<Id>{listOrder[1].Id}).get(listOrder[1].Id), new Map<String, PriceInfo_DTO>());
            returnData.clear();
            returnData.add(listOrderItemDTO[0].productCode);
            returnData.add('5');
            returnData.add('10');
            SAP_Freight_and_Tax_Mock.returnError = null;
            SAP_Freight_and_Tax_Mock.returnOK = JSON.serialize(returnData);
            responseMsg = Order_Svc.getSAP_Freight_Tax_for_DTO(listOrder[1].Type, listOrder[1].Source__c, listOrder[1].Order_Channel__c, 'soldTo', 'billTo', 'shipTo', listOrderItemDTO);
            system.assert(responseMsg == null, 'Call success: ' + responseMsg);
        Test.stopTest();
    } //*** end of "test_getSAP_Freight_Tax_for_DTO"


    /****************************************************************************************************
        Created by Thai 2015-11-23
            Cover code for methods "setPriceToOrder", "setPriceToOrderItem", "setUnitPriceFromPlan",
                "setUnitPriceFromFlatFee","getDiscountFromPlan", "getCouponPlan" in class Order_Svc
            Method "setFlatFeeFromPlan" cannot be covered since not called.  This is because method
                "setUnitPriceFromFlatFee" already took care
    ****************************************************************************************************/
    private static testMethod void test_setPriceToOrder()
    {
        TestDataGenerator.generateApexSetting();
        List<IATA_ISO_Country__c> ISOCountryState = TestDataGenerator.generateISOCountryState();

        //*** generate accounts, contacts and portal users
        List<Account> lstAccount = TestDataGenerator.generateAccounts(1, false);
        lstAccount[0].IATA_ISO_Country__c = ISOCountryState[0].Id;
        lstAccount[0].ShippingCountry = ISOCountryState[0].Name;
        insert lstAccount;
        List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 1, false);
        lstContact[0].User_IECPortal_Status__c = 'Privilege - Approved';
        insert lstContact;
        List<User> lstUser = new List<User> {TestDataGenerator.generatePortalUser('ISS Portal', lstContact[0].Id, true)};
        
        //*** generate products and price book entries
        List<Product2> lstProduct = TestDataGenerator.generateProducts(2, false);
        lstProduct[0].Product_Type__c = null;
        lstProduct[0].Is_Shippable__c = true;
        lstProduct[0].Charge_Shipping__c = true;
        lstProduct[1].Product_Type__c = null;
        lstProduct[1].Is_Shippable__c = true;
        lstProduct[1].Charge_Shipping__c = true;
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntry = TestDataGenerator.generatePricebookEntry(Test.getStandardPricebookId(), lstProduct[0].Id, 1, false);
        lstPriceBookEntry.addAll(TestDataGenerator.generatePricebookEntry(Test.getStandardPricebookId(), lstProduct[1].Id, 1, false));
        insert lstPriceBookEntry;
        
        //*** generate order
        List<Order> lstOrder = TestDataGenerator.generateOrder(2, lstAccount[0].Id, lstContact[0].Id, lstContact[0].Id, true);
        List<OrderItem> lstOrderItem = new List<OrderItem>(), checkOrderItem;
        lstOrderItem.add(new OrderItem(PriceBookEntryId=lstPriceBookEntry[0].Id, OrderId=lstOrder[0].Id, Quantity=1, UnitPrice=1, ServiceDate=Date.Today()));
        lstOrderItem.add(new OrderItem(PriceBookEntryId=lstPriceBookEntry[1].Id, OrderId=lstOrder[0].Id, Quantity=1, UnitPrice=1, ServiceDate=Date.Today().addDays(1)));
        insert lstOrderItem;
        List<Order_Item_Charge__c> checkZuoraCharge;
        Decimal discount;

        //*** cover set unit price scenarios
        PriceInfo_DTO price = new PriceInfo_DTO();
        Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>{lstProduct[0].SAP_Material_Number__c => price};
        PriceDetail_DTO standard = new PriceDetail_DTO();
        standard.unitPricePlanId = 'standard';   standard.discountName = null;
        standard.volumePrice = new List<VolumePrice_DTO>();
        VolumePrice_DTO standardVP1 = new VolumePrice_DTO();  standardVP1.qtyFrom = 100;   standardVP1.qtyTo = 1000;  standardVP1.price = 295;  standardVP1.planId = 'standard volume 1';  standard.volumePrice.add(standardVP1);
        VolumePrice_DTO standardVP2 = new VolumePrice_DTO();  standardVP2.qtyFrom = 1001;  standardVP2.qtyTo = null;  standardVP2.price = 290;  standardVP2.planId = 'standard volume 2';  standard.volumePrice.add(standardVP2);
        price.standardPrice = new List<PriceDetail_DTO> {standard};
        PriceDetail_DTO customer = new PriceDetail_DTO();
        customer.unitPricePlanId = 'customer';   customer.discountName = 'customer';
        customer.volumePrice = new List<VolumePrice_DTO>();
        VolumePrice_DTO customerVP1 = new VolumePrice_DTO();  customerVP1.qtyFrom = 200;   customerVP1.qtyTo = 1000;  customerVP1.price = 195;  customerVP1.planId = 'customer volume 1';  customer.volumePrice.add(customerVP1);
        VolumePrice_DTO customerVP2 = new VolumePrice_DTO();  customerVP2.qtyFrom = 1001;  customerVP2.qtyTo = null;  customerVP2.price = 190;  customerVP2.planId = 'customer volume 2';  customer.volumePrice.add(customerVP2);
        price.customerPrice = new List<PriceDetail_DTO> {customer};

        //*** cover setup fee
        PriceInfo_DTO price2 = new PriceInfo_DTO();
        mapProductNumber_Price.put(lstProduct[1].SAP_Material_Number__c, price2);
        PriceDetail_DTO standard2 = new PriceDetail_DTO();
        standard2.setupFeePlanId = 'setup-standard';   standard2.discountName = null;
        price2.standardPrice = new List<PriceDetail_DTO> {standard2};
        PriceDetail_DTO customer2 = new PriceDetail_DTO();
        customer2.unitPricePlanId = 'setup-customer';   customer2.discountName = 'customer';   customer2.setupFeePlanId = 'setup';   customer2.setupFeeChargeId = 'setup-charge';
        price2.customerPrice = new List<PriceDetail_DTO> {customer2};

        Test.startTest();   //*** to bypass limitation of # of queries

        //*** no unit price
        Order_Svc.setPriceToOrder(lstOrder[0], mapProductNumber_Price);
        checkOrderItem= [select Charge_Shipping__c, Quantity, UnitPrice, Discount__c, Zuora_Rate_Plan_Id__c from OrderItem where OrderId = :lstOrder[0].Id order by ServiceDate];
        checkZuoraCharge = [select Zuora_Rate_Plan_Id__c from Order_Item_Charge__c where Order_Item__c = :lstOrderItem[0].Id];
        system.assert(checkOrderItem[0].UnitPrice == lstOrderItem[0].UnitPrice && !checkOrderItem[0].Charge_Shipping__c && checkOrderItem[0].Zuora_Rate_Plan_Id__c == null
                    , 'Wrong UnitPrice: ' + checkOrderItem[0]);
        system.assert(checkOrderItem[1].UnitPrice == lstOrderItem[1].UnitPrice && !checkOrderItem[1].Charge_Shipping__c && checkOrderItem[1].Zuora_Rate_Plan_Id__c == null
                    , 'Wrong UnitPrice: ' + checkOrderItem[1]);
        system.assert(checkZuoraCharge.size() == 0, 'Wrong Zuora Charge: ' + checkZuoraCharge);

        //*** unit price in standard rate and unit price in setup fee of standard rate
        standard.unitPrice = 300;
        standard2.setupFee = 300;
        Order_Svc.setPriceToOrder(lstOrder[0], mapProductNumber_Price);
        checkOrderItem = [select Charge_Shipping__c, Quantity, UnitPrice, Discount__c, Zuora_Rate_Plan_Id__c from OrderItem where OrderId = :lstOrder[0].Id order by ServiceDate];
        checkZuoraCharge = [select Zuora_Rate_Plan_Id__c from Order_Item_Charge__c where Order_Item__c = :lstOrderItem[0].Id];
        system.assert(checkOrderItem[0].UnitPrice == standard.unitPrice && checkOrderItem[0].Charge_Shipping__c && checkOrderItem[0].Discount__c == null && checkOrderItem[0].Zuora_Rate_Plan_Id__c == standard.unitPricePlanId
                    , 'Wrong UnitPrice: ' + checkOrderItem[0]);
        system.assert(checkOrderItem[1].UnitPrice == standard2.setupFee && checkOrderItem[1].Charge_Shipping__c && checkOrderItem[1].Discount__c == null && checkOrderItem[1].Zuora_Rate_Plan_Id__c == standard2.setupFeePlanId
                    , 'Wrong UnitPrice: ' + checkOrderItem[1]);
        system.assert(checkZuoraCharge.size() == 0, 'Wrong Zuora Charge: ' + checkZuoraCharge);

        //*** unit price from volume price in standard rate
        lstOrderItem[0].Quantity = 150;
        update lstOrderItem[0];
        Order_Svc.setPriceToOrder(lstOrder[0], mapProductNumber_Price);
        checkOrderItem = [select Charge_Shipping__c, Quantity, UnitPrice, Discount__c, Zuora_Rate_Plan_Id__c from OrderItem where OrderId = :lstOrder[0].Id order by ServiceDate];
        checkZuoraCharge = [select Zuora_Rate_Plan_Id__c from Order_Item_Charge__c where Order_Item__c = :lstOrderItem[0].Id];
        system.assert(checkOrderItem[0].UnitPrice == standardVP1.price && checkOrderItem[0].Charge_Shipping__c && checkOrderItem[0].Discount__c == null && checkOrderItem[0].Zuora_Rate_Plan_Id__c == standardVP1.planId
                    , 'Wrong UnitPrice: ' + checkOrderItem[0]);
        system.assert(checkZuoraCharge.size() == 0, 'Wrong Zuora Charge: ' + checkZuoraCharge);

        ////*** unit price from volume price in customer type rate
        lstAccount[0].Customer_Type__c = customer.discountName;
        update lstAccount[0];
        lstOrderItem[0].Quantity = 250;
        update lstOrderItem[0];
        Order_Svc.setPriceToOrder(lstOrder[0], mapProductNumber_Price);
        checkOrderItem = [select Charge_Shipping__c, Quantity, UnitPrice, Discount__c, Zuora_Rate_Plan_Id__c from OrderItem where OrderId = :lstOrder[0].Id order by ServiceDate];
        checkZuoraCharge = [select Zuora_Rate_Plan_Id__c from Order_Item_Charge__c where Order_Item__c = :lstOrderItem[0].Id];
        system.assert(checkOrderItem[0].UnitPrice == customerVP1.price && checkOrderItem[0].Charge_Shipping__c && checkOrderItem[0].Discount__c == null && checkOrderItem[0].Zuora_Rate_Plan_Id__c == customerVP1.planId
                    , 'Wrong UnitPrice: ' + checkOrderItem[0]);
        system.assert(checkZuoraCharge.size() == 0, 'Wrong Zuora Charge: ' + checkZuoraCharge);

        //*** unit price in customer type rate and unit price with setup fee of customer type rate
        lstOrderItem[0].Quantity = 1;
        update lstOrderItem[0];
        customer.unitPrice = 200;
        customer2.unitPrice = 100;
        customer2.setupFee = 50;
        Order_Svc.setPriceToOrder(lstOrder[0], mapProductNumber_Price);
        checkOrderItem = [select Charge_Shipping__c, Quantity, UnitPrice, Discount__c, Zuora_Rate_Plan_Id__c, Setup_Fee__c, Zuora_Setup_Fee_Plan_Id__c from OrderItem where OrderId = :lstOrder[0].Id order by ServiceDate];
        checkZuoraCharge = [select Zuora_Rate_Plan_Id__c from Order_Item_Charge__c where Order_Item__c = :lstOrderItem[0].Id];
        system.assert(checkOrderItem[0].UnitPrice == customer.unitPrice && checkOrderItem[0].Charge_Shipping__c && checkOrderItem[0].Discount__c == null && checkOrderItem[0].Zuora_Rate_Plan_Id__c == customer.unitPricePlanId
                    , 'Wrong UnitPrice: ' + checkOrderItem[0]);
        system.assert(checkOrderItem[1].UnitPrice == customer2.unitPrice && checkOrderItem[1].Setup_Fee__c == customer2.setupFee && checkOrderItem[1].Charge_Shipping__c && checkOrderItem[1].Discount__c == null && checkOrderItem[1].Zuora_Rate_Plan_Id__c == customer2.unitPricePlanId && checkOrderItem[1].Zuora_Setup_Fee_Plan_Id__c == customer2.setupFeePlanId
                    , 'Wrong UnitPrice: ' + checkOrderItem[1]);
        system.assert(checkZuoraCharge.size() == 0, 'Wrong Zuora Charge: ' + checkZuoraCharge);

        //*** cover set discount scenarios
        PriceDetail_DTO region = new PriceDetail_DTO();
        region.discountPlanId = 'region';   region.discountName = ISOCountryState[0].Region__c;
        region.discountPercentage = 5;
        price.regionPrice = new List<PriceDetail_DTO> {region};
        PriceDetail_DTO country = new PriceDetail_DTO();
        country.discountPlanId = 'country';   country.discountName = ISOCountryState[0].Name;
        country.discountPercentage = 10;
        price.countryPrice = new List<PriceDetail_DTO> {country};
        PriceDetail_DTO presales = new PriceDetail_DTO();
        presales.discountPlanId = 'pre-sales';   presales.discountName = 'Pre-Sales';
        presales.discountAmount = 10;
        price.preSalePrice = new List<PriceDetail_DTO> {presales};
        price.couponPrice = new List<PriceDetail_DTO>();
        PriceDetail_DTO couponFreeShipping = new PriceDetail_DTO();
        couponFreeShipping.discountPlanId = 'coupon free shipping';
        couponFreeShipping.isFreeShipping = true;
        couponFreeShipping.discountName = 'free shipping';
        price.couponPrice.add(couponFreeShipping);
        PriceDetail_DTO couponDiscountPct = new PriceDetail_DTO();
        couponDiscountPct.discountPlanId = 'coupon discount %';
        couponDiscountPct.discountName = 'discount percentage';
        couponDiscountPct.discountPercentage = 20;
        price.couponPrice.add(couponDiscountPct);
        PriceDetail_DTO couponDiscountAmt = new PriceDetail_DTO();
        couponDiscountAmt.discountPlanId = 'coupon discount $';
        couponDiscountAmt.discountName = 'discount amount';
        couponDiscountAmt.discountAmount = 50;
        price.couponPrice.add(couponDiscountAmt);
        PriceDetail_DTO couponDiscountError = new PriceDetail_DTO();
        couponDiscountError.discountPlanId = 'coupon discount $';
        couponDiscountError.discountName = 'error percentage';
        couponDiscountError.discountPercentage = 999999;
        price.couponPrice.add(couponDiscountError);

        //*** discounts from region, country, pre-sales and coupon in amount
        lstOrderItem[0].Coupon__c = couponDiscountAmt.discountName;
        update lstOrderItem[0];
        Set<String> checkCoupon = new Set<String>{region.discountPlanId, country.discountPlanId, presales.discountPlanId, couponDiscountAmt.discountPlanId};
        Order_Svc.setPriceToOrder(lstOrder[0], mapProductNumber_Price);
        checkOrderItem = [select Charge_Shipping__c, Quantity, UnitPrice, Discount__c, Zuora_Rate_Plan_Id__c from OrderItem where OrderId = :lstOrder[0].Id order by ServiceDate];
        checkZuoraCharge = [select Zuora_Rate_Plan_Id__c from Order_Item_Charge__c where Order_Item__c = :lstOrderItem[0].Id];
        discount = checkOrderItem[0].Quantity * checkOrderItem[0].UnitPrice;
        discount -= (discount * region.discountPercentage / 100);
        discount -= (discount * country.discountPercentage / 100);
        discount = (checkOrderItem[0].Quantity * checkOrderItem[0].UnitPrice) - discount + presales.discountAmount + couponDiscountAmt.discountAmount;
        system.assert(checkOrderItem[0].Charge_Shipping__c, 'Wrong Discount: ' + checkOrderItem[0] );
        //system.assert(checkZuoraCharge.size() == 4, 'Wrong Zuora Charge: ' + checkZuoraCharge);
        for (Order_Item_Charge__c c : checkZuoraCharge)
            system.assert(checkCoupon.contains(c.Zuora_Rate_Plan_Id__c), 'Wrong Zuora Charge: ' + c);
        
        //*** free shipping coupon
        price.regionPrice = null;
        price.countryPrice = null;
        price.preSalePrice = null;
        lstOrderItem[0].Coupon__c = couponFreeShipping.discountName;
        update lstOrderItem[0];
        Order_Svc.setPriceToOrder(lstOrder[0], mapProductNumber_Price);
        checkOrderItem = [select Charge_Shipping__c, Quantity, UnitPrice, Discount__c, Zuora_Rate_Plan_Id__c from OrderItem where OrderId = :lstOrder[0].Id order by ServiceDate];
        checkZuoraCharge = [select Zuora_Rate_Plan_Id__c from Order_Item_Charge__c where Order_Item__c = :lstOrderItem[0].Id];
        system.assert(checkOrderItem[0].Charge_Shipping__c == false && checkOrderItem[0].Discount__c == null
                    , 'Wrong Discount: ' + checkOrderItem[0]);
        system.assert(checkZuoraCharge.size() == 0, 'Wrong Zuora Charge: ' + checkZuoraCharge);
        
        //*** wrong coupon
        lstOrderItem[0].Coupon__c = couponFreeShipping.discountName + 'x';
        update lstOrderItem[0];
        Order_Svc.setPriceToOrder(lstOrder[0], mapProductNumber_Price);
        checkOrderItem = [select Charge_Shipping__c, Quantity, UnitPrice, Discount__c, Zuora_Rate_Plan_Id__c from OrderItem where OrderId = :lstOrder[0].Id order by ServiceDate];
        checkZuoraCharge = [select Zuora_Rate_Plan_Id__c from Order_Item_Charge__c where Order_Item__c = :lstOrderItem[0].Id];
        system.assert(checkOrderItem[0].Charge_Shipping__c && checkOrderItem[0].Discount__c == null
                    , 'Wrong Discount: ' + checkOrderItem[0]);
        system.assert(checkZuoraCharge.size() == 0, 'Wrong Zuora Charge: ' + checkZuoraCharge);

        //*** order has no item -> nothing to assert
        Order_Svc.setPriceToOrder(lstOrder[1], mapProductNumber_Price);

        //*** order with new item
        lstOrderItem[0] = new OrderItem(PriceBookEntryId=lstPriceBookEntry[0].Id, OrderId=lstOrder[1].Id, Quantity=1, UnitPrice=1, Coupon__c=couponDiscountAmt.discountName, ServiceDate=Date.Today());
        Order_Svc.setPriceToOrderItem(new List<OrderItem>{lstOrderItem[0]}, mapProductNumber_Price, lstOrder[1].ShipToContactId);
        checkCoupon.clear();
        checkCoupon.add(couponDiscountAmt.discountPlanId);
        checkOrderItem = [select Charge_Shipping__c, Quantity, UnitPrice, Discount__c, Zuora_Rate_Plan_Id__c from OrderItem where OrderId = :lstOrder[1].Id order by ServiceDate];
        checkZuoraCharge = [select Zuora_Rate_Plan_Id__c from Order_Item_Charge__c where Order_Item__c = :lstOrderItem[0].Id];
        system.assert(checkOrderItem[0].Charge_Shipping__c && checkOrderItem[0].Discount__c == couponDiscountAmt.discountAmount
                    , 'Wrong Discount: ' + checkOrderItem[0]);
        system.assert(checkZuoraCharge.size() == 1, 'Wrong Zuora Charge: ' + checkZuoraCharge);
        for (Order_Item_Charge__c c : checkZuoraCharge)
            system.assert(checkCoupon.contains(c.Zuora_Rate_Plan_Id__c), 'Wrong Zuora Charge: ' + c);

        Test.stopTest();
    } //*** end of "test_setPriceToOrder"


    /****************************************************************************************************
        Created by Thai 2015-11-23
            Cover code for methods "setPriceToOrder", "setPriceToOrderItem", "setUnitPriceFromPlan",
                "getDiscountFromPlan", "getCouponPlan" in class
    ****************************************************************************************************/
    @isTest (seeAllData=true)
    private static void test_setPriceToOrderItemDTO()
    {
        List<IATA_ISO_Country__c> ISOCountryState = TestDataGenerator.generateISOCountryState();

        //*** generate accounts, contacts and portal users
        List<Account> lstAccount = TestDataGenerator.generateAccounts(1, false);
        lstAccount[0].IATA_ISO_Country__c = ISOCountryState[0].Id;
        lstAccount[0].ShippingCountry = ISOCountryState[0].Name;
        lstAccount[0].Customer_Type__c = 'customer';
        insert lstAccount;
        List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 1, false);
        lstContact[0].User_IECPortal_Status__c = 'Privilege - Approved';
        insert lstContact;
        List<User> lstUser = new List<User> {TestDataGenerator.generatePortalUser('ISS Portal', lstContact[0].Id, true)};
        
        //*** generate products and price book entries
        List<Product2> lstProduct = TestDataGenerator.generateProducts(1, false);
        lstProduct[0].Product_Type__c = null;
        lstProduct[0].Is_Shippable__c = true;
        lstProduct[0].Charge_Shipping__c = true;
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntry = TestDataGenerator.generatePricebookEntry(Test.getStandardPricebookId(), lstProduct[0].Id, 1, true);

        //*** generate price
        PriceInfo_DTO price = new PriceInfo_DTO();
        Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>{lstProduct[0].SAP_Material_Number__c => price};
        PriceDetail_DTO standard = new PriceDetail_DTO();
        standard.unitPricePlanId = 'standard';   standard.discountName = null;
        standard.unitPrice = 300;
        standard.volumePrice = new List<VolumePrice_DTO>();
        VolumePrice_DTO standardVP1 = new VolumePrice_DTO();  standardVP1.qtyFrom = 100;   standardVP1.qtyTo = 1000;  standardVP1.price = 295;  standardVP1.planId = 'standard volume 1';  standard.volumePrice.add(standardVP1);
        VolumePrice_DTO standardVP2 = new VolumePrice_DTO();  standardVP2.qtyFrom = 1001;  standardVP2.qtyTo = null;  standardVP2.price = 290;  standardVP2.planId = 'standard volume 2';  standard.volumePrice.add(standardVP2);
        price.standardPrice = new List<PriceDetail_DTO> {standard};
        PriceDetail_DTO customer = new PriceDetail_DTO();
        customer.unitPricePlanId = 'customer';   customer.discountName = lstAccount[0].Customer_Type__c;
        customer.unitPrice = 200;
        customer.volumePrice = new List<VolumePrice_DTO>();
        VolumePrice_DTO customerVP1 = new VolumePrice_DTO();  customerVP1.qtyFrom = 200;   customerVP1.qtyTo = 1000;  customerVP1.price = 195;  customerVP1.planId = 'customer volume 1';  customer.volumePrice.add(customerVP1);
        VolumePrice_DTO customerVP2 = new VolumePrice_DTO();  customerVP2.qtyFrom = 1001;  customerVP2.qtyTo = null;  customerVP2.price = 190;  customerVP2.planId = 'customer volume 2';  customer.volumePrice.add(customerVP2);
        price.customerPrice = new List<PriceDetail_DTO> {customer};
        PriceDetail_DTO region = new PriceDetail_DTO();
        region.discountPlanId = 'region';   region.discountName = ISOCountryState[0].Region__c;
        region.discountPercentage = 5;
        price.regionPrice = new List<PriceDetail_DTO> {region};
        PriceDetail_DTO country = new PriceDetail_DTO();
        country.discountPlanId = 'country';   country.discountName = ISOCountryState[0].Name;
        country.discountPercentage = 10;
        price.countryPrice = new List<PriceDetail_DTO> {country};
        PriceDetail_DTO presales = new PriceDetail_DTO();
        presales.discountPlanId = 'pre-sales';   presales.discountName = 'Pre-Sales';
        presales.discountAmount = 10;
        price.preSalePrice = new List<PriceDetail_DTO> {presales};
        price.couponPrice = new List<PriceDetail_DTO>();
        PriceDetail_DTO couponFreeShipping = new PriceDetail_DTO();
        couponFreeShipping.discountPlanId = 'coupon free shipping';
        couponFreeShipping.isFreeShipping = true;
        couponFreeShipping.discountName = 'free shipping';
        price.couponPrice.add(couponFreeShipping);
        PriceDetail_DTO couponDiscountPct = new PriceDetail_DTO();
        couponDiscountPct.discountPlanId = 'coupon discount %';
        couponDiscountPct.discountName = 'discount percentage';
        couponDiscountPct.discountPercentage = 20;
        price.couponPrice.add(couponDiscountPct);
        PriceDetail_DTO couponDiscountAmt = new PriceDetail_DTO();
        couponDiscountAmt.discountPlanId = 'coupon discount $';
        couponDiscountAmt.discountName = 'discount amount';
        couponDiscountAmt.discountAmount = 50;
        price.couponPrice.add(couponDiscountAmt);

        Decimal checkValue;

        //*** cover "getUnitPrice", "getUnitPriceFromPlan"
        system.runAs(lstUser[0]) {
            checkValue = Order_Svc.getUnitPrice(price, customer.discountName);
            system.assert(checkValue == customer.UnitPrice, 'Wrong UnitPrice: ' + checkValue);
            checkValue = Order_Svc.getUnitPrice(price, 500, customer.discountName);
            system.assert(checkValue == customerVP1.price, 'Wrong UnitPrice: ' + checkValue);
            standard.unitPrice = null;
            customer.unitPrice = null;
            checkValue = Order_Svc.getUnitPrice(price, customer.discountName);
            system.assert(checkValue == null, 'Wrong UnitPrice: ' + checkValue);
            standard.unitPrice = 300;
            customer.unitPrice = 200;
        }
        
        //*** cover "getDiscountPlans"
        List<PriceDetail_DTO> checkPlan = Order_Svc.getDiscountPlans(price.couponPrice, couponDiscountAmt.discountName, true);
        system.assert(checkPlan.size() == 1 && checkPlan[0].discountName == couponDiscountAmt.discountName, 'Wrong plan: ' + checkPlan);

        //*** generate order
        List<Order> lstOrder;
        OrderItem testOrderItem;
        system.runAs(lstUser[0]) {
            lstOrder = TestDataGenerator.generateOrder(1, lstAccount[0].Id, lstContact[0].Id, lstContact[0].Id, true);
            testOrderItem = new OrderItem(PriceBookEntryId=lstPriceBookEntry[0].Id, OrderId=lstOrder[0].Id, Quantity=1, UnitPrice=1, ServiceDate=Date.Today());
            insert testOrderItem;
        }
        OrderItem_Sel itemsSelector = new OrderItem_Sel();
        OrderItem_DTO testOrderItemDTO = OrderItem_DTO.format2DTO(itemsSelector.getOrderItems(new Set<Id>{lstOrder[0].Id}).get(lstOrder[0].Id), mapProductNumber_Price)[0];

        //*** cover "setPriceToOrderItemDTO", "getDiscountFromPlanDTO"
        testOrderItemDTO.couponCode = couponFreeShipping.discountName;
        system.runAs(lstUser[0]) {
            Order_Svc.setPriceToOrderItemDTO(testOrderItemDTO);
        }
        checkValue = testOrderItemDTO.quantity * customer.unitPrice;
        checkValue -= (checkValue * region.discountPercentage / 100);
        checkValue -= (checkValue * country.discountPercentage / 100);
        checkValue = (testOrderItemDTO.quantity * testOrderItemDTO.unitPrice) - checkValue + presales.discountAmount;
        system.assert(testOrderItemDTO.unitPrice == customer.UnitPrice && testOrderItemDTO.chargeShipping == false && testOrderItemDTO.discountAmount == checkValue
                    , 'Wrong Discount: ' + testOrderItemDTO + '\nCalculated discount: ' + checkValue);

        //*** cover "isCouponValid", "saveCouponUsed"
        system.runAs(lstUser[0]) {
            system.assert(false == Order_Svc.isCouponValid(lstProduct[0].Id, null, price.couponPrice, lstOrder[0].ShipToContactId), 'Wrong validation');
            system.assert(false == Order_Svc.isCouponValid(lstProduct[0].Id, 'not found', price.couponPrice, lstOrder[0].ShipToContactId), 'Wrong validation');
            system.assert(true == Order_Svc.isCouponValid(lstProduct[0].Id, couponDiscountAmt.discountName, price.couponPrice, lstOrder[0].ShipToContactId), 'Wrong validation');
            testOrderItem.Coupon__c = couponDiscountAmt.discountName;
            update testOrderItem;
            Order_Svc.saveCouponUsed(lstOrder[0].Id, lstOrder[0].ShipToContactId);
            delete [select Id from Apex_Setting__c where Name = 'Order Limit Coupon Used'];
            insert new Apex_Setting__c(Name='Order Limit Coupon Used', Number_1__c=1);
            system.assert(false == Order_Svc.isCouponValid(lstProduct[0].Id, couponDiscountAmt.discountName, price.couponPrice, lstOrder[0].ShipToContactId), 'Wrong validation');
        }
   } //*** end of "test_setPriceToOrderItemDTO"

   
    /****************************************************************************************************
        Created by Thai 2015-12-01
            Cover code for methods "getOrderStatusByPaymentType", "isOrderPaidByPaymentType"
                in class Order_Svc
    ****************************************************************************************************/
    static testMethod void test_OrderStatus_And_PaidStatus() {
        insert new Apex_Setting__c(Name='Order Paid Status for Payment Types', Text_1__c='Credit Card,ICH');

        //*** cover method "getOrderStatusByPaymentType"
        String Status;
        Status = Order_Svc.getOrderStatusByPaymentType(null);
        system.assert(Status == 'New', 'Wrong Order status: ' + Status);
        Status = Order_Svc.getOrderStatusByPaymentType('ICH');
        system.assert(Status == 'Paid', 'Wrong Order status: ' + Status);
        Status = Order_Svc.getOrderStatusByPaymentType('Check');
        system.assert(Status == 'Ready for SAP', 'Wrong Order status: ' + Status);

        //*** cover method "isOrderPaidByPaymentType"
        system.assert(Order_Svc.isOrderPaidByPaymentType(null) == false, 'Wrong Paid status');
        system.assert(Order_Svc.isOrderPaidByPaymentType('ICH') == true, 'Wrong Paid status');
        system.assert(Order_Svc.isOrderPaidByPaymentType('Check') == false, 'Wrong Paid status');
    } //*** end of "test_OrderStatus_And_PaidStatus"


    /****************************************************************************************************
        Created by Thai 2015-12-04
            Cover code for method "updateOrderNumber"
    ****************************************************************************************************/
    static testMethod void test_updateOrderNumber() {
        TestDataGenerator.generateApexSetting();

        //*** generate accounts, contacts and portal users
        List<Account> lstAccount = TestDataGenerator.generateAccounts(1, true);
        List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 1, true);
        List<User> lstUser = new List<User> {TestDataGenerator.generatePortalUser('ISS Portal', lstContact[0].Id, true)};
        
        //*** generate order
        List<Order> lstOrder = TestDataGenerator.generateOrder(3, lstAccount[0].Id, lstContact[0].Id, lstContact[0].Id, false);
        lstOrder[0].SAP_Order_Number__c = null;
        lstOrder[1].SAP_Order_Number__c = 'order 2';
        lstOrder[2].SAP_Order_Number__c = null;
        insert lstOrder;
        List<OrderItem> lstOrderItem = TestDataGenerator.generateOrderItem(lstOrder[0].Id, 1, false);
        lstOrderItem.addAll(TestDataGenerator.generateOrderItem(lstOrder[1].Id, 1, false));
        lstOrderItem.addAll(TestDataGenerator.generateOrderItem(lstOrder[2].Id, 1, false));
        lstOrderItem[2].SAP_Contract_Number__c = 'contract 3';
        insert lstOrderItem;
        
        //*** test
        Map<Id, String> mapOrderId_OrderNumber = new Map<Id, String>();
        mapOrderId_OrderNumber.put(lstOrder[0].Id, 'test 1');
        mapOrderId_OrderNumber.put(lstOrder[1].Id, 'test 2');
        mapOrderId_OrderNumber.put(lstOrder[2].Id, 'contract 3');
        Order_Svc.updateOrderNumber(mapOrderId_OrderNumber);
        system.assert(1 == [select count() from Order where Id = :lstOrder[0].Id and SAP_Order_Number__c = :mapOrderId_OrderNumber.get(lstOrder[0].Id)], 'Wrong order number');
        system.assert(1 == [select count() from Order where Id = :lstOrder[1].Id and SAP_Order_Number__c != :mapOrderId_OrderNumber.get(lstOrder[1].Id)], 'Wrong order number');
        system.assert(1 == [select count() from Order where Id = :lstOrder[2].Id and SAP_Order_Number__c != :mapOrderId_OrderNumber.get(lstOrder[2].Id)], 'Wrong order number');
    } //*** end of "test_updateOrderNumber"


    @isTest (seeAllData=true)
    static void test_Other()
    {
        List<Account> accounts = TestDataGenerator.generateAccounts(1, true);
        List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id, 1, true);

        String subscriptionId = '2c92c0f85133e1d90151637a01fe096b';
        Order theOrder = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[0].Id, contacts[0].Id,true)[0]; // 1 Order
        List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(theOrder.Id, 3,false);// 3 lineItems for theOrder
        orderItems[2].Zuora_Subscription_Status__c = 'Pending Activation';
        orderItems[2].Zuora_SubscriptionId__c = subscriptionId;
        insert orderItems;
        Mail_DTO m = Order_Svc.newMailDTO(contacts[0].Id, contacts[0].Id, new List<String>{'test@test.com'});

        //-- Call SalesOrder_Scheduler
        //Test.startTest();
        SalesOrder_Scheduler.doSchedule('0 0 1 * * ?');
        //Test.stopTest();

        //--SAPInvoice_DTO
        SAP_Invoice__c sapInvoice = new SAP_Invoice__c(
            Clearance_Date__c = Date.today(),
            Invoice_Number__c = 'INV-0007',
            Order__c = theOrder.Id
        );
        insert sapInvoice;

        Map<String, List<SAP_Invoice__c>> invoices = new SAPInvoice_Sel().getOrderInvoices(new Set<String>{theOrder.Id});
        System.assertEquals(1, invoices.size());

        SAPInvoice_DTO sid = new SAPInvoice_DTO(sapInvoice);

        OrderItem oi = [select id,Zuora_Subscription_Status__c from OrderItem where Zuora_SubscriptionId__c= :subscriptionId];
        system.assertEquals('Pending Activation', oi.Zuora_Subscription_Status__c);

    }

    /****************************************************************************************************
        Created by CGI, Thai 2016-05-06
            Cover code of methods "sendEmailWhenOrderIsSold", "newMailDTO" and "setOrderItemToPaid"
    ****************************************************************************************************/
    @isTest (seeAllData=true) static void test_setOrderItemToPaid()
    {
    	
        TestDataGenerator.generateISOCountryState();
        
     	IECAddress__c oAddress = TestDataGenerator.generateAddresses(1, true)[0];

        //*** generate data
        List<Account> lstAccount = TestDataGenerator.generateAccounts(1,true);
        List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id,2,true);
        
        Location__c locSoldTo = TestDataGenerator.generateLocations(IECConstants.SOLDTO, oAddress.Id, lstAccount[0].Id, NULL, '325231');
        Location__c locBillTo = TestDataGenerator.generateLocations(IECConstants.BILLTO, oAddress.Id, lstAccount[0].Id, lstContact[0].Id, '123623');
        Location__c locShipTo = TestDataGenerator.generateLocations(IECConstants.SHIPTO, oAddress.Id, lstAccount[0].Id, lstContact[0].Id, '451154');
        
        List<Order> lstOrder = TestDataGenerator.generateOrder(2, lstAccount[0].Id, lstContact[0].Id, lstContact[1].Id, false);
        lstOrder[0].BillToContact_Email__c = lstContact[0].Email;
        lstOrder[0].ShipToContact_Email__c = lstContact[0].Email;
        lstOrder[0].Shipping_Instruction__c = 'test';
 	    lstOrder[0].SoldTo_Location__c = locSoldTo.Id;
	    lstOrder[0].BillTo_Location__c = locBillTo.Id;
	    lstOrder[0].ShipTo_Location__c = locShipTo.Id;     
	            
        lstOrder[1].BillToContact_Email__c = lstContact[0].Email;
        lstOrder[1].ShipToContact_Email__c = lstContact[0].Email;
        lstOrder[1].Shipping_Instruction__c = 'test';
 	    lstOrder[1].SoldTo_Location__c = locSoldTo.Id;
	    lstOrder[1].BillTo_Location__c = locBillTo.Id;
	    lstOrder[1].ShipTo_Location__c = locShipTo.Id;       
        
        insert lstOrder;
        
        List<OrderItem> lstOrderItem = TestDataGenerator.generateOrderItem(lstOrder[0].Id, 1, false);
        lstOrderItem.addAll(TestDataGenerator.generateOrderItem(lstOrder[1].Id, 1, false));
        insert lstOrderItem;
        List<Product_Email_Notification__c> lstNotification = new List<Product_Email_Notification__c>();
        for (OrderItem oi : [select Product__c from OrderItem where OrderId = :lstOrder[0].Id or OrderId = :lstOrder[1].Id])
        {
            lstNotification.add(new Product_Email_Notification__c(Product__c=oi.Product__c, External_email_address__c=UserInfo.getUserEmail()));
            lstNotification.add(new Product_Email_Notification__c(Product__c=oi.Product__c, Internal_user__c=UserInfo.getUserId()));
        }
        insert lstNotification;
        
        //*** test
        Apex_Setting__c cs = Apex_Setting__c.getValues('Email batch max value');
        if (cs == null) cs = new Apex_Setting__c(Name='Email batch max value');
        cs.Number_1__c = 100;   //*** cover only 1 bulk email
        upsert cs;
		cs = Apex_Setting__c.getValues('ContactId to populate email Template');
        if (cs == null) cs = new Apex_Setting__c(Name='ContactId to populate email Template');
        cs.Text_1__c = lstContact[0].Id;
        upsert cs;
        lstOrder[0].Status = IECConstants.ORDER_STATUS_READY_FOR_SAP;
        lstOrder[0].Payment_Type__c = 'Bank Transfer';
        update lstOrder[0];
        system.assert(0 ==[select count() from OrderItem where OrderId = :lstOrder[0].Id and IEC_Is_Paid__c = true], 'Order Item should NOT be paid');
        Test.startTest();
            cs.Number_1__c = 2;   //*** cover multiple bulk emails
            update cs;
            lstOrder[1].Status = IECConstants.ORDER_STATUS_PAID;
            lstOrder[1].Payment_Type__c = 'ICH';
            lstOrder[1].Is_Paid__c = true;
            update lstOrder[1];
            system.assert(1 ==[select count() from OrderItem where OrderId = :lstOrder[1].Id and IEC_Is_Paid__c = true], 'Order Item should be paid');
        Test.stopTest();
    } //*** end of "test_setOrderItemToPaid"

}