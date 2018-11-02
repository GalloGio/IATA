public with sharing class ISSP_AvailableServices{

    public string selectedList {get;set;}
    public List<ServiceWrapper> ServiceList;
    public map<string,ISSPServiceListView__c> ServiceListViewMap {get;set;} 
    public list<string> ListViewNameList {get;set;}
    
    private String sortDirection = 'ASC';
    private String sortExp  = 'CreatedDate'; 
    
    public Boolean isAdmin {get;set;}
    public Boolean isAuthorisedSignatory {get;set;}

    public String conId {get; set;}
    public String conHOAccountLocType {get; set;} //FM 17-03-2017 - Contains Locatiopn Type of Top Parent  
    public Boolean isIEPAccountEnable {get;set;} //FM 17-03-2017 - check if IEC Account is available for User to request Access  
    //public String isIEPAccountEnableMsg {get; set;} //FM 17-03-2017 - Contains Locatiopn Type of Top Parent  
    public String modalErrorMessage {get; set;}
    public Boolean isModalErrorMessageEnable {get;set;}
    
    public ServiceWrapper Serv {get; set;}
    public String ServId {get; set;}
    
    public Boolean hasPremiumTD {get; set;}

    public String TOCdocumentId {get; set;}
    public list<String> errorMessage {get; set;}
    public boolean accept {get; set;}
    public boolean pollerOn {get; set;}
    public Map<String, String> iepRoles {get; set;}
    public Boolean redirect {get; set;}
    public Boolean provError {get; set;}
    public Integer failedCount  {get; set;}
    public Map<String, String> helpTextPortalRoles {get; set;}

    Integer count = 0;

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    
    public static User currentPortalUser {
        get {
            if(currentPortalUser == null){
                currentPortalUser = [SELECT id, ANG_Sector__c, ANG_Is_Accredited_Agent__c, ANG_Customer_Country_ISO__c, contact.AccountId, contact.name,
                                    contact.account.ANG_IEP_Status_FF__c,ContactId,
                                    languagelocalekey,ProfileId  
                                    from User where id =: UserInfo.getUserId()];
            }
            return currentPortalUser;
        } 
        set;}
    
    public String defaultPortalUserRole {get; set;}    

    public String IepStatus {get; set;}

    public class SelectOption2 {
        public String value {get; set;}
        public String label {get; set;}
        public String helpText {get; set;}

        public SelectOption2(String value, String label, String helpText) {
            this.value = value;
            this.label = label;
            this.helpText = helpText;
        }
    }

    public static Map<String,List<String>> availableRoles;

    public List<SelectOption2> availablePortalServiceRoles {
        get{


            Map<String, Map<Decimal, String>> orderRoles = new Map<String, Map<Decimal, String>>();


            availableRoles = new Map<String,List<String>>();

            for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()){
				if(role.Connected_App__c.startsWith('IATA EasyPay')) {
					if(availableRoles.get(role.Connected_App__c) == null) {
						availableRoles.put(role.Connected_App__c , new List<String>{role.Role__c});

						Map<Decimal, String> aux = new Map<Decimal, String>();
						aux.put(role.Order__c, role.Role__c);

						orderRoles.put(role.Connected_App__c, aux);

					} else {                        
						availableRoles.get(role.Connected_App__c).add(role.Role__c);

						Map<Decimal, String> aux = orderRoles.get(role.Connected_App__c);
						aux.put(role.Order__c, role.Role__c);                        
					}
				}
            }

            Set<String> availableRolesLst = availableRoles.keySet();

            List<SelectOption2> availablePortalServiceRolesAux = new List<SelectOption2>();
            
            Set<String> availableRolesSet = new Set<String>();

            for(String roleConnApp: availableRolesLst){

                if(roleConnApp == this.Serv.recordService.Name){

                    for(String roleStr : availableRoles.get(roleConnApp)){
                        availableRolesSet.add(roleStr);
                        //availablePortalServiceRolesAux.add(new SelectOption2(roleStr, roleStr, this.helpTextPortalRoles.get(roleStr)));
                    }
                }
            }
            

            if(orderRoles.containsKey(this.Serv.recordService.Name)) {

                availablePortalServiceRolesAux = new List<SelectOption2>();

                Map<Decimal, String> rolesOrderToApply = orderRoles.get(this.Serv.recordService.Name);

                List<Decimal> orders = new List<Decimal>();
                orders.addAll(rolesOrderToApply.keySet());
                orders.sort();

                for(Decimal o : orders) {

                    String roleStr = rolesOrderToApply.get(o);

                    if(availableRolesSet.contains(roleStr)) {
                        availablePortalServiceRolesAux.add(new SelectOption2(roleStr, roleStr, this.helpTextPortalRoles.get(roleStr)));

                    }
                }

                availablePortalServiceRoles = availablePortalServiceRolesAux;

            } else {
                availablePortalServiceRoles = availablePortalServiceRolesAux;
            }

            return availablePortalServiceRoles;

        } set;}    

    public List<SelectOption> iccsAvailablePortalServiceRoles {get; set;}

    public String sortExpression {
     get { return sortExp; }
     set {
        
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp || (value == 'Name' && sortExp == 'Name') || (value == 'Name' && sortExp == 'Name')){
        system.debug('CHANGING FROM: ' + sortDirection);
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
        system.debug('CHANGING TO: ' + sortDirection);
       }
       else{
         sortDirection = 'ASC';
         system.debug('NOT CHANGING');
       }
       if (value != 'Description__c')
        sortExp = value;
       else
        sortExp = 'Name';
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
    
    public ISSP_AvailableServices(){

        this.isModalErrorMessageEnable = false;

        this.helpTextPortalRoles = new Map<String, String>();

        for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()){
			if(role.Connected_App__c.startsWith('IATA EasyPay')) {
				if(!this.helpTextPortalRoles.containsKey(role.Role__c)) {
					String aux = role.Role__c.replaceAll(' ','');
					String aux2 = aux.replaceAll('-','');

					String helpText = getCustomLabel('ISSP_ANG_Portal_Role_' + aux2);

					if(helpText == 'NONE') helpText = '';

					this.helpTextPortalRoles.put(role.Role__c, helpText);

				}
			}
        }

        this.iepRoles = new Map<String, String>();

        this.redirect = false;
        this.provError = false;
        
        availableRoles = new Map<String,List<String>>();

        for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()){
			if(role.Connected_App__c.startsWith('IATA EasyPay')) {
				if(role.Permission_set_SSO__c != null){
					iepRoles.put(role.Connected_App__c + ' - ' + role.Role__c, role.Permission_set_SSO__c);   
				}


				if(availableRoles.get(role.Connected_App__c) == null)
					availableRoles.put(role.Connected_App__c , new List<String>{role.Permission_set_SSO__c});
				else
					availableRoles.get(role.Connected_App__c).add(role.Permission_set_SSO__c);

				if (role.Default_User_Role__c) {
					this.defaultPortalUserRole = role.Role__c;
				}
			}
        }

        IepStatus = currentPortalUser.contact.account.ANG_IEP_Status_FF__c;

        iccsAvailablePortalServiceRoles = new List<SelectOption>();
        
        List<Connected_App_Roles__c> iccsRoles = [SELECT Default_User_Role__c, Role__c FROM Connected_App_Roles__c where Connected_App__c = 'ICCS' and (Role__c = : ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY or Role__c = : ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1)];

        iccsAvailablePortalServiceRoles.add(new SelectOption('', ''));
        
        for (Connected_App_Roles__c role : iccsRoles) {
            iccsAvailablePortalServiceRoles.add(new SelectOption(role.Role__c, role.Role__c));

            if (role.Default_User_Role__c) {
                this.defaultPortalUserRole = role.Role__c;
            }
        }
    }

    public String getCustomLabel(String labelName) {
        if(labelName != null && labelName != '') {
            Component.Apex.OutputText output = new Component.Apex.OutputText();
            output.expressions.value = '{!$Label.' + labelName + '}';
            return string.valueOf(output.value);
        } else {
            return labelName;
        }
    }    
    
    public PageReference initialization() {
        try {

            this.count = 0;
            this.pollerOn = false;
            this.isAuthorisedSignatory = false;

            initFilters();
            initServiceListViewMap();

            errorMessage = new list<string>();
            accept = false;

            this.isAdmin = isPortalAdminUser();
            system.debug('isAdmin: ' +  this.isAdmin);


            if(!Test.isRunningTest()) {
                conId = currentPortalUser.ContactId;
            }else{
                conId = [select Id from Contact limit 1].Id;
            }

            //FM 17-03-2017 - Logic for Authorised Signatory 
            //NOTE - Base any logic on the Portal Admin for now (User Portal Status=Approved Admin) since Authorised Signatories are not yet identified in SFDC
            //TODO - Remove above note once  Authorised Signatory code implemented
            System.debug('[FM] initialization conId - '+ conId);

            //
            // Get the contact's data.
            //
            Contact contAcc = AMS_Utils.getIEPContact(conId);

            this.isAuthorisedSignatory = (isAdmin && contAcc.Authorized_Signatory__c);                
            
            System.debug('[FM] initialization contAcc - '+ contAcc);

            conHOAccountLocType = '';
            isIEPAccountEnable = false;

            // A user has accecss to easypay when:
            // If the IEP status is open
            // If the IEP status is not open and is an admin and the account is HO or HE 
            if(contAcc.Account.ANG_IEP_Status_FF__c == 'Open') {
                isIEPAccountEnable = true;                
            } else if( 
                isAuthorisedSignatory && isAdmin && (contAcc.Account.Location_Type__c == 'HO' || contAcc.Account.Location_Type__c == 'HE' || 
                         (contAcc.Account.Location_Type__c == 'AO' && contAcc.Account.Status__c == 'Listed'))) {
                isIEPAccountEnable = true;
            }

            String msgComplement;
            if(isAdmin) {
                if(contAcc.Account.ANG_IEP_Status_FF__c == ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT) 
                    msgComplement = Label.ANG_ISSP_IEP_AuthorisedSignatory_auth_msg_Administrator;
                else
                    msgComplement = Label.ANG_ISSP_IEP_AuthorisedSignatory_auth_msg_Active;
            } else {
                msgComplement = Label.ANG_ISSP_IEP_AuthorisedSignatory_auth_msg_Active;
            }

            String aux;
            if(contAcc.Account.Location_Type__c == 'HO' || contAcc.Account.Top_Parent__r.Location_Type__c == 'HO'){
                aux = Label.ANG_ISSP_IEP_AuthorisedSignatory_HO_auth_msg;
                modalErrorMessage = aux.replace('{0}', msgComplement);
            }else if(contAcc.Account.Location_Type__c == 'HE' || contAcc.Account.Top_Parent__r.Location_Type__c == 'HE'){
                aux = Label.ANG_ISSP_IEP_AuthorisedSignatory_HE_auth_msg;
                modalErrorMessage = aux.replace('{0}', msgComplement);
            } else if (contAcc.Account.Location_Type__c == 'AO' || contAcc.Account.Top_Parent__r.Location_Type__c == 'AO') {
                aux = Label.ANG_ISSP_IEP_AuthorisedSignatory_AO_auth_msg;
                modalErrorMessage = aux.replace('{0}', msgComplement);
            }

            if (!isIEPAccountEnable) {
                isModalErrorMessageEnable = true;
                if (contAcc.Account.ANG_IEP_Status_FF__c == ANG_ISSP_PortalServiceHelper.STATUS_IN_PROGRESS) {
                    modalErrorMessage = Label.ANG_ISSP_IEP_OpeningInProgress;
                }
            } else {
                if (contAcc.Account.ANG_IEP_Status_FF__c == ANG_ISSP_PortalServiceHelper.STATUS_IN_PROGRESS) {
                    modalErrorMessage = Label.ANG_ISSP_IEP_OpeningInProgress;
                    isModalErrorMessageEnable = true;
                } else {
                    if(contAcc.Account.ANG_IEP_Status_FF__c != ANG_ISSP_PortalServiceHelper.STATUS_OPEN && contAcc.Account.ANG_IEP_Status_FF__c != ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT) {
                        modalErrorMessage = aux.replace('{0}', Label.ANG_ISSP_IEP_AuthorisedSignatory_auth_msg_Active);
                        isModalErrorMessageEnable = true;
                    }
                }
            }

            if(contAcc.Account.Is_Branch_Abroad__c == 'Yes') {
                isModalErrorMessageEnable = true;
                modalErrorMessage = Label.ANG_ISSP_IEP_Abroad_Account_error_msg;
            }
            
            // ICCS Part
            iccsMembershipStatus = ISSP_ICCS_Utils.getICCSMembershipStatus(conId);
        } catch(Exception exp) {
            ISSP_Utilities.exceptionDump(exp);
        }
        return null;
    }
    
	public String iccsMembershipStatus {get;set;}
	public Boolean isIccsMembershipInactive {get{return iccsMembershipStatus == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_NONE || iccsMembershipStatus == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_INACTIVE;}}
	public Boolean isIccsMembershipProspect {get{return iccsMembershipStatus == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_PROSPECT;}}
	public Boolean isIccsMembershipActive {get{return iccsMembershipStatus == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_ACTIVE;}}
	public Boolean isIccsMembershipMember {get{return iccsMembershipStatus == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_MEMBER;}}
	public Boolean isIccsMembershipWithdrawn {get{return iccsMembershipStatus == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_WITHDRAWN;}}
	public Boolean isIccsMembershipSuspended {get{return iccsMembershipStatus == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_SUSPENDED;}}
    
    //AEF:
    private list<ISSPServiceListView__c> csServiceListViews { 
        get {
            if(null == csServiceListViews)
                csServiceListViews = ISSPServiceListView__c.getAll().values();
            system.debug('ISSPServiceListView__c: ' + csServiceListViews);
            return csServiceListViews;
        } 
        set; 
    }
    private PermissionSetFilter     thePermissionSetFilter { get; set; }
    private ProfilePermissionFilter theProfilePermissionFilter { get; set; }   
    //todo
    private void initFilters() {
        set<String> permissionSetIDs = new Set<String>(); 
        for(ISSPServiceListView__c ServiceListViewItem : csServiceListViews){
            if(String.isNotBlank(ServiceListViewItem.Permission_set__c)) {
                for(String permisSetStr : ServiceListViewItem.Permission_set__c.split(';')) {
                    if(String.isNotBlank(permisSetStr))
                        permissionSetIDs.add(permisSetStr);
                }
            }
        }
        
        theProfilePermissionFilter = new ProfilePermissionFilter(); 
        thePermissionSetFilter = new PermissionSetFilter(permissionSetIDs);
    }
    //todo 
    private void initServiceListViewMap() {
        ListViewNameList = new list<string>();
        ServiceListViewMap = new map<string,ISSPServiceListView__c>();
        for(ISSPServiceListView__c ServiceListViewItem : csServiceListViews){
            
            Boolean resultPermission1 = true; 
            if(!theProfilePermissionFilter.isDataEmpty(ServiceListViewItem)){
                system.debug('not profile data empty');
                resultPermission1 = theProfilePermissionFilter.isUserPermittedFor(ServiceListViewItem);
            }
            else{
                system.debug('profile data empty');
            }
             
            Boolean resultPermission2 = true; 
            if(!thePermissionSetFilter.isDataEmpty(ServiceListViewItem)){
                system.debug('not permission data empty');
                resultPermission2 = thePermissionSetFilter.isUserPermittedFor(ServiceListViewItem);
            }
            else{
                system.debug('permission data empty');
            }
            //resultPermission1 && resultPermission2    
            if(true) {
                ServiceListViewMap.put(ServiceListViewItem.Name,ServiceListViewItem);
                ListViewNameList.add(ServiceListViewItem.Name);
            }
            
            system.debug('resultPermission1: ' + resultPermission1);
            system.debug('resultPermission2: ' + resultPermission2);
            
        }
        ListViewNameList.sort();
        if(ListViewNameList.size()>0)
            selectedList = ListViewNameList.get(0);
        string ListViewName = ApexPages.currentPage().getParameters().get('ListViewName');
        if( ListViewName!=null && ServiceListViewMap.containsKey(ListViewName))
            selectedList = ListViewName;
            
        system.debug('ServiceListViewMap start: ' + ServiceListViewMap);
        system.debug('selectedList start: ' + selectedList);
        /*
        if(String.isNotBlank(selectedList)){
            
        }
        */
    }
    
    public List<Schema.FieldSetMember> getFields() {
        system.debug('selectedList rrr1: ' + selectedList);
        system.debug('ServiceListViewMap.get(selectedList).Field_Set_API_Name__c rrr1: ' + ServiceListViewMap.get(selectedList).Field_Set_API_Name__c);
        system.debug('final rrr1: ' + sObjectType.Portal_Applications__c.FieldSets.getMap().get(ServiceListViewMap.get(selectedList).Field_Set_API_Name__c).getFields());
       return selectedList==null||selectedList==''?
            new list<Schema.FieldSetMember>():
            sObjectType.Portal_Applications__c.FieldSets.getMap().get(ServiceListViewMap.get(selectedList).Field_Set_API_Name__c).getFields();
    }
    
    public Pagereference refresh(){ 
        //system.debug('selectedList: ' + selectedList);
        /*
        if(String.isNotBlank(selectedList)){

        }
        */
        setCon = null;
        return null; 
    }
    public string getQueryConditions() {
        
        //string t =  selectedList==null||selectedList=='' ? '' : contactListViewMap.get(selectedList).SOQL_Filter__c;
        system.debug('ServiceListViewMap>>> ' + ServiceListViewMap);
        //String queryConditions =  String.isBlank(selectedList) ? '' : ServiceListViewMap.get(selectedList).SOQL_Filter__c;
        //if (selectedList == null) selectedList = '';
        if(ServiceListViewMap.isEmpty())
            return 'WHERE ID = NULL';
        
        system.debug('selectedList: ' + selectedList);
        String queryConditions;
        if(String.isNotBlank(selectedList)){
            queryConditions = ServiceListViewMap.get(selectedList).SOQL_Filter__c;
        }
            
        return String.isNotBlank(queryConditions) ? queryConditions : ''; 
    }
    
    ////////////////////////////////
    
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                string sortFullExp = '';
                if (sortExpression == 'Name')
                    sortFullExp = 'Name'  + ' ' + sortDirection;
                else
                    sortFullExp = sortExpression  + ' ' + sortDirection;
                system.debug('ORDERING BY: ' + sortExpression);
                system.debug('ORDERING LIKE: ' + sortDirection);
                size = 10;

                String query = ' CreatedDate, Application_URL__c, Cannot_be_managed_by_portal_admin__c, New_Window__c,ServiceName__c, Service_Description_Label__c, ANG_Restrict_by_Agency_Sector__c, ANG_Accredited_Agents_Only__c ';
                for(Schema.FieldSetMember f : this.getFields()) {
                    query +=  ', '+f.getFieldPath() ;
                }
                string queryString = '';

                queryString = 'select '+query+' from Portal_Applications__c '+getQueryConditions()+' order by '+ sortFullExp;

                ISSP_Utilities.log('SQL String: ' + queryString);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
    
    public class ServiceWrapper {
        public string Status {get; set;}
        public Boolean selected {get; set;}
        public Portal_Applications__c recordService {get; set;}
        public String btnLabel {get; set;}
        public Boolean isEasyPayService {get; set;}
        public String portalServiceRole {get; set;} 
        public boolean useDefaultRole {get; set;}
        public boolean addUsersEnable {get; set;}
        public boolean accountNotOpenError {get; set;}
        public String lineErrorMessage {get; set;}
        public String modalStyle {get; set;}

        public ServiceWrapper(Portal_Applications__c inRecord, String IepStatus, Boolean isAdmin, Boolean isAuthorisedSignatory){
            this.Status = getServiceStatus(inRecord);
            this.selected = false;
            this.recordService = inRecord;   
            this.isEasyPayService = ANG_ISSP_PortalServiceHelper.isIepPortalService(inRecord.name);
            this.lineErrorMessage = '';

            this.modalStyle = 'modal-dialog';

            if(this.isEasyPayService) {
                this.addUsersEnable = isAdmin;
                this.accountNotOpenError = (IepStatus != ANG_ISSP_PortalServiceHelper.STATUS_OPEN);
                if(this.accountNotOpenError) {
                    this.lineErrorMessage = System.Label.ANG_ISSP_IEP_add_users_to_account_not_open_error_msg;
                }
            } else {
                this.addUsersEnable = !inRecord.Cannot_be_managed_by_portal_admin__c;             
                this.accountNotOpenError = false;
            }

            Boolean flagIsIepPortalService = ANG_ISSP_PortalServiceHelper.isIepPortalService(inRecord.name);
                                        
            if (flagIsIepPortalService && (IepStatus == ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT || IepStatus == ANG_ISSP_PortalServiceHelper.STATUS_IN_PROGRESS) && isAdmin && isAuthorisedSignatory) {
                this.btnLabel = System.Label.ANG_ISSP_Open_IATA_EasyPay_Account;
                this.useDefaultRole = true;
            } else {
                this.useDefaultRole = false;
                if (flagIsIepPortalService && IepStatus == ANG_ISSP_PortalServiceHelper.STATUS_OPEN) {
                    this.btnLabel = System.Label.ANG_ISSP_Request_Access_IATA_EasyPay;
                    this.modalStyle = 'modal-dialog modal-lg';
                } else if (isRequestableWithoutApproval(isAdmin,inRecord)) {
                    this.btnLabel = System.Label.ISSP_Enable_Service;
                } else {
                    this.btnLabel = System.Label.ISSP_New_Service_Request;
                }
            }
        }

        public string getServiceStatus(Portal_Applications__c inService){
            
            List<Portal_Application_Right__c> appsGrantedList = new List<Portal_Application_Right__c>([Select p.Application_Name__c, p.PortalServiceTranslatedName__c ,p.Portal_Application__r.Description__c,
                                                                                                    p.Portal_Application__r.Requestable__c,
                                                                                                    p.Application_icon_del__c, p.Portal_Application__r.New_Window__c,
                                                                                                    p.Right__c, p.IsSCIMIFG__c, p.Portal_Application__r.Application_icon_URL__c,
                                                                                                    p.Portal_Application__r.Name, p.Portal_Application__c,
                                                                                                    p.My_Apps__c, p.Contact__c, p.Application_Start_URL__c,Technical_Provisioning_Status__c, //Mconde
                                                                                                    p.Case_creation_record_Type__c, p.Portal_Application__r.Service_Description__c, 
                                                                                                    p.Portal_Application__r.Service_Description_Label__c
                                                                                                   From Portal_Application_Right__c p 
                                                                                                   where p.Contact__c =: currentPortalUser.ContactId and 
                                                                                                         p.Portal_Application__c =: inService.Id and
                                                                                                        (p.Right__c = 'Access Granted'  or p.Right__c = 'Access Requested' or p.Right__c =: 'Access denied') and
                                                                                                         p.Portal_Application__r.Hide_on_Homepage__c = false ]);   
            if(appsGrantedList != null && appsGrantedList.size() > 0){
                //MConde
                if(appsGrantedList[0].Right__c != null && appsGrantedList[0].Technical_Provisioning_Status__c != null) {

                    if(appsGrantedList[0].Right__c.equals('Access Granted') && appsGrantedList[0].Technical_Provisioning_Status__c.equals('IATA Access Granted') && appsGrantedList[0].IsSCIMIFG__c == true){
                        return 'Access Under Provisioning';
                    }

                }
                return appsGrantedList[0].Right__c;
            }else{
                return null ;
            }
        }
    }

     
    
    public List<ServiceWrapper > getServiceList(){
        hasPremiumTD = false;
        List<ServiceWrapper > allServiceList =  new List<ServiceWrapper>();   
        List<Portal_Applications__c > allServices = (List<Portal_Applications__c >)setCon.getRecords();

        for (Portal_Applications__c thisService : allServices){
            ServiceWrapper thisServiceRecord = new ServiceWrapper (thisService, IepStatus, isAdmin, isAuthorisedSignatory);
            allServiceList.add(thisServiceRecord);
        }
        
        //TF
        //system.debug(LoggingLevel.ERROR, '--CON ID: ' + conId);
        List <Portal_Application_Right__c> appRightList = [SELECT Id, Portal_Application__c,
                                                        Portal_Application__r.Name,
                                                        Portal_Application__r.ServiceName__c,   
                                                        Portal_Application__r.Service_Description__c,
                                                        Portal_Application__r.Service_Description_Label__c
                                                        FROM Portal_Application_Right__c
                                                        WHERE Contact__c = :conId
                                                        AND Right__c = 'Access Granted'];


        if (!appRightList.isEmpty()){
            Set<Id> appIds = new Set<Id>();
            Set<Id> newAppIds = new Set<Id>();
            for (Portal_Applications__c thisApp : allServices){
                if (!appIds.contains(thisApp.Id)){
                    system.debug('ADDING: ' + thisApp.Name);
                    appIds.add(thisApp.Id);
                }
            }
            for (Portal_Application_Right__c thisAppRight : appRightList){
                system.debug('THIS APP: ' + thisAppRight.Portal_Application__r.Name);
                if (thisAppRight.Portal_Application__r.Name == 'Treasury Dashboard - Premium'){
                    hasPremiumTD = true;
                    system.debug('HAS PREMIUM');
                }
                if (!appIds.contains(thisAppRight.Portal_Application__c)){
                    system.debug('ADDING SECOND: ' + thisAppRight.Portal_Application__r.Name);
                    newAppIds.add(thisAppRight.Portal_Application__c);
                }
            }
            if (!newAppIds.isEmpty()){
                List <Portal_Applications__c> appList = [SELECT Id, Name, Agency__c,
                                                        Aplication_Start_Icon__c, Application_icon__c,
                                                        Application_icon_URL__c, Application_URL__c,
                                                        Case_creation_record_type__c, Confirm_Box__c,
                                                        Confirm_Text__c, Description__c,
                                                        GSSA__c, Hide_on_Homepage__c,
                                                        ICH_Airline__c, New_Window__c,ServiceName__c,
                                                        Not_ICH_Airline__c, Record_type_for_App_Rigth__c,
                                                        Requestable__c, Restricted_App__c, Visible__c,
                                                        Service_Description__c, Cannot_be_managed_by_portal_admin__c,
                                                        Service_Description_Label__c, 
                                                        ANG_Restrict_by_Agency_Sector__c, ANG_Accredited_Agents_Only__c                                                
                                                        FROM Portal_Applications__c WHERE Id IN :newAppIds];
                if (!appList.isEmpty()){
                    for (Portal_Applications__c thisApp : appList){
                        system.debug('FOUND: ' + thisApp.Name);
                        if (!appIds.contains(thisApp.Id)){
                            system.debug('ADDING FINAL: ' + thisApp.Name);
                            ServiceWrapper thisServiceRecord = new ServiceWrapper (thisApp, IepStatus, isAdmin, isAuthorisedSignatory);
                            allServiceList.add(thisServiceRecord);
                        }
                    }
                }
            }
        }

        system.debug('hasPremiumTD: ' + hasPremiumTD);
        if (hasPremiumTD){
            integer i = 0;
            integer j = -1;
            for (ServiceWrapper thisService : allServiceList){
                if (thisService.recordService.Name == 'Treasury Dashboard' || thisService.recordService.Name == 'Treasury Dashboard - Basic'){
                    j = i;
                }
                i++;
            }
            if (j > -1){
                system.debug('removing service');
                allServiceList.remove(j);
            }
        }

        noOfRecords = allServiceList.size();

        return allServiceList;
    }
     
    public List<Portal_Applications__c > getServices(){
        return (List<Portal_Applications__c >)setCon.getRecords();
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
            ISSPServiceListView__c ServiceListViewItem = (ISSPServiceListView__c)oneData;
            list<String> profileIds = ServiceListViewItem.Profiles_Id__c.split(';');
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
            ISSPServiceListView__c ServiceListViewItem = (ISSPServiceListView__c)oneData;
            return String.isBlank(ServiceListViewItem.Profiles_Id__c);
            //Set<string> profilesIdSet = new Set<string>(ServiceListViewItem.Profiles_Id__c.split(';'));
            //return profilesIdSet.contains(profileId15);
        }
        
    }
    
    public class  PermissionSetFilter implements IPermissionFilter {
        private Set<String> permissionSetForUserSet; 
        public PermissionSetFilter(set<String> permissionSetIDs) {
            permissionSetForUserSet = getPermissionSetForUserSet(permissionSetIDs, UserInfo.getUserId()); 
        }
        
        public Boolean isDataEmpty(object oneData) {
            ISSPServiceListView__c ServiceListViewItem = (ISSPServiceListView__c)oneData;
            return String.isBlank(ServiceListViewItem.Permission_set__c);
        }

        public Boolean isUserPermittedFor(object oneData) {
            Boolean isUserPermitted = false;
            ISSPServiceListView__c ServiceListViewItem = (ISSPServiceListView__c)oneData;
            list<String> permissionSetIds = ServiceListViewItem.Permission_set__c.split(';');
            for(String permisSetId : permissionSetIds) {
                if(permissionSetForUserSet.contains(permisSetId)) {
                    return true; 
                }
            }
            return false;
        }
    }
    
    public PageReference doRequest() {

        system.debug('XXX START doRequest : ');
        String Servid = Apexpages.currentPage().getParameters().get('servId');
        system.debug('XXX Servid : '+Servid);

        List<Portal_Applications__c> Servicetmp_List = new List<Portal_Applications__c>([select id ,Application_icon__c , Application_URL__c, Confirm_Box__c, Confirm_Text__c, Description__c,Name, ServiceName__c,Cannot_be_managed_by_portal_admin__c from Portal_Applications__c where Id =: Servid ]);
        system.debug('XXX Servicetmp_List : '+Servicetmp_List);
        Serv = new ServiceWrapper (Servicetmp_List[0], IepStatus, isAdmin, isAuthorisedSignatory);

        List<UserProvisioningRequest> uprFailed = [Select id From UserProvisioningRequest where SalesforceUserId =: currentPortalUser.id And State = 'Failed'];

        this.failedCount = uprFailed.size();

        this.pollerOn = (Serv.recordService.Name.startsWith('IATA EasyPay') && Serv.useDefaultRole && !isModalErrorMessageEnable);

        system.debug('XXX Serv : '+Serv);

        //since you have the serv available ...

        availablePortalServiceRoles = null;

        return null ;
    }

    public Void submitRequest(){
        errorMessage.clear();

        if(!accept){
            errorMessage.add('Please accept the Terms & Conditions');
        }
       
    }

    @RemoteAction
    public static string newAppsRequest (string applicationId, string applicationName, string contactId){
        String res = 'ok';

        String appRight = 'Access Requested';
        String appRole = ''; 
        if(applicationName=='Standards Setting Workspace')
            appRight = 'Access Granted';
            
		// We'll ensure in the ISSP_AvailableServices pages that this method is called when ICCS membership is not Member
		// What about the Suspended and Withdrawn statuses?
        if(applicationName == ISSP_ICCS_Utils.ICCS_PORTAL_APPLICATION_NAME){
            appRight = 'Access Granted';
	        appRole = ISSP_ICCS_Utils.ICCS_ROLE_REGISTRATION;
        }

		Boolean isAdmin = isPortalAdminUser();
        Portal_Applications__c parentApp = [SELECT Id, Cannot_be_managed_by_portal_admin__c FROM Portal_Applications__c WHERE Id=:applicationId];
        if(isRequestableWithoutApproval(isAdmin,parentApp)) {
            appRight = 'Access Granted';
            res = 'okauto';
        }
                    
        Portal_Application_Right__c app =  new Portal_Application_Right__c(Contact__c = contactId,Portal_Application__c = applicationId,Right__c = appRight, ANG_Portal_Service_Role__c = appRole);
        insert app;
        submitApprovalProcess(app.id);
        return res;
    }
    
    public String iccsPortalApplicationName {get{return ISSP_ICCS_Utils.ICCS_PORTAL_APPLICATION_NAME;}}
    
    @RemoteAction    
    public static string newAppsRequest2 (string applicationId, string applicationName, string contactId, String portalServiceRole, Boolean flagUseDefaultRole, String defaultPortalUserRole) {
        String res = 'ok';

        String appRight = 'Access Requested';
        if(applicationName=='Standards Setting Workspace')
            appRight = 'Access Granted';


        Boolean isAdmin = isPortalAdminUser();
        Portal_Applications__c parentApp = [SELECT Id, Cannot_be_managed_by_portal_admin__c FROM Portal_Applications__c WHERE Id=:applicationId];
        if(isRequestableWithoutApproval(isAdmin,parentApp)) {
            appRight = 'Access Granted';
            res = 'okauto';
        }

        Portal_Application_Right__c app = new Portal_Application_Right__c(Contact__c = contactId,Portal_Application__c = applicationId,Right__c = appRight);

        if (portalServiceRole != '' || flagUseDefaultRole) {
            if (flagUseDefaultRole) {
                app.ANG_Portal_Service_Role__c = defaultPortalUserRole;                    
            } else {
                app.ANG_Portal_Service_Role__c = portalServiceRole;                    
            }
        }
        System.debug('-->Insert');
        insert app;

		if(applicationName == ISSP_ICCS_Utils.ICCS_PORTAL_APPLICATION_NAME){
        	System.debug('sending notification');
			Portal_Application_Right__c appForNotification = [select Id, Top_Account__c, Contact__r.FirstName, Contact__r.LastName, ANG_Portal_Service_Role__c from Portal_Application_Right__c where id =: app.Id];
			ISSP_ICCS_Utils.requestRole(appForNotification, portalServiceRole, true);
        }

        submitApprovalProcess(app.id);

        return res;             
    }
    
    public static void submitApprovalProcess(Id objectId){
        try {
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(objectId);
            req1.setSubmitterId(UserInfo.getUserId());
            Approval.ProcessResult result = Approval.process(req1);
            System.debug('SUCESS, approval process submitted ' + result);

        } catch (Exception e) {
            System.debug('ERROR Approval Process: ' + e.getMessage());
        }
    }

    public PageReference setPollerOff() {
        this.pollerOn = false;
        return null;
    }

    public PageReference iepPermissionSetPoller() {

        String permSetSSO = this.iepRoles.get(this.Serv.recordService.Name + ' - ' + this.defaultPortalUserRole);

        List<PermissionSetAssignment> l = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSetId in (select id from PermissionSet Where name =: permSetSSO)];

        if(l.size() != 0) {
            this.pollerOn = false;
            this.redirect = true;
        } else {

            List<UserProvisioningRequest> l2 = [Select id From UserProvisioningRequest where SalesforceUserId =: currentPortalUser.id And State = 'Failed'];

            if(l2.size() != this.failedCount) {
                this.provError = true;
            }            
        }                
        return null;
    }

    /**
        Returns true if the service can be requested and granted without any approval
        To have this the requester must be an admin user and the app service must have
        Cannot_be_managed_by_portal_admin__c = false
    **/
    private static Boolean isRequestableWithoutApproval(Boolean isAdmin, Portal_Applications__c app) {
        return isAdmin && app!=null && app.Cannot_be_managed_by_portal_admin__c == false;
    }
    
    /**
        Returns true if current user is a Portal Admin
    **/
    public static Boolean isPortalAdminUser() {
        return ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId());
    }
}