public with sharing class IEC_EventSubscription_Svc {

	public static Map<String,List<IEC_Event_Subscription__c>> buildMapWithSubscByProductNbrWoVersion(List<IEC_Event_Subscription__c> lstEventSubscriptions){

		Map<String,List<IEC_Event_Subscription__c>> mapSubscriptionByProductNbrWoVersion = new Map<String,List<IEC_Event_Subscription__c>>();
        
        if(lstEventSubscriptions != null && !lstEventSubscriptions.isEmpty()){
            for(IEC_Event_Subscription__c eventSubscriptionAux : lstEventSubscriptions){
                //subscription will be map by product number without version
                String productNbrWoVersion = eventSubscriptionAux.Product__r.SAP_Material_Number__c.substringBefore('-');
                if(mapSubscriptionByProductNbrWoVersion.containsKey(productNbrWoVersion)){
                    mapSubscriptionByProductNbrWoVersion.get(productNbrWoVersion).add(eventSubscriptionAux);
                }else{
                    List<IEC_Event_Subscription__c> iecEventSubsTmp = new List<IEC_Event_Subscription__c>();
                    iecEventSubsTmp.add(eventSubscriptionAux);
                    mapSubscriptionByProductNbrWoVersion.put(productNbrWoVersion, iecEventSubsTmp);
                }
            }
        }

        return mapSubscriptionByProductNbrWoVersion;
	}

}