public with sharing class ISSP_CertificationCases {

    public string selectedList {get;set;}
    public string currNavState {get;set;}
    public map<string,ISSPCaseListView__c> certificationCasesListViewMap {get;set;} 
    public list<string> ListViewNameList {get;set;}
    
    private String sortDirection = 'DESC';
    private String sortExp  = 'Account__r.IATACode__c, Expiry_Date__c';
    private boolean isExtinstion = false ; 

    public boolean isPWCProfile {get;set;}
    public boolean isDPCUser {get;set;}
    public boolean isAdmin {get;set;}

	public String conId {get; set;}        

    public boolean apList {get;set;}
    public boolean apUser {get;set;}
    
    public string soqlOrder {get;set;}

    public Id userAccount {get;set;}

    //FM 04-10-2017 - new search functionality
    public String searchText {get; set;}
    public Integer selectedPageSize {get;set;}
    

    //FM 29-09-2017 - new list to display on page
    public map<String, list<AMS_Agency_Regulation__c>> listCases {
        get{
            map<String, list<AMS_Agency_Regulation__c>> listCasesOrdered = new map<String, list<AMS_Agency_Regulation__c>>();
                
            if(listCases == null){
                
                listCases = new map<String, list<AMS_Agency_Regulation__c>>();
                ISSP_CertificationCases cert = new ISSP_CertificationCases();
                List<AMS_Agency_Regulation__c> l = setCon.getRecords();
                String sIATACode = '';
                String sIATACodeHO = ''; //For ordering, HO must come 1st on the list
                list<AMS_Agency_Regulation__c> lar = new list<AMS_Agency_Regulation__c>();
                for(AMS_Agency_Regulation__c ar : l){

                    //1st pass                    
                    if(sIATACode.equalsIgnoreCase('') || sIATACode.equalsIgnoreCase(ar.Account__r.IATACode__c)){
                        sIATACode = ar.Account__r.IATACode__c;
                        lar.add(ar);
                        listCases.put(ar.Account__r.IATACode__c, lar);
                        if(ar.Account__r.Location_Type__c == 'HO'){
                            sIATACodeHO = ar.Account__r.IATACode__c;
                        }
                    }

                    //if(sIATACode.equalsIgnoreCase(ar.Account__r.IATACode__c)){
                    //    lar.add(ar);   
                    //    listCases.put(ar.Account__r.IATACode__c, lar);
                    //}

                    if(!sIATACode.equalsIgnoreCase(ar.Account__r.IATACode__c)){
                        sIATACode = ar.Account__r.IATACode__c;
                        lar = new list<AMS_Agency_Regulation__c>();
                        lar.add(ar);
                        listCases.put(ar.Account__r.IATACode__c, lar);
                        if(ar.Account__r.Location_Type__c == 'HO'){
                            sIATACodeHO = ar.Account__r.IATACode__c;
                        }
                    }
                }
                //insert last result
                listCases.put(sIATACode, lar);

                System.debug('1st listCases: ' + listCases);
                //Sort Map in order that HO comes 1st
                //listCasesOrdered.put(sIATACodeHO, listCases.get(sIATACodeHO));
                System.debug('1st listCasesOrdered: ' + listCasesOrdered);
                for (String mapKey : listCases.keySet()) {
                    if(mapKey != sIATACodeHO){
                        System.debug('not HO');
                        listCasesOrdered.put('2' + mapKey, listCases.get(mapKey));
                    }
                }
                if(sIATACodeHO != null && !sIATACodeHO.equalsIgnoreCase('')){
                    listCasesOrdered.put('1' + sIATACodeHO, listCases.get(sIATACodeHO));
                }
                System.debug('2nd listCasesOrdered: ' + listCasesOrdered);

            }
            System.debug('listCases: ' + listCases);
            System.debug('listCases.size(): ' + listCases.size());
            System.debug('3rd listCasesOrdered: ' + listCasesOrdered);
            System.debug('listCasesOrdered.size(): ' + listCasesOrdered.size());
            
            listCases = listCasesOrdered;
            return listCases;
        }
        set;}

    //FM 29-09-2017 - new list to display on page
    public Integer listCasesSize {
        get{
            listCasesSize = setCon.getResultSize();
            return listCasesSize;
        }
        set;}

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
    
    public ISSP_CertificationCases(){}

    public ISSP_CertificationCases(ISSP_Homepage controller) {
        system.debug('KER1 START ISSP_CertificationCases(ISSP_Homepage controller)');
        isExtinstion = true ;
        initialization();
    }
    
    public PageReference initialization() {
        try {
            if(!isExtinstion){
                sortDirection = 'ASC';
            }
            else{
				ApexPages.currentPage().getParameters().put('ListViewName', 'ISSP_Certifications');
                sortDirection = 'ASC';
            }
            
            //FM 04-10-2017 - new search functionality
            if (ApexPages.currentPage().getParameters().get('search') != null){
                searchText = ApexPages.currentPage().getParameters().get('search');
            }

            //AS
            currNavState = ApexPages.currentPage().getParameters().get('mid');
            
            //TF
            apList = false;
            apUser = false;

            User myUser = [select Id,ContactId,Contact.AccountId from User where Id =:Userinfo.getUserId()];

            if (myUser.ContactId != null){
			
            	conId = myUser.ContactId;
				List <Portal_Application_Right__c> appRightList = [Select Id From Portal_Application_Right__c
																where Contact__c =: myUser.ContactId and
																Right__c = 'Access Granted'  and
																Portal_Application__r.Name = 'Airline Participation'];
		        if (!appRightList.isEmpty()){
		                apUser = true;
		        }
            }
            if (myUser.Contact.AccountId != null){
            	userAccount = myUser.Contact.AccountId;
            }
                
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            if(profileName.startsWith('ISS Portal PwC')){  isPWCProfile = true; }
            if(profileName.startsWith('ISS Portal DPC Admin') ){  isDPCUser= true; }
            
            isAdmin = ApexPages.currentPage().getParameters().get('admin') == 'true'  ? true : false ;
            
            initFilters();
            initCertificationCasesListViewMap();

            if(selectedPageSize == null){
                selectedPageSize = 25;
            }
            
        } catch(Exception exp) {
                ISSP_Utilities.exceptionDump(exp);
        }
        return null;
    }
    
    //AEF:
    private list<ISSPCaseListView__c> csCertificationCasesListViews { 
        get {
			if(null == csCertificationCasesListViews)
            	csCertificationCasesListViews = ISSPCaseListView__c.getAll().values();
			return csCertificationCasesListViews;
        } 
        set; 
    }
    private ISSP_PermissionFilterFactory.PermissionSetFilter     thePermissionSetFilter { get; set; }
    private ISSP_PermissionFilterFactory.ProfilePermissionFilter theProfilePermissionFilter { get; set; }   

    private void initFilters() {
        system.debug('initFilters user id >> ' + UserInfo.getUserId());
        theProfilePermissionFilter = ISSP_PermissionFilterFactory.createProfilePermissionFilter();
        thePermissionSetFilter =ISSP_PermissionFilterFactory.createPermissionSetFilter(csCertificationCasesListViews, 'Permission_set__c');
    }
    
    private void initCertificationCasesListViewMap() {
        ListViewNameList = new list<string>();
        certificationCasesListViewMap = new map<string,ISSPCaseListView__c>();
        for(ISSPCaseListView__c certificationCasesListViewItem : csCertificationCasesListViews){
                   
			Boolean resultPermission1 = true; 
            if(!theProfilePermissionFilter.isDataEmpty(certificationCasesListViewItem, 'Profiles_Id__c')) {
                resultPermission1 = theProfilePermissionFilter.isUserPermittedFor(certificationCasesListViewItem, 'Profiles_Id__c');
            }
                 
            Boolean resultPermission2 = true; 
            if(!thePermissionSetFilter.isDataEmpty(certificationCasesListViewItem, 'Permission_set__c')) {
                resultPermission2 = thePermissionSetFilter.isUserPermittedFor(certificationCasesListViewItem, 'Permission_set__c');
            }
                
            if(resultPermission1 && resultPermission2) {
                system.debug('certificationCasesListViewItem.Name: ' + certificationCasesListViewItem.Name);
                system.debug('apUser: ' + apUser);
                if (certificationCasesListViewItem.Name.startsWith('ISSP_Certifications') ){
                    //if (apUser){
                        certificationCasesListViewMap.put(certificationCasesListViewItem.Name,certificationCasesListViewItem);
                        ListViewNameList.add(certificationCasesListViewItem.Name);
                    //}
                }
                //else{
                //    if(!isAdmin && certificationCasesListViewItem.isAdmin__c == false){
                //        certificationCasesListViewMap.put(certificationCasesListViewItem.Name,certificationCasesListViewItem);
                //        ListViewNameList.add(certificationCasesListViewItem.Name);
                //    }else{
                //        if(isAdmin && certificationCasesListViewItem.isAdmin__c == true){
                //            certificationCasesListViewMap.put(certificationCasesListViewItem.Name,certificationCasesListViewItem);
                //            ListViewNameList.add(certificationCasesListViewItem.Name);
                //        } 
                //    }
                //}
            }
        }
        ListViewNameList.sort();
        //if(ListViewNameList.size()>0){
        //    selectedList = ListViewNameList.get(0);
        //}
        
        string ListViewName = ApexPages.currentPage().getParameters().get('ListViewName');
        if( ListViewName!=null && certificationCasesListViewMap.containsKey(ListViewName)){
            selectedList = ListViewName;
        }else{
        	selectedList = 'ISSP_Certifications';
        }
        system.debug('selectedList >>> ' + selectedList);
    }
    
    public List<Schema.FieldSetMember> getFields() {
    	system.debug('certificationCasesListViewMap >>> ' + certificationCasesListViewMap);
        return selectedList==null||selectedList==''?
            new list<Schema.FieldSetMember>():
            sObjectType.AMS_Agency_Regulation__c.FieldSets.getMap().get(certificationCasesListViewMap.get(selectedList).Field_Set_API_Name__c).getFields();
    }
    
    public Pagereference refresh(){ 
        setCon = null;
        listCases = null;
        return null;
    }
    public string getQueryConditions() {
        system.debug('certificationCasesListViewMap >>> ' + certificationCasesListViewMap);
        
        if(certificationCasesListViewMap.isEmpty())
			return 'WHERE ID = NULL';
        
        String queryConditions;
        if(String.isNotBlank(selectedList))
			queryConditions = certificationCasesListViewMap.get(selectedList).SOQL_Filter__c;             
                
        return String.isNotBlank(queryConditions) ? queryConditions : ''; 
    }

    //FM 29-09-2017 - new list to display on page
    public string getQuerySearchConditions() {
        String strQuery = '';
        if (searchText != null && searchText != '') {
            strQuery += ' AND (';
            strQuery += 'First_Name__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += 'OR Last_Name__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += 'OR Type_Of_Certificate__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += 'OR Account__r.IATACode__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += 'OR Account__r.BillingCity LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'';
            strQuery += ')';
        } 
        return strQuery;
    }
    
    ////////////////////////////////
    
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                string sortFullExp = sortExpression  + ' ' + sortDirection;
                
                //FM 09/10/2017 - implementation of number of records per page
                //size = 10;
                size = selectedPageSize;
                //AEF:
                Set<String> fieldPathSet = new Set<String>();
                for(Schema.FieldSetMember f : this.getFields()) {
                    fieldPathSet.add(f.getFieldPath());
                }

                //String query = '  Account.Name , Contact.Name   ';
                String query = '';
                for(String fieldPath  : fieldPathSet) {
                    system.debug('fieldPath: ' + fieldPath);
                    system.debug('query: ' + query);
                    query +=  (query.equalsIgnoreCase('')?'':',') + fieldPath;
                }
                
                string queryString ;
                if(String.isNotBlank(selectedList)){
                	if (certificationCasesListViewMap.containsKey(selectedList)){
						soqlOrder = certificationCasesListViewMap.get(selectedList).SOQL_Order__c;
                	}
                }
                system.debug('sortFullExp: ' + sortFullExp);
                system.debug('selectedList: ' + selectedList);
                system.debug('soqlOrder: ' + soqlOrder);
                system.debug('query: ' + query);
                if(!isExtinstion){
                	//if (sortFullExp == 'CaseNumber ASC' && soqlOrder != '' & soqlOrder != null)
                	//	sortFullExp = soqlOrder;
					//queryString = 'select '+query.substring(1) +' from AMS_Agency_Regulation__c  '+getQueryConditions()+' order by '+ sortFullExp;
					queryString = 'select '+query +' from AMS_Agency_Regulation__c  where (Account__c = :userAccount OR Account__r.top_parent__c = :userAccount) '+ getQueryConditions() + getQuerySearchConditions() +' order by '+ sortFullExp;
		        }
                else{
                     //queryString = 'select '+query.substring(1) +' from AMS_Agency_Regulation__c  '+getQueryConditions()+' order by CreatedDate '+ sortDirection +' limit 5';
                     queryString = 'select '+query +' from AMS_Agency_Regulation__c  where (Account__c = :userAccount OR Account__r.top_parent__c = :userAccount) '+ getQueryConditions() + getQuerySearchConditions() +' order by CreatedDate '+ sortDirection +' limit 5';
                }
                ISSP_Utilities.log('SQL String: ' + queryString);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
     
    Public List<AMS_Agency_Regulation__c> getCases(){
    	List<AMS_Agency_Regulation__c> l = setCon.getRecords();
    	system.debug('List Data: ' + l);
        return l;
    }

    // returns the next page of records
    public void next() {
        listCases = null;
        this.setCon.next();
    }
    
    // returns the first page of records
    public void first() {
        listCases = null;
        this.setCon.first();
    }

    // returns the last page of records
    public void last() {
        listCases = null;
        this.setCon.last();        
    }

    // returns the previous page of records
    public void previous() { 
        listCases = null;
        this.setCon.previous();
    }
}
