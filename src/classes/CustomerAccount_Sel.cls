/****************************************************************************************************
    Created by Kevin Ky 2015-09-23
****************************************************************************************************/
public without sharing class CustomerAccount_Sel {
	
	/****************************************************************************************************
	    Created by Kevin Ky 2015-09-23
	    Return Zuora customer Account Id by Salesforce account id
	****************************************************************************************************/
	public static map<Id,Zuora__CustomerAccount__c> getZuoraCustmerAccount(Set<Id> sfContactIds)
	{
		map<Id,Zuora__CustomerAccount__c> sfAccountId_ZCustomerAccountId = new map<Id,Zuora__CustomerAccount__c>();
		
		List<Zuora__CustomerAccount__c> lstZuoraCustAccount =
			[SELECT Id,
				Zuora__Account__c,
				Zuora__Zuora_Id__c,
				Zuora__BillToId__c,
				Zuora__SoldToId__c,
				Zuora__PaymentMethod_Type__c,
				Zuora__PaymentMethodType__c,
				Zuora__CreditCardType__c,
				Zuora__CreditCard_Number__c,
				Zuora__CreditCard_Expiration__c,
				Zuora__Default_Payment_Method__c,
                Zuora__DefaultPaymentMethod__c,
				Zuora__Default_Payment_Method__r.Zuora__External_Id__c,
				Zuora__Default_Payment_Method__r.Zuora__CreditCardExpirationMonth__c,
				Zuora__Default_Payment_Method__r.Zuora__CreditCardExpirationYear__c,
				Zuora__Default_Payment_Method__r.Zuora__CreditCardHolderName__c,
				Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c,
				Zuora__Default_Payment_Method__r.Zuora__CreditCardType__c,
				Zuora__Default_Payment_Method__r.Zuora__Type__c,
				CRMContactID__c 
			FROM Zuora__CustomerAccount__c 
			WHERE CRMContactID__c in :sfContactIds
			ORDER BY Zuora__AccountNumber__c DESC];
			
		if(lstZuoraCustAccount != null && lstZuoraCustAccount.size() > 0)
		{
			for (Zuora__CustomerAccount__c zca : lstZuoraCustAccount)
			{
				// Only add the account if it hasn't been added before
				if(zca.Zuora__Zuora_Id__c != null && !sfAccountId_ZCustomerAccountId.containsKey(zca.CRMContactID__c))
				{
					sfAccountId_ZCustomerAccountId.put(zca.CRMContactID__c,zca);
				}
			}
		}
		
		return sfAccountId_ZCustomerAccountId;
	}
	
	/**
     * Returns the SF Zuora Billing Account related to a Account/Contact (if any)
     * @param setAccConId The Account/Contact Id combine together
     * @return The Salesforce object representing the Zuora Billing Account or null if not found
     */
    public static Map<String, Zuora__CustomerAccount__c> getZAccountByAccountContactId(Set<String> setAccConId) {
    	Map<String, Zuora__CustomerAccount__c> mapAccConId_ZAccount = new Map<String, Zuora__CustomerAccount__c>();
    	
    	for (Zuora__CustomerAccount__c zAcc :
    		[SELECT Zuora__BillToId__c, Zuora__SoldToId__c, Account_Contact_ID__c, Zuora__External_Id__c
    			, Zuora__Default_Payment_Method__c, Zuora__Default_Payment_Method__r.Zuora__Type__c
    			, Zuora__Default_Payment_Method__r.Zuora__External_Id__c
    			/*, Zuora__CreditCard_Expiration__c
    			, Zuora__Default_Payment_Method__r.Zuora__CreditCardExpirationMonth__c
				, Zuora__Default_Payment_Method__r.Zuora__CreditCardExpirationYear__c*/
    		FROM Zuora__CustomerAccount__c
    		WHERE Account_Contact_ID__c IN :setAccConId
    		ORDER BY Zuora__AccountNumber__c DESC]) {
			
			// Only add the account if it hasn't been added before
			if (!mapAccConId_ZAccount.containsKey(zAcc.Account_Contact_ID__c))
				mapAccConId_ZAccount.put(zAcc.Account_Contact_ID__c, zAcc);
		}

    	return mapAccConId_ZAccount.isEmpty() ? null : mapAccConId_ZAccount;
    }
}