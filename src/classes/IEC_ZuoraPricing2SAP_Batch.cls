global class IEC_ZuoraPricing2SAP_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    //****************************************************************************************************
    //  Batch to send Zuora pricing to SAP
    //****************************************************************************************************
    public static final String processingStep1 = 'Track changes';
    public static final String processingStep2 = 'Send to SAP';
    String strProcessingStep;
    Map<Id, Product2> mapZProductId_Product;


    // constructor - used to specify step to execute
    global IEC_ZuoraPricing2SAP_Batch(String strRequestStep)
    {
        strProcessingStep = strRequestStep;
    }



    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        if (strProcessingStep == processingStep1)
        {
            // get products to track Zuora pricing
            mapZProductId_Product = new IEC_ZuoraPricing2SAP_Svc().getTrackingProduct();
            
            // query Zuora pricing to track
            return Database.getQueryLocator([select Id, CurrencyIsoCode, IsDeleted
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
                        and ZRatePlan_CouponCode__c = null
                        and zqu__ProductRatePlanCharge__r.zqu__Model__c in ('Per Unit', 'Per Unit Pricing', 'Volume', 'Volume Pricing'
                                                                          , 'Discount-Fixed Amount', 'Discount-Percentage')
                      order by zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c
                             , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c
                             , zqu__ProductRatePlanCharge__c
                             , zqu__Tier__c
                      ALL ROWS]);
        }
        else if (strProcessingStep == processingStep2)
        {
            // should order tracked data by operation to send the deletion first to prevent possible conflicts on SAP
            return Database.getQueryLocator([select Operation__c, Material_Number__c, CustomerType__c, Currency__c
                                                  , Pricing_Type__c, EffectiveFrom__c, EffectiveTo__c
                                                  , StartingUnit__c, EndingUnit__c, AmountOrPercentage__c
                                             from IEC_ZuoraPricing2SAP_Tracking__c
                                             where SendingTimestamp__c = null
                                             order by Operation__c, Material_Number__c, Id]);
        }
        else
            // when batch was wrongly invoked
            return Database.getQueryLocator([select Id from Product2 where Id = null]);
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        IEC_ZuoraPricing2SAP_Svc svc = new IEC_ZuoraPricing2SAP_Svc();
        // save changed pricing information to tracking table 
        if (strProcessingStep == processingStep1 && scope.size() > 0)
            svc.trackPricing((List<zqu__ProductRatePlanChargeTier__c>)scope, mapZProductId_Product);
        // send pricing information to SAP
        else if (strProcessingStep == processingStep2 && scope.size() > 0)
            svc.sendPricing((List<IEC_ZuoraPricing2SAP_Tracking__c>)scope);
    }


    global void finish(Database.BatchableContext BC) 
    {
        // send pricing to SAP after tracking changes
        if (strProcessingStep == processingStep1)
            Database.executeBatch(new IEC_ZuoraPricing2SAP_Batch(processingStep2), 2000);
        // send notification to support after sending pricing to SAP
        else if (strProcessingStep == processingStep2 && Boolean.valueOf(Utility.getTextSetting('ZuoraPricing2SAP Notify Job Completion')))
            TransformationHelper.sendEmailSupport('Zuora Pricing 2 SAP', 'Job complete at ' + system.now().format('yyyy-MM-dd HH:mm:ss'));
    }
}