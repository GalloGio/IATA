@isTest
private class IEC_ConfirmOrderControllerTest 
{
    @isTest (SeeAllData=true)
    static void test_not_logged() 
    {
        IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

        //-- Load page 
        System.assertEquals(null, ctrl.loggedCustomer);
        ctrl.onLoadAction(); 
    }

    @isTest (SeeAllData=true)
    static void test_empty_cart() 
    {
        //-- Create an logged-in has portal customer 
        User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
        System.runAs(usr)
        {
            Test.setCurrentPage(Page.IEC_ConfirmOrder);
            IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

            //-- Validate Cart is Empty 
            System.assertEquals(null, ctrl.onLoadAction());
        }
    }   

    @isTest (SeeAllData=true)
    static void test_no_payment_type() 
    {
        Test.setCurrentPage(Page.IEC_ConfirmOrder); 

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        //insert usr;

        Contact oContact = new Contact_Sel().getContactById(usr.contactId);
        //-- Generate locations
        List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(2, true);
        Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
        Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
        Location__c newShipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[1].Id, oContact.AccountId,  usr.contactId);

        oContact.BillTo_Location__c = billToLocation.Id;
        oContact.ShipTo_Location__c = shipToLocation.Id;
        update oContact;
        
        //-- Create Order for customer
        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
            
        Order ord = TestDataGenerator.generateOrder(1, oAccount.Id, usr.contactId, usr.contactId,false)[0];
        ord.OwnerId = usr.Id;
        ord.Type = 'Cart';
        insert ord;
        
