public class EF_PortalApplicationRightHandler {

	public List<Portal_Application_Right__c> triggerNew = (List<Portal_Application_Right__c>) Trigger.new;
	public Map<Id, Portal_Application_Right__c> oldMap = (Map<Id,Portal_Application_Right__c>) Trigger.oldMap;

	private final String APP_NAME = 'E&F APPS';
	private final String CONNAPP_NAME = 'E_F_APPS';
	private final String PERMISSIONSET_NAME = 'APPS_SSO';

	private List<Portal_Application_Right__c> grantedPARs = new List<Portal_Application_Right__c>();
	private List<Portal_Application_Right__c> removedPARs = new List<Portal_Application_Right__c>();

	private ConnectedApplication connApp;

	public EF_PortalApplicationRightHandler(){
		filterAccess();
	}

	public void onAfterInsert(){
		insertUserProvAccount();
		setConnectedAppsSSOPermission();
	}
	public void onAfterUpdate(){
		setConnectedAppsSSOPermission();
	}
	public void onAfterDelete() {
		setConnectedAppsSSOPermission();
	}

	private ConnectedApplication getConnApp(){
		if(connApp == null)
			connApp = [SELECT Id, Name FROM ConnectedApplication WHERE Name =: CONNAPP_NAME][0];

		return connApp;
	}
	
	private void insertUserProvAccount() {
		List<UserProvAccount> upal = new List<UserProvAccount>();

		Set<String> contactIds = new Set<String>();
		for(Portal_Application_Right__c access : grantedPARs) {
			contactIds.add(access.Contact__c);
		}

		Map<Id, User> mapUser = new Map<Id, User>();
		Set<Id> setUserId = new Set<Id>();

		for(User u: [SELECT id, ContactId, FederationIdentifier FROM User WHERE ContactId IN: contactIds]){
			mapUser.put(u.ContactId, u);
			setUserId.add(u.Id);
		}

		if(getConnApp() != null) return;

		String sConnId = String.valueOf(getConnApp().Id).left(15); //to be sure is same length;

		List<UserProvAccount> existingUPA = [SELECT ExternalUserId, ConnectedAppId FROM UserProvAccount WHERE SalesforceUserId IN: setUserId AND ConnectedAppId =: sConnId];

		if(!existingUPA.isEmpty()) return;

		for(Portal_Application_Right__c access : grantedPARs) {
	
			String sExtUserId = mapUser.get(access.Contact__c).FederationIdentifier == null ? access.Contact__c : mapUser.get(access.Contact__c).FederationIdentifier;

			UserProvAccount upa = new UserProvAccount (
				ExternalUserId = sExtUserId,
				SalesforceUserId = mapUser.get(access.Contact__c).Id,
				ConnectedAppId = getConnApp().Id,
				LinkState = 'Linked',
				Status = 'Active'
			);
			upal.add(upa);
		}

		System.debug(loggingLevel.FINE, '____ [cls EF_PortalApplicationRightHandler - insertUserProvAccount] upal - ' + upal);

		if(!upal.isEmpty())
			insert upal;
	}
	
	private void filterAccess(){
			
		if(Trigger.isInsert || Trigger.isUpdate){
			for(Portal_Application_Right__c access : triggerNew){
				if (access.Application_Name__c != APP_NAME) continue;

				if(access.Right__c == 'Access Granted' && (Trigger.isInsert || oldMap.get(access.Id).Right__c != 'Access Granted'))
					grantedPARs.add(access);
				else if(access.Right__c == 'Access Denied' && Trigger.isUpdate && oldMap.get(access.Id).Right__c != 'Access Denied')
					removedPARs.add(access);
			}
		}

		if(Trigger.isDelete){
			for(Portal_Application_Right__c accessDel : triggerOld){
				if (accessDel.Application_Name__c != APP_NAME) continue;
				
				removedPARs.add(accessDel);
			}
		}
	}

	private void setConnectedAppsSSOPermission() {

		ANG_PermissionSetHelper helper = new ANG_PermissionSetHelper();

		for(Portal_Application_Right__c access : grantedPARs){
			System.debug(loggingLevel.FINEST, '____ [cls EF_PortalApplicationRightHandler - setConnectedAppsSSOPermission] requested access - ' + access);
			System.debug(loggingLevel.FINEST, '____ [cls EF_PortalApplicationRightHandler - setConnectedAppsSSOPermission] connApp - ' + connApp);

			helper.addPermission(PERMISSIONSET_NAME, access.Contact__c);
			helper.setProvisioning(PERMISSIONSET_NAME, getConnApp().Name, getConnApp().Id);
		}

		for(Portal_Application_Right__c access : removedPARs){
			Connected_App_Roles__c role = roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c);
			System.debug(loggingLevel.ERROR, '____ [cls EF_PortalApplicationRightHandler - setConnectedAppsSSOPermission] removed access - ' + access);
			System.debug(loggingLevel.ERROR, '____ [cls EF_PortalApplicationRightHandler - setConnectedAppsSSOPermission] connApp - ' + connApp);

			helper.removePermission(PERMISSIONSET_NAME, access.Contact__c, getConnApp().Name, getConnApp().Id);
		}

		//assign/remove users to the permission sets (must be future to prevent MIXED DML errors)
		if(helper.isChanged()) helper.enqueueJob();
	}
}
