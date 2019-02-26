public with sharing class RecentCasesController {

    public static Id userId = UserInfo.getUserId();
    public static RecentCasesWrapper caseWrapper = new RecentCasesWrapper();
    public static String sortExp  = 'CaseNumber';
    public static Boolean isExtinstion = false;
    public static Boolean isNewGenApp = false;
    public static String ngaListViewName = '';
    public static Boolean isAdmin;
    public static String currentListViewName;
    public static Boolean apUser;
    public static String selectedList;
    public static String communityName;
    public static String soqlOrder;
    public static Id myAccountId;
    public static List<Case> caseList;
    public static List<Case> caseList_CompanyOpenCases;
    public static List<Case> caseList_ReqMyInput;
    private static ISSP_PermissionFilterFactory.PermissionSetFilter     thePermissionSetFilter;
    private static ISSP_PermissionFilterFactory.ProfilePermissionFilter theProfilePermissionFilter;
    private static List<ISSPCaseListView__c> csCaseListViews = ISSPCaseListView__c.getAll().values();
    public static Map<String, ISSPCaseListView__c> caseListViewMap = new Map<String, ISSPCaseListView__c>();

    @AuraEnabled(cacheable=true)
    public static RecentCasesWrapper getRecentCases() {
        /** ISSP_HomePage Constructor **/
        if(!Userinfo.getUserType().contains('Guest')) {
            populateVariables(caseWrapper);
        }
        Id profileId = UserInfo.getProfileId();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId].Name;
        isAdmin = (profileName.containsIgnoreCase('admin'));
        /** ISSP_HomePage Constructor **/ 

         /** ISSP_CaseList Constructor **/
        System.debug('KER1 START ISSP_CaseList(ISSP_Homepage controller)');
        isExtinstion = true ;
        initialization(caseWrapper);
        /** ISSP_CaseList Constructor **/

        getCases(caseWrapper);

        return caseWrapper;             
    }

    public static void populateVariables(RecentCasesWrapper caseWrapper) {
        User user = [SELECT Id, LanguageLocaleKey, ContactId, ProfileId FROM User WHERE Id = :userId];
        System.debug('\n\n\n user:'+user+'\n\n\n');

        Contact con = [
            SELECT Id, Credit_Card_Payment_Link__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c, 
                Account.Top_Parent__c, AccountId, Account.Industry, Account.Accumulated_Irregularities__c, Account.Category__c, Account.Status__c, Account.CNS_Agency__c 
            FROM Contact 
            WHERE Id = :user.ContactId
        ];

        String topParentId = con.Account.Top_Parent__c == null ? con.AccountId : con.Account.Top_Parent__c;

        caseList = [
            SELECT Id, Outstanding_Amount__c, IRR_Approval_Rejection__c, Update_AIMS_IRR__c, IRR_Withdrawal_Approval_Rejection__c, 
                Inform_Agent_DEF__c, REI_ApprovalRejectin__c, Recordtype.Name, Status, DEF_Approval_Rejection__c 
            FROM Case
            WHERE is_Portal_user_equal_case_contact__c = 'true'
            AND Visible_on_ISS_Portal__c = true
            AND CreatedDate >:Date.newInstance(2014, 1, 13)
            AND RecordType.Name != 'IATA Financial Review'
            AND IsClosed = false
        ];
        System.debug('MY OPEN: ' + caseList.size());
        caseWrapper.caseListSize = caseList.size();

        caseList_ReqMyInput = [
            SELECT Id from Case
            WHERE Status = 'Pending customer'
            AND is_Portal_user_equal_case_contact__c = 'true'
            AND Visible_on_ISS_Portal__c = true
            AND CreatedDate > :Date.newInstance(2014, 1, 13)
            AND RecordType.Name != 'IATA Financial Review'
        ];
        System.debug('INPUT OPEN: ' + caseList_ReqMyInput.size());
        caseWrapper.caseList_ReqMyInputSize = caseList_ReqMyInput.size();

        if(ISSP_Constant.adminIdSet.contains(user.ProfileId)) {
            System.debug('IS PARTNER');
            System.debug('TOP PARENT: ' + topParentId);
            caseList_CompanyOpenCases = [
                SELECT Id, Outstanding_Amount__c, IRR_Approval_Rejection__c, Update_AIMS_IRR__c, IRR_Withdrawal_Approval_Rejection__c, 
                    Inform_Agent_DEF__c, REI_ApprovalRejectin__c, Recordtype.Name, Status, DEF_Approval_Rejection__c
                FROM Case 
                WHERE (Contact.Account.Top_Parent__c = :topParentId OR Contact.AccountId = :topParentId)
                AND Visible_on_ISS_Portal__c = true
                AND IsClosed = false
                AND CreatedDate > :Date.newInstance(2014, 1, 13)
                AND RecordType.Name != 'IATA Financial Review'
            ];
            System.debug('COMPANY OPEN: ' + caseList_CompanyOpenCases.size());
        } else {
            System.debug('NOT IS PARTNER');
            System.debug('TOP PARENT: ' + topParentId);
            caseList_CompanyOpenCases = [
                SELECT Id 
                FROM Case 
                WHERE ContactId = :con.Id
                AND IsClosed = false
                AND Visible_on_ISS_Portal__c = true
                AND CreatedDate > :Date.newInstance(2014, 1, 13)
                AND isSISUser__c = 'true'
            ];
            System.debug('COMPANY OPEN: ' + caseList_CompanyOpenCases.size());
        }
        caseWrapper.caseList_CompanyOpenCasesSize = caseList_CompanyOpenCases.size();
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getIsAdminUser() {
        return ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId());
    }        

    public static void initialization(RecentCasesWrapper caseWrapper) {
        try {
            if(!isExtinstion) {
                caseWrapper.sortDirection = 'DESC';
            } else {
                if(isNewGenApp) {
                    currentListViewName = ngaListViewName;
                    caseWrapper.sortDirection = 'DESC';
                } else {
                    currentListViewName = '3_MyRecentCases';
                    caseWrapper.sortDirection = 'DESC';
                }	
            }

            apUser = false;
            User myUser = [
                SELECT Id, ContactId, Contact.AccountId 
                FROM User 
                WHERE Id = :userId
            ];
            if(myUser.ContactId != null) {
				List <Portal_Application_Right__c> appRightList = [
                    SELECT Id 
                    FROM Portal_Application_Right__c 
                    WHERE Contact__c =: myUser.ContactId 
                    AND Right__c = 'Access Granted' 
                    AND Portal_Application__r.Name = 'Airline Participation'
                ];
		        if(!appRightList.isEmpty()) {
		            apUser = true;
		        }

                myAccountId = myUser.Contact.AccountId;
            }
            
            isAdmin = false;
            
            initFilters();
            initCaseListViewMap();
            
        } catch(Exception exp) {
                ISSP_Utilities.exceptionDump(exp);
        }
    }

    private static void initFilters() {
        System.debug('initFilters user id >> ' + userId);
        /* UserInfo.getProfileId().substring(0,15) */
        theProfilePermissionFilter = ISSP_PermissionFilterFactory.createProfilePermissionFilter();
        /* Get all permissionSetIDs related to Custom Setting ISSPCaseListView__c */
        thePermissionSetFilter =ISSP_PermissionFilterFactory.createPermissionSetFilter(csCaseListViews, 'Permission_set__c');
    }

    private static void initCaseListViewMap() {
        List<String> ListViewNameList = new List<String>();

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
                System.debug('caseListViewItem.Name: ' + caseListViewItem.Name);
                System.debug('apUser: ' + apUser);
                System.debug('isAdmin: ' + isAdmin);
                System.debug('caseListViewItem.isAdmin__c: ' + caseListViewItem.isAdmin__c);
                if (caseListViewItem.Name == 'ISSP_AP_Cases') {
                    if (apUser) {
                        caseListViewMap.put(caseListViewItem.Name, caseListViewItem);
                        ListViewNameList.add(caseListViewItem.Name);
                    }
                } else {
                    if(!isAdmin && !caseListViewItem.isAdmin__c) {
                        caseListViewMap.put(caseListViewItem.Name, caseListViewItem);
                        ListViewNameList.add(caseListViewItem.Name);
                    } else {
                        if(isAdmin && caseListViewItem.isAdmin__c) {
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

        String ListViewName = '';
        if(isNewGenApp) {
            ListViewName = ngaListViewName;
        } else {
            ListViewName = currentListViewName;
        }

        if(ListViewName != null && caseListViewMap.containsKey(ListViewName)){
            selectedList = ListViewName;
        }
    }   

    public static void getCases(RecentCasesWrapper caseWrapper) {
        System.debug('basto1p - getCases BEGIN');
        //basto1p
        caseWrapper.myRecentCases = setCon();

        System.debug('basto1p - getCases.myRecentCases='+caseWrapper.myRecentCases);

        String statusFieldValMapKey = '';
        caseWrapper.mapFieldsValue = new Map<String, String>();
        for (Case Item : caseWrapper.myRecentCases) {
            //Add mapping for Status field
            statusFieldValMapKey = ISSP_Case.STATUS_FLD_NAME + Item.Status;
            caseWrapper.mapFieldsValue.put(statusFieldValMapKey, ISSP_Case.getFieldMappedValue(ISSP_Case.STATUS_FLD_NAME, Item.Status));
        }
        System.debug('basto1p - mapFieldsValue='+caseWrapper.mapFieldsValue);
    }

    public static List<Case> setCon() {
        String sortFullExp = caseWrapper.sortExpression  + ' ' + caseWrapper.sortDirection;
        //AEF:
        Set<String> fieldPathSet = new Set<String>{'CaseNumber'};
        for(Schema.FieldSetMember f : getFields()) {
            fieldPathSet.add(f.getFieldPath());
        }
        //basto1p
        String query = '  Account.Name , Contact.Name, Owner.Name, E2CP__AdditionalCC__c   ';
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
        
        String queryString ;
        if(String.isNotBlank(selectedList)) {
            if (caseListViewMap.containsKey(selectedList)) {
                soqlOrder = caseListViewMap.get(selectedList).SOQL_Order__c;
            }
        }
        System.debug('sortFullExp: ' + sortFullExp);
        System.debug('selectedList: ' + selectedList);
        System.debug('soqlOrder: ' + soqlOrder);
        if(!isExtinstion) {
            if (sortFullExp == 'CaseNumber ASC' && soqlOrder != '' & soqlOrder != null)
                sortFullExp = soqlOrder;
            queryString = 'select '+query.substring(1) +' from Case  '+getQueryConditions()+' order by '+ sortFullExp;
        }
        else if(isNewGenApp) {
            queryString = 'select '+query.substring(1) +', Description, (SELECT Id, CreatedDate, CommentBody, CreatedById, CreatedBy.Name FROM CaseComments order by CreatedDate ASC limit 200) from Case  '+getQueryConditions()+' order by CreatedDate DESC limit 200';
        } else {
            queryString = 'select '+query.substring(1) +' from Case  '+getQueryConditions()+' order by CreatedDate '+ caseWrapper.sortDirection +' limit 5';
        }

        ISSP_Utilities.log('SQL String: ' + queryString);
        //newgenapp

        return Database.query(queryString);
    }

    public static List<Schema.FieldSetMember> getFields() {
       return selectedList == null || selectedList == '' ? new List<Schema.FieldSetMember>() : sObjectType.Case.FieldSets.getMap().get(caseListViewMap.get(selectedList).Field_Set_API_Name__c).getFields();
    }    

    public static String getQueryConditions() {
        System.debug('caseListViewMap >>> ' + caseListViewMap);
        
        if(caseListViewMap.isEmpty()) {
            return 'WHERE ID = NULL';
        }
        
        String queryConditions;
        if(String.isNotBlank(selectedList)) {
            queryConditions = caseListViewMap.get(selectedList).SOQL_Filter__c;
        }

        if(caseListViewMap.get(selectedList).isOwnedByMe__c) {
            queryConditions += ' AND OwnerId = \'' + userId + '\' ';
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

    public class RecentCasesWrapper {
        @AuraEnabled
        public List<Case> myRecentCases {get; set;}
        @AuraEnabled
        public Integer caseListSize {get;private set;}
        @AuraEnabled
        public Integer caseList_ReqMyInputSize {get;private set;}
        @AuraEnabled
        public Integer caseList_CompanyOpenCasesSize {get;private set;}
        @AuraEnabled
        public String sortExpression {
            get {return sortExp;}
            set {
                //if the column is clicked on then switch between Ascending and Descending modes
                if (value == sortExp)
                    sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
                else
                    sortDirection = 'ASC';
                sortExp = value;
            }
        }
        @AuraEnabled
        public String sortDirection {get; set;}
        @AuraEnabled
        public Map<String, String> mapFieldsValue {get;set;}    

        public RecentCasesWrapper() {

        }        
    }    
}