public with sharing class ISSP_AMS_MSO_Controller {
    public String searchText {get; set;}
    public Account currentAccount {get; set;}
    public Boolean isExcludeTerminated {get; set;}

    private list<Account> lstAccountsInHierarchy;
    private Id currentAccountId;

    public list<Account> OrderedFilteredHierarchy;
    public ApexPages.StandardSetController ssc {get;set;}
    public list<Account> lstDisplayAccounts {
        get {
            list<Account> tmpList = new list<Account>();
            for (Account a : (list<Account>)ssc.getRecords()) {
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
            this.currentAccount = [SELECT Id, Name FROM Account WHERE Id = :currentUserContact.AccountId];
            currentAccountId = currentAccount.Id;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to determine current user account.'));
            return;
        }

        isExcludeTerminated = false;
        recordsPerPage = 25;

        refreshMsoGsaList();
    }

    public void refreshMsoGsaList() {
        String strQuery = 'SELECT Id, Name, IATACode__c, Category__c, BillingStreet, BillingCity, BillingCountry FROM Account WHERE (ParentId = :currentAccountId OR Id = :currentAccountId) ';

        if (isExcludeTerminated) {
            strQuery += ' AND Status__c <> \'Terminated\'';
        }

        if (searchText != null && searchText != '') {
            strQuery += ' AND (';
            strQuery += 'Name LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += 'OR IATACode__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += 'OR BillingCountry LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += ')';
        }

        strQuery += 'ORDER BY IATACode__c NULLS LAST';

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