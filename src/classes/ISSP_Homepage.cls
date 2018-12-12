public with sharing class ISSP_Homepage {

    public Account acct {get;private set;}
    public Contact con {get;private set;}
    public boolean isPartner {get;private set;}
    public boolean isDPCUser {get;set;}
    public boolean isAdmin{set;get;}
    public boolean isOpCalendarAirlineUser{set;get;}
    public boolean isOpCalendarAgencyUser{set;get;}
    public boolean showIrregularities {get;private set;}
    public list<Case> caseList {get;private set;}
    public list<Case> caseList_CompanyOpenCases {get;private set;}
    public list<Case> caseList_ReqMyInput {get;private set;}
    public map<string,integer> userMap {get;private set;}
    public List<Portal_Application_Right__c> appsGrantedList{get;private set;}
    public List<Portal_Applications__c> externalLinksList {get;private set;}
    public List<Portal_Applications__c> newAppsList {get;private set;}
    public List<Portal_Application_Right__c> appsPendingApprovalsList{get;private set;}
    public List<Notification__c> myNotificationsList{get;private set;}
    //public list<KnowledgeArticleVersionWrapper> kbList {get;private set;}

    //Survey variables
    public String  SurveyLink {get; set;}
    public String  SurveyName {get; set;}
    public Boolean ShowModal {get; set;}
    public Decimal SurveyDelayTime {get; set;}


    public string Cases_ListView {get {return ISSP_Constant.customSetingMap.get('Cases_ListView');}private set;}
    public string Pending_approvals_ListView {get {return ISSP_Constant.customSetingMap.get('Pending_approvals_ListView');}private set;}
    public string Portal_Admins_ListView {get {return ISSP_Constant.customSetingMap.get('Portal_Admins_ListView');}private set;}
    public string Portal_RegionalAdmins_ListView {get {return ISSP_Constant.customSetingMap.get('Portal_RegionalAdmins_ListView');}private set;}
    public string Portal_users_ListView {get {return ISSP_Constant.customSetingMap.get('Portal_users_ListView');} private set;}
    public string CompanyCases_ListView {get {return ISSP_Constant.customSetingMap.get('CompanyCases_ListView');} private set;}
    public string Pending_approvals_app_ListView {get {return ISSP_Constant.customSetingMap.get('Pending_approvals_app_ListView');} private set;}
    public string noirr {get;private set;}
//  public string maxirr {get;private set;}

    public string UserLanguage {get; set;}
    public boolean iataCertificatesVisible {get; set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

    public ISSP_Homepage(){
        if(!Userinfo.getUserType().contains('Guest')){
            populateVariables();
        }
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        isDPCUser = (profileName.startsWith('ISS Portal DPC Admin'));
        isAdmin =(profileName.containsIgnoreCase('admin'));
        String profileId15 = String.ValueOf(UserInfo.getProfileId()).left(15);
        try {
            isOpCalendarAirlineUser = ISSP_CS__c.getValues('ISS OperationalCalendar Airline Profil').Value__c.split(',').contains(profileId15);
        } catch (Exception e) {
            isOpCalendarAirlineUser = false;
        }
        try {
            isOpCalendarAgencyUser = ISSP_CS__c.getValues('ISS OperationalCalendar Agency Profile').Value__c.split(',').contains(profileId15);
        } catch (Exception e) {
            isOpCalendarAgencyUser = false;
        }

        //Survey init
        ShowModal = true ;
        SurveyDelayTime = 0 ;
        getSurveyDetails();

        UserLanguage = UserLanguage();
    }

    public void populateVariables(){
        User user = [select Id,languagelocalekey,ContactId,ProfileId from User where Id =:Userinfo.getUserId()];
        system.debug('\n\n\n user:'+user+'\n\n\n');
        Cookie coo = ApexPages.currentPage().getCookies().get('lang');
        if(coo == null){
            coo = new Cookie('lang',user.languagelocalekey,null,100000000,false);
            ApexPages.currentPage().setCookies(new Cookie[]{coo});
        }
        con = [select Id,Credit_Card_Payment_Link__c,User_Portal_Status__c,BSP_CASS_Payment_contact__c,Financial_Assessment_Contact__c,Account.Top_Parent__c,AccountId,Account.Industry,Account.Accumulated_Irregularities__c, Account.Category__c, Account.Status__c, Account.CNS_Agency__c from Contact where Id=:user.ContactId];
        // acct = [select Id,Industry,Accumulated_Irregularities__c from Account where Id=:con.AccountId];
        userMap = new map<string,integer> {'Pending approvals'=>0,'Portal Users'=>0,'Portal Delegates Administrators'=>0,'Regional Administrator'=>0};
        string topParentId = con.Account.Top_Parent__c==null?con.AccountId:con.Account.Top_Parent__c;
        noirr = string.valueof(con.Account.Accumulated_Irregularities__c);
        iataCertificatesVisible = DAL_ISSP.visibilityOnIATACertificate(con.Account.Category__c, con.Account.Status__c);
        if(con.Account.CNS_Agency__c) iataCertificatesVisible = false;
/* OLD IRREGULARITIES DISPLAY
        Irregularities_by_Agent_Type__c MaxCargo =  Irregularities_by_Agent_Type__c.getValues('Cargo');
        Irregularities_by_Agent_Type__c MaxTravel =  Irregularities_by_Agent_Type__c.getValues('Travel');

        if (con.Account.Industry=='Cargo Agent') {
                isAgency = true;
                maxirr = string.valueof(MaxCargo.max_irregularities__c.intValue());
        }
        else if (con.Account.Industry=='Travel Agent') {
                isAgency = true;
                maxirr = string.valueof(MaxTravel.max_irregularities__c.intValue());
        }
        else {
                isAgency = false;
                maxirr = '?';
        }
*/
        if ( (con.Account.Industry=='Cargo Agent' || con.Account.Industry=='Travel Agent') && (con.User_Portal_Status__c=='Approved Admin' || con.BSP_CASS_Payment_contact__c || con.Financial_Assessment_Contact__c)) {
                showIrregularities = True;
        }
        else {
                showIrregularities = False;
        }

        // MY OPEN CASES
        caseList = [select Id from Case
                    WHERE is_Portal_user_equal_case_contact__c = 'true'
                    AND Visible_on_ISS_Portal__c = true
                    and CreatedDate >:date.newInstance(2014, 1, 13)
                    AND RecordType.Name != 'IATA Financial Review'
                    and IsClosed = false];
        system.debug('MY OPEN: ' + caseList.size());

        caseList_ReqMyInput = [select Id from Case
                            where Status = 'Pending customer'
                            and is_Portal_user_equal_case_contact__c = 'true'
                            AND Visible_on_ISS_Portal__c = true
                            and CreatedDate >:date.newInstance(2014, 1, 13)
                            AND RecordType.Name != 'IATA Financial Review'];
        system.debug('INPUT OPEN: ' + caseList_ReqMyInput.size());

        if(ISSP_Constant.adminIdSet.contains(user.ProfileId)){
            system.debug('IS PARTNER');
            system.debug('TOP PARENT: ' + topParentId);
            isPartner = true;
            caseList_CompanyOpenCases = [select Id from Case where
                (Contact.Account.Top_Parent__c=:topParentId OR Contact.AccountId=:topParentId)
                AND Visible_on_ISS_Portal__c = true
                and IsClosed = false
                and CreatedDate >:date.newInstance(2014, 1, 13)
                AND RecordType.Name != 'IATA Financial Review'];
            system.debug('COMPANY OPEN: ' + caseList_CompanyOpenCases.size());

            for(Contact con :[select Id,User_Portal_Status__c from Contact where Account.Top_Parent__c=:topParentId OR AccountId=:topParentId ]){
                if(con.User_Portal_Status__c=='Pending Approval')
                    userMap.put('Pending approvals',userMap.get('Pending approvals')+1);
                //else if(con.User_Portal_Status__c=='Approved User')
                else if(con.User_Portal_Status__c=='Active')
                    userMap.put('Portal Users',userMap.get('Portal Users')+1);
                else if(con.User_Portal_Status__c=='Approved Admin')
                    userMap.put('Portal Delegates Administrators',userMap.get('Portal Delegates Administrators')+1);
                else if(con.User_Portal_Status__c=='Regional Administrator')
                    userMap.put('Regional Administrator',userMap.get('Regional Administrator')+1);
            }

        }
        else{
            system.debug('NOT IS PARTNER');
            system.debug('TOP PARENT: ' + topParentId);
            isPartner = false;
            caseList_CompanyOpenCases = [select Id from Case where
                                        (ContactId=:con.Id)
                                        and IsClosed = false
                                        AND Visible_on_ISS_Portal__c = true
                                        and CreatedDate >:date.newInstance(2014, 1, 13)
                                        AND isSISUser__c = 'true'];
            system.debug('COMPANY OPEN: ' + caseList_CompanyOpenCases.size());

        }
        myNotificationsList = [Select Notificatin_color__c,n.Type__c, n.Subject__c, n.Message__c, n.Id, n.Due_date__c, n.CreatedDate,Critical_notification__c, Number_of_views__c From Notification__c n where Contact__c=:con.Id and Archive__c=false order by Critical_notification__c DESC, CreatedDate  DESC];

        //appsGrantedList = [Select p.Application_Name__c, p.PortalServiceTranslatedName__c, p.Portal_Application__r.Description__c,p.Portal_Application__r.Service_Description__c,p.Portal_Application__r.Requestable__c,p.Application_icon_del__c, p.Portal_Application__r.New_Window__c,p.Right__c, p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__c, p.My_Apps__c, p.Contact__c, p.Application_Start_URL__c From Portal_Application_Right__c p where p.Contact__c =: user.ContactId and p.My_Apps__c = true and (p.Right__c = 'Access Granted'  or p.Right__c = 'Access Requested') and p.Portal_Application__r.Hide_on_Homepage__c = false ORDER BY p.Right__c DESC,p.Portal_Application__r.Name];

        appsGrantedList = new List<Portal_Application_Right__c>([Select p.Application_Name__c, p.PortalServiceTranslatedName__c ,p.Portal_Application__r.Description__c, p.Portal_Application__r.Requestable__c, p.Application_icon_del__c, p.Portal_Application__r.New_Window__c, p.Right__c, p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__c, p.My_Apps__c, p.Contact__c, p.Application_Start_URL__c,p.Technical_Provisioning_Status__c, p.Case_creation_record_Type__c, p.Portal_Application__r.Service_Description__c, p.Portal_Application__r.Service_Description_Label__c, p.IsSCIMIFG__c
            From Portal_Application_Right__c p 
            where p.Contact__c =: user.ContactId and (p.Right__c = 'Access Granted'  or p.Right__c = 'Access Requested') and p.Portal_Application__r.Hide_on_Homepage__c = false ORDER BY p.Right__c DESC,p.Portal_Application__r.Name]);   

        externalLinksList = [Select  p.Name,p.Description__c,p.Service_Description__c, p.Service_Description_Label__c,  p.Visible__c, p.Requestable__c, p.Application_icon__c, p.Application_URL__c,New_Window__c, p.VisibleCNS__c From Portal_Applications__c p where p.Visible__c = true and p.Requestable__c = false];
        appsPendingApprovalsList = [Select p.Application_icon_del__c, p.Right__c, p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__r.New_Window__c, p.Portal_Application__c, p.My_Apps__c, p.Contact__c, p.Application_Start_URL__c From Portal_Application_Right__c p where p.Contact__r.AccountId =: topParentId  and p.Right__c = 'Access Requested'];
        set<Id> appIdSet = new set<Id>();
        for(Portal_Application_Right__c par:appsGrantedList){
            appIdSet.add(par.Portal_Application__c);
        }
        newAppsList = [Select  p.Description__c,p.Service_Description__c,p.Service_Description_Label__c,p.Visible__c, p.Requestable__c, p.Application_icon__c,
                        p.Application_URL__c, p.Confirm_Box__c, p.Confirm_Text__c
                        From Portal_Applications__c p
                        where p.Visible__c = true and p.Requestable__c = true
                        and p.Hide_on_Homepage__c = false and id not in:appIdSet];
        //populateKBlist(user.languagelocalekey);

    }

    public Pagereference isLogined (){
        System.debug('isLogined:');
        String kaviURL = ApexPages.currentPage().getParameters().get('kaviURL');
        if(kaviURL!=null)
            return new Pagereference('https://' +  kaviURL);
        Boolean isCNS = ISSP_Utilities.isCNS();
        User u = [
            SELECT Id, Contact.Account.CNS_Agency__c, Contact.Account.CNS_Account__c, Contact.Account.RecordType.DeveloperName
            FROM User WHERE Id =:UserInfo.getUserId()];
        if(isCNS) {
            ApexPages.currentPage().getParameters().put('communityName','CNS');
        } else if(u.Contact.Account.RecordType.DeveloperName == 'IATA_Airline_BR' ||
                    u.Contact.Account.RecordType.DeveloperName == 'IATA_Airline' ||
                    u.Contact.Account.RecordType.DeveloperName == 'IATA_GSA') {
            ApexPages.currentPage().getParameters().put('communityName','ISS');

        }
        if(Userinfo.getUserType().contains('Guest') || system.Test.isRunningTest()){
            string host = ISSP_Constant.customSetingMap.get('Host');
            if(host==null || host==''){
                host =  ApexPages.currentPage().getHeaders().get('Host');
            }
            return new Pagereference('https://' + host+ '/ISSP_Login');
        }
        else{
            //TF - force logout for TD
            PageReference newPR = ISSP_TD.toLogout_TD();
            if (newPR != null){
                newPR.setRedirect(true);
                return newPR;
            }
        }
        return null;
    }

    @RemoteAction
    public static string newAppsRequest (string applicationId, string contactId){
        insert new Portal_Application_Right__c(Contact__c = contactId,Portal_Application__c = applicationId,Right__c = 'Access Requested');
        return 'ok';
    }

    @RemoteAction
    public static string archiveNotification (string notificationId){
        upsert new Notification__c(Id = notificationId,Archive__c=true);
        return 'ok';
    }

     @RemoteAction
    public static string addNumberOfViews(string notificationId){
        try{
            Notification__c notification = [select Id,Number_of_views__c from Notification__c where Id =:notificationId];
            if(notification.Number_of_views__c == null)
                notification.Number_of_views__c = 0;
            notification.Number_of_views__c = notification.Number_of_views__c+1;
            upsert notification;
            return 'ok';
        }catch(Exception ex){
            return 'ko';
        }
    }

    @RemoteAction
    public static String gUserId() { return Userinfo.getUserId(); }

    /*
    private void populateKBlist(string lang){
        kbList = new list<KnowledgeArticleVersionWrapper>();
        for(FAQ__kav kb:[select UrlName,Id ,title,LastPublishedDate,TOLABEL(ArticleType) from FAQ__kav  where Language=:UserInfo.getLanguage() and PublishStatus=:'Online'  and To_display_on_Homepage__c=true  order by LastPublishedDate DESC limit 10 ]){
            kbList.add(new KnowledgeArticleVersionWrapper(kb));
        }
        for(Portal_news__kav kb:[select UrlName,Id ,title,LastPublishedDate,TOLABEL(ArticleType) from Portal_news__kav  where Language=:UserInfo.getLanguage() and PublishStatus=:'Online'  and To_display_on_Homepage__c=true  order by LastPublishedDate DESC limit 10 ]){
            kbList.add(new KnowledgeArticleVersionWrapper(kb));
        }
        for(Content__kav kb:[select UrlName,Id ,title,LastPublishedDate,TOLABEL(ArticleType) from Content__kav  where Language=:UserInfo.getLanguage() and PublishStatus=:'Online'  and To_display_on_Homepage__c=true  order by LastPublishedDate DESC limit 10 ]){
            kbList.add(new KnowledgeArticleVersionWrapper(kb));
        }
        for(How_To__kav kb:[select UrlName,Id ,title,LastPublishedDate,TOLABEL(ArticleType) from How_To__kav  where Language=:UserInfo.getLanguage() and PublishStatus=:'Online'  and To_display_on_Homepage__c=true  order by LastPublishedDate DESC limit 10 ]){
            kbList.add(new KnowledgeArticleVersionWrapper(kb));
        }
        kbList.sort();
        list<KnowledgeArticleVersionWrapper> tkbwList = new list<KnowledgeArticleVersionWrapper>();
        integer i =0;
        for(KnowledgeArticleVersionWrapper kb:kbList){
            if(i>9)break;
            tkbwList.add(kb);
            i++;
        }
        kbList = tkbwList;
    }
    */

    public class KnowledgeArticleVersionWrapper implements Comparable {

        public sObject kb {get;set;}

        // Constructor
        public KnowledgeArticleVersionWrapper(KnowledgeArticleVersion kb) {
            this.kb = kb;
        }

        // Constructor
        public KnowledgeArticleVersionWrapper(FAQ__kav kb) {
            this.kb = kb;
        }

        // Constructor
        public KnowledgeArticleVersionWrapper(Portal_news__kav kb) {
            this.kb = kb;
        }

        // Constructor
        public KnowledgeArticleVersionWrapper(Content__kav kb) {
            this.kb = kb;
        }

        // Constructor
        public KnowledgeArticleVersionWrapper(How_To__kav kb) {
            this.kb = kb;
        }


        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            KnowledgeArticleVersionWrapper compareToKB = (KnowledgeArticleVersionWrapper)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (Datetime.valueOf(kb.get('LastPublishedDate')) > Datetime.valueOf(compareToKB.kb.get('LastPublishedDate'))) {
                // Set return value to a positive value.
                returnValue = -1;
            }else if (Datetime.valueOf(kb.get('LastPublishedDate')) < Datetime.valueOf(compareToKB.kb.get('LastPublishedDate'))) {
                // Set return value to a negative value.
                returnValue = 1;
            }

            return returnValue;
        }
    }

    public string UserLanguage() {
        return UserInfo.getLanguage();
    }

    public PageReference getSurveyDetails(){
    System.debug('SFI Start checkloginSurvey Method');

        //Select all active LoginSrvey Custom settings
        List<ISSPLoginSurvey__c> LoginSurvey_List = new List<ISSPLoginSurvey__c>([select Name, Survey_Link__c, isActive__c ,PopupDelayTime__c from ISSPLoginSurvey__c where isActive__c =: true ]);
        System.debug('SFI LoginSurvey_List'+LoginSurvey_List);

        if (LoginSurvey_List != null && LoginSurvey_List.size() > 0)
        {
            //Get the newest one according to Survey_Number Field
            ISSPLoginSurvey__c LoginSurvey_rec = new ISSPLoginSurvey__c();
            LoginSurvey_rec = LoginSurvey_List[0];
            SurveyName = LoginSurvey_rec.Name ;
            SurveyDelayTime = LoginSurvey_rec.PopupDelayTime__c * 1000;
            System.debug('SFI LoginSurvey_rec'+LoginSurvey_rec);

            //Get the Survey ID
            String SurveyID = (LoginSurvey_rec.Survey_Link__c).substringAfterLast('iv=');

            //Retrieve the current looged in useriv=
            User userRec = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getUserId()][0];
            System.debug('SFI userList'+userRec);

            //prepare the full survey URL
            String fullSurveyURL = LoginSurvey_rec.Survey_Link__c.removeStart('http:')+'&q3='+userRec.ContactId+'&q4='+userRec.ID+'&q5='+SurveyID;

            //Get Survey Instant according to UserId and Survey ID
            List<Instant_Surveys__c>  InstantSurvey_List = new List<Instant_Surveys__c>([select Id ,SurveyUserID__c , SurveyURL__c
                                                                                          From Instant_Surveys__c
                                                                                          Where SurveyUserID__c =: userRec.Id
                                                                                          AND SurveyURL__c =: SurveyID ]);

            if (InstantSurvey_List != null && InstantSurvey_List.size() > 0 )
            {
                ShowModal = false ;
            }
            else
            {
                SurveyLink = fullSurveyURL ;
            }
        }else{
            ShowModal = false ;
        }
    return null;
    }

    //browser detection ed dec15
   public string isIE {get
    {
        String b = 'IE';
        //default IE
          String browser = ApexPages.currentPage().getHeaders().get('USER-AGENT');
          if (browser != null && browser != ''){
          if (browser.contains('MSIE') || browser.contains('rv:11.0'))
            //IE
            {
                if (browser.contains('Trident/4.0') && browser.contains('MSIE 7.0') ){
                    b = 'IE8 '+ Label.ISSP_In_compatibility_mode ;
                }
                else if
                    (browser.contains('Trident/5.0') && browser.contains('MSIE 7.0') ){
                    b = 'IE9 '+ Label.ISSP_In_compatibility_mode ;
                }
                else if
                    (browser.contains('Trident/6.0') && browser.contains('MSIE 7.0')){
                    b = 'IE10 '+ Label.ISSP_In_compatibility_mode ;
                }

                else if
                   (browser.contains('Trident/7.0') && browser.contains('MSIE 7.0')){
                    b = 'IE11 '+ Label.ISSP_In_compatibility_mode ;
                }

          }
          else
            //not IE
          {
            b  = 'notIE';
            }
          }

        //return browser;
        return b;
    }set;}

    /**
        Returns true if current user is an Admin user according to ISSP_Constant class
    **/
    public Boolean getIsAdminUser() {
        return ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId());
    }
}