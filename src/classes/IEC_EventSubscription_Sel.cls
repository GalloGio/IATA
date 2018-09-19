public without sharing class IEC_EventSubscription_Sel extends Selector {

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> 
        {
            IEC_Event_Subscription__c.Id,
            IEC_Event_Subscription__c.Active__c,
            IEC_Event_Subscription__c.Product__c,
            IEC_Event_Subscription__c.Subscriber__c 
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return IEC_Event_Subscription__c.sObjectType;
    }

    //Get Event subscription by Id
    public map<Id,IEC_Event_Subscription__c> getEventSubscriptionById(set<Id> subscriptionIds){
        String query = String.format(
            'SELECT {0}  ' + 
            'FROM {1} ' + 
            'WHERE Id IN :subscriptionIds ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        return new map<Id,IEC_Event_Subscription__c>((List<IEC_Event_Subscription__c>)Database.query(query));
    }

    public List<IEC_Event_Subscription__c> getEventSubscriptionBySubscriber(Id subscriberId){

        String query = String.format(
            'SELECT {0}, ' + 
            ' (SELECT id,Invoice_Number__c, Order.Type, Order.EffectiveDate,Product_Name__c, Effective_End_Date__c, ' +
                'Order.OrderNumber,Order.Payment_Type__c, Order.Zuora_Transaction_Id__c ' +
                ' From Order_Products__r Order by CreatedDate Desc)' +
            ' FROM {1} ' + 
            ' WHERE Subscriber__c = :subscriberId and Active__c = true order by CreatedDate Desc ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        return Database.query(query);
    }
    
    public List<IEC_Event_Subscription__c> getEventSubscriptionByProductsIdListAndContactsList(Set<Id> lstProductsId, Set<Id> lstContactIds){

        String query = String.format(
            'SELECT {0} ' + ', Product__r.SAP_Material_Number__c '
            'FROM {1} ' + 
            'WHERE Product__c IN :lstProductsId ' + 
            ' AND Subscriber__c IN :lstContactIds ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        return Database.query(query);
    }

}