trigger OrchestratorTrigger on IATA_Process_Orchestrator__c (after Update) {

    if (trigger.IsUpdate && trigger.isafter) {
        ISSP_AMC_OrchestratorHandler.afterUpdate(trigger.new);
    }
}