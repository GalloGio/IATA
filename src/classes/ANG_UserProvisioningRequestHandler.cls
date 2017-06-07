public with sharing class ANG_UserProvisioningRequestHandler {
	public List<UserProvisioningRequest> triggerNew = (List<UserProvisioningRequest>) Trigger.new;
	public List<UserProvisioningRequest> triggerOld = (List<UserProvisioningRequest>) Trigger.old;

	public Map<Id, UserProvisioningRequest> newMap = (Map<Id,UserProvisioningRequest>) Trigger.newMap;
	public Map<Id, UserProvisioningRequest> oldMap = (Map<Id,UserProvisioningRequest>) Trigger.oldMap;

	public ANG_UserProvisioningRequestHandler() {}

	public void onAfterUpdate() {
		checkIataEasyPayUserProvisioning();
	}

	public void onAfterInsert() {
		checkIataEasyPayUserProvisioning();
	}

	//
	// Find all failing EasyPay Provisioning request and delete their portal service access requests (Status = "Access requested")
	//
	public void checkIataEasyPayUserProvisioning() {

		Set<String> connectedAppRoles = new Set<String>();
		Set<String> iepNames = new Set<String>();

        for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()) {	
			if(role.Connected_App__c.contains('IATA EasyPay')) {
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
        												    contact__c 
                                                       From Portal_Application_Right__c 
                                                      Where contact__c in : contactsIds 
                                                        and Application_Name__c in : iepNames
                                                        and Right__c = 'Access Requested'];

		if(!parList.isEmpty()) {

			Map<Id, Portal_Application_Right__c> parMap = new Map<Id, Portal_Application_Right__c>();

			for(Portal_Application_Right__c par : parList) {
				parMap.put(par.Contact__c, par);
			}

			List<Portal_Application_Right__c> parToDelete = new List<Portal_Application_Right__c>();

			for(UserProvisioningRequest newUp : triggerNew) {
				if(connectedAppRoles.contains(newUp.AppName) && newUp.state == 'Failed') {
					parToDelete.add(parMap.get(userContact.get(newUp.SalesforceUserId)));
				}
			}

			delete parToDelete;
		}
	}
}