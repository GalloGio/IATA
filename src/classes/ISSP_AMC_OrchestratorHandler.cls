/**
 * Created by Manuel Conde on 28/02/2019.
 */

public with sharing class ISSP_AMC_OrchestratorHandler {


    /**
        CODE AFTER UPDATE
    **/
    public static void afterUpdate( list<IATA_Process_Orchestrator__c> listNewsOrchestrators ) {
        Map<Id, Set<String>> mapOrchParents = new Map<Id, Set<String>>();

        for (IATA_Process_Orchestrator__c is : listNewsOrchestrators) {
            if(!String.isEmpty(is.Process_Step_Name__c)){

                if(mapOrchParents.containsKey(is.IATA_Orchestrator_Process__c))
                    mapOrchParents.get(is.IATA_Orchestrator_Process__c).add(is.Status__c);
                else{
                    set<String> setStages = new set<String>();
                    setStages.add(is.Status__c);
                    mapOrchParents.put(is.IATA_Orchestrator_Process__c, setStages);
                }

            }
        }

        if(!mapOrchParents.isEmpty()){

            List<IATA_Process_Orchestrator__c> allSteps = [select id, IATA_Orchestrator_Process__c, Process_Step_Stage__c, Status__c, Associated_Case__c
                    from IATA_Process_Orchestrator__c
                    where IATA_Orchestrator_Process__c in :  mapOrchParents.keySet()];

            Map<Id, IATA_Process_Orchestrator__c> allStepsMap = new Map<Id, IATA_Process_Orchestrator__c>([select id, IATA_Orchestrator_Process__c, Process_Step_Stage__c, Status__c, Associated_Case__c
                    from IATA_Process_Orchestrator__c
                    where id in :  mapOrchParents.keySet()]);

            for (IATA_Process_Orchestrator__c tst : allSteps) {
                mapOrchParents.get(tst.IATA_Orchestrator_Process__c).add(tst.Status__c);
            }

            List<IATA_Process_Orchestrator__c> toUpdate = new List<IATA_Process_Orchestrator__c>();

            Boolean completed = false;
            Boolean notStarted = false;
            Boolean pendingCustomer = false;
            Boolean fail = false;
            Boolean progressing = false;
            Boolean notApp = false;
            Case caseToUpdate = new Case();
            Boolean isToUpdateCase = true;

            for(Id idValue : mapOrchParents.keySet()){
                String stageValue = 'Not set';
                completed = false;
                notStarted = false;
                pendingCustomer = false;
                fail = false;
                progressing = false;
                notApp = false;
                set<String> setStages = mapOrchParents.get(idValue);

                for(String statusName: setStages){
                    if(statusName.equals('Pending Customer')){
                        pendingCustomer = true;
                        continue;
                    }
                    if(statusName.equals('Fail')){
                        fail = true;
                        continue;
                    }
                    if(statusName.equals('Progressing')){
                        progressing = true;
                        continue;
                    }
                    if(statusName.equals('Completed')){
                        completed = true;
                        continue;
                    }
                    if(statusName.equals('Not Started')){
                        notStarted = true;
                        continue;
                    }
                    if(statusName.equals('Not Applicable')){
                        notApp = true;
                        continue;
                    }

                    //stageValue = statusName;

                    if(stageValue.equals('Not set')) continue;

                }

                if(pendingCustomer){
                    stageValue = 'Pending Customer';
                }else if(fail){
                    stageValue = 'Fail';
                }else if((notStarted && completed) || progressing){
                    stageValue = 'Progressing';
                }else if(completed){
                    stageValue = 'Completed';
                }else if(notStarted) {
                    stageValue = 'Not Started';
                }else{
                    stageValue = 'Not Applicable';
                }

                if(!stageValue.equals('Not set')) {
                    IATA_Process_Orchestrator__c obj = new IATA_Process_Orchestrator__c();
                    obj.id = idValue;
                    obj.Overall_Status__c = stageValue;

                    System.debug('FILI OverAll trigger ' + obj.Overall_Status__c);

                    toUpdate.add(obj);

                    if(!allStepsMap.isEmpty()) {
                        caseToUpdate.id = allStepsMap.get(idValue).Associated_Case__c;

                        if(stageValue == 'Progressing'){
                            stageValue = 'In Progress';
                        }
                        if(stageValue == 'Fail'){
                            stageValue = 'Action Needed';
                        }
                        if(stageValue == 'Not Started'){
                            isToUpdateCase = false;
                        }
                        if(stageValue == 'Not Applicable'){
                            isToUpdateCase = false;
                        }

                        caseToUpdate.Status = stageValue;
                    }
                }

            }
            if(!toUpdate.isEmpty()) {
                update toUpdate;
                if(isToUpdateCase){
                    update caseToUpdate;
                }
            }
        }

    }
}