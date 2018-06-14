/*
 * Test Coverage is provided under the trgHndlrIECInvoice_tst class
 */
public without sharing class IEC_ZSubscription_Sel extends Selector {
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> 
        {
            Zuora__Subscription__c.Id,
            Zuora__Subscription__c.Name,
            Zuora__Subscription__c.Zuora__External_Id__c,
            Zuora__Subscription__c.OrderId__c,
            Zuora__Subscription__c.Zuora__Version__c
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Zuora__Subscription__c.sObjectType;
    }

    /****************************************************************************************************
    Created by Samy 2016-05-09
        return an Zuora__Subscription__c by Set of Zuora Id
    ****************************************************************************************************/
    public Map<String, Zuora__Subscription__c> getSubscriptionByZId(Set<String> setSubscriptionZId)
    {
    	String query = String.format(
            'SELECT {0}, Zuora__SubscriptionStartDate__c ' + 
            'FROM {1} ' + 
            ' WHERE Zuora__External_Id__c in :setSubscriptionZId', 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        
        List<Zuora__Subscription__c> lstSubscription = Database.query(query);
        
        Map<String, Zuora__Subscription__c> mapSubscription = new Map<String, Zuora__Subscription__c>();
        
        if (lstSubscription != null && !lstSubscription.isEmpty())
        {
        	for (Zuora__Subscription__c oSub : lstSubscription)
	        {
	        	mapSubscription.put(oSub.Zuora__External_Id__c, oSub);
	        }
        }
        
        return mapSubscription;
    }  

        /****************************************************************************************************
        Method created in the context of INC306838
        
        return an Zuora__Subscription__c by Set of Zuora Name
    ****************************************************************************************************/
    public Map<String, Zuora__Subscription__c> getSubscriptionByZName(Set<String> setSubscriptionZName)
    {
        String query = String.format(
            'SELECT {0}, Zuora__SubscriptionStartDate__c ' + 
            'FROM {1} ' + 
            ' WHERE Name in :setSubscriptionZName', 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        
        List<Zuora__Subscription__c> lstSubscription = Database.query(query);
        
        Map<String, Zuora__Subscription__c> mapSubscription = new Map<String, Zuora__Subscription__c>();
        
        if (lstSubscription != null && !lstSubscription.isEmpty())
        {
            for (Zuora__Subscription__c oSub : lstSubscription)
            {
                mapSubscription.put(oSub.Name, oSub);
            }
        }
        
        return mapSubscription;
    }  
      
}