@isTest
private class ProductSoldNotificationContent_Ctrl_Test {

    @isTest(SeeAllData=true)
    static void CustomerSoldNotificationTest() {
        TestDataGenerator.generateApexSetting();

        Test.StartTest();
        ProductSoldNotificationContent_Ctrl ctrl = new ProductSoldNotificationContent_Ctrl();
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
        
        Contact oContact = IECUserManager.getContactById(usr.ContactId);

        // Create Orders 
        List<Order> orders = TestDataGenerator.generateOrder(1, oContact.AccountId, oContact.Id, oContact.Id, true); // 1 Order
            
        List<Product2> products = TestDataGenerator.generateProductsWithPrice(1);
        products[0].Inventory_Status__c = 'In stock';
        update products;
        
        List<PricebookEntry> pricebookEntries =
            [SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :Test.getStandardPricebookId()
                AND Product2Id = :products[0].Id];

        OrderItem oi = new OrderItem(
                PriceBookEntryId = pricebookEntries[0].Id, 
                OrderId = orders[0].Id, 
                Quantity = 5,
                UnitPrice = 50, 
                Charge_Shipping__c = true,
                ServiceDate = Date.Today());
        insert oi;
        
        OrderItem oi2 = new OrderItem(
                PriceBookEntryId = pricebookEntries[0].Id, 
                OrderId = orders[0].Id, 
                Quantity = 1,
                UnitPrice = 100, 
                Setup_Fee__c = 10,
                Charge_Shipping__c = true,
                ServiceDate = Date.Today());
        insert oi2;

        List<OrderItem> lstOrderItem;
        
        // Test 01: Test with no input at all
        lstOrderItem = ctrl.getOrderItems();

        System.assertEquals(null, lstOrderItem, 'OrderItems is null since no parameters is passed');
        
        // Test 02: Test with only the Order Id passed
        ctrl.idOrder = orders[0].Id;
        lstOrderItem = ctrl.getOrderItems();
        
        System.assertEquals(2, lstOrderItem.size(), '2 OrderItems should be returned for the full order');
        
        // Test 03: Test with only the Order Id and Order Item Id passed
        ctrl.idOrderItem = oi.Id;
        lstOrderItem = ctrl.getOrderItems();
        
        System.assertEquals(1, lstOrderItem.size(), 'Only one OrderItem should be returned');
        System.assertEquals(oi.Id, lstOrderItem[0].Id, 'Ids must match');
        
        // Misc Coverage
        String sTest = ctrl.sBaseUrl;
        Test.StopTest();
    }
}