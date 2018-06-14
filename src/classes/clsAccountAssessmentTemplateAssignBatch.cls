global class clsAccountAssessmentTemplateAssignBatch implements Database.Batchable<SObject> {
    
    /*
    global List<Account> start(Database.BatchableContext BC){
        List<RecordType> accountRecordTypes = [Select r.Id, r.Name From RecordType r Where r.SobjectType  = 'Account' and r.Name = 'IATA Standard Account'];
        List<Account> listAccountToAssign = [Select a.Id, a.Name, a.Type, a.BillingCountry, a.Assessment_Template__c From Account a where a.Assessment_Template__c = null and a.RecordTypeId = :accountRecordTypes.get(0).Id and a.IATACode__c <> null and a.BillingCountry <> null];
        return listAccountToAssign;
    }
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<RecordType> accountRecordTypes = [Select r.Id, r.Name From RecordType r Where r.SobjectType  = 'Account' and r.Name = 'Standard Account'];
        String query = 'Select a.Id, a.Name, a.Type, a.BillingCountry, a.Assessment_Template__c From Account a where a.Assessment_Template__c = null and a.RecordTypeId = \'' + accountRecordTypes.get(0).Id + '\' and a.IATACode__c <> \'\' and a.BillingCountry <> \'\' and (a.Type = \'IATA Passenger Sales Agent\' or a.Type = \'IATA Cargo Agent\')';
        return Database.getQueryLocator(query);
   }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        try {
            List<Account> accsToUpdate = new List<Account>();
            for(Account a : scope){ 
                Id assessmentTemplateId = IFAP_BusinessRules.getAssessmentTemplateForAccount(a);
                if (assessmentTemplateId != null) {
                    a.Assessment_Template__c = assessmentTemplateId;
                    accsToUpdate.add(a);
                } 
            } 
            update accsToUpdate;
        }
        catch (Exception ex) {
            system.debug('ALEX - IFAP_BusinessRules.clsAccountAssessmentTemplateAssignationBatch(): ' + ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}