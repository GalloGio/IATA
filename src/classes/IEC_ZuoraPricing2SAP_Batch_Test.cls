@isTest
private class IEC_ZuoraPricing2SAP_Batch_Test
{
    //****************************************************************************************************
    //  Cover code of class "IEC_ZuoraPricing2SAP_Batch"
    //****************************************************************************************************


    // generate data to be called in test methods
    @testSetup static void generateTestData()
    {
        // Zuora pricing
        Map<String, zqu__ZProduct__c> mapZProduct = new Map<String, zqu__ZProduct__c>();
        mapZProduct.put('p4', new zqu__ZProduct__c(Name='Product 4', zqu__ZuoraId__c='p4', zqu__Deleted__c=false, zqu__SKU__c='SKU 4'
                                  , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)));
        insert mapZProduct.values();
        Map<String, zqu__ProductRatePlan__c> mapZRatePlan = new Map<String, zqu__ProductRatePlan__c>();
        mapZRatePlan.put('p4r1', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p4').Id, zqu__ZuoraId__c='p4r1'
                                     , Name='Product 4, Unit Price', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c=null, Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));

        insert mapZRatePlan.values();
        Map<String, zqu__ProductRatePlanCharge__c> mapZCharge = new Map<String, zqu__ProductRatePlanCharge__c>();
        mapZCharge.put('p4r1c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p4r1').Id, zqu__ZuoraId__c='p4r1c1'
                                     , Name='Product 4, Unit Price, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        insert mapZCharge.values();
        List<zqu__ProductRatePlanChargeTier__c> lstZTier = new List<zqu__ProductRatePlanChargeTier__c>();
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p4r1c1').Id, zqu__Deleted__c=false
                         , Name='Product 4, Unit Price, Charge, Tier 1', zqu__ZuoraId__c='p4r1c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=100));
        insert lstZTier;
        
        // Salesforce product
        List<Product2> lstProduct = TestDataGenerator.generateProducts(1, false);
        lstProduct[0].SAP_Material_Number__c = 'SAP-01';
        lstProduct[0].SAP_Sales_Channel_Code__c = '03';
        lstProduct[0].SAP_Division_Code__c = '01';
        insert lstProduct;
        lstProduct[0].ZProduct__c = mapZProduct.get('p4').Id;
        update lstProduct;
        
        // filter
        insert new IEC_ZuoraPricing2SAP_Filter__c(SAP_Sales_Channel_Code__c='03', SAP_Division_Code__c='01');
    }


    @isTest static void testAllMethod()
    {
        TestDataGenerator.generateApexSetting();
        insert new Apex_Setting__c(Name='ZuoraPricing2SAP Notify Job Completion', Text_1__c='true');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IEC_ZuoraPricing2SAP_HTTP_Mock());
            Database.executeBatch(new IEC_ZuoraPricing2SAP_Batch(IEC_ZuoraPricing2SAP_Batch.processingStep1), 2000);
            Database.executeBatch(new IEC_ZuoraPricing2SAP_Batch('error'), 2000);
        Test.stopTest();
        system.assertEquals(1, [select count() from IEC_ZuoraPricing2SAP_Tracking__c where SendingTimestamp__c != null], 'Must have 1 tracking sent to SAP');
     }
}