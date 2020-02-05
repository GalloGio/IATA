// Test Coverage is covered in the IECProductAccess_Svc_Test
public with sharing class IECProductAccess_Sel extends Selector {
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
			IEC_Product_Access__c.Id,
			IEC_Product_Access__c.Active__c,
			IEC_Product_Access__c.Subscription_Number__c,
			IEC_Product_Access__c.Effective_Start_Date__c,
			IEC_Product_Access__c.Effective_End_Date__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return IEC_Product_Access__c.sObjectType;
	}

	// Retrieve Inactive Product access by Subscription Number
	public List<IEC_Product_Access__c> getInactiveProductAccessBySubscriptionNumber(Set<String> setSubscriptionNumber)
	{
		String query = String.format(
			'SELECT {0}  ' +
			'FROM {1} ' +
			'WHERE Subscription_Number__c IN :setSubscriptionNumber AND Active__c = false ' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		return Database.query(query);
	}
}
