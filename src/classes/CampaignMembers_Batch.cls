global class CampaignMembers_Batch implements Database.Batchable<sObject> {
    
    //List<CampaignMember> campaignMembers;
    String action;
    String campaigId;
    String campaignNumber;
    
    //get Campaign members to create Order and items for.
    global CampaignMembers_Batch(String action,String campaignId, String cNumber) {/*, List<CampaignMember> campaignMembers*/
        //this.campaignMembers = campaignMembers;
        this.action = action;
        campaigId = campaignId;
        campaignNumber = cNumber;
    }
    
    //Campaign members to generate renewal
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Status, Contact.FirstName, Contact.LastName, Contact.Account.Name, Contact.Title, Campaign.Campaign_AutoNumber__c, CampaignId FROM CampaignMember where CampaignId = \'' + campaigId + '\' ';
        System.debug('query::'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        //Generate Renewal notice
        if(action == 'renewalNotice'){
            CampaignMember_Svc.generateRenewalOrder(scope[0].CampaignId,scope);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        try{
            //Update the Campaign Renewal notice generated field
            Campaign campaign = Campaign_Sel.getCampaignById(campaigId);
            campaign.Renewal_notice_generated__c = Datetime.now();
            update campaign;

            //Send notification to the loggin user
            String templateId = Utility.getTextSetting('loginUser campaign notice notification');
            
            list<EmailTemplate> templates = Utility.getEmailTemplatebyTemplateId((Id) templateId);
            if(templates != null && templates.size() > 0){
                //Send notification to login user
                CampaignMember_Svc.sendBatchFinishNotification(new List<String> {UserInfo.getUserEmail()}, campaignNumber, UserInfo.getName(), templates[0]);
            }

        }catch(Exception ex){
            System.debug('Batch error ' + ex.getMessage());
        }
        
    }
    
}