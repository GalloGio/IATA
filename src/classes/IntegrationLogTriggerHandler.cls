/*
* Company    : HARDIS Bordeaux
* Created on : 21-10-2019
* Author     : BTH
*/
public without sharing class IntegrationLogTriggerHandler {
    @TestVisible private static List<Subflow_SAP__e> sapEvents = new List<Subflow_SAP__e>();

    public static void OnAfterUpdate(List<Integration_Log__c> integrationLogs, Map<Id, Integration_Log__c> oldIntegrationLogById){
        spreadStatusUpdateToFlow(integrationLogs, oldIntegrationLogById);
    }

    private static void spreadStatusUpdateToFlow(List<Integration_Log__c> integrationLogs, Map<Id, Integration_Log__c> oldIntegrationLogById){
        for(Integration_Log__c integrationLog : integrationLogs){
            Integration_Log__c oldIntegrationLog = oldIntegrationLogById.get(integrationLog.Id);
            if(isLinkedToAddressRoleBusinessContext(integrationLog)
                    && statusHasChanged(integrationLog, oldIntegrationLog)){
                sapEvents.add(new Subflow_SAP__e(
                        Integration_Log_Id__c = integrationLog.Id,
                        Address_Role_Business_Context_Id__c = integrationLog.Record_Id__c
                ));
            }
        }
        EventBus.publish(sapEvents);
    }

    private static Boolean isLinkedToAddressRoleBusinessContext(Integration_Log__c integrationLog){
        return String.isNotBlank(integrationLog.Record_Id__c) && Id.valueOf(integrationLog.Record_Id__c).getSobjectType() == Address_Role_Business_Context__c.SObjectType;
    }

    private static Boolean statusHasChanged(Integration_Log__c integrationLog, Integration_Log__c oldIntegrationLog){
        return integrationLog.Status__c != oldIntegrationLog.Status__c;
    }
}