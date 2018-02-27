public with sharing class AMS_PCI_Compliant_Mass_OSCAR_CreationCtr{

    public static final Id AGENCY_RECORDTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordtypeId();
    public static final Integer MAX_SEARCH_ELEMENTS = 6000;

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
    public Id batchId {get;set;}
    public Map<Id, AccountWrapper> mapAccounts {get;set;}
    public List<AccountWrapper> lstAccountsWrapper {
        get {
            return mapAccounts.values();
        }
        set;
    }
    public Map<Id, String> mapAccountToError {get;set;}
    public String selectedIds {get;set;}

    public AMS_PCI_Compliant_Mass_OSCAR_CreationCtr() {
    	dailyCountry = new List<String>();
    	countrySelected = populateSelectedCountries(dailyCountry);
        reset(); 
        isBatchRunning = false;
        isBatchFinished = false;
        isPollerActive = false;
        showResults = false;
        mapAccounts = new Map<Id, AccountWrapper>();
        mapAccountToError = new Map<Id,String>();       
    }

    public PageReference createPCIOscar() {
        batchStartTime = Datetime.now();
        isPollerActive = true;
        Set<Account> filteredAccounts = new Set<Account>();
        system.debug('selectedIds: ' + selectedIds);
        
        for(AccountWrapper accW : lstAccountsWrapper) {
            if(accW.selected) {
                filteredAccounts.add(accW.accountRecord);
            }
        }

        if(filteredAccounts.isEmpty()) {
            isPollerActive = false;
            return null;
        }
        
        batchClass = new AMS_PCI_Complaint_Batch(1, new Set<String>(this.filter.country), 
            filteredAccounts.size() == lstAccountsWrapper.size() && filteredAccounts.size() != 0  ? null : filteredAccounts);
        batchId = Database.executeBatch(batchClass, 1);
        isBatchRunning = true;
        return null;
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
                searchCases();
            }
        }
        return null;
    }

    public void checkLogs() {
         List<Technical_Logs__c> logs = [SELECT Status__c, Log__c 
                                        FROM Technical_Logs__c 
                                        WHERE CreatedDate >= :batchStartTime AND Record__c = :this.batchId];

        for(Technical_Logs__c log : logs) {
            mapAccountToError.put(log.Status__c, log.Log__c);
        }
    }

    public PageReference searchPreview() {
        searchAccounts();
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
        for(Account acc : accounts) {
            mapAccounts.put(acc.Id, new AccountWrapper(acc));
        }

        if(accounts.size() > MAX_SEARCH_ELEMENTS) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                    'Your search criteria result exceeds the limit of number of records (' + MAX_SEARCH_ELEMENTS + ').' +
                    'Try to apply more filters to reduce the number of records or process your request in multiple sessions'));
        }

        showResults = accounts.size() <= MAX_SEARCH_ELEMENTS;

        searchContacts(accounts);
    }

    public void searchContacts(List<Account> accounts) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Map<String, Contact>> mapContacts = new Map<Id, Map<String, Contact>>();
        for(Account acc : accounts) {
            accountIds.add(acc.Id);
            if(acc.Location_Type__c != 'HO' && acc.Location_Type__c != 'AO' && !String.isBlank(acc.Top_Parent__c)) {
                accountIds.add(acc.Top_Parent__c);
                system.debug('top parent: ' + acc.Top_Parent__c);
            }   
        }

        String query = 'SELECT Id, Name, AccountId, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c ' +
                       'FROM Contact ' +
                       'WHERE AccountId IN :accountIds AND IsEmailBounced = false AND ' +
                       ' (BSP_CASS_Payment_contact__c = true OR Financial_Assessment_Contact__c = true OR User_Portal_Status__c = \'Approved Admin\')';

        List<Contact> contacts = (List<Contact>) Database.query(query);

        system.debug('contacts: ' + contacts);

        Map<Id, List<Contact>> mapAccountToContacts = new Map<Id, List<Contact>>();
        for(Contact con : contacts) {
            List<Contact> lstContacts = mapAccountToContacts.get(con.AccountId);
            if(lstContacts == null) {
                lstContacts = new List<Contact>();
                mapAccountToContacts.put(con.AccountId, lstContacts);
            }
            lstContacts.add(con);
        }

        for(Account acc : accounts) {
            List<Contact> accountContacts = mapAccountToContacts.get(acc.Id);
            if(accountContacts == null) {
                accountContacts = new List<Contact>();
            }
            Map<String, List<Contact>> mapStatusToContacts = new Map<String, List<Contact>>();
            List<Contact> appLst = new List<Contact>();
            List<Contact> finLst = new List<Contact>();
            List<Contact> bspLst = new List<Contact>();
            mapStatusToContacts.put('Approved Admin', appLst);
            mapStatusToContacts.put('Financial contact', finLst);
            mapStatusToContacts.put('BSP Cass contact', bspLst);
            Boolean needsHOContacts = populateMapContacts(accountContacts, mapStatusToContacts);
            if(needsHOContacts) {
                system.debug('top parent needed: ' + mapAccounts);
                accountContacts = mapAccountToContacts.get(acc.Top_Parent__c);
                if(accountContacts == null) {
                    continue;
                }
                populateMapContacts(accountContacts, mapStatusToContacts);
            }
            if(!appLst.isEmpty()) {
                mapAccounts.get(acc.Id).setContact(appLst[0]);
                continue;
            }
            if(!finLst.isEmpty()) {
                mapAccounts.get(acc.Id).setContact(appLst[0]);
                continue;
            }
            if(!bspLst.isEmpty()) {
                mapAccounts.get(acc.Id).setContact(appLst[0]);
            }

        }
    }

    public static Boolean populateMapContacts(List<Contact> contacts, Map<String, List<Contact>> mapContacts) {
        List<Contact> appLst = mapContacts.get('Approved Admin');
        List<Contact> finLst = mapContacts.get('Financial contact');
        List<Contact> bspLst = mapContacts.get('BSP Cass contact');
        for(Contact c : contacts) {
            if(c.User_Portal_Status__c == 'Approved Admin') {
                appLst.add(c);
            }

            if(c.Financial_Assessment_Contact__c) {
                finLst.add(c);
            }

            if(c.BSP_CASS_Payment_contact__c) {
                bspLst.add(c);
            }
        }
        return appLst.isEmpty() && finLst.isEmpty() && bspLst.isEmpty();
    }

    public void searchCases() {
        Set<Id> accountIds = mapAccounts.keySet();

        String reason = 'PCI DSS Compliant';
        String query = 'SELECT Id, CaseNumber, AccountId ' + 
                       'FROM Case ' + 
                       'WHERE AccountId IN :accountIds AND CreatedDate >= :batchStartTime ' +
                       'ORDER BY CreatedDate DESC';

        List<Case> cases = (List<Case>) Database.query(query);

        system.debug('cases: ' + cases);

        for(Case cs : cases) {
            if(mapAccounts.get(cs.AccountId).caseRecord == null) {
                mapAccounts.get(cs.AccountId).setCase(cs);
            }
        }

    }

    public class AccountWrapper {
        public Boolean selected {get;set;}
        public Account accountRecord {get;set;}
        public Contact contactRecord {get;set;}
        public Case caseRecord {get;set;}
        public String portalStatus {get;set;}

        public AccountWrapper(Account acc) {
            selected = false;
            accountRecord = acc;
        }

        public void setContact(Contact con) {
            contactRecord = con;
            if(con != null) {
                portalStatus = getStatus(accountRecord, contactRecord);
            }
        }

        public void setCase(Case cse) {
            caseRecord = cse;
        }

        private String getStatus(Account acc, Contact con) {
            String status;
            if(con.User_Portal_Status__c == 'Approved Admin') {
                status = 'Approved Admin';
            } else if(con.Financial_Assessment_Contact__c) {
                status = 'Financial contact';
            } else if (con.BSP_CASS_Payment_contact__c) {
                status = 'BSP Cass contact';
            } else {
                status = '';
            }

            return status;
        }

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
        this.selectedIds = '';
        fillMapCountries();
        isBatchRunning = false;
        isBatchFinished = false;
        isPollerActive = false;
        showResults = false;
        mapAccounts = new Map<Id, AccountWrapper>();
        mapAccountToError = new Map<Id,String>();
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