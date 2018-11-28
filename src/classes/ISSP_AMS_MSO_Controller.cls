public without sharing class ISSP_AMS_MSO_Controller {
    public static final String IATAORGNAME = 'INTERNATIONAL AIR TRANSPORT ASSOCIATION'; // Name of the IATA endorsement organization

    public String searchText {get; set;}
    public Account currentAccount {get; set;}
    public String SortingDirection {get; set;}
    public String SortBy {get; set;}
    public Boolean isExcludingTerminated {get; set;}

    public static list<AMS_Inspection__c> lstAccountsInHierarchy;
    public Integer pageNumberStatic = 1;
    private Id currentAccountId;
    private Id hqAccountId;
    private String airlineCode;
    public Boolean isMSO {
        get {
            String pageName = ApexPages.currentPage().getUrl().substringAfterLast('/').substringBefore('?');
            String dataParam = ApexPages.currentPage().getParameters().get('data');

            return pageName == 'ISSP_AMS_MSO' || (pageName == 'ISSP_AMS_GSA_MSO_CSV' && dataParam == 'MSO');
        } set;
    }
    public String strRenderAs {
        get {
            String pdfParam = ApexPages.currentPage().getParameters().get('renderAs');
            return (pdfParam == 'pdf' || pdfParam == 'csv') ? 'PDF' : 'HTML';
        } set;
    }

    public list<Account> OrderedFilteredHierarchy;
    public ApexPages.StandardSetController ssc {get;set;}
    public list<AppointmentWrapper> lstDisplayAccounts {
        get {
            list<AppointmentWrapper> tmpList = new list<AppointmentWrapper>();
            if (strRenderAs == 'PDF'){
                for (AMS_Inspection__c a : lstAccountsInHierarchy) {
                    String territories = '';
                    for (AMS_Territory__c t : a.AMS_Territories__r) {
                        territories += (territories == '' ? '' : ', ') + t.ISO_Country__r.Name;
                    }
    
                    tmpList.add(new AppointmentWrapper(a, territories, a.Account__r.Accreditation_date__c, a.Account__r.Expiry_Date__c));
                }
            }else{
	            for (AMS_Inspection__c a : (list<AMS_Inspection__c>)ssc.getRecords()) {
	                String territories = '';
	                for (AMS_Territory__c t : a.AMS_Territories__r) {
	                    territories += (territories == '' ? '' : ', ') + t.ISO_Country__r.Name;
	                }
	
	                tmpList.add(new AppointmentWrapper(a, territories, a.Account__r.Accreditation_date__c, a.Account__r.Expiry_Date__c));
	            }
            }
            System.debug('lstDisplayAccounts:' + tmpList);
            System.debug('lstDisplayAccounts - pageNumberStatic: ' + pageNumberStatic);
            return tmpList;
        } set;
    }

    public Integer recordsPerPage {get; set;}
    public List<SelectOption> getselectOptionItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('25','25'));
        options.add(new SelectOption('50','50'));
        options.add(new SelectOption('100','100'));
        options.add(new SelectOption('200','200'));
        options.add(new SelectOption('500','500'));

        return options;
    }

    
    public List<Data> getData() {
        if(lstAccountsInHierarchy == null) refreshMsoGsaList();
        return getChartData(lstAccountsInHierarchy);
    }

    // The actual chart data; needs to be static to be
    // called by a @RemoteAction method
    public static List<Data> getChartData(list<AMS_Inspection__c> lstAccounts) {
        
        Integer iAll = lstAccounts.size();
        Integer iApproved = 0;
        Integer iClosed = 0;
        for(AMS_Inspection__c appointment : lstAccounts){
            if(appointment.Account__r.Status__c == 'Terminated'){ iClosed++; }else{ iApproved++; }
        }
        List<Data> data = new List<Data>();
        data.add(new Data('Approved', iApproved));
        data.add(new Data('Terminated ', iClosed));
        //data.add(new Data('Total', iAll));
        return data;
    }
    
    // Wrapper class
    public class Data {
        public String name { get; set; }
        public Integer data1 { get; set; }
        public Data(String name, Integer data1) {
            this.name = name;
            this.data1 = data1;
        }
    }
    public ISSP_AMS_MSO_Controller() {
        try {
            User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Contact currentUserContact = [SELECT Id, AccountId FROM Contact WHERE Id = :currentUser.ContactId];
            currentAccount = [SELECT Id, ParentId, RecordType.DeveloperName, Name, Airline_designator__c FROM Account WHERE Id = :currentUserContact.AccountId];
            currentAccountId = currentAccount.Id;
            hqAccountId = currentAccount.RecordType.DeveloperName == 'IATA_Airline' ? currentAccountId : currentAccount.ParentId;
            airlineCode = currentAccount.Airline_designator__c;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to determine current user account.'));
            return;
        }

        recordsPerPage = 25;
        SortBy = 'IATACode__c';
        SortingDirection = 'ASC';
        isExcludingTerminated = ApexPages.currentPage().getParameters().get('exclude') == 'true';
        if (ApexPages.currentPage().getParameters().get('search') != null) searchText = ApexPages.currentPage().getParameters().get('search');

        refreshMsoGsaList();
    }

    public void refreshMsoGsaList() {
        String strQuery = 'SELECT Id, Account__r.Id, Account__r.Name, Account__r.Status__c, Account__r.Expiry_Date__c, Account__r.Accreditation_date__c, Account__r.Location_Class__c, Account__r.IATACode__c, Account__r.Category__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingCountry, Accreditation_Endorsement_Status_code__c, Date_Organisation_Status_attained__c ';

        if (!isMSO) {
            strQuery += ', (SELECT Id, ISO_Country__r.Name FROM AMS_Territories__r ORDER BY ISO_Country__r.Name ASC) ';
        }

        strQuery += ' FROM AMS_Inspection__c WHERE Airline_Code__c = :airlineCode '; //Airline__c = :hqAccountId ';
        strQuery += ' AND Account__r.Location_Class__c = \'' + (isMSO ? 'M' : 'G') + '\'';
        strQuery += ' AND Account__r.Purge_Flag__c = false ';
        strQuery += 'AND Account__r.RecordType.DeveloperName = \'IATA_Agency\' ';

        if (!isMSO) {
            strQuery += ' AND Accreditation_Endorsement_organisation__r.Name <> \'' + IATAORGNAME + '\'';
        }
        
        if (isExcludingTerminated) {
            //strQuery += ' AND Accreditation_Endorsement_Status_code__c <> \'0\'';
            strQuery += ' AND Account__r.Status__c not in (\'Terminated\',\'New application pending\')';
        }else{
            strQuery += ' AND Account__r.Status__c <> \'New application pending\'';
        }

        if (searchText != null && searchText != '') {
            strQuery += ' AND (';
            strQuery += ' Account__r.Name LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += ' OR Account__r.IATACode__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += ' OR Account__r.BillingCountry LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += ')';
        } 

        strQuery += ' ORDER BY Account__r.' + SortBy + ' ' + SortingDirection;

        system.debug('query: ' + strQuery);

        Database.QueryLocator ql;

        if(airlineCode != null && airlineCode != ''){
            lstAccountsInHierarchy = Database.query(strQuery);
            ql = Database.getQueryLocator(strQuery);
        }else{
            lstAccountsInHierarchy = new list<AMS_Inspection__c>();
        }   
        
        //ssc = new ApexPages.StandardSetController(lstAccountsInHierarchy);
        if (strRenderAs != 'PDF')
            ssc = new ApexPages.StandardSetController(ql);
        
        if (strRenderAs == 'PDF') 
            //ssc.setPageSize(lstAccountsInHierarchy.size()); // for PDF display all records
            System.debug('setPageSize');
        else
            ssc.setPageSize(recordsPerPage);
    }

    public PageReference checkIfUserHasAccessToService(){
        User u = [SELECT Id, ContactId From User WHERE Id =: UserInfo.getUserId()];
        if(u != null){
            List<Portal_Application_Right__c> par;
            if (isMSO)
                par = [SELECT Id, Terms_Acceptance__c FROM Portal_Application_Right__c WHERE Contact__c =: u.ContactId  AND Right__c = 'Access Granted' AND (Contact_User_Portal_Status__c = 'Approved User' OR Contact_User_Portal_Status__c = 'Approved Admin') AND Application_Start_URL__c = '/ISSP_AMS_MSO'];
            else 
                par = [SELECT Id, Terms_Acceptance__c FROM Portal_Application_Right__c WHERE Contact__c =: u.ContactId AND Right__c = 'Access Granted' AND (Contact_User_Portal_Status__c = 'Approved User' OR Contact_User_Portal_Status__c = 'Approved Admin') AND Application_Start_URL__c = '/ISSP_AMS_GSA'];

            if(par.size()==0) {
                // No access right => return to home page
                return new PageReference('/ISSP_Homepage');
            } else {
                // has access rights
                return null;
            }
        }

        // if this point is reached, an error occured => return to portal home page
        return new PageReference('/ISSP_Homepage');
    }


    public Boolean hasNext {
        get {
            //return ssc.getHasNext();
            if(pageNumberStatic == totalPages){
                return false;
            }else{
                return true;    
            }
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            //return ssc.getHasPrevious();
            if(pageNumberStatic == 1){
                return false;
            }else{
                return true;    
            }
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            if (strRenderAs != 'PDF'){
            	return ssc.getPageNumber();
            }else{
                return 1;
            }
        }
        set;
    }

    public Integer totalPages{
        get {
            integer total = 0;
            if (strRenderAs != 'PDF'){
                total = (ssc.getResultSize() / ssc.getPageSize());
	            if(math.mod(ssc.getResultSize(),ssc.getPageSize()) != 0){ 
	                total++ ;
	            }
	            system.debug('total Pages :' + ssc.getResultSize() + ssc.getPageSize() + (ssc.getResultSize() / ssc.getPageSize()));
            }
            return total;
        } 
        set;  
    }

    // returns the first page of records
    public void first() {
        pageNumberStatic = 1;
        ssc.first();
    }

    // returns the last page of records
    public void last() {
        pageNumberStatic = totalPages;
        ssc.last();
    }

    // returns the previous page of records
    public void previous() {
        //ssc.previous();
        pageNumberStatic --;
        ssc.setPageNumber(pageNumberStatic);
    }

    // returns the next page of records
    public void next() {
        //ssc.next();
        pageNumberStatic ++;
        ssc.setPageNumber(pageNumberStatic);
    }

    // the first characters in the CSV file, to ensure its correct display in Excel 
    public String getCSVHeader() {
        return EncodingUtil.convertFromHex('EFBBBF').toString();
    }

    public class AppointmentWrapper {
        public AMS_Inspection__c appointment {get; set;}
        public String territories {get; set;}
        public Date dAccreditation_date {get; set;}
        public Date dExpiry_Date {get; set;}

        public AppointmentWrapper(AMS_Inspection__c appointment, String territories, Date accDate, Date expDate) {
            this.appointment = appointment;
            this.territories = territories;
            this.dAccreditation_date = accDate;
            this.dExpiry_Date = expDate;

        }
     }
}
