global class AMS_PCI_Complaint_Batch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private Integer batchScope {get;set;}
    public Id iata_iso_Country_id {get;set;}
    public Set<String> list_iata_iso_Country_id {get;set;}
    global List<ErrorWrapper> lstErrors {get;set;}
    global List<ResultWrapper> lstResult {get;set;}
    public Set<Account> filteredAccounts {get;set;}
    public static Map<String, EmailTemplate> countryTemplates {get;set;}
    public static Map<Id, EmailTemplate> templateIdVsTemplates {get;set;}
    public static Map<Id, List<Attachment>> templateIdVsAttachemnt {get;set;}
    public static Map<Id, Case> casesInfo {get;set;}

    global AMS_PCI_Complaint_Batch(Integer batchScope, Set<String> list_iata_iso_Country_id) {
        this.batchScope = batchScope;
        this.list_iata_iso_Country_id = list_iata_iso_Country_id;
        this.lstErrors = new List<ErrorWrapper>();
        this.lstResult = new List<ResultWrapper>();
    }

    global AMS_PCI_Complaint_Batch(Integer batchScope, Set<String> list_iata_iso_Country_id, Set<Account> filteredAccounts) {
        this.batchScope = batchScope;
        this.list_iata_iso_Country_id = list_iata_iso_Country_id;
        this.lstErrors = new List<ErrorWrapper>();
        this.lstResult = new List<ResultWrapper>();
        this.filteredAccounts = filteredAccounts;
    }

    //public static void start(String cron, Integer scope) {
    //    System.schedule('AMS PCI Compliant Batch', cron, new AMS_PCI_Complaint_Batch (scope, null));
    //}
    public static void start(String cron, Integer scope) {
        if(!Test.isRunningTest()) {
            System.schedule('AMS PCI Compliant Batch', cron, new AMS_PCI_Complaint_Batch (scope, null));
        }else{
            System.schedule('AMS PCI Compliant Batch TEST', cron, new AMS_PCI_Complaint_Batch (scope, null));
        }
        
    }

    global static void stop(){
        String sJobName = '';
        if(!Test.isRunningTest()) {
            sJobName = 'AMS PCI Compliant Batch';
        }else{
            sJobName = 'AMS PCI Compliant Batch TEST';
        }
        
        List<CronTrigger> SCHEDULE_ID = [SELECT Id FROM CronTrigger where CronJobDetail.Name = :sJobName limit 1]; 
        
        if(SCHEDULE_ID.size() > 0){
            System.abortJob(SCHEDULE_ID[0].Id);
        }
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, this.batchScope);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String location = AMS_Utils.LC_PASSENGER;
        Id AGENCY_RECORDTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordtypeId();
        String reason = 'PCI DSS Compliant';
        Set<String> availableStatus = new Set<String> {AMS_Utils.ACC_S9_APPROVED, AMS_Utils.ACC_S5_CASHNOCOMMISSION, 
                                                       AMS_Utils.ACC_S6_CASHWITHCOMMISSION, AMS_Utils.ACC_S8_CHANGESPROCESSED,
                                                       AMS_Utils.ACC_S4_LISTED, AMS_Utils.ACC_S7_UNDERREVIEW, 'Review'};
        Set<String> pciValues = new Set<String> {'Yes', 'Nil CC'};
        String query = 'SELECT Id, Name, Is_PCI_compliant__c, ANG_PCI_compliance_expiry_date__c,' +
                       ' Abbreviated_address__c, Abbreviated_name__c, BillingState, BillingCity,' +
                       ' IATA_ISO_Country__c, Email__c, Fax, Phone, BillingPostalCode, BillingStreet,' +
                       ' CASS_Number__c, IATACode__c, Iso_State__c, License_Number__c, VAT_Number__c,' +
                       ' Is_your_firm_handling_Dangerous_Goods__c, Location_Class__c,Location_Type__c,' +
                       ' Mobile__c, Operation__c, Remittance_frequency__c, ShippingCity, ShippingCountry,' +
                       ' ShippingPostalCode, ShippingState, ShippingStreet, Short_Name__c,' + 
                       ' Solicitation_Flag__c, TradeName__c, VAT_Number_2__c, Website, BillingCountry,' +
                       ' Region_formula__c, Legal_name__c, IATA_ISO_Country__r.Name,' +
                       ' IATA_ISO_Country__r.ISO_Code__c, Company_Type__c, Status__c ' +
                       'FROM Account ' + 
                       'WHERE';

        if(filteredAccounts != null && !filteredAccounts.isEmpty()) {
            query += ' Id IN :filteredAccounts';
        } else {
            query += ' Location_Class__c = :location AND Status__c IN :availableStatus AND ANG_PCI_compliance_expiry_date__c = NEXT_N_DAYS:90' +
                     ' AND PCI_DSS_Compliant__c = NULL' +
                     ' AND Is_PCI_compliant__c IN :pciValues' +
                     ' AND RecordtypeId = :AGENCY_RECORDTYPE';

            if(list_iata_iso_Country_id != null && list_iata_iso_Country_id.size() > 0) {
                query += ' AND IATA_ISO_Country__c IN :list_iata_iso_Country_id';
            }
        }

        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<ResultWrapper> resChunk = new List<ResultWrapper>();
        Savepoint sp = Database.setSavepoint();
        try {
            validateCandidatesForRenewal(scope, resChunk);            
        } catch(Exception e) {
            System.debug('execute validateCandidatesForRenewal - Exception : ' + e);
            System.debug('execute validateCandidatesForRenewal - Exception : ' + e.getStackTraceString());

            Database.rollback(sp);
            for(sObject record : scope) {
                lstErrors.add(new ErrorWrapper((Id) record.get('Id'), e.getMessage()));
            }   
            for(ResultWrapper r : resChunk) {
                r.message = e.getMessage();
                r.cse = null;
            }         
        }

        lstResult.addAll(resChunk);
    }
    
    global void finish(Database.BatchableContext BC) {
        List<Technical_Logs__c> lstErrorsToInsert = new List<Technical_Logs__c>();



        sendEmailResult(lstResult);
        
        for(ErrorWrapper error : lstErrors) {
            lstErrorsToInsert.add(new Technical_Logs__c(Operation__c= 'PCI Compliant', 
                                                        Record__c= BC.getJobId(),
                                                        Status__c= error.accountId,
                                                        Log__c= error.message));
        }

        if(!lstErrorsToInsert.isEmpty()) {
            insert lstErrorsToInsert;
        }
    }

    public static void validateCandidatesForRenewal(List<Account> pciRequiringRenewal, List<ResultWrapper> resW){

        Set<Id> accountIds = new Set<Id>();

        casesInfo = new Map<Id, Case>();

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
            List<Contact> allContacts = new List<Contact>([SELECT Id, Name, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c FROM Contact WHERE AccountId IN :accountIds AND IsEmailBounced = FALSE AND (BSP_CASS_Payment_contact__c = TRUE OR Financial_Assessment_Contact__c = TRUE OR User_Portal_Status__c = 'Approved Admin')]);

            for(Contact c: allContacts){
                if(!keyContactsPerAccount.containsKey(c.AccountId))
                    keyContactsPerAccount.put(c.AccountId, new List<Contact>());

                keyContactsPerAccount.get(c.AccountId).add(c);
            }
        }

        system.debug('accountIdsHOs: ' + accountIdsHOs);
        //get contacts of topParents and relate them with first account
        if(!accountIdsHOs.isEmpty()){
            List<Contact> allContactsHOs = new List<Contact>([SELECT Id, Name, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c FROM Contact WHERE AccountId IN :accountIdsHOs AND IsEmailBounced = FALSE AND (BSP_CASS_Payment_contact__c = TRUE OR Financial_Assessment_Contact__c = TRUE OR User_Portal_Status__c = 'Approved Admin')]);

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
                    if(c.User_Portal_Status__c == 'Approved Admin') {
                        comCasecontact = c;
                        break;
                    }
                }

                system.debug('CHECK comcasecontact' + keyContactsPerAccount.get(agReg.Id).get(0));
                //if no admin is found just use one of the existing keyContacts
                system.debug('before assign comCaseContact: ' + comCasecontact);
                if(comCasecontact == null) {
                    comCasecontact = keyContactsPerAccount.get(agReg.Id).get(0);
                }
                system.debug('after assign comCaseContact: ' + comCasecontact);
            }

            system.debug('creating renewal for PCI');

            AMS_OSCAR__c oscar = createStagingArea(agReg, comCasecontact);
            ResultWrapper resProcess = new ResultWrapper(agReg);
            if(comCaseContact != null) {
                resProcess.con = comCaseContact;
            }
            if(oscar != null) {
                Case cse = [SELECT Id, CaseNumber, IATACodeProduct__c FROM Case WHERE Id = :oscar.Oscar_Communication_Case_Id__c];
                resProcess.cse = cse;
                System.debug('cse: ' + cse);
                casesInfo.put(oscar.Oscar_Communication_Case_Id__c, cse);
            }
            
            resW.add(resProcess);
            System.debug('oscar: ' + oscar);
            sendEmailAlert(keyContactsPerAccount.get(agReg.Id), oscar.Id, countryTemplates, oscar.Oscar_Communication_Case_Id__c, owea[0], true);

            agReg.PCI_DSS_Compliant__c = Date.today();
            
        }

        update pciRequiringRenewal;

    }

    
    public static AMS_OSCAR__c createStagingArea(Account accountData, Contact communicationCaseContact){

        AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = AMS_Utils.RECTYPE_CERT, Account__c = accountData.Id,
                                    Process__c = AMS_Utils.PCI_COMPLIANT, Status__c='Accepted_Future Date', ANG_PCI_compliance_expiry_date__c = accountData.ANG_PCI_compliance_expiry_date__c);
        
        theOscar.OSCAR_Deadline__c = Date.today().addDays(30);
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
        theCommunicationCase.Visible_on_ISS_Portal__c = true;
        theCommunicationCase.Status = 'Accepted_Future Date';
        theCommunicationCase.IATACodeProduct__c = accountData.IATACode__c;
        
        if(communicationCaseContact != null)
            theCommunicationCase.ContactId = communicationCaseContact.Id;

        system.debug('before case: ' + theCommunicationCase);
        
        insert theCommunicationCase;

        system.debug('after case: ' + theCommunicationCase);

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


        theCommunicationCase.Visible_on_ISS_Portal__c = true;
        update theCommunicationCase;

        return theOscar;
    }

    

    public static void sendEmailAlert(List<Contact> recipents, Id oscarId, Map<String, Id> countryTemplates, String oscarCommCaseId, OrgWideEmailAddress owea, boolean isDGR) {
        Id templateId;
        Boolean templateToIATA = false;
        List<EmailTemplate> tempIata = new List<EmailTemplate>();
        Map<Id, Id> mapContactsVs_User = new Map<Id, Id>();
        Map<Id, String> mapUserVsEmail = new Map<Id, String>();
        Set<Id> contactsId = new Set<Id>();

        if(recipents == null) {
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

        For(Contact c : recipents){
            contactsId.add(c.Id);
        }

        For(User u :  [Select Id, ContactId, Email FROM User WHERE ContactId in :contactsId]){
            mapContactsVs_User.put(u.ContactId, u.Id);
            mapUserVsEmail.put(u.Id, u.Email);
        }        
        
        system.debug('DGR sendEmailAlert: mapContactsVs_User : ' + mapContactsVs_User);

        if(recipents != null){

            List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

            system.debug('DGR sendEmailAlert: country templates ' + countryTemplates);
            system.debug('DGR sendEmailAlert: recipents ' + recipents);

            List<EmailMessage> mailsToTrackInCase = new List<EmailMessage>();

            //FM 24/10/2017 - AMSU-32 - when DGR case use only one mail message for all the Portal Admin, instead of a mail message per each
            List<String> lPortalAdminsEmailsDGR = new List<String>();
            Map<String, List<Id>> mPortalAdminsEmailsDGR = new Map<String, List<Id>>();
            Map<String, Contact> mRecipientPortalAdminsEmailsDGR = new Map<String, Contact>();

            for(Contact recipient: recipents){
                Id userId = mapContactsVs_User.get(recipient.Id);

                /**For testing purposes**/
                if(Test.isRunningTest()) userId = UserInfo.getUserId();

                system.debug('DGR sendEmailAlert: userId : ' + userId);

                if(userId != null){

                    if(!isDGR || recipient.BSP_CASS_Payment_contact__c || recipient.Financial_Assessment_Contact__c || templateToIATA){

                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        //mail.saveAsActivity = true;
                        mail.saveAsActivity = false; //must be false when sending mail to users.
                        
                        //mail.setToAddresses(new List<String>{recipient.Email});
                        mail.setTargetObjectId(userId);
                        
                        if(templateToIATA){
                            mail.setTemplateId(tempIata.get(0).Id);
                        } else {
                            mail.setTemplateId(getSpecificLangTemplate(recipient.Preferred_Language__c, countryTemplates));
                        }
                        //mail.setTargetObjectId(recipient.Id);
                        
                        //mail.setWhatId(oscarId); //WhatId is not available for sending emails to UserIds
                       
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
                                
                                //List<String> aux = mPortalAdminsEmailsDGR.get(recipient.Preferred_Language__c);
                                //aux.add(recipient.Email);
                                List<Id> aux = mPortalAdminsEmailsDGR.get(recipient.Preferred_Language__c);
                                aux.add(userId);
                                
                                mPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c, aux);
                            }else{
                                system.debug('DGR sendEmailAlert: NO record for Pref Lang : ' + recipient.Preferred_Language__c);
                                //List<String> aux = new List<String>();
                                //aux.add(recipient.Email);
                                List<Id> aux = new List<Id>();
                                aux.add(userId);
                                
                                mPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c, aux);
                                mRecipientPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c,recipient);
                            }

                            system.debug('DGR sendEmailAlert: mPortalAdminsEmailsDGR ' + mPortalAdminsEmailsDGR);


                        }else{
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            //mail.saveAsActivity = true;
                            mail.saveAsActivity = false; //must be false when sending mail to users.
                            //mail.setToAddresses(new List<String>{recipient.Email});
                            if(templateToIATA){
                                mail.setTemplateId(tempIata.get(0).Id);
                            } else {
                                mail.setTemplateId(getSpecificLangTemplate(recipient.Preferred_Language__c, countryTemplates));
                            }
                            //.setTargetObjectId(recipient.Id);
                            mail.setTargetObjectId(userId);
                                                        
                            //mail.setWhatId(oscarId); //WhatId is not available for sending emails to UserIds
                               
                            mail.setOrgWideEmailAddressId(owea.Id);

                            mailsToSend.add(mail);
                        }
                    }
                }
            }

            if(mPortalAdminsEmailsDGR != null && mPortalAdminsEmailsDGR.size() > 0){
                for(String key : mPortalAdminsEmailsDGR.keySet()){
                    List<Id> users = mPortalAdminsEmailsDGR.get(key);
                    system.debug('DGR sendEmailAlert: key : ' + key);
                    system.debug('DGR sendEmailAlert: List : mPortalAdminsEmailsDGR.get(key) : ' + mPortalAdminsEmailsDGR.get(key));
                    system.debug('DGR sendEmailAlert: users : ' + users);
                    
                    for(Id user : users){

                        Messaging.SingleEmailMessage mailPortalAdmin = new Messaging.SingleEmailMessage();
                        //mailPortalAdmin.saveAsActivity = true; //must be false when sending mail to users.
                        mailPortalAdmin.saveAsActivity = false; //must be false when sending mail to users.
                        
                        //mailPortalAdmin.setToAddresses(mPortalAdminsEmailsDGR.get(key));

                        mailPortalAdmin.setTargetObjectId(user);
                        //setToAddresses(mPortalAdminsEmailsDGR.get(key));
                        
                        if(templateToIATA){
                            mailPortalAdmin.setTemplateId(tempIata.get(0).Id);
                        } else {
                            mailPortalAdmin.setTemplateId(getSpecificLangTemplate(key, countryTemplates));
                        }
                       
                        //Contact auxCont = mRecipientPortalAdminsEmailsDGR.get(key);
                        //mailPortalAdmin.setTargetObjectId(auxCont.Id);

                        //mailPortalAdmin.setWhatId(oscarId); //WhatId is not available for sending emails to UserIds
                       
                        mailPortalAdmin.setOrgWideEmailAddressId(owea.Id);
                        mailsToSend.add(mailPortalAdmin);
                    }
                }
            }

            //Since when sending mails with the user in the TargetObjectId we lost the automatic 
            //merge functionality so we have to merge in here
            Date dTodayPlus30 = (date.today() + 30);

            system.debug('DGR sendEmailAlert: dTodayPlus30 - ' + dTodayPlus30);
            system.debug('DGR sendEmailAlert: AMS_PCI_Complaint_Batch.templateIdVsTemplates - ' + AMS_PCI_Complaint_Batch.templateIdVsTemplates);
            system.debug('DGR sendEmailAlert: casesInfo - ' +casesInfo);

            for(Messaging.SingleEmailMessage mail : mailsToSend){
                
                system.debug('DGR sendEmailAlert: mail.getTemplateId() - ' + mail.getTemplateId());

                EmailTemplate template = AMS_PCI_Complaint_Batch.templateIdVsTemplates.get( mail.getTemplateId() );

                String subject = template.Subject;
                String htmlBody = template.HtmlValue == null?'':template.HtmlValue;
                String textBody = template.Body == null?'':template.Body;
                String caseNumber = casesInfo.get(oscarCommCaseId).CaseNumber == null?'':casesInfo.get(oscarCommCaseId).CaseNumber;
                String iatacode = casesInfo.get(oscarCommCaseId).IATACodeProduct__c == null?'':casesInfo.get(oscarCommCaseId).IATACodeProduct__c;
                
                subject = subject.replace('{!Case.CaseNumber} ', caseNumber);
                mail.setSubject(subject);


                if(htmlBody != ''){
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}', caseNumber);
                    htmlBody = htmlBody.replace('{!Case.IATA_Code__c}', iatacode);
                    htmlBody = htmlBody.replace('{!Today()+30}', dTodayPlus30.format());
                    htmlBody = htmlBody.replace('{!Case.Id}', oscarCommCaseId);
                }

                if(textBody != ''){
                    textBody = textBody.replace('{!Case.CaseNumber}', caseNumber);
                    textBody = textBody.replace('{!Case.IATA_Code__c}', iatacode);
                    textBody = textBody.replace('{!Today()+30}', dTodayPlus30.format());
                    textBody = textBody.replace('{!Case.Id}', oscarCommCaseId);
                }

                mail.setHtmlBody(htmlBody);
                mail.setPlainTextBody(textBody);

                List<Attachment> attachs = templateIdVsAttachemnt.get(mail.getTemplateId());
                system.debug('DGR sendEmailAlert: attachs : ' + attachs);
                List<Messaging.EmailFileAttachment> emailAttachs = new list<Messaging.EmailFileAttachment>();
                for(Attachment attach : attachs){
                    Messaging.EmailFileAttachment emailAttc = new Messaging.EmailFileAttachment();
                    emailAttc.setFileName(attach.Name);
                    emailAttc.setBody(attach.Body);
                    emailAttc.setContenttype(attach.ContentType);

                    emailAttachs.add(emailAttc);    
                }
                system.debug('DGR sendEmailAlert: emailAttachs : ' + emailAttachs);
                mail.setFileAttachments(emailAttachs);
            }

            system.debug('DGR sendEmailAlert: mailsToSend : ' + mailsToSend);


            if(!mailsToSend.isEmpty()){
                if(!Test.isRunningTest()) Messaging.sendEmail(mailsToSend);
                for(Messaging.SingleEmailMessage mail: mailsToSend)
                {
                    EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                    //emailMsg.ToAddress=(mail.getToAddresses())[0];
                    system.debug('DGR sendEmailAlert: mail.getTargetObjectId() : ' + mail.getTargetObjectId());
                    system.debug('DGR sendEmailAlert: mapUserVsEmail.get(mail.getTargetObjectId()) : ' + mapUserVsEmail.get(mail.getTargetObjectId()));
                    emailMsg.ToAddress=mapUserVsEmail.get(mail.getTargetObjectId());
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
        Map<String, EmailTemplate> auxCountryTemplates = new Map<String, EmailTemplate>();
        Map<Id, EmailTemplate> auxTemplateIdVsTemplates = new Map<Id, EmailTemplate>();
        Map<Id, List<Attachment>> auxTemplateIdVsAttachemnt = new Map<Id, List<Attachment>>();
        String devNameLike = 'AMS_' + type + '_Compliant%';
        List<EmailTemplate> etDGR = [SELECT Id, DeveloperName, HtmlValue, Body, Subject FROM EmailTemplate WHERE DeveloperName LIKE :devNameLike];
        list<Attachment> attachments = [select ContentType, Body, parentId, Id, Name From Attachment where parentId in :etDGR];
        //Map<String, EmailTemplate> countryTemplates = new Map<String, EmailTemplate>();
        for(EmailTemplate et: etDGR){
            if(!auxCountryTemplates.containsKey(et.DeveloperName))
                auxCountryTemplates.put(et.DeveloperName, et);

            if(!auxTemplateIdVsTemplates.containsKey(et.Id))
                auxTemplateIdVsTemplates.put(et.Id, et);

        }
        for(Attachment attc : attachments){
            //auxTemplateIdVsAttachemnt.put(attc.parentId, attc);
            List<Attachment> auxl;
            if(auxTemplateIdVsAttachemnt.containsKey(attc.parentId)){
                auxl = auxTemplateIdVsAttachemnt.get(attc.parentId);
                auxl.add(attc);
            }else{
                auxl = new List<Attachment>{attc};
            }
            auxTemplateIdVsAttachemnt.put(attc.parentId, auxl);
            
        }

        system.debug('CHECK countryTemplates ' + auxCountryTemplates);

        //map template Ids with their respective language
        List<Schema.Picklistentry> prefLanguages = Contact.getSObjectType().getDescribe().fields.getMap().get('Preferred_Language__c').getDescribe().getPickListValues();

        for(Schema.Picklistentry pe: prefLanguages){
            EmailTemplate langTemplate = auxCountryTemplates.get('AMS_' + type + '_Compliant_' + pe.getValue());

            //English is default and must exist in the system
            if(langTemplate == null) langTemplate = auxCountryTemplates.get('AMS_' + type + '_Compliant_EN');

            multilangTemplates.put(pe.getValue(), langTemplate.Id);
        }

        //this should never happen unless picklist values are deleted form the Contact Preferred_Language__c
        if(multilangTemplates.isEmpty()) multilangTemplates.put('English', auxCountryTemplates.get('AMS_' + type + '_Compliant_EN').Id);

        system.debug(type + ' templates mapping ' + multilangTemplates);

        AMS_PCI_Complaint_Batch.countryTemplates = auxCountryTemplates;
        AMS_PCI_Complaint_Batch.templateIdVsTemplates = auxTemplateIdVsTemplates;
        AMS_PCI_Complaint_Batch.templateIdVsAttachemnt = auxTemplateIdVsAttachemnt;
        return multilangTemplates;

    }

    //return templateId based on lang selected, default English if none is found
    private static Id getSpecificLangTemplate(String lang, Map<String, Id> availableTemplates){
        if(availableTemplates.get(lang) != null) return availableTemplates.get(lang);
        else return availableTemplates.get('English');
    }

    public class ErrorWrapper {
        public Id accountId {get;set;}
        public String message {get;set;}

        public ErrorWrapper(Id accountId, String message) {
            this.accountId = accountId;
            this.message = message;
        }
    }

    public class ResultWrapper {
        public Account acc {get;set;}
        public Contact con {get;set;}
        public Case cse {get;set;}
        public Boolean hasError {get;set;}
        public String message {get;set;}

        public ResultWrapper(Account acc) {
            this.acc = acc;
            this.con = new Contact();
            this.cse = new Case();
            this.hasError = false;
            this.message = '';
        }
    }

    public static void sendEmailResult(List<ResultWrapper> results) {
        String body = 'IATA Code,Account,Contact,Contact Portal Status,Country,Case Number,Case Id,Message\n';

        for(ResultWrapper res : results) {
            body += (res.acc == null ? '' : res.acc.IATACode__c) + ',';
            body += (res.acc == null || String.isBlank(res.acc.Name) ? '' : res.acc.Name.escapeCSV()) + ','; 
            body += (res.con == null || String.isBlank(res.con.Name) ? '' : res.con.Name.escapeCSV()) + ',';
            body += (res.con == null || String.isBlank(res.con.User_Portal_Status__c) ? '' : res.con.User_Portal_Status__c.escapeCSV()) + ',';
            body += (res.acc == null || String.isBlank(res.acc.IATA_ISO_Country__r.Name) ? '' : res.acc.IATA_ISO_Country__r.Name.escapeCSV()) + ',';
            body += (res.cse == null ? '' : res.cse.CaseNumber) + ',';
            body += (res.cse == null ? '' : res.cse.Id) + ',';
            body += res.message + '\n';
        }

        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvReport = Blob.valueOf(body);
        csvAttc.setFileName('PCI Oscar mass creation report.csv');
        csvAttc.setBody(csvReport);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.subject = 'PCI Oscar mass creation report';
        
        //message.toAddresses = new List<String> {UserInfo.getUserEmail()};
        message.setTargetObjectId(UserInfo.getUserId());
        message.saveAsActivity = false; //must be false when sending mail to users.
        message.setPlainTextBody('PCI Oscar mass creation report - Check attachment with execution results');
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};
        Messaging.sendEmail(messages);

    }
    
}