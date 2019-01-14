@isTest
private class IEC_ZuoraPricing2SAP_Svc_Test
{
    //****************************************************************************************************
    //  Cover code of class "IEC_ZuoraPricing2SAP_Batch"
    //****************************************************************************************************


    // generate data to be called in test methods
    @testSetup static void generateTestData()
    {
        // Zuora pricing
        Map<String, zqu__ZProduct__c> mapZProduct = new Map<String, zqu__ZProduct__c>();
        mapZProduct.put('p1', new zqu__ZProduct__c(Name='Deleted product', zqu__ZuoraId__c='p1', zqu__Deleted__c=true, zqu__SKU__c='SKU 1'
                                  , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)));
        mapZProduct.put('p2', new zqu__ZProduct__c(Name='Product for deleted children', zqu__ZuoraId__c='p2', zqu__Deleted__c=false, zqu__SKU__c='SKU 2'
                                  , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)));
        mapZProduct.put('p3', new zqu__ZProduct__c(Name='Product 3', zqu__ZuoraId__c='p3', zqu__Deleted__c=false, zqu__SKU__c='SKU 3'
                                  , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)));
        mapZProduct.put('p4', new zqu__ZProduct__c(Name='Product 4', zqu__ZuoraId__c='p4', zqu__Deleted__c=false, zqu__SKU__c='SKU 4'
                                  , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)));
        insert mapZProduct.values();
        Map<String, zqu__ProductRatePlan__c> mapZRatePlan = new Map<String, zqu__ProductRatePlan__c>();
        mapZRatePlan.put('p1r1', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p1').Id, zqu__ZuoraId__c='p1r1'
                                     , Name='Deleted product, Plan', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c=null, Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p2r1', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p2').Id, zqu__ZuoraId__c='p2r1'
                                     , Name='Product for deleted children, Deleted plan', zqu__Deleted__c=true
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c=null, Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p2r2', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p2').Id, zqu__ZuoraId__c='p2r2'
                                     , Name='Product for deleted children, Plan for deleted charge', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c=null, Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p2r3', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p2').Id, zqu__ZuoraId__c='p2r3'
                                     , Name='Product for deleted children, Plan for deleted tier', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c=null, Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p3r1', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3r1'
                                     , Name='Product 3, Expired plan', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today().addDays(-5), zqu__EffectiveEndDate__c=system.today().addDays(-1)
                                     , CustomerType__c=null, Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p3r2', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3r2'
                                     , Name='Product 3, Unit Price', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c=null, Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p3r3', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3r3'
                                     , Name='Product 3, Volume Price', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c=null, Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p3r4', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3r4'
                                     , Name='Product 3, Discount Amount', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c='Type 1', Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p3r5', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3r5'
                                     , Name='Product 3, Discount Percentage', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c='Type 2', Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p3r6', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3r6'
                                     , Name='Product 3, Coupon Amount', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c='Type 3', Couponcode__c='Coupon 1', Region__c='Region 1', Country__c='Country 1', IsFreeShipping__c='Yes', IsPreSale__c='Yes'));
        mapZRatePlan.put('p3r7', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3r7'
                                     , Name='Product 3, Coupon Percentage', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c='Type 3', Couponcode__c='Coupon 2', Region__c='Region 2', Country__c='Country 2', IsFreeShipping__c='Yes', IsPreSale__c='Yes'));
        mapZRatePlan.put('p3r8', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3r8'
                                     , Name='Product 3, Unit Price 2', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c='Type 4', Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p3r9', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3r9'
                                     , Name='Product 3, Unit Price 3', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c='Type 5', Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p3rX', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3rX'
                                     , Name='Product 3, Unit Price X', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c='Type 6', Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p3rY', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p3').Id, zqu__ZuoraId__c='p3rY'
                                     , Name='Product 3, Unit Price Y', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c='Type 7', Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));
        mapZRatePlan.put('p4r1', new zqu__ProductRatePlan__c(zqu__ZProduct__c=mapZProduct.get('p4').Id, zqu__ZuoraId__c='p4r1'
                                     , Name='Product 4, Unit Price', zqu__Deleted__c=false
                                     , zqu__EffectiveStartDate__c=system.today(), zqu__EffectiveEndDate__c=system.today().addDays(365)
                                     , CustomerType__c=null, Couponcode__c=null, Region__c=null, Country__c=null, IsFreeShipping__c=null, IsPreSale__c=null));

        insert mapZRatePlan.values();
        Map<String, zqu__ProductRatePlanCharge__c> mapZCharge = new Map<String, zqu__ProductRatePlanCharge__c>();
        mapZCharge.put('p1r1c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p1r1').Id, zqu__ZuoraId__c='p1r1c1'
                                     , Name='Deleted product, Plan, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        mapZCharge.put('p2r1c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p2r1').Id, zqu__ZuoraId__c='p2r1c1'
                                     , Name='Product for deleted children, Deleted plan, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        mapZCharge.put('p2r2c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p2r2').Id, zqu__ZuoraId__c='p2r2c1'
                                     , Name='Product for deleted children, Plan for deleted charge, Deleted charge', zqu__Deleted__c=true
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        mapZCharge.put('p2r3c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p2r3').Id, zqu__ZuoraId__c='p2r3c1'
                                     , Name='Product for deleted children, Plan for deleted tier, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        mapZCharge.put('p3r1c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3r1').Id, zqu__ZuoraId__c='p3r1c1'
                                     , Name='Product 3, Expired plan, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        mapZCharge.put('p3r2c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3r2').Id, zqu__ZuoraId__c='p3r2c1'
                                     , Name='Product 3, Unit Price, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        mapZCharge.put('p3r3c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3r3').Id, zqu__ZuoraId__c='p3r3c1'
                                     , Name='Product 3, Volume Price, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Volume', zqu__Type__c='Recurring'));
        mapZCharge.put('p3r4c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3r4').Id, zqu__ZuoraId__c='p3r4c1'
                                     , Name='Product 3, Discount Amount, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Discount-Fixed Amount', zqu__Type__c='Recurring'));
        mapZCharge.put('p3r5c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3r5').Id, zqu__ZuoraId__c='p3r5c1'
                                     , Name='Product 3, Discount Percentage, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Discount-Percentage', zqu__Type__c='Recurring'));
        mapZCharge.put('p3r6c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3r6').Id, zqu__ZuoraId__c='p3r6c1'
                                     , Name='Product 3, Coupon Amount, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Discount-Fixed Amount', zqu__Type__c='Recurring'));
        mapZCharge.put('p3r7c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3r7').Id, zqu__ZuoraId__c='p3r7c1'
                                     , Name='Product 3, Coupon Percentage, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Discount-Percentage', zqu__Type__c='Recurring'));
        mapZCharge.put('p3r8c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3r8').Id, zqu__ZuoraId__c='p3r8c1'
                                     , Name='Product 3, Unit Price 2, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        mapZCharge.put('p3r9c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3r9').Id, zqu__ZuoraId__c='p3r9c1'
                                     , Name='Product 3, Unit Price 3, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        mapZCharge.put('p3rXc1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3rX').Id, zqu__ZuoraId__c='p3rXc1'
                                     , Name='Product 3, Unit Price X, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        mapZCharge.put('p3rYc1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p3rY').Id, zqu__ZuoraId__c='p3rYc1'
                                     , Name='Product 3, Unit Price Y, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        mapZCharge.put('p4r1c1', new zqu__ProductRatePlanCharge__c(zqu__ProductRatePlan__c=mapZRatePlan.get('p4r1').Id, zqu__ZuoraId__c='p4r1c1'
                                     , Name='Product 4, Unit Price, Charge', zqu__Deleted__c=false
                                     , zqu__Model__c='Per Unit', zqu__Type__c='One-Time'));
        insert mapZCharge.values();
        List<zqu__ProductRatePlanChargeTier__c> lstZTier = new List<zqu__ProductRatePlanChargeTier__c>();
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p1r1c1').Id, zqu__Deleted__c=false
                         , Name='Deleted product, Plan, Charge, Tier 1', zqu__ZuoraId__c='p1r1c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=100));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p2r1c1').Id, zqu__Deleted__c=false
                         , Name='Product for deleted children, Deleted plan, Charge, Tier 1', zqu__ZuoraId__c='p2r1c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=100));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p2r2c1').Id, zqu__Deleted__c=false
                         , Name='Product for deleted children, Plan for deleted charge, Deleted charge, Tier 1', zqu__ZuoraId__c='p2r2c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=100));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p2r3c1').Id, zqu__Deleted__c=true
                         , Name='Product for deleted children, Plan for deleted tier, Charge, Deleted tier', zqu__ZuoraId__c='p2r3c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=100));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3r1c1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Expired plan, Charge, Tier 1', zqu__ZuoraId__c='p3r1c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=100));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3r2c1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Unit Price, Charge, Tier 1', zqu__ZuoraId__c='p3r2c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=100));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3r3c1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Volume Price, Charge, Tier 1', zqu__ZuoraId__c='p3r3c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__EndingUnit__c=99, zqu__Price__c=100));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3r3c1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Volume Price, Charge, Tier 2', zqu__ZuoraId__c='p3r3c1t2'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=100, zqu__Price__c=95));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3r4c1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Discount Amount, Charge, Tier 1', zqu__ZuoraId__c='p3r4c1t1'
                         , zqu__Currency__c=null, zqu__Price__c=10));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3r5c1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Discount Percentage, Charge, Tier 1', zqu__ZuoraId__c='p3r5c1t1'
                         , zqu__Currency__c='CAD', zqu__Price__c=5));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3r6c1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Coupon Amount, Charge, Tier 1', zqu__ZuoraId__c='p3r6c1t1'
                         , zqu__Currency__c='CAD', zqu__Price__c=10));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3r7c1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Coupon Percentage, Charge, Tier 1', zqu__ZuoraId__c='p3r7c1t1'
                         , zqu__Currency__c='CAD', zqu__Price__c=5));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3r8c1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Unit Price, Charge, Tier 1', zqu__ZuoraId__c='p3r8c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=90));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3r9c1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Unit Price 3, Charge, Tier 1', zqu__ZuoraId__c='p3r9c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=80));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3rXc1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Unit Price X, Charge, Tier 1', zqu__ZuoraId__c='p3rXc1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=80));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p3rYc1').Id, zqu__Deleted__c=false
                         , Name='Product 3, Unit Price Y, Charge, Tier 1', zqu__ZuoraId__c='p3rYc1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=80));
        lstZTier.add(new zqu__ProductRatePlanChargeTier__c(zqu__ProductRatePlanCharge__c=mapZCharge.get('p4r1c1').Id, zqu__Deleted__c=false
                         , Name='Product 4, Unit Price, Charge, Tier 1', zqu__ZuoraId__c='p4r1c1t1'
                         , zqu__Currency__c='CAD', zqu__StartingUnit__c=1, zqu__Price__c=100));
        insert lstZTier;
        
        // Salesforce product
        List<Product2> lstProduct = TestDataGenerator.generateProducts(4, false);
        for (Integer ix = 0; ix < lstProduct.size(); ix++)
        {
            lstProduct[ix].SAP_Material_Number__c = 'SAP-' + String.valueOf(10 + ix + 1);
            lstProduct[ix].SAP_Sales_Channel_Code__c = '03';
            lstProduct[ix].SAP_Division_Code__c = '01';
        }
        insert lstProduct;
        for (Integer ix = 0; ix < lstProduct.size(); ix++)
            lstProduct[ix].ZProduct__c = mapZProduct.get('p' + (ix + 1)).Id;
        update lstProduct;
        
        // filter
        insert new IEC_ZuoraPricing2SAP_Filter__c(SAP_Sales_Channel_Code__c='03', SAP_Division_Code__c='01');
    }


    // cover code for method "trackingProduct"
    @isTest static void testGetTrackingProduct()
    {
        // reformat data for test
        List<Product2> lstProduct = [select SAP_Material_Number__c, ZProduct__c, ZProduct__r.zqu__ZuoraId__c from Product2 order by SAP_Material_Number__c];
        for (Integer ix = 3; ix < lstProduct.size(); ix++)
            lstProduct[ix].SAP_Division_Code__c = '02';
        update lstProduct;
        IEC_ZuoraPricing2SAP_Filter__c filter = [select Id from IEC_ZuoraPricing2SAP_Filter__c limit 1];
        filter.Exclude_SAP_Material_Number__c = '\'' + lstProduct[2].SAP_Material_Number__c + '\'';
        update filter;
        
        IEC_ZuoraPricing2SAP_Svc svc = new IEC_ZuoraPricing2SAP_Svc();
        Map<Id, Product2> mapZProductId_Product = svc.getTrackingProduct();
        system.assert(mapZProductId_Product.containsKey(lstProduct[0].ZProduct__c) &&
                      mapZProductId_Product.containsKey(lstProduct[1].ZProduct__c) && 
                      mapZProductId_Product.size() == 2, 'Wrong filter ' + String.join(mapZProductId_Product.values(), '\n'));
    }


    // return Zuora pricing for verification
    static Map<String, zqu__ProductRatePlanChargeTier__c> getZuoraPricing(Map<Id, Product2> mapZProductId_Product)
    {
        Map<String, zqu__ProductRatePlanChargeTier__c> mapZId_Tier = new Map<String, zqu__ProductRatePlanChargeTier__c>();
        for (zqu__ProductRatePlanChargeTier__c tier : [select Id, CurrencyIsoCode, zqu__ZuoraId__c, IsDeleted
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
                     , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c
                     , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.LastModifiedDate
                     , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Deleted__c
                from zqu__ProductRatePlanChargeTier__c
                where zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c in :mapZProductId_Product.keySet()
                  and zqu__ProductRatePlanCharge__r.zqu__Type__c in ('One-Time', 'Recurring')
                  and zqu__ProductRatePlanCharge__r.zqu__Model__c in ('Per Unit', 'Per Unit Pricing', 'Volume', 'Volume Pricing'
                                                                    , 'Discount-Fixed Amount', 'Discount-Percentage')
                ALL ROWS])
            mapZId_Tier.put(tier.zqu__ZuoraId__c, tier);
        return mapZId_Tier;
    }


    // return Salesforce tracking for verification
    static Map<String, IEC_ZuoraPricing2SAP_Tracking__c> getTracking()
    {
        Map<String, IEC_ZuoraPricing2SAP_Tracking__c> mapKey_Tracking = new Map<String, IEC_ZuoraPricing2SAP_Tracking__c>();
        for (IEC_ZuoraPricing2SAP_Tracking__c tracking : [select Key__c, Operation__c, Material_Number__c, CustomerType__c, Currency__c
                                                               , Pricing_Type__c, EffectiveFrom__c, EffectiveTo__c, SendingTimestamp__c
                                                               , StartingUnit__c, EndingUnit__c, AmountOrPercentage__c
                                                               , Region__c, Country__c, IsFreeShipping__c, IsPreSale__c
                                                          from IEC_ZuoraPricing2SAP_Tracking__c])
            mapKey_Tracking.put(tracking.Key__c, tracking);
        return mapKey_Tracking;
    }


    // cover code for method "trackPricing" which indirectly cover following methods
    //      sapPrice, isSAPDiscountAmt, isSAPDiscountPct, isSAPCouponAmt, isSAPCouponPct, isSAPVolume, isSAPUnit, sapOperation
    //      zuoraPrice, isZuoraTrue, isZuoraDiscount, isZuoraDiscountAmt, isZuoraDiscountPct, isZuoraRecurring, isZuoraVolume, isZuoraUnit, zuoraCurrency
    //      isPricingDeleted, getLatestTimestamp, buildTrackingKey, buildDiscardKey, isNewTracking, isPricingConditionChanged, prepareSendingTracking
    @isTest static void testTrackPricing()
    {
        IEC_ZuoraPricing2SAP_Svc svc = new IEC_ZuoraPricing2SAP_Svc();
        Map<Id, Product2> mapZProductId_Product = svc.getTrackingProduct();
        
        // cover insert
        Map<String, zqu__ProductRatePlanChargeTier__c> mapZId_Tier = getZuoraPricing(mapZProductId_Product);
        svc.trackPricing(mapZId_Tier.values(), mapZProductId_Product);
        Map<String, IEC_ZuoraPricing2SAP_Tracking__c> mapKey_Tracking = getTracking();
        for (String key : mapKey_Tracking.keySet())
            system.assertEquals(mapKey_Tracking.get(key).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Should have operation INSERT');
        system.assertEquals(mapKey_Tracking.containsKey(svc.buildTrackingKey(mapZId_Tier.get('p1r1c1t1'))), false, 'Should not found deleted product');
        system.assertEquals(mapKey_Tracking.containsKey(svc.buildTrackingKey(mapZId_Tier.get('p2r1c1t1'))), false, 'Should not found deleted plan');
        system.assertEquals(mapKey_Tracking.containsKey(svc.buildTrackingKey(mapZId_Tier.get('p2r2c1t1'))), false, 'Should not found deleted charge');
        system.assertEquals(mapKey_Tracking.containsKey(svc.buildTrackingKey(mapZId_Tier.get('p2r3c1t1'))), false, 'Should not found deleted tier');
        system.assertEquals(mapKey_Tracking.containsKey(svc.buildTrackingKey(mapZId_Tier.get('p3r1c1t1'))), false, 'Should not found expired plan');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.UNIT), 'Price type for Unit Price');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1'))).Currency__c, 'CAD', 'Currency from Zuora tier');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.VOLUME), 'Price type for Volume Price');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).Currency__c, 'CAD', 'Currency from Zuora tier');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.VOLUME), 'Price type for Volume Price');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).Currency__c, 'CAD', 'Currency from Zuora tier');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.DISCOUNT_AMT), 'Price type for Discount Fix Amount');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).Currency__c, mapZId_Tier.get('p3r4c1t1').CurrencyIsoCode, 'Currency from Salesforce default');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.DISCOUNT_PCT), 'Price type for Discount Percentage');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).Currency__c, '%', 'Percentage sign');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.COUPON_AMT), 'Price type for Coupon Fix Amount');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).Currency__c, 'CAD', 'Currency from Zuora tier');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.COUPON_PCT), 'Price type for Coupon Percentage');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).Currency__c, '%', 'Percentage sign');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.UNIT), 'Price type for Unit Price');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1'))).Currency__c, 'CAD', 'Currency from Zuora tier');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.UNIT), 'Price type for Unit Price');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1'))).Currency__c, 'CAD', 'Currency from Zuora tier');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.UNIT), 'Price type for Unit Price');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1'))).Currency__c, 'CAD', 'Currency from Zuora tier');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.UNIT), 'Price type for Unit Price');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1'))).Currency__c, 'CAD', 'Currency from Zuora tier');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.UNIT), 'Price type for Unit Price');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).Currency__c, 'CAD', 'Currency from Zuora tier');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        
        // cover update with pricings that do not change SAP pricing condition
        List<SObject> lstUpdate = new List<SObject>();
        zqu__ProductRatePlanChargeTier__c tierToUpdate;
        IEC_ZuoraPricing2SAP_Tracking__c trackingToUpdate;
        Map<String, String> mapKey = new Map<String, String>();
        // for deletion and pricing not sent to SAP yet
        tierToUpdate = mapZId_Tier.get('p3r2c1t1');
        tierToUpdate.zqu__Deleted__c = true;
        lstUpdate.add(tierToUpdate);
        mapKey.put('DeletionNotSentYet', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1')))));
        // for deletion and pricing already sent to SAP
        tierToUpdate = mapZId_Tier.get('p3r8c1t1');
        tierToUpdate.zqu__Deleted__c = true;
        lstUpdate.add(tierToUpdate);
        trackingToUpdate = mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1')));
        trackingToUpdate.SendingTimestamp__c = system.now();
        lstUpdate.add(trackingToUpdate);
        mapKey.put('DeletionAlreadySent', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1')))));
        // for update requesting to send to SAP and pricing not sent to SAP yet
        tierToUpdate = mapZId_Tier.get('p3r3c1t1');
        tierToUpdate.zqu__Price__c = 105;
        lstUpdate.add(tierToUpdate);
        tierToUpdate = mapZId_Tier.get('p3r3c1t2');
        tierToUpdate.zqu__Price__c = 100;
        lstUpdate.add(tierToUpdate);
        trackingToUpdate = mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2')));
        trackingToUpdate.SendingTimestamp__c = system.now();
        lstUpdate.add(trackingToUpdate);
        // for update that don't change pricing
        tierToUpdate = mapZId_Tier.get('p3r4c1t1');
        lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, Region__c='Region X'));
        trackingToUpdate = mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1')));
        trackingToUpdate.SendingTimestamp__c = system.now();
        lstUpdate.add(trackingToUpdate);
        tierToUpdate = mapZId_Tier.get('p3r5c1t1');
        lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, Country__c='Country X'));
        trackingToUpdate = mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1')));
        trackingToUpdate.SendingTimestamp__c = system.now();
        lstUpdate.add(trackingToUpdate);
        tierToUpdate = mapZId_Tier.get('p3r6c1t1');
        lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, IsFreeShipping__c='No'));
        trackingToUpdate = mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1')));
        trackingToUpdate.SendingTimestamp__c = system.now();
        lstUpdate.add(trackingToUpdate);
        tierToUpdate = mapZId_Tier.get('p3r7c1t1');
        lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, IsPreSale__c='No'));
        trackingToUpdate = mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1')));
        trackingToUpdate.SendingTimestamp__c = system.now();
        lstUpdate.add(trackingToUpdate);
        tierToUpdate = mapZId_Tier.get('p4r1c1t1');
        lstUpdate.add(new zqu__ZProduct__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c, Name='PPP'));
        trackingToUpdate = mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1')));
        trackingToUpdate.SendingTimestamp__c = system.now();
        lstUpdate.add(trackingToUpdate);
        lstUpdate.sort();   // prevent error of 10 chunks in a single operation
        update lstUpdate;
        mapZId_Tier = getZuoraPricing(mapZProductId_Product);
        svc.trackPricing(mapZId_Tier.values(), mapZProductId_Product);
        mapKey_Tracking = getTracking();
        // for deletion and pricing not sent to SAP yet
        system.assertEquals(mapKey_Tracking.containsKey(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1'))), false, 'Deleted pricing not tracked anymore');
        system.assertEquals(mapKey_Tracking.get(mapKey.get('DeletionNotSentYet')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Should have operation INSERT');
        system.assertNotEquals(mapKey_Tracking.get(mapKey.get('DeletionNotSentYet')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
        // for deletion and pricing already sent to SAP
        system.assertEquals(mapKey_Tracking.containsKey(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1'))), false, 'Deleted pricing not tracked anymore');
        system.assertEquals(mapKey_Tracking.get(mapKey.get('DeletionAlreadySent')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Should have operation DELETE');
        system.assertEquals(mapKey_Tracking.get(mapKey.get('DeletionAlreadySent')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
        // for update requesting to send to SAP and pricing not sent to SAP yet
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).AmountOrPercentage__c, 105, 'Price should be tracked');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Should have operation INSERT');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        // for update requesting to send to SAP and pricing already sent to SAP
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).AmountOrPercentage__c, 100, 'Price should be tracked');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.UPD), 'Should have operation UPDATE');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).SendingTimestamp__c, null, 'Pricing is to send to SAP');
        // for unchanged pricing
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Should have operation INSERT');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).Region__c, 'Region X', 'Should have new region');
        system.assertNotEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).SendingTimestamp__c, null, 'Pricing is not to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Should have operation INSERT');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).Country__c, 'Country X', 'Should have new country');
        system.assertNotEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).SendingTimestamp__c, null, 'Pricing is not to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Should have operation INSERT');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).IsFreeShipping__c, false, 'Should not free shipping');
        system.assertNotEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).SendingTimestamp__c, null, 'Pricing is not to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Should have operation INSERT');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).IsPreSale__c, false, 'Should not for pre-sales');
        system.assertNotEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).SendingTimestamp__c, null, 'Pricing is not to send to SAP');
        system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Should have operation INSERT');
        system.assertNotEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).SendingTimestamp__c, null, 'Pricing is not to send to SAP');
        
        // cover update with pricings that change SAP pricing condition and exceptions
        Test.startTest();
            // reset data
            delete [select Id from IEC_ZuoraPricing2SAP_Tracking__c];
            lstUpdate.clear();
            tierToUpdate = mapZId_Tier.get('p3r2c1t1');
            tierToUpdate.zqu__Deleted__c = false;
            lstUpdate.add(tierToUpdate);
            tierToUpdate = mapZId_Tier.get('p3r8c1t1');
            tierToUpdate.zqu__Deleted__c = false;
            lstUpdate.add(tierToUpdate);
            update lstUpdate;
            
            // when pricings are not sent to SAP yet
            mapZId_Tier = getZuoraPricing(mapZProductId_Product);
            svc.trackPricing(mapZId_Tier.values(), mapZProductId_Product);
            mapKey_Tracking = getTracking();
            lstUpdate.clear();
            mapKey.clear();
            tierToUpdate = mapZId_Tier.get('p3r2c1t1');
            lstUpdate.add(new zqu__ProductRatePlanCharge__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__c, zqu__Model__c='Volume'));
            mapKey.put('UnitToVolume', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r3c1t1');
            tierToUpdate.zqu__EndingUnit__c = 100;
            lstUpdate.add(tierToUpdate);
            mapKey.put('VolumeEndUnit', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r3c1t2');
            tierToUpdate.zqu__StartingUnit__c = 101;
            lstUpdate.add(tierToUpdate);
            mapKey.put('VolumeStartUnit', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2')))));
            tierToUpdate = mapZId_Tier.get('p3r4c1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, Couponcode__c='New1'));
            mapKey.put('DiscountAmountToCoupon', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r5c1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, Couponcode__c='New2'));
            mapKey.put('DiscountPctToCoupon', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r6c1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, Couponcode__c=null));
            mapKey.put('CouponAmountToDiscount', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r7c1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, Couponcode__c=null));
            mapKey.put('CouponPctToDiscount', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r8c1t1');
            tierToUpdate.zqu__Currency__c = 'AAA';
            lstUpdate.add(tierToUpdate);
            mapKey.put('Currency', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r9c1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, CustomerType__c='ZZZ'));
            mapKey.put('CustomerType', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3rXc1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, zqu__EffectiveStartDate__c=system.today().addDays(100)));
            mapKey.put('EffectiveFrom', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1')))));
            tierToUpdate = mapZId_Tier.get('p3rYc1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, zqu__EffectiveEndDate__c=system.today().addDays(100)));
            mapKey.put('EffectiveTo', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1')))));
            tierToUpdate = mapZId_Tier.get('p4r1c1t1');
            lstUpdate.add(new Product2(Id=mapZProductId_Product.get(tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c).Id, SAP_Material_Number__c='ZZZ'));
            mapKey.put('Material', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1')))));
            // ensure update will happen
            for (IEC_ZuoraPricing2SAP_Tracking__c tracking : mapKey_Tracking.values())
            {
                tracking.LatestSourceTimestamp__c = system.now().addDays(-1);
                lstUpdate.add(tracking);
            }
            lstUpdate.sort();   // prevent error of 10 chunks in a single operation
            update lstUpdate;
            mapZProductId_Product = svc.getTrackingProduct();
            mapZId_Tier = getZuoraPricing(mapZProductId_Product);
            svc.trackPricing(mapZId_Tier.values(), mapZProductId_Product);
            mapKey_Tracking = getTracking();
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.VOLUME), 'New price type is Volume Price');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('UnitToVolume')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).EndingUnit__c, 100, 'New ending unit');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('VolumeEndUnit')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).StartingUnit__c, 101, 'New starting unit');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('VolumeStartUnit')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.COUPON_AMT), 'New price type is Coupon Fix Amount');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('DiscountAmountToCoupon')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.COUPON_PCT), 'New price type is Coupon Percentage');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('DiscountPctToCoupon')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.DISCOUNT_AMT), 'New price type is Discount Fix Amount');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('CouponAmountToDiscount')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.DISCOUNT_PCT), 'New price type is Discount Percentage');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('CouponPctToDiscount')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1'))).Currency__c, 'AAA', 'New currency');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('Currency')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1'))).CustomerType__c, 'ZZZ', 'New customer type');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('CustomerType')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1'))).EffectiveFrom__c, system.today().addDays(100), 'New customer type');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('EffectiveFrom')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1'))).EffectiveTo__c, system.today().addDays(100), 'New customer type');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('EffectiveTo')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).Material_Number__c, 'ZZZ', 'New SAP material number');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertNotEquals(mapKey_Tracking.get(mapKey.get('Material')).SendingTimestamp__c, null, 'Deleted pricing not sent to SAP should be skipped of sending');
            
            // when pricings are already sent to SAP
            lstUpdate.clear();
            mapKey.clear();
            tierToUpdate = mapZId_Tier.get('p3r2c1t1');
            lstUpdate.add(new zqu__ProductRatePlanCharge__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__c, zqu__Model__c='Per Unit'));
            mapKey.put('VolumeToUnit', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r3c1t1');
            tierToUpdate.zqu__EndingUnit__c = 99;
            lstUpdate.add(tierToUpdate);
            mapKey.put('VolumeEndUnit', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r3c1t2');
            tierToUpdate.zqu__StartingUnit__c = 100;
            lstUpdate.add(tierToUpdate);
            mapKey.put('VolumeStartUnit', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2')))));
            tierToUpdate = mapZId_Tier.get('p3r4c1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, Couponcode__c=null));
            mapKey.put('CouponAmountToDiscount', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r5c1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, Couponcode__c=null));
            mapKey.put('CouponPctToDiscount', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r6c1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, Couponcode__c='New1'));
            mapKey.put('DiscountAmountToCoupon', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r7c1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, Couponcode__c='New2'));
            mapKey.put('DiscountPctToCoupon', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r8c1t1');
            tierToUpdate.zqu__Currency__c = 'BBB';
            lstUpdate.add(tierToUpdate);
            mapKey.put('Currency', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3r9c1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, CustomerType__c='YYY'));
            mapKey.put('CustomerType', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1')))));
            tierToUpdate = mapZId_Tier.get('p3rXc1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, zqu__EffectiveStartDate__c=system.today().addDays(50)));
            mapKey.put('EffectiveFrom', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1')))));
            tierToUpdate = mapZId_Tier.get('p3rYc1t1');
            lstUpdate.add(new zqu__ProductRatePlan__c(Id=tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, zqu__EffectiveEndDate__c=system.today().addDays(50)));
            mapKey.put('EffectiveTo', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1')))));
            tierToUpdate = mapZId_Tier.get('p4r1c1t1');
            lstUpdate.add(new Product2(Id=mapZProductId_Product.get(tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c).Id, SAP_Material_Number__c='YYY'));
            mapKey.put('Material', svc.buildDiscardKey(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1')))));
            // ensure update will happen and arrange for scenario
            for (IEC_ZuoraPricing2SAP_Tracking__c tracking : mapKey_Tracking.values())
            {
                tracking.Operation__c = svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS);
                tracking.LatestSourceTimestamp__c = system.now().addDays(-1);
                tracking.SendingTimestamp__c = system.now();
                lstUpdate.add(tracking);
            }
            lstUpdate.sort();   // prevent error of 10 chunks in a single operation
            update lstUpdate;
            mapZProductId_Product = svc.getTrackingProduct();
            mapZId_Tier = getZuoraPricing(mapZProductId_Product);
            svc.trackPricing(mapZId_Tier.values(), mapZProductId_Product);
            mapKey_Tracking = getTracking();
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.UNIT), 'New price type is Unit Price');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r2c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('VolumeToUnit')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('VolumeToUnit')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).EndingUnit__c, 99, 'New ending unit');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('VolumeEndUnit')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('VolumeEndUnit')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).StartingUnit__c, 100, 'New starting unit');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r3c1t2'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('VolumeStartUnit')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('VolumeStartUnit')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.DISCOUNT_AMT), 'New price type is Discount Fix Amount');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r4c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('CouponAmountToDiscount')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('CouponAmountToDiscount')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.DISCOUNT_PCT), 'New price type is Discount Percentage');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r5c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('CouponPctToDiscount')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('CouponPctToDiscount')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.COUPON_AMT), 'New price type is Coupon Fix Amount');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r6c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('DiscountAmountToCoupon')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('DiscountAmountToCoupon')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).Pricing_Type__c, svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.COUPON_PCT), 'New price type is Coupon Percentage');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r7c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('DiscountPctToCoupon')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('DiscountPctToCoupon')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1'))).Currency__c, 'BBB', 'New currency');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r8c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('Currency')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('Currency')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1'))).CustomerType__c, 'YYY', 'New customer type');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3r9c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('CustomerType')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('CustomerType')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1'))).EffectiveFrom__c, system.today().addDays(50), 'New customer type');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rXc1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('EffectiveFrom')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('EffectiveFrom')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1'))).EffectiveTo__c, system.today().addDays(50), 'New customer type');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p3rYc1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('EffectiveTo')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('EffectiveTo')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).Material_Number__c, 'YYY', 'New SAP material number');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS), 'Updated pricing should have operation INSERT');
            system.assertEquals(mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1'))).SendingTimestamp__c, null, 'Updated pricing is to send to SAP');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('Material')).Operation__c, svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL), 'Deleted pricing should have operation DELETE');
            system.assertEquals(mapKey_Tracking.get(mapKey.get('Material')).SendingTimestamp__c, null, 'Deleted pricing is to send to SAP');
            
            // cover exceptions
            lstUpdate.clear();
            tierToUpdate = mapZId_Tier.get('p4r1c1t1');
            lstUpdate.add(new Product2(Id=mapZProductId_Product.get(tierToUpdate.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c).Id, SAP_Material_Number__c='CCC'));
            trackingToUpdate = mapKey_Tracking.get(svc.buildTrackingKey(mapZId_Tier.get('p4r1c1t1')));
            trackingToUpdate.LatestSourceTimestamp__c = system.now().addDays(-1);
            lstUpdate.add(trackingToUpdate);
            update lstUpdate;
            trackingToUpdate.Key__c = svc.buildDiscardKey(trackingToUpdate);
            trackingToUpdate.Id = null;
            insert trackingToUpdate;   // to cause exception on update first following by insert
            mapZProductId_Product = svc.getTrackingProduct();
            mapZId_Tier = getZuoraPricing(mapZProductId_Product);
            svc.trackPricing(mapZId_Tier.values(), mapZProductId_Product);
            mapKey_Tracking = getTracking();
            system.assertEquals(2, [select count() from IEC_Error_Log__c], 'Should have 2 errors');
        Test.stopTest();
    }


    // cover code for method "sendPricing" which indirectly cover following methods
    //      sendPricingByOperation, sendPricingCallout, buildSAPDate, initializeOutputXML, addPricingToOutputXML, getOutputXML
    @isTest static void testSendPricing()
    {
        IEC_ZuoraPricing2SAP_Svc svc = new IEC_ZuoraPricing2SAP_Svc();
        // cannot use following to generate tracking data because it raises error "You cannot make callout after creating a Savepoint"
        //Map<Id, Product2> mapZProductId_Product = svc.getTrackingProduct();
        //Map<String, zqu__ProductRatePlanChargeTier__c> mapZId_Tier = getZuoraPricing(mapZProductId_Product);
        //svc.trackPricing(mapZId_Tier.values(), mapZProductId_Product);
        List<IEC_ZuoraPricing2SAP_Tracking__c> lstTracking = new List<IEC_ZuoraPricing2SAP_Tracking__c>();
        for (Integer ix = 10; ix < 20; ix++)
            lstTracking.add(new IEC_ZuoraPricing2SAP_Tracking__c(Operation__c=svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.INS)
                                , EffectiveFrom__c=system.today(), EffectiveTo__c=system.today().addDays(100), CustomerType__c='Type'+ix
                                , Key__c='Key'+ix, Material_Number__c='Mat'+ix, Currency__c='USD', AmountOrPercentage__c=100
                                , Pricing_Type__c=svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.UNIT), StartingUnit__c=1));
        // cause failure
        lstTracking.add(new IEC_ZuoraPricing2SAP_Tracking__c(Operation__c=svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL)
                            , EffectiveFrom__c=system.today(), EffectiveTo__c=system.today().addDays(100), CustomerType__c=null
                            , Key__c='KeyX1', Material_Number__c='MatX1', Currency__c='USD', AmountOrPercentage__c=100
                            , Pricing_Type__c=svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.VOLUME), StartingUnit__c=1, EndingUnit__c=99));
        lstTracking.add(new IEC_ZuoraPricing2SAP_Tracking__c(Operation__c=svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL)
                            , EffectiveFrom__c=system.today(), EffectiveTo__c=system.today().addDays(100), CustomerType__c=null
                            , Key__c='KeyX2', Material_Number__c='MatX1', Currency__c='USD', AmountOrPercentage__c=100
                            , Pricing_Type__c=svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.VOLUME), StartingUnit__c=100));
        lstTracking.add(new IEC_ZuoraPricing2SAP_Tracking__c(Operation__c=svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL)
                            , EffectiveFrom__c=system.today(), EffectiveTo__c=system.today().addDays(100), CustomerType__c=null
                            , Key__c='KeyX3', Material_Number__c='MatX2', Currency__c='USD', AmountOrPercentage__c=100
                            , Pricing_Type__c=svc.sapPrice.get(IEC_ZuoraPricing2SAP_Svc.sapPT.VOLUME)));
        insert lstTracking;
        TestDataGenerator.generateApexSetting();
        Test.startTest();
            Integer intCheckError = [select count() from IEC_Error_Log__c];
            Test.setMock(HttpCalloutMock.class, new IEC_ZuoraPricing2SAP_HTTP_Mock());
            svc.sendPricing(lstTracking);
            system.assertEquals(intCheckError + 1, [select count() from IEC_Error_Log__c], 'Must have 1 error');
            system.assertEquals(3, [select count() from IEC_ZuoraPricing2SAP_Tracking__c where SendingTimestamp__c = null], 'Must have 3 tracking not sent because error');
            system.assertEquals(lstTracking.size() - 3, [select count() from IEC_ZuoraPricing2SAP_Tracking__c where SendingTimestamp__c != null], 'Must have 3 tracking not sent because error');
        Test.stopTest();
    }
}