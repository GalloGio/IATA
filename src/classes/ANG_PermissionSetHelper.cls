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
		PermissionChange change = new PermissionChange(permissionSet);
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
		for(PermissionChange change : changes.values()){
			for(Id contact : change.contactsToAdd) users.put(contact, null);
			for(Id contact : change.contactsToRemove) users.put(contact, null);
		}

		//find the correct user for each contact
		for(User u : [SELECT Id, ContactId FROM User WHERE ContactId IN :users.keySet() AND IsActive = true]) users.put(u.ContactId, u.Id);

		//find assignments already in place
		Map<String, PermissionSetAssignment> assignments = new Map<String, PermissionSetAssignment>();
		for(PermissionSetAssignment a : [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :users.values() AND PermissionSetId IN :permissions.values()]){
			assignments.put(''+a.AssigneeId+a.PermissionSetId, a);
		}
		
		//apply changes
		List<PermissionSetAssignment> newPermissions = new List<PermissionSetAssignment>();
		List<PermissionSetAssignment> permissionsToDelete = new List<PermissionSetAssignment>();

		for(PermissionChange change : changes.values()){
			Id permissionSetId = permissions.get(change.permissionSetName);
			for(Id contact : change.contactsToAdd){
				//check if contact already has the permission set assigned
				//if not, create a new assignment
				String key = ''+users.get(contact)+permissionSetId;
				if(!assignments.containsKey(key)) newPermissions.add(
					new PermissionSetAssignment(
						AssigneeId = users.get(contact)
						, PermissionSetId = permissionSetId
					));
			}
			for(Id contact : change.contactsToRemove){
				String key = ''+users.get(contact)+permissionSetId;
				//find permission assignment on the map
				if(assignments.containsKey(key)) permissionsToDelete.add(assignments.get(key));
			}
		}

		if(!newPermissions.isEmpty()) insert newPermissions;
		if(!permissionsToDelete.isEmpty()) delete permissionsToDelete;
	}

	public Id enqueueJob() {
		return System.enqueueJob(new ANG_PermissionSetHelper.PermissionChanger(changes));
	}

	// ************************************************************
	// ********************* helper methods ***********************
	// ************************************************************

	public void addPermission(String permissionSet, Id contact) {
		if(!changes.containsKey(permissionSet)) changes.put(permissionSet, new PermissionChange(permissionSet));
		changes.get(permissionSet).contactsToAdd.add(contact);
		permissionsChanged = true;
	}

	public void removePermission(String permissionSet, Id contact) {
		if(!changes.containsKey(permissionSet)) changes.put(permissionSet, new PermissionChange(permissionSet));
		changes.get(permissionSet).contactsToRemove.add(contact);
		permissionsChanged = true;
	}

	public Boolean isChanged(){
		return permissionsChanged;
	}

	public class PermissionChange {
		private String permissionSetName;

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