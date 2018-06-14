public class vfIECEBC_CampaignTemplate extends vfIECEBC_Controller {
    public Id selectedTemplate {
        get {
            if (selectedTemplate == null && campaign.EBC_Design__c != null) {
                EBC_Template__c tpl = [Select Id, Parent_Template__c From EBC_Template__c Where Id = :campaign.EBC_Design__c];
                selectedTemplate = tpl.Parent_Template__c;
            }
            return selectedTemplate;
        }
        set;
    }
    
    public EBC_Campaign__c campaign { get; set; } 
    public ApexPages.StandardController con { public get; private set; }
    
    public vfIECEBC_CampaignTemplate(ApexPages.StandardController stdController) {
        this.con = stdController;
        
        this.campaign = (EBC_Campaign__c)stdController.getRecord();
    }
    
    public class MissingTemplate_Exception extends Exception{}
    
    private void upsertDesign() {
        EBC_Template__c d;
        if (String.isBlank(selectedTemplate)) {
            throw new MissingTemplate_Exception('Missing template');
        }
        
        if (campaign.EBC_Design__c == null) {
            d = new EBC_Template__c();
            d.Name = campaign.Name;
            d.Billing_Account__c = billingAccount.Id;
            d.Audience__c = campaign.Audience__c;
            d.Is_Reusable__c = false;
        } else {
            d = new EBC_Template__c();
            d.Id = campaign.EBC_Design__c;
        }
        
        EBC_Template__c t = [Select Id, RecordType.DeveloperName  From EBC_Template__c Where Id = :selectedTemplate];
        if (t.RecordType.DeveloperName != 'Global') {
            d = vfIECEBC_TemplateList.duplicate(selectedTemplate, campaign.Name, billingAccount.Id, false);
            
            campaign.EBC_Design__c = d.Id;
            return ;
        }
        
        d.Parent_Template__c = selectedTemplate;
        
        upsert d;
        
        campaign.EBC_Design__c = d.Id;
    }
    
    public String getAudience() {
        return campaign.Audience__c != 'Custom' ? campaign.Audience__c : 'Agency';
    }
    
    public EBC_Template__c customHtmlTemplate {
        get {
            
            if(customHtmlTemplate == null) {
                customHtmlTemplate = [
                    SELECT
                        Id,
                        Name 
                    FROM EBC_Template__c
                    WHERE
                        Recordtype.DeveloperName = 'Global' AND 
                        Audience__c = :getAudience() AND
                        External_Id__c LIKE 'customhtml-%'
                    LIMIT 1
                ];
            }
            
            return customHtmlTemplate;
        }
        set;
    }
    
    public PageReference upsertDesignAndExit() {
        try {
            upsertDesign();
            
            PageReference pr = this.con.save();
            
            if (!ApexPages.hasMessages()) {
                pr = Page.IECEBC_Dashboard;
                pr.setRedirect(true);
            }
            
            return pr;
        } catch(MissingTemplate_Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Template before proceeding.'));
        }
        
        return null;
    }
    public PageReference upsertDesignAndContinue() {
        try {
            upsertDesign();
            
            PageReference pr = this.con.save();
            
            if (!ApexPages.hasMessages()) {
                pr = Page.IECEBC_CampaignDesign;
                pr.getParameters().put('id', campaign.Id);
                pr.setRedirect(true);
            }
            
            return pr;
        } catch(MissingTemplate_Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Template before proceeding.'));
        }
        
        return null;
    }
}