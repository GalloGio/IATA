@isTest
private class IEC_ShippingControllerTest {
    
    @isTest static void test_not_logged_in() 
    {
        Test.setCurrentPage(Page.IEC_Shipping);
        IEC_ShippingController ctrl = new IEC_ShippingController(); 
        ctrl.onLoadAction();
    }
    
    @isTest (SeeAllData=true)
    static void test_empty_cart() 
    {
        Test.setCurrentPage(Page.IEC_Shipping);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        Contact oContact = new Contact_Sel().getContactById(usr.contactId);

        //-- Generate locations
        IECAddress__c address = TestDataGenerator.generateAddresses(1, true)[0];
        Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, address.Id, oContact.AccountId,  usr.contactId);
        Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, address.Id, oContact.AccountId,  usr.contactId);

        oContact.BillTo_Location__c = billToLocation.Id;
        oContact.ShipTo_Location__c = shipToLocation.Id;
        update oContact;

        System.runAs(usr)
        {
            IEC_ShippingController ctrl = new IEC_ShippingController(); 
            ctrl.onLoadAction();
        }
    }

    @isTest (SeeAllData=true)
    static void test_quote() 
    {
        Test.setCurrentPage(Page.IEC_Shipping); 

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        ////insert usr;

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
        List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, 2, true);
        
        for(OrderItem oi : new OrderItem_Sel().getOrderItems(ord.Id))
            IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);

        Test.startTest();
        System.runAs(usr)
        {
            IEC_ShippingController ctrl = new IEC_ShippingController(); 
            //-- Load Shipping page 
            ctrl.onLoadAction();

            //-- Generate Quote 
            try{
                ctrl.generateQuote();
            }
            catch(Exception ex){}
            
            //System.assert(ctrl.quoteGenerated);
        }
        Test.stopTest();
    }

    @isTest (SeeAllData=true)
    static void test_invalid_location() 
    {
        Test.setCurrentPage(Page.IEC_Shipping);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        Contact oContact = new Contact_Sel().getContactById(usr.contactId);
    
        System.runAs(usr)
        {
            IEC_ShippingController ctrl = new IEC_ShippingController(); 
            ctrl.onLoadAction();
        }
    }

    @isTest (SeeAllData=true)
    static void test_no_zaccount()
    {
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr)
        {
            IEC_ShippingController ctrl = new IEC_ShippingController(); 

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
    static void test_valid() 
    {
        try{
        
        Test.setCurrentPage(Page.IEC_Shipping); 
       
       
      
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        ////insert usr;

        Contact oContact = new Contact_Sel().getContactById(usr.contactId);
        //-- Generate locations
        List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(3, true);
        Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
        Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
        Location__c newShipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[1].Id, oContact.AccountId,  usr.contactId);
        Location__c newShipToLocation2 = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[2].Id, oContact.AccountId,  usr.contactId);

        oContact.BillTo_Location__c = billToLocation.Id;
        oContact.ShipTo_Location__c = shipToLocation.Id;
        oContact.OwnerId = usr.Id;
        update oContact;
        System.debug('oContact::'+oContact.Id);

        
        //-- Create Order for customer
        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];

        Order ord = TestDataGenerator.generateOrder(1, oAccount.Id, usr.contactId, usr.contactId,false)[0];
        ord.OwnerId = usr.Id;
        ord.Type = 'Cart';
        insert ord;
        
        //-- Create orderitems 
        Integer nb =2;
        List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nb, true);

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
                Test.setCurrentPage(Page.IEC_Shipping); 
                for(OrderItem oi : new OrderItem_Sel().getOrderItems(ord.Id))
                    IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);


                IEC_ShippingController ctrl = new IEC_ShippingController(); 
                //-- Load Shipping page 
                ctrl.onLoadAction();

                ctrl.initializeOrder();

                System.debug('sfOrer::'+ctrl.sfOrder);

                //-- refresh cookie
                Cookie Cookie_Sync = new Cookie('Cookie_Sync', '', null, 0, false);
                ApexPages.currentPage().setCookies(new Cookie[]{Cookie_Sync});
                ctrl.refreshCookieContent(orderItems, true);

                Cookie_Sync = new Cookie('Cookie_Sync', '', null, 0, false);
                ApexPages.currentPage().setCookies(new Cookie[]{Cookie_Sync});
                ctrl.refreshCookieContent(orderItems, false);       


                //-- Create new Shipping Address            
                ctrl.newShipToAddress = Address_DTO.format2DTO(newShipToLocation.Id);

                
                //-- Call Remote Action to show available addresses
                List<IECAddress__c> addresses_found = IEC_ShippingController.findIECAddresses('123');

                List<SelectOption> availableCountries = ctrl.availableCountries;
                List<SelectOption> shippingAddresses = ctrl.shippingAddresses;
                System.assert(availableCountries.size() >0);
                System.assert(shippingAddresses.size() >0);

                //Select Canada country 
                ApexPages.currentPage().getParameters().put('countryCode', 'CA');
                ctrl.refreshShipToProvinces();

                ctrl.regionChanged();

                //ctrl.saveNewAddress();

                ctrl.newShipToAddress = Address_DTO.format2DTO(newShipToLocation2.Id);
                ctrl.newShipToAddress.vatNumber= '12345';
                ctrl.saveNewAddress();

                //-- SAve invalid address 
                ctrl.newShipToAddress.email = 'test';
               try{
                 ctrl.saveNewAddress();
               }
               catch(Exception ex){}

                //Change Shipping Address
                System.debug('ctrl.sfOrder::'+ctrl.sfOrder);
                System.debug('newShipToLocation::'+newShipToLocation);
                //ctrl.sfOrder.ShipTo_Location__c = newShipToLocation.Id;
                try{ctrl.changeShipToAddress();}catch(Exception ex){}
                ctrl.recalculateFreightTax = true;
                try{ctrl.calculateFreightTaxDTO();}catch(Exception ex){}
                
                
                ctrl.vfOrder.shipToSameAsBilTo=true;
                ctrl.changeShipToAddressOption();
                ctrl.sendShipToCustomerToSAP();

                //-- Validate Order has 2 items 
                System.assertEquals(2, ctrl.vfOrder.orderitems.size());

                /*//-- Apply Invalid coupon COde 
                ctrl.updateItemId = ctrl.vfOrder.orderitems[1].orderItemId;
                ctrl.vfOrder.orderitems[1].couponCode = 'COUP123XX';
                try{ctrl.applyCoupon();}catch(Exception ex){}

                //-- Apply coupon code 
                ctrl.updateItemId = ctrl.vfOrder.orderitems[0].orderItemId;
                ctrl.vfOrder.orderitems[0].couponCode = 'COUP123';
                try{ctrl.applyCoupon();}catch(Exception ex){}

                //ctrl.applyCoupon();*/

                /*//-- Remove coupon code 
                ctrl.updateItemId = ctrl.vfOrder.orderitems[0].orderItemId;
                try{ctrl.removeCoupon();}catch(Exception ex){}*/

                //-- Validate T&C accepted 
                ctrl.isTermsAccepted();

                //-- Load customer credit cards
                ctrl.refreshCreditCards();
                String extra = ctrl.getExtraParamString();
                ctrl.defaultPaymentMethodId = ctrl.creditcards[0].zId;
                ApexPages.currentPage().getParameters().put('zId', ctrl.creditcards[0].zId);
                ctrl.selectedCreditCardId = ctrl.creditcards[0].zId;
                ctrl.setSelectedCreditCard();

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

                System.currentPageReference().getParameters().put('zId', ctrl.creditCards[1].zId);
                ctrl.setSelectedCreditCard();
                ctrl.removeCreditCard();

                //-- Add vblank credit card 
                ctrl.newCreditCardPaymentId = ''; 
                ctrl.addCreditCard();

                //--Goto confirm page
                ctrl.orderPaymentType = IECConstants.PaymentThresholdType_CreditCard;
                ctrl.orderCreditCardId = ctrl.creditcards[0].zId;
                ctrl.processPayment();

            }
            Test.stopTest();
            }
            catch (Exception e) {}
    }

    @isTest (SeeAllData=true)
    static void test_coupon_code() 
    {
    
        try {
        Test.setCurrentPage(Page.IEC_Shipping); 

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        ////insert usr;

        Contact oContact = new Contact_Sel().getContactById(usr.contactId);
        //-- Generate locations
        List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(3, true);
        Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
        Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
        Location__c newShipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[1].Id, oContact.AccountId,  usr.contactId);
        Location__c newShipToLocation2 = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[2].Id, oContact.AccountId,  usr.contactId);

        oContact.BillTo_Location__c = billToLocation.Id;
        oContact.ShipTo_Location__c = shipToLocation.Id;
        oContact.OwnerId = usr.Id;
        update oContact;
        System.debug('oContact::'+oContact.Id);

        
        //-- Create Order for customer
        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];

        Order ord = TestDataGenerator.generateOrder(1, oAccount.Id, usr.contactId, usr.contactId,false)[0];
        ord.OwnerId = usr.Id;
        ord.Type = 'Cart';
        insert ord;
        
        //-- Create orderitems 
        Integer nb =2;
        List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nb, true);

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
                Test.setCurrentPage(Page.IEC_Shipping); 
                for(OrderItem oi : new OrderItem_Sel().getOrderItems(ord.Id))
                    IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);

                IEC_ShippingController ctrl = new IEC_ShippingController(); 
                //-- Load Shipping page 
                ctrl.onLoadAction();

                //-- refresh cookie
                Cookie Cookie_Sync = new Cookie('Cookie_Sync', '', null, 0, false);
                ApexPages.currentPage().setCookies(new Cookie[]{Cookie_Sync});
                ctrl.refreshCookieContent(orderItems, true);

                Cookie_Sync = new Cookie('Cookie_Sync', '', null, 0, false);
                ApexPages.currentPage().setCookies(new Cookie[]{Cookie_Sync});
                ctrl.refreshCookieContent(orderItems, false);       

                //-- Apply Invalid coupon Code 
                                
                try{
                    ctrl.updateItemId = ctrl.vfOrder.orderitems[1].orderItemId;
                    ctrl.vfOrder.orderitems[1].couponCode = 'COUP123XX';
                    ctrl.applyCoupon();
                }
                catch(Exception ex){}

                //-- Apply coupon code 
                
                try{
                    ctrl.updateItemId = ctrl.vfOrder.orderitems[0].orderItemId;
                    ctrl.vfOrder.orderitems[0].couponCode = 'COUP123';
                    ctrl.applyCoupon();
                }catch(Exception ex){}
                
                //-- Remove coupon code 
                
                try{
                    ctrl.updateItemId = ctrl.vfOrder.orderitems[0].orderItemId;
                    ctrl.removeCoupon();
                }catch(Exception ex){}


            }
            Test.stopTest();
            }
            catch (Exception e) {}
    }
}