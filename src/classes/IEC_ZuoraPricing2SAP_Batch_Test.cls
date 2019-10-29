@isTest
private class IEC_ZuoraPricing2SAP_Batch_Test
{
    //****************************************************************************************************
    //  Cover code of class "IEC_ZuoraPricing2SAP_Batch"
    //****************************************************************************************************


    // generate data to be called in test methods
    @testSetup static void generateTestData()
    {

        // Salesforce product
        List<Product2> lstProduct = TestDataGenerator.generateProducts(1, false);
        lstProduct[0].SAP_Material_Number__c = 'SAP-01';
        lstProduct[0].SAP_Sales_Channel_Code__c = '03';
        lstProduct[0].SAP_Division_Code__c = '01';
        lstProduct[0].zqu__SKU2__c = 'SKU 4';
        lstProduct[0].zqu__Deleted__c = false;
        lstProduct[0].zqu__ZuoraId__c='p4';
        lstProduct[0].zqu__EffectiveStartDate__c=system.today();
        lstProduct[0].zqu__EffectiveEndDate__c=system.today().addDays(365);
        insert lstProduct;

        // Zuora pricing
        Map<String, Product2> mapProduct = new Map<String, Product2>();
        mapProduct.put('p4', lstProduct[0]);

        Map<String, zqu__ProductRatePlan__c> mapZRatePlan = new Map<String, zqu__ProductRatePlan__c>();
        mapZRatePlan.put('p4r1', new zqu__ProductRatePlan__c(zqu__Product__c=mapProduct.get('p4').Id, zqu__ZuoraId__c='p4r1'
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
        
        
        // filter
        insert new IEC_ZuoraPricing2SAP_Filter__c(SAP_Sales_Channel_Code__c='03', SAP_Division_Code__c='01');
    }


    @isTest static void testAllMethod()
    {
        TestDataGenerator.generateApexSetting();
        insert new Apex_Setting__c(Name='ZuoraPricing2SAP Notify Job Completion', Text_1__c='true');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IEC_ZuoraPricing2SAP_HTTP_Mock());

            Map<Id, Product2> mapProductId_Product = new IEC_ZuoraPricing2SAP_Svc().getTrackingProduct2();

            List<zqu__ProductRatePlanChargeTier__c> prpctList = [select Id, CurrencyIsoCode, IsDeleted
                      , LastModifiedDate
                      , zqu__Deleted__c
                      , zqu__Currency__c
                      , zqu__StartingUnit__c
                      , zqu__EndingUnit__c
                      , zqu__Price__c
                      , zqu__ProductRatePlanCharge__c
                      , zqu__ProductRatePlanCharge__r.LastModifiedDate
                      , zqu__ProductRatePlanCharge__r.zqu__Deleted__c
                      , zqu__ProductRatePlanCharge__r.zqu__Model__c
                      , zqu__ProductRatePlanCharge__r.zqu__Type__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.LastModifiedDate
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Deleted__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.CustomerType__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Couponcode__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Country__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Region__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.IsFreeShipping__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.IsPreSale__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.LastModifiedDate
                      , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.zqu__Deleted__c
                      from zqu__ProductRatePlanChargeTier__c
                      /*where zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c in :mapProductId_Product.keyset()
                        and zqu__ProductRatePlanCharge__r.zqu__Type__c in ('One-Time', 'Recurring')
                        and ZRatePlan_CouponCode__c = null
                        and zqu__ProductRatePlanCharge__r.zqu__Model__c in ('Per Unit', 'Per Unit Pricing', 'Volume', 'Volume Pricing'
                                                                          , 'Discount-Fixed Amount', 'Discount-Percentage')
                      order by zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c
                             , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c
                             , zqu__ProductRatePlanCharge__c
                             , zqu__Tier__c
                      ALL ROWS*/];

            List<zqu__ProductRatePlan__c> prpList = [select Id, Name, zqu__Product__c, zqu__ZuoraId__c from zqu__ProductRatePlan__c];

            Database.executeBatch(new IEC_ZuoraPricing2SAP_Batch(IEC_ZuoraPricing2SAP_Batch.processingStep1), 2000);
            Database.executeBatch(new IEC_ZuoraPricing2SAP_Batch('error'), 2000);
        Test.stopTest();
        system.assertEquals(1, [select count() from IEC_ZuoraPricing2SAP_Tracking__c where SendingTimestamp__c != null], 'Must have 1 tracking sent to SAP');
     }
}