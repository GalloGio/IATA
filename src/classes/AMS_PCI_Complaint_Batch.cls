global class AMS_PCI_Complaint_Batch implements Database.Batchable<sObject>, Schedulable {
    
    private Integer batchScope {get;set;}

    global AMS_PCI_Complaint_Batch(Integer batchScope) {
        //this.batchScope = batchScope;
        this.batchScope = 1;
    }

    public static void start(String cron, Integer scope) {
        System.schedule('AMS PCI Complaint Batch', cron, new AMS_PCI_Complaint_Batch (scope));
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, this.batchScope);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, Is_PCI_compliant__c, ANG_PCI_compliance_expiry_date__c, '+
                        'Abbreviated_address__c, Abbreviated_name__c, BillingState, BillingCity, ' +
                        'IATA_ISO_Country__c, Email__c, Fax, Phone, BillingPostalCode, BillingStreet, ' + 
                        'CASS_Number__c, IATACode__c, Iso_State__c, License_Number__c, VAT_Number__c, ' +
                        'Is_your_firm_handling_Dangerous_Goods__c, Location_Class__c,Location_Type__c, ' +
                        'Mobile__c, Operation__c, Remittance_frequency__c, ShippingCity, ShippingCountry, ' +
                        'ShippingPostalCode, ShippingState, ShippingStreet, Short_Name__c, ' +
                        'Solicitation_Flag__c, TradeName__c, VAT_Number_2__c, Website, BillingCountry, ' +
                        'Region_formula__c, Legal_name__c, IATA_ISO_Country__r.Name, ' + 
                        'IATA_ISO_Country__r.ISO_Code__c, Company_Type__c, Status__c ' +
                       'FROM Account ' +
                       'WHERE ANG_PCI_compliance_expiry_date__c = NEXT_N_DAYS:90';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        validateCandidatesForRenewal(scope);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

    public static void validateCandidatesForRenewal(List<Account> pciRequiringRenewal){

        Set<Id> accountIds = new Set<Id>();

        for(Account agReg: pciRequiringRenewal){
            if(agReg.Status__c != AMS_Utils.ACC_S0_TERMINATED){
                accountIds.add(agReg.Id);
            }
        }

        //contacts that will receive notifications for PCI renewal
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
        
        //--------------------------------------------

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

        
        Map<String, Id> countryTemplates = PCIemailTemplates('PCI');
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'agencymanagement@iata.org'];

        for(Account agReg: pciRequiringRenewal){

            Contact comCasecontact;

            if(keyContactsPerAccount!=null && keyContactsPerAccount.get(agReg.Id)!= null && !keyContactsPerAccount.get(agReg.Id).isEmpty()){
                system.debug('keyContactsPerAccount ' + keyContactsPerAccount);
                //find portal admin
                for(Contact c: keyContactsPerAccount.get(agReg.Id)){
                    if(c.User_Portal_Status__c == 'Approved Admin')
                        comCasecontact = c;
                }

                system.debug('CHECK comcasecontact' + keyContactsPerAccount.get(agReg.Id).get(0));
                //if no admin is found just use one of the existing keyContacts
                if(comCasecontact == null) comCasecontact = keyContactsPerAccount.get(agReg.Id).get(0);
            }

            system.debug('creating renewal for PCI');

            AMS_OSCAR__c oscar = createStagingArea(agReg, comCasecontact);
            
            System.debug('oscar: ' + oscar);
            sendEmailAlert(keyContactsPerAccount.get(agReg.Id), oscar.Id, countryTemplates, oscar.Oscar_Communication_Case_Id__c, owea[0], true);

            
        }
    }

    
    public static AMS_OSCAR__c createStagingArea(Account accountData, Contact communicationCaseContact){

        AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = AMS_Utils.RECTYPE_CERT, Account__c = accountData.Id,
                                    Process__c = AMS_Utils.PCI_COMPLIANT, Status__c='Accepted_Future Date', ANG_PCI_compliance_expiry_date__c = accountData.ANG_PCI_compliance_expiry_date__c);
        insert theOscar;

        system.debug('createStagingArea oscar: '+ theOscar);
        Case theCommunicationCase = new Case();

        theCommunicationCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
        theCommunicationCase.OSCAR__c = theOscar.Id;
        theCommunicationCase.CaseArea__c = 'Accreditation Process';
        theCommunicationCase.AccountId = accountData.Id;
        theCommunicationCase.Account_Concerned__c = accountData.Id;
        theCommunicationCase.BSPCountry__c = accountData.BillingCountry;
        theCommunicationCase.Reason1__c = 'PCI DSS Compliant';
        theCommunicationCase.Region__c = accountData.Region_formula__c;
        theCommunicationCase.SAAM_Deadline_Date__c = accountData.ANG_PCI_compliance_expiry_date__c;
        if(communicationCaseContact != null)
            theCommunicationCase.ContactId = communicationCaseContact.Id;
        
        insert theCommunicationCase;

        AMS_Pax_Accreditation_Form__c theStagingArea = new AMS_Pax_Accreditation_Form__c();

        theStagingArea.SAAM_Case__c                             = theCommunicationCase.Id;
        theStagingArea.Abbreviated_Address__c                   = accountData.Abbreviated_address__c;
        theStagingArea.Abbreviated_name__c                      = accountData.Abbreviated_name__c;
        theStagingArea.Accept_terms_and_conditions__c           = True;
        theStagingArea.Account_Name__c                          = accountData.Name;
        theStagingArea.Billing_State__c                         = accountData.BillingState;
        theStagingArea.Branch_Office_City__c                    = accountData.BillingCity;
        theStagingArea.Branch_Office_Country__c                 = accountData.IATA_ISO_Country__c;
        theStagingArea.Branch_Office_Email__c                   = accountData.Email__c;
        theStagingArea.Branch_Office_FAX__c                     = accountData.Fax;
        theStagingArea.Branch_Office_Phone__c                   = accountData.Phone;
        theStagingArea.Branch_Office_Postal_code__c             = accountData.BillingPostalCode;
        theStagingArea.Branch_Office_Street_name_number__c      = accountData.BillingStreet;
        theStagingArea.CASS_Number__c                           = accountData.CASS_Number__c;
        theStagingArea.IATACode__c                              = accountData.IATACode__c;
        theStagingArea.IATA_ISO_State__c                        = accountData.Iso_State__c;
        theStagingArea.ISSP_AMS_License_No__c                   = accountData.License_Number__c;
        theStagingArea.ISSP_AMS_VAT_number__c                   = accountData.VAT_Number__c;
        theStagingArea.Is_your_firm_handling_Dangerous_Goods__c = accountData.Is_your_firm_handling_Dangerous_Goods__c;
        theStagingArea.Location_Class__c                        = accountData.Location_Class__c;
        theStagingArea.Location_Type__c                         = accountData.Location_Type__c;
        theStagingArea.Mobile__c                                = accountData.Mobile__c;
        theStagingArea.Operation__c                             = accountData.Operation__c;
        theStagingArea.Remittance_frequency__c                  = accountData.Remittance_frequency__c;
        theStagingArea.Shipping_City__c                         = accountData.ShippingCity;
        theStagingArea.Shipping_Country__c                      = accountData.ShippingCountry;
        theStagingArea.Shipping_Postal_Code__c                  = accountData.ShippingPostalCode;
        theStagingArea.Shipping_State__c                        = accountData.ShippingState;
        theStagingArea.Shipping_Street__c                       = accountData.ShippingStreet;
        theStagingArea.Short_Name__c                            = accountData.Short_Name__c;
        theStagingArea.Solicitation_Flag__c                     = accountData.Solicitation_Flag__c;
        theStagingArea.Submitted_to_IATA__c                     = True;
        theStagingArea.Trade_Name__c                            = accountData.TradeName__c;
        theStagingArea.VAT_Number_2__c                          = accountData.VAT_Number_2__c;
        theStagingArea.Website__c                               = accountData.Website;
        theStagingArea.ISSP_AMS_Legal_Status__c                 = AMS_AgencyHelper.transformCompanyType(accountData.Company_Type__c);
        
        insert theStagingArea;

        theOscar.Oscar_Communication_Case_Id__c = theCommunicationCase.Id;
        theOscar.Emails_reference_Id__c = AMS_Utils.caseRefId(UserInfo.getOrganizationId(), theCommunicationCase.Id);
        theOscar.AMS_Online_Accreditation__c = theStagingArea.Id;
        update theOscar;

        return theOscar;
    }

    

    public static void sendEmailAlert(List<Contact> recipents, Id oscarId, Map<String, Id> countryTemplates, String oscarCommCaseId, OrgWideEmailAddress owea, boolean isDGR) {
        
        Id templateId;
        Boolean templateToIATA = false;
        List<EmailTemplate> tempIata = new List<EmailTemplate>();

        if(recipents == null)
        {
            templateToIATA = true;

            //getTemplate
            tempIata = [SELECT Id, DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Info_To_IATA_AMS_DGR_Renewal_Not_Sent'];
            
            //get region
            List<AMS_OSCAR__c> oscars = [SELECT Id, Region__c FROM AMS_OSCAR__c WHERE Id = :oscarId];
            String region = oscars.get(0).Region__c;

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

        if(recipents != null){

            List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

            system.debug('DGR sendEmailAlert: country templates ' + countryTemplates);
            system.debug('DGR sendEmailAlert: recipents ' + recipents);

            List<EmailMessage> mailsToTrackInCase = new List<EmailMessage>();

            //FM 24/10/2017 - AMSU-32 - when DGR case use only one mail message for all the Portal Admin, instead of a mail message per each
            List<String> lPortalAdminsEmailsDGR = new List<String>();
            Map<String, List<String>> mPortalAdminsEmailsDGR = new Map<String, List<String>>();
            Map<String, Contact> mRecipientPortalAdminsEmailsDGR = new Map<String, Contact>();

            for(Contact recipient: recipents){

                if(!isDGR || recipient.BSP_CASS_Payment_contact__c || recipient.Financial_Assessment_Contact__c || templateToIATA){

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.saveAsActivity = true;
                    mail.setToAddresses(new List<String>{recipient.Email});
                    if(templateToIATA){
                        mail.setTemplateId(tempIata.get(0).Id);
                    } else {
                        mail.setTemplateId(getSpecificLangTemplate(recipient.Preferred_Language__c, countryTemplates));
                    }
                    mail.setTargetObjectId(recipient.Id);
                    
                    mail.setWhatId(oscarId);
                   
                    mail.setOrgWideEmailAddressId(owea.Id);

                    mailsToSend.add(mail);

                //FM 07-07-2017 - AMSU-14 - added the test for the DGR in order to allow it to send the notification to multiple contacts
                //PS - add to replicate because this method is being used by OSCAR trigger to send email that are not only related to Renewalls... otherwise I'll mess up the NewGen functionalities
                }else if(isDGR){

                    system.debug('DGR sendEmailAlert: isDGR ' + isDGR);

                    //FM 24/10/2017 - AMSU-32 
                    if(recipient.User_Portal_Status__c == 'Approved Admin'){

                        system.debug('DGR sendEmailAlert: Entrei!! - recipient.User_Portal_Status__c ' + recipient.User_Portal_Status__c);
                        system.debug('DGR sendEmailAlert: Pref Lang ' + recipient.Preferred_Language__c);

                        //lPortalAdminsEmailsDGR.add(recipient.Email);
                        if(mPortalAdminsEmailsDGR.containsKey(recipient.Preferred_Language__c)){
                            system.debug('DGR sendEmailAlert: Already contain record for Pref Lang : ' + recipient.Preferred_Language__c);
                            List<String> aux = mPortalAdminsEmailsDGR.get(recipient.Preferred_Language__c);
                            aux.add(recipient.Email);
                            mPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c, aux);
                        }else{
                            system.debug('DGR sendEmailAlert: NO record for Pref Lang : ' + recipient.Preferred_Language__c);
                            List<String> aux = new List<String>();
                            aux.add(recipient.Email);
                            mPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c, aux);
                            mRecipientPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c,recipient);
                        }

                        system.debug('DGR sendEmailAlert: mPortalAdminsEmailsDGR ' + mPortalAdminsEmailsDGR);


                    }else{
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.saveAsActivity = true;
                    mail.setToAddresses(new List<String>{recipient.Email});
                    if(templateToIATA){
                        mail.setTemplateId(tempIata.get(0).Id);
                    } else {
                        mail.setTemplateId(getSpecificLangTemplate(recipient.Preferred_Language__c, countryTemplates));
                    }
                    mail.setTargetObjectId(recipient.Id);
                    
                    mail.setWhatId(oscarId);
                       
                    mail.setOrgWideEmailAddressId(owea.Id);

                    mailsToSend.add(mail);
                }
                }

            }

            //FM 24/10/2017 - AMSU-32 
            if(mPortalAdminsEmailsDGR != null && mPortalAdminsEmailsDGR.size() > 0){
                for(String key : mPortalAdminsEmailsDGR.keySet()){
                    
                    system.debug('DGR sendEmailAlert: key : ' + key);
                    system.debug('DGR sendEmailAlert: List : mPortalAdminsEmailsDGR.get(key) : ' + mPortalAdminsEmailsDGR.get(key));

                    Messaging.SingleEmailMessage mailPortalAdmin = new Messaging.SingleEmailMessage();
                    mailPortalAdmin.saveAsActivity = true;
                    mailPortalAdmin.setToAddresses(mPortalAdminsEmailsDGR.get(key));
                    if(templateToIATA){
                        mailPortalAdmin.setTemplateId(tempIata.get(0).Id);
                    } else {
                        mailPortalAdmin.setTemplateId(getSpecificLangTemplate(key, countryTemplates));
                    }

                    Contact auxCont = mRecipientPortalAdminsEmailsDGR.get(key);
                    mailPortalAdmin.setTargetObjectId(auxCont.Id);

                    mailPortalAdmin.setWhatId(oscarId);
                   
                    mailPortalAdmin.setOrgWideEmailAddressId(owea.Id);
                    mailsToSend.add(mailPortalAdmin);
            }
            }

            system.debug('DGR sendEmailAlert: mailsToSend : ' + mailsToSend);

            if(!mailsToSend.isEmpty()){
                if(!Test.isRunningTest()) Messaging.sendEmail(mailsToSend);
                for(Messaging.SingleEmailMessage mail: mailsToSend)
                {
                    EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                    emailMsg.ToAddress=(mail.getToAddresses())[0];
                    emailMsg.Subject = mail.getSubject();
                    emailMsg.HtmlBody = mail.getHtmlBody();
                    emailMsg.ParentId = oscarCommCaseId; //Attach with the case
                    emailMsg.MessageDate = system.now();
                    emailMsg.Status = '0';
                    mailsToTrackInCase.add(emailMsg);
                }
                insert mailsToTrackInCase;
            }

        }
    }

    private static Map<String, Id> PCIemailTemplates(String type){

        Map<String, Id> multilangTemplates = new Map<String, Id>();

        String devNameLike = 'AMS_' + type + '_Compliant%';
        List<EmailTemplate> etDGR = [SELECT Id, DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName LIKE :devNameLike];
        Map<String, EmailTemplate> countryTemplates = new Map<String, EmailTemplate>();
        for(EmailTemplate et: etDGR){
            if(!countryTemplates.containsKey(et.DeveloperName))
                countryTemplates.put(et.DeveloperName, et);
        }

        system.debug('CHECK countryTemplates ' + countryTemplates);

        //map template Ids with their respective language
        List<Schema.Picklistentry> prefLanguages = Contact.getSObjectType().getDescribe().fields.getMap().get('Preferred_Language__c').getDescribe().getPickListValues();

        for(Schema.Picklistentry pe: prefLanguages){
            EmailTemplate langTemplate = countryTemplates.get('AMS_' + type + '_Compliant_' + pe.getValue());

            //English is default and must exist in the system
            if(langTemplate == null) langTemplate = countryTemplates.get('AMS_' + type + '_Compliant_EN');

            multilangTemplates.put(pe.getValue(), langTemplate.Id);
        }

        //this should never happen unless picklist values are deleted form the Contact Preferred_Language__c
        if(multilangTemplates.isEmpty()) multilangTemplates.put('English', countryTemplates.get('AMS_' + type + '_Compliant_EN').Id);

        system.debug(type + ' templates mapping ' + multilangTemplates);

        return multilangTemplates;

    }

    //return templateId based on lang selected, default English if none is found
    private static Id getSpecificLangTemplate(String lang, Map<String, Id> availableTemplates){
        if(availableTemplates.get(lang) != null) return availableTemplates.get(lang);
        else return availableTemplates.get('English');
    }
    
}