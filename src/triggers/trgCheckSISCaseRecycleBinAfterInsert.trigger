trigger trgCheckSISCaseRecycleBinAfterInsert on Case (after insert) {

    system.debug('trgCheckSISCaseRecycleBinAfterInsert - IsAfter' + trigger.isAfter);
    system.debug('trgCheckSISCaseRecycleBinAfterInsert - IsInsert' + trigger.isInsert);
    Set<Id> idSet = new Set<Id> () ; 
    
    if(trigger.isAfter)
    {
        boolean isCaseMustBeDeleted;
        
        for(Case newCaseObj : trigger.new){ 
            isCaseMustBeDeleted = false;
            
            RecordType caseRecordType = [Select Id, Name from RecordType where Id=: newCaseObj.RecordTypeId];
                 // SIS email to case
            if ((newCaseObj.Origin == 'E-mail to Case - IS Help Desk' || newCaseObj.Origin == 'E-mail to Case - SIS Help Desk')&& caseRecordType != null && caseRecordType.Name == 'Cases - SIS Help Desk') {
                // Email From Address is excluded? Email Address is excluded?
                if (clsCheckOutOfOfficeAndAutoReply.IsFromAddressExcluded(newCaseObj, 'SIS') || clsCheckOutOfOfficeAndAutoReply.IsSubjectExcluded(newCaseObj, 'SIS') ) {
                    
                    if (!newCaseObj.IsDeleted){idSet.add(newCaseObj.id);isCaseMustBeDeleted = true;}
                }               
                               
                
                // Delete the case
                if(isCaseMustBeDeleted)
                {
                    system.debug('Try deleting the case');
                    //clsUtility.deleteSObjects(Trigger.newMap.keySet(), 'Case'); 
                    //if(!idSet.isEmpty()) clsUtility.deleteSObjects(idSet, 'Case');
                    if(!idSet.isEmpty()) TransformationHelper.deleteSObjects(idSet, 'Case');
                }
            }
        }
    }
}