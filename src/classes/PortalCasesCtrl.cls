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

    public static Boolean isAdmin;
    public static Boolean seeAllCases;
    public static String currentListViewName;
    public static Boolean apUser;
    public static String selectedList;
    public static String soqlOrder;
    public static Id myAccountId;
    public static Set<String> recordTypesSet;
    public static Set<String> openIFAPStatuses;
    public static Set<Id> amsListForm;
    public static Set<Id> apListForm;
    public static Contact con;
    public static PagedResult result;
    private static ISSP_PermissionFilterFactory.PermissionSetFilter     thePermissionSetFilter;
    private static ISSP_PermissionFilterFactory.ProfilePermissionFilter theProfilePermissionFilter;
    private static List<ISSPCaseListView__c> csCaseListViews;
    public static Map<String, ISSPCaseListView__c> caseListViewMap;
    public static List<Portal_Application_Right__c> appRightList;
    public static List<Portal_Application_Right__c> tipServiceRightList;
    public static List<Portal_Application_Right__c> airlineRightList;
    public static List<Portal_Application_Right__c> agencyRightList;
    public static List <AMS_Pax_Accreditation_Form__c> amsList;
    public static List <AP_Process_Form__c> apList;
    public static ISSP_Portal_Service_Ids__c serviceIdInstance;
    public static Boolean adminProfile = CSP_Utils.isAdmin();

    public static Integer RESULTS_PER_PAGE = 10;
    private static PortalSearchFilterWrapper filtersWrapper;
    private static Integer requestedPageNumber;

    private static String AGENT_ACCREDITATION_PORTAL_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().AgencyAccreditation__c;
    private static Boolean isCaseFromReachUs = false;
    /*
    *
    *
    */
    @AuraEnabled
    public static List<CSP_Utils.PickListWrapper> typeOfCasePortalCustomPicklist(){
        List<CSP_Utils.PickListWrapper> lstPickValues = new List<CSP_Utils.PickListWrapper>();
        lstPickValues.add(new CSP_Utils.PickListWrapper(System.Label.csp_Accreditation_Process, System.Label.csp_Accreditation_Process));
        lstPickValues.add(new CSP_Utils.PickListWrapper(System.Label.csp_Financial_Review, System.Label.csp_Financial_Review));
        lstPickValues.add(new CSP_Utils.PickListWrapper(System.Label.csp_IATA_Payment, System.Label.csp_IATA_Payment));
        lstPickValues.add(new CSP_Utils.PickListWrapper(System.Label.csp_Sales_Payment, System.Label.csp_Sales_Payment));
        lstPickValues.add(new CSP_Utils.PickListWrapper(System.Label.csp_Emergency_Query, System.Label.csp_Emergency_Query));
        lstPickValues.add(new CSP_Utils.PickListWrapper(System.Label.csp_Concern, System.Label.csp_Concern));
        lstPickValues.add(new CSP_Utils.PickListWrapper(System.Label.csp_Query, System.Label.csp_Query));
        lstPickValues.add(new CSP_Utils.PickListWrapper(System.Label.csp_Process, System.Label.csp_Process));

        return lstPickValues;
    }

    @AuraEnabled
    public static List<CSP_Utils.PickListWrapper> companyCasesContactsPicklist(){
        seeAllCases = true;
        initialization();

        String queryConditions = getQueryConditions();

        String queryString = 'SELECT ContactId creatorid, Contact.Name creatorname FROM Case ' + queryConditions + ' GROUP BY ContactId, Contact.Name ORDER BY Contact.Name ASC ';

        List<Aggregateresult> lstCases = Database.query(queryString);

        List<CSP_Utils.PickListWrapper> lstPickValues = new List<CSP_Utils.PickListWrapper>();

        for(Aggregateresult caseAux : lstCases){
            if(caseAux.get('creatorid') != null) {
                lstPickValues.add(new CSP_Utils.PickListWrapper(caseAux.get('creatorid') + '', caseAux.get('creatorname')+''));
            }
        }

        return lstPickValues;
    }

    /* 
    * @description Main method that returns a list of cases 
    * @params
    * @return List<Case>
    */
    @AuraEnabled(cacheable=true)
    public static PagedResult getRecentCases(Boolean limitView, Boolean seeAll, Boolean specialCaseOption) {
        seeAllCases = seeAll;
        isCaseFromReachUs = specialCaseOption;
        initialization();

        return getCases(limitView);
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
    private static PagedResult getCases(Boolean limitView) {
        String queryString;
        Set<String> fieldPathSet = new Set<String>{'CaseNumber'};

        for(Schema.FieldSetMember f : getFields()) { 
            fieldPathSet.add(f.getFieldPath());
        }

        String query = 'BSP_CASS__c, IATA_Code__c, Remittance_period__c, CaseArea__c, Contact.Name, Reason1__c, CNSCase__c, Origin, IsClosed, Classification_SIS__c, TIP_Partner_Product__c, RecordType.Name, RecordType.DeveloperName, Owner.Name, LastModifiedDate, CreatedBy.Name ';
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

        String queryLimit = '';

        if(filtersWrapper == null) {
            if (isCaseFromReachUs){
                queryLimit += 'LIMIT 3';
            } else if(limitView) {
                queryLimit += 'LIMIT 4';
            } else {
                queryLimit += 'LIMIT 2000';
            }
        } else {
            
            //insert filters
            if(filtersWrapper.searchText != null && filtersWrapper.searchText != ''){
                if(queryConditions == ''){
                    queryConditions = ' WHERE (CaseNumber LIKE \'%'+ String.escapeSingleQuotes(filtersWrapper.searchText) +'%\' OR Subject LIKE \'%'+ String.escapeSingleQuotes(filtersWrapper.searchText) +'%\') ';
                }else{
                    queryConditions += ' AND (CaseNumber LIKE \'%'+ String.escapeSingleQuotes(filtersWrapper.searchText) +'%\' OR Subject LIKE \'%'+ String.escapeSingleQuotes(filtersWrapper.searchText) +'%\') ';
                }
            }

            if(filtersWrapper.casesComponent != null){
                if(filtersWrapper.casesComponent.caseTypeFilter != null && filtersWrapper.casesComponent.caseTypeFilter != ''){
                    if(queryConditions == ''){
                        queryConditions = ' WHERE Type_of_case_Portal__c = \'' + filtersWrapper.casesComponent.caseTypeFilter + '\' ';
                    }else{
                        queryConditions += ' AND Type_of_case_Portal__c = \'' + filtersWrapper.casesComponent.caseTypeFilter + '\' ';
                    }
                }
                if(filtersWrapper.casesComponent.caseCountryFilter != null && filtersWrapper.casesComponent.caseCountryFilter != ''){
                    if(queryConditions == ''){
                        queryConditions = ' WHERE IFAP_Country_ISO__c = \'' + filtersWrapper.casesComponent.caseCountryFilter + '\' ';
                    }else{
                        queryConditions += ' AND IFAP_Country_ISO__c = \'' + filtersWrapper.casesComponent.caseCountryFilter + '\' ';
                    }
                }
                if(filtersWrapper.casesComponent.caseContactFilter != null && filtersWrapper.casesComponent.caseContactFilter != ''){
                    if(queryConditions == ''){
                        queryConditions = ' WHERE ContactId = \'' + filtersWrapper.casesComponent.caseContactFilter + '\' ';
                    }else{
                        queryConditions += ' AND ContactId = \'' + filtersWrapper.casesComponent.caseContactFilter + '\' ';
                    }
                }
                if(filtersWrapper.casesComponent.dateFromFilter != null && filtersWrapper.casesComponent.dateFromFilter != ''){
                    String dateFrom = CSP_Utils.toDatetime(Date.valueOf(filtersWrapper.casesComponent.dateFromFilter));

                    if(queryConditions == ''){
                        queryConditions = ' WHERE CreatedDate >= ' + dateFrom + ' ';
                    }else{
                        queryConditions += ' AND CreatedDate >= ' + dateFrom + ' ';
                    }
                }
                if(filtersWrapper.casesComponent.dateToFilter != null && filtersWrapper.casesComponent.dateToFilter != ''){
                    String dateTo = CSP_Utils.toDatetime(Date.valueOf(filtersWrapper.casesComponent.dateToFilter));

                    if(queryConditions == ''){
                        queryConditions = ' WHERE CreatedDate <= ' + dateTo + ' ';
                    }else{
                        queryConditions += ' AND CreatedDate <= ' + dateTo + ' ';
                    }
                }                
            }

            //pagination 
            Integer offset = requestedPageNumber * PortalCasesCtrl.RESULTS_PER_PAGE;
            queryLimit = ' LIMIT ' + PortalCasesCtrl.RESULTS_PER_PAGE + ' OFFSET ' + offset + ' ';

        }

        if(isCaseFromReachUs) {
            if(queryConditions == ''){
                queryConditions = ' WHERE IsClosed != true AND Portal_Case_Status__c != \'Draft\'';
            }else{
                queryConditions += ' AND IsClosed != true AND Portal_Case_Status__c != \'Draft\'';
            }
        }
        
        queryString = 'SELECT ' + query+ ' FROM Case ' + queryConditions + ' ORDER BY LastModifiedDate DESC ' + queryLimit;

        result = new PagedResult();
        result.records = Database.query(queryString);

        for(Case c : (List<Case>) result.records){
            if (c.RecordType.Name.contains('SIDRA') ) {
                c = buildSubject(c);
            }
        }

        if(filtersWrapper == null){
            result.totalItemCount = result.records.size();
        }else{
            String stringQueryCount = 'SELECT COUNT() FROM Case ' + queryConditions;
            Integer queryCountResult = Database.countQuery(stringQueryCount);
            result.totalItemCount = queryCountResult;
        }
        result.userAdmin = adminProfile;

        System.debug('____ [cls PortalCasesCtrl - getCases] queryString - ' + queryString);

        /* Generate Case URL */
        result.url = JSON.serialize(setCaseURLs((List<Case>)result.records));
        
        return result;
    }

    private static Map<Id, String> setCaseURLs(List<Case> records) {
        Map<Id, String> casesMap;
        Map<Id, String> caseURL;
        Set<Id> caseSetIds;

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
            tipServiceRightList = [
                SELECT Id 
                FROM Portal_Application_Right__c
                WHERE Contact__c = :myUser.ContactId 
                    AND Right__c = 'Access Granted' 
                    AND Portal_Application__c = :serviceIdInstance.TIP_Portal_Service_Id__c 
                LIMIT 1
            ];
            System.debug('____ [cls PortalCasesCtrl - setCaseURLs] tipServiceRightList - ' + tipServiceRightList);
        }
        
        if(String.isNotBlank(serviceIdInstance.AirlineParticipation__c) || String.isNotBlank(serviceIdInstance.AirlineParticipation_MinorChange__c) || String.isNotBlank(serviceIdInstance.AirlineParticipation_Bank_Change__c)) {
            airlineRightList = [
                SELECT Id
                FROM Portal_Application_Right__c
                WHERE Contact__c = :myUser.ContactId
                    AND Right__c = 'Access Granted'
                    AND Portal_Application__c IN (:serviceIdInstance.AirlineParticipation__c, :serviceIdInstance.AirlineParticipation_MinorChange__c, :serviceIdInstance.AirlineParticipation_Bank_Change__c)
            ];
            System.debug('____ [cls PortalCasesCtrl - setCaseURLs] airlineRightList - ' + airlineRightList);
        }

        if(String.isNotBlank(serviceIdInstance.AgencyAccreditation__c)) {
            agencyRightList = [
                SELECT Id 
                FROM Portal_Application_Right__c
                WHERE Contact__c = :myUser.ContactId 
                    AND Right__c = 'Access Granted' 
                    AND Portal_Application__c = :serviceIdInstance.AgencyAccreditation__c 
                LIMIT 1
            ];
            System.debug('____ [cls PortalCasesCtrl - setCaseURLs] agencyRightList - ' + agencyRightList);
        }        

        caseSetIds = new Set<Id>();
        for(Case cs : records) {
            caseSetIds.add(cs.Id);
        }

        amsList = [SELECT SAAM_Case__c FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c IN :caseSetIds];

        if(!amsList.isEmpty()) {
            amsListForm = new Set<Id>();
            for(AMS_Pax_Accreditation_Form__c ams : amsList) {
                amsListForm.add(ams.SAAM_Case__c);
            }
        }

        apList = [SELECT Case__c FROM AP_Process_Form__c WHERE Case__c IN :caseSetIds];

        if(!apList.isEmpty()) {
            apListForm = new Set<Id>();
            for(AP_Process_Form__c ap : apList) {
                apListForm.add(ap.Case__c);
            }
        }

        casesMap = new Map<Id, String>();
        caseURL = new Map<Id, String>();
        for(Case record : records) {
            casesMap = pageLoad(record);
            caseURL.putAll(casesMap);
        }
        
        System.debug('____ [cls PortalCasesCtrl - setCaseURLs] caseURL - ' + caseURL);

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
            return ' WHERE ID = NULL ';
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
        if(record.CNSCase__c) {
            return new Map<Id, String>{
                record.Id =>
                OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_Case?caseId=' + record.Id + '&communityName=CNS') 
            };
        }

        /* Transparency in Payment's portal access assignment */
        if((tipServiceRightList != null && !tipServiceRightList.isEmpty()) && record.Status == TIP_Utils.CASE_STATUS_DRAFT && record.CaseArea__c == TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS) {
            if(record.Reason1__c == TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT) {
                return new Map<Id, String>{
                    record.Id =>
                    OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_TIP_Home?caseId=' + record.Id) 
                };
            }
            
            if(record.Reason1__c == TIP_Utils.CASE_REASON_PRODUCT_MANAGEMENT) {
                return new Map<Id, String>{
                    record.Id => 
                    OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_TIP_Home?prodId=' + record.TIP_Partner_Product__c)
                };
            }
        }

        /* Open IFAP cases must be opened via the page used specifically for open IFAP cases (ISSP_IFAPCases) */
        if(record.RecordType.name == 'IATA Financial Review') {
            if(openIFAPStatuses.contains(record.Status.toLowerCase()) && myUser.Contact.Financial_Assessment_Contact__c) {
                return new Map<Id, String>{
                    record.Id => 
                    OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_IFAPCases?id=' + record.Id)
                };
            }
        } else if(record.RecordType.Name == 'OSCAR Communication') {
            if(!agencyRightList.isEmpty()) {
                if(amsListForm != null && amsListForm.contains(record.Id) && (record.Status == 'Draft' || record.Status == 'Open - EDMC') ) {
                    if(record.Reason1__c == AMS_Utils.CASE_REASON_FOR_MANAGEMENT || record.Reason1__c == AMS_Utils.CASE_REASON_PCI_DSS_COMPLIANT) {
                        return new Map<Id, String>{
                            record.Id => 
                            OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_ANG_PCI?caseId=' + record.Id)
                        }; 
                    } else if(record.Reason1__c.startsWith('New')) {
                        return new Map<Id, String>{
                            record.Id => 
                            OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_AMS_Accreditation?caseId=' + record.Id + '&step=2')
                        };                    
                    } else if(record.Reason1__c == 'CLO – Closure') {
                        return new Map<Id, String>{
                            record.Id => 
                            OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_ANG_VoluntaryRelinquishment?caseId=' + record.Id + '&step=1')
                        };                    
                    } else if(record.Reason1__c == 'Bank Detail Update') {
                        return new Map<Id, String>{
                            record.Id => 
                            OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_AMS_Accreditation?caseId=' + record.Id + '&isNoticeOfChange=true&isBankAccountChange=true&step=2')
                        };                    
                    } else {
                        return new Map<Id, String>{
                            record.Id => 
                            OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_AMS_Accreditation?caseId=' + record.Id + '&isNoticeOfChange=true&isBankAccountChange=false&step=2')
                        };
                    }
                } else if(((record.Origin == 'Massive FOP Creation' || record.Origin == 'FoP automatic renewal') && record.Owner.Name.startsWith('NewGen PCI')) 
                    || ((record.Reason1__c == AMS_Utils.CASE_REASON_FOR_MANAGEMENT || record.Reason1__c == AMS_Utils.CASE_REASON_PCI_DSS_COMPLIANT))) {
                    return new Map<Id, String>{
                        record.Id => 
                        OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_ANG_PCI?caseId=' + record.Id)
                    };
                } else if(record.Reason1__c == 'Annual revalidation' && record.Owner.Name.startsWith('Annual Revalidation')) {
                    return new Map<Id, String>{
                        record.Id => 
                        OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_ANG_ANNUAL_REVALIDATION?caseId=' + record.Id)
                    };
                } else if (record.Owner.Name.startsWith('Model A Onboarding')) {
                    return new Map<Id, String>{
                        record.Id => 
                        OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_ModelA_Onboarding?caseId=' + record.Id)
                    };
                }
            } else {
                return new Map<Id, String>{
                    record.Id => 
                    Label.CSP_PortalPath + 'case-details?caseId=' + record.Id
                };
            }
        }

        /* If case is a SIS Joining Form */
        if(record.RecordType.DeveloperName == 'IDFS_Airline_Participation_Process') {
            if(record.Status == 'Draft' && record.Classification_SIS__c == 'SIS Membership' && !record.isClosed && !record.Owner.Name.StartsWith('Recycle Bin')) {
                return new Map<Id, String>{
                    record.Id => 
                    OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_SISMembershipApplicationForm?id=' + record.Id + '&step=2')
                };
            } else if((record.Status == 'Draft' || record.Status == 'Open - EDMC' || record.Status == 'Return application to customer') && 
                    apListForm != null && apListForm.contains(record.Id) &&
                    airlineRightList != null && !airlineRightList.isEmpty()) {
                        return new Map<Id, String>{
                            record.Id => 
                            OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_APProcess?caseId=' + record.Id + '&step=2')
                        };
            }
        }

        /* If Case is an ICCS Case, redirect to ICCS Service */
        if(record.Origin == 'Portal' && recordTypesSet.contains(record.RecordType.Name)) {
            return new Map<Id, String>{
                record.Id => 
                OneIdUtils.getOrgUrl() + OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, 'ISSP_ICCS_Service?caseId=' + record.Id)
            };
        }

        /*If no match was done*/
        return new Map<Id, String>{
            record.Id => 
            Label.CSP_PortalPath + 'case-details?caseId=' + record.Id
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
    @AuraEnabled(cacheable=false)
    public static PagedResult getFilteredCasesResultsPage(String searchKey, String requestedPage, Boolean isAdminUser) {

        PortalSearchFilterWrapper filterWrapperAux = (PortalSearchFilterWrapper) JSON.deserialize(searchKey, PortalSearchFilterWrapper.class);
        System.debug('____ [cls PortalCasesCtrl - getFilteredCasesResultsPage] filterWrapperAux - ' + filterWrapperAux);

        filtersWrapper = filterWrapperAux;

        Integer requestedPageAux = integer.valueof(requestedPage);
        System.debug('____ [cls PortalCasesCtrl - getFilteredCasesResultsPage] requestedPageAux - ' + requestedPageAux);

        requestedPageNumber = requestedPageAux;

        Boolean isAdmin = false;
        if(isAdminUser == null ){
            isAdmin = CSP_Utils.isAdmin();
            System.debug('____ [cls PortalCasesCtrl - getFilteredCasesResultsPage] isAdmin - ' + isAdmin);
        }else{
            isAdmin = isAdminUser;
            System.debug('____ [cls PortalCasesCtrl - getFilteredCasesResultsPage] isAdminUser - ' + isAdminUser);
        }
        seeAllCases = isAdmin;
        
        PagedResult pages = getRecentCases(false, isAdmin, false);

        return pages;
    }


    @AuraEnabled
    public static Boolean isAirlineAdmin() {
        return Id.valueOf(ISSP_Constant.customSetingMap.get('ISS_Portal_Airline_Delegated_Admin')) == UserInfo.getProfileId();
    }

    /* 
    * @description Return a specific case to display the case details
    * @params String caseId
    * @return Case
    */
    @AuraEnabled
    public static Case getCaseById(String caseId) {
        Case caseAux = [SELECT CaseNumber, Type_of_case_Portal__c, Subject, Country_concerned_by_the_query__c,
                        Remittance_Date__c, CurrencyIsoCode, Update_AIMS_IRR__c, BSP_CASS__c, IATA_Code__c, Remittance_period__c,ClosedDate,
                        CreatedDate, CreatedBy.Name,LastModifiedDate, Portal_Case_Status__c,Topic__c,
                        Subtopic__c, Region__c, Reason1__c, Country_concerned__c, Account_Concerned__r.IATACode__c, 
                        Description,E2CP__AdditionalCC__c,Account_Concerned__c, Status,RecordType__c,
                        RecordType.Name, WhoClosedCase__c,WhoClosedCase__r.UserRole.Name, BSPCountry__c, AccountId,
                        Account.Name, ContactId, Contact.FirstName, Contact.LastName, Contact.Email,Contact.Phone,RecordType.Id,RecordType.DeveloperName
                        FROM Case 
                        WHERE Id = :caseId];

        if ( caseAux.RecordType__c.contains('SIDRA') ) {
            caseAux = buildSubject(caseAux);
        }
        return caseAux;
    }

    /**
        Returns true if the input case has an specific RecordType
        and is closed for more than 2 weeks
    **/
    @AuraEnabled
    public static Boolean getHideForClosedCases(String caseId) {
        set<String> validRecordtypes = new set<String>{'IDFS_Airline_Participation_Process', 'OSCAR_Communication', 'CasesMENA', 
        'CasesAmericas', 'ExternalCasesIDFSglobal', 'Cases_China_North_Asia', 'CasesEurope', 'Cases_Global', 'ComplaintIDFS', 'Inter_DPCs'};
        Case newCase = getCaseById(caseId);
        boolean isMSO = isMSOcase(newCase);

        List<Case> cases = 
        [SELECT Id,RecordType.Id 
        FROM Case 
        WHERE 
        RecordType.Id = :newCase.RecordType.Id
        AND (RecordType.DeveloperName IN :validRecordtypes)];
        
        return ((!cases.isEmpty() && newCase.ClosedDate < Date.today().addDays(-14)) || isMSO );
    }

    private Static boolean isMSOcase(Case newCase){
        return (newCase.RecordType.DeveloperName == 'OSCAR_Communication' && (newCase.Reason1__c == 'GSA / MSO / Handling Agent' || newCase.Subject.startsWith('MSO code ') ));
    }

    private Static Case buildSubject(Case caseAux){
        String subJ = '';
        
        subJ += (caseAux.BSP_CASS__c != null) ? caseAux.BSP_CASS__c + ' ' + System.Label.CSP_Payment + ' - ' : '';
        subJ += (caseAux.IATA_Code__c != null) ? System.Label.ICCS_IATA_Code + ': ' + caseAux.IATA_Code__c + ' - ' : '';
        subJ += (caseAux.Remittance_period__c != null) ? System.Label.CSP_Period + ' ' +  caseAux.Remittance_period__c : '';
        if ( subJ.length() > 0 ) {
            caseAux.Subject =  System.Label.CSP_IMPORTANT + ': ' + subJ;
        } else {
            caseAux.Subject =  (caseAux.Subject != null) ? System.Label.CSP_IMPORTANT + ': ' + caseAux.Subject : '';
        }
        return caseAux;
    }

    @AuraEnabled
    public static String getSurveyLink(String caseId){
        Case newCase = getCaseById(caseId);

        if(newCase.status != 'Closed'){
            return null;
        }
        
        Id profileId = Userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        ClosedSurvey__c csValues = ClosedSurvey__c.getInstance(newCase.RecordType__c);
        String userRole =  newCase.WhoClosedCase__c != null ? DAL_WithoutSharing.getUserDetails(newCase.WhoClosedCase__c).UserRole.Name : '';

        String caseType = ISSP_Constant.caseTypeMap.get(newCase.RecordType.Name);

        String surveyLanguage = UserInfo.getLanguage();

        Boolean matchingStatus = newCase.status == 'Closed';
        Boolean isPWCCase = newCase.RecordType.Name == 'ISS Portal PwC' || newCase.RecordType.Name == 'ISS Portal PwC for IATA user';
        Boolean isDPCuser = profileName.startsWith('ISS Portal DPC Admin');
        Boolean isToShowSurveyBtn = csValues != null && csValues.RolesAvailable__c.contains(userRole) || csValues.RolesAvailable__c.contains('All');
        Boolean matchingCaseType = caseType == null;
        Boolean surveyCompleted = false;
        Boolean validCloseDate = newCase.ClosedDate >= Date.today().addDays(-14);

        List<Instant_Surveys__c> Survey_List = new List<Instant_Surveys__c>([SELECT Case_ID__c
        FROM Instant_Surveys__c
        WHERE Relationship_to_Case__c = :newCase.Id
        AND recordType.developername != 'Live_Agent_Chat']);

        if (Survey_List != null && Survey_List.size() > 0) {
            surveyCompleted = true ;
        }

        Boolean showLink = matchingStatus && !isPWCCase && !isDPCuser && isToShowSurveyBtn && matchingCaseType && !surveyCompleted && validCloseDate;

        if(!showLink){
            return null;
        }

        String fName = newCase.Contact.FirstName != null ? newCase.Contact.FirstName : '';
        String lName = newCase.Contact.LastName != null ? newCase.Contact.LastName : '';
        String email = newCase.Contact.Email != null ? newCase.Contact.Email : '';
        String phone = newCase.Contact.Phone != null ? newCase.Contact.Phone : '';

        String surveyLink = 'http://survey.clicktools.com/go?iv='
                +System.Label.ISSP_SurveyClosedCase
                +'&q1='+newCase.Id
                +'&q2='+newCase.CaseNumber+
                +'&q3='+newCase.ContactId
                +'&q9='+fName+'|'+lName+'|'+email+'|'+phone
                +'&language='+surveyLanguage;

        return surveyLink;
    }

    /*
    * Returns the comments for a case, given the case id
    */
    @AuraEnabled
public static List<MessageWrapper> getCaseMessages(String caseId){
	List<MessageWrapper> lstToReturn = new List<MessageWrapper>();

	Case caseToFirstComment = [SELECT Id, Description, CreatedBy.Name, CreatedDate FROM Case WHERE Id =:caseId];

	List<CaseComment> lstCaseCommentsAux = [SELECT Id, ParentId, CommentBody, IsPublished,
	                                        CreatedDate, CreatedById, CreatedBy.Name, IsDeleted
	                                        FROM CaseComment
	                                        WHERE ParentId = :caseId AND IsDeleted = false
	                                                                                 ORDER BY CreatedDate ASC];

	String caseDescription = caseToFirstComment.Description != null ? caseToFirstComment.Description : '';

	lstToReturn.add(new MessageWrapper(caseDescription,
	                                   caseToFirstComment.CreatedDate,
	                                   caseToFirstComment.CreatedBy.Name,
	                                   true,
	                                   caseToFirstComment.Id));

	if(lstCaseCommentsAux != null && !lstCaseCommentsAux.isEmpty()) {
		for(CaseComment caseCommentAux : lstCaseCommentsAux) {
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

    public static String fullnameNOCFile(Case caseObj) {

            String folderName = '500/' + caseObj.Id + '/';
            String fileName = 'Notice_of_Change_form.pdf';
            String fullname = folderName + fileName;

            List<AmazonFile__c> amazonfilesList = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE Case__c = :caseObj.Id];
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

                if(caseObj.Reason1__c == 'Bank Detail Update')
                    isBankAccountChange = true;

                return '/ISSP_AMS_PDF_NOC?caseId=' + caseObj.Id + '&isNoticeOfChange=true&isBankAccountChange=' + isBankAccountChange;
            }
    }

    @AuraEnabled
    public static OptionWrapper optionBuilder(Case caseObj) {
        Boolean isAdmin = CSP_Utils.isAdmin();

        Boolean isOnlineOSCARCase = false;
        Boolean isTravelAccreditation = false;
        Boolean isSidraCase = false;

        List <AMS_Pax_Accreditation_Form__c> amsList = [SELECT Id, Operation_Type__c FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :caseObj.Id];
        if (!amsList.isEmpty()){
            isOnlineOSCARCase = true;
            if (amsList[0].Operation_Type__c != null && amsList[0].Operation_Type__c.StartsWith('Travel_Agent')) {
                isTravelAccreditation = true;
            }
        }

        Boolean showAccreditation = false;
        List <Portal_Application_Right__c> appRightList = [SELECT Id FROM Portal_Application_Right__c
                                                            WHERE Contact__c = :myUser.ContactId AND
                                                            Right__c = 'Access Granted'  AND
                                                            Portal_Application__c = :AGENT_ACCREDITATION_PORTAL_SERVICE];
        if (!appRightList.isEmpty())
            showAccreditation = true;

        Boolean isMSOcase = false;
        String caseType = ISSP_Constant.caseTypeMap.get(caseObj.RecordType.Name);
        if (caseType == 'OSCAR' && (caseObj.Reason1__c == 'GSA / MSO / Handling Agent' || caseObj.Subject.startsWith('MSO code ')))
            isMSOcase = true;
        
        String fullnameNOCFile = fullnameNOCFile(caseObj);

        if ( caseObj.RecordType__c!=null && caseObj.RecordType__c.contains('SIDRA') ) {
            isSidraCase = true;
        }

        OptionWrapper optToReturn = new OptionWrapper(isAdmin, isOnlineOSCARCase, showAccreditation, isMSOcase, isTravelAccreditation, fullnameNOCFile, isSidraCase);
        return optToReturn;
    }

    public class OptionWrapper {

        @AuraEnabled
        public Boolean isAdmin {get; set;}

        @AuraEnabled
        public Boolean isOnlineOSCARCase {get; set;}

        @AuraEnabled
        public Boolean showAccreditation {get; set;}

        @AuraEnabled
        public Boolean isMSOcase {get; set;}

        @AuraEnabled
        public Boolean isTravelAccreditation {get; set;}

        @AuraEnabled
        public String fullnameNOCFile {get; set;}

        @AuraEnabled
        public Boolean isSidraCase {get; set;}

        public OptionWrapper(Boolean isAdmin, Boolean isOnlineOSCARCase, Boolean showAccreditation, Boolean isMSOcase, Boolean isTravelAccreditation, String fullnameNOCFile, Boolean isSidraCase){
            this.isAdmin = isAdmin;
            this.isOnlineOSCARCase = isOnlineOSCARCase;
            this.showAccreditation = showAccreditation;
            this.isMSOcase = isMSOcase;
            this.isTravelAccreditation = isTravelAccreditation;
            this.fullnameNOCFile = fullnameNOCFile;
            this.isSidraCase = isSidraCase;
        }
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
