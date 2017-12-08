trigger meetingParticipantTrigger on Meeting_Participant__c (before insert, before update, before delete) {
System.debug(Trigger.new);
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
    List<Id> lsLGMIds = new List<Id>();
       for(Meeting_Participant__c m : Trigger.new) {
           lsLGMIds.add(m.Local_Governance_Meeting__c);
       }
       Map<Id, LocalGovernance_Meeting__c> mpLG = new Map<Id,LocalGovernance_Meeting__c>([SELECT Id, Name, Local_Governance__r.Active__c FROM LocalGovernance_Meeting__c WHERE Id IN :lsLGMIds]);
        for(Meeting_Participant__c m : Trigger.new) {
            if(mpLG.containsKey(m.Local_Governance_Meeting__c) && mpLG.get(m.Local_Governance_Meeting__c).Local_Governance__r.Active__c == false) {
                m.addError('cannot modify for inactive groups');
            }

        }
    }
    if(Trigger.isBefore && Trigger.isDelete) {
        List<Id> lsLGMIds = new List<Id>();
        for(Meeting_Participant__c m : Trigger.old) {
           lsLGMIds.add(m.Local_Governance_Meeting__c);
        }
        Map<Id, LocalGovernance_Meeting__c> mpLG = new Map<Id,LocalGovernance_Meeting__c>([SELECT Id, Name, Local_Governance__r.Active__c FROM LocalGovernance_Meeting__c WHERE Id IN :lsLGMIds]);
        for(Meeting_Participant__c m : Trigger.old) {
            if(mpLG.containsKey(m.Local_Governance_Meeting__c) && mpLG.get(m.Local_Governance_Meeting__c).Local_Governance__r.Active__c == false) {
                m.addError('cannot modify for inactive groups');
            }

        }
    }

}
