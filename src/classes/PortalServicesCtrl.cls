public with sharing class PortalServicesCtrl {


Public static final String PORTAL_ACCESS_GRANTED='Access Granted';
Public static final String PORTAL_ACCESS_REQUESTED='Access Requested';
Public static final String PORTAL_ACCESS_DENIED='Access Denied';
Public static final String PORTAL_USER_PENDING_APPR='Pending Approval';
Public static final String PORTAL_USER_APPROVED='Approved User';
Public static final String PORTAL_ADMIN_APPROVED='Approved Admin';
Public static final String WILDCARD = 'ALL';

	/*
		This method is used for CS Portal searchbar.
		@refinedSearchSerialized - is a serialized filter object sent from the LWC controller for further filtering
	*/
	@AuraEnabled (cacheable=true)
	public static List<Portal_Application_Right__c> getUserServicesList(String refinedSearchSerialized){
		User userAux = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

	Contact con = [Select id, account.Sector__c, contact.account.Category__c from Contact where id =:contactId];

	List<Portal_Applications__c> externalLinksList = new List<Portal_Applications__c>();
	List<Portal_Applications__c> portalApplicationList = new List<Portal_Applications__c>();

	string queryFields = 'Name, Description__c, Service_Description__c, Service_Description_Label__c, Visible__c, ' +
	                     'Requestable__c, Application_icon__c, Application_URL__c, New_Window__c, VisibleCNS__c, ' +
	                     'ANG_Flag_Restrict_Accredited_Agent__c, ANG_Flag_Restrict_Sector__c';

	string query = 'SELECT '  + queryFields +
	               ' FROM Portal_Applications__c' +
	               ' WHERE Visible__c = true' +
	               ' AND Requestable__c = false' +
	               ' AND ANG_Flag_Restrict_by_Agency_Category__c = true' +
	               ' AND ANG_Accre_Tp__c = true';

	portalApplicationList = Database.query(query);

	// Second search based in Custom Metadata for all those remaining apps
	List<String> requestableAppNameList = getVisibleApplicationNames(con.Account);
	query = 'SELECT ' + queryFields +
	        ' FROM Portal_Applications__c' +
	        ' WHERE Id NOT IN :portalApplicationList' +
	        ' AND Requestable__c = false' +
	        ' AND Name IN :requestableAppNameList';

	List<Portal_Applications__c> requestableAppList = Database.query(query);
	// combine first and second search of apps
	portalApplicationList.addAll(requestableAppList);

	for (Portal_Applications__c pApp: portalApplicationList) {
		if (pApp.Name == 'Insurance Providers') {
			if (((con.Account.Sector__c == 'Travel Agent' || con.Account.Sector__c == 'Cargo Agent')
			     && con.Account.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency')) &&
			    (con.Account.Is_Branch_Abroad__c == 'Yes') &&
			    (AMS_Utils.ACTIVEAGENCYSTATUS.contains(con.Account.Status__c) || con.Account.Status__c == AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING) &&
			    (con.Financial_Assessment_Contact__c || con.User_Portal_Status__c == 'Approved Admin')) {
				externalLinksList.add(pApp);
			}
		} else if (pApp.ANG_Flag_Restrict_Accredited_Agent__c && pApp.ANG_Flag_Restrict_Sector__c) {
			externalLinksList.add(pApp);
		}
	}

		return externalLinksList;
	}

	/*
		This method is used for CS Portal searchbar.
		@refinedSearchSerialized - is a serialized filter object sent from the LWC controller for further filtering
	*/
	@AuraEnabled (cacheable=true)
	public static List<Portal_Application_Right__c> getUsersFavoriteServicesList(String contactId){
		
		//base query
		String finalQuery = 'SELECT Id, Application_Name__c, PortalServiceTranslatedName__c ,Portal_Application__r.Description__c, '+
								'Portal_Application__r.Requestable__c, Application_icon_del__c, IsSCIMIFG__c, ' +
								'Portal_Application__r.New_Window__c, Right__c, Portal_Application__r.Application_icon_URL__c, ' +
								'Portal_Application__r.Name, Portal_Application__c, My_Apps__c, Contact__c, ' +
								'Application_Start_URL__c,Technical_Provisioning_Status__c, Case_creation_record_Type__c, ' +
								'Portal_Application__r.Service_Description__c, Portal_Application__r.Service_Description_Label__c ' +
							'FROM Portal_Application_Right__c ' +
							'WHERE (Contact__c = \'' + contactId + '\' AND '+
							'   Right__c = \'Access Granted\' AND ' +
							'   Portal_Application__r.Hide_on_Homepage__c = false)';


		finalQuery += ' ORDER BY Last_Visit_Date__c DESC NULLS LAST, Portal_Application__r.New_Window__c ASC, Portal_Application__r.Name ASC LIMIT 15';

		List<Portal_Application_Right__c> appsGrantedList = Database.query(finalQuery);

		return appsGrantedList;
	}

	@AuraEnabled (cacheable=true)
	public static List<Portal_Application_Right__c> getFavoriteServicesList(){
		User userAux = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

		String contactId = userAux.ContactId;

		List<Portal_Application_Right__c> lstPortalApplicationsRights = getUsersFavoriteServicesList(contactId);
		
		List<Portal_Applications__c> lstPortalApplications =  getNonRequestableServicesList(contactId);
		
		if(!lstPortalApplications.isEmpty()) {
			for(Portal_Applications__c pa : lstPortalApplications) {
				Portal_Application_Right__c par = new Portal_Application_Right__c();
				par.Portal_Application__r = pa;
				lstPortalApplicationsRights.add(par);
			}
		}

		return lstPortalApplicationsRights;
	}

	/*
	* Method used to retrieve the old link when redirecting the users to the old Portals
	*/
	@AuraEnabled
	public static String goToOldPortalService(String myurl){
		return OneIdUtils.getCommunityRedirection (OneIdUtils.Mode.ISSP, myurl);
	}

private static Map<String,ISSPServiceListView__c> getMapSrevicesListViews() {
	//get all values from custom settings object
	List<ISSPServiceListView__c> csServiceListViews = ISSPServiceListView__c.getAll().values();

		ISSP_PermissionFilterFactory.PermissionSetFilter thePermissionSetFilter = ISSP_PermissionFilterFactory.createPermissionSetFilter(csServiceListViews, 'Permission_set__c');
     	ISSP_PermissionFilterFactory.ProfilePermissionFilter theProfilePermissionFilter = ISSP_PermissionFilterFactory.createProfilePermissionFilter();


		Map<String,ISSPServiceListView__c> mapFilteredListViews = new Map<String,ISSPServiceListView__c>();
        for(ISSPServiceListView__c serviceListViewItem : csServiceListViews){
            
			//view if user have permissions from profile
            Boolean resultPermission1 = true;
            if(!theProfilePermissionFilter.isDataEmpty(serviceListViewItem, 'Profiles_Id__c')){
                resultPermission1 = theProfilePermissionFilter.isUserPermittedFor(serviceListViewItem, 'Profiles_Id__c');
            }
            
			//view if user have permissions from permission set
            Boolean resultPermission2 = true; 
            if(!thePermissionSetFilter.isDataEmpty(serviceListViewItem, 'Permission_set__c')){
                resultPermission2 = thePermissionSetFilter.isUserPermittedFor(serviceListViewItem, 'Permission_set__c');
            }

			//combine both and add to map
            if(resultPermission1 && resultPermission2) {
                mapFilteredListViews.put(serviceListViewItem.Name,serviceListViewItem);
            }
            
        }

		return mapFilteredListViews;
    }

	private static String getFieldsFromSelectedView(ISSPServiceListView__c selectedView){
		String fieldsStr = '';

		if(selectedView.Field_Set_API_Name__c != null && selectedView.Field_Set_API_Name__c != ''){

			List<Schema.FieldSetMember> fieldSet = sObjectType.Portal_Applications__c.FieldSets.getMap().get(selectedView.Field_Set_API_Name__c).getFields();

			if(fieldSet != null && !fieldSet.isEmpty()){
				for(Schema.FieldSetMember fieldAux : fieldSet) {
					fieldsStr +=  ', '+fieldAux.getFieldPath() ;
				}
			}

		}
		return fieldsStr;
	}

	private static String getConditionFromSelectedView(ISSPServiceListView__c selectedView){
		String conditionStr = '';

		if(selectedView.SOQL_Filter__c != null && selectedView.SOQL_Filter__c != ''){

			conditionStr = selectedView.SOQL_Filter__c;

		}
		return conditionStr;
	}

	private static List<Portal_Applications__c> getPortalApplications(){
		//get user available list views 
		Map<String,ISSPServiceListView__c> mapServiceListViews = PortalServicesCtrl.getMapSrevicesListViews();

		//Select "Available services" entry for this method
		ISSPServiceListView__c selectedView = mapServiceListViews.get('Available services');
		
		if(selectedView == null){
			//user cannot view portal applications, return empty list
			return new List<Portal_Applications__c>();
		}

		//construct query
		String fieldsStr = PortalServicesCtrl.getFieldsFromSelectedView(selectedView);
		String conditionStr = PortalServicesCtrl.getConditionFromSelectedView(selectedView);

		String extraQueryFields = ' CreatedDate, Application_URL__c, Cannot_be_managed_by_portal_admin__c, New_Window__c,ServiceName__c, Service_Description_Label__c, ANG_Restrict_by_Agency_Sector__c, ANG_Accredited_Agents_Only__c, Application_icon_URL__c';
		String finalQuery = 'SELECT '+ extraQueryFields + fieldsStr+ ' FROM Portal_Applications__c ' + conditionStr + ' ORDER BY Name ASC ';

		System.debug('getPortalApplications finalQuery : ' + finalQuery);
		System.debug(Database.query(finalQuery));

		return Database.query(finalQuery);

	}


	/*
		This method is used in services pages
	*/
	@AuraEnabled
	public static List<ServiceWrapper> getAllServices(){
		User userAux = [SELECT Id, ContactId, Contact.Account.ANG_IEP_Status_FF__c FROM User WHERE Id = :UserInfo.getUserId()];
		String contactId = userAux.ContactId;
		String iepStatus = userAux.Contact.Account.ANG_IEP_Status_FF__c;

		Boolean isAdmin = PortalServicesCtrl.isPortalAdminUser();

		Contact contAcc = AMS_Utils.getIEPContact(contactId);

		Boolean isAuthorisedSignatory = (isAdmin && contAcc.Authorized_Signatory__c); 

		//if the user have premium dashboard than this changes to true
		Boolean hasPremiumTD = false;


		List<String> lstPortalApplicationRightStatus = new List<String>{PortalServicesCtrl.PORTAL_ACCESS_GRANTED, PortalServicesCtrl.PORTAL_ACCESS_REQUESTED, PortalServicesCtrl.PORTAL_ACCESS_DENIED};

		//get portal applications for this user by enforcing custom setting for services list view
		List<Portal_Applications__c> lstPortalApplications = PortalServicesCtrl.getPortalApplications();

		//iterate over the returned portal apps and create a map of services
		Map<String,ServiceWrapper> mapServiceWrapper = new Map<String,ServiceWrapper>();
		for(Portal_Applications__c portalAppAux : lstPortalApplications){
			mapServiceWrapper.put(portalAppAux.Id, new ServiceWrapper(portalAppAux, isAdmin, iepStatus, isAuthorisedSignatory, ''));
		}

		//get the portal application rights for this user
		PortalApplicationRight_Sel portalApplicationRightSelector = new PortalApplicationRight_Sel();
		List<Portal_Application_Right__c> userGrantedList = portalApplicationRightSelector.getPortalApplicationRightsByContactIdAndRightsList(contactId, lstPortalApplicationRightStatus);

		//Defining a set of services that the user have access or requested to have access but was not retrieved by the first query 
		Set<String> appsAlreadyWithAccessIds = new Set<String>();

		for(Portal_Application_Right__c accessAux : userGrantedList){

			//check if the user have access to treasury dashboard premium 
			if(accessAux.Portal_Application__r.Name == 'Treasury Dashboard - Premium'){
				hasPremiumTD = true;
			}

			if(mapServiceWrapper.containsKey(accessAux.Portal_Application__c)){
				String statusAux = accessAux.Right__c;

				if(accessAux.Right__c != null && accessAux.Technical_Provisioning_Status__c != null && 
					accessAux.Right__c.equals(PortalServicesCtrl.PORTAL_ACCESS_GRANTED) && accessAux.Technical_Provisioning_Status__c.equals('IATA Access Granted') && accessAux.IsSCIMIFG__c == true) {
						statusAux = 'Access Under Provisioning';
				}
				
				alignStatus(mapServiceWrapper.get(accessAux.Portal_Application__c),statusAux);
			}else{
				appsAlreadyWithAccessIds.add(accessAux.Portal_Application__c);
			}
		}


		//now get the services based on the previous set
		PortalApplications_Sel portalApplicationsSelector = new PortalApplications_Sel();
		Map<String,Portal_Applications__c> mapAppsAlreadyWithAccess = 
				new Map<String,Portal_Applications__c>(portalApplicationsSelector.getPortalApplicationsByApplicationsList(appsAlreadyWithAccessIds));

		for(Portal_Application_Right__c accessAux : userGrantedList){
		
			//if the map of services does not contains this service yet, then add it
			if(!mapServiceWrapper.containsKey(accessAux.Portal_Application__c)){
				mapServiceWrapper.put(accessAux.Portal_Application__c, 
						new ServiceWrapper(mapAppsAlreadyWithAccess.get(accessAux.Portal_Application__c), isAdmin, iepStatus, isAuthorisedSignatory, accessAux.Right__c));
			}
		}

		//if the user have access to treasure dashboard premium then try to remove the other treasures
		if (hasPremiumTD){
            String treasureDashboardId = '';
            for (ServiceWrapper thisService : mapServiceWrapper.values()){
                if (thisService.recordService.Name == 'Treasury Dashboard' || thisService.recordService.Name == 'Treasury Dashboard - Basic'){
                    treasureDashboardId = thisService.recordService.Id;
                }
            }
            if (treasureDashboardId != ''){
                mapServiceWrapper.remove(treasureDashboardId);
            }
        }
		return mapServiceWrapper.values();
	}

	@AuraEnabled(cacheable=true)
	public static List<ServiceWrapper> getUserAvailableServices(){

		List<ServiceWrapper> lstAllServices = PortalServicesCtrl.getAllServices();

		List<ServiceWrapper> lstToReturn = new List<ServiceWrapper>();
		for(ServiceWrapper serviceWrapperAux : lstAllServices){
			if(serviceWrapperAux.status == ''){
				lstToReturn.add(serviceWrapperAux);
			}
		}

		return lstToReturn;
	}

	@AuraEnabled
	public static List<ServiceWrapper> getUserAccessRequestedServices(){

		List<ServiceWrapper> lstAllServices = PortalServicesCtrl.getAllServices();

		List<ServiceWrapper> lstToReturn = new List<ServiceWrapper>();
		for(ServiceWrapper serviceWrapperAux : lstAllServices){
			if(serviceWrapperAux.status == PortalServicesCtrl.PORTAL_ACCESS_REQUESTED){
				lstToReturn.add(serviceWrapperAux);
			}
		}

		return lstToReturn;
	}

	@AuraEnabled
	public static List<ServiceWrapper> getUserAccessGrantedServices(){

		List<ServiceWrapper> lstAllServices = PortalServicesCtrl.getAllServices();

		List<ServiceWrapper> lstToReturn = new List<ServiceWrapper>();
		for(ServiceWrapper serviceWrapperAux : lstAllServices){
			if(serviceWrapperAux.status == PortalServicesCtrl.PORTAL_ACCESS_GRANTED){
				lstToReturn.add(serviceWrapperAux);
			}
		}

		return lstToReturn;
	}

public static Integer RESULTS_PER_PAGE = 10;

/*
        This method is used for CS Portal searchbar.
        @refinedSearchSerialized - is a serialized filter object sent from the LWC controller for further filtering
 */
@AuraEnabled (cacheable=true)
public static PagedResult getUserFilteredServices(String searchKey, String requestedPage){

	PortalSearchFilterWrapper filtersWrapper = (PortalSearchFilterWrapper) JSON.deserialize(searchKey, PortalSearchFilterWrapper.class);

	Integer requestedPageAux = integer.valueof(requestedPage);

	//request all services
	//yes, it is requesting all services and then filter locally instead of inside the query...
	//this is to enforce all the protection around the services and since the user cannot have millions of
	//services it won't be a big deal to do this way
	List<ServiceWrapper> lstAllServices = PortalServicesCtrl.getAllServices();

	List<Portal_Applications__c> lstFiltered = new List<Portal_Applications__c>();

	for(ServiceWrapper serviceAux : lstAllServices) {
		//filter the service name
		if(filtersWrapper.searchText != null && filtersWrapper.searchText != '' && serviceAux.recordService.ServiceName__c.contains(filtersWrapper.searchText)) {
			lstFiltered.add(serviceAux.recordService);
		}

	}

	List<Portal_Applications__c> lstToReturn = new List<Portal_Applications__c>();
	Integer offset = requestedPageAux * PortalServicesCtrl.RESULTS_PER_PAGE;
	for(Integer i = offset; i < offset+RESULTS_PER_PAGE && i < lstFiltered.size(); i++) {
		lstToReturn.add(lstFiltered.get(i));
	}

	PagedResult result = new PagedResult();
	result.records = lstToReturn;
	result.totalItemCount = lstToReturn.size();

	return result;
}

public class PagedResult {
@AuraEnabled
public Integer totalItemCount { get; set; }
@AuraEnabled
public SObject[] records { get; set; }
@AuraEnabled
public Boolean userAdmin { get; set; }
@AuraEnabled
public String url { get; set; }
}

@AuraEnabled (cacheable=true)
public static ServiceWrapper getServiceDetails(string serviceId){

	List<ServiceWrapper> lstAllServices = PortalServicesCtrl.getAllServices();

		//PortalApplicationRight_Sel portalApplicationRightSelector = new PortalApplicationRight_Sel();
		//List<Portal_Application_Right__c> userGrantedList = portalApplicationRightSelector.getPortalApplicationRightsByPortalService(serviceId);

		ServiceWrapper temp=null;
		integer c=0;
		for(ServiceWrapper serviceWrapperAux : lstAllServices){
			if(serviceWrapperAux.recordService.id == serviceId){

				if(serviceWrapperAux.addUsersEnable) serviceWrapperAux.contactList= PortalServicesCtrl.getContactsAndStatusRelatedToServiceList(serviceId);
				temp= serviceWrapperAux;
				c++;
			}
		}
		return temp;
	}

	public static List<ContactWrapper> getContactsAndStatusRelatedToServiceList(string serviceId) {

        List<ContactWrapper> appsGrantedList = new List<ContactWrapper>();
	
        List<Portal_Application_Right__c> auxServicesList= new PortalApplicationRight_Sel().getPortalApplicationRightsByPortalService(serviceId);
     
        
        Set<String> contactIds = new Set<String>();
        for (Portal_Application_Right__c par : auxServicesList) {
            contactIds.add(par.contact__c);
        }

        List<User> userList = [SELECT Id, IsActive, ContactId FROM User WHERE ContactId IN :contactIds];

        Map<String, String> userContact = new Map<String, String>();
        for(User u : userList) {
            userContact.put(u.contactId, u.id);
        }        

        boolean isEasyPay = false;
        if(!auxServicesList.isEmpty()) {
            isEasyPay = auxServicesList[0].Application_Name__c.startsWith('IATA EasyPay');
        }        

        for(Portal_Application_Right__c par : auxServicesList) {
            ContactWrapper sw = new ContactWrapper();
            sw.par = par;             

            String contactStatus = par.Contact__r.User_Portal_Status__c;

            sw.cannotBeManagedByPortalAdmin = par.Portal_Application__r.Cannot_be_managed_by_portal_admin__c;
            sw.isEasyPayService = ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c);
        
            sw.hide = ((sw.isEasyPayService && !sw.cannotBeManagedByPortalAdmin) ||
                       (sw.isEasyPayService && sw.cannotBeManagedByPortalAdmin && par.right__c != PortalServicesCtrl.PORTAL_ACCESS_GRANTED) ||
                       (!sw.isEasyPayService && sw.cannotBeManagedByPortalAdmin)
                      );

            if (contactStatus == 'Pending Approval') {
                sw.contactStatus = 'PA';
            } else if (contactStatus == 'Inactive' || contactStatus == 'Rejected' || contactStatus == 'Deactivated') {
                sw.contactStatus = 'IN';
            } else if (!userContact.containsKey(par.Contact__c)) {
                sw.contactStatus = 'NO';
            }

            sw.showGrant = false;
            sw.showDeny = false;
            sw.showIfap = false;

            if(sw.isEasyPayService) {
                if(sw.cannotBeManagedByPortalAdmin && par.right__c == PortalServicesCtrl.PORTAL_ACCESS_GRANTED) {
                    sw.showDeny = true;
                }
            } else {
                if(!sw.cannotBeManagedByPortalAdmin) {                
                    if(par.Application_Name__c == 'IFAP') {
                        sw.showIfap = true;
                        if(par.right__c == PortalServicesCtrl.PORTAL_ACCESS_REQUESTED) {
                            sw.showDeny = true;
                        }
                    } else if(par.right__c == PortalServicesCtrl.PORTAL_ACCESS_DENIED) {
                        sw.showGrant = true;
                    } else  if(par.right__c == PortalServicesCtrl.PORTAL_ACCESS_REQUESTED) {
                        sw.showGrant = true;
                        sw.showDeny = true;
                    } else {
                        sw.showDeny = true;
                    }
                }
            }

            appsGrantedList.add(sw);
        }

        return appsGrantedList;
    }

    public class ContactWrapper {
        @AuraEnabled 
		public Portal_Application_Right__c par {get; set;}
        @AuraEnabled 
		public String contactStatus {get; set;}
        @AuraEnabled 
		public Boolean cannotBeManagedByPortalAdmin {get; set;}
        @AuraEnabled 
		public Boolean isEasyPayService {get; set;}
        @AuraEnabled 
		public boolean hide {get; set;}
        @AuraEnabled 
		public boolean showGrant {get; set;}
        @AuraEnabled 
		public boolean showDeny {get; set;}
        @AuraEnabled 
		public boolean showIfap {get; set;}        
    }



	public class ServiceWrapper {
		@AuraEnabled
        public string status {get; set;}
		@AuraEnabled
        public Portal_Applications__c recordService {get; set;}
		@AuraEnabled
        public String btnLabel {get; set;}
		@AuraEnabled
        public Boolean isEasyPayService {get; set;}
		@AuraEnabled
        public String portalServiceRole {get; set;}
		@AuraEnabled
        public boolean useDefaultRole {get; set;}
		@AuraEnabled
        public boolean isAdmin {get; set;}
		@AuraEnabled
        public boolean addUsersEnable {get; set;}
		@AuraEnabled
        public boolean accountNotOpenError {get; set;}
		@AuraEnabled
        public boolean accessGranted {get; set;}
		@AuraEnabled
        public boolean accessRequested {get; set;}
		@AuraEnabled
        public List<ContactWrapper> contactList {get; set;}
        private string iepStatus {get; set;}
        private boolean isAuthorisedSignatory {get; set;}
		
		

        public ServiceWrapper(Portal_Applications__c recordService, Boolean isAdmin, String iepStatus, Boolean isAuthorisedSignatory, String status){
            this.recordService = recordService;
            this.isEasyPayService = ANG_ISSP_PortalServiceHelper.isIepPortalService(recordService.name);
			this.status = status;
			this.isAdmin=isAdmin;
			this.iepStatus=iepStatus;
			this.isAuthorisedSignatory=isAuthorisedSignatory;
            if(this.isEasyPayService) {
                this.addUsersEnable = isAdmin;
                this.accountNotOpenError = (iepStatus != ANG_ISSP_PortalServiceHelper.STATUS_OPEN);
            } else {
             //   this.addUsersEnable = !recordService.Cannot_be_managed_by_portal_admin__c;             
                this.addUsersEnable =  isAdmin;             
                this.accountNotOpenError = false;
            }

            alignStatus(this,status);
        }

    }

	/**
        Returns true if current user is a Portal Admin
    **/
    private static Boolean isPortalAdminUser() {
        return ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId());
    }
	/**
        Returns true if the service can be requested and granted without any approval
        To have this the requester must be an admin user and the app service must have
        Cannot_be_managed_by_portal_admin__c = false
    **/
    private static Boolean isRequestableWithoutApproval(Boolean isAdmin, Portal_Applications__c app) {
        return isAdmin && app!=null && app.Cannot_be_managed_by_portal_admin__c == false;
    }
    

	@AuraEnabled
    public static void requestAccess(string applicationId){
		User userAux = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];

		//invokes request method, ignoring visibility 
		ISSP_AvailableServices.newAppsRequest(applicationId,'',userAux.ContactId);
    }

	private static void alignStatus(ServiceWrapper sw,string newStatus){
		//keeps assist variables consistent with the portal status
		sw.status=newStatus;
		Boolean flagIsIepPortalService = ANG_ISSP_PortalServiceHelper.isIepPortalService(sw.recordService.name);


			if(sw.status==PortalServicesCtrl.PORTAL_ACCESS_GRANTED ){
				sw.btnLabel =System.Label.CSP_Services_GoToService;
				sw.accessGranted =true;
				sw.accessRequested =false;
			}else if(sw.status==PortalServicesCtrl.PORTAL_ACCESS_REQUESTED){
				sw.btnLabel = System.Label.ISSP_Access_Requested;
				sw.accessGranted =false;
				sw.accessRequested =true;
			}else{
				if(sw.isAdmin){
					sw.btnLabel =System.Label.ISSP_Enable_Service;
				}
				else sw.btnLabel =System.Label.CSP_Request_Service;
				sw.accessGranted =false;
				sw.accessRequested =false;
			}
		
			if(flagIsIepPortalService){
				if ((sw.iepStatus == ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT || sw.iepStatus == ANG_ISSP_PortalServiceHelper.STATUS_IN_PROGRESS) && sw.isAdmin && sw.isAuthorisedSignatory) {
					sw.btnLabel = System.Label.ANG_ISSP_Open_IATA_EasyPay_Account;
					sw.useDefaultRole = true;
				} else {
					sw.useDefaultRole = false;
					if (flagIsIepPortalService && sw.iepStatus == ANG_ISSP_PortalServiceHelper.STATUS_OPEN) {
						sw.btnLabel = System.Label.ANG_ISSP_Request_Access_IATA_EasyPay;
					} else if (sw.isAdmin && sw.recordService.Cannot_be_managed_by_portal_admin__c == false) {
						sw.btnLabel = System.Label.CSP_Request_Service;
					} 
				} 
			}


	}

