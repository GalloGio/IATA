global class IEC_Event_Renewal_CreateOrders_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    private String query;
    global IEC_Event_Release__c eventRelease;
    global Decimal qty;
    global Decimal total;
    global Decimal customerNb;
    global Id lastCustomerId;
    global Boolean isReprocessingJob;
    
    //Query all the product Code with customer type for the giving parameters
    global IEC_Event_Renewal_CreateOrders_Batch(IEC_Event_Release__c iecEventRelease, String reprocessSubscriptionIds) {
        eventRelease = iecEventRelease;
        qty = 0;
        total = 0;
        customerNb = 0;
        lastCustomerId = null;
        isReprocessingJob = (reprocessSubscriptionIds != null);

        Id excludeProductId = (iecEventRelease.Swapped_Product__c != null) ? iecEventRelease.Swapped_Product__c : iecEventRelease.Last_Version__c;

        system.debug('excludeProductId ' + excludeProductId);
        String queryLimit = '';
        if(Test.isRunningTest())
            queryLimit = ' Limit 5';

        query = 'SELECT id, Product__c, Quantity__c, Subscriber__c, Default_Payment_Type__c ' +
                ' from IEC_Event_Subscription__c ' + 
                'where Active__c = true and Material_Number__c = \'' + iecEventRelease.Material_Number__c + '\' ' +
                ' and (Customer_Type__c in (\'' + iecEventRelease.Customer_Type__c.replace(';', '\',\'') + '\') ' +
                (iecEventRelease.Customer_Type__c.containsIgnoreCase(IECConstants.PARAM_CUSTOMERTYPE_DEFAULT) ? ' or Customer_Type__c = null' : '') + ') ' +
                ((excludeProductId == null) ? '' : ' and Product__c != \'' + excludeProductId + '\' ') +
                ((reprocessSubscriptionIds == null) ? '' : ' and Id in (' + reprocessSubscriptionIds + ') ') +
                'order by Subscriber__c ' + queryLimit;
		system.debug('query ' + query);
        List<IEC_Event_Subscription__c> lstEveSub = Database.query(query);
    }

    public void setProcessingStatus(Set<Id> releaseIds)
    {
        List<IEC_Event_Release__c> releasesToUpdate = [SELECT Id, Processing_Status__c FROM IEC_Event_Release__c WHERE Id IN:releaseIds];
        for(IEC_Event_Release__c release : releasesToUpdate)
            release.Processing_Status__c = 'Auto Renew Creation is processing ....';

        update releasesToUpdate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        setProcessingStatus(new Set<Id>{eventRelease.Id});
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<IEC_Event_Subscription__c> scope) {
        system.debug('scope ' + scope);
    	if(scope != null && scope.size() > 0){
        //Create order and orderItems with price
	        List<OrderItem> orderItems = Order_Svc.createAutoRenewalOrders(eventRelease, scope);
	        //set<Id> orderContactIds = new set<Id>();
	        for(OrderItem oi : orderItems){
	            qty += oi.Quantity;
	            total += oi.SubTotal__c;
	            //orderContactIds.add(oi.Order.BillToContactId);
	            if (lastCustomerId != oi.Order.BillToContactId)
	            {
	                lastCustomerId = oi.Order.BillToContactId;
	                customerNb += 1;
	            }
	        }
    	}
        //customerNb = orderContactIds.size();
    }
    
    global void finish(Database.BatchableContext BC) {
        //Get the last update of IEC_Event_Release__c before update
        IEC_Event_Release__c releaseToUpdate = [select id, Sales_Amout__c, Sales_Quantity__c, Nb_Customer__c from IEC_Event_Release__c where id = :eventRelease.Id ];
        releaseToUpdate.Sales_Amout__c = (releaseToUpdate.Sales_Amout__c == null) ? total : releaseToUpdate.Sales_Amout__c + total;
        releaseToUpdate.Sales_Quantity__c = (releaseToUpdate.Sales_Quantity__c == null) ? qty : releaseToUpdate.Sales_Quantity__c + qty;
        releaseToUpdate.Nb_Customer__c = (releaseToUpdate.Nb_Customer__c == null) ? customerNb : releaseToUpdate.Nb_Customer__c + customerNb;
        update releaseToUpdate;

        //Tax ans Shipping calculation after order creation
        IEC_Evt_Renew_GetSAPFreightTax_Batch batch = new IEC_Evt_Renew_GetSAPFreightTax_Batch(eventRelease.Id, isReprocessingJob);
        Integer batchSize = Utility.getIntegerSetting('IEC evt renewal batch size for taxes'); 
        if(Test.isRunningTest() && batchSize < 1) batchSize = 1; 
        System.debug('batchSize::'+batchSize);

        Database.executeBatch(batch, batchSize);
    }
    
}