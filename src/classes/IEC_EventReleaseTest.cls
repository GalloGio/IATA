@isTest
private class IEC_EventReleaseTest 
{
    @isTest (SeeAllData=true)
    static void test_validateProducts() 
    {
        Test.startTest();
        // Setup test data
        Account oAccount = TestDataGenerator.generateAccounts(1, false)[0];
        oAccount.BillingStreet = '123 Test';
        insert oAccount;

        List<Contact> lstContact = TestDataGenerator.generateContacts(oAccount.Id, 2, true);
        // Test 01: Initialize the first contact where no location record exists
        Location_Svc.InitializeContactLocations(lstContact[0].Id);
        
        List<Location__c> lstLocation = [SELECT Id FROM Location__c];
        //System.assertEquals(3, lstLocation.size(), 'Three location records must be created. Sold/Bill/Ship-To records.');

        //-- Generate Generate 3 Products with Price 1 whithout
        List<Product2> products = TestDataGenerator.generateProductsWithPrice(3);
        ///Activity_Code__c
            products[0].SAP_Material_Number__c = '8888-98';
            products[0].Activity_Code__c = '8888';
            products[0].SAP_Status_Code__c = 'A';
            products[0].Inventory_Status__c = 'In stock';
            products[0].Post_to_Ecommerce_Date__c = Date.today();
            products[0].Line_of_Business__c = 'Publications';

            products[1].SAP_Material_Number__c = '8888-99';
            products[1].Activity_Code__c = '8888';
            products[1].SAP_Status_Code__c = 'A';
            products[1].Inventory_Status__c = 'In stock';
            products[1].Post_to_Ecommerce_Date__c = Date.today();
            products[1].Line_of_Business__c = 'Publications';

            products[2].SAP_Material_Number__c = '2222-01';
            products[2].Activity_Code__c = '2222';
            products[2].SAP_Status_Code__c = 'A';
            products[2].Inventory_Status__c = 'In stock';
            products[2].Post_to_Ecommerce_Date__c = Date.today();
            products[2].Line_of_Business__c = 'Publications';


        update products;

        //-- UPdate zProducts Material Numbers
        Set<String> zProductIds = new Set<String>();
        for(Product2 prod : products)
            zProductIds.add(prod.ZProduct__c);

        List<zqu__ZProduct__c> zProducts = [SELECT Id, SAPProductMaterialNo__c FROM zqu__ZProduct__c WHERE Id IN :zProductIds];
            zProducts[0].SAPProductMaterialNo__c = '8888-98';
            zProducts[1].SAPProductMaterialNo__c = '8888-99';
            zProducts[2].SAPProductMaterialNo__c = '2222-01';
        update zProducts;


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
        insert release1;

        //Release with Swap
        IEC_Event_Release__c release2 = new IEC_Event_Release__c(
            Product__c = products[0].Id, 
            Swapped_Product__c = products[2].Id,
            Customer_Type__c = 'Member Airline',
            Name = 'Release 2'
        ); 
        insert release2;
        

        //Release with Product without price
        IEC_Event_Release__c release3 = new IEC_Event_Release__c(
            Product__c = products4.Id, 
            Customer_Type__c = 'Member Airline',
            Name = 'Release 3'
        ); 
        try{
            insert release3;
        }
        catch(Exception e){
            //Exception raised
        }

        //Cover the IEC Renewal create orders batch
        IEC_Event_Renewal_CreateOrders_Batch batch = new IEC_Event_Renewal_CreateOrders_Batch(release1, null);
        Database.executeBatch(batch,1);

        //Cover the IEC Event renewal Tax calculation
        IEC_Evt_Renew_GetSAPFreightTax_Batch batchForTax = new IEC_Evt_Renew_GetSAPFreightTax_Batch(release1.Id, false);
        Database.executeBatch(batchForTax,1);

        Test.stopTest();

        IEC_Event_Release__c evenRelease = [select id, Sales_Amout__c,Processing_Status__c from IEC_Event_Release__c where id = :release1.Id ];
        system.assert(evenRelease.Sales_Amout__c != null, 'Release amount can not be null');
        system.assert(evenRelease.Processing_Status__c == null, 'Tax and shipping done with error processing');

    }
    
}