@AuraEnabled(cacheable=true)
public static Map<String, String> getUserOptions(String portalUser){

	Map<String,String> userOptions = new Map<String,String>();

	List<User> userContactAccountOptions = [SELECT id, Account.ANG_IEP_Status_FF__c, Contact.Authorized_Signatory__c,
	                                        Contact.User_Portal_Status__c, ContactId, Account.ICCS_Membership_Status__c
	                                        FROM User WHERE Id =:portalUser];

	if(!userContactAccountOptions.isEmpty()) {
		for(User u : userContactAccountOptions) {
			if(u.Account.ANG_IEP_Status_FF__c != null) {
				userOptions.put('IEP_Status', u.Account.ANG_IEP_Status_FF__c);
			}
			if(u.Contact.Authorized_Signatory__c != null) {
				userOptions.put('Legal_Auth_Signature', String.valueOf(u.Contact.Authorized_Signatory__c));
			}
			if(u.Contact.User_Portal_Status__c != null  && u.Contact.User_Portal_Status__c != '') {
				userOptions.put('User_Portal_Status', u.Contact.User_Portal_Status__c);
			}
			if(u.ContactId != null) {
				userOptions.put('User_ContactId', u.ContactId);
			}
			if(u.Account.ICCS_Membership_Status__c != null) {
				userOptions.put('User_ICCS_Membership_Status', u.Account.ICCS_Membership_Status__c);
			}
		}
	}
	return userOptions;
}

