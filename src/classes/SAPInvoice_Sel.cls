public class SAPInvoice_Sel extends Selector
{
	/****************************************************************************************************
		Created by CGI - David
			return list fields for dynamic query
	****************************************************************************************************/
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
			SAP_Invoice__c.Id,
			SAP_Invoice__c.Name,
			SAP_Invoice__c.Clearance_Date__c,
			SAP_Invoice__c.Invoice_Number__c,
			SAP_Invoice__c.Order__c
		};
	}

	/****************************************************************************************************
		Created by CGI - David
			return SAP_Invoice__c for dynamic query
	****************************************************************************************************/
	public Schema.SObjectType getSObjectType()
	{
		return SAP_Invoice__c.sObjectType;
	}

	public Map<String, List<SAP_Invoice__c>> getOrderInvoices(Set<String> orderIds)
	{
		Map<String, List<SAP_Invoice__c>> result = new Map<String, List<SAP_Invoice__c>>();

		List<SAP_Invoice__c> invoices = (List<SAP_Invoice__c>) selectSObjectByField('Order__c',orderIds);

		for(SAP_Invoice__c invoice : invoices)
		{
			List<SAP_Invoice__c> tmp = (result.containsKey(invoice.Order__c)) ? result.get(invoice.Order__c) : new List<SAP_Invoice__c>();
				tmp.add(invoice);

			result.put(invoice.Order__c, tmp);
		}

		return result;
	}
}
