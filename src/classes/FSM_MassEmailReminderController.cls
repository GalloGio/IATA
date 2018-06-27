public class FSM_MassEmailReminderController {
    private final Id CASE_RECORDTYPE_FSM = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Security_Monitoring');    //Case Record Type
    private final Id ACCNT_RECORDTYPE_AGENCY = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');  //Account Record Type
    private list<string> lsCaseStatusToDisplay = new list<string> {'Open', 'Under Review'}; //List of status to show
    private list<string> lsAccntTypeDisplay = new list<string> {'Cargo Agent', 'Travel Agent'}; //List of account type to show

    public list<SelectOption> soStatus                              {get; set;} //SelectOption with the available status to select
    public list<string> SelectedStatus                              {get; set;} //Selected Status (one or more)

    public list<Selectoption> soAccntType                           {get; set;} //SelectOption with the available Account Type to select
    public list<string> SelectedAccntType                           {get; set;} //Selected account Type (one or more)

    public map<string, list<IATA_ISO_Country__c>> mapCountries      {get; set;} //HTML selectoption with all the available countries. Index of the map is the region
    public string SelectedCountry                                   {get; set;} //Selected country (one)

    public string lsSelectedCases                                   {get; set;} //list with ID of selected cases
    public list<CaseWrapper> cases                                  {get; set;} //List of wrapper

    //SelectOption with the case type to search
    public list<SelectOption> lsCaseTypeToSearch {
        get{
            list<SelectOption> ls = new list<SelectOption>();
            ls.Add(new SelectOption('All', 'All Cases'));
            ls.Add(new SelectOption('Master', 'Master Cases Only'));
            ls.Add(new SelectOption('Latest', 'Latest Cases'));
            return ls;
        }
        set;
    }

    public string sSelectedCaseTypeToSearch                         {get; set;} //Selected Case Type to search

    private Set<string> sentCaseIds;    //Set containing the IDs of cases for which the email has just been sent. These IDs will be taken out from the query, if re-executed
    private Set<string> selectedCaseIds;    //the contact ids selected by the user
    //set controller
    private ApexPages.StandardSetController setCon = new ApexPages.StandardSetController( [SELECT Id FROM Case where CaseNumber = 'ReturnFakeCase'] );

    public boolean getHasCases() {return this.setCon.getResultSize() < 1 || this.setCon == null ? false : true;}

    private final integer iNumStartingPage = 1; //set the starting page of the recordset
    public integer iPageSize = 25; //set the page size for the recordset
    public string getThePageSize() {return string.ValueOf(iPageSize);}
    private string sQueryWhereCondition;
    private list<Case> lsInternalCases;

    /****************************************/
    /************** CONTROLLER **************/
    /****************************************/
    public FSM_MassEmailReminderController() {
        //PageNumber = 1;
        lsSelectedCases = '';
        SelectedCountry = '';
        sSelectedCaseTypeToSearch = 'All';
        lsInternalCases = new list<Case>();
        this.sentCaseIds = new set<string>();
        //sQuery = '';
        sQueryWhereCondition = '';
        if (SelectedStatus == null) {
            SelectedStatus = new list<string>();
            SelectedStatus.addAll(lsCaseStatusToDisplay);
        }
        if (SelectedAccntType == null) {
            SelectedAccntType = new list<string>();
            SelectedAccntType.addAll(lsAccntTypeDisplay);
        }
        InitializeCountries();

        soStatus = new list<SelectOption>();
        soAccntType = new list<SelectOption>();

        InitializeSO(soStatus, lsCaseStatusToDisplay);  //Create the selectoption with the list of the available status for case that can be selected
        InitializeSO(soAccntType, lsAccntTypeDisplay);  //taken from the industry field of account

        //init variable
        if (this.selectedCaseIds == null)
            this.selectedCaseIds = new Set<string>();
        buildSetSelectedCases();

        cases = new list<CaseWrapper>();

    }

    /****************************************/
    /*************** METHODS ****************/
    /****************************************/

    public pageReference setThePageSize(string thePageSize) {
        if (this.iPageSize != integer.valueOf(thePageSize)) {
            this.iPageSize = integer.valueOf(thePageSize);
            return searchCase();
        } else
            return null;
    }

    public class CaseWrapper {
        public boolean isSelected {get; set;}
        public Case theCase  {get; set;}

        public CaseWrapper(Case c) {
            this.isSelected = false;
            this.theCase = c;
        }
    }

    /*Create a map with a list of the countries. Key of the map is the region.*/
    private void InitializeCountries() {
        mapCountries = new map<string, list<IATA_ISO_Country__c>>();
        for (IATA_ISO_Country__c iso : [select Id, Name, ISO_CODE__c, Region__c from IATA_ISO_Country__c order by Region__c, Name]) {
            string sKey = iso.Region__c == '' ? '-' : iso.Region__c;
            list<IATA_ISO_Country__c> lsCountry;
            if (mapCountries.get(sKey) == null)
                lsCountry = new list<IATA_ISO_Country__c>();
            else
                lsCountry = mapCountries.get(sKey);

            lsCountry.add(iso);
            mapCountries.put(sKey, lsCountry);
        }
    }

    private void InitializeSO(list<SelectOption> lsSO, list<string> lsValues) {
        for (string s : lsValues)
            lsSO.add(new SelectOption(s, s));
    }

    public pageReference UpdatePageSize() {
        QueryForCases();
        return null;
    }

    public void QueryForCases() {
        string sQuery = '';
        lsInternalCases.clear();
        sQueryWhereCondition = '';
        sQuery = 'Select id, CaseNumber, CreatedDate, Status, FSM_Flag__c, Account.Name, Account.IATACode__c, Account.Status__c, Account.Industry, Reminder_EmailTemplate__c, ';
        sQuery += ' Account.IATA_ISO_Country__c, Account.IATA_ISO_Country__r.Name, Account.Location_Type__c, Account.BillingCountry, Contact.Name, Contact.Email from Case ';
        sQueryWhereCondition += ' where RecordTypeId=:CASE_RECORDTYPE_FSM and status in:SelectedStatus ';
        sQueryWhereCondition += ' and Account.Industry in:SelectedAccntType';
        sQueryWhereCondition += ' and Reminder_EmailTemplate__c!=\'\'';

        if (SelectedCountry != 'WW')
            sQueryWhereCondition += ' and Account.Country_ISO_Code__c = :SelectedCountry';

        if (sSelectedCaseTypeToSearch == 'Master')
            sQueryWhereCondition += ' and FSM_Flag__c = \'\'';

        //exclude case for which the mail has just been sent
        if (!this.sentCaseIds.isEmpty())
            sQueryWhereCondition += ' and id not in:sentCaseIds';

        sQueryWhereCondition += ' order by AccountId, CreatedDate DESC';

        sQueryWhereCondition += ' LIMIT 50000';

        list<Case> lsTmpCase = database.query(sQuery + sQueryWhereCondition);

        if (sSelectedCaseTypeToSearch == 'All' || sSelectedCaseTypeToSearch == 'Master')
            lsInternalCases.addAll(lsTmpCase);
        else {
            id lastAccntId = null;
            for (Case cs : lsTmpCase) {
                if (cs.AccountId != null) {
                    if (cs.AccountId != lastAccntId) {
                        lsInternalCases.add(cs);
                        lastAccntId = cs.AccountId;
                    }
                }
            }
        }

        this.setCon = null;
        this.setCon = new ApexPages.StandardSetController(lsInternalCases);
        this.setCon.setPageSize(iPageSize);
        this.setCon.setPageNumber(1);
        cases = UpdateCaseWrapperList();
    }

    public pageReference searchCase() {
        string sMsg = '';

        if (SelectedCountry == '' || SelectedCountry == '--Please Select--')
            sMsg += 'Please select one country; ';

        if (SelectedAccntType.size() == 0)
            sMsg += 'Please select at least one account type; ';

        if (SelectedStatus.size() == 0)
            sMsg += 'Please select at least one status; ';

        if (sMsg == '') {
            selectedCaseIds.clear();
            QueryForCases();
        } else
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, sMsg));

        return null;
    }


    public pageReference sendMails() {
        buildSetSelectedCases();
        if (!this.selectedCaseIds.isEmpty())
            this.sentCaseIds.addAll(this.selectedCaseIds);
        QueryForCases();
        return InvokeBatchToSendMail(false);
    }

    public pageReference sendMailsToAll() {
        this.selectedCaseIds.clear();
        this.sentCaseIds.clear();
        if (!lsInternalCases.isEmpty()) {
            for (Case c : lsInternalCases) {
                this.selectedCaseIds.add(c.id);
                this.sentCaseIds.add(c.id);
            }
            this.setCon = new ApexPages.StandardSetController( [SELECT Id FROM Case where CaseNumber = 'ReturnFakeCase'] );
            cases = UpdateCaseWrapperList();
            return InvokeBatchToSendMail(true);
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please, search agent before sending emails'));
        }
        return null;
    }

    public PageReference InvokeBatchToSendMail(boolean bAll) {
        if (this.selectedCaseIds.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please, select at least one agent before sending emails'));
        } else {
            List<Case> cases = [Select c.Contact.Email, c.Account.AIMS_ID__c, c.CaseNumber, c.Account.Name, c.CurrencyISOCode, c.Financial_Security_Amount_2__c, c.FS_Deadline_Date__c, c.Account.Industry, c.Mass_Email_Send__c, c.EmailTemplate__c, c.FS_Reminder_EmailTemplate__c, c.Reminder_EmailTemplate__c, c.FS_Mass_Email_Send__c From Case c Where c.Id IN :selectedCaseIds];
            FSM_MassEmailReminderBatch cBatch = new FSM_MassEmailReminderBatch();
            cBatch.caseList = cases;
            ID batchprocessid = Database.executeBatch(cBatch, 10);

            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'The Email Requests have been created but may take some time to be sent.'));
            this.selectedCaseIds.clear();
            lsSelectedCases = '';
        }
        return null;
    }

    public void buildSetSelectedCases() {
        this.selectedCaseIds.clear();
        this.selectedCaseIds.addAll(lsSelectedCases.split(';'));
        if (this.selectedCaseIds.contains(''))
            this.selectedCaseIds.remove('');
    }

    //advance to next page
    public void doNext() {
        buildSetSelectedCases();
        if (this.setCon.getHasNext())
            this.setCon.next();

        cases = UpdateCaseWrapperList();
    }

    //advance to previous page
    public void doPrevious() {
        buildSetSelectedCases();
        if (this.setCon.getHasPrevious())
            this.setCon.previous();
        cases = UpdateCaseWrapperList();
    }

    private list<CaseWrapper> UpdateCaseWrapperList() {
        List<CaseWrapper> lsCW = new List<CaseWrapper>();
        for (sObject r : this.setCon.getRecords()) {
            Case c = (Case)r;
            CaseWrapper CW = new CaseWrapper(c);
            CW.IsSelected = this.selectedCaseIds.contains(c.Id);

            lsCW.add(CW);
        }
        return lsCW;
    }

    //return whether previous page exists
    public Boolean getHasPrevious() {return this.setCon.getHasPrevious();}

    //return whether next page exists
    public Boolean getHasNext() {return this.setCon.getHasNext();}

    //return page number
    public Integer getPageNumber() {return this.setCon.getPageNumber();}

    //return total pages
    Public Integer getTotalPages() {
        Decimal totalSize = this.setCon.getResultSize();
        Decimal pageSize = this.setCon.getPageSize();
        Decimal pages = totalSize / pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
}