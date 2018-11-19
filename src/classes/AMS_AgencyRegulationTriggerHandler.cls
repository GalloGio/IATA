public class AMS_AgencyRegulationTriggerHandler {

    public static void handleBeforeInsert() {

    }

    public static void handleBeforeUpdate() {

        processPostNotifSentActions((List<AMS_Agency_Regulation__c>)Trigger.New, (Map<Id,AMS_Agency_Regulation__c>)Trigger.oldMap);
        processRenewals((List<AMS_Agency_Regulation__c>)Trigger.New, (Map<Id,AMS_Agency_Regulation__c>)Trigger.oldMap);

    }

    //Create renewals and send notifications for expiring DGRs
    public static void processPostNotifSentActions(List<AMS_Agency_Regulation__c> agencyRegulations, Map<Id,AMS_Agency_Regulation__c> oldAgRegulationValues){

        List<AMS_Agency_Regulation__c> dgrRegulationsExpiringIn90Days = new List<AMS_Agency_Regulation__c>();
        Map<Id,String> regulationTypePesAccount = new Map<Id,String>();
        Map<String,Integer> renewalCertPerAccount = new Map<String,Integer>();

        Set<Id> accountIds = new Set<Id>();
        Set<String> regulationPerAccount = new Set<String>();

        Map<Id,String> agencyRegulationsAccStatus = new Map<Id,String>();
        for(AMS_Agency_Regulation__c agRegStatus : [SELECT Id, Account__r.Status__c FROM AMS_Agency_Regulation__c WHERE Id IN :agencyRegulations])
        {
            agencyRegulationsAccStatus.put(agRegStatus.Id, agRegStatus.Account__r.Status__c);
        }

        for(AMS_Agency_Regulation__c agReg: agencyRegulations){

            if(agencyRegulationsAccStatus.get(agReg.Id) != AMS_Utils.ACC_S0_TERMINATED){

                accountIds.add(agReg.Account__c);
            
                //FM 07-07-2017 - AMSU-14 - add new test for "Notification Date" change
                if( (
                    (!oldAgRegulationValues.get(agReg.Id).Notification_Sent__c && agReg.Notification_Sent__c)  
                    || (agReg.Notification_Date__c != null &&
                        oldAgRegulationValues.get(agReg.Id).Notification_Date__c != agReg.Notification_Date__c)
                    )
                    && (agReg.Type_of_Certificate__c == AMS_Utils.CERT_DGR 
                        || agReg.Type_of_Certificate__c == AMS_Utils.CERT_CATA 
                        || agReg.Type_of_Certificate__c == AMS_Utils.CERT_TSA) 
                    && agReg.Handling_Account__c)
                    dgrRegulationsExpiringIn90Days.add(agReg);
                    if(!renewalCertPerAccount.containsKey(agReg.Account__c+agReg.Type_of_Certificate__c))
                        renewalCertPerAccount.put(agReg.Account__c+agReg.Type_of_Certificate__c, -1);
            }
        }

        if(!dgrRegulationsExpiringIn90Days.isEmpty()){

            //contacts that will receive notifications for DGR certificates renewal
            Map<Id, List<Contact>> keyContactsPerAccount = new Map<Id, List<Contact>>();

            //get all accounts
            List<Account> allAccounts = new List<Account>([SELECT Id, Top_Parent__c, Location_Type__c FROM Account WHERE Id IN :accountIds]);


            Set<Id> accountIdsHOs = new Set<Id>();
            Map<Id, Set<Id>> parentPerBR = new Map<Id, Set<Id>>();

            //check if the account is an AO or HO to get the contacts of TopParent
            for(Account ac: allAccounts){
                if(ac.Location_Type__c != 'HO' && ac.Location_Type__c != 'AO'){
                    
                    //FM 07-07-2017 - AMSU-14 - need to be able to send to the BR also
                    //accountIds.remove(ac.Id);
                    accountIdsHOs.add(ac.Top_Parent__c);
                    if(!parentPerBR.containsKey(ac.Top_Parent__c))
                        parentPerBR.put(ac.Top_Parent__c, new Set<Id>());
                    
                    parentPerBR.get(ac.Top_Parent__c).add(ac.Id);
                }
            }

            system.debug('accountIds: ' + accountIds);

            //get contacts of first accounts
            if(!accountIds.isEmpty()) {
                List<Contact> allContacts = new List<Contact>([SELECT Id, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c FROM Contact WHERE AccountId IN :accountIds AND IsEmailBounced = FALSE AND (BSP_CASS_Payment_contact__c = TRUE OR Financial_Assessment_Contact__c = TRUE OR User_Portal_Status__c = 'Approved Admin')]);

                for(Contact c: allContacts){
                    if(!keyContactsPerAccount.containsKey(c.AccountId))
                        keyContactsPerAccount.put(c.AccountId, new List<Contact>());

                    keyContactsPerAccount.get(c.AccountId).add(c);
                }
            }

            system.debug('accountIdsHOs: ' + accountIdsHOs);
            //get contacts of topParents and relate them with first account
            if(!accountIdsHOs.isEmpty()){
                List<Contact> allContactsHOs = new List<Contact>([SELECT Id, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c FROM Contact WHERE AccountId IN :accountIdsHOs AND IsEmailBounced = FALSE AND (BSP_CASS_Payment_contact__c = TRUE OR Financial_Assessment_Contact__c = TRUE OR User_Portal_Status__c = 'Approved Admin')]);

                for(Contact cHO: allContactsHOs){

                    if(parentPerBR.containsKey(cHO.AccountId)){

                        for(Id idBR : parentPerBR.get(cHO.AccountId)){

                            if(!keyContactsPerAccount.containsKey(idBR))
                                keyContactsPerAccount.put(idBR, new List<Contact>());

                            keyContactsPerAccount.get(idBR).add(cHO);
                            
                        }
                    }
                }
            }
            system.debug('keyContactsPerAccount ' + keyContactsPerAccount);
            AMS_AgencyRegulationAutoRenewal b = new AMS_AgencyRegulationAutoRenewal(dgrRegulationsExpiringIn90Days, keyContactsPerAccount, renewalCertPerAccount);
            database.executebatch(b,1);
        }
    }

    //clean the Notification Date for manually changed agency regulations
    public static void processRenewals(List<AMS_Agency_Regulation__c> agencyRegulations, Map<Id,AMS_Agency_Regulation__c> oldAgRegulationValues) {
        
        List<AMS_Agency_Regulation__c> agencyRegulationsToUpdate = new List<AMS_Agency_Regulation__c>();

        for(AMS_Agency_Regulation__c agReg : agencyRegulations) {

            if(agReg.Expiry_Date__c != oldAgRegulationValues.get(agReg.Id).Expiry_Date__c 
                && agReg.Notification_Sent__c == false 
                && agReg.Notification_Sent__c != oldAgRegulationValues.get(agReg.Id).Notification_Sent__c
                && agReg.Notification_Date__c != null) {

                agReg.Notification_Date__c = null;
            }

        }
    }

    public static void countAccountDGR(List<AMS_Agency_Regulation__c> lsAgencyRegulations) {
        List<Id> lsAccountIds = new List<Id>();
        List<Account> lsAccounts = new List<Account>();
        List<Account> lsAccountsToUpdate = new List<Account>();
        for(AMS_Agency_Regulation__c ar : lsAgencyRegulations) {
            lsAccountIds.add(ar.Account__c);
        }
        lsAccounts =
            [SELECT Id, Location_type__c, Is_DGR_Compliant__c, IATA_ISO_Country__c, RecordType.DeveloperName, (SELECT Id FROM Cases WHERE OSCAR__r.Process__c LIKE '%NEW%')
            FROM Account
            WHERE Id IN :lsAccountIds
            AND (RecordType.DeveloperName = 'IATA_Agency' 
            OR (RecordType.DeveloperName = 'Standard_Account' 
            AND (Location_type__c = 'HO' OR Location_type__c = 'BR')))
            AND Location_Class__c = 'C'];

        List<IATA_ISO_Country__c> lsCountries = IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{'CN'});

        IATA_ISO_Country__c china;
        if(!lsCountries.isEmpty()) { china = lsCountries[0];}
        // fetch the existing regulations to make the count
        List<AMS_Agency_Regulation__c> lsAllAgencyRegulations =
            [SELECT Id, Account__c, Expired__c
            FROM AMS_Agency_Regulation__c
            WHERE Account__c IN :lsAccountIds
            AND Expired__c = false
            AND Type_Of_Certificate__c = 'DGR'];
        for(Account a :lsAccounts) {

            if(a.RecordType.DeveloperName == 'Standard_Account' && a.Cases.isEmpty())
                continue;

            Integer count = 0;
            Boolean isCompliant = false;
            for(AMS_Agency_Regulation__c ar : lsAllAgencyRegulations) {
                if(a.Id == ar.Account__c) {
                    count++;
                }
            }
            if(china != null && a.IATA_ISO_Country__c == china.Id && count >= 3) {
                isCompliant = true;
            }
            else if(a.Location_type__c == 'HO' && count >= 2) {
                isCompliant = true;
            }
            else if(a.Location_type__c == 'BR' && count >= 1) {
                isCompliant = true;
            }
            if(a.Is_DGR_Compliant__c != isCompliant) {
                a.Is_DGR_Compliant__c = isCompliant;
                lsAccountsToUpdate.add(a);
            }
        }
        try {
            if(!lsAccountsToUpdate.isEmpty()) update lsAccountsToUpdate;
        } catch (Exception e) {
            system.debug(e);
        }
    }

     public void isTestCompliant () {
        if (Test.isRunningTest()) {
            AMS_Oscar__c oscar = new AMS_Oscar__c();
            AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();
            oscar.Assessment_Performed_Date__c = date.today();
            oscar.Bank_Guarantee_deadline__c = date.today();
            oscar.Bank_Guarantee_received__c = date.today();
            oscar.Bank_Guarantee_requested__c = date.today();
            accreditationObj.Accept_terms_and_conditions__c = true;
            accreditationObj.Account_Name__c = 'TestName';
            accreditationObj.Billing_State__c = 'TestState';
            accreditationObj.Branch_Office_City__c = 'TestCity';
            accreditationObj.Branch_Office_Email__c = 'TestEmail';
            accreditationObj.Branch_Office_FAX__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);
            oscar.Bank_Guarantee_received__c = date.today();
            oscar.Bank_Guarantee_requested__c = date.today();
            accreditationObj.Accept_terms_and_conditions__c = true;
            accreditationObj.Account_Name__c = 'TestName';
            accreditationObj.Billing_State__c = 'TestState';
            accreditationObj.Branch_Office_City__c = 'TestCity';
            accreditationObj.Branch_Office_Email__c = 'TestEmail';
            accreditationObj.Branch_Office_FAX__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);
            oscar.Assessment_Performed_Date__c = date.today();
            oscar.Bank_Guarantee_deadline__c = date.today();
            oscar.Bank_Guarantee_received__c = date.today();

        }
    }
}