trigger trgCase_ContactLastSurveyUpdate on Case (after update)
{ 
    if (Trigger.isUpdate)
    {
        if (Trigger.isAfter)
        {         
            
            /****************************************************** FDS Enhancement ***********************************************************
            * This part of the code update a Case's Contact field Instant_Survey_Last_survey_sent__c, if the Case field Instant_Survey_Last_survey_sent__c is updated
            */            
            
            // Get all Cases' contact and put it in a Map.
            Map<Id, Contact> casesContacts;
            Map<Id, Contact> contactToUpdate = new Map<Id, Contact>(); 
            Boolean isCasesContactsInit = false; // This variable checks if the casesContacts have been already initialized.
            for(Case thisCase:trigger.new)
            {
                Case oldCase = Trigger.oldMap.get(thisCase.Id);                          
                if (thisCase.ContactId != null && oldCase.Instant_Survey_Last_survey_sent__c == null && thisCase.Instant_Survey_Last_survey_sent__c != null)
                {
                    // Initialise casesContacts if it is not initialized yet. This is a way to reduced SOQL call
                    if(isCasesContactsInit == false)
                    {
                        casesContacts = new Map<Id,Contact>([SELECT Id, Instant_Survey_Last_survey_sent__c FROM Contact 
                                                            WHERE Id IN (SELECT ContactId From Case WHERE Id IN :Trigger.newMap.keySet())]);
                        isCasesContactsInit = true;
                    }
                    
                    Contact caseContact = casesContacts.get(ThisCase.ContactId);
                    if (caseContact != null)
                    {                        
                        caseContact.Instant_Survey_Last_survey_sent__c = datetime.now();
                        contactToUpdate.put(caseContact.Id, caseContact); 
                    }          
                }               
            }
            if (contactToUpdate.size() > 0)
            {
                update contactToUpdate.values();
            }          
            
            /**********************************************************************************************************************************/
        }
    }
}