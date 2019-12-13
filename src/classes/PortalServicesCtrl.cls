public with sharing class PortalServicesCtrl {


Public static final String PORTAL_ACCESS_GRANTED='Access Granted';
Public static final String PORTAL_ACCESS_REQUESTED='Access Requested';
Public static final String PORTAL_ACCESS_DENIED='Access Denied';
Public static final String PORTAL_USER_PENDING_APPR='Pending Approval';
Public static final String PORTAL_USER_APPROVED='Approved User';
Public static final String WILDCARD = 'ALL';

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
						 'ANG_Flag_Restrict_Accredited_Agent__c, ANG_Flag_Restrict_Sector__c, ServiceName__c ';

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
		if (pApp.Name == 'Insurance Providers' || pApp.Name == 'Financial Securities') {
			if (((con.Account.Sector__c == 'Travel Agent' || con.Account.Sector__c == 'Cargo Agent')
				 && con.Account.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency')) &&
				(allowedLocTypes.contains(con.Account.Location_Type__c) || con.Account.Is_Branch_Abroad__c == 'Yes') &&
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
@AuraEnabled (cacheable=false)
public static List<Portal_Application_Right__c> getUsersFavoriteServicesList(String contactId){

	//base query
	String finalQuery = 'SELECT Id, Application_Name__c, PortalServiceTranslatedName__c ,Portal_Application__r.Description__c, '+
						'Portal_Application__r.Requestable__c, Application_icon_del__c, IsSCIMIFG__c, ' +
						'Portal_Application__r.New_Window__c, Right__c, Portal_Application__r.Application_icon_URL__c, ' +
						'Portal_Application__r.Name, Portal_Application__c, My_Apps__c, Contact__c, ' +
						'Application_Start_URL__c,Technical_Provisioning_Status__c, Case_creation_record_Type__c, ' +
						'Portal_Application__r.Service_Description__c, Portal_Application__r.Service_Description_Label__c  ' +
						'FROM Portal_Application_Right__c ' +
						'WHERE (Contact__c = \'' + contactId + '\' AND '+
						'   Right__c = \'Access Granted\' AND ' +
						'   Portal_Application__r.Hide_on_Homepage__c = false)';


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

	if(!lstPortalApplications.isEmpty()) {
		for(Portal_Applications__c pa : lstPortalApplications) {
			// for(Portal_Application_Right__c par : lstPortalApplicationsRights) {
			//     if(par.Portal_Application__c == pa.Id) {
			Portal_Application_Right__c lstPar = new Portal_Application_Right__c();
			lstPar.Portal_Application__r = pa;
			lstPortalApplicationsRights.add(lstPar);
			//         break;
			//     }
			// }
		}
	}

	return lstPortalApplicationsRights;
}

@AuraEnabled(cacheable=true)
public static String paymentLinkRedirect(){

	User userAux = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

	Contact con = [Select id, Credit_Card_Payment_Link__c from Contact where id =:userAux.ContactId];

	if(con.Credit_Card_Payment_Link__c != null) {
		return con.Credit_Card_Payment_Link__c;
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
	List<String> requestableAppNameList = getVisibleApplicationNames(userAux.Contact.Account);

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
	User userAux = [SELECT Id, ContactId, Contact.Account.ANG_IEP_Status_FF__c FROM User WHERE Id = :UserInfo.getUserId()];
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
		mapServiceWrapper.put(portalAppAux.Id, new ServiceWrapper(portalAppAux, isAdmin, iepStatus, isAuthorisedSignatory, ''));
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
								  new ServiceWrapper(mapAppsAlreadyWithAccess.get(accessAux.Portal_Application__c), isAdmin, iepStatus, isAuthorisedSignatory, accessAux.Right__c));
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
		if(serviceWrapperAux.status == PortalServicesCtrl.PORTAL_ACCESS_REQUESTED) {
			lstToReturn.add(serviceWrapperAux);
		}
	}

	return lstToReturn;
}

public static Map<Id,List<ServiceWrapper> > getContactsAccessGrantedServices(Map<Id,Id> contactToUserIds){

	Map<Id,List<ServiceWrapper> > contactToServices = new Map<Id,List<ServiceWrapper> >();

	List<Portal_Application_Right__c > usersGrantedList = [select id,Application_Name__c,Right__c,Portal_Application__r.ServiceName__c,Portal_Application__r.Id,Portal_Application__r.Application_URL__c,Contact__r.Account.ANG_IEP_Status_FF__c
														   from Portal_Application_Right__c
														   where Contact__c IN:contactToUserIds.keySet() AND Right__c =: PORTAL_ACCESS_GRANTED];


	System.debug('get Users '+contactToUserIds.values());
	Map<Id,User> userInfos = new Map<Id,User>([SELECT Id,ContactId,ProfileId from User WHERE Id in: contactToUserIds.values()]);

	Map<String,ServiceWrapper> mapServiceWrapper = new Map<String,ServiceWrapper>();
	for(Portal_Application_Right__c accessRight : usersGrantedList) {

		String iepStatus = accessRight.Contact__r.Account.ANG_IEP_Status_FF__c;
		System.debug('get User '+accessRight.Contact__c);
		System.debug('get User2 '+userInfos.get(contactToUserIds.get(accessRight.Contact__c)));

		Boolean isAdmin = ISSP_Constant.adminIdSet.contains(userInfos.get(contactToUserIds.get(accessRight.Contact__c)).ProfileId);

		Portal_Applications__c portalAppAux = new Portal_Applications__c(Id=accessRight.Portal_Application__r.Id,Application_URL__c=accessRight.Portal_Application__r.Application_URL__c,Name=accessRight.Application_Name__c);

		ServiceWrapper wrap = new ServiceWrapper(portalAppAux, isAdmin, iepStatus,false, '');

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

	List<ServiceWrapper> lstToReturn = new List<ServiceWrapper>();
	for(ServiceWrapper serviceWrapperAux : lstAllServices) {
		if(serviceWrapperAux.status == PortalServicesCtrl.PORTAL_ACCESS_GRANTED) {
			lstToReturn.add(serviceWrapperAux);
		}
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
public static PagedResult getUserFilteredServices(String searchKey, String requestedPage){

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
			temp = new ServiceWrapper(lstServicesAux.get(0), isAdmin, iepStatus, isAuthorisedSignatory, '');
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
// this method only used when not alll records are loaded on the client side
@AuraEnabled (cacheable=false)
public static List<ContactWrapper> searchContactsInService(string serviceId,string searchkey){
	string filter=' AND (contact__r.name LIKE \'%'+searchkey +'%\' or contact__r.email like \'%{0}%\' or contact__r.account.IATACode__c like \'%{0}%\' or contact__r.account.BillingCity like \'%{0}%\')'.replace('{0}',searchkey);
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



public ContactWrapper(Portal_Application_Right__c par){
	this.contactId=par.contact__c;
	this.contactName=par.contact__r.name;
	this.emailAddress=par.contact__r.email;
	this.iataCodeLoc=par.contact__r.Account.iataCode__C+' ('+par.Contact__r.Account.BillingCity+')';
	this.userPortalStatus=par.contact__r.user_portal_status__c;
	this.serviceRight= par.right__C;

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


	if(sw.status==PortalServicesCtrl.PORTAL_ACCESS_GRANTED ) {
		sw.btnLabel =System.Label.CSP_Services_GoToService;
		sw.accessGranted =true;
		sw.accessRequested =false;
	}else if(sw.status==PortalServicesCtrl.PORTAL_ACCESS_REQUESTED) {
		sw.btnLabel = System.Label.ISSP_Access_Requested;
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
public static String serviceWrapperRedirect(String serviceId){

	User currentPortalUser = [SELECT id, contact.account.ANG_IEP_Status_FF__c, contact.Authorized_Signatory__c, contact.User_Portal_Status__c
							  FROM User
							  WHERE id =: UserInfo.getUserId()];


	Boolean isAdmin = (currentPortalUser.contact.User_Portal_Status__c == 'Approved Admin');

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

	return [SELECT Id,name,email FROM Contact WHERE User_Portal_Status__c = : ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM AND (Account.Top_Parent__c =: u.contact.AccountId OR AccountId = : u.contact.AccountId)];
}

/**
	Returns a list of all visible application names for the input account
	according to the Custom Metadata Portal_Application_Setting__mdt
 **/
@TestVisible
private static List<String> getVisibleApplicationNames(Account account) {
	// Get the list of services visible for thi input account based on the Custom metadata Portal_Application_Setting__mdt
	List<String> requestableAppNameList = new List<String>();
	if (account==null) return requestableAppNameList;
	for (Portal_Application_Setting__mdt setting: [
			 SELECT id, MasterLabel,
			 (SELECT Sector__c, Category__c
			  FROM Portal_Application_Visibilities__r
			  WHERE is_Visible__c = true
									AND Sector__c = :account.Sector__c
													AND Category__c IN (:account.Category__c,:WILDCARD))
			 FROM Portal_Application_Setting__mdt]) {
		if (setting.Portal_Application_Visibilities__r.size()>0) {
			requestableAppNameList.add(setting.MasterLabel);
		}
	}
	return requestableAppNameList;
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
	public static Boolean changeIsFavoriteStatus(String portalApplicationRightId, Boolean isFavorite){
		try{
			System.debug('ID : ' + portalApplicationRightId);
			Portal_Application_Right__c par =[SELECT Id, Is_Favorite__c FROM Portal_Application_Right__c WHERE Id =: portalApplicationRightId];
			par.Is_Favorite__c = isFavorite;
			update par;
			return true;
		}
		catch(Exception ex){
			System.debug(ex.getMessage());
			return false;
		}
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

		System.debug('resURL: ' + resURL);

		return resURL;
	}

	@AuraEnabled(cacheable=false)
	public static String getPortalServiceId(string serviceName){

		system.debug('serviceName: ' + serviceName);
		List<Portal_Applications__c> pas = [SELECT Id FROM Portal_Applications__c WHERE Name =: serviceName];
		system.assert(pas.size() == 1, 'Service data integrity excpetion. None or more than one service was found.');

		return pas[0].Id;
	}
}