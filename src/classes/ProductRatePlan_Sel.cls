public with sharing class ProductRatePlan_Sel extends Selector
{
	public List<Schema.SObjectField> getSObjectFieldList()	{
		return new List<Schema.SObjectField> {
			zqu__ProductRatePlan__c.Id,
			zqu__ProductRatePlan__c.Name,
			zqu__ProductRatePlan__c.CustomerType__c,
			zqu__ProductRatePlan__c.zqu__Deleted__c, 
			zqu__ProductRatePlan__c.zqu__Description__c,
			zqu__ProductRatePlan__c.zqu__EffectiveEndDate__c,
			zqu__ProductRatePlan__c.zqu__EffectiveStartDate__c,
			zqu__ProductRatePlan__c.zqu__ZProduct__c,
			zqu__ProductRatePlan__c.zqu__ZuoraId__c,
			zqu__ProductRatePlan__c.FileFrequency__c,
			zqu__ProductRatePlan__c.GSSFileType__c,
			zqu__ProductRatePlan__c.GSSLocation__c,
			zqu__ProductRatePlan__c.IsTriable__c,
			zqu__ProductRatePlan__c.UIDisplay__c,
			zqu__ProductRatePlan__c.Country__c,
			zqu__ProductRatePlan__c.Couponcode__c,
			zqu__ProductRatePlan__c.Region__c,
			zqu__ProductRatePlan__c.IsFreeShipping__c
		};
	}

	public Schema.SObjectType getSObjectType()	{
		return zqu__ProductRatePlan__c.sObjectType;
	}

	/****************************************************************************************************
	    Created by CGI, David D 2015-09-22
	        Method return Map of chargeId with corresponding rate plan
	****************************************************************************************************/
	public Map<Id, zqu__ProductRatePlan__c> getRatePlanByCharge(List<zqu__ProductRatePlanCharge__c> zCharges, Boolean onlyStandardRatePlan)
	{
		Set<Id> ratePlanIds = new Set<Id>();
		Map<Id, Id> planIdByChargeId = new Map<Id, Id>(); //CHARGE_ID => RATE_PLAN_ID
		Map<Id, zqu__ProductRatePlan__c> ret = new Map<Id, zqu__ProductRatePlan__c>();

		for(zqu__ProductRatePlanCharge__c zCharge : zCharges){
			ratePlanIds.add(zCharge.zqu__ProductRatePlan__c);
			planIdByChargeId.put(zCharge.Id, zCharge.zqu__ProductRatePlan__c);
		}

		Map<Id, zqu__ProductRatePlan__c> ratePlanById = new Map<Id, zqu__ProductRatePlan__c>((List<zqu__ProductRatePlan__c>) selectSObjectById(ratePlanIds));

		for(Id chargeId : planIdByChargeId.keySet()){	
			Id planId = planIdByChargeId.get(chargeId); 

			if(ratePlanById.containsKey(planId)){
				zqu__ProductRatePlan__c ratePlan = ratePlanById.get(planId);

				if(onlyStandardRatePlan == true){
					//-- Validate RatePlan is Standard 
					if(isStandardRatePlan(ratePlan)){
						ret.put(chargeId, ratePlan);
					}
				}else{ret.put(chargeId, ratePlan);}
			}
		}
		return ret;
	}

	public static Boolean isStandardRatePlan(zqu__ProductRatePlan__c rp)
	{
		return (
			String.isBlank(rp.CustomerType__c) &&
			String.isBlank(rp.Region__c) && 
			String.isBlank(rp.Country__c) && 
			String.isBlank(rp.Couponcode__c)
		);
	}
}