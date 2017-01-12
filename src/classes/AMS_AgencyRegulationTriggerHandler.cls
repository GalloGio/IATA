public class AMS_AgencyRegulationTriggerHandler {

    public static void handleBeforeInsert() {
        
    }

    public static void handleBeforeUpdate() {

        processPostNotifSentActions((List<AMS_Agency_Regulation__c>)Trigger.New, (Map<Id,AMS_Agency_Regulation__c>)Trigger.oldMap);
        
    }

    //Create renewals and send notifications for expiring DGRs
    public static void processPostNotifSentActions(List<AMS_Agency_Regulation__c> agencyRegulations, Map<Id,AMS_Agency_Regulation__c> oldAgRegulationValues){

        List<AMS_Agency_Regulation__c> dgrRegulationsExpiringIn90Days = new List<AMS_Agency_Regulation__c>();

        Set<Id> accountIds = new Set<Id>();

        for(AMS_Agency_Regulation__c agReg: agencyRegulations){
            accountIds.add(agReg.Account__c);

            if(!oldAgRegulationValues.get(agReg.Id).Notification_Sent__c && agReg.Notification_Sent__c && (agReg.Type_of_Certificate__c == AMS_Utils.CERT_DGR || agReg.Type_of_Certificate__c == AMS_Utils.CERT_CATA || agReg.Type_of_Certificate__c == AMS_Utils.CERT_TSA) && agReg.Handling_Account__c)
                dgrRegulationsExpiringIn90Days.add(agReg);
        }

        if(!dgrRegulationsExpiringIn90Days.isEmpty()){

            //contacts that will receive notifications for DGR certificates renewal
            Map<Id, List<Contact>> keyContactsPerAccount = new Map<Id, List<Contact>>();

            List<Contact> allContacts = new List<Contact>([SELECT Id, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c FROM Contact WHERE AccountId IN :accountIds AND (BSP_CASS_Payment_contact__c = TRUE OR Financial_Assessment_Contact__c = TRUE OR User_Portal_Status__c = 'Approved Admin')]);

            for(Contact c: allContacts){
                if(!keyContactsPerAccount.containsKey(c.AccountId))
                    keyContactsPerAccount.put(c.AccountId, new List<Contact>());

                keyContactsPerAccount.get(c.AccountId).add(c);
            }

            AMS_AgencyRegulationAutoRenewal b = new AMS_AgencyRegulationAutoRenewal(dgrRegulationsExpiringIn90Days, keyContactsPerAccount); 
            database.executebatch(b,1);
        }
    }
}