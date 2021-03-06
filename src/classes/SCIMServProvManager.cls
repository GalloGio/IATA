public class SCIMServProvManager {

	public static boolean PREVENT_TRIGGER_RUN = false;
	public static final string PROD_SRV_PROV='IFG Prod';
	public static final string PRE_PROD_SRV_PROV='IFG PreProd';

	//IFG User Status Values
	public static final string IFG_USR_STS_PROD_AND_PRE_PROD='IFG_Active _Users';
	public static final string IFG_USR_STS_PRE_PROD='IFG_PreProduction_Active_User';
	public static final string IFG_USR_STS_PROD='IFG_Production_Active_User';

	//Record_Sharing_Criteria__c Values
	public static final string RSC_IFG_ACTIVE_USERS='IFG Active Users';

	//Status for field Technical_Provisioning_Status__c
	public static final string TECH_STS_EXT_ACCESS_DENIED='External Access Denied';
	public static final string TECH_STS_EXT_ACCESS_GRANTED='External Access Granted';
	public static final string TECH_STS_IATA_ACCESS_GRANTED='IATA Access Granted';
	public static final string TECH_STS_IATA_ACCESS_DENIED='IATA Access Denied';
	public static final string TECH_STS_PROV_FAIL='Fail';
	public static final string TECH_STS_REQUESTED='Access Requested';

	//Service status for IATA PErmissions rights
	public static final string IATA_STS_REQUESTED='Access Requested';
	public static final string IATA_STS_ACCESS_DENIED='Access Denied';
	public static final string IATA_STS_ACCESS_GRANTED='Access Granted';

	//Provision types
	public static final string PROV_TYP_SCIM='SCIM';
	public static final string PROV_TYP_WEB_SERV='Web Service';//AQUI


	/////////////////////////////////
	//SCIM ERRORS CODES:
	/////////////////////////////////
	public static final string ERR_SCIM_REST_INVALID_CONTEXT='ERR_SCIM_REST_INVALID_CONTEXT';
	public static final string ERR_SCIM_REST_INVALID_ROW_RESULT_EX_1='ERR_SCIM_REST_INVALID_ROW_RESULT';
	public static final string ERR_SCIM_APP_CONFIGURATION_MISSING='ERR_SCIM_APP_CONFIGURATION_MISSING';

	//mapp with errors messages
	public static final Map<String, String> mapCodMsg =
	new Map<String, String>{
			SCIMServProvManager.ERR_SCIM_REST_INVALID_CONTEXT => 'Inválid Context: flag value not expected for current context',
			SCIMServProvManager.ERR_SCIM_REST_INVALID_ROW_RESULT_EX_1 => 'Inválid row result: given search key returns zero or more than one rows, expected one row only!',
			SCIMServProvManager.ERR_SCIM_APP_CONFIGURATION_MISSING => 'Configuration NOT FOUND for given App Key'
	};

	//Exceptions debug mode active
	public static Boolean EXCEP_RSP_DEBUG_MODE_ACTIVE=true;


	public static Boolean isInitializedIATAServAccessMapOfApps=false;

	public One_Id_App_Config_Detail__c appConf{get;set;}

	private Map<String, One_Id_App_Config_Detail__c> mapAppConfList = new Map<String, One_Id_App_Config_Detail__c>();
	private List<String> listOfAppNames = new List<String>();
	private Set<Id> contactIdSet = new Set<Id>();
	private List<SCIMProvisioningRow> listOfProvRows = new List<SCIMProvisioningRow>();
	private Map<Id, User> mapContactUsers = new Map<Id, User>();

	public static List<Portal_Application_Right__c> portalAccessList = new List<Portal_Application_Right__c>();
	public static Set<id> portalAppsAccessSet = new Set<id>();
	public static Map<id, Portal_Applications__c> mapOfApps = new Map<id, Portal_Applications__c>();
	public static Set<id> portalAppsSet = new Set<Id>();


	//////////////////////////////////////
	// BEGIN SCIM EXCEptIon HANDLING CLASS
	//////////////////////////////////////
	public class SCIMException extends Exception{

		private String excepCode;
		private String excepMsg;
		private String spcMsg;

		public SCIMException(String spcCode, String spcMsg) {

			this.excepCode = spcCode;
			this.spcMsg=spcMsg;
			this.excepMsg=SCIMServProvManager.mapCodMsg.get(this.excepCode);

			if (EXCEP_RSP_DEBUG_MODE_ACTIVE){
				this.appendExcepMsg(this.spcMsg);
			}
			else{
				this.setMessage('Invalid request or Invalid request context!');
			}

		}

		public String getExcepCode(){
			return this.excepCode;
		}
		public String getExcepMsg(){
			return this.excepMsg;
		}

		public void appendExcepMsg(String spcMsg){
			this.excepMsg=this.excepMsg+'; SPECIFIC MESSAGE: '+spcMsg;
			this.setMessage(this.excepMsg+'; SYSTEM MSG EXCP:'+this.getMessage());
		}
	}
	//////////////////////////////////////
	// END SCIM EXCEptIon HANDLING CLASS
	//////////////////////////////////////



	public SCIMServProvManager(List<SCIMProvisioningRow> provRows){

		initSCIMProvisioningLists(provRows);
	}

	public SCIMServProvManager(string servProvName){
		List<String> myServProvNameList=new List<String> ();
		myServProvNameList.add(servProvName);

		initServiceConfig(myServProvNameList);

		this.appConf=mapAppConfList.get(servProvName);
	}

	private void initSCIMProvisioningLists(List<SCIMProvisioningRow> provRows){
		if(provRows != null && !provRows.isEmpty()){
			for(SCIMProvisioningRow row : provRows){
				this.listOfProvRows.add(row);
				this.listOfAppNames.add(row.scimAppName);
				this.contactIdSet.add(row.contactID);
			}

			initServiceConfig(this.listOfAppNames);

		}else{

			//TODO: throw an exception
		}
	}

	private void initServiceConfig(List<String> servProvNameList){

		List<One_Id_App_Config_Detail__c> apps = OneIdProvisioningDAO.getAppPermissionSetListForISSP(servProvNameList);

		for(One_Id_App_Config_Detail__c an : apps){
			mapAppConfList.put(an.One_Id_Service_Provider_Config__r.Service_Bundle__r.Service_Provider_Name__c , an);
		}

		List<User> listOfUsers = [select id, contactid from user where contactId = :contactIdSet];

		for(User anUser : listOfUsers){
			mapContactUsers.put(anUser.ContactId, anUser);
		}
	}


	static public void initIATAServAccessMapOfApps(List<Portal_Application_Right__c> serAccessList){
		portalAccessList = serAccessList;

		if (portalAccessList!=null) {
			for (Portal_Application_Right__c access : portalAccessList) {
				if (access.Portal_Application__c != null) {                    
					portalAppsSet.add(access.Portal_Application__c);				
				}
			}

			if (!portalAppsSet.isEmpty()) {
				for (Portal_Applications__c objCS :	[Select id,name, ServiceName__c ,Service_Description__c, SCIM_App_Name__c, Provisioning_Type__c	From Portal_Applications__c where id IN :portalAppsSet])
					mapOfApps.put(objCS.id, objCS);

			}
			for (Portal_Application_Right__c access : portalAccessList) {                
				if (access.Portal_Application__c != null && (mapOfApps.get(access.Portal_Application__c).SCIM_App_Name__c == PROD_SRV_PROV || mapOfApps.get(access.Portal_Application__c).SCIM_App_Name__c == PRE_PROD_SRV_PROV)){
					portalAppsAccessSet.add(access.Id);
				}
			}	
		}
	}

	public static String getSCIMAppNameFromId(Id IATAPortalApp){

		Portal_Applications__c resultApp;
		String result;

		resultApp=mapOfApps.get(IATAPortalApp);

		if (resultApp!=null)
			result=mapOfApps.get(IATAPortalApp).SCIM_App_Name__c;

		if (result==null) result='';

		return result;
	}

	public static Boolean isIFGServiceRow(Portal_Application_Right__c accessRow) {
		String appNameStr='';

		if (accessRow!=null)
			appNameStr=getSCIMAppNameFromId(accessRow.Portal_Application__c);

		if (appNameStr!=null) {
			return (
					appNameStr.equals(SCIMServProvManager.PRE_PROD_SRV_PROV) ||
					appNameStr.equals(SCIMServProvManager.PROD_SRV_PROV));
		}
		else{
			return false;
		}
	}
	public static Boolean isSCIMUserServiceProv(Portal_Application_Right__c accessRow){
		return  (mapOfApps.containsKey(accessRow.Portal_Application__c)
				&& (   mapOfApps.get(accessRow.Portal_Application__c).Provisioning_Type__c != null
						&& mapOfApps.get(accessRow.Portal_Application__c).Provisioning_Type__c.equals(PROV_TYP_SCIM)
				)
		);
	}

	public void populateFederationIds(){
		List<User> usersListToUpdate=new List<User>();
		List<User> usersList=[SELECT Id, FederationIdentifier FROM User WHERE ContactId IN :contactIdSet];

		for (User userItem:usersList){
			//If federation id is blank or null update it
			if (String.isBlank(userItem.FederationIdentifier)){
				User uToUp=new User();
				uToUp.Id=userItem.Id;
				uToUp.FederationIdentifier=userItem.Id;
				usersListToUpdate.add(uToUp);
			}
		}

		if(!usersListToUpdate.isEmpty())  update usersListToUpdate;
	}

	public void sendToSCIMProvisioning(){
		List<String> recipients = new List<String>();
		List<String> ccs = new List<String>();
		List<One_Id_User_Applications__c> userAppsIn = new List<One_Id_User_Applications__c>();

		List<One_Id_User_Applications__c> userAppsUpdate = new List<One_Id_User_Applications__c>();
		List<One_Id_User_Applications__c> toUpdate = new List<One_Id_User_Applications__c>();

		Set<String> keySet = new Set<String>();
		for(SCIMProvisioningRow aRow : listOfProvRows){

			One_Id_User_Applications__c anUserApp = new One_Id_User_Applications__c();
			anUserApp.Application__c = mapAppConfList.get(aRow.scimAppName).id;
			anUserApp.Identity_User__c = mapContactUsers.get(aRow.contactID).id;
			anUserApp.One_Id_App_Bundle__c = mapAppConfList.get(aRow.scimAppName).One_Id_Service_Provider_Config__r.Service_Bundle__r.id;
			anUserApp.One_Id_Service_Provider_Config__c = mapAppConfList.get(aRow.scimAppName).One_Id_Service_Provider_Config__r.id;
			anUserApp.Provisioning_Status__c = LightningConnectedAppHelper.OID_USER_APP_STATUS_STARTED;
			anUserApp.App_Key__c  = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp);
			anUserApp.Action__c = aRow.action;
			anUserApp.Portal_Service_Access__c = aRow.appRightId;

			if(aRow.action.equals('Add'))
				userAppsIn.add(anUserApp);
			else {
				userAppsUpdate.add(anUserApp);
				keySet.add(anUserApp.App_Key__c);
			}
		}

		if(!userAppsIn.isEmpty()) insert userAppsIn;

		if(!userAppsUpdate.isEmpty()){
			Map<String, One_Id_User_Applications__c> mapOfAppsAux = new Map<String, One_Id_User_Applications__c>();
			for(One_Id_User_Applications__c anUsrApp : userAppsUpdate){
				mapOfAppsAux.put(anUsrApp.App_Key__c, anUsrApp);
			}

			List<One_Id_User_Applications__c> allList =
			[select id, User_Provisioning_Request__c,App_Key__c
				from One_Id_User_Applications__c
				where App_Key__c in :mapOfAppsAux.keySet()];

			for(One_Id_User_Applications__c anApp : allList){
				One_Id_User_Applications__c toUp = new One_Id_User_Applications__c();
				toUp.id = anApp.id;
				toUp.User_Provisioning_Request__c = mapOfAppsAux.get(anApp.App_Key__c).User_Provisioning_Request__c;
				toUp.Action__c = mapOfAppsAux.get(anApp.App_Key__c).Action__c;
				toUp.Provisioning_Status__c = mapOfAppsAux.get(anApp.App_Key__c).Provisioning_Status__c;
				toUpdate.add(toUp);
			}

			if(!toUpdate.isEmpty()) update toUpdate;
		}

		//Send email to daemon
		if(!Test.isRunningTest()){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			recipients.add(SCIM_Prov_Connector__c.getOrgDefaults().Processor_Email__c);
			mail.setSubject('Awake up to work');
			mail.setToAddresses(recipients);
			ccs.add(SCIM_Prov_Connector__c.getOrgDefaults().FYI_Email__c);
			mail.setCcAddresses(ccs);
			mail.setPlainTextBody('Text');
			Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });			
		}
	}

	public class SCIMProvisioningRow{

		Id contactID;
		Id appRightId;
		String scimAppName;
		String action;

		public SCIMProvisioningRow(Id contactid, String appName, Id appRightId, String action){
			this.contactID = contactid;
			this.scimAppName = appName;
			this.appRightId = appRightId;
			this.action = action;
		}
	}



	public static void syncTechProvStatus(List<Portal_Application_Right__c> newListObj, map<Id, Portal_Application_Right__c> oldObjMap){

		Set<Id> servIds=new Set<Id>();
		for (Portal_Application_Right__c item : newListObj){
			servIds.add(item.Portal_Application__c);
		}

		//get Apps/Services Mapp
		Map<Id, Portal_Applications__c> servMap = new Map<Id, Portal_Applications__c> (
			[SELECT Id, Provisioning_Type__c from Portal_Applications__c WHERE Id IN :servIds]);



		for(Portal_Application_Right__c right : newListObj){
			if(System.Trigger.isUpdate && System.Trigger.isBefore ) {
				Portal_Application_Right__c oldAccess = oldObjMap.get(right.Id);
				if((right.Right__c != null && oldAccess.Right__c != null)
						&& right.Right__c != oldAccess.Right__c
						&& servMap.get(right.Portal_Application__c).Provisioning_Type__c!=null
						&& servMap.get(right.Portal_Application__c).Provisioning_Type__c.equals(PROV_TYP_SCIM)

				) {
					if (right.Right__c.equals(IATA_STS_ACCESS_GRANTED)){						
						right.Technical_Provisioning_Status__c = TECH_STS_IATA_ACCESS_GRANTED;
					}
					else if (  right.Right__c.equals(IATA_STS_ACCESS_DENIED)
							&& right.Technical_Provisioning_Status__c != null
							&& !right.Technical_Provisioning_Status__c.equals(SCIMServProvManager.TECH_STS_EXT_ACCESS_DENIED)
					){
						right.Technical_Provisioning_Status__c = TECH_STS_IATA_ACCESS_DENIED;
					}

				}
			}else if(System.Trigger.isInsert && System.Trigger.isBefore ) {
				if(right.Right__c != null && right.Right__c.equals(IATA_STS_ACCESS_GRANTED)
					 //&& right.Portal_Application__r.Provisioning_Type__c.equals(PROV_TYP_SCIM)
						&& servMap.get(right.Portal_Application__c).Provisioning_Type__c!=null
						&& servMap.get(right.Portal_Application__c).Provisioning_Type__c.equals(PROV_TYP_SCIM)
				  ) {
					right.Technical_Provisioning_Status__c = TECH_STS_IATA_ACCESS_GRANTED;
				}
			}
		}
	}

	public void setExternalAccessGranted(Portal_Application_Right__c serviceRqRow, id userId){

		SCIMServProvManager.addPermissionSet(
				userId,
				appConf.PermissionSet_SSO__c);

		serviceRqRow.Technical_Provisioning_Status__c = SCIMServProvManager.TECH_STS_EXT_ACCESS_GRANTED;

		update serviceRqRow;
	}

	public void setExternalAccessDenied(Portal_Application_Right__c serviceRqRow){

		serviceRqRow.Technical_Provisioning_Status__c = SCIMServProvManager.TECH_STS_EXT_ACCESS_DENIED;
		serviceRqRow.Right__c = SCIMServProvManager.IATA_STS_ACCESS_DENIED;
		serviceRqRow.Access_Status_Reason__c= Label.IFG_Prov_Declined;

		update serviceRqRow;
	}

	@future
	public static void setPortalAccessRightProvTechStatus(Id userId, String anAppkey, String techStatus){

		User u=[select ContactId from user where id =:userId];

		Portal_Application_Right__c ServiceRq=
		[Select p.Name, p.Application_Name__c, p.Right__c, p.PortalServiceTranslatedName__c , p.Portal_Application__r.Description__c,
				p.Portal_Application__r.Cannot_be_managed_by_portal_admin__c, p.Portal_Application__r.Requestable__c, p.Application_icon_del__c,
				p.Portal_Application__r.New_Window__c,p.Technical_Provisioning_Status__c, Portal_Application__r.SCIM_App_Name__c,
				p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__c,
				p.My_Apps__c, p.Contact__c,p.Contact__r.Name, p.Contact__r.AccountId, p.Application_Start_URL__c ,
				p.Case_creation_record_Type__c,p.Access_Status_Reason__c, p.Contact__r.User_Portal_Status__c
				From Portal_Application_Right__c p
				where p.Contact__r.Id = :u.ContactId
					and p.Portal_Application__r.Provisioning_Type__c = :SCIMServProvManager.PROV_TYP_SCIM
					and p.Portal_Application__r.SCIM_App_Name__c=:anAppkey
		];

		if (techStatus.equals(SCIMServProvManager.TECH_STS_PROV_FAIL)) {
			ServiceRq.Technical_Provisioning_Status__c = SCIMServProvManager.TECH_STS_PROV_FAIL;
			ServiceRq.Access_Status_Reason__c = Label.IFG_Prov_Failed;
			if (ServiceRq.Right__c!=null
					&& ServiceRq.Right__c.equals(SCIMServProvManager.IATA_STS_ACCESS_GRANTED)){
				ServiceRq.Right__c = SCIMServProvManager.IATA_STS_REQUESTED;
			}
		}
		else {
			ServiceRq.Technical_Provisioning_Status__c = techStatus;
		}

		Update ServiceRq;
	}

	@future
	public static void deleteProvRelatedPermissionSets(Set<id> oneIdUserApps){
		Set<String> permissionsetNamesToRemove = new Set<String>();
		Set<Id> usersList = new Set<Id>();
		Map<String, Id> mapPerm = new Map<String, Id>();

		if(oneIdUserApps.isEmpty()) return;

		List<One_Id_User_Applications__c> workToProcess = [select id,Action__c, Application__c,Application__r.Connected_App_Provisioning_Name__c, Application__r.PermissionSet_SSO__c, Application__r.PermissionSet_Provisioning__c, Identity_User__c,One_Id_App_Bundle__c,One_Id_Service_Provider_Config__c,Provisioning_Status__c
				from One_Id_User_Applications__c where id = :oneIdUserApps] ;

		for(One_Id_User_Applications__c anUap : workToProcess){
			permissionsetNamesToRemove.add(anUap.Application__r.PermissionSet_Provisioning__c);
			permissionsetNamesToRemove.add(anUap.Application__r.PermissionSet_SSO__c);
			usersList.add(anUap.Identity_User__c);
		}

		List<PermissionSet> listOfPermS = [SELECT id, name FROM PermissionSet WHERE name = :permissionsetNamesToRemove];

		for(PermissionSet ap : listOfPermS){
			mapPerm.put(ap.name, ap.id);
		}

		List<PermissionSetAssignment> toDelete = [SELECT AssigneeId,Id,PermissionSetId FROM PermissionSetAssignment where AssigneeId in :usersList and PermissionSetId in :mapPerm.values()];

		delete toDelete;
	}
	@future
	public static void deleteOneIdProvRows(Set<id> oneIdUserApps){

		if(oneIdUserApps.isEmpty()) return;


		List<One_Id_User_Applications__c> listOne = new List<One_Id_User_Applications__c>();
		for(id anId : oneIdUserApps){
			One_Id_User_Applications__c anObj = new One_Id_User_Applications__c();
			anObj.id = anId;
			listOne.add(anObj);
		}

		delete listOne;
	}

	@future
	public static void addPermissionSet(id userId, string permissionSetNameToAdd){
		Id permissionSetIdToAdd;

		//Get permission id
		permissionSetIdToAdd = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetNameToAdd LIMIT 1].Id;

		PermissionSetAssignment permissionToAdd = new PermissionSetAssignment();
		permissionToAdd.AssigneeId=userId;
		permissionToAdd.PermissionSetId=permissionSetIdToAdd;

		insert permissionToAdd;
	}

	@future
	public static void reviewIFGUserStatusAndContactSharing(Set<Id> listOfPortalAccessRows){
		if(!SCIMServProvManager.PREVENT_TRIGGER_RUN) SCIMServProvManager.PREVENT_TRIGGER_RUN = true;

		Map<id, Contact> updateContactList = new Map<id, Contact>();
		Map<id, String> contactRecSharingCritMapp = new Map<id, String>();
		Set<id> allContactsKeys = new Set<id>();

		String recordSharingCriteriaValue;
		String recordUserStatusValue;
		String recordSharingCriteriaValuePickListVal;

		List<Portal_Application_Right__c> ServiceAccList = [select Id, Right__c, Contact__c, Portal_Application__c, Contact__r.Record_Sharing_Criteria__c
		FROM Portal_Application_Right__c
		WHERE Id = :listOfPortalAccessRows];

		for (Portal_Application_Right__c conItem: ServiceAccList){
			allContactsKeys.add(conItem.Contact__c);
		}

		List<Contact> allContactsList=[SELECT Id, Record_Sharing_Criteria__c, Record_Sharing_Criteria_AUX__c, Name  FROM Contact WHERE Id IN :  allContactsKeys];
		for (Contact conItem : allContactsList){
			contactRecSharingCritMapp.put(conItem.Id, conItem.Record_Sharing_Criteria__c);
		}

		SCIMServProvManager.initIATAServAccessMapOfApps(ServiceAccList);

		for (Portal_Application_Right__c item : ServiceAccList){
			recordSharingCriteriaValue= '';
			recordUserStatusValue='';

			//Setting IFG_User_Status__c values
			if (!item.Right__c.equals(SCIMServProvManager.IATA_STS_ACCESS_DENIED)){

				//Set Record_Sharing_Criteria__c values
				if (isIFGServiceRow(item)) {
					recordSharingCriteriaValue = RSC_IFG_ACTIVE_USERS;
					recordSharingCriteriaValuePickListVal=multiSelectPickListAppendValue(contactRecSharingCritMapp.get(item.Contact__c),RSC_IFG_ACTIVE_USERS);
				}
				else{
					recordSharingCriteriaValuePickListVal=multiSelectPickListDeleteValue(contactRecSharingCritMapp.get(item.Contact__c),RSC_IFG_ACTIVE_USERS);
				}
			}
			else{
				recordSharingCriteriaValuePickListVal=multiSelectPickListDeleteValue(contactRecSharingCritMapp.get(item.Contact__c),RSC_IFG_ACTIVE_USERS);
			}

			//item add updates to Update contact list
			Contact anContact = new Contact(
					id = item.Contact__c,
					//IFG_User_Status__c = recordUserStatusValue,
					//Record_Sharing_Criteria_AUX__c = recordSharingCriteriaValue
					Record_Sharing_Criteria__c=recordSharingCriteriaValuePickListVal
			);
			updateContactList.put(item.Contact__c, anContact);
		}

		if(!updateContactList.isEmpty()) update updateContactList.values();
	}

	public static String multiSelectPickListAppendValue(String PickListCurrentValues, String ValueToAppend){
		if (PickListCurrentValues==null) return ValueToAppend;

		string[] arrayPickListCurrValues=PickListCurrentValues.split(';');
		for (String itemValStr:arrayPickListCurrValues){
			//If value already there return given list and do need to do nothing
			if (itemValStr.equals(ValueToAppend)){
				return PickListCurrentValues;
			}
		}

		//If not already there add new item to list
		arrayPickListCurrValues.add(ValueToAppend);
		return string.join(arrayPickListCurrValues,';')+';';
	}
	public static String multiSelectPickListDeleteValue(String PickListCurrentValues, String ValueToDelete){
		if (PickListCurrentValues==null) return '';

		string[] arrayPickListCurrValues=PickListCurrentValues.split(';');
		string[] resultArray=new List<String>();
		for (String itemValStr : arrayPickListCurrValues){
			//If value already there return given list and do need to do nothing
			if (!itemValStr.equals(ValueToDelete)){
				resultArray.add(itemValStr);
			}
		}

		//If not already there add new item to list
		return string.join(resultArray,';')+';';
	}

}