        //-- Create orderitems 
        Integer nb =2;
        List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nb, false);
        for(OrderItem oi : orderitems)
        {
            oi.Auto_Renew__c  = true;
        }
        insert orderItems;

        //-- Generate Coupon Code Rate plan for items 
        Set<String> productIds = new Set<String>();
        
        for(OrderItem oi : new OrderItem_Sel().getOrderItems(ord.Id))
        {
            productIds.add(oi.Product__c);
            IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
        }

        List<Product2> products = [SELECT Id, SAP_Material_Number__c, ZProduct__c FROM Product2 WHERE Id IN :productIds];

        List<zqu__ZProduct__c> zProducts = TestDataGenerator.generateZProducts(nb, false);
        for(Integer x = 0; x < nb; x++)
        {
            zqu__ZProduct__c zProduct = zProducts[x];
            Product2 prod = products[x]; 
            zProduct.SAPProductMaterialNo__c = prod.SAP_Material_Number__c;
        }
        insert zProducts;

        //-- Generate RatePlans & Charges & Tiers
        List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
        List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();
        List<zqu__ProductRatePlanChargeTier__c> zTiers = new List<zqu__ProductRatePlanChargeTier__c>();

        for(Integer x = 0; x < products.size(); x++)
        {
            Product2 prod = products[x]; 
            zqu__ZProduct__c zprod = zProducts[x];
            zqu__ProductRatePlan__c unitPricePlan = TestDataGenerator.generateZRatePlans(zprod.Id,1,false)[0];
            zqu__ProductRatePlan__c zPlan = TestDataGenerator.generateZRatePlans(zprod.Id,1,false)[0];
                zPlan.Couponcode__c = 'COUP123';
            zRatePlans.add(zPlan); 
            zRatePlans.add(unitPricePlan);
            prod.ZProduct__c = zprod.Id;
        }
        insert zRatePlans;

         //Create Unit Price Charge & Discount for each Plan 
        for(zqu__ProductRatePlan__c rp : zRatePlans)
        {
            //Unit Price Volume Price & Discount
            List<zqu__ProductRatePlanCharge__c> charges = TestDataGenerator.generateZCharges(rp.Id, 3, false);

            charges[0].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
            charges[1].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_VOLUME; 
            charges[2].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT;
            zCharges.addAll(charges);
        }

        insert zCharges;

        //-- Generate Tiers for Volume Prices 
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
        update products;



        Test.startTest();
            System.runAs(usr)
            {
                //Test.setCurrentPage(Page.IEC_ConfirmOrder);
                IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

                //-- Load Page
                ctrl.onLoadAction();    

                //-- Submit without Payment_Type__c 
                try{ctrl.submitOrder();}catch(Exception ex){}
                //System.assert(ApexPages.getMessages().size() > 0);
            }
        Test.stopTest();
    }   

    @isTest (SeeAllData=true)
    static void test_cc1() 
    {
        Test.setCurrentPage(Page.IEC_ConfirmOrder); 

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
       // //insert usr;

        Contact oContact = new Contact_Sel().getContactById(usr.contactId);
        //-- Generate locations
        List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(2, true);
        Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
        Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
        Location__c newShipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[1].Id, oContact.AccountId,  usr.contactId);

        oContact.BillTo_Location__c = billToLocation.Id;
        oContact.ShipTo_Location__c = shipToLocation.Id;
        update oContact;
        
        //-- Create Order for customer
        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
            
        Order ord = TestDataGenerator.generateOrder(1, oAccount.Id, usr.contactId, usr.contactId,false)[0];
        ord.OwnerId = usr.Id;
        ord.Type = 'Cart';
        insert ord;
        
        //-- Create orderitems 
        Integer nb =2;
        List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nb, false);
        for(OrderItem oi : orderitems)
        {
            oi.Auto_Renew__c  = true;
        }
        insert orderItems;

        //-- Generate Coupon Code Rate plan for items 
        Set<String> productIds = new Set<String>();
        
        for(OrderItem oi : new OrderItem_Sel().getOrderItems(ord.Id))
        {
            productIds.add(oi.Product__c);
            IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
        }

        List<Product2> products = [SELECT Id, SAP_Material_Number__c, ZProduct__c FROM Product2 WHERE Id IN :productIds];

        List<zqu__ZProduct__c> zProducts = TestDataGenerator.generateZProducts(nb, false);
        for(Integer x = 0; x < nb; x++)
        {
            zqu__ZProduct__c zProduct = zProducts[x];
            Product2 prod = products[x]; 
            zProduct.SAPProductMaterialNo__c = prod.SAP_Material_Number__c;
        }
        insert zProducts;

        //-- Generate RatePlans & Charges & Tiers
        List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
        List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();
        List<zqu__ProductRatePlanChargeTier__c> zTiers = new List<zqu__ProductRatePlanChargeTier__c>();

        for(Integer x = 0; x < products.size(); x++)
        {
            Product2 prod = products[x]; 
            zqu__ZProduct__c zprod = zProducts[x];
            zqu__ProductRatePlan__c unitPricePlan = TestDataGenerator.generateZRatePlans(zprod.Id,1,false)[0];
            zqu__ProductRatePlan__c zPlan = TestDataGenerator.generateZRatePlans(zprod.Id,1,false)[0];
                zPlan.Couponcode__c = 'COUP123';
            zRatePlans.add(zPlan); 
            zRatePlans.add(unitPricePlan);
            prod.ZProduct__c = zprod.Id;
        }
        insert zRatePlans;

         //Create Unit Price Charge & Discount for each Plan 
        for(zqu__ProductRatePlan__c rp : zRatePlans)
        {
            //Unit Price Volume Price & Discount
            List<zqu__ProductRatePlanCharge__c> charges = TestDataGenerator.generateZCharges(rp.Id, 3, false);

            charges[0].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
            charges[1].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_VOLUME; 
            charges[2].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT;
            zCharges.addAll(charges);
        }

        insert zCharges;

        //-- Generate Tiers for Volume Prices 
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
        update products;



        Test.startTest();
            System.runAs(usr)
            {
                //Test.setCurrentPage(Page.IEC_ConfirmOrder);
                IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

                //-- Validate Cart is Empty 
                ctrl.onLoadAction();    

                //-- Submit using Bank Transfert
                ctrl.initorder(); 
                ctrl.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_BankTransfer;

                ctrl.submitOrder();
            }
        Test.stopTest();
    }   

    @isTest (SeeAllData=true)
    static void test_cc2() 
    {
        Test.setCurrentPage(Page.IEC_ConfirmOrder); 

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        //insert usr;

        Contact oContact = new Contact_Sel().getContactById(usr.contactId);
        //-- Generate locations
        List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(2, true);
        Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
        Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
        Location__c newShipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[1].Id, oContact.AccountId,  usr.contactId);

        oContact.BillTo_Location__c = billToLocation.Id;
        oContact.ShipTo_Location__c = shipToLocation.Id;
        update oContact;
        
        //-- Create Order for customer
        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
            
        Order ord = TestDataGenerator.generateOrder(1, oAccount.Id, usr.contactId, usr.contactId,false)[0];
        ord.OwnerId = usr.Id;
        ord.Type = 'Cart';
        insert ord;
        
        //-- Create orderitems 
        Integer nb =2;
        List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nb, false);
        for(OrderItem oi : orderitems)
        {
            oi.Auto_Renew__c  = true;
        }
        insert orderItems;

        //-- Generate Coupon Code Rate plan for items 
        Set<String> productIds = new Set<String>();
        
        for(OrderItem oi : new OrderItem_Sel().getOrderItems(ord.Id))
        {
            productIds.add(oi.Product__c);
            IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
        }

        List<Product2> products = [SELECT Id, SAP_Material_Number__c, ZProduct__c FROM Product2 WHERE Id IN :productIds];

        List<zqu__ZProduct__c> zProducts = TestDataGenerator.generateZProducts(nb, false);
        for(Integer x = 0; x < nb; x++)
        {
            zqu__ZProduct__c zProduct = zProducts[x];
            Product2 prod = products[x]; 
            zProduct.SAPProductMaterialNo__c = prod.SAP_Material_Number__c;
        }
        insert zProducts;

        //-- Generate RatePlans & Charges & Tiers
        List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
        List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();
        List<zqu__ProductRatePlanChargeTier__c> zTiers = new List<zqu__ProductRatePlanChargeTier__c>();

        for(Integer x = 0; x < products.size(); x++)
        {
            Product2 prod = products[x]; 
            zqu__ZProduct__c zprod = zProducts[x];
            zqu__ProductRatePlan__c unitPricePlan = TestDataGenerator.generateZRatePlans(zprod.Id,1,false)[0];
            zqu__ProductRatePlan__c zPlan = TestDataGenerator.generateZRatePlans(zprod.Id,1,false)[0];
                zPlan.Couponcode__c = 'COUP123';
            zRatePlans.add(zPlan); 
            zRatePlans.add(unitPricePlan);
            prod.ZProduct__c = zprod.Id;
        }
        insert zRatePlans;

         //Create Unit Price Charge & Discount for each Plan 
        for(zqu__ProductRatePlan__c rp : zRatePlans)
        {
            //Unit Price Volume Price & Discount
            List<zqu__ProductRatePlanCharge__c> charges = TestDataGenerator.generateZCharges(rp.Id, 3, false);

            charges[0].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
            charges[1].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_VOLUME; 
            charges[2].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT;
            zCharges.addAll(charges);
        }

        insert zCharges;

        //-- Generate Tiers for Volume Prices 
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
        update products;

        Test.startTest();
            System.runAs(usr)
            {
                //Test.setCurrentPage(Page.IEC_ConfirmOrder);
                IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

                //-- Validate Cart is Empty 
                ctrl.onLoadAction();    

                //-- Submit order with CC without credit ref
                try{
                	if(ctrl.sfOrder == null)
						ctrl.sfOrder = IECOrder_Svc.getPenddingOrder();

	                ctrl.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;
	                ctrl.submitOrder();
                }
            	catch(Exception ex){}

                //-- Subl=mit with CC with ref 
                ctrl.card = new IEC_CreditCard_DTO();
                    ctrl.card.zId = 'abcd123';
                    ctrl.card.isDefault = true;
                    ctrl.card.isExpired = false;
                    ctrl.card.name = 'TEST';
                    ctrl.card.creditCardType = 'VISA';
                    ctrl.card.creditCardMaskNumber = 'xxxxxxxxxx111';
                    ctrl.card.creditCardCVV = '123';
                    ctrl.card.expirationMonth = 10;
                    ctrl.card.expirationYear = 2016;
                    ctrl.card.holderName = 'TEST VISA';
                    ctrl.card.country = 'Canada';
                    ctrl.card.addresLine1 = '123 Street';
                    ctrl.card.addresLine2 = '';
                    ctrl.card.city = 'Montreal';
                    ctrl.card.stateProvince = 'QC';
                    ctrl.card.postalCode = 'H0H0H0';
                    ctrl.card.accountId = '123456accc';
                    ctrl.card.lastTransactionStatus = 'Success';

                Zuora.zObject zPayment = ctrl.card.toZObjectForUpdate();

                ctrl.sfOrder.Zuora_Credit_Card_Id__c =ctrl.card.zId;
                ctrl.submitOrder();

            }
        Test.stopTest();
    }   
    
}