public without sharing class IEC_EventRelease_Sel extends Selector {
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
			IEC_Event_Release__c.Id,
			IEC_Event_Release__c.Name,
			IEC_Event_Release__c.Nb_Customer__c,
			IEC_Event_Release__c.Product__c,
			IEC_Event_Release__c.Material_Number__c,
			IEC_Event_Release__c.Last_Version__c,
			IEC_Event_Release__c.Product_Last_Version__c,
			IEC_Event_Release__c.Swapped_Product__c,
			IEC_Event_Release__c.Product_Number__c,
			IEC_Event_Release__c.Released__c,
			IEC_Event_Release__c.Customer_Type__c,
			IEC_Event_Release__c.Processing_Status__c,
			IEC_Event_Release__c.Sales_Amout__c,
			IEC_Event_Release__c.Sales_Quantity__c,
			IEC_Event_Release__c.Processing_Message__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return IEC_Event_Release__c.sObjectType;
	}

	public map<Id,IEC_Event_Release__c> getEventReleaseById(set<Id> releaseIds){
		String query = String.format(
			'SELECT {0}  ' +
			'FROM {1} ' +
			'WHERE Id IN :releaseIds ' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		return new map<Id,IEC_Event_Release__c>((List<IEC_Event_Release__c>)Database.query(query));
	}
}
