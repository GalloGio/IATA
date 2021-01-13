public with sharing class ProductRatePlanCharge_Sel /*extends Selector*/
{
	/*public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
			zqu__ProductRatePlanCharge__c.Id,
			zqu__ProductRatePlanCharge__c.Name,
			zqu__ProductRatePlanCharge__c.zqu__ProductRatePlan__c,
			zqu__ProductRatePlanCharge__c.zqu__AccountingCode__c,
			zqu__ProductRatePlanCharge__c.zqu__Apply_Discount_To_One_Time_Charges__c,
			zqu__ProductRatePlanCharge__c.zqu__Apply_Discount_To_Recurring_Charges__c,
			zqu__ProductRatePlanCharge__c.zqu__Apply_Discount_To_Usage_Charges__c,
			zqu__ProductRatePlanCharge__c.zqu__DefaultQuantity__c,
			zqu__ProductRatePlanCharge__c.zqu__Deleted__c,
			zqu__ProductRatePlanCharge__c.zqu__Description__c,
			zqu__ProductRatePlanCharge__c.zqu__Discount_Apply_Type__c,
			zqu__ProductRatePlanCharge__c.zqu__Discount_Level__c,
			zqu__ProductRatePlanCharge__c.zqu__ListPrice__c,
			zqu__ProductRatePlanCharge__c.zqu__MaxQuantity__c,
			zqu__ProductRatePlanCharge__c.zqu__MinQuantity__c,
			zqu__ProductRatePlanCharge__c.zqu__Model__c,
			zqu__ProductRatePlanCharge__c.zqu__PrepaymentPeriods__c,
			zqu__ProductRatePlanCharge__c.zqu__PriceTable__c,
			zqu__ProductRatePlanCharge__c.zqu__RecurringPeriod__c,
			zqu__ProductRatePlanCharge__c.zqu__RevRecCode__c,
			zqu__ProductRatePlanCharge__c.zqu__TaxCode__c,
			zqu__ProductRatePlanCharge__c.zqu__Type__c,
			zqu__ProductRatePlanCharge__c.zqu__UOM__c,
			zqu__ProductRatePlanCharge__c.zqu__Upto_How_Many_Periods__c,
			zqu__ProductRatePlanCharge__c.zqu__ZuoraId__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return zqu__ProductRatePlanCharge__c.sObjectType;
	}*/

	/*public List<zqu__ProductRatePlanCharge__c> getActiveCharges(Set<String> zRatePlanIds)
	{
		String query = String.format(
			'SELECT {0}  ' +
			'FROM {1} ' +
			'WHERE zqu__ProductRatePlan__c IN :zRatePlanIds  '  +
			'  AND zqu__Deleted__c=false',
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		return Database.query(query);
	}*/

	public static list<zqu__ProductRatePlanCharge__c> getChargesToSetToZero(String planId, String chargeId){

		list<zqu__ProductRatePlanCharge__c> prpc = [Select
														zqu__ZuoraId__c,
														zqu__ProductRatePlan__r.zqu__ZuoraId__c,
														zqu__ProductRatePlan__c,
														zqu__Model__c,
														Name,
														Id
													 From zqu__ProductRatePlanCharge__c
													 where zqu__ProductRatePlan__r.zqu__ZuoraId__c = :planId
													 and zqu__ZuoraId__c <> :chargeId
													 and zqu__Deleted__c = false];
		return prpc;
	}

	public static List<zqu__ProductRatePlanCharge__c> getProductRatePlanChargeByRatePlanId(set<Id> productRatePlanIds){
		return [select id,zqu__Model__c,zqu__ListPrice__c,zqu__ProductRatePlan__c
																				from zqu__ProductRatePlanCharge__c
																				where zqu__ProductRatePlan__c in :productRatePlanIds];
	}

	//Set the Product Rate Plan Charge pricing model by Zuora Id
	public static Map<String,String> getProductRatePlanChargeModelByZuoraId(set<String> zuoraIds){

		Map<String,String> productRatePlanChargeModelByZuoraId = new Map<String,String>();

		List<zqu__ProductRatePlanCharge__c> lstZproductRatePlanCharge = [select id, zqu__Model__c, zqu__ZuoraId__c
																			from zqu__ProductRatePlanCharge__c
																		where zqu__ZuoraId__c in :zuoraIds ];

		if(lstZproductRatePlanCharge != null && !lstZproductRatePlanCharge.isEmpty()){
			for(zqu__ProductRatePlanCharge__c prpc : lstZproductRatePlanCharge){
				productRatePlanChargeModelByZuoraId.put(prpc.zqu__ZuoraId__c, prpc.zqu__Model__c);
			}
		}
		return productRatePlanChargeModelByZuoraId;
	}

}
