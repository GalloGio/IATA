trigger RemoteInvocationArtefactTrigger on Remote_Invocation_Artefact__c (before insert ) {
	if (Trigger.isBefore) {
        if (Trigger.isInsert) {
           // RemoteInvocationArtefactTriggerHandler.handleBeforeInsert();
        }
    }
}