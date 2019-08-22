/**
 * Class encapsulates query logic for zqu__ZProduct__c
 *
 * @author: David Daboue <daboued@iata.org>
 * @date: 2015-08-14
 *
 **/
public class ZProduct_Sel extends Selector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			zqu__ZProduct__c.Id,
			zqu__ZProduct__c.Name,
			zqu__ZProduct__c.zqu__Category__c,
			zqu__ZProduct__c.zqu__Currency__c,
			zqu__ZProduct__c.zqu__Deleted__c,
			zqu__ZProduct__c.zqu__Description__c,
			zqu__ZProduct__c.zqu__EffectiveEndDate__c,
			zqu__ZProduct__c.zqu__EffectiveEndDateTEXT__c,
			zqu__ZProduct__c.zqu__EffectiveStartDate__c,
			zqu__ZProduct__c.zqu__EffectiveStartDateTEXT__c,
			zqu__ZProduct__c.zqu__SKU__c,
			zqu__ZProduct__c.zqu__ZuoraId__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return zqu__ZProduct__c.sObjectType;
	}

	public List<zqu__ZProduct__c> selectById(Set<Id> zProductIds)
	{
		return (List<zqu__ZProduct__c>) selectSObjectById(zProductIds);
	}

	public List<zqu__ZProduct__c> selectById(Set<Id> zProductIds, List<String> fields)
	{
		return (List<zqu__ZProduct__c>) selectSObjectById(zProductIds, fields);
	}

	public String getProductQueryString(Set<String> zuoraIds)
	{
		List<String> whereItems = new List<String>(); 
		for(String i: zuoraIds)
			whereItems.add('Id = \'' + i + '\'');
		
		String zoql = 'SELECT Id, SAPProductMaterialNo__c FROM Product WHERE ' + String.join(whereItems, ' OR ');
    	return zoql;
	}

	/****************************************************************************************************
	    Created by CGI, David D 2015-09-22
	        Method return Map of ratePlanId with corresponding ZProduct
	****************************************************************************************************/
	public Map<Id, zqu__ZProduct__c> getProductByPlan(List<zqu__ProductRatePlan__c> zRatePlans)
	{
		Set<Id> zProductIds = new Set<Id>();
		Map<Id, Id> productIdByPlanId = new Map<Id, Id>(); //RATE_PLAN_ID => ZPRODUCT_ID
		Map<Id, zqu__ZProduct__c> ret = new Map<Id, zqu__ZProduct__c>();

		for(zqu__ProductRatePlan__c zRatePlan : zRatePlans)
		{
			zProductIds.add(zRatePlan.zqu__ZProduct__c);
			productIdByPlanId.put(zRatePlan.Id, zRatePlan.zqu__ZProduct__c);
		}

		Map<Id, zqu__ZProduct__c> productById = new Map<Id, zqu__ZProduct__c>((List<zqu__ZProduct__c>) selectSObjectById(zProductIds));

		for(Id planId : productIdByPlanId.keySet())
		{	
			Id productId = productIdByPlanId.get(planId); 

			if(productById.containsKey(productId))
			{
				zqu__ZProduct__c product = productById.get(productId);
				ret.put(planId, product);
			}
		}

		return ret;
	}

	/****************************************************************************************************
	    Created by CGI, David D 2015-09-22
	        Method return Map of ratePlanId with corresponding Product
	****************************************************************************************************/
	public Map<Id, Id> getProductIdByPlan(List<zqu__ProductRatePlan__c> zRatePlans)
	{
		Map<Id, Id> productIdByPlanId = new Map<Id, Id>(); //RATE_PLAN_ID => ZPRODUCT_ID
		
		for(zqu__ProductRatePlan__c zRatePlan : zRatePlans)
		{
			productIdByPlanId.put(zRatePlan.Id, zRatePlan.zqu__Product__c);
		}
		
		return productIdByPlanId;
	}
}