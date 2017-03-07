@isTest
private class IEC_EventReleaseTest 
{
    @isTest (SeeAllData=true)
    static void test_validateProducts() 
    {
        delete [select Id from Apex_Setting__c where Name like 'ECommerce Products Filter%'];
        
        Test.startTest();
        // Setup test data
        Account oAccount = TestDataGenerator.generateAccounts(1, false)[0];
        oAccount.BillingStreet = '123 Test';
        oAccount.Customer_Type__c = 'Member Airline';
        insert oAccount;

        List<Contact> lstContact = TestDataGenerator.generateContacts(oAccount.Id, 2, true);
        // Test 01: Initialize the first contact where no location record exists
        List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
        List<Location__c> lstLocation = new List<Location__c>();
        lstLocation.add(new Location__c(Type__c='Sold To', Address__c=lstAddress[0].Id, Account__c=oAccount.Id, SAP_Id__c='sold1'));
        lstLocation.add(new Location__c(Type__c='Bill To', Address__c=lstAddress[0].Id, Account__c=oAccount.Id, Contact__c=lstContact[0].Id, SAP_Id__c='bill1'));
        lstLocation.add(new Location__c(Type__c='Ship To', Address__c=lstAddress[0].Id, Account__c=oAccount.Id, Contact__c=lstContact[0].Id, SAP_Id__c='ship1'));
        insert lstLocation;
        update new Account(Id=oAccount.Id, SoldTo_Location__c=lstLocation[0].Id);
        update new Contact(Id=lstContact[0].Id, BillTo_Location__c=lstLocation[1].Id, ShipTo_Location__c=lstLocation[2].Id);

        //-- Generate Generate 3 Products with Price 1 whithout
        List<Product2> products = TestDataGenerator.generateProductsWithPrice(3);
            products[0].Activity_Code__c = products[0].SAP_Material_Number__c.left(4);
            products[0].SAP_Status_Code__c = 'A';
            products[0].Inventory_Status__c = 'In stock';
            products[0].Post_to_Ecommerce_Date__c = Date.today();
            products[0].Sell_through_eCommerce__c = true; 
            products[0].Line_of_Business__c = 'Publications';

            products[1].Activity_Code__c = products[1].SAP_Material_Number__c.left(4);
            products[1].SAP_Status_Code__c = 'A';
            products[1].Inventory_Status__c = 'In stock';
            products[1].Post_to_Ecommerce_Date__c = Date.today();
            products[1].Sell_through_eCommerce__c = true; 
            products[1].Line_of_Business__c = 'Publications';

            products[2].Activity_Code__c = products[2].SAP_Material_Number__c.left(4);
            products[2].SAP_Status_Code__c = 'A';
            products[2].Inventory_Status__c = 'In stock';
            products[2].Post_to_Ecommerce_Date__c = Date.today();
            products[2].Sell_through_eCommerce__c = true; 
            products[2].Line_of_Business__c = 'Publications';
        update products;


        //Products
        Product2 products4 = TestDataGenerator.generateProducts(1, true)[0];

        //Create Event Subscription
        List<IEC_Event_Subscription__c> lstEventSub = new List<IEC_Event_Subscription__c>();
        lstEventSub.add(new IEC_Event_Subscription__c(Product__c = products[0].Id, Quantity__c = 1, Start_Date__c = Date.today(), Subscriber__c = lstContact[0].Id));
        insert lstEventSub;

        //Release without Swap
        IEC_Event_Release__c release1 = new IEC_Event_Release__c(
            Product__c = products[0].Id, 
            Customer_Type__c = 'Member Airline',
            Name = 'Release 1'
        ); 
        Database.insert(release1, false) ;

        //Release with Swap
        IEC_Event_Release__c release2 = new IEC_Event_Release__c(
            Product__c = products[0].Id, 
            Swapped_Product__c = products[2].Id,
            Customer_Type__c = 'Member Airline',
            Name = 'Release 2'
        ); 
        Database.insert(release2, false);

        //Release with Product without price -> error
        IEC_Event_Release__c release3 = new IEC_Event_Release__c(
            Product__c = products4.Id, 
            Customer_Type__c = 'Member Airline',
            Name = 'Release 3'
        ); 
        try { insert release3; } catch(Exception e) {}

        //Release with Product with Swap without price -> error
        release3 = new IEC_Event_Release__c(
            Product__c = products[0].Id, 
            Swapped_Product__c = products4.Id, 
            Customer_Type__c = 'Member Airline',
            Name = 'Release 3'
        ); 
        try { insert release3; } catch(Exception e) {}

        //Release used for deletion
        release3 = new IEC_Event_Release__c(
            Product__c = products[0].Id, 
            Customer_Type__c = 'Member Airline',
            Name = 'Release 3'
        ); 
        insert release3;

        Test.stopTest();

        if(release1.Id != null){
                //Cover the IEC Renewal create orders batch
                IEC_Event_Renewal_CreateOrders_Batch batch = new IEC_Event_Renewal_CreateOrders_Batch(release1, null);
                Database.executeBatch(batch,1);

                //Cover the IEC Event renewal Tax calculation
                IEC_Evt_Renew_GetSAPFreightTax_Batch batchForTax = new IEC_Evt_Renew_GetSAPFreightTax_Batch(release1.Id, false);
                Database.executeBatch(batchForTax,1);
        }
        
        if(release1.Id != null){
                IEC_Event_Release__c evenRelease = [select id, Sales_Amout__c,Processing_Status__c from IEC_Event_Release__c where id = :release1.Id ];
                system.assert(evenRelease.Sales_Amout__c != null, 'Release amount can not be null');
                system.assert(evenRelease.Processing_Status__c == null, 'Tax and shipping done with error processing');
        }

        if(release1.Id != null){
            //Cover the IEC_ReleaseLogCleanup_Batch
            IEC_ReleaseLogCleanup_Batch batch = new IEC_ReleaseLogCleanup_Batch(new List<IEC_Event_Release__c>{release1}, 'ClearAutoRenewals');
            Database.executeBatch(batch,1);
        }

        try {
            //Cover IEC_EventRelease_Svc.generateAutoRenewals case product/customer type changed
            release2.Swapped_Product__c = null;
            update release2;
            IEC_EventRelease_Svc.generateAutoRenewals(new List<IEC_Event_Release__c>{release2}, new Map<Id, IEC_Event_Release__c>{release2.Id => release2});
        } catch (Exception e) {}

        try {
            //Cover IEC_EventRelease_Dom and IEC_EventRelease_Svc case delete
            update new IEC_Event_Release__c(Id=release3.Id, Processing_Status__c='test');
            delete release3;
        } catch (Exception e) {}
    }
    
}