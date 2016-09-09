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
    
    private void upsertDesign() {
        EBC_Template__c d;
        
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
        
        if (!String.isBlank(selectedTemplate)) { 
            EBC_Template__c t = [Select Id, RecordType.DeveloperName  From EBC_Template__c Where Id = :selectedTemplate];
            if (t.RecordType.DeveloperName != 'Global') {
                d = vfIECEBC_TemplateList.duplicate(selectedTemplate, campaign.Name, billingAccount.Id, false);
                
		        campaign.EBC_Design__c = d.Id;
                return ;
            }
            
            d.Parent_Template__c = selectedTemplate;
        }
        
        upsert d;
        
        campaign.EBC_Design__c = d.Id;
    }
    
    public PageReference upsertDesignAndExit() {
        upsertDesign();
            
        PageReference pr = this.con.save();
        
        if (!ApexPages.hasMessages()) {
            pr = Page.IECEBC_Dashboard;
            pr.setRedirect(true);
        }
        
        return pr;
    }
    public PageReference upsertDesignAndContinue() {
        upsertDesign();
        
        PageReference pr = this.con.save();
        
        if (!ApexPages.hasMessages()) {
            pr = Page.IECEBC_CampaignDesign;
            pr.getParameters().put('id', campaign.Id);
            pr.setRedirect(true);
        }
        
        return pr;
    }
}