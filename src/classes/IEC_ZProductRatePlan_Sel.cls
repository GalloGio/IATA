/*
 * Test Coverage is provided under the IEC_REST_Zuora_Test class
 */
public class IEC_ZProductRatePlan_Sel extends Selector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			zqu__ProductRatePlan__c.Id,
			zqu__ProductRatePlan__c.Name,
			zqu__ProductRatePlan__c.Product_Number__c,
			zqu__ProductRatePlan__c.zqu__ZuoraId__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return zqu__ProductRatePlan__c.sObjectType;
	}

	public List<zqu__ProductRatePlan__c> getZProductRatePlanByZId(Set<String> setZuoraIds)
	{
		String query = String.format(
			'SELECT {0}  ' +
			'FROM {1} ' +
			'WHERE zqu__ZuoraId__c IN :setZuoraIds ' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		return Database.query(query);
	}
}
