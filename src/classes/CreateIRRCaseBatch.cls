global class CreateIRRCaseBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    global Map<Id,String> mapCases {get;set;}

    global CreateIRRCaseBatch(Map<Id,String> mapCases) {
        this.mapCases = mapCases;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> caseIds = this.mapCases.keySet();
        String queryStr = 'SELECT Id, AccountId, Account.Name, Account.IATA_ISO_Country__r.ISO_Code__c, ContactId, Type_of_customer__c, BSPCountry__c, Region__c FROM Case WHERE Id IN :caseIds';
        return Database.getQueryLocator(queryStr);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        Id saamRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;  
        List<Case> cases = new List<Case>();
        
        for(Case parentCase : scope) {            
            Case cse = new Case();
            
            cse.Subject = parentCase.Account.Name + ' - ' + parentCase.Account.IATA_ISO_Country__r.ISO_Code__c;
            cse.CaseArea__c = 'Risk Management Process';
            mapReasonType(cse, mapCases.get(parentCase.Id));
            cse.AccountId = parentCase.AccountId;
            cse.ContactId = parentCase.ContactId;
            cse.Type_of_customer__c = parentCase.Type_of_customer__c;
            cse.Region__c = parentCase.Region__c;
            cse.BSPCountry__c = parentCase.BSPCountry__c;
            cse.RecordTypeId = saamRT;
            cse.ParentId = parentCase.Id;
            cse.setOptions(dmo);
            cases.add(cse);
        }
        insert cases;
    }

    private static void mapReasonType(Case cse, String irrReason) {
        if(irrReason == 'FS') {
            cse.Reason1__c = 'Financial Security Request';
            cse.Subject += ' - FS request';
        } else if(irrReason == 'FA') {
            cse.Reason1__c = 'Adhoc review';
            cse.Subject += ' - FA request';
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}