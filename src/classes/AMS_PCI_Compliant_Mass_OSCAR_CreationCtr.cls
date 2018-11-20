public with sharing class AMS_PCI_Compliant_Mass_OSCAR_CreationCtr{

    public static final Integer MAX_SEARCH_ELEMENTS = 5000;

    public Integer totalErrors { get; set; }
    public Integer totalCreated { get; set; }
    public Boolean isBatchRunning { get; set; }
    public Boolean isBatchFinished { get; set; }
    public Id batchId { get; set; }
    public list<jsonError> allErrorMessages { get; set; }
    public list<jsonError> errorMessagesToShow { get; set; }
    private integer counter=0;  //keeps track of the offset
    private integer list_size=10; //sets the page size or number of rows
    public String csvFileContent {get;set;} //AMSU-189

    public boolean updateTable {
        get{
            if(updateTable == null)
                this.updateTable = false;

            return this.updateTable;
        }
        set;
    }

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
                for (IATA_ISO_Country__c c : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'Name')) {
                    if(c.Region__c == region && c.Sub_Region__c != 'USA'){
                        if((operation == 'PCI' && !c.ANG_Enable_NewGen__c) || (operation != 'PCI' && c.ANG_Enable_NewGen__c)) {//AMSU-159
                            availableCountries.add(new SelectOption(c.Id , c.Name));
                        }
                    }
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
                if(operation == 'PCI') availableLocations.add(new SelectOption(AMS_Utils.HO,AMS_Utils.HO));
                availableLocations.add(new SelectOption(AMS_Utils.HE,AMS_Utils.HE));
                if(operation == 'PCI')  availableLocations.add(new SelectOption(AMS_Utils.BR,AMS_Utils.BR));
                availableLocations.add(new SelectOption(AMS_Utils.AE,AMS_Utils.AE));
            }
            return availableLocations;
        }
        set;
    }

    /*** AMSU-157 ***/
    public List<SelectOption> selectedClasses {
        get{
            if(selectedClasses == null) selectedClasses = new List<SelectOption>();
            return selectedClasses;
        }
        set;
    }

    public List<SelectOption> availableClasses {
        get{
            if(availableClasses == null){
                availableClasses = new List<SelectOption>();
                availableClasses.add(new SelectOption('P', 'P'));
                availableClasses.add(new SelectOption('D', 'D'));
            }
            return availableClasses;
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
        allErrorMessages = new list<jsonError>();
    }

    // ****************************************
    // ************* action methods ***********
    // ****************************************

    public void reset(){
        availableLocations = null;
        selectedLocations = null;
        availableCountries = null;
        selectedCountries = null;
        availableClasses = null;
        selectedClasses = null;
        summaryMap = null;
        accountIds = null;
        /*** AMSU-189 ***/
        isBatchRunning = false;
        isBatchFinished = false;
        batchId = null;
        csvFileContent = null;
    }

    public void search() {
        summaryMap = null;
        accountIds = null;
        //input validations
        if(selectedCountries.isEmpty()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Select a Country'));
        if(selectedLocations.isEmpty()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Select a Location'));
        /*** AMSU-157 ***/
        if(operation == 'PCI' && selectedClasses.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Select a Location Class'));
        }

        if(ApexPages.hasMessages()) return;
        
        //set filters
        Set<String> countries = new Set<String>();
        for(SelectOption c : selectedCountries) countries.add(c.getValue());

        Set<String> locations = new Set<String>();
        for(SelectOption c : selectedLocations) locations.add(c.getValue());

        Set<String> locationClass = new Set<String>();
        if(operation == 'FOP') {
        locationClass.add(AMS_Utils.LC_PASSENGER);
            locationClass.add('D');
        } else { //AMSU-157
            for(SelectOption c : selectedClasses) locationClass.add(c.getValue());
        }

        Set<String> statuses = new Set<String> {AMS_Utils.ACC_S9_APPROVED, AMS_Utils.ACC_S5_CASHNOCOMMISSION, AMS_Utils.ACC_S6_CASHWITHCOMMISSION, AMS_Utils.ACC_S8_CHANGESPROCESSED, AMS_Utils.ACC_S4_LISTED, AMS_Utils.ACC_S7_UNDERREVIEW, 'Review'};

        String reason = caseReason.get(operation);
		String recTypeOSCARCOMM = AMS_Utils.RECTYPE_OSCARCOMM; //FM - 10-05-2018 - added OSCAR Communication recordtype to use on the query below

        String agency = AMS_Utils.RECTYPE_IATAAGENCY;


        //Assemble query
        String query = 'SELECT Id, Name, Is_PCI_compliant__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Top_Parent__c, Location_Type__c, IATACode__c ';

        query += 'FROM Account ';
        
        query += 'WHERE Location_Class__c IN :locationClass AND Status__c IN :statuses AND Is_PCI_compliant__c = null AND Location_Type__c IN :locations';
        query += ' AND RecordtypeId = :agency AND IATA_ISO_Country__c IN :countries';

        //FM - 10-05-2018 - removed the close condition and implemented the check by the case recordtype
        //query += ' AND Id NOT IN (SELECT AccountId FROM Case WHERE Reason1__c = :reason AND IsClosed = false) ';
        query += ' AND Id NOT IN (SELECT AccountId FROM Case WHERE Reason1__c = :reason AND RecordTypeId = :recTypeOSCARCOMM) ';

        query += 'LIMIT ' + (MAX_SEARCH_ELEMENTS + 1);

        for(Account a : (List<Account>)Database.query(query)){
            accountIds.add(a.Id);
            String country = a.IATA_ISO_Country__r.Name;
            
            if(summaryMap.containsKey(country)) summaryMap.get(country).toCreate++;
            else summaryMap.put(country, new CountrySummary(country));
        }
    }

    public void createOSCARs() {

        if(operation == 'PCI') batchId = Database.executeBatch(new AMS_PCI_Complaint_Batch(1, accountIds), 1);
        if(operation == 'FOP') batchId = Database.executeBatch(new ANG_MassiveFOPCaseCreationBatch(accountIds), 1);

        startTime = System.now();
        isBatchRunning = true;
    }

    public void compareIDs(){
        String receivedID = Apexpages.currentPage().getParameters().get('batch');
        String message = Apexpages.currentPage().getParameters().get('message');

        if (receivedID == batchId){
            allErrorMessages = (List<jsonError>) System.JSON.deserialize(message , List<jsonError>.class);
            counter = 0;
            setErrorToShow();            
        } 
    }

    public void checkBatchStatus(){

        AsyncApexJob batchRecord = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :this.batchId];
        System.debug(loggingLevel.FINE, '____ [cls AMS_PCI_Compliant_Mass_OSCAR_CreationCtr - checkBatchStatus] batchRecord - ' + batchRecord);
        
        isBatchRunning = batchRecord.Status != 'Aborted' && batchRecord.Status != 'Completed' &&  batchRecord.Status != 'Failed';
        isBatchFinished = !isBatchRunning;
        
        System.debug(loggingLevel.FINE, '____ [cls AMS_PCI_Compliant_Mass_OSCAR_CreationCtr - checkBatchStatus] isBatchRunning - ' + isBatchRunning);
        System.debug(loggingLevel.FINE, '____ [cls AMS_PCI_Compliant_Mass_OSCAR_CreationCtr - checkBatchStatus] isBatchFinished - ' + isBatchFinished);
        
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


    //methods used for pagination of the errors

    public void setErrorToShow(){
        updateTable = false;
        errorMessagesToShow = new List<jsonError>();
        for(Integer i = 0 + counter; i < allErrorMessages.size() && i < counter + list_size ; i ++){
            errorMessagesToShow.add(allErrorMessages[i]);
        }
        updateTable = true;
    }

   public PageReference Beginning() { //user clicked beginning
      counter = 0;
      setErrorToShow();
      return null;
   }

   public PageReference Previous() { //user clicked previous button
      counter -= list_size;
      setErrorToShow();
      return null;
   }

   public PageReference Next() { //user clicked next button
      counter += list_size;
      setErrorToShow();
      return null;
   }

   public PageReference End() { //user clicked end
      counter = (math.mod(allErrorMessages.size(), list_size) == 0 ? allErrorMessages.size() - list_size : allErrorMessages.size() - math.mod(allErrorMessages.size(), list_size) );
      setErrorToShow();
      return null;
   }

   public Boolean getDisablePrevious() { 
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }

   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + list_size < allErrorMessages.size()) return false; else return true;
   }

   public Integer getTotal_size() {
      return allErrorMessages.size();
   }

   public Integer getPageNumber() {
    return counter/list_size + 1;
   }

   public Integer getTotalPages() {
      if (math.mod(allErrorMessages.size(), list_size) > 0) {
         return allErrorMessages.size()/list_size + 1;
      } else {
         return (allErrorMessages.size()/list_size);
      }
   }

    /*** AMSU-189 ***/
    public void uploadFile() {
        System.debug('Upload File');
        System.debug(csvFileContent);

        Set<Id> recordIds = new Set<Id>();
        try {
            List<String> rows = csvFileContent.split('\n');
            rows.remove(0);
            for(String row : rows) {
                recordIds.add(row.trim());       
            }

            if(operation == 'CVR') {
                batchId = Database.executeBatch(new AMS_OSCAR_Mass_ActionBatch(AMS_OSCAR_Mass_ActionBatch.CREATE_VR, 'Account', recordIds), 1);
                isBatchRunning = true;
            } else if(operation == 'PCI_C') {
                System.debug('Start batch');
                System.debug('recordIds: ' + recordIds);
                batchId = Database.executeBatch(new AMS_OSCAR_Mass_ActionBatch(AMS_OSCAR_Mass_ActionBatch.PROCESS_PCI, 'AMS_OSCAR__c', recordIds), 1);
                isBatchRunning = true;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid operation, please contact support.'));
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
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

    public class jsonError{
        public String iataCode{get;set;}
        public String errorMessage{get;set;}  
        
        public jsonError(){}    
    }
}