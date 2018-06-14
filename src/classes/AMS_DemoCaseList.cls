public class AMS_DemoCaseList {
    //public AMS_Agency__c ag {get;set;}#AMSFTS
    public Account ag {get;set;}
    public String filterCustomerService {get;set;}
    public String filterAccreditation {get;set;}
    public String filterAgencyRiskManagement {get;set;}
    public String filterSidra {get;set;}
    public String filterRemaining {get;set;}
    private final ID saamRT;
    private final ID financialReviewRT;
    private final ID sidraRT;
    private final ID oscarCommunication;
    private final List<ID> remainingRT;
    private final List<ID> casesRT;

    public AMS_DemoCaseList(ApexPages.StandardController stdController) {

        Id objectId = ApexPages.currentPage().getParameters().get('id');
        
        if(objectId == null)
            return;

        this.ag = (Account)stdController.getRecord();
        //this.ag = [select id, Account__c from AMS_Agency__c where id =: this.ag.id];#AMSFTS
        //filterLifeCycle = 'All';
        //filterBehaviour = 'All';
        List<ID> aux = new List<ID>();
        List<ID> auxRemaining = new List<ID>();
        
        saamRT = [select id from RecordType where RecordType.DeveloperName='ProcessEuropeSCE'].id;
        financialReviewRT = [select id from RecordType where RecordType.DeveloperName='IATA_Financial_Review'].id;
        sidraRT = [select id from RecordType where RecordType.DeveloperName='SIDRA'].id;
        oscarCommunication = [select id from RecordType where RecordType.DeveloperName='OSCAR_Communication'].id;

        for(RecordType rt:[select id from RecordType where RecordType.DeveloperName='CasesMENA' or RecordType.DeveloperName='Cases_China_North_Asia' or RecordType.DeveloperName='CasesAmericas' or
                    RecordType.DeveloperName='ExternalCasesIDFSglobal' or RecordType.DeveloperName='CasesEurope']){
            aux.add(rt.id);
        }
        casesRT = aux;
        
        for(RecordType rmt:[select id from RecordType where RecordType.DeveloperName != 'SIDRA' and RecordType.DeveloperName != 'IATA_Financial_Review' and 
            RecordType.DeveloperName != 'ProcessEuropeSCE' and RecordType.DeveloperName !='CasesMENA' and RecordType.DeveloperName !='Cases_China_North_Asia' and RecordType.DeveloperName !='CasesAmericas' and 
                    RecordType.DeveloperName != 'ExternalCasesIDFSglobal' and RecordType.DeveloperName != 'CasesEurope' and RecordType.DeveloperName != 'OSCAR_Communication']){
            auxRemaining.add(rmt.id);
        }

        remainingRT = auxRemaining;

        filterCustomerService = 'Open';
        filterAccreditation = 'Open';
        filterAgencyRiskManagement = 'Open';
        filterSidra = 'Open';
        filterRemaining = 'Open';
    }

    /*public List<Case> getLifeCycleCases(){
        if(filterLifeCycle == 'Closed')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.Account__c and Priority = 'Normal' and isClosed = true];
        else if(filterLifeCycle == 'Open')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.Account__c and Priority = 'Normal' and isClosed = false];

        return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.Account__c and Priority = 'Normal'];
    }

    public List<Case> getBehaviourCases(){
        if(filterBehaviour == 'Closed')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.Account__c and Priority != 'Normal' and isClosed = true];
        else if(filterBehaviour == 'Open')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.Account__c and Priority != 'Normal' and isClosed = false];

        return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.Account__c and Priority != 'Normal'];
    }*/

    public List<Case> getCustomerServiceCases(){//#AMSFTS Account__c is now id
        if(filterCustomerService == 'Closed')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and RecordTypeID IN :casesRT and isClosed = true];
        else if(filterCustomerService == 'Open')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and RecordTypeID IN :casesRT and isClosed = false];

        return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and RecordTypeID IN :casesRT];
    }

    public List<Case> getAccreditationCases(){
        if(filterAccreditation == 'Closed')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and 
                        ((RecordTypeID = :saamRT and CaseArea__c = 'Accreditation Process') or (RecordTypeID = :financialReviewRT and Financial_Review_Type__c != 'Annual') or (RecordTypeID = :oscarCommunication)) and isClosed = true];
        else if(filterAccreditation == 'Open')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and 
                        ((RecordTypeID = :saamRT and CaseArea__c = 'Accreditation Process') or (RecordTypeID = :financialReviewRT and Financial_Review_Type__c != 'Annual') or (RecordTypeID = :oscarCommunication)) and isClosed = false];

        return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and 
                        ((RecordTypeID = :saamRT and CaseArea__c = 'Accreditation Process') or (RecordTypeID = :financialReviewRT and Financial_Review_Type__c != 'Annual') or (RecordTypeID = :oscarCommunication))];
    }

    public List<Case> getAgencyRiskManagementCases(){
        if(filterAgencyRiskManagement == 'Closed')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and 
                        ((RecordTypeID = :saamRT and CaseArea__c = 'Risk Management Process') or (RecordTypeID = :financialReviewRT and Financial_Review_Type__c = 'Annual')) and isClosed = true];
        else if(filterAgencyRiskManagement == 'Open')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and 
                        ((RecordTypeID = :saamRT and CaseArea__c = 'Risk Management Process') or (RecordTypeID = :financialReviewRT and Financial_Review_Type__c = 'Annual')) and isClosed = false];

        return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and 
                        ((RecordTypeID = :saamRT and CaseArea__c = 'Risk Management Process') or (RecordTypeID = :financialReviewRT and Financial_Review_Type__c = 'Annual'))];
    }

    public List<Case> getSIDRACases(){
        if(filterSidra == 'Closed')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and RecordTypeID = :sidraRT and isClosed = true];
        else if(filterSidra == 'Open')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and RecordTypeID = :sidraRT and isClosed = false];

        return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and RecordTypeID = :sidraRT];
    }

    //Get all remaning cases that don't belong to the previous lists
    public List<Case> getRemaningCases(){
        if(filterRemaining == 'Closed')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and RecordTypeID = :remainingRT and isClosed = true];
        else if(filterRemaining == 'Open')
            return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and RecordTypeID = :remainingRT and isClosed = false];

        return [select id, CaseNumber, Reason1__c, CreatedDate, Status, Case_Age_Days__c from Case where AccountId =: this.ag.id and RecordTypeID = :remainingRT];
    }


    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('Open','Open'));
        options.add(new SelectOption('Closed','Closed'));
        return options;
    }

    public PageReference radioSelectAction(){
        return null;
    }
}