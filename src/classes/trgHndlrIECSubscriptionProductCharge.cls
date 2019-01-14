/**  
  * Description: Trigger Handler for the Zuora Subscription Product Charge object
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
public with sharing class trgHndlrIECSubscriptionProductCharge {
    public static void OnBeforeInsert(List<Zuora__SubscriptionProductCharge__c> newRecords, Map<Id, Zuora__SubscriptionProductCharge__c> newRecordsMap) {
        BuildProductLink(newRecords);
    }

    public static void OnBeforeUpdate(List<Zuora__SubscriptionProductCharge__c> newRecords, Map<Id, Zuora__SubscriptionProductCharge__c> newRecordsMap, List<Zuora__SubscriptionProductCharge__c> oldRecords, Map<Id, Zuora__SubscriptionProductCharge__c> oldRecordsMap) {
        BuildProductLink(newRecords);
    }
    
    private static void BuildProductLink(List<Zuora__SubscriptionProductCharge__c> lstCharges) {
        // Retrieve unique key set of Rate Plan Names & Charges
        Set<String> setRatePlanName = new Set<String>();
        Set<String> setRatePlanChargeName = new Set<String>();
        
        for (Zuora__SubscriptionProductCharge__c charge : lstCharges) {
            setRatePlanName.add(charge.Zuora__RatePlanName__c);
            setRatePlanChargeName.add(charge.Name);
        }

        // Build a map of rateplan charge names and their corresponding IDs
        Map<String, zqu__ProductRatePlanCharge__c> mapRatePlanCharge = new Map<String, zqu__ProductRatePlanCharge__c>();
        for (zqu__ProductRatePlanCharge__c ratePlanCharge:
            [SELECT Id, Name, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.Name
                , zqu__ProductRatePlan__r.zqu__ZProduct__r.Name, zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c
            FROM zqu__ProductRatePlanCharge__c
            WHERE Name IN :setRatePlanChargeName
                AND zqu__ProductRatePlan__r.Name IN :setRatePlanName])
        {
            string key = ratePlanCharge.Name + '|' + ratePlanCharge.zqu__ProductRatePlan__r.Name + '|' + ratePlanCharge.zqu__ProductRatePlan__r.zqu__ZProduct__r.Name + '|' + ratePlanCharge.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c;
            if(!mapRatePlanCharge.containsKey(key))
                mapRatePlanCharge.put(key, ratePlanCharge);
        }
        
        // Retrieve map of Parent Subscription Id, and their corresponding Rate Plan Id
        Map<Id, Id> mapParentSubscription_to_RatePlanId = new Map<Id, Id>();
        
        // Match the rateplan & product name against what is in salesforce to populate the "Product Rate Plan" & "Product Rate Plan Charge" fields
        for (Zuora__SubscriptionProductCharge__c charge : lstCharges) {
            string key = charge.Name + '|' + charge.Zuora__RatePlanName__c + '|' + charge.Zuora__ProductName__c + '|' + charge.Zuora__ProductSKU__c;

            if (mapRatePlanCharge.containsKey(key)) {
                zqu__ProductRatePlanCharge__c ratePlanCharge = mapRatePlanCharge.get(key);
                charge.Product_Rate_Plan_Charge__c = ratePlanCharge.Id;

                // Capture Rate Plan to assign it to parent subscription
                //*** (Thai 2016-11-09) exclude shipping & tax rate plan to set to subscription
                if (!mapParentSubscription_to_RatePlanId.containsKey(charge.Zuora__Subscription__c) &&
                    !'Shipping,Tax'.containsIgnoreCase(charge.Zuora__RatePlanName__c))
                    mapParentSubscription_to_RatePlanId.put(charge.Zuora__Subscription__c, ratePlanCharge.zqu__ProductRatePlan__c);
            }
        }
        
        // Retrieve parent Subscription
        Map<Id, Zuora__Subscription__c> mapSubscription = new Map<Id, Zuora__Subscription__c> (
                [SELECT Id, Product_Rate_Plan_Information__c
                FROM Zuora__Subscription__c
                WHERE Id IN :mapParentSubscription_to_RatePlanId.keySet()]
            );

        // Retrieve Product Rate Plan and their corresponding Information object
        Map<Id, Id> mapProdRatePlan_to_Info = new Map<Id, Id>();
        for (Product_Rate_Plan_Information__c ratePlanInfo :
            [SELECT Id, Product_Rate_Plan__c
            FROM Product_Rate_Plan_Information__c
            WHERE Product_Rate_Plan__c IN :mapParentSubscription_to_RatePlanId.values()
                AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                AND Active__c = true                
                AND Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveEndDate__c >= TODAY
                AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY
                AND Product_Rate_Plan__r.zqu__Deleted__c = false])
        {
            mapProdRatePlan_to_Info.put(ratePlanInfo.Product_Rate_Plan__c, ratePlanInfo.Id);
        }
        
        
        // ### Now update parent subscription to link them to the corresponding Product Rate Plan Info Object
        for(Id idSub: mapParentSubscription_to_RatePlanId.keySet()) {
            mapSubscription.get(idSub).Product_Rate_Plan_Information__c = mapProdRatePlan_to_Info.get(mapParentSubscription_to_RatePlanId.get(idSub));
        }
        
        update mapSubscription.values();
    }
}