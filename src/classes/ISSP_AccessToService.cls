public with sharing class ISSP_AccessToService{

    public string selectedList {get;set;}
    public List<AccServiceWrapper> AccServiceList;
    public map<string,ISSPAccServiceListView__c> AccServiceListViewMap {get;set;} 
    public list<string> ListViewNameList {get;set;}
    
    private String sortDirection = 'ASC';
    private String sortExp  = 'CreatedDate'; 
    
    public Boolean isAdmin {get;set;} 
    public String denyReason {get;set;} 
    public String grantReason {get;set;}

    public String serviceId {get;set;} 
    public String serviceName {get;set;} 
    public String contactId {get;set;} 

    public list<String> errorMessage {get; set;}
    public Integer failedCount  {get; set;}
    public Datetime timeStamp {get; set;}
    public String contactStatus {get; set;}
    
    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    
    
    public list<String> AlphaList {get; set;}
    public String AlphaFilter {get; set;}

    public String sortExpression {
     get { return sortExp; }
     set {
        system.debug('CLICKED VALUE: ' + value);
        system.debug('CLICKED EXP: ' + sortExp);
        system.debug('CLICKED CURRENT: ' + sortDirection);
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp || (value == 'Name' && sortExp == 'LastName') || (value == 'LastName' && sortExp == 'Name')){
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
    
    public static User currentPortalUser {
        get {
            if(currentPortalUser == null){
                currentPortalUser = [SELECT id, ANG_Sector__c, ANG_Is_Accredited_Agent__c, ANG_Customer_Country_ISO__c, 
                                    contact.account.ANG_IEP_Status_FF__c,ContactId,
                                    languagelocalekey,ProfileId  
                                    from User where id =: UserInfo.getUserId()];
            }
            return currentPortalUser;
        } 
        set;}

    public boolean pollerOn {get; set;}
    public Boolean redirect {get; set;}
    public Boolean provError {get; set;}
    public Map<String, String> iepRoles {get; set;}
    public String defaultPortalUserRole {get; set;}    

    public ISSP_AccessToService() {
        this.errorMessage = null;
        this.pollerOn = false;       
        this.denyReason = '';
        this.grantReason = '';
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
        
    public PageReference initialization() {
        try {
            AlphaList = new list<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Other', 'All'};
            initFilters();
            initAccServiceListViewMap();
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
    private list<ISSPAccServiceListView__c> csAccServiceListViews { 
        get {
            if(null == csAccServiceListViews)
                csAccServiceListViews = ISSPAccServiceListView__c.getAll().values();
            system.debug('ISSPAccServiceListView__c: ' + csAccServiceListViews);
            return csAccServiceListViews;
        } 
        set; 
    }
    private PermissionSetFilter     thePermissionSetFilter { get; set; }
    private ProfilePermissionFilter theProfilePermissionFilter { get; set; }   
    //todo
    private void initFilters() {
        set<String> permissionSetIDs = new Set<String>(); 
        for(ISSPAccServiceListView__c AccServiceListViewItem : csAccServiceListViews){
            if(String.isNotBlank(AccServiceListViewItem.Permission_set__c)) {
                for(String permisSetStr : AccServiceListViewItem.Permission_set__c.split(';')) {
                    if(String.isNotBlank(permisSetStr))
                        permissionSetIDs.add(permisSetStr);
                }
            }
        }
        
        theProfilePermissionFilter = new ProfilePermissionFilter(); 
        thePermissionSetFilter = new PermissionSetFilter(permissionSetIDs);
    }
    //todo 
    private void initAccServiceListViewMap() {
        ListViewNameList = new list<string>();
        AccServiceListViewMap = new map<string,ISSPAccServiceListView__c>();
        for(ISSPAccServiceListView__c AccServiceListViewItem : csAccServiceListViews){
            
            Boolean resultPermission1 = true; 
            if(!theProfilePermissionFilter.isDataEmpty(AccServiceListViewItem)){
                system.debug('not profile data empty');
                resultPermission1 = theProfilePermissionFilter.isUserPermittedFor(AccServiceListViewItem);
            }
            else{
                system.debug('profile data empty');
            }
             
            Boolean resultPermission2 = true; 
            if(!thePermissionSetFilter.isDataEmpty(AccServiceListViewItem)){
                system.debug('not permission data empty');
                resultPermission2 = thePermissionSetFilter.isUserPermittedFor(AccServiceListViewItem);
            }
            else{
                system.debug('permission data empty');
            }
            //resultPermission1 && resultPermission2    
            if(true) {
                AccServiceListViewMap.put(AccServiceListViewItem.Name,AccServiceListViewItem);
                ListViewNameList.add(AccServiceListViewItem.Name);
            }
            
            system.debug('resultPermission1: ' + resultPermission1);
            system.debug('resultPermission2: ' + resultPermission2);
            
        }
        ListViewNameList.sort();
        if(ListViewNameList.size()>0)
            selectedList = ListViewNameList.get(0);
        string ListViewName = ApexPages.currentPage().getParameters().get('ListViewName');
        if( ListViewName!=null && AccServiceListViewMap.containsKey(ListViewName))
            selectedList = ListViewName;
            
        system.debug('AccServiceListViewMap start: ' + AccServiceListViewMap);
        system.debug('selectedList start: ' + selectedList);
        if(String.isNotBlank(selectedList)){
            //buttonChange = AccServiceListViewMap.get(selectedList).Button_Change__c;
            //buttonActivate = AccServiceListViewMap.get(selectedList).Button_Activate__c;
            //buttonAdmin = AccServiceListViewMap.get(selectedList).Button_Admin__c;
            //buttonInactivate = AccServiceListViewMap.get(selectedList).Button_Deactivate__c;
            //buttonReject = AccServiceListViewMap.get(selectedList).Button_Reject__c;
        }
    }
     
    public List<Schema.FieldSetMember> getFields() {
        //system.debug('selectedList rrr1: ' + selectedList);
        //system.debug('AccServiceListViewMap.get(selectedList).Field_Set_API_Name__c rrr1: ' + AccServiceListViewMap.get(selectedList).Field_Set_API_Name__c);
        //system.debug('final rrr1: ' + sObjectType.Portal_Application_Right__c.FieldSets.getMap().get(AccServiceListViewMap.get(selectedList).Field_Set_API_Name__c).getFields());
       return selectedList==null||selectedList==''?
            new list<Schema.FieldSetMember>():
            sObjectType.Portal_Application_Right__c.FieldSets.getMap().get(AccServiceListViewMap.get(selectedList).Field_Set_API_Name__c).getFields();
    } 
    
    public Pagereference refresh(){ 
        //system.debug('selectedList: ' + selectedList);
        if(String.isNotBlank(selectedList)){
            //buttonChange = AccServiceListViewMap.get(selectedList).Button_Change__c;
            //buttonActivate = AccServiceListViewMap.get(selectedList).Button_Activate__c;
            //buttonAdmin = AccServiceListViewMap.get(selectedList).Button_Admin__c;
            //buttonInactivate = AccServiceListViewMap.get(selectedList).Button_Deactivate__c;
            //buttonReject = AccServiceListViewMap.get(selectedList).Button_Reject__c;
        }
        setCon = null;
        return null; 
    }
    public string getQueryConditions() {
        
        //string t =  selectedList==null||selectedList=='' ? '' : contactListViewMap.get(selectedList).SOQL_Filter__c;
        system.debug('AccServiceListViewMap>>> ' + AccServiceListViewMap);
        //String queryConditions =  String.isBlank(selectedList) ? '' : AccServiceListViewMap.get(selectedList).SOQL_Filter__c;
        //if (selectedList == null) selectedList = '';
        if(AccServiceListViewMap.isEmpty())
            return 'WHERE ID = NULL';
        
        system.debug('selectedList: ' + selectedList);
        String queryConditions;
        if(String.isNotBlank(selectedList)){
            queryConditions = AccServiceListViewMap.get(selectedList).SOQL_Filter__c;
        }
            
        //system.debug('buttonInactivate: ' + buttonInactivate);
        return String.isNotBlank(queryConditions) ? queryConditions : ''; 
    }
    
    ////////////////////////////////
    
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 10;

                String query = ' CreatedDate, Account__c, Contact__r.name, Contact__r.User_Portal_Status__c, Application_Name__c,PortalServiceTranslatedName__c,' +
                               ' Portal_Application__r.Cannot_be_managed_by_portal_admin__c';
                for(Schema.FieldSetMember f : this.getFields()) {
                    query +=  ', '+f.getFieldPath() ;
                }
                string queryString = '';

                queryString = 'select '+query+' from Portal_Application_Right__c '+getQueryConditions()+' order by Application_Name__c';

                ISSP_Utilities.log('SQL String: ' + queryString);

                System.debug(LoggingLevel.ERROR, 'ALEX SQL-->' + queryString);

                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();                
            }
            return setCon;
        }set;
    }
    
    public class AccServiceWrapper {
        public Boolean selected {get; set;}
        public Portal_Application_Right__c recordAccService {get; set;}
        public String contactStatus {get; set;}
        public Boolean cannotBeManagedByPortalAdmin {get; set;}
        public Boolean isEasyPayService {get; set;}
        public boolean hide {get; set;}
        public boolean showGrant {get; set;}
        public boolean showDeny {get; set;}
        public boolean showIfap {get; set;}
    }
    
    public List<AccServiceWrapper > getAccServiceList(){
        this.denyReason = '';
        this.grantReason = '';

        List<AccServiceWrapper > allAccServiceList =  new List<AccServiceWrapper>();   
        List<Portal_Application_Right__c > allAccServices = (List<Portal_Application_Right__c >)setCon.getRecords();

        Set<String> contactIds = new Set<String>();
        for (Portal_Application_Right__c thisAccService : allAccServices) {
            contactIds.add(thisAccService.contact__c);
        }

        List<User> userList = [SELECT Id, IsActive, ContactId FROM User WHERE ContactId IN :contactIds];

        Map<String, String> userContact = new Map<String, String>();
        for(User u : userList) {
            userContact.put(u.contactId, u.id);
        }

        for (Portal_Application_Right__c thisAccService : allAccServices) {

            AccServiceWrapper thisAccServiceRecord = new AccServiceWrapper ();
            thisAccServiceRecord.contactStatus = 'AA';

            String contactStatus = thisAccService.Contact__r.User_Portal_Status__c;

            thisAccServiceRecord.cannotBeManagedByPortalAdmin = thisAccService.Portal_Application__r.Cannot_be_managed_by_portal_admin__c;
            thisAccServiceRecord.isEasyPayService = ANG_ISSP_PortalServiceHelper.isIepPortalService(thisAccService.Application_Name__c);

            thisAccServiceRecord.hide = ((thisAccServiceRecord.isEasyPayService && !thisAccServiceRecord.cannotBeManagedByPortalAdmin) ||
                                         (thisAccServiceRecord.isEasyPayService && thisAccServiceRecord.cannotBeManagedByPortalAdmin && thisAccService.right__c != 'Access Granted') ||
                                         (!thisAccServiceRecord.isEasyPayService && thisAccServiceRecord.cannotBeManagedByPortalAdmin)
                                        );

            if (contactStatus == 'Pending Approval') {
                thisAccServiceRecord.contactStatus = 'PA';
            } else if (contactStatus == 'Inactive' || contactStatus == 'Rejected' || contactStatus == 'Deactivated') {
                thisAccServiceRecord.contactStatus = 'IN';
            } else if (!userContact.containsKey(thisAccService.Contact__c)) {
                thisAccServiceRecord.contactStatus = 'NO';
            }

            thisAccServiceRecord.showGrant = false;
            thisAccServiceRecord.showDeny = false;
            thisAccServiceRecord.showIfap = false;

            if(thisAccServiceRecord.isEasyPayService) {
                if(thisAccServiceRecord.cannotBeManagedByPortalAdmin && thisAccService.right__c == 'Access Granted') {
                    thisAccServiceRecord.showDeny = true;
                }
            } else {
                if(!thisAccServiceRecord.cannotBeManagedByPortalAdmin) {                
                    if(thisAccService.Application_Name__c == 'IFAP') {
                        thisAccServiceRecord.showIfap = true;
                        if(thisAccService.right__c == 'Access Requested') {
                            thisAccServiceRecord.showDeny = true;
                        }
                    } else if(thisAccService.right__c == 'Access Denied') {
                        thisAccServiceRecord.showGrant = true;
                    } else  if(thisAccService.right__c == 'Access Requested') {
                        thisAccServiceRecord.showGrant = true;
                        thisAccServiceRecord.showDeny = true;
                    } else {
                        thisAccServiceRecord.showDeny = true;
                    }
                }
            }

            thisAccServiceRecord.selected = false;
            thisAccServiceRecord.recordAccService = thisAccService;
            allAccServiceList.add(thisAccServiceRecord);
        }
        AccServiceList = allAccServiceList;
        return allAccServiceList;
    }
     
    public List<Portal_Application_Right__c > getAccServices(){
        return (List<Portal_Application_Right__c >)setCon.getRecords();
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
            ISSPAccServiceListView__c AccServiceListViewItem = (ISSPAccServiceListView__c)oneData;
            list<String> profileIds = AccServiceListViewItem.Profiles_Id__c.split(';');
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
            ISSPAccServiceListView__c AccServiceListViewItem = (ISSPAccServiceListView__c)oneData;
            return String.isBlank(AccServiceListViewItem.Profiles_Id__c);
            //Set<string> profilesIdSet = new Set<string>(AccServiceListViewItem.Profiles_Id__c.split(';'));
            //return profilesIdSet.contains(profileId15);
        }
        
    }
    
    public class  PermissionSetFilter implements IPermissionFilter {
        private Set<String> permissionSetForUserSet; 
        public PermissionSetFilter(set<String> permissionSetIDs) {
            permissionSetForUserSet = getPermissionSetForUserSet(permissionSetIDs, UserInfo.getUserId()); 
        }
        
        public Boolean isDataEmpty(object oneData) {
            ISSPAccServiceListView__c AccServiceListViewItem = (ISSPAccServiceListView__c)oneData;
            return String.isBlank(AccServiceListViewItem.Permission_set__c);
        }

        public Boolean isUserPermittedFor(object oneData) {
            Boolean isUserPermitted = false;
            ISSPAccServiceListView__c AccServiceListViewItem = (ISSPAccServiceListView__c)oneData;
            list<String> permissionSetIds = AccServiceListViewItem.Permission_set__c.split(';');
            for(String permisSetId : permissionSetIds) {
                if(permissionSetForUserSet.contains(permisSetId)) {
                    return true; 
                }
            }
            return false;
        }
    }
    

    public Pagereference denyAccess() {

        Portal_Application_Right__c psa;

        pollerOn = true;

        List<Portal_Application_Right__c> psal = [Select Id, Right__c, Access_Status_Reason__c,
                                                         LastModifiedDate 
                                                    From Portal_Application_Right__c
                                                   Where Portal_Application__c =: serviceId
                                                     And Contact__c =: contactId];


        if(psal.size() != 0) {
            psa = psal[0];
        }

        if(psa == null) {
            System.debug(LoggingLevel.ERROR, 'PSA is null [serviceId : ' + serviceId + ' - contactId : ' + contactId + ']');            
            errorMessage = new List<String>(); errorMessage.add(Label.ISSP_ANG_GenericError);
        } else {
            this.timeStamp = psa.LastModifiedDate;                                              

            psa.Right__c = 'Access Denied';
            psa.Access_Status_Reason__c = denyReason;

            try {
                update psa;

                this.denyReason = '';
                this.grantReason = '';

            } catch(Exception e) {
                errorMessage = new List<String>(); errorMessage.add(e.getdmlMessage(0));
            }
        }

        return null;
    }    
   
    public Pagereference grantAccess() {

        Portal_Application_Right__c psa;

        pollerOn = true;

        List<Portal_Application_Right__c> psal = [Select Id, Right__c, Access_Status_Reason__c,
                                                         LastModifiedDate 
                                                    From Portal_Application_Right__c
                                                   Where Portal_Application__c =: serviceId
                                                     And Contact__c =: contactId];

        if(psal.size() != 0) {
            psa = psal[0];
        }

        if(psa == null) {
            System.debug(LoggingLevel.ERROR, 'PSA is null (2) [serviceId : ' + serviceId + ' - contactId : ' + contactId + ']');            
            errorMessage = new List<String>(); errorMessage.add(Label.ISSP_ANG_GenericError);
            
        } else {
            Contact contact = null;

            List<Contact> cl = [Select Id, User_Portal_Status__c, Email, Name From Contact Where id =: contactId];

            if(!cl.isEmpty()) {
                contact = cl[0];
            
                if (this.contactStatus == 'PA') {
                    // Pending Approval
                    contact.User_Portal_Status__c = 'Approved User';
                    update contact;
                    ISSP_EditPortalServiceAccessExt.updateUserProfile(contact.Id);
                } else if (this.contactStatus == 'NO') {
                    // No USer
                    ISSP_ContactList ctrl = new ISSP_ContactList();
                    ctrl.processMultiplePortalUserStatusChange(cl, 'Approved User', 'Active');
                }
            }

            this.timeStamp = psa.LastModifiedDate;

            psa.Right__c = 'Access Granted';
            psa.Access_Status_Reason__c = grantReason;

            try {          
                update psa; 

                this.denyReason = '';
                this.grantReason = '';

            } catch(Exception e) {
                errorMessage = new List<String>(); errorMessage.add(e.getdmlMessage(0));
            }
        }

        return null;
    }

    public PageReference permissionSetPoller() {

        if(errorMessage != null) {
            pollerOn = false;
        } else {
            List<Portal_Application_Right__c> psal = [Select Id, Right__c, Access_Status_Reason__c,
                                                             LastModifiedDate 
                                                        From Portal_Application_Right__c
                                                       Where Portal_Application__c =: serviceId
                                                         And Contact__c =: contactId];

            Portal_Application_Right__c psa = null;

            if(psal.size() != 0) {
                psa = psal[0];
            }

            if(psa == null) {
                System.debug(LoggingLevel.ERROR, 'PSA is null (3) [serviceId : ' + serviceId + ' - contactId : ' + contactId + ']');            
                errorMessage = new List<String>(); errorMessage.add('And error has occured');
                pollerOn = false;
            } else {
                if(psa.LastModifiedDate > this.timeStamp) {
                    pollerOn = false;
                }
            }
        }
        return null;
    }    

    public Pagereference refreshList() {
        pollerOn = false;
        setCon = null;
        return null;
    }    
}