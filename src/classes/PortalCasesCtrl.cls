public with sharing class PortalCasesCtrl {
 
    public static Id userId = UserInfo.getUserId();
    public static Boolean isAdmin;
    public static String currentListViewName;
    public static Boolean apUser;
    public static String selectedList;
    public static String soqlOrder;
    public static Id myAccountId;
    private static ISSP_PermissionFilterFactory.PermissionSetFilter     thePermissionSetFilter;
    private static ISSP_PermissionFilterFactory.ProfilePermissionFilter theProfilePermissionFilter;
    private static List<ISSPCaseListView__c> csCaseListViews = ISSPCaseListView__c.getAll().values(); /* Custom Setting to control the visibility on what Cases should appear */
    public static Map<String, ISSPCaseListView__c> caseListViewMap;

    /* 
    * @description Main method that returns a list of cases 
    * @params
    * @return List<Case>
    */
    @AuraEnabled(cacheable=true)
    public static List<Case> getRecentCases() {

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
            User myUser = [
                SELECT Id, ContactId, Contact.AccountId 
                FROM User 
                WHERE Id = :userId
            ];
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
            
            isAdmin = false;
            
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
    private static List<Case> getCases() {
        String queryString;
        Set<String> fieldPathSet = new Set<String>{'CaseNumber'};

        for(Schema.FieldSetMember f : getFields()) {
            fieldPathSet.add(f.getFieldPath());
        }

        String query = ' Account.Name, Contact.Name, Owner.Name, E2CP__AdditionalCC__c ';
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
        
        queryString = 'SELECT ' + query.substring(1) + ' FROM Case ' + getQueryConditions() + ' ORDER BY CreatedDate DESC LIMIT 4';

        List<Case> queryResult = Database.query(queryString);

        System.debug(LoggingLevel.FINE, '____ [cls PortalCasesCtrl - getCases] queryString - ' + queryString);
        System.debug('____ [cls PortalCasesCtrl - getCases] queryResult - ' + queryResult);

        return queryResult;
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

    /* 
    * @description Return cases related to logged User, used in search functionality
    * @params String searchKey
    * @return List<Case>
    */
    @AuraEnabled(cacheable=true)
    public static List<Case> getFilteredCases(String searchKey) {
        User userLogged = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        Boolean isAdmin = ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId());

        Id accountId = userLogged.AccountId;

        String finalQuery = 'SELECT CaseNumber, Type_of_case_Portal__c, Subject, Country_concerned_by_the_query__c, CreatedDate, Portal_Case_Status__c ' +
            'FROM Case ' +
            'WHERE Visible_on_ISS_Portal__c = true AND ' + 
                '(CaseNumber LIKE \'%'+ String.escapeSingleQuotes(searchKey) +'%\' OR Subject LIKE \'%'+ String.escapeSingleQuotes(searchKey) +'%\') ';

        if(isAdmin) {
            finalQuery += 'AND AccountId = \''+ userLogged.AccountId +'\' ';
        } else {
            finalQuery += 'AND is_Portal_user_equal_case_contact__c = \'true\' ';
        }

        finalQuery += 'LIMIT 4';

        List<Case> queryResult = Database.query(finalQuery);

        System.debug(LoggingLevel.FINE, '____ [cls PortalCasesCtrl - getFilteredCases] finalQuery - ' + finalQuery);
        System.debug('____ [cls PortalCasesCtrl - getFilteredCases] queryResult - ' + queryResult);

        return queryResult;
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
                        Description

            FROM Case 
            WHERE Id = :caseId];

        return caseAux;
    }                     
}