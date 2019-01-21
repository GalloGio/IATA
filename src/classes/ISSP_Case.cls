public without sharing class ISSP_Case {

    private static Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
    private static Id AME_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesMENA');
    private static Id AMERICAS_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesAmericas');
    private static Id APAC_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ExternalCasesIDFSglobal');
    private static Id CHINA_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_China_North_Asia');
    private static Id EUROPE_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
    private static Id IDFS_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ComplaintIDFS');
    private static Id INTER_DPC_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Inter_DPCs');
    private static String AGENT_ACCREDITATION_PORTAL_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().AgencyAccreditation__c;
    private static String AIRLINE_PARTICIPATION_PORTAL_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().AirlineParticipation__c;
    private static String AIRLINE_PARTICIPATION_CHANGE_PORTAL_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().AirlineParticipation_MinorChange__c;
    private static String AIRLINE_PARTICIPATION_BANK_CHANGE_PORTAL_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().AirlineParticipation_Bank_Change__c;
    public Case newCase {get; set;}
    public boolean isISSPortalPwCCase {set; get;}
    public boolean isNewCase {get; set;}
    public boolean isSISCase {get; set;}
    public boolean isPWCCase {get; set;}
    public boolean isAPCase {get; set;}
    public boolean isOSCARCase {get; set;}
    public boolean isIFAPCase {get; set;}  //AS - 08.2016: Closed IFAP cases now to be displayed on Portal
    public boolean isOnlineOSCARCase {get; set;}
    public boolean isTravelAccreditation {get; set;}
    public boolean isPWCProfile {get; set;}
    public boolean isKaleRole {get; set;}
    public boolean isDPCUser {get; set;}
    public boolean isAgencyUser {get; set;} //TF - SP9-C5
    public boolean isGSAUser {get; set;} //TF - SP9-C5
    public boolean isFDSRecordType {get; set;} //TF - SP9-C5
    public boolean isGSAOnly {get; set;} //TF - SP9-C5
    public String accountId {get; set;} //TF - SP9-C5
    public boolean DPCCaseScheduleWarning {get; set;}
    public boolean isEditMode {get; set;}
    public String sisCaseArea {get; set;}
    public boolean isAccreditationUploadCase {get; set;} //Accreditation upload to case e.g. for TIDS, VR etc.
    public boolean isToShowSurveyBtn {get; set;} //INC260167
    public boolean disableCaseComments;
    private final static Integer CLOSE_COMMENTS_AFTER_DAYS = 7;

    // DPC
    public Boolean dpcCanAccept {get;set;}
    public Boolean isDPCAdmin {get;set;}
    public Boolean isACCA {get;set;}
    public list<SelectOption> lst_whoToContact {get;set;}
    public String whoToContact { get; set; }
    public String caseAreaa { get; set; }
    public String additionalRecipients { get; set; }
    public String JSONcontacts { get; set; }

    public Id runningUserId {get; set;}
    public Contact con {get; set;}
    public List <FAQ__kav> finalArticleList {get; set;}
    //public FAQ__kav selectedArtical { get; set; }
    public List <How_To__kav> finalHowList {get; set;} //TF-sp2
    //public How_To__kav selectedHow { get; set; }//TF-sp2
    public List <articleWrapper> globalList {get; set;}//TF-sp2
    public articleWrapper selectedArtical { get; set; }
    public static Boolean showAP { get; set; }
    public static Boolean showAccreditation { get; set; }
    public List<CaseComment> List_CaseComment {get; set;}
    public List<Case_Milestone__c> List_CaseMilestones {get; set;}
    public String SurveyLanguage {get; set;}
    private E2CPFieldAccess e2cpFieldaccess;

    //Content Related List Handle
    public List<ContentDistribution> ContentDistribution_List {get; set;}
    public boolean isDisplay_ContentTL  {get; set;}
    public List<ContentVersion > tmpContentVersion_Lst  {get; set;}

    //SIS Lists
    //JQuery on ISSP_Case page was breaking deependent picklists, so need to build our own dynamic lists
    public List<SelectOption> caseTypeItems;
    public List<SelectOption> caseSubTypeItems;
    public List<SelectOption> caseClassificationItems;
    public List<SelectOption> caseDefectItems;

    public String caseTypeSelection {get; set;}
    private String caseTypeSelectionInit;
    public String caseClassificationSelection {get; set;}

    //Store PDF per type of Accreditation request e.g. TIDS, VR etc,
    public List <ISSP_PDF_Per_Region__c> pdfPerAccreditationTypeList {get; set;}

    //Survey Handle
    public boolean mySurveyCompletedVariable  {get; set;}

    //basto1p
    public String statusValMapped  {get; set;}
    public static final String  STATUS_FLD_NAME='Status';
    public static final String  NO_FIELD_MAP='NO_FIELD_MAP';

    public static Boolean preventTrigger = false;

    public boolean isDPCInvestigateMode {get {
            return (caseType == 'DPCSR' && (CaseStatus == 'DPC_INVESTIGATING' || CaseStatus == 'SCHEDULED'));
        }
    }
    public boolean isDPCAccepted {get {
            return (caseType == 'DPCSR' && caseStatus != 'OPEN');
        }
    }
    public boolean isACRAccepted {get {
            return (caseType == 'ACR' && newCase.Escalated_Status_ACCA__c != null && newCase.ACCA_Owner__c != null);
        }
    }
    //AMSU-119
    public boolean isMSOcase {get {
            return (caseType == 'OSCAR' && (newCase.Reason1__c == 'GSA / MSO / Handling Agent' || newCase.Subject.startsWith('MSO code ') ));
        }
    }

    public String CaseType { get {return ISSP_Constant.caseTypeMap.get(newCase.RecordType.Name);}   }
    public String CaseStatus { get {return ISSP_Constant.caseStatusMap.get(newCase.Status);}    }
    //public String CaseDPCStatus { get {return ISSP_Constant.caseStatusMap.get(newCase.Escalated_Status_ACCA__c);}   }

    public Decimal CaseStatusACR { get {return ISSP_Constant.caseStatusMap_ACR_Internal.get(newCase.Status);}    }
    public Decimal CaseDPCStatusACR { get {return ISSP_Constant.caseStatusMap_ACR_Portal.get(newCase.Escalated_Status_ACCA__c);}   }

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    public String firstCommParam { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}

    public ANG_ProgressBarHelper progressBarHelper{get; set;}

    public PageReference pageLoad() {
        if (ApexPages.currentPage().getParameters().containsKey('caseId')) {
            string caseId = ApexPages.currentPage().getParameters().get('caseId');
            newCase = DAL_ISSP.getCase(caseId);

            //ACAMBAS - WMO-389 - Start
            if(newCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA')) {
                newCase.Subject = 'IMPORTANT: IATA Payment';
                newCase.Subject = (newCase.IATA_Code__c != null) ? newCase.Subject + ' - IATA Code ' + newCase.IATA_Code__c : newCase.Subject;
                newCase.Subject = (newCase.Remittance_period__c != null) ? newCase.Subject + ' - Period ' +  newCase.Remittance_period__c : newCase.Subject;
            }
            //ACAMBAS - WMO-389 - End

            if(newCase.status == TIP_Utils.CASE_STATUS_DRAFT && newCase.CaseArea__c == TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS){ //Transparency in Payment's portal access assignment
                User user = DAL_ISSP.getUser(Userinfo.getUserId());
                Id appListId;
                ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
                if (serviceIdInstance != null && serviceIdInstance.TIP_Portal_Service_Id__c != null){
                    appListId = serviceIdInstance.TIP_Portal_Service_Id__c;
                    
                    List <Portal_Application_Right__c> appRightList = [Select Id From Portal_Application_Right__c
                                        where Contact__c = :user.ContactId and
                                                           Right__c = 'Access Granted'  and
                                                           Portal_Application__c = :appListId limit 1];


                    if(appRightList != null && appRightList.size() == 1){
                        if(newCase.Reason1__c == TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT) return new PageReference('/ISSP_TIP_Home?caseId='+caseid);
                        
                        Id prodId = [select TIP_Partner_Product__c from Case where id = :caseid limit 1].TIP_Partner_Product__c;
                        if(newCase.Reason1__c == TIP_Utils.CASE_REASON_PRODUCT_MANAGEMENT) return new PageReference('/ISSP_TIP_Home?prodId='+prodId);
                    }
                }
            }
            if (!newCase.Visible_on_ISS_Portal__c) {
                PageReference pr = new PageReference('/ISSP_Homepage' + firstCommParam);
                return pr;
            }
            this.e2cpFieldAccess = new E2CPFieldAccess(caseId);

            if(newCase.RecordType.name == 'IATA Financial Review') { //Open IFAP cases must be opened via the page used specifically for open IFAP cases (ISSP_IFAPCases)
                popContact();
                Set<String> openIFAPStatuses = new Set<String>
                    {'action needed', 'agent notified (email)', 'agent notified (mail)', 'sanity check failure'};
                if(openIFAPStatuses.contains(newCase.Status.toLowerCase()) && con.Financial_Assessment_Contact__c) {
                        PageReference pr = new PageReference('/ISSP_IFAPCases?id=' + caseId + commParam);
                        return pr;
                    }
            }else if(newCase.RecordType.name == 'OSCAR Communication' && (newCase.Origin == 'Massive FOP Creation' || newCase.Origin == 'FoP automatic renewal') && newCase.Owner.Name.startsWith('NewGen PCI')){
                        PageReference pr = new PageReference('/ISSP_ANG_PCI?caseId=' + caseId + commParam);
                        return pr;
            } else if (newCase.RecordType.name == 'OSCAR Communication' && newCase.Status == 'Draft' && (newCase.Reason1__c == AMS_Utils.CASE_REASON_FOR_MANAGEMENT || newCase.Reason1__c == AMS_Utils.CASE_REASON_PCI_DSS_COMPLIANT)) {
                PageReference pr = new PageReference('/ISSP_ANG_PCI?caseId=' + caseId + commParam);
                return pr;
            }else if(newCase.RecordType.name == 'OSCAR Communication' && newCase.Reason1__c == 'Annual revalidation' && newCase.Owner.Name.startsWith('Annual Revalidation')){
                PageReference pr = new PageReference('/ISSP_ANG_ANNUAL_REVALIDATION?caseId=' + caseId);
                return pr;
            } else if (newCase.RecordType.Name == 'OSCAR Communication' && newCase.Owner.Name.startsWith('Model A Onboarding')) {
                return new PageReference('/ISSP_ModelA_Onboarding?caseId=' + caseId);
            }

            //if case is a SIS Joining Form
            if(newCase.RecordType.DeveloperName == 'IDFS_Airline_Participation_Process' && newCase.Classification_SIS__c == 'SIS Membership'
                    && newCase.Status == 'Draft' && !newCase.isClosed && !newCase.Owner.Name.StartsWith('Recycle Bin')){
                return new PageReference('/ISSP_SISMembershipApplicationForm?id=' + caseId + '&step=2');
            }
            // If Case is an ICCS Case, redirect to ICCS Service
			Set<String> recordTypesSet = new Set<String>{
				'FDS ASP Management',
				'FDS ICCS Bank Account Management',
				'FDS ICCS Membership Management',
				'FDS ICCS Product Management'
			};
			if(newCase.Origin == 'Portal' && recordTypesSet.contains(newCase.RecordType.Name)){
                PageReference pr = new PageReference('/ISSP_ICCS_Service?caseId=' + caseId);
                return pr;
			}
            showAlertMessage();

        }
        return null;
    }

    /**
        Shows a disclaimer if current case was closed for more than 2 weeks
    **/
    public void showAlertMessage() {
        //AMSU-119
        if (getHideForClosedCases() && !isMSOcase) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.ISSP_Case_Closed_More_Than_2_Months);
            ApexPages.addMessage(myMsg);
        }else if(isMSOcase){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.ISSP_AMS_MSO_Case_Alert);
            ApexPages.addMessage(myMsg);
        }
    }

    /**
        Returns true if the input case has an specific RecordType
        and is closed for more than 2 months
    **/
    public Boolean getHideForClosedCases() {
        set<String> validRecordtypes = new set<String>{AME_RECORD_TYPE_ID, AMERICAS_RECORD_TYPE_ID, APAC_RECORD_TYPE_ID, CHINA_RECORD_TYPE_ID, EUROPE_RECORD_TYPE_ID, IDFS_RECORD_TYPE_ID};
        //AMSU-119
        //return (validRecordtypes.contains(this.newCase.RecordtypeId) && this.newCase.ClosedDate < Date.today().addDays(-14));
        return ((validRecordtypes.contains(this.newCase.RecordtypeId) && this.newCase.ClosedDate < Date.today().addDays(-14)) || isMSOcase );
    }

    public String fullnameNOCFile { get{

            Id caseId = ApexPages.currentPage().getParameters().get('caseId');
            String folderName = '500/' + caseid + '/';
            String fileName = 'Notice_of_Change_form.pdf';
            String fullname = folderName + fileName;

            List<AmazonFile__c> amazonfilesList = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE Case__c =: caseId];
            Boolean hasFile = false;
            for(AmazonFile__c af : amazonfilesList) {
                if(af.Full_Name_Unique__c == fullname) {
                    hasFile = true;
                    break;
                }
            }

            if(hasFile){
                String link = ISSP_AmazonS3_Ctrl.getExpiringLinkIfap(fullname);

                return link;
            } else {

                Boolean isBankAccountChange = false;

                if(newCase.Reason1__c == 'Bank Detail Update')
                    isBankAccountChange = true;

                return '/ISSP_AMS_PDF_NOC?caseId=' + newCase.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange;
            }

        }
    }

    public ISSP_Case() {
        newCase = new Case();

        showAP = false;
        showAccreditation = false;
        isAccreditationUploadCase = false;
        SurveyLanguage = UserInfo.getLanguage() ;

        popContact();

        //TF - SP9-C5
        ID FDScaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Email_to_Case');
        String recordTypeId = ApexPages.currentPage().getParameters().get('recordTypeId');

        //AS - SP10; get the recordtyype name for new cases, esp. for SIS
        String recordTypeName;
        If(recordTypeId <> null) {
            recordTypeName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', recordTypeId).Name;
        }

        //get parameters
        String paramTopic = ApexPages.currentPage().getParameters().get('topic');
        String paramSubtopic = ApexPages.currentPage().getParameters().get('subtopic');
        if (paramTopic != null && paramSubtopic != null) {
            newCase.Type = EncodingUtil.urlDecode(paramSubtopic, 'UTF-8');
            caseTypeSelectionInit = EncodingUtil.urlDecode(paramSubtopic, 'UTF-8');

            if (paramTopic.startsWith('SIS')) {
                newCase.CaseArea__c = 'SIS';
            } else {
                newCase.CaseArea__c = 'ICH';
            }
        }

        if (paramTopic != null ) { //Specific cases created from accreditation landing page

            //Get the PDF URLs to download for this Accred. type
            String paramTopicString = paramTopic + '-%';
            pdfPerAccreditationTypeList = [SELECT Address__c, Link_To_PDF__c FROM ISSP_PDF_Per_Region__c
                                           WHERE Name LIKE :paramTopicString ORDER BY Sort_Order__c, Name];
            newCase.Country_concerned_by_the_query__c = con.Account.IATA_ISO_Country__r.Name;
            newCase.Region__c = con.Account.IATA_ISO_Country__r.Region__c;
            newCase.Dossier_reception_date__c = datetime.now().date();
            newCase.Visible_on_ISS_Portal__c = true;

            if (paramTopic == 'SA') {
                newCase.Subject = 'New SA - ' + con.Account.Name;
                newCase.CaseArea__c = 'Accreditation Process';
                newCase.Reason1__c = 'New SA / CHV – New Code';
                newCase.Status = 'Draft';
                newCase.Product_Category_ID__c = '-'; //Set Product Id so picked up by case assign to AM Regional queue
                isAccreditationUploadCase = true;
            } else if (paramTopic == 'TIDS') {
                newCase.Subject = 'New TIDS - ' + con.Account.Name;
                newCase.CaseArea__c = 'Accreditation Products';
                newCase.Reason1__c = 'TIDS';
                newCase.Status = 'Draft';
                isAccreditationUploadCase = true;
            } else if (paramTopic == 'VR') {
                newCase.Subject = 'Closure - ' + con.Account.IATACode__c + ' - ' + con.Account.Name;
                newCase.CaseArea__c = 'Accreditation Process';
                newCase.Reason1__c = 'CLO - Closure';
                newCase.Status = 'Draft';
                newCase.Product_Category_ID__c = '-'; //Set Product Id so picked up by case assign to AM Regional queue
                isAccreditationUploadCase = true;
            }
        }


        String origin = ApexPages.currentPage().getParameters().get('origin');
        if (recordTypeId == FDScaseRecordTypeID && origin == 'Portal')
            isFDSRecordType = true;
        else
            isFDSRecordType = false;
        if (recordTypeId != '' && recordTypeId != null)
            newCase.RecordTypeId = recordTypeId;
        if (origin != '' && origin != null)
            newCase.Origin = origin;

        //Set the Variables default values
        isISSPortalPwCCase = false;
        isNewCase = true;
        isSISCase = false;
        isPWCCase = false;
        isAPCase = false;
        isIFAPCase = false;
        isPWCProfile = false;
        isKaleRole = false;
        isDPCUser = false;
        isACCA = false;
        isDPCAdmin = false;
        isEditMode = false;
        isGSAUser = false; //TF - SP9-C5
        isGSAOnly = false; //TF - SP9-C5
        isOnlineOSCARCase = false; //AS - AMS SP02
        isTravelAccreditation = false; //AS - AMS SP07
        disableCaseComments = false;
        additionalRecipients = '';
        runningUserId = UserInfo.getUserId();
        //Verify User Profile
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        //Verify if user is a PWC profile
        if (profileName.startsWith('ISS Portal PwC')) {  isPWCProfile = true; }
        if (profileName.startsWith('ISS Portal DPC Admin') ) {  isDPCUser = true; }
        if (profileName.startsWith('ISS Portal Agency') ) {  isAgencyUser = true; }
        if (profileName.startsWith('ISS Portal GSA') ) {  isGSAUser = true; }

        //Verify if the case is an SIS case
        if (recordTypeName == 'Cases - SIS Help Desk') {
            isSISCase = true;
        }

        //Verify User Role
        Id roleId = userinfo.getUserRoleId();
        String profileRole;
        try {
            profileRole = [Select Id, Name from UserRole where Id = :roleId].Name;
        } catch (Exception e) {
            profileRole = '';
        }
        //Verify if user is a Kale role
        if (profileRole.startsWith('Kale Application Support')) {  isKaleRole = true; }
        System.debug('xx2 caseId ' + ApexPages.currentPage().getParameters().get('caseId'));
        //Query case information and verify case characteristics
        if (ApexPages.currentPage().getParameters().containsKey('caseId')) {
            string caseId = ApexPages.currentPage().getParameters().get('caseId');
            newCase = DAL_ISSP.getCase(caseId);

            //AS - SP10
            if (isDPCInvestigateMode && caseType == 'DPCSR')
                isEditMode = true;


            //Survey Handle 
            mySurveyCompletedVariable  = false ;
            //RN-INC428791 - remove live agent chat rt
            List<Instant_Surveys__c> Survey_List = new List<Instant_Surveys__c>([SELECT Case_ID__c
                    FROM Instant_Surveys__c
                    WHERE Relationship_to_Case__c = :newCase.Id and recordType.developername != 'Live_Agent_Chat']);
            if (Survey_List != null && Survey_List.size() > 0) {
                mySurveyCompletedVariable = true ;
            }


                        //Content Related ListHandle
                        isDisplay_ContentTL = false ;
                    ContentDistribution_List = new List<ContentDistribution>([SELECT ContentDocumentId, ContentVersionId
                                                                      FROM ContentDistribution
                                                                      WHERE RelatedRecordId =: newCase.Id]);
                        System.debug('xx2 ContentDistribution_List '+ContentDistribution_List);

            if (ContentDistribution_List != null && ContentDistribution_List.size() > 0) {
                isDisplay_ContentTL = true ;
                Set<Id> cdIds_set = new Set<Id>();
                for (ContentDistribution cd : ContentDistribution_List) {
                    cdIds_set.add(cd.ContentVersionId);
                }
                tmpContentVersion_Lst =
                    new List<ContentVersion >([ select id, CreatedDate, Title, Description, FileType, OwnerId, Owner.Name, VersionNumber , Country_visibilty__c , User_status_access__c, Region__c, TagCsv , ContentSize, Language__c, ContentDocumentId, Document_Category__c, Country_of_publication__c , ContentUrl
                                                From ContentVersion
                                                where Id IN: cdIds_set ]) ;

            }
            //TF - link to AP Joining form
            //AS - link to Online Pax Accreditation form (only if case contact equals logged in user)
            system.debug('record type: ' + newCase.RecordType.Name);
            if (newCase.RecordType.Name == 'IDFS Airline Participation Process' || newCase.RecordType.Name == 'SAAM' || newCase.RecordType.Name == 'OSCAR Communication') {
                List <AMS_Pax_Accreditation_Form__c> amsList = [SELECT Id, Operation_Type__c FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :caseId];
                if (!amsList.isEmpty()) {
                    isOnlineOSCARCase = true; //SAAM, OSCAR case has associated online form and so was submitted via Portal (cannot use case origin since converted Case Queries also have Origin=Portal)
                    if (amsList[0].Operation_Type__c != null && amsList[0].Operation_Type__c.StartsWith('Travel_Agent')) {
                        isTravelAccreditation = true;
                    }
                }

                system.debug('status: ' + newCase.Status);
                if (newCase.Status == 'Draft' || newCase.Status == 'Open - EDMC' || newCase.Status == 'Pending customer' || newCase.Status == 'Return application to customer') {
                    List <AP_Process_Form__c> apList = [SELECT Id FROM AP_Process_Form__c WHERE Case__c = :caseId];

                    system.debug('apList: ' + apList);
                    if (!apList.isEmpty()) {
                        User myUser = [select Id, ContactId from User where Id = :Userinfo.getUserId()];
                        if (myUser.ContactId != null) {
                            List <Portal_Application_Right__c> appRightList = [Select Id From Portal_Application_Right__c
                                    where Contact__c = :myUser.ContactId and
                                                       Right__c = 'Access Granted'  and
                                                                  Portal_Application__c IN (:AIRLINE_PARTICIPATION_PORTAL_SERVICE, :AIRLINE_PARTICIPATION_CHANGE_PORTAL_SERVICE, :AIRLINE_PARTICIPATION_BANK_CHANGE_PORTAL_SERVICE)];
                            system.debug('appRightList: ' + appRightList);
                            if (!appRightList.isEmpty()) {
                                showAP = true;
                            }
                        }
                    }

                    if (!amsList.isEmpty() || newCase.Status == 'Open - EDMC') { //For SAAM/OSCAR cases created internally show link to Online form even if no record yet created
                        User myUser = [select Id, ContactId from User where Id = :Userinfo.getUserId()];
                        if (myUser.ContactId != null) {
                            List <Portal_Application_Right__c> appRightList = [Select Id From Portal_Application_Right__c
                                    where Contact__c = :myUser.ContactId and
                                                       Right__c = 'Access Granted'  and
                                                                  Portal_Application__c = :AGENT_ACCREDITATION_PORTAL_SERVICE];
                            system.debug('appRightList: ' + appRightList);
                            if (!appRightList.isEmpty()) {
                                showAccreditation = true; //Show link to Online Accreditation form on OSCAR Comm, SAAM Case, but only if Draft
                            }
                        }
                    }
                }
            }

            finalArticleList = new List <FAQ__kav>();
            finalHowList = new List <How_To__kav>();//TF-sp2
            globalList = new List <articleWrapper>();//TF-sp2
            List <CaseArticle> caseArticleList = [SELECT Id, KnowledgeArticleId  FROM CaseArticle WHERE CaseId = :caseId];
            if (!caseArticleList.isEmpty()) {
                Set <Id> articleIdSet = new Set <Id>();
                Map <String, String> articleMap = new Map <String, String>();
                for (CaseArticle thisArticle : caseArticleList) {
                    articleIdSet.add(thisArticle.KnowledgeArticleId);
                }
                String currentLanguage = UserInfo.getLanguage();
                system.debug('currentLanguage: ' + currentLanguage);
                List <FAQ__kav> kList = [SELECT Id, ArticleNumber, CreatedDate, CreatedBy.Name,
                                         Language, LastModifiedDate, Title, KnowledgeArticleId,
                                         Summary, Answer__c, ArticleType
                                         FROM FAQ__kav
                                         WHERE PublishStatus = 'Online'
                                                 AND KnowledgeArticleId IN :articleIdSet];
                for (FAQ__kav thisVersion : kList) {
                    system.debug('ARTICLE LANGUAGE: ' + thisVersion.Language);
                    if (thisVersion.Language == currentLanguage) {
                        finalArticleList.add(thisVersion);
                        if (!articleMap.containsKey(thisVersion.KnowledgeArticleId)) {
                            system.debug('adding my language');
                            articleMap.put(thisVersion.KnowledgeArticleId, thisVersion.KnowledgeArticleId);
                            //TF-sp2
                            articleWrapper newArticle = new articleWrapper();
                            newArticle.articleId = thisVersion.KnowledgeArticleId;
                            newArticle.articleTitle = thisVersion.Title;
                            newArticle.articleText = thisVersion.Answer__c;
                            newArticle.articleType = 'FAQ';
                            globalList.add(newArticle);
                        }
                    }
                }
                for (FAQ__kav thisVersion : kList) {
                    if (!articleMap.containsKey(thisVersion.KnowledgeArticleId)) {
                        system.debug('article not there yet');
                        if (thisVersion.Language == 'en_US') {
                            system.debug('adding english');
                            finalArticleList.add(thisVersion);
                            articleMap.put(thisVersion.KnowledgeArticleId, thisVersion.KnowledgeArticleId);
                            //TF-sp2
                            articleWrapper newArticle = new articleWrapper();
                            newArticle.articleId = thisVersion.KnowledgeArticleId;
                            newArticle.articleTitle = thisVersion.Title;
                            newArticle.articleText = thisVersion.Answer__c;
                            newArticle.articleType = 'FAQ';
                            globalList.add(newArticle);
                        }
                    }
                }

                //TF-sp2
                List <How_To__kav> hList = [SELECT Id, ArticleNumber, CreatedDate, CreatedBy.Name,
                                            Language, LastModifiedDate, Title, KnowledgeArticleId,
                                            Instructions__c, ArticleType
                                            FROM How_To__kav
                                            WHERE PublishStatus = 'Online'
                                                    AND KnowledgeArticleId IN :articleIdSet];
                for (How_To__kav thisVersion : hList) {
                    system.debug('HOW TO LANGUAGE: ' + thisVersion.Language);
                    if (thisVersion.Language == currentLanguage) {
                        finalHowList.add(thisVersion);
                        if (!articleMap.containsKey(thisVersion.KnowledgeArticleId)) {
                            system.debug('adding my language to how to');
                            articleMap.put(thisVersion.KnowledgeArticleId, thisVersion.KnowledgeArticleId);
                            //TF-sp2
                            articleWrapper newArticle = new articleWrapper();
                            newArticle.articleId = thisVersion.KnowledgeArticleId;
                            newArticle.articleTitle = thisVersion.Title;
                            newArticle.articleText = thisVersion.Instructions__c;
                            newArticle.articleType = 'How To';
                            globalList.add(newArticle);
                        }
                    }
                }
                for (How_To__kav thisVersion : hList) {
                    if (!articleMap.containsKey(thisVersion.KnowledgeArticleId)) {
                        system.debug('how to not there yet');
                        if (thisVersion.Language == 'en_US') {
                            system.debug('adding english to how to');
                            finalHowList.add(thisVersion);
                            articleMap.put(thisVersion.KnowledgeArticleId, thisVersion.KnowledgeArticleId);
                            //TF-sp2
                            articleWrapper newArticle = new articleWrapper();
                            newArticle.articleId = thisVersion.KnowledgeArticleId;
                            newArticle.articleTitle = thisVersion.Title;
                            newArticle.articleText = thisVersion.Instructions__c;
                            newArticle.articleType = 'How To';
                            globalList.add(newArticle);
                        }
                    }
                }
            }

            isNewCase = false;
            //Verify if the case is an SIS case
            if (newCase.RecordType.name == 'Cases - SIS Help Desk') {
                isSISCase = true;
            }

            //Verify if the case is an IFAP case
            if (newCase.RecordType.name == 'IATA Financial Review') {
                isIFAPCase = true;
            }

            /*06/08/2014 Merge of 2 RTs ISS Portal PwC Edit + ISS Portal PwC => ISS Portal PwC - Gavriel
            if(newCase.RecordType.name=='ISS Portal PwC Edit'){ isPWCCase = true; }*/

            if (newCase.RecordType.Name == 'ISS Portal PwC' ||  newCase.RecordType.Name == 'ISS Portal PwC for IATA user') {
                isISSPortalPwCCase = true;
                isPWCCase = true;
            }
            //Verify if the case is an Airline participation case
            if (newCase.RecordType.name == 'IDFS Airline Participation Process') {isAPCase = true; }

            //Verify if the case is a OSCAR Communication or SAAM Case
            if (newCase.RecordType.name == 'SAAM' || newCase.RecordType.name == 'OSCAR Communication' || newCase.RecordType.name == 'SIDRA') {isOSCARCase = true;}


            //Verify the Role of the user that close the case -- INC260167 - Start
            if (newCase.Status == 'Closed') {
                List<Case> caseInfo = [SELECT id, WhoClosedCase__r.UserRole.Name, RecordType__c FROM Case where id = :caseID];
                String userRole;

                for (Case c : caseInfo) {
                    userRole =  c.WhoClosedCase__r.UserRole.Name;
                    recordTypeName = c.RecordType__c;
                }

                ClosedSurvey__c csValues = ClosedSurvey__c.getInstance(recordTypeName);

                if(csValues != null){
                    if(csValues.RolesAvailable__c.contains(userRole) || csValues.RolesAvailable__c.contains('All')){
                        isToShowSurveyBtn = true;
                    }
                }
            }
            // INC260167 - End
            if(isDPCUser ) {
                User myUser = [SELECT Id, Contact.AccountId, Contact.User_Portal_Status__c FROM User WHERE Id = :UserInfo.getUserId()];
                if(myUser.Contact.User_Portal_Status__c == 'Approved Admin') isDPCAdmin = true;
                accountId = myUser.Contact.AccountId;
                if(accountId == newCase.Account_Concerned__c && newCase.OwnerId != UserInfo.getUserId()) {
                    dpcCanAccept = true;
                }
                ISSP_DPC__c accaAccounts = ISSP_DPC__c.getValues('ACCA Accounts');
                List<Id> lsAccountIds = new List<Id>();
                // Boolean isIATA = false;
                if(accaAccounts.Value__c != null ) lsAccountIds = accaAccounts.Value__c.split(',');
                if(!lsAccountIds.isEmpty() && lsAccountIds.contains(accountId.Substring(0,15))) {isACCA = true;}

            }
        } else {
            if (isDPCUser) {
                // set the record type
                // if not IATA then we create a case using the new RT with the same layout (so far).
                List<ISSP_DPC__c> mcs = ISSP_DPC__c.getall().values();
                ISSP_DPC__c accaRoleIds = ISSP_DPC__c.getValues('ACCA Roles');
                ISSP_DPC__c accaAccounts = ISSP_DPC__c.getValues('ACCA Accounts');
                ISSP_DPC__c dpcRecordType = ISSP_DPC__c.getValues('DPC Recordtype');
                ISSP_DPC__c dpcSector = ISSP_DPC__c.getValues('DPC Sector');
                ISSP_DPC__c dpcCategory = ISSP_DPC__c.getValues('DPC Category');
                List<Id> lsAccountIds;
                Boolean isIATA = false;
                if(whoToContact == 'IATA') isIATA = true;
                if(!isIATA ) {
                    newCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Inter_DPCs');
                    newCase.Account_Concerned__c = whoToContact;
                }
                
                List<Account> lsAccounts = new List<Account>();
                if(accaRoleIds.Value__c != null && accaRoleIds.Value__c.contains(UserInfo.getUserRoleId().Substring(0,15))){
                    if(dpcRecordType.Value__c != null && dpcSector.Value__c != null && dpcCategory.Value__c != null) {
                        list<String> listRecordTypes = dpcRecordType.Value__c.split(',');
                        lsAccounts =
                            [SELECT Id, Name FROM Account
                            WHERE Recordtype.DeveloperName IN :listRecordTypes
                            AND Sector__c = :dpcSector.Value__c
                            AND Category__c = :dpcCategory.Value__c];
                    }
                } else {
                    if(accaAccounts.Value__c != null ) lsAccountIds = accaAccounts.Value__c.split(',');
                    if(lsAccountIds != null ) {
                        lsAccounts =
                            [SELECT Id, Name FROM Account
                            WHERE Id IN :lsAccountIds];
                    }
                }
                
                List<Contact> lsContacts = new list<Contact>();
                for (User user: [SELECT ContactId, Contact.Name, Contact.Email, Contact.AccountId
                        FROM User
                        WHERE isActive = true
                        AND Contact.AccountId IN :lsAccounts
                        AND Contact.User_Portal_Status__c IN ('Approved Admin', 'Approved User')
                        AND Contact.Status__c = 'Active']) {
                    lsContacts.add(user.contact);
                }

                JSONcontacts = JSON.serialize(lsContacts);
                System.debug(lsAccounts);
                newCase.ACCA_Owner__c = Userinfo.getUserId();

                System.debug(profileRole);

                this.lst_whoToContact = new list<SelectOption>();
                this.lst_whoToContact.add(new SelectOption('',''));
                Account iataAccount;
                for(Account a : lsAccounts) {
                    if (a.Id != this.con.AccountId) {
                        this.lst_whoToContact.add(new SelectOption(a.Id,a.Name));
                    }
                }
                this.lst_whoToContact.add(new SelectOption('IATA','IATA'));
            }

        }

        List_CaseComment = new List<CaseComment>([SELECT Id, ParentId, Parent.CaseNumber, CommentBody, IsPublished, CreatedDate, CreatedById , CreatedBy.Name , IsDeleted
                FROM CaseComment
                WHERE ParentId = :newCase.Id AND IsDeleted = false
                                 ORDER BY CreatedDate DESC]);

        List_CaseMilestones = new List<Case_Milestone__c>([
                    SELECT StatusName__c, Classification_Phase__c, Milestone_Date__c, Milestone_Length__c, End_Date__c, IsDeleted, Is_Milestone__c
                    FROM Case_Milestone__c
                    WHERE Case__c = :newCase.Id AND IsDeleted = false
                                    ORDER BY Milestone_Date__c ASC
                ]);

        //basto1p
        statusValMapped=getFieldMappedValue(ISSP_Case.STATUS_FLD_NAME,newCase.Status);

        Map<String, String> objectsIds = new Map<String, String>();
        objectsIds.put('AMS_OSCAR__C', newCase.OSCAR__c);
        objectsIds.put('CASE', newCase.id);

        // If the process is null the use the reason on the casop.
        String process = '';
        if(newCase.Oscar__r.Process__c == null || (newCase.Oscar__r.Process__c != null && newCase.Oscar__r.Process__c == '')) {
            process = newCase.Reason1__c;
        } else {
            process = newCase.Oscar__r.Process__c;
        }

        progressBarHelper = new ANG_ProgressBarHelper(process, objectsIds);

        for (ANG_ProgressNode node : progressBarHelper.progressNodes) {
            if (node.titleTranslatable != null && node.titleTranslatable != '') {
                node.title = getCustomLabel(node.titleTranslatable);
            }
        }
    }

    @TestVisible private String getCustomLabel(String labelName) {
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        output.expressions.value = '{!$Label.' + labelName + '}';
        return string.valueOf(output.value);
    }


    //basto1p
    public static String getFieldMappedValue(String filedName, String fieldValueToMapp){
        String returnVal=ISSP_Case.NO_FIELD_MAP;

        if (filedName!=null && fieldValueToMapp!=null){
            if ( filedName.equalsIgnoreCase(ISSP_Case.STATUS_FLD_NAME) && fieldValueToMapp.equals('Solution Provided')){
                returnVal=Label.ISSP_Solution_Provided;
            }
            /*
            else if (filedName.equalsIgnoreCase('CaseType') && fieldValueToMapp.equals('Solution Provided')){

            }
            */
        }
        return returnVal;
    }

    public List<SelectOption> getItems() {
        system.debug('LANGUAGE: ' + UserInfo.getLanguage());
        String currentLanguage = UserInfo.getLanguage();
        List<SelectOption> options = new List<SelectOption>();
        list<IATA_ISO_Country__c> isoList;
 
        if (currentLanguage == 'es') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Country_SP__c');
        } else if (currentLanguage == 'ko') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Contry_KR__c');
        } else if (currentLanguage == 'zh_CN') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Country_ZH__c');
        } else if (currentLanguage == 'pt_BR') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Country_PT__c');
        } else if (currentLanguage == 'fr') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Country_FR__c');
        } else if (currentLanguage == 'ja') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Country_JP__c');
        } else if (currentLanguage == 'it') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Country_IT__c');
        } else {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'Name');
        }
        options.add(new SelectOption('', '--None--'));
        for (IATA_ISO_Country__c iso : isoList) {
            if (currentLanguage == 'es') {
                if (iso.IATA_Country_SP__c != null)
                    options.add(new SelectOption(iso.Name, iso.IATA_Country_SP__c));
                else
                    options.add(new SelectOption(iso.Name, iso.Name));
            } else if (currentLanguage == 'ko') {
                if (iso.IATA_Contry_KR__c != null)
                    options.add(new SelectOption(iso.Name, iso.IATA_Contry_KR__c));
                else
                    options.add(new SelectOption(iso.Name, iso.Name));
            } else if (currentLanguage == 'zh_CN') {
                if (iso.IATA_Country_ZH__c != null)
                    options.add(new SelectOption(iso.Name, iso.IATA_Country_ZH__c));
                else
                    options.add(new SelectOption(iso.Name, iso.Name));
            } else if (currentLanguage == 'pt_BR') {
                if (iso.IATA_Country_PT__c != null)
                    options.add(new SelectOption(iso.Name, iso.IATA_Country_PT__c));
                else
                    options.add(new SelectOption(iso.Name, iso.Name));
            } else if (currentLanguage == 'fr') {
                if (iso.IATA_Country_FR__c != null)
                    options.add(new SelectOption(iso.Name, iso.IATA_Country_FR__c));
                else
                    options.add(new SelectOption(iso.Name, iso.Name));
            } else if (currentLanguage == 'ja') {
                if (iso.IATA_Country_JP__c != null)
                    options.add(new SelectOption(iso.Name, iso.IATA_Country_JP__c));
                else
                    options.add(new SelectOption(iso.Name, iso.Name));
            } else if (currentLanguage == 'it') {
                if (iso.IATA_Country_IT__c != null)
                    options.add(new SelectOption(iso.Name, iso.IATA_Country_IT__c));
                else
                    options.add(new SelectOption(iso.Name, iso.Name));
            } else {
                options.add(new SelectOption(iso.Name, iso.Name));
            }
            //options.add(new SelectOption(iso.Name,iso.Name));
        }
        return options;
    }

    //TF - SP9-C5
    public List<SelectOption> getAirlines() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        User myUser = [SELECT Id, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        accountId = myUser.Contact.AccountId;
        List <Services_Rendered__c> servicesList = [SELECT Id, Services_Rendered_to_Airline__r.Site, Services_Rendered_to_Airline__r.Name,
                                    Services_Rendered_to_Airline__r.IATACode__c
                                    FROM Services_Rendered__c WHERE Services_Rendered_By__c = :accountId];
        system.debug('ACCOUNT ID: ' + accountId);
        system.debug('servicesList: ' + servicesList);
        if (!servicesList.isEmpty()) {
            for (Services_Rendered__c thisService : servicesList) {
                system.debug('adding 1: ' + thisService.Services_Rendered_to_Airline__r.Site + ' : ' + thisService.Services_Rendered_to_Airline__r.Name);
                options.add(new SelectOption(thisService.Services_Rendered_to_Airline__r.Site, thisService.Services_Rendered_to_Airline__r.Name));
            }
        }
        return options;
    }

    public Pagereference edit() {
        isEditMode = true;
        return null;
    }

    public Pagereference save() {
        //TF - SP9-C5
        system.debug('newCase.Classification_SIS__c: ' + newCase.Classification_SIS__c);
        system.debug('newCase.Defect_Issue__c: ' + newCase.Defect_Issue__c);
        system.debug('newCase.Type: ' + newCase.Type);
        system.debug('isGSAOnly: ' + isGSAOnly);
        //system.debug('IATAcode__c: ' + newCase.IATAcode__c);
        system.debug('isGSAUser: ' + isGSAUser);
        system.debug('isFDSRecordType: ' + isFDSRecordType);
        system.debug('AccountId: ' + accountId);

        //DPC
        if(isDPCUser) {
            Boolean isIATA = false;
            if(whoToContact == 'IATA') isIATA = true;
            if(!isIATA ) {
                newCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Inter_DPCs');
                newCase.Account_Concerned__c = whoToContact;
            } else {
                newCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Service_Request');
            }
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            newCase.setOptions(dmo);
        }

        if (!isGSAOnly && (newCase.IATAcode__c == '' || newCase.IATAcode__c == null) && isGSAUser && !isFDSRecordType) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.ISSP_Select_Airline);
            ApexPages.addMessage(myMsg);
            return null;
        } else if (isGSAOnly && accountId != null) {
            newCase.Account_Concerned__c = accountId;
            upsert newCase;
            return new Pagereference('/ISSP_Case?caseId=' + newCase.Id + commParam);
        } else {
            try {
                //get parameters
                String paramTopic = ApexPages.currentPage().getParameters().get('topic');
                String paramSubtopic = ApexPages.currentPage().getParameters().get('subtopic');
                if (paramTopic != null && paramSubtopic != null) {
                    newCase.Description = newCase.Description + '\n'
                                          + Label.ISSP_F2CTopic + ' - '
                                          + paramTopic.replace('+', ' ') + '\n'
                                          + Label.ISSP_F2CSubTopic + ' - '
                                          + paramSubtopic.replace('+', ' ');

                }

                upsert newCase;

                if(isDPCUser && whoToContact != 'IATA') {
                    addListCCOthersToDPC(this.additionalRecipients);
                }
                /**
                popContact();
                String typeOfProcess = '';
                if (paramTopic == 'VR'){
                    //P,C,R,I,Q,D -> VR.1.0
                    //outros -> VR.1.0.CA
                    //Map<String, String> mLocationClassTypes = new Map<String, String>{'P'=>'P','C'=>'C','R'=>'R','I'=>'I','Q'=>'Q','D'=>'D'};

                    if(mVR_LocationClassTypes.containsKey(con.Account.Location_Class__c)   ){
                        typeOfProcess = AMS_RecordCreatorWebservice.NEWVR_PV;
                    }else{
                        typeOfProcess = AMS_RecordCreatorWebservice.NEWVRCA_PV;
                    }
                }

                System.debug('con.Account.Location_Class__c: ' + con.Account.Location_Class__c);
                System.debug('typeOfProcess: ' + typeOfProcess);


                if (newCase.RecordTypeId == OSCAR_RECORD_TYPE_ID && paramTopic == 'VR'){
                    AMS_RecordCreatorWebservice.createAccreditation(con.AccountId, AMS_RecordCreatorWebservice.EMPTYACCREDITATIONID, typeOfProcess, newCase.Id);
                }
                **/

                //PageReference pr = new Pagereference('/ISSP_Case?caseId='+newCase.Id);
                //pr.setRedirect(true);
                //return pr;
                return new Pagereference('/ISSP_Case?caseId=' + newCase.Id + commParam);
            } catch (DmlException ex) {
                ApexPages.addMessages(ex);
            }
            return null;
        }

    }

    public Pagereference saveAttach() {

        system.debug('saveAttach AccountId: ' + accountId);

        //DPC
        if(isDPCUser) {
            Boolean isIATA = false;
            if(whoToContact == 'IATA') isIATA = true;
            if(!isIATA ) {
                newCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Inter_DPCs');
                newCase.Account_Concerned__c = whoToContact;
            } else {
                newCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Service_Request');
            }
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            newCase.setOptions(dmo);
        }

        // CNS
        if(con!=null && con.Account.RecordType.DeveloperName == 'IATA_Agency' && con.Account.CNS_Account__c == true && newCase.CaseArea__c == 'Accreditation Process') {
            newCase.CNSCase__c = true;
            newCase.Groups__c = 'CNS Team';
        }

        //TF - SP9-C5
        if (!isGSAOnly && (newCase.IATAcode__c == '' || newCase.IATAcode__c == null) && isGSAUser && !isFDSRecordType) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.ISSP_Select_Airline);
            ApexPages.addMessage(myMsg);
            return null;
        } else if (isGSAOnly && accountId != null) {
            newCase.Account_Concerned__c = accountId;
            upsert newCase;
            return new Pagereference('/ISSP_Case?caseId=' + newCase.Id + commParam);
        } else {
            //get parameters
            String paramTopic = ApexPages.currentPage().getParameters().get('topic');
            String paramSubtopic = ApexPages.currentPage().getParameters().get('subtopic');
            if (paramTopic != null && paramSubtopic != null) {
                newCase.Description = newCase.Description + '\n'
                                      + Label.ISSP_F2CTopic + ' - '
                                      + paramTopic.replace('+', ' ') + '\n'
                                      + Label.ISSP_F2CSubTopic + ' - '
                                      + paramSubtopic.replace('+', ' ');

            }

            try {
                upsert newCase;
                SYSTEM.DEBUG('ATTACHING file');

                /**
                popContact();
                String typeOfProcess = '';
                if (paramTopic == 'VR'){
                    //P,C,R,I,Q,D -> VR.1.0
                    //outros -> VR.1.0.CA

                    if(mVR_LocationClassTypes.containsKey(con.Account.Location_Class__c)   ){
                        typeOfProcess = AMS_RecordCreatorWebservice.NEWVR_PV;
                    }else{
                        typeOfProcess = AMS_RecordCreatorWebservice.NEWVRCA_PV;
                    }
                }

                System.debug('con.Account.Location_Class__c: ' + con.Account.Location_Class__c);
                System.debug('typeOfProcess: ' + typeOfProcess);

                if (newCase.RecordTypeId == OSCAR_RECORD_TYPE_ID && paramTopic == 'VR'){
                   AMS_RecordCreatorWebservice.createAccreditation(con.AccountId, AMS_RecordCreatorWebservice.EMPTYACCREDITATIONID, typeOfProcess, newCase.Id);
                }
                **/

                if(isDPCUser && whoToContact != 'IATA') {
                    addListCCOthersToDPC(this.additionalRecipients);
                }

                //return new Pagereference('/p/attach/NoteAttach?pid' + newCase.Id + '&retURL=%2FISSP_Case?caseId='+ newCase.Id);
                return new Pagereference('/ISSP_AddAttachment?caseid=' + newCase.Id + commParam);
            } catch (DmlException ex) {
                ApexPages.addMessages(ex);
            }
            return new Pagereference('/ISSP_AddAttachment?caseid=' + newCase.Id + commParam);
        }
    }

    public Pagereference cancel() {
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        string caseId = ApexPages.currentPage().getParameters().get('caseId');
        if (retURL != null && retURL != '')
            return new Pagereference(retURL);
        else if (caseId != null) {
            isEditMode = false;
            return new Pagereference('/ISSP_Case?caseId=' + caseId + commParam);
        } else {
            isEditMode = false;
            return new Pagereference('/ISSP_Homepage?mid=M0S1' + commParam);
            //return null;
        }
    }

    public Pagereference close() {
        string caseId = ApexPages.currentPage().getParameters().get('caseId');
        //closeCase = new Case();
        Case closeCase = [select Id  from Case where Id = :caseId];
        closeCase.ownerid = UserInfo.getUserId();
        closeCase.status = 'Closed';
        upsert closeCase ;
        //string retURL = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pageRef = ApexPages.currentPage();
        return new Pagereference('/ISSP_Case?caseId=' + closeCase.Id + commParam); //ApexPages.currentPage();
    }

    /**
        Take ownership of a case for DPC (except RT Inter DPC)
    **/
    public Pagereference DPCAccept() {
        newCase.ACCA_Owner__c = UserInfo.getUserId();
        if (caseType == 'DPCSR') {
            newCase.Status = 'DPC Investigating';
            User u = [SELECT ContactId FROM User WHERE User.Id = :UserInfo.getUserId()];
            Contact c = [SELECT Id FROM Contact WHERE Contact.Id = :u.ContactId];
            newCase.ContactId = c.Id; //Make the DPC user the contact for DPC SRs
        }

        // happens automatically (trigger?)
        //if (caseType=='ACR')
        //  newCase.Escalated_Status_ACCA__c = 'DPC Investigating';
        update newCase;
        newCase = DAL_ISSP.getCase(newCase.Id);
        isEditMode = true;
        return null;
    }

    /**
        Take ownership of a case for DPC (only RT Inter DPC)
    **/
    public PageReference InterDPCAccept() {
        Savepoint sp = Database.setSavepoint();
        try {
            //change owner
            newCase.OwnerId = UserInfo.getUserId();
            newCase.ACCA_Owner__c = UserInfo.getUserId();
            newCase.Status = 'In progress';
            update newCase;

        } catch (DMLException e) {
            Database.rollback(sp);
        }
        newCase = DAL_ISSP.getCase(newCase.Id);
        isEditMode = true;
        return null;
    }

    public Pagereference DPCCompleteDSR() {
        if (newCase.Planned_Start_CR__c == null && newCase.Planned_End_CR__c == null) {
            newCase.Status = 'Complete DSR';
            update newCase;
            newCase = DAL_ISSP.getCase(newCase.Id);
        }
        return null;
    }

    public Pagereference DPCCompleteScheduleDSR() {
        if (newCase.Planned_Start_CR__c != null && newCase.Planned_End_CR__c != null) {
            newCase.Status = 'Complete Schedule DSR';
            update newCase;
            newCase = DAL_ISSP.getCase(newCase.Id);
        }
        return null;
    }

    public Pagereference DPCSave() {
        System.DEBUG('DPC Save Planned start: ' + newCase.Planned_Start_CR__c);
        System.DEBUG('DPC Save Planned end: ' + newCase.Planned_End_CR__c);
        if (caseType == 'DPCSR') {
            if (newCase.Status == 'DPC investigating' && newCase.Planned_Start_CR__c != null && newCase.Planned_End_CR__c != null)
                newCase.Status = 'Scheduled';
            else
                newCase.Status = 'DPC investigating';
        }
        if (CaseType == 'ACR' && !validateACR())
            return null;

        try {
            update newCase;
            newCase = DAL_ISSP.getCase(newCase.Id);
            isEditMode = false;
            return null;
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }


    /**
    *@Author: Gavriel Talala - Balink
    *@Desc: Route the case to the appropriate Queue, According the the case region.
    */
    public Pagereference assignToIATA() {
        //Available queue names
        Set<String> queueNames = new Set<String> {'A&ME PwC', 'Americas PwC', 'Asia & Pacific PwC', 'China & North Asia PwC', 'Europe PwC'};
        Map<String, QueueSobject> mapRegionalQueue = new Map<String, QueueSobject>();
        //Build map queue.name -> queue
        for (QueueSobject queue : [Select Queue.Id, Queue.Name From QueueSobject Where Queue.Name in: queueNames]) {
            mapRegionalQueue.put(queue.Queue.Name, queue);
        }

        //Assigns queue according to region
        if (newCase.Region__c == 'Africa & Middle East') {
            if (mapRegionalQueue.get('A&ME PwC') != null) {
                newCase.ownerid = mapRegionalQueue.get('A&ME PwC').Queue.Id;
            }

        } else if (newCase.Region__c == 'Americas') {
            if (mapRegionalQueue.get('Americas PwC') != null) {
                newCase.ownerid = mapRegionalQueue.get('Americas PwC').Queue.Id;
            }

        } else if (newCase.Region__c == 'Asia & Pacific') {
            if (mapRegionalQueue.get('Asia & Pacific PwC') != null) {
                newCase.ownerid = mapRegionalQueue.get('Asia & Pacific PwC').Queue.Id;
            }

        } else if (newCase.Region__c == 'China & North Asia') {
            if (mapRegionalQueue.get('China & North Asia PwC') != null) {
                newCase.ownerid = mapRegionalQueue.get('China & North Asia PwC').Queue.Id;
            }

        } else if (newCase.Region__c == 'Europe') {
            if (mapRegionalQueue.get('Europe PwC') != null) {
                newCase.ownerid = mapRegionalQueue.get('Europe PwC').Queue.Id;
            }

        }
        update newCase;
        //return new Pagereference('/ISSP_Case?caseId=' + newCase.Id);
        return new Pagereference('/ISSP_CaseList?MainNav=Queries&subNav=MyQueries&mid=M4S3&admin=true' + commParam);
    }

    @TestVisible
    private boolean validateACR() {
        if (CaseDPCStatusACR >= 3.1) {
            if (newCase.Evaluation_Effort__c == null)
                newCase.Evaluation_Effort__c.addError(Label.ISSP_YouMustEnter);
            if (newCase.Specification_Effort__c == null)
                newCase.Specification_Effort__c.addError(Label.ISSP_YouMustEnter);
            if (newCase.Coding_Effort__c == null)
                newCase.Coding_Effort__c.addError(Label.ISSP_YouMustEnter);
            if (newCase.Unit_Test_Effort__c == null)
                newCase.Unit_Test_Effort__c.addError(Label.ISSP_YouMustEnter);
            if (newCase.System_Test_Effort__c == null)
                newCase.System_Test_Effort__c.addError(Label.ISSP_YouMustEnter);
            if (newCase.QA_Effort__c == null)
                newCase.QA_Effort__c.addError(Label.ISSP_YouMustEnter);
            if (newCase.Documentation_Effort__c == null)
                newCase.Documentation_Effort__c.addError(Label.ISSP_YouMustEnter);
            if (newCase.Implementation_Effort__c == null)
                newCase.Implementation_Effort__c.addError(Label.ISSP_YouMustEnter);
            if (newCase.Estimated_Total_Person_days__c == null)
                newCase.Estimated_Total_Person_days__c.addError(Label.ISSP_YouMustEnter);
            if (newCase.Estimated_Total_Development_Cost__c == null)
                newCase.Estimated_Total_Development_Cost__c.addError(Label.ISSP_YouMustEnter);

            if (newCase.Evaluation_Effort__c == null        || newCase.Specification_Effort__c == null  ||
                    newCase.Coding_Effort__c == null            || newCase.Unit_Test_Effort__c == null      ||
                    newCase.System_Test_Effort__c == null       || newCase.QA_Effort__c == null             ||
                    newCase.Documentation_Effort__c == null     || newCase.Implementation_Effort__c == null ||
                    newCase.Estimated_Total_Person_days__c == null || newCase.Estimated_Total_Development_Cost__c == null)
            { return false; }

            if (CaseDPCStatusACR >= 6.1) {
                if (newCase.Planned_Implementation_Date__c == null)
                    newCase.Planned_Implementation_Date__c.addError(Label.ISSP_YouMustEnter);
                if (newCase.Planned_Documentation_Date__c == null)
                    newCase.Planned_Documentation_Date__c.addError(Label.ISSP_YouMustEnter);

                if (newCase.Planned_Documentation_Date__c == null || newCase.Planned_Implementation_Date__c == null) {
                    system.debug('DPC ACR Status 6.1: ' + CaseDPCStatusACR);
                    return false;
                }
            }

            if (CaseDPCStatusACR >= 7.0) {
                if (newCase.Documentation_Complete__c == null)
                    newCase.Documentation_Complete__c.addError(Label.ISSP_YouMustEnter);
                if (newCase.Deployment_date_to_acca__c == null)
                    newCase.Deployment_date_to_acca__c.addError(Label.ISSP_YouMustEnter);

                if (newCase.Documentation_Complete__c == null || newCase.Deployment_date_to_acca__c == null) {
                    system.debug('DPC ACR Status 7.0: ' + CaseDPCStatusACR);
                    return false;
                }
            }
        }
        return true;
    }

    public void changeDpcOwner() {
        update newCase;
    }

    private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        system.debug('user.ContactId ' + user.ContactId);
        con = DAL_ISSP.getContact(user.ContactId);
    }

    public PageReference getSelectArtical() {

        string artid = ApexPages.currentPage().getParameters().get('artid');
        system.debug('ARTICLE ID: ' + artid);
        String currentLanguage = UserInfo.getLanguage();
        Boolean isArticalSelected = false;

        //TF-sp2
        for (articleWrapper thisArticle : globalList) {
            if (thisArticle.articleId == artid) {
                selectedArtical = thisArticle;
            }
        }
        /*
        for(FAQ__kav myFaq : finalArticleList){
        if(myFaq.KnowledgeArticleId == artid) {
        if (myFaq.Language == currentLanguage){
        selectedArtical = myFaq;
        isArticalSelected = true;
        system.debug('FOUND MY LANGUAGE');
        //createArticleStatisticsRecords(selectedArtical, ENV.ArticleStatType.View);
        }
        break;
        }
        }
        if (!isArticalSelected){
        for(FAQ__kav myFaq : finalArticleList){
        if(myFaq.KnowledgeArticleId == artid) {
        if (myFaq.Language == 'en_US'){
        selectedArtical = myFaq;
        isArticalSelected = true;
        system.debug('FOUND OTHER LANGUAGE');
        //createArticleStatisticsRecords(selectedArtical, ENV.ArticleStatType.View);
        }
        break;
        }
        }
        }
        */
        system.debug('FOUND THIS: ' + selectedArtical.articleText);
        return null;

    }

    //TF-sp2
    public class articleWrapper {
        public String articleId {get; set;}
        public String articleTitle {get; set;}
        public String articleText {get; set;}
        public String articleType {get; set;}
        public String articleLang {get; set;}
    }

    public Pagereference AddComment() {
        PageReference p = new PageReference('/apex/ISSP_AddComment?caseId=' + ApexPages.currentPage().getParameters().get('caseId') + commParam);
        p.setRedirect(true);
        return p;
    }

    public Id getAMSRegionalQueue() {
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

    public List<SelectOption> getCaseTypeItems() {
        List<SelectOption> options = new List<SelectOption>();

        if (caseType == 'IATASR') {
            options.add(new SelectOption('IATA SERVICE REQUEST', 'IATA SERVICE REQUEST'));
        } else if (newCase.CaseArea__c == 'ICH') {
            options.add(new SelectOption('', '- None -'));
            options.add(new SelectOption('ICH Finance', 'ICH Finance'));
            options.add(new SelectOption('ICH General', 'ICH General'));
            options.add(new SelectOption('ICH Membership', 'ICH Membership'));
            options.add(new SelectOption('ICH Operations', 'ICH Operations'));
        } else If (newCase.CaseArea__c == 'SIS') {
            options.add(new SelectOption('', '- None -'));
            options.add(new SelectOption('SIS Feature Request', 'SIS Feature Request'));
            options.add(new SelectOption('SIS Member Profile Update', 'SIS Member Profile Update'));
            options.add(new SelectOption('SIS Membership', 'SIS Membership'));
            options.add(new SelectOption('SIS Question/Problem', 'SIS Question/Problem'));

        } else {
            options.add(new SelectOption('', '- None -'));
            options.add(new SelectOption('SIS Feature Request', 'SIS Feature Request'));
            options.add(new SelectOption('SIS Member Profile Update', 'SIS Member Profile Update'));
            options.add(new SelectOption('SIS Membership', 'SIS Membership'));
            options.add(new SelectOption('SIS Question/Problem', 'SIS Question/Problem'));
            options.add(new SelectOption('ICH Finance', 'ICH Finance'));
            options.add(new SelectOption('ICH General', 'ICH General'));
            options.add(new SelectOption('ICH Membership', 'ICH Membership'));
            options.add(new SelectOption('ICH Operations', 'ICH Operations'));
        }

        return options;
    }

    public List<SelectOption> getCaseClassificationItems() {
        String cType;

        List<SelectOption> options = new List<SelectOption>();
        Set<SelectOption> uniqueOptions = new Set<SelectOption>();
        List<Priority_Mapping__c> lmappings = new List<Priority_Mapping__c>();

        if (newCase.CaseArea__c == 'ICH')
            lmappings = [Select Case_Type__c, Case_Classification__c, Case_Reason__c from Priority_Mapping__c where Visible_in_ISS_Portal__c = true AND Application__c = 'ICH Help Desk'];
        else if (newCase.CaseArea__c == 'SIS')
            lmappings = [Select Case_Type__c, Case_Classification__c, Case_Reason__c from Priority_Mapping__c where Visible_in_ISS_Portal__c = true AND Application__c = 'SIS Help Desk'];

        caseTypeSelection = Apexpages.currentPage().getParameters().get('caseTypeSelection');

        if (caseTypeSelection == null) {
            cType = caseTypeSelectionInit; //Coming from constructor when set from FAQ2Case
        } else {
            cType = caseTypeSelection;
        }


        if (lmappings.size() > 0 && lmappings <> null) {
            for (Priority_Mapping__c pm : lmappings) {
                if (pm.Case_Type__c == cType) {
                    uniqueOptions.add(new SelectOption(pm.Case_Classification__c, pm.Case_Classification__c));
                }
            }
        }

        if (uniqueOptions.contains(new SelectOption('Other', 'Other'))) {
            uniqueOptions.remove(new SelectOption('Other', 'Other'));
            options.addAll(uniqueOptions);
            options.sort();
            options.add(new SelectOption('Other', 'Other'));
        } else {
            options.addAll(uniqueOptions);
            options.sort();
        }


        if (options.size() >= 2) {
            options.add(0, new SelectOption('', '- None -'));
        }

        if (options.size() == 0) {
            options.add(new SelectOption('', '- None -'));
        }

        return options;
    }

    public List<SelectOption> getCaseDefectItems() {

        List<SelectOption> options = new List<SelectOption>();
        Set<SelectOption> uniqueOptions = new Set<SelectOption>();
        List<Priority_Mapping__c> lmappings = new List<Priority_Mapping__c>();
        caseClassificationSelection = Apexpages.currentPage().getParameters().get('caseClassificationSelection');

        if (newCase.CaseArea__c == 'ICH')
            lmappings = [Select Case_Type__c, Case_Classification__c, Case_Reason__c from Priority_Mapping__c where Visible_in_ISS_Portal__c = true AND Application__c = 'ICH Help Desk'];
        else if (newCase.CaseArea__c == 'SIS')
            lmappings = [Select Case_Type__c, Case_Classification__c, Case_Reason__c from Priority_Mapping__c where Visible_in_ISS_Portal__c = true AND Application__c = 'SIS Help Desk'];

        if (caseClassificationSelection != null) {
            if (lmappings.size() > 0 && lmappings <> null) {
                for (Priority_Mapping__c pm : lmappings) {
                    if (pm.Case_Classification__c == caseClassificationSelection) {
                        system.debug('should add defects ' + pm.Case_Reason__c);
                        uniqueOptions.add(new SelectOption(pm.Case_Reason__c, pm.Case_Reason__c));
                    }
                }
            }
        } else {

            if (uniqueOptions.size() == 0) {
                system.debug('uniqueOptions.size()   ' + uniqueOptions.size() );

                Schema.DescribeFieldResult fieldResult = Case.Defect_Issue__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

                for ( Schema.PicklistEntry f : ple) {
                    uniqueOptions.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            }
        }

        if (uniqueOptions.contains(new SelectOption('Other', 'Other'))) {
            uniqueOptions.remove(new SelectOption('Other', 'Other'));
            options.addAll(uniqueOptions);
            options.sort();
            options.add(new SelectOption('Other', 'Other'));
        } else {
            options.addAll(uniqueOptions);
            options.sort();
        }

        if (options.size() >= 2) {
            options.add(0, new SelectOption('', '- None -'));
        }

        if (options.size() == 0) {
            options.add(new SelectOption('', '- None -'));
        }

        return options;
    }

    public boolean getDisableCaseComments() {
        if(newCase != null) {
            if(newCase.Status == 'Draft') {
                return true;
            }

            if(isIFAPCase) {
                 DateTime closedDate = newCase.ClosedDate;
                if(closedDate==null) { //IFAP Case not yet closed
                    return false;
                } else {
                    //Disable Case Comments for Closed IFAP cases after x days
                    return closedDate.addDays(CLOSE_COMMENTS_AFTER_DAYS) < Date.today();
                }
            }
        }
         return false;
    }

    /**
        Add a list of AdditionalRecipients to current Case based on input emails
        but only for DPC users, so the user or contact to add must be in the same
        Account concerned
    **/
    public void addListCCOthersToDPC(String stringEmails) {
        // filter input emails
        Set<String> setEmail = new Set<String>();
        for(String s : stringEmails.split(',')) {
            String email = s.trim();
            if (!String.isBlank(email)) {
                setEmail.add(email);
            }
        }
        List<CaseTeamMember> lsCaseTeamMembers = new List<CaseTeamMember>();
        List<String> lsNewEmails = new List<String>();
        // only add Users from Account_Concerned__c
        List<User> lsUsers =
            [SELECT Id, Name, Email, AccountId, Contact.AccountId
            FROM User
            WHERE Email IN :setEmail
            AND isActive = true
            AND Contact.AccountId = :newCase.Account_Concerned__c];

        for(User user : lsUsers) {
            CaseTeamMember teammember = new CaseTeamMember(
                ParentId = newCase.Id,
                MemberId = user.Id,
                TeamRoleId = PARTNER_USER_ROLE);
            lsCaseTeamMembers.add(teammember);
            lsNewEmails.add(user.Email);
            setEmail.remove(user.Email);
        }
        // Find the contacts for the emails not found
        if (!setEmail.isEmpty()) {
            list<Contact> listContact = [
                SELECT Id,Email
                FROM Contact
                WHERE Email IN :setEmail
                AND User_Portal_Status__c IN ('Approved Admin', 'Approved User')
                AND Status__c = 'Active'
                AND AccountId = :newCase.Account_Concerned__c
                LIMIT 1];

            for(Contact contact : listContact) {
                CaseTeamMember teammember = new CaseTeamMember(
                    ParentId = newCase.Id,
                    MemberId = contact.Id,
                    TeamRoleId = PARTNER_USER_ROLE);
                lsCaseTeamMembers.add(teammember);
                lsNewEmails.add(contact.Email);
            }
        }

        // insert found users as a team member of the case
        Savepoint sp = Database.setSavepoint();
        try {
            this.e2cpFieldAccess = new E2CPFieldAccess(newCase.Id);
            // modify the ccother field in the case before inserting the new team members
            insertListAddressInE2CP_CCOthers(lsNewEmails);
            insert lsCaseTeamMembers;
            //finally sends an email to the full recipients list
            EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'New_DPC_Case'];
            sendMassEmail(newCase.Id,template.Id);

        } catch (DMLException e) {
            Database.rollback(sp);
        }
    }

    public static void sendMassEmail(Id caseId, Id templateId) {
        try {
            OrgWideEmailAddress orgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];
            list<User> listUsers = [SELECT Id, ContactId
                FROM User
                WHERE Id IN (SELECT MemberId FROM CaseTeamMember WHERE ParentId = :caseId)];

            List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
            for(User user : listUsers) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(orgAddress.Id);
                mail.setTargetObjectId(user.ContactId);
                mail.setWhatId(caseId);
                mail.setUseSignature(false);
                mail.setBccSender(false);
                mail.setSaveAsActivity(false);
                mail.setTemplateId(templateId);
                listEmail.add(mail);
            }

            if (!listEmail.isEmpty()) {
                Messaging.sendEmail(listEmail);
            }

        } catch (Exception e) {
            System.debug('Error sending an email sendMassEmail(' + caseId + ',' + templateId + ')');
        }
    }

    /**
        Add a new CC Other Contact to current Case
    **/
    public static final Id PARTNER_USER_ROLE = [SELECT id FROM CaseTeamRole WHERE Name = 'Partner User Role'].Id;
    public String inputccotheremail{get; set;}
    public void addCCOther() {
        String findEmail = this.inputccotheremail.trim();
        this.inputccotheremail = '';
        if (findEmail==null||findEmail=='') return;
        // find contact with input email
        list<Contact> listContact = [
            SELECT Id, Email, AccountId
            FROM Contact
            WHERE Email = :findEmail
            AND Status__c = 'Active'
            LIMIT 1];
        if (listContact.size()!=1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.ISSP_CCOther_Wrong_Emails.replace('{0}',findEmail)));
            return;
        }
        // insert found contact as a team member of the case
        Savepoint sp = Database.setSavepoint();
        try {
            Contact contact = listContact.get(0);
            Id memberId = contact.Id;
            if(isDPCUser) {
                // only add people from Account_Concerned__c by User
                list<User> listUser = [
                    SELECT Id, Contact.AccountId
                    FROM User
                    WHERE ContactId = :contact.Id
                    AND isActive = true
                    AND Contact.AccountId = :newCase.Account_Concerned__c
                    AND Contact.User_Portal_Status__c IN ('Approved Admin', 'Approved User') ];
                if (!listUser.isEmpty()) {
                    memberId = listUser[0].Id;
                } else {
                    if (contact.AccountId != newCase.Account_Concerned__c){
                        //if it's DPC, a user is not found and the selected contact is not in the
                        //same Account Concerned then we cannot continue
                        return;
                    }
                }
            }
            CaseTeamMember teammember = new CaseTeamMember(
                ParentId = this.newCase.Id,
                MemberId = memberId,
                TeamRoleId = PARTNER_USER_ROLE);
            System.debug(teammember);
            insert teammember;
            insertAddressInE2CP_CCOthers(contact.Email);
        } catch (DMLException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, findemail + ': ' + e.getDmlMessage(i)));
            }
            Database.rollback(sp);
        }
    }

    public String inputDelCCOther {get; set;}
    public void delCCOther() {
        Savepoint sp = Database.setSavepoint();
        try {
            String emailFiltered = this.inputDelCCOther==null? '': this.inputDelCCOther.trim();
            removeAddressInE2CP_CCOthers(emailFiltered);
            list<Contact> listContact = [SELECT Id, AccountId FROM Contact WHERE email = :emailFiltered];
            list<User> listUser = [SELECT Id, Contact.AccountId FROM User WHERE email = :emailFiltered];
            list<CaseTeamMember> listMember = [
                SELECT id
                FROM CaseTeamMember
                WHERE ParentId = :this.newCase.Id
                AND TeamRoleId = :PARTNER_USER_ROLE
                AND (MemberId IN :listContact
                    OR MemberId IN :listUser)];
            if (!listMember.isEmpty()) {
                delete listMember;
            }
        } catch (DMLException e) {
            System.debug('ERROR delTeamMember ' + e.getMessage());
            for (Integer i = 0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, this.inputDelCCOther + ': ' + e.getDmlMessage(i)));
            }
            Database.rollback(sp);
        }
    }

    public String getAdditionalCC() {
        if (this.e2cpFieldAccess==null) {
            return '';
        }
        return this.e2cpFieldAccess.getAdditionalCC();
    }

    /**
        Convert the cc emails string in a list
    **/
    public list<String> getListCCOther() {
        String additionalCC = getAdditionalCC();
        if (additionalCC==null) {
            return new list<String>();
        }
        set<String> setString = new set<String>(additionalCC.split(';'));
        setString.remove('');
        return new list<String>(setString);
    }
    /**
        Inserts a new email in the field Case.E2CP__AdditionalCC__c which is a
        list of emails in semi-colon separated string
    **/
    private void insertAddressInE2CP_CCOthers(String insertEmail) {
        String additionalCC = getAdditionalCC();
        set<String> setNews = new set<String>();
        setNews.add(insertEmail);
        for (String email: additionalCC.split(';')) {
            setNews.add(email.trim());
        }
        if (this.e2cpFieldAccess!= null) {
            this.e2cpFieldAccess.setAdditionalCC(String.join(new list<String>(setNews),';'));
        }
    }

    /**
        Inserts a list of emails in the field Case.E2CP__AdditionalCC__c
        Previous list is removed
    **/
    private void insertListAddressInE2CP_CCOthers(list<String> listInsertEmail) {
        if (listInsertEmail.isEmpty()) return;
        set<String> setNews = new set<String>();
        for (String email: listInsertEmail) {
            setNews.add(email.trim());
        }
        if (this.e2cpFieldAccess!= null) {
            this.e2cpFieldAccess.setAdditionalCC(String.join(new list<String>(setNews),';'));
        }
    }

    /**
        Removes an email in the field Case.E2CP__AdditionalCC__c which is a
        list of emails in semi-colon separated string
    **/
    private void removeAddressInE2CP_CCOthers(String address) {
        String additionalCC = getAdditionalCC();
        list<String> listNews = new list<String>();
        for (String email: additionalCC.split(';')) {
            String trimEmail = email.trim();
            if (trimEmail!=address) {
                listNews.add(trimEmail);
            }
        }
        if (this.e2cpFieldAccess!= null) {
            this.e2cpFieldAccess.setAdditionalCC(String.join(listNews,';'));
        }
    }

    public void updateCase() {
        update newCase;
    }

    public Boolean getIsInterDPCCase() {
        return newCase.RecordTypeId==INTER_DPC_RECORD_TYPE_ID;
    }

    public String getAccountConcernedName() {
        try {
            return [SELECT Name FROM Account WHERE Id = :newCase.Account_Concerned__c].Name;
        } catch (Exception e) {
            return '';
        }
    }

    public String getCaseContactName() {
        try {
            return [SELECT Name FROM Contact WHERE Id = :newCase.contactId].Name;
        } catch (Exception e) {
            return '';
        }
    }

    public list<CaseHistory> getListCaseHistory() {
        list<String> listExcluded;
        try {
            listExcluded = ISSP_DPC__c.getValues('History Excluded Fields').Value__c.split(',');
        } catch (Exception e) {
            listExcluded = new list<String>();
        }

        list<CaseHistory> listHistory = new list<CaseHistory>();
        for (CaseHistory history: [SELECT Id,Field,NewValue,OldValue,CreatedBy.Name,CreatedDate
            FROM CaseHistory
            WHERE CaseId = :newCase.Id
            AND Field NOT IN :listExcluded
            ORDER BY CreatedDate DESC]
        ) {
            try {
                Id tmp = (Id)history.newValue;//ignore lines with ids
            } catch(Exception e) {
                listHistory.add(history);
            }
        }
        return listHistory;
    }
    
    /**
        Allowed values for Status field when a DPC user is using this page
    **/
    public list<SelectOption> getListDPCValidCaseStatus() {
        set<String> setStatus = new set<String>{'Pending Feedback From Requestor','Action Needed'};
        setStatus.add(this.newCase.Status);
        list<SelectOption> listOptions = new list<SelectOption>();
        for (String status: setStatus) {
            listOptions.add(new SelectOption(status,status));
        }
        return listOptions;
    }
}