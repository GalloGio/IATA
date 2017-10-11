/****************************************************************************************************
    Created by Kevin Ky 2015-09-29
    my first change
****************************************************************************************************/
public without sharing class Account_Sel extends Selector {
	

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> 
		{
			Account.id,
			Account.Name,
			Account.CurrencyIsoCode,
			Account.Email__c,
			Account.BillingCountry,
			Account.BillingPostalCode,
			Account.BillingState,
			Account.BillingCity,
			Account.BillingStreet,
			Account.ShippingCountry,
			Account.ShippingPostalCode,
			Account.ShippingState,
			Account.ShippingCity,
			Account.ShippingStreet,
			Account.ParentId,
			Account.Region__c,
			Account.Customer_Type__c,
			Account.Default_Payment_Type__c,
			Account.IATA_ISO_Billing_State__c,
			Account.IATA_ISO_Country__c,
			Account.IATA_ISO_Shipping_State__c,
			Account.VAT_Number__c,
			Account.Region_formula__c,
			Account.SoldTo_Location__c,
			Account.ICH_Member__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Account.sObjectType;
	}

	public Account getAccountById(Id accountId)
    {
        /*List<Account> accounts = (List<Account>) selectSObjectById(new Set<Id>{accountId}); 
        
        return (accounts.size() > 0) 
            ? accounts[0]
            : null;*/

        String query = String.format(
            'SELECT {0}, IATA_ISO_Country__r.ISO_Code__c, IATA_ISO_Billing_State__r.ISO_Code__c, IATA_ISO_Shipping_State__r.ISO_Code__c ' + 
            ', Parent.Name, Parent.SoldTo_Location__c, Parent.Default_Payment_Type__c, Parent.SoldTo_Location__r.SAP_Id__c, SoldTo_Location__r.SAP_Id__c ' +
            'FROM {1} ' + 
            'WHERE Id = :accountId ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        List<Account> accounts = Database.query(query);
        return (accounts != null && accounts.size() > 0)  ? accounts[0]  : null;
    }
    
    public Map<Id, Account> getAccountById(Set<Id> setAccountId)
    {
        return new Map<Id, Account>(
            [SELECT id, Name, CurrencyIsoCode, Email__c, BillingCountry, BillingPostalCode, BillingState, BillingCity
	            , BillingStreet, ShippingCountry, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, ParentId, Region__c
	            , Customer_Type__c, Default_Payment_Type__c, IATA_ISO_Billing_State__c, IATA_ISO_Country__c, IATA_ISO_Shipping_State__c
	            , VAT_Number__c, Region_formula__c, SoldTo_Location__c, ICH_Member__c
	            , IATA_ISO_Country__r.ISO_Code__c, IATA_ISO_Billing_State__r.ISO_Code__c, IATA_ISO_Shipping_State__r.ISO_Code__c 
	            , Parent.Name, Parent.SoldTo_Location__c
            FROM Account
            WHERE Id IN :setAccountId]
           );  
    }

	/****************************************************************************************************
	    Created by Kevin Ky 2015-09-29
	    Return the Bill to and Sold to Account by Account Id
	****************************************************************************************************/
	public map<Id,Account> getBillToAndSoldToAccountByAccountId(set<Id> accountIds){
		
		map<Id,Account> acountId_Account = new map<Id,Account>();
		list<Account> lstAccount = (List<Account>) selectSObjectById(accountIds); 

		if(lstAccount != null && lstAccount.size() > 0){
			for(Account account : lstAccount){
				//Add the Bill To account
				acountId_Account.put(account.Id, account);
			}
		}
		
		return acountId_Account;
	}
	
}