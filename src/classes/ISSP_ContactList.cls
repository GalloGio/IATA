public with sharing class ISSP_ContactList {

    public static Boolean avoidContactStatusTrigger = false;

    public string selectedList {get;set;}
    public List<contactWrapper> contactList;
    public map<string,ISSPContactListView__c> contactListViewMap {get;set;} 
    public list<string> ListViewNameList {get;set;}
    
    private String sortDirection = 'ASC';
    private String sortExp  = 'Name'; 
    
    public Boolean isAdmin {get;set;} 
    
    public Boolean buttonChange {get;set;}
    public Boolean buttonActivate {get;set;}
    public Boolean buttonAdmin {get;set;}
    public Boolean buttonInactivate {get;set;}
    public Boolean buttonReject {get;set;}
    
    public list<String> AlphaList {get; set;}
    public String AlphaFilter {get; set;}
    
    public list<String> errorMessage {get; set;}
    
    public List<SelectOption> rejectionReasonOptions {get;set;}
    public List<SelectOption> inactiveReasonOptions {get;set;}
    public String contactStatus {get;set;}
    
    public Boolean contactsWithIdCard {get; set;}
    public String contactsWithIdCardString {get; set;}

    public String searchString {get; set;}
    public String currentSearch {get; set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}

    public String sortExpression {
     get { return sortExp; }
     set {
        system.debug('CLICKED VALUE: ' + value);
        system.debug('CLICKED EXP: ' + sortExp);
        system.debug('CLICKED CURRENT: ' + sortDirection);
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp || (value == 'ISSP_Contact_Name__c' && sortExp == 'Name') || (value == 'Name' && sortExp == 'ISSP_Contact_Name__c')){
        system.debug('CHANGING FROM: ' + sortDirection);
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
        system.debug('CHANGING TO: ' + sortDirection);
       }
       else{
         sortDirection = 'ASC';
         system.debug('NOT CHANGING');
       }
       sortExp = value;
     }
    }

    public String getSortDirection() {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value) {  
        sortDirection = value;
    }
    
    public ISSP_ContactList(){
    }
    
    public PageReference initialization() {
        try {
            contactsWithIdCard = false;
            contactsWithIdCardString = '';
            errorMessage = new list<string>();
            
            rejectionReasonOptions = new List<SelectOption>();
            rejectionReasonOptions.add(new SelectOption('Retired', Label.ISSP_RejectReason_Retired));
            rejectionReasonOptions.add(new SelectOption('LeftCompany', Label.ISSP_RejectReason_Left));
            rejectionReasonOptions.add(new SelectOption('UnknownContact', Label.ISSP_RejectReason_Unknown));
            
            inactiveReasonOptions = new List<SelectOption>();
            inactiveReasonOptions.add(new SelectOption('Retired', Label.ISSP_RejectReason_Retired));
            inactiveReasonOptions.add(new SelectOption('LeftCompany', Label.ISSP_RejectReason_Left));
            inactiveReasonOptions.add(new SelectOption('UnknownContact', Label.ISSP_RejectReason_Unknown));
            
            AlphaList = new list<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Other', 'All'};
            initFilters();
            initContactListViewMap();
            String currentUserProfileId = UserInfo.getProfileId();
            List <Profile> profileList = [SELECT Name FROM Profile WHERE Id = :currentUserProfileId];
            if (!profileList.isEmpty()){
                String currentUserProfileName = profileList[0].Name;
                system.debug('currentUserProfileName: ' + currentUserProfileName);
                if (currentUserProfileName.contains('dmin'))
                    isAdmin = true;
                else
                    isAdmin = false;
            }
            else
                isAdmin = false;
        } catch(Exception exp) {
            ISSP_Utilities.exceptionDump(exp);
        }
        return null;
    }
    
    //AEF:
    private list<ISSPContactListView__c> csContactListViews { 
        get {
            if(null == csContactListViews)
                csContactListViews = ISSPContactListView__c.getAll().values();
            system.debug('ISSPContactListView__c: ' + csContactListViews);
            return csContactListViews;
        } 
        set; 
    }
    private PermissionSetFilter     thePermissionSetFilter { get; set; }
    private ProfilePermissionFilter theProfilePermissionFilter { get; set; }   
    //todo
    private void initFilters() {
        set<String> permissionSetIDs = new Set<String>(); 
        for(ISSPContactListView__c contactListViewItem : csContactListViews){
            if(String.isNotBlank(contactListViewItem.Permission_set__c)) {
                for(String permisSetStr : contactListViewItem.Permission_set__c.split(';')) {
                    if(String.isNotBlank(permisSetStr))
                        permissionSetIDs.add(permisSetStr);
                }
            }
        }
        
        theProfilePermissionFilter = new ProfilePermissionFilter(); 
        thePermissionSetFilter = new PermissionSetFilter(permissionSetIDs);
    }
    //todo 
    private void initContactListViewMap() {
        ListViewNameList = new list<string>();
        contactListViewMap = new map<string,ISSPContactListView__c>();
        for(ISSPContactListView__c contactListViewItem : csContactListViews){
            
            Boolean resultPermission1 = true; 
            if(!theProfilePermissionFilter.isDataEmpty(contactListViewItem)){
                system.debug('not profile data empty');
                resultPermission1 = theProfilePermissionFilter.isUserPermittedFor(contactListViewItem);
            }
            else{
                system.debug('profile data empty');
            }
             
            Boolean resultPermission2 = true; 
            if(!thePermissionSetFilter.isDataEmpty(contactListViewItem)){
                system.debug('not permission data empty');
                resultPermission2 = thePermissionSetFilter.isUserPermittedFor(contactListViewItem);
            }
            else{
                system.debug('permission data empty');
            }
                
            if(resultPermission1 && resultPermission2) {
                contactListViewMap.put(contactListViewItem.Name,contactListViewItem);
                ListViewNameList.add(contactListViewItem.Name);
            }
            
            system.debug('resultPermission1: ' + resultPermission1);
            system.debug('resultPermission2: ' + resultPermission2);
            
        }
        ListViewNameList.sort();
        if(ListViewNameList.size()>0){
            selectedList = ListViewNameList.get(0);
        }
        string ListViewName = ApexPages.currentPage().getParameters().get('ListViewName');
        system.debug('ListViewName: ' + ListViewName);
        system.debug('containsKey: ' + contactListViewMap.containsKey(ListViewName));
        if( ListViewName!=null && contactListViewMap.containsKey(ListViewName)){
            selectedList = ListViewName;
        }
            
        system.debug('contactListViewMap start: ' + contactListViewMap);
        system.debug('selectedList start: ' + selectedList);
        if(String.isNotBlank(selectedList)){
            buttonChange = contactListViewMap.get(selectedList).Button_Change__c;
            buttonActivate = contactListViewMap.get(selectedList).Button_Activate__c;
            buttonAdmin = contactListViewMap.get(selectedList).Button_Admin__c;
            buttonInactivate = contactListViewMap.get(selectedList).Button_Deactivate__c;
            buttonReject = contactListViewMap.get(selectedList).Button_Reject__c;
        }
    }
    
    public List<Schema.FieldSetMember> getFields() {
       return selectedList==null||selectedList==''?
            new list<Schema.FieldSetMember>():
            sObjectType.Contact.FieldSets.getMap().get(contactListViewMap.get(selectedList).Field_Set_API_Name__c).getFields();
    }
    
    public Pagereference refresh(){ 
        if(String.isNotBlank(selectedList)){
            buttonChange = contactListViewMap.get(selectedList).Button_Change__c;
            buttonActivate = contactListViewMap.get(selectedList).Button_Activate__c;
            buttonAdmin = contactListViewMap.get(selectedList).Button_Admin__c;
            buttonInactivate = contactListViewMap.get(selectedList).Button_Deactivate__c;
            buttonReject = contactListViewMap.get(selectedList).Button_Reject__c;
        }
        setCon = null;
        return null;
    }
    public string getQueryConditions() {
        
        system.debug('contactListViewMap >>> ' + contactListViewMap);

        if(contactListViewMap == null || contactListViewMap.isEmpty())
            return 'WHERE ID = NULL';
        
        system.debug('selectedList: ' + selectedList);
        String queryConditions;
        if(String.isNotBlank(selectedList)){
            queryConditions = contactListViewMap.get(selectedList).SOQL_Filter__c;
        }
            
        system.debug('buttonInactivate: ' + buttonInactivate);
        return String.isNotBlank(queryConditions) ? queryConditions : ''; 
    }
    
    ////////////////////////////////
    
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                string sortFullExp = '';
                if (sortExpression == 'ISSP_Contact_Name__c')
                    sortFullExp = 'Name'  + ' ' + sortDirection;
                else
                    sortFullExp = sortExpression  + ' ' + sortDirection;
                system.debug('ORDERING BY: ' + sortExpression);
                system.debug('ORDERING LIKE: ' + sortDirection);
                size = 10;

                String searchFilter = '';
                if(searchString != null && searchString != '') {
                    searchFilter = ' AND ((name Like \'%' + searchString + '%\') OR (email Like \'%' + searchString + '%\'))';
                }

                String query = ' CreatedDate , Name , Account.Name , ValidContactDomainName__c, ValidContactDomainImage__c, Portal_User_Frozen__c ';
                for(Schema.FieldSetMember f : this.getFields()) {
                    query +=  ', '+f.getFieldPath() ;
                }
                string queryString = '';
                string otherQuery = ',(SELECT Id, Valid_To_Date__c FROM ID_Cards__r WHERE NOT card_status__c like \'Cancelled%\'), (SELECT Id FROM IEC_Subscriptions_History__r)';
                system.debug('AlphaFilter: ' + AlphaFilter);
                if (AlphaFilter != '' && AlphaFilter != null && AlphaFilter != 'All' && sortExpression != 'CreatedDate' && AlphaFilter != 'Other'){
                    if (sortExpression == 'ISSP_Contact_Name__c')
                        queryString = 'select '+query+otherQuery+' from Contact  '+getQueryConditions()+ searchFilter + ' AND Name like \'' + AlphaFilter + '%\'' + ' order by '+ sortFullExp;
                    else
                        queryString = 'select '+query+otherQuery+' from Contact  '+getQueryConditions()+ searchFilter + ' AND ' + sortExpression + ' like \'' + AlphaFilter + '%\'' + ' order by '+ sortFullExp;
                }
                else if (AlphaFilter == 'Other' && sortExpression != 'CreatedDate'){
                    if (sortExpression == 'ISSP_Contact_Name__c')
                        queryString = 'select '+query+otherQuery+' from Contact  '+getQueryConditions()+ searchFilter + ' AND (Name < \'A\' OR Name > \'Z\') AND (NOT Name LIKE \'Z%\') order by '+ sortFullExp;
                    else
                        queryString = 'select '+query+otherQuery+' from Contact  '+getQueryConditions()+ searchFilter + ' AND (' + sortExpression + ' < \'A\' OR ' + sortExpression + ' > \'Z\') AND (NOT ' + sortExpression + ' LIKE \'Z%\') order by '+ sortFullExp;
                }
                else{
                    queryString = 'select '+query+otherQuery+' from Contact  '+getQueryConditions() + searchFilter + ' order by '+ sortFullExp;
                }

                ISSP_Utilities.log('SQL String: ' + queryString);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
    
    public class contactWrapper {
        public Boolean selected {get; set;}
        public Boolean hasIdCard {get; set;}
        public Boolean hasProducts {get; set;}
        public Contact recordContact {get; set;}
        public User user {get; set;}
    }
    
    public List<contactWrapper> getContactList(){
        List<contactWrapper> allContactList =  new List<contactWrapper>();   
        List<Contact> allContacts = (List<Contact>)setCon.getRecords();
        map<Id,User> mapContactUser = new map<Id,User>();
        for (User user: [SELECT Id, ContactId, LastLoginDate FROM User Where ContactId in :allContacts]) {
            mapContactUser.put(user.ContactId, user);
        }
        for (Contact thisContact : allContacts){
            contactWrapper thisContactRecord = new contactWrapper();
            if (!thisContact.ID_Cards__r.isEmpty()){
                thisContactRecord.hasIdCard = true;
            }
            else{
                thisContactRecord.hasIdCard = false;
            }
            if (!thisContact.IEC_Subscriptions_History__r.isEmpty()){
                thisContactRecord.hasProducts = true;
            }
            else{
                thisContactRecord.hasProducts = false;
            }
            thisContactRecord.selected = false;
            thisContactRecord.recordContact = thisContact;
            thisContactRecord.user = mapContactUser.get(thisContact.Id);
            allContactList.add(thisContactRecord);
        }
        contactList = allContactList;
        return allContactList;
    }

    public PageReference doSearch() {
        setCon = null;
        return null;
    }
     
    public List<Contact> getContacts(){
        return (List<Contact>)setCon.getRecords();
    }
    //AEF:
    public static set<String> getPermissionSetForUserSet(set<String> permissionSetIDs, ID userId) {
        set<String> permissionSetForUserSet = new Set<String>();
        for(PermissionSet onePermissionSet :  getPermissionSetById(permissionSetIDs, userId)) {
            if(ISSP_Utilities.isNotEmpty(onePermissionSet.Assignments)) {
                permissionSetForUserSet.add(onePermissionSet.Id);
            }
        }
        return permissionSetForUserSet;
                
    }  
    
    public static list<PermissionSet> getPermissionSetById(set<String> permissionSetIDs, ID userId) {
        return 
            [SELECT Id
                  ,(SELECT Id, PermissionSetId, AssigneeId 
                      FROM Assignments
                     WHERE AssigneeId =: userId) 
               FROM PermissionSet 
              WHERE Id IN : permissionSetIDs];
    } 
    
    public interface IPermissionFilter {
        
        Boolean isUserPermittedFor(object oneData);
        Boolean isDataEmpty(object oneData);
    }
    
    public class ProfilePermissionFilter implements IPermissionFilter {
        private String profileId15; 
        public ProfilePermissionFilter() {
            profileId15 = UserInfo.getProfileId().substring(0,15);
        }
        
        public Boolean isUserPermittedFor(object oneData) {
            //ISSPContactListView__c contactListViewItem = (ISSPContactListView__c)oneData;
            //return String.isBlank(contactListViewItem.Profiles_Id__c);
            Boolean isUserPermitted = false;
            ISSPContactListView__c contactListViewItem = (ISSPContactListView__c)oneData;
            list<String> profileIds = contactListViewItem.Profiles_Id__c.split(';');
            system.debug('MY PROFILE: ' + profileId15);
            for(String profileId : profileIds) {
                system.debug('THIS PROFILE: ' + profileId);
                if(profileId15 == profileId) {
                    return true; 
                }
            }
            return false;
        }

        public Boolean isDataEmpty(object oneData) {
            ISSPContactListView__c contactListViewItem = (ISSPContactListView__c)oneData;
            return String.isBlank(contactListViewItem.Profiles_Id__c);

        }
        
    }
    
    public class  PermissionSetFilter implements IPermissionFilter {
        private Set<String> permissionSetForUserSet; 
        public PermissionSetFilter(set<String> permissionSetIDs) {
            permissionSetForUserSet = getPermissionSetForUserSet(permissionSetIDs, UserInfo.getUserId()); 
        }
        
        public Boolean isDataEmpty(object oneData) {
            ISSPContactListView__c contactListViewItem = (ISSPContactListView__c)oneData;
            return String.isBlank(contactListViewItem.Permission_set__c);
        }

        public Boolean isUserPermittedFor(object oneData) {
            Boolean isUserPermitted = false;
            ISSPContactListView__c contactListViewItem = (ISSPContactListView__c)oneData;
            list<String> permissionSetIds = contactListViewItem.Permission_set__c.split(';');
            for(String permisSetId : permissionSetIds) {
                if(permissionSetForUserSet.contains(permisSetId)) {
                    return true; 
                }
            }
            return false;
        }
    }
    
    public void reject(){
        errorMessage = new list<string>();
        List<Contact> cls = new List<Contact>();
        for (contactWrapper thisContactRecord : contactList){
            system.debug('EMAIL: ' + thisContactRecord.recordContact.Email + ' SELECTED: ' + thisContactRecord.selected);
            if (thisContactRecord.selected){
                cls.add(thisContactRecord.recordContact);
            }
        }
        if (cls.isEmpty()){
            errorMessage.add(Label.ISSP_SelectOneContact);
        }
        else{
            processMultiplePortalUserStatusChange(cls, 'Rejected', 'Rejected');
        }
        refresh();
    }
    
    public void checkIdCard(){
        system.debug('checkIdCard');
        contactsWithIdCard = false;
        contactsWithIdCardString = Label.ISSP_InactiveUser_IdCard_Portal;
        for (contactWrapper thisContactRecord : contactList){
            if (thisContactRecord.selected){
                if (thisContactRecord.hasIdCard){
                    contactsWithIdCard = true;
                    contactsWithIdCardString = contactsWithIdCardString +'</br>'+ thisContactRecord.recordContact.Name;
                    system.debug('add id card');
                }
            }
        }
        if (!contactsWithIdCard){
            inactivate();
        }
    }
    
    public void resetIdCard(){
        contactsWithIdCard = false;
    }
    
    public void inactivate(){
        resetIdCard();
        errorMessage = new list<string>();
        Set <Id> contactIds = new Set <Id>();
        List<Contact> cls = new List<Contact>();
        String productMessage = '';
        for (contactWrapper thisContactRecord : contactList){
            system.debug('EMAIL: ' + thisContactRecord.recordContact.Email + ' SELECTED: ' + thisContactRecord.selected);
            if (thisContactRecord.selected){
                if (thisContactRecord.hasProducts){
                    if (productMessage == ''){
                        productMessage = Label.ISSP_InactiveUser_Subscription_Portal;
                    }
                    productMessage = productMessage + '</br>'+thisContactRecord.recordContact.Name;
                }
                contactIds.add(thisContactRecord.recordContact.Id);
                cls.add(thisContactRecord.recordContact);
            }
        }
        if (productMessage != ''){
            errorMessage.add(productMessage);
        }
        else
        {
            if (contactIds.isEmpty()){
                errorMessage.add(Label.ISSP_SelectOneContact);
            }
            else if (contactIds.size() > 0){
                List <Portal_Application_Right__c> appList =
                    [SELECT Id, Application_Name__c, Contact__r.Name, Contact__c
                    FROM Portal_Application_Right__c
                    WHERE Right__c = 'Access Granted' AND Contact__c IN :contactIds
                    AND Portal_Application__r.Critical_Service__c = true
                    ORDER BY Contact__c];

                //ACAMBAS - TIP-282 Start
                List <Account_Contact_Role__c> primaryConList =
                    [SELECT Id, Contact__c, Contact__r.Name
                     FROM Account_Contact_Role__c
                     WHERE Contact__c IN :contactIds AND is_primary__c = true];
                //ACAMBAS - TIP-282 End

                if (!appList.isEmpty()){
                    String message = Label.ISSP_UserInactivation_ServiceMsg_4;
                    String currentConId = '';
                    for (Portal_Application_Right__c thisAppRight : appList){
                        if (currentConId == ''){
                            currentConId = thisAppRight.Contact__c;
                            message += '<br/> - ' + thisAppRight.Contact__r.Name;
                            message += ': ' + thisAppRight.Application_Name__c;
                        }
                        else if (currentConId != thisAppRight.Contact__c){
                            currentConId = thisAppRight.Contact__c;
                            message += '<br/> - ' + thisAppRight.Contact__r.Name;
                            message += ': ' + thisAppRight.Application_Name__c;
                        }
                        else{
                            message += ', ' + thisAppRight.Application_Name__c;
                        }
                    }
                    message += Label.ISSP_UserInactivation_ServiceMsg_2;
                    message += Label.ISSP_UserInactivation_ServiceMsg_3;
                    errorMessage.add(message);
                }
                //ACAMBAS - TIP-282 Start 
                else if(!primaryConList.isEmpty()) {
                    String message = Label.ISSP_UserInactivation_ServiceMsg_4;
                    String currentConId = '';
                    for (Account_Contact_Role__c thisPrimaryContact : primaryConList){
                        if (currentConId == ''){
                            currentConId = thisPrimaryContact.Contact__c;
                            message += '<br/> - ' + thisPrimaryContact.Contact__r.Name;
                        }
                        else if (currentConId != thisPrimaryContact.Contact__c){
                            currentConId = thisPrimaryContact.Contact__c;
                            message += '<br/> - ' + thisPrimaryContact.Contact__r.Name;
                        }
                    }
                    message += ': ' + Label.ISSP_UserInactivation_ServiceMsg_5;
                    errorMessage.add(message);
                }
                //ACAMBAS - TIP-282 End 
                else{
                    processMultiplePortalUserStatusChange(cls, 'Deactivated', contactStatus);
                }
            }
        }
        refresh();
    }
    
    public void activateContact(){
        errorMessage = new list<string>();
        List<Contact> cls = new List<Contact>();
        for (contactWrapper thisContactRecord : contactList){
            system.debug('EMAIL: ' + thisContactRecord.recordContact.Email + ' SELECTED: ' + thisContactRecord.selected);
            if (thisContactRecord.selected){
                cls.add(thisContactRecord.recordContact);
            }
        }
        if (cls.isEmpty()){
            errorMessage.add(Label.ISSP_SelectOneContact);
        }
        else{
            processMultiplePortalUserStatusChange(cls, 'Approved User', 'Active');
        }
        refresh();
    }
    
    public void makeAdmin(){
        errorMessage = new list<string>();
        List<Contact> cls = new List<Contact>();
        for (contactWrapper thisContactRecord : contactList){
            system.debug('EMAIL: ' + thisContactRecord.recordContact.Email + ' SELECTED: ' + thisContactRecord.selected);
            if (thisContactRecord.selected){
                cls.add(thisContactRecord.recordContact);
            }
        }
        if (cls.size() == 0){
            errorMessage.add(Label.ISSP_SelectOneContact);
        }
        else if (cls.size() > 1){
            errorMessage = new list<string>();
            errorMessage.add(Label.ISSP_SelectOnlyOneContact);
        }
        else if (cls.size() > 0){
            processMultiplePortalUserStatusChange(cls, 'Approved Admin', 'Active');
        }
        refresh();
    }

    public void processMultiplePortalUserStatusChange(Set<Id> contactIds, String action, String inactivationReason){

        List <Contact> processContactList = [SELECT Id, Name, User_Portal_Status__c, Email FROM Contact WHERE Id IN :contactIds];
        processMultiplePortalUserStatusChange(processContactList,action, inactivationReason);
    }
    
    public void processMultiplePortalUserStatusChange(List<Contact> processContactList, String action, String inactivationReason){
        system.debug('ACTION: ' + action);
        system.debug('IDS: ' + processContactList);

        if (!processContactList.isEmpty()){
            system.debug('STATUS: ' + processContactList[0].User_Portal_Status__c);
            String currentStatus = processContactList[0].User_Portal_Status__c;
            if (currentStatus == '' || currentStatus == null){
                currentStatus = 'New user';
            }
            String theAction = ISSP_PortalUserStatusChange.actionsMap.get(currentStatus).get(action);
            
            for (Contact thisContact : processContactList){
                Savepoint sPointContact = Database.setSavepoint();

                String theResult = ISSP_PortalUserStatusChange.runAction(thisContact.Id, thisContact.Email, theAction, action, inactivationReason, null);
                system.debug('theResult: ' + theResult);
                if (theResult != ''){
                    Database.rollback(sPointContact);
                    errorMessage = new list<string>();
                    errorMessage.add(theResult);
                }
                system.debug('PROCESSING: ' + thisContact.Id + ' ' + thisContact.Name);
                system.debug('CURRENT STATUS: ' + thisContact.User_Portal_Status__c);
            }
        }
        else{
            system.debug('NOTHING TO PROCESS');
        }
    }
    

    @future
    public static void updateContact (String contactId, String userStatus){
        system.debug('updating contact: ' + contactId);
        List <Contact> contactList = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Id = :contactId];
        if (!contactList.isEmpty()){
            contactList[0].User_Portal_Status__c = userStatus;
            update contactList;
        }
    }
    
    public PageReference changeUserPortalStatus(){
        errorMessage = new list<string>();
        Set <Id> contactIds = new Set <Id>();
        String thisRecordId = '';
        for (contactWrapper thisContactRecord : contactList){
            system.debug('EMAIL: ' + thisContactRecord.recordContact.Email + ' SELECTED: ' + thisContactRecord.selected);
            if (thisContactRecord.selected){
                contactIds.add(thisContactRecord.recordContact.Id);
                thisRecordId = thisContactRecord.recordContact.Id;
            }
        }
        if (contactIds.size() == 0){
            errorMessage.add(Label.ISSP_SelectOneContact);
        }
        else if (contactIds.size() > 1){
            errorMessage.add(Label.ISSP_SelectOnlyOneContact);
        }
        else{
            PageReference pr = new PageReference('/ISSP_PortalUserStatusChange?id=' + thisRecordId + commParam);
            return pr;
        }
        return null;
    }
    
    public List<contactWrapper> getFilteredContactList() {
        string paramSelectedList = ApexPages.currentPage().getParameters().get('selectedList');
        if (paramSelectedList!=null) {
            this.selectedList = paramSelectedList;
        }
        return getContactList();
    }

    public String getCSVHeader() {
        return EncodingUtil.convertFromHex('EFBBBF').toString();
    }
    
    public String getCSVContent() {
        // get field info
        list<String> listFieldLabels = new list<String>();
        list<String> listFieldPaths = new list<String>();
        for(Schema.FieldSetMember f : getFields()) {
            if (f.getFieldPath() == 'Airline_Contact_Type__c') {
                // do not add
            } else if (f.getFieldPath() == 'Services__c') {
                // do not add
            } else {
                listFieldLabels.add(f.getLabel());
                listFieldPaths.add(f.getFieldPath());
            }
        }
        if (isAdmin) {
            listFieldLabels.add('Last Login');
            listFieldPaths.add('LastLoginDate');
        }
        
        //prepare out string
        String out = getCSVHeader();
        out+= '"' + String.join(listFieldLabels,'","') + '"\n';
        setCon.setPageSize(2000);
        for (contactWrapper wrapper: getFilteredContactList()) {
            list<String> listFieldValues = wrapperToListValues(wrapper, listFieldPaths);
            out+= '"' + String.join(listFieldValues,'","') + '"\n';
        }
        return out;
    }
    
    public list<String> wrapperToListValues(contactWrapper wrapper, list<String> listFieldPaths) {
        list<String> listFieldValues = new list<String>();
        for (String fieldPath: listFieldPaths) {
            try {
                if (fieldPath == 'ISSP_Contact_Name__c') {
                    listFieldValues.add(tostr(wrapper.recordContact.Name));
                } else if (fieldPath == 'ISSP_Account_Portal_Link__c') {
                    listFieldValues.add(tostr(wrapper.recordContact.Account.Name));
                } else if (fieldPath == 'LastLoginDate') {
                    listFieldValues.add(tostr(wrapper.user.LastLoginDate));
                } else {
                    listFieldValues.add(tostr(wrapper.recordContact.get(fieldPath)));
                }
            } catch (Exception e) {
                listFieldValues.add('');
            }
        }
        return listFieldValues;
    }
    
    public static String tostr(Object obj) {
        return obj==null? '': String.valueOf(obj).replaceAll('"','\'');
    }
}