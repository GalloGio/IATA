@isTest
private class IECOrder_Svc_Test {

    @isTest(SeeAllData=true)
    static void test_createOrderFromCookie()
    {
        //*** remove additional filters when query products for ECommerce
        delete [select Id from Apex_Setting__c where Name like 'ECommerce Products Filter%'];

        //*** create products
        List<Product2> lstProduct = TestDataGenerator.generateProductsWithPrice(3);
        for(Integer x =0; x < lstProduct.size(); x++)
        {
            Product2 p = lstProduct[x];
            p.Post_to_Ecommerce_Date__c = Date.today().addDays(-10);
            p.Sell_through_eCommerce__c = true; 
            p.Inventory_Status__c = 'In stock';
            p.SAP_Status_Code__c = 'A';
        }
        update lstProduct;

        //*** create location
        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
        Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
        IECAddress__c oAddress = TestDataGenerator.generateAddresses(1, true)[0];
        Location__c oLocation = TestDataGenerator.generateLocations('Ship To', oAddress.Id, oAccount.Id, oContact.Id, 'ship1');

        //*** create cookies
        Test.setCurrentPage(Page.IEC_ProductList);
        IECOrder_Svc.addCartToCookie(lstProduct[0].SAP_Material_Number__c, 1);

        Test.startTest();
            User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
            system.runAs(oUser)
            {
                //*** cover method "getPenddingOrder"
                Order orderCheck = IECOrder_Svc.getPenddingOrder(false);
                system.assertEquals(orderCheck.Id, null);
                orderCheck = IECOrder_Svc.getPenddingOrder(orderCheck.Id);
                system.assertNotEquals(orderCheck.Id, null);
                update new Order(Id=orderCheck.Id, ShipTo_Location__c=oLocation.Id, IEC_Order_Previous_Type__c='Quote');
                TestDataGenerator.generateOrderItem(orderCheck.Id, 1, true);
                system.assertEquals(IECOrder_Svc.getPenddingOrder(false).Id, orderCheck.Id);
            }
        Test.stopTest();
    }


    @isTest(SeeAllData=true)
    static void test_createOrderFromCookie2()
    {
        //*** remove additional filters when query products for ECommerce
        delete [select Id from Apex_Setting__c where Name like 'ECommerce Products Filter%'];

        User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
        Contact oContact = new Contact_Sel().getContactById(oUser.ContactId);
        Order oOrder = TestDataGenerator.generateOrder(1, oContact.AccountId, oContact.Id, oContact.Id, false)[0];
        oOrder.OwnerId = oUser.Id;
        oOrder.Type = 'Cart';
        oOrder.IEC_Order_Previous_Type__c='Quote';
        insert oOrder;
        TestDataGenerator.generateOrderItem(oOrder.Id, 1, true);
        Test.startTest();
            system.runAs(oUser)
            {
                //*** cover method "validateQuoteNumberToConvert"
                system.assertEquals(IECOrder_Svc.validateQuoteNumberToConvert(oOrder.OrderNumber, oUser.Id, oContact.Id), false);

                //*** cover method "changePenddingOrder"
                IECOrder_Svc.changePenddingOrder(oOrder);
                //system.assertEquals(IECOrder_Svc.getItemsInCookie().size(), 1);
            }
        Test.stopTest();
    }


