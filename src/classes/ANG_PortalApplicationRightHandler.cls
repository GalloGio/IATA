public class ANG_PortalApplicationRightHandler {

	public List<Portal_Application_Right__c> triggerNew = (List<Portal_Application_Right__c>) Trigger.new;
	public List<Portal_Application_Right__c> triggerOld = (List<Portal_Application_Right__c>) Trigger.old;

	public Map<Id, Portal_Application_Right__c> newMap = (Map<Id,Portal_Application_Right__c>) Trigger.newMap;
	public Map<Id, Portal_Application_Right__c> oldMap = (Map<Id,Portal_Application_Right__c>) Trigger.oldMap;

	private String connectedAppId;

	//empty constructor (for trigger)
	public ANG_PortalApplicationRightHandler(){}

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onAfterInsert(){
		insertUserProvAccount();
		setConnectedAppsSSOPermission();		
	}
	public void onAfterUpdate(){
		setConnectedAppsSSOPermission();
		checkMinimumUsersAllowedUpdate();
	}
	public void onBeforeDelete(){
		checkMinimumUsersAllowedDelete();
	}
	public void onAfterDelete() {
		setConnectedAppsSSOPermission();
	}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************

	private void insertUserProvAccount() {
		List<UserProvAccount> upal = new List<UserProvAccount>();

		Set<String> contactIds = new Set<String>();
		for(Portal_Application_Right__c access : filterRequestedAccess()) {
			contactIds.add(access.Contact__c);			
		}
		
		map<id, User> mapUser = new map<id, User>();
		set<id> setUserId = new set<id>();
		
		for(user u: [select id, ContactId, FederationIdentifier from User where ContactId in:contactIds]){
			mapUser.put(u.ContactId, u);
			setUserId.add(u.Id);
		}
		
		List<UserProvAccount> ExistingUPA = [Select ExternalUserId, ConnectedAppId From UserProvAccount Where SalesforceUserId in : setUserId];
		
		for(Portal_Application_Right__c access : filterRequestedAccess()) {
			if(roles.containsKey(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c)){
				string sConnId = roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c).Provisioning_Id__c;
				//It means it's IEP
				if(sConnId != '' && sConnId!=null){
					sConnId = sConnId.left(15); //to be sure is same length
					boolean UPAToCreate = true;
					for(UserProvAccount upa: ExistingUPA){
						if(string.ValueOf(upa.ConnectedAppId).left(15) == sConnId)
							UPAToCreate = false;
					}
					
					if(UPAToCreate){
						string sExtUserId = '';
						if(mapUser.get(access.Contact__c).FederationIdentifier==null)
							sExtUserId = access.Contact__c;
						else
		            		sExtUserId = mapUser.get(access.Contact__c).FederationIdentifier;
			            
						UserProvAccount upa = new UserProvAccount (
		            		ExternalUserId = sExtUserId,
			                SalesforceUserId = mapUser.get(access.Contact__c).Id,
			                ConnectedAppId = roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c).Provisioning_Id__c,
			                LinkState = 'Linked',
			                Status = 'Active'
			            );
			            upal.add(upa);
					}
				}
			}
		}
		
		System.debug(LoggingLevel.ERROR, 'INSERT UserProvAccount --> ' + upal);
		
		if(!upal.isEmpty())
			insert upal;
	}

	private void setConnectedAppsSSOPermission() {

		//no Connected app roles found
		if(roles.isEmpty()) return;

		ANG_PermissionSetHelper helper = new ANG_PermissionSetHelper();

		for(Portal_Application_Right__c access : filterRequestedAccess()){
			Connected_App_Roles__c role = roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_PortalApplicationRightHandler - setConnectedAppsSSOPermission] requested access - ' + access);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_PortalApplicationRightHandler - setConnectedAppsSSOPermission] role - ' + role);

			helper.addPermission(role.PermissionSet_Provisioning__c, access.Contact__c);
			helper.setProvisioning(role.PermissionSet_Provisioning__c, role);
		}

		for(Portal_Application_Right__c access : filterGrantedAccess()){
			Connected_App_Roles__c role = roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_PortalApplicationRightHandler - setConnectedAppsSSOPermission] granted access - ' + access);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_PortalApplicationRightHandler - setConnectedAppsSSOPermission] role - ' + role);

			helper.addPermission(role.Permission_set_SSO__c, access.Contact__c);
		}

		for(Portal_Application_Right__c access : filterRemovedAccess()){
			Connected_App_Roles__c role = roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c);
			System.debug(loggingLevel.ERROR, '____ [cls ANG_PortalApplicationRightHandler - setConnectedAppsSSOPermission] removed access - ' + access);
			System.debug(loggingLevel.ERROR, '____ [cls ANG_PortalApplicationRightHandler - setConnectedAppsSSOPermission] role - ' + role);

			helper.removePermission(role.Permission_set_SSO__c, access.Contact__c, role);
			helper.removePermission(role.PermissionSet_Provisioning__c, access.Contact__c, role);
		}

		//assign/remove users to the permission sets (must be future to prevent MIXED DML errors)
		if(helper.isChanged()) helper.enqueueJob(); 
	}

	// ************************************************************
	// ********************* helper methods ***********************
	// ************************************************************

	//fetch all connected app roles that need to grant a permission set
	private Map<String, Connected_App_Roles__c> roles{
		get{
			if(roles == null){
				roles = new Map<String, Connected_App_Roles__c>();
				for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()){
					if(role.Permission_set_SSO__c != null){
						roles.put(role.Connected_App__c + ' - ' + role.Role__c, role);
						connectedAppId = role.Provisioning_Id__c;
					}
				}

				System.debug(loggingLevel.FINEST, '____ [cls ANG_PortalApplicationRightHandler - setConnectedAppsSSOPermission] roles - ' + roles);
			}
			return roles;
		}
		set;
	}

	private List<Portal_Application_Right__c> filterRequestedAccess() {
		List<Portal_Application_Right__c> filter = new List<Portal_Application_Right__c>();
		if(Trigger.isInsert || Trigger.isUpdate){
			for(Portal_Application_Right__c access : triggerNew){

				if (roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c) == null) continue;
				else if(access.Right__c == 'Access Requested' && (Trigger.isInsert || oldMap.get(access.Id).Right__c != 'Access Requested')) filter.add(access);
			}
		}

		return filter;
	}

	private List<Portal_Application_Right__c> filterGrantedAccess() {
		List<Portal_Application_Right__c> filter = new List<Portal_Application_Right__c>();
		if(Trigger.isInsert || Trigger.isUpdate){
			for(Portal_Application_Right__c access : triggerNew){

				if (roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c) == null) continue;
				else if(access.Right__c == 'Access Granted' && (Trigger.isInsert || oldMap.get(access.Id).Right__c != 'Access Granted')) filter.add(access);
			}
		}

		return filter;
	}

	private List<Portal_Application_Right__c> filterRemovedAccess() {
		List<Portal_Application_Right__c> filter = new List<Portal_Application_Right__c>();

		if(Trigger.isUpdate){
			for(Portal_Application_Right__c access : triggerNew){

				if (roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c) == null) continue;
				else if(access.Right__c == 'Access Denied') filter.add(access);
			}
		}

		if(Trigger.isDelete){
			for(Portal_Application_Right__c access : triggerOld){

				if (roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c) == null) continue;
				else filter.add(access);
			}
		}

		return filter;
	}

	private void checkMinimumUsersAllowedDelete() {
		Set<Id> parSet = new Set<Id>();
		for(Portal_Application_Right__c access : triggerOld) {
			//
			// Only take in consideration IEP services
			//
			if(access.Application_Name__c.startsWith('IATA EasyPay') && access.Right__c == 'Access Granted') {
				parSet.add(access.id);
			}
		}	

		List<Portal_Application_Right__c> errorList	= ANG_PortalApplicationRightHelper.getCheckMinimumUsersAllowedErrorList(parSet);

		for(Portal_Application_Right__c par : errorList) {
			oldMap.get(par.id).addError(System.label.ANG_ISSP_Min_Users_With_Role_Error_Msg.replace('$$ROLE$$', par.ANG_Portal_Service_Role__c));
		}
	}

	private void checkMinimumUsersAllowedUpdate() {
		Set<Id> parSet = new Set<Id>();
		for(Portal_Application_Right__c access : triggerNew) {
			//
			// Only take in consideration IEP services
			//			
			if(access.Right__c == 'Access Denied' && access.Application_Name__c.startsWith('IATA EasyPay')) {
				parSet.add(access.id);	
			}						
		}

		List<Portal_Application_Right__c> errorList	= ANG_PortalApplicationRightHelper.getCheckMinimumUsersAllowedErrorList(parSet);

		for(Portal_Application_Right__c par : errorList) {
			newMap.get(par.id).addError(System.label.ANG_ISSP_Min_Users_With_Role_Error_Msg.replace('$$ROLE$$', par.ANG_Portal_Service_Role__c));
		}
	}	
}
