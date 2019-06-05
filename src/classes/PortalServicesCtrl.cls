public with sharing class PortalServicesCtrl {


	/*
		This method is used for CS Portal searchbar.
		@refinedSearchSerialized - is a serialized filter object sent from the LWC controller for further filtering
	*/
	@AuraEnabled (cacheable=true)
	public static List<Portal_Application_Right__c> getUserServicesList(String refinedSearchSerialized){
		User userAux = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

		String contactId = userAux.ContactId;

		FilteringObject refinedSearch = null;

		if(refinedSearchSerialized != null && refinedSearchSerialized != '') {
			refinedSearch = (FilteringObject) JSON.deserialize(refinedSearchSerialized, FilteringObject.class);
		}

		//base query
		String finalQuery = 'Select Application_Name__c, PortalServiceTranslatedName__c ,Portal_Application__r.Description__c, '+
							'Portal_Application__r.Requestable__c, Application_icon_del__c, IsSCIMIFG__c, ' +
							'Portal_Application__r.New_Window__c, Right__c, Portal_Application__r.Application_icon_URL__c, ' +
							'Portal_Application__r.Name, Portal_Application__c, My_Apps__c, Contact__c, ' +
							'Application_Start_URL__c,Technical_Provisioning_Status__c, Case_creation_record_Type__c, ' +
							'Portal_Application__r.Service_Description__c, Portal_Application__r.Service_Description_Label__c ' +
							'FROM Portal_Application_Right__c ' +
							'WHERE Contact__c =:contactId AND '+
							'   (Right__c = \'Access Granted\' OR Right__c = \'Access Requested\') AND ' +
							'    Portal_Application__r.Hide_on_Homepage__c = false ';

		//Add the clauses for further filtering
		if(refinedSearch != null ) {
			finalQuery += ' AND Application_Name__c LIKE \'%' + refinedSearch.searchText + '%\' ';
		}

		finalQuery += ' ORDER BY Right__c DESC,Portal_Application__r.Name ';

		List<Portal_Application_Right__c> appsGrantedList = Database.query(finalQuery);

		return appsGrantedList;
	}


	@AuraEnabled (cacheable=true)
	public static List<Portal_Applications__c> getNonRequestableServicesList(String contactId){

		Contact con = [Select id from Contact where id =:contactId];

		List<Portal_Applications__c> externalLinksList = new List<Portal_Applications__c>();

		for (Portal_Applications__c pApp: [SELECT Name, Description__c, Service_Description__c, Service_Description_Label__c, Visible__c,
										Requestable__c, Application_icon__c, Application_URL__c, New_Window__c, VisibleCNS__c,
										ANG_Flag_Restrict_Accredited_Agent__c, ANG_Flag_Restrict_Sector__c
										FROM Portal_Applications__c
										WHERE Visible__c = true
										AND Requestable__c = false
										AND ANG_Flag_Restrict_by_Agency_Category__c = true
										AND ANG_Accre_Tp__c = true]) {

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

	/*
		Classes for the search filtering
	*/
	public class FilteringObject {

		@AuraEnabled
		public String searchText {get; set;}

		//the rest of the filters should be here too

		public FilteringObject(){
		}

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

		String extraQueryFields = ' CreatedDate, Application_URL__c, Cannot_be_managed_by_portal_admin__c, New_Window__c,ServiceName__c, Service_Description_Label__c, ANG_Restrict_by_Agency_Sector__c, ANG_Accredited_Agents_Only__c, Application_icon_URL__c ';
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


		List<String> lstPortalApplicationRightStatus = new List<String>{'Access Granted', 'Access Requested', 'Access Denied'};

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
					accessAux.Right__c.equals('Access Granted') && accessAux.Technical_Provisioning_Status__c.equals('IATA Access Granted') && accessAux.IsSCIMIFG__c == true) {
						statusAux = 'Access Under Provisioning';
				}

				mapServiceWrapper.get(accessAux.Portal_Application__c).status = statusAux;
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

	@AuraEnabled
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
			if(serviceWrapperAux.status == 'Access Requested'){
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
			if(serviceWrapperAux.status == 'Access Granted'){
				lstToReturn.add(serviceWrapperAux);
			}
		}

		return lstToReturn;
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
        public boolean addUsersEnable {get; set;}
		@AuraEnabled
        public boolean accountNotOpenError {get; set;}

        public ServiceWrapper(Portal_Applications__c recordService, Boolean isAdmin, String iepStatus, Boolean isAuthorisedSignatory, String status){
            this.recordService = recordService;
            this.isEasyPayService = ANG_ISSP_PortalServiceHelper.isIepPortalService(recordService.name);
			this.status = status;

            if(this.isEasyPayService) {
                this.addUsersEnable = isAdmin;
                this.accountNotOpenError = (iepStatus != ANG_ISSP_PortalServiceHelper.STATUS_OPEN);
            } else {
                this.addUsersEnable = !recordService.Cannot_be_managed_by_portal_admin__c;             
                this.accountNotOpenError = false;
            }

            Boolean flagIsIepPortalService = ANG_ISSP_PortalServiceHelper.isIepPortalService(recordService.name);
                                        
            if (flagIsIepPortalService && (iepStatus == ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT || iepStatus == ANG_ISSP_PortalServiceHelper.STATUS_IN_PROGRESS) && isAdmin && isAuthorisedSignatory) {
                this.btnLabel = System.Label.ANG_ISSP_Open_IATA_EasyPay_Account;
                this.useDefaultRole = true;
            } else {
                this.useDefaultRole = false;
                if (flagIsIepPortalService && iepStatus == ANG_ISSP_PortalServiceHelper.STATUS_OPEN) {
                    this.btnLabel = System.Label.ANG_ISSP_Request_Access_IATA_EasyPay;
                } else if (isAdmin && recordService.Cannot_be_managed_by_portal_admin__c == false) {
                    this.btnLabel = System.Label.ISSP_Enable_Service;
                } else {
                    this.btnLabel = System.Label.ISSP_New_Service_Request;
                }
            }
        }

    }

	/**
        Returns true if current user is a Portal Admin
    **/
    private static Boolean isPortalAdminUser() {
        return ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId());
    }


}