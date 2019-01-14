public class AMS_SAAMCaseMigrationController {

    private String SPECIFIC_CASES = 'Specific Cases';
    private String ALL_CASES = 'All SAAM Cases';
    private String ALL_FROM_PORTAL = 'All SAAM Cases from Portal';
    private String ALL_NOT_FROM_PORTAL = 'All SAAM Cases not from Portal';

    private final Integer PAGE_SIZE = 50; //max size: 1000
    private final Integer RECORD_LIMIT = 750; //prevent view state limit, if you increase page size, decrease limit
    private final Id SAAMCaseRecType = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM

    public String caseNumbers   { get; set; }
    public String searchOption  { get; set; }
    public Boolean selectAll    { get; set; }

    private List<String> caseMigratedFields = new List<String> {'Financial_Assessment_compliant__c','Financial_Assessment_received__c','Bank_Guarantee_deadline__c','Bank_Guarantee_received__c','Bank_Guarantee_requested__c','Change_effective_as_of__c','Criteria_remarks__c','Documentation_remarks__c','Dossier_reception_date__c','Fees_refund_requested__c','Finalization_checklist__c','Financial_Assessment_deadline__c','Financial_Assessment_requested__c','Financial_Review_Result__c','Invoice_number__c','Local_Inspection_compliant__c','Local_Inspection_deadline__c','Local_Inspection_received__c','Local_Inspection_requested__c','Process_Start_Date__c','Proof_of_payment_received__c','PSAA_EACP_Agreement_received__c','PSAA_signed_copy_sent__c','SAAM_Deadline_Date__c','AIMS_updated__c','Finalized_in_AIMS__c'};

    private Map<String, String> pageQueriesOption {
        get {
            return new Map<String, String> {
                SPECIFIC_CASES => 'SPECIFIC_CASES',
                ALL_CASES => 'ALL_CASES',
                ALL_FROM_PORTAL => 'ALL_FROM_PORTAL',
                ALL_NOT_FROM_PORTAL => 'ALL_NOT_FROM_PORTAL'
            };
        }
        set;
    }

    private Map<String, String> pageQueries {
        get {
            if(pageQueries == null){
                pageQueries = new Map<String, String> {

                    'SPECIFIC_CASES_QUERY' => 'SELECT Id, CaseNumber, OSCAR__c , OSCAR__r.Id ' + caseFieldsStr + toMigrateFields + ' , Account.IATACode__c ,  Contact.Email, Account.Category__c,Account.Location_Class__c,Account.ParentId,Account.Location_Type__c FROM CASE WHERE OSCAR__c = \'\' and CaseNumber In :caseNumberList and RecordTypeId = :SAAMCaseRecType and isCLosed = false and status != \'Draft\' and CaseArea__c in( \'Accreditation Process\' , \'Accreditation Products\' , \'Airline Management Process\') and Reason1__c in (\'Certificate DGR\',\'ERSP\',\'TIDS\', \'New BR / IP\' ,\'New BR Abroad\' ,\'New HO\',\'Manage Changes / Major\',\'CHL - Change of Location\',\'CHO / CHS – Change of Ownership / Legal Status\',\'CHN - Change of Name\',\'CHC – Change of Shareholding\' , \'CLO - Closure\' , \'ID card\' , \'Operational changes\' , \'PAX/CARGO Certificate\') and OwnerId not in :queueRecycle',
                
                    'ALL_CASES_QUERY' => 'SELECT Id, CaseNumber , OSCAR__c , OSCAR__r.Id' + caseFieldsStr + toMigrateFields + ' , Account.IATACode__c , Contact.Email, Account.Category__c,Account.Location_Class__c,Account.ParentId,Account.Location_Type__c FROM CASE WHERE OSCAR__c = \'\' and RecordTypeId = :SAAMCaseRecType and isCLosed = false and status != \'Draft\' and CaseArea__c in( \'Accreditation Process\' , \'Accreditation Products\', \'Airline Management Process\') and Reason1__c in (\'Certificate DGR\',\'ERSP\',\'TIDS\',\'New BR / IP\' ,\'New BR Abroad\' ,\'New HO\',\'Manage Changes / Major\',\'CHL - Change of Location\',\'CHO / CHS – Change of Ownership / Legal Status\',\'CHN - Change of Name\',\'CHC – Change of Shareholding\' , \'CLO - Closure\' , \'ID card\' , \'PAX/CARGO Certificate\') and OwnerId not in :queueRecycle',
                
                    'ALL_FROM_PORTAL_QUERY' => 'SELECT Id, CaseNumber, OSCAR__c , OSCAR__r.Id ' + caseFieldsStr + toMigrateFields + ' , Account.IATACode__c , Contact.Email, Account.Category__c,Account.Location_Class__c,Account.ParentId,Account.Location_Type__c  FROM CASE WHERE OSCAR__c = \'\' and Id IN :SAAMCaseWithAccreditations and RecordTypeId = :SAAMCaseRecType and isCLosed = false and status != \'Draft\' and CaseArea__c in( \'Accreditation Process\' , \'Accreditation Products\', \'Airline Management Process\') and Reason1__c in (\'Certificate DGR\',\'ERSP\',\'TIDS\',\'New BR / IP\' ,\'New BR Abroad\' ,\'New HO\',\'Manage Changes / Major\',\'CHL - Change of Location\',\'CHO / CHS – Change of Ownership / Legal Status\',\'CHN - Change of Name\',\'CHC – Change of Shareholding\' , \'CLO - Closure\' , \'ID card\' , \'Operational changes\' , \'PAX/CARGO Certificate\') and OwnerId not in :queueRecycle',
                
                    'ALL_NOT_FROM_PORTAL_QUERY' => 'SELECT Id, CaseNumber, OSCAR__r.Id ' +  caseFieldsStr + toMigrateFields + ' , Account.IATACode__c , Contact.Email, Account.Category__c,Account.Location_Class__c,Account.ParentId,Account.Location_Type__c  FROM CASE WHERE OSCAR__c = \'\' and Id not in :SAAMCaseWithAccreditations and RecordTypeId = :SAAMCaseRecType and isCLosed = false and status != \'Draft\' and CaseArea__c in( \'Accreditation Process\' , \'Accreditation Products\', \'Airline Management Process\') and Reason1__c in (\'Certificate DGR\',\'ERSP\',\'TIDS\',\'New BR / IP\' ,\'New BR Abroad\' ,\'New HO\',\'Manage Changes / Major\',\'CHL - Change of Location\',\'CHO / CHS – Change of Ownership / Legal Status\',\'CHN - Change of Name\',\'CHC – Change of Shareholding\' , \'CLO - Closure\' , \'ID card\' , \'Operational changes\' , \'PAX/CARGO Certificate\') and OwnerId not in :queueRecycle'
                
                };

                System.debug(loggingLevel.INFO, '____ [cls AMS_SAAMCaseMigrationController - pageQueries] pageQueries - ' + pageQueries);
            }
            return pageQueries;
        }
        set;
    }

    private List<String> caseNumberList{
        get{
            return caseNumbers.split('\\s*[,\\n\\r]\\s*');
        }
    }

    private List<Schema.SObjectField> caseFields{
        get{
            return new List<Schema.SObjectField>{
                Case.OwnerId,
                Case.Status,
                Case.RecordType__c,
                Case.Reason1__c,
                Case.AccountId,
                Case.BSPCountry__c
                
            };
        }
    }

    private String caseFieldsStr{
        get{
            caseFieldsStr = '';         
            for(String field : caseFieldNames) caseFieldsStr += ', '+field;
            return caseFieldsStr;
        }
        set;
    }

    private String toMigrateFields{
        get{
            toMigrateFields = '';         
            for(String field : caseMigratedFields) toMigrateFields += ', '+field;
            return toMigrateFields;
        }
        set;
    }

    private Set<Id> SAAMCaseWithAccreditations{
        get{
            if(SAAMCaseWithAccreditations == null){
                SAAMCaseWithAccreditations = new Set<Id>();
                for(AMS_Pax_Accreditation_Form__c f : [SELECT SAAM_Case__c 
                                                        FROM AMS_Pax_Accreditation_Form__c 
                                                        WHERE SAAM_Case__r.RecordTypeId = :SAAMCaseRecType 
                                                        AND SAAM_Case__r.isCLosed = false 
                                                        AND SAAM_Case__r.OSCAR__c = '']){
                    SAAMCaseWithAccreditations.add(f.SAAM_Case__c);
                }
            }
            return SAAMCaseWithAccreditations;
        }
        set;
    }


    //************************************
    //********** contructor **************
    //************************************

    public AMS_SAAMCaseMigrationController() { }


    //************************************
    //******** public getters ************
    //************************************


    public List<List<AMS_MigrationToolHelper.CaseContainer>> saamCases{
        get{
            if(saamCases == null) saamCases = new List<List<AMS_MigrationToolHelper.CaseContainer>>();
            return saamCases;
        }
        set;
    }

    public List<String> getEmptyList(){
        return new List<String>{ 'No records found'};
    }

    public List<SelectOption> searchOptions {
        get{
            if(searchOptions == null){
                searchOptions = new List<SelectOption>{
                    new SelectOption(ALL_CASES, ALL_CASES),
                    new SelectOption(ALL_FROM_PORTAL, ALL_FROM_PORTAL),
                    new SelectOption(ALL_NOT_FROM_PORTAL, ALL_NOT_FROM_PORTAL),
                    new SelectOption(SPECIFIC_CASES, SPECIFIC_CASES)
                };
            }
            return searchOptions;
        }
        set;
    }

    public List<String> caseFieldNames {
        get{
            if(caseFieldNames == null){
                caseFieldNames = new List<String>();
                for(Schema.SObjectField field : caseFields) caseFieldNames.add(field.getDescribe().getName());
            }
            return caseFieldNames;
        }
        set;
    }

    public Integer pageNumber{
        get{
            if(pageNumber == null) pageNumber = 1;
            return pageNumber;
        }
        set;
    }

    public Boolean searched{
        get{
            if(searched == null) searched = false;
            return searched;
        }
        set;
    }

    public Boolean processing{
        get{
            if(processing == null) processing = false;
            return processing;
        }
        set;
    }

    public Boolean showTextArea{
        get{
            return searchOption == SPECIFIC_CASES;
        }
        set;
    }

    public List<AMS_MigrationToolHelper.CaseContainer> casesOnPage {
        get{
            return saamCases[pageNumber-1];
        }
        set;
    }


    //************************************
    //*********** helpers ****************
    //************************************

    private Boolean isFromPortal(Case c){
        Boolean fromPortal = SAAMCaseWithAccreditations.contains(c.Id);

        System.debug(loggingLevel.Debug, '____ [cls AMS_SAAMCaseMigrationController - isFromPortal] '+c.CaseNumber+' is from Portal ? - ' + fromPortal);
        return SAAMCaseWithAccreditations.contains(c.Id);
    }


    //************************************
    //*********** actions ****************
    //************************************

    public PageReference cancel() {
        return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
    }

    public void doSelectAll() {
        for(AMS_MigrationToolHelper.CaseContainer cc : casesOnPage) if(!cc.migrated) cc.selected = selectAll;
    }

    public void search() {

        Map<id,Group> aMap = new Map<id,Group>([select Id from Group where Type = 'Queue' and Name like '%recycle%']);

        Set<Id> queueRecycle = aMap.keyset();


        if(!(searchOption == SPECIFIC_CASES || searchOption == ALL_FROM_PORTAL || searchOption == ALL_NOT_FROM_PORTAL || searchOption == ALL_CASES)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Not a valid option, please choose a valid option.'));
            return;
        }

        saamCases = new List<List<AMS_MigrationToolHelper.CaseContainer>>();
        List<AMS_MigrationToolHelper.CaseContainer> cases = new List<AMS_MigrationToolHelper.CaseContainer>();

        if(searchOption == SPECIFIC_CASES || searchOption == ALL_FROM_PORTAL || searchOption == ALL_NOT_FROM_PORTAL){

            System.debug('Search option is:' + pageQueriesOption.get(searchOption) + '_QUERY');

            System.debug('Performing query:' + pageQueries.get(pageQueriesOption.get(searchOption) + '_QUERY'));
            
            for(Case c : Database.query(pageQueries.get(pageQueriesOption.get(searchOption) + '_QUERY'))){

                cases.add(new AMS_MigrationToolHelper.CaseContainer(c,isFromPortal(c)));
            }
        }

        if(searchOption == ALL_CASES){

            System.debug('Performing query:' + pageQueries.get(pageQueriesOption.get(searchOption) + '_QUERY'));
/*
            for(Case c : Database.query(pageQueries.get(pageQueriesOption.get(searchOption) + '_QUERY'))){

                cases.add(new AMS_MigrationToolHelper.CaseContainer(c,false));
            }
*/
            for(Case c : Database.query(pageQueries.get('ALL_FROM_PORTAL' + '_QUERY'))){

                cases.add(new AMS_MigrationToolHelper.CaseContainer(c,true));
            }

            for(Case c : Database.query(pageQueries.get('ALL_NOT_FROM_PORTAL' + '_QUERY'))){

                cases.add(new AMS_MigrationToolHelper.CaseContainer(c,false));
            }
        }

        if(cases.size() > RECORD_LIMIT) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'Too many cases found, showing just the first '+RECORD_LIMIT));

        Integer index = 0;
        List<AMS_MigrationToolHelper.CaseContainer> page = new List<AMS_MigrationToolHelper.CaseContainer>();
        for(AMS_MigrationToolHelper.CaseContainer container : cases){

            page.add(container);

            if(page.size() == PAGE_SIZE){
                saamCases.add(new List<AMS_MigrationToolHelper.CaseContainer>(page));
                page.clear();
            }

            if(index == RECORD_LIMIT) break;
            index++;
        }
        if(!page.isEmpty()) saamCases.add(page);

        searched = true;
    }

    public void first() {
        pageNumber = 1;
    }

    public void previous() {
        pageNumber = pageNumber - 1; 
    }

    public void next() {
        pageNumber = pageNumber + 1; 
    }

    public void last() {
        pageNumber = saamCases.size(); 
    }

    public void convert() {
        List<AMS_MigrationToolHelper.CaseContainer> caseContainers = new List<AMS_MigrationToolHelper.CaseContainer>();

        for(List<AMS_MigrationToolHelper.CaseContainer> page : saamCases){
            for(AMS_MigrationToolHelper.CaseContainer container : page){
                if(container.selected){
                    processing = true;
                    //if(AMS_MigrationToolHelper.alternate) container.fromPortal = true;
                }
            }
        }

        if(!processing) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'No case selected '));   
    }

    public void migrateCases() {
        for(List<AMS_MigrationToolHelper.CaseContainer> page : saamCases){
            for(AMS_MigrationToolHelper.CaseContainer container : page){
                if(container.selected && container.processing){
                    return;
                }else if(container.selected && !container.migrated){

                    try{
                        container.processing = true;
                        if(!Test.isRunningTest())
                            container = AMS_MigrationToolHelper.migratecases(container,null);
                        
                    }catch(Exception e){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));      
                    }

                    return; 
                }
            }
        }
        processing = false;
    }
}