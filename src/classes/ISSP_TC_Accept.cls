public  class ISSP_TC_Accept {

    public boolean accept {get; set;}
    public list<String> errorMessage {get; set;}
    public List <User> userList {get; set;}
    public Boolean toChangePassword {get; set;}
    public Boolean toAcceptTC {get; set;}
    public Boolean isBSP {get; set;}
    
    public String searchText {get; set;}

    public Boolean showFinancialInstitution {
        get {
            if (showFinancialInstitution == null) showFinancialInstitution =  false;
            return showFinancialInstitution;
        } 
        private set;
    }

    //Survey variables
    public String SurveyLink {get; set;}
    public String SurveyName {get; set;}
    public Boolean ShowModal {get; set;}

    //AMSU-142 (AMSU-26)
    public Boolean isCargoDGR {get; set;}

     //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}
    
    //Language picklist
    public String selectedLanguage {get;set;}
    
    public List<SelectOption> languages {
    get {
        List<SelectOption> options = new List<selectOption>();

        Map<String,String> langMap = new Map<String,String>();

        for(Preferred_Language_on_ISS_Portal__c l : Preferred_Language_on_ISS_Portal__c.getAll().values())
            langMap.put(l.Language__c,l.languageLocalKey__c);

        List<String> auxList = new List<String>(langMap.keySet());
        auxList.sort();

        for(String key :auxList)
            options.add(new SelectOption(langMap.get(key), key));

        return options; 
    }
    set;
    }
    

    public ISSP_TC_Accept(){
        isBSP = false;
        errorMessage = new list<string>();
        toChangePassword = false;
        ShowModal = true ;
        toAcceptTC = false;
        integer passwordDays = integer.ValueOF(ISSP_CS__c.getValues('PasswordResetPeriod').value__c);
        //AMSU-142 (AMSU-26) - added accountId      
        userList = [SELECT Id, ToU_Accepted__c, UID__c, LastPasswordChangeDate , Email, ContactId, AccountId, Contact.Designated_IFAP_Contact__c, Contact.User_Portal_Status__c, Contact.Financial_Assessment_Contact__c
                    FROM User WHERE Id =:UserInfo.getUserId()];
        if (!userList.isEmpty()){
            if (userList[0].LastPasswordChangeDate != null){
                system.debug('LastPasswordChangeDate: ' + userList[0].LastPasswordChangeDate);
                system.debug('LastPasswordChangeDate addDays: ' + userList[0].LastPasswordChangeDate.addDays(passwordDays));
                system.debug('LastPasswordChangeDate now: ' + system.now());
                //if (userList[0].LastPasswordChangeDate.addMinutes(10) < system.now() && userList[0].Email == 'tiago.ferreira+newportal_01_01@kerensen.com'){
                if (userList[0].LastPasswordChangeDate.addDays(passwordDays) < system.now()){
                    toChangePassword = true;
                    system.debug('password date passed');
                }
                else{
                    system.debug('password date not passed');
                }
            }
            if (userList[0].UID__c != '' && userList[0].UID__c != null){
                toChangePassword = true;
            }
            if (!userList[0].ToU_Accepted__c){
                toAcceptTC = true;
            }
            if (userList[0].ContactId != null){
                ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
                String appId = serviceIdInstance.BSPLink__c;
                List <Portal_Application_Right__c> bspList = [SELECT Id FROM Portal_Application_Right__c
                                                            WHERE Portal_Application__c = :appId
                                                            AND Contact__c = :userList[0].ContactId
                                                            AND Right__c = 'Access Granted'];
                if (!bspList.isEmpty()){
                    isBSP = true;
                }
            }
            //AMSU-142 (AMSU-26)
            isCargoDGR = false;
            if (userList[0].AccountId != null){
                Account acc = [Select Location_Class__c, Category__c, Sector__c, Is_Branch_Abroad__c, Status__c, Location_Type__c, RecordTypeId from Account where Id = :userList[0].AccountId];
                if( AMS_Utils.LocationClassDGR.contains(acc.Location_Class__c) ) {
                    isCargoDGR = true;
                }

                Set<String> allowedLocTypes = new Set<String>{'HO', 'HE', 'AO'};

                if (((acc.Sector__c == 'Travel Agent' || acc.Sector__c == 'Cargo Agent') && acc.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency')) && 
                    (allowedLocTypes.contains(acc.Location_Type__c) || acc.Is_Branch_Abroad__c == 'Yes') &&
                    (AMS_Utils.ACTIVEAGENCYSTATUS.contains(acc.Status__c) || acc.Status__c == AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING) &&
                    (userList[0].Contact.Financial_Assessment_Contact__c || userList[0].Contact.User_Portal_Status__c == 'Approved Admin')) {
                    showFinancialInstitution = true;
                }
            }
        }
        
        selectedLanguage = UserInfo.getLanguage();
        system.debug('IS BSP: ' + isBSP);
    }
    
    public PageReference redirectChangePassword(){
        if (!userList.isEmpty()){
            integer passwordDays = integer.ValueOF(ISSP_CS__c.getValues('PasswordResetPeriod').value__c);
            if (userList[0].UID__c != '' && userList[0].UID__c != null){
                PageReference pr = new PageReference('/ISSP_ChangePassword'+commParam);
                system.debug('REDIRECTING TO CHANGE PASSWORD');
                pr.setRedirect(true);
                return pr;
            }
            else if (userList[0].LastPasswordChangeDate != null){
                //if (userList[0].LastPasswordChangeDate.addMinutes(10) < system.now() && userList[0].Email == 'tiago.ferreira+newportal_01_01@kerensen.com'){
                if (userList[0].LastPasswordChangeDate.addDays(passwordDays) < system.now()){
                    PageReference pr2 = new PageReference('/ISSP_ChangePassword'+commParam);
                    system.debug('REDIRECTING TO CHANGE PASSWORD');
                    pr2.setRedirect(true);
                    return pr2;
                }
            }
        }
        return null;
    }

    public PageReference redirectTC_Accept(){
        if (!userList.isEmpty()){
            if (!userList[0].ToU_Accepted__c){
                PageReference pr = new PageReference('/ISSP_TC_Accept');
                if(communityName=='CNS') pr = new PageReference('/ISSP_TC_Accept?CommunityName=CNS');
                system.debug('REDIRECTING TO TC ACCEPT');
                pr.setRedirect(true);
                return pr;
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }


    public PageReference pageLoad(){
        String strUrl = ApexPages.currentPage().getUrl();
        system.debug('URL: ' + strUrl);
        if (!strUrl.contains('ISSP_TC_Accept')){// && !strUrl.contains('ISSP_2FA')){
            system.debug('DOES NOT CONTAIN ISSP_CHANGEPASSWORD');
            List <User> userList = [SELECT Id, ToU_Accepted__c, UID__c
                                //X2FA_Session__c, TD_User__c
                                FROM User WHERE Id =:UserInfo.getUserId()];
            if (!userList.isEmpty()){
                if (!userList[0].ToU_Accepted__c){
                    //PageReference pr = new PageReference('/ISSP_TC_Redirect');
                    PageReference pr = new PageReference('/ISSP_TC_Accept');
                    system.debug('REDIRECTING TO TC ACCEPT');
                    pr.setRedirect(true);
                    return pr;
                }
                else if (userList[0].UID__c != '' && userList[0].UID__c != null){
                    //PageReference pr = new PageReference('/ISSP_ChangePasswordRedirect');
                    PageReference pr = new PageReference('/ISSP_ChangePassword' + commParam);
                    system.debug('REDIRECTING TO CHANGE PASSWORD');
                    pr.setRedirect(true);
                    return pr;
                }
            }
        }
        return null;
    }


    public PageReference docontinue(){
        if(!accept){
            errorMessage = new list<string>();
            errorMessage.add(Label.ISSP_accept_General_Conditions);
            return null;
        }
        else{
            List <User> userList = [SELECT Id, ToU_Accepted__c FROM User WHERE Id =:UserInfo.getUserId()];
            if (!userList.isEmpty()){
                userList[0].ToU_Accepted__c = true;
                userList[0].Date_ToU_accepted__c = system.now();
                update userList;
            }
            PageReference pr = new PageReference('/ISSP_Homepage' + commParam);
            pr.setRedirect(true);
            return pr;
        }
    }

    public PageReference CheckLogoutorSurvey(){
    System.debug('SFI Start CheckLogoutorSurvey Method');

        //Select all active LogoutSrvey Custom settings
        List<ISSPLogoutSurvey__c> LogoutSurvey_List = new List<ISSPLogoutSurvey__c>([select Name, Survey_Link__c, isActive__c  from ISSPLogoutSurvey__c where isActive__c =: true ]);
        System.debug('SFI LogoutSurvey_List'+LogoutSurvey_List);

        if (LogoutSurvey_List != null && LogoutSurvey_List.size() > 0)
        {
            //Get the newest one according to Survey_Number Field
            ISSPLogoutSurvey__c LogoutSurvey_rec = new ISSPLogoutSurvey__c();
            LogoutSurvey_rec = LogoutSurvey_List[0];
            SurveyName = LogoutSurvey_rec.Name ;
            System.debug('SFI LogoutSurvey_rec'+LogoutSurvey_rec);

            //Get the Survey ID
            String SurveyID = (LogoutSurvey_rec.Survey_Link__c).substringAfterLast('iv=');

            //Retrieve the current looged in useriv=
            User userRec = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getUserId()][0];
            System.debug('SFI userList'+userRec);

            //prepare the full survey URL
            String fullSurveyURL = LogoutSurvey_rec.Survey_Link__c.removeStart('http:')+'&q4='+userRec.ID+'&q5='+SurveyID;

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
            String BaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            String redirectURL = '/secur/logout.jsp?retUrl=' + BaseURL + '/ISSP_Login';
            if(CommunityName != null && CommunityName != '') redirectURL +='?CommunityName='+CommunityName;
            Pagereference p =  new PageReference(redirectURL);
            p.setRedirect(true);
            return p;
        }
    return null;
    }

    public Boolean getCountryRequirementPermission() {
        return ISSP_Ctrl_Country_Requirements.isAllowedAccess();
    }

    public Boolean getOperationalCalendarPermission() {
        return ISSP_OperationalCalendarController.isAllowedAccess();
    }
}