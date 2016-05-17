public class vfIECEBC_CampaignList {
    public static Integer CAMPAIGNS_PER_PAGE = 25;
    
    public Integer page {
        get {
            if (page == null) page = 1;
            
            return page;
        }
        set {
            page = value;
            
            offset = (page * CAMPAIGNS_PER_PAGE) - CAMPAIGNS_PER_PAGE;
            
            campaigns = null;
        }
    }
    
    public Integer maxPage {
        get {
            if (maxPage == null) maxPage = Integer.valueOf(Math.ceil(Double.valueOf(campaignsCount) / Double.valueOf(CAMPAIGNS_PER_PAGE)));
            return maxPage;
        }
        private set;
    }
    
    public List<SelectOption> getPageOptions() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(Integer i = 1; i<=maxPage; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        
        return options;
    }
    
    class Controller_Exception extends Exception{}
    
    public String sortBy {
        get {
            if (sortBy == null) sortBy = 'CreatedDate ASC';
            
            return sortBy;
        }
        set {
            sortBy = value;
            
            campaigns = null;
        }
    }
    
    public List<SelectOption> getSortByOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('CreatedDate ASC','First Created'));
        options.add(new SelectOption('CreatedDate DESC','Last Created'));
        return options;
    }

    public PageReference doNothing() { return null; }
    
    public Integer offset {
        get {
            if (offset == null) offset = 0;
            return offset;
        }
        set;
    }
    
    private String getQuery(Boolean isCountOnly) {
        User u = [Select ContactId, AccountId from User where id =: Userinfo.getUserid()];
        
        List<String> fields = new List<String>();
        if (isCountOnly) {
            fields.add('count()');
        } else {
            fields.add('Id');
            fields.add('Name');
            fields.add('Status__c');
            fields.add('Scheduled_Date__c');
            fields.add('Is_Step5_Writable__c');
            fields.add('Is_Step4_Valid__c'); 
            fields.add('Owner.Name');
        }
        
        return 'Select ' + String.join(fields, ',') + ' FROM EBC_Campaign__c WHERE Account__c = \'' + u.AccountId + '\' AND Status__c != \'DELETED\'';
    }
    
    public Integer campaignsCount {
        get {
            if (campaignsCount == null) campaignsCount = Database.countQuery(getQuery(true));
            
            return campaignsCount;
        }
        set;
    }
    
    public List<EBC_Campaign__c> campaigns {
        get {
            if (campaigns == null) {
                String query = getQuery(false) + ' ORDER BY ' + sortBy + ' LIMIT ' + CAMPAIGNS_PER_PAGE + ' OFFSET ' + offset;
                campaigns = Database.query(query);
            }
            return campaigns;
        }
        private set;
    }
    
    public vfIECEBC_CampaignList() {
    }
}