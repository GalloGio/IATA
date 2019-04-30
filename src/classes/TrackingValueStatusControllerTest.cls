/*
Class Name: TrackingValueStatusControllerTest
Related Component: TrackingValueStatusController

Copyright © IATA

Purpose: Test class TrackingValueStatusController

VERSION AUTHOR   			DATE					DETAIL/CHANGE REFERENCE
1.0 - Daniela Cerqueira		13/02/2019				INITIAL DEVELOPMENT
*/
@isTest
public class TrackingValueStatusControllerTest {
    
    static testmethod void testgetOldNewStatus() {
        
        String Stage= 'Stage A';
        
        IATA_Process_Orchestrator__c IATA_PO = new IATA_Process_Orchestrator__c();
        IATA_PO.Process_Name__c = 'Name';
        insert IATA_PO;
        
        IATA_Process_Orchestrator_Step_Action__c IATA_POSA = new IATA_Process_Orchestrator_Step_Action__c();
        IATA_POSA.Action_name__c = 'Name';
        IATA_POSA.Status__c = 'Progressing';
        IATA_POSA.IATA_Process_Orchestrator__c = IATA_PO.Id;
        insert IATA_POSA;
        
        IATA_POSA.Status__c = 'Completed';
        update IATA_POSA;
        
        TrackingValueStatusController.getOldNewStatus(IATA_PO.Id, Stage);
        
    }
}