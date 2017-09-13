public without sharing class ISSP_AMS_MSO_Update_Controller {

    public static final String ACTION_CORRECTION  = 'correction';
    public static final String ACTION_TERMINATION = 'termination';


	public String action {get; set;}
    public String step {get; set;}
    public String applyLanguage {get; set;}

    private User currentUser;
    
    public Account msoAccount {get; set;}
    public Contact currentUserContact {get; set;}
    public Case oscarCase {get; set;}
    public AMS_Pax_Accreditation_Form__c accreditationForm {get; set;}
    public AMS_OSCAR__c oscar {get; set;}


    public String countrySelected {get; set;}
    public String billingState {get; set;}
    public List<SelectOption> countryISOCodeList {get;set;}
    public List<SelectOption> billingStatesList {get; set; }

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    public String commParamFirst { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}


    public ISSP_AMS_MSO_Update_Controller() {
        action = ApexPages.currentPage().getParameters().get('action');
        Id caseId = ApexPages.currentPage().getParameters().get('caseId');
        Id msoId = ApexPages.currentPage().getParameters().get('msoId');

        step = ApexPages.currentPage().getParameters().get('step');
        if (step == null) step = 'form';
        
        currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        currentUserContact = [SELECT Id, AccountId, Account.Name, Account.RecordType.DeveloperName FROM Contact WHERE Id = :currentUser.ContactId];

        applyLanguage = UserInfo.getLanguage();
        if (applyLanguage != 'en_US' && applyLanguage != 'es' && applyLanguage != 'fr')
            applyLanguage = 'en_US';

        list<Account> lstAcc = new list<Account>([SELECT Id, BillingStreet, BillingPostalCode, BillingCity, IATACode__c, IATA_ISO_Country__c, Iso_State__c, Email__c, Phone, Company_Type__c FROM Account WHERE Id = :msoId]);

        if (String.isBlank(action) || String.isBlank(msoId) || lstAcc.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_MSO_Invalid_Request));
        } else {
        
            msoAccount = lstAcc[0];
            if (caseId == null) {
                oscarCase = new Case();
            } else {
                oscarCase = [SELECT Id, CaseNumber, IATAcode__c, OSCAR__c, OSCAR__r.Account__c FROM Case WHERE Id = :caseId];
            }
            
            oscar = new AMS_OSCAR__c(Id = oscarCase.OSCAR__c); 

            if (action == ACTION_CORRECTION) {
                if (oscarCase.Id == null)
                    accreditationForm = new AMS_Pax_Accreditation_Form__c(Branch_Office_Street_name_number__c = msoAccount.BillingStreet, Branch_Office_Postal_code__c = msoAccount.BillingPostalCode, Branch_Office_City__c = msoAccount.BillingCity, Branch_Office_Email__c = msoAccount.Email__c, Branch_Office_Phone__c = msoAccount.Phone, IATA_ISO_State__c = msoAccount.Iso_State__c, Branch_Office_Country__c = msoAccount.IATA_ISO_Country__c, IATACode__c = msoAccount.IATACode__c);
                else {
                    accreditationForm = [SELECT Id, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c, Branch_Office_City__c, Branch_Office_Phone__c, Branch_Office_Email__c, IATACode__c, IATA_ISO_State__c, IATA_ISO_State__r.Name, Branch_Office_Country__c, Branch_Office_Country__r.Name FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :oscarCase.Id];
                }
                
                refreshStates();
                countrySelected = accreditationForm.Branch_Office_Country__c;
                billingState = accreditationForm.IATA_ISO_State__c;
            }

        }
    }
    
    public void refreshStates(){
        list<IATA_ISO_Country__c> isoList = [SELECT Name, Id, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                IATA_Country_FR__c, IATA_Country_SP__c, IATA_Country_ZH__c,
                (SELECT Id, Name FROM IATA_ISO_States__r ORDER BY Name)
                FROM IATA_ISO_Country__c
                WHERE Id = :msoAccount.IATA_ISO_Country__c
                ORDER BY Name];
        
        IATA_ISO_Country__c iso = isoList[0];    
            
        billingStatesList = new List<SelectOption>();
        for (IATA_ISO_State__c s : iso.IATA_ISO_States__r) {
                billingStatesList.add(new SelectOption(s.Id, s.Name));
            }

        countryISOCodeList = new List<SelectOption>();

        if (applyLanguage == 'es') {
            if (iso.IATA_Country_SP__c != null)
                countryISOCodeList.add(new SelectOption(iso.Id , iso.IATA_Country_SP__c));
            else
                countryISOCodeList.add(new SelectOption(iso.Id , iso.Name));
        } else if (applyLanguage == 'fr') {
            if (iso.IATA_Country_FR__c != null)
                countryISOCodeList.add(new SelectOption(iso.Id, iso.IATA_Country_FR__c));
            else
                countryISOCodeList.add(new SelectOption(iso.Id, iso.Name));
        } else {
            countryISOCodeList.add(new SelectOption(iso.Id, iso.Name));
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

        return null;
    }

    public Pagereference cancel() {
        return new Pagereference('/ISSP_AMS_MSO');
    }

    // create / update the MSO Account, Oscar, Communication Case, Accreditation Form and Appointment
    public PageReference save() {
        // validate selection
        Boolean isValid = true;

        if (countrySelected == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_MSO_Country_ErrMsg));
            isValid = false;
        }

        if (billingState == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_MSO_Billing_State_ErrMsg));
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
                // create new OSCAR
                oscar.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_OSCAR__c'}).get('AMS_OSCAR__c').get('CORRECTION');//oscarRT.Id;
                oscar.Name = 'tempName'; //oscarCase.CaseNumber;                
                oscar.Process__c = AMS_Utils.COR;
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
                oscarCase.Subject = 'Corrections - ' + currentUserContact.Account.Name;
                oscarCase.CaseArea__c = 'Accreditation Process';
                oscarCase.Reason1__c = 'Corrections';
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


                oscarCase.ContactId = currentUser.ContactId;
                update oscarCase;


            } else {
                accreditationForm.IATA_ISO_State__c = billingState;
                accreditationForm.Branch_Office_Country__c = countrySelected;
                upsert accreditationForm;
            }
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }

        return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=review&caseId=' + oscarCase.Id);
    }

    public PageReference terminate() {
        try {
                // create new OSCAR
                oscar.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_OSCAR__c'}).get('AMS_OSCAR__c').get('VOLUNTARY_RELINQUISHMENT');
                oscar.Name = 'tempName'; 
                oscar.Process__c = AMS_Utils.VOLRELINQUISH_CA;
                oscar.Account__c = msoAccount.Id;
                insert oscar;

                // avoid sending notification email
                Id noEmailContactId = null;
                if (ISSP_CS__c.getValues('No Notification Email Contact Id') != null && ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c != null)
                    noEmailContactId = ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c;

                // create new OSCAR Communication case
                oscarCase.AccountId = currentUserContact.AccountId;
                oscarCase.ContactId = noEmailContactId; //currentUser.ContactId;
                oscarCase.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case').get('OSCAR_Communication');
                oscarCase.Subject = 'CLO - Closure - ' + currentUserContact.Account.Name;
                oscarCase.CaseArea__c = 'Accreditation Process';
                oscarCase.Reason1__c = 'CLO - Closure';
                oscarCase.Origin = 'Portal';
                oscarCase.Type_of_customer__c = 'IATA Travel Agent';
                oscarCase.OSCAR__c = oscar.Id;
                oscarCase.Status = 'Draft';
                insert oscarCase;

                // AUTOMATICALLY APPROVE & TERMINATE
                // pass sanity check
                oscar.STEP6__c = AMS_Utils.PASSED;
                oscar.Change_effective_as_of__c = Date.today();
                update oscar;

                oscar.STEP31__c = AMS_Utils.PASSED;
                update oscar;


                closeOscar(oscar.Id);


                // POST SUCCESS COMMENT HERE

        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }

        return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_TERMINATION + '&msoId=' + msoAccount.Id + '&step=success&caseId=' + oscarCase.Id);
    }

    public PageReference submitAndApproveCase() {
        try {
            oscar.AMS_Correction_change_code__c = 'COR';
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;

            closeOscar(oscar.Id);

            // POST SUCCESS COMMENT HERE

        } catch (Exception ex){
            ApexPages.addMessages(ex);
            system.debug('error processing the OSCAR: ' + ex.getMessage());
            return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=pending&caseId=' + oscarCase.Id);
            // don't block, as the OSCAR has been correctly created at this point
            // it just fails to be automatically processed, so it will have to be processed manually
        }

        return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=success&caseId=' + oscarCase.Id);
    }

    public PageReference cancelRequest() {
        oscar.Status__c = 'Closed_Withdrawn';
        update oscar;

        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        //if (retURL == null) {
            return new Pagereference('/ISSP_AMS_MSO');
        /*} else {
            return new Pagereference(retURL);
        }*/
    }

    public PageReference goBackToForm() {
        return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=form&caseId=' + oscarCase.Id);
    }

    @future
    public static void closeOscar(Id oscarId) {
        try {

            AMS_OSCAR__c oscar = new AMS_OSCAR__c(Id = oscarId);
            //update oscar;
            
            oscar.Status__c = 'Closed';
            update oscar;
        } catch (DmlException ex) {
            system.debug('Error closing the OSCAR: ' + ex.getMessage());
        }
    }

}