public without sharing class ISSP_Case {
    
    //private static String AGENT_ACCREDITATION_PORTAL_SERVICE = 'Become an IATA Accredited Agent';
    //private static String AIRLINE_PARTICIPATION_PORTAL_SERVICE = 'Join BSP / CASS';
    private static String AGENT_ACCREDITATION_PORTAL_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().AgencyAccreditation__c;
    private static String AIRLINE_PARTICIPATION_PORTAL_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().AirlineParticipation__c;
    private static String AIRLINE_PARTICIPATION_CHANGE_PORTAL_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().AirlineParticipation_MinorChange__c;
    private static String AIRLINE_PARTICIPATION_BANK_CHANGE_PORTAL_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().AirlineParticipation_Bank_Change__c;
    public Case newCase {get;set;}
    public boolean isISSPortalPwCCase{set;get;}
    public boolean isNewCase {get;set;}
    public boolean isSISCase {get;set;}
    public boolean isPWCCase {get;set;}
    public boolean isAPCase {get;set;}
    public boolean isOSCARCase {get;set;}
    public boolean isOnlineOSCARCase {get;set;}
    public boolean isTravelAccreditation {get;set;}
    public boolean isPWCProfile {get;set;}
    public boolean isKaleRole {get;set;}
    public boolean isDPCUser {get;set;}
    public boolean isAgencyUser {get;set;} //TF - SP9-C5
    public boolean isGSAUser {get;set;} //TF - SP9-C5
    public boolean isFDSRecordType {get;set;} //TF - SP9-C5
    public boolean isGSAOnly {get;set;} //TF - SP9-C5
    public String accountId {get;set;} //TF - SP9-C5
    public boolean DPCCaseScheduleWarning {get;set;}
    public boolean isEditMode {get;set;}
    public String sisCaseArea {get;set;}
   
    public Id runningUserId{get;set;}
    public List <FAQ__kav> finalArticleList {get;set;}
    //public FAQ__kav selectedArtical { get; set; }
    public List <How_To__kav> finalHowList {get;set;}//TF-sp2
    //public How_To__kav selectedHow { get; set; }//TF-sp2
    public List <articleWrapper> globalList {get; set;}//TF-sp2
    public articleWrapper selectedArtical { get; set; }
    public static Boolean showAP { get; set; }
    public static Boolean showAccreditation { get; set; }
    public List<CaseComment> List_CaseComment {get;set;}
    public List<Case_Milestone__c> List_CaseMilestones {get;set;}
    public String SurveyLanguage {get;set;}

	//Content Related List Handle
	public List<ContentDistribution> ContentDistribution_List {get;set;}
    public boolean isDisplay_ContentTL  {get;set;}
	public List<ContentVersion > tmpContentVersion_Lst  {get;set;}
    
    //SIS Lists
    //JQuery on ISSP_Case page was breaking deependent picklists, so need to build our own dynamic lists
    public List<SelectOption> caseTypeItems;
    public List<SelectOption> caseSubTypeItems;
    public List<SelectOption> caseClassificationItems;
    public List<SelectOption> caseDefectItems;
  
    public String caseTypeSelection {get;set;}
    private String caseTypeSelectionInit;
    public String caseClassificationSelection {get;set;}
    
    //Survey Handle
    public boolean mySurveyCompletedVariable  {get;set;}
    
    public static Boolean preventTrigger = false;
    
    public boolean isDPCInvestigateMode {get {
        return (caseType=='DPCSR' && (CaseStatus=='DPC_INVESTIGATING' || CaseStatus=='SCHEDULED'));}  }
    public boolean isDPCAccepted {get {
        return (caseType=='DPCSR' && caseStatus!='OPEN');}  }
    public boolean isACRAccepted {get {
        return (caseType=='ACR' && newCase.Escalated_Status_ACCA__c!=null && newCase.ACCA_Owner__c != null);}    }
    
    public String CaseType { get {return ISSP_Constant.caseTypeMap.get(newCase.RecordType.Name);}   }
    public String CaseStatus { get {return ISSP_Constant.caseStatusMap.get(newCase.Status);}    }
    //public String CaseDPCStatus { get {return ISSP_Constant.caseStatusMap.get(newCase.Escalated_Status_ACCA__c);}   }
    
    public Decimal CaseStatusACR { get {return ISSP_Constant.caseStatusMap_ACR_Internal.get(newCase.Status);}    }
    public Decimal CaseDPCStatusACR { get {return ISSP_Constant.caseStatusMap_ACR_Portal.get(newCase.Escalated_Status_ACCA__c);}   }
    
    public PageReference pageLoad(){
        if(ApexPages.currentPage().getParameters().containsKey('caseId')){
            string caseId = ApexPages.currentPage().getParameters().get('caseId');
            newCase = DAL_ISSP.getCase(caseId);
            if (!newCase.Visible_on_ISS_Portal__c){
                PageReference pr = new PageReference('/ISSP_Homepage');
                return pr;
            }
        }
        return null;
    }
    
    public ISSP_Case(){
	System.debug('xx2 Controller ');
        newCase = new Case();
        
        showAP = false;
        showAccreditation = false;
        SurveyLanguage = UserInfo.getLanguage() ;
        //TF - SP9-C5
        ID FDScaseRecordTypeID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('FDS_ICCS_Email_to_Case');
        String recordTypeId = ApexPages.currentPage().getParameters().get('recordTypeId');
        
        //AS - SP10; get the recordtyype name for new cases, esp. for SIS
        String recordTypeName;
        If(recordTypeId <> null) {
            recordTypeName = [SELECT DeveloperName, Name FROM RecordType WHERE Id = :recordTypeId].Name;
        }
 
 		//get parameters
		String paramTopic = ApexPages.currentPage().getParameters().get('topic');
		String paramSubtopic = ApexPages.currentPage().getParameters().get('subtopic');
		if (paramTopic != null && paramSubtopic != null)
		{
			//newCase.Description = Label.ISSP_F2CTopic + ' - ' 
                              //+ paramTopic.replace('+',' ') + '\n' 
                              //+ Label.ISSP_F2CSubTopic + ' - '  
                              //+ paramSubtopic.replace('+',' ');
            
            newCase.Type=EncodingUtil.urlDecode(paramSubtopic, 'UTF-8');
            caseTypeSelectionInit = EncodingUtil.urlDecode(paramSubtopic, 'UTF-8');
            
            if(paramTopic.startsWith('SIS')) {
                newCase.CaseArea__c='SIS';
             } else {
                newCase.CaseArea__c='ICH';
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
        isPWCProfile = false;
        isKaleRole = false;
        isDPCUser = false;
        isEditMode = false;
        isGSAUser = false; //TF - SP9-C5
        isGSAOnly = false; //TF - SP9-C5
        isOnlineOSCARCase = false; //AS - AMS SP02
        isTravelAccreditation = false; //AS - AMS SP07
        runningUserId = UserInfo.getUserId();
        //Verify User Profile
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //Verify if user is a PWC profile
        if(profileName.startsWith('ISS Portal PwC')){  isPWCProfile = true; }
        if(profileName.startsWith('ISS Portal DPC') ){  isDPCUser= true; }
        if(profileName.startsWith('ISS Portal Agency') ){  isAgencyUser= true; }
        if(profileName.startsWith('ISS Portal GSA') ){  isGSAUser= true; }
        
        //Verify if the case is an SIS case
        if(recordTypeName=='Cases - SIS Help Desk') {
            isSISCase = true;
        }
        
        //Verify User Role
        Id roleId = userinfo.getUserRoleId();
        String profileRole;
        try{
            profileRole=[Select Id,Name from UserRole where Id=:roleId].Name;
        }
        catch(Exception e){
            profileRole = '';
        }
        //Verify if user is a Kale role
        if(profileRole.startsWith('Kale Application Support')){  isKaleRole = true; }
        System.debug('xx2 caseId '+ApexPages.currentPage().getParameters().get('caseId'));
        //Query case information and verify case characteristics
        if(ApexPages.currentPage().getParameters().containsKey('caseId')){
            string caseId = ApexPages.currentPage().getParameters().get('caseId');
            newCase = DAL_ISSP.getCase(caseId);
			
			//AS - SP10            
            if(isDPCInvestigateMode && caseType=='DPCSR')
               isEditMode = true;
                
            
            //Survey Handle
            mySurveyCompletedVariable  = false ;
            List<Instant_Surveys__c> Survey_List = new List<Instant_Surveys__c>([SELECT Case_ID__c
                                                                                 FROM Instant_Surveys__c
                                                                                 WHERE Relationship_to_Case__c=:newCase.Id]);
            if (Survey_List != null && Survey_List.size() > 0)
            {
                mySurveyCompletedVariable = true ;
            }

			
			//Content Related ListHandle
			isDisplay_ContentTL = false ;
		    ContentDistribution_List = new List<ContentDistribution>([SELECT ContentDocumentId, ContentVersionId
																	  FROM ContentDistribution
																	  WHERE RelatedRecordId =: newCase.Id]);
			System.debug('xx2 ContentDistribution_List '+ContentDistribution_List);
			if(ContentDistribution_List != null && ContentDistribution_List.size() > 0)
            {
                isDisplay_ContentTL = true ; 
				Set<Id> cdIds_set = new Set<Id>();
				for (ContentDistribution cd :ContentDistribution_List)
				{
					cdIds_set.add(cd.ContentVersionId);
				}
				  tmpContentVersion_Lst =
					new List<ContentVersion >([ select id, CreatedDate, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId,Document_Category__c,Country_of_publication__c ,ContentUrl
												From ContentVersion 
												where Id IN: cdIds_set ]) ;

            }	
            //TF - link to AP Joining form
            //AS - link to Online Pax Accreditation form (only if case contact equals logged in user)
            system.debug('record type: ' + newCase.RecordType.Name);
            if (newCase.RecordType.Name == 'IDFS Airline Participation Process' || newCase.RecordType.Name == 'SAAM' || newCase.RecordType.Name == 'OSCAR Communication'){
                List <AMS_Pax_Accreditation_Form__c> amsList = [SELECT Id, Operation_Type__c FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :caseId];
                if (!amsList.isEmpty()){
                	isOnlineOSCARCase = true; //SAAM, OSCAR case has associated online form and so was submitted via Portal (cannot use case origin since converted Case Queries also have Origin=Portal)
                    if(amsList[0].Operation_Type__c.StartsWith('Travel_Agent')) {
                        isTravelAccreditation = true;
                    }
                }
                
                system.debug('status: ' + newCase.Status);
                if (newCase.Status == 'Draft' || newCase.Status == 'Pending customer'){
                    List <AP_Process_Form__c> apList = [SELECT Id FROM AP_Process_Form__c WHERE Case__c = :caseId];
   
                    system.debug('apList: ' + apList);
                    if (!apList.isEmpty()){
                        User myUser = [select Id,ContactId from User where Id =:Userinfo.getUserId()];
                        if (myUser.ContactId != null){
                            List <Portal_Application_Right__c> appRightList = [Select Id From Portal_Application_Right__c
                                                                               where Contact__c = :myUser.ContactId and
                                                                               Right__c = 'Access Granted'  and
                                                                               Portal_Application__c IN (:AIRLINE_PARTICIPATION_PORTAL_SERVICE,:AIRLINE_PARTICIPATION_CHANGE_PORTAL_SERVICE,:AIRLINE_PARTICIPATION_BANK_CHANGE_PORTAL_SERVICE)];
                            system.debug('appRightList: ' + appRightList);
                            if (!appRightList.isEmpty()){
                                showAP = true;
                            }
                        }
                    }
                    
                    if (!amsList.isEmpty()){
                        User myUser = [select Id,ContactId from User where Id =:Userinfo.getUserId()];
                        if (myUser.ContactId != null){
                            List <Portal_Application_Right__c> appRightList = [Select Id From Portal_Application_Right__c
                                                                               where Contact__c = :myUser.ContactId and
                                                                               Right__c = 'Access Granted'  and
                                                                               Portal_Application__c = :AGENT_ACCREDITATION_PORTAL_SERVICE];
                            system.debug('appRightList: ' + appRightList);
                            if (!appRightList.isEmpty()){
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
            if (!caseArticleList.isEmpty()){
                Set <Id> articleIdSet = new Set <Id>();
                Map <String, String> articleMap = new Map <String, String>();
                for (CaseArticle thisArticle : caseArticleList){
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
                for (FAQ__kav thisVersion : kList){
                    system.debug('ARTICLE LANGUAGE: ' + thisVersion.Language);
                    if (thisVersion.Language == currentLanguage){
                        finalArticleList.add(thisVersion);
                        if (!articleMap.containsKey(thisVersion.KnowledgeArticleId)){
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
                for (FAQ__kav thisVersion : kList){
                    if (!articleMap.containsKey(thisVersion.KnowledgeArticleId)){
                        system.debug('article not there yet');
                        if (thisVersion.Language == 'en_US'){
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
                for (How_To__kav thisVersion : hList){
                    system.debug('HOW TO LANGUAGE: ' + thisVersion.Language);
                    if (thisVersion.Language == currentLanguage){
                        finalHowList.add(thisVersion);
                        if (!articleMap.containsKey(thisVersion.KnowledgeArticleId)){
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
                for (How_To__kav thisVersion : hList){
                    if (!articleMap.containsKey(thisVersion.KnowledgeArticleId)){
                        system.debug('how to not there yet');
                        if (thisVersion.Language == 'en_US'){
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
            if(newCase.RecordType.name=='Cases - SIS Help Desk') {
                isSISCase = true;
            }
            
            /*06/08/2014 Merge of 2 RTs ISS Portal PwC Edit + ISS Portal PwC => ISS Portal PwC - Gavriel
if(newCase.RecordType.name=='ISS Portal PwC Edit'){ isPWCCase = true; }*/
            
            if(newCase.RecordType.Name == 'ISS Portal PwC'){
                isISSPortalPwCCase = true;
                isPWCCase = true;
            }
            //Verify if the case is an Airline participation case
            if(newCase.RecordType.name=='IDFS Airline Participation Process'){isAPCase = true; }
            
            //Verify if the case is a OSCAR Communication or SAAM Case
            if(newCase.RecordType.name=='SAAM' || newCase.RecordType.name=='OSCAR Communication'){isOSCARCase = true;}
            
        	} else {
            if (isDPCUser) {
                newCase.RecordTypeId = DAL_ISSP.getRecordTypeId('IATA_Service_Request');
                newCase.ACCA_Owner__c = Userinfo.getUserId();
            }
        }
        
        List_CaseComment = new List<CaseComment>([SELECT Id, ParentId, Parent.CaseNumber, CommentBody, IsPublished, CreatedDate, CreatedById , CreatedBy.Name , IsDeleted
                                                  FROM CaseComment
                                                  WHERE ParentId = :newCase.Id AND IsDeleted = false
                                                  ORDER BY CreatedDate DESC]);
        
        List_CaseMilestones = new List<Case_Milestone__c>([
            SELECT StatusName__c, Classification_Phase__c,Milestone_Date__c,Milestone_Length__c,End_Date__c,IsDeleted,Is_Milestone__c
            FROM Case_Milestone__c
            WHERE Case__c = :newCase.Id AND IsDeleted = false
            ORDER BY Milestone_Date__c ASC
        ]);

    }
    
    
    public List<SelectOption> getItems() {
        system.debug('LANGUAGE: ' + UserInfo.getLanguage());
        String currentLanguage = UserInfo.getLanguage();
        List<SelectOption> options = new List<SelectOption>();
        list<IATA_ISO_Country__c> isoList;
        /*list<IATA_ISO_Country__c> isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
from IATA_ISO_Country__c
where Case_BSP_Country__c!=null
and Case_BSP_Country__c!=''
order by Name];*/
        if (currentLanguage == 'es'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
                       IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                       IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                       from IATA_ISO_Country__c
                       where Case_BSP_Country__c!=null
                       and Case_BSP_Country__c!=''
                       order by IATA_Country_SP__c];
        }
        else if (currentLanguage == 'ko'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
                       IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                       IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                       from IATA_ISO_Country__c
                       where Case_BSP_Country__c!=null
                       and Case_BSP_Country__c!=''
                       order by IATA_Contry_KR__c];
        }
        else if (currentLanguage == 'zh_CN'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
                       IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                       IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                       from IATA_ISO_Country__c
                       where Case_BSP_Country__c!=null
                       and Case_BSP_Country__c!=''
                       order by IATA_Country_ZH__c];
        }
        else if (currentLanguage == 'pt_BR'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
                       IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                       IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                       from IATA_ISO_Country__c
                       where Case_BSP_Country__c!=null
                       and Case_BSP_Country__c!=''
                       order by IATA_Country_PT__c];
        }
        else if (currentLanguage == 'fr'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
                       IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                       IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                       from IATA_ISO_Country__c
                       where Case_BSP_Country__c!=null
                       and Case_BSP_Country__c!=''
                       order by IATA_Country_FR__c];
        }
        else if (currentLanguage == 'ja'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
                       IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                       IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                       from IATA_ISO_Country__c
                       where Case_BSP_Country__c!=null
                       and Case_BSP_Country__c!=''
                       order by IATA_Country_JP__c];
        }
        else if (currentLanguage == 'it'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
                       IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                       IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                       from IATA_ISO_Country__c
                       where Case_BSP_Country__c!=null
                       and Case_BSP_Country__c!=''
                       order by IATA_Country_IT__c];
        }
        else{
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
                       IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                       IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                       from IATA_ISO_Country__c
                       where Case_BSP_Country__c!=null
                       and Case_BSP_Country__c!=''
                       order by Name];
        }
        options.add(new SelectOption('', '--None--'));
        for(IATA_ISO_Country__c iso : isoList){
            if (currentLanguage == 'es'){
                if (iso.IATA_Country_SP__c != null)
                    options.add(new SelectOption(iso.Name,iso.IATA_Country_SP__c));
                else
                    options.add(new SelectOption(iso.Name,iso.Name));
            }
            else if (currentLanguage == 'ko'){
                if (iso.IATA_Contry_KR__c != null)
                    options.add(new SelectOption(iso.Name,iso.IATA_Contry_KR__c));
                else
                    options.add(new SelectOption(iso.Name,iso.Name));
            }
            else if (currentLanguage == 'zh_CN'){
                if (iso.IATA_Country_ZH__c != null)
                    options.add(new SelectOption(iso.Name,iso.IATA_Country_ZH__c));
                else
                    options.add(new SelectOption(iso.Name,iso.Name));
            }
            else if (currentLanguage == 'pt_BR'){
                if (iso.IATA_Country_PT__c != null)
                    options.add(new SelectOption(iso.Name,iso.IATA_Country_PT__c));
                else
                    options.add(new SelectOption(iso.Name,iso.Name));
            }
            else if (currentLanguage == 'fr'){
                if (iso.IATA_Country_FR__c != null)
                    options.add(new SelectOption(iso.Name,iso.IATA_Country_FR__c));
                else
                    options.add(new SelectOption(iso.Name,iso.Name));
            }
            else if (currentLanguage == 'ja'){
                if (iso.IATA_Country_JP__c != null)
                    options.add(new SelectOption(iso.Name,iso.IATA_Country_JP__c));
                else
                    options.add(new SelectOption(iso.Name,iso.Name));
            }
            else if (currentLanguage == 'it'){
                if (iso.IATA_Country_IT__c != null)
                    options.add(new SelectOption(iso.Name,iso.IATA_Country_IT__c));
                else
                    options.add(new SelectOption(iso.Name,iso.Name));
            }
            else{
                options.add(new SelectOption(iso.Name,iso.Name));
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
        if (!servicesList.isEmpty()){
            for (Services_Rendered__c thisService : servicesList){
                system.debug('adding 1: ' + thisService.Services_Rendered_to_Airline__r.Site + ' : ' + thisService.Services_Rendered_to_Airline__r.Name);
                options.add(new SelectOption(thisService.Services_Rendered_to_Airline__r.Site, thisService.Services_Rendered_to_Airline__r.Name));
            }
        }
        return options;
    }
    
    public Pagereference edit(){
        isEditMode = true;
        return null;
    }
    
    public Pagereference save(){
        //TF - SP9-C5
        system.debug('newCase.Classification_SIS__c: ' + newCase.Classification_SIS__c);
        system.debug('newCase.Defect_Issue__c: ' + newCase.Defect_Issue__c);
        system.debug('newCase.Type: ' + newCase.Type);
        system.debug('isGSAOnly: ' + isGSAOnly);
        //system.debug('IATAcode__c: ' + newCase.IATAcode__c);
        system.debug('isGSAUser: ' + isGSAUser);
        system.debug('isFDSRecordType: ' + isFDSRecordType);
        system.debug('AccountId: ' + accountId);
        if (!isGSAOnly && (newCase.IATAcode__c == '' || newCase.IATAcode__c == null) && isGSAUser && !isFDSRecordType){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.ISSP_Select_Airline);
            ApexPages.addMessage(myMsg);
            return null;
        }
        else if (isGSAOnly && accountId != null){
            newCase.Account_Concerned__c = accountId;
            upsert newCase;
            return new Pagereference('/ISSP_Case?caseId='+newCase.Id);
        }
        else{
            try {
				//get parameters
				String paramTopic = ApexPages.currentPage().getParameters().get('topic');
				String paramSubtopic = ApexPages.currentPage().getParameters().get('subtopic');
				if (paramTopic != null && paramSubtopic != null)
				{
					newCase.Description = newCase.Description + '\n' 
									  + Label.ISSP_F2CTopic + ' - ' 
									  + paramTopic.replace('+',' ') + '\n' 
									  + Label.ISSP_F2CSubTopic + ' - '  
									  + paramSubtopic.replace('+',' ');
            
				}
                upsert newCase;
                //PageReference pr = new Pagereference('/ISSP_Case?caseId='+newCase.Id);
     			//pr.setRedirect(true);
     			//return pr;
                return new Pagereference('/ISSP_Case?caseId='+newCase.Id);
            } catch (DmlException ex) {
                ApexPages.addMessages(ex);
            }
            return null;
        }
    }
    
    public Pagereference saveAttach(){
        //TF - SP9-C5
        if (!isGSAOnly && (newCase.IATAcode__c == '' || newCase.IATAcode__c == null) && isGSAUser && !isFDSRecordType){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.ISSP_Select_Airline);
            ApexPages.addMessage(myMsg);
            return null;
        }
        else if (isGSAOnly && accountId != null){
            newCase.Account_Concerned__c = accountId;
            upsert newCase;
            return new Pagereference('/ISSP_Case?caseId='+newCase.Id);
        }
        else{
			//get parameters
			String paramTopic = ApexPages.currentPage().getParameters().get('topic');
			String paramSubtopic = ApexPages.currentPage().getParameters().get('subtopic');
			if (paramTopic != null && paramSubtopic != null)
			{
				newCase.Description = newCase.Description + '\n' 
									+ Label.ISSP_F2CTopic + ' - ' 
									+ paramTopic.replace('+',' ') + '\n' 
									+ Label.ISSP_F2CSubTopic + ' - '  
									+ paramSubtopic.replace('+',' ');
            
			}
            upsert newCase;
            //return new Pagereference('/p/attach/NoteAttach?pid' + newCase.Id + '&retURL=%2FISSP_Case?caseId='+ newCase.Id);
            return new Pagereference('/ISSP_AddAttachment?caseid='+ newCase.Id);
        }
    }
    
    public Pagereference cancel(){
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        string caseId = ApexPages.currentPage().getParameters().get('caseId');
        if (retURL != null && retURL != '')
            return new Pagereference(retURL);
        else if (caseId != null) {
            isEditMode = false;
            return new Pagereference('/ISSP_Case?caseId='+caseId);
        } else {
            isEditMode = false;
            return new Pagereference('/ISSP_Homepage?mid=M0S1');
            //return null; 
        }
    }
    
    public Pagereference close(){
        string caseId = ApexPages.currentPage().getParameters().get('caseId');
        //closeCase = new Case();
        Case closeCase = [select Id  from Case where Id=:caseId];
        closeCase.ownerid = UserInfo.getUserId();
        closeCase.status = 'Closed';
        upsert closeCase ;
        //string retURL = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pageRef = ApexPages.currentPage();
        return new Pagereference('/ISSP_Case?caseId='+closeCase.Id);//ApexPages.currentPage();
    }
    
    public Pagereference DPCAccept() {
        newCase.ACCA_Owner__c = UserInfo.getUserId();
        if (caseType=='DPCSR') {
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
        if (caseType=='DPCSR') {
            if (newCase.Status == 'DPC investigating' && newCase.Planned_Start_CR__c != null && newCase.Planned_End_CR__c != null)
                newCase.Status = 'Scheduled';
            else 
                newCase.Status = 'DPC investigating';
        }
        if (CaseType=='ACR' && !validateACR())
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
    public Pagereference assignToIATA(){
        //Available queue names
        Set<String> queueNames = new Set<String>{'A&ME PwC','Americas PwC','Asia & Pacific PwC','China & North Asia PwC','Europe PwC'};
            Map<String,QueueSobject> mapRegionalQueue = new Map<String,QueueSobject>();
        //Build map queue.name -> queue
        for(QueueSobject queue : [Select Queue.Id,Queue.Name From QueueSobject Where Queue.Name in: queueNames]){
            mapRegionalQueue.put(queue.Queue.Name,queue);
        }
        
        //Assigns queue according to region
        if(newCase.Region__c == 'Africa & Middle East'){
            if(mapRegionalQueue.get('A&ME PwC') != null){
                newCase.ownerid = mapRegionalQueue.get('A&ME PwC').Queue.Id;
            }
            
        }
        else if(newCase.Region__c == 'Americas'){
            if(mapRegionalQueue.get('Americas PwC') != null){
                newCase.ownerid = mapRegionalQueue.get('Americas PwC').Queue.Id;
            }
            
        }
        else if(newCase.Region__c == 'Asia & Pacific'){
            if(mapRegionalQueue.get('Asia & Pacific PwC') != null){
                newCase.ownerid = mapRegionalQueue.get('Asia & Pacific PwC').Queue.Id;
            }
            
        }
        else if(newCase.Region__c == 'China & North Asia'){
            if(mapRegionalQueue.get('China & North Asia PwC') != null){
                newCase.ownerid = mapRegionalQueue.get('China & North Asia PwC').Queue.Id;
            }
            
        }
        else if(newCase.Region__c == 'Europe'){
            if(mapRegionalQueue.get('Europe PwC') != null){
                newCase.ownerid = mapRegionalQueue.get('Europe PwC').Queue.Id;
            }
            
        }
        update newCase;
        //return new Pagereference('/ISSP_Case?caseId=' + newCase.Id);
        return new Pagereference('/ISSP_CaseList?MainNav=Queries&subNav=MyQueries&mid=M4S3&admin=true');
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
    
    public void changeDpcOwner(){
        update newCase; 
        
    }
    
    public PageReference getSelectArtical() {
        
        string artid = ApexPages.currentPage().getParameters().get('artid');
        system.debug('ARTICLE ID: ' + artid);
        String currentLanguage = UserInfo.getLanguage();
        Boolean isArticalSelected = false;
        
        //TF-sp2
        for (articleWrapper thisArticle : globalList){
            if(thisArticle.articleId == artid) {
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
    public class articleWrapper{
        public String articleId {get; set;}
        public String articleTitle {get; set;}
        public String articleText {get; set;}
        public String articleType {get; set;}
        public String articleLang {get; set;}
    }
    
    public Pagereference AddComment(){
        PageReference p = new PageReference('/apex/ISSP_AddComment?caseId='+ApexPages.currentPage().getParameters().get('caseId'));
        p.setRedirect(true);
        return p;
    }
    
    public List<SelectOption> getCaseTypeItems() {
        List<SelectOption> options = new List<SelectOption>();
      
        if(caseType=='IATASR') {
        	 options.add(new SelectOption('IATA SERVICE REQUEST','IATA SERVICE REQUEST'));    
        } else if (newCase.CaseArea__c=='ICH') {
            options.add(new SelectOption('','- None -'));
			options.add(new SelectOption('ICH Finance','ICH Finance'));
          	options.add(new SelectOption('ICH General','ICH General'));
            options.add(new SelectOption('ICH Membership','ICH Membership'));
            options.add(new SelectOption('ICH Operations','ICH Operations'));            
        } else If (newCase.CaseArea__c=='SIS') {
            options.add(new SelectOption('','- None -'));
            options.add(new SelectOption('Feature Request','Feature Request'));
            options.add(new SelectOption('General Question','General Question'));
            options.add(new SelectOption('Problem / Issue','Problem / Issue'));
        } else {
            options.add(new SelectOption('','- None -'));
            options.add(new SelectOption('Feature Request','Feature Request'));
            options.add(new SelectOption('General Question','General Question'));
            options.add(new SelectOption('Problem / Issue','Problem / Issue'));
            options.add(new SelectOption('ICH Finance','ICH Finance'));
          	options.add(new SelectOption('ICH General','ICH General'));
            options.add(new SelectOption('ICH Membership','ICH Membership'));
            options.add(new SelectOption('ICH Operations','ICH Operations'));
        }
 
        return options;
    }
    
    public List<SelectOption> getCaseClassificationItems() {
        String cType;

        List<SelectOption> options = new List<SelectOption>();
        
        caseTypeSelection = Apexpages.currentPage().getParameters().get('caseTypeSelection');
        if(caseTypeSelection==null) {
            cType = caseTypeSelectionInit; //Coming from constructor when set from FAQ2Case
        } else {
            cType = caseTypeSelection;
        }
      	
        if(cType=='Feature Request') {
            options.add(new SelectOption('','- None -'));
       		options.add(new SelectOption('Enhancement to Existing Feature','Enhancement to Existing Feature'));
            options.add(new SelectOption('New Feature','New Feature'));
        } else if (cType=='General Question') {
            options.add(new SelectOption('','- None -'));
       		options.add(new SelectOption('Business Related','Business Related'));
            options.add(new SelectOption('System Related','System Related'));
        } else if (cType=='Problem / Issue') {
            options.add(new SelectOption('','- None -'));
            options.add(new SelectOption('Application Error','Application Error'));
             options.add(new SelectOption('Billing Data Issue','Billing Data Issue'));
             options.add(new SelectOption('Certification Issue','Certification Issue'));
             options.add(new SelectOption('Digital Signature Issue','Digital Signature Issue'));
             options.add(new SelectOption('Input File load Issue','Input File load Issue'));
             options.add(new SelectOption('Member Profile Issue','Member Profile Issue'));
             options.add(new SelectOption('Migration Issue','Migration Issue'));
             options.add(new SelectOption('Output File Issue','Output File Issue'));
             options.add(new SelectOption('Processing Time Issue','Processing Time Issue'));
             options.add(new SelectOption('Reporting Issue','Reporting Issue'));
             options.add(new SelectOption('Sandbox Issue','Sandbox Issue'));
             options.add(new SelectOption('Server / iiNET Issue','Server / iiNET Issue'));
             options.add(new SelectOption('Settlement File Issue','Settlement File Issue'));
             options.add(new SelectOption('User Access Issue','User Access Issue'));        
        } else if (cType=='ICH Finance') {
            options.add(new SelectOption('','- None -'));
            options.add(new SelectOption('Invoicing / Billing','Invoicing / Billing'));
            options.add(new SelectOption('Miscellaneous','Miscellaneous'));
            options.add(new SelectOption('Protest / Adjustment','Protest / Adjustment'));
            options.add(new SelectOption('Remittance and Settlement','Remittance and Settlement'));
        } else if (cType=='ICH General') {
             options.add(new SelectOption('','- None -'));
             options.add(new SelectOption('Bankruptcy','Bankruptcy'));
             options.add(new SelectOption('ICH General','ICH General'));
            options.add(new SelectOption('ICH Reports','ICH Reports'));
            options.add(new SelectOption('Invoice Issue','Invoice Issue'));
             options.add(new SelectOption('New Feature','New Feature'));
        } else if (cType=='ICH Membership') {
        	options.add(new SelectOption('','- None -'));
            options.add(new SelectOption('ICH Contacts','ICH Contacts'));
            options.add(new SelectOption('ICH Membership','ICH Membership'));
        } else if (cType=='ICH Operations') {    
            options.add(new SelectOption('','- None -'));
            options.add(new SelectOption('Claim Entry','Claim Entry'));
            options.add(new SelectOption('Clearance Notifications','Clearance Notifications'));
            options.add(new SelectOption('ICH Reports Issue','ICH Reports Issue'));
        } else {
            options.add(new SelectOption('','- None -'));
        	options.add(new SelectOption('Enhancement to Existing Feature','Enhancement to Existing Feature'));
        	options.add(new SelectOption('New Feature','New Feature'));
        	options.add(new SelectOption('Business Related','Business Related'));
        	options.add(new SelectOption('System Related','System Related'));
        	options.add(new SelectOption('Application Error','Application Error'));
        	options.add(new SelectOption('Billing Data Issue','Billing Data Issue'));
        	options.add(new SelectOption('Certification Issue','Certification Issue'));
        	options.add(new SelectOption('Digital Signature Issue','Digital Signature Issue'));
        	options.add(new SelectOption('Input File load Issue','Input File load Issue'));
        	options.add(new SelectOption('Member Profile Issue','Member Profile Issue'));
        	options.add(new SelectOption('Migration Issue','Migration Issue'));
        	options.add(new SelectOption('Output File Issue','Output File Issue'));
        	options.add(new SelectOption('Processing Time Issue','Processing Time Issue'));
        	options.add(new SelectOption('Reporting Issue','Reporting Issue'));
        	options.add(new SelectOption('Sandbox Issue','Sandbox Issue'));
        	options.add(new SelectOption('Server / iiNET Issue','Server / iiNET Issue'));
        	options.add(new SelectOption('Settlement File Issue','Settlement File Issue'));
        	options.add(new SelectOption('User Access Issue','User Access Issue'));        
        	options.add(new SelectOption('Invoicing / Billing','Invoicing / Billing'));
        	options.add(new SelectOption('Miscellaneous','Miscellaneous'));
        	options.add(new SelectOption('Protest / Adjustment','Protest / Adjustment'));
        	options.add(new SelectOption('Remittance and Settlement','Remittance and Settlement'));
        	options.add(new SelectOption('Bankruptcy','Bankruptcy'));
        	options.add(new SelectOption('ICH General','ICH General'));
        	options.add(new SelectOption('ICH Reports','ICH Reports'));
        	options.add(new SelectOption('Invoice Issue','Invoice Issue'));
       	 	options.add(new SelectOption('New Feature','New Feature'));
        	options.add(new SelectOption('ICH Contacts','ICH Contacts'));
        	options.add(new SelectOption('ICH Membership','ICH Membership'));
        	options.add(new SelectOption('Claim Entry','Claim Entry'));
        	options.add(new SelectOption('Clearance Notifications','Clearance Notifications'));
        	options.add(new SelectOption('ICH Reports Issue','ICH Reports Issue'));
        }
            system.debug('salesforce options: ' + options);
         return options;
    }
    
     public List<SelectOption> getCaseDefectItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        caseClassificationSelection = Apexpages.currentPage().getParameters().get('caseClassificationSelection');
        
          if(caseClassificationSelection=='Application Error') {
          	options.add(new SelectOption('','- None -'));
            options.add(new SelectOption('Alerts are not / incorrectly delivered','Alerts are not / incorrectly delivered'));
            options.add(new SelectOption('Functionality not working as expected','Functionality not working as expected'));
            options.add(new SelectOption('Minor defects which do not affect functionality','Minor defects which do not affect functionality'));
            options.add(new SelectOption('SIS Solution is not working','SIS Solution is not working'));
            options.add(new SelectOption('SIS usage data incorrectly produced','SIS usage data incorrectly produced'));  
          } else if(caseClassificationSelection=='Application Error - ICH') {
              options.add(new SelectOption('Functionality not working as expected','Functionality not working as expected'));
              options.add(new SelectOption('ICH application issue','ICH application issue'));
              options.add(new SelectOption('Incorrect reporting','Incorrect reporting'));
          } else if(caseClassificationSelection=='Bankruptcy') {    
            options.add(new SelectOption('','- None -'));
           	options.add(new SelectOption('Filing of Claims','Filing of Claims'));
           	options.add(new SelectOption('Updates','Updates'));
         } else if(caseClassificationSelection=='Billing Data Issue') {    
            options.add(new SelectOption('','- None -'));
             options.add(new SelectOption('Billing data captured through IS-Web does not contain intended values','Billing data captured through IS-Web does not contain intended values'));
             options.add(new SelectOption('Billing data submitted via IS-IDEC/IS-XML does not contain intended values','Billing data submitted via IS-IDEC/IS-XML does not contain intended values'));
             options.add(new SelectOption('Submission of billing data not possible','Submission of billing data not possible'));
         } else if(caseClassificationSelection=='Business Related') {    
            options.add(new SelectOption('','- None -'));
            options.add(new SelectOption('Business Related Question','Business Related Question'));
          } else if(caseClassificationSelection=='Certification Issue') {
            options.add(new SelectOption('Certification Issue','Certification Issue'));
          } else if(caseClassificationSelection=='Claim Entry') {
            options.add(new SelectOption('','- None -'));
            options.add(new SelectOption('Block Issue','Block Issue'));
              options.add(new SelectOption('Claim Adjustments / Errors','Claim Adjustments / Errors'));
              options.add(new SelectOption('Claim Confirmation Request','Claim Confirmation Request'));
              options.add(new SelectOption('Duplicate Invoice','Duplicate Invoice'));
              options.add(new SelectOption('Late Claim Submission','Late Claim Submission'));
              options.add(new SelectOption('No Claim entry for period','No Claim entry for period'));
          } else if(caseClassificationSelection=='Clearance Notifications') {
            	options.add(new SelectOption('','- None -'));
               options.add(new SelectOption('Issue found in Clearance Notifications','Issue found in Clearance Notifications'));
               options.add(new SelectOption('Non-receipt of ICH Clearance Notifications','Non-receipt of ICH Clearance Notifications'));
           } else if(caseClassificationSelection=='Digital Signature Issue') {
            	options.add(new SelectOption('','- None -'));
               options.add(new SelectOption('Invoices cannot be Digitally Signed','Invoices cannot be Digitally Signed'));
               options.add(new SelectOption('Other Digital Signature issues','Other Digital Signature issues'));
           } else if(caseClassificationSelection=='Enhancement to Existing Feature') {
            	options.add(new SelectOption('Enhancement to Existing Feature','Enhancement to Existing Feature'));   
           } else if(caseClassificationSelection=='ICH Contacts') {
            	options.add(new SelectOption('ICH Contacts Changes Question','ICH Contacts Changes Question'));    
          } else if(caseClassificationSelection=='ICH General') {
            	options.add(new SelectOption('General Question','General Question'));
          } else if(caseClassificationSelection=='ICH Membership') {
            	options.add(new SelectOption('','- None -'));
              	options.add(new SelectOption('Applying to the ICH','Applying to the ICH'));
              options.add(new SelectOption('Bank Account Related Matters','Bank Account Related Matters'));
              options.add(new SelectOption('Change of Currency of Settlement','Change of Currency of Settlement'));
              options.add(new SelectOption('Change of Zone','Change of Zone'));
              options.add(new SelectOption('ICH Extranet Access/Issues','ICH Extranet Access/Issues'));
              options.add(new SelectOption('Merger/Sponsor Related Matters','Merger/Sponsor Related Matters'));
             options.add(new SelectOption('New Applicants Security Deposits','New Applicants Security Deposits'));
              options.add(new SelectOption('Standing Deposits','Standing Deposits'));
          } else if(caseClassificationSelection=='ICH Reports') {
            options.add(new SelectOption('','- None -'));
              options.add(new SelectOption('Enhancement to Existing Report','Enhancement to Existing Report'));
              options.add(new SelectOption('New Report Request','New Report Request'));
         	} else if(caseClassificationSelection=='ICH Reports Issue') {
            	options.add(new SelectOption('','- None -'));
                options.add(new SelectOption('Cannot access ICH Reports from SIS','Cannot access ICH Reports from SIS'));
                options.add(new SelectOption('Error encountered in ICH Reports','Error encountered in ICH Reports'));
                options.add(new SelectOption('Other ICH Reports issues','Other ICH Reports issues'));
     		} else if(caseClassificationSelection=='Input File load Issue') {
            	options.add(new SelectOption('Response times for manual file load are greater than expected','Response times for manual file load are greater than expected'));
     		} else if(caseClassificationSelection=='Invoice Issue') {
            	options.add(new SelectOption('Invoice Clarification','Invoice Clarification'));
          	} else if(caseClassificationSelection=='Invoicing / Billing') {
            	options.add(new SelectOption('','- None -'));
              	options.add(new SelectOption('Invoicing / Billing Fees Query','Invoicing / Billing Fees Query'));
              	options.add(new SelectOption('Invoicing / Billing Penalties Query','Invoicing / Billing Penalties Query'));
          	}  else if(caseClassificationSelection=='Master Table Issue') {
            	options.add(new SelectOption('Master Table Issue','Master Table Issue'));  
          	}  else if(caseClassificationSelection=='Member Profile Issue') {
            	options.add(new SelectOption('Member Profile issue / updates not working','Member Profile issue / updates not working'));
          	} else if(caseClassificationSelection=='Migration Issue') {
            	options.add(new SelectOption('Unable to send migrated transaction types','Unable to send migrated transaction types'));
            }  else if(caseClassificationSelection=='Miscellaneous') {
            	options.add(new SelectOption('Financial Miscellaneous Query','Financial Miscellaneous Query'));
            }  else if(caseClassificationSelection=='New Feature') {
            	options.add(new SelectOption('New Feature Request','New Feature Request'));
            }  else if(caseClassificationSelection=='Output File Issue') {
                options.add(new SelectOption('','- None -'));
            	options.add(new SelectOption('File is corrupted','File is corrupted'));
                options.add(new SelectOption('Output billing files cannot be created or are incorrect or do not arrive at their destination within SIS','Output billing files cannot be created or are incorrect or do not arrive at their destination within SIS'));
          	}  else if(caseClassificationSelection=='Processing Time Issue') {
            	options.add(new SelectOption('Response times for files submitted are greater than expected','Response times for files submitted are greater than expected'));
            }  else if(caseClassificationSelection=='Protest / Adjustment') {
            	options.add(new SelectOption('Protest / Adjustment request through Protest Procedure','Protest / Adjustment request through Protest Procedure'));
             }  else if(caseClassificationSelection=='Remittance and Settlement') {
                options.add(new SelectOption('','- None -'));
            	options.add(new SelectOption('DUE FROM ICH Details Query','DUE FROM ICH Details Query'));
                options.add(new SelectOption('DUE TO ICH Details Query','DUE TO ICH Details Query'));
            }  else if(caseClassificationSelection=='Reporting Issue') {
                options.add(new SelectOption('','- None -'));
                options.add(new SelectOption('Reports cannot be viewed / downloaded','Reports cannot be viewed / downloaded'));
                options.add(new SelectOption('Validation reports have not been received / generated','Validation reports have not been received / generated'));
            }  else if(caseClassificationSelection=='Sandbox Issue') {
                options.add(new SelectOption('Sandbox Issue','Sandbox Issue')); 
            }  else if(caseClassificationSelection=='Server / iiNET Issue') {
                options.add(new SelectOption('Server / iiNET Issue','Server / iiNET Issue')); 
            }  else if(caseClassificationSelection=='Settlement File Issue') {
                options.add(new SelectOption('Billing data is incorrectly reported or not present in the respective clearing house.','Billing data is incorrectly reported or not present in the respective clearing house.')); 
            }  else if(caseClassificationSelection=='Supporting Document') {
                options.add(new SelectOption('Supporting Document','Supporting Document')); 
            }  else if(caseClassificationSelection=='System Related') {
                options.add(new SelectOption('System Related Question', 'System Related Question'));
            }  else if(caseClassificationSelection=='User Access Issue') {
                options.add(new SelectOption('','- None -'));
                options.add(new SelectOption('Access to SIS Solution is not possible','Access to SIS Solution is not possible'));
                options.add(new SelectOption('Users unable to log on to SIS Solution','Users unable to log on to SIS Solution'));
            } else {
              options.add(new SelectOption('','- None -'));
            options.add(new SelectOption('Alerts are not / incorrectly delivered','Alerts are not / incorrectly delivered'));
            options.add(new SelectOption('Functionality not working as expected','Functionality not working as expected'));
            options.add(new SelectOption('Minor defects which do not affect functionality','Minor defects which do not affect functionality'));
            options.add(new SelectOption('SIS Solution is not working','SIS Solution is not working'));
            options.add(new SelectOption('SIS usage data incorrectly produced','SIS usage data incorrectly produced')); 
            options.add(new SelectOption('Functionality not working as expected','Functionality not working as expected'));
            options.add(new SelectOption('ICH application issue','ICH application issue'));
            options.add(new SelectOption('Incorrect reporting','Incorrect reporting'));
           	options.add(new SelectOption('Filing of Claims','Filing of Claims'));
           	options.add(new SelectOption('Updates','Updates'));
            options.add(new SelectOption('Billing data captured through IS-Web does not contain intended values','Billing data captured through IS-Web does not contain intended values'));
            options.add(new SelectOption('Billing data submitted via IS-IDEC/IS-XML does not contain intended values','Billing data submitted via IS-IDEC/IS-XML does not contain intended values'));
            options.add(new SelectOption('Submission of billing data not possible','Submission of billing data not possible'));
            options.add(new SelectOption('Business Related Question','Business Related Question'));
            options.add(new SelectOption('Certification Issue','Certification Issue'));
            options.add(new SelectOption('Block Issue','Block Issue'));
            options.add(new SelectOption('Claim Adjustments / Errors','Claim Adjustments / Errors'));
            options.add(new SelectOption('Claim Confirmation Request','Claim Confirmation Request'));
            options.add(new SelectOption('Duplicate Invoice','Duplicate Invoice'));
            options.add(new SelectOption('Late Claim Submission','Late Claim Submission'));
            options.add(new SelectOption('No Claim entry for period','No Claim entry for period'));
            options.add(new SelectOption('Issue found in Clearance Notifications','Issue found in Clearance Notifications'));
            options.add(new SelectOption('Non-receipt of ICH Clearance Notifications','Non-receipt of ICH Clearance Notifications'));
            options.add(new SelectOption('Invoices cannot be Digitally Signed','Invoices cannot be Digitally Signed'));
            options.add(new SelectOption('Other Digital Signature issues','Other Digital Signature issues'));
            options.add(new SelectOption('Enhancement to Existing Feature','Enhancement to Existing Feature'));   
            options.add(new SelectOption('ICH Contacts Changes Question','ICH Contacts Changes Question'));    
			options.add(new SelectOption('General Question','General Question'));
            options.add(new SelectOption('Applying to the ICH','Applying to the ICH'));
            options.add(new SelectOption('Bank Account Related Matters','Bank Account Related Matters'));
            options.add(new SelectOption('Change of Currency of Settlement','Change of Currency of Settlement'));
            options.add(new SelectOption('Change of Zone','Change of Zone'));
            options.add(new SelectOption('ICH Extranet Access/Issues','ICH Extranet Access/Issues'));
            options.add(new SelectOption('Merger/Sponsor Related Matters','Merger/Sponsor Related Matters'));
            options.add(new SelectOption('New Applicants Security Deposits','New Applicants Security Deposits'));
            options.add(new SelectOption('Standing Deposits','Standing Deposits'));
            options.add(new SelectOption('Enhancement to Existing Report','Enhancement to Existing Report'));
            options.add(new SelectOption('New Report Request','New Report Request'));
            options.add(new SelectOption('Cannot access ICH Reports from SIS','Cannot access ICH Reports from SIS'));
            options.add(new SelectOption('Error encountered in ICH Reports','Error encountered in ICH Reports'));
            options.add(new SelectOption('Other ICH Reports issues','Other ICH Reports issues'));
            options.add(new SelectOption('Response times for manual file load are greater than expected','Response times for manual file load are greater than expected'));
			options.add(new SelectOption('Invoice Clarification','Invoice Clarification'));
            options.add(new SelectOption('Invoicing / Billing Fees Query','Invoicing / Billing Fees Query'));
            options.add(new SelectOption('Invoicing / Billing Penalties Query','Invoicing / Billing Penalties Query'));
            options.add(new SelectOption('Master Table Issue','Master Table Issue'));  
            options.add(new SelectOption('Member Profile issue / updates not working','Member Profile issue / updates not working'));
            options.add(new SelectOption('Unable to send migrated transaction types','Unable to send migrated transaction types'));
            options.add(new SelectOption('Financial Miscellaneous Query','Financial Miscellaneous Query'));
            options.add(new SelectOption('New Feature Request','New Feature Request'));
            options.add(new SelectOption('File is corrupted','File is corrupted'));
            options.add(new SelectOption('Output billing files cannot be created or are incorrect or do not arrive at their destination within SIS','Output billing files cannot be created or are incorrect or do not arrive at their destination within SIS'));
            options.add(new SelectOption('Response times for files submitted are greater than expected','Response times for files submitted are greater than expected'));
            options.add(new SelectOption('Protest / Adjustment request through Protest Procedure','Protest / Adjustment request through Protest Procedure'));
            options.add(new SelectOption('DUE FROM ICH Details Query','DUE FROM ICH Details Query'));
            options.add(new SelectOption('DUE TO ICH Details Query','DUE TO ICH Details Query'));
            options.add(new SelectOption('Reports cannot be viewed / downloaded','Reports cannot be viewed / downloaded'));
            options.add(new SelectOption('Validation reports have not been received / generated','Validation reports have not been received / generated'));
            options.add(new SelectOption('Sandbox Issue','Sandbox Issue'));
            options.add(new SelectOption('Server / iiNET Issue','Server / iiNET Issue')); 
            options.add(new SelectOption('Billing data is incorrectly reported or not present in the respective clearing house.','Billing data is incorrectly reported or not present in the respective clearing house.')); 
            options.add(new SelectOption('Supporting Document','Supporting Document')); 
            options.add(new SelectOption('System Related Question', 'System Related Question'));
            options.add(new SelectOption('Access to SIS Solution is not possible','Access to SIS Solution is not possible'));
            options.add(new SelectOption('Users unable to log on to SIS Solution','Users unable to log on to SIS Solution')); 
          }
              return options;
     }
    
    public List<SelectOption> getCaseSubTypeItems() {
        List<SelectOption> options = new List<SelectOption>();
      
        options.add(new SelectOption('','- None -'));
        options.add(new SelectOption('Other','Other'));
        options.add(new SelectOption('Schedule downtime','Schedule downtime'));
        
        return options;
    }
}