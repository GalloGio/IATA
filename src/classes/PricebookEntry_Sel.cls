public with sharing class PricebookEntry_Sel extends Selector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> 
		{
			PricebookEntry.Id,
			PricebookEntry.Pricebook2Id,
			PricebookEntry.Product2Id,
			PricebookEntry.UnitPrice
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return PricebookEntry.sObjectType;
	}

	/****************************************************************************************************
        Created by CGI - David
            this function list pricebookEntries for given pricebook and products
    ****************************************************************************************************/
    public Map<Id, PricebookEntry> getPricebookEntryByProductId(Id pricebookId, Set<Id> productId)
    {
    	Map<Id, PricebookEntry> ret = new Map<Id, PricebookEntry>();

    	String query = String.format(
			'SELECT {0}  ' + 
			'FROM {1} ' + 
			'WHERE Pricebook2Id = :pricebookId AND Product2Id IN :productId ' , 
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<PricebookEntry> pricebookEntries = Database.query(query);

		for(PricebookEntry pbe : pricebookEntries)
		{
			ret.put(pbe.Product2Id, pbe);
		}

		return ret;
    }

    /****************************************************************************************************
        getPricebookEntryByProductId, function that retrieves a list of pricebookEntries for given
        							 pricebook and product
        @Id pricebookId, Id of the pricebook
        @Id productId, Id of the product
        @return, list of priceEntry by ProductId
        
        Author: Ângela Lázaro 
    ****************************************************************************************************/
	public Map<Id, PricebookEntry> getPricebookEntryByProductId(Id pricebookId, Id productId)
    {
    	Map<Id, PricebookEntry> ret = new Map<Id, PricebookEntry>();

    	String query = String.format(
			'SELECT {0}  ' + 
			'FROM {1} ' + 
			'WHERE Pricebook2Id = :pricebookId AND Product2Id = :productId ' , 
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<PricebookEntry> pricebookEntries = Database.query(query);

		for(PricebookEntry pbe : pricebookEntries)
		{
			ret.put(pbe.Product2Id, pbe);
		}

		return ret;
    }
}