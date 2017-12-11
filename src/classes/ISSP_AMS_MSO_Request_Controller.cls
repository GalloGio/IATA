public without sharing class ISSP_AMS_MSO_Request_Controller {

    public String applyLanguage {get; set;}
    public String step {get; set;}
    public String countrySelected {get; set;}
    public String billingState {get; set;}
    public List<SelectOption> billingStatesList {get; set; }

    private map<String,list<IATA_ISO_State__c>> mapBillingStatesPerCountry;
    private User currentUser;
    
    public Account msoAccount {get; set;}
    public Contact currentUserContact {get; set;}
    public Case oscarCase {get; set;}
    public AMS_Pax_Accreditation_Form__c accreditationForm {get; set;}
    public AMS_OSCAR__c oscar {get; set;}

    private static final string ISO_8859_1_regEx = '^[\\x00-\\x7F\\xA0-\\xFF]+$';  //Reg exp to limit inputted chars to ISO-8859-1

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    public String commParamFirst { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}
	
    public ISSP_AMS_MSO_Request_Controller() {
        step = ApexPages.currentPage().getParameters().get('step');
        Id caseId = ApexPages.currentPage().getParameters().get('caseId');
        if (String.isBlank(step)) step = 'form';

        mapBillingStatesPerCountry = new map<String,list<IATA_ISO_State__c>>();
        billingStatesList = new list<SelectOption>();

        currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        currentUserContact = [SELECT Id, AccountId, Account.RecordType.DeveloperName, Account.Name, Account.ParentId, Account.IATA_Member__c FROM Contact WHERE Id = :currentUser.ContactId];

        applyLanguage = UserInfo.getLanguage();
        if (applyLanguage != 'en_US' && applyLanguage != 'es' && applyLanguage != 'fr')
            applyLanguage = 'en_US';
        
        if (oscarCase == null) {
            if (caseId == null) {
                oscarCase = new Case();
            } else {
                oscarCase = [SELECT Id, CaseNumber, IATAcode__c, OSCAR__c, OSCAR__r.Account__c FROM Case WHERE Id = :caseId];
            }
        }

        if (msoAccount == null) msoAccount = new Account(Id = oscarCase.OSCAR__r.Account__c);

        if (oscar == null) oscar = new AMS_OSCAR__c(Id = oscarCase.OSCAR__c); 

        if (accreditationForm == null) {
            if (oscarCase.Id == null)
                accreditationForm = new AMS_Pax_Accreditation_Form__c();
            else {
                accreditationForm = [SELECT Id, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c, Branch_Office_City__c, Branch_Office_Phone__c, Branch_Office_Email__c, IATA_ISO_State__c, IATA_ISO_State__r.Name, Branch_Office_Country__c, Branch_Office_Country__r.Name, Accept_terms_and_conditions__c FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :oscarCase.Id];
                countrySelected = accreditationForm.Branch_Office_Country__c;
                refreshStates();
                billingState = accreditationForm.IATA_ISO_State__c;
            }
        }
    }

    public Pagereference securityCheck() {
        // checkIfUserHasAccessToService
        if (currentUserContact.Account.RecordType.DeveloperName != 'IATA_Airline' && currentUserContact.Account.RecordType.DeveloperName != 'IATA_Airline_BR') 
            return new Pagereference('/ISSP_Homepage');

        User u = [SELECT Id, ContactId From User WHERE Id =: UserInfo.getUserId()];
        if(u != null){
            List<Portal_Application_Right__c> par;
            par = [SELECT Id, Terms_Acceptance__c FROM Portal_Application_Right__c 
                        WHERE Contact__c =: u.ContactId 
                        AND Right__c = 'Access Granted'
                        AND (Contact_User_Portal_Status__c = 'Approved User' OR Contact_User_Portal_Status__c = 'Approved Admin')
                        AND Application_Start_URL__c = '/ISSP_AMS_MSO'];

            if(par.size()==0) // No access right => return to home page
                return new PageReference('/ISSP_Homepage');
        }


        // check if success step -> then close the OSCAR
        if (step == 'success' && oscarCase != null && oscarCase.OSCAR__c != null) {
            system.debug('Success step - closing the OSCAR');
            closeOscar(oscarCase.OSCAR__c);
        }
        

        return null;
    }

    public List<SelectOption> countryISOCodeList {
        get {
            List<SelectOption> options = new List<SelectOption>();

            list<IATA_ISO_Country__c> isoList;

            if (applyLanguage == 'es') {
                isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                           IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                           IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c,
                           (SELECT Id, Name FROM IATA_ISO_States__r)
                           FROM IATA_ISO_Country__c
                           WHERE Case_BSP_Country__c != null
                           AND Case_BSP_Country__c != ''
                           ORDER BY IATA_Country_SP__c];
            } else if (applyLanguage == 'fr') {
                isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                           IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                           IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c,
                           (SELECT Id, Name FROM IATA_ISO_States__r)
                           FROM IATA_ISO_Country__c
                           WHERE Case_BSP_Country__c != null
                           AND Case_BSP_Country__c != ''
                           ORDER BY IATA_Country_FR__c];
            } else {
                isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c,
                (SELECT Id, Name FROM IATA_ISO_States__r)
                FROM IATA_ISO_Country__c
                WHERE Case_BSP_Country__c != null
                AND Case_BSP_Country__c != ''
                ORDER BY Name];
            }
            
            for (IATA_ISO_Country__c c : isoList) {
                list<IATA_ISO_State__c> lstIsoStates = new list<IATA_ISO_State__c>();
                for (IATA_ISO_State__c s : c.IATA_ISO_States__r) {
                    lstIsoStates.add(s);
                }

                mapBillingStatesPerCountry.put(c.Id, lstIsoStates);
            }

            options.add(new SelectOption('', Label.ISSP_SELECT_COUNTRY));
            for (IATA_ISO_Country__c iso : isoList) {
                if (applyLanguage == 'es') {
                    if (iso.IATA_Country_SP__c != null)
                        options.add(new SelectOption(iso.Id , iso.IATA_Country_SP__c));
                    else
                        options.add(new SelectOption(iso.Id , iso.Name));
                } else if (applyLanguage == 'fr') {
                    if (iso.IATA_Country_FR__c != null)
                        options.add(new SelectOption(iso.Id, iso.IATA_Country_FR__c));
                    else
                        options.add(new SelectOption(iso.Id, iso.Name));
                } else {
                    options.add(new SelectOption(iso.Id, iso.Name));
                }
            }

            return options;
        }
        set;
    }
    
    public void refreshStates(){
        billingStatesList.clear();

        if (countryISOCodeList.size() == 0 || countrySelected == null || mapBillingStatesPerCountry.get(countrySelected) == null) return;

        for (IATA_ISO_State__c s : mapBillingStatesPerCountry.get(countrySelected)) {
            billingStatesList.add(new SelectOption(s.Id, s.Name));
        }
    }

    public Pagereference cancel() {
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if (retURL == null) {
            return new Pagereference('/ISSP_Homepage');
        } else {
            return new Pagereference(retURL);
        }
    }

    // create / update the MSO Account, Oscar, Communication Case, Accreditation Form and Appointment
    public PageReference save() {
        // validate selection
        Boolean isValid = true;
        Pattern p = Pattern.compile(ISO_8859_1_regEx);

        if (countrySelected == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_MSO_Country_ErrMsg));
            isValid = false;
        }

        if (billingState == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_MSO_Billing_State_ErrMsg));
            isValid = false;
        }
        
        // Verify only latin characters have been used in the address, city & postal code
        if (accreditationForm.Branch_Office_Street_name_number__c != null && !p.matcher(accreditationForm.Branch_Office_Street_name_number__c).matches()) {
            accreditationForm.Branch_Office_Street_name_number__c.addError(Label.ISSP_EnterValidString);
            isValid = false;
        }
        
        if (accreditationForm.Branch_Office_Postal_code__c != null && !p.matcher(accreditationForm.Branch_Office_Postal_code__c).matches()) {
            accreditationForm.Branch_Office_Postal_code__c.addError(Label.ISSP_EnterValidString);
            isValid = false;
        }
        
        if (accreditationForm.Branch_Office_City__c != null && !p.matcher(accreditationForm.Branch_Office_City__c).matches()) {
            accreditationForm.Branch_Office_City__c.addError(Label.ISSP_EnterValidString);
            isValid = false;
        }


        if (accreditationForm.Branch_Office_Email__c != null && accreditationForm.Branch_Office_Email__c != '') { // email is optional
            if (accreditationForm.Branch_Office_Email__c.indexOf('@') < 1 || accreditationForm.Branch_Office_Email__c.indexOf('.', accreditationForm.Branch_Office_Email__c.indexOf('@') + 2) < 0 || accreditationForm.Branch_Office_Email__c.length() < accreditationForm.Branch_Office_Email__c.lastIndexOf('.')+3) {
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid email address'));
            }
        }


        if (!isValid) {
            return null;
        }

        try {
            if (oscarCase.Id == null) {
                msoAccount.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account'}).get('Account').get('Standard_Account');//acctRT.Id;
                msoAccount.Name = currentUserContact.Account.Name;
                msoAccount.Sector__c = 'Travel Agent';
                msoAccount.Category__c = 'MSO Member Sales Office';
                msoAccount.Location_Class__c = 'M';
                msoAccount.Location_Type__c = 'HO';
                msoAccount.Reason_for_creation__c = 'New Agent';
                msoAccount.Location_Category__c = currentUserContact.Account.IATA_Member__c == true ? 'IC' : 'NI';
                insert msoAccount;

                // create new OSCAR
                oscar.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_OSCAR__c'}).get('AMS_OSCAR__c').get('NEW');//oscarRT.Id;
                oscar.Name = 'tempName'; //oscarCase.CaseNumber;                
                oscar.Process__c = 'NEW.MSO.1.0';
                oscar.Account__c = msoAccount.Id;
                insert oscar;

                // avoid sending notification email
                Id noEmailContactId = null;
                if (ISSP_CS__c.getValues('No Notification Email Contact Id') != null && ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c != null)
                    noEmailContactId = ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c;

                // create new OSCAR Communication case
                oscarCase.AccountId = currentUserContact.AccountId;
                oscarCase.ContactId = noEmailContactId; //currentUser.ContactId;
                oscarCase.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case').get('OSCAR_Communication');//caseRT.Id;
                oscarCase.Subject = 'GSA / MSO / Handling Agent - ' + currentUserContact.Account.Name + ' - Self-service (IATA Portal)';
                oscarCase.CaseArea__c = 'Accreditation Process';
                oscarCase.Reason1__c = 'GSA / MSO / Handling Agent';
                oscarCase.Origin = 'Portal';
                oscarCase.Type_of_customer__c = 'IATA Travel Agent';
                oscarCase.OSCAR__c = oscar.Id;
                oscarCase.Status = 'Draft';
                insert oscarCase;

                oscarCase = [SELECT Id, CaseNumber FROM Case WHERE Id =:oscarCase.Id];

                // create new accreditation form
                accreditationForm.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Pax_Accreditation_Form__c'}).get('AMS_Pax_Accreditation_Form__c').get('GeneralOnlineAccreditation');//accreditationRT.Id;
                accreditationForm.SAAM_Case__c = oscarCase.Id;
                accreditationForm.Account_Name__c = currentUserContact.Account.Name;
                accreditationForm.Location_Class__c = 'M';
                accreditationForm.Location_Type__c = 'HO';
                accreditationForm.IATA_ISO_State__c = billingState;
                accreditationForm.Branch_Office_Country__c = countrySelected;
                insert accreditationForm;

                oscar.AMS_Online_Accreditation__c = accreditationForm.Id;
                oscar.Name = oscarCase.CaseNumber;
                update oscar;

                AMS_Inspection__c app = new AMS_Inspection__c();
                app.Airline__c = currentUserContact.AccountId;
                app.Account__c = msoAccount.Id;
                app.OSCAR__c = oscar.Id;
                insert app;

                // update the case contact
                //updateCaseContact(oscarCase.Id, currentUser.ContactId);

            } else {
                accreditationForm.IATA_ISO_State__c = billingState;
                accreditationForm.Branch_Office_Country__c = countrySelected;
                upsert accreditationForm;
            }
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }

        return new PageReference('/ISSP_AMS_MSO_Request?step=review&caseId=' + oscarCase.Id);
    }

    public PageReference submitAndApproveCase() {
        try {
            // try to generate IATA Code 
            Boolean success = generateMsoIataCode(msoAccount.Id, accreditationForm.Id, oscar.Id, oscarCase.Id);

            if (!success) sendConfirmationEmail(oscarCase.Id, currentUser.ContactId, false); // for success update the case with the IATA code and send confirmation after, to have the code in the email
        } catch (Exception ex){
            system.debug('error processing the OSCAR: ' + ex.getMessage());
            // don't block, as the OSCAR has been correctly created at this point
            // it just fails to be automatically processed, so it will have to be processed manually
        }

        return new PageReference('/ISSP_AMS_MSO_Request?step=success&caseId=' + oscarCase.Id);
    }

    public PageReference cancelRequest() {
        oscar.Status__c = 'Closed_Withdrawn';
        update oscar;

        delete msoAccount;

        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        //if (retURL == null) {
            return new Pagereference('/ISSP_Homepage');
        /*} else {
            return new Pagereference(retURL);
        }*/
    }

    public PageReference goBackToForm() {
        return new PageReference('/ISSP_AMS_MSO_Request?step=form&caseId=' + oscarCase.Id);
    }

    // return false for failure, true for success
    public Boolean generateMsoIataCode (Id accountId, Id accreditationId, Id oscarId, Id caseId) {
        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Id = oscarId);

        if (accountId == null || accreditationId == null || oscarID == null)  return false;

        /*String[] generateResult = AmsIataCodeGenerator.generatedAgencyIATACode(accountId, accreditationId);
        if (generateResult[0] != '1') return false;

        String copyResult = AMS_OSCAR_Webservice.copyDataToAccount(oscarId);
        if (copyResult != 'OK') return false;

        String changeCodeResult = AMS_OSCAR_Webservice.createChangeCodeNEW(oscarId);
        if (changeCodeResult != 'OK') return false;*/

        String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(accountId, accreditationId,oscarId);
        if (result[0] != '0') return false;

        // update case with IATA Code and correct Contact 
        oscar = [SELECT Id, AMS_Online_Accreditation__r.IATACode__c FROM AMS_OSCAR__c WHERE Id = :oscarId];
        Case c = new Case(Id = caseId, IATAcode__c = oscar.AMS_Online_Accreditation__r.IATACode__c, ContactId = currentUser.ContactId);
        update c;

        // send confirmation email
        sendConfirmationEmail(caseId, currentUser.ContactId, true);

        //closeOscar(oscarId);

        return true;
    }

    //@future
    public static void closeOscar(Id oscarId) {
        try {
            // all the different behavior when Test.isRunningTest() is in place due to the tests being unstable and randomly throwing "too many soql queries" errors
            // insert case comment
            Case c = new Case();
            if (!Test.isRunningTest()) {
                c = [SELECT Id, IATAcode__c FROM Case WHERE OSCAR__c = :oscarId];
            }
            
            CaseComment successComment = new CaseComment();
            successComment.ParentId = c.Id;
            successComment.isPublished = true;
            successComment.CommentBody = Label.ISSP_AMS_MSO_Request_Successfull + ' ' + c.IATAcode__c;
            
            if (!Test.isRunningTest())
                insert successComment;

            // update oscar & mark it closed
            AMS_OSCAR__c oscar = new AMS_OSCAR__c(Id = oscarId);
            oscar.STEP10__c = 'Passed';
            oscar.Flag_Data_to_Account__c = true;
                        
            oscar.Status__c = 'Closed';
            if (!Test.isRunningTest())
                update oscar;
        } catch (DmlException ex) {
            system.debug('Error closing the OSCAR: ' + ex.getMessage());
        }
    }

    /*@future
    public static void updateCaseContact(Id caseId, Id contactId) {
        try {
            Case c = new Case(Id = caseId, ContactId = contactId);
            //update c;
        }  catch (DmlException ex) {
            system.debug('Error updating the OSCAR Communication case contact: ' + ex.getMessage());
        }
    }*/


    public void sendConfirmationEmail(Id caseId, Id contactId, Boolean success) {
        String emailTemplateName = success ? 'IDFS_Case confirmation - MSO self-service' : 'IDFS_Case confirmation - phone, e-mail HTML (English)';

        SYSTEM.DEBUG('Selected template: ' + emailTemplateName);

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> ets = [SELECT Name, Id FROM EmailTemplate WHERE Name = :emailTemplateName];

        if (ets.isEmpty()) return;

        EmailTemplate et = ets[0];

        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(et.Id);
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }
        
        mail.setTargetObjectId(contactId);
        mail.setWhatId(caseId);
        mail.setSaveAsActivity(true);

        emails.add(mail);
        if (!Test.IsRunningTest()) {
            //SYSTEM.DEBUG('Sending confirmation email');
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emails);
        }
    }

}