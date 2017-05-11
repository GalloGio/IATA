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
		checkMinimumUsersAllowedUpdate();
	}
	public void onBeforeDelete(){
		checkMinimumUsersAllowedDelete();
	}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************

	private void checkMinimumUsersAllowedDelete() {
		Set<Id> parSet = new Set<Id>();
		for(Portal_Application_Right__c access : triggerOld) {
			//
			// Only take in consideration IEP services
			//
			if(access.Application_Name__c.startsWith('IATA EasyPay')) {
				parSet.add(access.id);
			}
		}	

		List<Portal_Application_Right__c> errorList	= getCheckMinimumUsersAllowedErrorList(parSet);

		for(Portal_Application_Right__c par : errorList) {
			oldMap.get(par.id).addError(System.label.ANG_ISSP_Min_Users_With_Role_Error_Msg + ' ' +  par.ANG_Portal_Service_Role__c + ' ' + System.label.ANG_ISSP_Min_Users_With_Role_Error_Msg2);
		}
	}
	private void checkMinimumUsersAllowedUpdate() {
		Set<Id> parSet = new Set<Id>();
		for(Portal_Application_Right__c access : triggerNew) {
			if(access.Right__c == 'Access Denied') {
				parSet.add(access.id);	
			}						
		}

		List<Portal_Application_Right__c> errorList	= getCheckMinimumUsersAllowedErrorList(parSet);

		for(Portal_Application_Right__c par : errorList) {
			newMap.get(par.id).addError(System.label.ANG_ISSP_Min_Users_With_Role_Error_Msg + ' ' +  par.ANG_Portal_Service_Role__c + ' ' + System.label.ANG_ISSP_Min_Users_With_Role_Error_Msg2);
		}
	}

	private List <Portal_Application_Right__c> getCheckMinimumUsersAllowedErrorList(Set<id> parSet) {
		List<Portal_Application_Right__c> parList = [Select id,
															Application_Name__c,
		                                                    contact__r.account.Top_Parent__c, 
		                                                    contact__r.accountId,
		                                                    ANG_Portal_Service_Role__c
		                                               From Portal_Application_Right__c
		                                              Where id in :parSet];

		return checkMinimumUsersAllowed(parList);
	}

	private void setConnectedAppsSSOPermission() {

		//fetch all connected app roles that need to grant a permission set
		Map<String, Connected_App_Roles__c> roles = new Map<String, Connected_App_Roles__c>();

		for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()) {
			if(role.Permission_set_SSO__c != null) {
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

	public class RoleCntWrapper {
		public String role {get; set;}
		public Decimal cnt {get; set;}

		public RoleCntWrapper(String parRole) {
			this.role = parRole;
			this.cnt = 1;
		}

		public void add() {
			this.cnt++;
		}

		public void sub() {
			this.cnt++;
		}		
	}

	private List<Portal_Application_Right__c> checkMinimumUsersAllowed(List<Portal_Application_Right__c> parList) {

		List<Portal_Application_Right__c> errorList = new List<Portal_Application_Right__c>();
		Map<String, Decimal> roles = new Map<String, Decimal>();

		for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()){
			if(role.Permission_set_SSO__c != null){
				roles.put(role.Connected_App__c + ' - ' + role.Role__c, role.Min_Users_With_Role__c);
			}
		}

		//no Connected app roles found
		if(roles.isEmpty()) {
			return errorList;
		}

		Map<Id,List<String>> parTopAccount = new Map<Id,List<String>>();
		Set<Id> accountsTp = new Set<Id>();
		Set<Id> accounts = new Set<Id>();
		Set<Id> contacts = new Set<Id>();
		Map<Id,Id> parAccount = new Map<Id,Id>();

		//   <-------------- FIRST PART ----------------><------ SECOND PART ---------->
		//   PAR ----> Contact ----> Account -----> Top Parent <----- Contact <----- PAR
		//
		//

		//
		// GET the accounts of the first part
		//
		for(Portal_Application_Right__c access : parList) {
			contacts.add(access.Contact__c);

			Id accountPivotId;
			if(access.contact__r.account.Top_Parent__c != null) {
				accountPivotId = access.contact__r.account.Top_Parent__c;
				accountsTP.add(access.contact__r.account.Top_Parent__c);
			} else { 
				accountPivotId = access.contact__r.accountId;
				accounts.add(access.contact__r.accountId);
			}

			if(!parTopAccount.containsKey(accountPivotId)) {
				parTopAccount.put(accountPivotId, new List<String>());
				parAccount.put(access.id, accountPivotId);
			}

			List<String> lst = parTopAccount.get(accountPivotId);

			lst.add(access.ANG_Portal_Service_Role__c);
		}

		//
		// GET the accounts of the second part
		//
		List<Portal_application_right__c> related = [Select id, 
															ANG_Portal_Service_Role__c,
															contact__r.accountId
													   From Portal_application_right__c
													  where contact__r.accountId in :accountsTp
													    and contact__c not in : contacts];

		for(Portal_Application_Right__c access : related) {
			if(!parTopAccount.containsKey(access.contact__r.accountId)) {
				parTopAccount.put(access.contact__r.accountId, new List<String>());
				parAccount.put(access.id, access.contact__r.accountId);
			}
			List<String> lst = parTopAccount.get(access.contact__r.accountId);

			lst.add(access.ANG_Portal_Service_Role__c);
		}

		//
		// GET the accounts of the second part
		//
		List<Portal_application_right__c> related2 = [Select id, 
															ANG_Portal_Service_Role__c,
															contact__r.account.Top_Parent__c
													   From Portal_application_right__c
													  where contact__r.account.Top_Parent__c in :accounts
													    and contact__c not in : contacts];		

		for(Portal_Application_Right__c access : related2) {
			if(!parTopAccount.containsKey(access.contact__r.account.Top_Parent__c)) {
				parTopAccount.put(access.contact__r.account.Top_Parent__c, new List<String>());
				parAccount.put(access.id, access.contact__r.account.Top_Parent__c);
			}
			List<String> lst = parTopAccount.get(access.contact__r.account.Top_Parent__c);

			lst.add(access.ANG_Portal_Service_Role__c);
		}

		System.debug('--->' + parTopAccount);

		//
		// Match the Pivot Account and count all the roles found (Do the math).
		//
		Map<Id, List<RoleCntWrapper>> accountCntRoles = new Map<Id, List<RoleCntWrapper>>();

		for(Portal_Application_Right__c access : parList) {
			Id accountPivotId;
			if(access.contact__r.account.Top_Parent__c != null) {
				accountPivotId = access.contact__r.account.Top_Parent__c;
			} else { 
				accountPivotId = access.contact__r.accountId;
			}

			List<String> rolesList = parTopAccount.get(accountPivotId);

			if(!accountCntRoles.containsKey(access.id)) {
				accountCntRoles.put(accountPivotId, new List<RoleCntWrapper>());
			}

			List<RoleCntWrapper> lst = accountCntRoles.get(accountPivotId);

			for(String role : rolesList) {
				boolean found = false;
				for(RoleCntWrapper r : lst) {
					if(r.role == role) {
						found = true;
						r.add();
						break;
					}
				}

				if(!found) {
					lst.add(new RoleCntWrapper(role));
				}
			}
		}

		System.debug('accountCntRoles->' + accountCntRoles);

		//
		// Check if after delete we will have less portal service roles than the minimum configured.
		//
		for(Portal_Application_Right__c access : parList) {
			//
			// Get the account id associated with the par
			//
			Id accountPivotId = parAccount.get(access.id);

			System.debug('accountPivotId---->' + accountPivotId);

			Decimal min = roles.get(access.Application_Name__c + ' - ' + access.ANG_Portal_Service_Role__c);

			List<RoleCntWrapper> roleCntList = accountCntRoles.get(accountPivotId);
			for(RoleCntWrapper r : roleCntList) {
				if(r.role == access.ANG_Portal_Service_Role__c && r.cnt - 1 < min) {
					errorList.add(access);
				} else {
					r.sub();
				}
			}
		}

		return errorList;
	}	
}