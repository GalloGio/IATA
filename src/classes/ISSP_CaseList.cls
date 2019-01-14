/*
    Class that lists all the cases of Portal Users
    Used in Portal and NewGen APP (mobile)
*/
@RestResource(urlMapping='/newgenapp/v1/getCaseList/*')
global with sharing class ISSP_CaseList {

    public string selectedList {get;set;}
    public string currNavState {get;set;}
    public map<string,ISSPCaseListView__c> caseListViewMap {get;set;} 
    public list<string> ListViewNameList {get;set;}
    
    private String sortDirection = 'ASC';
    private String sortExp  = 'CaseNumber';
    private boolean isExtinstion = false ; 

    public boolean isPWCProfile {get;set;}
    public boolean isDPCUser {get;set;}
    public boolean isAdmin {get;set;}
        
    public boolean apList {get;set;}
    public boolean apUser {get;set;}
    private Id myAccountId {get;set;}

    public string soqlOrder {get;set;}
    //basto1p
    public Map<String,String> mapFieldsValue {get;set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

    public String sortExpression {
     get { return sortExp; }
     set {
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp)
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'ASC';
       sortExp = value;
     }
    }

    //Start NewGenApp
    public boolean isNewGenApp = false;
    public string ngaListViewName = '';
    public integer newgenappPage = 0;
    
    @HttpGet
    global static List<Case> doGet(){
        RestRequest req = RestContext.request;
        String filterKey = req.params.get('filterKey');
        String page = req.params.get('page');
        System.Debug('REQ' + req);
        System.Debug('filterKey' + filterKey);
        System.Debug('page' + page);

        ISSP_CaseList caseListInstance = new ISSP_CaseList(); 
        
        List<Case> caseList = new List<Case>();

        System.Debug('PRINTING1 ' + caseListInstance.ngaListViewName);
        caseListInstance.ngaListViewName = filterKey;
        caseListInstance.newgenappPage = integer.valueof(page);

        caseListInstance.isExtinstion = true;
        caseListInstance.isAdmin = false;
        caseListInstance.apUser = false;
        caseListInstance.apList = false;
        caseListInstance.isNewGenApp = true; 

        System.Debug('PRINTING2 ' + caseListInstance.ngaListViewName);

        caseListInstance.initialization();
        caseListInstance.initFilters(); 
        caseListInstance.initCaseListViewMap();

        System.Debug('ReadyToGetCases');
        
        caseList = caseListInstance.getCases();

        return caseList; 
    }
    //End NewGenApp

    public String getSortDirection() {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
			return 'DESC';
        else
			return sortDirection;
    }
        
    public void setSortDirection(String value) {  
		sortDirection = value;
    }
    
    public ISSP_CaseList(){}

    public ISSP_CaseList(ISSP_Homepage controller) {
        system.debug('KER1 START ISSP_CaseList(ISSP_Homepage controller)');
        isExtinstion = true ;
        initialization();
    }
    
    public PageReference initialization() {
        try {
            if(!isExtinstion){
                sortDirection = 'DESC';
            }
            else{
                if(isNewGenApp){
                    ApexPages.currentPage().getParameters().put('ListViewName', ngaListViewName);
                sortDirection = 'DESC';
                }
                else {
                    ApexPages.currentPage().getParameters().put('ListViewName', '3_MyRecentCases');
                    sortDirection = 'DESC';
                }	
            }
            
            //AS
            currNavState = ApexPages.currentPage().getParameters().get('mid');
            
            //TF
            apList = false;
            apUser = false;
            User myUser = [select Id,ContactId, Contact.AccountId from User where Id =:Userinfo.getUserId()];
            if (myUser.ContactId != null){
				List <Portal_Application_Right__c> appRightList = [Select Id From Portal_Application_Right__c
																where Contact__c =: myUser.ContactId and
																Right__c = 'Access Granted'  and
																Portal_Application__r.Name = 'Airline Participation'];
		        if (!appRightList.isEmpty()){
		                apUser = true;
		        }
                myAccountId = myUser.Contact.AccountId;
            }
                
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            if(profileName.startsWith('ISS Portal PwC')){  isPWCProfile = true; }
            if(profileName.startsWith('ISS Portal DPC Admin') ){  isDPCUser= true; }
            
            isAdmin = ApexPages.currentPage().getParameters().get('admin') == 'true'  ? true : false ;
            
            initFilters();
            initCaseListViewMap();
            
        } catch(Exception exp) {
                ISSP_Utilities.exceptionDump(exp);
        }
        return null;
    }
    
    //AEF:
    private list<ISSPCaseListView__c> csCaseListViews { 
        get {
			if(null == csCaseListViews)
            	csCaseListViews = ISSPCaseListView__c.getAll().values();
			return csCaseListViews;
        } 
        set; 
    }
    private ISSP_PermissionFilterFactory.PermissionSetFilter     thePermissionSetFilter { get; set; }
    private ISSP_PermissionFilterFactory.ProfilePermissionFilter theProfilePermissionFilter { get; set; }   

    private void initFilters() {
        system.debug('initFilters user id >> ' + UserInfo.getUserId());
        theProfilePermissionFilter = ISSP_PermissionFilterFactory.createProfilePermissionFilter();
        thePermissionSetFilter =ISSP_PermissionFilterFactory.createPermissionSetFilter(csCaseListViews, 'Permission_set__c');
    }
    
    private void initCaseListViewMap() {
        ListViewNameList = new list<string>();
        caseListViewMap = new map<string,ISSPCaseListView__c>();
        for(ISSPCaseListView__c caseListViewItem : csCaseListViews){
                   
			Boolean resultPermission1 = true; 
            if(!theProfilePermissionFilter.isDataEmpty(caseListViewItem, 'Profiles_Id__c')) {
                resultPermission1 = theProfilePermissionFilter.isUserPermittedFor(caseListViewItem, 'Profiles_Id__c');
            }
                 
            Boolean resultPermission2 = true; 
            if(!thePermissionSetFilter.isDataEmpty(caseListViewItem, 'Permission_set__c')) {
                resultPermission2 = thePermissionSetFilter.isUserPermittedFor(caseListViewItem, 'Permission_set__c');
            }
                
            if(resultPermission1 && resultPermission2) {
                system.debug('caseListViewItem.Name: ' + caseListViewItem.Name);
                system.debug('apUser: ' + apUser);
                if (caseListViewItem.Name == 'ISSP_AP_Cases'){
                    if (apUser){
                        caseListViewMap.put(caseListViewItem.Name,caseListViewItem);
                        ListViewNameList.add(caseListViewItem.Name);
                    }
                }
                else{
                    if(!isAdmin && caseListViewItem.isAdmin__c == false){
                        caseListViewMap.put(caseListViewItem.Name,caseListViewItem);
                        ListViewNameList.add(caseListViewItem.Name);
                    }else{
                        if(isAdmin && caseListViewItem.isAdmin__c == true){
                            caseListViewMap.put(caseListViewItem.Name,caseListViewItem);
                            ListViewNameList.add(caseListViewItem.Name);
                        } 
                    }
                }
            }
        }
        ListViewNameList.sort();
        if(ListViewNameList.size()>0){
            selectedList = ListViewNameList.get(0);
        }

        string ListViewName = '';
        if(isNewGenApp){
            ListViewName = ngaListViewName;
        } 
        else {
            ListViewName = ApexPages.currentPage().getParameters().get('ListViewName');
        }

        if( ListViewName!=null && caseListViewMap.containsKey(ListViewName)){
            selectedList = ListViewName;
        }
    }
    
    public List<Schema.FieldSetMember> getFields() {
       return selectedList==null||selectedList==''?
            new list<Schema.FieldSetMember>():
            sObjectType.Case.FieldSets.getMap().get(caseListViewMap.get(selectedList).Field_Set_API_Name__c).getFields();
    }
    
    public Pagereference refresh(){ 
        setCon = null;
        return null;
    }
    public string getQueryConditions() {
        system.debug('caseListViewMap >>> ' + caseListViewMap);
        
        if(caseListViewMap.isEmpty())
			return 'WHERE ID = NULL';
        
        String queryConditions;
        if(String.isNotBlank(selectedList))
			queryConditions = caseListViewMap.get(selectedList).SOQL_Filter__c;             
                
        if(caseListViewMap.get(selectedList).isOwnedByMe__c)
           queryConditions += ' AND OwnerId = \'' + UserInfo.getUserId() + '\' ';
        if(caseListViewMap.get(selectedList).isMyAccount__c) {
            List<User> lsUsers = [SELECT Id FROM User WHERE AccountId = :myAccountId AND Contact.User_Portal_Status__c IN ('Approved User','Approved Admin')];
            String userIds = '';
            for(User u : lsUsers) {
                userIds += '\'' + u.Id  + '\',';
            }
            if(userIds.endsWith(',')) userIds = userIds.substring(0,userIds.length()-1);
            if(userIds != '') queryConditions += ' AND OwnerId IN (' + userIds + ') ';
        }

        return String.isNotBlank(queryConditions) ? queryConditions : ''; 
    }
    
    ////////////////////////////////
    
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                string sortFullExp = sortExpression  + ' ' + sortDirection;
                size = 10;
                //AEF:
                Set<String> fieldPathSet = new Set<String>{'CaseNumber'};
                for(Schema.FieldSetMember f : this.getFields()) {
                    fieldPathSet.add(f.getFieldPath());
                }
                //basto1p
                String query = '  Account.Name , Contact.Name, Owner.Name, E2CP__AdditionalCC__c   ';
                Boolean hasStatus = false;
                
                for(String fieldPath  : fieldPathSet) {

                    if(fieldPath.trim() == 'Status')
                    {
                        hasStatus = true;
                    }

                    query +=  ',' + fieldPath;
                }

                if(!hasStatus)
                {
                    query += ', Status';
                }
                
                string queryString ;
                if(String.isNotBlank(selectedList)){
                	if (caseListViewMap.containsKey(selectedList)){
						soqlOrder = caseListViewMap.get(selectedList).SOQL_Order__c;
                	}
                }
                system.debug('sortFullExp: ' + sortFullExp);
                system.debug('selectedList: ' + selectedList);
                system.debug('soqlOrder: ' + soqlOrder);
                if(!isExtinstion){
                	if (sortFullExp == 'CaseNumber ASC' && soqlOrder != '' & soqlOrder != null)
                		sortFullExp = soqlOrder;
					queryString = 'select '+query.substring(1) +' from Case  '+getQueryConditions()+' order by '+ sortFullExp;
                }
                else if(isNewGenApp){
                    queryString = 'select '+query.substring(1) +', Description, (SELECT Id, CreatedDate, CommentBody, CreatedById, CreatedBy.Name FROM CaseComments order by CreatedDate ASC limit 200) from Case  '+getQueryConditions()+' order by CreatedDate DESC limit 200';
                }
                else{
                     queryString = 'select '+query.substring(1) +' from Case  '+getQueryConditions()+' order by CreatedDate '+ sortDirection +' limit 5';
                }
                ISSP_Utilities.log('SQL String: ' + queryString);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                //newgenapp

                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
     
    Public List<Case> getCases(){
        system.debug('basto1p - getCases BEGIN');
        //basto1p
        List<Case> casesList=new List<Case>();
        casesList=setCon.getRecords();

        system.debug('basto1p - getCases.casesList='+casesList);

        mapFieldsValue=new Map<String, String>();
        String statusFieldValMapKey='';
        for (Case Item : casesList) {

            //Add mapping for Status field
            statusFieldValMapKey=ISSP_Case.STATUS_FLD_NAME+Item.Status;
            mapFieldsValue.put(statusFieldValMapKey,ISSP_Case.getFieldMappedValue(ISSP_Case.STATUS_FLD_NAME,Item.Status));

        }
        system.debug('basto1p - mapFieldsValue='+mapFieldsValue);

        return casesList;
        //return (List<Case>)setCon.getRecords();
    }
    
}
