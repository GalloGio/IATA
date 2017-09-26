public class ANG_PermissionSetHelper {

	// ************************************************************
	// ************************ variables *************************
	// ************************************************************

	private Map<String, PermissionChange> changes{
		get{
			if(changes == null) changes = new Map<String, PermissionChange>();
			return changes;
		}
		set;
	}
	private Boolean permissionsChanged = false;

	// ************************************************************
	// *********************** constructors ***********************
	// ************************************************************

	public ANG_PermissionSetHelper(){}

	//constructor to use the managePermissions method with a single permission set (not in use right now)
	/*public ANG_PermissionSetHelper(String permissionSet, Set<Id> contactsToAdd, Set<Id> contactsToRemove){
		PermissionChange change = new PermissionChange(permissionSet, false);
		change.contactsToAdd.addAll(contactsToAdd);
		change.contactsToRemove.addAll(contactsToRemove);

		changes.put(permissionSet, change);
	}*/

	public ANG_PermissionSetHelper(Map<String, PermissionChange> changes){
		this.changes = changes;
	}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************

	public void managePermissions() {

		//look for permission sets
		Map<String, Id> permissions = new Map<String, Id>();
		for(PermissionSet ps : [SELECT Id, Name FROM PermissionSet WHERE Name IN :changes.keySet()]){
			permissions.put(ps.Name, ps.Id);
		}

		if(permissions.isEmpty()) return;

		//create fetch list of involved contacts
		Map<Id, Id> users = new Map<Id, Id>();
		Map<String, Id> connectedApps = new Map<String, Id>();
		for(PermissionChange change : changes.values()){
			for(Id contact : change.contactsToAdd) users.put(contact, null);
			for(Id contact : change.contactsToRemove) users.put(contact, null);

			if(String.isNotEmpty(change.provisioningAppName)) connectedApps.put(change.provisioningAppName, null);
		}

		//find the correct user for each contact
		for(User u : [SELECT Id, ContactId FROM User WHERE ContactId IN :users.keySet() AND IsActive = true]) users.put(u.ContactId, u.Id);
		System.debug(loggingLevel.FINEST, '____ [cls ANG_PermissionSetHelper - managePermissions] users - ' + users);

		//find assignments already in place
		Map<String, PermissionSetAssignment> assignments = new Map<String, PermissionSetAssignment>();
		for(PermissionSetAssignment a : [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :users.values() AND PermissionSetId IN :permissions.values()]){
			assignments.put(''+a.AssigneeId+a.PermissionSetId, a);
		}
		System.debug(loggingLevel.FINEST, '____ [cls ANG_PermissionSetHelper - managePermissions] assignments - ' + assignments);
		
		//apply changes
		List<PermissionSetAssignment> newPermissions = new List<PermissionSetAssignment>();
		List<PermissionSetAssignment> permissionsToDelete = new List<PermissionSetAssignment>();
		List<UserProvisioningRequest> provRequests = new List<UserProvisioningRequest>();

		for(PermissionChange change : changes.values()){
			System.debug(loggingLevel.FINEST, '____ [cls ANG_PermissionSetHelper - managePermissions] change - ' + change);

			Id permissionSetId = permissions.get(change.permissionSetName);

			if(permissionSetId == null) continue;

			for(Id contact : change.contactsToAdd){
				//check if contact already has the permission set assigned
				//if not, create a new assignment
				String key = ''+users.get(contact)+permissionSetId;

				System.debug(loggingLevel.FINEST, '____ [cls ANG_PermissionSetHelper - managePermissions] key - ' + key);
				if(!assignments.containsKey(key)){
					newPermissions.add(
						new PermissionSetAssignment(
							AssigneeId = users.get(contact)
							, PermissionSetId = permissionSetId
						)
					);

					if(change.needsProvisioning){
						System.debug(loggingLevel.FINEST, '____ Add - ' + change.operation);
						provRequests.add(
							new UserProvisioningRequest(
								AppName = change.provisioningAppName
								, ConnectedAppId = change.provisioningAppId
								, Operation = 'Create'
								, ApprovalStatus = 'NotRequired'
								, SalesforceUserId = users.get(contact)
								, state = 'New'
							)
						);
					}
				}				
			}
			for(Id contact : change.contactsToRemove){
				String key = ''+users.get(contact)+permissionSetId;
				//find permission assignment on the map
				//if(assignments.containsKey(key)) permissionsToDelete.add(assignments.get(key));

                if(assignments.containsKey(key)) {
                    permissionsToDelete.add(assignments.get(key));

                    Id profileId = userinfo.getProfileId();
					String profileName = [Select Id,Name from Profile where Id=:profileId].Name;

                    if(profileName.startsWith('ISS Portal')) {
	                    System.debug(loggingLevel.FINEST, '____ Remove - ' + change.operation);

	                    provRequests.add(
	                        new UserProvisioningRequest(
	                            AppName = change.provisioningAppName
	                            , ConnectedAppId = change.provisioningAppId
	                            , Operation = 'Deactivate'
	                            , ApprovalStatus = 'NotRequired'
	                            , SalesforceUserId = users.get(contact)
	                            , state = 'New'
	                        )
	                    );
                    }
                }
			}
		}

		System.debug(loggingLevel.FINEST, '____ [cls ANG_PermissionSetHelper - managePermissions] newPermissions - ' + newPermissions);
		System.debug(loggingLevel.FINEST, '____ [cls ANG_PermissionSetHelper - managePermissions] provRequests - ' + provRequests);
		System.debug(loggingLevel.FINEST, '____ [cls ANG_PermissionSetHelper - managePermissions] permissionsToDelete - ' + permissionsToDelete);

		try {
			if(!newPermissions.isEmpty()) insert newPermissions;
			if(!provRequests.isEmpty()) insert provRequests;
			if(!permissionsToDelete.isEmpty()) delete permissionsToDelete;
		} catch(Exception e) {
			System.debug(loggingLevel.ERROR, '____ [cls ANG_PermissionSetHelper - managePermissions] ERROR - ' + e);
		}
	}

	public Id enqueueJob() {
		return System.enqueueJob(new ANG_PermissionSetHelper.PermissionChanger(changes));
	}

	// ************************************************************
	// ********************* helper methods ***********************
	// ************************************************************

	public void addPermission(String permissionSet, Id contact) {
		if(!changes.containsKey(permissionSet)) changes.put(permissionSet, new PermissionChange(permissionSet));

		permissionsChanged = true;
		changes.get(permissionSet).contactsToAdd.add(contact);
	}

	public void removePermission(String permissionSet, Id contact, Connected_App_Roles__c role) {
		if(!changes.containsKey(permissionSet)) changes.put(permissionSet, new PermissionChange(permissionSet));

		changes.get(permissionSet).operation = 'Deactivate';
		changes.get(permissionSet).needsProvisioning = true;
		permissionsChanged = true;
		changes.get(permissionSet).provisioningAppName = role.Connected_App_Provisioning_Name__c;
		changes.get(permissionSet).provisioningAppId = role.Provisioning_Id__c;

		changes.get(permissionSet).contactsToRemove.add(contact);
	}

	public void setProvisioning(String permissionSet, Connected_App_Roles__c role) {
		if(!changes.containsKey(permissionSet)) changes.put(permissionSet, new PermissionChange(permissionSet));

		changes.get(permissionSet).needsProvisioning = true;
		changes.get(permissionSet).operation = 'Create';
		changes.get(permissionSet).provisioningAppName = role.Connected_App_Provisioning_Name__c;
		changes.get(permissionSet).provisioningAppId = role.Provisioning_Id__c;
	}

	public Boolean isChanged(){
		return permissionsChanged;
	}

	public class PermissionChange {
		private String permissionSetName;
		private String provisioningAppName;
		private String provisioningAppId;
		private String operation {get; set;}

		private Boolean needsProvisioning{
			get{
				if(needsProvisioning == null) needsProvisioning = false;
				return needsProvisioning;
			}
			set;
		}

		public Set<Id> contactsToAdd{
			get{
				if(contactsToAdd == null) contactsToAdd = new Set<Id>();
				return contactsToAdd;
			}
			set;
		}

		public Set<Id> contactsToRemove{
			get{
				if(contactsToRemove == null) contactsToRemove = new Set<Id>();
				return contactsToRemove;
			}
			set;
		}

		public PermissionChange(String name){
			this.permissionSetName = name;
		}
	}

	public class PermissionChanger implements Queueable {

		private Map<String, PermissionChange> changes;

		private PermissionChanger(Map<String, PermissionChange> changes){
			this.changes = changes;
		}

		public void execute(QueueableContext qc){
			ANG_PermissionSetHelper helper = new ANG_PermissionSetHelper(changes);
			helper.managePermissions();
		}
	}
}