@AuraEnabled(cacheable=true)
public static List<Connected_App_Roles__c> availableIEPPortalServiceRoles(){
	List<Connected_App_Roles__c> allAppRoles = Connected_App_Roles__c.getAll().values();
	List<Connected_App_Roles__c> finalAllAppRoles = new List<Connected_App_Roles__c>();
	for(Connected_App_Roles__c car : allAppRoles) {
		if(car.Connected_App__c.startsWith('IATA EasyPay')) {
			finalAllAppRoles.add(car);
		}
	}
	return finalAllAppRoles;
}

@AuraEnabled(cacheable=true)
public static List<Connected_App_Roles__c> availableICCSPortalServiceRoles(){
	List<Connected_App_Roles__c> allAppRoles = Connected_App_Roles__c.getAll().values();
	List<Connected_App_Roles__c> finalAllAppRoles = new List<Connected_App_Roles__c>();
	for(Connected_App_Roles__c car : allAppRoles) {
		if(car.Connected_App__c.startsWith('ICCS')) {
			finalAllAppRoles.add(car);
		}
	}
	return finalAllAppRoles;
}

@AuraEnabled
public static String newAppsRequest2(String applicationId, String applicationName, String contactId, String portalServiceRole, Boolean flagUseDefaultRole, String defaultPortalUserRole){
	return ISSP_AvailableServices.newAppsRequest2(applicationId, applicationName, contactId, portalServiceRole, flagUseDefaultRole, defaultPortalUserRole);
}

