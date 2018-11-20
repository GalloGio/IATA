/**
    Controller class used in many ISS portal pages to handle the process for 
    Airline Participation Joining Applications and Change Requests
**/
public without sharing class ISSP_APProcess {

    private static String RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('IDFS Airline Participation Process').RecordTypeId;
    @TestVisible private string vCaseId;
    private Id vHQAccountId;
    private Id vGSSAAccountId;
    private Id vAccountConcernedId;
    private Id caseId;
    private Id contactId;
    public string cassairlineid {get;set;}
    public Case newCase {get;set;}
    public Account hqAccount {get;set;}
    public Contact con {get;set;}
    public AP_Process_Form__c newForm {get;set;}
    public AP_Country_Requierment__c countryRequirement {get;set;}
    public IATA_ISO_Country__c isocountry{get;set;}
    public boolean isNewCase {get;set;}
    public string stepNumber {get;set;}
    public string APprocess {get;set;}
    public boolean allfieldsfilled {get;set;}
    public boolean isMandatory {get;set;}
    public boolean isBSP {get;set;}
    public boolean isCASS {get;set;}
    public boolean isStep1 {get;set;}
    public boolean isStep2 {get;set;}
    public boolean isStep3 {get;set;}
    public boolean isStep4 {get;set;}
    public boolean isFinalStep {get;set;}
    public boolean isGSSAUser {get;set;} //AS - R03 SP03
    public boolean countryRequirementFound {get;set;}
    public boolean dupeDraftExists{get;set;}
    public string BankMandateUrl {get;set;}
  	public string strOperationType { get; set; } //BSP, CASS Import or CASS Export from Step 1 selection
    public string strAreaType{ get; set; } //AP Joining or Change
    public string strChangeType{ get; set; } //AP Joining or Change
    public string strLoB { get; set; } //Line of Business, BSP or CASS
    public string dupLoB { get; set; } //INC300017

    public string strParentMembershipStatus {get; set;}
    public string strParentLegalName {get; set;}
    public string strParentTradeName {get; set;}
    public string strParentDesignator {get; set;}
    public string strParentIATACode {get; set;}
    public string strParentBillingStreet {get; set;}
    public string strParentBillingCode {get; set;}
    public string strParentBillingCity {get; set;}
    public string strParentBillingState {get; set;}
    public string strParentBillingCountry {get; set;}
    public string fileName {get;set;}
    public string strCountryspecURL {get;set;}
    public string strCountryspecLinkLabel {get;set;}
    public string strCountryspecURL2 {get;set;}
    public string strCountryspecLinkLabel2 {get;set;}
    public string strCountryspecURL3 {get;set;}
    public string strCountryspecLinkLabel3 {get;set;}

    public string strGSSAName {get;set;}
    public string strGSSAAddress {get;set;}
    public string gssaCountryISOCode {get;set;}
    public string category {get;set;}

    public List <AP_Country_specs__c> urlList {get; set;}
    public transient Blob fileBody {get;set;}

    List<Case> dupeDraft;
    public List<SelectOption> changeItems;

    public String apCountry{get;set;}
    public String apCountryisocode{get;set;}
    public string bspLinkContact{get;set;}

    public List<citySelection> cityList{get;set;}//TF
    public List<citySelection> cityListWithValue{get;set;}//TF

    public String strOT{get;set;}
    public String strOperationTypeAux{get;set;}

    public List<GST_Information__c> list_GSTNumber{get;set;}
    public Boolean displayPopup{get;set;}
    public String editGSTNumberId{get;set;}
    public GST_Information__c newGSTInfo{get;set;}
    public Boolean allGSTFieldsFilled{get;set;}
    public String optInOut {get;set;}
    public List<Services_Rendered__c> servicesRendered {get;set;}
    public List<SelectOption> countries {get;set;}
    public String selectedCountries {get;set;}
    public Boolean flagShowCountries {get;set;}
    public String pEffectiveDateStr {get;set;}
    public List<SelectOption> countriesOut {get;set;}
    public Boolean hasCountriesOut {get;set;}
    public List<SelectOption> countriesIn {get;set;}
    public Boolean hasCountriesIn {get;set;}
    public List<SelectOption> optInOutOptions {get;set;}
    public Integer airlineOptInDays {get;set;}
    public Integer airlineOptOutDays {get;set;}
    public Boolean isoCountryEligible {get;set;} //Variable to define if the isoCountry is EasyPay Eligible (used in VF Page)

    public Boolean getIsNewCountryProcess() {
        try {
            String value = ISSP_CS__c.getValues('ISSP_APProcess_New_Countries').Value__c;
            if (value=='Default') return true;
            return value.contains(apcountryisocode);
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    }
   
    public ISSP_APProcess(){
        //Set the Variables default values
        isNewCase = true;
        isBSP = false;
        isCASS = false;
        isStep1 = false;
        isStep2 = false;
        isStep3 = false;
        isFinalStep = false;
        dupeDraftExists = false;
        countryRequirementFound = false;
        allfieldsfilled = true;
        isMandatory = false;
        isGSSAUser = false; //AS R03-SP03
        displayPopup = false;
		flagShowCountries = false;
        isoCountryEligible = false;

        newForm = new AP_Process_Form__c();
        newCase = new Case();
        countryRequirement = new AP_Country_Requierment__c();

        list_GSTNumber = new List<GST_Information__c>();
        newGSTInfo = new GST_Information__c();
        allGSTFieldsFilled = false;

        countries = new List<SelectOption>();

        //Verify User Profile (AS R03-SP03)
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName.startsWith('ISS Portal GSA') ){  isGSSAUser= true; }

        //If controller called internally then get Account from URL param, else from account of portal user / contact
        vAccountConcernedId = ApexPages.currentPage().getParameters().get('vAccountId');
        contactId = Apexpages.currentPage().getParameters().get('vContactID');
        con = retrieveContact(contactId);

        if(vAccountConcernedId==null) {
            //Case has not been created at this stage, so need to get AL Account (can be HQ or BR) for logged in user
            popContact();

            newForm.Contact_Resp_Job_Title__c = con.Title;
            newForm.Contact_Resp_F_Name__c = con.FirstName;
            newForm.Contact_Resp_L_Name__c = con.LastName;
            newForm.Contact_Resp_Email__c = con.Email;
        }

        if(isGSSAUser) {
            vGSSAAccountId = con.AccountId;
            category = con.Account.Category__c;
        } else if (con.Account.Top_Parent__c == null) { //User is from HQ  Account
            vHQAccountId = con.AccountId;
        } else {
            vHQAccountId = con.Account.Top_Parent__c;
        }

        if(ApexPages.currentPage().getParameters().get('cdupetype') <> null)
            dupeDraftExists = true;

        if (ApexPages.currentPage().getParameters().containsKey('isMandatory')) {
            isMandatory = true;
        } else {
            isMandatory = false;
        }

        if(ApexPages.currentPage().getParameters().containsKey('step'))
          	stepNumber = ApexPages.currentPage().getParameters().get('step');

        if(stepNumber == '1' || stepNumber == null) {
            isStep1= true;
        }

        if(ApexPages.currentPage().getParameters().containsKey('proc')) {
            APprocess = ApexPages.currentPage().getParameters().get('proc');
            if(APprocess=='chg' || APprocess=='bnk') {
                strAreaType = 'Airline Change';
                if(APprocess=='chg') {
                    strChangeType = 'Minor database changes';
                } else {
                    strChangeType = 'Bank Account Instructions';
                }
            } else {
                strAreaType = 'Airline Joining';
            }
        } else {
            strAreaType = 'Airline Joining';
        }

        if(ApexPages.currentPage().getParameters().containsKey('ctryreq'))
            if(ApexPages.currentPage().getParameters().get('ctryreq')=='false') {
                //Set the case to not new
                isNewCase = false;
                apCountry = ApexPages.currentPage().getParameters().get('country');
                strLOB = ApexPages.currentPage().getParameters().get('lob');
            }

        //Query case information and verify case characteristics
        if(ApexPages.currentPage().getParameters().containsKey('caseId')) {
            //Retrieve information linked to the case Id
            vCaseId = ApexPages.currentPage().getParameters().get('caseId');
            newCase = retrieveCase(vCaseId);

            if(newCase==null)
              	redirectToCasesList();

            if(newCase.IFAP_Country_ISO__c != null) {
                isocountry = fetchISOCountry(newCase.IFAP_Country_ISO__c);

                newForm.ANG_Enable_NewGen__c = (isocountry.ANG_Portal_Service__c != null);
            } else {
                newForm.ANG_Enable_NewGen__c = false;
            }

            //if(newCase.Status != 'Draft'){
            //    redirectToCasesList();
            //}

            isNewCase = false;
            strOperationType = newCase.Verification__c;
            strOperationTypeAux = strOperationType;
            strAreaType = newCase.CaseArea__c;
            strChangeType = newCase.Reason1__c;

            //Need to get Id for Account for country of application concerned
            vAccountConcernedId = newCase.Account_Concerned__c;

            //and to get Id for HQ Account for branch office)
            if (newCase.Account_Concerned__r.Top_Parent__c == null) {
                vHQAccountId = newCase.Account_Concerned__c;
            } else {
                vHQAccountId = newCase.Account_Concerned__r.Top_Parent__c;
            }

            retrieveHQAccountDetails(vHQAccountId);

            if (isGSSAUser){  //For GSSA display Airline details
                strGSSAName = newCase.Account.Name;
                strGSSAAddress = newCase.Account.Billing_Address_formated__c;
            }

            getLoB(strOperationType); //Get the line of business - BSP or CASS

            apcountryisocode = newCase.IFAP_Country_ISO__c;
            SYSTEM.DEBUG('INIT - LOB: ' + strLoB);
            SYSTEM.DEBUG('INIT - Country ISO Code: ' + apcountryisocode);

            retrieveCountryRequirements(apcountryisocode, strLoB );
            apCountry = countryRequirement.Name;  //Used for country display on Country Reqs pages

            if(apcountryisocode == 'CN') {
                bspLinkContact='ASD';
            } else {
                bspLinkContact='BSPLink';
            }

            //Verify to which step the user should go
            //and retrieve information linked to the step
            if(stepNumber == '1'){
                isStep1= true;
            }else if(stepNumber == '2'){
                isStep2= true;
            }else if(stepNumber == '3'){
                isStep3= true;
                retrieveAPProcessForm();

                if(newForm.Id==null) {
                    newForm.Airline_Local_address_in_the_BSP_Country__c = newCase.BSPCountry__c;
                }

                getCityData();//TF
                newForm.Submitted_to_IATA__c = FALSE;

                // TF - Type of Change Requested
        		typeOfChangeRequested = new List<String>();
        		if (newForm.Type_of_Change_Requested__c != null){
          			for (String thisValue : newForm.Type_of_Change_Requested__c.split(';')){
            			typeOfChangeRequested.add(thisValue);
          			}
        		}

            }else if(stepNumber == '4'){
                system.debug('STEP 4 - 1');
                isStep4 = true;
                retrieveAPProcessForm();
                system.debug('STEP 4 - 2');
                newForm.Submitted_to_IATA__c = FALSE;

                // TF - Type of Change Requested
        		typeOfChangeRequested = new List<String>();
        		if (newForm.Type_of_Change_Requested__c != null){
          			for (String thisValue : newForm.Type_of_Change_Requested__c.split(';')){
            			typeOfChangeRequested.add(thisValue);
          			}
        		}

                //TF
                String nameString = apcountryisocode + '-' + strLOB + '%';
                system.debug('STEP 4 - 3');
                urlList = [SELECT Id, Name, Download_URL__c, Link_label__c FROM AP_Country_specs__c
                           WHERE Name LIKE :nameString ORDER BY Name];
                system.debug('STEP 4 - 4');

                //Get country specific bank mandate URL; else get default from custom settings
                AP_Country_specs__c apcbm = AP_Country_specs__c.getValues(apcountryisocode + '-BankMandate');
                if(apcbm!=null) {
                    BankMandateUrl = apcbm.Download_URL__c;
                } else {
                    AP_Country_specs__c apcdef = AP_Country_specs__c.getValues('DEFAULT-BankMandate');
                    BankMandateUrl = apcdef.Download_URL__c;
                }

                //Test if BSP / CASS compulsory fields are filled
                if (isBSP && strAreaType=='Airline Joining') {
                    if(ISSP_AP_FieldLists.bsp_MandatoryFieldsbyCountry.get(apcountryisocode) != null) {
                        Map<String, String> extraMandatoryFields = ISSP_AP_FieldLists.bsp_MandatoryFieldsbyCountry.get(apcountryisocode);
                        for(String tmp : extraMandatoryFields.keySet()) {
                            ISSP_AP_fieldLists.bspMandatoryFields.put(tmp, extraMandatoryFields.get(tmp));
                        }
                    }

                    for (String fldLabel : ISSP_AP_fieldLists.bspMandatoryFields.keySet())
                    {
                        if (newForm.get(fldLabel)==null) {
                            allfieldsfilled = false;
                            break;
                        }
                    }

                    // Patch to make mandatory some fields dependent from Participate_in_any_Commission_Control__c
                    if (newForm.Participate_in_any_Commission_Control__c=='Yes') {
                        for (String fieldName: getMandatoryFieldsForCommission()) {
                            if (newForm.get(fieldName) == null) {
                                allfieldsfilled = false;
                                break;
                            }
                        }
                    }

                    // either one or the other field is mandatory
                    if (newForm.VAT_Tax_number_in_your_home_country__c==null && newForm.BSP_Country_VAT_Tax_number__c==null ) {
                        allfieldsfilled = false;
                    }
                    
                } else if(isCASS && strAreaType=='Airline Joining') {  //Test CASS mandatory fields
                    if(ISSP_AP_FieldLists.cass_MandatoryFieldsbyCountry.get(apcountryisocode) != null) {
                        Map<String, String> extraMandatoryFields = ISSP_AP_FieldLists.cass_MandatoryFieldsbyCountry.get(apcountryisocode);
                        for(String tmp : extraMandatoryFields.keySet()) {
                            ISSP_AP_fieldLists.cassMandatoryFields.put(tmp, extraMandatoryFields.get(tmp));
                        }
                    }
                    if (this.countryRequirement.Local_VAT_Mandatory__c=='YES') {
                        ISSP_AP_fieldLists.cassMandatoryFields.putAll(ISSP_AP_fieldLists.cassLocalVATMandatoryFields);
                    } else {
                        ISSP_AP_fieldLists.cassMandatoryFields.putAll(ISSP_AP_fieldLists.cassLocalVATNOTMandatoryFields);
                    }
                    for (String fldLabel : ISSP_AP_fieldLists.cassMandatoryFields.keySet())
                    {
                        System.Debug('CASS FldLabel: '+ fldLabel);
                        if (newForm.get(fldLabel)==null) {
                            System.Debug('CASS FldLabel FAIL');
                            allfieldsfilled = false;
                            break;
                        }
                    }
                } else if(strAreaType=='Airline Change' && strChangeType=='Minor database changes') {
                    if(newForm.Type_of_Change_Requested__c != null) {
                        if(newForm.Type_of_Change_Requested__c.contains('Master')) { //Need to include MasterTable mandatory fields
                          	Map<String, String> masterTableMandatoryFields = ISSP_AP_FieldLists.changeMasterTableMandatoryFields;
                            	for(String tmp : masterTableMandatoryFields.keySet()) {
                                	ISSP_AP_fieldLists.changeMandatoryFields.put(tmp, masterTableMandatoryFields.get(tmp));
                            	}
                          }
                    }
                    for (String fldLabel : ISSP_AP_fieldLists.changeMandatoryFields.keySet()) {
                        System.Debug('Change FldLabel: '+ fldLabel);
                        if (newForm.get(fldLabel)==null) {
                            allfieldsfilled = false;
                            break;
                        }
                    }
                } else if(strAreaType=='Airline Change' && strChangeType=='Bank Account Instructions') {
                   	for (String fldLabel : ISSP_AP_fieldLists.changeBankMandatoryFields.keySet()) {
                        System.Debug('Change FldLabel: '+ fldLabel);
                        if (newForm.get(fldLabel)==null) {
                            allfieldsfilled = false;
                            break;
                        }
                    }
                } else {
                    allfieldsfilled = true;
                }
            }else if(stepNumber == 'Final'){
                isFinalStep = true;
                retrieveCase(vCaseId);
            } else {
                stepNumber = '1';
                isStep1 = true;
            }
        }

        populateCountriesMap();
        poupulateOptInOutOptions();
    }

    private void popContact(){
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        con = DAL_ISSP.getContact(user.ContactId);
    }

    public void retrieveAPProcessForm(){
        List <AP_Process_Form__c> newForms = [
            SELECT Id, Case__c, Type__c, Type_of_participation_desired__c, Airline_Local_address_in_the_BSP_Country__c,
            Desired_commencment_date__c, Accept_terms_and_conditions__c, Accept_payment_Cards_for_BSP_ticket__c , Airline__c,
            Airline_HO__c, Airline_trade_name__c, American_Express_Merchant_Number__c, American_Express_Name_of_Acquirer__c,
            BSP_Country_VAT_Tax_number__c, BSPLink_ASD_China_Contact_Email__c, BSPLink_ASD_China_Contact__c, BSPLink_ASD_China_Contact_L_Name__c,
            BSPLink_ASD_China_Contact_Phone__c, BSPLink_access_level_requested__c, BSP_Local_address__c, BSP_Local_City__c, BSP_Local_Zip_Code__c,
            Card_brand_accepted_for_BSP_ticket__c, Contact_Resp_Email__c, Contact_Resp_F_Name__c, Contact_Resp_L_Name__c,
            Contact_Resp_Phone__c, Diners_Merchant_Number__c, Fin_Adm_Contact_Address__c, Fin_Adm_Contact_City__c, Fin_Adm_Contact_Country__c,
            Fin_Adm_Contact_Email__c, Fin_Adm_Contact_F_Name__c, Fin_Adm_Contact_Job_Title__c, Fin_Adm_Contact_L_Name__c, Fin_Adm_Contact_Phone__c,
            Fin_Adm_Contact__c, Fin_Adm_Contact_Zip_Code__c, Flights_operated_in_the_BSP_country__c, Hot_files_delivery_format__c, IINET_account_number__c,
            Join_BSP_ECCB__c, Master_Card_Merchant_Number__c, Master_Card_Name_of_Acquirer__c, Online_carrier_in_the_BSP_country__c, Other_Card_brand_accepted_for_BSP_ticket__c,
            Participate_in_any_Commission_Control__c, Participate_in_any_Remit_scheme__c, Receive_HOT_files__c,
            VAT_Tax_number_in_your_home_country__c, Visa_merchant_number__c, Visa_Name_of_Acquirer_or_Processor__c, Diners_Name_of_Acquirer__c,
            Airline_wish_to_join_ICCS__c, Contact_Resp_Job_Title__c, Contact_Resp_Salutation__c, ETSP_Contractor_Name__c, ETSP_Contact_Address__c, ETSP_Contact_F_Name__c,
            ETSP_Contact_Job_Title__c, ETSP_Contact_L_Name__c, ETSP_Contact_Salutation__c, ETSP_Contact_Email__c, ETSP_Contact_Fax__c, ETSP_Contact_Phone__c,
            CASS_Operation__c, Airline_Invoice_Address__c, CASSLink_Contact_Email__c, CASSLink_Contact_Fax__c, CASSLink_Contact_F_Name__c, CASSLink_Contact_Job_Title__c,
            CASSLink_Contact_L_Name__c, CASSLink_Contact_Phone__c, CASSLink_Contact_Salutation__c,CASS_Ad_Hoc_Bulletins_Email_1__c,CASS_Ad_Hoc_Bulletins_Email_2__c,
            CASS_Corrections_Email_1__c, CASS_Corrections_Email_2__c, CASS_Corrections_Email_3__c, CASS_Corrections_Email_4__c, CASS_Defaults_Email_1__c, CASS_Defaults_Email_2__c,
            Airline_Billing_Data_File_Type__c, Billing_File_Emrgcy_Contact_Email__c, Billing_File_Emrgcy_Contact_F_Name__c, Billing_File_Emrgcy_Contact_Job_Title__c,
            Billing_File_Emrgcy_Contact_L_Name__c, Billing_File_Emrgcy_Contact_Salutation__c, HOT_File_Recipient_Email_1__c, HOT_File_Recipient_Email_2__c,
            HOT_File_Recipient_Email_3__c, HOT_File_Recipient_Email_4__c, Receive_XLS_Reports__c, PDF_Report_Delivery_Format__c, PDF_File_Recipient_Email_1__c, PDF_File_Recipient_Email_2__c,
            PDF_File_Recipient_Email_3__c, PDF_File_Recipient_Email_4__c, CASSLink_Extra_Existing_Users__c, CASSLink_User_1_System_Functions__c, CASSLink_User_2_System_Functions__c,
            CASSLink_User_3_System_Functions__c, CASSLink_Username_1__c, CASSLink_Username_2__c, CASSLink_Username_3__c, CASSLink_New_User_1_Salutation__c, CASSLink_New_User_2_Salutation__c,
            CASSLink_New_User_3_Salutation__c, CASSLink_New_User_1_F_Name__c, CASSLink_New_User_2_F_Name__c, CASSLink_New_User_3_F_Name__c, CASSLink_New_User_1_L_Name__c,
            CASSLink_New_User_2_L_Name__c, CASSLink_New_User_3_L_Name__c, CASSLink_New_User_1_Email__c, CASSLink_New_User_2_Email__c, CASSLink_New_User_3_Email__c,
            CASSLink_New_User_1_System_Functions__c, CASSLink_New_User_2_System_Functions__c, CASSLink_New_User_3_System_Functions__c, CASSLink_Extra_New_Users__c,
            Pay_Commission_to_agents__c, Commission_Rate__c, Pay_Standard_Commission__c, Receive_Cargo_BI_statistics__c, Participate_in_AWB_Stock_Management__c,
            GSSA_Legal_Name__c,GSSA_Contact_Salutation__c,GSSA_Address__c,GSSA_Code__c,GSSA_Contact_Email__c,GSSA_Contact_FAX__c,GSSA_Contact_F_Name__c,GSSA_Contact_L_Name__c,GSSA_Contact_JobTitle__c,GSSA_Contact_Phone__c,
            Submitted_to_IATA__c,AP_BR_Address_CNP__c,AP_BR_Address_To_Insert__c,AP_BR_BankBeneficiary_Account_Holder__c,Clave_Bancaria_Unificada_CBU__c,Other_TAX_Identification__c,Cyprus_Turkey_based_Airline__c,Airline_s_Fiscal_Status__c,
            Company_Registration_number__c, Name_of_business_comm_assoc__c, Capital_amount_of_the_business__c,Local_CC_Settlement_Scheme__c,Airline_Registered_under_other_name__c,
            CASS_PH_Bilateral_Agreement__c,CASS_PH_Preferred_Billing_Currency__c,CASS_PH_Bilat_Agreement_Tax_Rate__c,Airline_Intra_Europe_Flights__c,BSP_UA_LocalReg_Number_EDRPOU__c,BSP_UA_BankCode_MFO__c,Ecuador_Legal_Forms_requirements__c,
            BSP_Russia_Double_Tax_avoiding_Treaty__c, Colombia_City_selection__c, Colombia_City_percentage__c, Name_Appearing_in_VAT__c, Colombia_Type_of_Contributor__c, Territory_Percentage__c,
            Canada_Has_Principal_Office__c,Canada_Provincial_Offices__c,Canada_LocalVAT_Info__c, GSSA_Legal_Name_Formula__c, GSSA_Address_Formula__c, Case__r.AccountId,
            ANG_Airline_accepts_EasyPay_tr_in_BSP__c,Minimum_Commission_Rate__c, Maximum_Commission_Rate__c, Default_Commission_Rate__c, Type_of_Change_Requested__c
            FROM AP_Process_Form__c
            WHERE Case__c = :newCase.Id
            LIMIT 1
        ];
        if (newForms.size()>0)
        {
            newForm = newForms[0];
            list_GSTNumber = [SELECT Id, AP_Process_Form__c, India_Local_VAT_Number__c, India_Local_VAT_Street__c, India_Local_VAT_City__c, India_Local_VAT_State_Name__c, India_Local_VAT_State_Code__c FROM GST_Information__c WHERE AP_Process_Form__c =: newForm.Id];
        }
    }

    public Case retrieveCase(String vCaseId){
        List <Case> newCases = [
            SELECT OwnerId, Id, CaseNumber, Reason1__c, CaseArea__c, Status, BSPCountry__c, Country_concerned_by_the_query__c, Contact.Name, Account.Id, Description, Subject, Account_Concerned__c, Account_Concerned__r.Top_Parent__c, Account.Name,
            Account.Billing_Address_formated__c, Verification__c,IFAP_Country_ISO__c,
            Account_Concerned__r.IATA_ISO_Country__r.AMS_Settlement_System__r.DPC_System__c
            FROM Case 
            WHERE Id=:vCaseId 
        ];
        if (newCases.size()>0) {
            return newCases[0];
        } else {
            return null;
        }
    }

    public Contact retrieveContact (String vContactID){
        List<Contact> contact = [SELECT Id, FirstName, LastName , Email, AccountId, Account.Top_Parent__c FROM Contact where Id = :vContactID ];
        if(contact.size()>0){
            return contact[0];
        }else{
            return null;
        }
    }

    public void retrieveCountryRequirements(String vCountry, String strLoB) {

        List <AP_Country_Requierment__c> countryReqments = [

            SELECT Id, Name, Local_Representation_Mandatory__c, Local_accountant_mandatory__c, Local_VAT_Mandatory__c,
            Foreign_VAT_accepted__c, Special_VAT_status_allowed__c, Local_Representation_for_Fiscal_requirem__c,
            Currency_of_the_Settlement__c, Dual_currencies__c, bank_account_in_of_the_settlement__c,
            Mandatory_to_give_commission_to_agencies__c, Comments__c, Government_requirements__c, Type_of_address_accepted__c,
            VAT_no_always_inserted_into_ISS_systems__c, bank_account_in_of_the_settlement_com__c, Currency_of_the_Settlement_com__c,
            Dual_currencies_com__c, Foreign_VAT_accepted_com__c, Local_accountant_mandatory_com__c, Local_Representation_for_Fiscal_req_com__c,
            Local_Representation_Mandatory_com__c, Local_VAT_Mandatory_com__c, Mandatory_to_give_commission_to_agen_com__c, Special_VAT_status_allowed_com__c,
            Type_of_address_accepted_com__c, VAT_no_always_ins_into_ISS_systems_com__c, Government_requirements_com__c,Country__r.ISO_Code__c,
            Country__r.Case_BSP_Country__c,Bank_Account_Change_Comment__c

            //SELECT id
            FROM AP_Country_Requierment__c
            WHERE Line_of_business__c = :strLoB AND Country__r.ISO_Code__c = :vCountry
            LIMIT 1
        ];
        if (countryReqments.size()>0)
        {
            countryRequirement = countryReqments[0];
            countryRequirementFound = true;
        }else{
            countryRequirementFound = false;
        }
    }

    private boolean isDupeDraft(Id vAccountConcerned, String joiningType, String changeType) {

        //Is there already an Ongoing Joining Process
        dupeDraft = [
            SELECT id, AccountId, Reason1__c, Country_concerned_by_the_query__c,CaseArea__c
            FROM Case
            WHERE Case.Status IN ('Draft','Pending customer','For Review and Acceptance') AND Case.RecordTypeId=:RECORD_TYPE_ID AND Case.Account_Concerned__c = :vAccountConcerned
            AND Case.Verification__c = : joiningType AND Case.CaseArea__c = 'Airline Joining'];

        if(dupeDraft.size()>0) {
              dupeDraftExists = true;
              return true;
        } else {
            //No Joining Process, so check for ongoing Minor DB or Bank details Change
            if(changeType=='Minor database changes') {
                dupeDraft = [
                SELECT id, AccountId, Reason1__c, Country_concerned_by_the_query__c,CaseArea__c
                FROM Case
                WHERE Case.Status IN ('Draft','Pending customer','For Review and Acceptance') AND Case.RecordTypeId=:RECORD_TYPE_ID AND Case.Account_Concerned__c = :vAccountConcerned
                AND Case.Verification__c = : joiningType AND Case.CaseArea__c = 'Airline Change' AND Case.Reason1__c = 'Minor database changes'];
            } else {
                dupeDraft = [
                SELECT id, AccountId, Reason1__c, Country_concerned_by_the_query__c,CaseArea__c
                FROM Case
                WHERE Case.Status IN ('Draft','Pending customer','For Review and Acceptance') AND Case.RecordTypeId=:RECORD_TYPE_ID AND Case.Account_Concerned__c = :vAccountConcerned
                AND Case.Verification__c = : joiningType AND Case.CaseArea__c = 'Airline Change' AND Case.Reason1__c = 'Bank Account Instructions'];
            }

             if(dupeDraft.size()>0) {
              dupeDraftExists = true;
              return true;
             }
        }
        dupeDraftExists = false;
        return false;
    }

    public boolean isSameAPCase() {
            List<Case> dupeCases = [
                SELECT Id, CaseNumber, Reason1__c, CaseArea__c, Status, BSPCountry__c, Country_concerned_by_the_query__c, Contact.Name, Account.Id, Description, Subject, Account_Concerned__c, Account_Concerned__r.Top_Parent__c, Account.Name,
                  Account.Billing_Address_formated__c, Verification__c,IFAP_Country_ISO__c
                    FROM Case WHERE RecordType.DeveloperName = 'IDFS_Airline_Participation_Process' AND Id = :vCaseId
            ];
            if(dupeCases.size()>0) {
                isNewCase=false;
                newCase = dupeCases[0];
                return true;
            } else {
              return false;
            }
        }

    public Pagereference save(){
        String description;

         if(isGSSAUser) {
             if(strOperationType=='Airline Joining') {
               vGSSAAccountId = con.AccountId;
              vHQAccountId = cassairlineid; //For Joining selected AL in list is a HQ Account Id
             } else { //whereas for Chhanges (Services Rendered) selected Account Id may well be a BR account
                List <Account> airlineList = [SELECT Id, Name, IATACode__c, Airline_designator__c, Airline_Prefix__c, Top_Parent__c FROM Account WHERE Id = :cassairlineid];
                if (!airlineList.isEmpty()){
                    if(airlineList[0].Top_Parent__c==null) {
                        vHQAccountId = airlineList[0].Id;
                    } else {
                        vHQAccountId = airlineList[0].Top_Parent__c;
                    }
                }
             }

        } else if (con.Account.Top_Parent__c == null) { //User is from HQ  Account
            vHQAccountId = con.AccountId;
        } else {
            vHQAccountId = con.Account.Top_Parent__c;
        }

        apcountryisocode = newCase.IFAP_Country_ISO__c; //Need Country ISO Code to search for AL Branch office (Account concerned) in case of GSSA applying

        description = newCase.Description;
        SYSTEM.DEBUG('HQ Account Id: ' + vHQAccountId);
        retrieveHQAccountDetails(vHQAccountId);  //Especially to get AL Membershhip status at this stage for initial case creation

        if(strOperationType.startsWith('BSP')) {
            strLoB = 'BSP';
        } else {
            strLoB = 'CASS';
        }

        SYSTEM.DEBUG('SAVE - strOperationType: ' + strOperationType);
        SYSTEM.DEBUG('SAVE - LOB: ' + strLoB);
        SYSTEM.DEBUG('SAVE - Country ISO Code: ' + apcountryisocode);

        retrieveCountryRequirements(apcountryisocode, strLoB);
        Boolean sameCase = isSameAPCase();
        //If we have retrieved same case going from STEP 1 back to STEP 2 then need to reset these 2 submitted fields
        newCase.IFAP_Country_ISO__c = apcountryisocode;
        newCase.Description = description;

        isocountry = fetchISOCountry(newCase.IFAP_Country_ISO__c);
        newCase.BSPCountry__c =  isocountry.Case_BSP_Country__c ;
        newCase.Country_concerned_by_the_query__c = isocountry.Case_BSP_Country__c;
        newCase.Visible_on_ISS_Portal__c = true;

        newForm.ANG_Enable_NewGen__c = (isocountry.ANG_Portal_Service__c != null);

        //AS - R03 SP03; for when GSSA create joining processs on behalf of Airline
        if (isGSSAUser){
            //GSSA user has selected Airline HQ account for Joining, or BR AL Account for Change (from Services Rendered), from dropdown list of Airlines in Step 1
            if (cassairlineid != '' && cassairlineid != null){
                List <Account> airlineList = [SELECT Id, Name, IATACode__c, Airline_designator__c, Airline_Prefix__c FROM Account WHERE Id = :cassairlineid];
                if (!airlineList.isEmpty()){
                    newCase.IATAcode__c = airlineList[0].IATACode__c;
                    newCase.Provider__c = con.AccountId;  //Put GSSA as Provider for backwards compatibility
                    newCase.Account_Concerned__c = retrieveAirlineConcerned(hqAccount, hqAccount.Airline_designator__c,
                                                                            hqAccount.Airline_Prefix__c,
                                                                            apCountryisocode, airlineList[0].Name, airlineList[0].Id);
                }
            }
        } else {
            newCase.IATAcode__c = con.Account.IATACode__c;  //Web IATA Code on case
            newCase.Account_Concerned__c = retrieveAirlineConcerned(hqAccount, con.Account.Airline_designator__c,
                                                                    con.Account.IATACode__c,
                                                                    apCountryisocode, con.Account.Name, vHqAccountId);
        }

        //Defining default values for the case
        //create case with RT IDFS Airline Participation Process
        newCase.recordTypeId = RECORD_TYPE_ID;
        newCase.Origin = 'Portal';
        newCase.Country_concerned_by_the_query__c = countryRequirement.Country__r.Case_BSP_Country__c;

        newCase.CaseArea__c = strAreaType;

        if(strAreaType=='Airline Joining') {
          	newCase.Reason1__c = caseReason(strOperationType, strParentMembershipstatus);
            newCase.Subject='Airline Participation - '+ strOperationType + ' Joining Process - ' + newCase.Country_concerned_by_the_query__c;
        } else {
            newCase.Reason1__c = strChangeType;
            newCase.Subject='Airline Participation - ' + strOperationType + ' - '+ strChangeType + ' - ' + newCase.Country_concerned_by_the_query__c;
        }
        if (strOperationType=='BSP') {
            newCase.Subject += ' - ' + hqAccount.IATACode__c + '/' + hqAccount.Airline_designator__c;
        } else if (strOperationType.startsWith('CASS')) {
            newCase.Subject += ' - ' + hqAccount.Airline_Prefix__c + '/' + hqAccount.Airline_designator__c;
        }

        newCase.Verification__c = strOperationType;  //Store the type of Joining application, for later use in indentifying Duplicate application for same AL + Country
        newCase.Type_of_customer__c = con.Account.Category__c;

        SYSTEM.DEBUG('Case ID: ' + vCaseId);
        SYSTEM.DEBUG('Is Dupe Draft: ' + isDupeDraft(newCase.Account_Concerned__c, strOperationType, strChangeType));

        if(isDupeDraft(newCase.Account_Concerned__c, strOperationType, strChangeType) && !sameCase) { //Has GSSA or AL applied for same joining type for this Account
            return redirectToCasesListForDupe();
        } else if(!sameCase) {
          newCase.Status = 'Draft';
        }

        try {
            upsert newCase;
            return goToStep2();
        } catch(DmlException ex) {
            ApexPages.addMessages(ex);
        }

        return goToStep2();
    }

    public void saveBSPForm(){
        getLob(newCase.Verification__c);
        // TF - Type of Change Requested
        String typeOfChangeRequestedString = '';
        for (String thisValue : typeOfChangeRequested){
          typeOfChangeRequestedString = typeOfChangeRequestedString + thisValue + ';';
        }
        newForm.Type_of_Change_Requested__c = typeOfChangeRequestedString;

        //TF
        if (cityList != null){
            if (!cityList.isEmpty()){
                String citySelection = '';
                String cityPercentage = '';
                for (citySelection thisCity : cityList){
                    system.debug('CITY: ' + thisCity.city);
                    system.debug('SELECTED: ' + thisCity.selected);
                    system.debug('PERCENTAGE: ' + thisCity.percentage);
                    if (thisCity.selected){
                        if (citySelection == ''){
                            citySelection = thisCity.city;
                            if (thisCity.percentage == '' || thisCity.percentage == null){
                                thisCity.percentage = '0';
                            }
                            cityPercentage = thisCity.percentage;
                        }
                        else{
                            citySelection = citySelection + ';' + thisCity.city;
                            if (thisCity.percentage == '' || thisCity.percentage == null){
                                thisCity.percentage = '0';
                            }
                            cityPercentage = cityPercentage + ';' + thisCity.percentage;
                        }
                    }
                }
                newForm.Colombia_City_selection__c = citySelection;
                newForm.Colombia_City_percentage__c = cityPercentage;
            }
        }

        //If we create the form we need to set the default values
        if(String.isBlank(String.ValueOf(newForm.Case__c))){
            newForm.Case__c =newCase.Id;
          //newForm.Type__c = type;

            if(strAreaType == 'Airline Joining') {
                SYSTEM.DEBUG('Record Type Name: ' + strLoB + ' Joining');
              newForm.RecordTypeId = Schema.SObjectType.AP_Process_Form__c.RecordTypeInfosByName.get(strLoB + ' Joining').RecordTypeId;
            } else {
                newForm.RecordTypeId = Schema.SObjectType.AP_Process_Form__c.RecordTypeInfosByName.get(strLoB + ' Change').RecordTypeId;
            }

            //newForm.RecordTypeId =[Select Id,SobjectType,Name From RecordType WHERE Name = :strLoB and SobjectType ='AP_Process_Form__c'  limit 1].Id;
        }

       upsert newForm;
    }

    public Pagereference saveBSPFormAndGoForward(){

        try {
            saveBSPForm();
            return goToStep4();
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public Pagereference saveBSPFormAndGoBack(){
        try {
          saveBSPForm();
            return goToStep2();
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public Pagereference saveBSPFormAndLeave(){
        try {
            saveBSPForm();
          return redirectToCasesList();
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    private String caseReason(String strType, String strMembershipStatus) {
        String strReasonMembership;
        String strReason;

        if(strMembershipStatus=='IATA member')
        {
            strReasonMembership = ' - Member';
        } else {
            strReasonMembership= ' - Non-Member';
        }

        if(isGSSAUser && category <> 'IBCS consolidator') {
            if (strType=='CASS Import') {
                strReason='CASS Import via GHA' + strReasonMembership;
            } else {
                strReason='CASS Export via GSSA' + strReasonMembership;
            }
            isCASS = true;
            strLoB = 'CASS';
        } else if(strType=='BSP') {
            strReason='BSP Direct' + strReasonMembership;
            isBSP = true;
            strLoB = 'BSP';
        } else if (strType=='CASS Export') {
            strReason='CASS Direct' + strReasonMembership;
            isCASS = true;
            strLoB = 'CASS';
        } else {
            strReason='CASS Import Direct' + strReasonMembership;
            isCASS = true;
            strLoB = 'CASS';
        }

        return strReason;
    }

    public Pagereference goToStep1(){

        if(countryRequirementFound) {
            return new Pagereference('/ISSP_APProcess?caseId='+newCase.Id+'&step=1');
        }   else {
            return new Pagereference('/ISSP_APProcess?step=1');
        }
    }

    public Pagereference goToStep2(){
        if(countryRequirementFound) {
            return new Pagereference('/ISSP_APProcess?caseId='+newCase.Id+'&step=2');
        } else { //No case created if Country Reqs are not found
            return new Pagereference('/ISSP_APProcess?step=2&ctryreq=false&country=' + apCountry + '&lob=' + strLOB);
        }
    }

    public Pagereference goToStep3(){
        return new Pagereference('/ISSP_APProcess?caseId='+newCase.Id+'&step=3');
    }
    public Pagereference goToStep4(){
        return new Pagereference('/ISSP_APProcess?caseId='+newCase.Id+'&step=4');
    }

    public Pagereference goToFinalStep(){
        List<Attachment> attch = getAttachList();

        if(newForm.Airline_wish_to_join_ICCS__c == 'No' && attch.size() < 1) {
            newForm.addError('Please attach the bank mandate (one for each currency) before submitting the application.');
            return null;
        }

        try{

            newForm.ANG_Enable_NewGen__c = (isocountry.ANG_Portal_Service__c != null && isocountry.Airline_EasyPay_Opt_Out_Date__c <= Date.today() && isocountry.Airline_EasyPay_Opt_Out_Date__c != null);

            newForm.Submitted_to_IATA__c = TRUE;
            if(strAreaType == 'Airline Joining') {
                newForm.RecordTypeId = Schema.SObjectType.AP_Process_Form__c.RecordTypeInfosByName.get(strLoB + ' Joining').RecordTypeId;
            } else {
                newForm.RecordTypeId = Schema.SObjectType.AP_Process_Form__c.RecordTypeInfosByName.get(strLoB + ' Change').RecordTypeId;
            }
            upsert newForm;
            newCase.Status = 'For Review and Acceptance';
            if(newCase.ownerid == APQueue('Airline Participation - Drafts').Id)
            newCase.ownerid = APQueue('Airline Participation - Head Office').Id;
            upsert newCase;

            sendConfirmationEmail(newCase);

            return new Pagereference('/ISSP_APProcess?caseId='+newCase.Id+'&step=Final');
        } catch (DmlException ex) {
            newForm.Submitted_to_IATA__c = FALSE;
            ApexPages.addMessages(ex);
        }

        return null;
    }

    public Pagereference redirectToCasesList(){
        return new Pagereference('/ISSP_APCases');
    }

    public Pagereference redirectToCasesListForDupe() {
        if(dupeDraft[0].CaseArea__c=='Airline Joining') {
            APprocess='jng';
        } else {
            APprocess='chg';
        }
        return new Pagereference('/ISSP_APCases?proc=' + APprocess + '&cdupetype=' + strOperationType + '&caseId=' + dupeDraft[0].Id + '&retURL=/ISSP_HomePage');
    }

    public Pagereference cancel(){
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if (retURL == null) {
            return new Pagereference('/ISSP_APCases');
        } else {
            return new Pagereference(retURL);
        }
    }

    public List<SelectOption> getItems() {
        List <AP_Country_Requierment__c> isoListJoining;
        List <Services_Rendered__c> isoListChange;

        strOperationType = Apexpages.currentPage().getParameters().get('strOT');
        strLOB = null;
        if(strOperationType != null) {
            strOperationTypeAux = strOperationType;
            getLoB(strOperationType);
        } else if (strOperationTypeAux != null) {
            strOperationType = strOperationTypeAux;
            getLoB(strOperationType);
        }

        SYSTEM.DEBUG('Area Type: ' + strAreaType);
        SYSTEM.DEBUG('Operation Type: ' + strOperationType);
        SYSTEM.DEBUG('LoB: ' + strLoB);

        if(strLOB != null) //INC300017
            dupLoB = strLOB;

        if(strAreaType=='Airline Joining') {
          if(strLoB=='CASS' || (isGSSAUser & category <> 'IBCS consolidator')) {
             isoListJoining = [SELECT Id, Name, Country__r.Name, Country__r.Case_BSP_Country__c, Country__r.ISO_Code__c from AP_Country_Requierment__c
                        WHERE Line_of_business__c = 'CASS' ORDER by Name];
          } else {
             isoListJoining = [SELECT Id, Name, Country__r.Name, Country__r.Case_BSP_Country__c, Country__r.ISO_Code__c from AP_Country_Requierment__c
                              WHERE Line_of_business__c = 'BSP' ORDER by Name];
          }
        } else {  //AP Change process, so based country list on Services Rendered
            if(!isGSSAUser) {
              if(strLOB=='CASS' || dupLoB == 'CASS') {
               isoListChange = [SELECT Id, ISO_Country_formula__c, ISO_Country_Code__c from Services_Rendered__c
                            WHERE Services_Rendered_By__c = :vHQAccountId AND Services_Rendered_Type__c LIKE '%CASS%' AND Services_Rendered_Status__c='Active'
                             ORDER BY ISO_Country_formula__c];
            } else {
               isoListChange = [SELECT Id, ISO_Country_formula__c, ISO_Country_Code__c from Services_Rendered__c
                            WHERE Services_Rendered_By__c = :vHQAccountId AND Services_Rendered_Type__c='BSP Participation' AND Services_Rendered_Status__c='Active'
                             ORDER BY ISO_Country_formula__c];
            }
            } else {
                System.DEBUG('GSSA HQ Id: ' + vGSSAAccountId);

        isoListChange = [SELECT Id, ISO_Country_formula__c, ISO_Country_Code__c from Services_Rendered__c
                            WHERE Services_Rendered_By__c = :vGSSAAccountId AND Services_Rendered_Type__c='CASS Export via GSSA' AND Services_Rendered_Status__c='Active'
                             ORDER BY ISO_Country_formula__c];
            }
        }

        List<SelectOption> options = new List<SelectOption>();
        Set<String> sISOCode = New Set<String>();

        options.add(new SelectOption('', '--None--'));
         if(strAreaType=='Airline Joining') {
            for(AP_Country_Requierment__c iso : isoListJoining){
            //        if (sISOCode.Contains(iso.Country__r.ISO_Code__c) == FALSE){ ---INC314169---
                      sISOCode.add(iso.Country__r.ISO_Code__c);
                        options.add(new SelectOption(iso.Country__r.ISO_Code__c,iso.Name));
            //        }
            }
            } else {
              for(Services_Rendered__c iso : isoListChange){
                  if (sISOCode.Contains(iso.ISO_Country_Code__c) == FALSE){
                       sISOCode.add(iso.ISO_Country_Code__c);
                  options.add(new SelectOption(iso.ISO_Country_Code__c,iso.ISO_Country_formula__c));
                     }
            }
          }

        return options;
    }

    public List<SelectOption> financialCountryNameList {
        get {
            List<SelectOption> options = new List<SelectOption>();

            list<IATA_ISO_Country__c> isoList;

            isoList = [SELECT Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c, AMS_Pilot_Country__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        FROM IATA_ISO_Country__c
                        ORDER BY Name];

          options.add(new SelectOption('', Label.ISSP_SELECT_COUNTRY));
          for(IATA_ISO_Country__c iso : isoList){
            options.add(new SelectOption(iso.Name,iso.Name));
          }

          return options;
        }
        set;
    }

    public List<SelectOption> countryNameList {
        get {
            List<SelectOption> options = new List<SelectOption>();

            list<IATA_ISO_Country__c> isoList;

            isoList = [SELECT Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c, AMS_Pilot_Country__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        FROM IATA_ISO_Country__c
                        WHERE Case_BSP_Country__c!=null
                        AND Case_BSP_Country__c!=''
                        ORDER BY Name];

          options.add(new SelectOption('', Label.ISSP_SELECT_COUNTRY));
          for(IATA_ISO_Country__c iso : isoList){
            options.add(new SelectOption(iso.Name,iso.Name));
          }

          return options;
        }
        set;
    }

    public List<SelectOption> getAPTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));

        if(!isGSSAUser) { //GSSA cannot create BSP cases
            options.add(new SelectOption('BSP','BSP'));
        }

        if(category == 'IBCS consolidator'){
            options.add(new SelectOption('BSP','BSP'));
        }

        if(category <> 'IBCS consolidator'){
        options.add(new SelectOption('CASS Export','CASS Export'));
        options.add(new SelectOption('CASS Import','CASS Import'));
        }

        /**
        if(strParentMembershipStatus=='IATA member') {
            if(!isGSSAUser) {
                options.add(new SelectOption('BSP Direct - Member','BSP'));
                options.add(new SelectOption('CASS Direct - Member','CASS Export'));
                options.add(new SelectOption('CASS Import Direct - Member','CASS Import'));
            } else {
                options.add(new SelectOption('CASS via GSSA - Member','CASS Export'));
                options.add(new SelectOption('CASS Import via GHA - Member','CASS Import'));
            }
        } else { //IATA Non-Member
            if(!isGSSAUser) {
                options.add(new SelectOption('BSP Direct - Non-Member','BSP'));
                options.add(new SelectOption('CASS Direct - Non-Member','CASS Export'));
                options.add(new SelectOption('CASS Import Direct - Non-Member','CASS Import'));
            } else {
                options.add(new SelectOption('CASS via GSSA - Non-Member','CASS Export'));
                options.add(new SelectOption('CASS Import via GHA - Non-Member','CASS Import'));
            }
        }
    **/

        return options;
    }

    public List<SelectOption> getCassAirlines() {
        List <Account> casshq;
        List <Services_Rendered__c> existingCASS;

        gssaCountryISOCode = Apexpages.currentPage().getParameters().get('gssaCountryISOCode');
        SYSTEM.DEBUG ('GSSA Country code: ' + gssaCountryISOCode);

        if(strAreaType=='Airline Joining') { //Get list of all Cargo Airlines when GSSA wants to craete new joining
           casshq = [SELECT Id, Name, Airline_Prefix__c, Airline_designator__c
                  FROM Account
                  WHERE RecordType.DeveloperName IN ('IATA_Airline') AND (Airline_Prefix__c != null OR IATAcode__c != null) AND Airline_designator__c != null AND ACLI_Status__c != 'Inactive Company'
                  ORDER BY Name];
        } else { //Or else get list of existing Airlines where this GSSA renders the CASS service, for selected country, for changes
            if(gssaCountryISOCode != null) {
              existingCASS = [SELECT Services_Rendered_to_Airline__c, Services_Rendered_to_Airline__r.Name, Services_Rendered_to_Airline__r.Airline_designator__c, Services_Rendered_to_Airline__r.Parent.Airline_Prefix__c
                            FROM Services_Rendered__c
                            WHERE Services_Rendered_By__c = :vGSSAAccountId AND Services_Rendered_Type__c='CASS Export via GSSA' AND Services_Rendered_Status__c='Active' AND ISO_Country_Code__c = :gssaCountryISOCode
                             ORDER BY Services_Rendered_to_Airline__r.Name];
            } else {
                existingCASS = [SELECT Services_Rendered_to_Airline__c, Services_Rendered_to_Airline__r.Name, Services_Rendered_to_Airline__r.Airline_designator__c, Services_Rendered_to_Airline__r.Parent.Airline_Prefix__c
                            FROM Services_Rendered__c
                            WHERE Services_Rendered_By__c = :vGSSAAccountId AND Services_Rendered_Type__c='CASS Export via GSSA' AND Services_Rendered_Status__c='Active'
                             ORDER BY Services_Rendered_to_Airline__r.Name];
            }

        }

        List<SelectOption> cass_airlines = new List<SelectOption>();
        cass_airlines.add(new SelectOption('','--None--'));

        if(strAreaType=='Airline Joining') {
          for(Account als : casshq){
              cass_airlines.add(new SelectOption(als.id, als.Name + ' (' + als.Airline_designator__c + ' ' + als.Airline_Prefix__c + ')'));
          }
        } else {
          for(Services_Rendered__c als : existingCASS){
              cass_airlines.add(new SelectOption(als.Services_Rendered_to_Airline__c, als.Services_Rendered_to_Airline__r.Name + ' (' + als.Services_Rendered_to_Airline__r.Airline_designator__c+ ' ' + als.Services_Rendered_to_Airline__r.Parent.Airline_Prefix__c +')'));
          }
        }

        return cass_airlines;
    }

    // Initialize setCon and return a list of records
    public List<Case> getAPDraftCases() {
        return (List<Case>) setConn.getRecords();
    }

    public Group APQueue(String qName) {

        //Available AP queue names
        Set<String> queueNames = new Set<String>{'Airline Participation - Drafts','Airline Participation - Head Office'};
            Map<String,QueueSobject> mapRegionalQueue = new Map<String,QueueSobject>();

        //Build map queue.name -> queue
        for(QueueSobject queue : [Select Queue.Id,Queue.Name From QueueSobject Where Queue.Name in: queueNames]){
            mapRegionalQueue.put(queue.Queue.Name,queue);
        }

        return mapRegionalQueue.get(qName).Queue;
    }

    public PageReference redirect(String destinationURL) {
        PageReference redirecturl = new PageReference(destinationURL);
        redirecturl.setRedirect(true);
        return redirecturl;
    }

    public PageReference checkRedirect(){
        List<Case> IFAPCases = getAPDraftCases();
        if(IFAPCases.size() == 1){
            String redirectTo = '/'+IFAPCases.get(0).Id;
            return redirect(redirectTo);
        }else{
            return null;
        }
    }

    private void poupulateOptInOutOptions() {
    	optInOutOptions = new List<SelectOption>();
    	optInOutOptions.add(new SelectOption('', '-Select-'));
    	optInOutOptions.add(new SelectOption('IN', 'Opt-In to IATA EasyPay'));
    	optInOutOptions.add(new SelectOption('OUT', 'Opt-Out from IATA EasyPay'));
    }

    private void populateCountriesMap() {
        airlineOptInDays = Integer.valueOf(ISSP_CS__c.getValues('EasyPay Opt-In Days').Value__c);
        airlineOptOutDays = Integer.valueOf(ISSP_CS__c.getValues('EasyPay Opt-Out Days').Value__c);

    	countriesIn = new List<SelectOption>();
    	hasCountriesIn = false;
    	countriesOut = new List<SelectOption>();
    	hasCountriesOut = false;

    	for(Services_Rendered__c service : [SELECT Id, ISO_Country_formula__c, ANG_IATA_EasyPay_Opt_out__c, Services_Rendered_to_Airline__r.IATA_ISO_Country__c
    										FROM Services_Rendered__c
    										WHERE Services_Rendered_to_Airline__r.IATA_ISO_Country__r.Airline_EasyPay_Opt_Out_Date__c <= :Date.today()
    											AND Services_Rendered_Type__c = 'BSP Participation'
    											AND Services_Rendered_By__c = :vHQAccountId
                                                AND Services_Rendered_Status__c = 'Active']) {
    		if (service.ANG_IATA_EasyPay_Opt_out__c) {
    			countriesIn.add(new SelectOption(service.Services_Rendered_to_Airline__r.IATA_ISO_Country__c, service.ISO_Country_formula__c));
    			hasCountriesIn = true;
    		} else {
    			countriesOut.add(new SelectOption(service.Services_Rendered_to_Airline__r.IATA_ISO_Country__c, service.ISO_Country_formula__c));
    			hasCountriesOut = true;
    		}
    	}    	
    }

    public PageReference submitOptInOutServer() {
        String optInOutParam = Apexpages.currentPage().getParameters().get('optInOutParam');
        List<String> countriesParam = (List<String>) System.JSON.deserialize(Apexpages.currentPage().getParameters().get('countriesParam'), List<String>.class);
        String effectiveDateParam = Apexpages.currentPage().getParameters().get('effectiveDateParam');

        String optInOutSubject = optInOutParam == 'OUT' ? 'Opt-Out' : 'Opt-In';

        retrieveHQAccountDetails(vHQAccountId);

        Map<Id, IATA_ISO_Country__c> isoCountriesMap = new Map<Id, IATA_ISO_Country__c>([SELECT Id, ISO_Code__c, Region__c, Name FROM IATA_ISO_Country__c WHERE Id IN :countriesParam]);
        
        List<String> countryNames = new List<String>();
        for (IATA_ISO_Country__c country: isoCountriesMap.values()) countryNames.add(country.Name);

        Case optInOutParentCase = new Case(RecordTypeId = RECORD_TYPE_ID,
        								   Description = String.join(countryNames, ', '),
        								   Status = 'For Review and Acceptance',
        								   CaseArea__c = 'Airline Change',
        								   Reason1__c = 'IATA Easy Pay',
        								   IFAP_Country_ISO__c = isoCountriesMap.get(countriesParam[0]).ISO_Code__c,
        								   Visible_on_ISS_Portal__c = true,
        								   IATAcode__c = con.Account.IATACode__c,
        								   BSPCountry__c = isoCountriesMap.get(countriesParam[0]).Name,
        							 	   Region__c = isoCountriesMap.get(countriesParam[0]).Region__c,
        							 	   Account_Concerned__c = retrieveAirlineConcerned(hqAccount, con.Account.Airline_designator__c,
                                                                    con.Account.IATACode__c,
                                                                    isoCountriesMap.get(countriesParam[0]).ISO_Code__c, con.Account.Name, vHqAccountId),
        							 	   Origin = 'Portal',
        							 	   Subject = 'Airline Participation - IATA EasyPay ' + optInOutSubject + ' - ' + isoCountriesMap.get(countriesParam[0]).Name,
        							 	   Provider__c = con.AccountId,
                                           Type_of_customer__c = 'Airline Passenger',
                                           Verification__c = 'BSP');

        insert optInOutParentCase;

        List<String> splittedDate = effectiveDateParam.split('-');
        Date parsedDate = Date.newInstance(Integer.valueOf(splittedDate[0]), Integer.valueOf(splittedDate[1]), Integer.valueOf(splittedDate[2]));

        AP_Process_Form__c processForm = new AP_Process_Form__c(Case__c = optInOutParentCase.Id,
        														IATA_EasyPay_Effective_Date__c = parsedDate,
        														IATA_EasyPay_Opt_In_Opt_Out__c = optInOutParam,
        														RecordTypeId = AMS_Utils.RECTYPE_IATAEASYPAY);

        insert processForm;

        Case childCase;

        if (countriesParam.size() > 1) {
        	List<Case> childCases = new List<Case>();
        	for (Integer i = 1; i < countriesParam.size(); i++) {
        		childCase = new Case(RecordTypeId = RECORD_TYPE_ID,
        							 Description = isoCountriesMap.get(countriesParam[i]).Name,
        					    	 Status = 'For Review and Acceptance',
        							 CaseArea__c = 'Airline Change',
        							 Reason1__c = 'IATA Easy Pay',
        							 ParentId = optInOutParentCase.Id,
        							 IFAP_Country_ISO__c = isoCountriesMap.get(countriesParam[i]).ISO_Code__c,
        							 IATAcode__c = con.Account.IATACode__c,
        							 Visible_on_ISS_Portal__c = false,
        							 BSPCountry__c = isoCountriesMap.get(countriesParam[i]).Name,
        							 Region__c = isoCountriesMap.get(countriesParam[i]).Region__c,
        							 Account_Concerned__c = retrieveAirlineConcerned(hqAccount, con.Account.Airline_designator__c,
                                                                    con.Account.IATACode__c,
                                                                    isoCountriesMap.get(countriesParam[i]).ISO_Code__c, con.Account.Name, vHqAccountId),
        							 Origin = 'Portal',
        							 Subject = 'Airline Participation - IATA EasyPay ' + optInOutSubject + ' - ' + isoCountriesMap.get(countriesParam[i]).Name,
        							 Provider__c = con.AccountId,
                                     Type_of_customer__c = 'Airline Passenger',
                                     Verification__c = 'BSP');
        		
        		childCases.add(childCase);
        	}

        	insert childCases;
        }

        return null;
    }

    public PageReference securityCheck() {
        if (newCase.Id != null && newCase.Status != 'Draft' && newCase.Status != 'Return application to customer') {
            return new Pagereference('/ISSP_Case?caseId=' + newCase.Id); 
        }

        return null;
    }


    public Boolean getIsEmpty(){
        List<Case> IFAPCases = getAPDraftCases();
        if(IFAPCases.isEmpty()){
            return true;
        }
        return false;
    }

    Public Boolean getIsNotEmpty(){
        List<Case> IFAPCases = getAPDraftCases();
        if(IFAPCases.isEmpty()){
            return false;
        }
        return true;
    }

    public pagereference UploadFile(){
        if(fileBody == null || fileName == null)  {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a file.');
            ApexPages.addMessage(myMsg);
            fileBody = null;
        } else {
            Attachment myAttachment  = new Attachment();
            myAttachment.Body = fileBody;
            myAttachment.Name = fileName;
            myAttachment.ParentId = vCaseId;
            insert myAttachment;
        }
        return null;
    }

    public List<Attachment> getAttachList(){
        return [SELECT Id, Name FROM Attachment WHERE ParentId = :vCaseId];
    }

    //TF
    public void getCityData(){

        List <AP_Country_Cities__c> csList = [SELECT City__c FROM AP_Country_Cities__c
                                              WHERE Country_ISO_Code__c = :apCountryisocode
                                              AND Operation__c = :strLoB
                                              ORDER BY City__c];
        Map<String,String> cityPerMap = new Map<String,String>();
        if (!csList.isEmpty()){
            cityList = new List<citySelection>();
            cityListWithValue = new List<citySelection>();

            if (newForm.Colombia_City_selection__c != '' && newForm.Colombia_City_selection__c != null){
                List<String> cityStringList = newForm.Colombia_City_selection__c.split(';');
                List<String> cityPercentageStringList = newForm.Colombia_City_percentage__c.split(';');
                integer i = 0;
                for (String thisCity : cityStringList){
                    cityPerMap.put(thisCity, cityPercentageStringList[i]);
                    i++;
                }
                for (AP_Country_Cities__c thisCity : csList){
                    citySelection cityRecord = new citySelection();
                    if (cityPerMap.containsKey(thisCity.City__c)){
                        cityRecord.selected = true;
                        cityRecord.city = thisCity.City__c;
                        cityRecord.percentage = cityPerMap.get(thisCity.City__c);
                        cityListWithValue.add(cityRecord);
                    }
                    else{
                        cityRecord.selected = false;
                        cityRecord.city = thisCity.City__c;
                    }
                    cityList.add(cityRecord);
                }
            }
            else{
                for (AP_Country_Cities__c thisCity : csList){
                    citySelection cityRecord = new citySelection();
                    cityRecord.selected = false;
                    cityRecord.city = thisCity.City__c;
                    cityList.add(cityRecord);
                }
            }
        }
    }

    //TF
    public class citySelection{
        public Boolean selected{get;set;}
        public String city{get;set;}
        public String percentage{get;set;}
    }

    public void retrieveHQAccountDetails (Id hqId){
        hqAccount = [
            SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode,
            BillingCountry, Airline_designator__c, TradeName__c, Membership_status__c, IATACode__c, Top_Parent__c, Top_Parent__r.BillingStreet, Top_Parent__r.BillingCity, Top_Parent__r.BillingState, Top_Parent__r.BillingPostalCode,
            Top_Parent__r.BillingCountry, Top_Parent__r.Membership_status__c, Top_Parent__r.Name, Top_Parent__r.Airline_designator__c, Top_Parent__r.IATACode__c, Top_Parent__r.TradeName__c,
            Sector__c, Category__c, Due_Diligence_Status__c, Due_Diligence_Remarks__c, Level_of_risk__c, Airline_Prefix__c
            FROM Account
            WHERE Id = :hqId
            LIMIT 1
        ];

        //Only want to display AL HQ details on the joining form, so need to get them if the user applying is from a Branch office
        strParentMembershipStatus = hqAccount.Membership_status__c;

        strParentLegalName = hqAccount.Name;
        strParentTradeName = hqAccount.TradeName__c;
        strParentDesignator = hqAccount.Airline_designator__c;
        strParentIATACode = hqAccount.IATACode__c;
        strParentBillingStreet = hqAccount.BillingStreet;
        strParentBillingCity = hqAccount.BillingCity;
        strParentBillingState = hqAccount.BillingState;
        strParentBillingCode = hqAccount.BillingPostalCode;
        strParentBillingCountry = hqAccount.BillingCountry;
    }

    Public Id retrieveAirlineConcerned(Account hq, String DesignatorCode, String IATACode, String CountryCode, String AL_Name, Id AL_Id) {
        //Get handle for Account (HQ or BR AL Office) for the country of joining application
        Id accountConcernedId;
        String airlinesite_BR;

        //airlinesite_BR = DesignatorCode + ' ' + IATACode + ' ' + CountryCode;

        airlinesite_BR = (IATACode == null && hq.Airline_Prefix__c != null)?
+                            DesignatorCode + ' ' + hq.Airline_Prefix__c + ' ' + CountryCode :
+                            DesignatorCode + ' ' + IATACode + ' ' + CountryCode;

        System.debug('AL BR Site: ' + airlinesite_BR);

        List <Account> concernedAccount = [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.DeveloperName IN ('IATA_Airline', 'IATA_Airline_BR', 'Standard_Account') AND Site = :airlineSite_BR
            LIMIT 1
        ];

        if(concernedAccount.size() > 0) { //Airline has HQ / BR office in country of application
            accountConcernedId = concernedAccount[0].Id;
        } else { //BR does not exist for this Airline, for this country of application, so create Unverified Account
            Account airlineBR = new Account();
            airlineBR.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Standard Account').RecordTypeId;
            airlineBR.Name = AL_Name;
            airlineBR.OwnerId = ISSP_Constant.newAccountOwnerId;
            airlineBR.ParentId = AL_Id;
            airlineBR.Top_Parent__c = AL_Id;
            airlineBR.Site = airlineSite_BR;
            airlineBR.Site_index__c = airlineSite_BR;
            airlineBR.Airline_designator__c = DesignatorCode;
            airlineBR.IATACode__c = IATACode;
            airlineBR.Airline_Prefix__c = hq.Airline_Prefix__c;
            airlineBR.IATA_ISO_Country__c = countryRequirement.Country__c;
            airlineBR.Sector__c = hq.Sector__c;
            airlineBR.Category__c = hq.Category__c;
            airlineBR.Reason_for_creation__c = 'New Airline joining CASS';
            if (!test.isRunningtest())
                insert airlineBR;

            accountConcernedId = airlineBR.Id;
        }

        return accountConcernedId;
    }

    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
    public ApexPages.StandardSetController setConn {
        get {
            if(setConn == null) {
                setConn = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT CaseNumber, CreatedDate, Account_Concerned__r.Site, Id, Subject, Status, Priority, Reason1__c, CaseArea__c, Account.Billing_Address_formated__c
                     FROM Case
                     WHERE RecordType.Name IN ('IDFS Airline Participation Process') AND (Status = 'Draft' OR Status = 'Pending customer' OR Status = 'For Review and Acceptance') AND Origin = 'Portal'
                     AND Visible_on_ISS_Portal__c = true AND ((Case.AccountId = :con.AccountId) OR (Case.Account_Concerned__r.Top_Parent__c = :con.AccountId AND (NOT Case.Reason1__c LIKE '%via%')))
                     ORDER BY CaseNumber DESC]));
            }
            return setConn;
        }
        set;
    }

    public IATA_ISO_Country__c fetchISOCountry(string isocode) {

        IATA_ISO_Country__c isocountry = [
            SELECT Id, Name, CurrencyIsoCode, EU_Country__c, AMS_Pilot_Country__c, Case_BSP_Country__c,IATA_Country_FR__c,IATA_Country_SP__c,IATA_COUNTRY_EN__c,
            IATA_Contry_KR__c,IATA_Country_IT__c,IATA_Country_JP__c,IATA_Country_PT__c,IATA_Country_ZH__c,
            Tax_Number_label__c,Tax_number_format__c,Tax_number_help_text__c, ANG_Enable_NewGen__c, ANG_Portal_Service__c, Airline_EasyPay_Opt_Out_Date__c
            FROM IATA_ISO_Country__c
            WHERE ISO_Code__c = :isocode
         ];

        //ISOCountry eligibility for IEP 
        isoCountryEligible = (isocountry.Airline_EasyPay_Opt_Out_Date__c != null && isocountry.Airline_EasyPay_Opt_Out_Date__c <= Date.today());

        return isocountry;
    }

    public List<SelectOption> getChangeItems() {
        List<SelectOption> options = new List<SelectOption>();
        String masterTableLabel = strLoB + 'Link Master Table';

        options.add(new SelectOption('Change of Address','Change of Local Address'));
        options.add(new SelectOption('Tax Number',' Tax Number'));
        options.add(new SelectOption('Master Table', masterTableLabel));

        return options;
    }

    public List <String> typeOfChangeRequested {get; set;}

    private void getLob(String strLine) {
     //Verify if it's a BSP or a CASS Form
      if(strLine.startsWith('BSP')) {
          isBSP = true;
            strLoB = 'BSP';
        }else{
          isCASS = true;
            strLoB = 'CASS';
        }
    }

    private void sendConfirmationEmail(Case newCase) {
        String emailTemplateName;
        String fromaddress;

        if(newCase.BSPCountry__c.contains('Spain')) {
            emailTemplateName = 'EUR_Case confirmation - online HTML (Spanish)';
            fromaddress = 'IATA Service Centre - Europe (noreply@iata.org)';
        } else if(newCase.BSPCountry__c == 'France') {
            emailTemplateName = 'EUR_Case Confirmation - online HTML (French)';
            fromaddress = 'IATA Service Centre - Europe (noreply@iata.org)';
        } else if(newCase.Region__c == 'Europe') {
            emailTemplateName = 'EUR_Case confirmation - online HTML (English) - Europe';
            fromaddress = 'IATA Europe (noreply@iata.org)';
        } else if(newCase.BSPCountry__c == 'Canada') {
            emailTemplateName = 'A1 - CS Auto-response confirmation (EN/FR)';
            fromaddress = 'IATA Customer Service Americas (noreply@iata.org)';
        } else if(newCase.BSPCountry__c == 'Brazil') {
            emailTemplateName = 'A1 - CS Auto-response confirmation (EN/PT)';
            fromaddress = 'IATA Customer Service Americas (noreply@iata.org)';
        } else if(newCase.Region__c == 'Americas') {
            emailTemplateName = 'A1 - CS Auto-response confirmation (EN/SP)';
            fromaddress = 'IATA Customer Service Americas (noreply@iata.org)';
        } else if(newCase.Region__c != null && newCase.Region__c.contains('China')) {
            emailTemplateName = 'N.ASIA_Case confirmation - online HTML (English)- China';
            fromaddress = 'IATA China - Customer Services (noreply@iata.org)';
        } else if(newCase.Region__c != null && newCase.Region__c.contains('Africa')) {
            fromaddress = 'IATA Customer Service - Africa (noreply@iata.org)';
            emailTemplateName = 'MENA_Case confirmation - online HTML (English)';
        } else {
            emailTemplateName = 'A&P_Case confirmation - online HTML (English)- Singapore';
            fromaddress = 'ISS Operations & Service Centre - Asia & Pacific (' + newCase.BSPCountry__c + ') (noreply@iata.org)';
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> ets = [Select Name, Id From EmailTemplate where Name = :emailTemplateName];
        EmailTemplate et = ets[0];

        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@iata.org'];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(et.Id);
        if ( owea.size() > 0 ) {
        mail.setOrgWideEmailAddressId(owea[0].Id);
    }
        //mail.setSenderDisplayName(fromaddress);
        mail.setTargetObjectId(newCase.ContactId);
        mail.setWhatId(newCase.Id);
        mail.setSaveAsActivity(true);

        emails.add(mail);

        Messaging.sendEmail(emails);
    }

    public void editGSTNumber()
    {
        String editGSTNumberId = Apexpages.currentPage().getParameters().get('recordIdEdit');
        newGSTInfo = [SELECT Id, AP_Process_Form__c, India_Local_VAT_Number__c, India_Local_VAT_Street__c, India_Local_VAT_City__c, India_Local_VAT_State_Name__c, India_Local_VAT_State_Code__c FROM GST_Information__c WHERE Id =: editGSTNumberId LIMIT 1];
        displayPopup = true;
    }

    public void delGSTNumber()
    {
        String delGSTNumberId = Apexpages.currentPage().getParameters().get('recordIdDel');
        GST_Information__c info = [SELECT Id FROM GST_Information__c WHERE Id =: delGSTNumberId LIMIT 1];
        if(info != null){
            delete info;
            list_GSTNumber = [SELECT Id, AP_Process_Form__c, India_Local_VAT_Number__c, India_Local_VAT_Street__c, India_Local_VAT_City__c, India_Local_VAT_State_Name__c, India_Local_VAT_State_Code__c FROM GST_Information__c WHERE AP_Process_Form__c =: newForm.Id];
        }
    }

    public void closePopup() {
        displayPopup = false;
        newGSTInfo = new GST_Information__c();

    }
    public void showNewGSTNumberFields() {
        system.debug('SS## list_GSTNumber: ' + list_GSTNumber);
        displayPopup = true;
    }

    public void addGSTInfo() {

        List<GST_Information__c> list_GSTNumberAux = new List<GST_Information__c>();
        if(newGSTInfo.AP_Process_Form__c == null){
            newGSTInfo.AP_Process_Form__c = newForm.Id;
        }

        list_GSTNumberAux.add(newGSTInfo);

        upsert list_GSTNumberAux;

        list_GSTNumber = [SELECT Id, AP_Process_Form__c, India_Local_VAT_Number__c, India_Local_VAT_Street__c, India_Local_VAT_City__c, India_Local_VAT_State_Name__c, India_Local_VAT_State_Code__c FROM GST_Information__c WHERE AP_Process_Form__c =: newForm.Id];

        displayPopup = false;
        newGSTInfo = new GST_Information__c();
        allGSTFieldsFilled = false;
    }

    public void checkAllFieldGST() {

        if(newGSTInfo.India_Local_VAT_Number__c != '' &&
            newGSTInfo.India_Local_VAT_Street__c != '' &&
            newGSTInfo.India_Local_VAT_City__c != '' &&
            newGSTInfo.India_Local_VAT_State_Name__c != '' &&
            newGSTInfo.India_Local_VAT_State_Code__c != '') {

            allGSTFieldsFilled = true;
        } else {
            allGSTFieldsFilled = false;
        }
    }
    
    /**
        Find in ISSP_AP_FieldLists those fields marked as mandatory for current DPC System
    **/
    public list<String> getMandatoryFieldsForCommission() {
        String dpcSystem = newCase.Account_Concerned__r.IATA_ISO_Country__r.AMS_Settlement_System__r.DPC_System__c;
        list<String> listFieldsToCheck = ISSP_AP_FieldLists.bspCommissionMandatoryFields.get(dpcSystem);
        if (listFieldsToCheck==null) return new list<String>();
        return listFieldsToCheck;
    }
}