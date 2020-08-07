public class EF_PortalApplicationRightHandler {

	public List<Portal_Application_Right__c> triggerNew = (List<Portal_Application_Right__c>) Trigger.new;
	public List<Portal_Application_Right__c> triggerOld = (List<Portal_Application_Right__c>) Trigger.old;
	public Map<Id, Portal_Application_Right__c> oldMap = (Map<Id,Portal_Application_Right__c>) Trigger.oldMap;

	private final String APP_NAME = 'E&F APPS';

	private List<Portal_Application_Right__c> grantedPARs = new List<Portal_Application_Right__c>();
	private List<Portal_Application_Right__c> removedPARs = new List<Portal_Application_Right__c>();

	private String connAppId;
	private String connAppName;
	private String permissionSetName;

	public EF_PortalApplicationRightHandler(){
		filterAccess();
	}

	public void onAfterInsert(){
		if(grantedPARs.isEmpty()) return;
		getConnAppInfo();
		insertUserProvAccount();
		setConnectedAppsSSOPermission();
	}
	public void onAfterUpdate(){
		if(grantedPARs.isEmpty() && removedPARs.isEmpty()) return;
		getConnAppInfo();
		if(!grantedPARs.isEmpty()) insertUserProvAccount();
		setConnectedAppsSSOPermission();
	}
	public void onAfterDelete() {
		if(removedPARs.isEmpty()) return;
		getConnAppInfo();
		setConnectedAppsSSOPermission();
	}

	private void getConnAppInfo(){
		Connected_App_Roles__c cAR= Connected_App_Roles__c.getValues(APP_NAME);
		if(cAR == null) return;
		connAppId = cAR.Provisioning_Id__c;
		connAppName = cAR.Connected_App_Provisioning_Name__c;
		permissionSetName = cAR.PermissionSet_Provisioning__c;
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

		String sConnId = String.valueOf(connAppId).left(15); //to be sure is same length;

		List<UserProvAccount> existingUPA = [SELECT ExternalUserId, ConnectedAppId FROM UserProvAccount WHERE SalesforceUserId IN: setUserId AND ConnectedAppId =: connAppId];

		if(!existingUPA.isEmpty()) return;

		for(Portal_Application_Right__c access : grantedPARs) {
	
			String sExtUserId = mapUser.get(access.Contact__c).FederationIdentifier == null ? access.Contact__c : mapUser.get(access.Contact__c).FederationIdentifier;

			UserProvAccount upa = new UserProvAccount (
				ExternalUserId = sExtUserId,
				SalesforceUserId = mapUser.get(access.Contact__c).Id,
				ConnectedAppId = connAppId,
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
			System.debug(loggingLevel.FINEST, '____ [cls EF_PortalApplicationRightHandler - setConnectedAppsSSOPermission] connAppId - ' + connAppId);

			helper.addPermission(permissionSetName, access.Contact__c);
			helper.setProvisioning(permissionSetName, connAppName, connAppId);
		}

		for(Portal_Application_Right__c access : removedPARs){
			System.debug(loggingLevel.ERROR, '____ [cls EF_PortalApplicationRightHandler - setConnectedAppsSSOPermission] removed access - ' + access);
			System.debug(loggingLevel.ERROR, '____ [cls EF_PortalApplicationRightHandler - setConnectedAppsSSOPermission] connAppId - ' + connAppId);

			helper.removePermission(permissionSetName, access.Contact__c, connAppName, String.valueOf(connAppId));
		}

		//assign/remove users to the permission sets (must be future to prevent MIXED DML errors)
		if(helper.isChanged()) helper.enqueueJob();
	}
}
