public class ISSP_Ctrl_BuyCertificate { 
    public Case newCase {get;set;}

/*------------------------------------------------------*/
    
    public string selectedList {get;set;}
    public string currNavState {get;set;}
    public map<string,ISSP_CertificateListView__c> caseListViewMap {get;set;} 
    public list<string> ListViewNameList {get;set;}
    
    private String sortDirection = 'DESC';
    private String sortExp  = 'CaseNumber';
    private boolean isExtinstion = false ; 

    public boolean isPWCProfile {get;set;}
    public boolean isDPCUser {get;set;}
    public boolean isAdmin {get;set;}
        
    public boolean apList {get;set;}
    public boolean apUser {get;set;}
    
    public string soqlOrder {get;set;}

    public String Category {get;set;}
    public String SubCategory{get;set;}

    public Contact con       {get;set;}  

    public String sortExpression {
     get { return sortExp; }
     set {
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp)
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'DESC';
       sortExp = value;
     }
    }

    public boolean iataCertificatesVisible {get; set;}

    public static final Set<String> EXCLUDEACCOUNTSTATUS = new Set<String>{'Terminated','New application pending','Not accreditated'};
    
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
    
    public List<SelectOption> getCategories()
    {
       List<SelectOption> options = new List<SelectOption>();
        
        List <Product_Category__c> ProductCategorytList = [SELECT Id, Name, Active__c,Short_Description__c
                                      FROM Product_Category__c
                                     WHERE Name = : 'IATA Certificate'
                                     ORDER BY Name
                                     ];
        Set<String> ProductCategory_set = new Set<String>();

        for(Product_Category__c thisPC : ProductCategorytList){
            if (!ProductCategory_set.contains(thisPC.Name))
            {
                ProductCategory_set.add(thisPC.Name);
            }
        }
        for(String thisPC : ProductCategory_set){
            options.add(new SelectOption(thisPC, thisPC));
        }
        return options;
    } 
    
    public List<SelectOption> getSubCategories()
    {
         List<SelectOption> options = new List<SelectOption>();
        
        List <Product_Category__c> ProductCategorytList = [SELECT Id, Name, Active__c,Short_Description__c
                                      FROM Product_Category__c
                                     WHERE Name = : 'IATA Certificate'
                                     ORDER BY Name
                                     ];
        for(Product_Category__c thisPC : ProductCategorytList){
            options.add(new SelectOption(thisPC.Short_Description__c, thisPC.Short_Description__c));
        }
        return options;
    }       

    public ISSP_Ctrl_BuyCertificate(){}
    public ISSP_Ctrl_BuyCertificate(ISSP_Homepage controller){
        isExtinstion = true ;
        initialization();
    }
    
    public PageReference initialization() {
        try {
            if(!isExtinstion){
                sortDirection = 'ASC';
            }
            else{
                ApexPages.currentPage().getParameters().put('ListViewName', '1_Certificate_All');
                sortDirection = 'DESC';
            }

            //Retrieve  Contact
            User myUser = DAL_ISSP.getUser(Userinfo.getUserId());
            con = DAL_ISSP.getContact(myUser.ContactId);
            
            if(con <> null){
                iataCertificatesVisible = DAL_ISSP.visibilityOnIATACertificate(con.Account.Category__c, con.Account.Status__c);
            } else {
                iataCertificatesVisible = false;
            }
            
            newCase = new Case();
            //Assign IATA Code
            newCase.IATACodeProduct__c = con.Account.IATACode__c != null ? con.Account.IATACode__c : '';
            //AS
            currNavState = ApexPages.currentPage().getParameters().get('mid');
            
            //TF
            apList = false;
            apUser = false;
             
            if (myUser.ContactId != null){
                List <Portal_Application_Right__c> appRightList = [Select Id From Portal_Application_Right__c
                                                                where Contact__c =: myUser.ContactId and
                                                                Right__c = 'Access Granted'  and
                                                                Portal_Application__r.Name = 'Airline Participation'];
                if (!appRightList.isEmpty()){
                        apUser = true;
                }
            }
                
            isAdmin = ApexPages.currentPage().getParameters().get('admin') == 'true'  ? true : false ;
            
            initFilters();
            initCaseListViewMap();
            
        } catch(Exception exp) {
                ISSP_Utilities.exceptionDump(exp);
        }
        return null;
    }
    
     
    private list<ISSP_CertificateListView__c> csCaseListViews { 
        get {
            if(null == csCaseListViews)
                csCaseListViews = ISSP_CertificateListView__c.getAll().values();
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
        caseListViewMap = new map<string,ISSP_CertificateListView__c>();
        for(ISSP_CertificateListView__c caseListViewItem : csCaseListViews){
                   
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
        
        string ListViewName = ApexPages.currentPage().getParameters().get('ListViewName');
        if( ListViewName!=null && caseListViewMap.containsKey(ListViewName)){
            selectedList = ListViewName;
        }
    }
    
    public List<Schema.FieldSetMember> getFields() {
       return selectedList==null||selectedList==''?
            new list<Schema.FieldSetMember>():
            sObjectType.Case.FieldSets.getMap().get(caseListViewMap.get(selectedList).Field_Set_API_Name__c).getFields();
    }


    public List<List<SelectOption>> getAccounts() {
        List<List<SelectOption>> options = new List<List<SelectOption>>();
        List<SelectOption> none = new List<SelectOption>();
        none.add(new SelectOption('', '--None--'));
        options.add(none);
        List<List<Account>> auxAccounts = new List<List<Account>>();
        List <Account> accountList2 = new List<Account>();
        List <Account> accountList3 = new List<Account>();
        List <Account> accountList4 = new List<Account>();
        List <Account> accountList5 = new List<Account>();
        List <Account> accountList1 = [SELECT Id, Name, IATA_ISO_Country__r.Name, Site, Sector__c, IATACode__c, Field_Head_Office__c, Status__c
                                        FROM Account
                                        WHERE (Id = :con.AccountId OR Top_Parent__c = :con.AccountId) AND RecordType.DeveloperName IN ('IATA_Agency','IATA_Airline','IATA_Airline_BR','Standard_Account')
                                        AND IATACode__c != null AND Status__c NOT IN :EXCLUDEACCOUNTSTATUS
                                      ORDER BY IATACode__c limit 1000
                                      ];
             auxAccounts.add(accountList1);                       
         if(accountList1.size() == 1000){
            accountList2=
            [SELECT Id, Name, IATA_ISO_Country__r.Name, Site, Sector__c, IATACode__c, Field_Head_Office__c, Status__c
             FROM Account
             WHERE (Id = :con.AccountId OR Top_Parent__c = :con.AccountId) AND RecordType.DeveloperName IN ('IATA_Agency','IATA_Airline','IATA_Airline_BR','Standard_Account')
             AND IATACode__c != null AND Status__c NOT IN :EXCLUDEACCOUNTSTATUS
             ORDER BY IATACode__c
             Limit 1000
             OFFSET 1000
            ];
            auxAccounts.add(accountList2);
        }
         if(accountList2.size() == 1000){
            accountList3=
            [SELECT Id, Name, IATA_ISO_Country__r.Name, Site, Sector__c, IATACode__c, Field_Head_Office__c, Status__c
             FROM Account
             WHERE (Id = :con.AccountId OR Top_Parent__c = :con.AccountId) AND RecordType.DeveloperName IN ('IATA_Agency','IATA_Airline','IATA_Airline_BR','Standard_Account')
             AND IATACode__c != null AND Status__c NOT IN :EXCLUDEACCOUNTSTATUS
             ORDER BY IATACode__c
             Limit 1000
             OFFSET 2000
            ];
            auxAccounts.add(accountList3);
        }   
        if(accountList3.size() == 1000){
            accountList4=
            [SELECT Id, Name, IATA_ISO_Country__r.Name, Site, Sector__c, IATACode__c, Field_Head_Office__c, Status__c
             FROM Account
             WHERE (Id = :con.AccountId OR Top_Parent__c = :con.AccountId) AND RecordType.DeveloperName IN ('IATA_Agency','IATA_Airline','IATA_Airline_BR','Standard_Account')
             AND IATACode__c != null AND Status__c NOT IN :EXCLUDEACCOUNTSTATUS
             ORDER BY IATACode__c
             Limit 1000
             OFFSET 3000
            ];
            auxAccounts.add(accountList4);
        } 
        if(accountList4.size() == 1000){
            accountList5=
            [SELECT Id, Name, IATA_ISO_Country__r.Name, Site, Sector__c, IATACode__c, Field_Head_Office__c, Status__c
             FROM Account
             WHERE (Id = :con.AccountId OR Top_Parent__c = :con.AccountId) AND RecordType.DeveloperName IN ('IATA_Agency','IATA_Airline','IATA_Airline_BR','Standard_Account')
             AND IATACode__c != null AND Status__c NOT IN :EXCLUDEACCOUNTSTATUS
             ORDER BY IATACode__c
             Limit 1000
             OFFSET 4000
            ];
            auxAccounts.add(accountList5);
        }                          
        if(auxAccounts!= null && auxAccounts.size() >0 ){  
            for(List<Account> accounts : auxAccounts){
                List<SelectOption> optionsAux = new List<SelectOption>();
                for(Account account : accounts){
                    String theLabel = account.Name + ' (' + account.IATACode__c + ')';
                    optionsAux.add(new SelectOption(account.IATACode__c, theLabel));
                }
                options.add(optionsAux);
            }
        }
        return options;
    }
    
    public PageReference refresh(){
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

                String query = '  Account.Name , Contact.Name   ';
                for(String fieldPath  : fieldPathSet) {
                    query +=  ',' + fieldPath;
                }
                
                string queryString ;
                if(String.isNotBlank(selectedList)){
                    if (caseListViewMap.containsKey(selectedList)){
                        soqlOrder = caseListViewMap.get(selectedList).SOQL_Order__c;
                    }
                }

                if(!isExtinstion){
                    if (sortFullExp == 'CaseNumber ASC' && soqlOrder != '' & soqlOrder != null)
                        sortFullExp = soqlOrder;
                    queryString = 'select '+query.substring(1) +' from Case  '+getQueryConditions()+' order by CreatedDate DESC';
                }
                else{
                     queryString = 'select '+query.substring(1) +' from Case  '+getQueryConditions()+' order by CreatedDate '+ sortDirection +' limit 5';
                }
                ISSP_Utilities.log('SQL String: ' + queryString);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
     
    Public List<Case> getCases(){
        return (List<Case>)setCon.getRecords();
    }

/*------------------------------------------------------*/
  public PageReference home()  
    {
        //string retURL = ApexPages.currentPage().getParameters().get('retURL');
        return new Pagereference('/ISSP_Homepage?mid=M0S1');
        
    }



    public Pagereference Purchase(){
    system.debug('XXX Purchase: ' );
        try 
        {      
            //Assign RecordType
            Id CaseSAAMId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM
            Id CaseOSCARid = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
            
            //Assign Account_Concerned__c
            List <Account> accountList = [SELECT Id, Name, IATA_ISO_Country__r.Name,IATA_ISO_Country__r.OSCAR_enabled__c, Site, Sector__c, IATACode__c, Field_Head_Office__c ,Region_formula__c
                                     FROM Account
                                     WHERE IATACode__c =: newCase.IATACodeProduct__c
                                     ORDER BY IATACode__c
                                     ];

            if(accountList[0].IATA_ISO_Country__r.OSCAR_enabled__c){
                newCase.RecordTypeId = CaseOSCARid ;
            }else{
                newCase.RecordTypeId = CaseSAAMId ;
            }


            system.debug('XXX accountList: ' +accountList);
            newCase.Account_Concerned__c    = accountList[0].Id ;
            newCase.BSPCountry__c           = accountList[0].IATA_ISO_Country__r.Name ;
            newCase.Region__c               = accountList[0].Region_formula__c;
            newCase.Origin                  = 'Portal';
            newCase.Subject                 = 'Request for certificate - '+ newCase.IATACodeProduct__c;
            newCase.CaseArea__c             = 'Accreditation Products';
            newCase.Reason1__c              = 'PAX/CARGO Certificate';
            if (newCase.Description == null){
                newCase.Description = '';   
            }
            newCase.Description             = 'Product Category : ' + Category +'\n' +
                                              'Product SubCategory : ' + SubCategory +'\n' +
                                               '\n' + newCase.Description   ;
           
            system.debug('XXX newCase: ' +newCase);
            List <Product_Category__c> ProductCategorytList = [SELECT Id, Name, Active__c,Short_Description__c
                                      FROM Product_Category__c
                                     WHERE Short_Description__c = : SubCategory
                                     ORDER BY Name
                                     ];

            system.debug('XXX ProductCategorytList: ' +ProductCategorytList);
            newCase.Product_Category_ID__c  = ProductCategorytList != null ? ProductCategorytList[0].Id : '' ;
            
            newCase.ownerid = getRegionalQueue();

            //Assign Category and Subcategory      
            //newCase.ProductCategory__c        = Category ;
            //newCase.ProductSubcategory__c = SubCategory ;
            system.debug('XXX newCase: ' + newCase);
            insert newCase ;
            
            //Call OSCAR integration WS
            if(accountList[0].IATA_ISO_Country__r.OSCAR_enabled__c){
                AMS_RecordCreatorWebservice.createAccreditation(con.AccountId, AMS_RecordCreatorWebservice.EMPTYACCREDITATIONID, 'CER.1.0', newCase.Id);
            }
            
            PageReference p = new PageReference('/ISSP_Case?caseId='+newCase.Id);
            p.setRedirect(true);
            return p;
        }
        catch (Exception  e)
        {
            AddError(e.getMessage());
        }
        return null;
    }

    private void AddError(string msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
    }

    public Id getRegionalQueue() {
        //Available queue names
        Id qId;

        Set<String> queueNames = new Set<String> {'AgencyManagementAP', 'AgencyManagementAfricaME', 'AgencyManagementAmericas', 'AgencyManagementChinaNAsia', 'CasesACCEuropeOffOnshore'};
        Map<String, QueueSobject> mapRegionalQueue = new Map<String, QueueSobject>();
        //Build map queue.name -> queue
        for (QueueSobject queue : [Select Queue.Id, Queue.DeveloperName From QueueSobject Where Queue.DeveloperName in: queueNames]) {
            mapRegionalQueue.put(queue.Queue.DeveloperName, queue);
        }

        //Assigns queue according to region
        if (newCase.Region__c == 'Africa & Middle East') {
            if (mapRegionalQueue.get('AgencyManagementAfricaME') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAfricaME').Queue.Id;
            }

        } else if (newCase.Region__c == 'Americas') {
            if (mapRegionalQueue.get('AgencyManagementAmericas') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAmericas').Queue.Id;
            }

        } else if (newCase.Region__c == 'Asia & Pacific') {
            if (mapRegionalQueue.get('AgencyManagementAP') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAP').Queue.Id;
            }
        } else if (newCase.Region__c == 'China & North Asia') {
            if (mapRegionalQueue.get('AgencyManagementChinaNAsia') != null) {
                qId = mapRegionalQueue.get('AgencyManagementChinaNAsia').Queue.Id;
            }
        } else if (newCase.Region__c == 'Europe') {
            if (mapRegionalQueue.get('CasesACCEuropeOffOnshore') != null) {
                qId = mapRegionalQueue.get('CasesACCEuropeOffOnshore').Queue.Id;
            }
        }
        System.DEBUG('Case region: ' + newCase.Region__c);
        System.DEBUG('AM Queue returned: ' + qId);
        return qId;
    }
}