public without sharing class ISSP_SISMembershipApplicationForm_Ctrl{

    public static String AMAZON_CREDENTIALS_NAME = 'GenericAttach';
    public static final Map<String,Schema.RecordTypeInfo> MAP_AP_RT = Schema.SObjectType.AP_Process_Form__c.getRecordTypeInfosByDeveloperName();
    public static final Id AP_RT_ISPA = MAP_AP_RT.get('SIS_Application_ISPA').getRecordTypeId();
    public static final Id AP_RT_ISUA = MAP_AP_RT.get('SIS_Application_ISUA').getRecordTypeId();
    public static final Id AP_RT_TOU  = MAP_AP_RT.get('SIS_Application_TOU').getRecordTypeId();
    public static final Map<Id,String> MAP_RECORDTYPE_FORMS = new Map<Id,String>{
        AP_RT_ISPA => 'ISPA',
        AP_RT_ISUA => 'ISUA',
        AP_RT_TOU  => 'TOU'
    };
    public static final Map<String,list<String>> MAP_STEPS = new Map<String,list<String>>{
        AP_RT_ISPA => new list<String>{'A. ' + Label.ISSP_SIS_Membership_Review_Country_Req,'B. ' + Label.ISSP_SIS_Membership_Fill_The_Form,'C. ' + Label.ISSP_SIS_Membership_Submit_To_IATA},
        AP_RT_ISUA => new list<String>{'A. ' + Label.ISSP_SIS_Membership_Review_Country_Req,'B. ' + Label.ISSP_SIS_Membership_Fill_The_Form,'C. ' + Label.ISSP_SIS_Membership_Submit_To_IATA},
        AP_RT_TOU  => new list<String>{'A. ' + Label.ISSP_SIS_Membership_Fill_The_Form,'B. ' + Label.ISSP_SIS_Membership_Submit_To_IATA}
    };
    public Boolean getisISPA() {return this.newForm.RecordTypeId==AP_RT_ISPA;}
    public Boolean getisISUA() {return this.newForm.RecordTypeId==AP_RT_ISUA;}
    public Boolean getisTOU()  {return this.newForm.RecordTypeId==AP_RT_TOU;}
    public list<String> getSteps()  {
        return MAP_STEPS.get(this.newForm.RecordTypeId);
    }

    public Integer currentStep {get;set;}
    public Sis_Management_Type__mdt sisType {get;set;}
    public AP_Process_Form__c newForm {get;set;}
    public Account account {get;set;}
    @TestVisible private Case newCase;

    /**
        Controller
    **/
    public ISSP_SISMembershipApplicationForm_Ctrl(){
        // this id can be a APProcessForm or a Case Id
        String inputId = Apexpages.CurrentPage().getParameters().get('id');
        String inputStep = Apexpages.CurrentPage().getParameters().get('step');
        this.newForm = retrieveAPProcessForm(inputId);
        this.newCase = this.newForm.Case__r;
        this.account = retrieveAccount(this.newForm.Airline__c);
        this.sisType = retrieveSisType();
        // step 1 is for requirements, if there are no requirements then begin in step 2
        this.currentStep = this.sisType.Requirements_Text__c==null? 2: 1;
        if (inputStep!=null) {
            Integer newStep = Integer.ValueOf(inputStep);
            if (newStep==1||newStep==2||newStep==3) this.currentStep=newStep;
        }
    }
    
    /**
        Find requirements text from the type of SIS membership
    **/
    private Sis_Management_Type__mdt retrieveSisType(){
        try {
            String typeName = MAP_RECORDTYPE_FORMS.get(this.newForm.RecordTypeId);
            return [
                SELECT Id, DeveloperName, MasterLabel, Description_Label__c, 
                Sending_e_invoices__c, Receiving_e_invoices__c, ERP_Integration__c, Data_Validation__c,
                Enables_Automated_Posting_Reconciliati__c, Online_Functions_and_Dashboard__c, 
                Full_Traceability__c, Transaction_Fees__c, Invoice_and_details_in_Excel_format__c,
                Payment_Status__c, Requirements_Text__c
                FROM Sis_Management_Type__mdt
                WHERE DeveloperName = :typeName];
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ISSP_SIS_Membership_Type_Not_Valid));
            return null;
        }
    }

    /**
        Get all fields in object AP_Process_Form__c form input id (case id or form id)
    **/
    public AP_Process_Form__c retrieveAPProcessForm(Id inputId){
        return [
            SELECT Id, Type__c, Type_of_participation_desired__c, Airline_Local_address_in_the_BSP_Country__c,
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
            Canada_Has_Principal_Office__c,Canada_Provincial_Offices__c,Canada_LocalVAT_Info__c, GSSA_Legal_Name_Formula__c, GSSA_Address_Formula__c,
            ANG_Airline_accepts_EasyPay_tr_in_BSP__c,Minimum_Commission_Rate__c, Maximum_Commission_Rate__c, Default_Commission_Rate__c, Type_of_Change_Requested__c,
            Legal_Name_of_company__c,Company_address__c,Company_city__c,Company_State__c,Postal_code__c,Company_Country__c, Company_Country__r.Name, Company_Trade_Name__c,
            Super_User_Salutation__c,Super_User_First_Name__c,Super_User_Last_Name__c,Super_User_Email_Address__c,Super_User_Phone_Number__c,Super_User_Mobile_Number__c,Super_User_Fax_Number__c,
            Is_AA_Member__c,Digital_Signature_application__c,Digital_Signature_verification__c,Legal_Archiving__c,Billing_Value_Determination__c,Billing_Value_Confirmation__c,Auto_billing__c,
            Do_you_have_an_iiNET_account__c,Is_your_company_joining_the_Clearing_Hou__c,Select_Bank_Account__c,Is_company_subject_to_EU_laws__c,EU_Data_Privacy_Laws__c,
            Company_Registration_ID__c,TAX_VAT_Registration_Number__c,Billing_File_Emrgcy_Contact_Number__c,Who_requested_to_join_TOU__c,Legal_Name_of_account__c,
            RecordTypeId, RecordType.DeveloperName, Do_you_want_to_add_Bank_Details__c, Data_Exporting_Organization_Name__c,Data_Exporting_Organization_Address__c,
            Data_Exporting_Organization_Phone__c,Data_Exporting_Organization_Fax__c,Data_Exporter_Name__c,Data_Exporter_Signatory_Name__c,Data_Exporter_Signatory_Position__c,
            Contact_Title__c,Contact_First_name__c,Contact_Last_name__c,Contact_email__c,Contact_number__c,
            Case__c, Case__r.CaseNumber, Case__r.BSPCountry__c, Case__r.Id, Case__r.RecordtypeId, Case__r.AccountId, Case__r.CaseArea__c, Case__r.Reason1__c, Case__r.Status, Case__r.Type,
            Case__r.Visible_on_ISS_Portal__c
            FROM AP_Process_Form__c
            WHERE Id = :inputId OR Case__c = :inputId
        ];
    }

    /**
        Get all fields from input Account Id
    **/
    private Account retrieveAccount(Id accountId){
        Account account = [
            SELECT Id,Name,Sector__c,Category__c,Legal_name__c,Airline_designator__c,
                BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,
                IATA_ISO_Country__c, Date_of_last_clearance__c, Clearance_level__c,
                IATA_ISO_Country__r.Name
            FROM Account 
            WHERE Id=:accountId 
        ];
        // find country, not because we want to update it, but to use it in the Copy Company Information method in the ISPA component
        list<IATA_ISO_Country__c> listCountries = [SELECT Id FROM IATA_ISO_Country__c WHERE Name LIKE :account.BillingCountry LIMIT 1];
        if (!listCountries.isEmpty()) {
            account.IATA_ISO_Country__c = listCountries[0].Id;
        }
        return account;
    }

    /**
        Updates current Ap Process form, and makes some validations depending on the page we are
    **/
    private Boolean saveDraft() {
        System.Savepoint savepoint = Database.setSavepoint();
        try {
            if (this.currentStep==2) {
                //clean section 3
                if (this.newForm.Is_AA_Member__c == 'No') {
                    this.newForm.Billing_Value_Determination__c = null;
                    this.newForm.Billing_Value_Confirmation__c = null;
                    this.newForm.Auto_billing__c = null;
                }
                //clean section 4
                if (this.newForm.Do_you_have_an_iiNET_account__c == 'No') {
                    this.newForm.IINET_account_number__c = null;
                }
                //clean section 6
                if (this.newForm.Is_your_company_joining_the_Clearing_Hou__c == 'No') {
                    this.newForm.Select_Bank_Account__c = null;
                }
                //clean section 7
                if (this.newForm.Is_company_subject_to_EU_laws__c == 'No') {
                    this.newForm.EU_Data_Privacy_Laws__c = null;
                }
                //Update Form
                update this.newForm;

                //update Case
                list<IATA_ISO_Country__c> listCountries = [
                    SELECT Id, Name FROM IATA_ISO_Country__c WHERE Id = :this.newForm.Company_Country__c];
                if (!listCountries.isEmpty()) {
                    this.newCase.BSPCountry__c = listCountries[0].Name;
                }
                this.newCase.Visible_on_ISS_Portal__c = true;
                //Apply default case assignment rules
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                this.newCase.setOptions(dmo);
                update this.newCase;
            }

            if (this.currentStep==3 && this.newForm.Accept_terms_and_conditions__c) {
                //Update Form
                update this.newForm;
                //this.newCase.Status = 'Open';
                update this.newCase;
            }
            return true;

        } catch(Exception e) {
            Database.rollback(savepoint);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return false;
        }
    }

    /**
        Send to main home page after saving
    **/
    public PageReference saveFormAndLeave() {
        if(saveDraft()) {
            return Page.ISSP_Homepage;
        }
        return null;
    }

    /**
        Goes to previous step after saving, unless we are in step one, then it goes to main app page
    **/
    public PageReference saveFormAndGoBack() {
        if(saveDraft()) {
            if (this.currentStep==1) {
                return Page.ISSP_SISMembershipApplication;
            }
            this.currentStep--;
            if (this.currentStep==1 && this.sisType.Requirements_Text__c==null) {
                return Page.ISSP_SISMembershipApplication;
            }
        }
        return null;
    }

    /**
        This is the action of submit button
        It actually sends the form to be processes, so it is markes as Open
    **/
    public PageReference submitForm() {
        this.newCase.Status = 'Open';
        if(validateFields() && saveDraft()) {
            // upload agreement
            uploadForm(this.newCase.Id);

            PageReference pageref = Page.ISSP_Case;
            pageref.getParameters().put('caseId',this.newForm.Case__c);
            pageref.getParameters().put('mid','M1S2');
            pageref.setRedirect(true);
            return pageref;
        }
        return null;
    }

    /**
        Generates the agreement form as a PDF and uploads it to Amazon
    **/
    @future(callout=true)
    private static void uploadForm(Id caseId) {
        PageReference formPage = new PageReference('/apex/ISSP_SISMembershipApplicationFormPDF?id=' + caseId);
        String fileName = 'SISMembershipForm.pdf';
        String fileIdentifier = 'SIS_Membership_Form';
        Blob content = Test.isRunningTest()? Blob.ValueOf(''): formPage.getContent();
        String contentType = 'application/pdf';
        uploadToAmazon(caseId, fileName, fileIdentifier, content, contentType);
    }

    /**
        Upload input file to amazon, including the amazonfile__c record
    **/
    private static void uploadToAmazon(Id caseId, String fileName, String fileIdentifier, Blob content, String contentType) {
        //uplaod file
        AmazonCredentials credential = AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME);
        String fullFileName = '500/' + String.valueOf(caseId) + '/' + fileName;
        if (!amazonRest.uploadFile(credential, fullFileName, contentType, content)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Internal error in submit'));
            return;
        }
        //create amazonFile__c record
        AmazonFile__c amazonFile = new AmazonFile__c(
            Name = fileName,
            Full_Name_Unique__c = '500/' + String.valueOf(caseId) + '/' + fileName,
            File_Identifier__c = fileIdentifier,
            File_Identifier_picklist__c = fileIdentifier,
            Review_Status__c = 'Pending',
            RecordTypeId = Schema.SObjectType.AmazonFile__c.RecordTypeInfosByName.get('AMS File').RecordTypeId,
            Size_MB__c = content.size()* 0.000001, //convert to MB
            isPublic__c = true,
            Case__c = caseId
        );
        try {
            insert amazonFile;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    /**
        Goes to next step after saving
    **/
    public PageReference saveFormAndGoForward() {
        if(validateFields() && saveDraft()) {
            this.currentStep++;
        }
        return null;
    }

    /**
        Check validity of certain fields, depending on the current page
        Some fields are mandatory and some others are dependent fields
    **/
    private Boolean validateFields() {
        if (this.currentStep==1) {
            return true;
        }
        if (this.currentStep==2) {
            if (getisISPA()||getisISUA()) {
                list<String> listMandatoryFileId = new list<String>();
                if (getIsValidDueDiligence()) {
                    listMandatoryFileId.add('COI');
                    listMandatoryFileId.add('Shareholders_List');
                }
                if (this.newForm.Do_you_want_to_add_Bank_Details__c=='Yes') {
                    listMandatoryFileId.add('BankMandate');
                    listMandatoryFileId.add('Passport');
                }
                return checkMandatoryFiles(listMandatoryFileId);
            }
            return true;
        }
        if (this.currentStep==3) {
            return true;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Wrong step number'));
        return false;
    }

    /**
        Find all related amazon fiels to current AP process form
    **/
    private map<String,list<AmazonFile__c>> retrieveMapAmazonFiles() {
        map<String,list<AmazonFile__c>> mapAmazonFiles = new map<String,list<AmazonFile__c>>();
        for (AmazonFile__c file: [
                SELECT Id, File_Identifier__c
                FROM AmazonFile__c
                WHERE Case__c = :this.newForm.Case__c]) {
            list<AmazonFile__c> listFiles = mapAmazonFiles.get(file.File_Identifier__c);
            if (listFiles==null) {
                listFiles = new list<AmazonFile__c>();
            }
            listFiles.add(file);
            mapAmazonFiles.put(file.File_Identifier__c, listFiles);
        }
        return mapAmazonFiles;
    }

    /**
        Check if an Amazon Fiel is mandatory for current AP process form
    **/
    private Boolean checkMandatoryFiles(list<String> listMandatoryFileId) {
        map<String,list<AmazonFile__c>> mapFiles = retrieveMapAmazonFiles();
        for (String fielId: listMandatoryFileId) {
            list<AmazonFile__c> listAmazonFiles = mapFiles.get(fielId);
            if (listAmazonFiles==null || listAmazonFiles.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ISSP_SIS_Membership_Missing_Input_File));
                return false;
            } else if(listAmazonFiles.size()>1) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ISSP_SIS_Membership_Only_One_File));
                return false;
            } 
        }
        return true;
    }

    /**
        Lsit of countries used to populate picklists
    **/
    public list<SelectOption> getListCountryOptions() {
        list<SelectOption> listOptions = new list<SelectOption>();
        for (IATA_ISO_Country__c country: [SELECT Id,Name FROM IATA_ISO_Country__c]) {
            listOptions.add(new SelectOption(country.Id,country.Name));
        }
        return listOptions;
    }

    /**
        Checks if current AP process form has a valid Due diligenece (defined in a helper class)
    **/
    public Boolean getIsValidDueDiligence() {
        return CaseDueDiligence.isValid(this.newCase, this.account);
    }
}