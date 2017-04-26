public class ANG_PortalApplicationRightHandler {

	public List<Portal_Application_Right__c> triggerNew = (List<Portal_Application_Right__c>) Trigger.new;
	public List<Portal_Application_Right__c> triggerOld = (List<Portal_Application_Right__c>) Trigger.old;

	public Map<Id, Portal_Application_Right__c> newMap = (Map<Id,Portal_Application_Right__c>) Trigger.newMap;
	public Map<Id, Portal_Application_Right__c> oldMap = (Map<Id,Portal_Application_Right__c>) Trigger.oldMap;

	//empty constructor (for trigger)
	public ANG_PortalApplicationRightHandler(){}

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onAfterInsert(){
		setConnectedAppsSSOPermission();
	}
	public void onAfterUpdate(){
		setConnectedAppsSSOPermission();
	}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************

	private void setConnectedAppsSSOPermission() {

		//fetch all connected app roles that need to grant a permission set
		Map<String, Connected_App_Roles__c> roles = new Map<String, Connected_App_Roles__c>();

		for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()){
			if(role.Permission_set_SSO__c != null){
				roles.put(role.Connected_App__c + ' - ' + role.Role__c, role);
			}
		}

		//no Connected app roles found
		if(roles.isEmpty()) return;

		ANG_PermissionSetHelper helper = new ANG_PermissionSetHelper();

		//filter Portal Services Accessses and create the change structure
		for(Portal_Application_Right__c access : triggerNew){

			Connected_App_Roles__c role = roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c);

			if (role == null) continue;

			String permissionSet = role.Permission_set_SSO__c;

			if(access.Right__c == 'Access Granted' && (Trigger.isInsert || oldMap.get(access.Id).Right__c != 'Access Granted')){

				helper.addPermission(permissionSet, access.Contact__c);
			}

			if(Trigger.isUpdate && access.Right__c != 'Access Granted' && oldMap.get(access.Id).Right__c == 'Access Granted'){
				
				helper.removePermission(permissionSet, access.Contact__c);
			}
			
		}

		//assign/remove users to the permission sets (must be future to prevent MIXED DML errors)
		if(helper.isChanged()) helper.enqueueJob(); 
	}

}