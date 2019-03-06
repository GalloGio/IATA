public without sharing class ISSP_AMS_PASS_Accreditation {
    private static String SAAM_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('SAAM').RecordTypeId;
    private static String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;
    private static String RECORD_TYPE_ID = SAAM_RECORD_TYPE_ID;
    
    //public static String FILE_ID_FOR_PARTNERSHIP  {get{ return 'Signed Application Form';}}
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
    private Boolean isScopeOfChangeChanged = false;
    public String hqCountryISOCode;
    private Id vHQAccountId;
    public List<SelectOption> agencyCodesConcerned {get; set;}
    private Id vAccountConcernedId;
    public String amsCountryLabel {get; set;}
    //public String memberairlineid {get; set;}
    public String amsAllLangCountryLabel {get; set;}
    public String amsContactCountry {get; set;}
    public String amsOfficeType {get; set;}
    public String amsAgentType {get; set;}
    public String agentCaseType {get; set;} //Used to set TIDS, Sales Agent (SA) from links on ISSP_AMSCase
    public String amsLocationType {get; set;}
    public String amsLocationTypeLabelHq {get; set;}
    public String amsLocationTypeLabel {get; set;}
    //public String noCLocationType {get; set;}
    public boolean isGSARequired;
    public String applyLanguage {get; set;}
    public String displayLanguage {get; set;}
    public string sector {get; set;}
    public string sectorDisplay {get; set;}
    public string sectorValue {get; set;}
    public string category {get; set;}
    public string baseUrl {get; set;}
    public string step1GoToNumber {get; set;}

    public String vatNumber {get; set;}
    public string stepNumber {get; set;}
    public string editContactId {get; set;}
    //public string editSalesId {get; set;}
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
    public string lblPASSTitle {get; set;}
    public string lblImporAgentTitle {get; set;}
    public string lblCourierTitle {get; set;}

    public boolean isNewCase {get; set;}
    public boolean isEUcountry {get; set;}
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

    /*public List<regionSelection> cargoRegionList {get; set;}
    public List<regionSelection> cargoRegionListWithValue {get; set;}
    public List<specialTraffic> specialTrafficList {get; set;}*/

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
    public String agencyCodesConcernedForPDF {get; set;}

    public List<AMS_Accreditation_Contact__c> checkAllOwners {get; set;}

    public String accredidationType {get; set;}
    public Integer cntIFAPContacts {get; set;}

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

    public String pageName{get; set;}
    public string agencyCategory {get; set;}
    public String termsAndConditionsText{get;set;}
    public boolean governmentOwnedPASS{get;set;}
    public String legalStatusValue{get;set;}

    public ISSP_AMS_PASS_Accreditation() {
        system.debug('kerensen ISSP_AMS_Accreditation ctor');
        isNewCase = true;
        isStep1 = false;
        isStep2 = false;
        isStep3 = false;
        isStep4 = false;
        isStep5 = false;
        isFinalStep = false;
        isHOAccredited = false;
        isUserAccAccredited = false;
        isNoticeOfChange = false;
        isBankAccountChange = false;
        isEligableForChange = false;
        isTerminatedAgent = false;
        isNewHOforAccredAgent = false;
        bIsAdmin = false;
        stepNumber = '';
        cntAgencyLookups = 0;
        cntIFAPContacts = 0;
        isAuthorizedSignature = false;
        governmentOwnedPASS=false;
        legalStatusValue='';

        pageName='/apex/ISSP_AMS_Upload?accType=PASS';
        agencyCategory='';

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

        if (isocountry != null) {
            isEUcountry = isocountry.EU_Country__c;

            amsAllLangCountryLabel = getAmsAllLangCountryLabel(isocountry, UserInfo.getLanguage());
        }

        if(con.Authorized_Signatory__c == true)
            isAuthorizedSignature = true;

        system.debug('issp ams con ' + con);

        sector = con.Account.Sector__c;
        category = con.Account.Category__c;

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

        if(hqAccount.Status__c == 'Terminated')
            isTerminatedAgent = true;

        hqCountryISOCode = hqAccount.IATA_ISO_Country__r.ISO_Code__c;
        newForm.HO_Account__c = vHQAccountId;

        System.DeBUG('vHQAccountId: ' + vHQAccountId);
        SYSTEM.DEBUG('HQ Ctry Code: ' + hqCountryISOCode);
        //Need to translate sector for display

        sector = AMS_Utils.SECTOR_PASS;
        sectorValue = AMS_Utils.sectorValuePass;
        sectorDisplay = Label.ISSP_PASS_Agent;
        if(isHOAccredited){
            amsOfficeType = 'Branch';
            amsLocationType=AMS_Utils.TYPE_PAX_PASS_BRANCH;
        }else{
            amsOfficeType = AMS_Utils.HO;
            amsLocationType=AMS_Utils.TYPE_PAX_PASS_HO;
        }


        fetchCountryRequirements();

        System.DeBUG('SFSF con.Account.IATA_ISO_Country__c: ' + con.Account.IATA_ISO_Country__c);
        System.DeBUG('SFSF con.Account.IATA_ISO_Country__r.ISO_Code__c: ' + con.Account.IATA_ISO_Country__r.ISO_Code__c);

        applyLanguageList = new List<SelectOption>();
        applyLanguageList.add(new SelectOption('en_US', 'English'));
        applyLanguageList.add(new SelectOption('fr', 'Français'));
        applyLanguageList.add(new SelectOption('es', 'Español'));

        applyLanguage = UserInfo.getLanguage();
        displayLanguage = UserInfo.getLanguage();

        if (applyLanguage != 'en_US' && applyLanguage != 'es' && applyLanguage != 'fr')
            applyLanguage = 'en_US';

        //Labels set in controller remain in portal's user language

        lblStepA=Label.ISSP_AMS_Step1_ProgressBar_PASS;
        lblStepB = Label.ISSP_AMS_Step2_ProgressBar_PASS;
        lblStepC = Label.ISSP_AMS_Step3_ProgressBar_PASS;
        lblStepD = Label.ISSP_AMS_Step4_ProgressBar_PASS;
        lblStepE = Label.ISSP_AMS_Step5_ProgressBar;

        lblNoCStepA = Label.ISSP_AMS_NoC_StepA;
        lblNoCStepC = Label.ISSP_AMS_NoC_StepC;
        lblNoCStepD = Label.ISSP_AMS_NOC_StepD_ProgressBar;

        lblNocRequest = Label.ISSP_AMS_NoC_Request_for_Change;
        lblPAXTitle = Label.ISSP_AMS_StepsAll_Travel_Title;

        lblCargoTitle = isocountry.AMS_Accreditation_New_Labels__c? Label.ISSP_AMS_StepsAll_Cargo_Title_New: Label.ISSP_AMS_StepsAll_Cargo_Title;

        lblPASSTitle = Label.ISSP_AMS_StepsAll_PASS_Participant_Title;
        lblImporAgentTitle = Label.ISSP_AMS_StepsAll_Import_Agent_Title;
        lblCourierTitle = Label.ISSP_AMS_StepsAll_Courier_Title;

        termsAndConditionsText='   '+Label.ISSP_AMS_TC_PASS;

        if (ApexPages.currentPage().getParameters().containsKey('step'))
            stepNumber = ApexPages.currentPage().getParameters().get('step');

        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=Application_Summary.pdf');

        newForm.Scope_of_Change__c = isHOcontact ? 'HO Only' : 'Selected Branches Only'; //Set default
        newForm.Is_change_legal_name__c = true;
        newForm.Is_change_location__c = true;
        newForm.Is_change_ownership_or_shareholding__c = true;

        //Verify to which step the user should go
        //and retrieve information linked to the step
        if (stepNumber == '1' || stepNumber == '') {
            isStep2=true;
            isStep1=true;
        }

        newForm.Scope_of_Change__c = isHOcontact ? 'HO Only' : 'Selected Branches Only'; //Set default

        if (ApexPages.currentPage().getParameters().containsKey('caseId')) {

            //Retrieve information linked to the case Id
            vSAAMCaseId = ApexPages.currentPage().getParameters().get('caseId');
            system.debug('URL vSAAMCaseId: ' + vSAAMCaseId);
            fetchCase(vSAAMCaseId);

            if (newCase != null) {
                system.debug('newCase.IFAP_Country_ISO__c ' + newCase.IFAP_Country_ISO__c);
                if (newCase.IFAP_Country_ISO__c == null) {
                    //If case created internally by IATA, for user, then set country from the contact's Account
                    newCase.IFAP_Country_ISO__c = con.Account.IATA_ISO_Country__r.ISO_Code__c;
                }

                isocountry = fetchISOCountry(newCase.IFAP_Country_ISO__c);

                amsAllLangCountryLabel = getAmsAllLangCountryLabel(isocountry, UserInfo.getLanguage());

                if(newCase.Case_Language__c == null || newCase.Case_Language__c == 'English')
                    newCase.Case_Language__c = 'en_US';

                applyLanguage = newCase.Case_Language__c;
                displayLanguage = newCase.Case_Language__c;

                if (applyLanguage == 'en_US') {
                    amsCountryLabel = isocountry.Case_BSP_Country__c;
                } else if (applyLanguage == 'fr') {
                    amsCountryLabel = isocountry.IATA_Country_FR__c;
                } else {
                    amsCountryLabel = isocountry.IATA_Country_SP__c;
                }

                system.debug('newCase.Reason1__c ' + newCase.Reason1__c);
                if ( newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || newCase.Reason1__c == AMS_Utils.CASE_REASON_HE_STANDARD || newCase.Reason1__c == AMS_Utils.CASE_REASON_HE_LITE) {
                    amsOfficeType = AMS_Utils.HO; //Branches Abroad have same country requirements as HO in that country
                } else if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP || newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD || newCase.Reason1__c == AMS_UTILS.CASE_REASON_NEW_BR) {
                    amsOfficeType = 'Branch';
                }

                if(amsOfficeType == AMS_Utils.HO && isHOAccredited && newCase.Reason1__c != AMS_Utils.CASE_REASON_BR_ABROAD)
                    isNewHOforAccredAgent = true; //Accrediedt Agent applying for HO of different Program e.g. Accred PAX applyiong for CGO HO

                system.debug('amsOfficeType ' + amsOfficeType);

                fetchAMSProcessForm();

                newForm.HO_Account__c = vHQAccountId;

                //Need to get Id for Account for country of application concerned
                if (newCase.Account_Concerned__c==null) {
                    vAccountConcernedId = newForm.HO_Account__c;
                } else {
                    vAccountConcernedId = newCase.Account_Concerned__c;
                }

                newForm.Is_change_legal_name__c = true;
                newForm.Is_change_location__c = true;
                newForm.Is_change_ownership_or_shareholding__c = true;

                /*if (newForm != null && newForm.Operation_Type__c != null) {
                    newForm.HO_Account__c = vHQAccountId;
                    sectorValue = newForm.Operation_Type__c;
                    amsLocationType = newCase.Reason1__c + ' - ' + newForm.Agent_Type__c;
                }*/

                SYSTEM.DEBUG('sectorValue init: ' + sectorValue);

                if (sectorValue != null) {
                    sector = sectorValue.replace('_', ' ');
                    sectorDisplay = Label.ISSP_PASS_Agent;
                }

                fetchCountryRequirements();

                if (stepNumber == '1' || stepNumber == '' ) {
                    isStep1=true;
                    isStep2=true;
                    setOwnerAndRoleLabels();
                    setContextualHelp(userInfo.getLanguage());
                } else if (stepNumber == '2') {
                    isStep1=true;
                    isStep2=true;
                } else if (stepNumber == '3') {
                    isStep3 = true;
                    System.Debug('SAAM Case Id: ' + newCase.Id);

                    setOwnerAndRoleLabels();

                    newForm.Submitted_to_IATA__c = FALSE;

                    //Retrieve Cargo Agent if user has entered IATA  Code

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

                    setContextualHelp(userInfo.getLanguage());

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
                    if ( newForm.Validation_ERRORS__c ) {
                        validateAttachedFiles();
                        isValError = true;
                    }
                    isStep4 = true;
                } else if (stepNumber == '5') {
                    fetchAMSProcessForm();
                    newForm.Submitted_to_IATA__c = FALSE;
                    if ( newForm.Validation_ERRORS__c ) {
                        validateAttachedFiles();
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
        } else {
            // no case Id

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

        system.debug('sector value ' + sectorValue + ' defaultSectorValue ' + defaultSectorValue);

        selectPageName();

        this.helper = new ANG_ProductComparisonHelper('B');
    }

    public void updateAmsCountry() {
        isocountry = fetchISOCountry(con.Account.IATA_ISO_Country__r.ISO_Code__c);

        if (isocountry != null) {
            amsAllLangCountryLabel = getAmsAllLangCountryLabel(isocountry, UserInfo.getLanguage());
        }
    }

    private List<Account> getBranchList(Boolean fullHierarchy) {
        List<String> selectedBranchCodes;
        selectedBranchCodes = new List<String>();

         if(newForm.Agency_Codes_Concerned__c != null && !fullHierarchy) //Exclude already selected branches
            selectedBranchCodes = newForm.Agency_Codes_Concerned__c.split(',');

        if (isHOcontact) {
        return [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry, Legal_name__c, ANG_Accreditation_Model__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c
                                      FROM Account
                                      WHERE Top_Parent__c = :vHQAccountId AND IATACode__c != null AND RecordType.DeveloperName IN ('IATA_Agency') AND (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending')) AND (IATACode__c NOT IN : selectedBranchCodes)
                                              ORDER BY Name, IATACode__c
                                     ];
        } else { // BR contacts can only apply for changes to their own BR and SAs of their BR
            return [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry, Legal_name__c, ANG_Accreditation_Model__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c
                        FROM Account
                        WHERE Top_Parent__c = :vHQAccountId AND IATACode__c != null AND RecordType.DeveloperName IN ('IATA_Agency') AND (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending')) AND (IATACode__c NOT IN : selectedBranchCodes)
                            AND (Id = :con.AccountId OR ParentId =: con.AccountId )
                        ORDER BY Name, IATACode__c
                    ];
        }
    }

    public List<SelectOption> getBranchAccounts() {

        System.DeBUG('vHQAccountId for BR Accounts: ' + vHQAccountId);

        List<SelectOption> options = new List<SelectOption>();

        List <Account> accountList = getBranchList(false);

        SYSTEM.DEBUG('ALL Branch Size: ' + accountList.size());

        for (Account thisAccount : accountList) {
            String theLabel;
            theLabel = thisAccount.IATACode__c + ' - ' + (!getIsAccreditationModelNotNullOrLegacy() ? thisAccount.Location_Type__c : thisAccount.Name) + ' (' + thisAccount.BillingCity + (thisAccount.BillingState!= null ? ' ' + thisAccount.BillingState : '') + ')';

            options.add(new SelectOption(thisAccount.IATACode__c, theLabel));
        }
        return options;
    }

    public Boolean getIsAccreditationModelNotNullOrLegacy() {
        return (String.isNotEmpty(con.Account.ANG_Accreditation_Model__c)  && con.Account.ANG_Accreditation_Model__c != AMS_UTILS.ACCREDITATIONMODEL_LEGACY);
    }


    public Pagereference cancel() {
        system.debug('in cancel');
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if (retURL == null) {
            return new Pagereference('/ISSP_Homepage?mid=M0S1' +commParam);
        } else {
            return new Pagereference(retURL);
        }
    }

    private void selectPageName() {
        amsAgentType = newForm.Agent_Type__c;
        if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_NEW_BR){
            includedPageName = 'ISSP_AMS_PASS_Branch_Form';
            includedSummaryPage = 'ISSP_AMS_PASS_BR_ReadOnly';
        }else{
            includedPageName = 'ISSP_AMS_PASS_Form';
            includedSummaryPage = 'ISSP_AMS_PASS_HO_ReadOnly';
        }
    }

    /*** AMSU-37 Start ***/
    private List<String> hasPendingHOAccreditations(Case cse) {
        List<String> res = new List<String>();
        system.debug('hqAccount: ' + hqAccount);
        system.debug('cse: ' + cse);
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

        system.debug('Salesforce newForm.ANG_AE_SameLegal__c: ' + newForm.ANG_AE_SameLegal__c);
        system.debug('Salesforce newForm.AE_separate_Legal_Entity__c ' + newForm.AE_separate_Legal_Entity__c);
        system.debug('amsLocationType: ' + amsLocationType);

        if (amsLocationType == null && !isNoticeOfChange) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_Empty_Location_Type));
            return null;
        }

        //Defining default values for the case
        //create case with RT SAAM
        String agentType;

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

        if(ISSP_Utilities.isCNS()){ newCase.CNSCase__c=true;}

        agentType = amsLocationType.substring(amsLocationType.indexOf('-') + 1).trim();

        newCase.Reason1__c = amsLocationType.left(amsLocationType.indexOf('-')).trim();

        if (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD && newForm.AE_separate_Legal_Entity__c == null) {
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

        newCase.Description = Label.ISSP_Email_Draft_Process1 + ' ' + getApplicationTypeLabel(amsLocationType)+ '.';
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
        //newCase.Country_concerned_by_the_query__c = isocountry.Case_BSP_Country__c ;
        newCase.Country_concerned_by_the_query__c = isocountry.Name;

        system.debug('Salesforce sectorValue-->' + sectorValue);

        newCase.Type_of_customer__c = con.Account.Category__c;

        if(amsLocationType.contains('Standard') || amsLocationType.contains('Associate')){
            newCase.Subject = getCaseReason(newCase.Reason1__c, hqAccount.ANG_Accreditation_Model__c) + ' - ' + newCase.Country_concerned_by_the_query__c;
        }
        else{
            newCase.Subject = getCaseReason(newCase.Reason1__c, hqAccount.ANG_Accreditation_Model__c) + ' - ' + getAgentTypeLabel(agentType) + ' - ' + newCase.Country_concerned_by_the_query__c;
        }

        try {
            String newIsoCountry = newCase.IFAP_Country_ISO__c;

            /*** AMSU-37 Start ***/
            system.debug('newCase: ' + newCase);
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
                //newCase.Country_concerned_by_the_query__c = isocountry.Case_BSP_Country__c ;
                newCase.Country_concerned_by_the_query__c = isocountry.Name;
                newCase.Description = Label.ISSP_Email_Draft_Process1 + ' ' + getApplicationTypeLabel(amsLocationType)+'.';

                if(amsLocationType.contains('Standard') || amsLocationType.contains('Associate')){
                    newCase.Subject = getCaseReason(newCase.Reason1__c, hqAccount.ANG_Accreditation_Model__c) + ' - ' + newCase.Country_concerned_by_the_query__c;
                }else{
                    newCase.Subject = getCaseReason(newCase.Reason1__c, hqAccount.ANG_Accreditation_Model__c) + ' - ' + getAgentTypeLabel(agentType) + ' - ' + newCase.Country_concerned_by_the_query__c;
                }
                if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD) //NEWGEN-1249
                    upsert newform;
                //upsert newCase;
                fetchAMSProcessForm();

            }
            // Creation of first draft case (either HO or BR)
            upsert newCase;

            if (isNewCase) {

                //NEWGEN-1249 checking if the account will use the same legal entity. This will be use to see if the user changes their mind in the middle of the proccess
                if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD) newForm.ANG_AE_SameLegal__c = newForm.AE_separate_Legal_Entity__c;

                newForm.Branch_Office_Country__c = isocountry.ID;

                if(newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD ||
                    newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD  || newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_BR) {
                    newForm.ISSP_AMS_Legal_Status__c = mapCompanyTypes(hqAccount.Company_Type__c);
                    newForm.Remittance_frequency__c = hqAccount.Remittance_frequency__c;

                    SYSTEM.DEBUG('Set BR Abroad Legal Name: ' + hqAccount.Name + ' newForm.AE_separate_Legal_Entity__c ' + newForm.AE_separate_Legal_Entity__c + ' hqAccount.Name ' + hqAccount.Name);
                    if(newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || newForm.AE_separate_Legal_Entity__c == 'No'){  //Legal name is editable for BR Abroad, so set default value
                        newForm.Account_Name__c = hqAccount.Name;
                    }

                    saveAMSForm();

                    if(newForm.AE_separate_Legal_Entity__c == 'No' || newForm.AE_separate_Legal_Entity__c == null) // NEWGEN-1249 only with same legal entity have the owners from parent
                        setOwners('Branch');
                } else { //Insert current user as default contatc for HO applications
                    saveAMSForm();
                    insertDefaultContact();
                }
            } else {
                /*system.debug('aqui newCase.Reason1__c ' + newCase.Reason1__c + ' newForm.AE_separate_Legal_Entity__c ' + newForm.AE_separate_Legal_Entity__c + ' newForm.ANG_AE_SameLegal__c ' + newForm.ANG_AE_SameLegal__c);
                if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD && newForm.AE_separate_Legal_Entity__c == 'No'){ //NEWGEN-1249
                    resetCreatedOwnership();

                    newForm.ISSP_AMS_Legal_Status__c = mapCompanyTypes(hqAccount.Company_Type__c);
                    newForm.Account_Name__c = hqAccount.Name;
                    newForm.Trade_Name__c = hqAccount.TradeName__c;

                    if(checkAllOwners != null || !checkAllOwners.isEmpty())
                        delete checkAllOwners;


                    setOwners('Branch');
                }
                else if (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD && newForm.AE_separate_Legal_Entity__c == 'Yes'){
                    resetOwnership();

                    if(checkAllOwners != null || !checkAllOwners.isEmpty())
                        delete checkAllOwners;
                }*/

                saveAMSForm();
            }

        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }

        selectPageName();

        if (step1GoToNumber == '5') {
            return goToStep5();
        } else if (step1GoToNumber == '4') {
            return goToStep4();
        } else if (step1GoToNumber == '3') {
            return goToStep3();
        } else {
            return goToStep3();
        }
    }

    public void saveAMSForm() {
        system.debug('Salesforce saveAMSForm sectorValue: ' + sectorValue);
        system.debug('Salesforce saveAMSForm newCase.Reason1__c: ' + newCase.Reason1__c);

        //system.debug('Salesforce saveAMSForm sectorValue: ' + sectorValue);

        newForm.Operation_Type__c = sectorValue;
        if (!isNoticeOfChange) {
            if (amsLocationType != null) {
                newForm.Agent_Type__c = 'IATA '+AMS_Utils.categoryPass;
            }
        }

        if (isEUcountry) { ///Add 2-letter ISO Code to VAT Number of EU countries
            if(newForm.ISSP_AMS_VAT_number_input__c != null) {
                newForm.ISSP_AMS_VAT_number__c = newCase.IFAP_Country_ISO__c + newForm.ISSP_AMS_VAT_number_input__c;
            }
        } else {
            newForm.ISSP_AMS_VAT_number__c = newForm.ISSP_AMS_VAT_number_input__c;
        }

        if (cargoAgentAccount != null) {
            system.debug('cargoAgentAccount.Id: ' + cargoAgentAccount.Id);
            newForm.Cargo_Agent_Account__c = cargoAgentAccount.Id;
        }

        if(IATANAgentAccount != null)
            newForm.IATAN_Agent_Account__c = IATANAgentAccount.id;

        //NEWGEN - 604 START
        // Only validate Agency Address details when user is on STEP C (StepNumber==3)
        //
        if(hqAccount != null && (newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH || newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_CASH) && (!isTerminatedAgent && !isHOAccredited) && stepNumber == '3'){
            if (!validateCharactersInAgencyWindow()) {
                accountUpdated = false;
                return;
            }
            upsert hqAccount;
        }
        //NEWGEN - 604 END

        try {

            if (String.isBlank(String.ValueOf(newForm.SAAM_Case__c))) {
                newForm.SAAM_Case__c = newCase.Id;
            }

            upsert newForm;
            if (!Test.IsRunningTest()) fetchAMSProcessForm();

        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
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
        system.debug('newSFDCAccount ' + newSFDCAccount + ' hqAccount.Name ' + hqAccount.Name);
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
        SFDCAccount.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Standard Account').RecordTypeId;
        if (!test.isRunningTest()) {
            SFDCAccount.OwnerId = ISSP_Constant.newAccountOwnerId;
        } else if (test.isRunningTest()) {
            SFDCAccount.OwnerId = userInfo.getUserId();
        }

        SFDCAccount.Location_Class__c = getLocationClass();

        if(getIsAccreditationModelNotNullOrLegacy()){
            SFDCAccount.Location_Type__c = AMS_Utils.AE;
        }else{
            SFDCAccount.Location_Type__c = AMS_Utils.BR;
        }

        SFDCAccount.Reason_for_creation__c = 'Created by customer';

        /*if(newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD) {
            SFDCAccount.Name = newForm.Account_Name__c;
            SFDCAccount.TradeName__c = newForm.Trade_Name__c;
        } else {*/
            SFDCAccount.Name = hqAccount.Name;
        //}

        SFDCAccount.ParentId = vHQAccountId;
        SFDCAccount.Sector__c = hqAccount.Sector__c;

        SFDCAccount.Category__c = AMS_Utils.categoryPass;

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

    /*private void createHOAccount(Account parentHO) {
         Account newHOAccount = new Account(Name = newForm.Account_Name__c);

        newHOAccount.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Standard Account').RecordTypeId;

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
        //newHOAccount.Mobile__c = newForm.Mobile__c;
        //newHOAccount.MobileNational__c = newForm.MobileNational__c;
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


        newHOAccount.Location_Type__c = AMS_Utils.HO;

        newHOAccount.Location_Class__c = getLocationClass();

        if(sectorValue.StartsWith('Travel_Agent')) {
            newHOAccount.Sector__c = AMS_Utils.SECTOR_PASSENGER;
        } else {
            newHOAccount.Sector__c = AMS_Utils.SECTOR_CARGO;
        }

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

        SYSTEM.DEBUG('AccountId for new HO: ' + vHQAccountId);
        SYSTEM.DEBUG('Case AccountId on HO creation: ' + newCase.AccountId);
    }*/


    private String getLocationClass() {
        String locationClass = 'L';
        return locationClass;
    }


    public void createAgencyContact() {
        system.debug('I enter createAgencyContact');
        system.debug('createAgencyContact contactType: ' + contactType);
        Id rtAccreditContPreviousOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Previous Owner').getRecordTypeId();

        integer cntOwners;
        integer cntEmailContacts;
        contactSaved = true;
        ApexPages.Message myMsg;

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
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Must fill valid until');
                    ApexPages.addMessage(myMsg);
                    contactSaved = false;
                    return;
                }
            }
        }


        if (contactToUpsert.AMS_Pax_Accreditation_Form__c == null)
            contactToUpsert.AMS_Pax_Accreditation_Form__c = newForm.Id;

        cntOwners = [SELECT COUNT() FROM AMS_Accreditation_Contact__c
                     WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND Agency_owner__c = true AND Id != :newContact.Id And RecordType.Name = :contactType];


        refreshCntIFAPContacts();

        cntEmailContacts = [SELECT COUNT() FROM AMS_Accreditation_Contact__c
                            WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND Email__c != :null  AND Email__c = :newContact.Email__c AND Id != :newContact.Id
                           AND RecordTypeId != :rtAccreditContPreviousOwner
                           ];

        if (contactType == 'Company' || contactType == 'Current Company Owner') {
            newContact.First_name__c = '';
            newContact.Last_name__c = newContact.Name;
            newContact.Agency_owner__c = true;
            if (companyModalNameOfEmployer == '' && iatacode != '' && iatacode != null) {
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Invalid_IATA_Code);
                ApexPages.addMessage(myMsg);
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
            system.debug('newContact.Name ' + newContact.Name);

            if (!validateCharactersInPersonWindow()) {
                contactSaved = false;
                return;
            }
        } else if (contactType == 'Trained Staff') {
            trainedStaffContact.Name = trainedStaffContact.First_name__c + ' ' + trainedStaffContact.Last_name__c;
        }

        if (Test.IsRunningTest() == false) {
            contactToUpsert.RecordTypeId = Schema.SObjectType.AMS_Accreditation_Contact__c.RecordTypeInfosByName.get(contactType).RecordTypeId;
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

            /*if ((includedPageName == 'ISSP_AMS_Cargo_Form' || includedPageName == 'ISSP_AMS_Pax_Form' || includedPageName == 'ISSP_ANG_PAX_HE') && newContact.Agency_owner__c == true && amsOfficeType == AMS_Utils.HO && (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_STANDARD || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_LITE) && contactType != 'Company') { //Exclude Owners for Branches Abroad
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
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Sole_Owner_Exists);
                    ApexPages.addMessage(myMsg);
                    contactSaved = false;
                }

                if (!contactSaved)
                    return;
            }*/

            if (isNoticeOfChange) {
                if (newContact.AddressCountry__c == null && contactType == 'Current Owner') {
                    newContact.AddressCountry__c.addError(Label.ISSP_YouMustEnter);
                    contactSaved = false;
                }

                if (contactType == 'Current Owner' && (newContact.Agency_owner__c == true || newContact.Agency_role__c == true)  && (newContact.Time_devoted_to_Agency_business__c < 0 || newContact.Time_devoted_to_Agency_business__c == null))  {
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Time_Devoted);
                    ApexPages.addMessage(myMsg);
                    contactSaved = false;
                    return;
                }
            }

            if (contactType == 'Current Owner' && newContact.Agency_owner__c == false && newContact.Agency_role__c == false) {
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_NoC_Type_Of_Person);
                ApexPages.addMessage(myMsg);
                contactSaved = false;
                return;
            }

            //Only one owner allowed for Sole Proprietorships
                if (cntOwners >= 1 && isNoticeOfChange && newContact.Agency_owner__c == true && legalStatusAfterChange == 'sole proprietorship') {
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Sole_Owner_Exists);
                    ApexPages.addMessage(myMsg);
                    contactSaved = false;
                }

            if (newContact.Agency_owner__c == true && (amsOfficeType == AMS_Utils.HO || contactType == 'Current Owner') && (newContact.Financial_interest__c <= 0 || newContact.Financial_interest__c == null))  {
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_FIN_Interest);
                ApexPages.addMessage(myMsg);
                contactSaved = false;
                return;
            }

            if (sector == AMS_Utils.SECTOR_PASSENGER && !isNoticeOfChange) {
                if (
                    (((newContact.Agency_owner__c == true || newContact.Agency_role__c == true) && amsOfficeType == AMS_Utils.HO && (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_STANDARD || newCase.Reason1__c == AMS_UTILS.CASE_REASON_HE_LITE) && contactType != 'Company') || (newContact.Agency_owner__c == false && newContact.Agency_role__c == true && (amsOfficeType == 'Branch' || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD)))  && newContact.Agencies_prev_worked_for__c == null
                    ) {
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Prev_Employ);
                    ApexPages.addMessage(myMsg);
                    contactSaved = false;
                    return;
                }
            }

            //Only Max of 3 IFAP Contacts allowed
            if (cntIFAPContacts >= MAX_IFAP_Contacts && newContact.Financial_Assessment_Contact__c == true) {
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Max_FinContacts1 + ' ' + MAX_IFAP_CONTACTS + ' ' + Label.ISSP_AMS_Step3_ErrMsg_Max_FinContacts2);
                ApexPages.addMessage(myMsg);
                contactSaved = false;
            }

            if (cntEmailContacts > 0) {
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_Unique_Email);
                ApexPages.addMessage(myMsg);
                contactSaved = false;
            }

            if (!contactSaved) {
                return;
            }

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

                system.debug('in 7' + contactSaved);

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
            system.debug('in 9' + contactSaved);
            contactSaved = false;
            ApexPages.addMessages(ex);
        }
        iatacode = '';
    }

    public Pagereference securityCheck() {
        if(con.Account.Sector__c != AMS_Utils.SECTOR_PASS) {
            return new Pagereference('/ISSP_Homepage?mid=M0S1' + commParam);
        }

        if (newCase.Id != null && newCase.Status != 'Draft' && newCase.Status != 'Open - EDMC' && !createListOfClosedStatuses().contains(newCase.Status) && !isFinalStep) {
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

    public void editAgencyContact() {
        System.debug('editContactId: ' + editContactId);
        newContact = new AMS_Accreditation_Contact__c();

        newContact = [SELECT Id, AMS_Pax_Accreditation_Form__c, Name, Authorised_signatory__c, Email__c, First_name__c, Last_name__c, Local_First_name__c, Local_Last_name__c, Salutation__c, Agency_owner__c, Agency_role__c,
                      AddressStreet__c, AddressCity__c, AddressCountry__c, AddressPostcode__c, Financial_interest__c, Date_joined_agency__c, Registration_number__c, IATAcode__c, Company_Name_Local__c,Contact__c,
                      Phone__c, PhoneNational__c, FAX__c, FAXNational__c, Financial_Assessment_Contact__c, Job_title__c, Mobile__c, MobileNational__c, Time_devoted_to_Agency_business__c, Agencies_prev_worked_for__c,
                      Prev_Job1_Position__c, Prev_Job1_From__c, Prev_Job1_IATA_accredited__c, Prev_Job1_IATA_code__c, Prev_Job1_Employer__c, Prev_Job1_Address__c, CASS_contact__c, Number_Of_Shares__c,
                      Prev_Job2_Position__c, Prev_Job2_From__c, Prev_Job2_IATA_accredited__c, Prev_Job2_IATA_code__c, Prev_Job2_Employer__c, Prev_Job2_Address__c, AMS_ContactId__c, AMS_OwnershipId__c, Authorised_to_make_customs_declarations__c,
                PASS_contact__c
                      FROM AMS_Accreditation_Contact__c
                      WHERE Id = : editContactId];

        amsContactCountry =  newContact.AddressCountry__c;
    }

    public void updateAgencyDetails() {
        try {
            accountUpdated = true;
            if (hqAccount.BillingStreet == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH)) {
                hqAccount.BillingStreet.addError(Label.ISSP_YouMustEnter);
                accountUpdated = false;
            }
            if (hqAccount.BillingCity == null && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH)) {
                hqAccount.BillingCity.addError(Label.ISSP_YouMustEnter);
                accountUpdated = false;
            }

            if (hqAccount.Email__c == null) {
                hqAccount.Email__c.addError(Label.ISSP_YouMustEnter);
                accountUpdated = false;
            }

            if (!accountUpdated)
                return;
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

    public Pagereference goToStep1() {

        if (isNoticeOfChange)
            return new Pagereference('/ISSP_AMS_PASS_Accreditation?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + '&step=1' +commParam);
        return new Pagereference('/ISSP_AMS_PASS_Accreditation?caseId=' + newCase.Id + '&step=1' + commParam);
    }

    public Pagereference goToStep2() {
        if (isNoticeOfChange)
            return new Pagereference('/ISSP_AMS_PASS_Accreditation?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + '&step=2' + commParam);
        return new Pagereference('/ISSP_AMS_PASS_Accreditation?caseId=' + newCase.Id + '&step=2' + commParam);
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
        if (isNoticeOfChange)
            return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + commParam + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + '&step=3' );
        return new Pagereference('/' + includedPageName + '?caseId=' + newCase.Id + commParam +'&step=3' );
    }

    public Pagereference goToStep4() {
        if (isNoticeOfChange) {
            if(newForm.Is_change_ownership_or_shareholding__c) { //No File Upload for Change of Ownership
                return goToStep3();
            } else {
                return new Pagereference('/ISSP_AMS_PASS_Accreditation?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + '&step=4' + commParam+'&accType=PASS');
            }
        }

        return new Pagereference('/ISSP_AMS_PASS_Accreditation?caseId=' + newCase.Id + '&step=4' + commParam+'&accType=PASS');
    }

    public Pagereference goToStep5() {
        if (isNoticeOfChange)
            return new Pagereference('/ISSP_AMS_PASS_Accreditation?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange + '&step=5' + commParam+'&accType=PASS');
        return new Pagereference('/ISSP_AMS_PASS_Accreditation?caseId=' + newCase.Id + '&step=5' + commParam+'&accType=PASS');
    }


    public Pagereference highLightPageForErrors() {
        if (newForm.Validation_ERRORS__c ) {
            if (!validateCharactersInForm() || !validateForm(true)) {
                return null;
            }
        }
        return null;
    }

    public Pagereference saveAMSFormAndGoForward() {

        try {

            newForm.Validation_ERRORS__c = FALSE;
            saveAMSForm();

            if (!validateCharactersInForm() || !validateForm(true) ) {
                return null;
            }

            if (isNoticeOfChange && newForm.Is_change_ownership_or_shareholding__c) {
                return goToStep5(); //No File Upload for NoC that isn't change of bank details
            }
            return goToStep4();
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public Pagereference saveAMSFormAndGoToStep5() {

        try {
            newForm.Validation_ERRORS__c = FALSE;

            if (!validateCharactersInForm())
                return null;

            saveAMSForm();
            return goToStep5();
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public Pagereference saveAMSFormAndGoBack() {

        try {
            newForm.Validation_ERRORS__c = FALSE;

            if (!validateCharactersInForm())
                return null;

            saveAMSForm();
            return goToStep2();
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public Pagereference saveAMSFormAndGoToStep1() {

        try {
            newForm.Validation_ERRORS__c = FALSE;

            if (!validateCharactersInForm())
                return null;

            saveAMSForm();
            return goToStep1();
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public Pagereference saveAMSFormAndLeave() {
        newForm.Validation_ERRORS__c = FALSE;
        saveAMSForm();
        return redirectToCasesList();
    }

    public Pagereference redirectToCasesList() {
        return new Pagereference('/ISSP_AMSCases?accType=PASS' + commParam);
    }

    public class AccountChanges {

        public String accountFieldAPI {get; set;}
        public String oldValue {get; set;}
        public String newValue {get; set;}

        public AccountChanges(String accountFieldAPI, String oldValue, String newValue) {

            this.accountFieldAPI = accountFieldAPI;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }

    }

    /*private Void updateAccountDetails() {
        List<AccountChanges> accChanges_List = new List<AccountChanges>();
        if (newForm.Branch_Office_Phone__c != null) {
            accChanges_List.add(new AccountChanges('Phone', accountConcerned.Phone, newForm.Branch_Office_Phone__c));
            accountConcerned.Phone = newForm.Branch_Office_Phone__c;
        }
        if (newForm.Branch_Office_Phone_National__c != null) {
            accChanges_List.add(new AccountChanges('PhoneNational__c', accountConcerned.PhoneNational__c, newForm.Branch_Office_Phone_National__c));
            accountConcerned.PhoneNational__c = newForm.Branch_Office_Phone_National__c;
        }
        if (newForm.Branch_Office_Fax__c != null) {
            accChanges_List.add(new AccountChanges('Fax', accountConcerned.Fax, newForm.Branch_Office_Fax__c));
            accountConcerned.Fax = newForm.Branch_Office_Fax__c;
        }
        if (newForm.Branch_Office_Fax_National__c != null) {
            accChanges_List.add(new AccountChanges('FaxNational__c', accountConcerned.FaxNational__c, newForm.Branch_Office_Fax_National__c));
            accountConcerned.FaxNational__c = newForm.Branch_Office_Fax_National__c;
        }
        if (newForm.Branch_Office_Email__c != null) {
            accChanges_List.add(new AccountChanges('Email__c', accountConcerned.Email__c, newForm.Branch_Office_Email__c));
            accountConcerned.Email__c = newForm.Branch_Office_Email__c;
        }
        if (!isocountry.Prevent_Portal_Trade_Name_Change__c && newForm.Trade_Name__c != null) {
            accChanges_List.add(new AccountChanges('TradeName__c', accountConcerned.TradeName__c, newForm.Trade_Name__c));
            accountConcerned.TradeName__c = newForm.Trade_Name__c;
        }

        if (isHOAccredited) {
            //callToMinorChangesWS(getWSInstance(), accountConcerned.Id, accChanges_List);
        }

        upsert accountConcerned;
    }


    public static ISSP_AMS_RecordCreator_Class.AMS_RecordCreatorWebservice getWSInstance() {
        ISSP_AMS_RecordCreator_Class.AMS_RecordCreatorWebservice newInstance;
        try {
            partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
            String userName;
            string password;
            if (ISSP_Ams_Login_Credentials__c.getValues('AmsDev1') != null) {
                userName = ISSP_Ams_Login_Credentials__c.getValues('AmsDev1').User_Name__c;
                password = ISSP_Ams_Login_Credentials__c.getValues('AmsDev1').Password__c;
            }
            partnerSoapSforceCom.LoginResult loginResult = sp.login(userName, password);
            newInstance = new ISSP_AMS_RecordCreator_Class.AMS_RecordCreatorWebservice();

            ISSP_AMS_RecordCreator_Class.SessionHeader_element newSessionInstance = new ISSP_AMS_RecordCreator_Class.SessionHeader_element();
            newSessionInstance.sessionId = loginResult.sessionId;
            newInstance.SessionHeader = newSessionInstance;
        } catch (Exception e) {
            system.debug('login failed: ' + e.getMessage());
        }

        return newInstance;

    }*/


    public Pagereference goToFinalStep() {

        System.DEBUG('goToFinalStep  - newForm Legal Status 1: ' + newForm.ISSP_AMS_Legal_Status__c);

        //if (isNoticeOfChange && newForm.Is_change_ownership_or_shareholding__c && !newForm.Notify_Change_Ownership__c)
        //    resetOwnershipSecFields(); //Clear current owners if added by user, then they switch back to Confirm Ownership

        if (!validateCharactersInForm() || !validateForm(true) ) {
            newForm.Validation_ERRORS__c = TRUE;
            upsert newForm;
            return goToStep3();
        }
        System.DEBUG('goToFinalStep  - if (!validateCharactersInForm() || !validateForm(true) ) - Pass ');
        System.DEBUG('goToFinalStep  - newform.Accept_terms_and_conditions__c - '+newform.Accept_terms_and_conditions__c);

        if ( !validateAttachedFiles()) {
            //ApexPages.Message myMsg;
            //myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step5_Files_Missing);
            //ApexPages.addMessage(myMsg);
            newForm.Validation_ERRORS__c = TRUE;
            upsert newForm;

            if (redirectToStepE)
                return goToStep5();

            return goToStep4();
        }
        
        if (!newform.Accept_terms_and_conditions__c) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_Accept_TOS_PASS));
            return null;
        }

        try {
            system.debug('kerensen Zohar goToFinalStep newForm: ' + newForm);
            system.debug('kerensen Zohar goToFinalStep newCase: ' + newCase);

            if (newCase.RecordTypeId != OSCAR_RECORD_TYPE_ID) { //Convert Contacts against Application into proper SFDC contacts
                //FM 25-01-2017 - not needed anymore, everything now points to the OSCAR
                //convertAMSContacts();  //For SAAM cases; AMS to take care of OSCAR enabled countries
            } else {
                setPortalAdminContact(); //Portal Admin is stored on AMS Form; for OSCAR Countries need to set AMS Contact as Portal Admin on submit
                setInvoicingContact(); // CB AMSU-10
            }

            System.Debug('amsOfficeType: ' + amsOfficeType);
            System.Debug('isHOAccredited: ' + isHOAccredited);

            if (amsOfficeType == 'Branch' || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD) {
                createBranchAccount();
                if(newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD)
                    accountStagingFieldMapping(hqAccount, newCase.Reason1__c, true);
            }/* else if (isNewHOforAccredAgent || isTerminatedAgent) {
                //Terminated Agent, or Accredited agent applying for HO of a different program e.g. PAX HO applying for IATA CGO HO
                //So create a new HO account and move case to new account
                createHOAccount(hqAccount);
                accountStagingFieldMapping(hqAccount, newCase.Reason1__c, true);
            }*/ else {  //Non-accredited agent applying for new HO
                hqAccount.Location_Type__c = AMS_Utils.HO;

                hqAccount.Location_Class__c = getLocationClass();
                upsert hqAccount;

                accountStagingFieldMapping(hqAccount, newCase.Reason1__c, false);
            }

            newForm.Submitted_to_IATA__c = TRUE;

            //RB-INC381175: Oscar fields Shipping ISO Country & Shipping ISO State not populated by the account's equivalent fields
            if (newCase.RecordTypeId == OSCAR_RECORD_TYPE_ID && (newCase.Reason1__c == AMS_Utils.CASE_REASON_NEW_HO || newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_IP
                || newForm.Location_Type__c == 'AE' || newForm.Location_Type__c == 'HE')) {
                if (newForm.Shipping_ISO_Country__c == null) {
                    system.DEBUG('Branch_Office_Country__c + Shipping_ISO_Country__c: ' + newForm.Branch_Office_Country__c + newForm.Shipping_ISO_Country__c);
                    newForm.Shipping_ISO_Country__c = newForm.Branch_Office_Country__c;
                }

                if (newForm.Shipping_ISO_State__c == null) {
                    system.DEBUG('IATA_ISO_State__c + Shipping_ISO_State__c: ' + newForm.IATA_ISO_State__c + newForm.Shipping_ISO_State__c);
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

            upsert newForm;

            // AMSU-110 assign Case via assignment rules
            //if(newCase.Status == 'Draft') //Change queue for drafts being submitted; Open - EDMC cases stay with current owner
            //    newCase.ownerid = getRegionalQueue();

            newCase.Status = 'Open';
            newCase.Dossier_reception_date__c = datetime.now().date();


            system.DEBUG('Invalid TAX Number: ' + newForm.INVALID_Tax_number__c);
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

            String typeOfProcess = AMS_Utils.new_PASS_HO;
            if (amsOfficeType == 'Branch')
                typeOfProcess = AMS_Utils.new_PASS_BR;

            SYSTEM.DEBUG('accountId for OSCAR: ' + accountId);

            if (newCase.RecordTypeId == OSCAR_RECORD_TYPE_ID)
                OSCARIntegration(accountId, newForm.Id, typeOfProcess, newCase.Id);

             //Send std Case Confirmation email
            SYSTEM.DEBUG('Pre-Send Confirm: ' + isNoticeOfChange);

            sendConfirmationEmail(newCase);

            return new Pagereference('/ISSP_AMS_PASS_Accreditation?caseId=' + newCase.Id + '&step=Final' + commParam);
        } catch (DmlException ex) {
            newForm.Submitted_to_IATA__c = FALSE;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'DML error - '+ex.getMessage()+' / '+ex.getLineNumber()));
        } catch (Exception e) {
            newForm.Submitted_to_IATA__c = FALSE;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'error - '+e.getMessage()+' / '+e.getLineNumber()));
        }

        return null;
    }

    private void accountStagingFieldMapping(Account sourceAccount, String strReason, Boolean alreadyAccredited) {  //Field mapping to be used when updating staging area from HO Account for HO Applications
        Map<String, String> mapAccountToAccrFormFields;
        system.debug('aqui strReason ' + strReason + ' alreadyAccredited ' + alreadyAccredited );
        if((strReason == AMS_Utils.CASE_REASON_NEW_HO || strReason == AMS_UTILS.CASE_REASON_HE_LITE || strReason == AMS_UTILS.CASE_REASON_HE_STANDARD) && !alreadyAccredited) {
            mapAccountToAccrFormFields = new Map<String, String> {'Name' => 'Account_Name__c', 'IATACode__c' => 'IATACode__c', 'Short_Name__c' => 'Short_Name__c',
                'Location_Class__c' => 'Location_Class__c', 'Location_Type__c' => 'Location_Type__c', 'TradeName__c' => 'Trade_Name__c',
                'BillingStreet' => 'Branch_Office_Street_name_number__c', 'BillingPostalCode' => 'Branch_Office_Postal_code__c', 'BillingState' => 'Billing_State__c', 'BillingCity' => 'Branch_Office_City__c',
                'IATA_ISO_Country__c' => 'ISO_Country__c', 'IATA_ISO_Country__c' => 'Branch_Office_Country__c', 'Iso_State__c' => 'IATA_ISO_State__c', 'ShippingCountry' => 'Shipping_Country__c', 'ShippingStreet' => 'Shipping_Street__c',
                'ShippingPostalCode' => 'Shipping_Postal_Code__c', 'ShippingState' => 'Shipping_State__c', 'ShippingCity' => 'Shipping_City__c', 'Email__c' => 'Branch_Office_Email__c',
                'Website' => 'Website__c', 'Phone' => 'Branch_Office_Phone__c', 'Fax' => 'Branch_Office_FAX__c', 'Mobile__c' => 'Mobile__c', 'Abbreviated_name__c' => 'Abbreviated_name__c',
                'Abbreviated_Address__c' => 'Abbreviated_Address__c', 'Remittance_frequency__c' => 'Remittance_frequency__c', 'Solicitation_Flag__c' => 'Solicitation_Flag__c',
                'VAT_Number_2__c' => 'VAT_Number_2__c', 'CASS_Number__c' => 'CASS_Number__c'
                };
        } else if((strReason == AMS_Utils.CASE_REASON_NEW_HO || strReason == AMS_UTILS.CASE_REASON_HE_LITE || strReason == AMS_UTILS.CASE_REASON_HE_STANDARD) && alreadyAccredited) {
            mapAccountToAccrFormFields = new Map<String, String> {'Name' => 'Account_Name__c', 'Short_Name__c' => 'Short_Name__c',
                'Location_Class__c' => 'Location_Class__c', 'Location_Type__c' => 'Location_Type__c', 'TradeName__c' => 'Trade_Name__c',
                'BillingStreet' => 'Branch_Office_Street_name_number__c', 'BillingPostalCode' => 'Branch_Office_Postal_code__c', 'BillingState' => 'Billing_State__c', 'BillingCity' => 'Branch_Office_City__c',
                'IATA_ISO_Country__c' => 'ISO_Country__c', 'IATA_ISO_Country__c' => 'Branch_Office_Country__c', 'Iso_State__c' => 'IATA_ISO_State__c', 'ShippingCountry' => 'Shipping_Country__c', 'ShippingStreet' => 'Shipping_Street__c',
                'ShippingPostalCode' => 'Shipping_Postal_Code__c', 'ShippingState' => 'Shipping_State__c', 'ShippingCity' => 'Shipping_City__c', 'Email__c' => 'Branch_Office_Email__c',
                'Website' => 'Website__c', 'Phone' => 'Branch_Office_Phone__c', 'Fax' => 'Branch_Office_FAX__c', 'Mobile__c' => 'Mobile__c'
                };
        } else if (strReason == AMS_Utils.CASE_REASON_BR_ABROAD)  {
            mapAccountToAccrFormFields = new Map<String, String> {'Location_Class__c' => 'Location_Class__c',
                'IATA_ISO_Country__c' => 'ISO_Country__c', 'Iso_State__c' => 'IATA_ISO_State__c'
                };
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
        boolean errorFound = false;
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

        if (errorFound)
            return false;

        return true;
    }

    public boolean validateCharactersInCompanyWindow() {
        boolean errorFound = false;
        //Pattern p = Pattern.compile('^[0-9\\\\A-z\\u00C0-\\u00ff\\s\\.,-\\/#!$%\\^&\\*;:{}=\\-_`~()]+$');
        Pattern p = Pattern.compile(ISO_8859_1_regEx);

        if (newContact.Name != null && !p.matcher(newContact.Name).matches()) {
            newContact.Name.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (newContact.Registration_number__c != null && !p.matcher(newContact.Registration_number__c).matches()) {
            newContact.Registration_number__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if (errorFound)
            return false;

        return true;
    }

	/*** AMSU--112 Start ***/
    public Set<String> accfieldsToCheck = new Set<String> {'BillingState', 'BillingStreet', 'BillingCity', 'TradeName__c', 'Name', 'BillingPostalCode'};
    public Set<String> formfieldsToCheck = new Set<String> {'Account_Name__c', 'Trade_Name__c', 'Branch_Office_Street_name_number__c', 'Branch_Office_City__c', 'Branch_Office_Postal_code__c', 'State_Province__c',
                                                            'Shipping_Street__c', 'Shipping_City__c', 'Shipping_Postal_Code__c', 'Shipping_State__c', 'Shipping_Country__c', 'ISSP_AMS_License_No__c',
                                                            'ISSP_AMS_Trade_Reg_No__c', 'ISSP_AMS_where_incorporated__c', 'ISSP_AMS_Principal_business_Org__c'};
    public Set<String> confieldsToCheck = new Set<String> {'AddressStreet__c', 'AddressCity__c', 'First_name__c', 'Last_name__c'};
    public void checkTabCharacters(AMS_Pax_Accreditation_Form__c form, Account acc, AMS_Accreditation_Contact__c con) {
        for(String fieldToCheck : formfieldsToCheck) {
            form.put(fieldToCheck, AMS_Utils.replaceTabCharcter((String) form.get(fieldToCheck)));
        }
        for(String fieldToCheck : accfieldsToCheck) {
            acc.put(fieldToCheck, AMS_Utils.replaceTabCharcter((String) acc.get(fieldToCheck)));
        }
        for(String fieldToCheck : confieldsToCheck) {
            con.put(fieldToCheck, AMS_Utils.replaceTabCharcter((String) con.get(fieldToCheck)));
        }
    }
    /*** AMSU-112 End ***/

    public boolean validateCharactersInForm() {
        boolean errorFound = false;
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
            } if (hqAccount.BillingCity != null && !p.matcher(hqAccount.BillingCity).matches()) {
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

            Pattern validEmail = Pattern.compile( '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,6}|[0-9]{1,6}))');

            if (newForm.Branch_Office_Email__c != null && !validEmail.matcher(newForm.Branch_Office_Email__c).matches()) {
                newForm.Branch_Office_Email__c.addError(Label.ISSP_AMS_Invalid_Email);
                errorFound = true;
            }
        }

        /*if (newCase.Reason1__c == AMS_Utils.CASE_REASON_BR_ABROAD || (isNoticeOfChange && newForm.Notify_Change_Legal_Details__c)) {
            if (newForm.Account_name__c != null && !p.matcher(newForm.Account_name__c).matches()) {
                newForm.Account_name__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }

            if (newForm.Trade_Name__c != null && !p.matcher(newForm.Trade_Name__c).matches()) {
                newForm.Trade_Name__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
        }*/

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

        if (errorFound)
            return false;

        return true;
    }


    public void sendConfirmationEmail(Case newCase) {
        String emailTemplateName;
        String fromaddress;

        if(newCase.Reason1__c == 'FoP Management' && newCase.origin == 'Massive FOP Creation') {
            emailTemplateName = 'ISSP ANG PCI Process Notification';
            fromaddress = 'IATA Service Centre (noreply@iata.org)';
        } else if (isNoticeOfChange && (newCase.ContactId == con.id)) { //Can't user VF template if Contact submitting case does not have case visibility i.e. is not the case contact
            SYSTEM.DEBUG('Sending NoC Confirmation 1');
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
            SYSTEM.DEBUG('Sending NoC Confirmation 2');
            Messaging.sendEmail(emails);
        }
    }

    private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        system.debug('user.ContactId ' + user.ContactId);
        con = DAL_ISSP.getContact(user.ContactId);

        if (con.User_Portal_Status__c == 'Administrator' || con.User_Portal_Status__c == 'Approved Admin' || con.User_Portal_Status__c == 'Regional Administrator' || con.User_Portal_Status__c == 'R. Administrator' )
            bIsAdmin = true;
    }

    public void fetchCase(String vCaseId) {
        List <Case> newCases = [
                                   SELECT Id, CaseNumber, Reason1__c, CaseArea__c, Status, BSPCountry__c, Country_concerned_by_the_query__c, Contact.Name, Account.Id, Description, Subject, Account_Concerned__c, Account_Concerned__r.Top_Parent__c, Account.Name,
                                   Account.Billing_Address_formated__c, Verification__c, IFAP_Country_ISO__c, Case_Language__c, Region__c, Applicable_to_Which_Version_s__c
                                   FROM Case
                                   WHERE Id = :vCaseId
                               ];
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
        if (r == AMS_Utils.CASE_REASON_NEW_HO) {
            return Label.ISSP_AMS_Reason_New_HO;
        } else{
            return Label.ISSP_AMS_Reason_New_Branch;
        }
    }

    private string getAgentTypeLabel(string agentType) {
        if (agentType == 'Legacy') {
            return Label.ISSP_AMS_IATA_Passenger_Sales_Agent;
        }
        return agentType;
    }

    private string getApplicationTypeLabel(string amsLocationType) {
        if (amsLocationType == AMS_Utils.TYPE_PAX_PASS_HO ){
             return Label.ISSP_AMS_OPTION_PAX_PASS_HO;
        } else{
            return Label.ISSP_AMS_OPTION_PAX_PASS_BRANCH;
        }
    }

    public AMS_Accreditation_Country_CheckList__c CountryCheckList {

        get{
            system.debug('sector ' + sector);
            system.debug('newCase.IFAP_Country_ISO__c ' + newCase.IFAP_Country_ISO__c);

            List<AMS_Accreditation_Country_CheckList__c> aux=new List<AMS_Accreditation_Country_CheckList__c>();

            aux = [
                SELECT License_required__c, Registration_required__c, Statement_of_International_Sales__c, Statement_of_International_Sales_Branch__c
                FROM AMS_Accreditation_Country_CheckList__c
                WHERE Operation__c = :sector LIMIT 1
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
        SYSTEM.DEBUG('Fetching Country REQS -  Sector: ' + sector);
        SYSTEM.DEBUG('Fetching Country REQS -  amsOfficeType: ' + amsOfficeType);
        SYSTEM.DEBUG('Getting PASS requirements');

        String selectedLang;

        if (applyLanguage == 'fr') {
            selectedLang = 'French';
        } else if (applyLanguage == 'es') {
            selectedLang = 'Spanish';
        } else {
            selectedLang = 'English';
        }
	
	Id passReqRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Requirement__c', 'PASS');
        this.List_CountryReqments = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                     FROM AMS_Accreditation_Requirement__c
                                     WHERE AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                                AND Location_type__c INCLUDES (:amsOfficeType) AND Language__c = :selectedLang
                                                AND RecordTypeId = :passReqRecordTypeId
                                                        ORDER BY Sort_Order__c ASC
                                    ];
    }

    public void fetchHQAccountDetails () {
        hqAccount = [
                        SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                        TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                        Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                        Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                        ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,
                        Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                        VAT_Number_2__c, CASS_Number__c,Company_Type__c,RecordType.DeveloperName,Status__c,IATA_ISO_Country__r.ISO_Code__c,ANG_Accreditation_Model__c,
                        IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c, Ownership
                        FROM Account
                        WHERE Id = :vHQAccountId
                                   LIMIT 1
                    ];
    }

    /*public void fetchAccountConcernedDetails () {
        accountConcerned = [
                            SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                            TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                            Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                            Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                            ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,
                            Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                            VAT_Number_2__c, CASS_Number__c,Company_Type__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c
                               FROM Account
                               WHERE Id = :vAccountConcernedId
                                          LIMIT 1
                           ];
    }*/

    public void fetchAMSProcessForm() {
        List <AMS_Pax_Accreditation_Form__c> newForms = [
                    SELECT Id, Name, SAAM_Case__c, Submitted_to_IATA__c, CurrencyIsoCode, IATACode__c, ISSP_AMS_Bank_account__c, ISSP_AMS_Date_license_granted__c, ISSP_AMS_Date_Registration_granted__c, ISSP_AMS_GDS_with_signed_contract__c,
                    ISSP_AMS_Gross_Amnt_First_year__c, ISSP_AMS_Gross_Amnt_Second_year__c, ISSP_AMS_IATA_Registered_Cargo_Agent__c, ISSP_AMS_Legal_Reg_Name_Address__c, ISSP_AMS_Legal_Status__c,
                    ISSP_AMS_License_No__c, ISSP_AMS_Min_Paidup_capital__c, ISSP_AMS_Online_Agency_Application__c, ISSP_AMS_Online_Agency_URL__c, ISSP_AMS_Paidup_capital__c, Total_International_Sales__c,
                    ISSP_AMS_Pax_Office_Open_Date__c, ISSP_AMS_Cargo_Office_Open_Date__c, ISSP_AMS_Premises_located_at_airport__c, ISSP_AMS_Previous_default__c, ISSP_AMS_Prev_default_explanation__c, ISSP_AMS_Principal_business_Org__c, Branch_Office_Phone_National__c, Branch_Office_Fax_National__c,
                    ISSP_AMS_Registered_Capital__c, ISSP_AMS_IBAN__c, ISSP_AMS_SWIFT__c, ISSP_AMS_Trade_Reg_No__c, ISSP_AMS_VAT_number__c, ISSP_AM_Means_Identified_Travel_Agency__c, ISSP_AMS_where_incorporated__c,
                    ISSP_AMS_Entity_with_listed_shares__c, ISSP_AMS_when_incorporated__c, ISSP_AMS_Portal_admin__c, ISSP_AMS_Invoicing_Contact__c, Cargo_Agent_Account__c, ISSP_AMS_Total_Ownership__c, Validation_ERRORS__c, IsGSA__c, INVALID_Tax_number__c,
                    International_Sales_in_last_Year__c, Sales_Period_From__c, Sales_Period_To__c, Branch_Office_City__c, Branch_Office_Phone__c, Branch_Office_Street_name_number__c, Branch_Office_Country__c, Branch_Office_Country__r.name, Branch_Office_Email__c,
                    Branch_Office_Fax__c, Branch_Office_Postal_code__c, Wholly_managed_by_this_Head_Office__c, Wholly_owned_by_this_Head_Office__c, AMS_Agency_Id__c, ISSP_Branch_AccountId__c, ISSP_AMS_Date_of_incorporation__c,
                    ISSP_AMS_Date_of_Association__c, ISSP_AMS_Business_Activities__c, ISSP_AMS_Is_Make_Declarations__c, ISSP_AMS_Nominee_Trustee__c, ISSP_AMS_VAT_number_input__c, ISSP_AMS_Number_of_Years_Traded__c, ISSP_AMS_Type_of_License__c,
                    ISSP_AMS_State_Names_Addresses__c, ISSP_AMS_Is_Applicant_Parent__c, ISSP_AMS_For_whom_Nominee__c, ISSP_AMS_Date_legal_establishment__c, Give_full_details__c, List_the_airport_s_to_be_authorized__c, Does_your_firm_intend_to_request__c,
                    Operation_Type__c, Has_your_firm_ever_held_a_Cargo_Agency__c, Date_issued__c, Name_under_which_it_was_issued__c, Reason_for_cancellation__c, Is_your_firm_an_approved_IATA_Passenger__c, IATA_Agents_Numeric_Code__c,
                    Does_the_air_transportation_which_your__c, State_the_percentage_of_your_gross__c, Does_your_firm_sell_air_cargo__c, What_percentage_of_your_sales__c, Is_your_firm_a_General_Sales_Agent_GSA__c, List_carriers__c,
                    Been_found_guilty_of_infringements__c, Been_a_sole_proprietor__c, Been_director_or_had_a_financial__c, Agents_Numeric_Code_of_your_Head_Office__c, Been_involved_in_a_bankruptcy__c, Does_your_firm_now_share_or_intend__c,
                    If_yes_are_you_fully_and_legally__c, Is_there_any_relationship__c, Is_your_firm_acting_as_agent_for_surface__c, Is_your_firm_affiliated_directly__c, provide_details__c, Rail__c, Steamship__c, Trucking__c,
                    Were_all_IATA_Members_fully_repaid__c, Has_your_form_ever_held_CASS_Assoc_etc__c, CASS_Assoc_Code__c, CASS_Date_issued__c, CASS_Name_under_which_it_was_issued__c, State_full_name_of_such_Agent__c, Is_your_firm_insured_to_cover__c,
                    Explain_fully_stating_name__c, Does_your_firm_operate_a_cargo_cartage__c, CASS_Reason_for_cancellation__c, Does_your_firm_use_its_own_vehicles__c, Is_your_firm_a_member_of_a_national__c, Give_the_name_of_the_association_s__c, IATA_Cargo_Code__c, Type_of_Operation__c,
                    ISSP_AMS_Amount_of_credit_requested__c, ISSP_AMS_Bank_Address_1__c, ISSP_AMS_Bank_Account_Number_1__c, ISSP_AMS_Bank_Address_2__c, ISSP_AMS_Bank_Account_Number_2__c, ISSP_AMS_Bank_Address_3__c, ISSP_AMS_Bank_Account_Number_3__c, Total_Charges_Specialized_Traffic__c, Total_Number_of_Consignments__c,
                    Total_Tons_Special_Traffic__c, Total_Percentage_Specialized_Traffic__c, Total_Freight_Charges_monetary_value__c, Total_Freight_weight_Kgs__c, No_Consignments_Last_Year__c, Total_Projected_Value_Freight__c, Total_Projected_Weight_Kilos__c, Total_Projected_Number_Consignments__c, Specialize_in_particular_traffic_type__c,
                    DG_Number_of_Consignments__c, Live_Animals_No_of_Consignments__c, Other_Number_of_Consignments__c, DG_Tons__c, Live_Animals_Tons__c, Other_Tons__c, DG_Air_Freight_Charges__c, Live_Animals_Air_Freight_Charges__c, Other_Air_Freight_Charges__c, DG_Percentage__c, Live_Animals_Percentage__c, Other_Percentage__c, CGO_Region_Selection__c,
                    CGO_Region_Consignment_Selection__c, CGO_Region_Consignment_Total__c, CGO_Region_Percentage_Selection__c, CGO_Region_Percentage_Total__c, CGO_Region_Tons_Selection__c, CGO_Region_Tons_Total__c, CGO_Region_AirFreight_Total__c, CGO_Region_AirFreight_Selection__c, Total_SOIS_Prepaid_Collected__c, Total_SOIS_Charges_Collected__c, Total_SOIS_Weight__c,
                    Separate_user_access__c, Head_Office_have_access__c, Billing_payment_Head_Office__c, Billing_payment_Branch_Office__c, Billing_payment_Another_Branch__c, Billing_payment_Bilateral__c, Branch_Office_Code__c, Payment_Via_Bank_Transfer__c, Payment_Via_Direct_Debit__c, Local_Legally_Registered_Name__c, Local_Physical_Address_Street__c, Local_Physical_Address_City__c, Local_Physical_Address_Postal_Code__c,
                    Local_Physical_Address_Province__c, Local_Physical_Address_Area__c, Local_Postal_Address_Street__c, Local_Postal_Address_City__c, Local_Postal_Address_Postal_Code__c, Local_Postal_Address_Province__c, Local_Postal_Address_Area__c, Local_Agent_Type__c, Accept_terms_and_conditions__c, Type_of_Cargo_Agent__c, Est_Future_Sales__c, Registered_to_hot_files__c, Agent_Type__c,
                    Is_change_bank_account_details__c, Is_change_legal_name__c, Is_change_location__c, Is_change_ownership_or_shareholding__c, State_Province__c, Mobile__c, MobileNational__c, Local_Physical_Address_Country__c, Local_Address_Country__c, Is_this_Branch_becoming_a_Head_Office__c, Is_this_Head_Office_becoming_a_Branch__c, Please_provide_details_for_the_change__c, Provide_details_for_change_affect_staff__c,
                    Provide_explanation_for_change_locations__c, Will_such_change_affect_locations__c, Will_such_change_affect_the_managers__c, Will_such_change_affect_the_premises__c, Will_the_change_of_ownership_cause__c, Effective_Date_Of_Change__c, Give_details_for_authorization_to_act__c, Give_details_for_the_change_of_ownership__c, Have_any_having_authorization_to_act__c, Issued_share_capital__c,
                    Specify_Legal_Status_After_Change__c, Issued_share_capital_After_Change__c, Trade_Name__c, ISSP_AMS_Curr_Entity_with_listed_shares__c, ISSP_AMS_Total_Current_Ownership__c, ISSP_AMS_Total_Previous_Ownership__c, Is_your_firm_handling_Dangerous_Goods__c, Country__c, Account_Name__c,Scope_of_Change__c,Agency_Codes_Concerned__c,Billing_State__c,Website__c,
                    Confirm_Legal_Details_are_correct__c,Notify_Change_Legal_Details__c,Confirm_Location_Details_are_correct__c,Notify_Change_Location__c,Confirm_Ownership_details_are_correct__c,Notify_Change_Ownership__c,Map_Company_Type_to_Legal_Status__c,New_Head_Office_IATA_Code__c,Shipping_Street__c,Shipping_City__c,Shipping_Postal_Code__c,Shipping_State__c,HO_Account__c,RecordTypeId,
                    IATAN_Code__c,IATA_Registered_IATAN_Agent__c,Enable_Credit_Card_FOP__c,IATAN_Agent_Account__c,AE_separate_Legal_Entity__c,ANG_AE_SameLegal__c,ANG_Accreditation_Model_to_Change__c, Notify_Change_Accreditation_Type__c, Confirm_accreditation_type_are_correct__c, Last_Scope_Of_Change__c, ANG_Accreditation_type__c,
                    SAAM_Case__r.Reason1__c,Mail_Flow_Inbound__c,Mail_Flow_Outbound__c,Mail_Class_Inbound__c,Mail_Class_Outbound__c,Mail_Category_Inbound__c,Mail_Category_Outbound__c,IMPC_Operator_Code__c,IMPC_Code__c,Special_Type__c,VAT_Exemption__c
                    FROM AMS_Pax_Accreditation_Form__c
                    WHERE SAAM_Case__c = :newCase.Id
                                         LIMIT 1
                ];
        system.debug('aqui newForms ' + newForms);
        if (newForms.size() > 0) {
            newForm = newForms[0];
        }
    }

    public void resetOwnership() { //NEWGEN-1249
        List<AMS_Accreditation_Contact__c> allOwners = [
            SELECT Name, RecordType.DeveloperName, Financial_interest__c,ANG_contactFromAccount__c
            FROM AMS_Accreditation_Contact__c
            WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id
            AND Agency_owner__c = true
            AND ANG_contactFromAccount__c = true];

        checkAllOwners = new List<AMS_Accreditation_Contact__c>();

        if(allOwners.size() > 0){
            checkAllOwners = allOwners;
        }
    }

    public void resetCreatedOwnership() { //NEWGEN-1249
        List<AMS_Accreditation_Contact__c> allOwners = [
            SELECT Name, RecordType.DeveloperName, Financial_interest__c,ANG_contactFromAccount__c
            FROM AMS_Accreditation_Contact__c
            WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id
            AND Agency_owner__c = true
            AND ANG_contactFromAccount__c = false];

        checkAllOwners = new List<AMS_Accreditation_Contact__c>();

        if(allOwners.size() > 0){
            checkAllOwners = allOwners;
        }
    }

    public IATA_ISO_Country__c fetchISOCountry(string isocode) {

        IATA_ISO_Country__c isocountry = [
                                             SELECT Id, Name, CurrencyIsoCode, EU_Country__c, AMS_Pilot_Country__c, Case_BSP_Country__c, IATA_Country_FR__c, IATA_Country_SP__c, IATA_COUNTRY_EN__c,
                                             IATA_Contry_KR__c, IATA_Country_IT__c, IATA_Country_JP__c, IATA_Country_PT__c, IATA_Country_ZH__c, Tax_Number_label__c, Tax_number_format__c, Branches_abroad_not_allowed__c,
                                             Tax_number_help_text__c, Hide_Tax_Number_VAT__c, ISO_Code__c, EACP_Country__c, OSCAR_enabled__c, CASS_Import__c, CASS_Country_free_text__c, Region__c, Disable_non_IATA_Cargo_Agents__c,
                                             original_bank_details_not_required__c, Local_language_Agency_details_required__c, Prevent_Portal_Trade_Name_Change__c, Enable_Notice_of_Change__c, SAAM_enable_non_IATA_Cargo_Agents__c,
                                             Enable_Minor_Changes_from_Portal__c, AMS_Accreditation_New_Labels__c,ANG_Enable_NewGen__c
                                             FROM IATA_ISO_Country__c
                                             WHERE ISO_Code__c = :isocode
                                         ];

        return isocountry;
    }

    public List<AMS_Accreditation_Contact__c> trainedStaffList {

        get{
            List<AMS_Accreditation_Contact__c> tsl = [
                SELECT Id, Name, First_name__c, Last_name__c, Position_trained_staff__c, List_Dangerous_Goods_Awareness__c,
                IATA_FIATA_training_history__c, Training_dangerous_goods_completed__c, Valid_until__c, Air_cargo_transport_business_exp__c
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__c = :this.newForm.Id
                AND recordTypeId = :retRecordTypeByObjectTypeAndName(AMS_Accreditation_Contact__c.SobjectType, 'Trained Staff')];
            return tsl;
        }
        set{}
    }

    public List<AMS_Accreditation_Contact__c> List_AgencyContacts {

        get{
            List<AMS_Accreditation_Contact__c> cons = [
                SELECT AMS_Pax_Accreditation_Form__c, Name, Authorised_signatory__c, Email__c, First_name__c, Last_name__c, Salutation__c, Agency_owner__c, Agency_role__c,
                AddressStreet__c, AddressCity__c, AddressCountry__c, AddressPostcode__c, Financial_interest__c, Date_joined_agency__c, CASS_contact__c, Invoicing_Contact__c,
                Phone__c, FAX__c, Financial_Assessment_Contact__c, Job_title__c, Mobile__c, Time_devoted_to_Agency_business__c, Agencies_prev_worked_for__c,
                Prev_Job1_Position__c, Prev_Job1_From__c, Prev_Job1_IATA_accredited__c, Prev_Job1_IATA_code__c, Prev_Job1_Employer__c, Prev_Job1_Address__c,
                Prev_Job2_Position__c, Prev_Job2_From__c, Prev_Job2_IATA_accredited__c, Prev_Job2_IATA_code__c, Prev_Job2_Employer__c, Prev_Job2_Address__c, Duplicate_contact_exists__c,
                Portal_administrator__c, Contact_Id__c,Contact__c, AMS_OwnershipId__c, AMS_ContactId__c, Authorised_to_make_customs_declarations__c, Local_First_name__c, Local_Last_name__c,
                PASS_contact__c
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND  RecordType.DeveloperName = 'Person'
                ORDER BY Agency_owner__c DESC, Name ASC
            ];
            return cons;

        }
        set{}
    }

    public List<AMS_Accreditation_Contact__c> List_IFAPAgencyContacts {

        get{
            List<AMS_Accreditation_Contact__c> ifapContatc = [
                SELECT Salutation__c, Name, Email__c, First_name__c, Last_name__c,
                       Phone__c, FAX__c, Financial_Assessment_Contact__c, Mobile__c,
                       Contact_Id__c, Contact__c, AMS_Pax_Accreditation_Form__c
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND  RecordType.DeveloperName = 'Person' AND Financial_Assessment_Contact__c = true
                ORDER BY Agency_owner__c DESC, Name ASC
            ];
            return ifapContatc;
        }
        set{}
    }

        public List<AMS_Accreditation_Contact__c> List_PreviousOwners {

            get{
                List<AMS_Accreditation_Contact__c> prevOwner = [
                    SELECT AMS_Pax_Accreditation_Form__c, Name, First_name__c, Last_name__c, Salutation__c, Agency_owner__c, Agency_role__c, Email__c,Phone__c,
                    Financial_interest__c, Contact_Id__c, Contact__c, AMS_OwnershipId__c, AMS_ContactId__c, Local_First_name__c, Local_Last_name__c, Number_Of_Shares__c,
                    AddressStreet__c, AddressCity__c, AddressCountry__c, AddressPostcode__c, Time_devoted_to_Agency_business__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND  RecordType.DeveloperName = 'Previous_Owner'
                    ORDER BY Name ASC
                ];
                return prevOwner;

            }
            set{}
        }

        public List<AMS_Accreditation_Contact__c> List_CurrentOwners {

            get{
                List<AMS_Accreditation_Contact__c> currOwner = [
                    SELECT AMS_Pax_Accreditation_Form__c, Name, First_name__c, Last_name__c, Salutation__c, Agency_owner__c, Agency_role__c, Email__c,Phone__c,
                    Financial_interest__c, Contact_Id__c, AMS_OwnershipId__c, AMS_ContactId__c, Local_First_name__c, Local_Last_name__c, Number_Of_Shares__c,
                    AddressStreet__c, AddressCity__c, AddressCountry__c, AddressPostcode__c, Time_devoted_to_Agency_business__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND  RecordType.DeveloperName = 'Current_Owner'
                    ORDER BY Name ASC
                ];
                return currOwner;

            }
            set{}
        }

        public List<AMS_Accreditation_Contact__c> List_CurrentCompanies {

            get{
                List<AMS_Accreditation_Contact__c> cons = [
                    SELECT Name, Financial_interest__c, Registration_number__c, IATAcode__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND  RecordType.DeveloperName = 'Current_Company_Owner'
                    ORDER BY Name ASC
                ];
                return cons;

            }
            set{}
        }

        public List<AMS_Accreditation_Contact__c> List_PreviousCompanies {

            get{
                List<AMS_Accreditation_Contact__c> cons = [
                    SELECT Name, Financial_interest__c, Registration_number__c, IATAcode__c
                    FROM AMS_Accreditation_Contact__c
                    WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND  RecordType.DeveloperName = 'Previous_Company_Owner'
                    ORDER BY Name ASC
                ];
                return cons;

            }
            set{}
        }

    public List<AMS_Accreditation_Contact__c> List_AgencyCompanies {

        get{
            List<AMS_Accreditation_Contact__c> cons = [
                SELECT Name, Financial_interest__c, Registration_number__c, IATAcode__c, Company_Name_Local__c, Agency_owner__c
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND  RecordType.DeveloperName = 'Company'
                ORDER BY Name ASC
            ];
            return cons;

        }
        set{}
    }

    public List<ISSP_AMS_Statement_International_Sales__c> List_InternationalSales {

        get{
            List<ISSP_AMS_Statement_International_Sales__c> sales = [
                SELECT IATA_Member_Airline__c, Sales_Amount__c, IATA_Member_Airline__r.Name, Charges_Collected__c, Prepaid_Collected__c, Weight_Kg__c
                FROM ISSP_AMS_Statement_International_Sales__c
                WHERE AMS_Online_Accreditation__c = :newForm.Id
                ORDER BY Name ASC
            ];
            return sales;

        }
        set{}
    }

    public List<AMS_Accreditation_Contact__c> List_Ownership_Summary {

        get{
            List<AMS_Accreditation_Contact__c> cons = [
                SELECT Name, RecordType.DeveloperName, Financial_interest__c
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0)
                ORDER BY Name ASC
            ];
            return cons;
        }
        set{}
    }

    public List<AMS_Accreditation_Contact__c> List_Curr_Ownership_Summary {

        get{
            List<AMS_Accreditation_Contact__c> cons = [
                SELECT Name, RecordType.DeveloperName, Financial_interest__c
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0) AND
                (RecordType.DeveloperName = 'Current_Company_Owner' OR RecordType.DeveloperName = 'Current_Owner')
                ORDER BY Name ASC
            ];
            return cons;
        }
        set{}
    }

    public List<AMS_Accreditation_Contact__c> List_Prev_Ownership_Summary {

        get{
            List<AMS_Accreditation_Contact__c> cons = [
                SELECT Name, RecordType.DeveloperName, Financial_interest__c
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0) AND
                (RecordType.DeveloperName = 'Previous_Company_Owner' OR RecordType.DeveloperName = 'Previous_Owner')
                ORDER BY Name ASC
            ];
            return cons;
        }
        set{}
    }

    public Double Ownership_Total {
        get{
            AggregateResult ownerTotal = [
                SELECT SUM(Financial_interest__c)total
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0)
            ];
            return (Double)ownerTotal.get('total');
        }
        set{}
    }

    public Double Curr_Ownership_Total {
        get{
            AggregateResult ownerTotal = [
                SELECT SUM(Financial_interest__c)total
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0) AND
                (RecordType.DeveloperName = 'Current_Company_Owner' OR RecordType.DeveloperName = 'Current_Owner')
            ];
            return (Double)ownerTotal.get('total');
        }
        set{}
    }

    public Double Prev_Ownership_Total {
        get{
            AggregateResult ownerTotal = [
                SELECT SUM(Financial_interest__c)total
                FROM AMS_Accreditation_Contact__c
                WHERE AMS_Pax_Accreditation_Form__r.Id = :newForm.Id AND (Financial_interest__c > 0) AND
                (RecordType.DeveloperName = 'Previous_Company_Owner' OR RecordType.DeveloperName = 'Previous_Owner')
            ];
            return (Double)ownerTotal.get('total');
        }
        set{}
    }

    public Decimal InternationalSales_Total {
        get{
            AggregateResult salesTotal = [
                SELECT SUM(Sales_Amount__c)total
                FROM ISSP_AMS_Statement_International_Sales__c
                WHERE AMS_Online_Accreditation__c = :newForm.Id
            ];
            return (Decimal)salesTotal.get('total');
        }
        set{}
    }

    public Decimal InternationalCharges_Collected_Total {
        get{
            AggregateResult chargesTotal = [
                SELECT SUM(Charges_Collected__c)total
                FROM ISSP_AMS_Statement_International_Sales__c
                WHERE AMS_Online_Accreditation__c = :newForm.Id
            ];
            return (Decimal)chargesTotal.get('total');
        }
        set{}
    }

    public Decimal InternationalPrepaid_Collected_Total {
        get{
            AggregateResult prepaidTotal = [
                SELECT SUM(Prepaid_Collected__c)total
                FROM ISSP_AMS_Statement_International_Sales__c
                WHERE AMS_Online_Accreditation__c = :newForm.Id
            ];
            return (Decimal)prepaidTotal.get('total');
        }
        set{}
    }

    public String Portal_Login_URL {
        get{
            String portalLoginUrl = '';
            if (ISSP_CS__c.getValues('ISSP Portal Login URL') != null)
                portalLoginUrl = ISSP_CS__c.getValues('ISSP Portal Login URL').value__c;
            return portalLoginUrl;
        }
        set{}
    }


    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
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
                                        :AMS_Utils.CASE_REASON_OPT_OUT,
                                        :AMS_Utils.CASE_REASON_NEW_BR)
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
        List<Case> AMSCases = getAMSDraftCases();
        if (AMSCases.isEmpty()) {
            return true;
        }
        return false;
    }

    Public Boolean getIsNotEmpty() {
        List<Case> AMSCases = getAMSDraftCases();
        if (AMSCases.isEmpty()) {
            return false;
        }
        return true;
    }

    // Initialize setCon and return a list of records
    public List<Case> getAMSDraftCases() {

        system.debug('******con.Account.Category__c '+con.Account.Category__c);
        system.debug('******con.Account.ANG_Accreditation_Model__c '+con.Account.ANG_Accreditation_Model__c);
        system.debug('******con.Account.ANG_FA_Opt_out__c '+con.Account.ANG_FA_Opt_out__c);

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

        System.DEBUG('Owner Label: ' + ownerLabel);
        System.DEBUG('Role Label: ' + roleLabel);
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

        System.DEBUG('Owner Label After Change: ' + ownerLabelAfterChange);
        System.DEBUG('Role Label After Change: ' + roleLabelAfterChange);
        return null;
    }

    public Pagereference fetchIATANDetails(){ //NEWGEN - 663
           String qCargoCode;
           IATANAgentAccount = new Account();
           List <Account> agentaccountITAN = null;

           if (iatacode == null)
                return null;
           qCargoCode = iatacode + '%';

            system.debug('agentsector:' + agentsector);
            system.debug('accountType:' + accountType);
            system.debug('amsOfficeType:' + amsOfficeType);
            system.debug('iatanAccount:' + iatanAccount);

            Set<String> categories = new Set<String>();
            categories.add(AMS_UTILS.IATAN_PASSENGER_AGENT);
            categories.add(AMS_UTILS.ARC_TRAVEL_AGENT_USA_ONLY);
            categories.add(AMS_UTILS.IATAN_PASSENGER_SALES_AGENT_USA_ONLY);
            categories.add(AMS_UTILS.TRAVEL_SERVICE_INTERMEDIATES_TSI_USA_ONLY);

            if(iatanAccount == AMS_UTILS.IATAN_PASSENGER_AGENT){
                agentaccountITAN = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                 BillingCountry, Name
                                 FROM Account
                                 WHERE RecordType.DeveloperName = 'IATA_Agency' AND Sector__c = :agentsector AND IATACode__c LIKE :qCargoCode
                                 AND Category__c in :categories
                                ];

                system.debug('agentaccountITAN ' + agentaccountITAN);
            }

            if(agentaccountITAN != null && !agentaccountITAN.isEmpty()) {
                if(iatanAccount == AMS_UTILS.IATAN_PASSENGER_AGENT )
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

        if (iatacode == null)
            return null;

        //Limit how many calls can be made to this service, to prevent a user from attempting to retrieve full list of agents
        cntAgencyLookups += 1;
        if (cntAgencyLookups > MAX_AgencyAccount_LOOKUPS_ALLOWED) {
            TravelAgentPrevAccount = new Account();
            return null;
        }

        /*//Must be min of 8 chars for Cargo Search
        if (agentsector == AMS_Utils.SECTOR_CARGO && iatacode.length() < 8) {
            return null;
        }

        //Must be min of 7 chars for Cargo Search
        if ((agentsector == AMS_Utils.SECTOR_PASSENGER || agentsector == 'Both')  && iatacode.length() < 7) {
            return null;
        }*/

        qCargoCode = iatacode + '%';

        List <Account> agentaccounts = null;
        system.debug('agentsector:' + agentsector);
        system.debug('accountType:' + accountType);
        system.debug('amsOfficeType:' + amsOfficeType);

        /*if (agentsector == AMS_Utils.SECTOR_CARGO && amsOfficeType == 'Branch' && newCase.Reason1__c != AMS_Utils.CASE_REASON_ASSOCIATE_ENTITY_STANDARD) {
            agentaccounts = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                             BillingCountry, Name
                             FROM Account
                             WHERE RecordType.DeveloperName = 'IATA_Agency' AND Sector__c = :agentsector AND IATACode__c LIKE :qCargoCode AND Location_Type__c = :AMS_Utils.BR
                            ];
            system.debug('agentaccounts:' + agentaccounts);
        } else if (agentsector == 'Both') {

            agentaccounts = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                             BillingCountry, Name
                             FROM Account
                             WHERE RecordType.DeveloperName = 'IATA_Agency' AND (Sector__c = :AMS_Utils.SECTOR_PASSENGER OR Sector__c = :AMS_Utils.SECTOR_CARGO) AND IATACode__c LIKE :qCargoCode
                            ];
            system.debug('agentaccounts:' + agentaccounts);

        } else if (accountType == AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT) {
            agentaccounts = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                             BillingCountry, Name
                             FROM Account
                             WHERE RecordType.DeveloperName = 'IATA_Agency' AND Sector__c = :agentsector AND IATACode__c LIKE :qCargoCode AND Type = : accountType
                            ];
            system.debug('agentaccounts:' + agentaccounts);

        } else {*/
            agentaccounts = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                             BillingCountry, Name
                             FROM Account
                             WHERE RecordType.DeveloperName = 'IATA_Agency' AND Sector__c = :agentsector AND IATACode__c LIKE :qCargoCode
                            ];
            system.debug('agentaccounts:' + agentaccounts);
        //}

        if (agentaccounts!= null && !agentaccounts.isEmpty()) {
            String agentAddress;
            /*if (agentsector == 'Both') {
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
            }else{*/
                TravelAgentPrevAccount = agentaccounts[0];
                System.Debug('Travel Agent name:' + TravelAgentPrevAccount.Name);

                agentAddress = notNull(TravelAgentPrevAccount.BillingStreet) + ' \r\n' +
                               notNull(TravelAgentPrevAccount.BillingCity) + '' + notNull(TravelAgentPrevAccount.BillingState) +
                               ' \r\n' + notNull(TravelAgentPrevAccount.BillingCountry);
                System.Debug('IATA Agent address lookup:' + agentAddress);
                if (prevAgentHistory == '1') {
                    newContact.Prev_Job1_Address__c = agentAddress;
                    newContact.Prev_Job1_Employer__c = TravelAgentPrevAccount.Name;
                    newContact.Accredited_employer_1__c = TravelAgentPrevAccount.Id;
                } else {
                    newContact.Prev_Job2_Address__c = agentAddress;
                    newContact.Prev_Job2_Employer__c = TravelAgentPrevAccount.Name;
                    newContact.Accredited_employer_2__c = TravelAgentPrevAccount.Id;
                }
            //}

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
                //foundCompany = false;
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
        system.debug('valid vat number');
        system.debug('vatNumber ' + vatNumber);
        IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
        try {
            if (isEUcountry && vatNumber != '') {
                IECVATUtil.VATResponse res = ws.ValidateVAT(newCase.IFAP_Country_ISO__c, vatNumber);
                if (!res.valid) {
                    newForm.ISSP_AMS_VAT_number_input__c.addError(Label.ISSP_PAX_Validating_VAT_Number_error);
                    system.debug('vatNumber adding an error');
                    newForm.INVALID_Tax_Number__c = true;
                } else {
                    newForm.INVALID_Tax_Number__c = false;
                }
            }
        } catch (System.CalloutException ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_PAX_Validating_VAT_Number_error);
            ApexPages.addMessage(myMsg);
        }
    }

    //Does Open, non-Draft/Pending customer SAAM case already exist for HQ?
    public boolean openHQCaseExists {
        get {
            List<Case> dupeDrafts = [
                SELECT Id, IFAP_Country_ISO__c, Reason1__c, CaseArea__c FROM Case WHERE RecordTypeId = :RECORD_TYPE_ID AND IsClosed = false AND Status NOT IN ('Draft', 'Pending customer') AND AccountId = :vHQAccountId AND Reason1__c = :AMS_Utils.CASE_REASON_NEW_HO
            ];
            system.debug('getter openHQCaseExists dupeDrafts.size(): ' + dupeDrafts.size());
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
            List<Case> dupeDrafts = [
                SELECT Id, IFAP_Country_ISO__c, Reason1__c, CaseArea__c FROM Case WHERE RecordTypeId = :RECORD_TYPE_ID AND Status IN ('Draft') AND AccountId = :vHQAccountId AND
                (Reason1__c = :AMS_Utils.CASE_REASON_NEW_HO OR Reason1__c = :AMS_UTILS.CASE_REASON_HE_STANDARD OR Reason1__c = :AMS_UTILS.CASE_REASON_HE_LITE)
            ];

            system.debug('getter draftHQCaseExists dupeDrafts.size(): ' + dupeDrafts.size());
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
            List<Case> dupeCases = [
                SELECT Id, IFAP_Country_ISO__c, Reason1__c, CaseArea__c FROM Case WHERE RecordTypeId = :RECORD_TYPE_ID AND Id = :vSAAMCaseId
            ];
            system.debug('getter draftHQCaseExists dupeCases.size(): ' + dupeCases.size());
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
                System.Debug('Apply language 2.1: ' + lang);
                if (lang != '') {
                    return lang;
                } else {
                    return UserInfo.getLanguage();
                }
            } else {
                /** Applications can only happen in eng, es or fr
                if(lang != 'en_US' && lang != 'es' && lang != 'fr') {
                    lang = 'en_US';
                }
                **/
                return UserInfo.getLanguage();
            }
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
        //options.add(new SelectOption('3 or more',Label.ISSP_SELECT_THREE_or_MORE));
        return options;
    }


    public void getPilotCountries() {
        List<IATA_ISO_Country__c> isoList;

        isoList = [SELECT Name, Id, ISO_Code__c, AMS_Pilot_Country__c
                   FROM IATA_ISO_Country__c
                   WHERE Case_BSP_Country__c != null
                   AND Case_BSP_Country__c != ''
                   ORDER BY Name];

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

        isoList = [SELECT Name, Id, ISO_Code__c, Travel_Branch_Country__c, Travel_HO_Country__c, Cargo_Branch_Country__c, Cargo_HO_Country__c, Branches_abroad_not_allowed__c
                   FROM IATA_ISO_Country__c
                   WHERE Case_BSP_Country__c != null
                   AND Case_BSP_Country__c != ''
                   ORDER BY Name];

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
            if (iso.Branches_abroad_not_allowed__c)
                notAllowedCountries.add(iso.ISO_Code__c);
        }

        jsonCountriesMap = JSON.serialize(mapCountriesList);
        jsonCountriesNotAllowedList = JSON.serialize(notAllowedCountries);
    }

    private void setPortalAdminContact() {
        Id personRecordTypeId;
        if (Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person') != null) {
            personRecordTypeId = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();
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
        if (Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person') != null) {
            personRecordTypeId = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();
        }

        List<AMS_Accreditation_Contact__c> amscontacts = [SELECT Id, Name, Invoicing_Contact__c
                                           FROM AMS_Accreditation_Contact__c WHERE
                                           recordTypeId = :personRecordTypeId AND AMS_Pax_Accreditation_Form__c = :newForm.Id AND Id = :newForm.ISSP_AMS_Invoicing_Contact__c];
        if (amsContacts.size() > 0) {
             amsContacts[0].Invoicing_Contact__c = true;
            update amsContacts[0];
        }
    }

    private boolean validateAttachedFiles() {
        boolean errorFound = false;

        redirectToStepE = false;

        SYSTEM.DEBUG('Sector on submit: ' + sector);

        system.debug('List_CountryReqments: ' + List_CountryReqments);

        Map<String, String> folderMap = new Map<String, String>();
        folderMap = getMapAmazonFileIdentifiers();

        for (AMS_Accreditation_Requirement__c thisReq : List_CountryReqments) {
            if (thisReq.File_to_Upload__c == 'Mandatory') {
                system.debug('MANDATORY FOR: ' + thisReq.File_Identifier2__c);
                if (!folderMap.containsKey(thisReq.File_Identifier2__c)) {
                    //system.debug('FILE NOT AVAILABLE');
                    ApexPages.Message myMsg;
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Please_Upload + ' ' + thisReq.Name);
                    ApexPages.addMessage(myMsg);

                    if (thisReq.File_Identifier2__c == CGO_SIGNED_CONTRACT || thisReq.File_Identifier2__c == NOC_SIGNED_CONTRACT)
                        redirectToStepE = true;

                    errorFound = true;
                } else {
                    system.debug('FILE AVAILABLE');
                }
            }
        }

        if (errorFound)
            return false;

        return true;
    }

    private boolean validateForm(boolean includeErrorMsgs) {
        boolean errorFound = false;
        Integer cntAuthorisedSig;
        Integer cntContact;

        system.debug('aqui  amsOfficeType ' +  amsOfficeType);
        system.debug('aqui  sectorValue ' +  sectorValue);

        cntAuthorisedSig = [SELECT COUNT() FROM AMS_Accreditation_Contact__c
                            WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND Authorised_signatory__c = true];

        refreshCntIFAPContacts();

        cntContact = [SELECT COUNT() FROM AMS_Accreditation_Contact__c
                          WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND PASS_contact__c = true];

        system.debug('validateForm - cntAuthorisedSig: ' + cntAuthorisedSig);
        system.debug('validateForm - cntContact: ' + cntContact);
        system.debug('amsOfficeType: ' + amsOfficeType);
        system.debug('AMS_Utils.HO: ' + AMS_Utils.HO);

        if(sectorValue.StartsWith(AMS_Utils.sectorValuePass) && amsOfficeType == AMS_Utils.HO){
            if (hqAccount.Email__c == null) {
                hqAccount.Email__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Legal_Status__c == null) {
                newForm.ISSP_AMS_Legal_Status__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if ((isTerminatedAgent || isNewHOforAccredAgent) && newForm.Account_Name__c == null) {
                newForm.Account_Name__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if ((isTerminatedAgent || isNewHOforAccredAgent) && !validateBROfficeDetails())
                errorFound = true;


            if (newForm.ISSP_AMS_Portal_admin__c == null ) {
                ApexPages.Message myMsg;
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Portal_Admin);
                ApexPages.addMessage(myMsg);
                errorFound = true;
            }

            if (cntContact == 0) {
                ApexPages.Message myMsg;
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please designate at least one PASS Contact.');
                ApexPages.addMessage(myMsg);
                errorFound = true;
            }

            if (cntAuthorisedSig == 0) {
                ApexPages.Message myMsg;
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Author_Sig);
                ApexPages.addMessage(myMsg);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_Legal_Status__c != 'State Owned Enterprise' && !(newForm.ISSP_AMS_Legal_Status__c == 'Corporation' && newForm.ISSP_AMS_Entity_with_listed_shares__c == 'Yes')) {
                if (newForm.ISSP_AMS_Total_Ownership__c == null || newForm.ISSP_AMS_Total_Ownership__c < 99.99 || newForm.ISSP_AMS_Total_Ownership__c > 100 ) {
                    ApexPages.Message myMsg;
                    if (newForm.ISSP_AMS_Legal_Status__c == 'Sole Proprietorship') {
                        myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'SECTIONS 2.1 PEOPLE - Please ensure that the % Total Ownership equals 100%.');
                    } else {
                        myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'SECTIONS 2.1 PEOPLE - Please ensure that the % Total Ownership equals 100%.');
                    }

                    ApexPages.addMessage(myMsg);
                    errorFound = true;
                }
            }

            if(isocountry.Local_language_Agency_details_required__c){
                if(newForm.Local_Legally_Registered_Name__c == null){
                    newForm.Local_Legally_Registered_Name__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Physical_Address_Street__c == null){
                    newForm.Local_Physical_Address_Street__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Physical_Address_City__c == null){
                    newForm.Local_Physical_Address_City__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Physical_Address_Province__c == null){
                    newForm.Local_Physical_Address_Province__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Postal_Address_Street__c == null){
                    newForm.Local_Postal_Address_Street__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Postal_Address_City__c == null){
                    newForm.Local_Postal_Address_City__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Postal_Address_Province__c == null){
                    newForm.Local_Postal_Address_Province__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            }
        } else if(sectorValue.StartsWith(AMS_Utils.sectorValuePass) && amsOfficeType == 'Branch') {
            if (!validateBROfficeDetails())
                errorFound = true;

            if(newForm.Branch_Office_Email__c == null){
                newForm.Branch_Office_Email__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.ISSP_AMS_VAT_Number_Input__c == null && isocountry.Hide_Tax_Number_VAT__c == false) {
                newForm.ISSP_AMS_VAT_Number_Input__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if(isocountry.Local_language_Agency_details_required__c){
                if(newForm.Local_Legally_Registered_Name__c == null){
                    newForm.Local_Legally_Registered_Name__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Physical_Address_Street__c == null){
                    newForm.Local_Physical_Address_Street__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Physical_Address_City__c == null){
                    newForm.Local_Physical_Address_City__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Physical_Address_Province__c == null){
                    newForm.Local_Physical_Address_Province__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Postal_Address_Street__c == null){
                    newForm.Local_Postal_Address_Street__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Postal_Address_City__c == null){
                    newForm.Local_Postal_Address_City__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
                if(newForm.Local_Postal_Address_Province__c == null){
                    newForm.Local_Postal_Address_Province__c.addError(Label.ISSP_YouMustEnter);
                    errorFound = true;
                }
            }

            if (newForm.Separate_user_access__c == null) {
                newForm.Separate_user_access__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Head_Office_have_access__c == null) {
                newForm.Head_Office_have_access__c.addError(Label.ISSP_YouMustEnter);
                errorFound = true;
            }

            if (newForm.Billing_payment_Head_Office__c == false && newForm.Billing_payment_Branch_Office__c == false && newForm.Billing_payment_Another_Branch__c == false && newForm.Billing_payment_Bilateral__c == false) {
                newForm.Billing_payment_Head_Office__c.addError(Label.ISSP_YouMustEnter);
                newForm.Billing_payment_Branch_Office__c.addError(Label.ISSP_YouMustEnter);
                newForm.Billing_payment_Bilateral__c.addError(Label.ISSP_YouMustEnter);
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

            if (cntContact == 0) {
                ApexPages.Message myMsg;
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please designate at least one PASS Contact.');
                ApexPages.addMessage(myMsg);
                errorFound = true;
            }

            if (cntAuthorisedSig == 0) {
                ApexPages.Message myMsg;
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Validation_Author_Sig);
                ApexPages.addMessage(myMsg);
                errorFound = true;
            }
        }

        if (errorFound)
            return false;

        return true;
    }

    public Boolean validateDangerousGoods(Integer limitNum) {
        Boolean errorFound = false;
        Integer cntCrtDanGoodsContacts;
        cntCrtDanGoodsContacts = [SELECT COUNT() FROM AMS_Accreditation_Contact__c
                                  WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id
                                          AND recordTypeId = :retRecordTypeByObjectTypeAndName(AMS_Accreditation_Contact__c.SobjectType, 'Trained Staff')
                                                  AND Training_dangerous_goods_completed__c = 'Yes'];

        if (cntCrtDanGoodsContacts < limitNum) {
            ApexPages.Message myMsg;
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Must have ' + limitNum + ' or more staff members with dangerous goods handling certificate');
            ApexPages.addMessage(myMsg);
            errorFound = true;
        }

        if (errorFound)
            return false;

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

        if (errorFound)
            return false;

        return true;
    }

    public Id getRegionalQueue() {
        //Available queue names
        Id qId;

        Set<String> queueNames = new Set<String> {'AgencyManagementAP', 'AgencyManagementAfricaME', 'AgencyManagementAmericas', 'AgencyManagementChinaNAsia', 'CasesACCEuropeOffOnshore'};
        Map<String, QueueSobject> mapRegionalQueue = new Map<String, QueueSobject>();
        //Build map queue.name -> queue
        for (QueueSobject queue : [Select Queue.Id, Queue.DeveloperName From QueueSobject Where Queue.DeveloperName in: queueNames]) {
            mapRegionalQueue.put(queue.Queue.DeveloperName, queue);
        }

        //Assigns queue according to region
        if (newCase.Region__c == 'Africa & Middle East') {
            if (mapRegionalQueue.get('AgencyManagementAfricaME') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAfricaME').Queue.Id;
            }

        } else if (newCase.Region__c == 'Americas') {
            if (mapRegionalQueue.get('AgencyManagementAmericas') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAmericas').Queue.Id;
            }

        } else if (newCase.Region__c == 'Asia & Pacific') {
            if (mapRegionalQueue.get('AgencyManagementAP') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAP').Queue.Id;
            }
        } else if (newCase.Region__c == 'China & North Asia') {
            if (mapRegionalQueue.get('AgencyManagementChinaNAsia') != null) {
                qId = mapRegionalQueue.get('AgencyManagementChinaNAsia').Queue.Id;
            }
        } else if (newCase.Region__c == 'Europe') {
            if (mapRegionalQueue.get('CasesACCEuropeOffOnshore') != null) {
                qId = mapRegionalQueue.get('CasesACCEuropeOffOnshore').Queue.Id;
            }
        }
        System.DEBUG('Case region: ' + newCase.Region__c);
        System.DEBUG('AM Queue returned: ' + qId);
        return qId;
    }

    public void setContextualHelp(string lang) {
        String fldName;
        ISSP_AMS_Contextual_Help__c hlp;

        if(displayLanguage != null && displayLanguage != ''){
            lang = displayLanguage;
        }

        fldName = 'ISSP_AMS_HelpText_' + lang + '__c';

        hlp = ISSP_AMS_Contextual_Help__c.getValues('CURRENCY');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpCurrency =  (String)hlp.get(fldName);
            } else {
                txtHelpCurrency =  (String)hlp.get(fldName);
            }
        }


        hlp = ISSP_AMS_Contextual_Help__c.getValues('MIN_PAIDUP_CAPITAL');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpMinPaidCapital =  (String)hlp.get(fldName);
            } else {
                txtHelpMinPaidCapital = (String)hlp.get(fldName);
            }
        }


        hlp = ISSP_AMS_Contextual_Help__c.getValues('REGISTERED_CAPITAL');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpRegisteredCapital = (String)hlp.get(fldName);
            } else {
                txtHelpRegisteredCapital = (String)hlp.get(fldName);
            }
        }

        hlp = ISSP_AMS_Contextual_Help__c.getValues('PAIDUP_CAPITAL');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpPaidUpCapital = (String)hlp.get(fldName);
            } else {
                txtHelpPaidUpCapital = (String)hlp.get(fldName);
            }
        }

        hlp = ISSP_AMS_Contextual_Help__c.getValues('TAX_NUMBER');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpTaxNumber = (String)hlp.get(fldName);
            } else {
                txtHelpTaxNumber = (String)hlp.get(fldName);
            }
        }

        hlp = ISSP_AMS_Contextual_Help__c.getValues('AUTHORISED_SIG');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpAuthorisedSig = (String)hlp.get(fldName);
            } else {
                txtHelpAuthorisedSig = (String)hlp.get(fldName);
            }
        }

        hlp = ISSP_AMS_Contextual_Help__c.getValues('FIN_CONTACT');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpFinContact = (String)hlp.get(fldName);
            } else {
                txtHelpFinContact = (String)hlp.get(fldName);
            }
        }

        hlp = ISSP_AMS_Contextual_Help__c.getValues('PORTAL_ADMIN');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpPortalAdmin = (String)hlp.get(fldName);
            } else {
                txtHelpPortalAdmin = (String)hlp.get(fldName);
            }
        }

        hlp = ISSP_AMS_Contextual_Help__c.getValues('GROSS_SALES');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpGrossSales = (String)hlp.get(fldName);
            } else {
                txtHelpGrossSales = (String)hlp.get(fldName);
            }
        }


        //FM 03/11/2017 - AMSU-20
        hlp = ISSP_AMS_Contextual_Help__c.getValues('TRAINED_STAFF_ORGANIZATION');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpTrainedStaffOrganization = (String)hlp.get(fldName);
            } else {
                txtHelpTrainedStaffOrganization = (String)hlp.get(fldName);
            }
        }

        //FM 03/11/2017 - AMSU-20
        hlp = ISSP_AMS_Contextual_Help__c.getValues('TRAINED_STAFF_REFERENCE');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpTrainedStaffReference = (String)hlp.get(fldName);
            } else {
                txtHelpTrainedStaffReference = (String)hlp.get(fldName);
            }
        }

        txtLocalAgencyDetailsTitle = Label.ISSP_AMS_Local_Details_Title_PASS_BRANCH;
        txtLocalAgencyDetailsPleaseEnter = Label.ISSP_AMS_Local_Details_Please_Enter_PASS;
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
            if (userLang == 'en_US') {
                ctrylabel = (String)isoctry.get('Name');
            } else If (userLang == 'es') {
                ctrylabel =  (String)isoctry.get('IATA_Country_SP__c');
            } else If (userLang == 'fr') {
                ctrylabel =  (String)isoctry.get('IATA_Country_FR__c');
            } else If (userLang == 'it') {
                ctrylabel =  (String)isoctry.get('IATA_Country_IT__c');
            } else if (userLang == 'pt_BR') {
                ctrylabel =  (String)isoctry.get('IATA_Country_PT__c');
            } else If (userLang == 'ko') {
                ctrylabel =  (String)isoctry.get('IATA_Contry_KR__c');
            } else if (userLang == 'zh_CN') {
                ctrylabel =  (String)isoctry.get('IATA_Country_ZH__c');
            } else if (userLang == 'ja') {
                ctrylabel =  (String)isoctry.get('IATA_Country_JP__c');
            } else {
                ctrylabel = (String)isoctry.get('Name');
            }

            if (ctrylabel != null) {
                return ctrylabel;
            } else {
                return (String)isoctry.get('Name');
            }
        } catch (DmlException ex) {
            return (String)isoctry.get('Name');
        }
    }

    private void setOwnerAndRoleLabels() {
        if (newForm.ISSP_AMS_Legal_Status__c != null) {
            legalstatus = newForm.ISSP_AMS_Legal_Status__c.toLowerCase();
            System.Debug('New Form Legal Status: ' + legalstatus);
            setPageLegalStatusLabels();
        } else {
            roleLabelType = 'manager';
            ownerLabelType = 'owner';
            ownerLabel = Label.ISSP_AMS_Owner;
            roleLabel = Label.ISSP_AMS_Manager;
        }


        if (newForm.ISSP_AMS_Legal_Status__c != null) {
            legalstatusafterchange = newForm.ISSP_AMS_Legal_Status__c.toLowerCase();
            System.Debug('New Form Legal Status After Change: ' + legalstatusafterchange);
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
        system.debug('createAccreditation(' + accountId + ', ' + accreditationId + ', ' + typeOfProcess + ', ' + caseId + ')');

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

        if (sectorValue.StartsWith('Travel_Agent') && (newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH && newform.Agent_Type__c != AMS_UTILS.NEWFORM_AGENTTYPE_CASH)) {
            np = new PageReference('/ISSP_AMS_PDF_ApplicationForm?caseid=' + newCase.id);
        }
        else if (sectorValue.StartsWith('Travel_Agent') && (newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH || newform.Agent_Type__c == AMS_UTILS.NEWFORM_AGENTTYPE_CASH) && newCase.Reason1__c != AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD) { //NEWGEN - 605
            np = new PageReference('/ISSP_AMS_PDF_ANG_PAX_HE?caseid=' + newCase.id);

        }else if (sectorValue.StartsWith('Travel_Agent') && (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD)) {
            np = new PageReference('/ISSP_AMS_PDF_ANG_PAX_AE?caseid=' + newCase.id);

        }else {
            np = new PageReference('/ISSP_AMS_PDF_CGO?caseid=' + newCase.id + '&mode=pdf');
        }

        np.setRedirect(false);
        return np;

        //return Page.ISSP_AMS_PDF_ApplicationForm;
    }

    private void setTrainedStaffList() {
        //FM 19-07-2017 - AMSU-20 - added: Type_Of_Certificate__c, Registration_number__c, Certificate_Issuer__c
        this.trainedStaffList = [SELECT Id, Name, First_name__c, Last_name__c, List_Dangerous_Goods_Awareness__c, Position_trained_staff__c, IATA_FIATA_training_history__c, Air_cargo_transport_business_exp__c, Training_dangerous_goods_completed__c, Valid_until__c, Type_Of_Certificate__c, Registration_number__c, Certificate_Issuer__c FROM AMS_Accreditation_Contact__c WHERE AMS_Pax_Accreditation_Form__c = :this.newForm.Id AND recordTypeId = :retRecordTypeByObjectTypeAndName(AMS_Accreditation_Contact__c.SobjectType, 'Trained Staff')];
    }

    public void editTrainedStaff() {
        trainedStaffContact = new AMS_Accreditation_Contact__c();
        //FM 19-07-2017 - AMSU-20 - added: Type_Of_Certificate__c, Registration_number__c, Certificate_Issuer__c
        trainedStaffContact = [SELECT Id, Name, First_name__c, Last_name__c, List_Dangerous_Goods_Awareness__c, Position_trained_staff__c, IATA_FIATA_training_history__c, Air_cargo_transport_business_exp__c, Training_dangerous_goods_completed__c, Valid_until__c, AMS_Pax_Accreditation_Form__c, Type_Of_Certificate__c, Registration_number__c, Certificate_Issuer__c FROM AMS_Accreditation_Contact__c WHERE Id = : trainedStaffId limit 1];

    }

    public void cancelTrainedStaff() {
        this.trainedStaffContact = new AMS_Accreditation_Contact__c();
        contactSaved = false;
    }

    public void upsertTrainedStaff() {
        this.trainedStaffContact.AMS_Pax_Accreditation_Form__c = this.newForm.Id;
        upsert this.trainedStaffContact;
    }

    private Id retRecordTypeByObjectTypeAndName(SObjectType entity, String recordTypeName) {
        try {
            return entity
                   .getDescribe()
                   .getRecordTypeInfosByName()
                   .get(recordTypeName)
                   .getRecordTypeId();
        } catch (Exception e) {
            return null;
        }
    }

    public void refreshCntIFAPContacts() {
        cntIFAPContacts = [SELECT COUNT()
                             FROM AMS_Accreditation_Contact__c
                            WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id AND Financial_Assessment_Contact__c = true
                              AND Id != :newContact.Id];
    }

    private Map<String, String> getMapAmazonFileIdentifiers() {
        //Get File identifiers for AmzonFile records assoc. with case
        list<AmazonFile__c> listAmazonFile = [
                Select Size_MB__c, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c , File_Identifier__c
                From AmazonFile__c
                Where Case__c = :newCase.Id
                                             ];

        SYSTEM.DEBUG('RETRIEVED listAmazonFile size:' + listAmazonFile.size());

        Map<String, String> mapAmazonFileIdentifiers = new Map<String, String>();
        for ( AmazonFile__c amazonFile : listAmazonFile) {
            if (!mapAmazonFileIdentifiers.containsKey(amazonFile.File_Identifier__c)) {
                //system.debug('FILE IN FOLDER: ' + folderName);
                mapAmazonFileIdentifiers.put(amazonFile.File_Identifier__c, amazonFile.File_Identifier__c);
            }
        }
        return mapAmazonFileIdentifiers;
    }

    public PageReference redirectToCasePage() {
        System.debug('Kerensen2 START GenerateCreateButtonURL ==>');

        List<ISSP_FAQ2Case_CreateCaseURL__c> ISSP_CreateButtonURL_Lst = new List<ISSP_FAQ2Case_CreateCaseURL__c> ([ select Id , Topic__c , SubTopic__c , URL__c
                From ISSP_FAQ2Case_CreateCaseURL__c
                WHERE
                Topic__c = : AgentCaseType
                                                                                                                  ]);

        System.debug('Kerensen2 ISSP_CreateButtonURL_Lst ==>' + ISSP_CreateButtonURL_Lst);
        if (ISSP_CreateButtonURL_Lst != null && ISSP_CreateButtonURL_Lst.size() > 0) {
            if(ISSP_CreateButtonURL_Lst[0].Topic__c == 'VR'){
                return new Pagereference(ISSP_CreateButtonURL_Lst[0].URL__c);
            }else{
                return new Pagereference(ISSP_CreateButtonURL_Lst[0].URL__c + '&topic=' + ISSP_CreateButtonURL_Lst[0].Topic__c + commParam);
            }

        } else {
            return null;
        }
    }

    public PageReference redirectToCountryRequirementPage(){
        PageReference pg = Page.ISSP_Country_Requirements;
        pg.getParameters().put('from', 'acc');
        pg.getParameters().put('comp', 'true');
        system.debug('aqui pg ' + pg);
        return pg;
    }

    public void setOwners(String type){
        List<AMS_Accreditation_Contact__c> lstAccreditationContact = new List<AMS_Accreditation_Contact__c>();
        Boolean notToAdd = false;
        //Get owners related to the account

        Id rtAccRoleOwnership = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();
        //BR
        Id rtAccreditContPersonOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();
        Id rtAccreditContCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        //NoC
        Id rtAccreditContPreviousOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Previous Owner').getRecordTypeId();
        Id rtAccreditContCurrentOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Current Owner').getRecordTypeId();
        Id rtAccreditContPreviousCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Previous Company Owner').getRecordTypeId();
        Id rtAccreditContCurrentCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Current Company Owner').getRecordTypeId();

        List<AMS_Accreditation_Contact__c> countAccreditationContact = [SELECT Id, ANG_contactFromAccount__c, RecordTypeId FROM AMS_Accreditation_Contact__c WHERE AMS_Pax_Accreditation_Form__c = :newForm.Id];
        //NEWGEN-205
        ID lAccountConcerned = ( (newForm.Scope_of_Change__c == 'Selected Branches Only' && newCase.Account_Concerned__c != null) ? newCase.Account_Concerned__c : vHQAccountId );
        if (isScopeOfChangeChanged && countAccreditationContact.size() != 0) {
            List<AMS_Accreditation_Contact__c> prevAndCurrOwnersList = new List<AMS_Accreditation_Contact__c>();
            for (AMS_Accreditation_Contact__c lCont: countAccreditationContact) {
                if (lCont.RecordTypeId == rtAccreditContPreviousOwner || lCont.RecordTypeId == rtAccreditContCurrentOwner) {
                    prevAndCurrOwnersList.add(lCont);
                }
            }
            if (prevAndCurrOwnersList.size() > 0) {
                List<Database.DeleteResult> re = database.delete(prevAndCurrOwnersList, false);
            }
        }
        // END NEWGEN-205

    for(AMS_Accreditation_Contact__c amsAccCon : countAccreditationContact){ //NEWGEN-1249
            if(newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD && amsAccCon.ANG_contactFromAccount__c == false){
                notToAdd = true;
                break;
            }
        }
        if (isScopeOfChangeChanged || countAccreditationContact.size() == 0 || (newCase.Reason1__c == AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD  && notToAdd == true)) {
            List<AMS_Account_Role__c> amsOwners = [SELECT Account__c,Active__c,
                Employee_Name__c,Employee_type__c,Id,
                Owner_Account__c,Owner_Account__r.Name,Owner_Account__r.IATACode__c,Owner_Account__r.Email__c,
                Owner_Name__c,Percentage__c,
                Position__c,RecordTypeId,Title__c,Valid__c,
                Person__c,Person__r.First_Name__c,Person__r.Lastname__c,Person__r.Email__c,
                Contact__c,Contact__r.FirstName,Contact__r.LastName,Contact__r.Email,Contact__r.Phone,
                Contact__r.OtherStreet,Contact__r.OtherCity,Contact__r.OtherPostalCode,Contact__r.OtherCountry,
                Legacy_External_ID__c
                FROM AMS_Account_Role__c
                where Account__c = :lAccountConcerned
                and RecordTypeId = :rtAccRoleOwnership
                and Active__c = true
                and Percentage__c > 0];

            for(AMS_Account_Role__c accRole : amsOwners){

                if(type.equalsIgnoreCase('NoC')){

                    lstAccreditationContact.add( setAccreditationContact(accRole, newForm.Id, rtAccreditContPreviousOwner, rtAccreditContPreviousCompanyOwner ) );
                    lstAccreditationContact.add( setAccreditationContact(accRole, newForm.Id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner ) );
                }

                if(type.equalsIgnoreCase('Branch')){

                    lstAccreditationContact.add( setAccreditationContact(accRole, newForm.Id, rtAccreditContPersonOwner, rtAccreditContCompanyOwner ) );

                }

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
            //auxAccreditCont.Last_name__c = accRole.Owner_Name__c;
            auxAccreditCont.Last_name__c = accRole.Owner_Name__c != null ? accRole.Owner_Name__c : accRole.Employee_Name__c ;
            auxAccreditCont.Name = accRole.Owner_Name__c;
            auxAccreditCont.Financial_interest__c = accRole.Percentage__c;
            auxAccreditCont.Agency_owner__c = true;
            auxAccreditCont.RecordTypeId = rtRecordTypePerson;


        }else
        //Check if owner is contact
        if(accRole.Contact__c != null){

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

        }else
        //Check if owner is PERSON
        if(accRole.Person__c != null){

            auxAccreditCont.AMS_Pax_Accreditation_Form__c = newFormId;
            auxAccreditCont.First_name__c = accRole.Person__r.First_Name__c;
            auxAccreditCont.Last_name__c = accRole.Person__r.Lastname__c;
            auxAccreditCont.Name = accRole.Person__r.First_Name__c + ' ' + accRole.Person__r.Lastname__c;
            auxAccreditCont.Financial_interest__c = accRole.Percentage__c;
            auxAccreditCont.Agency_owner__c = true;
            auxAccreditCont.RecordTypeId = rtRecordTypePerson;
            auxAccreditCont.Email__c = accRole.Person__r.Email__c;

        }else
        //Check if owner is PERSON
        if(accRole.Owner_Account__c != null){

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
        } else {
            return accreditationModel;
        }
    }

    public Pagereference runOptInOut() {

        //newForm.Effective_Date_Of_Change__c = Date.valueOf(pEfectiveDateStr);

        newCase.RecordTypeId = AMS_Utils.OSCAR_COMUNICATION;
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

        ISSP_AMS_PASS_Accreditation.OSCARIntegration(newCase.Account_Concerned__c, newForm.Id, AMS_Utils.NGOPTINOUT, newCase.Id);

        return null;
    }

    public PageReference checkLegalStatus(){
        legalStatusValue = Apexpages.currentPage().getParameters().get('legalStatusValue');

        if(legalStatusValue=='State Owned Enterprise'){
            governmentOwnedPASS=true;
        }else{
            governmentOwnedPASS=false;
        }

        return null;
    }
}