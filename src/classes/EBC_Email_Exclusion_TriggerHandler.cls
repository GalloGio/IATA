public class EBC_Email_Exclusion_TriggerHandler {
    // http://help.marketingcloud.com/en/documentation/exacttarget/interactions/email_messages/email_send_error_codes/
    public static Boolean isEmailExclusionGenerateCredit(EBC_Email_Exclusion__c ee) {
        if (ee.Type__c == 'HARDBOUNCE') return true;
        if (ee.Type__c == 'LISTDETECTIVE') return true;

        return false;
    }
    public static void creditHardBounce(List<EBC_Email_Exclusion__c> ees) {
        
        List<Id> campaignsId = new List<Id>();
        
        for(EBC_Email_Exclusion__c ee : ees) {
            if (!isEmailExclusionGenerateCredit(ee)) continue;
            campaignsId.add(ee.Source_Campaign__c);
        }
        
        if (campaignsId.size() == 0) return ;
        
        Map<Id, EBC_Campaign__c> campaigns = new Map<Id, EBC_Campaign__c>([Select Id, Billing_Account__c From EBC_Campaign__c Where Id in :campaignsId]);
        
        Map<Id, EBC_Activity__c> campaignActivity = new Map<Id, EBC_Activity__c>();
        
        for(EBC_Email_Exclusion__c ee : ees) {
            if (!isEmailExclusionGenerateCredit(ee)) continue;
            
            EBC_Activity__c a;
            if (campaignActivity.containsKey(ee.Source_Campaign__c)) {
                a = campaignActivity.get(ee.Source_Campaign__c);
            } else {
                a = new EBC_Activity__c(
                    name = ee.Type__c,
                    Activity_Date_Time__c = ee.Event_Date__c,
                    Activity_Type__c = 'Adjustment',
                    EBC_Campaign__c = ee.Source_Campaign__c,
                    Total_Count__c = 0,
                    Related_Billing_Account__c = campaigns.get(ee.Source_Campaign__c).Billing_Account__c,
	                Reason__c = ee.Type__c
                );
            }
            
            a.Total_Count__c++;
            
            campaignActivity.put(ee.Source_Campaign__c, a);
        }
        
        if (campaignActivity.size() == 0) return ;
        insert campaignActivity.values();
    }
}