public with sharing class Product_Term_Condition_Svc
{
	/****************************************************************************************************
			 Created By David D
			 	validate that each item the combination of T&C-Product-CustomerType
			 		where IsActive=true is uniq
	****************************************************************************************************/
	public static void validateProductTnC(List<Product_Term_Condition__c> productTnCs2Save)
	{
		Term_And_Condition_Sel tncSelector = new Term_And_Condition_Sel();

		//-- Existing Active Product T&C for current Products & T&C
		Set<Id> productIds = new Set<Id>();

		for(Product_Term_Condition__c ptnc: productTnCs2Save)
		{
			productIds.add(ptnc.Product__c);
		}

		Map<Id, List<Product_Term_Condition__c>> existingActiveProductTnC = tncSelector.getActiveTermsAndConditions(productIds);

		if(!existingActiveProductTnC.isEmpty())
		{
			for(Product_Term_Condition__c ptnc : productTnCs2Save)
			{
				if(ptnc.Is_Active__c== true && existingActiveProductTnC.containsKey(ptnc.Product__c))
				{
					List<Product_Term_Condition__c> productActiveTnCs = existingActiveProductTnC.get(ptnc.Product__c);

					if(productActiveTnCs.size() > 0)
					{
						for(Product_Term_Condition__c existing_ptnc : productActiveTnCs)
						{
							if(existing_ptnc.Term_Condition__r.Name == ptnc.Term_Condition_Name__c)
							{
								Set<String> existingCustomerTypes =  new Set<String>(existing_ptnc.Customer_Type__c.split(';'));
								Set<String> customerTypes2Save =  new Set<String>(ptnc.Customer_Type__c.split(';'));

								for(String ct: customerTypes2Save)
								{
									if(existingCustomerTypes.contains(ct))
									{
										ptnc.addError(ptnc.Term_Condition_Name__c+'"'+ ' already active for the customer type  "'+ ct+'"');
									}
								}
							}
						}
					}
				}
			}
		}



	}


}
