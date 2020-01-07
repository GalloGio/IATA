public with sharing class PortalServicesCtrl {


Public static final String PORTAL_ACCESS_GRANTED='Access Granted';
Public static final String PORTAL_ACCESS_REQUESTED='Access Requested';
Public static final String PORTAL_ACCESS_DENIED='Access Denied';
Public static final String PORTAL_USER_PENDING_APPR='Pending Approval';
Public static final String PORTAL_USER_APPROVED='Approved User';
Public static final String PORTAL_ADMIN_APPROVED='Approved Admin';
Public static final String PORTAL_EXTERNAL_ACCESS_GRANTED='External Access Granted';

public class portalServiceException extends Exception {}

@AuraEnabled (cacheable=false)
public static List<Portal_Applications__c> getNonRequestableServicesList(String contactId){

	Set<String> allowedLocTypes = new Set<String> {'HO', 'HE', 'AO', 'GE'};
	Contact con = [Select id, account.Sector__c, account.Location_Type__c, contact.account.Category__c,
					User_Portal_Status__c, Financial_Assessment_Contact__c,
					Account.RecordTypeId, Account.Is_Branch_Abroad__c, Account.Status__c from Contact where id =:contactId];

	List<Portal_Applications__c> externalLinksList = new List<Portal_Applications__c>();
	List<Portal_Applications__c> portalApplicationList = new List<Portal_Applications__c>();

	string queryFields = 'Name, Description__c, Service_Description__c, Service_Description_Label__c, Visible__c, ' +
							'Requestable__c, Application_icon__c, Application_URL__c, New_Window__c, VisibleCNS__c, ' +
							'ANG_Flag_Restrict_Accredited_Agent__c, ANG_Flag_Restrict_Sector__c, ServiceName__c, Application_icon_URL__c ';

	string query = 'SELECT '  + queryFields +
					' FROM Portal_Applications__c' +
					' WHERE Visible__c = true' +
					' AND Requestable__c = false' +
					' AND ANG_Flag_Restrict_by_Agency_Category__c = true' +
					' AND ANG_Accre_Tp__c = true';

	portalApplicationList = Database.query(query);

	// Second search based in Custom Metadata for all those remaining apps
	List<String> requestableAppNameList = PortalApplicationSettingHelper.getVisibleApplicationNames(con.Account);
	query = 'SELECT ' + queryFields +
			' FROM Portal_Applications__c' +
			' WHERE Id NOT IN :portalApplicationList' +
			' AND Requestable__c = false' +
			' AND Name IN :requestableAppNameList';

	List<Portal_Applications__c> requestableAppList = Database.query(query);
	// combine first and second search of apps
	portalApplicationList.addAll(requestableAppList);

	for (Portal_Applications__c pApp: portalApplicationList) {
		if(pApp.Name.contains('Paypal') && pApp.VisibleCNS__c) {
			continue;
		}		
		if((pApp.Name == 'Trained Staff Certification' || pApp.Name == 'Local Industry Groups') && con.User_Portal_Status__c != PORTAL_ADMIN_APPROVED) {
			continue;
		}
		if (pApp.Name == 'Insurance Providers' || pApp.Name == 'Financial Securities') {
			if (((con.Account.Sector__c == 'Travel Agent' || con.Account.Sector__c == 'Cargo Agent')
				 && con.Account.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency')) &&
				(allowedLocTypes.contains(con.Account.Location_Type__c) || con.Account.Is_Branch_Abroad__c == 'Yes') &&
				(AMS_Utils.ACTIVEAGENCYSTATUS.contains(con.Account.Status__c) || con.Account.Status__c == AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING) &&
				(con.Financial_Assessment_Contact__c || con.User_Portal_Status__c == PORTAL_ADMIN_APPROVED)) {
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
@AuraEnabled (cacheable=false)
public static List<Portal_Application_Right__c> getUsersFavoriteServicesList(String contactId){

	//base query
	String finalQuery = 'SELECT Id, Application_Name__c, PortalServiceTranslatedName__c ,Portal_Application__r.Description__c, '+
						'Portal_Application__r.Requestable__c, Application_icon_del__c, IsSCIMIFG__c, ' +
						'Portal_Application__r.New_Window__c, Right__c, Portal_Application__r.Application_icon_URL__c, ' +
						'Portal_Application__r.Name, Portal_Application__c, My_Apps__c, Contact__c, ' +
						'Application_Start_URL__c,Technical_Provisioning_Status__c, Case_creation_record_Type__c, ' +
						'Portal_Application__r.Service_Description__c, Portal_Application__r.Service_Description_Label__c, Is_Favorite__c, Portal_Application__r.Id  ' +
						'FROM Portal_Application_Right__c ' +
						'WHERE (Contact__c = \'' + contactId + '\' AND '+
						'   (Right__c = \'' +  PORTAL_ACCESS_GRANTED + '\' OR Portal_Application__r.Requestable__c = false) AND ' +
						'   Portal_Application__r.Hide_on_Homepage__c = false)' +
						' AND (IsSCIMIFG__c = false OR (IsSCIMIFG__c = true AND Technical_Provisioning_Status__c = \'' + PORTAL_EXTERNAL_ACCESS_GRANTED + '\' ))';

	finalQuery += ' ORDER BY Last_Visit_Date__c DESC NULLS LAST, Portal_Application__r.New_Window__c ASC, Portal_Application__r.Name ASC LIMIT 15';

	List<Portal_Application_Right__c> appsGrantedList = Database.query(finalQuery);

	return appsGrantedList;
}

@AuraEnabled (cacheable=false)
public static List<Portal_Application_Right__c> getFavoriteServicesList(){
	User userAux = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

	String contactId = userAux.ContactId;

	List<Portal_Application_Right__c> lstPortalApplicationsRights = getUsersFavoriteServicesList(contactId);

	List<Portal_Applications__c> lstPortalApplications =  getNonRequestableServicesList(contactId);

	List<Portal_Application_Right__c> listToReturn = new List<Portal_Application_Right__c>();
	List<Portal_Application_Right__c> nonFavorites = new List<Portal_Application_Right__c>();
	Set<Id> portalApplicationIdSet = new Set<Id>();
	for(Portal_Application_Right__c par : lstPortalApplicationsRights){
		if(par.Is_Favorite__c){
			listToReturn.add(par);
		}
		else{
			nonFavorites.add(par);
		}
		portalApplicationIdSet.add(par.Portal_Application__r.Id);
	}

	listToReturn.addAll(nonFavorites);

	if(!lstPortalApplications.isEmpty()) {
		for(Portal_Applications__c pa : lstPortalApplications) {
			if(! portalApplicationIdSet.contains(pa.Id)){
				Portal_Application_Right__c lstPar = new Portal_Application_Right__c();
				lstPar.Portal_Application__r = pa;
				lstPar.Is_Favorite__c = false;
				listToReturn.add(lstPar);
			}
		}
	}

	return listToReturn;
}

@AuraEnabled(cacheable=true)
public static String paymentLinkRedirect(){

	User userAux = [SELECT Id, Contact.Credit_Card_Payment_Link__c FROM User WHERE Id = :UserInfo.getUserId()];

	if(userAux.Contact != null && userAux.Contact.Credit_Card_Payment_Link__c != null) {
		return userAux.Contact.Credit_Card_Payment_Link__c;
	}else{
		return '';
	}
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
	for(ISSPServiceListView__c serviceListViewItem : csServiceListViews) {

		//view if user have permissions from profile
		Boolean resultPermission1 = true;
		if(!theProfilePermissionFilter.isDataEmpty(serviceListViewItem, 'Profiles_Id__c')) {
			resultPermission1 = theProfilePermissionFilter.isUserPermittedFor(serviceListViewItem, 'Profiles_Id__c');
		}

		//view if user have permissions from permission set
		Boolean resultPermission2 = true;
		if(!thePermissionSetFilter.isDataEmpty(serviceListViewItem, 'Permission_set__c')) {
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

	if(selectedView.Field_Set_API_Name__c != null && selectedView.Field_Set_API_Name__c != '') {

		List<Schema.FieldSetMember> fieldSet = sObjectType.Portal_Applications__c.FieldSets.getMap().get(selectedView.Field_Set_API_Name__c).getFields();

		if(fieldSet != null && !fieldSet.isEmpty()) {
			for(Schema.FieldSetMember fieldAux : fieldSet) {
				fieldsStr +=  ', '+fieldAux.getFieldPath();
			}
		}

	}
	return fieldsStr;
}

private static String getConditionFromSelectedView(ISSPServiceListView__c selectedView){
	String conditionStr = '';

	if(selectedView.SOQL_Filter__c != null && selectedView.SOQL_Filter__c != '') {

		conditionStr = selectedView.SOQL_Filter__c;

	}
	return conditionStr;
}

private static List<Portal_Applications__c> getPortalApplications(){
	//get user available list views
	Map<String,ISSPServiceListView__c> mapServiceListViews = PortalServicesCtrl.getMapSrevicesListViews();

	//Select "Available services" entry for this method
	ISSPServiceListView__c selectedView = mapServiceListViews.get('Available services');

	if(selectedView == null) {
		//user cannot view portal applications, return empty list
		return new List<Portal_Applications__c>();
	}

	//construct query
	String fieldsStr = PortalServicesCtrl.getFieldsFromSelectedView(selectedView);
	String conditionStr = PortalServicesCtrl.getConditionFromSelectedView(selectedView);

	String extraQueryFields = ' CreatedDate, Application_URL__c, Cannot_be_managed_by_portal_admin__c, New_Window__c,ServiceName__c, Service_Description_Label__c, '+
								'ANG_Restrict_by_Agency_Sector__c, ANG_Accredited_Agents_Only__c, Application_icon_URL__c, Requestable__c, Requires_Level2_Registration__c';
	String finalQuery = 'SELECT '+ extraQueryFields + fieldsStr+ ' FROM Portal_Applications__c ' + conditionStr + ' ORDER BY Name ASC ';

	System.debug('getPortalApplications finalQuery : ' + finalQuery);
	List<Portal_Applications__c> portalAppList = Database.query(finalQuery);

	// Second search based in Custom Metadata for all those remaining apps
	User userAux = [SELECT Id, contact.account.Sector__c, contact.account.Category__c FROM User WHERE Id = :UserInfo.getUserId()];
	List<String> requestableAppNameList = PortalApplicationSettingHelper.getVisibleApplicationNames(userAux.Contact.Account);

	finalQuery = 'SELECT ' + extraQueryFields + fieldsStr +
				 +' FROM Portal_Applications__c'
				 + ' WHERE Id NOT IN :portalAppList'
				 + ' AND Requestable__c = true'
				 + ' AND Name IN :requestableAppNameList';

	List<Portal_Applications__c> requestableAppList = Database.query(finalQuery);
	// combine first and second search of apps
	portalAppList.addAll(requestableAppList);
	return portalAppList;

}


/*
		This method is used in services pages
 */
@AuraEnabled
public static List<ServiceWrapper> getAllServices(){
	User userAux = [SELECT Id, ContactId, Contact.Account.ANG_IEP_Status_FF__c,Contact.Preferred_Language__c,LastLoginDate FROM User WHERE Id = :UserInfo.getUserId()];
	String contactId = userAux.ContactId;
	String iepStatus = userAux.Contact.Account.ANG_IEP_Status_FF__c;

	Boolean isAdmin = PortalServicesCtrl.isPortalAdminUser();

	Contact contAcc = AMS_Utils.getIEPContact(contactId);

	Boolean isAuthorisedSignatory = (isAdmin && contAcc.Authorized_Signatory__c);

	//if the user have premium dashboard than this changes to true
	Boolean hasPremiumTD = false;


	List<String> lstPortalApplicationRightStatus = new List<String> {PortalServicesCtrl.PORTAL_ACCESS_GRANTED, PortalServicesCtrl.PORTAL_ACCESS_REQUESTED, PortalServicesCtrl.PORTAL_ACCESS_DENIED};

	//get portal applications for this user by enforcing custom setting for services list view
	List<Portal_Applications__c> lstPortalApplications = PortalServicesCtrl.getPortalApplications();

	//iterate over the returned portal apps and create a map of services
	Map<String,ServiceWrapper> mapServiceWrapper = new Map<String,ServiceWrapper>();
	for(Portal_Applications__c portalAppAux : lstPortalApplications) {
		mapServiceWrapper.put(portalAppAux.Id, new ServiceWrapper(portalAppAux, isAdmin, iepStatus, isAuthorisedSignatory, '', userAux, true));
	}

	//get the portal application rights for this user
	PortalApplicationRight_Sel portalApplicationRightSelector = new PortalApplicationRight_Sel();
	List<Portal_Application_Right__c> userGrantedList = portalApplicationRightSelector.getPortalApplicationRightsByContactIdAndRightsList(contactId, lstPortalApplicationRightStatus);

	//Defining a set of services that the user have access or requested to have access but was not retrieved by the first query
	Set<String> appsAlreadyWithAccessIds = new Set<String>();

	for(Portal_Application_Right__c accessAux : userGrantedList) {

		//check if the user have access to treasury dashboard premium
		if(accessAux.Portal_Application__r.Name == 'Treasury Dashboard - Premium') {
			hasPremiumTD = true;
		}

		if(mapServiceWrapper.containsKey(accessAux.Portal_Application__c)) {
			String statusAux = accessAux.Right__c;

			if(accessAux.Right__c != null && accessAux.Technical_Provisioning_Status__c != null &&
				accessAux.Right__c.equals(PortalServicesCtrl.PORTAL_ACCESS_GRANTED) && accessAux.Technical_Provisioning_Status__c.equals('IATA Access Granted') && accessAux.IsSCIMIFG__c == true) {
				statusAux = 'Access Under Provisioning';
			}

			alignStatus(mapServiceWrapper.get(accessAux.Portal_Application__c),statusAux);
			mapServiceWrapper.get(accessAux.Portal_Application__c).portalApplicationRightId = accessAux.Id;
			mapServiceWrapper.get(accessAux.Portal_Application__c).isFavorite = accessAux.Is_Favorite__c;
		}else{
			appsAlreadyWithAccessIds.add(accessAux.Portal_Application__c);
		}
	}


	//now get the services based on the previous set
	PortalApplications_Sel portalApplicationsSelector = new PortalApplications_Sel();
	Map<String,Portal_Applications__c> mapAppsAlreadyWithAccess =
		new Map<String,Portal_Applications__c>(portalApplicationsSelector.getPortalApplicationsByApplicationsList(appsAlreadyWithAccessIds));

	for(Portal_Application_Right__c accessAux : userGrantedList) {

		//if the map of services does not contains this service yet, then add it
		if(!mapServiceWrapper.containsKey(accessAux.Portal_Application__c)) {
			mapServiceWrapper.put(accessAux.Portal_Application__c,
				new ServiceWrapper(mapAppsAlreadyWithAccess.get(accessAux.Portal_Application__c), isAdmin, iepStatus, isAuthorisedSignatory, accessAux.Right__c, userAux, true));
			mapServiceWrapper.get(accessAux.Portal_Application__c).portalApplicationRightId = accessAux.Id;
			mapServiceWrapper.get(accessAux.Portal_Application__c).isFavorite = accessAux.Is_Favorite__c;
		}
	}

	//if the user have access to treasure dashboard premium then try to remove the other treasures
	if (hasPremiumTD) {
		String treasureDashboardId = '';
		for (ServiceWrapper thisService : mapServiceWrapper.values()) {
			if (thisService.recordService.Name == 'Treasury Dashboard' || thisService.recordService.Name == 'Treasury Dashboard - Basic') {
				treasureDashboardId = thisService.recordService.Id;
			}
		}
		if (treasureDashboardId != '') {
			mapServiceWrapper.remove(treasureDashboardId);
		}
	}
	return mapServiceWrapper.values();
}

@AuraEnabled(cacheable=true)
public static List<ServiceWrapper> getUserAvailableServices(){

	List<ServiceWrapper> lstAllServices = PortalServicesCtrl.getAllServices();

	List<ServiceWrapper> lstToReturn = new List<ServiceWrapper>();
	for(ServiceWrapper serviceWrapperAux : lstAllServices) {
		if(serviceWrapperAux.status == '') {
			lstToReturn.add(serviceWrapperAux);
		}
	}

	return lstToReturn;
}

@AuraEnabled
public static List<ServiceWrapper> getUserAccessRequestedServices(){

	List<ServiceWrapper> lstAllServices = PortalServicesCtrl.getAllServices();

	List<ServiceWrapper> lstToReturn = new List<ServiceWrapper>();
	for(ServiceWrapper serviceWrapperAux : lstAllServices) {
		if(serviceWrapperAux.status == PortalServicesCtrl.PORTAL_ACCESS_REQUESTED
			|| serviceWrapperAux.status == 'Access Under Provisioning' ) {
			lstToReturn.add(serviceWrapperAux);
		}
	}

	return lstToReturn;
}

public static Map<Id,List<ServiceWrapper> > getContactsAccessGrantedServices(Map<Id,Id> contactToUserIds, Boolean getServiceDescription){

	Map<Id,List<ServiceWrapper> > contactToServices = new Map<Id,List<ServiceWrapper> >();

	List<Portal_Application_Right__c > usersGrantedList = [select id,IsSCIMIFG__c,Application_Name__c,Right__c,Portal_Application__r.ServiceName__c,Portal_Application__r.Id,Portal_Application__r.Application_URL__c,Contact__r.Account.ANG_IEP_Status_FF__c
															from Portal_Application_Right__c
															where Contact__c IN:contactToUserIds.keySet() AND Right__c =: PORTAL_ACCESS_GRANTED];


	System.debug('get Users '+contactToUserIds.values());
	Map<Id,User> userInfos = new Map<Id,User>([SELECT Id,ContactId,ProfileId,Contact.Preferred_Language__c from User WHERE Id in: contactToUserIds.values()]);

	Map<String,ServiceWrapper> mapServiceWrapper = new Map<String,ServiceWrapper>();
	for(Portal_Application_Right__c accessRight : usersGrantedList) {

		String iepStatus = accessRight.Contact__r.Account.ANG_IEP_Status_FF__c;
		System.debug('get User '+accessRight.Contact__c);
		System.debug('get User2 '+userInfos.get(contactToUserIds.get(accessRight.Contact__c)));

		Boolean isAdmin = ISSP_Constant.adminIdSet.contains(userInfos.get(contactToUserIds.get(accessRight.Contact__c)).ProfileId);

		Portal_Applications__c portalAppAux = new Portal_Applications__c(Id=accessRight.Portal_Application__r.Id,Application_URL__c=accessRight.Portal_Application__r.Application_URL__c,Name=accessRight.Application_Name__c);

		ServiceWrapper wrap = new ServiceWrapper(portalAppAux, isAdmin, iepStatus,false, '', userInfos.get(contactToUserIds.get(accessRight.Contact__c)), getServiceDescription);

		if(!contactToServices.containsKey(accessRight.Contact__c)) {
			contactToServices.put(accessRight.Contact__c,new List<ServiceWrapper> {wrap});
		}else{
			contactToServices.get(accessRight.Contact__c).add(wrap);
		}
	}

	return contactToServices;
}

@AuraEnabled
public static List<ServiceWrapper> getUserAccessGrantedServices(){

	List<ServiceWrapper> lstAllServices = PortalServicesCtrl.getAllServices();

	Set<Id> serviceIds = new Set<Id>();

	List<ServiceWrapper> lstToReturn = new List<ServiceWrapper>();
	for(ServiceWrapper serviceWrapperAux : lstAllServices) {
		if(serviceWrapperAux.status == PortalServicesCtrl.PORTAL_ACCESS_GRANTED) {
			lstToReturn.add(serviceWrapperAux);
			serviceIds.add(serviceWrapperAux.recordService.Id);
		}
	}

	User userAux = [SELECT Id, ContactId,Contact.Preferred_Language__c FROM User WHERE Id = :UserInfo.getUserId()];
	String contactId = userAux.ContactId;

	List<Portal_Applications__c> lstPA = getNonRequestableServicesList(contactId);
	List<ServiceWrapper> lstServiceWrapper = new List<ServiceWrapper>();

	if(!lstPA.isEmpty()) {
		Map<String,ServiceWrapper> mapServiceWrapper = new Map<String,ServiceWrapper>();
		// Non-requestable services for the contact might have Portal Service Access records, defining if the service belongs to the favorites
		List<Portal_Application_Right__c> portalServiceAccessesList = [SELECT Id, Portal_Application__r.Id, Is_Favorite__c FROM Portal_Application_Right__c WHERE Contact__r.Id =:contactId]; 
		Map<Id, Portal_Application_Right__c> portalServiceAccessesMap = new Map<Id, Portal_Application_Right__c>();
		for(Portal_Application_Right__c par : portalServiceAccessesList){
			portalServiceAccessesMap.put(par.Portal_Application__r.Id, par);
		}
		Set<Id> keySet = portalServiceAccessesMap.keySet();

		for(Portal_Applications__c portalAppAux : lstPA) {
			if(! serviceIds.contains(portalAppAux.Id)){
				ServiceWrapper wrappedService = new ServiceWrapper(portalAppAux, false, '', false, '', userAux, true);
				if(keySet.contains(portalAppAux.Id)){
					wrappedService.isFavorite = portalServiceAccessesMap.get(portalAppAux.Id).Is_Favorite__c;
					wrappedService.portalApplicationRightId = portalServiceAccessesMap.get(portalAppAux.Id).Id;
				}
				else{
					wrappedService.isFavorite = false;
				}
				lstServiceWrapper.add(wrappedService);
			}
		}
		lstToReturn.addAll(lstServiceWrapper);
	}

	return lstToReturn;
}

@AuraEnabled
public static void updateLastModifiedService(String serviceId) {
	User u = CSP_Utils.getLoggedUser();
	List<Portal_Application_Right__c> serviceToUpdate = [SELECT Last_Visit_Date__c FROM Portal_Application_Right__c WHERE Contact__c = :u.ContactId AND Portal_Application__c = :serviceId LIMIT 1];

	if(!serviceToUpdate.isEmpty()) {
		serviceToUpdate[0].Last_Visit_Date__c = Datetime.now();

		update serviceToUpdate;
	}
}

public static Integer RESULTS_PER_PAGE = 10;

/*
		This method is used for CS Portal searchbar.
		@refinedSearchSerialized - is a serialized filter object sent from the LWC controller for further filtering
 */
@AuraEnabled (cacheable=false)
public static CSP_Utils.PagedResult getUserFilteredServices(String searchKey, String requestedPage){

	PortalSearchFilterWrapper filtersWrapper = (PortalSearchFilterWrapper) JSON.deserialize(searchKey, PortalSearchFilterWrapper.class);

	Integer requestedPageAux = integer.valueof(requestedPage);

	List<String> serachTextLst = new List<String>();
	if(filtersWrapper != null && filtersWrapper.searchText != null && filtersWrapper.searchText != '') {
		serachTextLst = filtersWrapper.searchText.split(' ');
	}

	//request all services
	//yes, it is requesting all services and then filter locally instead of inside the query...
	//this is to enforce all the protection around the services and since the user cannot have millions of
	//services it won't be a big deal to do this way
	List<ServiceWrapper> lstAllServices = PortalServicesCtrl.getAllServices();

	Map<String,Portal_Applications__c> mapFiltered = new Map<String,Portal_Applications__c>();

	for(ServiceWrapper serviceAux : lstAllServices) {
		//filter the service name
		for(String searchStrAux : serachTextLst) {
			if(searchStrAux != '' && searchStrAux != ' ' && serviceAux.recordService.ServiceName__c.containsIgnoreCase(searchStrAux)) {
				if(!mapFiltered.containsKey(serviceAux.recordService.Id)) {
					mapFiltered.put(serviceAux.recordService.Id,serviceAux.recordService);
				}
			}
		}

	}

	List<Portal_Applications__c> lstFiltered = mapFiltered.values();

	List<Portal_Applications__c> lstToReturn = new List<Portal_Applications__c>();
	Integer offset = requestedPageAux * PortalServicesCtrl.RESULTS_PER_PAGE;
	for(Integer i = offset; i < offset+RESULTS_PER_PAGE && i < lstFiltered.size(); i++) {
		lstToReturn.add(lstFiltered.get(i));
	}

	CSP_Utils.PagedResult result = new CSP_Utils.PagedResult();
	result.records = lstToReturn;
	result.totalItemCount = lstToReturn.size();

	return result;
}

@AuraEnabled (cacheable=false)
public static ServiceWrapper getServiceDetails(string serviceId){

	ServiceWrapper temp = null;

	//use all salesforce logic and the custom settings logic to get the services and filter by the requested service
	List<ServiceWrapper> lstAllServices = PortalServicesCtrl.getAllServices();
	for(ServiceWrapper serviceWrapperAux : lstAllServices) {
		if(serviceWrapperAux.recordService.id == serviceId) {
			serviceWrapperAux.userContactId=DAL_ISSP.getUser(UserInfo.getUserId()).contactId; //Adds user contact to wrapper

			if(serviceWrapperAux.addUsersEnable) {
				serviceWrapperAux.totalNrContacts =PortalServicesCtrl.getTotalNrContatsRelatedToService(serviceId);
			}
			temp= serviceWrapperAux;
		}
	}

	User user = [select Id,ContactId, Contact.Preferred_Language__c,LastLoginDate from User where Id=:Userinfo.getUserId()];

	//if user is admin and does not have access to this service, it's ok to retrieve anyway
	if(PortalServicesCtrl.isPortalAdminUser() && temp == null){
		User userAux = [SELECT Id, ContactId, Contact.Account.ANG_IEP_Status_FF__c FROM User WHERE Id = :UserInfo.getUserId()];
		String contactId = userAux.ContactId;
		String iepStatus = userAux.Contact.Account.ANG_IEP_Status_FF__c;
		Boolean isAdmin = PortalServicesCtrl.isPortalAdminUser();
		Contact contAcc = AMS_Utils.getIEPContact(contactId);
		Boolean isAuthorisedSignatory = (isAdmin && contAcc.Authorized_Signatory__c);

		PortalApplications_Sel portalApplicationsSelector = new PortalApplications_Sel();
		List<Portal_Applications__c> lstServicesAux = portalApplicationsSelector.getPortalApplicationsByApplicationsList(new Set<String>{serviceId});

		if(lstServicesAux != null && !lstServicesAux.isEmpty()){
			temp = new ServiceWrapper(lstServicesAux.get(0), isAdmin, iepStatus, isAuthorisedSignatory, '', user, true);
			temp.totalNrContacts = PortalServicesCtrl.getTotalNrContatsRelatedToService(serviceId);
		}
	}

	return temp;
}

//returns the total number of contacts for that service
public static integer getTotalNrContatsRelatedToService(string serviceId) {
	return new PortalApplicationRight_Sel().getTotalNrContacts(serviceId);
}

//returns the a page of the list of contacts for that service,
@AuraEnabled (cacheable=false)
public static List<ContactWrapper> getContactsAndStatusRelatedToServiceList(string serviceId,integer offset){
	return getContactsAndStatusRelatedToServiceList(serviceId,offset,'');
}


//searchs for a specific set of records bsed by criteria.
@AuraEnabled (cacheable=false)
public static List<ContactWrapper> searchContactsInService(string serviceId,string searchkey,string filter1,string filter1_2,string filter2){
	string filter=' AND (contact__r.name LIKE \'%'+searchkey +'%\' OR contact__r.email LIKE \'%{0}%\' OR contact__r.account.IATACode__c LIKE \'%{0}%\' OR contact__r.account.BillingCity LIKE \'%{0}%\' OR contact__r.account.IATA_ISO_Country__r.Name LIKE \'%{0}%\' )'.replace('{0}',searchkey);
	
	if(filter1 != '' && filter1 != 'All' && filter1_2 != ''){
		filter += 'AND contact__r.account.IATACode__c =\'' + filter1 + '\' AND contact__r.account.BillingCity =\'' + filter1_2 + '\' ';
	} else if(filter1 != '' && filter1 != 'All' && filter1_2 == '') {
		filter += 'AND contact__r.account.IATA_ISO_Country__r.Name =\'' + filter1 + '\'';
	}

	if(filter2 != '' && filter2 != 'All')
		filter += 'AND Right__c =\'' + filter2 + '\'';

	return getContactsAndStatusRelatedToServiceList(serviceId,null,filter);
}

//returns all contacts under a specific srevice
private static List<ContactWrapper> getContactsAndStatusRelatedToServiceList(string serviceId,integer offset,string searchkey) {


	List<ContactWrapper> appsGrantedList = new List<ContactWrapper>();
	List<Portal_Application_Right__c> auxServicesList=new PortalApplicationRight_Sel().getPortalApplicationRightsByPortalService(serviceId,offset,searchkey);


	Set<String> contactIds = new Set<String>();
	for (Portal_Application_Right__c par : auxServicesList) {
		contactIds.add(par.contact__c);
	}

	for( user u:[SELECT ContactId FROM User WHERE ContactId IN :contactIds])
		PortalServicesCtrl.contactWithUserSet.add(u.ContactId);

	for(Portal_Application_Right__c par : auxServicesList) {
		ContactWrapper sw = new ContactWrapper(par);



		if(sw.isInactive || ((sw.isEasyPayService && !sw.cannotBeManagedByPortalAdmin) ||
			(sw.isEasyPayService && sw.cannotBeManagedByPortalAdmin && par.right__c != PortalServicesCtrl.PORTAL_ACCESS_GRANTED) ||
			(!sw.isEasyPayService && sw.cannotBeManagedByPortalAdmin)
			)) {
			continue;
		}

		appsGrantedList.add(sw);
	}

	return appsGrantedList;
}

//stores contacts with an user record
public static set<id> contactWithUserSet {

	get {
		if(contactWithUserSet==null) {
			contactWithUserSet=new set<id>();
		}
		return contactWithUserSet;
	}
	set;
}

public class ContactWrapper {
//@AuraEnabled
//public Portal_Application_Right__c par {get; set;}
//@AuraEnabled
//public String contactStatus {get; set;}
@AuraEnabled
public Boolean cannotBeManagedByPortalAdmin {get; set;}
@AuraEnabled
public Boolean isEasyPayService {get; set;}
@AuraEnabled
public Boolean isIFAPService {get; set;}
@AuraEnabled
public boolean hide {get; set;}
@AuraEnabled
public boolean showGrant {get; set;}
@AuraEnabled
public boolean showDeny {get; set;}
@AuraEnabled
public boolean showIfap {get; set;}
@AuraEnabled
public boolean isAdmin {get; set;}

//contact info
@AuraEnabled
public string contactId {get; set;}
@AuraEnabled
public string contactName {get; set;}
@AuraEnabled
public string emailAddress {get; set;}
@AuraEnabled
public string iataCodeLoc {get; set;}
@AuraEnabled
public string userPortalStatus {get; set;}
@AuraEnabled
public string serviceRight {get; set;}
@AuraEnabled
public string portalRole {get; set;}
@AuraEnabled
public boolean isPendingAccess {get; set;}
@AuraEnabled
public boolean isInactive {get; set;}
@AuraEnabled
public boolean hasNoContact {get; set;}
@AuraEnabled
public string country {get; set;}



public ContactWrapper(Portal_Application_Right__c par){
	String accountLocation = String.isNotBlank(par.Contact__r.Account.BillingCity) ? ' (' + par.Contact__r.Account.BillingCity + ')' : '';

	this.country=par.contact__r.Account_Country__c;
	this.contactId=par.contact__c;
	this.contactName=par.contact__r.name;
	this.emailAddress=par.contact__r.email;
	this.iataCodeLoc=par.contact__r.Account.iataCode__C+' ('+par.Contact__r.Account.BillingCity+')';
	this.userPortalStatus=par.contact__r.user_portal_status__c;
	if(par.IsSCIMIFG__c && par.Technical_Provisioning_Status__c != 'External Access Granted' && par.right__c == PortalServicesCtrl.PORTAL_ACCESS_GRANTED) {
		this.serviceRight= System.Label.ISSP_Homepage_Pending_approval;
	}else{
		this.serviceRight= par.right__C;
	}

	this.cannotBeManagedByPortalAdmin = par.Portal_Application__r.Cannot_be_managed_by_portal_admin__c;
	this.isEasyPayService = ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c);


	this.isPendingAccess=false;
	this.isInactive=false;
	this.hasNoContact=false;

	if (this.userPortalStatus == PortalServicesCtrl.PORTAL_USER_PENDING_APPR) {
		this.isPendingAccess=true;
	} else if (par.Contact__r.Status__c != 'Active' || this.userPortalStatus == 'Rejected' || this.userPortalStatus == 'Deactivated') {
		this.isInactive = true;
	} else if (!PortalServicesCtrl.contactWithUserSet.contains(par.Contact__c)) {
		this.hasNoContact = true;
	}

	this.showGrant = false;
	this.showDeny = false;
	this.showIfap = false;

	if(this.isEasyPayService) {
		if(this.cannotBeManagedByPortalAdmin && this.serviceRight == PortalServicesCtrl.PORTAL_ACCESS_GRANTED) {
			this.showDeny = true;
		}
	} else {
		if(!this.cannotBeManagedByPortalAdmin) {
			if(par.Application_Name__c == 'IFAP') {
				this.showIfap = true;
				if(this.serviceRight == PortalServicesCtrl.PORTAL_ACCESS_REQUESTED) {
					this.showDeny = true;
				}
			} else if(this.serviceRight == PortalServicesCtrl.PORTAL_ACCESS_DENIED) {
				this.showGrant = true;
			} else if(this.serviceRight == PortalServicesCtrl.PORTAL_ACCESS_REQUESTED) {
				this.showGrant = true;
				this.showDeny = true;
			} else {
				this.showDeny = true;
			}
		}
	}



}
}



public class ServiceWrapper {
@AuraEnabled
public string status {get; set;}
@AuraEnabled
public Portal_Applications__c recordService {get; set;}
@AuraEnabled
public String portalApplicationRightId {get; set;}
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
public boolean isFavorite {get; set;}
@AuraEnabled
public List<ContactWrapper> contactList {get; set;}
@AuraEnabled
public integer totalNrContacts {get; set;}
@AuraEnabled
public string userContactId {get; set;}
@AuraEnabled
public Boolean isIFGPending {get; set;}
@AuraEnabled
public String serviceDescriptionLabel {get; set;}
private string iepStatus {get; set;}
private boolean isAuthorisedSignatory {get; set;}



public ServiceWrapper(Portal_Applications__c recordService, Boolean isAdmin, String iepStatus, Boolean isAuthorisedSignatory, String status, User user, Boolean getServiceDescription){
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
		//	this.addUsersEnable = !recordService.Cannot_be_managed_by_portal_admin__c;
		this.addUsersEnable =  isAdmin;
		this.accountNotOpenError = false;
	}

	if(getServiceDescription){
	this.serviceDescriptionLabel = getServiceDescription(recordService, user);
	}else{
		this.serviceDescriptionLabel = '';
	}
	
	alignStatus(this,status);
}

}

private static String getServiceDescription (Portal_Applications__c recordService, User user) {
	String description = '';

	if(user == null){
		user = [select Id,ContactId, Contact.Preferred_Language__c from User where Id=:Userinfo.getUserId()];
	}

	try {
		LabelTranslator translator = new LabelTranslator();

		String translatedString = translator.translate(recordService.Service_Description_Label__c,user.Contact.Preferred_Language__c);

		description = translatedString == null ? '' : translatedString;

	}catch(Exception err) {
		System.debug(err);
	}

	return description;
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


	if(sw.status==PortalServicesCtrl.PORTAL_ACCESS_GRANTED ) {
		sw.btnLabel =System.Label.CSP_Services_GoToService;
		sw.accessGranted =true;
		sw.accessRequested =false;
		sw.isIFGPending = false;
	}else if(sw.status==PortalServicesCtrl.PORTAL_ACCESS_REQUESTED) {
		sw.btnLabel = System.Label.ISSP_Access_Requested;
		sw.accessGranted =false;
		sw.accessRequested =true;
		sw.isIFGPending = false;
	}else if(sw.status=='Access Under Provisioning') {
		sw.btnLabel = System.Label.ISSP_Access_Under_Provisioning;
		sw.isIFGPending = true;
		sw.accessGranted =false;
		sw.accessRequested =true;
	}else{
		if(sw.isAdmin) {
			if (sw.recordService.Cannot_be_managed_by_portal_admin__c == true) {
				sw.btnLabel = System.Label.CSP_Request_Service;
			}else{
				sw.btnLabel =System.Label.ISSP_Enable_Service;
			}
		}
		else sw.btnLabel =System.Label.CSP_Request_Service;
		sw.accessGranted =false;
		sw.accessRequested =false;
		sw.isIFGPending = false;
	}

	if(flagIsIepPortalService) {
		if ((sw.iepStatus == ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT || sw.iepStatus == ANG_ISSP_PortalServiceHelper.STATUS_IN_PROGRESS) && sw.isAdmin && sw.isAuthorisedSignatory) {
			sw.btnLabel = System.Label.ANG_ISSP_Open_IATA_EasyPay_Account;
			sw.useDefaultRole = true;
		} else {
			sw.useDefaultRole = false;
			if (flagIsIepPortalService && sw.iepStatus == ANG_ISSP_PortalServiceHelper.STATUS_OPEN) {
				sw.btnLabel = System.Label.ANG_ISSP_Request_Access_IATA_EasyPay;
			} else if (sw.isAdmin && sw.recordService.Cannot_be_managed_by_portal_admin__c == true) {
				sw.btnLabel = System.Label.CSP_Request_Service;
			}
		}
	}


}

@AuraEnabled(cacheable=true)
public static Map<String, String> getUserOptions(String portalUser){

	return DAL_WithoutSharing.getUserOptions(portalUser);
}

@AuraEnabled(cacheable=true)
public static List<Connected_App_Roles__c> availableIEPPortalServiceRoles(String serviceId){
	List<Portal_Applications__c> portalApps = [SELECT Id, Name FROM Portal_Applications__c WHERE id =:serviceId];

	List<Connected_App_Roles__c> allAppRoles = Connected_App_Roles__c.getAll().values();
	List<Connected_App_Roles__c> finalAllAppRoles = new List<Connected_App_Roles__c>();

	if(!portalApps.isEmpty()) {
		for(Connected_App_Roles__c car : allAppRoles) {

			if(car.Connected_App__c == portalApps[0].Name) {
				finalAllAppRoles.add(car);
			}
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
public static String newAppsRequest2(String applicationId, String applicationName, String contactId, String portalServiceRole, Boolean flagUseDefaultRole){
	String defaultPortalUserRole = '';
	if(flagUseDefaultRole){
		List<Connected_App_Roles__c> lstConAppRoles = availableIEPPortalServiceRoles(applicationId);
		for(Connected_App_Roles__c car : lstConAppRoles){
			if(car.Default_User_Role__c && car.Connected_App__c == applicationName){
				defaultPortalUserRole = car.Role__c;
			}
		}
		if(defaultPortalUserRole == ''){
			return null;
		}
	}
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
public static String serviceWrapperRedirect(String serviceId){

	User currentPortalUser = [SELECT id, contact.account.ANG_IEP_Status_FF__c, contact.Authorized_Signatory__c, contact.User_Portal_Status__c
							  FROM User
							  WHERE id =: UserInfo.getUserId()];


	Boolean isAdmin = (currentPortalUser.contact.User_Portal_Status__c == PORTAL_ADMIN_APPROVED);

	List<Portal_Applications__c> Servicetmp_List = new List<Portal_Applications__c>([SELECT id,Application_icon__c, Application_URL__c,Application_icon_URL__c,
																					 Confirm_Box__c, Confirm_Text__c, Description__c,Name,
																					 ServiceName__c,Cannot_be_managed_by_portal_admin__c
																					 FROM Portal_Applications__c WHERE Id =: serviceId ]);

	ISSP_AvailableServices.ServiceWrapper serviceWrap = new ISSP_AvailableServices.ServiceWrapper (Servicetmp_List[0], currentPortalUser.contact.account.ANG_IEP_Status_FF__c, isAdmin, currentPortalUser.contact.Authorized_Signatory__c);

	return serviceWrap.recordService.Application_URL__c;
}


	/**
	* getPortalAdmins - Method based on existing functionality on ISSP__PersonalInformationWithoutSharing.loadPortalAdmins
	* @return	returns Administrator contacts based on AccountTeamMembers
	*/
	@AuraEnabled(cacheable=true)
	public static List<AccountTeamMember> getPortalAdmins() {
		User currentUser = DAL_ISSP.getUser(Userinfo.getUserId());
		Contact currentUserContact = DAL_ISSP.getContact(currentUser.ContactId);

		List<AccountTeamMember> portalAdmins = new List<AccountTeamMember>();
		Map<Id, AccountTeamMember> portalAdminMap = new Map<Id, AccountTeamMember>();

		if (currentUserContact == null 
			|| 
				(currentUserContact.User_Portal_Status__c != 'Active'
				&& currentUserContact.User_Portal_Status__c != 'Approved Admin' //WMO-386  
				&& currentUserContact.User_Portal_Status__c != 'Regional Administrator'
				&& currentUserContact.User_Portal_Status__c != 'Approved User'
				&& currentUserContact.User_Portal_Status__c != 'Pending Approval')
			)
			return new List<AccountTeamMember>();
			
		try {
			String currentUserProfile = '';
			List<AccountTeamMember> teamMembers = ISSP_PersonalInformationWithoutSharing.getPortalAdmins(new Id[] { currentUserContact.AccountId, currentUserContact.Account.ParentId });
			
			for (AccountTeamMember teamMember : teamMembers) {
				if(currentUserContact.Id == teamMember.User.ContactId) {
					if(currentUserProfile == '') {
						currentUserProfile = teamMember.TeamMemberRole;
					}
					else if(currentUserProfile == 'Portal Administrator') {
						if(teamMember.TeamMemberRole != 'Portal Administrator' ) {
							currentUserProfile = teamMember.TeamMemberRole;
						}
					}
					else if(currentUserProfile == 'Portal Regional Administrator') {
						if(teamMember.TeamMemberRole != 'Portal Administrator' && teamMember.TeamMemberRole != 'Portal Regional Administrator'){
							currentUserProfile = teamMember.TeamMemberRole;
						}
					}
				}
			}

			// fill admins contacts lists
			for (AccountTeamMember teamMember : teamMembers) {
				if(currentUserProfile == '' || currentUserProfile == 'Manager' || currentUserProfile == 'Collaborator') {
					if(teamMember.TeamMemberRole == 'Portal Regional Administrator') {
						portalAdminMap.put(teamMember.User.ContactId, teamMember);
					}
				}
			}
			if (portalAdminMap.size() == 0) {
				for (AccountTeamMember teamMember : teamMembers) {
					if (teamMember.TeamMemberRole == 'Portal Administrator') {
						portalAdminMap.put(teamMember.User.ContactId, teamMember);
					}
				}
			} 
			
			portalAdmins = portalAdminMap.values(); 
			
		} catch (Exception e) {
			ISSP_Utilities.log(e);
		}

		return portalAdmins;
	}

@AuraEnabled(cacheable=false)
public static Boolean massDenyAccess(List<String> contactIds,string serviceId, String reason) {
	List<Portal_Application_Right__c> psaToUpdate = new List<Portal_Application_Right__c>();

	// Retrieve Portal Application Rights for Service ID and Contact IDs
	List<Portal_Application_Right__c> psaList = [SELECT Id, Right__c, Access_Status_Reason__c,LastModifiedDate,Contact__c
												 FROM Portal_Application_Right__c
												 WHERE Portal_Application__c = :serviceId AND Contact__c IN :contactIds];

	if(psaList == null || psaList.isEmpty()) {
		throw new portalServiceException(Label.ISSP_ANG_GenericError + ' EMPTY');
	}
	
	for(Portal_Application_Right__c psa : psaList) {
		psa.Right__c = PortalServicesCtrl.PORTAL_ACCESS_DENIED;
		psa.Access_Status_Reason__c = reason;

		psaToUpdate.add(psa);
	}

	// Records to update
	if(psaToUpdate != null && !psaToUpdate.isEmpty()) {
		try {
			update psaToUpdate;
		} catch(Exception e) {
			throw new portalServiceException(Label.ISSP_ANG_GenericError);
		}
	}

	return true;
}


// Denys Acccess to a portal service from the manage service page by an portal administrator
@AuraEnabled(cacheable=false)
public static Boolean denyAccess(String contactId,string serviceId, String reason, Boolean isFromContactTable) {

	List<Portal_Application_Right__c> psaList = [SELECT Id, Right__c, Access_Status_Reason__c,LastModifiedDate
												 FROM Portal_Application_Right__c
												 WHERE Portal_Application__c = :serviceId AND Contact__c = :contactId];

	System.debug('psaList: ' + psaList);
	if(psaList == null || psaList.isEmpty()) {
		throw new portalServiceException(Label.ISSP_ANG_GenericError);
	}
	Portal_Application_Right__c psa = psaList.get(0);

	if(isFromContactTable){
		psa.Right__c = PortalServicesCtrl.PORTAL_ACCESS_DENIED;
		psa.Access_Status_Reason__c = reason;

		try {
			update psa;
			return true;
		} catch(Exception e) {
			throw new portalServiceException(Label.ISSP_ANG_GenericError);
		}
	}else{
		try {
			delete psa;
			return true;
		} catch(Exception e) {
			throw new portalServiceException(Label.ISSP_ANG_GenericError);
		}
	}

}

// Grants Acccess to a portal service from the manage service page by an portal administrator
@AuraEnabled(cacheable=false)
public static Boolean massGrantAccess(List<String> contactIds, String serviceId, String reason) {
	// retrieves the record with the request
	List<Portal_Application_Right__c> psal = [SELECT Id, Right__c, Access_Status_Reason__c, LastModifiedDate, Contact__c
											  FROM Portal_Application_Right__c
											  WHERE Portal_Application__c = :serviceId AND Contact__c IN :contactIds];

	if(psal.isEmpty()) {
		System.debug(LoggingLevel.ERROR, 'PSA is null (2) [serviceId : ' + serviceId + ' - contactIds : ' + contactIds + '] ');
		throw new portalServiceException(Label.ISSP_ANG_GenericError);
	}

	Map<Id, Contact> contactsMap = new Map<Id, Contact>();
	for(Contact con : [SELECT Id, User_Portal_Status__c, (SELECT Id FROM Users) FROM Contact WHERE Id IN :contactIds]) {
		contactsMap.put(con.Id, con);
	}
	if(contactsMap.isEmpty()) {
		System.debug(LoggingLevel.ERROR, 'PSA is null (2) [serviceId : ' + serviceId + ' - contactIds : ' + contactIds + '] ');
		throw new portalServiceException(Label.ISSP_ANG_GenericError);
	}

	List<Portal_Application_Right__c> appRightsToUpdate = new List<Portal_Application_Right__c>();
	Map<String, Contact> contactsToUpdateMap = new Map<String, Contact>();
	Set<Id> contactsToStatusChangeList = new Set<Id>();

	for(Portal_Application_Right__c psa : psal) {
		if(psa.Contact__c != null) {
			Contact contact = contactsMap.get(psa.Contact__c);

			if (contact.User_Portal_Status__c == PortalServicesCtrl.PORTAL_USER_PENDING_APPR) {
				// Pending Approval
				contact.User_Portal_Status__c = PortalServicesCtrl.PORTAL_USER_APPROVED;
				
				contactsToUpdateMap.put(contact.Id, contact);
			} else if (contact.users.isEmpty()) {
				// No USer
				contactsToStatusChangeList.add(contact.Id);
				
			}
		}

		psa.Right__c = PortalServicesCtrl.PORTAL_ACCESS_GRANTED;
		psa.Access_Status_Reason__c = reason;
		appRightsToUpdate.add(psa);
	}
    
    if(!contactsToUpdateMap.keySet().isEmpty()){
        try {
            update contactsToUpdateMap.values();
            
            ISSP_EditPortalServiceAccessExt.updateUserProfiles(new List<String>(contactsToUpdateMap.keySet()));
        } catch(exception e) {
            throw e;
            //throw new portalServiceException(Label.ISSP_ANG_GenericError);
        }
    }
	if(contactsToStatusChangeList != null && !contactsToStatusChangeList.isEmpty()) {
		ISSP_ContactList ctrl = new ISSP_ContactList();

		//generates user active with the portal
		ctrl.processMultiplePortalUserStatusChange(contactsToStatusChangeList, PortalServicesCtrl.PORTAL_USER_APPROVED, 'Active');
	}
	
	try {
		update appRightsToUpdate;
	} catch(Exception e) {
		throw new portalServiceException(Label.ISSP_ANG_GenericError);
	}
	
	return true;
}

// Grants Acccess to a portal service from the manage service page by an portal administrator
@AuraEnabled(cacheable=false)
public static Boolean grantAccess(string contactId,string serviceId,string reason) {


	//retrieves the record with the request
	List<Portal_Application_Right__c> psal = [SELECT Id, Right__c, Access_Status_Reason__c,
											  LastModifiedDate
											  FROM Portal_Application_Right__c
											  WHERE Portal_Application__c = :serviceId AND Contact__c = :contactId];

	if(psal.isEmpty()) {
		System.debug(LoggingLevel.ERROR, 'PSA is null (2) [serviceId : ' + serviceId + ' - contactId : ' + contactId + '] ');
		throw new portalServiceException(Label.ISSP_ANG_GenericError);
	}

	Portal_Application_Right__c psa=psal.get(0);


	List<Contact> contactList = [Select Id, User_Portal_Status__c,(select id from users) From Contact Where id =: contactId];


	if(contactList.isEmpty()) {
		System.debug(LoggingLevel.ERROR, 'PSA is null (2) [serviceId : ' + serviceId + ' - contactId : ' + contactId + '] ');
		throw new portalServiceException(Label.ISSP_ANG_GenericError);
	}
	Contact contact = contactList.get(0);

	if (contact.User_Portal_Status__c == PortalServicesCtrl.PORTAL_USER_PENDING_APPR) {
		// Pending Approval
		contact.User_Portal_Status__c = PortalServicesCtrl.PORTAL_USER_APPROVED;
		try{

			update contact;
		}catch(exception e) {
			throw new portalServiceException(Label.ISSP_ANG_GenericError);
		}

		ISSP_EditPortalServiceAccessExt.updateUserProfile(contact.Id);

	} else if (contact.users.isEmpty()) {
		// No USer

		Set <Id> idSet = new Set <Id>();
		idSet.add(contact.Id);

		ISSP_ContactList ctrl = new ISSP_ContactList();

		//generates user active with the portal
		ctrl.processMultiplePortalUserStatusChange(idSet, PortalServicesCtrl.PORTAL_USER_APPROVED, 'Active');

	}
	psa.Right__c = PortalServicesCtrl.PORTAL_ACCESS_GRANTED;
	psa.Access_Status_Reason__c = reason;

	try {
		update psa;
		return true;
	} catch(Exception e) {
		throw new portalServiceException(Label.ISSP_ANG_GenericError);
	}

}
	@AuraEnabled
	public static List<PortalLookupSearchResult> getContactsForServiceAssignment(String serviceId,String queryString){

		List<Contact> contacts = new List<Contact>();
		List<PortalLookupSearchResult> results = new List<PortalLookupSearchResult>();

		User u = [SELECT id, contact.account.ANG_IEP_Status_FF__c, contact.Authorized_Signatory__c, contact.User_Portal_Status__c
		FROM User
		WHERE id =: UserInfo.getUserId()];

		List<Id> alreadyAssignedContactIds = new List<Id>();


		List<Portal_Application_Right__c> existingRights = [SELECT Id,Contact__c
		FROM Portal_Application_Right__c
		WHERE ((Contact__r.Account.Top_Parent__c =: u.contact.AccountId OR Contact__r.AccountId = : u.contact.AccountId) OR Right__c !=: PORTAL_ACCESS_GRANTED)
		AND Portal_Application__c =: serviceId];

		for(Portal_Application_Right__c right:existingRights) {
			alreadyAssignedContactIds.add(right.Contact__c);
		}
		

		String contactsQuery = 'SELECT Id, Name , AccountId, Email,Contact.Account_Country__c, User_Portal_Status__c, '+
			'(select id, Right__c from Portal_Application_Rights__r where Portal_Application__c =\''+ ServiceId + '\'),'+
			' Contact.IATA_Code__c , Account.IATA_ISO_Country__r.Name , Account.BillingCity ,'+
			' Account.IATACode__c  from Contact' +
			' WHERE User_Portal_Status__c NOT IN (\'Inactive\', \'Rejected\', \'Deactivated\')' +
			' AND Community__c != null' +
			' AND Email != null' +
			' AND Id NOT IN :alreadyAssignedContactIds ';
			
		if(!String.isBlank(queryString)){
			contactsQuery += ' AND (Name LIKE \'%'+queryString+'%\' ) ';
		}

		contactsQuery+=' ORDER BY NAME LIMIT 20';

		contacts = Database.query(contactsQuery);

		// Extract Contacts & convert them into PortalLookupSearchResult (check this class for more info)
		String contactIcon = 'standard:contact';
		Map<String,String> extraFields;

		for (Contact contact : contacts) {
			PortalLookupSearchResult res = new PortalLookupSearchResult(contact.Id, 'Contact', contactIcon, contact.Name, contact.Email);
			String iataCodeLocation = contact.Account.iataCode__c+' ('+contact.Account.BillingCity+')';

			extraFields = new Map<String,String>();

			extraFields.put('iataCodeLocation',iataCodeLocation);
			extraFields.put('status',contact.User_Portal_Status__c);
			extraFields.put('country',contact.Account_Country__c);
			res.setExtraFields(extraFields);

			results.add(res);
		}

		return results;
	}

	@AuraEnabled
	public static void grantAccessToContacts(List<String> contactIds, String serviceId){
		List<Portal_Application_Right__c> existingRights = [SELECT Id,Right__c,Contact__c from Portal_Application_Right__c WHERE Contact__c IN:contactIds AND Portal_Application__c=:serviceid];

		List <Contact> processContactList = [SELECT Id, User_Portal_Status__c, Name FROM Contact WHERE Id IN :contactIds];
		List <String> activateIdList = new List <String>();
		Set <Id> createIdSet = new Set <Id>();
		for (Contact thisContact : processContactList){
			if (thisContact.User_Portal_Status__c == 'Pending Approval'){
				activateIdList.add(thisContact.Id);
				thisContact.User_Portal_Status__c = 'Approved User';
			}
			else if (thisContact.User_Portal_Status__c == '' || thisContact.User_Portal_Status__c == null){
				createIdSet.add(thisContact.Id);
			}
		}

		if (!activateIdList.isEmpty()){
			ISSP_EditPortalServiceAccessExt.updateUserProfiles(activateIdList);
			update processContactList;
		}

		if (!createIdSet.isEmpty()){
			ISSP_ContactList ctrl = new ISSP_ContactList();
			ctrl.processMultiplePortalUserStatusChange(createIdSet, 'Approved User', 'Active');
		}

		Set<Id> toUpdateIds = new Set<Id>();


		if(!existingRights.isEmpty()){
			for(Portal_Application_Right__c right:existingRights){
				right.Right__c = 'Access Granted';
				toUpdateIds.add(right.Contact__c);
			}

			update existingRights;
		}

		List<Portal_Application_Right__c> newRights = new List<Portal_Application_Right__c>();

		for(String contactId : contactIds){
			if(!toUpdateIds.contains(contactId)){
				Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = contactId, Portal_Application__c = serviceid, Right__c = 'Access Granted');
				newRights.add(appRight);
			}
		}

		if(!newRights.isEmpty()){
			insert newRights;
		}

	}

	/**
	Returns true if the service can be requested and granted without any approval
	To have this the requester must be an admin user and the app service must have
	Cannot_be_managed_by_portal_admin__c = false. Also, there is an exception for IATA EasyPay services, which can be requested even when flag is false.
	**/
	@AuraEnabled
	public static Boolean newUserRequestableWithoutApproval(Boolean isAdmin, String serviceId) {

		List<Portal_Applications__c> portalServices = [SELECT Id,Name,Cannot_be_managed_by_portal_admin__c FROM Portal_Applications__c WHERE Id=:serviceId];

		if(!portalServices.isEmpty()){
			Boolean isEasyPay = portalServices[0].Name.contains('IATA EasyPay');

			Boolean canManage = portalServices[0].Cannot_be_managed_by_portal_admin__c == false || isEasyPay;

			return isAdmin && canManage;
		}

		return false;
	}

	//Activates old Iata Easy Pay users that were disabled after some time (Add users in Manage Portal Service)
	@AuraEnabled
	public static void ActivateIEPUsers(List<String> contactIds){
		try{
			DAL_WithoutSharing.ActivateIEPUsers(contactIds);
		}catch(Exception e) {
			throw new portalServiceException(Label.ISSP_ANG_GenericError);
		}
	
	}

	@AuraEnabled
	public static string CreateNewPortalAccess(List<String> ContactIds, String ServiceId, String PortalServiceRole){

		if(ContactIds.size()>0) {

			List<Portal_Application_Right__c> ContactToAdd_Lst = new List<Portal_Application_Right__c>();

			Set <String> contactIdSet = new Set <String>();

			String auxRight = PORTAL_ACCESS_REQUESTED;

			List<Portal_Application_Right__c> existPSA_Lst = new List<Portal_Application_Right__c>(
				[Select p.Name, p.Application_Name__c, p.Right__c,p.PortalServiceTranslatedName__c,  p.Portal_Application__r.Description__c, p.Portal_Application__r.Cannot_be_managed_by_portal_admin__c, p.Portal_Application__r.Requestable__c, p.Application_icon_del__c, p.Portal_Application__r.New_Window__c,
				 p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__c, p.My_Apps__c, p.Contact__c,p.Contact__r.Name, p.Contact__r.AccountId, p.Application_Start_URL__c,
				 p.Case_creation_record_Type__c,p.Access_Status_Reason__c
				 From Portal_Application_Right__c p
				 where p.Contact__c IN: ContactIds AND
				 p.Portal_Application__c =: ServiceId]
				);

			for(String ContactId : ContactIds) {

				contactIdSet.add(ContactId.trim());

				Boolean isUpdated = false;
				if(existPSA_Lst != null & existPSA_Lst.size() > 0 ) {
					for(Portal_Application_Right__c itemPSA : existPSA_Lst) {
						itemPSA.Right__c = auxRight;
						isUpdated = true;
						itemPSA.ANG_Portal_Service_Role__c = PortalServiceRole;
					}
				}

				if(isUpdated == false) {
					Portal_Application_Right__c PSAitem = new Portal_Application_Right__c();

					PSAitem.Portal_Application__c = ServiceId;
					PSAitem.Right__c = auxRight;
					PSAitem.ANG_Portal_Service_Role__c = PortalServiceRole;
					PSAitem.Contact__c = Id.valueOf(ContactId.trim());

					ContactToAdd_Lst.add(PSAitem);
				}
			}

			List <Contact> processContactList = [SELECT Id, User_Portal_Status__c, Name FROM Contact WHERE Id IN :contactIdSet];
			List <String> activateIdList = new List <String>();
			Set <Id> createIdSet = new Set <Id>();
			for (Contact thisContact : processContactList) {
				if (thisContact.User_Portal_Status__c == PORTAL_USER_PENDING_APPR) {
					activateIdList.add(thisContact.Id);
					thisContact.User_Portal_Status__c = PORTAL_USER_APPROVED;
				}
				else if (thisContact.User_Portal_Status__c == '' || thisContact.User_Portal_Status__c == null) {
					createIdSet.add(thisContact.Id);
				}
			}

			if (!activateIdList.isEmpty()) {
				ISSP_EditPortalServiceAccessExt.updateUserProfiles(activateIdList);
				update processContactList;
			}

			if (!createIdSet.isEmpty()) {
				ISSP_ContactList ctrl = new ISSP_ContactList();
				ctrl.processMultiplePortalUserStatusChange(createIdSet, PORTAL_USER_APPROVED, 'Active');
			}

			//
			// Save all the Portal_Application_Right__c after creating the users.
			// This is important for all EASY PAY services because they need to have the portal users.
			//
			if(ContactToAdd_Lst != null && ContactToAdd_Lst.size() > 0) {
				insert ContactToAdd_Lst;
			}

			if(existPSA_Lst != null && existPSA_Lst.size() > 0) {
				update existPSA_Lst;
			}
			return 'Success';

		}else{
			return 'Failure';
		}
	}

	//WMO-736 - ACAMBAS: Begin
	@AuraEnabled
	public static ServiceWrapper getPortalServiceDetails(string serviceName) {       
		Portal_Applications__c portalService = [SELECT Id FROM Portal_Applications__c WHERE Name = :serviceName LIMIT 1];
		return getServiceDetails(portalService.Id);
	}
	//WMO-736 - ACAMBAS: End

	@AuraEnabled
	public static Boolean changeIsFavoriteStatus(String portalApplicationId, String portalApplicationRightId, Boolean isFavorite){
		System.debug('portalApplicationId ' + portalApplicationId);
		System.debug('portalApplicationRightId ' + portalApplicationRightId);
		System.debug('isFavorite ' + isFavorite);
		try{
			if(portalApplicationRightId != null){
				Portal_Application_Right__c par = new Portal_Application_Right__c(
					Id = portalApplicationRightId,
					Is_Favorite__c = isFavorite
				);
				update par;
				return true;
			}
			else if(portalApplicationId != null){
				Portal_Application_Right__c par = new Portal_Application_Right__c(
					Portal_Application__c = portalApplicationId,
					Contact__c = DAL_ISSP.getUser(Userinfo.getUserId()).ContactId,
					Is_Favorite__c = isFavorite
				);
				insert par;
				return true;
			}
			return false;

		}
		catch(Exception ex){
			System.debug('ERROR ' + ex.getMessage());
			return false;
		}
	}

	@AuraEnabled
	public static Boolean createPortalApplicationRight(String portalApplicationId){
		try{
			Portal_Application_Right__c par = new Portal_Application_Right__c(
				Portal_Application__c = portalApplicationId,
				Contact__c = DAL_ISSP.getUser(Userinfo.getUserId()).ContactId,
				Last_Visit_Date__c = Datetime.now()
			);
			insert par;
			return true;
		}
		catch(Exception ex){
			System.debug('ERROR ' + ex.getMessage());
			return false;
		}
	}

	//This method is used when a portal admin is creating a new contact in the portal
	//It should retun all the services that he can assign to the contact he is creating
	@AuraEnabled(cacheable=true)
	public static List<Portal_Applications__c> getAvailableServicesForNewContact(){
		List<Portal_Applications__c> toReturn = new List<Portal_Applications__c>();
		for(Portal_Applications__c service : getPortalApplications()){
			if(!service.Cannot_be_managed_by_portal_admin__c){
				toReturn.add(service);
			}
		}
		return toReturn;
	}
	
		@AuraEnabled (cacheable=false)
	public static String verifyCompleteL3Data(String serviceId){

		Boolean requiredDataPopulated = true;
		Boolean latestToSAccepted = false;

		String resURL = '';

		User userAux = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

		Set<String> l3MandatoryFields = new Set<String>{
			'Birthdate'//, 'Shipping_Address__c'
		};

		Contact c = [SELECT Id, Name, Birthdate , Shipping_Address__c FROM Contact WHERE Id =: userAux.ContactId];
		for(String apiName: l3MandatoryFields){
			if(c.get(apiName) == null){
				requiredDataPopulated = false;
			}
		}

		List<Term_and_Condition__c> tos = [SELECT Id FROM Term_and_Condition__c WHERE NewGenApp_PortalService__c =: serviceId AND Is_Latest__c = true AND Status__c = 'Final'];
		system.assert(tos.size() == 1, 'Terms of Service data integrity compromised. Found none more than one active ToS for the service.');

		//check if the tos has been accepted
		List<Term_and_Condition_Acceptance__c> tosAccept = [SELECT Id, Is_Accepted__c FROM Term_and_Condition_Acceptance__c WHERE Term_Condition__c =:tos[0].Id AND Contact__c =: userAux.ContactId AND Is_Accepted__c = true];
		if(!tosAccept.isEmpty())
			latestToSAccepted = true;

		String baseUrl = Site.getBaseSecureUrl();
		String pathPrefix = Site.getPathPrefix().replace('/s', '');

		if(requiredDataPopulated && latestToSAccepted){
			String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Training_Contact_Role_Details__c', 'Yardstick_Trainee');


			List<AppMenuItem> ami = [SELECT StartUrl FROM AppMenuItem WHERE Name = 'Yardstick' LIMIT 1];
			// system.assert(!ami.isEmpty(), 'Connected app Yardstick does not exist.');

			Training_Contact_Role_Details__c tcrd = [SELECT Id,RecordTypeId,Account_Contact_Role__c,Username__c,UserId__c,Preferred_Course__c
															FROM Training_Contact_Role_Details__c
															WHERE Account_Contact_Role__r.Contact__c = :userAux.ContactId
															AND RecordTypeId = :RECTYPE_Trainee_YASContDet
															LIMIT 1];
			//https://preprod-customer-portal-iata.cs109.force.com/csportal/idp/login?app=0sp0Q0000008OTD&RelayState=
			resURL = baseUrl + pathPrefix + ami[0].StartUrl + '&RelayState=' + EncodingUtil.urlEncode(tcrd.Preferred_Course__c, 'UTF-8');
		}else{
			resURL = 'not_complete';
		}

		return resURL;
	}

	@AuraEnabled(cacheable=false)
	public static String getPortalServiceId(string serviceName){

		List<Portal_Applications__c> pas = [SELECT Id FROM Portal_Applications__c WHERE Name =: serviceName];
		system.assert(pas.size() == 1, 'Service data integrity excpetion. None or more than one service was found.');

		return pas[0].Id;
	}

}
