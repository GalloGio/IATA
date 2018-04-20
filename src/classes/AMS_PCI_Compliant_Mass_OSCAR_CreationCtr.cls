public with sharing class AMS_PCI_Compliant_Mass_OSCAR_CreationCtr{

    public static final Integer MAX_SEARCH_ELEMENTS = 5000;

    public Integer totalErrors { get; set; }
    public Integer totalCreated { get; set; }
    public Boolean isBatchRunning { get; set; }
    public Boolean isBatchFinished { get; set; }
    public Id batchId { get; set; }

    public String operation {
        get;
        set{
            if(operation != value){
                operation = value;
                reset();
            }
        }
    }
    public String region {
        get;
        set{
            if(region != value){
                region = value;
                availableCountries = null;
                selectedCountries = null;
            }
        }
    }
    
    public List<SelectOption> selectedCountries {
        get{
            if(selectedCountries == null) selectedCountries = new List<SelectOption>();
            return selectedCountries;
        }
        set;
    }
    public List<SelectOption> availableCountries {
        get{
            if(availableCountries == null){
                availableCountries = new List<SelectOption>();
                for (IATA_ISO_Country__c c : [SELECT Name, Id, ANG_Enable_NewGen__c
                                                FROM IATA_ISO_Country__c
                                                WHERE Case_BSP_Country__c != null
                                                AND Case_BSP_Country__c != ''
                                                AND Region__c = :region
                                                AND Sub_Region__c not in ('USA')
                                                ORDER BY Name]) {
                    if(operation == 'PCI' || c.ANG_Enable_NewGen__c) availableCountries.add(new SelectOption(c.Id , c.Name));
                }
                if(availableCountries.isEmpty()){
                    availableCountries.add(new SelectOption('', '--- No country found ---'));
                }
            }
            return availableCountries;
        }
        set;
    }

    public List<SelectOption> selectedLocations {
        get{
            if(selectedLocations == null) selectedLocations = new List<SelectOption>();
            return selectedLocations;
        }
        set;
    }
    public List<SelectOption> availableLocations {
        get{
            if(availableLocations == null){
                availableLocations = new List<SelectOption>();
                if(operation == 'PCI') availableLocations.add(new SelectOption('HO','HO'));
                availableLocations.add(new SelectOption('HE','HE'));
                if(operation == 'PCI')  availableLocations.add(new SelectOption('BR','BR'));
                availableLocations.add(new SelectOption('AE','AE'));
            }
            return availableLocations;
        }
        set;
    }

    public List<CountrySummary> summary {
        get{
            return summaryMap.values();
        }
    }

    public Integer totalAccounts{
        get{
            return accountIds.size();
        }
    }

    public Boolean tooMuchResults{
        get{
            return accountIds.size() > MAX_SEARCH_ELEMENTS;
        }
    }

    // ****************************************
    // *********** private variables **********
    // ****************************************

    private DateTime startTime;

    private Map<String, String> caseReason {
        get{
            return new Map<String, String>{
                'PCI' => 'PCI DSS Compliant',
                'FOP' => 'FoP Management'
            };
        }
    }

    private Set<Id> accountIds{
        get{
            if(accountIds == null) accountIds = new Set<Id>();
            return accountIds;
        }
        set;
    }

    private Map<String, CountrySummary> summaryMap{
        get{
            if(summaryMap == null) summaryMap = new Map<String, CountrySummary>();
            return summaryMap;
        }
        set;
    }

    // ****************************************
    // ************** constructor *************
    // ****************************************
    public AMS_PCI_Compliant_Mass_OSCAR_CreationCtr(){
        //constructor
    }

    // ****************************************
    // ************* action methods ***********
    // ****************************************

    public void reset(){
        availableLocations = null;
        selectedLocations = null;
        availableCountries = null;
        selectedCountries = null;
        summaryMap = null;
        accountIds = null;
    }

    public void search() {
        summaryMap = null;
        accountIds = null;
        //input validations
        if(selectedCountries.isEmpty()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Select a Country'));
        if(selectedLocations.isEmpty()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Select a Location'));

        if(ApexPages.hasMessages()) return;
        
        //set filters
        Set<String> countries = new Set<String>();
        for(SelectOption c : selectedCountries) countries.add(c.getValue());

        Set<String> locations = new Set<String>();
        for(SelectOption c : selectedLocations) locations.add(c.getValue());

        Set<String> locationClass = new Set<String>();
        locationClass.add(AMS_Utils.LC_PASSENGER);
        if(operation == 'FOP') locationClass.add('D');

        Set<String> statuses = new Set<String> {AMS_Utils.ACC_S9_APPROVED, AMS_Utils.ACC_S5_CASHNOCOMMISSION, AMS_Utils.ACC_S6_CASHWITHCOMMISSION, AMS_Utils.ACC_S8_CHANGESPROCESSED, AMS_Utils.ACC_S4_LISTED, AMS_Utils.ACC_S7_UNDERREVIEW, 'Review'};

        Set<String> isPCICompliant = new Set<String> {'Yes', 'Nil CC', 'No'};

        String reason = caseReason.get(operation);

        String agency = AMS_Utils.RECTYPE_IATAAGENCY;


        //Assemble query
        String query = 'SELECT Id, Name, Is_PCI_compliant__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Top_Parent__c, Location_Type__c, IATACode__c ';

        query += 'FROM Account ';
        
        query += 'WHERE Location_Class__c IN :locationClass AND Status__c IN :statuses AND Is_PCI_compliant__c NOT IN :isPCICompliant AND Location_Type__c IN :locations';
        query += ' AND RecordtypeId = :agency AND IATA_ISO_Country__c IN :countries';

        query += ' AND Id NOT IN (SELECT AccountId FROM Case WHERE Reason1__c = :reason AND IsClosed = false) ';

        query += 'LIMIT ' + (MAX_SEARCH_ELEMENTS + 1);

        for(Account a : (List<Account>)Database.query(query)){
            accountIds.add(a.Id);
            String country = a.IATA_ISO_Country__r.Name;
            
            if(summaryMap.containsKey(country)) summaryMap.get(country).toCreate++;
            else summaryMap.put(country, new CountrySummary(country));
        }
    }

    public void createOSCARs() {

        if(operation == 'PCI') batchId = Database.executeBatch(new AMS_PCI_Complaint_Batch(1, null, accountIds), 1);
        if(operation == 'FOP') batchId = Database.executeBatch(new ANG_MassiveFOPCaseCreationBatch(accountIds), 1);

        startTime = System.now();
        isBatchRunning = true;
    }

    public void checkBatchStatus(){

        AsyncApexJob batchRecord = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :this.batchId];
        
        isBatchRunning = batchRecord.Status != 'Aborted' && batchRecord.Status != 'Completed' &&  batchRecord.Status != 'Failed';
        isBatchFinished = !isBatchRunning;
        
        if(isBatchFinished) {
            if(operation == 'PCI'){
                 List<Technical_Logs__c> logs = [SELECT Status__c, Log__c 
                                                FROM Technical_Logs__c 
                                                WHERE CreatedDate >= :startTime AND Record__c = :this.batchId];

                Set<Id> failedAccounts = new Set<Id>();
                for(Technical_Logs__c log : logs) failedAccounts.add(log.Status__c);

                for(Account acc : [SELECT Id, IATA_ISO_Country__r.Name FROM Account WHERE Id IN :failedAccounts]) {
                    summaryMap.get(acc.IATA_ISO_Country__r.Name).errors++;
                }

                for(CountrySummary country : summary){
                    country.created = country.toCreate - country.errors;
                }
            }

            if(operation == 'FOP'){
                for(Case c : [SELECT Id, Account.IATA_ISO_Country__r.Name  FROM Case WHERE AccountId IN :accountIds AND Reason1__c = 'FoP Management' AND Origin = 'Massive FOP Creation' AND CreatedDate > :startTime]){
                    summaryMap.get(c.Account.IATA_ISO_Country__r.Name).created++;
                }

                for(CountrySummary country : summary){
                    country.errors = country.toCreate - country.created;
                    
                }
            }

        }
    }

    // ****************************************
    // ************* helper methods ***********
    // ****************************************

    public class CountrySummary{
        public String name { get; set; }
        public Integer toCreate { get; set; }
        public Integer errors { get; set; }
        public Integer created { get; set; }

        public CountrySummary(String name){
            this.name = name;
            toCreate = 1;
            errors = 0;
            created = 0;
        }
    }
}