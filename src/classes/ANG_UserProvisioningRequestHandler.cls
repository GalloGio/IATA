public class ANG_UserProvisioningRequestHandler {
	public List<UserProvisioningRequest> triggerNew = (List<UserProvisioningRequest>) Trigger.new;
	public List<UserProvisioningRequest> triggerOld = (List<UserProvisioningRequest>) Trigger.old;

	public Map<Id, UserProvisioningRequest> newMap = (Map<Id,UserProvisioningRequest>) Trigger.newMap;
	public Map<Id, UserProvisioningRequest> oldMap = (Map<Id,UserProvisioningRequest>) Trigger.oldMap;

	public ANG_UserProvisioningRequestHandler() {}

	public void onAfterUpdate() {
		checkUserProvisioning();
	}

	/*public void onAfterInsert() {
		checkIataEasyPayUserProvisioning();
	}*/

	//
	// Find all failing EasyPay or GDI Provisioning request and delete their portal service access requests (Status = "Access requested")
	//
	public void checkUserProvisioning() {

		Set<String> connectedAppRoles = new Set<String>();
		Set<String> iepNames = new Set<String>();

        for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()) {	
			if(role.Connected_App__c != null && (role.Connected_App__c.contains('IATA EasyPay') || role.Connected_App__c.contains('Global Default Insurance'))) {
				connectedAppRoles.add(role.Connected_App_Provisioning_Name__c);
				iepNames.add(role.Connected_App__c);
			}
        }

        Set<Id> usersIds = new Set<Id>();
        for(UserProvisioningRequest newUp : triggerNew) {
        	usersIds.add(newUp.SalesforceUserId);
        }

        List<User> users = [Select id, ContactId from User where id in : usersIds];

		Set<Id> contactsIds = new Set<Id>();
		Map<id, id> userContact = new Map<id, id>();
        for(User user : users) {
        	contactsIds.add(user.ContactId);
        	userContact.put(user.Id, user.ContactId);
        }

        List<Portal_Application_Right__c> parList = [Select id,
        												    contact__c,
        												    Application_Name__c,
        												    ANG_Portal_Service_Role__c
                                                       From Portal_Application_Right__c 
                                                      Where contact__c in : contactsIds 
                                                        and Application_Name__c in : iepNames
                                                        and Right__c = 'Access Requested'];

		if(!parList.isEmpty()) {

			Map<String, Portal_Application_Right__c> parMap = new Map<String, Portal_Application_Right__c>();

			for(Portal_Application_Right__c par : parList) {
				String provisioningApp = roles.get(par.Application_Name__c + ' - ' + par.ANG_Portal_Service_Role__c).Connected_App_Provisioning_Name__c;
				parMap.put(par.Contact__c+provisioningApp, par);
			}

			List<Portal_Application_Right__c> parToDelete = new List<Portal_Application_Right__c>();
			List<ISSP_Web_Service_Log__c> logs = new List<ISSP_Web_Service_Log__c>();

			for(UserProvisioningRequest newUp : triggerNew) {
				if(connectedAppRoles.contains(newUp.AppName) && newUp.State == 'Failed') {

					logs.add(getErrorLogEntry(userContact.get(newUp.SalesforceUserId),
											  newUp.ConnectedAppId,
											  newUp.State,
											  newUp.Id));

					parToDelete.add(parMap.get(userContact.get(newUp.SalesforceUserId)+newUp.AppName));
				}
			}

			delete parToDelete;
			insert logs;
		}
	}

	private static ISSP_Web_Service_Log__c getErrorLogEntry(Id contactId, Id connectedAppId, String state, Id uprId) {
		String soqlQuery = 'SELECT CreatedDate, Details, Status, SystemModstamp, UserId, UserProvisioningRequestId FROM UserProvisioningLog where UserProvisioningRequestId = \'' + uprId + '\'';

		ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c(
			Contact__c = contactId,
			Web_Service__c = connectedAppId,
			Method__c = 'User Provisioning',
			Error_Code__c = state,
			Error_Message__c = 'Error provisioning user \n(Use following SOQL query to further details on the provisioning error : ' + soqlQuery + ')',
			Success__c = false
		);
		return log;
	}


	private Map<String, Connected_App_Roles__c> roles{
		get{
			if(roles == null){
				roles = new Map<String, Connected_App_Roles__c>();
				for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()){
					if(role.Permission_set_SSO__c != null){
						roles.put(role.Connected_App__c + ' - ' + role.Role__c, role);
					}
				}
				
			}
			return roles;
		}
		set;
	}
}