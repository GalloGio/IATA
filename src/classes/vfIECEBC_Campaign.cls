public class vfIECEBC_Campaign extends vfIECEBC_Controller {
    
    public ApexPages.StandardController con {
        public get;
        private set;
    }
    
	public Integer numberOfRecipients {
		get{
			if (numberOfRecipients == null) {
                HttpRequest req = new HttpRequest();
                //req.setEndpoint(IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/services/apexrest/RecipientsCount/' + campaign.EBC_Master_Filter__c);
                req.setEndpoint(IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/IECEBC_RecipientCount?id=' + campaign.EBC_Master_Filter__c);
                req.setMethod('GET');
                //req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                
                Integer cnt = Integer.valueOf(res.getBody().trim());
                
                EBC_Campaign__c tmpCamp = new EBC_Campaign__c();
                tmpCamp.Id = campaign.Id;
                campaign.Number_of_Recipients__c = tmpCamp.Number_of_Recipients__c = cnt;
                update tmpCamp;
                
                numberOfRecipients = Integer.valueOf(campaign.Number_of_Recipients__c);
			}
			return numberOfRecipients;
		}
		set;
	}
    
    private Map<Integer, PageReference> stepToPageReference = new Map<Integer, PageReference>{
        1 => Page.IECEBC_Campaign,
        2 => Page.IECEBC_CampaignRecipients,
        3 => Page.IECEBC_CampaignTemplate,
        4 => Page.IECEBC_CampaignDesign,
        5 => Page.IECEBC_CampaignSchedule,
        6 => Page.IECEBC_CampaignConfirm,
        7 => Page.IECEBC_CampaignPayment
    };
    
    public Integer currentStepNumber {
        get {
            if (currentStepNumber == null) {
                PageReference currentPage = ApexPages.currentPage();
                currentPage.getParameters().clear();
                
                for(Integer i = 1; i <= 7; i++) {
                    if (currentPage.getUrl().toLowerCase() == getPRByStepNumber(i, false).getUrl().toLowerCase()) currentStepNumber = i;
                }
            }
            
            return currentStepNumber;
        }
        private set;
    }
    public PageReference getPRByStepNumber(Integer stepNumber, Boolean withParams) {
        PageReference pr = stepToPageReference.get(stepNumber);
        
        if (withParams) {
        	if (!String.isBlank(this.con.getId())) pr.getParameters().put('id', this.con.getId());
        }
        
        pr.setRedirect(true);
        
        return pr;
    }
    
    public EBC_Campaign__c campaign { get; set; }
    
    public vfIECEBC_Campaign(ApexPages.StandardController stdController) {        
        this.con = stdController;
        
        if (!Test.isRunningTest()) {
            List<String> fields = new List<String>();
            fields.addAll(Schema.sObjectType.EBC_Campaign__c.fields.getMap().keySet());
            fields.addAll(new List<String>{
                'EBC_Design__r.Is_Tested__c',
                'EBC_Master_Filter__r.Audience__c',
                'EBC_Master_Filter__r.Name',
                'EBC_Master_Filter__r.Number_of_Recipients__c'
            });
        	stdController.addFields(fields);
        }
        
        this.campaign = (EBC_Campaign__c)stdController.getRecord();
        
        if (!String.isBlank(this.campaign.Id) && this.campaign.Billing_Account__c != billingAccount.Id) {
            throw new Controller_Exception('You don\'t have access to this record (' + this.campaign.Billing_Account__c + ':' + billingAccount.Id + ').');
        }
        this.campaign.Billing_Account__c = vfIECEBC.billingAccount.Id;
        
        if (this.campaign.Id == null) {
            this.campaign.From_Name__c = vfIECEBC.pref.Default_From_Name__c;
            this.campaign.Google_Analytics_Tracking_Code__c = vfIECEBC.pref.Default_Google_Analytics_Tracker__c;
            if (!String.isBlank(this.campaign.Google_Analytics_Tracking_Code__c)) {
                this.campaign.Is_Google_Analytics_Tracker_Active__c = true;
            }
        }
    }
    
    public PageReference saveAndExit() {
        PageReference pr = this.con.save();
        
        if (!ApexPages.hasMessages()) {
            pr = Page.IECEBC_Dashboard;
        }
        
        return pr;
    }
    
    public PageReference previous() {
        currentStepNumber--;
        
        return getPRByStepNumber(currentStepNumber, true);
    }
    public PageReference next() {
        currentStepNumber++;
        
        return getPRByStepNumber(currentStepNumber, true);
    }
    
    public PageReference saveAsTemplate() {
        vfIECEBC_TemplateList.duplicate(campaign.EBC_Design__c, 'Template based on ' + campaign.Name, billingAccount.Id, true);
        
        return null;
    }
    
    public PageReference saveAndContinue() {
        PageReference pr = this.con.save();
        
        if (!ApexPages.hasMessages()) {
            currentStepNumber++;
            
            pr = getPRByStepNumber(currentStepNumber, true);
        }
        
        return pr;
    }
    
    public PageReference pageLoad() {
        
        PageReference pr = null;
        
        // Check if the current step is allowed and if not, redirect to the last allowed step
        if (campaign.Maximum_Allowed_Step__c == 4 && currentStepNumber == 5 && !campaign.EBC_Design__r.Is_Tested__c ) {
            pr = getPRByStepNumber(Integer.valueOf(campaign.Maximum_Allowed_Step__c), true);
            String url = pr.getUrl() + (pr.getUrl().indexOf('?') == -1 ? '?' : '&') + 'notice=sendtest_needed';
            System.debug(url);
            
            pr = new PageReference(url);
            pr.setRedirect(true);
        } else if (campaign.Maximum_Allowed_Step__c < currentStepNumber) pr = getPRByStepNumber(Integer.valueOf(campaign.Maximum_Allowed_Step__c), true);
        else if (campaign.Maximum_Allowed_Step__c == 6) {
            Integer previousCount = Integer.valueOf(campaign.Number_of_Recipients__c);
            Integer newCount = numberOfRecipients;
            if (previousCount != newCount) { // If the count changed, refresh the page
                pr = ApexPages.currentPage();
                pr.getParameters().put('id', campaign.Id);
                pr.setRedirect(true);
            }
        }
        
        return pr;
    }

    
}