@AuraEnabled
public static String newAppsRequestICCS(String applicationId, String applicationName, String contactId){
	return ISSP_AvailableServices.newAppsRequest(applicationId, applicationName, contactId);
}

@AuraEnabled(cacheable=true)
public static Integer userProvisioningRequests(){
	Id userId = UserInfo.getUserId();
	List<UserProvisioningRequest> userProvList = [SELECT id FROM UserProvisioningRequest WHERE SalesforceUserId =: userId AND State = 'Failed'];
	System.debug(userProvList);
	return userProvList.size();
}

@AuraEnabled(cacheable=true)
public static String performCheckonPoll(String permSetSSO, Integer failedCount){
	Id userId = UserInfo.getUserId();
	List<PermissionSetAssignment> permissionSetList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: userId AND PermissionSetId IN (select id from PermissionSet Where name =: permSetSSO)];
	System.debug('HERE!!!');

	System.debug(permissionSetList);

	if(!permissionSetList.isEmpty()) {
		return 'Success';
	} else {
		List<UserProvisioningRequest> userProvisioningList = [SELECT id FROM UserProvisioningRequest WHERE SalesforceUserId =: userId AND State = 'Failed '];
		if(userProvisioningList.size() != failedCount) {
			return 'Error ';
		}
	}
	return 'Incomplete';
}

