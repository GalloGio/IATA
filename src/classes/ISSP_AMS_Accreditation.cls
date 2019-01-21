public without sharing class ISSP_AMS_Accreditation {
    private static String SAAM_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM
    private static String OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
    private static String RECORD_TYPE_ID = SAAM_RECORD_TYPE_ID;

    public static String FILE_ID_FOR_PARTNERSHIP  {get{ return 'Signed Application Form';}}
    public static  Integer MAX_IFAP_Contacts {get{ return 1;} private set;}
    private static integer MAX_AgencyAccount_LOOKUPS_ALLOWED = 20;
    private static final String WAREHOUSE_LEASE = 'WAREHOUSE_LEASE';
    private static final String OFFICE_LEASE = 'OFFICE_LEASE';
    private static final String WAREHOUSE_SUBCONTRACTED = 'WAREHOUSE_SUBCONTRACTED';
    private static final String CGO_SIGNED_CONTRACT = 'CGO_SIGNED_CONTRACT';
    private static final String NOC_SIGNED_CONTRACT = 'NOC_SIGNED_CONTRACT';
    private static final String BNK_ACCNT_DTLS = 'BNK_ACCNT_DTLS';
    private static final String PCI_COMPLIANCE = 'PCI_COMPLIANCE';
    private static final String OTHERS = 'OTHERS';
    private static final string ISO_8859_1_regEx = '^[\\x00-\\x7F\\xA0-\\xFF]+$';  //Reg exp to limit inputted chars to ISO-8859-1
    private String vSAAMCaseId;
    @TestVisible private Boolean isScopeOfChangeChanged = false;
    public String hqCountryISOCode;
    private Id vHQAccountId;
    public Id brAccountId {get; set;}
    public List<SelectOption> agencyCodesConcerned {get; set;}
    private Id vAccountConcernedId;
    public String amsCountryLabel {get; set;}
    public String memberairlineid {get; set;}
    public String amsAllLangCountryLabel {get; set;}
    public String amsContactCountry {get; set;}
    public String amsOfficeType {get; set;}
    public String amsAgentType {get; set;}
    public String agentCaseType {get; set;} //Used to set TIDS, Sales Agent (SA) from links on ISSP_AMSCase
    public String amsLocationType {get; set;}
    public String amsLocationTypeLabelHq {get; set;}
    public String amsLocationTypeLabel {get; set;}
    public String amsIsGSA {get; set;}
    public String noCLocationType {get; set;}
    public boolean isGSARequired;
    public String applyLanguage {get; set;}
    public String displayLanguage {get; set;}
    public string sector {get; set;}
    public string sectorDisplay {get; set;}
    public string sectorValue {get; set;}
    public string agencyCategory {get; set;}
    public string baseUrl {get; set;}
    public string step1GoToNumber {get; set;}

    public String vatNumber {get; set;}
    public string stepNumber {get; set;}
    public string editContactId {get; set;}
    public string editSalesId {get; set;}
    public string contactType {get; set;}
    public string ownerLabel {get; set;}
    public string roleLabel {get; set;}
    public string legalStatus {get; set;}
    public string ownerLabelAfterChange {get; set;}
    public string roleLabelAfterChange {get; set;}
    public string legalstatusAfterChange {get; set;}
    public string pilotlist {get; set;}
    public string jsonCountriesMap {get; set;}
    public string jsonCountriesNotAllowedList {get; set;}

    //Variables set from VF page to lookup Travel / Cargo agnt details
    public string iatacode {get; set;}
    public string agentsector {get; set;}
    public string prevagentHistory {get; set;}
    public string iatanAccount {get;set;}

    //Contextual Help text set based on user's portal language
    public string txtHelpCurrency {get; set;}
    public string txtHelpMinPaidCapital {get; set;}
    public string txtHelpRegisteredCapital {get; set;}
    public string txtHelpPaidUpCapital {get; set;}
    public string txtHelpTaxNumber {get; set;}
    public string txtHelpAuthorisedSig {get; set;}
    public string txtHelpFinContact {get; set;}
    public string txtHelpPortalAdmin {get; set;}
    public string txtHelpGrossSales {get; set;}
    public string txtHelpTrainedStaffOrganization {get; set;} //FM - AMSU-20
    public string txtHelpTrainedStaffReference {get; set;} //FM - AMSU-20

    //Labels to come up in user's portal language (and not lang set on VF page)
    public string txtLocalAgencyDetailsTitle {get; set;}
    public string txtLocalAgencyDetailsPleaseEnter {get; set;}
    public string txtLocalAgencyDetailsChangePleaseEnter {get; set;}
    public string txtLocalAgencyDetailsLegalNameENG {get; set;}
    public string txtLocalAgencyDetailsLegalName {get; set;}
    public string txtLocalAgencyDetailsNoCompany {get; set;}
    public string txtLocalAgencyDetailsCopyAddress {get; set;}
    public string txtLocalAgencyDetailsPhysicalAddress {get; set;}
    public string txtLocalAgencyDetailsCorrespondenceAddress {get; set;}
    public string txtLocalAgencyDetailsFirstNameENG {get; set;}
    public string txtLocalAgencyDetailsFirstNameLocal {get; set;}
    public string txtLocalAgencyDetailsLastNameENG {get; set;}
    public string txtLocalAgencyDetailsLastNameLocal {get; set;}
    public string txtLocalAgencyDetailsCompanyNameENG {get; set;}
    public string txtLocalAgencyDetailsCompanyNameLocal {get; set;}
    public string txtLocalAgencyDetailsNoLocalFirstName {get; set;}
    public string txtLocalAgencyDetailsNoLocalLastName {get; set;}
    public string txtLocalAgencyDetailsNoLocalCompanyName {get; set;}

    //Set header labels that are to remain in portal user's language
    public string lblStepA {get; set;}
    public string lblStepB {get; set;}
    public string lblStepC {get; set;}
    public string lblStepD {get; set;}
    public string lblStepE {get; set;}
    public string lblNoCStepA {get; set;}
    public string lblNoCStepC {get; set;}
    public string lblNoCStepD {get; set;}
    public string lblStep1Title {get; set;}
    public string lblNocRequest {get; set;}
    public string lblPAXTitle {get; set;}
    public string lblCargoTitle {get; set;}
    public string lblEACPTitle {get; set;}
    public string lblCASSTitle {get; set;}
    public string lblImporAgentTitle {get; set;}
    public string lblCourierTitle {get; set;}

    public boolean isNewCase {get; set;}
    public boolean isEUcountry {get; set;}
    public boolean isCASSCountry {get; set;}
    public boolean isCASSImport {get; set;}
    public boolean isHOAccredited {get; set;}
    public boolean isUserAccAccredited {get; set;}
    public boolean isValError {get; set;}
    public boolean isNoticeOfChange {get; set;}
    public boolean bIsAdmin {get; set;}     //identify if a user is an administrator or not
    public boolean isHOcontact {get; set;}  // identify whether a user is from the HO account or not

    public boolean isStep1 {get; set;}
    public boolean isStep2 {get; set;}
    public boolean isStep3 {get; set;}
    public boolean isStep4 {get; set;}
    public boolean isStep5 {get; set;}
    public boolean isFinalStep {get; set;}
    public boolean redirectToStepE {get; set;}
    public boolean isBankAccountChange {get; set;}
    public boolean isEligableForChange {get; set;}
    public boolean isTerminatedAgent {get; set;}
    public boolean isNewHOforAccredAgent {get; set;}
    public boolean isAuthorizedSignature {get;set;}

    public Case newCase {get; set;}
    public Contact con {get; set;}
    public Account hqAccount {get; set;}
    public Account accountConcerned {get; set;}
    public Account CargoAgentAccount {get; set;}
    public Account IATANAgentAccount {get; set;}
    public Account TravelAgentPrevAccount {get; set;}
    public AMS_Pax_Accreditation_Form__c newForm {get; set;}
    public ISSP_AMS_Statement_International_Sales__c newInternationalSales {get; set;}
    public IATA_ISO_Country__c isocountry {get; set;}
    public List<AMS_Accreditation_Requirement__c> List_CountryReqments {get; set;}
    public AMS_Accreditation_Contact__c newContact {get; set;}
    public List<AMS_Accreditation_Contact__c> amsDuplicateContactList {get; set;}
    public ISSP_PDF_Per_Region__c PDFPerRegionCS {get; set;}

    integer cntAgencyLookups;

    public List<SelectOption> applyLanguageList {get; set;}
    public List<SelectOption> isGSAList {get; set;}
    public List<SelectOption> itemsYesNo {get; set;}
    public List<SelectOption> OfficeTypes;
    public List<String> noticeOfChangeList {get; set;}

    public List<regionSelection> cargoRegionList {get; set;}
    public List<regionSelection> cargoRegionListWithValue {get; set;}
    public List<specialTraffic> specialTrafficList {get; set;}

    public Boolean contactSaved {get; set;}
    public Boolean salesSaved {get; set;}
    public Boolean accountUpdated {get; set;}
    public Boolean passedFormValidation {get; set;}
    public Boolean formUpdated {get; set;}

    public transient Blob fileBody {get; set;}
    public string fileName {get; set;}

    public Boolean isAddCompanyModal {get; set;}
    public string companyModalNameOfEmployer {get; set;}
    public string companyModalAddress {get; set;}

    public string roleLabelType {get; set;}
    public string ownerLabelType {get; set;}
    public string roleLabelTypeAfterChange {get; set;}
    public string ownerLabelTypeAfterChange {get; set;}

    public string includedPageName {get; set;}
    public string includedSummaryPage {get; set;}


    // facilities implementation for cargo form
    public String consignments {get; set;}
    public String isleased {get; set;}
    public String issubcontractor {get; set;}
    public Id facilitiesId {get; set;}
    //public List<AMS_Facility__c> facilityList {get;set;}
    public AMS_Facility__c facilityInContext {get; set;}
    public String facilityRecordTypeName {get; set;}
    public String accountType {get; set;}
    private String defaultSectorValue;

    // trained staff implementation for cargo form
    public AMS_Accreditation_Contact__c trainedStaffContact {get; set;}
    //public List<AMS_Accreditation_Contact__c> trainedStaffList{get;set;}
    public Id trainedStaffId {get; set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    public String commParamFirst { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}
    public String agencyCodesConcernedForPDF {get; set;}

    public boolean newAccreditationModels {get; set;}
    public boolean namEnabled {get; set;}
    public List<AMS_Accreditation_Contact__c> checkAllOwners {get; set;}

    public String accredidationType {get; set;}
    public Integer cntIFAPContacts {get; set;}

    public Boolean namPaxAgent {get; set;}

    public Boolean getnewlabels() {
        if (isocountry==null) return false;
        return isocountry.AMS_Accreditation_New_Labels__c;
    }

    public ANG_ProductComparisonHelper helper {get; set;}

    public Boolean flagShowOptInOutButton {get; set;}
    public Boolean flagShowOptInOutButtonDisabled {get; set;}
    public Boolean isIFAPContact {get; set;}
    public String pEfectiveDateStr {get;set;}

    public String optInOutMessage {get; set;}
    public String optInOutModalTitle {get; set;}

    public String optInOutSuccessMessage {get; set;}
    public String optInOutBtn {get; set;}
    public String optInOutErrorNoDate {get; set;}

    public List<SelectOption> countryList {
        get {
            if (countryList == null) {
                countryList = new List<SelectOption>();
                countryList.add(new SelectOption('', ''));
                
                Set<String> isoCodesToExclude = new Set<String>{'IO','TF','GS','UM','UP','VI'};

                for (IATA_ISO_Country__c cnt: IATAIsoCountryDAO.getIsoCountries()) {
                    if (cnt.Region__c == null || isoCodesToExclude.contains(cnt.Iso_Code__c)) continue;
                        
                    countryList.add(new SelectOption(cnt.Informatica_Value__c.toUpperCase(), cnt.Name));
                }

                countryList.sort();
            }
            return countryList;
        }
        private set;
    }
    public Boolean isMultiCountry {get; private set;}
    public Boolean isMultiCountryStarted {get; private set;}
    public Boolean isMultiCountryNewAE {get; private set;}

    public List<AMS_Pax_Accreditation_Form__c> multiCountryApplicationForms {
        get {
            return (multiCountryApplicationForms == null) ? fetchMultiCountryApplicationForms() : multiCountryApplicationForms;
        }
        private set;
    }

    public Boolean mcApplicationFormsFound {
        get {
            if (mcApplicationFormsFound == null) mcApplicationFormsFound = false;
            return mcApplicationFormsFound;
        }
        private set;
    }

    public String mcFormIdToDelete {get; set;}
    public String currentMCFormId {get; private set;}

    public ISSP_AMS_Accreditation() {
        isNewCase = true;
        isStep1 = false;
        isStep2 = false;
        isStep3 = false;
        isStep4 = false;
        isStep5 = false;
        isFinalStep = false;
        isHOAccredited = false;
        isUserAccAccredited = false;
        isEUcountry = false;
        isCASSCountry = false;
        isCASSImport = false;
        isNoticeOfChange = false;
        isBankAccountChange = false;
        isEligableForChange = false;
        isTerminatedAgent = false;
        isNewHOforAccredAgent = false;
        bIsAdmin = false;
        stepNumber = '';
        cntAgencyLookups = 0;
        newAccreditationModels = false;
        namEnabled = false;
        cntIFAPContacts = 0;
        isAuthorizedSignature = false;
        isMultiCountry = false;
        isMultiCountryNewAE = false;
        isMultiCountryStarted = false;

        newCase = new Case();
        newForm = new AMS_Pax_Accreditation_Form__c();
        newContact = new AMS_Accreditation_Contact__c();
        trainedStaffContact = new AMS_Accreditation_Contact__c();
        newInternationalSales = new ISSP_AMS_Statement_International_Sales__c();
        baseUrl = url.getsalesforcebaseurl().toexternalform();
        amsDuplicateContactList = new List<AMS_Accreditation_Contact__c>();
        accountConcerned = new Account();
        noticeOfChangeList = new List<String>();
        agencyCodesConcerned = new List<SelectOption>();

        amsContactCountry = '';

        popContact();  //Get the contact details of currently logged in user

        getPilotCountries();
        getCountriesMap();

        newCase.IFAP_Country_ISO__c = con.Account.IATA_ISO_Country__r.ISO_Code__c;
        isocountry = fetchISOCountry(newCase.IFAP_Country_ISO__c);

        defaultSectorValue = System.currentPageReference().getParameters().get('sectorValue');
        String defaultAmsLocationType = System.currentPageReference().getParameters().get('accredType');

        if (defaultAmsLocationType != null && defaultAmsLocationType != '') amsLocationType = defaultAmsLocationType;

        if (isocountry != null) {
            isEUcountry = isocountry.EU_Country__c;

            if (isocountry.CASS_Country_free_text__c != 'No CASS')
                isCASSCountry = true;

            if (isocountry.CASS_Import__c == 'Yes')
                isCASSImport = true;

            amsAllLangCountryLabel = getAmsAllLangCountryLabel(isocountry, UserInfo.getLanguage());
        }

        if(con.Authorized_Signatory__c == true) isAuthorizedSignature = true;

        sector = con.Account.Sector__c;
        agencyCategory = con.Account.Category__c;

        if (con.Account.Top_Parent__c == null) { //User is from HQ Account
            vHQAccountId = con.AccountId;
            fetchHQAccountDetails();
            if (con.Account.IATACode__c != null && con.Account.RecordType.DeveloperName == 'IATA_Agency' && con.Account.Status__c != 'Terminated' && con.Account.Status__c != 'Not accreditated' && con.Account.Status__c != 'New application pending' && con.Account.Status__c != 'No longer a customer' && con.Account.Status__c != 'Not in operation' &&
                (con.Account.Status__c != 'Endorsed' || (con.Account.Location_Class__c != 'V' && con.Account.Location_Class__c != 'P') || (isocountry != null && isocountry.ISO_Code__c != 'US' && isocountry.ISO_Code__c != 'UP')) &&
                (con.Account.Status__c != 'Listed' || (isocountry != null && isocountry.ISO_Code__c != 'CN' )) ){

                isHOAccredited = true; //This is an accredited  Agency Account
                isUserAccAccredited = true;
            }
            isHOcontact = true;
        } else { //Get Id for HQ Account when user's Account is a branch office
            vHQAccountId = con.Account.Top_Parent__c;
            fetchHQAccountDetails();

            if (con.Account.IATACode__c != null && con.Account.RecordType.DeveloperName == 'IATA_Agency' && con.Account.Status__c != 'Terminated' && con.Account.Status__c != 'Not accreditated' && con.Account.Status__c != 'New application pending' && con.Account.Status__c != 'No longer a customer')
                isUserAccAccredited = true;

            if (hqAccount.RecordType.DeveloperName == 'IATA_Agency' && hqAccount.Status__c != 'Terminated' && hqAccount.Status__c != 'Not accreditated' && hqAccount.Status__c != 'No longer a customer' && hqAccount.Status__c != 'New application pending' && hqAccount.Status__c != 'Not in operation' &&
                (hqAccount.Status__c != 'Endorsed' || (hqAccount.Location_Class__c != 'V' && hqAccount.Location_Class__c != 'P') || (isocountry != null && isocountry.ISO_Code__c != 'US' && isocountry.ISO_Code__c != 'UP')) &&
                (hqAccount.Status__c != 'Listed' || (isocountry != null && isocountry.ISO_Code__c != 'CN' )) )
                isHOAccredited = true; //This is an accredited  Agency Account

            isHOcontact = false;
        }

        if (isMultiCountryStarted) fetchMultiCountryApplicationForms();

        if(hqAccount.Status__c == 'Terminated')
            isTerminatedAgent = true;

        hqCountryISOCode = hqAccount.IATA_ISO_Country__r.ISO_Code__c;
        newForm.HO_Account__c = vHQAccountId;

        //Need to translate sector for display

        if(defaultSectorValue != '' && defaultSectorValue != null) {
            sectorValue = defaultSectorValue;
        } else {
            if (sector == AMS_Utils.SECTOR_PASSENGER) {
                sectorDisplay = Label.ISSP_Travel_Agent;
                sectorValue = 'Travel_Agent';
            } else {
                sectorDisplay = isocountry.AMS_Accreditation_New_Labels__c? Label.ISSP_Cargo_Agent_New: Label.ISSP_Cargo_Agent;
                sectorValue = 'Cargo_Agent';
            }
        }

        // NewGen is only valid for Travel Agents
        newAccreditationModels = (isocountry.ANG_Enable_NewGen__c == true && sectorValue.StartsWith('Travel_Agent')) ;
        namEnabled = isocountry.ANG_Enable_NewGen__c;

        checkEligibilityForAChange();

        applyLanguageList = new List<SelectOption>();
        applyLanguageList.add(new SelectOption('en_US', 'English'));
        applyLanguageList.add(new SelectOption('fr', 'Français'));
        applyLanguageList.add(new SelectOption('es', 'Español'));

        applyLanguage = UserInfo.getLanguage();
        displayLanguage = UserInfo.getLanguage();

        if (applyLanguage != 'en_US' && applyLanguage != 'es' && applyLanguage != 'fr') applyLanguage = 'en_US';

        //Labels set in controller remain in portal's user language
        lblStepA = isocountry.AMS_Accreditation_New_Labels__c? Label.ISSP_AMS_Step1_ProgressBar_New: Label.ISSP_AMS_Step1_ProgressBar;
        lblStepB = Label.ISSP_AMS_Step2_ProgressBar;
        lblStepC = Label.ISSP_AMS_Step3_ProgressBar;
        lblStepD = Label.ISSP_AMS_Step4_ProgressBar;
        lblStepE = communityName == 'CNS' ? Label.ISSP_AMS_Step5_ProgressBar_CNS : Label.ISSP_AMS_Step5_ProgressBar;

        lblNoCStepA = Label.ISSP_AMS_NoC_StepA;
        lblNoCStepC = Label.ISSP_AMS_NoC_StepC;
        lblNoCStepD = communityName == 'CNS' ? Label.ISSP_AMS_NOC_StepD_ProgressBar_CNS : Label.ISSP_AMS_NOC_StepD_ProgressBar;

        lblStep1Title = communityName == 'CNS' ? Label.ISSP_AMS_Step1_Title_CNS : isocountry.AMS_Accreditation_New_Labels__c ? Label.ISSP_AMS_Step1_Title_New : Label.ISSP_AMS_Step1_Title;

        lblNocRequest = Label.ISSP_AMS_NoC_Request_for_Change;
        lblPAXTitle = Label.ISSP_AMS_StepsAll_Travel_Title;

        lblCargoTitle = communityName == 'CNS' ? Label.ISSP_AMS_StepsAll_Cargo_Title_CNS : isocountry.AMS_Accreditation_New_Labels__c ? Label.ISSP_AMS_StepsAll_Cargo_Title_New : Label.ISSP_AMS_StepsAll_Cargo_Title;

        lblEACPTitle = Label.ISSP_AMS_StepsAll_Cargo_EACP_Intermediary_Title;
        lblCASSTitle = Label.ISSP_AMS_StepsAll_Cargo_CASS_Associate_Title;
        lblImporAgentTitle = Label.ISSP_AMS_StepsAll_Import_Agent_Title;
        lblCourierTitle = Label.ISSP_AMS_StepsAll_Courier_Title;

        if (ApexPages.currentPage().getParameters().containsKey('step'))
            stepNumber = ApexPages.currentPage().getParameters().get('step');

        if (ApexPages.currentPage().getParameters().containsKey('isNoticeOfChange'))
            isNoticeOfChange = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isNoticeOfChange'));

        if (ApexPages.currentPage().getParameters().containsKey('isBankAccountChange'))
            isBankAccountChange = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isBankAccountChange'));

        if (ApexPages.currentPage().getParameters().containsKey('isMultiCountryNewAE'))
            isMultiCountryNewAE = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isMultiCountryNewAE'));

        if (ApexPages.currentPage().getParameters().containsKey('currentMCFormId'))
            currentMCFormId = String.valueOf(ApexPages.currentPage().getParameters().get('currentMCFormId'));
            
        if (isMultiCountryNewAE)
            amsLocationType = AMS_Utils.TYPE_PAX_AE_MULTICOUNTRY;

        if (isNoticeOfChange)
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=Change_Summary.pdf');
        else
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=Application_Summary.pdf');

        //AS - NoC V2.0 - Now Other Change will always be for 3 types of changes
        if(isBankAccountChange) {
            newForm.Is_change_bank_account_details__c = true;
        } else {
            newForm.Scope_of_Change__c = isHOcontact ? 'HO Only' : 'Selected Branches Only'; //Set default
            newForm.Is_change_legal_name__c = true;
            newForm.Is_change_location__c = true;
            newForm.Is_change_ownership_or_shareholding__c = true;
        }

        //Verify to which step the user should go
        //and retrieve information linked to the step
        if (stepNumber == '1' || stepNumber == '') {
            isStep1 = true;
        }

        newForm.Scope_of_Change__c = isHOcontact ? 'HO Only' : 'Selected Branches Only'; //Set default

        if (ApexPages.currentPage().getParameters().containsKey('caseId')) {
            //Retrieve information linked to the case Id
            vSAAMCaseId = ApexPages.currentPage().getParameters().get('caseId');
            fetchCase(vSAAMCaseId);

            if (newCase != null) {
                if (newCase.IFAP_Country_ISO__c == null) {
                    //If case created internally by IATA, for user, then set country from the contact's Account
                    newCase.IFAP_Country_ISO__c = con.Account.IATA_ISO_Country__r.ISO_Code__c;
                }

                isocountry = fetchISOCountry(newCase.IFAP_Country_ISO__c);

                // NewGen is only valid for Travel Agents
                newAccreditationModels = (isocountry.ANG_Enable_NewGen__c == true && sectorValue.StartsWith('Travel_Agent')) ;
                namEnabled = isocountry.ANG_Enable_NewGen__c;

                amsAllLangCountryLabel = getAmsAllLangCountryLabel(isocountry, UserInfo.getLanguage());

                if(newCase.Case_Language__c == null || newCase.Case_Language__c == 'English')
                    newCase.Case_Language__c = 'en_US';

                applyLanguage = newCase.Case_Language__c;
                displayLanguage = newCase.Case_Language__c;

                if (applyLanguage == 'en_US') amsCountryLabel = isocountry.Case_BSP_Country__c; 
                else if (applyLanguage == 'fr') amsCountryLabel = isocountry.IATA_Country_FR__c;
                else amsCountryLabel = isocountry.IATA_Country_SP__c;
                    
                if ( newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || newCase.Reason1__c == AMS_Utils.CASE_REASON_HE_STANDARD || newCase.Reason1__c == AMS_Utils.CASE_REASON_HE_LITE || newCase.Reason1__c == AMS_Utils.CASE_REASON_HE_MULTICOUNTRY) {
                    amsOfficeType = AMS_Utils.HO; //Branches Abroad have same country requirements as HO in that country
                } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP || (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE)) {
                    amsOfficeType = 'Branch';
                }

                if (newCase.Reason1__c == AMS_Utils.CASE_REASON_HE_MULTICOUNTRY) {
                    lblStepE = Label.ISSP_AMS_Step5_ProgressBar_Validate_Data;
                    isMultiCountry = true;
                }

                if(amsOfficeType == AMS_Utils.HO && isHOAccredited && newCase.Reason1__c != AMS_Utils.CASE_REASON_BR_ABROAD)
                    isNewHOforAccredAgent = true; //Accrediedt Agent applying for HO of different Program e.g. Accred PAX applyiong for CGO HO

                fetchAMSProcessForm();

                newForm.HO_Account__c = vHQAccountId;

                //Need to get Id for Account for country of application concerned
                if (newCase.Account_Concerned__c==null) {
                    vAccountConcernedId = newForm.HO_Account__c;
                } else {
                    vAccountConcernedId = newCase.Account_Concerned__c;
                }

                if (isNoticeOfChange && vAccountConcernedId != null)
                    fetchAccountConcernedDetails();

                if (newForm.Agent_Type__c == null) {
                    newForm.Agent_Type__c = 'IATA Cargo Agent'; //Default Type of Agent to Cargo if case created internally - Open - EDMC - and online form not yet created
                }

                 //AS - NoC V2.0 - ensure that the following var are set for the case with "Open - EDMC" status
                if(isBankAccountChange) {
                    newForm.Is_change_bank_account_details__c = true;
                } else {
                    newForm.Is_change_legal_name__c = true;
                    newForm.Is_change_location__c = true;
                    newForm.Is_change_ownership_or_shareholding__c = true;
                }

                createNoCList();

                if (newForm != null && newForm.Operation_Type__c != null) {
                    newForm.HO_Account__c = vHQAccountId;
                    sectorValue = newForm.Operation_Type__c;
                    amsLocationType = newCase.Reason1__c + ' - ' + newForm.Agent_Type__c;
                }

                if (sectorValue != null) {
                    sector = sectorValue.replace('_', ' ');

                    if (isNoticeOfChange) {
                        sectorDisplay = Label.ISSP_AMS_NoC_Request_for_Change;
                    } else if (sectorValue.StartsWith('Travel_Agent')) {
                        sectorDisplay = Label.ISSP_Travel_Agent;
                    } else {
                        sectorDisplay = isocountry.AMS_Accreditation_New_Labels__c? Label.ISSP_Cargo_Agent_New: Label.ISSP_Cargo_Agent;
                        getCGORegionData();
                        getSpecialTrafficData();
                        setFacilityList();
                        setTrainedStaffList();
                    }
                }

                fetchCountryRequirements();

                if (isNoticeOfChange) {
                    sectorDisplay = Label.ISSP_AMS_NoC_Notice_of_Change;

                    agencyCodesConcernedForPDF = '';
                    if(newForm.Agency_Codes_Concerned__c != null) {
                        agencyCodesConcerned = getAgencyCodesConcerned();
                        agencyCodesConcernedForPDF = newForm.Agency_Codes_Concerned__c.replace(',',', ');
                    }

                    PDFPerRegionCS = getPDFPerRegionCS();
                }

                if (stepNumber == '1' || stepNumber == '') {
                    isStep1 = true;
                    amsIsGSA = 'NO';
                    setOwnerAndRoleLabels();
                    setContextualHelp(userInfo.getLanguage());
                } else if (stepNumber == '2') {
                    isStep2 = true;
                } else if (stepNumber == '3') {
                    isStep3 = true;

                    if (isNoticeOfChange && con.Account.ANG_Accreditation_Model__c != AMS_Utils.ACCREDITATIONMODEL_CASH)
                        refreshCntIFAPContacts();

                    setOwnerAndRoleLabels();
                    getCGORegionData();
                    getSpecialTrafficData();

                    newForm.Submitted_to_IATA__c = FALSE;

                    //Retrieve Cargo Agent if user has entered IATA  Code
                    if(newForm.IATA_Cargo_Code__c != null){
                        iatacode = newForm.IATA_Cargo_Code__c;
                        agentsector = AMS_Utils.SECTOR_CARGO;
                        fetchAgentDetails();
                    }

                    if(newform.IATAN_Code__c != null){
                        iatacode = newForm.IATAN_Code__c;
                        agentsector = AMS_Utils.SECTOR_PASSENGER;
                        iatanAccount = AMS_UTILS.IATAN_PASSENGER_AGENT;
                        fetchIATANDetails();
                    }

                    if (newCase.IFAP_Country_ISO__c == null) {
                        //If case created internally by IATA, for user, then set country from the contact's Account
                        newCase.IFAP_Country_ISO__c = con.Account.IATA_ISO_Country__r.ISO_Code__c;
                    }

                    isocountry = fetchISOCountry(newCase.IFAP_Country_ISO__c);

                    //Set default currency, as defined in IATA ISO Country record
                    if (isocountry != null) {
                        isEUcountry = isocountry.EU_Country__c;
                    }

                    // NewGen is only valid for Travel Agents
                    newAccreditationModels = (isocountry.ANG_Enable_NewGen__c == true && sectorValue.StartsWith('Travel_Agent'));
                    namEnabled = isocountry.ANG_Enable_NewGen__c;

                    setContextualHelp(userInfo.getLanguage());

                    if (!String.isEmpty(currentMCFormId)) {
                        newForm.Status__c = 'InProgress';
                        newForm.Id = currentMCFormId;
                    }

                    //Validation error flag is set in STEP 5 (when submitting to IATA); redirects back to STEP 3
                    //so need to check here if to redisplay error masgs
                    isValError = false;
                    if (newForm.Validation_ERRORS__c && newCase.Reason1__c != AMS_UTILS.CASE_REASON_FOR_MANAGEMENT) {
                        highLightPageForErrors();
                        isValError = true;
                    }
                } else if (stepNumber == '4') {
                    fetchAMSProcessForm();
                    setContextualHelp(userInfo.getLanguage());
                    newForm.Submitted_to_IATA__c = FALSE;
                    if (newForm.Validation_ERRORS__c) {
                        validateAttachedFiles();
                        isValError = true;
                    }
                    isStep4 = true;
                } else if (stepNumber == '5') {
                    fetchAMSProcessForm();
                    newForm.Submitted_to_IATA__c = FALSE;
                    if (newForm.Validation_ERRORS__c) {
                        validateAttachedFiles();
                        if (sectorValue.StartsWith('Cargo_Agent') && isNoticeOfChange == false) {
                            retCargoCountryReqments(false);
                        } else if (sectorValue.StartsWith('Cargo_Agent') && isNoticeOfChange == true) {
                            retNoCCargoCountryReqments(false);
                        } else if (sectorValue.StartsWith('Travel_Agent') && isNoticeOfChange == true) {
                            retNoCTravelCountryReqments(false);
                        }
                        isValError = true;
                    }
                    setOwnerAndRoleLabels();
                    setContextualHelp(userInfo.getLanguage());
                    isStep5 = true;
                } else {
                    fetchAMSProcessForm();
                    if (newForm.ISSP_AMS_Legal_Status__c != null)
                        legalstatus = newForm.ISSP_AMS_Legal_Status__c.toLowerCase();
                    setPageLegalStatusLabels();
                    isFinalStep = true;
                }
            }
        } 
        //Set default VAT Number of Branch to that of the HO and
        // It's not a separate legal entity
        // It's null when it's a branch.
        if (amsOfficeType == 'Branch' && (newForm.AE_separate_Legal_Entity__c == null || newForm.AE_separate_Legal_Entity__c == 'No')) {
            if (newForm.ISSP_AMS_VAT_number_input__c == null)
                if (isEUcountry) { //Need to remove first 2 chars (ISO County code) for VAT input field for EU countries since not required by validation WS
                    if (con.Account.VAT_Number__c != null)
                        newForm.ISSP_AMS_VAT_number_input__c = con.Account.VAT_Number__c.substring(2);
                } else { //Simply take BR VAT default of HO for non-EU countries
                    newForm.ISSP_AMS_VAT_number_input__c = con.Account.VAT_Number__c;
                }
        }

        if(isHOAccredited) {
            amsLocationTypeLabelHq = translateAccreditationModel(hqAccount.ANG_Accreditation_Model__c);
            amsLocationTypeLabel = translateAccreditationModel(newForm.ANG_Accreditation_type__c);
            if(amsLocationTypeLabelHq == null) {
                amsLocationTypeLabelHq = amsLocationTypeLabel;
            }
        } else {
            amsLocationTypeLabel = translateAccreditationModel(newForm.ANG_Accreditation_type__c);
            amsLocationTypeLabelHq = amsLocationTypeLabel;
        }

        namPaxAgent = (sector == 'Travel Agent' && namEnabled);

        selectPageName();

        this.helper = new ANG_ProductComparisonHelper('B');
    }

    public ISSP_AMS_Accreditation(ISSP_AddAttachment attachCtrl) {
        isNoticeOfChange = false;
        newAccreditationModels = false;

        popContact();  //Get the contact details of currently logged in user

        newCase = DAL_ISSP.getCase(attachCtrl.tmpCase.Id);

        if(newCase.IFAP_Country_ISO__c != null) {
            isocountry = fetchISOCountry(newCase.IFAP_Country_ISO__c);
            fetchAMSProcessForm();
        }else{
            newCase.IFAP_Country_ISO__c = con.Account.IATA_ISO_Country__r.ISO_Code__c;
            isocountry = fetchISOCountry(newCase.IFAP_Country_ISO__c);
            fetchAMSProcessForm();
        }

         if (con.Account.Top_Parent__c == null) { //User is from HQ Account
            vHQAccountId = con.AccountId;
            fetchHQAccountDetails();
        } else { //Get Id for HQ Account when user's Account is a branch office
            vHQAccountId = con.Account.Top_Parent__c;
            fetchHQAccountDetails();
        }

        if (newForm != null) {
            amsAgentType = newForm.Agent_Type__c;

            if (newForm.Operation_Type__c != null)
                sectorValue = newForm.Operation_Type__c;
            else
                sectorValue = newForm.Type_of_Operation__c.replace(' ', '_');

            if (newForm.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Change_of_Bank_Account_Details') ||
                newForm.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Other_Changes'))
                isNoticeOfChange = true;

            noticeOfChangeList = new List<String>();
            createNoCList();
        } else {
            //fix amsu-113
            newForm = new AMS_Pax_Accreditation_Form__c();
            noticeOfChangeList = new List<String>();
            sectorValue = con != null && con.Account != null && !String.isBlank(con.Account.Sector__c) ? con.Account.Sector__c.replace(' ', '_') : '';
            List_CountryReqments = new List<AMS_Accreditation_Requirement__c>();
        }

        if (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || newCase.Reason1__c == AMS_Utils.CASE_REASON_HE_STANDARD || newCase.Reason1__c == AMS_Utils.CASE_REASON_HE_LITE || newCase.Reason1__c == AMS_Utils.CASE_REASON_HE_MULTICOUNTRY) {
            amsOfficeType = AMS_Utils.HO;
        } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP || (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE)) {
            amsOfficeType = 'Branch';
        }

        applyLanguage = newCase.Case_Language__c;

        // NewGen is only valid for Travel Agents
        newAccreditationModels = (isocountry.ANG_Enable_NewGen__c == true && !String.isBlank(sectorValue) && sectorValue.StartsWith('Travel_Agent')) ;//fix amsu-113

        if (sectorValue != null) {
            if (sectorValue.StartsWith('Cargo_Agent'))
                setFacilityList();

            sector = sectorValue.replace('_', ' ');

            if(isNoticeOfChange) {
                stepNumber='5'; //Set to Step 5, so together with isValidation=true, STEP E docs such as signed contract (NOC_SIGNED_CONTRACT) also appears in list of attachments
                if(sectorValue.StartsWith('Travel_Agent')) {
                     retNoCTravelCountryReqments(true);
                } else {
                     retNoCCargoCountryReqments(true);
                }
            } else {
                fetchCountryRequirements();
            }
        }
    }

    public void createNoCList() {
        if (newForm.Is_change_bank_account_details__c == true)
            noticeOfChangeList.add('bank account details');
        else
            noticeOfChangeList.add('');
        
        if (newForm.Is_change_legal_name__c == true)
            noticeOfChangeList.add('legal name');
        else
            noticeOfChangeList.add('');
        
        if (newForm.Is_change_location__c == true)
            noticeOfChangeList.add('location');
        else
            noticeOfChangeList.add('');
        
        if (newForm.Is_change_ownership_or_shareholding__c == true)
            noticeOfChangeList.add('ownership or shareholding or legal status');
        else
            noticeOfChangeList.add('');
    }

    public void updateAmsCountry() {
        isocountry = fetchISOCountry(con.Account.IATA_ISO_Country__r.ISO_Code__c);

        if (isocountry != null) 
            amsAllLangCountryLabel = getAmsAllLangCountryLabel(isocountry, UserInfo.getLanguage());
    }

    public List<SelectOption> countryISOCodeList {
        get {
            List<SelectOption> options = new List<SelectOption>();

            Map<String, String> mapRegionToOtherRegion = new Map<String, String>{'Americas' => 'Americas', 'Europe' => 'Africa & Middle East', 'Africa & Middle East' => 'Europe',
                'Asia & Pacific' => 'China & North Asia', 'China & North Asia' => 'Asia & Pacific'};

            String query = 'SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c, IATA_Country_FR__c, ';
            query += 'IATA_Country_IT__c, IATA_Country_JP__c, IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c, ANG_Enable_NewGen__c ';
            query += 'FROM IATA_ISO_Country__c ';

            if (isMultiCountryNewAE) {
                query += 'WHERE Multicountry_Enabled__c = true ORDER BY Name';
            } else {
                query += 'WHERE Case_BSP_Country__c != null ';
                query += 'AND (Region__c = \'' + isocountry.Region__c + '\' OR Region__c = \'' + mapRegionToOtherRegion.get(isocountry.Region__c) + '\') ';
                query += 'AND Case_BSP_Country__c != \'\' AND ANG_Enable_NewGen__c = false ';

                if (applyLanguage == 'es') query += 'ORDER BY IATA_Country_SP__c';
                else if (applyLanguage == 'fr') query += 'ORDER BY IATA_Country_FR__c';
                else query += 'ORDER BY Name';
            }

            List<IATA_ISO_Country__c> isoList = Database.query(query);

            options.add(new SelectOption('', Label.ISSP_SELECT_COUNTRY));
            for (IATA_ISO_Country__c iso : isoList) {

                if (applyLanguage == 'es') {
                    if (iso.IATA_Country_SP__c != null)
                        options.add(new SelectOption(iso.ISO_Code__c , iso.IATA_Country_SP__c));
                    else
                        options.add(new SelectOption(iso.ISO_Code__c , iso.Name));
                } else if (applyLanguage == 'fr') {
                    if (iso.IATA_Country_FR__c != null)
                        options.add(new SelectOption(iso.ISO_Code__c, iso.IATA_Country_FR__c));
                    else
                        options.add(new SelectOption(iso.ISO_Code__c, iso.Name));
                } else {
                    options.add(new SelectOption(iso.ISO_Code__c, iso.Name));
                }
            }

            return options;
        }
        set;
    }

    public List<SelectOption> countryNameList {
        get {
            List<SelectOption> options = new List<SelectOption>();

            list<IATA_ISO_Country__c> isoList;
            if (applyLanguage == 'es') {
                isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Country_SP__c');
                
            } else if (applyLanguage == 'fr') {
                isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Country_FR__c');

            } else {
                isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'Name');
            }

            options.add(new SelectOption('', Label.ISSP_SELECT_COUNTRY));
            for (IATA_ISO_Country__c iso : isoList) {
                if (applyLanguage == 'es') {
                    if (iso.IATA_Country_SP__c != null)
                        options.add(new SelectOption(iso.IATA_Country_SP__c , iso.IATA_Country_SP__c));
                    else
                        options.add(new SelectOption(iso.Name , iso.Name));
                } else if (applyLanguage == 'fr') {
                    if (iso.IATA_Country_FR__c != null)
                        options.add(new SelectOption(iso.IATA_Country_FR__c, iso.IATA_Country_FR__c));
                    else
                        options.add(new SelectOption(iso.Name, iso.Name));
                } else {
                    options.add(new SelectOption(iso.Name, iso.Name));
                }
            }

            return options;
        }
        set;
    }

    public ISSP_PDF_Per_Region__c getPDFPerRegionCS() {
        List<ISSP_PDF_Per_Region__c> allowedOrgs = ISSP_PDF_Per_Region__c.getall().values();
        for (ISSP_PDF_Per_Region__c regionRec : allowedOrgs) {
            if (regionRec.Name == newCase.Region__c) {
                return regionRec;
            }
        }
        return null;
    }


    public List<SelectOption> getIATAMemberAirlines() {
        List <Account> members;

        members = [SELECT Id, Name, Airline_Prefix__c, Airline_designator__c
                   FROM Account
                   WHERE RecordType.DeveloperName IN ('IATA_Airline') AND Membership_status__c = 'IATA member'
                           ORDER BY Name];

        List<SelectOption> member_airlines = new List<SelectOption>();
        member_airlines.add(new SelectOption('', '--None--'));

        for (Account als : members) {
            member_airlines.add(new SelectOption(als.id, als.Name + ' (' + als.Airline_designator__c + ')'));
        }

        return member_airlines;
    }

    public Integer getContactAccountAEsChilds() {
        List <String> l = new List<String>();
        l.add(AMS_Utils.ACC_S9_APPROVED);
        l.add(AMS_Utils.ACC_S5_CASHNOCOMMISSION);
        l.add(AMS_Utils.ACC_S6_CASHWITHCOMMISSION);
        l.add(AMS_Utils.ACC_S8_CHANGESPROCESSED);

        return [SELECT COUNT()
                  FROM Account
                 WHERE Top_Parent__c = :con.Account.Id
                   AND Location_Type__c = :AMS_Utils.AE
                   AND Status__c in :l];
    }

    private List<Account> getBranchList(Boolean fullHierarchy) {
        List<String> selectedBranchCodes;
        selectedBranchCodes = new List<String>();

        if(newForm.Agency_Codes_Concerned__c != null && !fullHierarchy) //Exclude already selected branches
            selectedBranchCodes = newForm.Agency_Codes_Concerned__c.split(',');

        if (isHOcontact) {
        return [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry, Legal_name__c, ANG_Accreditation_Model__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c
                FROM Account
                WHERE Top_Parent__c = :vHQAccountId 
                    AND IATACode__c != null 
                    AND RecordType.DeveloperName IN ('IATA_Agency') 
                    AND (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending')) 
                    AND (IATACode__c NOT IN : selectedBranchCodes)
                ORDER BY Name, IATACode__c];
        } else { // BR contacts can only apply for changes to their own BR and SAs of their BR
            return [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry, Legal_name__c, ANG_Accreditation_Model__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c
                    FROM Account
                    WHERE Top_Parent__c = :vHQAccountId AND IATACode__c != null AND RecordType.DeveloperName IN ('IATA_Agency') AND (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending')) AND (IATACode__c NOT IN : selectedBranchCodes)
                        AND (Id = :con.AccountId OR ParentId =: con.AccountId )
                    ORDER BY Name, IATACode__c];
        }
    }

    private List<Account> getSelectedBranchList(List<String> branchCodes) {
        return [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry
                FROM Account
                WHERE IATACode__c IN : branchCodes
                ORDER BY Name, IATACode__c];
    }

    public List<SelectOption> getBranchAccounts() {
        List<SelectOption> options = new List<SelectOption>();

        List <Account> accountList = getBranchList(false);

        for (Account thisAccount : accountList) {
            String theLabel;
            theLabel = thisAccount.IATACode__c + ' - ' + (!getIsAccreditationModelNotNullOrLegacy() ? thisAccount.Location_Type__c : thisAccount.Name) + ' (' + thisAccount.BillingCity + (thisAccount.BillingState!= null ? ' ' + thisAccount.BillingState : '') + ')';

            options.add(new SelectOption(thisAccount.IATACode__c, theLabel));
        }
        return options;
    }

    public String getContactAccount() {
        List<SelectOption> options = new List<SelectOption>();
        Account conAccount = con.Account;
        String optionLabel =  conAccount.IATACode__c + ' - ' + (!getIsAccreditationModelNotNullOrLegacy() ? conAccount.Location_Type__c : conAccount.Name) + ' (' + conAccount.BillingCity + (conAccount.BillingState!= null ? ' ' + conAccount.BillingState : '') + ')';
        options.add(new SelectOption(conAccount.IATACode__c, optionLabel));
        agencyCodesConcerned = options;
        newForm.Scope_of_Change__c = 'Selected Branches Only';
        return optionLabel;
    }

    public List<SelectOption> getAgencyCodesConcerned() {
        List <Account> accountList;
        List<SelectOption> options = new List<SelectOption>();

        if(newForm.Agency_Codes_Concerned__c != null)
            accountList = getSelectedBranchList(newForm.Agency_Codes_Concerned__c.split(','));

        for (Account thisAccount : accountList) {
            String theLabel;
            theLabel = thisAccount.IATACode__c + ' - ' + (!getIsAccreditationModelNotNullOrLegacy() ? thisAccount.Location_Type__c : thisAccount.Name) + ' (' + thisAccount.BillingCity + (thisAccount.BillingState!= null ? ' ' + thisAccount.BillingState : '') + ')';

            options.add(new SelectOption(thisAccount.IATACode__c, theLabel));
        }
        return options;
    }

    public Integer getAgencyCodesConcernedSize() {
        return agencyCodesConcerned.size();
    }

    public Boolean getIsAccreditationModelNotNullOrLegacy() {
        return (String.isNotEmpty(con.Account.ANG_Accreditation_Model__c)  && con.Account.ANG_Accreditation_Model__c != AMS_UTILS.ACCREDITATIONMODEL_LEGACY);
    }

    public Boolean getCanChangeAccreditationType() {
        return !((getContactAccountAEsChilds() > 0 && newForm.Scope_of_Change__c != 'HO - All Branches') || (newForm.Scope_of_Change__c != 'HO - All Branches' && newForm.Scope_of_Change__c != 'HO Only'));
    }

    public List<SelectOption> getOfficeTypes() {
        Boolean isUKTerritory;

        isUKTerritory = false;

        if(newCase.IFAP_Country_ISO__c == 'GB' || newCase.IFAP_Country_ISO__c == 'GI' || newCase.IFAP_Country_ISO__c == 'GG' || newCase.IFAP_Country_ISO__c == 'IM' || newCase.IFAP_Country_ISO__c == 'JE' || newCase.IFAP_Country_ISO__c == 'SH' || newCase.IFAP_Country_ISO__c == 'PN') {
            isUKTerritory = true;
        }

        List<SelectOption> options = new List<SelectOption>();

        if (sectorValue.StartsWith('Cargo_Agent')) { //User has selected Cargo in STEP A
            if (!isHOAccredited && con.Account.Sector__c == AMS_Utils.SECTOR_CARGO) { //This is a non-Accredited Cargo Agent
                options.add(new SelectOption('', Label.ISSP_Select));
                if (isocountry.EACP_Country__c) {
                    options.add(new SelectOption(AMS_Utils.TYPE_EACP_HO, Label.ISSP_AMS_OPTION_EACP_HO));
                } else {
                    if(communityName=='CNS'){
                        options.add(new SelectOption(AMS_Utils.TYPE_CGO_HO, Label.ISSP_AMS_OPTION_CGO_HO_CNS));
                    }else{
                        options.add(new SelectOption(AMS_Utils.TYPE_CGO_HO, isocountry.AMS_Accreditation_New_Labels__c? Label.ISSP_AMS_OPTION_CGO_HO_New: Label.ISSP_AMS_OPTION_CGO_HO));
                    }

                }

                if (isCASSCountry && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //Only CASS Countries get CASS Assoc. option
                    options.add(new SelectOption(AMS_Utils.TYPE_CASS_ASSOC_HO, Label.ISSP_AMS_OPTION_CASS_ASSOC_HO));
                }

                if (isCASSImport && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //Only CASS Import Countries get CASS Import Agent option
                    options.add(new SelectOption(AMS_Utils.TYPE_IMPORT_HO, Label.ISSP_AMS_OPTION_IMPORT_HO));
                }

                if (isUKTerritory && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //UK also has courier HO option
                    options.add(new SelectOption(AMS_Utils.TYPE_COURIER_HO, Label.ISSP_AMS_OPTION_COURIER_HO));

                }

            } else if (isHOAccredited && con.Account.Sector__c == AMS_Utils.SECTOR_CARGO) { //An accredited CGO Agent
                options.add(new SelectOption('', Label.ISSP_Select));

                if (con.Account.Category__c == 'IATA Cargo Agent') { // Accredited IATA CGO Agent / EACP Intermediary
                    if (isocountry.EACP_Country__c) {
                        options.add(new SelectOption(AMS_Utils.TYPE_EACP_BRANCH, Label.ISSP_AMS_OPTION_EACP_BRANCH));
                    } else {
                        if(communityName=='CNS'){
                            options.add(new SelectOption(AMS_Utils.TYPE_CGO_BRANCH, Label.ISSP_AMS_OPTION_CGO_BRANCH_CNS));
                        }else{
                            options.add(new SelectOption(AMS_Utils.TYPE_CGO_BRANCH, (getnewlabels()? Label.ISSP_AMS_OPTION_CGO_BRANCH_NEW: Label.ISSP_AMS_OPTION_CGO_BRANCH)));
                        }
                    }
                    if (isUKTerritory && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //UK also has courier HO option
                        options.add(new SelectOption(AMS_Utils.TYPE_COURIER_HO, Label.ISSP_AMS_OPTION_COURIER_HO));
                    }
                    if (isCASSCountry && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //Accred. CGO Agent can also apply for CASS Assoc. option
                        options.add(new SelectOption(AMS_Utils.TYPE_CASS_ASSOC_HO, Label.ISSP_AMS_OPTION_CASS_ASSOC_HO));
                    }
                    if (isCASSImport && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //Only CASS Import Countries get CASS Import Agent option
                        options.add(new SelectOption(AMS_Utils.TYPE_IMPORT_HO, Label.ISSP_AMS_OPTION_IMPORT_HO));
                    }
                } else if (con.Account.Category__c == AMS_Utils.CATEGORY_CASSASSOCIATE || con.Account.Category__c == 'CASS Associates') {
                    if (!isocountry.Disable_non_IATA_Cargo_Agents__c)
                        options.add(new SelectOption(AMS_Utils.TYPE_CASS_ASSOC_BRANCH, Label.ISSP_AMS_OPTION_CASS_ASSOC_BRANCH));
                    if (isocountry.EACP_Country__c) {
                        options.add(new SelectOption(AMS_Utils.TYPE_EACP_HO, Label.ISSP_AMS_OPTION_EACP_HO));
                    } else {
                        options.add(new SelectOption(AMS_Utils.TYPE_CGO_HO, isocountry.AMS_Accreditation_New_Labels__c? Label.ISSP_AMS_OPTION_CGO_HO_New: Label.ISSP_AMS_OPTION_CGO_HO));
                    }

                    if (isUKTerritory && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //UK also has courier HO option
                        options.add(new SelectOption(AMS_Utils.TYPE_COURIER_HO, Label.ISSP_AMS_OPTION_COURIER_HO));
                    }

                    if (isCASSImport && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //Only CASS Import Countries get CASS Import Agent option
                        options.add(new SelectOption(AMS_Utils.TYPE_IMPORT_HO, Label.ISSP_AMS_OPTION_IMPORT_HO));
                    }
                } else if (con.Account.Category__c == AMS_Utils.CATEGORY_COURIER) {
                    options.add(new SelectOption(AMS_Utils.TYPE_EACP_HO, Label.ISSP_AMS_OPTION_EACP_HO));
                    if (!isocountry.Disable_non_IATA_Cargo_Agents__c) {
                        options.add(new SelectOption(AMS_Utils.TYPE_COURIER_BRANCH, Label.ISSP_AMS_OPTION_COURIER_BRANCH));
                        options.add(new SelectOption(AMS_Utils.TYPE_CASS_ASSOC_HO, Label.ISSP_AMS_OPTION_CASS_ASSOC_HO));
                    }
                    if (isCASSImport && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //Only CASS Import Countries get CASS Import Agent option
                        options.add(new SelectOption(AMS_Utils.TYPE_IMPORT_HO, Label.ISSP_AMS_OPTION_IMPORT_HO));
                    }
                } else if (con.Account.Category__c == AMS_Utils.CATEGORY_IMPORT_AGENT) {
                    if (!isocountry.Disable_non_IATA_Cargo_Agents__c)
                        options.add(new SelectOption(AMS_Utils.TYPE_IMPORT_BRANCH, Label.ISSP_AMS_OPTION_IMPORT_BRANCH));
                    if (isocountry.EACP_Country__c) {
                        options.add(new SelectOption(AMS_Utils.TYPE_EACP_HO, Label.ISSP_AMS_OPTION_EACP_HO));
                    } else {
                        options.add(new SelectOption(AMS_Utils.TYPE_CGO_HO, isocountry.AMS_Accreditation_New_Labels__c? Label.ISSP_AMS_OPTION_CGO_HO_New: Label.ISSP_AMS_OPTION_CGO_HO));
                    }
                    if (!isocountry.Disable_non_IATA_Cargo_Agents__c)
                        options.add(new SelectOption(AMS_Utils.TYPE_CASS_ASSOC_HO, Label.ISSP_AMS_OPTION_CASS_ASSOC_HO));
                    if (isUKTerritory && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //UK also has courier HO option
                        options.add(new SelectOption(AMS_Utils.TYPE_COURIER_HO, Label.ISSP_AMS_OPTION_COURIER_HO));
                    }
                }
            } else  {  //CGO Options for PAX Agents (Accredited or Non-Accredited)
                options.add(new SelectOption('', Label.ISSP_Select));

                if (isocountry.EACP_Country__c) {
                    options.add(new SelectOption(AMS_Utils.TYPE_EACP_HO, Label.ISSP_AMS_OPTION_EACP_HO));
                } else {
                    options.add(new SelectOption(AMS_Utils.TYPE_CGO_HO, isocountry.AMS_Accreditation_New_Labels__c? Label.ISSP_AMS_OPTION_CGO_HO_New: Label.ISSP_AMS_OPTION_CGO_HO));
                }

                if (isCASSCountry && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //Only PAX Agents from CASS Countries get CASS Assoc. option
                    options.add(new SelectOption(AMS_Utils.TYPE_CASS_ASSOC_HO, Label.ISSP_AMS_OPTION_CASS_ASSOC_HO));
                }

                if (isCASSImport && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //Only PAX Agents from CASS Import Countries get Import Agent options
                    options.add(new SelectOption(AMS_Utils.TYPE_IMPORT_HO, Label.ISSP_AMS_OPTION_IMPORT_HO));
                }

                if (isUKTerritory && !isocountry.Disable_non_IATA_Cargo_Agents__c) { //UK also has courier HO option
                    options.add(new SelectOption(AMS_Utils.TYPE_COURIER_HO, Label.ISSP_AMS_OPTION_COURIER_HO));
                }
            }
        } else if (sectorValue.StartsWith('Travel_Agent')) { //User has selected Travel in STEP A

            if (isHOAccredited && con.Account.Category__c == AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT) { //And this is an Accredited PAX Agent

                if(!getIsAccreditationModelNotNullOrLegacy()){
                    options.add(new SelectOption(AMS_Utils.TYPE_PAX_BRANCH_L, Label.ISSP_AMS_OPTION_PAX_BRANCH));

                    if (isocountry.Region__c != 'Americas')
                        options.add(new SelectOption(AMS_Utils.TYPE_PAX_BRANCH_ABROAD_L, Label.ISSP_AMS_OPTION_PAX_BRANCH_ABROAD));

                }else{ //NEWGEN - 552 START
                    if(con.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH){
                        options.add(new SelectOption(AMS_Utils.TYPE_PAX_AE_CASH, Label.ISSP_AMS_Associate_Entity_Cash));
                    }else if(con.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASHLESS){
                        options.add(new SelectOption(AMS_Utils.TYPE_PAX_AE_NO_CASH, Label.ISSP_AMS_Associate_Entity_Cashless));
                    } else if (con.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY) {
                        options.add(new SelectOption(AMS_Utils.TYPE_PAX_AE_NO_CASH, Label.ISSP_AMS_Associate_Entity_Multicountry));
                    }
                    //NEWGEN - 552 END
                }
            }else {
                if(isocountry.ANG_Enable_NewGen__c == true){
                    options.add(new SelectOption(AMS_Utils.TYPE_HE_ST_CASH, Label.ISSP_AMS_Head_Entity_Cash));  //can only apply for New Accreditaiton Models enable
                    options.add(new SelectOption(AMS_Utils.TYPE_HE_LITE_NO_CASH, Label.ISSP_AMS_Head_Entity_No_Cash));  //can only apply for New Accreditaiton Models enable
                    if (isocountry.Multicountry_Enabled__c) options.add(new SelectOption(AMS_Utils.TYPE_HE_MULTICOUNTRY, Label.ISSP_AMS_Head_Entity_Multicountry));
                    if (isMultiCountryNewAE) options.add(new SelectOption(AMS_Utils.TYPE_PAX_AE_MULTICOUNTRY, Label.ISSP_AMS_Associate_Entity_Multicountry));
                }else{    //Not an Accredited PAX Agent, or any type of Cargo Agent
                     options.add(new SelectOption(AMS_Utils.TYPE_PAX_HO, Label.ISSP_AMS_OPTION_PAX_HO));  //can only apply for PAX HO
                }
            }
        }

        defaultSectorValue = null;
        if(con.Account.ANG_Accreditation_Model__c != AMS_UTILS.ACCREDITATIONMODEL_CASH || con.Account.ANG_Accreditation_Model__c != AMS_UTILS.ACCREDITATIONMODEL_CASHLESS)
            sector = null;

        return options;
    }

    public Pagereference cancel() {
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if (retURL == null) {
            return new Pagereference('/ISSP_Homepage?mid=M0S1' +commParam);
        } else {
            return new Pagereference(retURL);
        }
    }

    private void selectPageName() {
        amsAgentType = newForm.Agent_Type__c;
        if (isNoticeOfChange) {
            includedPageName = 'ISSP_AMS_Notice_Of_Change';
            includedSummaryPage = 'ISSP_AMS_NoC_ReadOnly';

        } else if (  sectorValue.StartsWith('Travel_Agent') && newForm.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newForm.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newForm.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY) {

            includedPageName = 'ISSP_AMS_Pax_Form';
            includedSummaryPage = 'ISSP_AMS_PAX_ReadOnly';

        } else if( (sectorValue.StartsWith('Travel_Agent') && (!isMultiCountryNewAE) && (newForm.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_CASH || newForm.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH || newForm.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY) && ( newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_STANDARD || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_LITE || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_MULTICOUNTRY))){
            includedPageName = 'ISSP_ANG_PAX_HE';
            includedSummaryPage = 'ISSP_ANG_PAX_HE_ReadOnly';//NEWGEN-604

        } else if((sectorValue.StartsWith('Travel_Agent') && (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE))){
            includedPageName = 'ISSP_ANG_PAX_AE';
            includedSummaryPage = 'ISSP_ANG_PAX_AE_ReadOnly';

        } else if (sectorValue.StartsWith('Cargo_Agent') && (newForm.Agent_Type__c == 'IATA Cargo Agent' || newForm.Agent_Type__c == 'EACP Intermediary')  && newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO) {
            includedPageName = 'ISSP_AMS_Cargo_Form';
            includedSummaryPage = 'ISSP_AMS_CGO_ReadOnly';
        } else if (sectorValue.StartsWith('Cargo_Agent') && (newForm.Agent_Type__c == 'IATA Cargo Agent' || newForm.Agent_Type__c == 'EACP Intermediary') && newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP) {
            includedPageName = 'ISSP_AMS_Cargo_Branch_Form';
            includedSummaryPage = 'ISSP_AMS_CGO_BR_ReadOnly';
        } else if (sectorValue.StartsWith('Cargo_Agent') && newForm.Agent_Type__c != 'IATA Cargo Agent' && newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO) {
            includedPageName = 'ISSP_AMS_CASS_Associate_Form';
            includedSummaryPage = 'ISSP_AMS_CASS_HO_ReadOnly';
        } else {
            includedPageName = 'ISSP_AMS_Cargo_Branch_Form';
            includedSummaryPage = 'ISSP_AMS_CGO_BR_ReadOnly';
        }
    }

    /*** AMSU-37 Start ***/
    private List<String> hasPendingHOAccreditations(Case cse) {
        List<String> res = new List<String>();

        if(cse.id == null && String.isBlank(cse.CaseNumber) && cse.Reason1__c == 'New HO') {
            List<Case> cases = [SELECT Id, CaseNumber
                                FROM Case 
                                WHERE (AccountId = :hqAccount.Id OR ContactId = :cse.ContactId) AND Reason1__c = 'New HO' AND 
                                    (IsClosed = false AND (NOT Owner.Name LIKE '%Recycle%')) AND 
                                    Type_of_customer__c = :cse.Type_of_customer__c  LIMIT 1];

            if(!cases.isEmpty()) {
                res.add(cases[0].Id);
                res.add(cases[0].CaseNumber);                
            }
        }

        return res;
    }
    /*** AMSU-37 End ***/

    public Pagereference save() {
        SYSTEM.DEBUG('Saving Record - STEP A');

        if (amsLocationType == null && !isNoticeOfChange) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_Empty_Location_Type));
            return null;
        }
        if (isNoticeOfChange != true) {
            //Defining default values for the case
            //create case with RT SAAM
            String agentType;
            if (newCase.Status == 'Open - EDMC') {
            if (con.Account.Category__c == 'IATA Cargo Agent')
                amsLocationType = AMS_Utils.TYPE_CGO_HO;
            else if (con.Account.Category__c == AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT)
                amsLocationType = 'New HO - IATA Passenger Sales Agent';
            }

            if(isHOAccredited) {
                amsLocationTypeLabelHq = translateAccreditationModel(hqAccount.ANG_Accreditation_Model__c);
                amsLocationTypeLabel = translateAccreditationModel(newForm.ANG_Accreditation_type__c);
                if(amsLocationTypeLabelHq == null) {
                    amsLocationTypeLabelHq = amsLocationTypeLabel;
                }
            } else {
                amsLocationTypeLabel = translateAccreditationModel(newForm.ANG_Accreditation_type__c);
                amsLocationTypeLabelHq = amsLocationTypeLabel;
            }

            if(ISSP_Utilities.isCNS()) newCase.CNSCase__c=true;

            if (amsLocationType.contains('GoGlobal')) {
                lblStepE = Label.ISSP_AMS_Step5_ProgressBar_Validate_Data;
                isMultiCountry = true;
            } 

            agentType = amsLocationType.substring(amsLocationType.indexOf('-') + 1).trim();

            newCase.Reason1__c = amsLocationType.left(amsLocationType.indexOf('-')).trim();

            if (newCase.IFAP_Country_ISO__c == 'CN' && sectorValue.startsWith('Travel_Agent')) {
                if (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO) {
                    sectorValue = sectorValue + ' - ' + newForm.Local_Agent_Type__c;
                } else {
                    //International HO can only apply for International Branch
                    if (con.Account.Category__c == 'Domestic Agent') {
                        sectorValue = sectorValue + ' - Domestic';
                        newForm.Local_Agent_Type__c = 'Domestic';
                    } else {
                        sectorValue = sectorValue + ' - International';
                        newForm.Local_Agent_Type__c = 'International';
                    }
                }
            }

            if (amsIsGSA == 'YES' && sectorValue.StartsWith('Travel_Agent')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.ISSP_AMS_Step1_IS_GSA_Warning));
                return null;
            }

            if (sectorValue == 'Travel_Agent' && amsIsGSA == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_Step1_Is_GSA + ': ' + Label.ISSP_YouMustEnter));
                return null;
            }

            if ((newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE) && newForm.AE_separate_Legal_Entity__c == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_IS_Separate_Entity_Null));
                return null;
            }

            if(newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD && (newCase.IFAP_Country_ISO__c == hqCountryISOCode)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.ISSP_AMS_Branch_Abroad_Invalid_Country));
                return null;
            }

            newCase.Origin = 'Portal';
            newCase.Status = 'Draft';
            newForm.Agent_Type__c = agentType;

            newCase.Description = Label.ISSP_Email_Draft_Process1 + ' ' + getApplicationTypeLabel(amsLocationType) + getAccreditationModel(hqAccount.ANG_Accreditation_Model__c) + '.';
            newCase.CaseArea__c = 'Accreditation Process';
            newcase.Case_Language__c = applyLanguage;
            newCase.Visible_on_ISS_Portal__c = true;

            if(newCase.IFAP_Country_ISO__c == null) newCase.IFAP_Country_ISO__c = con.Account.IATA_ISO_Country__r.ISO_Code__c;

            isocountry = fetchISOCountry(newCase.IFAP_Country_ISO__c);
            if (isocountry.OSCAR_enabled__c && (!isocountry.SAAM_enable_non_IATA_Cargo_Agents__c ||
                                                (newForm.Agent_Type__c != AMS_Utils.CATEGORY_CASSASSOCIATE && newForm.Agent_Type__c != AMS_Utils.CATEGORY_IMPORT_AGENT && newForm.Agent_Type__c != AMS_Utils.CATEGORY_COURIER)))
                RECORD_TYPE_ID = OSCAR_RECORD_TYPE_ID;

            newCase.recordTypeId = RECORD_TYPE_ID;
            newCase.BSPCountry__c =  isocountry.Case_BSP_Country__c ;
            newCase.Country_concerned_by_the_query__c = isocountry.Name;

            if(sectorValue == 'Travel_Agent') {
                newCase.Type_of_customer__c = 'IATA Travel Agent';
            } else if (sectorValue == 'Cargo_Agent') {
                newCase.Type_of_customer__c = 'IATA Cargo Agent';
            } else {
                newCase.Type_of_customer__c = con.Account.Category__c;
            }

            if(amsLocationType.contains('Standard') || amsLocationType.contains('Associate') || amsLocationType.contains('Multicountry')){
                newCase.Subject = getCaseReason(newCase.Reason1__c, hqAccount.ANG_Accreditation_Model__c) + ' - ' + newCase.Country_concerned_by_the_query__c;
            } else {
                newCase.Subject = getCaseReason(newCase.Reason1__c, hqAccount.ANG_Accreditation_Model__c) + ' - ' + getAgentTypeLabel(agentType) + ' - ' + newCase.Country_concerned_by_the_query__c;
            }

            try {
                String newIsoCountry = newCase.IFAP_Country_ISO__c;

                /*** AMSU-37 Start ***/
                List<String> csNumber = hasPendingHOAccreditations(newCase);
                if(!csNumber.isEmpty()) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, String.format(Label.AMS_PendingHOAccr,csNumber)));
                    return null;
                }
                /*** AMSU-37 End ***/

                if ((draftHQCaseExists) || isDupeSAAMCase) {
                    agentType = amsLocationType.substring(amsLocationType.indexOf('-') + 1).trim();
                    newCase.Reason1__c = amsLocationType.left(amsLocationType.indexOf('-')).trim();
                    newCase.Case_Language__c = applyLanguage;
                    newCase.IFAP_Country_ISO__c = newIsoCountry;
                    isocountry = fetchISOCountry(newCase.IFAP_Country_ISO__c);
                    newCase.BSPCountry__c =  isocountry.Case_BSP_Country__c ;
                    newCase.Country_concerned_by_the_query__c = isocountry.Name;
                    newCase.Description = Label.ISSP_Email_Draft_Process1 + ' ' + getApplicationTypeLabel(amsLocationType) + getAccreditationModel(hqAccount.ANG_Accreditation_Model__c) + '.';

                    if(amsLocationType.contains('Standard') || amsLocationType.contains('Associate')){
                        newCase.Subject = getCaseReason(newCase.Reason1__c, hqAccount.ANG_Accreditation_Model__c) + ' - ' + newCase.Country_concerned_by_the_query__c;
                    }else{
                        newCase.Subject = getCaseReason(newCase.Reason1__c, hqAccount.ANG_Accreditation_Model__c) + ' - ' + getAgentTypeLabel(agentType) + ' - ' + newCase.Country_concerned_by_the_query__c;
                    }

                    if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE) //NEWGEN-1249
                        upsert newform;

                    fetchAMSProcessForm();

                }
                // Creation of first draft case (either HO or BR)
                if (!isMultiCountryNewAE) upsert newCase;
                else {
                    newCase = hqAccount.Cases[0];
                    newForm.Status__c = 'InProgress';
                }

                if (isNewCase) {

                    //NEWGEN-1249 checking if the account will use the same legal entity. This will be use to see if the user changes their mind in the middle of the proccess
                    if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE) newForm.ANG_AE_SameLegal__c = newForm.AE_separate_Legal_Entity__c;

                    newForm.Branch_Office_Country__c = isocountry.ID;

                    if(newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE)) {
                        newForm.ISSP_AMS_Legal_Status__c = mapCompanyTypes(hqAccount.Company_Type__c);
                        newForm.Remittance_frequency__c = hqAccount.Remittance_frequency__c;

                        if(newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || newForm.AE_separate_Legal_Entity__c == 'No'){  //Legal name is editable for BR Abroad, so set default value
                            newForm.Account_Name__c = hqAccount.Name;
                        }

                        saveAMSForm();

                        if(newForm.AE_separate_Legal_Entity__c == 'No' || newForm.AE_separate_Legal_Entity__c == null) // NEWGEN-1249 only with same legal entity have the owners from parent
                            setOwners('Branch');
                    } else { //Insert current user as default contatc for HO applications
                        if (newCase.Reason1__c == AMS_Utils.CASE_REASON_HE_MULTICOUNTRY) newform.Status__c = 'InProgress';
                            
                        saveAMSForm();
                        insertDefaultContact();
                    }
                } else {
                    if((newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE) && newForm.AE_separate_Legal_Entity__c == 'No'){ //NEWGEN-1249
                        resetCreatedOwnership();

                        newForm.ISSP_AMS_Legal_Status__c = mapCompanyTypes(hqAccount.Company_Type__c);
                        newForm.Account_Name__c = hqAccount.Name;
                        newForm.Trade_Name__c = hqAccount.TradeName__c;

                        if(checkAllOwners != null || !checkAllOwners.isEmpty())
                            delete checkAllOwners;

                        setOwners('Branch');
                    }
                    else if ((newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE) && newForm.AE_separate_Legal_Entity__c == 'Yes'){
                        resetOwnership();

                        if(checkAllOwners != null || !checkAllOwners.isEmpty())
                            delete checkAllOwners;
                    }

                    saveAMSForm();
                }

            } catch (DmlException ex) { ApexPages.addMessages(ex); }
        } else { //This is a NoC
            Boolean changeOfAccountConcerned = false;

            if ((newForm.Scope_of_Change__c == 'HO - Selected Branches' || newForm.Scope_of_Change__c == 'Selected Branches Only')  && agencyCodesConcerned.size()==0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, (getIsAccreditationModelNotNullOrLegacy() ? Label.ISSP_NoC_Least_One_AE : Label.ISSP_NoC_Least_One_BO)));
                return null;
            }

            newCase.Origin = 'Portal';

            if (newCase.Status != 'Open - EDMC') {
                newCase.Status = 'Draft';
            }

            if (isBankAccountChange) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Change_of_Bank_Account_Details');
            } else {
                if (!getIsAccreditationModelNotNullOrLegacy()) {
                    newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Other_Changes');
                } else {
                    newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Other_Changes_NAM');
                }
            }
            newCase.CaseArea__c = 'Accreditation Process';
            newcase.Case_Language__c = applyLanguage;
            newCase.Visible_on_ISS_Portal__c = true;

            if (newForm.Scope_of_Change__c=='HO Only' || newForm.Scope_of_Change__c=='HO - All Branches') {
                if(newCase.Account_Concerned__c != null)
                    changeOfAccountConcerned = true;

                newCase.Account_Concerned__c = null;
                newForm.Agency_Codes_Concerned__c = null;
            } else {
               Boolean first = true;
               String agencyCodes;
                for ( SelectOption ac : agencyCodesConcerned ) {
                    if (!first) agencyCodes += ',';

                    if (first) agencyCodes = ac.getValue();
                    else agencyCodes += ac.getValue();

                    first = false;
                }

                newForm.Agency_Codes_Concerned__c = agencyCodes;

                if(newForm.Scope_of_Change__c=='Selected Branches Only') {
                    Account branchAccount = [SELECT Id, Name, IATACode__c
                                            FROM Account
                                            WHERE IATACode__c = :agencyCodesConcerned[0].getValue()
                                            LIMIT 1];
                    //If BR Only selection has changed then need to retrieve BR details again
                    if(newCase.Account_Concerned__c != branchAccount.Id)
                        changeOfAccountConcerned = true;

                    newCase.Account_Concerned__c = branchAccount.Id;
                } else { //HO with selected Branches
                    if(newCase.Account_Concerned__c != null)
                        changeOfAccountConcerned = true;

                    newCase.Account_Concerned__c = null;
                }
            }

            if(getIsAccreditationModelNotNullOrLegacy()) {
                //NEWGEN-668
                if (newForm.Scope_Of_Change__c == 'Selected Branches Only') {
                    newForm.Is_this_Head_Office_becoming_a_Branch__c = 'No';
                }
                //END - NEWGEN-668
                //NEWGEN-205
                if (newForm.Last_Scope_Of_Change__c == null) {
                    newForm.Last_Scope_Of_Change__c = newForm.Scope_of_Change__c;
                } else if ( newForm.Last_Scope_Of_Change__c != newForm.Scope_of_Change__c) {
                    if ((newForm.Last_Scope_Of_Change__c == 'Selected Branches Only' && newForm.Scope_of_Change__c != 'Selected Branches Only') ||
                        (newForm.Last_Scope_Of_Change__c != 'Selected Branches Only' && newForm.Scope_of_Change__c == 'Selected Branches Only')) {
                        isScopeOfChangeChanged = true;
                        setOwners('NoC');
                    }
                    newForm.Last_Scope_Of_Change__c = newForm.Scope_of_Change__c;
                } else {
                    isScopeOfChangeChanged = false;
                }
            }

            if(!getCanChangeAccreditationType()) {
                newForm.Notify_Change_Accreditation_Type__c = false;
                newForm.ANG_Accreditation_Model_to_Change__c = null;
            }

            if (newCase.Account_Concerned__c==null) {
                vAccountConcernedId = newForm.HO_Account__c;
            } else {
                vAccountConcernedId = newCase.Account_Concerned__c;
            }

            fetchAccountConcernedDetails();

            //AMSU-140 update newForm.location_class from the Account_Concerned
            newForm.Location_Class__c = accountConcerned.Location_Class__c;
            if(newForm.Location_Class__c == 'I'){  //AMSU-140
                newCase.Visible_on_ISS_Portal__c = true;
            }

            updateNoCReasonSubject();

            if (isocountry.OSCAR_enabled__c && (!isocountry.SAAM_enable_non_IATA_Cargo_Agents__c ||
                                                (newForm.Agent_Type__c != AMS_Utils.CATEGORY_CASSASSOCIATE && newForm.Agent_Type__c != AMS_Utils.CATEGORY_IMPORT_AGENT && newForm.Agent_Type__c != AMS_Utils.CATEGORY_COURIER)))
                RECORD_TYPE_ID = OSCAR_RECORD_TYPE_ID;

            if (isNewCase || changeOfAccountConcerned) {
                accountStagingFieldMapping(accountConcerned, AMS_Utils.CASE_REASON_NEW_HO, false);
                newForm.ISSP_AMS_Legal_Status__c = mapCompanyTypes(hqAccount.Company_Type__c);

                if (isEUcountry) { //Need to remove first 2 chars (ISO County code) for VAT input field for EU countries since not required by validation WS
                    if (accountConcerned.VAT_Number__c != null)
                        newForm.ISSP_AMS_VAT_number_input__c = accountConcerned.VAT_Number__c.substring(2);
                } else { //Simply take BR VAT default of HO for non-EU countries
                    newForm.ISSP_AMS_VAT_number_input__c = accountConcerned.VAT_Number__c;
                }
            }

            newCase.recordTypeId = RECORD_TYPE_ID;
            newCase.BSPCountry__c = isocountry.Case_BSP_Country__c ;
            newCase.Country_concerned_by_the_query__c = isocountry.Name;
            newCase.Type_of_customer__c = con.Account.Category__c;

            // CNS
            if(con.Account.RecordType.DeveloperName == 'IATA_Agency' && con.Account.CNS_Account__c == true && newCase.CaseArea__c == 'Accreditation Process') {
                newCase.CNSCase__c = true;
                newCase.Groups__c = 'CNS Team';
            }

            upsert newCase;

            if (String.isBlank(String.ValueOf(newForm.SAAM_Case__c))) {
                newForm.SAAM_Case__c = newCase.Id;
            }

            if(sector.equalsIgnoreCase(AMS_Utils.SECTOR_PASSENGER))
                newForm.Operation_Type__c = 'Travel_Agent';
            else
                newForm.Operation_Type__c = 'Cargo_Agent';

            if (newCase.IFAP_Country_ISO__c == 'CN' && sector.equalsIgnoreCase(AMS_Utils.SECTOR_PASSENGER)) {
                    if (con.Account.Category__c == 'Domestic Agent') {
                        newForm.Operation_Type__c = 'Travel_Agent - Domestic';
                        newForm.Local_Agent_Type__c = 'Domestic';
                    } else {
                        newForm.Operation_Type__c = 'Travel_Agent - International';
                        newForm.Local_Agent_Type__c = 'International';
                    }
            }

            /*** AMSU-121 ***/
            if(newForm.Is_change_location__c) {
                newForm.Shipping_Street__c = null;
                newForm.Shipping_City__c = null;
                newForm.Shipping_State__c = null;
                newForm.Shipping_Country__c = null;
                newForm.Shipping_Postal_Code__c = null;
                newForm.Shipping_ISO_State__c = null;
                newForm.Shipping_ISO_Country__c = null;
            }
            /*** AMSU-121 ***/

            upsert newForm;

            //Ownership area
            if (isNewCase || newCase.Status == 'Open - EDMC') setOwners('NoC');
        } //EO NoC

        selectPageName();

        if (step1GoToNumber == '5') return goToStep5();
        else if (step1GoToNumber == '4') return goToStep4();
        else if (step1GoToNumber == '3') return goToStep3();
        else return goToStep2();
    }

    public void saveAMSForm() {
        newForm.Operation_Type__c = sectorValue;
        if (!isNoticeOfChange) {
            if (amsLocationType != null) {
                newForm.Agent_Type__c = amsLocationType.substring(amsLocationType.indexOf('-') + 1).trim();

                if (newForm.Agent_Type__c == AMS_Utils.AGENTTYPE_WITHCASH) {
                    newForm.ANG_Accreditation_Type__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
                } else if (newForm.Agent_Type__c == AMS_Utils.AGENTTYPE_NOCASH) {
                    newForm.ANG_Accreditation_Type__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS;
                } else if (newForm.Agent_Type__c == AMS_Utils.AGENTTYPE_MULTICOUNTRY) {
                    newForm.ANG_Accreditation_Type__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
                }

            } else if (sectorValue.StartsWith('Travel_Agent')) {
                newForm.Agent_Type__c = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;
            } else {
                newForm.Agent_Type__c = 'IATA Cargo Agent';
            }
        }

        if (sectorValue.StartsWith('Travel_Agent')) {
            if (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_HO');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Branch');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Branch_Abroad');
            }
            else if (newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_STANDARD) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Head_Entity_Standard_with_Cash');
            }else if (newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_LITE) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Head_Entity_Standard_no_Cash');
            }else if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Associate_Entity');
            }

        } else if (sectorValue.StartsWith('Cargo_Agent')) {
            if (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO && newForm.Agent_Type__c == 'IATA Cargo Agent') {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Cargo_Agent_HO');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO && newForm.Agent_Type__c == 'EACP Intermediary') {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Cargo_EACP_HO');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP && newForm.Agent_Type__c == 'EACP Intermediary') {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Cargo_EACP_Branch');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP && newForm.Agent_Type__c == 'IATA Cargo Agent') {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Cargo_Agent_Branch');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO && newForm.Agent_Type__c == AMS_Utils.CATEGORY_CASSASSOCIATE) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'CASS_Associate_HO');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP && newForm.Agent_Type__c == AMS_Utils.CATEGORY_CASSASSOCIATE) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'CASS_Associate_Branch');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO && newForm.Agent_Type__c == AMS_Utils.CATEGORY_COURIER) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Courier_HO');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP && newForm.Agent_Type__c == AMS_Utils.CATEGORY_COURIER) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Courier_Branch');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO && newForm.Agent_Type__c == AMS_Utils.CATEGORY_IMPORT_AGENT) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'CASS_Import_HO');
            } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP && newForm.Agent_Type__c == AMS_Utils.CATEGORY_IMPORT_AGENT) {
                newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'CASS_Import_Branch');
            }
            //Set the field values for Special Cargo types Volumes (Section 8)
            if (specialTrafficList != null) {
                if (!specialTrafficList.isEmpty()) {
                    for (specialTraffic thisSpecialCargo : specialTrafficList) {
                        if (thisSpecialCargo.cargotype == 'Dangerous Goods') {
                            newForm.DG_Number_of_Consignments__c = thisSpecialCargo.consignments;
                            newForm.DG_Tons__c = thisSpecialCargo.tons;
                            newForm.DG_Air_Freight_Charges__c = thisSpecialCargo.airfreight;
                            newForm.DG_Percentage__c = thisSpecialCargo.percentage;
                        } else if (thisSpecialCargo.cargotype == 'Live Animals') {
                            newForm.Live_Animals_No_of_Consignments__c = thisSpecialCargo.consignments;
                            newForm.Live_Animals_Tons__c = thisSpecialCargo.tons;
                            newForm.Live_Animals_Air_Freight_Charges__c = thisSpecialCargo.airfreight;
                            newForm.Live_Animals_Percentage__c = thisSpecialCargo.percentage;
                        } else {
                            newForm.Other_Number_of_Consignments__c = thisSpecialCargo.consignments;
                            newForm.Other_Tons__c = thisSpecialCargo.tons;
                            newForm.Other_Air_Freight_Charges__c = thisSpecialCargo.airfreight;
                            newForm.Other_Percentage__c = thisSpecialCargo.percentage;
                        }
                    }
                }
            }

            //Set the field values for Cargo Region Volumes (Section 8)
            if (cargoRegionList != null) {
                if (!cargoRegionList.isEmpty()) {
                    String regionSelection = '';
                    String regionConsignments = '';
                    String regionTons = '';
                    String regionAirFreight = '';
                    String regionPercentage = '';

                    for (regionSelection thisRegion : cargoRegionList) {
                        if (thisRegion.selected) {
                            if (regionSelection == '') {
                                regionSelection = thisRegion.region;
                                if (thisRegion.consignments == '' || thisRegion.consignments == null) {
                                    thisRegion.consignments = '0';
                                }
                                if (thisRegion.tons == '' || thisRegion.tons == null) {
                                    thisRegion.tons = '0';
                                }
                                if (thisRegion.airfreight == '' || thisRegion.airfreight == null) {
                                    thisRegion.airfreight = '0';
                                }
                                if (thisRegion.percentage == '' || thisRegion.percentage == null) {
                                    thisRegion.percentage = '0';
                                }
                                regionConsignments = thisRegion.consignments;
                                regionTons = thisRegion.tons;
                                regionAirFreight = thisRegion.airfreight;
                                regionPercentage = thisRegion.percentage;
                            } else {
                                regionSelection = regionSelection + ';' + thisRegion.region;
                                if (thisRegion.consignments == '' || thisRegion.consignments == null) {
                                    thisRegion.consignments = '0';
                                }
                                if (thisRegion.tons == '' || thisRegion.tons == null) {
                                    thisRegion.tons = '0';
                                }
                                if (thisRegion.airfreight == '' || thisRegion.airfreight == null) {
                                    thisRegion.airfreight = '0';
                                }
                                if (thisRegion.percentage == '' || thisRegion.percentage == null) {
                                    thisRegion.percentage = '0';
                                }
                                regionConsignments = regionConsignments + ';' + thisRegion.consignments;
                                regionTons = regionTons + ';' + thisRegion.tons;
                                regionAirFreight = regionAirFreight + ';' + thisRegion.airfreight;
                                regionPercentage = regionPercentage + ';' + thisRegion.percentage;
                            }
                        }
                    }
                    newForm.CGO_Region_Selection__c = regionSelection;
                    newForm.CGO_Region_Consignment_Selection__c = regionConsignments;
                    newForm.CGO_Region_Tons_Selection__c = regionTons;
                    newForm.CGO_Region_AirFreight_Selection__c = regionAirFreight;
                    newForm.CGO_Region_Percentage_Selection__c = regionPercentage;
                }
            }

        }

        if (isEUcountry) { ///Add 2-letter ISO Code to VAT Number of EU countries
            if(newForm.ISSP_AMS_VAT_number_input__c != null) 
                newForm.ISSP_AMS_VAT_number__c = newCase.IFAP_Country_ISO__c + newForm.ISSP_AMS_VAT_number_input__c;
        } else 
            newForm.ISSP_AMS_VAT_number__c = newForm.ISSP_AMS_VAT_number_input__c;


        if (cargoAgentAccount != null) 
            newForm.Cargo_Agent_Account__c = cargoAgentAccount.Id;

        if (IATANAgentAccount != null)
            newForm.IATAN_Agent_Account__c = IATANAgentAccount.id;

        //NEWGEN - 604 START
        // Only validate Agency Address details when user is on STEP C (StepNumber==3)
        if(hqAccount != null && (newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH || newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_CASH || newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY) 
            && (!isTerminatedAgent && !isHOAccredited) && stepNumber == '3') {
            if (!validateCharactersInAgencyWindow()) {
                accountUpdated = false;
                return;
            }
            upsert hqAccount;
        }
        //NEWGEN - 604 END

        try {
            if (String.isBlank(String.ValueOf(newForm.SAAM_Case__c))) newForm.SAAM_Case__c = newCase.Id;

            if (isMultiCountryNewAE) newform.HO_Account__c = null;
                 
            upsert newForm;

            if (isMultiCountryNewAE) currentMCFormId = newForm.Id;

            if (!Test.IsRunningTest()) fetchAMSProcessForm();

        } catch (DmlException ex) { ApexPages.addMessages(ex); }
    }

    public static String mapCompanyTypes(String companyType) {
        if(companyType == 'A') {
            return 'Association';
        } else if (companyType == 'C') {
            return 'Corporation';
        } else if (companyType == 'E') {
            return 'Government Owned Enterprise';
        } else if (companyType == 'L') {
            return 'Limited Company';
        } else if (companyType == 'O') {
            return 'Other';
        } else if (companyType == 'P') {
            return 'Partnership';
        } else if (companyType == 'R') {
            return 'Limited Partnership';
        } else if (companyType == 'S') {
            return 'Sole Proprietorship';
        } else if (companyType == 'T') {
            return 'Trust Company';
        } else if (companyType == 'V') {
            return 'Co-operative';
        } else {
            return '';
        }
    }

    private void insertDefaultContact() {
        //First time case is being created so setup current user as Contact (in People's table)

        newForm.IsGSA__c = amsIsGSA;
        newForm.CurrencyIsoCode = isocountry.CurrencyIsoCode;
        saveAMSForm();

        newContact = new AMS_Accreditation_Contact__c();
        newContact.Name = con.Name;
        newContact.Salutation__c = con.Salutation;
        newContact.First_name__c = con.FirstName;
        newContact.Last_name__c = con.LastName;
        newContact.Phone__c = con.Phone;
        newContact.PhoneNational__c = con.PhoneNational__c;
        newContact.Mobile__c = con.MobilePhone;
        newContact.MobileNational__c = con.MobileNational__c;
        newContact.Fax__c = con.Fax;
        newContact.FaxNational__c = con.FaxNational__c;
        newContact.Email__c = con.Email;
        newContact.Job_title__c = con.Title;
        newContact.Authorised_signatory__c = true;
        newContact.Contact__c = con.Id;
        newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
        insert newContact;
    }

    public void createBranchAccount() {
        Account newSFDCAccount = new Account(Id = newForm.ISSP_Branch_AccountId__c);
        updateAccountByBranchApp(newSFDCAccount);
        upsert newSFDCAccount;

        //Populate Online Accred. form (Staging area) with missing values from Branch account
        newForm.ISSP_Branch_AccountId__c = newSFDCAccount.Id;
        newForm.Account_Name__c = newSFDCAccount.Name;
        newForm.Location_Class__c = newSFDCAccount.Location_Class__c;
        newForm.Location_Type__c = newSFDCAccount.Location_Type__c;
        newForm.ISO_Country__c = newSFDCAccount.IATA_ISO_Country__c;

        newCase.Account_Concerned__c = newSFDCAccount.Id;
    }

    private void updateAccountByBranchApp(Account SFDCAccount) {
        SFDCAccount.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        if (!test.isRunningTest())
            SFDCAccount.OwnerId = ISSP_Constant.newAccountOwnerId;
        else if (test.isRunningTest())
            SFDCAccount.OwnerId = userInfo.getUserId();

        SFDCAccount.Location_Class__c = getLocationClass();

        if(getIsAccreditationModelNotNullOrLegacy())
            SFDCAccount.Location_Type__c = AMS_Utils.AE;
        else
            SFDCAccount.Location_Type__c = AMS_Utils.BR;

        SFDCAccount.Reason_for_creation__c = 'Created by customer';

        if(newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE)) {
            SFDCAccount.Name = newForm.Account_Name__c;
            SFDCAccount.TradeName__c = newForm.Trade_Name__c;
        } else {
            SFDCAccount.Name = hqAccount.Name;
        }

        SFDCAccount.ParentId = vHQAccountId;
        SFDCAccount.Sector__c = hqAccount.Sector__c;

        if(hqAccount.Sector__c == AMS_Utils.SECTOR_PASSENGER) 
            SFDCAccount.Category__c = 'Non-IATA Travel Agent';
        else
            SFDCAccount.Category__c = 'Non-IATA Cargo Agent';

        SFDCAccount.Top_Parent__c = hqAccount.ParentId;
        SFDCAccount.Phone = newForm.Branch_Office_Phone__c;
        SFDCAccount.Fax = newForm.Branch_Office_FAX__c;
        SFDCAccount.Email__c = newForm.Branch_Office_Email__c;
        SFDCAccount.IATA_ISO_Country__c = newForm.Branch_Office_Country__c;
        SFDCAccount.BillingCity = newForm.Branch_Office_City__c;
        SFDCAccount.BillingState = newForm.State_Province__c;
        SFDCAccount.BillingStreet = newForm.Branch_Office_Street_name_number__c;
        SFDCAccount.BillingPostalCode = newForm.Branch_Office_Postal_code__c;
        SFDCAccount.BillingCountry = isocountry.Name;
        SFDCAccount.Remittance_frequency__c = hqAccount.Remittance_frequency__c;
    }

    private void createHOAccount(Account parentHO) {
        Account newHOAccount = new Account(Name = newForm.Account_Name__c);

        newHOAccount.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

        if (!test.isRunningTest()) {
            newHOAccount.OwnerId = ISSP_Constant.newAccountOwnerId;
        } else if (test.isRunningTest()) {
            newHOAccount.OwnerId = userInfo.getUserId();
        }

        newHOAccount.TradeName__c = newForm.Trade_Name__c;
        newHOAccount.Phone = newForm.Branch_Office_Phone__c;
        newHOAccount.PhoneNational__c = newForm.Branch_Office_Phone_National__c;
        newHOAccount.Fax = newForm.Branch_Office_FAX__c;
        newHOAccount.FaxNational__c = newForm.Branch_Office_Fax_National__c;
        newHOAccount.Email__c = newForm.Branch_Office_Email__c;
        newHOAccount.Website = newForm.Website__c;
        newHOAccount.IATA_ISO_Country__c = isocountry.Id;
        newHOAccount.BillingCity = newForm.Branch_Office_City__c;
        newHOAccount.BillingState = newForm.State_Province__c;
        newHOAccount.BillingStreet = newForm.Branch_Office_Street_name_number__c;
        newHOAccount.BillingPostalCode = newForm.Branch_Office_Postal_code__c;
        newHOAccount.BillingCountry = isocountry.Name;
        newHOAccount.ShippingCity = newForm.Shipping_City__c;
        newHOAccount.ShippingState = newForm.Shipping_State__c;
        newHOAccount.ShippingStreet = newForm.Shipping_Street__c;
        newHOAccount.ShippingPostalCode = newForm.Shipping_Postal_Code__c;
        newHOAccount.ShippingCountry = isocountry.Name;

        if(newAccreditationModels) //NEWGEN - 1017
            newHOAccount.Location_Type__c = AMS_Utils.HE;
        else
            newHOAccount.Location_Type__c = AMS_Utils.HO;
        

        newHOAccount.Location_Class__c = getLocationClass();

        if(sectorValue.StartsWith('Travel_Agent'))
            newHOAccount.Sector__c = AMS_Utils.SECTOR_PASSENGER;
        else
            newHOAccount.Sector__c = AMS_Utils.SECTOR_CARGO;

        newHOAccount.Reason_for_creation__c = 'Created by customer';

        if(newHOAccount.Sector__c == AMS_Utils.SECTOR_PASSENGER) {
            newHOAccount.Category__c = 'Non-IATA Travel Agent';
        } else {
            newHOAccount.Category__c = 'Non-IATA Cargo Agent';
        }

        insert newHOAccount;

        //Move OSCAR case under newly created HO Account
        //Portal user from initiating HO is still case contact so keeps portal visibility
        newCase.AccountId = newHOAccount.Id;
        hqAccount = newHOAccount;
        vHQAccountId = newHOAccount.Id;
    }

    private String getLocationClass() {
        String locationClass = 'P';

        if (sectorValue.StartsWith('Cargo_Agent')) {
            if (newForm.Agent_Type__c == 'IATA Cargo Agent' || newForm.Agent_Type__c == 'EACP Intermediary')
                locationClass = 'C';
            else if (newForm.Agent_Type__c == AMS_Utils.CATEGORY_CASSASSOCIATE)
                locationClass = 'R';
            else if (newForm.Agent_Type__c == AMS_Utils.CATEGORY_IMPORT_AGENT)
                locationClass = 'I';
            else if (newForm.Agent_Type__c == AMS_Utils.CATEGORY_COURIER)
                locationClass = 'Q';
        }

        return locationClass;
    }

    public void createAgencyContact() {
        Id rtAccreditContPreviousOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Owner');
        contactSaved = true;

        saveAMSForm();

        AMS_Accreditation_Contact__c contactToUpsert = newContact;
        if (contactType == 'Trained Staff') {
            contactToUpsert = trainedStaffContact;
            if (!( isocountry.EACP_Country__c && newForm.Is_your_firm_handling_Dangerous_Goods__c == 'No')
                 && contactToUpsert.Type_Of_Certificate__c != 'BCH' && contactToUpsert.Type_Of_Certificate__c != 'DGA' && contactToUpsert.Type_Of_Certificate__c != 'TSA'
                 && contactToUpsert.Training_dangerous_goods_completed__c == null) {
                contactToUpsert.Training_dangerous_goods_completed__c.addError(Label.ISSP_YouMustEnter);
                contactSaved = false;
                return;
            }
            if (contactToUpsert.Training_dangerous_goods_completed__c == 'Yes') {
                if (contactToUpsert.Valid_until__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Must fill valid until'));
                    contactSaved = false;
                    return;
                }
            }
        }

        if (contactToUpsert.AMS_Pax_Accreditation_Form__c == null)
            contactToUpsert.AMS_Pax_Accreditation_Form__c = newForm.Id;

        Integer cntOwners = [SELECT COUNT() FROM AMS_Accreditation_Contact__c
                     WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND Agency_owner__c = true AND Id != :newContact.Id And RecordType.Name = :contactType];

        refreshCntIFAPContacts();

        Integer cntEmailContacts = [SELECT COUNT() FROM AMS_Accreditation_Contact__c
                            WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND Email__c != :null  AND Email__c = :newContact.Email__c AND Id != :newContact.Id
                                AND RecordTypeId != :rtAccreditContPreviousOwner];

        if (contactType == 'Company' || contactType == 'Current Company Owner') {
            newContact.First_name__c = '';
            newContact.Last_name__c = newContact.Name;
            newContact.Agency_owner__c = true;

            if (companyModalNameOfEmployer == '' && iatacode != '' && iatacode != null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Invalid_IATA_Code));
                contactSaved = false;
                return;
            }
            if (newContact.Registration_number__c == null || newContact.Name == null || newContact.Financial_interest__c == null ) {
                contactSaved = false;
                return;
            }
            if (!validateCharactersInCompanyWindow()) {
                contactSaved = false;
                return;
            }
        } else if (contactType == 'Person' || contactType == 'Current Owner') {
            newContact.Name = (newContact.First_name__c != null ? newContact.First_name__c : '')  + ' ' + newContact.Last_name__c;

            if (!validateCharactersInPersonWindow()) {
                contactSaved = false;
                return;
            }
        } else if (contactType == 'Trained Staff') {
            trainedStaffContact.Name = trainedStaffContact.First_name__c + ' ' + trainedStaffContact.Last_name__c;
        }

        if (!Test.IsRunningTest()) {
            contactToUpsert.RecordTypeId = RecordTypeSingleton.getInstance().getMapRecordTypesBySObject('AMS_Accreditation_Contact__c').get(contactType);
        }

        if (sector == AMS_Utils.SECTOR_PASSENGER) {
            //Clear the links to Prev Emp History Agencies, if they were set from prev selection
            if (newContact.Agencies_prev_worked_for__c == ''  || newContact.Agencies_prev_worked_for__c == 'none') {
                newContact.Accredited_employer_1__c = null;
                newContact.Accredited_employer_2__c = null;
            } else if (newContact.Agencies_prev_worked_for__c == '1') {
                newContact.Accredited_employer_2__c = null;
            }
        }

        newContact.AddressCountry__c = amsContactCountry;

        if (legalstatus == 'sole proprietorship' && newContact.Agency_owner__c == true && amsOfficeType == AMS_Utils.HO)
            newContact.Financial_interest__c = 100;

        try {
            if ((includedPageName == 'ISSP_AMS_Cargo_Form' || includedPageName == 'ISSP_AMS_Pax_Form' || includedPageName == 'ISSP_ANG_PAX_HE') && newContact.Agency_owner__c == true && amsOfficeType == AMS_Utils.HO && (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_STANDARD || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_LITE || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_MULTICOUNTRY) && contactType != 'Company') { //Exclude Owners for Branches Abroad
                if (newContact.Time_devoted_to_Agency_business__c == null) {
                    newContact.Time_devoted_to_Agency_business__c.addError(Label.ISSP_YouMustEnter);
                    contactSaved = false;
                }
                if (newContact.AddressCity__c == null) {
                    newContact.AddressCity__c.addError(Label.ISSP_YouMustEnter);
                    contactSaved = false;
                }
                if (newContact.AddressCountry__c == null) {
                    newContact.AddressCountry__c.addError(Label.ISSP_YouMustEnter);
                    contactSaved = false;
                }
                if (newContact.AddressStreet__c == null) {
                    newContact.AddressStreet__c.addError(Label.ISSP_YouMustEnter);
                    contactSaved = false;
                }

                //Only one owner allowed for Sole Proprietorships
                if (cntOwners >= 1 && newContact.Agency_owner__c == true && legalstatus == 'sole proprietorship') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Sole_Owner_Exists));
                    contactSaved = false;
                }

                if (!contactSaved)
                    return;
            }

            if (isNoticeOfChange) {
                if (newContact.AddressCountry__c == null && contactType == 'Current Owner') {
                    newContact.AddressCountry__c.addError(Label.ISSP_YouMustEnter);
                    contactSaved = false;
                }

                if (contactType == 'Current Owner' && (newContact.Agency_owner__c == true || newContact.Agency_role__c == true)  && (newContact.Time_devoted_to_Agency_business__c < 0 || newContact.Time_devoted_to_Agency_business__c == null))  {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Time_Devoted));
                    contactSaved = false;
                    return;
                }
            }

            if (contactType == 'Current Owner' && newContact.Agency_owner__c == false && newContact.Agency_role__c == false) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_NoC_Type_Of_Person));
                contactSaved = false;
                return;
            }

            //Only one owner allowed for Sole Proprietorships
            if (cntOwners >= 1 && isNoticeOfChange && newContact.Agency_owner__c == true && legalStatusAfterChange == 'sole proprietorship') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Sole_Owner_Exists));
                contactSaved = false;
            }

            if (newContact.Agency_owner__c == true && (amsOfficeType == AMS_Utils.HO || contactType == 'Current Owner') && (newContact.Financial_interest__c <= 0 || newContact.Financial_interest__c == null))  {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_FIN_Interest));
                contactSaved = false;
                return;
            }

            if (sector == AMS_Utils.SECTOR_PASSENGER && !isNoticeOfChange) {
                if (
                    (((newContact.Agency_owner__c == true || newContact.Agency_role__c == true) && amsOfficeType == AMS_Utils.HO && (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_STANDARD || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_LITE || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_MULTICOUNTRY) && contactType != 'Company') || (newContact.Agency_owner__c == false && newContact.Agency_role__c == true && (amsOfficeType == 'Branch' || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD)))  && newContact.Agencies_prev_worked_for__c == null
                    ) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Prev_Employ));
                    contactSaved = false;
                    return;
                }
            }

            //Only Max of 3 IFAP Contacts allowed
            if (cntIFAPContacts >= MAX_IFAP_Contacts && newContact.Financial_Assessment_Contact__c == true) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Max_FinContacts1 + ' ' + MAX_IFAP_CONTACTS + ' ' + Label.ISSP_AMS_Step3_ErrMsg_Max_FinContacts2));
                contactSaved = false;
            }

            if (cntEmailContacts > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_Unique_Email));
                contactSaved = false;
            }

            if (!contactSaved) return;

            if (newContact.Agencies_prev_worked_for__c != 'none' && newContact.Agencies_prev_worked_for__c != null) {
                if (newContact.Prev_Job1_Position__c == null) {
                    newContact.Prev_Job1_Position__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition1);
                }
                if (newContact.Prev_Job1_From__c == null) {
                    newContact.Prev_Job1_From__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition1);
                }
                if (newContact.Prev_Job1_Address__c == null) {
                    newContact.Prev_Job1_Address__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition1);
                }
                if (newContact.Prev_Job1_employer__c == null) {
                    newContact.Prev_Job1_employer__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition1);
                }

                if (newContact.Prev_Job1_Position__c == null || newContact.Prev_Job1_From__c == null || newContact.Prev_Job1_Address__c == null || newContact.Prev_Job1_employer__c == null) {
                    contactSaved = false;
                    return;
                }

                if (newContact.Agencies_prev_worked_for__c == '2' || newContact.Agencies_prev_worked_for__c == '3 or more') {
                    if (newContact.Prev_Job2_Position__c == null) {
                        newContact.Prev_Job2_Position__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition2);
                    }
                    if (newContact.Prev_Job2_From__c == null) {
                        newContact.Prev_Job2_From__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition2);
                    }

                    if (newContact.Prev_Job2_Address__c == null) {
                        newContact.Prev_Job2_Address__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition2);
                    }

                    if (newContact.Prev_Job2_employer__c == null) {
                        newContact.Prev_Job2_employer__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition2);
                    }

                    if (newContact.Prev_Job2_Position__c == null || newContact.Prev_Job2_From__c == null || newContact.Prev_Job2_Address__c == null || newContact.Prev_Job2_employer__c == null) {
                        contactSaved = false;
                        return;
                    }
                }
            }

            upsert contactToUpsert;
            if (contactToUpsert.Financial_Assessment_Contact__c && cntIFAPContacts < 1) {
                cntIFAPContacts = 1;
            }
            newContact = new AMS_Accreditation_Contact__c();
            contactToUpsert = new AMS_Accreditation_Contact__c();
        } catch (DmlException ex) {
            contactSaved = false;
            ApexPages.addMessages(ex);
        }
        iatacode = '';
    }

    public Pagereference securityCheck() {
        if(con.Account.Sector__c != AMS_Utils.SECTOR_PASSENGER && con.Account.Sector__c != AMS_Utils.SECTOR_CARGO)
            return new Pagereference('/ISSP_Homepage?mid=M0S1' + commParam);

        if (newCase.Id != null && newCase.Status != 'Draft' && newCase.Status != 'Open - EDMC' && !createListOfClosedStatuses().contains(newCase.Status) && !isFinalStep && currentMCFormId == null && !isMultiCountryNewAE) {
            return new Pagereference('/ISSP_Case?caseId=' + newCase.Id + '&mid=M1S2' + commParam);
        } else if ((newCase.Id != null && newCase.Status != 'Draft' && newCase.Status != 'Open - EDMC' && createListOfClosedStatuses().contains(newCase.Status) && !isFinalStep) || (isNoticeOfChange && !isEligableForChange)) {
            string retURL = ApexPages.currentPage().getParameters().get('retURL');
            if (retURL == null) {
                return new Pagereference('/ISSP_Homepage?mid=M0S1' +commParam);
            } else {
                return new Pagereference(retURL);
            }
        }

        return null;
    }

    public void createInternationalSales() {
        try {
            salesSaved = true;
            if (newInternationalSales.AMS_Online_Accreditation__c == null) 
                newInternationalSales.AMS_Online_Accreditation__c = newForm.Id;

            if (newInternationalSales.CurrencyIsoCode == '')
                newInternationalSales.CurrencyIsoCode = newForm.CurrencyIsoCode;

            newInternationalSales.IATA_Member_Airline__c = memberairlineid;

            upsert newInternationalSales;
            fetchAMSProcessForm(); //Need to refetch parent AMS form in order to recalculate roll-up Total field in forms currency

            newInternationalSales = new ISSP_AMS_Statement_International_Sales__c();
            memberairlineid = null;
        } catch (DmlException ex) {
            salesSaved = false;
            ApexPages.addMessages(ex);
        }

        newInternationalSales.Sales_Amount__c = null;
        newInternationalSales.Prepaid_Collected__c = null;
        newInternationalSales.Charges_Collected__c = null;
    }

    public void cancelAgentUpdate() {
        //Need to clear pointer to newContact on cancel of update; to avoid replacing contact on adding New Person
        newContact = new AMS_Accreditation_Contact__c();
        iatacode = '';
        contactSaved = false;
    }

    public void cancelAccountUpdate() {
        //Need to clear pointer to newContact on cancel of update; to avoid replacing contact on adding New Person
        fetchHQAccountDetails();
        accountUpdated = false;
    }

    public void cancelSalesUpdate() {
        //Need to clear pointer to new sales on cancel of update; to avoid replacing sales on adding New Sales addition
        newInternationalSales = new ISSP_AMS_Statement_International_Sales__c();
        salesSaved = false;
    }

    public void deleteAgencyContact() {
        AMS_Accreditation_Contact__c delContact = [SELECT Id
                                                FROM AMS_Accreditation_Contact__c
                                                WHERE Id = : editContactId];
        if (delContact != null)
            delete delContact;
        refreshCntIFAPContacts();
    }

    public void deleteTrainedStaff() {
        AMS_Accreditation_Contact__c deleteTrainedStaff = [SELECT Id
                                                        FROM AMS_Accreditation_Contact__c
                                                        WHERE Id = : trainedStaffId];
        if (deleteTrainedStaff != null)
            delete deleteTrainedStaff;
    }

    public void deleteFacility() {
        AMS_Facility__c deleteFacility = [SELECT Id
                                          FROM AMS_Facility__c
                                          WHERE Id = : facilitiesId];
        if (deleteFacility != null) {
            delete deleteFacility;
        }

        facilitiesId = null;
    }

    public void deleteInternationalSales() {
        ISSP_AMS_Statement_International_Sales__c delSales = [SELECT Id
                                                            FROM ISSP_AMS_Statement_International_Sales__c
                                                            WHERE Id = : editSalesId];
        if (delSales != null)
            delete delSales;

        fetchAMSProcessForm(); //Need to refetch parent AMS form in order to recalculate roll-up Total field in forms currency
    }

    public void editAgencyContact() {
        newContact = [SELECT Id, AMS_Pax_Accreditation_Form__c, Name, Authorised_signatory__c, Email__c, First_name__c, Last_name__c, Local_First_name__c, Local_Last_name__c, Salutation__c, Agency_owner__c, Agency_role__c,
                      AddressStreet__c, AddressCity__c, AddressCountry__c, AddressPostcode__c, Financial_interest__c, Date_joined_agency__c, Registration_number__c, IATAcode__c, Company_Name_Local__c,Contact__c,
                      Phone__c, PhoneNational__c, FAX__c, FAXNational__c, Financial_Assessment_Contact__c, Job_title__c, Mobile__c, MobileNational__c, Time_devoted_to_Agency_business__c, Agencies_prev_worked_for__c,
                      Prev_Job1_Position__c, Prev_Job1_From__c, Prev_Job1_IATA_accredited__c, Prev_Job1_IATA_code__c, Prev_Job1_Employer__c, Prev_Job1_Address__c, CASS_contact__c, Number_Of_Shares__c,
                      Prev_Job2_Position__c, Prev_Job2_From__c, Prev_Job2_IATA_accredited__c, Prev_Job2_IATA_code__c, Prev_Job2_Employer__c, Prev_Job2_Address__c, AMS_ContactId__c, AMS_OwnershipId__c, Authorised_to_make_customs_declarations__c
                      FROM AMS_Accreditation_Contact__c
                      WHERE Id = : editContactId];

        amsContactCountry =  newContact.AddressCountry__c;
    }

    public void editInternationalSales() {
        newInternationalSales = [SELECT Id, AMS_Online_Accreditation__c, IATA_Member_Airline__c, Sales_Amount__c, CurrencyIsoCode, Prepaid_Collected__c, Charges_Collected__c, Weight_Kg__c
                                 FROM ISSP_AMS_Statement_International_Sales__c
                                 WHERE Id = : editSalesId];

        memberairlineid = newInternationalSales.IATA_Member_Airline__c;
        fetchAMSProcessForm(); //Need to refetch parent AMS form in order to recalculate roll-up Total field in forms currency
    }

    public void accountUpdatedToggleOff() {
        accountUpdated = false;
    }

    public void cancelFormUpdate() {
        //Need to clear pointer to newContact on cancel of update; to avoid replacing contact on adding New Person
        fetchAMSProcessForm();
        formUpdated = false;
    }

    public void updateAgencyDetails() {
        try {
            accountUpdated = true;

            if (hqAccount.BillingStreet == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                hqAccount.BillingStreet.addError(Label.ISSP_YouMustEnter);
                accountUpdated = false;
            }

            if (hqAccount.BillingCity == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                hqAccount.BillingCity.addError(Label.ISSP_YouMustEnter);
                accountUpdated = false;
            }

            if (hqAccount.Email__c == null) {
                hqAccount.Email__c.addError(Label.ISSP_YouMustEnter);
                accountUpdated = false;
            }

            if (!accountUpdated) return;

            if (!validateCharactersInAgencyWindow()) {
                accountUpdated = false;
                return;
            }

            upsert hqAccount;
        } catch (DmlException ex) {
            accountUpdated = false;
            ApexPages.addMessages(ex);
        }
    }

    public void updateNoCAgencyLegalDetails() {
        try {
            formUpdated = true;
            upsert newForm;
        } catch (DmlException ex) {
            formUpdated = false;
            ApexPages.addMessages(ex);
        }
    }

    public void updateNoCAgencyLocation() {
        try {
            formUpdated = true;

            if (newForm.Branch_Office_Street_name_number__c == null) {
                newForm.Branch_Office_Street_name_number__c.addError(Label.ISSP_YouMustEnter);
                formUpdated = false;
            }

            if (newForm.Branch_Office_City__c == null) {
                newForm.Branch_Office_City__c.addError(Label.ISSP_YouMustEnter);
                formUpdated = false;
            }

            if (newForm.Branch_Office_Email__c == null) {
                newForm.Branch_Office_Email__c.addError(Label.ISSP_YouMustEnter);
                formUpdated = false;
            }

            if (!formUpdated) return;

            if (accountConcerned.BillingStreet == newForm.Branch_Office_Street_name_number__c)
                newForm.Branch_Office_Street_name_number__c = null;

            if (accountConcerned.BillingCity == newForm.Branch_Office_City__c)
                newForm.Branch_Office_City__c = null;

            if (accountConcerned.BillingPostalCode == newForm.Branch_Office_Postal_code__c)
                newForm.Branch_Office_Postal_code__c = null;

            if (accountConcerned.BillingState == newForm.State_Province__c)
                newForm.State_Province__c = null;

            if (accountConcerned.Email__c == newForm.Branch_Office_Email__c)
                newForm.Branch_Office_Email__c = null;

            if (accountConcerned.Phone == newForm.Branch_Office_Phone__c && accountConcerned.PhoneNational__c == newForm.Branch_Office_Phone_National__c) {
                newForm.Branch_Office_Phone__c = null;
                newForm.Branch_Office_Phone_National__c = null;
            }

            if (accountConcerned.FAX == newForm.Branch_Office_Fax__c && accountConcerned.FAXNational__c == newForm.Branch_Office_Fax_National__c) {
                newForm.Branch_Office_Fax__c = null;
                newForm.Branch_Office_Fax_National__c = null;
            }

            upsert newForm;
        } catch (DmlException ex) {
            formUpdated = false;
            ApexPages.addMessages(ex);
        }
    }

    public Pagereference goToStep1() {
        String pageURL = '/ISSP_AMS_Accreditation?caseId=' + newCase.Id + '&step=1' + commParam;

        if (isNoticeOfChange) pageURL += '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange;
        else if (isMultiCountryNewAE) pageURL += '&isMultiCountryNewAE=true';

        return new Pagereference(pageURL);
    }

    public Pagereference goToStep2() {
        String pageURL = '/ISSP_AMS_Accreditation?caseId=' + newCase.Id + '&step=2' + commParam;

        if (isNoticeOfChange) pageURL += '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange;
        else if (isMultiCountryNewAE) pageURL += '&isMultiCountryNewAE=true&currentMCFormId=' + currentMCFormId;

        return new Pagereference(pageURL);
    }

    public Pagereference goToStep3Section1() {
        if (isNoticeOfChange)
            return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + commParam + '&step=3#nav_one' );
        return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id  + commParam +'&step=3#nav_one' );
    }

    public Pagereference goToStep3Section2() {
        if (isNoticeOfChange)
            return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + commParam + '&step=3#nav_two' );
        return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + commParam + '&step=3#nav_two');
    }

    public Pagereference goToStep3Section3() {
        if (isNoticeOfChange)
            return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + commParam +'&step=3#nav_three' );
        return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id  + commParam +'&step=3#nav_three');
    }

    public Pagereference goToStep3Section4() {
        if (isNoticeOfChange)
            return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + commParam +'&step=3#nav_four' );
        return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + commParam +'&step=3#nav_four' );
    }

    public Pagereference goToStep3Section5() {
        if (isNoticeOfChange)
            return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + commParam +'&step=3#nav_five' );
        return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + commParam +'&step=3#nav_five' );
    }

    public Pagereference goToStep3Section6() {
        return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + commParam + '&step=3#nav_six');
    }

    public Pagereference goToStep3Section7() {
        return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + commParam + '&step=3#nav_seven');
    }

    public Pagereference goToStep3Section8() {
        return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + commParam + '&step=3#nav_eight' );
    }

    public Pagereference goToStep3() {
        String pageURL = '/' + includedPageName + '?caseId=' + newCase.Id + commParam +'&step=3';

        if (isNoticeOfChange) pageURL += '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange;
        else if (isMultiCountryNewAE) pageURL += '&isMultiCountryNewAE=true&currentMCFormId=' + currentMCFormId;

        return new Pagereference(pageURL);
    }

    public Pagereference goToStep4() {
        String pageURL = '/ISSP_AMS_Accreditation?caseId=' + newCase.Id + '&step=4' + commParam;
        if (isNoticeOfChange) {
            if(newForm.Is_change_ownership_or_shareholding__c) { //No File Upload for Change of Ownership
                return goToStep3();
            } else {
                pageURL += '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange;
            }
        } else if (isMultiCountryNewAE) pageURL += '&isMultiCountryNewAE=true&currentMCFormId=' + currentMCFormId;

        return new Pagereference(pageURL);
    }

    public Pagereference goToStep5() {
        String pageURL = '/ISSP_AMS_Accreditation?caseId=' + newCase.Id + '&step=5' + commParam;

        if (isNoticeOfChange) pageURL += '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange;
        else if (isMultiCountryNewAE) pageURL += '&isMultiCountryNewAE=true&currentMCFormId=' + currentMCFormId;
        
        return new Pagereference(pageURL);
    }

    public Pagereference highLightPageForErrors() {
        if (newForm.Validation_ERRORS__c ) {
            if (!validateCharactersInForm() || !validateForm(true)) return null;
        }
        return null;
    }

    public Pagereference saveAMSFormAndGoForward() {
        try {
            newForm.Validation_ERRORS__c = FALSE;
            saveAMSForm();

            if (!validateCharactersInForm() || !validateForm(true))
                return null;

            if (isNoticeOfChange && newForm.Is_change_ownership_or_shareholding__c)
                return goToStep5(); //No File Upload for NoC that isn't change of bank details

            return goToStep4();
        } catch (DmlException ex) { ApexPages.addMessages(ex); }
        return null;
    }

    public Pagereference saveAMSFormAndGoToStep5() {
        try {
            newForm.Validation_ERRORS__c = FALSE;

            if (!validateCharactersInForm()) return null;

            saveAMSForm();
            return goToStep5();
        } catch (DmlException ex) { ApexPages.addMessages(ex); }
        return null;
    }

    public Pagereference saveAMSFormAndGoBack() {
        try {
            newForm.Validation_ERRORS__c = FALSE;

            if (!validateCharactersInForm()) return null;

            saveAMSForm();
            return goToStep2();
        } catch (DmlException ex) { ApexPages.addMessages(ex); }
        return null;
    }

    public Pagereference saveAMSFormAndGoToStep1() {
        try {
            newForm.Validation_ERRORS__c = FALSE;

            if (!validateCharactersInForm()) return null;

            saveAMSForm();
            return goToStep1();
        } catch (DmlException ex) { ApexPages.addMessages(ex); }
        return null;
    }

    public Pagereference saveAMSFormAndLeave() {
        newForm.Validation_ERRORS__c = FALSE;
        saveAMSForm();
        return redirectToCasesList();
    }

    public Pagereference redirectToCasesList() {
        return new Pagereference('/ISSP_AMSCases' + commParamFirst);
    }

    private void updateAccountDetails() {
        if (newForm.Branch_Office_Phone__c != null)
            accountConcerned.Phone = newForm.Branch_Office_Phone__c;
        
        if (newForm.Branch_Office_Phone_National__c != null)
            accountConcerned.PhoneNational__c = newForm.Branch_Office_Phone_National__c;
        
        if (newForm.Branch_Office_Fax__c != null)
            accountConcerned.Fax = newForm.Branch_Office_Fax__c;
        
        if (newForm.Branch_Office_Fax_National__c != null)
            accountConcerned.FaxNational__c = newForm.Branch_Office_Fax_National__c;
        
        if (newForm.Branch_Office_Email__c != null)
            accountConcerned.Email__c = newForm.Branch_Office_Email__c;
        
        if (!isocountry.Prevent_Portal_Trade_Name_Change__c && newForm.Trade_Name__c != null)
            accountConcerned.TradeName__c = newForm.Trade_Name__c;

        upsert accountConcerned;
    }

    public Pagereference goToFinalStep() {
        if (!validateCharactersInForm() || !validateForm(true) ) {
            newForm.Validation_ERRORS__c = TRUE;
            upsert newForm;
            return goToStep3();
        }

        if (!validateAttachedFiles()) {
            newForm.Validation_ERRORS__c = TRUE;
            upsert newForm;

            if (redirectToStepE) return goToStep5();

            return goToStep4();
        }
        
        if (!newform.Accept_terms_and_conditions__c && !isMultiCountry) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_Accept_TOS));
            return null;
        }

        //INC355752 - add attachment to case after submission
        if(isNoticeOfChange) attachNOCFormToCase(newCase.Id, isBankAccountChange);

        try {
            if (isNoticeOfChange && !isBankAccountChange && newCase.RecordTypeId == OSCAR_RECORD_TYPE_ID && isocountry.Enable_Minor_Changes_from_Portal__c)
                updateAccountDetails();

            if (newCase.RecordTypeId == OSCAR_RECORD_TYPE_ID) { 
                setPortalAdminContact(); //Portal Admin is stored on AMS Form; for OSCAR Countries need to set AMS Contact as Portal Admin on submit
                setInvoicingContact(); // CB AMSU-10
            } 

            if (!isNoticeOfChange) {
                //ONLY FOR PARTNERSHIP: Check if the signed PDF was uploaded to Amazon
                if (getIsPartnership()) {
                    list<AmazonFile__c> listAmazonFile = [SELECT Id
                                                          FROM AmazonFile__c
                                                          WHERE Case__c = :newCase.Id
                                                            AND File_Identifier__c = :FILE_ID_FOR_PARTNERSHIP];
                    if (listAmazonFile.isEmpty()) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_Form_Missing_Signed_File));
                        return null;
                    }
                }
                if (amsOfficeType == 'Branch' || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD) {
                    createBranchAccount();
                    if(newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD)
                        accountStagingFieldMapping(hqAccount, newCase.Reason1__c, true);
                } else if (isNewHOforAccredAgent || isTerminatedAgent) {
                    //Terminated Agent, or Accredited agent applying for HO of a different program e.g. PAX HO applying for IATA CGO HO
                    //So create a new HO account and move case to new account
                    createHOAccount(hqAccount);
                    accountStagingFieldMapping(hqAccount, newCase.Reason1__c, true);
                } else {  //Non-accredited agent applying for new HO
                    if(newAccreditationModels) //NEWGEN - 1017
                        hqAccount.Location_Type__c = AMS_Utils.HE;
                    else
                        hqAccount.Location_Type__c = AMS_Utils.HO;

                    hqAccount.Location_Class__c = getLocationClass();
                    upsert hqAccount;

                    accountStagingFieldMapping(hqAccount, newCase.Reason1__c, false);
                }
            } else {
                if(!newForm.Notify_Change_Accreditation_Type__c) {
                    newForm.ANG_Accreditation_type__c = con.Account.ANG_Accreditation_Model__c;
                } else {
                    newForm.ANG_Accreditation_type__c = newForm.ANG_Accreditation_Model_to_Change__c;
                }
            }

            newForm.Submitted_to_IATA__c = TRUE;

            //RB-INC381175: Oscar fields Shipping ISO Country & Shipping ISO State not populated by the account's equivalent fields
            if (newCase.RecordTypeId == OSCAR_RECORD_TYPE_ID && (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP
                || newForm.Location_Type__c == 'AE' || newForm.Location_Type__c == 'HE')) {
                if (newForm.Shipping_ISO_Country__c == null) {
                    newForm.Shipping_ISO_Country__c = newForm.Branch_Office_Country__c;
                }

                if (newForm.Shipping_ISO_State__c == null) {
                    newForm.Shipping_ISO_State__c = newForm.IATA_ISO_State__c;
                }
            }

            if (newCase.RecordTypeId == OSCAR_RECORD_TYPE_ID && (newCase.Reason1__c == 'Major Change')) {
                if (newForm.Shipping_ISO_Country__c == null) {
                    newForm.Shipping_ISO_Country__c = accountConcerned.IATA_ISO_Shipping_Country__c;
                }

                if (newForm.Shipping_ISO_State__c == null) {
                    newForm.Shipping_ISO_State__c = accountConcerned.IATA_ISO_Shipping_State__c;
                }
            }

            if (isMultiCountry) newForm.Status__c = 'Completed';

            upsert newForm;

            newCase.Status = 'Open';
            newCase.Dossier_reception_date__c = datetime.now().date();

            if (newForm.INVALID_Tax_number__c) {
                newCase.Comments__c = 'NOTE: The invalid tax number ' + newCase.IFAP_Country_ISO__c + newForm.ISSP_AMS_VAT_number_input__c + ' has been submitted with this application';
            }

            //Account concerned is set for NoC to display info on LHS of form STEP C
            //However, remove on Submit to IATA if same as acount of user i..e. Case Account, as it is not required
            if(newCase.Account_Concerned__c == newCase.AccountId)
                newCase.Account_Concerned__c = null;

            // AMSU-110 assign Case via assignment rules -> re-trigger assignment rules on update
            //update newCase;
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            Database.update(newCase, dmo);

            //***********

            String accountId = vHQAccountId;
            if (isNoticeOfChange) accountId = accountConcerned.Id;

            String typeOfProcess = 'NEW.HO.1.0';
            if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD)
                typeOfProcess = 'NEW.BR.ABROAD';
            else if (!isNoticeOfChange && amsOfficeType == 'Branch' && newCase.Reason1__c != AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD)
                typeOfProcess = 'NEW.BR';
            else if (isNoticeOfChange && isBankAccountChange)
                typeOfProcess = 'BANK.ACCOUNT.CHANGES';
            else if (isNoticeOfChange && !isBankAccountChange) {
                //NEWGEN 683
                if (getIsAccreditationModelNotNullOrLegacy())
                    typeOfProcess = AMS_UTILS.NGCHANGES;
                else if(newCase.Reason1__c == AMS_Utils.CASE_REASON_CHG_DATA_MAINTENANCE) //AMSU-140//AMSU-165
                    typeOfProcess = AMS_Utils.COR;  
                else
                    typeOfProcess = 'MAJOR.CHANGES';
            }

            else if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_STANDARD)
                typeOfProcess = 'ANG.NEW.HE.STANDARD.1.0';
            else if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_LITE)
                typeOfProcess = 'ANG.NEW.HE.LITE.1.0';
            else if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE)
                typeOfProcess = 'ANG.NEW.AE.1.0';
            else if(newCase.Reason1__c == 'Corrections') //AMSU-140
                typeOfProcess = AMS_Utils.COR;  

            if (newCase.RecordTypeId == OSCAR_RECORD_TYPE_ID && !isMultiCountry)
                OSCARIntegration(accountId, newForm.Id, typeOfProcess, newCase.Id);

            //Create child OSCAR Comm cases for Change of Bank details where one or more (but not all) Branches are involved
            if (isNoticeOfChange && isBankAccountChange && (newForm.Scope_of_Change__c == 'HO - Selected Branches' || newForm.Scope_of_Change__c=='Selected Branches Only')){
                createChildCases();
            }

            //Send std Case Confirmation email
            sendConfirmationEmail(newCase);

            // AMSU-39 if NoC from BR then create notification for HO portal admin
            if (isNoticeOfChange && amsOfficeType != AMS_Utils.HO && amsOfficeType != AMS_Utils.HE) {
                createHoAdminNotifications();
            }

            if (isNoticeOfChange)
                return new Pagereference('/ISSP_AMS_Accreditation?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + '&step=Final' + commParam);

            if (isMultiCountry) return new PageReference('/ISSP_AMSCases');

            return new Pagereference('/ISSP_AMS_Accreditation?caseId=' + newCase.Id + '&step=Final' + commParam);
        } catch (DmlException ex) {
            newForm.Submitted_to_IATA__c = FALSE;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'DML error - '+ex.getMessage()+' / '+ex.getLineNumber()));
        } catch (Exception e) {
            newForm.Submitted_to_IATA__c = FALSE;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'error - '+e.getMessage()+' / '+e.getLineNumber()));
        }

        return null;
    }

    private static void attachNOCFormToCase(Id caseId, Boolean isBankAccountChange) {
        PageReference pdfNOC = new Pagereference('/ISSP_AMS_PDF_NoC?caseId=' + caseId + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange);
        Blob bodyNOC;

        try {
            bodyNOC = pdfNOC.getContent();
        } catch (Exception e) { System.debug('ERROR getting PDF content: ' + e.getMessage()); }

        if(bodyNOC != null) {
            Long size = bodyNOC.size();
            String fileName = 'Notice_of_Change_form.pdf';
            String contentType = 'application/pdf';
            String folder = WrapperAttach.getAmazonFolder(caseId);

            UploadMultipleFileToAmazonButtonCtrl.UploadFile upF = UploadMultipleFileToAmazonButtonCtrl.createUploadFile(caseId, fileName, contentType, size, folder,  WrapperAttach.CREDENTIAL_NAME);

            Boolean result = AmazonRest.uploadFile(upF, bodyNOC);

            if(result) UploadMultipleFileToAmazonButtonCtrl.createAmazonFileObject(folder+fileName, size, caseId, 'AMS_File', OTHERS, 'Portal');
        }
    }

    public Pagereference goToDownloadPDF() {
        passedFormValidation = true;

        if (!validateCharactersInForm() || !validateForm(true) ) {
            newForm.Validation_ERRORS__c = TRUE;
            upsert newForm;

            passedFormValidation = false;
            return goToStep3();
        }

        return null;
    }

    private void accountStagingFieldMapping(Account sourceAccount, String strReason, Boolean alreadyAccredited) {  //Field mapping to be used when updating staging area from HO Account for HO Applications
        Map<String, String> mapAccountToAccrFormFields;
        if((strReason == AMS_Utils.CASE_REASON_NEW_HO || strReason == AMS_UTILS.CASE_REASON_HE_LITE || strReason == AMS_UTILS.CASE_REASON_HE_STANDARD || strReason == AMS_UTILS.CASE_REASON_HE_MULTICOUNTRY) && !alreadyAccredited) {
            mapAccountToAccrFormFields = new Map<String, String> {'Name' => 'Account_Name__c', 'IATACode__c' => 'IATACode__c', 'Short_Name__c' => 'Short_Name__c',
                'Location_Class__c' => 'Location_Class__c', 'Location_Type__c' => 'Location_Type__c', 'TradeName__c' => 'Trade_Name__c',
                'BillingStreet' => 'Branch_Office_Street_name_number__c', 'BillingPostalCode' => 'Branch_Office_Postal_code__c', 'BillingState' => 'Billing_State__c', 'BillingCity' => 'Branch_Office_City__c',
                'IATA_ISO_Country__c' => 'ISO_Country__c', 'IATA_ISO_Country__c' => 'Branch_Office_Country__c', 'Iso_State__c' => 'IATA_ISO_State__c', 'ShippingCountry' => 'Shipping_Country__c', 'ShippingStreet' => 'Shipping_Street__c',
                'ShippingPostalCode' => 'Shipping_Postal_Code__c', 'ShippingState' => 'Shipping_State__c', 'ShippingCity' => 'Shipping_City__c', 'Email__c' => 'Branch_Office_Email__c',
                'Website' => 'Website__c', 'Phone' => 'Branch_Office_Phone__c', 'Fax' => 'Branch_Office_FAX__c', 'Mobile__c' => 'Mobile__c', 'Abbreviated_name__c' => 'Abbreviated_name__c',
                'Abbreviated_Address__c' => 'Abbreviated_Address__c', 'Remittance_frequency__c' => 'Remittance_frequency__c', 'Solicitation_Flag__c' => 'Solicitation_Flag__c',
                'VAT_Number_2__c' => 'VAT_Number_2__c', 'CASS_Number__c' => 'CASS_Number__c'};
        } else if((strReason == AMS_Utils.CASE_REASON_NEW_HO || strReason == AMS_UTILS.CASE_REASON_HE_LITE || strReason == AMS_UTILS.CASE_REASON_HE_STANDARD || strReason == AMS_UTILS.CASE_REASON_HE_MULTICOUNTRY) && alreadyAccredited) {
            mapAccountToAccrFormFields = new Map<String, String> {'Name' => 'Account_Name__c', 'Short_Name__c' => 'Short_Name__c',
                'Location_Class__c' => 'Location_Class__c', 'Location_Type__c' => 'Location_Type__c', 'TradeName__c' => 'Trade_Name__c',
                'BillingStreet' => 'Branch_Office_Street_name_number__c', 'BillingPostalCode' => 'Branch_Office_Postal_code__c', 'BillingState' => 'Billing_State__c', 'BillingCity' => 'Branch_Office_City__c',
                'IATA_ISO_Country__c' => 'ISO_Country__c', 'IATA_ISO_Country__c' => 'Branch_Office_Country__c', 'Iso_State__c' => 'IATA_ISO_State__c', 'ShippingCountry' => 'Shipping_Country__c', 'ShippingStreet' => 'Shipping_Street__c',
                'ShippingPostalCode' => 'Shipping_Postal_Code__c', 'ShippingState' => 'Shipping_State__c', 'ShippingCity' => 'Shipping_City__c', 'Email__c' => 'Branch_Office_Email__c',
                'Website' => 'Website__c', 'Phone' => 'Branch_Office_Phone__c', 'Fax' => 'Branch_Office_FAX__c', 'Mobile__c' => 'Mobile__c'};
        } else if (strReason == AMS_Utils.CASE_REASON_BR_ABROAD)  {
            mapAccountToAccrFormFields = new Map<String, String> {'Location_Class__c' => 'Location_Class__c',
                'IATA_ISO_Country__c' => 'ISO_Country__c', 'Iso_State__c' => 'IATA_ISO_State__c'};
        }

        for (String accountApiName : mapAccountToAccrFormFields.keyset())
            newForm.put(mapAccountToAccrFormFields.get(accountApiName), sourceAccount.get(accountApiName));
    }

    public boolean validateCharactersInAgencyWindow() {
        boolean errorFound = false;
        Pattern p = Pattern.compile(ISO_8859_1_regEx);

        if (hqAccount.Website != null && !p.matcher(hqAccount.Website).matches()) {
            hqAccount.Website.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if (hqAccount.BillingCountry != null && !p.matcher(hqAccount.BillingCountry).matches()) {
            hqAccount.BillingCountry.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (hqAccount.BillingPostalCode != null && !p.matcher(hqAccount.BillingPostalCode).matches()) {
            hqAccount.BillingPostalCode.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (hqAccount.BillingCity != null && !p.matcher(hqAccount.BillingCity).matches()) {
            hqAccount.BillingCity.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (hqAccount.BillingStreet != null && !p.matcher(hqAccount.BillingStreet).matches()) {
            hqAccount.BillingStreet.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (hqAccount.TradeName__c != null && !p.matcher(hqAccount.TradeName__c).matches()) {
            hqAccount.TradeName__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (hqAccount.Name != null && !p.matcher(hqAccount.Name).matches()) {
            hqAccount.Name.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if (errorFound)
            return false;

        return true;
    }

    public boolean validateCharactersInPersonWindow() {
        Boolean errorFound = false;
        Pattern p = Pattern.compile(ISO_8859_1_regEx);

        if (newContact.First_name__c != null && !p.matcher(newContact.First_name__c).matches()) {
            newContact.First_name__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (newContact.Last_name__c != null && !p.matcher(newContact.Last_name__c).matches()) {
            newContact.Last_name__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (newContact.AddressStreet__c != null && !p.matcher(newContact.AddressStreet__c).matches()) {
            newContact.AddressStreet__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if (newContact.AddressCity__c != null && !p.matcher(newContact.AddressCity__c).matches()) {
            newContact.AddressCity__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (newContact.AddressPostcode__c != null && !p.matcher(newContact.AddressPostcode__c).matches()) {
            newContact.AddressPostcode__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (newContact.Job_title__c != null && !p.matcher(newContact.Job_title__c).matches()) {
            newContact.Job_title__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if (newContact.Agencies_prev_worked_for__c != 'none') {
            if (newContact.Prev_Job1_Employer__c != null && !p.matcher(newContact.Prev_Job1_Employer__c).matches()) {
                newContact.Prev_Job1_Employer__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
            if (newContact.Prev_Job1_Position__c != null && !p.matcher(newContact.Prev_Job1_Position__c).matches()) {
                newContact.Prev_Job1_Position__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
            if (newContact.Prev_Job1_Address__c != null && !p.matcher(newContact.Prev_Job1_Address__c).matches()) {
                newContact.Prev_Job1_Address__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
            if (newContact.Agencies_prev_worked_for__c != '1') {
                if (newContact.Prev_Job2_Employer__c != null && !p.matcher(newContact.Prev_Job2_Employer__c).matches()) {
                    newContact.Prev_Job2_Employer__c.addError(Label.ISSP_EnterValidString);
                    errorFound = true;
                }
                if (newContact.Prev_Job2_Position__c != null && !p.matcher(newContact.Prev_Job2_Position__c).matches()) {
                    newContact.Prev_Job2_Position__c.addError(Label.ISSP_EnterValidString);
                    errorFound = true;
                }
                if (newContact.Prev_Job2_Address__c != null && !p.matcher(newContact.Prev_Job2_Address__c).matches()) {
                    newContact.Prev_Job2_Address__c.addError(Label.ISSP_EnterValidString);
                    errorFound = true;
                }
            }
        }

        if (errorFound) return false;

        return true;
    }

    public boolean validateCharactersInCompanyWindow() {
        boolean errorFound = false;
        Pattern p = Pattern.compile(ISO_8859_1_regEx);

        if (newContact.Name != null && !p.matcher(newContact.Name).matches()) {
            newContact.Name.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (newContact.Registration_number__c != null && !p.matcher(newContact.Registration_number__c).matches()) {
            newContact.Registration_number__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if (errorFound) return false;

        return true;
    }

    /*** AMSU--112 Start ***/
    public Set<String> accfieldsToCheck = new Set<String> {'BillingState', 'BillingStreet', 'BillingCity', 'TradeName__c', 'Name', 'BillingPostalCode'};
    
    public Set<String> formfieldsToCheck = new Set<String> {'Account_Name__c', 'Trade_Name__c', 'Branch_Office_Street_name_number__c', 'Branch_Office_City__c', 'Branch_Office_Postal_code__c', 'State_Province__c',
                                                            'Shipping_Street__c', 'Shipping_City__c', 'Shipping_Postal_Code__c', 'Shipping_State__c', 'Shipping_Country__c', 'ISSP_AMS_License_No__c',
                                                            'ISSP_AMS_Trade_Reg_No__c', 'ISSP_AMS_where_incorporated__c', 'ISSP_AMS_Principal_business_Org__c'};
    
    public Set<String> confieldsToCheck = new Set<String> {'AddressStreet__c', 'AddressCity__c', 'First_name__c', 'Last_name__c'};
    
    public void checkTabCharacters(AMS_Pax_Accreditation_Form__c form, Account acc, AMS_Accreditation_Contact__c con) {
        for(String fieldToCheck : formfieldsToCheck)
            form.put(fieldToCheck, AMS_Utils.replaceTabCharcter((String) form.get(fieldToCheck)));

        for(String fieldToCheck : accfieldsToCheck)
            acc.put(fieldToCheck, AMS_Utils.replaceTabCharcter((String) acc.get(fieldToCheck)));
    
        for(String fieldToCheck : confieldsToCheck)
            con.put(fieldToCheck, AMS_Utils.replaceTabCharcter((String) con.get(fieldToCheck)));
    
    }
    /*** AMSU-112 End ***/

    public boolean validateCharactersInForm() {
        Boolean errorFound = false;
        Pattern p = Pattern.compile(ISO_8859_1_regEx);

        if(!isNoticeOfChange) {
            if (newForm.ISSP_AMS_where_incorporated__c != null && !p.matcher(newForm.ISSP_AMS_where_incorporated__c).matches()) {
                newForm.ISSP_AMS_where_incorporated__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Principal_business_Org__c != null && !p.matcher(newForm.ISSP_AMS_Principal_business_Org__c).matches()) {
                newForm.ISSP_AMS_Principal_business_Org__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (hqAccount.BillingState != null && !p.matcher(hqAccount.BillingState).matches()) {
                hqAccount.BillingState.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (newContact.Job_title__c != null && !p.matcher(newContact.Job_title__c ).matches()) {
                newContact.Job_title__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (newContact.AddressStreet__c != null && !p.matcher(newContact.AddressStreet__c).matches()) {
                newContact.AddressStreet__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (newForm.ISSP_AM_Means_Identified_Travel_Agency__c != null && !p.matcher(newForm.ISSP_AM_Means_Identified_Travel_Agency__c).matches()) {
                newForm.ISSP_AM_Means_Identified_Travel_Agency__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Prev_default_explanation__c != null && !p.matcher(newForm.ISSP_AMS_Prev_default_explanation__c).matches()) {
                newForm.ISSP_AMS_Prev_default_explanation__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (newContact.AddressCity__c != null && !p.matcher(newContact.AddressCity__c).matches()) {
                newContact.AddressCity__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (newContact.First_name__c != null && !p.matcher(newContact.First_name__c).matches()) {
                newContact.First_name__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (newContact.Last_name__c != null && !p.matcher(newContact.Last_name__c).matches()) {
                newContact.Last_name__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (hqAccount.BillingStreet != null && !p.matcher(hqAccount.BillingStreet).matches()) {
                hqAccount.BillingStreet.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (hqAccount.BillingCity != null && !p.matcher(hqAccount.BillingCity).matches()) {
                hqAccount.BillingCity.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
        }

        /*** AMSU-112 - Start ***/
        //replace tab character
        checkTabCharacters(newForm, hqAccount, newContact);
        //check non latin characters
        if((!String.isBlank(newForm.Account_Name__c) && !p.matcher(newForm.Account_Name__c).matches()) || (!String.isBlank(hqAccount.Name) && !p.matcher(hqAccount.Name).matches())) {
            newForm.Account_Name__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if((!String.isBlank(newForm.Trade_Name__c) && !p.matcher(newForm.Trade_Name__c).matches()) ||(!String.isBlank(hqAccount.TradeName__c) && !p.matcher(hqAccount.TradeName__c).matches())) {
            newForm.Trade_Name__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if(!String.isBlank(newForm.ISSP_AMS_License_No__c) && !p.matcher(newForm.ISSP_AMS_License_No__c).matches()) {
            newForm.ISSP_AMS_License_No__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if(!String.isBlank(newForm.ISSP_AMS_Trade_Reg_No__c) && !p.matcher(newForm.ISSP_AMS_Trade_Reg_No__c).matches()) {
            newForm.ISSP_AMS_Trade_Reg_No__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if(!String.isBlank(newForm.Branch_Office_Street_name_number__c) && !p.matcher(newForm.Branch_Office_Street_name_number__c).matches()) {
            newForm.Branch_Office_Street_name_number__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if(!String.isBlank(newForm.Branch_Office_City__c) && !p.matcher(newForm.Branch_Office_City__c).matches()) {
            newForm.Branch_Office_City__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if(!String.isBlank(newForm.Branch_Office_Postal_code__c) && !p.matcher(newForm.Branch_Office_Postal_code__c).matches()) {
            newForm.Branch_Office_Postal_code__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if(!String.isBlank(newForm.State_Province__c) && !p.matcher(newForm.State_Province__c).matches()) {
            newForm.State_Province__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if(!String.isBlank(newForm.ISSP_AMS_VAT_Number_Input__c) && !p.matcher(newForm.ISSP_AMS_VAT_Number_Input__c).matches()) {
            newForm.ISSP_AMS_VAT_Number_Input__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if(!String.isBlank(newForm.ISSP_AMS_VAT_number__c) && !p.matcher(newForm.ISSP_AMS_VAT_number__c).matches()) { 
            newForm.ISSP_AMS_VAT_number__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if((!String.isBlank(newForm.Shipping_Street__c) && !p.matcher(newForm.Shipping_Street__c).matches()) || (!String.isBlank(hqAccount.ShippingStreet) && !p.matcher(hqAccount.ShippingStreet).matches())) {
            newForm.Shipping_Street__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if((!String.isBlank(newForm.Shipping_City__c) && !p.matcher(newForm.Shipping_City__c).matches()) || (!String.isBlank(hqAccount.ShippingCity) && !p.matcher(hqAccount.ShippingCity).matches())) {
            newForm.Shipping_City__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if((!String.isBlank(newForm.Shipping_Postal_Code__c) && !p.matcher(newForm.Shipping_Postal_Code__c).matches()) || (!String.isBlank(hqAccount.ShippingPostalCode) && !p.matcher(hqAccount.ShippingPostalCode).matches())) {
            newForm.Shipping_Postal_Code__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if((!String.isBlank(newForm.Shipping_State__c) && !p.matcher(newForm.Shipping_State__c).matches()) || (!String.isBlank(hqAccount.ShippingState) && !p.matcher(hqAccount.ShippingState).matches())) {
            newForm.Shipping_State__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if((!String.isBlank(newForm.Shipping_Country__c) && !p.matcher(newForm.Shipping_Country__c).matches()) || (!String.isBlank(hqAccount.ShippingCountry) && !p.matcher(hqAccount.ShippingCountry).matches())) {
            newForm.Shipping_Country__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        /*** AMSU-112 - End ***/

        if (amsOfficeType == 'Branch' || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || (isNoticeOfChange && newForm.Notify_Change_Location__c)) {
            if (newForm.Branch_Office_Street_name_number__c != null && !p.matcher(newForm.Branch_Office_Street_name_number__c).matches()) {
                newForm.Branch_Office_Street_name_number__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
            if (newForm.Branch_Office_City__c != null && !p.matcher(newForm.Branch_Office_City__c).matches()) {
                newForm.Branch_Office_City__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;

            }
            if (newForm.Branch_Office_Postal_code__c != null && !p.matcher(newForm.Branch_Office_Postal_code__c).matches()) {
                newForm.Branch_Office_Postal_code__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
            if (newForm.State_Province__c != null && !p.matcher(newForm.State_Province__c).matches()) {
                newForm.State_Province__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            Pattern validEmail = Pattern.compile('([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,6}|[0-9]{1,6}))');

            if (newForm.Branch_Office_Email__c != null && !validEmail.matcher(newForm.Branch_Office_Email__c).matches()) {
                newForm.Branch_Office_Email__c.addError(Label.ISSP_AMS_Invalid_Email);
                errorFound = true;
            }
        }

        if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || (isNoticeOfChange && newForm.Notify_Change_Legal_Details__c)) {
            if (newForm.Account_name__c != null && !p.matcher(newForm.Account_name__c).matches()) {
                newForm.Account_name__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (newForm.Trade_Name__c != null && !p.matcher(newForm.Trade_Name__c).matches()) {
                newForm.Trade_Name__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
        }

        String allowedUrlRegEx = ISSP_CS__c.getValues('ISSP AMS ALLOWED AGENCY URL').Value__c;

        Pattern validUrl = Pattern.compile(allowedUrlRegEx);

        if (newForm.ISSP_AMS_Online_Agency_URL__c != null && !validUrl.matcher(newForm.ISSP_AMS_Online_Agency_URL__c.toLowerCase()).matches()) {
            newForm.ISSP_AMS_Online_Agency_URL__c.addError(Label.ISSP_AMS_Valid_URL);
            errorFound = true;
        }
        if (newForm.ISSP_AMS_Legal_Reg_Name_Address__c != null && !p.matcher(newForm.ISSP_AMS_Legal_Reg_Name_Address__c).matches()) {
            newForm.ISSP_AMS_Legal_Reg_Name_Address__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if (errorFound) return false;

        return true;
    }

    public void sendConfirmationEmail(Case newCase) {
        String emailTemplateName;
        String fromaddress;

        if(newCase.Reason1__c == 'FoP Management' && newCase.origin == 'Massive FOP Creation') {
            emailTemplateName = 'ISSP ANG PCI Process Notification';
            fromaddress = 'IATA Service Centre (noreply@iata.org)';
        } else if (isNoticeOfChange && (newCase.ContactId == con.id)) { //Can't user VF template if Contact submitting case does not have case visibility i.e. is not the case contact
            emailTemplateName = 'ISSP AMS Process Notification';
            fromaddress = 'IATA Service Centre (noreply@iata.org)';
        } else if (newCase.BSPCountry__c == null) {
            emailTemplateName = 'EUR_Case confirmation - online HTML (English) - Europe';
            fromaddress = 'IATA (noreply@iata.org)';
        } else if (newCase.BSPCountry__c.contains('Spain')) {
            emailTemplateName = 'EUR_Case confirmation - online HTML (Spanish)';
            fromaddress = 'IATA Service Centre - Europe (noreply@iata.org)';
        } else if (newCase.BSPCountry__c == 'France') {
            emailTemplateName = 'EUR_Case Confirmation - online HTML (French)';
            fromaddress = 'IATA Service Centre - Europe (noreply@iata.org)';
        } else if (newCase.Region__c == 'Europe') {
            emailTemplateName = 'EUR_Case confirmation - online HTML (English) - Europe';
            fromaddress = 'IATA Europe (noreply@iata.org)';
        } else if (newCase.BSPCountry__c == 'Canada') {
            emailTemplateName = 'A1 - CS Auto-response confirmation (EN/FR)';
            fromaddress = 'IATA Customer Service Americas (noreply@iata.org)';
        } else if (newCase.BSPCountry__c == 'Brazil') {
            emailTemplateName = 'A1 - CS Auto-response confirmation (EN/PT)';
            fromaddress = 'IATA Customer Service Americas (noreply@iata.org)';
        } else if (newCase.Region__c == 'Americas') {
            emailTemplateName = 'A1 - CS Auto-response confirmation (EN/SP)';
            fromaddress = 'IATA Customer Service Americas (noreply@iata.org)';
        } else if (newCase.Region__c.contains('China')) {
            emailTemplateName = 'N.ASIA_Case confirmation - online HTML (English)- China';
            fromaddress = 'IATA China - Customer Services (noreply@iata.org)';
        } else if (newCase.Region__c.contains('Africa')) {
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
        if (Test.IsRunningTest() == false) {
            Messaging.sendEmail(emails);
        }
    }

    private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        con = DAL_ISSP.getContact(user.ContactId);

        if (con.User_Portal_Status__c == 'Administrator' || con.User_Portal_Status__c == 'Approved Admin' || con.User_Portal_Status__c == 'Regional Administrator' || con.User_Portal_Status__c == 'R. Administrator' )
            bIsAdmin = true;
    }

    public void fetchCase(String vCaseId) {
        List <Case> newCases = [SELECT Id, CaseNumber, Reason1__c, CaseArea__c, Status, BSPCountry__c, Country_concerned_by_the_query__c, Contact.Name, Account.Id, Description, Subject, Account_Concerned__c, Account_Concerned__r.Top_Parent__c, Account.Name,
                                   Account.Billing_Address_formated__c, Verification__c, IFAP_Country_ISO__c, Case_Language__c, Region__c, Applicable_to_Which_Version_s__c
                                FROM Case
                                WHERE Id = :vCaseId];
        if (newCases.size() > 0) {
            isNewCase = false;
            newCase = newCases[0];
            if (newCase.Status != 'Draft') {
                redirectToCasesList();
            }
        } else {
            redirectToCasesList();
        }
    }

    private string getCaseReason(string r, String accreditationModel) {
        if (r == AMS_Utils.CASE_REASON_NEW_HO)
            return Label.ISSP_AMS_Reason_New_HO;
        else if (r == AMS_Utils.CASE_REASON_BR_IP)
            return Label.ISSP_AMS_Reason_New_Branch;
        else if (r == AMS_Utils.CASE_REASON_BR_ABROAD)
            return Label.ISSP_AMS_Reason_Branch_Abroad;
        else if (r == AMS_Utils.CASE_REASON_HE_STANDARD)
            return Label.ISSP_AMS_Head_Entity_Cash;
        else if ( r == AMS_Utils.CASE_REASON_HE_LITE)
            return Label.ISSP_AMS_Head_Entity_No_Cash;
        else if(r == AMS_Utils.CASE_REASON_HE_MULTICOUNTRY)
            return Label.ISSP_AMS_Head_Entity_Multicountry;
        else if( r == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || r == AMS_Utils.CASE_REASON_AE_MULTICOUNTRY)
            return Label.ISSP_ANG_Assoc_Entity + getAccreditationModel(accreditationModel);
        else if(r == AMS_Utils.CASE_REASON_OPT_OUT)
            return Label.ANG_ISSP_CASE_REASON_OPT_OUT;
        else 
            return Label.ISSP_AMS_Reason_New_HO;
    }

    private String getAccreditationModel(String accreditationModel) {
        if (accreditationModel == AMS_Utils.ACCREDITATIONMODEL_CASH)
            return ' - ' + Label.ANG_ISSP_ProductStandardAccreditationWithCash;
        else if (accreditationModel == AMS_Utils.ACCREDITATIONMODEL_CASHLESS)
            return ' - ' + Label.ANG_ISSP_ProductStandardAccreditationWithNoCash;
        else if (accreditationModel == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY)
            return ' - ' + Label.ANG_ISSP_ProductStandardAccreditationWithMultiCountry;
        else
            return '';
    }

    private string getAgentTypeLabel(string agentType) {
        return (agentType == 'Legacy') ? Label.ISSP_AMS_IATA_Passenger_Sales_Agent : agentType;
    }

    private string getApplicationTypeLabel(string amsLocationType) {
        if (amsLocationType == AMS_Utils.TYPE_EACP_HO)
            return Label.ISSP_AMS_OPTION_EACP_HO;
        else if (amsLocationType == AMS_Utils.TYPE_EACP_BRANCH)
            return Label.ISSP_AMS_OPTION_EACP_BRANCH;
        else if (amsLocationType == AMS_Utils.TYPE_CGO_HO)
            return isocountry.AMS_Accreditation_New_Labels__c? Label.ISSP_AMS_OPTION_CGO_HO_New: Label.ISSP_AMS_OPTION_CGO_HO;
        else if (amsLocationType == AMS_Utils.TYPE_CGO_BRANCH)
            return Label.ISSP_AMS_OPTION_CGO_BRANCH;
        else if (amsLocationType == AMS_Utils.TYPE_CASS_ASSOC_HO)
            return Label.ISSP_AMS_OPTION_CASS_ASSOC_HO;
        else if (amsLocationType == AMS_Utils.TYPE_CASS_ASSOC_BRANCH)
            return Label.ISSP_AMS_OPTION_CASS_ASSOC_BRANCH;
        else if (amsLocationType == AMS_Utils.TYPE_IMPORT_HO)
            return Label.ISSP_AMS_OPTION_IMPORT_HO;
        else if (amsLocationType == AMS_Utils.TYPE_IMPORT_BRANCH)
            return Label.ISSP_AMS_OPTION_IMPORT_BRANCH;
        else if (amsLocationType == AMS_Utils.TYPE_COURIER_HO)
            return Label.ISSP_AMS_OPTION_COURIER_HO;
        else if (amsLocationType == AMS_Utils.TYPE_COURIER_BRANCH)
            return Label.ISSP_AMS_OPTION_COURIER_BRANCH;
        else if (amsLocationType == AMS_Utils.TYPE_PAX_HO)
            return Label.ISSP_AMS_OPTION_PAX_HO;
        else if (amsLocationType == AMS_Utils.TYPE_PAX_BRANCH_ABROAD_PSA) 
            return Label.ISSP_AMS_OPTION_PAX_BRANCH_ABROAD;
        else if (amsLocationType == AMS_Utils.TYPE_PAX_AE_CASH || amsLocationType == AMS_Utils.TYPE_PAX_AE_NO_CASH || amsLocationType == AMS_Utils.TYPE_PAX_AE_MULTICOUNTRY) //NEWGEN - 552
            return Label.ISSP_ANG_OPTION_PAX_AE;
        else if (amsLocationType == AMS_Utils.TYPE_HE_ST_CASH || amsLocationType == AMS_Utils.TYPE_HE_MULTICOUNTRY)
            return Label.ISSP_ANG_OPTION_PAX_HE_standard;
        else if (amsLocationType == AMS_Utils.TYPE_HE_LITE_NO_CASH)
            return Label.ISSP_ANG_OPTION_PAX_HE_lite;
        else
            return Label.ISSP_AMS_OPTION_PAX_BRANCH;
    }

    public AMS_Accreditation_Country_CheckList__c CountryCheckList {
        get{
            List<AMS_Accreditation_Country_CheckList__c> aux = [
                SELECT License_required__c, Registration_required__c, Statement_of_International_Sales__c, Statement_of_International_Sales_Branch__c
                FROM AMS_Accreditation_Country_CheckList__c
                WHERE IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND Operation__c = :sector
            ];

            if(!aux.isEmpty()) {
                return aux[0];
            } else {
                return null;
            }
        }
        set{}
    }

    public void fetchCountryRequirements() {
        Set<String> allowIdentifierSetTravel = new Set<String>();
        Set<String> identifierSetTravel = new Set<String>{AMS_UTILS.PCI_COMPLIANCE};

        if (sectorValue.StartsWith('Travel_Agent') && isNoticeOfChange == false) {
            String selectedLang;
            String accredModel;
            Id TravelReqRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Requirement__c', 'Travel_Agent');

            AggregateResult[] distinctReqmentLangs;

            if (applyLanguage == 'fr') selectedLang = 'French';
            else if (applyLanguage == 'es') selectedLang = 'Spanish';
            else selectedLang = 'English';

            if(newForm.Agent_Type__c == AMS_Utils.AGENTTYPE_WITHCASH){
                accredModel = AMS_Utils.ACCREDITATIONMODEL_CASH;
            } else if (newForm.Agent_Type__c == AMS_Utils.AGENTTYPE_NOCASH){
                accredModel = AMS_Utils.ACCREDITATIONMODEL_CASHLESS;
            } else if (newForm.Agent_Type__c == AMS_Utils.AGENTTYPE_MULTICOUNTRY) {
                accredModel = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
            } else {
                accredModel = newForm.Agent_Type__c;
            }

            if(newAccreditationModels){ //AMSU-113
            //NEWGEN-583 start
                if(newForm.Enable_Credit_Card_FOP__c == 'Yes') allowIdentifierSetTravel.add(PCI_COMPLIANCE);
                    
            } else allowIdentifierSetTravel.add(PCI_COMPLIANCE);
                
            Set<String> excludeIdentifierSetTravel = new Set<String>();
            for(String identifier : identifierSetTravel){
                if(!(allowIdentifierSetTravel.contains(identifier)))
                    excludeIdentifierSetTravel.add(identifier);
            }
            //NEWGEN-583 end

             //Get distinct set of Languages for this country / operation requirements
            distinctReqmentLangs = [SELECT Language__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Language__c !=null
                                        AND RecordTypeId = :TravelReqRecTypeId
                                    GROUP BY Language__c
                                    ORDER BY Language__c ASC];
            //First look for country requirements in the User's selected language
            List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                        AND Location_type__c INCLUDES (:amsOfficeType) AND ANG_Accreditation_Model__c INCLUDES (:accredModel) AND Language__c = :selectedLang AND RecordTypeId = :TravelReqRecTypeId
                                        AND File_Identifier2__c NOT IN: excludeIdentifierSetTravel
                                    ORDER BY Sort_Order__c ASC];
            //Then look for country requirements in English if not found for selected language
            if (List_CountryReqments.size() == 0) {
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                            AND Location_type__c INCLUDES (:amsOfficeType) AND ANG_Accreditation_Model__c INCLUDES (:accredModel) AND Language__c = 'English' AND RecordTypeId = :TravelReqRecTypeId
                                            AND File_Identifier2__c NOT IN: excludeIdentifierSetTravel
                                        ORDER BY Sort_Order__c ASC];
            }

            if (distinctReqmentLangs.size() > 0) {
                //... and if English not found return requirements in 3rd lang
                String finalLang = (String)distinctReqmentLangs[0].get('Language__c');
                if (List_CountryReqments.size() == 0) {
                    List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                            FROM AMS_Accreditation_Requirement__c
                                            WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                                AND Location_type__c INCLUDES (:amsOfficeType) AND ANG_Accreditation_Model__c INCLUDES (:accredModel) AND Language__c = :finalLang AND RecordTypeId = :TravelReqRecTypeId
                                                AND File_Identifier2__c NOT IN: excludeIdentifierSetTravel
                                            ORDER BY Sort_Order__c ASC];
                }

            }

            // Clean any css style in the Requirement_text__c and also Bold tags
            for(AMS_Accreditation_Requirement__c req : List_CountryReqments) {
                if (req.Requirement_text__c != null) {
                    req.Requirement_text__c = req.Requirement_text__c.replaceAll('style[/a-zA-Z0-9="-: ;]*','');
                    req.Requirement_text__c = req.Requirement_text__c.replaceAll('<b>','');
                    req.Requirement_text__c = req.Requirement_text__c.replaceAll('</b>','');
                }
            }

        } else if (sectorValue.StartsWith('Cargo_Agent') && isNoticeOfChange == false) {
            retCargoCountryReqments(false);
        } else if (sectorValue.StartsWith('Cargo_Agent') && isNoticeOfChange == true) {
            retNoCCargoCountryReqments(false);
        } else if (sectorValue.StartsWith('Travel_Agent') && isNoticeOfChange == true) {
            retNoCTravelCountryReqments(false);
        }
    }

    public void fetchHQAccountDetails () {
        Set<string> closedStatusesList = createListOfClosedStatuses();
        hqAccount = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                        TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                        Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                        Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                        ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,
                        Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                        VAT_Number_2__c, CASS_Number__c,Company_Type__c,RecordType.DeveloperName,Status__c,IATA_ISO_Country__r.ISO_Code__c,ANG_Accreditation_Model__c,
                        IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c, Ownership, 
                        (SELECT Id, Status, Reason1__c, IFAP_Country_ISO__c, Applicable_to_Which_Version_s__c
                         FROM Cases WHERE AccountId = :vHQAccountId 
                            AND Reason1__c LIKE '%multicountry%'
                            AND Status NOT IN :closedStatusesList)
                    FROM Account
                    WHERE Id = :vHQAccountId
                    LIMIT 1];

        if (!hqAccount.Cases.isEmpty()) {
            isMultiCountryStarted = true;
            newCase = hqAccount.Cases[0];
        }
    }

    public void fetchAccountConcernedDetails () {
        accountConcerned = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                                TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                                Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                                Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                                ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,
                                Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                                VAT_Number_2__c, CASS_Number__c,Company_Type__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c
                            FROM Account
                            WHERE Id = :vAccountConcernedId
                            LIMIT 1];
    }

    public void fetchAMSProcessForm() {
        String query = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('AMS_Pax_Accreditation_Form__c').getDescribe().fields.getMap();

        for(String field : objectFields.keySet())
           query += field + ', ';

        query += 'Branch_Office_Country__r.Name, SAAM_Case__r.Reason1__c ';
        query += 'FROM AMS_Pax_Accreditation_Form__c ';

        if (currentMCFormId != null && currentMCFormId != '')
            query += 'WHERE Id = \'' + currentMCFormId + '\'';
        else
            query += 'WHERE SAAM_Case__c = \'' + newCase.Id + '\'';
        
        List<AMS_Pax_Accreditation_Form__c> newForms = Database.query(query);
        if (!newForms.isEmpty()) newForm = newForms[0];
    }

    public void resetOwnership() { //NEWGEN-1249
        List<AMS_Accreditation_Contact__c> allOwners = [SELECT Name, RecordType.DeveloperName, Financial_interest__c,ANG_contactFromAccount__c
                                                        FROM AMS_Accreditation_Contact__c
                                                        WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id
                                                            AND Agency_owner__c = true
                                                            AND ANG_contactFromAccount__c = true];

        checkAllOwners = new List<AMS_Accreditation_Contact__c>();

        if(allOwners.size() > 0) checkAllOwners = allOwners;
    }

    public void resetCreatedOwnership() { //NEWGEN-1249
        List<AMS_Accreditation_Contact__c> allOwners = [SELECT Name, RecordType.DeveloperName, Financial_interest__c,ANG_contactFromAccount__c
                                                        FROM AMS_Accreditation_Contact__c
                                                        WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id
                                                            AND Agency_owner__c = true
                                                            AND ANG_contactFromAccount__c = false];

        checkAllOwners = new List<AMS_Accreditation_Contact__c>();

        if(allOwners.size() > 0) checkAllOwners = allOwners;
    }

    public IATA_ISO_Country__c fetchISOCountry(string isocode) {
        return IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{isocode})[0];
    }

    public List<AMS_Facility__c> facilityList {
        get{
            return [SELECT Id, recordTypeId, recordType.Name, Name, AMS_Online_Accreditation__c, Alarm_system__c, Automated_export_accounting__c, Automated_export_documentation__c,
            Date_agreement_expires__c, Date_lease_expires__c, Duration_of_contract__c, Email__c, Name_of_lessor__c,
            Name_of_sub_contractor__c, Other_pertinent_details__c, Telephone__c, Accessibility_to_vehicles__c,
            An_alarm_system__c, Any_functions_involved_in_preperations__c, Area_used_for_Air_freight__c, Are_Consignments_made_ready__c,
            A_sprinkler_system__c, Ceiling_height__c, Date_location_opened_for_business__c, Distance_from_nearest_Airport__c,
            Distance_from_nearest_Office__c, Doc_Areas__c, Fax__c, Is_the_office_warehouse_leased__c, Is_the_office_open_to_the_general_public__c, General_Public_Opening_Hours__c,
            Is_the_warehouse_sub_contracted__c, Is_warehouse_open_to_general_public__c, List_airports_serviced_by_this_facility__c,
            Number_of_overhead_doors__c, Office_Full_Address__c, Telex__c, Total_Area__c, Type__c, Type_of_Premises__c, Website__c,
            Forklift_Max_Weight__c, Forklift_Number__c, Forklift_Type__c, Other_equipment_Max_Weight__c, Other_equipment_Number__c, Other_equipment_Type__c,
            Scales_Max_Weight__c, Scales_Number__c, Scales_Type__c, Duration_of_lease__c
            FROM AMS_Facility__c
            WHERE AMS_Online_Accreditation__c = : this.newForm.Id];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> trainedStaffList {
        get{
            return [SELECT Id, Name, First_name__c, Last_name__c, Position_trained_staff__c, List_Dangerous_Goods_Awareness__c,
                        IATA_FIATA_training_history__c, Training_dangerous_goods_completed__c, Valid_until__c, Air_cargo_transport_business_exp__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__c = :this.newForm.Id
                        AND recordTypeId = :RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Trained_Staff')];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> List_AgencyContacts {
        get{
            return [SELECT AMS_Pax_Accreditation_Form__c, Name, Authorised_signatory__c, Email__c, First_name__c, Last_name__c, Salutation__c, Agency_owner__c, Agency_role__c,
                        AddressStreet__c, AddressCity__c, AddressCountry__c, AddressPostcode__c, Financial_interest__c, Date_joined_agency__c, CASS_contact__c, Invoicing_Contact__c,
                        Phone__c, FAX__c, Financial_Assessment_Contact__c, Job_title__c, Mobile__c, Time_devoted_to_Agency_business__c, Agencies_prev_worked_for__c,
                        Prev_Job1_Position__c, Prev_Job1_From__c, Prev_Job1_IATA_accredited__c, Prev_Job1_IATA_code__c, Prev_Job1_Employer__c, Prev_Job1_Address__c,
                        Prev_Job2_Position__c, Prev_Job2_From__c, Prev_Job2_IATA_accredited__c, Prev_Job2_IATA_code__c, Prev_Job2_Employer__c, Prev_Job2_Address__c, Duplicate_contact_exists__c,
                        Portal_administrator__c, Contact_Id__c,Contact__c, AMS_OwnershipId__c, AMS_ContactId__c, Authorised_to_make_customs_declarations__c, Local_First_name__c, Local_Last_name__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND RecordType.DeveloperName = 'Person'
                    ORDER BY Agency_owner__c DESC, Name ASC];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> List_IFAPAgencyContacts {
        get{
            return [SELECT Salutation__c, Name, Email__c, First_name__c, Last_name__c,
                       Phone__c, FAX__c, Financial_Assessment_Contact__c, Mobile__c,
                       Contact_Id__c, Contact__c, AMS_Pax_Accreditation_Form__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND  RecordType.DeveloperName = 'Person' AND Financial_Assessment_Contact__c = true
                    ORDER BY Agency_owner__c DESC, Name ASC];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> List_PreviousOwners {
        get{
            return [SELECT AMS_Pax_Accreditation_Form__c, Name, First_name__c, Last_name__c, Salutation__c, Agency_owner__c, Agency_role__c, Email__c,Phone__c,
                        Financial_interest__c, Contact_Id__c, Contact__c, AMS_OwnershipId__c, AMS_ContactId__c, Local_First_name__c, Local_Last_name__c, Number_Of_Shares__c,
                        AddressStreet__c, AddressCity__c, AddressCountry__c, AddressPostcode__c, Time_devoted_to_Agency_business__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND  RecordType.DeveloperName = 'Previous_Owner'
                    ORDER BY Name ASC];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> List_CurrentOwners {
        get{
            return [SELECT AMS_Pax_Accreditation_Form__c, Name, First_name__c, Last_name__c, Salutation__c, Agency_owner__c, Agency_role__c, Email__c,Phone__c,
                        Financial_interest__c, Contact_Id__c, AMS_OwnershipId__c, AMS_ContactId__c, Local_First_name__c, Local_Last_name__c, Number_Of_Shares__c,
                        AddressStreet__c, AddressCity__c, AddressCountry__c, AddressPostcode__c, Time_devoted_to_Agency_business__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND  RecordType.DeveloperName = 'Current_Owner'
                    ORDER BY Name ASC];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> List_CurrentCompanies {
        get{
            return [SELECT Name, Financial_interest__c, Registration_number__c, IATAcode__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id 
                        AND RecordType.DeveloperName = 'Current_Company_Owner'
                    ORDER BY Name ASC];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> List_PreviousCompanies {
        get{
            return [SELECT Name, Financial_interest__c, Registration_number__c, IATAcode__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND  RecordType.DeveloperName = 'Previous_Company_Owner'
                    ORDER BY Name ASC];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> List_AgencyCompanies {
        get{
            return [SELECT Name, Financial_interest__c, Registration_number__c, IATAcode__c, Company_Name_Local__c, Agency_owner__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND  RecordType.DeveloperName = 'Company'
                    ORDER BY Name ASC];
        }
        set;
    }

    public List<ISSP_AMS_Statement_International_Sales__c> List_InternationalSales {
        get{
            return [SELECT IATA_Member_Airline__c, Sales_Amount__c, IATA_Member_Airline__r.Name, Charges_Collected__c, Prepaid_Collected__c, Weight_Kg__c
                    FROM ISSP_AMS_Statement_International_Sales__c
                    WHERE AMS_Online_Accreditation__c = :newForm.Id
                    ORDER BY Name ASC];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> List_Ownership_Summary {
        get{
            return [SELECT Name, RecordType.DeveloperName, Financial_interest__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0)
                    ORDER BY Name ASC];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> List_Curr_Ownership_Summary {
        get{
            return [SELECT Name, RecordType.DeveloperName, Financial_interest__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0) 
                        AND (RecordType.DeveloperName = 'Current_Company_Owner' OR RecordType.DeveloperName = 'Current_Owner')
                    ORDER BY Name ASC];
        }
        set;
    }

    public List<AMS_Accreditation_Contact__c> List_Prev_Ownership_Summary {
        get{
            return [SELECT Name, RecordType.DeveloperName, Financial_interest__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0) 
                        AND (RecordType.DeveloperName = 'Previous_Company_Owner' OR RecordType.DeveloperName = 'Previous_Owner')
                    ORDER BY Name ASC];
        }
        set;
    }

    public Double Ownership_Total {
        get{
            AggregateResult ownerTotal = [SELECT SUM(Financial_interest__c)total
                                        FROM AMS_Accreditation_Contact__c
                                        WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0)];
            
            return (Double)ownerTotal.get('total');
        }
        set;
    }

    public Double Curr_Ownership_Total {
        get{
            AggregateResult ownerTotal = [SELECT SUM(Financial_interest__c)total
                                        FROM AMS_Accreditation_Contact__c
                                        WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0) 
                                            AND (RecordType.DeveloperName = 'Current_Company_Owner' 
                                            OR RecordType.DeveloperName = 'Current_Owner')];
            
            return (Double)ownerTotal.get('total');
        }
        set;
    }

    public Double Prev_Ownership_Total {
        get{
            AggregateResult ownerTotal = [
                SELECT SUM(Financial_interest__c)total
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0) AND
                (RecordType.DeveloperName = 'Previous_Company_Owner' OR RecordType.DeveloperName = 'Previous_Owner')];

            return (Double)ownerTotal.get('total');
        }
        set;
    }

    public Decimal InternationalSales_Total {
        get{
            AggregateResult salesTotal = [SELECT SUM(Sales_Amount__c)total
                                        FROM ISSP_AMS_Statement_International_Sales__c
                                        WHERE AMS_Online_Accreditation__c = :newForm.Id];
            
            return (Decimal)salesTotal.get('total');
        }
        set;
    }

    public Decimal InternationalCharges_Collected_Total {
        get{
            AggregateResult chargesTotal = [SELECT SUM(Charges_Collected__c)total
                                        FROM ISSP_AMS_Statement_International_Sales__c
                                        WHERE AMS_Online_Accreditation__c = :newForm.Id];
            
            return (Decimal)chargesTotal.get('total');
        }
        set;
    }

    public Decimal InternationalPrepaid_Collected_Total {
        get{
            AggregateResult prepaidTotal = [SELECT SUM(Prepaid_Collected__c)total
                                            FROM ISSP_AMS_Statement_International_Sales__c
                                            WHERE AMS_Online_Accreditation__c = :newForm.Id];

            return (Decimal)prepaidTotal.get('total');
        }
        set;
    }

    public String Portal_Login_URL {
        get{
            return ISSP_CS__c.getValues('ISSP Portal Login URL') != null ? ISSP_CS__c.getValues('ISSP Portal Login URL').value__c : '';
        }
        set;
    }

    // ApexPages.StandardSetController must be instantiated for standard list controllers
    public ApexPages.StandardSetController setConn {
        get {
            Set<string> closedStatusesList = createListOfClosedStatuses();
            if (setConn == null) {
                setConn = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, CaseNumber, CreatedDate, Account.Name, Country_concerned_by_the_query__c, Subject, Status, Portal_Case_Status__c, Priority, Reason1__c, CaseArea__c, Account.Billing_Address_formated__c
                FROM Case
                WHERE RecordType.Name IN ('SAAM', 'OSCAR Communication')
                AND (Status = 'Draft' OR (Status Not In :closedStatusesList AND Case.ContactId = :con.Id))
                AND Origin = 'Portal'
                AND ((Case.AccountId = :con.AccountId) OR (Case.Account_Concerned__r.Top_Parent__c = :con.AccountId))
                AND Case.Reason1__c IN (:AMS_Utils.CASE_REASON_NEW_HO,
                                        :AMS_Utils.CASE_REASON_BR_IP,
                                        :AMS_Utils.CASE_REASON_BR_ABROAD,
                                        'CHL - Change of Location', 'CHN - Change of Name',
                                        'CHO / CHS – Change of Ownership / Legal Status', 'Bank Detail Update',
                                        'IRIS Bank Detail Update', 'Major Change',
                                        :AMS_Utils.CASE_REASON_HE_STANDARD,
                                        :AMS_Utils.CASE_REASON_HE_LITE,
                                        :AMS_Utils.CASE_REASON_ASSOCIATE_ENTITY_STANDARD ,
                                        :AMS_UTILS.CASE_REASON_FOR_MANAGEMENT,
                                        :AMS_Utils.CASE_REASON_OPT_OUT)
                ORDER BY CaseNumber DESC]));
            }
            return setConn;
        }
        set;
    }

    public Set<string> createListOfClosedStatuses() {
        Set<string> closedStatusesList = new Set<string>();
        Schema.DescribeFieldResult caseDescribe = case.Status.getDescribe();

        List<Schema.PicklistEntry> caseStatusValues = caseDescribe.getPicklistValues();

        List<String> caseStatuesStrValues = new List<String>();

        for (Schema.PicklistEntry csv : caseStatusValues)
            caseStatuesStrValues.add(csv.getValue());

        for (casestatus cs : [Select Apiname, IsClosed from casestatus where ApiName IN: caseStatuesStrValues And IsClosed = true])
            closedStatusesList.add(cs.apiname);

        return closedStatusesList;
    }

    public Boolean getIsEmpty() {
        if (getAMSDraftCases().isEmpty()) return true;
            
        return false;
    }

    Public Boolean getIsNotEmpty() {
        List<Case> AMSCases = getAMSDraftCases();
        if (AMSCases.isEmpty()) return false;
            
        return true;
    }

    // Initialize setCon and return a list of records
    public List<Case> getAMSDraftCases() {
        List<Case> l = (List<Case>) setConn.getRecords();

        Boolean isOpt_IN_OUT_InProgress = false;

        for(Case c : l) {
            if(c.Reason1__c == AMS_Utils.CASE_REASON_OPT_OUT) {
                isOpt_IN_OUT_InProgress = true;
                break;
            }
        }

        Boolean flagShowOptOutButton = (sector ==  AMS_Utils.SECTOR_PASSENGER && con.Account.Category__c == AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT &&
            isHOAccredited && isHOcontact && con.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH && !con.Account.ANG_FA_Opt_out__c);

        Boolean flagShowOptOutButtonDisabled = (flagShowOptOutButton && isOpt_IN_OUT_InProgress);

        if(flagShowOptOutButtonDisabled) flagShowOptOutButton = false;

        Boolean flagShowOptInButton = (sector ==  AMS_Utils.SECTOR_PASSENGER && con.Account.Category__c == AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT &&
            isHOAccredited && isHOcontact && con.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH && con.Account.ANG_FA_Opt_out__c);

        Boolean flagShowOptInButtonDisabled = (flagShowOptInButton && isOpt_IN_OUT_InProgress);

        if(flagShowOptInButtonDisabled) flagShowOptInButton = false;

        if(flagShowOptOutButton) optInOutSuccessMessage = Label.ISSP_ANG_OPT_OUT_SUCCESS_MESSAGE;

        if(flagShowOptInButton) optInOutSuccessMessage = Label.ISSP_ANG_OPT_IN_SUCCESS_MESSAGE;

        isIFAPContact = (con.Financial_Assessment_Contact__c);

        if (flagShowOptInButton) {
            optInOutErrorNoDate = Label.ANG_ISSP_OptInEmptyDateErrorMessage;
            optInOutBtn = Label.ISSP_ANG_OPT_IN_FINANCIAL_REVIEW_BTN;
            optInOutModalTitle = Label.ISSP_ANG_OPT_IN_MODAL_TITLE;
            flagShowOptInOutButton = true;
            if(isIFAPContact) {
                if(bIsAdmin) {
                    optInOutMessage = Label.ISSP_ANG_OPT_IN_FINANCIAL_MESSAGE_1;
                } else {
                    optInOutMessage = Label.ISSP_ANG_OPT_IN_FINANCIAL_MESSAGE_2 ;
                }
            } else {
                if(bIsAdmin) {
                    optInOutMessage = Label.ISSP_ANG_OPT_IN_FINANCIAL_MESSAGE_3;
                } else {
                    optInOutMessage = Label.ISSP_ANG_OPT_IN_FINANCIAL_MESSAGE_4 ;
                }
            }
        }

        if (flagShowOptOutButton) {
            optInOutErrorNoDate = Label.ANG_ISSP_OptOutEmptyDateErrorMessage;
            optInOutBtn = Label.ISSP_ANG_OPT_OUT_FINANCIAL_REVIEW_BTN;
            flagShowOptInOutButton = true;
            optInOutModalTitle = Label.ISSP_ANG_OPT_OUT_MODAL_TITLE;
            if(isIFAPContact) {
                optInOutMessage = Label.ISSP_ANG_OPT_OUT_MODAL_CONFIRMATION_TEXT;
            } else {
                optInOutMessage = Label.ISSP_ANG_OPT_OUT_NON_FINANCIAL_ASSESSEMENT_ERROR;
            }
        }

        flagShowOptInOutButtonDisabled = (flagShowOptInButtonDisabled || flagShowOptOutButtonDisabled);

        if(flagShowOptInButtonDisabled) {
            optInOutBtn = Label.ISSP_ANG_OPT_IN_FINANCIAL_REVIEW_BTN;
        }
        if(flagShowOptOutButtonDisabled) {
            optInOutBtn = Label.ISSP_ANG_OPT_OUT_FINANCIAL_REVIEW_BTN;
        }

        return l;
    }

    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
    public ApexPages.StandardSetController setConnNotDraft {
        get {
            if (setConnNotDraft == null) {
                setConnNotDraft = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, CaseNumber, CreatedDate, Account.Name, Country_concerned_by_the_query__c, Subject, Status, Portal_Case_Status__c, Priority, Reason1__c, CaseArea__c, Account.Billing_Address_formated__c
                FROM Case
                WHERE RecordType.Name IN ('SAAM', 'OSCAR Communication') AND (Status != 'Draft') AND Origin = 'Portal'
                AND ((Case.AccountId = :con.AccountId) OR (Case.Account_Concerned__r.Top_Parent__c = :con.AccountId))
                AND Case.id = '5007E000006UizO'
                AND Case.Reason1__c IN (:AMS_Utils.CASE_REASON_NEW_HO,
                                        :AMS_Utils.CASE_REASON_BR_IP,
                                        :AMS_Utils.CASE_REASON_BR_ABROAD,
                                        'CHL - Change of Location',
                                        'CHN - Change of Name', 'CHO / CHS – Change of Ownership / Legal Status',
                                        'IRIS Bank Detail Update',
                                        'Bank Detail Update',
                                        'Major Change',
                                        :AMS_Utils.CASE_REASON_HE_STANDARD,
                                        :AMS_Utils.CASE_REASON_HE_LITE,
                                        :AMS_Utils.CASE_REASON_ASSOCIATE_ENTITY_STANDARD)
                ORDER BY CaseNumber DESC]));
            }
            return setConnNotDraft;
        }
        set;
    }

    public Boolean getIsEmptySumbittedCases() {
        List<Case> AMSCases = getAMSSubmittedCases();
        if (AMSCases.isEmpty()) {
            return true;
        }
        return false;
    }

    // Initialize setConnNotDraft and return a list of records
    public List<Case> getAMSSubmittedCases() {
        return (List<Case>) setConnNotDraft.getRecords();
    }

    public PageReference CheckCountryReqments() {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.ISSP_AMS_No_Requirements));
        return null;
    }


    public PageReference setPageLegalStatusLabels() {
        roleLabelType = 'director';
        roleLabel = Label.ISSP_AMS_Director;
        if (legalStatus == 'association' || legalStatus == 'corporation' || legalStatus == 'limited company' || legalStatus == 'trust company') {
            ownerLabelType = 'shareholder';
            ownerLabel = Label.ISSP_AMS_Shareholder;
        } else if (legalStatus == 'co-operative' || legalStatus == 'joint venture' || legalStatus == 'limited partnership' || legalStatus == 'partnership') {
            ownerLabelType = 'partner';
            ownerLabel = Label.ISSP_AMS_Partner;
        } else {
            roleLabelType = 'manager';
            ownerLabelType = 'owner';
            ownerLabel = Label.ISSP_AMS_Owner;
            roleLabel = Label.ISSP_AMS_Manager;
        }

        return null;
    }

    public PageReference setPageLegalStatusAfterChangeLabels() {
        roleLabelTypeAfterChange = 'director';
        roleLabelAfterChange = Label.ISSP_AMS_Director;
        if (legalStatusAfterChange == 'association' || legalStatusAfterChange == 'corporation' || legalStatusAfterChange == 'limited company' || legalStatusAfterChange == 'trust company') {
            ownerLabelTypeAfterChange = 'shareholder';
            ownerLabelAfterChange = Label.ISSP_AMS_Shareholder;
        } else if (legalStatusAfterChange == 'co-operative' || legalStatusAfterChange == 'joint venture' || legalStatusAfterChange == 'limited partnership' || legalStatusAfterChange == 'partnership') {
            ownerLabelTypeAfterChange = 'partner';
            ownerLabelAfterChange = Label.ISSP_AMS_Partner;
        } else {
            roleLabelTypeAfterChange = 'manager';
            ownerLabelTypeAfterChange = 'owner';
            ownerLabelAfterChange = Label.ISSP_AMS_Owner;
            roleLabelAfterChange = Label.ISSP_AMS_Manager;
        }

        return null;
    }

    public Pagereference fetchIATANDetails(){ //NEWGEN - 663
            IATANAgentAccount = new Account();
            List <Account> agentaccountITAN = null;

            if (iatacode == null) return null;
                
            String qCargoCode = iatacode + '%';

            Set<String> categories = new Set<String>{AMS_UTILS.IATAN_PASSENGER_AGENT, AMS_UTILS.ARC_TRAVEL_AGENT_USA_ONLY,
                AMS_UTILS.IATAN_PASSENGER_SALES_AGENT_USA_ONLY, AMS_UTILS.TRAVEL_SERVICE_INTERMEDIATES_TSI_USA_ONLY};

            if(iatanAccount == AMS_UTILS.IATAN_PASSENGER_AGENT){
                agentaccountITAN = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Name
                                    FROM Account
                                    WHERE RecordType.DeveloperName = 'IATA_Agency' AND Sector__c = :agentsector AND IATACode__c LIKE :qCargoCode
                                        AND Category__c in :categories];
            }

            if(agentaccountITAN != null && !agentaccountITAN.isEmpty()) {
                if(iatanAccount == AMS_UTILS.IATAN_PASSENGER_AGENT)
                    IATANAgentAccount = agentaccountITAN[0];
            }
            return null;
    }

    public PageReference fetchAgentDetails() {
        String qCargoCode;
        CargoAgentAccount = new Account();
        IATANAgentAccount = new Account();
        TravelAgentPrevAccount = new Account();
        Account generalAccount = null;
        companyModalAddress = '';
        companyModalNameOfEmployer = '';

        if (iatacode == null) return null;

        //Limit how many calls can be made to this service, to prevent a user from attempting to retrieve full list of agents
        cntAgencyLookups += 1;
        if (cntAgencyLookups > MAX_AgencyAccount_LOOKUPS_ALLOWED) {
            TravelAgentPrevAccount = new Account();
            return null;
        }

        //Must be min of 8 chars for Cargo Search
        if (agentsector == AMS_Utils.SECTOR_CARGO && iatacode.length() < 8) return null;

        //Must be min of 7 chars for Cargo Search
        if ((agentsector == AMS_Utils.SECTOR_PASSENGER || agentsector == 'Both')  && iatacode.length() < 7) return null;

        qCargoCode = iatacode + '%';

        List <Account> agentaccounts = null;

        if (agentsector == AMS_Utils.SECTOR_CARGO && amsOfficeType == 'Branch' && newCase.Reason1__c != AMS_Utils.CASE_REASON_ASSOCIATE_ENTITY_STANDARD) {
            agentaccounts = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Name
                            FROM Account
                            WHERE RecordType.DeveloperName = 'IATA_Agency' AND Sector__c = :agentsector 
                                AND IATACode__c LIKE :qCargoCode AND Location_Type__c = :AMS_Utils.BR];
        } else if (agentsector == 'Both') {

            agentaccounts = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Name
                            FROM Account
                            WHERE RecordType.DeveloperName = 'IATA_Agency' 
                                AND (Sector__c = :AMS_Utils.SECTOR_PASSENGER OR Sector__c = :AMS_Utils.SECTOR_CARGO) 
                                AND IATACode__c LIKE :qCargoCode];

        } else if (accountType == AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT) {
            agentaccounts = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Name
                            FROM Account
                            WHERE RecordType.DeveloperName = 'IATA_Agency' AND Sector__c = :agentsector 
                                AND IATACode__c LIKE :qCargoCode AND Type = : accountType];

        } else {
            agentaccounts = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Name
                            FROM Account
                            WHERE RecordType.DeveloperName = 'IATA_Agency' AND Sector__c = :agentsector AND IATACode__c LIKE :qCargoCode];
        }

        if (agentaccounts!= null && !agentaccounts.isEmpty()) {
            String agentAddress;
            if (agentsector == 'Both') {
                generalAccount = agentaccounts[0];
                if (isAddCompanyModal != null && isAddCompanyModal == true) {
                    companyModalAddress = notNull(generalAccount.BillingStreet) + ' \r\n' +
                                          notNull(generalAccount.BillingCity) + '' + notNull(generalAccount.BillingState) +
                                          ' \r\n' + notNull(generalAccount.BillingCountry);
                    companyModalNameOfEmployer = notNull(generalAccount.Name);
                }
            } else if (agentsector == AMS_Utils.SECTOR_CARGO){
                    CargoAgentAccount = agentaccounts[0];
                if (accountType == 'IATA Cargo Agent')
                    newForm.Name_under_which_it_was_issued__c = CargoAgentAccount.Name;
                else if (accountType == 'CASS Associates')
                    newForm.CASS_Name_under_which_it_was_issued__c = CargoAgentAccount.Name;
            }else{
                TravelAgentPrevAccount = agentaccounts[0];

                agentAddress = notNull(TravelAgentPrevAccount.BillingStreet) + ' \r\n' +
                               notNull(TravelAgentPrevAccount.BillingCity) + '' + notNull(TravelAgentPrevAccount.BillingState) +
                               ' \r\n' + notNull(TravelAgentPrevAccount.BillingCountry);

                if (prevAgentHistory == '1') {
                    newContact.Prev_Job1_Address__c = agentAddress;
                    newContact.Prev_Job1_Employer__c = TravelAgentPrevAccount.Name;
                    newContact.Accredited_employer_1__c = TravelAgentPrevAccount.Id;
                } else {
                    newContact.Prev_Job2_Address__c = agentAddress;
                    newContact.Prev_Job2_Employer__c = TravelAgentPrevAccount.Name;
                    newContact.Accredited_employer_2__c = TravelAgentPrevAccount.Id;
                }
            }

            return null;
        }
        else {
            if (prevAgentHistory == '1') {
                newContact.Prev_Job1_Address__c = '';
                newContact.Prev_Job1_Employer__c = '';
            } else {
                newContact.Prev_Job2_Address__c = '';
                newContact.Prev_Job2_Employer__c = '';
            }

            if (isAddCompanyModal != null && isAddCompanyModal == true) {
                companyModalAddress = '';
                companyModalNameOfEmployer = '';
            }

            return null;
        }
    }

    private String notNull(String value) {
        if (value == null) {
            return '';
        }
        return value;
    }

    public void validateVATNumber() {
        IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
        try {
            if (isEUcountry && vatNumber != '') {
                IECVATUtil.VATResponse res = ws.ValidateVAT(newCase.IFAP_Country_ISO__c, vatNumber);
                if (!res.valid) {
                    newForm.ISSP_AMS_VAT_number_input__c.addError(Label.ISSP_PAX_Validating_VAT_Number_error);
                    newForm.INVALID_Tax_Number__c = true;
                } else {
                    newForm.INVALID_Tax_Number__c = false;
                }
            }
        } catch (System.CalloutException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_PAX_Validating_VAT_Number_error));
        }
    }

    //Does Open, non-Draft/Pending customer SAAM case already exist for HQ?
    public boolean openHQCaseExists {
        get {
            List<Case> dupeDrafts = [SELECT Id, IFAP_Country_ISO__c, Reason1__c, CaseArea__c 
                                    FROM Case 
                                    WHERE RecordTypeId = :RECORD_TYPE_ID AND IsClosed = false 
                                        AND Status NOT IN ('Draft', 'Pending customer') 
                                        AND AccountId = :vHQAccountId AND Reason1__c = :AMS_Utils.CASE_REASON_NEW_HO];

            if (dupeDrafts.size() > 0) {
                isNewCase = false;
                return true;
            } else {
                return false;
            }
        }
        set;
    }

    //Does Draft or Pending customer SAAM case already exists for HQ?
    // Ask Adrian why cases are being switched here
    public boolean draftHQCaseExists {
        get {
            List<Case> dupeDrafts = [SELECT Id, IFAP_Country_ISO__c, Reason1__c, CaseArea__c 
                                    FROM Case 
                                    WHERE RecordTypeId = :RECORD_TYPE_ID 
                                        AND Status IN ('Draft') AND AccountId = :vHQAccountId 
                                        AND (Reason1__c = :AMS_Utils.CASE_REASON_NEW_HO OR Reason1__c = :AMS_UTILS.CASE_REASON_HE_STANDARD OR Reason1__c = :AMS_UTILS.CASE_REASON_HE_LITE)];

            if (dupeDrafts.size() > 0) {
                isNewCase = false;
                newCase = dupeDrafts[0];
                return true;
            } else {
                return false;
            }
        }
        set;
    }

    public boolean isDupeSAAMCase {
        get {
            List<Case> dupeCases = [SELECT Id, IFAP_Country_ISO__c, Reason1__c, CaseArea__c 
                                    FROM Case 
                                    WHERE RecordTypeId = :RECORD_TYPE_ID AND Id = :vSAAMCaseId];

            if (dupeCases.size() > 0) {
                isNewCase = false;
                newCase = dupeCases[0];
                return true;
            } else {
                return false;
            }
        }
        set;
    }

    public string pageLanguage {
        get{
            string lang;
            if (newCase != null) {
                lang = newCase.Case_Language__c;
                if (lang != '') return lang;
                else return UserInfo.getLanguage();

            } else return UserInfo.getLanguage();
        }
        set;
    }

    public Void checkEligibilityForAChange() {
        if ((sector == AMS_Utils.SECTOR_PASSENGER && (con.Account.Category__c == 'Non-IATA Travel Agent' || con.Account.Category__c == AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT)) ||
                (sector == AMS_Utils.SECTOR_CARGO && (con.Account.Category__c == 'Non-IATA Cargo Agent' || con.Account.Category__c == 'IATA Cargo Agent' || con.Account.Category__c == AMS_Utils.CATEGORY_CASSASSOCIATE || con.Account.Category__c == 'CASS Associates' || con.Account.Category__c == AMS_Utils.CATEGORY_COURIER || con.Account.Category__c == AMS_Utils.CATEGORY_IMPORT_AGENT)))
            isEligableForChange = true;
    }

    public List<SelectOption> getPrevWorkedForItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('none', Label.PKB2_None));
        options.add(new SelectOption('1', '1'));
        options.add(new SelectOption('2', Label.ISSP_SELECT_THREE_or_MORE));

        return options;
    }

    public void getPilotCountries() {
        List<IATA_ISO_Country__c> isoList;

        isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'Name');

        String tmpList;
        Integer idx = 0;
        for (IATA_ISO_Country__c iso : isoList) {
            if (idx == 0) {
                tmpList = iso.ISO_Code__c + ':' + iso.AMS_Pilot_Country__c;
            } else {
                tmpList = tmpList + ',' + iso.ISO_Code__c + ':' + iso.AMS_Pilot_Country__c;
            }
            ++idx;
        }

        pilotlist = tmpList;
    }

    public void getCountriesMap() {
        List<IATA_ISO_Country__c> isoList;

        isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'Name');
       
        Map<String, String> mapCountriesList = new Map<String, String>();
        List<String> notAllowedCountries = new List<String>();
        Integer idx = 0;
        for (IATA_ISO_Country__c iso : isoList) {
            if (idx == 0) {
                mapCountriesList.put('Cargo_Agent-New BR / IP', iso.ISO_Code__c + ':' + iso.Cargo_Branch_Country__c);
                mapCountriesList.put('Cargo_Agent-New HO', iso.ISO_Code__c + ':' + iso.Cargo_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New BR / IP', iso.ISO_Code__c + ':' + iso.Travel_Branch_Country__c);
                mapCountriesList.put('Travel_Agent-New BR Abroad', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HO', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HE standard', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HE lite', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New AE', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c); //NEWGEN - 552
            } else {
                mapCountriesList.put('Cargo_Agent-New BR / IP', mapCountriesList.get('Cargo_Agent-New BR / IP') + ',' + iso.ISO_Code__c + ':' + iso.Cargo_Branch_Country__c);
                mapCountriesList.put('Cargo_Agent-New HO', mapCountriesList.get('Cargo_Agent-New HO') + ',' + iso.ISO_Code__c + ':' + iso.Cargo_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New BR / IP', mapCountriesList.get('Travel_Agent-New BR / IP') + ',' + iso.ISO_Code__c + ':' + iso.Travel_Branch_Country__c);
                mapCountriesList.put('Travel_Agent-New BR Abroad', mapCountriesList.get('Travel_Agent-New BR Abroad') + ',' + iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HO', mapCountriesList.get('Travel_Agent-New HO') + ',' + iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HE standard', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HE lite', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New AE', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);//NEWGEN - 552
            }
            ++idx;
            
            if (iso.Branches_abroad_not_allowed__c) notAllowedCountries.add(iso.ISO_Code__c);  
        }

        jsonCountriesMap = JSON.serialize(mapCountriesList);
        jsonCountriesNotAllowedList = JSON.serialize(notAllowedCountries);
    }

    private List<String> getAmscontactsEmails(List <AMS_Accreditation_Contact__c> amscontacts) {
        List<String> amscontactsEmails = new List<String>();
        if (amscontacts != null) {
            for (AMS_Accreditation_Contact__c amscon : amscontacts) {
                if (amscon.email__c != null && amscon.email__c.trim() != '') {
                    amscontactsEmails.add(amscon.Email__c);
                }
            }
        }
        return amscontactsEmails;
    }

    private void setPortalAdminContact() {
        Id personRecordTypeId;
        if (RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person') != null) {
            personRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
        }

        List<AMS_Accreditation_Contact__c> amscontacts = [SELECT Id, Name, Portal_administrator__c
                                           FROM AMS_Accreditation_Contact__c WHERE
                                           recordTypeId = :personRecordTypeId AND AMS_Pax_Accreditation_Form__c = :newForm.Id AND Id = :newForm.ISSP_AMS_Portal_admin__c];
        if (amsContacts.size() > 0) {
            amsContacts[0].Portal_administrator__c = true;
            update amsContacts[0];
        }
    }

    private void setInvoicingContact() {
        Id personRecordTypeId;
        if (RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c','Person') != null) {
            personRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c','Person');
        }

        List<AMS_Accreditation_Contact__c> amscontacts = [SELECT Id, Name, Invoicing_Contact__c
                                           FROM AMS_Accreditation_Contact__c WHERE
                                           recordTypeId = :personRecordTypeId AND AMS_Pax_Accreditation_Form__c = :newForm.Id AND Id = :newForm.ISSP_AMS_Invoicing_Contact__c];
        if (amsContacts.size() > 0) {
             amsContacts[0].Invoicing_Contact__c = true;
            update amsContacts[0];
        }
    }

    private void retCargoCountryReqments(boolean isFromValidation) {
        Set<String> allowIdentifierSet = new Set<String>();

        String selectedLang;

        if (applyLanguage == 'fr') selectedLang = 'French';
        else if (applyLanguage == 'es') selectedLang = 'Spanish';
        else selectedLang = 'English';

        Id CargoReqRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Requirement__c', 'Cargo_Agent');

        for (AMS_Facility__c facility : facilityList) {
            if (facility.recordType.Name == 'Office') {
                if (facility.Is_the_office_warehouse_leased__c == 'Yes') {
                    allowIdentifierSet.add(OFFICE_LEASE);
                }
            } else if (facility.recordType.Name == 'Warehouse') {
                if (facility.Is_the_office_warehouse_leased__c == 'Yes') {
                    allowIdentifierSet.add(WAREHOUSE_LEASE);
                }
                if (facility.Is_the_warehouse_sub_contracted__c == 'Yes') {
                    allowIdentifierSet.add(WAREHOUSE_SUBCONTRACTED);
                }
            }
        }

        Set<String> identifierSet = new Set<String> {OFFICE_LEASE, WAREHOUSE_LEASE, WAREHOUSE_SUBCONTRACTED};
        Set<String> excludeIdentifierSet = new Set<String>();
        for (String ident : identifierSet) {
            if (!(allowIdentifierSet.contains(ident)))
                excludeIdentifierSet.add(ident);
        }

        AggregateResult[] distinctReqmentLangs;
        String finalLang = '';

        distinctReqmentLangs = [SELECT Language__c
                                FROM AMS_Accreditation_Requirement__c
                                WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Language__c !=null
                                    AND RecordTypeId = :CargoReqRecTypeId
                                GROUP BY Language__c
                                ORDER BY Language__c ASC];

        if (distinctReqmentLangs.size() > 0) {
            //... and if English not found return requirements in 3rd lang
            finalLang = (String)distinctReqmentLangs[0].get('Language__c');
        }

        if (stepNumber != '5') {
            excludeIdentifierSet.add(CGO_SIGNED_CONTRACT);
            //Exclude the Signed Contract in Step B and files to upload in Step D
            this.List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                            AND Location_type__c INCLUDES (:amsOfficeType) AND Language__c = :selectedLang AND File_Identifier2__c NOT IN: excludeIdentifierSet And Type_Of_Agent__c INCLUDES (:newForm.Agent_Type__c)
                                            AND RecordTypeId = :CargoReqRecTypeId
                                        ORDER BY Sort_Order__c ASC];

            if (List_CountryReqments.size() == 0) {
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                            AND Location_type__c INCLUDES (:amsOfficeType) AND Language__c = 'English' AND File_Identifier2__c NOT IN: excludeIdentifierSet And Type_Of_Agent__c INCLUDES (:newForm.Agent_Type__c)
                                            AND RecordTypeId = :CargoReqRecTypeId
                                        ORDER BY Sort_Order__c ASC];
            }

            if (!finalLang.equalsIgnoreCase('') && List_CountryReqments.size() == 0) {
                //... and if English not found return requirements in 3rd lang
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                            AND Location_type__c INCLUDES (:amsOfficeType) AND Language__c = :finalLang AND File_Identifier2__c NOT IN: excludeIdentifierSet And Type_Of_Agent__c INCLUDES (:newForm.Agent_Type__c)
                                            AND RecordTypeId = :CargoReqRecTypeId
                                        ORDER BY Sort_Order__c ASC];
            }

            // when step 5 loads
        } else if (stepNumber == '5' && !isFromValidation) {
            //and display Signed Contract to upload in Step E
            this.List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE (AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                            AND Location_type__c INCLUDES (:amsOfficeType) AND Language__c = :selectedLang AND File_Identifier2__c = :CGO_SIGNED_CONTRACT) And Type_Of_Agent__c INCLUDES (:newForm.Agent_Type__c)
                                            AND RecordTypeId = :CargoReqRecTypeId
                                        ORDER BY Sort_Order__c ASC];

            if (List_CountryReqments.size() == 0) {
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE (AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                            AND Location_type__c INCLUDES (:amsOfficeType) AND Language__c = 'English' AND File_Identifier2__c = :CGO_SIGNED_CONTRACT) And Type_Of_Agent__c INCLUDES (:newForm.Agent_Type__c)
                                            AND RecordTypeId = :CargoReqRecTypeId
                                        ORDER BY Sort_Order__c ASC];
            }

            if (!finalLang.equalsIgnoreCase('') && List_CountryReqments.size() == 0) {
                //... and if English not found return requirements in 3rd lang
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE (AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                            AND Location_type__c INCLUDES (:amsOfficeType) AND Language__c = :finalLang AND File_Identifier2__c = :CGO_SIGNED_CONTRACT) And Type_Of_Agent__c INCLUDES (:newForm.Agent_Type__c)
                                            AND RecordTypeId = :CargoReqRecTypeId
                                        ORDER BY Sort_Order__c ASC];
            }

            // From validation function
        } else if (stepNumber == '5' && isFromValidation) {
            //and display Signed Contract to upload in Step E
            this.List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                            AND Location_type__c INCLUDES (:amsOfficeType) AND Language__c = :selectedLang AND File_Identifier2__c NOT IN: excludeIdentifierSet And Type_Of_Agent__c INCLUDES (:newForm.Agent_Type__c)
                                            AND RecordTypeId = :CargoReqRecTypeId
                                        ORDER BY Sort_Order__c ASC];
            if (List_CountryReqments.size() == 0) {
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                            AND Location_type__c INCLUDES (:amsOfficeType) AND Language__c = 'English' AND File_Identifier2__c NOT IN: excludeIdentifierSet And Type_Of_Agent__c INCLUDES (:newForm.Agent_Type__c)
                                            AND RecordTypeId = :CargoReqRecTypeId
                                        ORDER BY Sort_Order__c ASC];
            }

            if (!finalLang.equalsIgnoreCase('') && List_CountryReqments.size() == 0) {
                //... and if English not found return requirements in 3rd lang
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                            AND Location_type__c INCLUDES (:amsOfficeType) AND Language__c = :finalLang AND File_Identifier2__c NOT IN: excludeIdentifierSet And Type_Of_Agent__c INCLUDES (:newForm.Agent_Type__c)
                                            AND RecordTypeId = :CargoReqRecTypeId
                                        ORDER BY Sort_Order__c ASC];
            }
        }

        // Clean any css style in the Requirement_text__c and also Bold tags
        for(AMS_Accreditation_Requirement__c req : List_CountryReqments) {
            if (req.Requirement_text__c != null) {
                req.Requirement_text__c = req.Requirement_text__c.replaceAll('style[/a-zA-Z0-9="-: ;]*','');
                req.Requirement_text__c = req.Requirement_text__c.replaceAll('<b>','');
                req.Requirement_text__c = req.Requirement_text__c.replaceAll('</b>','');
            }
        }
    }

    private void retNoCCargoCountryReqments(boolean isFromValidation) {
        String selectedLang;
        string agentType;

        AggregateResult[] distinctReqmentLangs;

        if (applyLanguage == 'fr') selectedLang = 'French';
        else if (applyLanguage == 'es') selectedLang = 'Spanish';
        else selectedLang = 'English';

        if(isocountry.EACP_Country__c && hqAccount.Category__c=='IATA Cargo Agent') {
            agentType = 'EACP Intermediary';
        } else {
            agentType = hqAccount.Category__c;
        }

        Id ChangeReqRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Requirement__c', 'Change');

        if (stepNumber != '5') {
            //Get distinct set of Languages for this country / operation requirements
            distinctReqmentLangs = [SELECT Language__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                            AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                            AND ((File_Identifier2__c NOT IN (:NOC_SIGNED_CONTRACT, :BNK_ACCNT_DTLS))
                                                OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                    GROUP BY Language__c
                                    ORDER BY Language__c ASC];

            //Exclude the Signed Contract in Step B and files to upload in Step D
            this.List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                            AND RecordTypeId = :ChangeReqRecTypeId
                                            AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                            AND ((File_Identifier2__c NOT IN (:NOC_SIGNED_CONTRACT, :BNK_ACCNT_DTLS))
                                                OR (File_Identifier2__c = : BNK_ACCNT_DTLS))
                                            AND Type_Of_Agent__c INCLUDES (:agentType)
                                            AND Language__c = :selectedLang
                                        ORDER BY Sort_Order__c ASC];

            //Then look for country requirements in English if not found for selected language
            if (List_CountryReqments.size() == 0) {
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                            AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                            AND ((File_Identifier2__c NOT IN (:NOC_SIGNED_CONTRACT, :BNK_ACCNT_DTLS))
                                                OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND Type_Of_Agent__c INCLUDES (:agentType)
                                            AND Language__c = 'English'
                                        ORDER BY Sort_Order__c ASC];
            }

            if (distinctReqmentLangs.size() > 0) {
                //... and if English not found return requirements in 3rd lang
                String finalLang = (String)distinctReqmentLangs[0].get('Language__c');

                if (List_CountryReqments.size() == 0) {
                    List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                            FROM AMS_Accreditation_Requirement__c
                                            WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                                AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                    OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                                AND ((File_Identifier2__c NOT IN (:NOC_SIGNED_CONTRACT, :BNK_ACCNT_DTLS))
                                                    OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND Type_Of_Agent__c INCLUDES (:agentType)
                                                AND Language__c = :finalLang
                                            ORDER BY Sort_Order__c ASC];
                }

            }


            // when step 5 loads
        } else if (stepNumber == '5' && !isFromValidation) {
            //and display Signed Contract to upload in Step E
            distinctReqmentLangs = [SELECT Language__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                        AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                            OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                        AND File_Identifier2__c = :NOC_SIGNED_CONTRACT
                                    GROUP BY Language__c
                                    ORDER BY Language__c ASC];
            //First look for country requirements in the User's selected language

            this.List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE (AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                            AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                            AND File_Identifier2__c = :NOC_SIGNED_CONTRACT) AND Type_Of_Agent__c INCLUDES (:agentType)
                                            AND Language__c = :selectedLang
                                        ORDER BY Sort_Order__c ASC];

            //Then look for country requirements in English if not found for selected language
            if (List_CountryReqments.size() == 0) {
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE (AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                            AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                            AND File_Identifier2__c = :NOC_SIGNED_CONTRACT) AND Type_Of_Agent__c INCLUDES (:agentType)
                                            AND Language__c = 'English'
                                        ORDER BY Sort_Order__c ASC];
            }

            if (distinctReqmentLangs.size() > 0) {
                //... and if English not found return requirements in 3rd lang
                String finalLang = (String)distinctReqmentLangs[0].get('Language__c');
                if (List_CountryReqments.size() == 0) {
                    List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                            FROM AMS_Accreditation_Requirement__c
                                            WHERE (AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                                    AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                            OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                                    AND File_Identifier2__c = :NOC_SIGNED_CONTRACT) AND Type_Of_Agent__c INCLUDES (:agentType)
                                                    AND Language__c = :finalLang
                                            ORDER BY Sort_Order__c ASC];
                }
            }
            // From validation function
        } else if (stepNumber == '5' && isFromValidation) {
            //and display Signed Contract to upload in Step E
            distinctReqmentLangs = [SELECT Language__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                        AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                            OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                        AND ((File_Identifier2__c != :BNK_ACCNT_DTLS)
                                            OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                    GROUP BY Language__c
                                    ORDER BY Language__c ASC];
            //First look for country requirements in the User's selected language
            this.List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                            AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                            AND ((File_Identifier2__c NOT IN (:BNK_ACCNT_DTLS))
                                                OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND Type_Of_Agent__c INCLUDES (:agentType)
                                            AND Language__c = :selectedLang
                                        ORDER BY Sort_Order__c ASC];

            //Then look for country requirements in English if not found for selected language
            if (List_CountryReqments.size() == 0) {
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                            AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                            AND ((File_Identifier2__c NOT IN (:BNK_ACCNT_DTLS))
                                                OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND Type_Of_Agent__c INCLUDES (:agentType)
                                            AND Language__c = 'English'
                                        ORDER BY Sort_Order__c ASC];
            }

            if (distinctReqmentLangs.size() > 0) {
                //... and if English not found return requirements in 3rd lang
                String finalLang = (String)distinctReqmentLangs[0].get('Language__c');
                if (List_CountryReqments.size() == 0) {
                    List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                            FROM AMS_Accreditation_Requirement__c
                                            WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                                AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                    OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                                AND ((File_Identifier2__c NOT IN (:BNK_ACCNT_DTLS))
                                                    OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND Type_Of_Agent__c INCLUDES (:agentType)
                                                AND Language__c = :finalLang
                                            ORDER BY Sort_Order__c ASC];
                }

            }
        }
    }

    private void retNoCTravelCountryReqments(boolean isFromValidation) {
        String selectedLang;
        Id ChangeReqRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Requirement__c', 'Change');

        AggregateResult[] distinctReqmentLangs;

        if (applyLanguage == 'fr') selectedLang = 'French';
        else if (applyLanguage == 'es') selectedLang = 'Spanish';
        else selectedLang = 'English';

        //Get distinct set of Languages for this country / operation requirements
        if (stepNumber != '5') {
            distinctReqmentLangs = [SELECT Language__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                        AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                            OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                        AND ((File_Identifier2__c NOT IN (:NOC_SIGNED_CONTRACT, :BNK_ACCNT_DTLS))
                                            OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                    GROUP BY Language__c
                                    ORDER BY Language__c ASC];

            //First look for country requirements in the User's selected language
            List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                        AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                            OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                        AND ((File_Identifier2__c NOT IN (:NOC_SIGNED_CONTRACT, :BNK_ACCNT_DTLS))
                                            OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND Language__c = :selectedLang
                                    ORDER BY Sort_Order__c ASC];

            //Then look for country requirements in English if not found for selected language
            if (List_CountryReqments.size() == 0) {
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                            AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                            AND Language__c = 'English' AND ((File_Identifier2__c NOT IN (:NOC_SIGNED_CONTRACT, :BNK_ACCNT_DTLS))
                                                OR (File_Identifier2__c = : BNK_ACCNT_DTLS))
                                        ORDER BY Sort_Order__c ASC];
            }

            if (distinctReqmentLangs.size() > 0) {
                //... and if English not found return requirements in 3rd lang
                String finalLang = (String)distinctReqmentLangs[0].get('Language__c');

                if (List_CountryReqments.size() == 0) {
                    List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                            FROM AMS_Accreditation_Requirement__c
                                            WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                                AND RecordTypeId = :ChangeReqRecTypeId AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                    OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                                AND ((File_Identifier2__c NOT IN (:NOC_SIGNED_CONTRACT, :BNK_ACCNT_DTLS))
                                                    OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND Language__c = :finalLang
                                            ORDER BY Sort_Order__c ASC];
                }

            }
        } else if (stepNumber == '5' && !isFromValidation) {
            distinctReqmentLangs = [SELECT Language__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                        AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                            OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                        AND File_Identifier2__c = :NOC_SIGNED_CONTRACT
                                    GROUP BY Language__c
                                    ORDER BY Language__c ASC];
            //First look for country requirements in the User's selected language
            List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                        AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                            OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                        AND File_Identifier2__c = :NOC_SIGNED_CONTRACT
                                        AND Language__c = :selectedLang
                                    ORDER BY Sort_Order__c ASC];
            //Then look for country requirements in English if not found for selected language
            if (List_CountryReqments.size() == 0) {
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                            AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                            AND Language__c = 'English' AND File_Identifier2__c = :NOC_SIGNED_CONTRACT
                                        ORDER BY Sort_Order__c ASC];
            }

            if (distinctReqmentLangs.size() > 0) {
                //... and if English not found return requirements in 3rd lang
                String finalLang = (String)distinctReqmentLangs[0].get('Language__c');
                if (List_CountryReqments.size() == 0) {
                    List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                            FROM AMS_Accreditation_Requirement__c
                                            WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                                AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                    OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                                AND File_Identifier2__c = :NOC_SIGNED_CONTRACT AND Language__c = :finalLang
                                            ORDER BY Sort_Order__c ASC];
                }

            }
        } else if (stepNumber == '5' && isFromValidation) {
            distinctReqmentLangs = [SELECT Language__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                        AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                            OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                        AND ((File_Identifier2__c != :BNK_ACCNT_DTLS)
                                            OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                    GROUP BY Language__c
                                    ORDER BY Language__c ASC];
            //First look for country requirements in the User's selected language
            List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                    FROM AMS_Accreditation_Requirement__c
                                    WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                        AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                            OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                        AND ((File_Identifier2__c != :BNK_ACCNT_DTLS)
                                            OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND Language__c = :selectedLang
                                    ORDER BY Sort_Order__c ASC];
            //Then look for country requirements in English if not found for selected language
            if (List_CountryReqments.size() == 0) {
                List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                        FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                            AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                            AND Language__c = 'English' AND ((File_Identifier2__c != :BNK_ACCNT_DTLS)
                                                OR (File_Identifier2__c = : BNK_ACCNT_DTLS))
                                        ORDER BY Sort_Order__c ASC];
            }

            if (distinctReqmentLangs.size() > 0) {
                //... and if English not found return requirements in 3rd lang
                String finalLang = (String)distinctReqmentLangs[0].get('Language__c');
                if (List_CountryReqments.size() == 0) {
                    List_CountryReqments = [
                                               SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                               FROM AMS_Accreditation_Requirement__c
                                               WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector AND Type_Of_Change__c != null
                                                       AND (Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(0)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(1))
                                                            OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(2)) OR Type_Of_Change__c INCLUDES (:noticeOfChangeList.get(3)))
                                                       AND ((File_Identifier2__c != :BNK_ACCNT_DTLS)
                                                            OR (File_Identifier2__c = : BNK_ACCNT_DTLS)) AND Language__c = :finalLang
                                                                    ORDER BY Sort_Order__c ASC];
                }
            }
        }
    }

    private boolean validateAttachedFiles() {
        Boolean errorFound = false;

        redirectToStepE = false;

        //Need to refresh CGO requirements on validation to include Signed Application from STEP E in list
        if (sectorValue.StartsWith('Cargo_Agent') && isNoticeOfChange == true) {
            retNoCCargoCountryReqments(true);
        } else if (sectorValue.startsWith('Cargo_Agent') && isNoticeOfChange == false) {
            retCargoCountryReqments(true);
        } else if (sectorValue.StartsWith('Travel_Agent') && isNoticeOfChange == true) {
            retNoCTravelCountryReqments(true);
        }

        Map<String, String> folderMap = getMapAmazonFileIdentifiers();

        for (AMS_Accreditation_Requirement__c thisReq : List_CountryReqments) {
            if (thisReq.File_to_Upload__c == 'Mandatory') {
                if (!folderMap.containsKey(thisReq.File_Identifier2__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Please_Upload + ' ' + thisReq.Name));

                    if (thisReq.File_Identifier2__c == CGO_SIGNED_CONTRACT || thisReq.File_Identifier2__c == NOC_SIGNED_CONTRACT)
                        redirectToStepE = true;

                    errorFound = true;
                }
            }
        }

        if (errorFound) return false;

        return true;
    }

    private boolean validateFacilities() {
        Boolean errorFound = false;

        if (facilityRecordTypeName == 'Office' && facilityInContext.Are_Consignments_made_ready__c == 'Yes' && isocountry.EACP_Country__c && facilityInContext.Any_functions_involved_in_preperations__c == null) {
            facilityInContext.Any_functions_involved_in_preperations__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (facilityInContext.Is_the_office_warehouse_leased__c == 'Yes' && !isocountry.EACP_Country__c && facilityInContext.Name_of_lessor__c == null) {
            facilityInContext.Name_of_lessor__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (facilityInContext.Is_the_office_warehouse_leased__c == 'Yes' && !isocountry.EACP_Country__c && facilityInContext.Duration_of_lease__c == null) {
            facilityInContext.Duration_of_lease__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (facilityInContext.Is_the_office_warehouse_leased__c == 'Yes' && !isocountry.EACP_Country__c && facilityInContext.Date_lease_expires__c == null) {
            facilityInContext.Date_lease_expires__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (facilityRecordTypeName == 'Office' && facilityInContext.Is_the_office_warehouse_leased__c == 'Yes' && !isocountry.EACP_Country__c && facilityInContext.Other_pertinent_details__c == null) {
            facilityInContext.Other_pertinent_details__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (facilityRecordTypeName == 'Warehouse' && facilityInContext.Is_the_warehouse_sub_contracted__c == 'Yes' && !isocountry.EACP_Country__c && facilityInContext.Name_of_sub_contractor__c == null) {
            facilityInContext.Name_of_sub_contractor__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (facilityRecordTypeName == 'Warehouse' && facilityInContext.Is_the_warehouse_sub_contracted__c == 'Yes' && !isocountry.EACP_Country__c && facilityInContext.Date_agreement_expires__c == null) {
            facilityInContext.Date_agreement_expires__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (facilityRecordTypeName == 'Warehouse' && facilityInContext.Is_the_warehouse_sub_contracted__c == 'Yes' && !isocountry.EACP_Country__c && facilityInContext.Duration_of_contract__c == null) {
            facilityInContext.Duration_of_contract__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (errorFound) return false;

        return true;
    }

    private boolean validateNewAccModelHO(boolean isnewgenError){
        Boolean ngErrorFound = false;

        //checking if IATAN question is answered
        if(newForm.IATA_Registered_IATAN_Agent__c == null && (newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH || newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_CASH)){
            newform.IATA_Registered_IATAN_Agent__c.addError(Label.ISSP_AMS_Step5_IATAN_Travel_Agent);
            ngErrorFound = true;
        }

        //checking if IATAN code field is fill
        if (newForm.IATA_Registered_IATAN_Agent__c == 'Yes' && newForm.IATAN_Agent_Account__c == null) {
            newForm.IATAN_Code__c.addError(Label.ISSP_AMS_Invalid_IATAN_Code);
            ngErrorFound = true;
        }

        //checking if the Legal Name is fill
        if(hqAccount.Name == null){
            hqAccount.Name.addError(Label.ISSP_YouMustEnter);
            ngErrorFound = true;
        }

        //checking if the Phone number is fill
        if(hqAccount.Phone == null && hqAccount.Status__c != 'Terminated'){
            hqAccount.PhoneNational__c.addError(Label.ISSP_YouMustEnter);
            ngErrorFound = true;
        }

        //checking if the Billing Street is fill
        if (hqAccount.BillingStreet == null && hqAccount.Status__c != 'Terminated'){
            hqAccount.BillingStreet.addError(Label.ISSP_YouMustEnter);
            accountUpdated = false;
        }

        //checking if the Billing City is fill
        if (hqAccount.BillingCity == null && hqAccount.Status__c != 'Terminated'){
            hqAccount.BillingCity.addError(Label.ISSP_YouMustEnter);
            accountUpdated = false;
        }

        if(newForm.Branch_Office_Fax_National__c == null && (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE)){
            newForm.Branch_Office_Fax_National__c.addError(Label.ISSP_YouMustEnter);
            ngErrorFound = true;
        }

        if(newForm.Enable_Credit_Card_FOP__c == null){
            newForm.Enable_Credit_Card_FOP__c.addError(Label.ISSP_YouMustEnter);
            ngErrorFound = true;
        }

        return ngErrorFound;
    }

    private boolean validateNewAccModelBranch(boolean isnewgenError){
        Boolean ngErrorFoundBR = false;

        if(newForm.Account_Name__c == null && newForm.AE_separate_Legal_Entity__c == 'Yes'){
            newForm.Account_Name__c.addError(Label.ISSP_YouMustEnter);
            ngErrorFoundBR = true;
        }

        if(newForm.ISSP_AMS_Legal_Status__c == null){
            newForm.ISSP_AMS_Legal_Status__c.addError(Label.ISSP_YouMustEnter);
            ngErrorFoundBR = true;
        }

        if (newForm.ISSP_AMS_Legal_Status__c == 'Corporation' && newForm.AE_separate_Legal_Entity__c == 'Yes') {
            if (newForm.ISSP_AMS_when_incorporated__c == null) {
                newForm.ISSP_AMS_when_incorporated__c.addError(Label.ISSP_YouMustEnter);
                ngErrorFoundBR = true;
            }

            if (newForm.ISSP_AMS_where_incorporated__c == null) {
                newForm.ISSP_AMS_where_incorporated__c.addError(Label.ISSP_YouMustEnter);
                ngErrorFoundBR = true;
            }
        }

        if (newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c == null) {
            newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c.addError(Label.ISSP_YouMustEnter);
            ngErrorFoundBR = true;
        }
        if (newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c == 'Yes' && newForm.Cargo_Agent_Account__c == null) {
            newForm.IATA_Cargo_Code__c.addError(Label.ISSP_AMS_Validation_Cargo_Code);
            ngErrorFoundBR = true;
        }

        //checking if IATAN question is answered
        if(newForm.IATA_Registered_IATAN_Agent__c == null){
            newform.IATA_Registered_IATAN_Agent__c.addError(Label.ISSP_AMS_Step5_IATAN_Travel_Agent);
            ngErrorFoundBR = true;
        }

        if(newForm.Branch_Office_Email__c == null){
            newform.Branch_Office_Email__c.addError(Label.ISSP_YouMustEnter);
            ngErrorFoundBR = true;
        }

        //checking if IATAN code field is fill
        if (newForm.IATA_Registered_IATAN_Agent__c == 'Yes' && newForm.IATAN_Agent_Account__c == null) {
            newForm.IATAN_Code__c.addError(Label.ISSP_AMS_Invalid_IATAN_Code);
            ngErrorFoundBR = true;
        }

        if(newform.AE_separate_Legal_Entity__c == 'Yes' && !(newForm.ISSP_AMS_Legal_Status__c == 'Corporation' && newForm.ISSP_AMS_Entity_with_listed_shares__c == 'Yes')) {
            if (newForm.ISSP_AMS_Total_Ownership__c == null || newForm.ISSP_AMS_Total_Ownership__c < 99.99 || newForm.ISSP_AMS_Total_Ownership__c > 100 ) {
                if (newForm.ISSP_AMS_Legal_Status__c == 'Sole Proprietorship' || newForm.ISSP_AMS_Legal_Status__c == null)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Percent_Ownership_AE));
                else 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Percent_Ownership2_AE));

                ngErrorFoundBR = true;
            }
        }

        if(newForm.Enable_Credit_Card_FOP__c == null){
            newForm.Enable_Credit_Card_FOP__c.addError(Label.ISSP_YouMustEnter);
            ngErrorFoundBR = true;
        }

        return ngErrorFoundBR;
    }

    private boolean validateForm(boolean includeErrorMsgs) {
        Boolean errorFound = false;

        Integer cntAuthorisedSig = [SELECT COUNT() FROM AMS_Accreditation_Contact__c
                            WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND Authorised_signatory__c = true];

        refreshCntIFAPContacts();

        Integer cntCASSContact = [SELECT COUNT() FROM AMS_Accreditation_Contact__c
                          WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND CASS_contact__c = true];

        if (isNoticeOfChange && !isBankAccountChange) {
            if (newform.Is_change_legal_name__c && newForm.Notify_Change_Legal_Details__c) {
                if(newForm.Account_Name__c == null) {
                    newForm.Account_Name__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.ISSP_AMS_VAT_Number_Input__c == null && isocountry.Hide_Tax_Number_VAT__c == false) {
                    newForm.ISSP_AMS_VAT_Number_Input__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            }

            //NEWGEN-668
            if (getIsAccreditationModelNotNullOrLegacy() && newForm.ISSP_AMS_GDS_with_signed_contract__c == null) {
                newForm.ISSP_AMS_GDS_with_signed_contract__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            //END NEWGEN-668

            if (newForm.Notify_Change_Accreditation_Type__c == true) {
                if (String.isEmpty(newForm.ANG_Accreditation_Model_to_Change__c)) {
                    newForm.ANG_Accreditation_Model_to_Change__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                } else {
                    if (newForm.ANG_Accreditation_Model_to_Change__c == AMS_Utils.ACCREDITATIONMODEL_CASH && cntIFAPContacts == 0) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_NoC_No_Contact_Error));
                        errorFound = true;
                    }
                }
            }

            if(isocountry.Local_language_Agency_details_required__c && newform.Is_change_legal_name__c && newForm.Notify_Change_Legal_Details__c && newForm.Local_Legally_Registered_Name__c == null) {
                newForm.Local_Legally_Registered_Name__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newform.Is_change_location__c && newForm.Notify_Change_Location__c) {
                if(newForm.Branch_Office_Street_name_number__c == null) {
                     newForm.Branch_Office_Street_name_number__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Branch_Office_City__c == null) {
                    newForm.Branch_Office_City__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Branch_Office_Phone_National__c == null) {
                    newForm.Branch_Office_Phone_National__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            }

            if (newform.Is_change_location__c && newForm.Notify_Change_Location__c && isocountry.Local_language_Agency_details_required__c) {
                if (newForm.Local_Physical_Address_Street__c == null) {
                    newForm.Local_Physical_Address_Street__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Local_Physical_Address_City__c == null) {
                    newForm.Local_Physical_Address_City__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Local_Physical_Address_Province__c == null) {
                    newForm.Local_Physical_Address_Province__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Local_Postal_Address_Street__c == null) {
                    newForm.Local_Postal_Address_Street__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Local_Postal_Address_City__c == null) {
                    newForm.Local_Postal_Address_City__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Local_Postal_Address_Province__c == null) {
                    newForm.Local_Postal_Address_Province__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            } //EO check for Change of Location & Local Agency Details fields

            if (newForm.Is_this_Head_Office_becoming_a_Branch__c == null && newForm.Scope_of_Change__c != 'Selected Branches Only') {
                newForm.Is_this_Head_Office_becoming_a_Branch__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Is_this_Head_Office_becoming_a_Branch__c == 'Yes' && newForm.New_Head_Office_IATA_Code__c == null) {
                newForm.New_Head_Office_IATA_Code__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Is_this_Branch_becoming_a_Head_Office__c == null) {
                newForm.Is_this_Branch_becoming_a_Head_Office__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Will_such_change_affect_locations__c == null) {
                newForm.Will_such_change_affect_locations__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newform.Will_such_change_affect_locations__c == 'No' && newForm.Provide_explanation_for_change_locations__c == null) {
                newForm.Provide_explanation_for_change_locations__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Notify_Change_Ownership__c && newForm.ISSP_AMS_Legal_Status__c == null) {
                newForm.ISSP_AMS_Legal_Status__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Effective_Date_Of_Change__c == null) {
                newForm.Effective_Date_Of_Change__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Will_such_change_affect_the_managers__c == null) {
                newForm.Will_such_change_affect_the_managers__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newform.Will_such_change_affect_the_managers__c == 'Yes' && newForm.Provide_details_for_change_affect_staff__c == null) {
                newForm.Provide_details_for_change_affect_staff__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Have_any_having_authorization_to_act__c == null) {
                newForm.Have_any_having_authorization_to_act__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Have_any_having_authorization_to_act__c == 'Yes' && newForm.Give_details_for_authorization_to_act__c == null) {
                newForm.Give_details_for_authorization_to_act__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Will_the_change_of_ownership_cause__c == null) {
                newForm.Will_the_change_of_ownership_cause__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Will_the_change_of_ownership_cause__c == 'Yes' && newForm.Give_details_for_the_change_of_ownership__c == null) {
                newForm.Give_details_for_the_change_of_ownership__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (!isBankAccountChange && !newform.Confirm_accreditation_type_are_correct__c && !newForm.Notify_Change_Accreditation_Type__c && getIsAccreditationModelNotNullOrLegacy()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_NoC_error_Accreditation_Type));
                errorFound = true;
            }

            if (!isBankAccountChange && !newform.Confirm_Legal_Details_are_correct__c && !newForm.Notify_Change_Legal_Details__c) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_NoC_error_message1));
                errorFound = true;
            }

            if (!isBankAccountChange && !newform.Confirm_Location_Details_are_correct__c && !newForm.Notify_Change_Location__c) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_NoC_error_message2));
                errorFound = true;
            }

            if (!isBankAccountChange && !newform.Confirm_Ownership_Details_are_correct__c && !newForm.Notify_Change_Ownership__c) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_NoC_error_message3));
                errorFound = true;
            }

            if (newForm.Notify_Change_Ownership__c && !(newForm.ISSP_AMS_Legal_Status__c == 'Corporation' && newForm.ISSP_AMS_Entity_with_listed_shares__c == 'Yes')) {
                if (newForm.ISSP_AMS_Total_Current_Ownership__c == null || newForm.ISSP_AMS_Total_Current_Ownership__c < 99.99 || newForm.ISSP_AMS_Total_Current_Ownership__c > 100) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_NoC_Percent_Ownership));
                    errorFound = true;
                }
            }
        } else if (sectorValue.StartsWith('Travel_Agent') && !isNoticeOfChange) {
            if (amsOfficeType == AMS_Utils.HO) {
                if (includeErrorMsgs) {
                    if(newCase.Reason1__c==AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_STANDARD || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_LITE || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_MULTICOUNTRY) { //Check Corporate fields for New HO (and not Branches Abroad)
                        if (newForm.ISSP_AMS_Legal_Status__c == 'Corporation') {
                            if (newForm.ISSP_AMS_when_incorporated__c == null) {
                                newForm.ISSP_AMS_when_incorporated__c.addError(Label.ISSP_YouMustEnter);
                                errorFound = true;
                            }

                            if (newForm.ISSP_AMS_where_incorporated__c == null) {
                                newForm.ISSP_AMS_where_incorporated__c.addError(Label.ISSP_YouMustEnter);
                                errorFound = true;
                            }

                            if (newForm.ISSP_AMS_Entity_with_listed_shares__c == null) {
                                newForm.ISSP_AMS_Entity_with_listed_shares__c.addError(Label.ISSP_YouMustEnter);
                                errorFound = true;
                            } 
                        }

                        if (newForm.ISSP_AMS_Legal_Status__c == null) {
                            newForm.ISSP_AMS_Legal_Status__c.addError(Label.ISSP_YouMustEnter);
                            errorFound = true;
                        }
                    }

                    if (newForm.ISSP_AMS_Online_Agency_Application__c == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                        newForm.ISSP_AMS_Online_Agency_Application__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (hqAccount.Name == null) {
                        hqAccount.Name.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (hqAccount.BillingStreet == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                        hqAccount.BillingStreet.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }
                    if (hqAccount.BillingCity == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                        hqAccount.BillingCity.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (hqAccount.ShippingStreet == null && hqAccount.Status__c != 'Terminated'){
                        hqAccount.ShippingStreet.addError(Label.ISSP_YouMustEnter);
                        accountUpdated = false;
                    }

                    if (hqAccount.ShippingCity == null && hqAccount.Status__c != 'Terminated'){
                        hqAccount.ShippingCity.addError(Label.ISSP_YouMustEnter);
                        accountUpdated = false;
                    }

                    if (hqAccount.Email__c == null) {
                        hqAccount.Email__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (hqAccount.Phone == null) {
                        hqAccount.Phone.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (newForm.ISSP_AMS_Online_Agency_Application__c == 'Yes' && newForm.ISSP_AMS_Online_Agency_URL__c == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                        newForm.ISSP_AMS_Online_Agency_URL__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (CountryCheckList.Statement_of_International_Sales__c && newForm.International_Sales_in_last_Year__c == null && newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO) {
                        newForm.International_Sales_in_last_Year__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (newForm.ISSP_AMS_VAT_Number_Input__c == null && isocountry.Hide_Tax_Number_VAT__c == false) {
                        newForm.ISSP_AMS_VAT_Number_Input__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (newForm.ISSP_AMS_Registered_Capital__c == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                        newForm.ISSP_AMS_Registered_Capital__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (newForm.ISSP_AMS_Paidup_capital__c == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                        newForm.ISSP_AMS_Paidup_capital__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (newForm.ISSP_AMS_Min_Paidup_capital__c == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                        newForm.ISSP_AMS_Min_Paidup_capital__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }

                    if (newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c == null) {
                        newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }
                    if (newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c == 'Yes' && newForm.Cargo_Agent_Account__c == null) {
                        newForm.IATA_Cargo_Code__c.addError(Label.ISSP_AMS_Validation_Cargo_Code);
                        errorFound = true;
                    }

                    if (newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c == null) {
                        newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c.addError(Label.ISSP_AMS_Step3_IATA_Reg_Cargo_Agent);
                        errorFound = true;
                    }

                    if (newForm.ISSP_AMS_GDS_with_signed_contract__c == null) {
                        newForm.ISSP_AMS_GDS_with_signed_contract__c.addError(Label.ISSP_AMS_Step3_Indicate_GDSs);
                        errorFound = true;
                    }

                    //Legal / Registered name required for Branches Abroad, Terminated Agent and Accred Agent applying for New HO
                    if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || isTerminatedAgent || isNewHOforAccredAgent) {
                        if (newForm.Account_Name__c == null) {
                            newForm.Account_Name__c.addError(Label.ISSP_YouMustEnter);
                            errorFound = true;
                        }

                        if (!validateBROfficeDetails()) {
                            errorFound = true;
                        }
                    }

                    if (newForm.ISSP_AMS_Portal_admin__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Portal_Admin));
                        errorFound = true;
                    }

                    if (cntIFAPContacts == 0 && newForm.Agent_Type__c != AMS_Utils.NEWFORM_AGENTTYPE_NO_CASH && !isMultiCountryNewAE) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Financial_Contact));
                        errorFound = true;
                    }

                    if(newForm.Agent_Type__c == AMS_Utils.NEWFORM_AGENTTYPE_NO_CASH || newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_CASH){
                        if(validateNewAccModelHO(true)) errorFound = true;
                    }

                    if ((newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_STANDARD || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_LITE || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_MULTICOUNTRY ) && !(newForm.ISSP_AMS_Legal_Status__c == 'Corporation' && newForm.ISSP_AMS_Entity_with_listed_shares__c == 'Yes')) {
                        if (newForm.ISSP_AMS_Total_Ownership__c == null || newForm.ISSP_AMS_Total_Ownership__c < 99.99 || newForm.ISSP_AMS_Total_Ownership__c > 100 ) {

                            if(newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO) {
                                if (newForm.ISSP_AMS_Legal_Status__c == 'Sole Proprietorship' || newForm.ISSP_AMS_Legal_Status__c == null) {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Percent_Ownership));
                                } else {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Percent_Ownership2));
                                }
                            } else {
                                if (newForm.ISSP_AMS_Legal_Status__c == 'Sole Proprietorship' || newForm.ISSP_AMS_Legal_Status__c == null) {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Percent_Ownership_AE));
                                } else {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Percent_Ownership2_AE));
                                }
                            }
                            errorFound = true;
                        }
                    }
                }
            }

            if (amsOfficeType == 'Branch') {
                if ((newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE) && newForm.ISSP_AMS_GDS_with_signed_contract__c == null) {
                    newForm.ISSP_AMS_GDS_with_signed_contract__c.addError(Label.ISSP_AMS_Step3_Indicate_GDSs);
                    errorFound = true;
                }

                if (newForm.Wholly_owned_by_this_Head_Office__c == null && newCase.Reason1__c != AMS_Utils.CASE_REASON_ASSOCIATE_ENTITY_STANDARD) {
                    newForm.Wholly_owned_by_this_Head_Office__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if (newForm.Wholly_managed_by_this_Head_Office__c == null && newCase.Reason1__c != AMS_Utils.CASE_REASON_ASSOCIATE_ENTITY_STANDARD) {
                    newForm.Wholly_managed_by_this_Head_Office__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                //NG this will be used for the New Associated Entity
                if(newForm.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH || newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_CASH){
                    if(validateNewAccModelBranch(true)) errorFound = true;
                }

                if (!validateBROfficeDetails()) errorFound = true;

                if (newForm.ISSP_AMS_VAT_Number_Input__c == null && isocountry.Hide_Tax_Number_VAT__c == false) {
                    newForm.ISSP_AMS_VAT_Number_Input__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            }

            if (cntAuthorisedSig == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Author_Sig));
                errorFound = true;
            }

            //Validation for both HO & Branch office

            if (newForm.ISSP_AMS_Pax_Office_Open_Date__c == null) {
                newForm.ISSP_AMS_Pax_Office_Open_Date__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (CountryCheckList.Registration_required__c) {
                if (newForm.ISSP_AMS_Trade_Reg_No__c == null) {
                    newForm.ISSP_AMS_Trade_Reg_No__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.ISSP_AMS_Date_Registration_granted__c == null) {
                    newForm.ISSP_AMS_Date_Registration_granted__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            }

            if (CountryCheckList.License_required__c) {
                if (newForm.ISSP_AMS_License_No__c == null) {
                    newForm.ISSP_AMS_License_No__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if (newForm.ISSP_AMS_Date_License_granted__c == null) {
                    newForm.ISSP_AMS_Date_License_granted__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            }

            if (newForm.ISSP_AMS_Previous_default__c == null) {
                newForm.ISSP_AMS_Previous_default__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.ISSP_AMS_Previous_default__c == 'YES' && newForm.ISSP_AMS_Prev_default_explanation__c == null) {
                newForm.ISSP_AMS_Prev_default_explanation__c.addError(Label.ISSP_AMS_Previous_Default_Details);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Premises_located_at_airport__c == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                newForm.ISSP_AMS_Premises_located_at_airport__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AM_Means_Identified_Travel_Agency__c == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                newForm.ISSP_AM_Means_Identified_Travel_Agency__c.addError(Label.ISSP_AMS_Means_Agency_Identified);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Gross_Amnt_First_year__c == null && (newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_CASH || newform.Agent_Type__c == AMS_UTILS.ACCREDITATIONMODEL_LEGACY)) {
                newForm.ISSP_AMS_Gross_Amnt_First_year__c.addError(Label.ISSP_AMS_Gross_Amnt_First_year);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Gross_Amnt_Second_year__c == null && (newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_CASH || newform.Agent_Type__c == AMS_UTILS.ACCREDITATIONMODEL_LEGACY)) {
                newForm.ISSP_AMS_Gross_Amnt_Second_year__c.addError(Label.ISSP_AMS_Gross_Amnt_Second_year);
                errorFound = true;
            }

        //EO Travel Agency Form Validation, start of CGO HO validation
        } else if (sectorValue.StartsWith('Cargo_Agent') && (newForm.Agent_Type__c == 'IATA Cargo Agent' || newForm.Agent_Type__c == 'EACP Intermediary') && amsOfficeType == AMS_Utils.HO) {
            Integer cntFacilities = [SELECT COUNT() FROM AMS_Facility__c WHERE AMS_Online_Accreditation__c = :newForm.Id];

            if (cntFacilities == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add at least one facility (SECTION 5)'));
                errorFound = true;
            }

            if (hqAccount.Email__c == null) {
                hqAccount.Email__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Legal_Status__c == null) {
                newForm.ISSP_AMS_Legal_Status__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            //Legal / Registered name required for Terminated Cargo Agent and Accred PAX Agent applying for New CGO HO
            if ((isTerminatedAgent || isNewHOforAccredAgent) && newForm.Account_Name__c == null) {
                newForm.Account_Name__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if ((isTerminatedAgent || isNewHOforAccredAgent) && !validateBROfficeDetails())
                errorFound = true;

            if (newForm.ISSP_AMS_Date_legal_establishment__c == null) {
                newForm.ISSP_AMS_Date_legal_establishment__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Is_there_any_relationship__c == 'Yes' && !isocountry.EACP_Country__c && newForm.Give_full_details__c == null) {
                newForm.Give_full_details__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Is_Applicant_Parent__c == null && !isocountry.EACP_Country__c) {
                newForm.ISSP_AMS_Is_Applicant_Parent__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (isocountry.EACP_Country__c && newForm.ISSP_AMS_Number_of_Years_Traded__c == null) {
                newForm.ISSP_AMS_Number_of_Years_Traded__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (isocountry.EACP_Country__c && newForm.Is_your_firm_handling_Dangerous_Goods__c == null) {
                newForm.Is_your_firm_handling_Dangerous_Goods__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Business_Activities__c == null && !isocountry.EACP_Country__c) {
                newForm.ISSP_AMS_Business_Activities__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Is_Applicant_Parent__c == 'Yes' && !isocountry.EACP_Country__c && newForm.ISSP_AMS_State_Names_Addresses__c == null) {
                newForm.ISSP_AMS_State_Names_Addresses__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (CountryCheckList != null && CountryCheckList.License_required__c && newForm.ISSP_AMS_Type_of_License__c == null) {
                newForm.ISSP_AMS_Type_of_License__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (CountryCheckList != null && CountryCheckList.License_required__c && newForm.ISSP_AMS_Date_License_granted__c == null) {
                newForm.ISSP_AMS_Date_License_granted__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Legal_Status__c == 'Corporation' && newForm.ISSP_AMS_Date_of_incorporation__c == null) {
                newForm.ISSP_AMS_Date_of_incorporation__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Legal_Status__c == 'Corporation' && !isocountry.EACP_Country__c && newForm.ISSP_AMS_Nominee_Trustee__c == null) {
                newForm.ISSP_AMS_Nominee_Trustee__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Legal_Status__c == 'Association' && newForm.ISSP_AMS_Date_of_Association__c == null) {
                newForm.ISSP_AMS_Date_of_Association__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Legal_Status__c == 'Corporation' && newForm.ISSP_AMS_Nominee_Trustee__c == 'Yes' && !isocountry.EACP_Country__c && newForm.ISSP_AMS_For_whom_Nominee__c == null) {
                newForm.ISSP_AMS_For_whom_Nominee__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (!isocountry.EACP_Country__c && newForm.Does_your_firm_intend_to_request__c == null) {
                newForm.Does_your_firm_intend_to_request__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Does_your_firm_intend_to_request__c == 'Yes' && !isocountry.EACP_Country__c && newForm.List_the_airport_s_to_be_authorized__c == null) {
                newForm.List_the_airport_s_to_be_authorized__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Has_your_firm_ever_held_a_Cargo_Agency__c == null) {
                newForm.Has_your_firm_ever_held_a_Cargo_Agency__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Has_your_firm_ever_held_a_Cargo_Agency__c == 'Yes') {
                if (newForm.IATA_Agents_Numeric_Code__c == null) {
                    newForm.IATA_Agents_Numeric_Code__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Date_issued__c == null) {
                    newForm.Date_issued__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Name_under_which_it_was_issued__c == null) {
                    newForm.Name_under_which_it_was_issued__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Reason_for_cancellation__c == null) {
                    newForm.Reason_for_cancellation__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            }
            
            if (isocountry.EACP_Country__c && newForm.Has_your_form_ever_held_CASS_Assoc_etc__c == null) {
                newForm.Has_your_form_ever_held_CASS_Assoc_etc__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Has_your_form_ever_held_CASS_Assoc_etc__c == 'Yes') {
                if (isocountry.EACP_Country__c && newForm.CASS_Assoc_Code__c == null) {
                    newForm.CASS_Assoc_Code__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.CASS_Date_issued__c == null) {
                    newForm.CASS_Date_issued__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.CASS_Name_under_which_it_was_issued__c == null) {
                    newForm.CASS_Name_under_which_it_was_issued__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.CASS_Reason_for_cancellation__c == null) {
                    newForm.CASS_Reason_for_cancellation__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            }

            if (newForm.Is_your_firm_an_approved_IATA_Passenger__c == null) {
                newForm.Is_your_firm_an_approved_IATA_Passenger__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Is_your_firm_an_approved_IATA_Passenger__c == 'Yes' && newForm.Agents_Numeric_Code_of_your_Head_Office__c == null) {
                newForm.Agents_Numeric_Code_of_your_Head_Office__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (!isocountry.EACP_Country__c && newForm.Does_the_air_transportation_which_your__c == null) {
                newForm.Does_the_air_transportation_which_your__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Does_the_air_transportation_which_your__c == 'Yes' && !isocountry.EACP_Country__c && newForm.State_the_percentage_of_your_gross__c == null) {
                newForm.State_the_percentage_of_your_gross__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (!isocountry.EACP_Country__c && newForm.Does_your_firm_sell_air_cargo__c == null) {
                newForm.Does_your_firm_sell_air_cargo__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Does_your_firm_sell_air_cargo__c == 'Yes' && !isocountry.EACP_Country__c && newForm.What_percentage_of_your_sales__c == null) {
                newForm.What_percentage_of_your_sales__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.Is_your_firm_a_General_Sales_Agent_GSA__c == 'Yes' && newForm.List_carriers__c == null) {
                newForm.List_carriers__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.Been_found_guilty_of_infringements__c == null) {
                newForm.Been_found_guilty_of_infringements__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.Been_involved_in_a_bankruptcy__c == null) {
                newForm.Been_involved_in_a_bankruptcy__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.Been_involved_in_a_bankruptcy__c == 'Yes' && newForm.If_yes_are_you_fully_and_legally__c == null) {
                newForm.If_yes_are_you_fully_and_legally__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Been_a_sole_proprietor__c == null) {
                newForm.Been_a_sole_proprietor__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Been_director_or_had_a_financial__c == null) {
                newForm.Been_director_or_had_a_financial__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Been_director_or_had_a_financial__c == 'Yes') {
                if (newForm.State_full_name_of_such_Agent__c == null) {
                    newForm.State_full_name_of_such_Agent__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }

                if (newForm.Were_all_IATA_Members_fully_repaid__c == null) {
                    newForm.Were_all_IATA_Members_fully_repaid__c.addError(Label.ISSP_YouMustEnter);
                    newForm.State_full_name_of_such_Agent__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            }

            if (newForm.Is_your_firm_acting_as_agent_for_surface__c == 'Yes' && !isocountry.EACP_Country__c && newForm.Rail__c == null && newForm.Steamship__c == null && newForm.Trucking__c == null) {
                newForm.Rail__c.addError('Please fill in at least one of the fields: "Rail" , "Steamship" , "Trucking"');
                newForm.Steamship__c.addError('Please fill in at least one of the fields: "Rail" , "Steamship" , "Trucking"');
                newForm.Trucking__c.addError('Please fill in at least one of the fields: "Rail" , "Steamship" , "Trucking"');
                errorFound = true;
            }
            if (newForm.Is_your_firm_affiliated_directly__c == 'Yes' && !isocountry.EACP_Country__c && newForm.provide_details__c == null) {
                newForm.provide_details__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (!isocountry.EACP_Country__c && newForm.Does_your_firm_now_share_or_intend__c == null) {
                newForm.Does_your_firm_now_share_or_intend__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.Does_your_firm_now_share_or_intend__c == 'Yes' && !isocountry.EACP_Country__c && newForm.Explain_fully_stating_name__c == null) {
                newForm.Explain_fully_stating_name__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.Does_your_firm_operate_a_cargo_cartage__c == 'Yes' && !isocountry.EACP_Country__c && newForm.Does_your_firm_use_its_own_vehicles__c == null) {
                newForm.Does_your_firm_use_its_own_vehicles__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.Is_your_firm_insured_to_cover__c == null) {
                newForm.Is_your_firm_insured_to_cover__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.Is_your_firm_a_member_of_a_national__c == 'Yes' && newForm.Give_the_name_of_the_association_s__c == null) {
                newForm.Give_the_name_of_the_association_s__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.ISSP_AMS_Registered_Capital__c == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
                newForm.ISSP_AMS_Registered_Capital__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.ISSP_AMS_Paidup_capital__c == null && newForm.ISSP_AMS_Legal_Status__c == 'Corporation') {
                newForm.ISSP_AMS_Paidup_capital__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.ISSP_AMS_Min_Paidup_capital__c == null) {
                newForm.ISSP_AMS_Min_Paidup_capital__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
            if (newForm.ISSP_AMS_Amount_of_credit_requested__c == null && isocountry.EACP_Country__c) {
                newForm.ISSP_AMS_Amount_of_credit_requested__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Total_Freight_Charges_monetary_value__c == null) {
                newForm.Total_Freight_Charges_monetary_value__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Total_Freight_weight_Kgs__c == null) {
                newForm.Total_Freight_weight_Kgs__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.No_Consignments_Last_Year__c == null) {
                newForm.No_Consignments_Last_Year__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Total_Projected_Value_Freight__c == null) {
                newForm.Total_Projected_Value_Freight__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Total_Projected_Weight_Kilos__c == null) {
                newForm.Total_Projected_Weight_Kilos__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Total_Projected_Number_Consignments__c == null) {
                newForm.Total_Projected_Number_Consignments__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Portal_admin__c == null ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Portal_Admin));
                errorFound = true;
            }

            if (cntIFAPContacts == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Financial_Contact));
                errorFound = true;
            }

            if (cntAuthorisedSig == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Author_Sig));
                errorFound = true;
            }

            //Cargo Ownership must be 100% except for listed Corporations (check this for CGO)
            if (!(newForm.ISSP_AMS_Legal_Status__c == 'Corporation' && newForm.ISSP_AMS_Entity_with_listed_shares__c == 'Yes')) {
                if (newForm.ISSP_AMS_Total_Ownership__c == null || newForm.ISSP_AMS_Total_Ownership__c < 99.99 || newForm.ISSP_AMS_Total_Ownership__c > 100) {
                    if (newForm.ISSP_AMS_Legal_Status__c == 'Sole Proprietorship')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SECTIONS 3.1 PEOPLE - Please ensure that the % Total Ownership equals 100%.'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SECTIONS 3.1 PEOPLE & 3.2 COMPANIES - Please ensure that the % Total Ownership equals 100%.'));

                    errorFound = true;
                }
            }

            if (!(isocountry.EACP_Country__c && newForm.Is_your_firm_handling_Dangerous_Goods__c == 'No') && !validateDangerousGoods(2))
                errorFound = true;

        } else if (sector!= null && amsOfficeType != null && isNoticeOfChange != null && sector.StartsWith(AMS_Utils.SECTOR_CARGO) && amsOfficeType == 'Branch' && !isNoticeOfChange) { //All CGO Branches share the same form, exept that Only IATA / EACP CGO agents require DGR trained staff
            if (!validateBROfficeDetails())
                errorFound = true;

            if (newForm.ISSP_AMS_VAT_Number_Input__c == null && isocountry.Hide_Tax_Number_VAT__c == false) {
                newForm.ISSP_AMS_VAT_Number_Input__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Separate_user_access__c == null) {
                newForm.Separate_user_access__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Head_Office_have_access__c == null) {
                newForm.Head_Office_have_access__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (isocountry.EACP_Country__c && newForm.Is_your_firm_handling_Dangerous_Goods__c == null) {
                newForm.Is_your_firm_handling_Dangerous_Goods__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Billing_payment_Head_Office__c == false && newForm.Billing_payment_Branch_Office__c == false && newForm.Billing_payment_Another_Branch__c == false) {
                newForm.Billing_payment_Head_Office__c.addError(Label.ISSP_YouMustEnter);
                newForm.Billing_payment_Branch_Office__c.addError(Label.ISSP_YouMustEnter);
                newForm.Billing_payment_Another_Branch__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Billing_payment_Another_Branch__c == true && newForm.Branch_Office_Code__c == null) {
                newForm.Branch_Office_Code__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Billing_payment_Branch_Office__c == true && newForm.Payment_Via_Bank_Transfer__c == false && newForm.Payment_Via_Direct_Debit__c == false) {
                newForm.Payment_Via_Bank_Transfer__c.addError(Label.ISSP_YouMustEnter);
                newForm.Payment_Via_Direct_Debit__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (cntCASSContact == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please designate at least one CASS Contact.'));
                errorFound = true;
            }

            if (cntAuthorisedSig == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Author_Sig));
                errorFound = true;
            }

            //Only IATA / EACP CGO Branch offices require a DGR, and not others such as CASS Assoc. etc.
            if ((newForm.Agent_Type__c == 'IATA Cargo Agent' || newForm.Agent_Type__c == 'EACP Intermediary') && !(isocountry.EACP_Country__c && newForm.Is_your_firm_handling_Dangerous_Goods__c == 'No') && !validateDangerousGoods(1))
                errorFound = true;

        } else if (sector != null && sector.StartsWith(AMS_Utils.SECTOR_CARGO) && !isNoticeOfChange &&  (newForm.Agent_Type__c != 'IATA Cargo Agent' && newForm.Agent_Type__c != 'EACP Intermediary') && amsOfficeType == AMS_Utils.HO) {
            errorFound = validateCGOCASSAssociate(cntIFAPContacts, cntAuthorisedSig, cntCASSContact);

            if (hqAccount.Email__c == null) {
                hqAccount.Email__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
        }

        //Finally need to check that Local Address fields are completed for China, for all forms (HO & BR)
        if(isocountry.Local_language_Agency_details_required__c && !isNoticeOfChange) {
            if (newForm.Local_Legally_Registered_Name__c == null) {
                newForm.Local_Legally_Registered_Name__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Local_Physical_Address_Street__c == null) {
                newForm.Local_Physical_Address_Street__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Local_Physical_Address_City__c == null) {
                newForm.Local_Physical_Address_City__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Local_Physical_Address_Province__c == null) {
                newForm.Local_Physical_Address_Province__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Local_Postal_Address_Street__c == null) {
                newForm.Local_Postal_Address_Street__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Local_Postal_Address_City__c == null) {
                newForm.Local_Postal_Address_City__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Local_Postal_Address_Province__c == null) {
                newForm.Local_Postal_Address_Province__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }
        } //EO Local Agency details e.g. for China, validation

        if (errorFound) return false;

        return true;
    }

    public Boolean validateCGOCASSAssociate(Integer cntIFAPContacts, Integer cntAuthorisedSig, Integer cntCASSContact) {
        Boolean errorFound = false;
        if (newForm.ISSP_AMS_Portal_admin__c == null ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Portal_Admin));
            errorFound = true;
        }

        if (cntAuthorisedSig == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Author_Sig));
            errorFound = true;
        }

        if (cntCASSContact == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please designate at least one CASS Contact.'));
            errorFound = true;
        }

        //CASS Ownership must be 100% except for listed Corporations (check this for CGO)
        if (!(newForm.ISSP_AMS_Legal_Status__c == 'Corporation' && newForm.ISSP_AMS_Entity_with_listed_shares__c == 'Yes')) {
            if (newForm.ISSP_AMS_Total_Ownership__c == null || newForm.ISSP_AMS_Total_Ownership__c < 99.99 || newForm.ISSP_AMS_Total_Ownership__c > 100 ) {
                if (newForm.ISSP_AMS_Legal_Status__c == 'Sole Proprietorship')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SECTIONS 2.1 PEOPLE - Please ensure that the % Total Ownership equals 100%.'));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SECTIONS 2.1 PEOPLE & 2.2 COMPANIES - Please ensure that the % Total Ownership equals 100%.'));
                
                errorFound = true;
            }
        }

        if (newForm.ISSP_AMS_Legal_Status__c == null) {
            newForm.ISSP_AMS_Legal_Status__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        //Legal / Registered name required for Terminated Cargo Agent and Accred PAX Agent applying for New CASS HO
        if ((isTerminatedAgent || isNewHOforAccredAgent) && newForm.Account_Name__c == null) {
            newForm.Account_Name__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if ((isTerminatedAgent || isNewHOforAccredAgent) && !validateBROfficeDetails())
            errorFound = true;

        if (newForm.Est_Future_Sales__c == null) {
            newForm.Est_Future_Sales__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (newForm.ISSP_AMS_VAT_Number_Input__c == null && isocountry.Hide_Tax_Number_VAT__c == false) {
            newForm.ISSP_AMS_VAT_Number_Input__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (newForm.Registered_to_hot_files__c == null) {
            newForm.Registered_to_hot_files__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (CountryCheckList.Registration_required__c && newForm.ISSP_AMS_Trade_Reg_No__c == null) {
            newForm.ISSP_AMS_Trade_Reg_No__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (CountryCheckList.Registration_required__c && newForm.ISSP_AMS_Date_Registration_granted__c == null) {
            newForm.ISSP_AMS_Date_Registration_granted__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        return errorFound;
    }

    public Boolean validateDangerousGoods(Integer limitNum) {
        Boolean errorFound = false;
        Integer cntCrtDanGoodsContacts = [SELECT COUNT() 
                                        FROM AMS_Accreditation_Contact__c
                                        WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id
                                            AND recordTypeId = :RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Trained_Staff')
                                            AND Training_dangerous_goods_completed__c = 'Yes'];

        if (cntCrtDanGoodsContacts < limitNum) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Must have ' + limitNum + ' or more staff members with dangerous goods handling certificate'));
            errorFound = true;
        }

        if (errorFound) return false;

        return true;
    }

    public Boolean validateBROfficeDetails() {
        Boolean errorFound = false;
        if (newForm.Branch_Office_Street_name_number__c == null) {
            newForm.Branch_Office_Street_name_number__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (newForm.Branch_Office_City__c == null) {
            newForm.Branch_Office_City__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (newForm.Branch_Office_Phone__c == null) {
            newForm.Branch_Office_Phone_National__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (newform.Shipping_Street__c == null) {
            newform.Shipping_Street__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        } 

        if (newform.Shipping_City__c == null) {
            newform.Shipping_City__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }

        if (errorFound) return false;

        return true;
    }

    public Id getRegionalQueue() {
        Id qId;

        Set<String> queueNames = new Set<String> {'AgencyManagementAP', 'AgencyManagementAfricaME', 'AgencyManagementAmericas', 'AgencyManagementChinaNAsia', 'CasesACCEuropeOffOnshore'};
        Map<String, QueueSobject> mapRegionalQueue = new Map<String, QueueSobject>();
        //Build map queue.name -> queue
        for (QueueSobject queue : [Select Queue.Id, Queue.DeveloperName From QueueSobject Where Queue.DeveloperName in: queueNames]) {
            mapRegionalQueue.put(queue.Queue.DeveloperName, queue);
        }

        //Assigns queue according to region
        if (newCase.Region__c == 'Africa & Middle East') {
            if (mapRegionalQueue.get('AgencyManagementAfricaME') != null)
                qId = mapRegionalQueue.get('AgencyManagementAfricaME').Queue.Id;

        } else if (newCase.Region__c == 'Americas') {
            if (mapRegionalQueue.get('AgencyManagementAmericas') != null)
                qId = mapRegionalQueue.get('AgencyManagementAmericas').Queue.Id;

        } else if (newCase.Region__c == 'Asia & Pacific') {
            if (mapRegionalQueue.get('AgencyManagementAP') != null) 
                qId = mapRegionalQueue.get('AgencyManagementAP').Queue.Id;

        } else if (newCase.Region__c == 'China & North Asia') {
            if (mapRegionalQueue.get('AgencyManagementChinaNAsia') != null) 
                qId = mapRegionalQueue.get('AgencyManagementChinaNAsia').Queue.Id;
            
        } else if (newCase.Region__c == 'Europe') {
            if (mapRegionalQueue.get('CasesACCEuropeOffOnshore') != null) 
                qId = mapRegionalQueue.get('CasesACCEuropeOffOnshore').Queue.Id;
        }

        return qId;
    }

    public void setContextualHelp(string lang) {
        if(displayLanguage != null && displayLanguage != '') lang = displayLanguage;

        String fldName = 'ISSP_AMS_HelpText_' + lang + '__c';

        Map<String, ISSP_AMS_Contextual_Help__c> hlpMap = ISSP_AMS_Contextual_Help__c.getAll();

        if (hlpMap.containsKey('MIN_PAIDUP_CAPITAL')) txtHelpMinPaidCapital = (String) hlpMap.get('MIN_PAIDUP_CAPITAL').get(fldName);
        if (hlpMap.containsKey('REGISTERED_CAPITAL')) txtHelpRegisteredCapital = (String) hlpMap.get('REGISTERED_CAPITAL').get(fldName);
        if (hlpMap.containsKey('PAIDUP_CAPITAL')) txtHelpPaidUpCapital = (String) hlpMap.get('PAIDUP_CAPITAL').get(fldName);
        if (hlpMap.containsKey('TAX_NUMBER')) txtHelpTaxNumber = (String) hlpMap.get('TAX_NUMBER').get(fldName);
        if (hlpMap.containsKey('AUTHORISED_SIG')) txtHelpAuthorisedSig = (String) hlpMap.get('AUTHORISED_SIG').get(fldName);
        if (hlpMap.containsKey('FIN_CONTACT')) txtHelpFinContact = (String) hlpMap.get('FIN_CONTACT').get(fldName);
        if (hlpMap.containsKey('PORTAL_ADMIN')) txtHelpPortalAdmin = (String) hlpMap.get('PORTAL_ADMIN').get(fldName);
        if (hlpMap.containsKey('GROSS_SALES')) txtHelpGrossSales = (String) hlpMap.get('GROSS_SALES').get(fldName);
        if (hlpMap.containsKey('TRAINED_STAFF_ORGANIZATION')) txtHelpTrainedStaffOrganization = (String) hlpMap.get('TRAINED_STAFF_ORGANIZATION').get(fldName);
        if (hlpMap.containsKey('TRAINED_STAFF_REFERENCE')) txtHelpTrainedStaffReference = (String) hlpMap.get('TRAINED_STAFF_REFERENCE').get(fldName);

        txtLocalAgencyDetailsTitle = Label.ISSP_AMS_Local_Details_Title;
        txtLocalAgencyDetailsPleaseEnter = Label.ISSP_AMS_Local_Details_Please_Enter;
        txtLocalAgencyDetailsChangePleaseEnter = Label.ISSP_AMS_Local_Details_Change_Please_Enter;
        txtLocalAgencyDetailsLegalNameENG = Label.ISSP_AMS_Local_Details_Legal_Name_ENG;
        txtLocalAgencyDetailsLegalName = Label.ISSP_AMS_Local_Details_Legal_Name;
        txtLocalAgencyDetailsNoCompany = Label.ISSP_AMS_Local_Details_No_Company;
        txtLocalAgencyDetailsCopyAddress = Label.ISSP_AMS_Local_Details_Copy_Address;
        txtLocalAgencyDetailsPhysicalAddress = Label.ISSP_AMS_Local_Details_Physical_Address;
        txtLocalAgencyDetailsCorrespondenceAddress = Label.ISSP_AMS_Local_Details_Correspondence_Address;
        txtLocalAgencyDetailsFirstNameENG = Label.ISSP_AMS_Local_Details_First_Name_ENG;
        txtLocalAgencyDetailsFirstNameLocal = Label.ISSP_AMS_Local_Details_First_Name_Local;
        txtLocalAgencyDetailsLastNameENG = Label.ISSP_AMS_Local_Details_Last_Name_ENG;
        txtLocalAgencyDetailsLastNameLocal = Label.ISSP_AMS_Local_Details_Last_Name_Local;
        txtLocalAgencyDetailsCompanyNameENG = Label.ISSP_AMS_Local_Details_Company_Name_ENG;
        txtLocalAgencyDetailsCompanyNameLocal = Label.ISSP_AMS_Local_Details_Company_Name_Local;
        txtLocalAgencyDetailsNoLocalFirstName = Label.ISSP_AMS_Local_Details_No_Local_FirstName;
        txtLocalAgencyDetailsNoLocalLastName = Label.ISSP_AMS_Local_Details_No_Local_LastName;
        txtLocalAgencyDetailsNoLocalCompanyName = Label.ISSP_AMS_Local_Details_No_Local_CompanyName;
    }

    public string getAmsAllLangCountryLabel(IATA_ISO_Country__c isoctry, string userLang) {
        String ctrylabel;

        try {
            if (userLang == 'en_US') ctrylabel = (String)isoctry.get('Name');
            else if (userLang == 'es') ctrylabel =  (String)isoctry.get('IATA_Country_SP__c');
            else if (userLang == 'fr') ctrylabel =  (String)isoctry.get('IATA_Country_FR__c');
            else if (userLang == 'it') ctrylabel =  (String)isoctry.get('IATA_Country_IT__c');
            else if (userLang == 'pt_BR') ctrylabel =  (String)isoctry.get('IATA_Country_PT__c');
            else if (userLang == 'ko') ctrylabel =  (String)isoctry.get('IATA_Contry_KR__c');
            else if (userLang == 'zh_CN') ctrylabel =  (String)isoctry.get('IATA_Country_ZH__c');
            else if (userLang == 'ja') ctrylabel =  (String)isoctry.get('IATA_Country_JP__c');
            else ctrylabel = (String)isoctry.get('Name');

            if (ctrylabel != null) return ctrylabel;
            else return (String)isoctry.get('Name');

        } catch (DmlException ex) { return (String)isoctry.get('Name'); }
    }

    private void setOwnerAndRoleLabels() {
        if (newForm.ISSP_AMS_Legal_Status__c != null) {
            legalstatus = newForm.ISSP_AMS_Legal_Status__c.toLowerCase();
            setPageLegalStatusLabels();
        } else {
            roleLabelType = 'manager';
            ownerLabelType = 'owner';
            ownerLabel = Label.ISSP_AMS_Owner;
            roleLabel = Label.ISSP_AMS_Manager;
        }

        if (newForm.ISSP_AMS_Legal_Status__c != null) {
            legalstatusafterchange = newForm.ISSP_AMS_Legal_Status__c.toLowerCase();
            setPageLegalStatusAfterChangeLabels();
        } else {
            roleLabelTypeAfterChange = 'manager';
            ownerLabelTypeAfterChange = 'owner';
            ownerLabelAfterChange = Label.ISSP_AMS_Owner;
            roleLabelAfterChange = Label.ISSP_AMS_Manager;
        }
    }

    //@future (callout = true)
    public static void OSCARIntegration(String accountId, String accreditationId, String typeOfProcess, String caseId) {
        /** USE WS Method
        ISSP_AMS_RecordCreator_Class.AMS_RecordCreatorWebservice instanceWS = getWSInstance();
        String createAccreditationResponse = instanceWS.createAccreditation(accountId, accreditationId, typeOfProcess, caseId);
       **/

        //FM 30-01-2017 - OSCAR Integration - do not create OSCAR when there's a existing case with "Open - EDMC" status and an OSCAR Record already assigned to the case
        List<Case> checkCase = [Select id,OSCAR__c  from case where id = :caseid AND OSCAR__c <> null AND status = 'Open - EDMC'];

        // USE Static Method
        if(checkCase == null || checkCase.size() == 0 ){
            AMS_RecordCreatorWebservice.createAccreditation(accountId, accreditationId, typeOfProcess, caseId);
        }else{
            case auxOscarCase = checkCase.get(0);
            List<AMS_OSCAR__c> checkOscar = [Select id,Status__c  from AMS_OSCAR__c where id = :auxOscarCase.OSCAR__c];
            AMS_OSCAR__c auxOscar = checkOscar.get(0);
            auxOscar.Status__c = 'Open';
            update auxOscar;
        }
    }

    public PageReference redirectToPDF() {
        PageReference np;

        if (sectorValue.StartsWith('Travel_Agent') && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_MULTICOUNTRY)) {
            np = new PageReference('/ISSP_AMS_PDF_ApplicationForm?caseid=' + newCase.id);
        } else if (sectorValue.StartsWith('Travel_Agent') && (newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH || newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_CASH) && newCase.Reason1__c != AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD) { //NEWGEN - 605
            np = new PageReference('/ISSP_AMS_PDF_ANG_PAX_HE?caseid=' + newCase.id);
        } else if (sectorValue.StartsWith('Travel_Agent') && (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE)) {
            np = new PageReference('/ISSP_AMS_PDF_ANG_PAX_AE?caseid=' + newCase.id);
        } else {
            np = new PageReference('/ISSP_AMS_PDF_CGO?caseid=' + newCase.id + '&mode=pdf');
        }

        np.setRedirect(false);
        return np;
    }

    private Void updateNoCReasonSubject() {
        if (isBankAccountChange) {
            newCase.Reason1__c = 'Bank Detail Update';
            newCase.Subject = Label.ISSP_AMS_NoC_Direct_Debit_Change + ' – ' + accountConcerned.IATACode__c + ' – ' + accountConcerned.Name;
        } else if(newForm.Location_Class__c == 'I'){  //AMSU-140
            newCase.Reason1__c = AMS_Utils.CASE_REASON_CHG_DATA_MAINTENANCE; //AMSU-165
            newCase.Subject =  'Agency Changes – ' + accountConcerned.Name;
        } else if ((newForm.Is_change_location__c && newForm.Is_change_legal_name__c) || (newForm.Is_change_location__c && newForm.Is_change_ownership_or_shareholding__c) || (newForm.Is_change_ownership_or_shareholding__c && newForm.Is_change_legal_name__c)) {
            newCase.Reason1__c = 'Major Change';
            newCase.Subject = Label.ISSP_AMS_NoC_Multiple_Changes + ' – ' + accountConcerned.IATACode__c + ' – ' + accountConcerned.Name;
        } else {
            newCase.Subject = 'Change – ' + accountConcerned.IATACode__c + ' – ' + accountConcerned.Name;
            if (newForm.Is_change_location__c)
                newCase.Reason1__c = 'CHL - Change of Location';
            else if (newForm.Is_change_legal_name__c)
                newCase.Reason1__c = 'CHN - Change of Name';
            else if (newForm.Is_change_ownership_or_shareholding__c)
                newCase.Reason1__c = 'CHO / CHS – Change of Ownership / Legal Status';
        }
        newCase.Description = Label.ISSP_AMS_Case_Change_Description;
    }

    public Pagereference redirectToFacilitiesPage() {
        saveAMSForm();
        PageReference prFacilities = Page.ISSP_AMS_Facilities;

        prFacilities.getParameters().put('caseId', 'newCase.Id');
        prFacilities.setRedirect(false);
        if (this.facilitiesId != null) {
            retFacility();
            facilityRecordTypeName = this.facilityInContext.recordType.DeveloperName;
        } else if (this.facilitiesId == null) {
            this.facilityInContext = new AMS_Facility__c();
            this.facilityInContext.AMS_Online_Accreditation__c = newForm.Id;
            try {
                this.facilityInContext.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Facility__c', facilityRecordTypeName);
            } catch (exception e) { System.debug('no record type name created'); }
        }

        return prFacilities;
    }

    public PageReference saveFacilities() {
        if (validateFacilities()) {
            upsert this.facilityInContext;
            return goToStep3Section5();
        }
        return null;
    }

    public PageReference cancelFacilities() {
        return goToStep3Section5();
    }

    private void retFacility() {
        this.facilityInContext = [SELECT Id, recordTypeId, recordType.Name, recordType.DeveloperName, Name, AMS_Online_Accreditation__c, Alarm_system__c, Automated_export_accounting__c, Automated_export_documentation__c,
                                  Date_agreement_expires__c, Date_lease_expires__c, Duration_of_contract__c, Email__c, Name_of_lessor__c,
                                  Name_of_sub_contractor__c, Other_pertinent_details__c, Telephone__c, Accessibility_to_vehicles__c,
                                  An_alarm_system__c, Any_functions_involved_in_preperations__c, Area_used_for_Air_freight__c, Are_Consignments_made_ready__c,
                                  A_sprinkler_system__c, Ceiling_height__c, Date_location_opened_for_business__c, Distance_from_nearest_Airport__c,
                                  Distance_from_nearest_Office__c, Doc_Areas__c, Fax__c, Is_the_office_warehouse_leased__c, Is_the_office_open_to_the_general_public__c, General_Public_Opening_Hours__c,
                                  Is_the_warehouse_sub_contracted__c, Is_warehouse_open_to_general_public__c, List_airports_serviced_by_this_facility__c,
                                  Number_of_overhead_doors__c, Office_Full_Address__c, Telex__c, Total_Area__c, Type__c, Type_of_Premises__c, Website__c, Duration_of_lease__c,
                                  Forklift_Max_Weight__c, Forklift_Number__c, Forklift_Type__c, Other_equipment_Max_Weight__c, Other_equipment_Number__c, Other_equipment_Type__c,
                                  Scales_Max_Weight__c, Scales_Number__c, Scales_Type__c
                                  FROM AMS_Facility__c
                                  WHERE Id = : this.facilitiesId LIMIT 1];
    }

    private void setFacilityList() {
        this.facilityList = [SELECT Id, recordTypeId, Name, AMS_Online_Accreditation__c, Alarm_system__c, Automated_export_accounting__c, Automated_export_documentation__c,
                             Date_agreement_expires__c, Date_lease_expires__c, Duration_of_contract__c, Email__c, Name_of_lessor__c,
                             Name_of_sub_contractor__c, Other_pertinent_details__c, Telephone__c, Accessibility_to_vehicles__c,
                             An_alarm_system__c, Any_functions_involved_in_preperations__c, Area_used_for_Air_freight__c, Are_Consignments_made_ready__c,
                             A_sprinkler_system__c, Ceiling_height__c, Date_location_opened_for_business__c, Distance_from_nearest_Airport__c,
                             Distance_from_nearest_Office__c, Doc_Areas__c, Fax__c, Is_the_office_warehouse_leased__c, Is_the_office_open_to_the_general_public__c, General_Public_Opening_Hours__c,
                             Is_the_warehouse_sub_contracted__c, Is_warehouse_open_to_general_public__c, List_airports_serviced_by_this_facility__c,
                             Number_of_overhead_doors__c, Office_Full_Address__c, Telex__c, Total_Area__c, Type__c, Type_of_Premises__c, Website__c,
                             Forklift_Max_Weight__c, Forklift_Number__c, Forklift_Type__c, Other_equipment_Max_Weight__c, Other_equipment_Number__c, Other_equipment_Type__c,
                             Scales_Max_Weight__c, Scales_Number__c, Scales_Type__c, Duration_of_lease__c
                             FROM AMS_Facility__c
                             WHERE AMS_Online_Accreditation__c = : this.newForm.Id];
    }

    private void setTrainedStaffList() {
        //FM 19-07-2017 - AMSU-20 - added: Type_Of_Certificate__c, Registration_number__c, Certificate_Issuer__c
        this.trainedStaffList = [SELECT Id, Name, First_name__c, Last_name__c, List_Dangerous_Goods_Awareness__c, 
        Position_trained_staff__c, IATA_FIATA_training_history__c, Air_cargo_transport_business_exp__c, Training_dangerous_goods_completed__c, 
        Valid_until__c, Type_Of_Certificate__c, Registration_number__c, Certificate_Issuer__c FROM AMS_Accreditation_Contact__c 
        WHERE AMS_Pax_Accreditation_Form__c = :this.newForm.Id AND 
        recordTypeId = :RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Trained_Staff')];
    }

    public void editTrainedStaff() {
        trainedStaffContact = [SELECT Id, Name, First_name__c, Last_name__c, List_Dangerous_Goods_Awareness__c, Position_trained_staff__c, IATA_FIATA_training_history__c, Air_cargo_transport_business_exp__c, Training_dangerous_goods_completed__c, Valid_until__c, AMS_Pax_Accreditation_Form__c, Type_Of_Certificate__c, Registration_number__c, Certificate_Issuer__c 
                               FROM AMS_Accreditation_Contact__c 
                               WHERE Id = :trainedStaffId limit 1];
    }

    public void cancelTrainedStaff() {
        this.trainedStaffContact = new AMS_Accreditation_Contact__c();
        contactSaved = false;
    }

    public void upsertTrainedStaff() {
        this.trainedStaffContact.AMS_Pax_Accreditation_Form__c = this.newForm.Id;
        upsert this.trainedStaffContact;
    }

    public void getCGORegionData() {
        List<String> cargoAllRegionsList = new List<String>{'Africa', 'Australia & S. Pacific', 'Central America & Caribbean', 'Europe',
            'Far East', 'Middle East', 'South America', 'USA / Canada'};

        Map<String, Map<String, String>> regionPerMap = new Map<String, Map<String, String>>();

        cargoRegionList = new List<regionSelection>();
        cargoRegionListWithValue = new List<regionSelection>();

        if (newForm.CGO_Region_Selection__c != '' && newForm.CGO_Region_Selection__c != null) {
            List<String> regionStringList = newForm.CGO_Region_Selection__c.split(';');
            List<String> regionConsignmentsStringList = newForm.CGO_Region_Consignment_Selection__c.split(';');
            List<String> regionTonsStringList = newForm.CGO_Region_Tons_Selection__c.split(';');
            List<String> regionAirFreightStringList = newForm.CGO_Region_AirFreight_Selection__c.split(';');
            List<String> regionPercentagesStringList = newForm.CGO_Region_Percentage_Selection__c.split(';');

            integer i = 0;
            for (String thisRegion : regionStringList) {
                Map<String, String> regionValues = new Map<String, String>();

                regionValues.put('Consignments', regionConsignmentsStringList[i]);
                regionValues.put('Tons', regionTonsStringList[i]);
                regionValues.put('AirFreight', regionAirFreightStringList[i]);
                regionValues.put('Percentages', regionPercentagesStringList[i]);

                regionPerMap.put(thisRegion, regionValues);
                i++;
            }

            for (String thisRegion : cargoAllRegionsList) {
                regionSelection regionRecord = new regionSelection();
                if (regionPerMap.containsKey(thisRegion)) {
                    regionRecord.selected = true;
                    regionRecord.region = thisRegion;
                    regionRecord.consignments = regionPerMap.get(thisRegion).get('Consignments');
                    regionRecord.tons = regionPerMap.get(thisRegion).get('Tons');
                    regionRecord.airfreight = regionPerMap.get(thisRegion).get('AirFreight');
                    regionRecord.percentage = regionPerMap.get(thisRegion).get('Percentages');

                    cargoRegionListWithValue.add(regionRecord);
                } else {
                    regionRecord.selected = false;
                    regionRecord.region = thisRegion;
                }
                cargoRegionList.add(regionRecord);
            }
        } else {
            for (String thisRegion : cargoAllRegionsList) {
                regionSelection regionRecord = new regionSelection();
                regionRecord.selected = false;
                regionRecord.region = thisRegion;
                cargoRegionList.add(regionRecord);
            }
        }
    }

    public class regionSelection {
        public Boolean selected {get; set;}
        public String region {get; set;}
        public String consignments {get; set;}
        public String tons {get; set;}
        public String airfreight {get; set;}
        public String percentage {get; set;}
    }

    public void getSpecialTrafficData() {
        List<String> cargoSpecialTypesList = new List<String>();
        cargoSpecialTypesList.add('Dangerous Goods');
        cargoSpecialTypesList.add('Live Animals');
        cargoSpecialTypesList.add('Other');

        specialTrafficList = new List<specialTraffic>();

        for (String thisType : cargoSpecialTypesList) {
            specialTraffic specialTrafficRecord = new specialTraffic();
            specialTrafficRecord.cargotype = thisType;
            if (thisType == 'Dangerous Goods') {
                specialTrafficRecord.consignments = newForm.DG_Number_of_Consignments__c;
                specialTrafficRecord.tons = newForm.DG_Tons__c;
                specialTrafficRecord.airfreight = newForm.DG_Air_Freight_Charges__c;
                specialTrafficRecord.percentage = newForm.DG_Percentage__c;
            } else if (thisType == 'Live Animals') {
                specialTrafficRecord.consignments = newForm.Live_Animals_No_of_Consignments__c;
                specialTrafficRecord.tons = newForm.Live_Animals_Tons__c;
                specialTrafficRecord.airfreight = newForm.Live_Animals_Air_Freight_Charges__c;
                specialTrafficRecord.percentage = newForm.Live_Animals_Percentage__c;
            } else {
                specialTrafficRecord.consignments = newForm.Other_Number_of_Consignments__c;
                specialTrafficRecord.tons = newForm.Other_Tons__c;
                specialTrafficRecord.airfreight = newForm.Other_Air_Freight_Charges__c;
                specialTrafficRecord.percentage = newForm.Other_Percentage__c;
            }
            specialTrafficList.add(specialTrafficRecord);
        }
    }

    public void refreshCntIFAPContacts() {
        cntIFAPContacts = [SELECT COUNT()
                             FROM AMS_Accreditation_Contact__c
                            WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND Financial_Assessment_Contact__c = true
                              AND Id != :newContact.Id];
    }

    public class specialTraffic {
        public String cargotype {get; set;}
        public Decimal consignments {get; set;}
        public Decimal tons {get; set;}
        public Decimal airfreight {get; set;}
        public Decimal percentage {get; set;}
    }

    private Map<String, String> getMapAmazonFileIdentifiers() {
        //Get File identifiers for AmzonFile records assoc. with case
        Map<String, String> mapAmazonFileIdentifiers = new Map<String, String>();
        for (AmazonFile__c amazonFile: [SELECT Size_MB__c, Name, Full_Name_Unique__c, CreatedDate, CreatedById, 
                                            CreatedBy.Name, Case__c, File_Identifier__c
                                        FROM AmazonFile__c
                                        WHERE Case__c = :newCase.Id]) {
            if (!mapAmazonFileIdentifiers.containsKey(amazonFile.File_Identifier__c))
                mapAmazonFileIdentifiers.put(amazonFile.File_Identifier__c, amazonFile.File_Identifier__c);
        }
        return mapAmazonFileIdentifiers;
    }

    public PageReference redirectToCasePage() {
        List<ISSP_FAQ2Case_CreateCaseURL__c> ISSP_CreateButtonURL_Lst = new List<ISSP_FAQ2Case_CreateCaseURL__c> ([ select Id , Topic__c , SubTopic__c , URL__c
                From ISSP_FAQ2Case_CreateCaseURL__c
                WHERE
                Topic__c = : AgentCaseType]);

        if (ISSP_CreateButtonURL_Lst != null && ISSP_CreateButtonURL_Lst.size() > 0) {
            if(ISSP_CreateButtonURL_Lst[0].Topic__c == 'VR')
                return new Pagereference(ISSP_CreateButtonURL_Lst[0].URL__c);
            else
                return new Pagereference(ISSP_CreateButtonURL_Lst[0].URL__c + '&topic=' + ISSP_CreateButtonURL_Lst[0].Topic__c + commParam);

        } else return null;
    }

    public PageReference redirectToCountryRequirementPage(){
        PageReference pg = Page.ISSP_Country_Requirements;
        pg.getParameters().put('from', 'acc');
        pg.getParameters().put('comp', 'true');
        return pg;
    }

    private void createChildCases() {
        List<String> agencySelectedBranches;

        if(newForm.Agency_Codes_Concerned__c != null)
            agencySelectedBranches = newForm.Agency_Codes_Concerned__c.split(',');

        Map<String, Account> agencies = new Map<String, Account>();
        for(Account branch : getBranchList(true)){
            agencies.put(branch.IATACode__c, branch);
        }

        if(agencies.isEmpty()) return;

        if(newForm.Scope_of_Change__c == 'HO - All Branches'){
            if(agencySelectedBranches == null) agencySelectedBranches = new List<String>();
            else agencySelectedBranches.clear();

            agencySelectedBranches.addAll(agencies.keySet());
        }

        //CB 07-03-2017 Create an OSCAR for every child case and link it to the account concerned; clone from the HO Oscar; no staging area
        List<Case> parentCase = [SELECT Id, OSCAR__c  FROM Case WHERE Id = :newCase.Id AND OSCAR__c <> null];
        if(parentCase.isEmpty()) return;

        List<AMS_OSCAR__c> hoOscars = [SELECT Id, Status__c, Account__c, Process__c, RecordTypeId, OwnerId, AMS_Online_Accreditation__c, Type_of_change__c FROM AMS_OSCAR__c WHERE Id = :parentCase.get(0).OSCAR__c];
        if(hoOscars.isEmpty()) return;

        AMS_OSCAR__c hoOscar = hoOscars[0];

        Id auxId = null;
        Map<Id, Case> mapChildCasesPerAccountConcernedId = new map<Id, Case>();
        Map<Id, AMS_OSCAR__c> mapOscarsPerAccountConcernedId = new map<Id, AMS_OSCAR__c>();

        for(String iataCode : agencySelectedBranches){
            Account accConcerned =  agencies.get(iataCode);
            if(accConcerned.Id != newCase.Account_Concerned__c && accConcerned.Id != newCase.AccountId){

                Case child = newCase.clone(false, true);

                child.Subject = Label.ISSP_AMS_NoC_Direct_Debit_Change + ' – ' + accConcerned.IATACode__c + ' – ' + accConcerned.Name;
                child.Account_Concerned__c = accConcerned.Id;
                child.ParentId = newCase.Id;
                child.Status = 'Open';
                child.Origin = 'Portal';
                child.Product_Category_ID__c = '-'; //Set Product Id so picked up by case assign to AM Regional queue

                //FM 31-10-2016 - Set IATA Country to 'All Countries' so auto-response doesn't get sent for child cases
                auxId = child.ContactId;
                child.ContactId = ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c == null? null : ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c;

                mapChildCasesPerAccountConcernedId.put(accConcerned.Id, child);

                AMS_OSCAR__c childOscar = hoOscar.clone(false, true);
                childOscar.AMS_Online_Accreditation__c = null;
                childOscar.Account__c = accConcerned.Id;

                mapOscarsPerAccountConcernedId.put(accConcerned.Id, childOscar);
            }
        }

        if(!mapChildCasesPerAccountConcernedId.isEmpty()) {
            insert mapOscarsPerAccountConcernedId.values();

            for (Id AcctConcernedId : mapOscarsPerAccountConcernedId.keyset())
                 mapChildCasesPerAccountConcernedId.get(AcctConcernedId).OSCAR__c = mapOscarsPerAccountConcernedId.get(AcctConcernedId).Id;

            insert mapChildCasesPerAccountConcernedId.values();
            //FM 31-10-2016 - Set IATA Country to the Country of the parent case (because of auto-response that was being sent for child cases)
            for(Case auxCase: mapChildCasesPerAccountConcernedId.values()) auxCase.ContactId = auxId;

            update mapChildCasesPerAccountConcernedId.values();
        }
    }

    public void setOwners(String type){
        List<AMS_Accreditation_Contact__c> lstAccreditationContact = new List<AMS_Accreditation_Contact__c>();
        Boolean notToAdd = false;
        //Get owners related to the account

        Id rtAccRoleOwnership = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

        List<String> rtDeveloperNamesAccredContact = new List<String>{'Person', 'Company', 'Previous_Owner', 'Current_Owner', 'Previous_Company_Owner', 'Current_Company_Owner'};

        Map<String, Id> rtIdsPerDevNameAccredContact = RecordTypeSingleton.getInstance().getRecordTypeObjIdMapForSpecfifiedNames('AMS_Accreditation_Contact__c', rtDeveloperNamesAccredContact);

        List<AMS_Accreditation_Contact__c> countAccreditationContact = [SELECT Id, ANG_contactFromAccount__c, RecordTypeId FROM AMS_Accreditation_Contact__c WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id];
        //NEWGEN-205
        ID lAccountConcerned = ((newForm.Scope_of_Change__c == 'Selected Branches Only' && newCase.Account_Concerned__c != null) ? newCase.Account_Concerned__c : vHQAccountId );

        if (isScopeOfChangeChanged && countAccreditationContact.size() != 0) {
            List<AMS_Accreditation_Contact__c> prevAndCurrOwnersList = new List<AMS_Accreditation_Contact__c>();
            for (AMS_Accreditation_Contact__c lCont: countAccreditationContact) {
                if (lCont.RecordTypeId == rtIdsPerDevNameAccredContact.get('Previous_Owner') || lCont.RecordTypeId == rtIdsPerDevNameAccredContact.get('Current_Owner')) {
                    prevAndCurrOwnersList.add(lCont);
                }
            }
            if (prevAndCurrOwnersList.size() > 0) {
                List<Database.DeleteResult> re = database.delete(prevAndCurrOwnersList, false);
            }
        } // END NEWGEN-205

        for(AMS_Accreditation_Contact__c amsAccCon : countAccreditationContact){ //NEWGEN-1249
            if((newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE) && amsAccCon.ANG_contactFromAccount__c == false){
                notToAdd = true;
                break;
            }
        }
        if (isScopeOfChangeChanged || countAccreditationContact.size() == 0 || ((newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || isMultiCountryNewAE) && notToAdd == true)) {
            for(AMS_Account_Role__c accRole: [SELECT Account__c, Active__c, Employee_Name__c, Employee_type__c, Id, Owner_Account__c,
                                                    Owner_Account__r.Name, Owner_Account__r.IATACode__c, Owner_Account__r.Email__c, Owner_Name__c, 
                                                    Percentage__c, Position__c, RecordTypeId, Title__c, Valid__c, Person__c, Person__r.First_Name__c,
                                                    Person__r.Lastname__c, Person__r.Email__c, Person__r.Phone__c, Contact__c, Contact__r.FirstName,
                                                    Contact__r.LastName, Contact__r.Email, Contact__r.Phone, Contact__r.OtherStreet, Contact__r.OtherCity,
                                                    Contact__r.OtherPostalCode, Contact__r.OtherCountry, Legacy_External_ID__c
                                                FROM AMS_Account_Role__c
                                                WHERE Account__c = :lAccountConcerned
                                                    AND RecordTypeId = :rtAccRoleOwnership AND Active__c = true AND Percentage__c > 0]){
                if(type.equalsIgnoreCase('NoC')){
                    lstAccreditationContact.add(ISSP_AMS_Accreditation.setAccreditationContact(accRole, newForm.Id, rtIdsPerDevNameAccredContact.get('Previous_Owner'), rtIdsPerDevNameAccredContact.get('Previous_Company_Owner')));
                    lstAccreditationContact.add(ISSP_AMS_Accreditation.setAccreditationContact(accRole, newForm.Id, rtIdsPerDevNameAccredContact.get('Current_Owner'), rtIdsPerDevNameAccredContact.get('Current_Company_Owner')));
                }

                if(type.equalsIgnoreCase('Branch'))
                    lstAccreditationContact.add(ISSP_AMS_Accreditation.setAccreditationContact(accRole, newForm.Id, rtIdsPerDevNameAccredContact.get('Person'), rtIdsPerDevNameAccredContact.get('Company')));
            }
            upsert lstAccreditationContact;
        }
        isScopeOfChangeChanged = false;
    }

    public static AMS_Accreditation_Contact__c setAccreditationContact(AMS_Account_Role__c accRole, Id newFormId, Id rtRecordTypePerson, Id rtRecordTypeCompany){
        AMS_Accreditation_Contact__c auxAccreditCont = new AMS_Accreditation_Contact__c();

        //Check if Legacy_External_ID__c exists, meaning there's no Contact, Person or Account to fetch data
        if(accRole.Legacy_External_ID__c != null){
            auxAccreditCont.AMS_Pax_Accreditation_Form__c = newFormId;
            auxAccreditCont.Legacy_External_Id__c = accRole.Legacy_External_ID__c;
            auxAccreditCont.First_name__c = '';
            auxAccreditCont.Last_name__c = accRole.Owner_Name__c != null ? accRole.Owner_Name__c : accRole.Employee_Name__c ;
            auxAccreditCont.Name = accRole.Owner_Name__c;
            auxAccreditCont.Financial_interest__c = accRole.Percentage__c;
            auxAccreditCont.Agency_owner__c = true;
            auxAccreditCont.RecordTypeId = rtRecordTypePerson;

        }else if(accRole.Contact__c != null){ //Check if owner is contact
            auxAccreditCont.AMS_Pax_Accreditation_Form__c = newFormId;
            auxAccreditCont.First_name__c = accRole.Contact__r.FirstName;
            auxAccreditCont.Last_name__c = accRole.Contact__r.LastName;
            auxAccreditCont.Name = accRole.Contact__r.FirstName + ' ' + accRole.Contact__r.LastName;
            auxAccreditCont.Financial_interest__c = accRole.Percentage__c;
            auxAccreditCont.Agency_owner__c = true;
            auxAccreditCont.RecordTypeId = rtRecordTypePerson;
            auxAccreditCont.Email__c = accRole.Contact__r.Email;
            auxAccreditCont.Phone__c = accRole.Contact__r.Phone;
            auxAccreditCont.Contact__c = accRole.Contact__c;
            auxAccreditCont.AddressStreet__c = accRole.Contact__r.OtherStreet;
            auxAccreditCont.AddressCity__c = accRole.Contact__r.OtherCity;
            auxAccreditCont.AddressPostcode__c = accRole.Contact__r.OtherPostalCode;
            auxAccreditCont.AddressCountry__c = accRole.Contact__r.OtherCountry;

        }else if(accRole.Person__c != null){//Check if owner is PERSON
            auxAccreditCont.AMS_Pax_Accreditation_Form__c = newFormId;
            auxAccreditCont.First_name__c = accRole.Person__r.First_Name__c;
            auxAccreditCont.Last_name__c = accRole.Person__r.Lastname__c;
            auxAccreditCont.Name = accRole.Person__r.First_Name__c + ' ' + accRole.Person__r.Lastname__c;
            auxAccreditCont.Financial_interest__c = accRole.Percentage__c;
            auxAccreditCont.Agency_owner__c = true;
            auxAccreditCont.RecordTypeId = rtRecordTypePerson;
            auxAccreditCont.Email__c = accRole.Person__r.Email__c;
            auxAccreditCont.Phone__c = accRole.Person__r.Phone__c;

        }else if(accRole.Owner_Account__c != null){
            auxAccreditCont.AMS_Pax_Accreditation_Form__c = newFormId;
            auxAccreditCont.First_name__c = '';
            auxAccreditCont.Last_name__c = accRole.Owner_Account__r.Name;
            auxAccreditCont.Financial_interest__c = accRole.Percentage__c;
            auxAccreditCont.IATACode__c = accRole.Owner_Account__r.IATACode__c;
            auxAccreditCont.Name = accRole.Owner_Account__r.Name;
            auxAccreditCont.Agency_owner__c = true;
            auxAccreditCont.RecordTypeId = rtRecordTypeCompany;
            auxAccreditCont.Email__c = accRole.Owner_Account__r.Email__c;
        }
        
        auxAccreditCont.ANG_contactFromAccount__c = true;
        return auxAccreditCont;
    }

    private String translateAccreditationModel(String accreditationModel) {
        if(accreditationModel == AMS_Utils.ACCREDITATIONMODEL_CASH) {
            return Label.ANG_ISSP_ProductStandardAccreditationWithCash;
        } else if(accreditationModel == AMS_Utils.ACCREDITATIONMODEL_CASHLESS) {
            return Label.ANG_ISSP_ProductStandardAccreditationWithNoCash;
        } else if (accreditationModel == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY) {
            return Label.ANG_ISSP_ProductStandardAccreditationWithMultiCountry;
        } else {
            return accreditationModel;
        }
    }

    private void createHoAdminNotifications() {
        // get HO portal admin contact
        List<Contact> adminContactsHO = [SELECT Id, Email, AccountId, Account.IATACode__c, User_Portal_Status__c 
                                        FROM Contact 
                                        WHERE AccountId = :con.Account.Top_Parent__c 
                                            AND IsEmailBounced = false AND User_Portal_Status__c = 'Approved Admin'];

        if (!adminContactsHO.isEmpty()) {
            try {
                list<Notification__c> lstNotificationsToCreate = new list<Notification__c>();

                for (Contact loopCon : adminContactsHO) {
                    Notification__c notification = new Notification__c();
                    notification.Contact__c = loopCon.Id;
                    notification.Type__c= 'Information';
                    notification.Notificatin_color__c = '#007FFF';
                    notification.Alert_Contact_By_Email__c = true;
                    notification.Expiry_date__c = Datetime.now().addDays(14);
                    notification.Subject__c = 'New ' + (isBankAccountChange ? 'Change of Bank Account Details' : 'Notice of Change') + ' from branch ' + loopCon.Account.IATACode__c;
                    notification.Message__c = '<p>A new ' + (isBankAccountChange ? 'Change of Bank Account Details' : 'Notice of Change') + ' case has been submitted from one of your branch accounts, with IATA Code ' + loopCon.Account.IATACode__c + '.<br/>';
                    notification.Message__c+= 'Case number: <a href="/ISSP_Case?caseId=' + newCase.Id + '">' + newCase.CaseNumber + '</a></p>';

                    lstNotificationsToCreate.add(notification);
                }

                insert lstNotificationsToCreate;

            } catch (Exception e) { System.debug('Add notification ERROR: ' + e.getmessage()); }
        }
    }
    
    /**
        Return true if this forms is considered Partnership
        There are some differences in the page and the final PDF whe the form is partnership
        Those differences apply to both New Application and Notice Of Change
    **/
    public Boolean getIsPartnership() {
        return this.sectorValue=='Travel_Agent' && (this.hqAccount.Ownership=='Partnership' || this.newForm.ISSP_AMS_Legal_Status__c=='Partnership');
    }

    public Pagereference runOptInOut() {
        newCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
        newCase.Status = AMS_Utils.OPEN;
        newCase.CaseArea__c = AMS_Utils.CASE_AREA_AGENCY_RISK_MANAGEMENT;
        newCase.Reason1__c = AMS_Utils.CASE_REASON_OPT_OUT;
        newCase.Origin = AMS_Utils.CASE_ORIGIN_PORTAL;
        newCase.Visible_on_ISS_Portal__c = true;
        newCase.BSPCountry__c =  isocountry.Case_BSP_Country__c ;
        newCase.Country_concerned_by_the_query__c = isocountry.Name;
        newCase.Region__c = isocountry.Region__c;
        newCase.Type_of_customer__c = AMS_Utils.CASE_TYPE_OF_CUSTOMER_IATA_TRAVEL_AGENT;
        newCase.Account_Concerned__c = con.AccountId;
        newCase.Product_Category_ID__c = '_';

        newCase.Subject = getCaseReason(AMS_Utils.CASE_REASON_OPT_OUT, hqAccount.ANG_Accreditation_Model__c) + ' - ' + hqAccount.ANG_Accreditation_Model__c + ' - ' + hqAccount.name;

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        newCase.setOptions(dmo);

        upsert newCase;

        saveAMSForm();

        ISSP_AMS_Accreditation.OSCARIntegration(newCase.Account_Concerned__c, newForm.Id, AMS_Utils.NGOPTINOUT, newCase.Id);

        return null;
    }

    private List<AMS_Pax_Accreditation_Form__c> fetchMultiCountryApplicationForms() {
        List<AMS_Pax_Accreditation_Form__c> mCountryApplicationForms = [SELECT Id, Name, Status__c, HO_Account__c, Branch_Office_Country__r.Name, 
                                                                            SAAM_Case__r.Subject, SAAM_Case__r.Id
                                                                        FROM AMS_Pax_Accreditation_Form__c
                                                                        WHERE SAAM_Case__c = :newCase.Id];

        if (!mCountryApplicationForms.isEmpty())
            mcApplicationFormsFound = true;

        return mCountryApplicationForms;
    }

    public void deleteMCForm() {
        List<AMS_Pax_Accreditation_Form__c> formToDelete = [SELECT Id FROM AMS_Pax_Accreditation_Form__c WHERE Id = :mcFormIdToDelete LIMIT 1];
        if (!formToDelete.isEmpty()) {
            deleteFormsFuture(new Set<Id>{formToDelete[0].Id});

            Map<Id, AMS_Pax_Accreditation_Form__c> mCApplicationFormMap = new Map<Id, AMS_Pax_Accreditation_Form__c>(multiCountryApplicationForms);
            mCApplicationFormMap.remove(formToDelete[0].Id);

            multiCountryApplicationForms = new List<AMS_Pax_Accreditation_Form__c>(mCApplicationFormMap.values());
        }
    }

    @future
    private static void deleteFormsFuture(Set<Id> formsToDelete) {
        List<AMS_Pax_Accreditation_Form__c> formListToDelete = [SELECT Id FROM AMS_Pax_Accreditation_Form__c WHERE Id IN :formsToDelete];
        if (!formListToDelete.isEmpty()) delete formListToDelete;
    }
}