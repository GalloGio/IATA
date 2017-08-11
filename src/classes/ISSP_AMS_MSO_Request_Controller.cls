public without sharing class ISSP_AMS_MSO_Request_Controller {

    public String applyLanguage {get; set;}
    public String step {get; set;}
    public String countrySelected {get; set;}
    public String billingState {get; set;}
    public String legalStatus {get; set;}
    public List<SelectOption> billingStatesList {get; set; }

    private map<String,list<IATA_ISO_State__c>> mapBillingStatesPerCountry;
    private User currentUser;
    
    public Account msoAccount {get; set;}
    public Account airlineAccount {get; set;}
    public Case oscarCase {get; set;}
    public AMS_Pax_Accreditation_Form__c accreditationForm {get; set;}

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
        Contact currentUserContact = [SELECT Id, AccountId FROM Contact WHERE Id = :currentUser.ContactId];
        airlineAccount = [SELECT Id, ParentId, RecordType.DeveloperName, Name, Airline_designator__c FROM Account WHERE Id = :currentUserContact.AccountId];
        

        if (msoAccount == null) msoAccount = new Account();

        if (caseId == null) {
            oscarCase = new Case();
        } else {
            oscarCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId];
        }

        if (accreditationForm == null) accreditationForm = new AMS_Pax_Accreditation_Form__c();
    }

    public Pagereference securityCheck() {
        if (airlineAccount.RecordType.DeveloperName != 'IATA_Airline' && airlineAccount.RecordType.DeveloperName != 'IATA_Airline_BR') 
            return new Pagereference('/ISSP_Homepage');
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

        if (countrySelected == null || mapBillingStatesPerCountry.get(countrySelected) == null) return;

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

    public Pagereference save() {
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

        if (!isValid) {
            return null;
        }


        AMS_OSCAR__c oscar = new AMS_OSCAR__c();


        try {
            // create new MSO account
            RecordType acctRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Standard_Account'  AND IsActive = true];
            msoAccount.RecordTypeId = acctRT.Id;
            msoAccount.Name = airlineAccount.Name;
            msoAccount.Sector__c = 'Travel Agent';
            msoAccount.Category__c = 'MSO Member Sales Office';
            msoAccount.Location_Class__c = 'M';
            msoAccount.Location_Type__c = 'HO';
            msoAccount.Reason_for_creation__c = 'New Agent';

            insert msoAccount;

            // create new OSCAR Communication case
            RecordType caseRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'OSCAR_Communication'  AND IsActive = true];
            oscarCase.AccountId = airlineAccount.Id;
            oscarCase.ContactId = currentUser.ContactId;
            oscarCase.RecordTypeId = caseRT.Id;
            oscarCase.Subject = 'New MSO - ' + airlineAccount.Name;
            oscarCase.CaseArea__c = 'Accreditation Process';
            oscarCase.Reason1__c = 'New MSO';
            oscarCase.Type_of_customer__c = 'IATA Travel Agent';
            insert oscarCase;

            oscarCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :oscarCase.Id];

            // create new accreditation form
            RecordType accreditationRT = [SELECT Id FROM RecordType WHERE SObjectType = 'AMS_Pax_Accreditation_Form__c' AND DeveloperName = 'GeneralOnlineAccreditation'  AND IsActive = true];
            accreditationForm.RecordTypeId = accreditationRT.Id;
            accreditationForm.SAAM_Case__c = oscarCase.Id;
            accreditationForm.Account_Name__c = airlineAccount.Name;
            accreditationForm.Location_Class__c = 'M';
            accreditationForm.Location_Type__c = 'HO';
            accreditationForm.IATA_ISO_State__c = billingState;
            accreditationForm.Branch_Office_Country__c = countrySelected;
            insert accreditationForm;

            // create new OSCAR
            RecordType oscarRT = [SELECT Id FROM RecordType WHERE SObjectType = 'AMS_OSCAR__c' AND DeveloperName = 'NEW'  AND IsActive = true];
            oscar.RecordTypeId = oscarRT.Id;
            oscar.Name = oscarCase.CaseNumber;
            oscar.AMS_Online_Accreditation__c = accreditationForm.Id;
            oscar.Account__c = msoAccount.Id;
            oscar.Process__c = 'NEW.MSO.1.0';
            insert oscar;

            oscarCase.OSCAR__c = oscar.Id;
            update oscarCase;

            // Create new appointment
            AMS_Inspection__c app = new AMS_Inspection__c();
            app.Airline__c = airlineAccount.Id;
            app.Account__c = msoAccount.Id;
            app.OSCAR__c = oscar.Id;
            insert app;

        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }

        try {
            // try to generate IATA Code 
            generateMsoIataCode(msoAccount.Id, accreditationForm.Id, oscar.Id);
        } catch (Exception ex){
            system.debug('error processing the OSCAR: ' + ex.getMessage());
            // don't block, as the OSCAR has been correctly created at this point
            // it just fails to be automatically processed, so it will have to be processed manually
        }

        return new PageReference('/ISSP_AMS_MSO_Request?step=success&caseId=' + oscarCase.Id);
    }

    public void generateMsoIataCode (Id accountId, Id accreditationId, Id oscarId) {
        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Id = oscarId);

        if (accountId == null || accreditationId == null || oscarID == null)  return;

        String[] generateResult = AmsIataCodeGenerator.generatedAgencyIATACode(accountId, accreditationId);
        if (generateResult[0] != '1') return;

        oscar.STEP10__c = 'Passed';

        String copyResult = AMS_OSCAR_Webservice.copyDataToAccount(oscarId);
        if (copyResult != 'OK') return;

        oscar.Flag_Data_to_Account__c = true;

        String changeCodeResult = AMS_OSCAR_Webservice.createChangeCodeNEW(oscarId);
        if (changeCodeResult != 'OK') return;

        update oscar;

        closeOscar(oscarId);
    }

    @future
    public static void closeOscar(Id oscarId) {
        try {
            AMS_OSCAR__c oscar = new AMS_OSCAR__c(Id = oscarId, Status__c = 'Closed');
            update oscar;
        } catch (DmlException ex) {
            system.debug('Error closing the OSCAR: ' + ex.getMessage());
        }
    }

}