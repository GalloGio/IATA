public class ANG_PortalApplicationRightHelper {

	public static List<Portal_Application_Right__c> getCheckMinimumUsersAllowedErrorList(Set<id> parSet) {
		List<Portal_Application_Right__c> parList = [Select id, 
		                                                    Application_Name__c, 
		                                                    contact__r.account.Top_Parent__c, 
		                                                    contact__r.accountId, 
		                                                    ANG_Portal_Service_Role__c 
		                                               From Portal_Application_Right__c		                                              
		                                              Where id in :parSet];

		return checkMinimumUsersAllowed(parList);
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

	private static List<Portal_Application_Right__c> checkMinimumUsersAllowed(List<Portal_Application_Right__c> parList) {

		List<Portal_Application_Right__c> errorList = new List<Portal_Application_Right__c>();
		Map<String, Decimal> roles = new Map<String, Decimal>();

		for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()){
			if(role.Permission_set_SSO__c != null){
				roles.put(role.Connected_App__c + ' - ' + role.Role__c, role.Min_Users_With_Role__c);
			}
		}

		System.debug('parList--->' + parList);
		System.debug('roles--->' + roles);

		//no Connected app roles found
		if(roles.isEmpty()) return errorList;

		Map<Id,List<String>> parTopAccount = new Map<Id,List<String>>();
		//Set<Id> accountsTp = new Set<Id>();
		Set<Id> accounts = new Set<Id>();
		Set<Id> contacts = new Set<Id>();
		Map<Id,Id> parAccount = new Map<Id,Id>();

		//
		// GET the pivot accounts from the trigger list
		//
		for(Portal_Application_Right__c access : parList) {
			contacts.add(access.Contact__c);

			Id accountPivotId;
			if(access.contact__r.account.Top_Parent__c != null) {
				accountPivotId = access.contact__r.account.Top_Parent__c;
				//accountsTP.add(access.contact__r.account.Top_Parent__c);
			} else { 
				accountPivotId = access.contact__r.accountId;				
			}
			accounts.add(accountPivotId);

			if(!parTopAccount.containsKey(accountPivotId)) {
				parTopAccount.put(accountPivotId, new List<String>());
				parAccount.put(access.id, accountPivotId);
			}

			List<String> lst = parTopAccount.get(accountPivotId);

			lst.add(access.ANG_Portal_Service_Role__c);
		}

		System.debug('parTopAccount1--->' + parTopAccount);

		//
		// GET the HO accounts
		//
		List<Portal_application_right__c> related = [Select id, 
															ANG_Portal_Service_Role__c,
															contact__r.account.Top_Parent__c,
															contact__r.accountId,
															contact__c
													   From Portal_application_right__c
													  where contact__r.accountId in :accounts
													    and Portal_application_right__c.right__c = 'Access Granted'
													    and contact__c not in : contacts];

		System.debug('related--->' + related);

		for(Portal_Application_Right__c access : related) {
			contacts.add(access.Contact__c);

			Id accountPivotId;
			if(access.contact__r.account.Top_Parent__c != null) {
				accountPivotId = access.contact__r.account.Top_Parent__c;
			} else { 
				accountPivotId = access.contact__r.accountId;				
			}
			
			if(!parTopAccount.containsKey(accountPivotId)) {
				parTopAccount.put(accountPivotId, new List<String>());
				parAccount.put(access.id, accountPivotId);
			}
			List<String> lst = parTopAccount.get(accountPivotId);

			lst.add(access.ANG_Portal_Service_Role__c);
		}

		System.debug('parTopAccount2--->' + parTopAccount);
		System.debug('accounts--->' + accounts);

		//
		// GET the BR accounts 
		//
		List<Portal_application_right__c> related2 = [Select id, 
															 ANG_Portal_Service_Role__c,
															 contact__r.account.Top_Parent__c,
															 contact__r.accountId
													    From Portal_application_right__c
													   where contact__r.account.Top_Parent__c in :accounts
													     and Portal_application_right__c.right__c = 'Access Granted'
													     and contact__c not in : contacts];		

		System.debug('related2--->' + related2);

		for(Portal_Application_Right__c access : related2) {
			Id accountPivotId;
			if(access.contact__r.account.Top_Parent__c != null) {
				accountPivotId = access.contact__r.account.Top_Parent__c;
			} else { 
				accountPivotId = access.contact__r.accountId;				
			}

			if(!parTopAccount.containsKey(accountPivotId)) {
				parTopAccount.put(accountPivotId, new List<String>());
				parAccount.put(access.id, accountPivotId);
			}
			List<String> lst = parTopAccount.get(accountPivotId);

			lst.add(access.ANG_Portal_Service_Role__c);
		}


		System.debug('parTopAccount--->' + parTopAccount);

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

				System.debug('Test---->' + r.role + ' = ' + access.ANG_Portal_Service_Role__c);

				if(r.role == access.ANG_Portal_Service_Role__c && r.cnt - 1 < min) {
					System.debug('Found error---->' + access);
					errorList.add(access);
				} else {
					System.debug('Ok');					
					r.sub();
				}
			}
		}

		return errorList;
	}

}