public with sharing class PortalCasesCtrl {
 
    public static User myUser {
        get {
            if(myUser == null) {
                myUser = [
                    SELECT Id, AccountId, ContactId, Contact.AccountId, Contact.Financial_Assessment_Contact__c
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()
                ];
            }
            return myUser;
        }
        set;
    }

    public static Boolean seeAllCases;
    public static Boolean limitCases;
    public static String currentListViewName;
    public static Boolean apUser;
    public static String selectedList;
    public static String soqlOrder;
    public static Id myAccountId;
    public static Set<String> recordTypesSet;
    public static Set<String> openIFAPStatuses;
    public static Contact con;
    public static PagedResult result;
    private static ISSP_PermissionFilterFactory.PermissionSetFilter     thePermissionSetFilter;
    private static ISSP_PermissionFilterFactory.ProfilePermissionFilter theProfilePermissionFilter;
    private static List<ISSPCaseListView__c> csCaseListViews;
    public static Map<String, ISSPCaseListView__c> caseListViewMap;
    public static List<Portal_Application_Right__c> appRightList;
    public static ISSP_Portal_Service_Ids__c serviceIdInstance;
    public static Boolean adminProfile = ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId());

    /* 
    * @description Main method that returns a list of cases 
    * @params
    * @return List<Case>
    */
    @AuraEnabled(cacheable=true)
    public static PagedResult getRecentCases(Boolean limitView, Boolean seeAll) {
        seeAllCases = seeAll;
        limitCases = limitView;

        initialization();

        return getCases();
    }

    /* 
    * @description Initialize and populate properties related to user logged
    * @params
    * @return
    */
    private static void initialization() {
        try {
            currentListViewName = '3_MyRecentCases';

            apUser = false;
            System.debug('____ [cls PortalCasesCtrl - initialization] myUser - ' + myUser);

            if(myUser.ContactId != null) {
                List <Portal_Application_Right__c> appRightList = [
                    SELECT Id
                    FROM Portal_Application_Right__c
                    WHERE Contact__c = :myUser.ContactId
                    AND Right__c = 'Access Granted'
                    AND Portal_Application__r.Name = 'Airline Participation'
                ];
                if(!appRightList.isEmpty()) {
                    System.debug(LoggingLevel.FINE, '____ [cls PortalCasesCtrl - initialization] appRightList - ' + appRightList);
                    apUser = true;
                }

                myAccountId = myUser.Contact.AccountId;
            }
            
            initFilters();
            initCaseListViewMap();
            
        } catch(Exception exp) {
                ISSP_Utilities.exceptionDump(exp);
        }
    }

    /* 
    * @description Populate property "theProfilePermissionFilter" with User Profile Id and "thePermissionSetFilter" with all permissionSetIDs related to Custom Setting ISSPCaseListView__c
    * @params
    * @return
    */    
    private static void initFilters() {
        csCaseListViews = ISSPCaseListView__c.getAll().values();

        theProfilePermissionFilter = ISSP_PermissionFilterFactory.createProfilePermissionFilter();
        thePermissionSetFilter = ISSP_PermissionFilterFactory.createPermissionSetFilter(csCaseListViews, 'Permission_set__c');
    }

    /* 
    * @description Populate "caseListViewMap" with possible values for Case List View
    * @params
    * @return
    */
    private static void initCaseListViewMap() {
        List<String> ListViewNameList = new List<String>();
        caseListViewMap = new Map<String, ISSPCaseListView__c>();

        for(ISSPCaseListView__c caseListViewItem : csCaseListViews) {
            Boolean resultPermission1 = true; 
            if(!theProfilePermissionFilter.isDataEmpty(caseListViewItem, 'Profiles_Id__c')) {
                resultPermission1 = theProfilePermissionFilter.isUserPermittedFor(caseListViewItem, 'Profiles_Id__c');
            }
                 
            Boolean resultPermission2 = true; 
            if(!thePermissionSetFilter.isDataEmpty(caseListViewItem, 'Permission_set__c')) {
                resultPermission2 = thePermissionSetFilter.isUserPermittedFor(caseListViewItem, 'Permission_set__c');
            }
                
            if(resultPermission1 && resultPermission2) {
                System.debug(LoggingLevel.FINE, '____ [cls PortalCasesCtrl - initCaseListViewMap] caseListViewItem.Name - ' + caseListViewItem.Name);
                System.debug(LoggingLevel.FINE, '____ [cls PortalCasesCtrl - initCaseListViewMap] apUser - ' + apUser);
                if (caseListViewItem.Name == 'ISSP_AP_Cases') {
                    if (apUser) {
                        caseListViewMap.put(caseListViewItem.Name, caseListViewItem);
                        ListViewNameList.add(caseListViewItem.Name);
                    }
                } else {
                    if(!seeAllCases && !caseListViewItem.isAdmin__c) {
                        caseListViewMap.put(caseListViewItem.Name, caseListViewItem);
                        ListViewNameList.add(caseListViewItem.Name);
                    } else {
                        if(seeAllCases && caseListViewItem.isAdmin__c) {
                            caseListViewMap.put(caseListViewItem.Name, caseListViewItem);
                            ListViewNameList.add(caseListViewItem.Name);
                        } 
                    }
                }
            }
        }

        ListViewNameList.sort();
        if(!ListViewNameList.isEmpty()) {
            selectedList = ListViewNameList.get(0);
        }

        if(currentListViewName != null && caseListViewMap.containsKey(currentListViewName)) {
            selectedList = currentListViewName;
        }
        System.debug('____ [cls PortalCasesCtrl - initCaseListViewMap] selectedList - ' + selectedList);
    }   

    /* 
    * @description Return the list of Cases using fields of a Case Field Set and filtered by "ISSPCaseListView__c" Custom Setting using SOQL Filter field.
    * @params
    * @return List<Case>
    */
    private static PagedResult getCases() {
        String queryString;
        Set<String> fieldPathSet = new Set<String>{'CaseNumber'};

        for(Schema.FieldSetMember f : getFields()) { 
            fieldPathSet.add(f.getFieldPath());
        }

        String query = ' CaseArea__c, Reason1__c, CNSCase__c, Origin, IsClosed, Classification_SIS__c, TIP_Partner_Product__c, RecordType.Name, RecordType.DeveloperName, Owner.Name, LastModifiedDate, CreatedBy.Name ';
        Boolean hasStatus = false;
        
        for(String fieldPath : fieldPathSet) {
            if(fieldPath.trim() == 'Status') {
                hasStatus = true;
            }
            query +=  ',' + fieldPath;
        }

        if(!hasStatus) {
            query += ', Status';
        }
        
        String queryConditions = getQueryConditions();

        queryString = 'SELECT ' + query.substring(1) + ' FROM Case ' + queryConditions + ' ORDER BY LastModifiedDate DESC ';

        if(limitCases) {
            queryString += 'LIMIT 4';
        } else {
            queryString += 'LIMIT 2000';
        }

        result = new PagedResult();
        result.records = Database.query(queryString);
        result.totalItemCount = result.records.size();
        result.userAdmin = adminProfile;

        System.debug(LoggingLevel.FINE, '____ [cls PortalCasesCtrl - getCases] queryString - ' + queryString);
        System.debug('____ [cls PortalCasesCtrl - getCases] queryResult - ' + result.records.size() + ' record(s) - ' + result.records);

        /* Generate Case URL */
        result.url = JSON.serialize(setCaseURLs((List<Case>)result.records));
        
        return result;
    }

    private static Map<Id, String> setCaseURLs(List<Case> records) {
        Map<Id, String> casesMap;
        Map<Id, String> caseURL;
        
        /* Generate Case URL */
        recordTypesSet = new Set<String>{
            'FDS ASP Management',
            'FDS ICCS Bank Account Management',
            'FDS ICCS Membership Management',
            'FDS ICCS Product Management'
        };
        openIFAPStatuses = new Set<String>{
            'action needed', 
            'agent notified (email)', 
            'agent notified (mail)', 
            'sanity check failure'
        };
        
        serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();

        if(String.isNotBlank(serviceIdInstance.TIP_Portal_Service_Id__c)) {
            appRightList = [
                SELECT Id 
                FROM Portal_Application_Right__c
                WHERE Contact__c = :myUser.ContactId 
                    AND Right__c = 'Access Granted' 
                    AND Portal_Application__c = :serviceIdInstance.TIP_Portal_Service_Id__c 
                LIMIT 1
            ];

            System.debug('____ [cls PortalCasesCtrl - getCases] appRightList - ' + appRightList);
        }

        casesMap = new Map<Id, String>();
        caseURL = new Map<Id, String>();

        for(Case record : records) {
            casesMap = pageLoad(record);
            caseURL.putAll(casesMap);
        }
        
        System.debug(LoggingLevel.FINE, '____ [cls PortalCasesCtrl - setCaseURLs] caseURL - ' + caseURL);

        return caseURL;
    }

    /* 
    * @description Get Field Set using "caseListViewMap" populated by "initCaseListViewMap()" method
    * @params
    * @return List<Schema.FieldSetMember>
    */
    private static List<Schema.FieldSetMember> getFields() {
       return selectedList == null || selectedList == '' ? new List<Schema.FieldSetMember>() : sObjectType.Case.FieldSets.getMap().get(caseListViewMap.get(selectedList).Field_Set_API_Name__c).getFields();
    }

    /*
    * @description Generate filter to create a query. Filtered by "ISSPCaseListView__c" Custom Setting using SOQL Filter field.
    * @params
    * @return String
    */
    private static String getQueryConditions() {
        
        if(caseListViewMap.isEmpty()) {
            return 'WHERE ID = NULL';
        }
        
        String queryConditions;
        if(String.isNotBlank(selectedList)) {
            queryConditions = caseListViewMap.get(selectedList).SOQL_Filter__c;
        }

        if(caseListViewMap.get(selectedList).isOwnedByMe__c) {
            queryConditions += ' AND OwnerId = \'' + myUser.Id + '\' ';
        }

        if(caseListViewMap.get(selectedList).isMyAccount__c) {
            List<User> lsUsers = [
                SELECT Id
                FROM User
                WHERE AccountId = :myAccountId
                AND Contact.User_Portal_Status__c IN ('Approved User','Approved Admin')
            ];

            String userIds = '';
            for(User u : lsUsers) {
                userIds += '\'' + u.Id  + '\',';
            }

            if(userIds.endsWith(',')) {
                userIds = userIds.substring(0,userIds.length()-1);
            }

            if(userIds != '') {
                queryConditions += ' AND OwnerId IN (' + userIds + ') ';
            }
        }

        return String.isNotBlank(queryConditions) ? queryConditions : '';
    } 


    /*
    * @description Generate URL Redirection for Cases
    * @params Case record
    * @return Map<Id, String>
    */ 
    private static Map<Id, String> pageLoad(Case record) {
        if(record.CNSCase__c == true) {
            return new Map<Id, String>{
                record.Id =>
                OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_Case?caseId=' + record.Id + '&communityName=CNS') 
            };
        }

        /* Transparency in Payment's portal access assignment */
        if((appRightList != null && !appRightList.isEmpty()) && record.Status == TIP_Utils.CASE_STATUS_DRAFT && record.CaseArea__c == TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS) {
            if(record.Reason1__c == TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT) {
                return new Map<Id, String>{
                    record.Id =>
                    OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_TIP_Home?caseId=' + record.Id) 
                };
            }
            
            if(record.Reason1__c == TIP_Utils.CASE_REASON_PRODUCT_MANAGEMENT) {
                return new Map<Id, String>{
                    record.Id => 
                    OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_TIP_Home?prodId=' + record.TIP_Partner_Product__c)
                };
            }
        }

        /* Open IFAP cases must be opened via the page used specifically for open IFAP cases (ISSP_IFAPCases) */
        if(record.RecordType.name == 'IATA Financial Review') {
            if(openIFAPStatuses.contains(record.Status.toLowerCase()) && myUser.Contact.Financial_Assessment_Contact__c) {
                return new Map<Id, String>{
                    record.Id => 
                    OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_IFAPCases?id=' + record.Id)
                };
            }
        } else if((record.RecordType.Name == 'OSCAR Communication' && (record.Origin == 'Massive FOP Creation' || record.Origin == 'FoP automatic renewal') && record.Owner.Name.startsWith('NewGen PCI')) 
            || (record.RecordType.Name == 'OSCAR Communication' && record.Status == 'Draft' && (record.Reason1__c == AMS_Utils.CASE_REASON_FOR_MANAGEMENT || record.Reason1__c == AMS_Utils.CASE_REASON_PCI_DSS_COMPLIANT))) {
            
            return new Map<Id, String>{
                record.Id => 
                OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_ANG_PCI?caseId=' + record.Id)
            };
        } else if(record.RecordType.Name == 'OSCAR Communication' && record.Reason1__c == 'Annual revalidation' && record.Owner.Name.startsWith('Annual Revalidation')) {
            return new Map<Id, String>{
                record.Id => 
                OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_ANG_ANNUAL_REVALIDATION?caseId=' + record.Id)
            };
        } else if (record.RecordType.Name == 'OSCAR Communication' && record.Owner.Name.startsWith('Model A Onboarding')) {
            return new Map<Id, String>{
                record.Id => 
                OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_ModelA_Onboarding?caseId=' + record.Id)
            };
        }

        /* If case is a SIS Joining Form */
        if(record.RecordType.DeveloperName == 'IDFS_Airline_Participation_Process' && record.Classification_SIS__c == 'SIS Membership' 
            && record.Status == 'Draft' && !record.isClosed && !record.Owner.Name.StartsWith('Recycle Bin')) {
            
            return new Map<Id, String>{
                record.Id => 
                OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_SISMembershipApplicationForm?id=' + record.Id + '&step=2')
            };
        }

        /* If Case is an ICCS Case, redirect to ICCS Service */
        if(record.Origin == 'Portal' && recordTypesSet.contains(record.RecordType.Name)) {
            return new Map<Id, String>{
                record.Id => 
                OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_ICCS_Service?caseId=' + record.Id)
            };
        }

        /*If no match was done*/
        return new Map<Id, String>{
            record.Id => 
            '/csportal/s/case-details?caseId=' + record.Id
        };
    }

    public class PagedResult {
        @AuraEnabled
        public Integer totalItemCount { get;set; }        
        @AuraEnabled
        public SObject[] records { get;set; }
        @AuraEnabled
        public Boolean userAdmin { get;set; }
        @AuraEnabled
        public String url { get;set; }
    }     

    /* 
    * @description Return cases related to logged User, used in search functionality
    * @params String searchKey
    * @return List<Case>
    */
    @AuraEnabled(cacheable=true)
    public static PagedResult getFilteredCases(String searchKey) {
        Boolean isAdmin = ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId());

        String finalQuery = 'SELECT CaseNumber, Type_of_case_Portal__c, Subject, Country_concerned_by_the_query__c, CreatedDate, LastModifiedDate, Portal_Case_Status__c, Status, CaseArea__c, Reason1__c, CNSCase__c, Origin, IsClosed, Classification_SIS__c, TIP_Partner_Product__c, RecordType.Name, RecordType.DeveloperName, Owner.Name, CreatedBy.Name ' +
            'FROM Case ' +
            'WHERE Visible_on_ISS_Portal__c = true AND ' + 
                '(CaseNumber LIKE \'%'+ String.escapeSingleQuotes(searchKey) +'%\' OR Subject LIKE \'%'+ String.escapeSingleQuotes(searchKey) +'%\') ';

        if(isAdmin) {
            finalQuery += 'AND AccountId = \''+ myUser.AccountId +'\' ';
        } else {
            finalQuery += 'AND is_Portal_user_equal_case_contact__c = \'true\' ';
        }

        finalQuery += 'LIMIT 4';

        List<Case> queryResult = Database.query(finalQuery);

        System.debug('____ [cls PortalCasesCtrl - getFilteredCases] finalQuery - ' + finalQuery);
        System.debug('____ [cls PortalCasesCtrl - getFilteredCases] queryResult - ' + queryResult);

        result = new PagedResult();
        result.records = queryResult;
        result.totalItemCount = result.records.size();
        result.userAdmin = adminProfile;

        /* Generate Case URL */
        result.url = JSON.serialize(setCaseURLs(queryResult));

        return result;
    } 

    /* 
    * @description Return a specific case to display the case details
    * @params String caseId
    * @return Case
    */
    @AuraEnabled
    public static Case getCaseById(String caseId) {
        Case caseAux = [SELECT CaseNumber, Type_of_case_Portal__c, Subject, Country_concerned_by_the_query__c, 
                        CreatedDate, CreatedBy.Name,LastModifiedDate, Portal_Case_Status__c,Topic__c,
                        Subtopic__c, Region__c, Country_concerned__c, Account_Concerned__r.IATACode__c, 
                        Description,E2CP__AdditionalCC__c,Account_Concerned__c, Status

                        FROM Case 
                        WHERE Id = :caseId];

        return caseAux;
    }

    /*
    * Returns the comments for a case, given the case id
    */
    @AuraEnabled 
    public static List<MessageWrapper> getCaseMessages(String caseId){
        List<MessageWrapper> lstToReturn = new List<MessageWrapper>();

        List<CaseComment> lstCaseCommentsAux = [SELECT Id, ParentId, CommentBody, IsPublished, 
                                                CreatedDate, CreatedById , CreatedBy.Name , IsDeleted
                                                FROM CaseComment
                                                WHERE ParentId = :caseId AND IsDeleted = false
                                                ORDER BY CreatedDate ASC];
        
        if(lstCaseCommentsAux != null && !lstCaseCommentsAux.isEmpty()){
            for(CaseComment caseCommentAux : lstCaseCommentsAux){
                Boolean isSelfAux = caseCommentAux.CreatedById == UserInfo.getUserId();
                lstToReturn.add(new MessageWrapper(caseCommentAux.CommentBody, 
                                                    caseCommentAux.CreatedDate, 
                                                    caseCommentAux.CreatedBy.Name, 
                                                    isSelfAux, 
                                                    caseCommentAux.Id));
            }
        }

        return lstToReturn;
    }

    @AuraEnabled
    public static ReturnWrapper submitNewMessage(String caseId, String messageTextAux){
        ReturnWrapper returnWrapper = new ReturnWrapper();
        Savepoint sp = Database.setSavepoint();
        Case caseAux = new Case();
        caseAux.Id = caseId;
        caseAux.New_interaction__c = 'New Comment';
        caseAux.New_Comment_From_Connection_User__c = true;
        CaseComment caseCommentAux = new CaseComment();
        caseCommentAux.ParentId = caseId;
        caseCommentAux.CommentBody = messageTextAux;

        try{
            insert caseCommentAux;
            update caseAux;
            returnWrapper = new ReturnWrapper(true, Label.CSP_CaseMessage_SubmitSuccess, ''); 
        }catch(Exception e){
            Database.rollback(sp);
            returnWrapper = new ReturnWrapper(false, e.getMessage(), '');
        }

        return returnWrapper;
    }

    /*
    * Method that adds a new Recipient for this case
    */
    @AuraEnabled
    public static ReturnWrapper addNewRecipient(String caseId, String newRecipientEmail){
        ReturnWrapper returnWrapper = new ReturnWrapper();

        String findEmail = newRecipientEmail.trim();
        
        if (findEmail == null || findEmail == ''){
            returnWrapper.success = false;
            returnWrapper.returnMessage = 'No email was provided. ';
            return returnWrapper;
        }

        // find contact with input email
        list<Contact> listContact = [SELECT Id, Email, AccountId FROM Contact WHERE Email = :findEmail AND Status__c = 'Active' LIMIT 1];
        if (listContact.size() != 1) {
            returnWrapper.success = false;
            returnWrapper.returnMessage = Label.ISSP_CCOther_Wrong_Emails.replace('{0}',findEmail);
            return returnWrapper;
        }

        Boolean isDPCUser = false;
        Id profileId = Userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        //Verify if user is a PWC profile
        if (profileName.startsWith('ISS Portal DPC Admin') ) {  isDPCUser = true; }

        //get partner user role id
        Id PARTNER_USER_ROLE = [SELECT id FROM CaseTeamRole WHERE Name = 'Partner User Role'].Id;

        //get the case
        Case caseAux = PortalCasesCtrl.getCaseById(caseId);

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
                    WHERE ContactId = :contact.Id AND isActive = true AND Contact.AccountId = :caseAux.Account_Concerned__c AND Contact.User_Portal_Status__c IN ('Approved Admin', 'Approved User') ];
                if (!listUser.isEmpty()) {
                    memberId = listUser[0].Id;
                } else {
                    if (contact.AccountId != caseAux.Account_Concerned__c){
                        //if it's DPC, a user is not found and the selected contact is not in the
                        //same Account Concerned then we cannot continue

                        returnWrapper.success = false;
                        returnWrapper.returnMessage = 'User is now in the same account concerned';
                        return returnWrapper;
                    }
                }
            }
            CaseTeamMember teammember = new CaseTeamMember(ParentId = caseAux.Id, MemberId = memberId, TeamRoleId = PARTNER_USER_ROLE);
            System.debug(teammember);
            insert teammember;
            
            if(caseAux.E2CP__AdditionalCC__c != null && caseAux.E2CP__AdditionalCC__c != ''){
                caseAux.E2CP__AdditionalCC__c =  caseAux.E2CP__AdditionalCC__c + ';' + contact.Email;
            }else{
                caseAux.E2CP__AdditionalCC__c = contact.Email;
            }
            update caseAux;

            returnWrapper.success = true;
            returnWrapper.returnMessage = 'Recipient added with success!';

        } catch (DMLException e) {
            String messages = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                messages += ' ' + findemail + ': ' + e.getDmlMessage(i);
            }
            Database.rollback(sp);

            returnWrapper.success = false;
            returnWrapper.returnMessage = messages;
        }

        return returnWrapper;
    }

    /*
    * Method that removes a recipient from this case
    */
    @AuraEnabled
    public static ReturnWrapper removeRecipient(String caseId, String recipientEmail){
        ReturnWrapper returnWrapper = new ReturnWrapper();

        String emailFiltered = recipientEmail==null ? '': recipientEmail.trim();

        Case caseAux = PortalCasesCtrl.getCaseById(caseId);

        Savepoint sp = Database.setSavepoint();
        try {
            List<String> listNews = new List<String>();
            for (String email: caseAux.E2CP__AdditionalCC__c.split(';')) {
                String trimEmail = email.trim();
                if (trimEmail != emailFiltered) {
                    listNews.add(trimEmail);
                }
            }
            caseAux.E2CP__AdditionalCC__c = (String.join(listNews,';'));
            
            update caseAux;

            //get partner user role id
            Id PARTNER_USER_ROLE = [SELECT id FROM CaseTeamRole WHERE Name = 'Partner User Role'].Id;

            list<Contact> listContact = [SELECT Id, AccountId FROM Contact WHERE email = :emailFiltered];
            list<User> listUser = [SELECT Id, Contact.AccountId FROM User WHERE email = :emailFiltered];
            list<CaseTeamMember> listMember = [SELECT id FROM CaseTeamMember
                WHERE ParentId = :caseId AND TeamRoleId = :PARTNER_USER_ROLE AND (MemberId IN :listContact OR MemberId IN :listUser)];
            if (!listMember.isEmpty()) {
                delete listMember;
            }

            returnWrapper.success = true;
            returnWrapper.returnMessage = 'Recipient removed with success!';

        } catch (DMLException e) {
            System.debug('ERROR delTeamMember ' + e.getMessage());
            
            String messages = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                messages += ' ' + emailFiltered + ': ' + e.getDmlMessage(i);
            }
            Database.rollback(sp);

            returnWrapper.success = false;
            returnWrapper.returnMessage = messages;
        }

        return returnWrapper;
    }

    /*
    *   Wrapper class for returning database operations success / unsuccess
    */
    public class ReturnWrapper {
        @AuraEnabled
        public Boolean success {get; set;}
        @AuraEnabled
        public String returnMessage {get; set;}
        @AuraEnabled
        public String extraDetails {get; set;}

        public ReturnWrapper(){}

        public ReturnWrapper(Boolean successAux, String returnMessageAux, String extraDetailsAux){
            this.success = successAux;
            this.returnMessage = returnMessageAux;
            this.extraDetails = extraDetailsAux;
        }
    }

    /*
    * Wrapper class for the messaging system
    */
    public class MessageWrapper {

        @AuraEnabled
        public String messageText{get; set;}
        @AuraEnabled
        public Datetime timeStamp{get; set;}
        @AuraEnabled
        public String senderName{get; set;}
        @AuraEnabled
        public Boolean isSelf{get; set;}
        @AuraEnabled
        public String id{get; set;}

        public MessageWrapper(){}

        public MessageWrapper(String messageTextAux, Datetime timeStampAux, String senderNameAux, Boolean isSelfAux, String idAux){
            this.messageText = messageTextAux;
            this.timeStamp = timeStampAux;
            this.isSelf = isSelfAux;
            this.id = idAux;
            this.senderName = senderNameAux;
        }

    }




}