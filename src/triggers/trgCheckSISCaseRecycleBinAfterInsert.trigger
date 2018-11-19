trigger trgCheckSISCaseRecycleBinAfterInsert on Case (after insert) {

    system.debug('trgCheckSISCaseRecycleBinAfterInsert - IsAfter' + trigger.isAfter);
    system.debug('trgCheckSISCaseRecycleBinAfterInsert - IsInsert' + trigger.isInsert);
    Set<Id> idSet = new Set<Id> () ; 
    
    if(trigger.isAfter)
    {
        boolean isCaseMustBeDeleted;
        
        for(Case newCaseObj : trigger.new){ 
            isCaseMustBeDeleted = false;
            
            // SIS email to case
            if ((newCaseObj.Origin == 'E-mail to Case - IS Help Desk' || newCaseObj.Origin == 'E-mail to Case - SIS Help Desk') 
                && newCaseObj.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk')) {

                // Email From Address is excluded? Email Address is excluded?
                if (clsCheckOutOfOfficeAndAutoReply.IsFromAddressExcluded(newCaseObj, 'SIS') || clsCheckOutOfOfficeAndAutoReply.IsSubjectExcluded(newCaseObj, 'SIS') ) {
                    
                    if (!newCaseObj.IsDeleted){idSet.add(newCaseObj.id);isCaseMustBeDeleted = true;}
                }               
                
                // Delete the case
                if(isCaseMustBeDeleted)
                {
                    system.debug('Try deleting the case');
                    if(!idSet.isEmpty()) TransformationHelper.deleteSObjects(idSet, 'Case');
                }
            }
        }
    }
}