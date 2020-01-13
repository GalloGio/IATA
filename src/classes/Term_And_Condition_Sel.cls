public with sharing class Term_And_Condition_Sel extends Selector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
			Term_And_Condition__c.Id,
			Term_And_Condition__c.Name,
			Term_And_Condition__c.Effective_Start_Date__c,
			//Term_And_Condition__c.Previous_Version__c,
			Term_And_Condition__c.Status__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Term_And_Condition__c.sObjectType;
	}

	public Map<Id, List<Product_Term_Condition__c>> getRelatedProducts(Set<Id> tncIds)
	{
		Map<Id, List<Product_Term_Condition__c>> ret = new Map<Id, List<Product_Term_Condition__c>>();

		List<Product_Term_Condition__c> lst = [
			SELECT Id,
				Customer_Type__c,
				Product__c,
				Term_Condition__c
			FROM  Product_Term_Condition__c
			WHERE Term_Condition__c IN :tncIds
		];

		for(Product_Term_Condition__c ptc : lst)
		{
			List<Product_Term_Condition__c> tmp = (ret.containsKey(ptc.Term_Condition__c)) ? ret.get(ptc.Term_Condition__c) : new List<Product_Term_Condition__c>();
				tmp.add(ptc);
			ret.put(ptc.Term_Condition__c, tmp);
		}

		return ret;
	}

	 /****************************************************************************************************
		Created by David D 2015-10-20
			Return List of terms & conditions for each product based on Customer Type
	****************************************************************************************************/
	public Map<Id, List<Product_Term_Condition__c>> getActiveTermsAndConditions(String customerType, Set<Id> productIds)
	{
		Map<Id, List<Product_Term_Condition__c>> ret = new Map<Id, List<Product_Term_Condition__c>>();

		List<Product_Term_Condition__c> lst_prod_tnc = [
			SELECT  Id,
				Product__c,
				Is_Active__c,
			   	Customer_Type__c,
				Term_Condition__c,
					Term_Condition__r.Name,
					Term_Condition__r.Effective_Start_Date__c,
					Term_Condition__r.Version_Number__c,
					Term_Condition__r.Status__c
			FROM Product_Term_Condition__c
			WHERE Is_Active__c = true
				AND Term_Condition__r.Status__c = 'Final'
				AND Customer_Type__c INCLUDES(:customerType)
				AND Product__c IN :productIds
		];

		for(Product_Term_Condition__c ptc: lst_prod_tnc)
		{
			List<Product_Term_Condition__c> tmp = (ret.containsKey(ptc.Product__c)) ? ret.get(ptc.Product__c) : new List<Product_Term_Condition__c>();
				tmp.add(ptc);
			ret.put(ptc.Product__c, tmp);
		}

		return ret;
	}

	public Map<Id, List<Product_Term_Condition__c>> getActiveTermsAndConditions(Set<Id> productIds)
	{
		Map<Id, List<Product_Term_Condition__c>> ret = new Map<Id, List<Product_Term_Condition__c>>();

		List<Product_Term_Condition__c> lst_prod_tnc = [
			SELECT  Id,
				Product__c,
				Is_Active__c,
			   	Customer_Type__c,
				Term_Condition__c,
					Term_Condition__r.Name,
					Term_Condition__r.Effective_Start_Date__c,
					Term_Condition__r.Version_Number__c,
					Term_Condition__r.Status__c
			FROM Product_Term_Condition__c
			WHERE Is_Active__c = true
				AND Product__c IN :productIds
		];

		for(Product_Term_Condition__c ptc: lst_prod_tnc)
		{
			List<Product_Term_Condition__c> tmp = (ret.containsKey(ptc.Product__c)) ? ret.get(ptc.Product__c) : new List<Product_Term_Condition__c>();
				tmp.add(ptc);
			ret.put(ptc.Product__c, tmp);
		}

		return ret;
	}

	public Map<String, Term_and_Condition__c> getTermLastVersion(Set<String> tncNames)
	{
		Map<String, Term_and_Condition__c> ret = new Map<String, Term_and_Condition__c>();

		List<Term_and_Condition__c> lst = [
			SELECT  Id, Name, Version_Number__c
			FROM Term_and_Condition__c
			WHERE Name IN :tncNames
		];

		for(Term_and_Condition__c t : lst)
		{
			if(!ret.containsKey(t.Name))
			{
				ret.put(t.Name, t);
			}
			else
			{
				Term_and_Condition__c t2 = ret.get(t.Name);
				if(t2.Version_Number__c < t.Version_Number__c)
				{
					ret.put(t.Name, t);
				}
			}
		}

		return ret;
	}
}