@AuraEnabled(cacheable=true)
public static String serviceWrapperRedirect(String serviceId){

	User currentPortalUser = [SELECT id, contact.account.ANG_IEP_Status_FF__c, contact.Authorized_Signatory__c, contact.User_Portal_Status__c
	                          FROM User
	                          WHERE id =: UserInfo.getUserId()];


	Boolean isAdmin = (currentPortalUser.contact.User_Portal_Status__c == PORTAL_ADMIN_APPROVED);

	List<Portal_Applications__c> Servicetmp_List = new List<Portal_Applications__c>([SELECT id,Application_icon__c, Application_URL__c,
	                                                                                 Confirm_Box__c, Confirm_Text__c, Description__c,Name,
	                                                                                 ServiceName__c,Cannot_be_managed_by_portal_admin__c
	                                                                                 FROM Portal_Applications__c WHERE Id =: serviceId ]);

	ISSP_AvailableServices.ServiceWrapper serviceWrap = new ISSP_AvailableServices.ServiceWrapper (Servicetmp_List[0], currentPortalUser.contact.account.ANG_IEP_Status_FF__c, isAdmin, currentPortalUser.contact.Authorized_Signatory__c);

	return serviceWrap.recordService.Application_URL__c;
}

	//gets Portal ADmins - Method based on existing funcionality ANG_RHCAlertTriggerHandler.sendAlertNotification
	@AuraEnabled(cacheable=true)
	public static list<contact> getPortalAdmins(){
		User u=DAL_ISSP.getUser(UserInfo.getUserId());

		return [SELECT Id,name,email FROM Contact WHERE User_Portal_Status__c = :ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM AND (Account.Top_Parent__c =:u.contact.AccountId OR AccountId = :u.contact.AccountId)];
	}
}
