public class vfIECEBC_CampaignList extends vfIECEBC_Controller {
    public Boolean isLimitedComponent {
        get {
            if (isLimitedComponent == null) isLimitedComponent = false;
            return isLimitedComponent;
        }
        set {
            isLimitedComponent = value;
            if (value == true) CAMPAIGNS_PER_PAGE = 2;
        }
    }
    public static Integer CAMPAIGNS_PER_PAGE = 10;
    
    public Id selectedCampaignId { get; set; }
    public EBC_Campaign__c selectedCampaign {
        get {
            if (selectedCampaign == null || selectedCampaign.Id != selectedCampaignId) {
                Map<Id, EBC_Campaign__c> campaignsMapping = new Map<Id, EBC_Campaign__c>(campaigns);
                selectedCampaign = campaignsMapping.get(selectedCampaignId);
            }
            
            return selectedCampaign;
        }
        set;
    }
    public PageReference deleteCampaign() {
        delete selectedCampaign;
        
        clear();
        
        return null;
    }
    public PageReference save() {
        update selectedCampaign;
        
        clear();
        
        return null;
    }
    public PageReference cancel() {
        
        IECEBC_Utility.creditCampaign(selectedCampaign.Id);
        
        if (selectedCampaign.Status__c == 'PENDING_APPROVAL') {
            // RECALL
            List<ProcessInstanceWorkitem> piwis = [SELECT Id,Actor.Name,ElapsedTimeInHours,OriginalActor.Name,ProcessInstanceId FROM ProcessInstanceWorkitem Where ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObjectId = :selectedCampaign.Id LIMIT 1];
            ProcessInstanceWorkitem piwi = piwis[0];
            System.debug(piwi);
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Removed');
            req.setWorkitemId(piwi.Id); 
            System.debug(req);
            Approval.ProcessResult result =  Approval.process(req);
        } else {
            selectedCampaign.Status__c = 'DRAFT';
            update selectedCampaign;
        }
        
        clear();
        
        return null;
    }
    
    public PageReference duplicate() {
        EBC_Campaign__c oCampaign = [
            Select
                Id,
                Billing_Account__c,
                EBC_Master_Filter__c,
                //          EBC_Master_Filter__c,
                // Exact_Target_Campaign_Id__c  wtf is that?
                From_Name__c,
                Google_Analytics_Tracking_Code__c,
                Is_Google_Analytics_Tracker_Active__c,
                Subject__c,
                
                EBC_Design__c
            From EBC_Campaign__c
            Where Id = :selectedCampaign.Id
        ];
        
        //EBC_Master_Filter__c nFilter = vfIECEBC_RecipientList.duplicate(oCampaign.EBC_Master_Filter__c, 'new name');
        
        EBC_Campaign__c nCampaign = oCampaign.clone(false, true, false, false);
        nCampaign.Name = selectedCampaign.Name;
        //nCampaign.EBC_Master_Filter__c = nFilter.Id;
        nCampaign.Status__c = 'DRAFT';
        
        
        if (oCampaign.EBC_Design__c != null) {
	        EBC_Template__c nDesign = vfIECEBC_TemplateList.duplicate(oCampaign.EBC_Design__c, selectedCampaign.Name, billingAccount.Id, false);
	        nCampaign.EBC_Design__c = nDesign.Id;
        }
        
        insert nCampaign;
        
        PageReference pr = new PageReference('/apex/IECEBC_Campaign?id=' + nCampaign.Id);
        pr.setRedirect(true);
        return pr;
    }
     
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
            if (sortBy == null) {
                if (isLimitedComponent) {
                    sortBy = 'LastModifiedDate DESC';
                } else {
                    sortBy = 'CreatedDate Desc';
                }
            }
            
            return sortBy;
        }
        set {
            sortBy = value;
            
            campaigns = null;
        } 
    } 
    
    private boolean firsttimepageload=true;
    private Boolean getIsFirstTimeLoadPage() { 
        if (firsttimepageload) {firsttimepageload=false; return true;}
        return false;} 
    
    public List<SelectOption> getSortByOptions() {
        List<SelectOption> options = new List<SelectOption>();
        if (getIsFirstTimeLoadPage()) options.add(new SelectOption(sortBy,'Sort by'));
        options.add(new SelectOption('Name','Campaign Name'));
        options.add(new SelectOption('Status__c','Campaign  Status'));
        options.add(new SelectOption('CreatedDate DESC','Created Date - Descending'));
        options.add(new SelectOption('CreatedDate ASC','Created Date - Ascending'));
        options.add(new SelectOption('LastModifiedDate ASC','Last Edited - Ascending'));
        options.add(new SelectOption('LastModifiedDate DESC','Last Edited - Descending'));
      
        
        return options;
    }
    
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
            fields.add('Number_of_Recipients__c');
            fields.add('Number_of_Unique_Opens__c');
            fields.add('NumberSent__c');
            fields.add('Delivered7Days__c');
            fields.add('Number_of_Unique_Clicks__c');
            fields.add('EBC_Design__c');
            fields.add('Is_Step5_Writable__c');
            fields.add('Is_Step4_Valid__c');  
            fields.add('Owner.Name'); 
            fields.add('EBC_Master_Filter__r.Name');
            fields.add('LastModifiedDate');
            fields.add('Send_Datetime__c');
            fields.add('OpenRate7Days__c');
            fields.add('ClickRate7Days__c');
             
        }
        
        return 'Select ' + String.join(fields, ',') + ' FROM EBC_Campaign__c WHERE Billing_Account__c = \'' + vfIECEBC.billingAccount.Id + '\'';
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
                if (offset < 0) offset = 0;
                String query = getQuery(false) + ' ORDER BY ' + sortBy + ' LIMIT ' + CAMPAIGNS_PER_PAGE + ' OFFSET ' + offset;
                campaigns = Database.query(query);
            }
            return campaigns;
        }
        private set;
    }
    
    private void clear() {
        campaignsCount = null;
        campaigns = null;
        maxPage = null;
        if (page > maxPage) {
            page = maxPage;
        }
    }
    
    public vfIECEBC_CampaignList() {
    }
}