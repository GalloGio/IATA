/*
 * Test Coverage is provided under the vfIECRenew_tst class
 */
public class IEC_ZSubscriptionProductCharge_Sel extends Selector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Zuora__SubscriptionProductCharge__c.Id,
			Zuora__SubscriptionProductCharge__c.Zuora__Price__c,
			Zuora__SubscriptionProductCharge__c.Zuora__Type__c,
			Zuora__SubscriptionProductCharge__c.Zuora__Zuora_Id__c,
			Zuora__SubscriptionProductCharge__c.Zuora__Quantity__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Zuora__SubscriptionProductCharge__c.sObjectType;
	}

	public Map<String, List<Zuora__SubscriptionProductCharge__c>> getZSubscriptionProductChargeByProdRatePlanChargeZId(Set<String> setSubscriptionZId, Set<String> setChargeZIds, Boolean bIncludeChargeZIds, String sAdditionalWhere)
	{
		String query = String.format(
			'SELECT {0}  ' +
			'	, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c ' +
			'	, Product_Rate_Plan_Charge__r.zqu__ZuoraId__c ' +
			'	, Zuora__Subscription__r.Zuora__External_Id__c ' +
			'FROM {1} ' +
			'WHERE Product_Rate_Plan_Charge__r.zqu__ZuoraId__c' + (bIncludeChargeZIds ? '' : ' NOT') + ' IN :setChargeZIds '
			+ '	AND Zuora__Subscription__r.Zuora__External_Id__c IN :setSubscriptionZId '
				+ (String.isBlank(sAdditionalWhere) ? '' : ' AND ' + sAdditionalWhere),
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<Zuora__SubscriptionProductCharge__c> lstCharges = Database.query(query);

		Map<String, List<Zuora__SubscriptionProductCharge__c>> mapSubscriptionCharges = new Map<String, List<Zuora__SubscriptionProductCharge__c>>();

		if (lstCharges != null && !lstCharges.isEmpty())
		{
			for (Zuora__SubscriptionProductCharge__c oSubChrg : lstCharges)
			{
				if (mapSubscriptionCharges.containsKey(oSubChrg.Zuora__Subscription__r.Zuora__External_Id__c))
					mapSubscriptionCharges.get(oSubChrg.Zuora__Subscription__r.Zuora__External_Id__c).add(oSubChrg);
				else
					mapSubscriptionCharges.put(oSubChrg.Zuora__Subscription__r.Zuora__External_Id__c, new List<Zuora__SubscriptionProductCharge__c> {oSubChrg});
			}
		}

		return mapSubscriptionCharges;
	}
}
