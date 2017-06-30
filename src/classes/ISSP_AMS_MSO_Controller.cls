public without sharing class ISSP_AMS_MSO_Controller {
    public String searchText {get; set;}
    public Account currentAccount {get; set;}
    public String SortingDirection {get; set;}
    public String SortBy {get; set;}

    private list<AMS_Inspection__c> lstAccountsInHierarchy;
    private Id currentAccountId;
    private Id hqAccountId;
    public Boolean isMSO {
        get {
            String pageName = ApexPages.currentPage().getUrl().substringAfterLast('/').substringBefore('?');
            //String pdfParam = ApexPages.currentPage().getParameters().get('')
            return pageName == 'ISSP_AMS_MSO';
        } set;
    }

    public list<Account> OrderedFilteredHierarchy;
    public ApexPages.StandardSetController ssc {get;set;}
    public list<AMS_Inspection__c> lstDisplayAccounts {
        get {
            list<AMS_Inspection__c> tmpList = new list<AMS_Inspection__c>();
            for (AMS_Inspection__c a : (list<AMS_Inspection__c>)ssc.getRecords()) {
                tmpList.add(a);
            }

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

    
    public ISSP_AMS_MSO_Controller() {
        try {
            User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Contact currentUserContact = [SELECT Id, AccountId FROM Contact WHERE Id = :currentUser.ContactId];
            this.currentAccount = [SELECT Id, ParentId, RecordType.DeveloperName, Name FROM Account WHERE Id = :currentUserContact.AccountId];
            currentAccountId = currentAccount.Id;
            hqAccountId = currentAccount.RecordType.DeveloperName == 'IATA_Airline' ? currentAccountId : currentAccount.ParentId;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to determine current user account.'));
            return;
        }

        recordsPerPage = 25;
        SortBy = 'IATACode__c';
        SortingDirection = 'ASC';

        refreshMsoGsaList();
    }

    public void refreshMsoGsaList() {
        String strQuery = 'SELECT Id, Account__r.Name,Account__r.Location_Class__c, Account__r.IATACode__c, Account__r.Category__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingCountry ';
        strQuery += 'FROM AMS_Inspection__c WHERE Airline__c = :hqAccountId ';
        strQuery += 'AND Account__r.Location_Class__c = \'' + (isMSO ? 'M' : 'G') + '\'';

        //
        if (searchText != null && searchText != '') {
            strQuery += ' AND (';
            strQuery += 'Account__r.Name LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += 'OR Account__r.IATACode__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += 'OR Account__r.BillingCountry LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += ')';
        } 

        strQuery += ' ORDER BY Account__r.' + SortBy + ' ' + SortingDirection + ' NULLS LAST';

        system.debug('query: ' + strQuery);

        lstAccountsInHierarchy = Database.query(strQuery);

        ssc = new ApexPages.StandardSetController(lstAccountsInHierarchy);
        ssc.setPageSize(recordsPerPage);
    }

    public Boolean hasNext {
        get {
            return ssc.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return ssc.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return ssc.getPageNumber();
        }
        set;
    }

    public Integer totalPages{
        get {
            integer total = (ssc.getResultSize() / ssc.getPageSize());
            if(math.mod(ssc.getResultSize(),ssc.getPageSize()) != 0){ 
                total++ ;
            }
            system.debug('total Pages :' + ssc.getResultSize() + ssc.getPageSize() + (ssc.getResultSize() / ssc.getPageSize()));
            
            return total;
        } 
        set;  
    }

    // returns the first page of records
     public void first() {
         ssc.first();
     }

     // returns the last page of records
     public void last() {
         ssc.last();
     }

     // returns the previous page of records
     public void previous() {
         ssc.previous();
     }

     // returns the next page of records
     public void next() {
         ssc.next();
     }

}