/*
Class Name: TrackingValueStatusController
Related Component: TrackingValueStatus

Copyright © IATA

Purpose: This class lists the history of the state field

VERSION AUTHOR   			DATE					DETAIL/CHANGE REFERENCE
1.0 - Daniela Cerqueira		12/02/2019				INITIAL DEVELOPMENT
*/

public with sharing class TrackingValueStatusController {
    
    @AuraEnabled
    public static List<IATA_Process_Orchestrator_Step_Action__history> getOldNewStatus(Id recordId, String Status){
        System.debug('RecordId '+recordId);
        
        List<id> listId= new List<id>();
        for(IATA_Process_Orchestrator__c parentOrchestrator: [SELECT Id FROM IATA_Process_Orchestrator__c  WHERE IATA_Orchestrator_Process__c =:recordId ]){
            listId.add(parentOrchestrator.Id);
        }
        
        List<IATA_Process_Orchestrator_Step_Action__history> childOrchestratorStep = [SELECT OldValue, NewValue, Parent.Id, Parent.name, Parent.Stage__c, CreatedDate,CreatedBy.Name,Parent.Action_name__c, Parent.IATA_Process_Orchestrator__c
                                                                                      FROM IATA_Process_Orchestrator_Step_Action__history 
                                                                                      WHERE Parent.IATA_Process_Orchestrator__c =: listId AND Field = 'Status__c' ORDER BY createddate DESC ];
        System.debug('childOrchestratorStep '+childOrchestratorStep);
        return childOrchestratorStep;
        
        
        
        /* List<IATA_Process_Orchestrator__c > parentOrchestrator = [SELECT Id FROM IATA_Process_Orchestrator__c  WHERE IATA_Orchestrator_Process__c =:recordId ];
System.debug('parentOrchestrator '+parentOrchestrator);
System.debug([SELECT Id FROM IATA_Process_Orchestrator__c  WHERE IATA_Orchestrator_Process__c =:recordId ]);
*/ 
        /*[SELECT OldValue, NewValue, Parent.Id, Parent.name, Parent.Stage__c, CreatedDate,CreatedBy.Name,Parent.Action_name__c, Parent.IATA_Process_Orchestrator__c
FROM IATA_Process_Orchestrator_Step_Action__history 
WHERE Parent.IATA_Process_Orchestrator__c =: parentOrchestrator.Id AND Field = 'Status__c' ORDER BY createddate DESC ];  */
    }
}