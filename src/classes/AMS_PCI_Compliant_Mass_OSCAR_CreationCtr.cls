public with sharing class AMS_PCI_Compliant_Mass_OSCAR_CreationCtr{

    public static final Id AGENCY_RECORDTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordtypeId();
    public static final Integer MAX_SEARCH_ELEMENTS = 5000;

    public WrapperFilter filter {get;set;}

    public Map<String,IATA_ISO_Country__c> mCountries;
    public List<String> dailyCountry {get; set;}
    public List<String> countryList {get; set;}
    public List<SelectOption> countrySelected {get; set;}

    /*** AMSU-113 Start ***/
    public AMS_PCI_Complaint_Batch batchClass {get;set;}
    public Datetime batchStartTime {get;set;}
    public Boolean isBatchRunning {get;set;}
    public Boolean isBatchFinished {get;set;}
    public Boolean isPollerActive {get;set;}
    public Boolean showResults {get;set;}
    public Boolean tooMuchResults {
        get {
            return srw.totalAccounts > MAX_SEARCH_ELEMENTS;
        }
        set;
    }
    public Id batchId {get;set;}
    public SearchResultWrapper srw {get;set;}

    public AMS_PCI_Compliant_Mass_OSCAR_CreationCtr() {
    	dailyCountry = new List<String>();
    	countrySelected = populateSelectedCountries(dailyCountry);
        reset(); 
        isBatchRunning = false;
        isBatchFinished = false;
        isPollerActive = false;
        showResults = false;
        srw = new SearchResultWrapper();
    }

    public class SearchResultWrapper {
        public Map<String, List<Id>> mapCountriesAccounts {get;set;}
        public Map<String, Integer> mapNrAccounts {
            get {
                Map<String, Integer> res = new Map<String, Integer>();
                for(String country : mapCountriesAccounts.keySet()) {
                    res.put(country, mapCountriesAccounts.get(country).size());
                }
                return res;
            }
            set;
        }
        public Map<String, Integer> mapCountriesErrors {get;set;}
        public Integer totalErrors {
            get {
                Integer total = 0;
                for(Integer i : mapCountriesErrors.values()) {
                    total += i;
                }
                return total;
            }
            set;
        }
        public Integer totalAccounts {
            get {
                Integer total = 0;
                for(List<Id> accs : mapCountriesAccounts.values()) {
                    if(accs != null) {
                        total += accs.size();
                    }
                } 
                return total;
            }
            set;
        }

        public SearchResultWrapper() {
            this.mapCountriesAccounts = new Map<String, List<Id>>();
            this.mapCountriesErrors = new Map<String, Integer>();
        }
    }

    public PageReference createPCIOscar() {
        batchStartTime = Datetime.now();
        isPollerActive = true;
        Set<Account> filteredAccounts = new Set<Account>();
        for(List<Id> accs : srw.mapCountriesAccounts.values()) {
            for(Id accId : accs) {
                filteredAccounts.add(new Account(Id= accId));
            }
        }

        if(filteredAccounts.isEmpty()) {
            isPollerActive = false;
            return null;
        }

       batchClass = new AMS_PCI_Complaint_Batch(1, null, filteredAccounts);
       batchId = Database.executeBatch(batchClass, 1);
       isBatchRunning = true;

       return null;
    }

    public void searchAccounts() {
        this.filter.country = getMultiSelectOptions(CountrySelected);
        if(this.filter.country==null || this.filter.country.size()==0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Select an Country'));
            reset();
            return;
        }

        String locationClass = AMS_Utils.LC_PASSENGER;
        Set<String> lstStatus = new Set<String> {AMS_Utils.ACC_S9_APPROVED, AMS_Utils.ACC_S5_CASHNOCOMMISSION, AMS_Utils.ACC_S6_CASHWITHCOMMISSION, AMS_Utils.ACC_S8_CHANGESPROCESSED, AMS_Utils.ACC_S4_LISTED, AMS_Utils.ACC_S7_UNDERREVIEW, 'Review'};
        Set<String> isPCICompliantLst = new Set<String> {'Yes', 'Nil CC', 'No'};
        Set<String> countryIds = new Set<String>(this.filter.country);
        String reason = 'PCI DSS Compliant';
        String query = 'SELECT Id, Name, Is_PCI_compliant__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Top_Parent__c,';
        query +=       ' Location_Type__c, IATACode__c ';
        query +=       'FROM Account ';
        query +=       'WHERE Location_Class__c = :locationClass AND Status__c IN :lstStatus AND Is_PCI_compliant__c NOT IN :isPCICompliantLst';
        query +=       ' AND RecordtypeId = :AGENCY_RECORDTYPE AND IATA_ISO_Country__c IN :countryIds';
        query +=       ' AND Id NOT IN (SELECT AccountId FROM Case WHERE Reason1__c = :reason AND IsClosed = false) ';
        query +=       ' LIMIT ' + (MAX_SEARCH_ELEMENTS + 1);

        List<Account> accounts = (List<Account>) Database.query(query);
        srw = new SearchResultWrapper();
        for(Account acc : accounts) {
            List<Id> accs = srw.mapCountriesAccounts.get(acc.IATA_ISO_Country__r.Name);
            
            if(accs == null) {
                accs = new List<Id>();
                srw.mapCountriesAccounts.put(acc.IATA_ISO_Country__r.Name, accs);
                srw.mapCountriesErrors.put(acc.IATA_ISO_Country__r.Name, 0);
            }

            accs.add(acc.Id);
        }


        showResults = true;
    }

    public PageReference checkBatchStatus() {
        if(batchId != null) {
            system.debug('batchClass: ' + batchClass);
            AsyncApexJob batchRecord = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :this.batchId];
            isBatchRunning = batchRecord.Status != 'Aborted' && batchRecord.Status != 'Completed' &&  batchRecord.Status != 'Failed';
            isBatchFinished = !isBatchRunning;
            if(isBatchFinished) {
                checkLogs();
                isPollerActive = false;
            }
        }
        return null;
    }

    public void checkLogs() {
         List<Technical_Logs__c> logs = [SELECT Status__c, Log__c 
                                        FROM Technical_Logs__c 
                                        WHERE CreatedDate >= :batchStartTime AND Record__c = :this.batchId];


        Set<Id> accountIds = new Set<Id>();
        for(Technical_Logs__c log : logs) {
            accountIds.add(log.Status__c);
        }

        List<Account> accs = [SELECT Id, IATA_ISO_Country__r.Name FROM Account WHERE Id IN :accountIds];

        for(Account acc : accs) {
            Integer errors = srw.mapCountriesErrors.get(acc.IATA_ISO_Country__r.Name);
            errors++;
            srw.mapCountriesErrors.put(acc.IATA_ISO_Country__r.Name, errors);
        }
    }

    public PageReference searchPreview() {
        searchAccounts();
        return null;
    }

    /*** AMSU-113 End ***/

    public List<SelectOption> countryNameListSelectOption {
        get {

            List<SelectOption> auxListSO = countryNameListSelectOption();
            List<SelectOption> auxListSO_clone = countryNameListSelectOption();

            for(Integer i=countrySelected.size()-1; i >= 0 ; i--){
                Boolean bExist = false;
                for(SelectOption auxSO2 : auxListSO){
                    if(countrySelected.get(i).getValue() == auxSO2.getValue()){
                        bExist = true;
                    }
                }
                if(!bExist){
                    countrySelected.remove(i);
                }
            }

            for(Integer i=auxListSO_clone.size()-1; i >= 0 ; i--) {
                Boolean bExist = false;
                for(SelectOption auxSO2 : countrySelected){
                    if(auxListSO.get(i) != null && auxSO2.getValue() != null && auxListSO.get(i).getValue() == auxSO2.getValue()){
                        auxListSO.remove(i);
                        break;
                    }
                }

            }
            return auxListSO;
        }
        set;
    }

    public List<SelectOption> populateSelectedCountries(List<String> lSelectedCountries){

        List<SelectOption> auxSO = new List<SelectOption>();

        for(String aux : lSelectedCountries){
            
            if(!mCountries.containsKey(aux)){
                continue;
            }
            
            IATA_ISO_Country__c iso = mCountries.get(aux);

            auxSO.add(new SelectOption(iso.Id , iso.Name));
                   
        }
        return auxSO;
    }

     public List<String> getMultiSelectOptions(List<SelectOption> vals) {
        List<String> res = new List<String>();
        
        if(vals != null && vals.size() > 0) {           
            for(SelectOption val : vals) {
                res.add(val.getValue());
            }
        }
        
        return res;
    }


    /**
        Return the label of the Approval button based on the filter
    **/
    public String getApprovalButtonLabel() {
        return 'Create PCI OSCAR\'s';
    } 
   
    /**
        Reset filter
    **/
    public PageReference reset() {
        this.filter = new WrapperFilter();
        fillMapCountries();
        isBatchRunning = false;
        isBatchFinished = false;
        isPollerActive = false;
        showResults = false;
        srw = new SearchResultWrapper();
        return null;
    }

    public List<SelectOption> countryNameListSelectOption() {
        
        List<SelectOption> options = new List<SelectOption>();

        Set<String> sRegion = new Set<String>();
        sRegion.add(this.filter.region);
        
        System.debug('sRegion: ' + sRegion);

        if(sRegion.size() > 0){
            list<IATA_ISO_Country__c> isoList;
            
            isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                FROM IATA_ISO_Country__c
                WHERE Case_BSP_Country__c != null
                AND Case_BSP_Country__c != ''
                AND Region__c in :sRegion
                AND Sub_Region__c not in ('USA')
                ORDER BY Name];
            

            //options.add(new SelectOption('', Label.ISSP_SELECT_COUNTRY));
            for (IATA_ISO_Country__c iso : isoList) {
                //options.add(new SelectOption(iso.ISO_Code__c , iso.Name));
                options.add(new SelectOption(iso.Id , iso.Name));
            }
        }

        if(options.isEmpty()){
            options.add(new SelectOption('--- Select an Area ---', '--- Select an Area ---'));
        }

        System.debug('options: ' + options);

        return options;

    }



    public void fillMapCountries() {

        if(mCountries == null){
            mCountries = new Map<String,IATA_ISO_Country__c>();
        
            List<IATA_ISO_Country__c> isoList;
            
            isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                FROM IATA_ISO_Country__c
                WHERE Case_BSP_Country__c != null
                AND Case_BSP_Country__c != ''
                AND Sub_Region__c not in ('USA')
                ORDER BY Name];
            
            for (IATA_ISO_Country__c iso : isoList) {
                //mCountries.put(iso.ISO_Code__c , iso);
                mCountries.put(iso.Id , iso);
            }
        }

    }


    /**
        class to store all variables required to create a set of filters
        for the Account selection
    **/
    public class WrapperFilter {
        public Account acc {get; set;}
        public String operation {get; set;}
        public String region {get; set;}
        public List<String> country {get; set;}
        
        public WrapperFilter() {
            reset();
        }

        public void reset() {
            this.acc = new Account();
            this.acc.RecordtypeId = AGENCY_RECORDTYPE;
            this.operation = '';
            this.region = '';
            this.country = new List<String>();

        }
    }

}