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
        
        saamRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');
        financialReviewRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        sidraRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        oscarCommunication = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        casesRT = RecordTypeSingleton.getInstance().getRecordTypeObjIdListForSpecfifiedNames('Case', new List<String>{'CasesMENA', 'Cases_China_North_Asia', 'CasesAmericas', 'ExternalCasesIDFSglobal', 'CasesEurope', 'Cases_Global'});
        
        remainingRT = RecordTypeSingleton.getInstance().getRecordTypeObjIdListExceptPassedNames('Case', new List<String>{'SIDRA', 'IATA_Financial_Review', 'Cases_Global', 'ProcessEuropeSCE', 'CasesMENA', 'Cases_China_North_Asia', 
                                                                                                                         'CasesAmericas', 'ExternalCasesIDFSglobal', 'CasesEurope', 'OSCAR_Communication'});

        filterCustomerService = 'Open';
        filterAccreditation = 'Open';
        filterAgencyRiskManagement = 'Open';
        filterSidra = 'Open';
        filterRemaining = 'Open';
    }

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