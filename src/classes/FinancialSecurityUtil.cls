/*
 * This class contains helper methods for the trigger FinancialSecurityHandler. 
 * These methods handle the creation of the renewal cases for Financial Security records 
 * that are close to expiry.
 * Also Send Email Notifications for FS created with: 
 * • Status = Not yet active, Active, Close to expiry 
 *    AND
 * • Unlimited Validity = True OR Validity start date not empty
 */
public with sharing class FinancialSecurityUtil {
	
    //AMSU-190
    public static List<Financial_Security__c> triggerNew;
    public static List<Financial_Security__c> triggerOld;
    public static Map<String, EmailTemplate> countryTemplates {get;set;}
    public static Map<Id, EmailTemplate> templateIdVsTemplates {get;set;}
    public static Map<Id, List<Attachment>> templateIdVsAttachemnt {get;set;}

    //AMSU-190
    public void onAfterInsert(Map<Id, Financial_Security__c> mapTriggerNew, Map<Id, Financial_Security__c> mapTriggerOld){
        triggerNew = new List<Financial_Security__c>();
        triggerOld = new List<Financial_Security__c>();

        for (Financial_Security__c fs : mapTriggerNew.values()) {
            triggerNew.add(fs);
        }

        for (Financial_Security__c fs : mapTriggerNew.values()) {
            triggerOld.add(fs);
        }

        validateFSforNotification(); 
    }
	
	/*
     *  Handles the actions of the Before Update trigger for Financial Security records
     */
    public static void HandleFSBeforeUpdate (Map<Id, Financial_Security__c> mapTriggerNew, Map<Id, Financial_Security__c> mapTriggerOld) {
    	// Create a renewal Case for all the Financial_Security__c records that are switched to the status "close to expiry"
    	
    	// Select the IDs of the Financial Security records of interest
    	List<Id> lstFSRecordIds = new List<Id>();
    	// Select the IDs of the related accounts
    	List<Id> lstRelatedAccountIds = new List<Id>();
    	
    	for (Financial_Security__c fs : mapTriggerNew.values()) {
    		if (fs.Security_Status__c == 'Close to Expiry Date' && mapTriggerOld.get(fs.Id).Security_Status__c != 'Close to Expiry Date') {
    			lstFSRecordIds.add(fs.Id);
    			lstRelatedAccountIds.add(fs.Account__c);
    		}
    	}
    	
    	// Get extra information on these FS records (information not available in the Trigger.new map, like the account name)
    	List<Financial_Security__c> lstFSRecordsWithExtraInfo = [SELECT Id, Name, Region__c, Account_Country__c, IATA_code__c, Expiry_Date__c, Account__c, Account__r.Name, Account__r.Industry, Account__r.Type,
    						Financial_Institution__r.Name, Amount__c, Security_Type__c, Remarks__c FROM Financial_Security__c WHERE Id IN :lstFSRecordIds];
    	
    	// Get all financial assessment contacts from the accounts related to the FS records (keep 1 contact per account), to add them on the cases
    	List<Contact> lstFAContacts = [SELECT Id, AccountId FROM Contact WHERE Financial_Assessment_Contact__c = true AND AccountId IN :lstRelatedAccountIds];
    	map<Id, Id> mapFAContactIdsPerAccountIds = new map<Id, Id>();
    	for (Contact c : lstFAContacts) {
    		mapFAContactIdsPerAccountIds.put(c.AccountId, c.Id);
    	}
    	
    	
    	// a map to hold the newly created cases per the corresponding Financial Security record Id
    	Map<Id, Case> mapNewCasesPerFSId = new Map<Id, Case>();
    	
    	// create the renewal cases for the records of interest
    	for (Financial_Security__c fs : lstFSRecordsWithExtraInfo) {
    		// create the case object
    		Case tmpCase = CaseFactory.CreateFinancialSecurityCase(fs, false);
    		    		
    		// fill in the contact info, if available
    		tmpCase.ContactId = mapFAContactIdsPerAccountIds.get(fs.Account__c);
    		
    		mapNewCasesPerFSId.put(fs.Id, tmpCase);
    	}
    	
    	if (!mapNewCasesPerFSId.values().isEmpty()) {
    		try {
    			insert mapNewCasesPerFSId.values();
    			
    			// take the newly created cases Ids and fill it on the original Financial Security record
    			for (Id fsId : mapNewCasesPerFSId.keyset()) {
    				mapTriggerNew.get(fsId).Renewal_Case__c = mapNewCasesPerFSId.get(fsId).Id;
    			}
    			
    		} catch (Exception e) {
    			system.debug('## ERROR: ' + e.getMessage());
    		}
    	}
    }


    //AMSU-190
    public static void validateFSforNotification(){

        List<Financial_Security__c> fsToValidate = new List<Financial_Security__c>();
        List<Financial_Security__c> fsToUpdate = new List<Financial_Security__c>();

        Set<Id> accountIds = new Set<Id>();

        for(Financial_Security__c fs:triggerNew){

            //• Status = Not yet active, Active, Close to expiry AND
            //• Unlimited Validity = True OR Validity start date not empty
            if( (fs.Security_Status__c == 'Close to Expiry Date' || fs.Security_Status__c == 'Not Active yet' || fs.Security_Status__c == 'Active') 
                && (fs.Unlimited_Security__c == true || fs.Validity_Start_Date__c != null) && fs.Security_Type__c != 'Others') { /* WMO-400 */
                fsToValidate.add(fs);
                accountIds.add(fs.Account__c);
            }
        }

        //contacts that will receive notifications
        Map<Id, List<Contact>> keyContactsPerAccount = new Map<Id, List<Contact>>();

        //get all accounts
        List<Account> allAccounts = new List<Account>([SELECT Id, Top_Parent__c, Location_Type__c FROM Account WHERE Id IN :accountIds]);

        Set<Id> accountIdsHOs = new Set<Id>();
        Map<Id, Set<Id>> parentPerBR = new Map<Id, Set<Id>>();

        //check if the account is an AO or HO to get the contacts of TopParent
        for(Account ac: allAccounts){

            if(!AMS_Utils.LocationTypeAllHOTypes.contains(ac.Location_Type__c)){
                
                accountIdsHOs.add(ac.Top_Parent__c);
                if(!parentPerBR.containsKey(ac.Top_Parent__c))
                    parentPerBR.put(ac.Top_Parent__c, new Set<Id>());
                
                parentPerBR.get(ac.Top_Parent__c).add(ac.Id);
            }
        }

        //get contacts of first accounts
        if(!accountIds.isEmpty()) {
            List<Contact> allContacts = new List<Contact>([SELECT Id, Name, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c, Account.Region_formula__c FROM Contact WHERE AccountId IN :accountIds AND IsEmailBounced = FALSE AND (Financial_Assessment_Contact__c = TRUE OR User_Portal_Status__c = 'Approved Admin')]);

            for(Contact c: allContacts){
                if(!keyContactsPerAccount.containsKey(c.AccountId))
                    keyContactsPerAccount.put(c.AccountId, new List<Contact>());

                keyContactsPerAccount.get(c.AccountId).add(c);
            }
        }

        //get contacts of topParents and relate them with first account
        if(!accountIdsHOs.isEmpty()){
            List<Contact> allContactsHOs = new List<Contact>([SELECT Id, Name, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c FROM Contact WHERE AccountId IN :accountIdsHOs AND IsEmailBounced = FALSE AND (Financial_Assessment_Contact__c = TRUE OR User_Portal_Status__c = 'Approved Admin')]);

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
        

        Set<Id> accts = new Set<Id>();
        Set<Id> isoCountries = new Set<Id>();

        
        Map<Id, Account> accountData = new Map<Id, Account>([SELECT Abbreviated_address__c, Abbreviated_name__c, Name, BillingState, BillingCity, IATA_ISO_Country__c,
                                                                   Email__c, Fax, Phone, BillingPostalCode, BillingStreet, CASS_Number__c, IATACode__c, Iso_State__c,
                                                                   License_Number__c, VAT_Number__c, Is_your_firm_handling_Dangerous_Goods__c, Location_Class__c,
                                                                   Location_Type__c, Mobile__c, Operation__c, Remittance_frequency__c, ShippingCity, ShippingCountry,
                                                                   ShippingPostalCode, ShippingState, ShippingStreet, Short_Name__c, Solicitation_Flag__c, TradeName__c,
                                                                   VAT_Number_2__c, Website, BillingCountry, Region_formula__c, Legal_name__c, IATA_ISO_Country__r.Name,
                                                                   IATA_ISO_Country__r.ISO_Code__c, Company_Type__c
                                                            FROM Account WHERE Id IN :accountIds]);

        for(Account acc: accountData.values())
            isoCountries.add(acc.IATA_ISO_Country__c);
        
        Map<String, Id> countryTemplates = getFSEmailTemplates();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'agencymanagement@iata.org'];

        for(Financial_Security__c fsReg: fsToValidate){

            sendEmailAlert(keyContactsPerAccount.get(fsReg.Account__c), fsReg, countryTemplates, owea[0]);

            fsToUpdate.add(new Financial_Security__c(id=fsReg.id, Acknowledgment_sent__c = true));
            
        }

        update fsToUpdate;

    }

    //AMSU-190
    public static void sendEmailAlert(List<Contact> recipents, Financial_Security__c fs, Map<String, Id> countryTemplates, OrgWideEmailAddress owea) {
        Id templateId;
        Boolean templateToIATA = false;
        List<EmailTemplate> tempIata = new List<EmailTemplate>();
        Map<Id, Id> mapContactsVs_User = new Map<Id, Id>();
        Map<Id, String> mapUsersVsContactName = new Map<Id, String>();
        Map<Id, String> mapUserVsEmail = new Map<Id, String>();
        Set<Id> contactsId = new Set<Id>();

        if(recipents == null) {
            templateToIATA = true;

            //getTemplate
            tempIata = [SELECT Id, DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Info_To_IATA_AMS_FS_Not_Sent'];
            
            //get region
            String region =fs.Region__c;

            //get contact from IATA by custom setting
            List<IATA_Contacts_by_Region__c> customSettingValues = IATA_Contacts_by_Region__c.getall().values();
            List<String> emailsToSend = new List<String>();
            for(IATA_Contacts_by_Region__c cR : customSettingValues)
            {
                if(cR.Region__c == region)
                    emailsToSend.add(cR.Contact_Email__c);
            }
            
            //put the contacts in recipents list
            recipents = [SELECT Id, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c FROM Contact WHERE Email IN :emailsToSend];
            System.debug('IATA recipents list: ' + recipents);
        }

        For(Contact c : recipents){
            contactsId.add(c.Id);
        }

        For(User u :  [Select Id, ContactId, Email, Name FROM User WHERE ContactId in :contactsId]){
            mapContactsVs_User.put(u.ContactId, u.Id);
            mapUserVsEmail.put(u.Id, u.Email);
            mapUsersVsContactName.put(u.Id, u.Name);
        }        
        
        if(recipents != null){

            List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
            List<EmailMessage> mailsToTrackInCase = new List<EmailMessage>();
            List<String> lPortalAdminsEmails = new List<String>();
            Map<String, List<Id>> mPortalAdminsEmails = new Map<String, List<Id>>();
            Map<String, Contact> mRecipientPortalAdminsEmails = new Map<String, Contact>();

            for(Contact recipient: recipents){
                Id userId = mapContactsVs_User.get(recipient.Id);

                if(recipient.User_Portal_Status__c == 'Approved Admin' || recipient.Financial_Assessment_Contact__c || templateToIATA){

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.saveAsActivity = true;
                    mail.setTargetObjectId(recipient.id);
                    mail.setWhatId(fs.Id);
                    mail.setOrgWideEmailAddressId(owea.Id);

                    if(templateToIATA){
                        mail.setTemplateId(tempIata.get(0).Id);
                    } else {
                        mail.setTemplateId(getSpecificLangTemplate((fs.Unlimited_Security__c == true?'Unlimited_':'') + recipient.Preferred_Language__c, countryTemplates));
                        system.debug('sendEmailAlert: mail.getTemplateId() - ' + mail.getTemplateId());
                    }
                    
                    mailsToSend.add(mail);
                 }
            }            

            if(!mailsToSend.isEmpty()){
                if(!Test.isRunningTest()) Messaging.sendEmail(mailsToSend);
            }

        }
    }

    //AMSU-190
    private static Map<String, Id> getFSEmailTemplates(){

        Map<String, Id> multilangTemplates = new Map<String, Id>();
        Map<String, EmailTemplate> auxCountryTemplates = new Map<String, EmailTemplate>();
        Map<Id, EmailTemplate> auxTemplateIdVsTemplates = new Map<Id, EmailTemplate>();
        Map<Id, List<Attachment>> auxTemplateIdVsAttachemnt = new Map<Id, List<Attachment>>();
        String devNameLike = 'AMS_FS_Notification%';
        List<EmailTemplate> etFS = [SELECT Id, DeveloperName, HtmlValue, Body, Subject FROM EmailTemplate WHERE DeveloperName LIKE :devNameLike];
        list<Attachment> attachments = [select ContentType, Body, parentId, Id, Name From Attachment where parentId in :etFS];
        for(EmailTemplate et: etFS){
            if(!auxCountryTemplates.containsKey(et.DeveloperName))
                auxCountryTemplates.put(et.DeveloperName, et);

            if(!auxTemplateIdVsTemplates.containsKey(et.Id))
                auxTemplateIdVsTemplates.put(et.Id, et);

        }
        for(Attachment attc : attachments){
            List<Attachment> auxl;
            if(auxTemplateIdVsAttachemnt.containsKey(attc.parentId)){
                auxl = auxTemplateIdVsAttachemnt.get(attc.parentId);
                auxl.add(attc);
            }else{
                auxl = new List<Attachment>{attc};
            }
            auxTemplateIdVsAttachemnt.put(attc.parentId, auxl);
            
        }

        //map template Ids with their respective language
        List<Schema.Picklistentry> prefLanguages = Contact.getSObjectType().getDescribe().fields.getMap().get('Preferred_Language__c').getDescribe().getPickListValues();

        for(Schema.Picklistentry pe: prefLanguages){

            EmailTemplate langTemplate = auxCountryTemplates.get('AMS_FS_Notification_' + pe.getValue());
            EmailTemplate langTemplateUnlimited = auxCountryTemplates.get('AMS_FS_Notification_Unlimited_' + pe.getValue());

            //English is default and must exist in the system
            if(langTemplate == null) langTemplate = auxCountryTemplates.get('AMS_FS_Notification_English');
            if(langTemplateUnlimited == null) langTemplateUnlimited = auxCountryTemplates.get('AMS_FS_Notification_Unlimited_English');

            multilangTemplates.put(pe.getValue(), langTemplate.Id);
            multilangTemplates.put('Unlimited_' + pe.getValue(), langTemplateUnlimited.Id);
        }

        //this should never happen unless picklist values are deleted form the Contact Preferred_Language__c
        if(multilangTemplates.isEmpty()){
            multilangTemplates.put('English', auxCountryTemplates.get('AMS_FS_Notification_English').Id);
            multilangTemplates.put('Unlimited_English', auxCountryTemplates.get('AMS_FS_Notification_Unlimited_English').Id);
        } 

        //system.debug('FS templates mapping ' + multilangTemplates);

        FinancialSecurityUtil.countryTemplates = auxCountryTemplates;
        FinancialSecurityUtil.templateIdVsTemplates = auxTemplateIdVsTemplates;
        FinancialSecurityUtil.templateIdVsAttachemnt = auxTemplateIdVsAttachemnt;
        return multilangTemplates;

    }

    //AMSU-190
    //return templateId based on lang selected, default English if none is found
    private static Id getSpecificLangTemplate(String lang, Map<String, Id> availableTemplates){
        String defaultLang = Lang.contains('Unlimited')?'Unlimited_English':'English';
        if(availableTemplates.get(lang) != null) return availableTemplates.get(lang);
        else return availableTemplates.get(defaultLang);
    }
}