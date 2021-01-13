public with sharing class ProductRatePlanChargeTier_Sel extends Selector 
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> 
		{
			zqu__ProductRatePlanChargeTier__c.Id,
			zqu__ProductRatePlanChargeTier__c.Name,
			zqu__ProductRatePlanChargeTier__c.zqu__ProductRatePlanCharge__c,
			zqu__ProductRatePlanChargeTier__c.zqu__Currency__c,
			zqu__ProductRatePlanChargeTier__c.zqu__Price__c,
			zqu__ProductRatePlanChargeTier__c.zqu__IsOveragePrice__c,
			zqu__ProductRatePlanChargeTier__c.zqu__PriceFormat__c,
			zqu__ProductRatePlanChargeTier__c.zqu__EndingUnit__c,
			zqu__ProductRatePlanChargeTier__c.zqu__StartingUnit__c,
			zqu__ProductRatePlanChargeTier__c.zqu__Tier__c,
			zqu__ProductRatePlanChargeTier__c.zqu__ZuoraId__c,
			zqu__ProductRatePlanChargeTier__c.zqu__Deleted__c,

			zqu__ProductRatePlanChargeTier__c.Product_Number__c,
			zqu__ProductRatePlanChargeTier__c.ZProduct_EffectiveStartDate__c,
			zqu__ProductRatePlanChargeTier__c.ZProduct_EffectiveEndDate__c,
			zqu__ProductRatePlanChargeTier__c.ZProduct_Deleted__c,
			zqu__ProductRatePlanChargeTier__c.ZProduct_ZuoraId__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_Name__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_Deleted__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_EffectiveStartDate__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_EffectiveEndDate__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_CustomerType__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_Country__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_Region__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_CouponCode__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_ZuoraId__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_IsFreeShipping__c,
			zqu__ProductRatePlanChargeTier__c.ZRatePlan_IsPreSale__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_DefaultQuantity__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_Deleted__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_Discount_Level__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_ListPrice__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_MaxQuantity__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_MinQuantity__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_Model__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_Type__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_UOM__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_Name__c,
			zqu__ProductRatePlanChargeTier__c.ZCharge_ZuoraId__c

		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return zqu__ProductRatePlanChargeTier__c.sObjectType;
	}

	public List<zqu__ProductRatePlanChargeTier__c> getActiveTiers(Set<String> zChargeIds)
	{
		String query = String.format(
			'SELECT {0}  ' + 
			'FROM {1} ' + 
			'WHERE zqu__ProductRatePlanCharge__c IN :zChargeIds  '  + 
			'  AND zqu__Deleted__c!=true', 
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		return Database.query(query);
	}

	public List<zqu__ProductRatePlanChargeTier__c> getProductTiers(Set<String> productNumbers)
	{
		String query = String.format(
			'SELECT {0}  ' + 
			'FROM {1} ' + 
			'WHERE Product_Number__c IN :productNumbers  '  + 
			'  AND ZProduct_Deleted__c!=true AND ZRatePlan_Deleted__c!=true AND ZCharge_Deleted__c!=true AND zqu__Deleted__c!=true ' +
			'  AND ZProduct_EffectiveStartDate__c <= TODAY AND ZProduct_EffectiveEndDate__c >= TODAY ' + 
			'  AND ZRatePlan_EffectiveStartDate__c <= TODAY AND ZRatePlan_EffectiveEndDate__c >= TODAY ', 
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		System.debug('ztier query::'+query);
		List<zqu__ProductRatePlanChargeTier__c> result = Database.query(query);
		System.debug('ztier result::'+result);
		return result;

		//return Database.query(query);
	}


	public List<zqu__ProductRatePlanChargeTier__c> getProductTiers(Set<String> productNumbers, String customerType, String customerRegion, String customerCountry)
	{
		String soqlStr = 'SELECT {0}  ' + 
				'FROM {1} ' + 
				'WHERE Product_Number__c IN :productNumbers  ' ; 

		if(String.isNotBlank(customerType)) soqlStr += '  AND (ZRatePlan_CustomerType__c=null OR ZRatePlan_CustomerType__c= :customerType)' ;
		if(String.isNotBlank(customerRegion)) soqlStr +=  '  AND (ZRatePlan_Region__c=null OR ZRatePlan_Region__c= :customerRegion)';
		if(String.isNotBlank(customerCountry)) soqlStr +=  '  AND (ZRatePlan_Country__c=null OR ZRatePlan_Country__c= :customerCountry)';

		soqlStr += '  AND ZProduct_Deleted__c!=true AND ZRatePlan_Deleted__c!=true AND ZCharge_Deleted__c!=true AND zqu__Deleted__c!=true ' +
				'  AND ZProduct_EffectiveStartDate__c <= TODAY AND ZProduct_EffectiveEndDate__c >= TODAY ' + 
				'  AND ZRatePlan_EffectiveStartDate__c <= TODAY AND ZRatePlan_EffectiveEndDate__c >= TODAY ';

		String query = String.format(soqlStr, new List<String>{
			String.join(getDefaultFields(), ', '),
			getSObjectType().getDescribe().getName()
		});

		List<zqu__ProductRatePlanChargeTier__c> result = Database.query(query);
		System.debug('ztier result::'+result);
		return result;
	}

	// Get the charge tiers based on specified rateplan zuora Ids
	public List<zqu__ProductRatePlanChargeTier__c> getProductTiersByRatePlan(Set<String> ratePlanZIds)
	{
		String query = String.format(
			'SELECT {0}  ' + 
			'FROM {1} ' + 
			'WHERE ZRatePlan_ZuoraId__c IN :ratePlanZIds  '  + 
			'  AND ZProduct_Deleted__c!=true AND ZRatePlan_Deleted__c!=true AND ZCharge_Deleted__c!=true AND zqu__Deleted__c!=true ' +
			'  AND ZProduct_EffectiveStartDate__c <= TODAY AND ZProduct_EffectiveEndDate__c >= TODAY ' + 
			'  AND ZRatePlan_EffectiveStartDate__c <= TODAY AND ZRatePlan_EffectiveEndDate__c >= TODAY ', 
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);
		List<zqu__ProductRatePlanChargeTier__c> result = Database.query(query);
		return result;
	}

	public static Boolean isStandardPrice(zqu__ProductRatePlanChargeTier__c zTier)
	{
		return (String.isBlank(zTier.ZRatePlan_CustomerType__c) 
			&& String.isBlank(zTier.ZRatePlan_Region__c) 
			&& String.isBlank(zTier.ZRatePlan_Country__c)
			&& String.isBlank(zTier.ZRatePlan_CouponCode__c)
			&& (zTier.ZRatePlan_IsPreSale__c != 'Yes')
		);
	}
}