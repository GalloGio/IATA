public with sharing class OrderItemCharge_Sel  extends Selector
{
	/****************************************************************************************************
		Created by CGI - David
			return list fields for dynamic query
	****************************************************************************************************/
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
			Order_Item_Charge__c.Id,
			Order_Item_Charge__c.Name,
			Order_Item_Charge__c.Discount_Amount__c,
			Order_Item_Charge__c.Discount_Percentage__c,
			Order_Item_Charge__c.Discount_Type__c,
			Order_Item_Charge__c.Order_Item__c,
			Order_Item_Charge__c.Zuora_Rate_Plan_Charge_Id__c,
			Order_Item_Charge__c.Zuora_Rate_Plan_Id__c
		};
	}

	/****************************************************************************************************
		Created by CGI - David
			return Order_Item_Charge__c for dynamic query
	****************************************************************************************************/
	public Schema.SObjectType getSObjectType()
	{
		return Order_Item_Charge__c.sObjectType;
	}

	/****************************************************************************************************
		Created by CGI - David
			return List of Charges (discounts) for each OrderItemId
	****************************************************************************************************/
	public Map<Id, List<Order_Item_Charge__c>> getChargesByOrerItem(Set<Id> orderItemIds)
	{
		Map<Id, List<Order_Item_Charge__c>> ret = new Map<Id, List<Order_Item_Charge__c>>();

		List<Order_Item_Charge__c> charges = (List<Order_Item_Charge__c>) selectSObjectByField('Order_Item__c', IdToString(orderItemIds));

		for(Order_Item_Charge__c c : charges)
		{
			List<Order_Item_Charge__c> tmp = (ret.containsKey(c.Order_Item__c)) ? ret.get(c.Order_Item__c) : new List<Order_Item_Charge__c>();
				tmp.add(c);

			ret.put(c.Order_Item__c, tmp);
		}

		return ret;
	}
}
