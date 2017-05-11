public with sharing class AccountHierarchyController {

	public Account currentAccount {get; set;}
    public Id topParentAccountId {get; set;}
    public Boolean isExcludeTerminated {get; set;}
    public String searchString {get; set;}
    public Boolean displayHeaderSidebar {get; set;}

    private list<Account> lstAccountsInHierarchy;
    private map<Id,Integer> mapHierarchyLevelPerAccountId;

    public list<Account> OrderedFilteredHierarchy;
    public ApexPages.StandardSetController ssc {get;set;}
    public list<AccountWrapper> lstDisplayAccounts {
        get {
            list<AccountWrapper> tmpList = new list<AccountWrapper>();
            for (Account a : (list<Account>)ssc.getRecords()) {
                tmpList.add(new AccountWrapper(a, mapHierarchyLevelPerAccountId.get(a.Id)));
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


    
    public AccountHierarchyController(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) stdController.addFields(new list<String>{'Name', 'Top_Parent__c'});

        this.currentAccount = (Account)stdController.getRecord();

        displayHeaderSidebar = ApexPages.currentPage().getParameters().get('console') == '1' ? false : true;

        topParentAccountId = currentAccount.Top_Parent__c == null ? currentAccount.Id : currentAccount.Top_Parent__c;

        isExcludeTerminated = false;
        recordsPerPage = 50;
        mapHierarchyLevelPerAccountId = new map<Id, Integer>();

        refreshHierarchy();
    }

    public void refreshHierarchy() {
        String strQuery = 'SELECT Id, ParentId, Name, Location_Type__c, IATACode__c, Category__c, Status__c, Reason__c, Expiry_Date__c, BillingCity, TC_Comments__c FROM Account WHERE (Top_Parent__c = :topParentAccountId OR Id = :topParentAccountId) ';

        if (isExcludeTerminated) {
            strQuery += ' AND Status__c <> \'Terminated\'';
        }

        if (searchString != null && searchString != '') {
            strQuery += ' AND (';
            strQuery += 'Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
            strQuery += 'OR Location_Type__c LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
            strQuery += 'OR IATACode__c LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
            strQuery += 'OR Category__c LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
            strQuery += 'OR Status__c LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
            strQuery += 'OR Reason__c LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
            strQuery += 'OR BillingCity LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
            strQuery += ')';
        }

        strQuery += 'ORDER BY IATACode__c NULLS LAST';

        system.debug('query: ' + strQuery);

        lstAccountsInHierarchy = Database.query(strQuery);

        ssc = new ApexPages.StandardSetController(getOrderedFilteredHierarchy());
        ssc.setPageSize(recordsPerPage);
    }


    public list<Account> getOrderedFilteredHierarchy() {
        if (searchString == null || searchString == '')  {
            Account topParent;

            // build a map of all the child accounts per parent - ONLY IF NOT SEARCH
            map<Id, list<Account>> mapChildAccountsPerParentId = new map<Id, list<Account>>();

            for (Account acc : lstAccountsInHierarchy) {
                list<Account> lstChildAccounts = new list<Account>();

                for (Account a : lstAccountsInHierarchy) {
                    if (a.ParentId == acc.Id) {
                        lstChildAccounts.add(a);
                    }
                }

                if (! lstChildAccounts.isEmpty()) {
                    mapChildAccountsPerParentId.put(acc.Id, lstChildAccounts);
                }

                if (acc.Id == topParentAccountId) topParent = acc;
            }

            // get the html code for the hierarchy representation; start with the top parent
            return orderedRows(topParent, mapChildAccountsPerParentId, 0);

        } else {
            // if a search string is present, we  might no longer be able to display the selected accounts in a hierarchy, so just display a list
            list<Account> tmpList = new list<Account>();

            for (Account acc : lstAccountsInHierarchy) {
                tmpList.addAll(orderedRows(acc, new map<Id, list<Account>>(), 0));
            }

            return tmpList;
        }
    }

    private list<Account> orderedRows(Account acc, map<Id, list<Account>> mapAccountChildrenMap, Integer level) {
        list<Account> tmpList = new list<Account>();

        mapHierarchyLevelPerAccountId.put(acc.Id, level);

        tmpList.add(acc);

        if (mapAccountChildrenMap.get(acc.Id) != null) {
            for (Account a : mapAccountChildrenMap.get(acc.Id)) {
                tmpList.addAll(orderedRows(a, mapAccountChildrenMap, level + 1));
            }
        }
        
        return tmpList;
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

     public class AccountWrapper {
        public Account acc {get; set;}
        public String indentation {get; set;}

        public AccountWrapper (Account a, Integer level) {
            this.acc = a;
            this.indentation = level != null ? '&nbsp;'.repeat(level*6) : '';
        }
     }
}