    @isTest(SeeAllData=true)
    static void test_IECOrderSvc(){
        //*** remove additional filters when query products for ECommerce
        delete [select Id from Apex_Setting__c where Name like 'ECommerce Products Filter%'];

        //*** create products
        List<Product2> lstProduct = TestDataGenerator.generateProductsWithPrice(3);
        lstProduct.addAll(TestDataGenerator.generateProducts(1, true));
        for(Integer x =0; x < lstProduct.size(); x++)
        {
            Product2 p = lstProduct[x];
            p.Post_to_Ecommerce_Date__c = Date.today().addDays(-10);
            p.Sell_through_eCommerce__c = true; 
            p.Inventory_Status__c = 'In stock';
            p.SAP_Status_Code__c = 'A';
        }
        lstProduct[2].IEC_Static_Cart_Quantity__c = 5;
        update lstProduct;

        //*** cover cookie methods
        Cookie ckCheck;
        Integer intCount;
        Map<String, Decimal> mapProductNumber_Quantity;

        Test.setCurrentPage(Page.IEC_ProductDetail);
        intCount = ApexPages.currentPage().getCookies().size();
        IECOrder_Svc.addProductToCookie(lstProduct[0].SAP_Material_Number__c, 1);
        system.assertEquals(ApexPages.currentPage().getCookies().size(), intCount + 1);
        ckCheck = IECOrder_Svc.getOrderCookie(1);
        system.assertEquals(ckCheck.getValue(), lstProduct[0].SAP_Material_Number__c + '_2');
        IECOrder_Svc.modifiedProductToCookie(lstProduct[0].SAP_Material_Number__c, 5);   //*** case of 1 product only
        system.assertEquals(ApexPages.currentPage().getCookies().size(), intCount + 1);
        mapProductNumber_Quantity = IECOrder_Svc.getItemsInCookie();
        system.assertEquals(mapProductNumber_Quantity.get(lstProduct[0].SAP_Material_Number__c), 5);
        IECOrder_Svc.deleteProductToCookie(lstProduct[0].SAP_Material_Number__c);   //*** case of 1 product only
        ckCheck = IECOrder_Svc.getOrderCookie(1);
        system.assert(String.isBlank(ckCheck.getValue()), String.valueOf(ckCheck));

        Test.setCurrentPage(Page.IEC_ProductList);
        intCount = ApexPages.currentPage().getCookies().size();
        IECOrder_Svc.addCartToCookie(lstProduct[0].SAP_Material_Number__c, 1);
        system.assertEquals(ApexPages.currentPage().getCookies().size(), intCount + 1);
        ckCheck = IECOrder_Svc.getOrderCookie(1);
        system.assertEquals(ckCheck.getValue(), lstProduct[0].SAP_Material_Number__c + '_1');
        IECOrder_Svc.addCartToCookie(lstProduct[0].SAP_Material_Number__c, 1);
        system.assertEquals(ApexPages.currentPage().getCookies().size(), intCount + 1);
        ckCheck = IECOrder_Svc.getOrderCookie(1);
        system.assertEquals(ckCheck.getValue(), lstProduct[0].SAP_Material_Number__c + '_2');
        IECOrder_Svc.addCartToCookie(lstProduct[1].SAP_Material_Number__c, 1);
        system.assertEquals(ApexPages.currentPage().getCookies().size(), intCount + 1);
        mapProductNumber_Quantity = IECOrder_Svc.getItemsInCookie();
        system.assertEquals(mapProductNumber_Quantity.get(lstProduct[1].SAP_Material_Number__c), 1);
        IECOrder_Svc.addCartToCookie(lstProduct[2].SAP_Material_Number__c, 1);
        system.assertEquals(ApexPages.currentPage().getCookies().size(), intCount + 1);
        mapProductNumber_Quantity = IECOrder_Svc.getItemsInCookie();
        system.assertEquals(mapProductNumber_Quantity.get(lstProduct[2].SAP_Material_Number__c), 5);
        IECOrder_Svc.modifiedProductToCookie(lstProduct[1].SAP_Material_Number__c, 5);   //*** case of multiple products
        mapProductNumber_Quantity = IECOrder_Svc.getItemsInCookie();
        system.assertEquals(mapProductNumber_Quantity.get(lstProduct[1].SAP_Material_Number__c), 5);
        IECOrder_Svc.deleteProductToCookie(lstProduct[1].SAP_Material_Number__c);   //*** case of multiple products
        mapProductNumber_Quantity = IECOrder_Svc.getItemsInCookie();
        system.assertEquals(mapProductNumber_Quantity.get(lstProduct[1].SAP_Material_Number__c), null);
        IECOrder_Svc.deleteAllCookies();

        //*** cover method "returnToLogin"
        system.assertNotEquals(IECOrder_Svc.returnToLogin('/test'), null);

        //*** cover method "getOrderItemsInCookie"
        Test.setCurrentPage(Page.IEC_ProductList);
        IECOrder_Svc.addCartToCookie(lstProduct[0].SAP_Material_Number__c, 1);
        IECOrder_Svc.addCartToCookie(lstProduct[2].SAP_Material_Number__c, 1);
        IECOrder_Svc.addCartToCookie(lstProduct[3].SAP_Material_Number__c, 1);
        system.assertEquals(IECOrder_Svc.getOrderItemsInCookie().size(), 2);

        //*** create portal user
        Test.startTest();
            User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
            system.runAs(oUser)
            {
                //*** cover method "createOrderFromCookie"
                IECOrder_Svc.createOrderFromCookie();   //*** no order yet
                List<Order> lstOrder = [select Id, OrderNumber from Order where BillToContactId = :oUser.ContactId];
                system.assertEquals(lstOrder.size(), 1);
                TestDataGenerator.generateOrderItem(lstOrder[0].Id, 1, true);
            }
        Test.stopTest();
            system.runAs(oUser)
            {
                IECOrder_Svc.createOrderFromCookie();   //*** have order -> no need to assert
            }
    }
}