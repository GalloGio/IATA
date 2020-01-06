public without sharing class GADM_ExternalUserContactDetail_CTRL {

	@AuraEnabled
	public static UserManagementData prepareManagementData(String currentUserData, String selectedUserData, Boolean isSuperUser, boolean isPowerUser) {
		GADM_ExternalUserContactList_CTRL.UserInformation currentUserInfo = (GADM_ExternalUserContactList_CTRL.UserInformation)JSON.deserialize(currentUserData, GADM_ExternalUserContactList_CTRL.UserInformation.class);
		Contact_Roles_Helper.AggregatedRecordWrapper selectedUserInfo = (Contact_Roles_Helper.AggregatedRecordWrapper)JSON.deserialize(selectedUserData, Contact_Roles_Helper.AggregatedRecordWrapper.class);

		//current user
		List<Contact_Roles__c> currentUserRoles = currentUserInfo.grantedRoles;
		List<Contact_Roles__c> currentUserBusinessUnits = currentUserInfo.grantedBusinessUnits;
		List<Account> currentUserActors = currentUserInfo.visibleAccounts;

		//selected user
		Map<Id, Contact_Role_Service_Access__c> roles = selectedUserInfo.rolesData;
		Map<Id,Contact_Role_Service_Access__c> businessUnits = selectedUserInfo.buData;
		Map<Id,Account_Contact_Role__c> actors = selectedUserInfo.actorsData;

		List<Contact_Roles__c> selectedUserRoles = new List<Contact_Roles__c>();
		List<Contact_Roles__c> selectedUserBusinessUnits = new List<Contact_Roles__c>();
		List<Account> selectedUserActors = new List<Account>();


		if(roles != null && !roles.isEmpty()) {
			for(Id roleId : roles.keySet()) {
				Contact_Roles__c role = new Contact_Roles__c();
				role.Id = roleId;
				role.Name = roles.get(roleId).Contact_Role__r.Contact_Roles__r.Name;
				selectedUserRoles.add(role);
			}
		}

		if(businessUnits != null && !businessUnits.isEmpty()) {
			for(Id buId : businessUnits.keySet()) {
				Contact_Roles__c businessUnit = new Contact_Roles__c();
				businessUnit.Id = buId;
				businessUnit.Name = businessUnits.get(buId).Contact_Role__r.Contact_Roles__r.Name;
				selectedUserBusinessUnits.add(businessUnit);
			}
		}

		if(actors != null && !actors.isEmpty()) {
			for(Id actorId : actors.keySet()) {
				Account actor = new Account();
				actor.Id = actorId;
				actor.Name = actors.get(actorId).Account_Role__r.Account__r.Name;
				selectedUserActors.add(actor);
			}
		}

		UserManagementData managementData = new UserManagementData();

		managementData.roles = new Map<Id, GADM_ExternalUserContactDetail_CTRL.Role>();
		managementData.businessUnits = new Map<Id, GADM_ExternalUserContactDetail_CTRL.BusinessUnit>();
		managementData.actors = new Map<Id, GADM_ExternalUserContactDetail_CTRL.Actor>();
		managementData.currentUserIsSelectedUser = false;

		Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');
		List<Contact_Role_Service__c> contactRoleServices = [SELECT Id, Contact_Role__c FROM Contact_Role_Service__c WHERE Service__r.Name = 'GADM' AND Contact_Role__r.RecordTypeId = :externalRecordTypeId AND (Contact_Role__r.Category__c = '' OR Contact_Role__r.Category__c = null)];

		Set<Id> contactRolesIds = new Set<Id>();
		for(Contact_Role_Service__c service : contactRoleServices) {
			contactRolesIds.add(service.Contact_Role__c);
		}

		boolean selectedUserIsPowerUser = false;
		boolean selectedUserIsSuperUser = false;

		for(Contact_Roles__c selectedRole : selectedUserRoles) {
			if(selectedRole.Name == 'Service Power User') {
				selectedUserIsPowerUser = true;
				continue;
			}
			if(selectedRole.Name == 'Service Super User') {
				selectedUserIsSuperUser = true;
				continue;
			}
		}

		List<Contact_Roles__c> standardGadmRoles = [SELECT Id, Name FROM Contact_Roles__c WHERE Id = :contactRolesIds];
		for(Contact_Roles__c role : standardGadmRoles) {
			//power user role cannot be taken
			if(role.Name == 'Service Power User') {
				if(isPowerUser){
					Role dataRole = new Role();
					dataRole.role = role;
					dataRole.isChecked = selectedUserRoles.contains(role);
					dataRole.isEditable = false;
					managementData.roles.put(role.Id, dataRole);
				} else{
					continue;
				}
			}
			else if(role.Name == 'Service Super User') {
				if(isPowerUser){
					Role dataRole = new Role();
					dataRole.role = role;
					dataRole.isChecked = selectedUserRoles.contains(role);
					dataRole.isEditable = true;
					managementData.roles.put(role.Id, dataRole);
				} else if(isSuperUser) {
					Role dataRole = new Role();
					dataRole.role = role;
					dataRole.isChecked = selectedUserRoles.contains(role);
					dataRole.isEditable = false;
					managementData.roles.put(role.Id, dataRole);
				} else{
					continue;
				}
			}else if (role.Name == 'GADM User') {
				if (isPowerUser && selectedUserIsPowerUser) {
					Role dataRole = new Role();
					dataRole.role = role;
					dataRole.isChecked = selectedUserRoles.contains(role);
					dataRole.isEditable = false;
					managementData.roles.put(role.Id, dataRole);
				} else if(isSuperUser && selectedUserIsSuperUser) {
					Role dataRole = new Role();
					dataRole.role = role;
					dataRole.isChecked = selectedUserRoles.contains(role);
					dataRole.isEditable = false;
					managementData.roles.put(role.Id, dataRole);
				} else {
					Role dataRole = new Role();
					dataRole.role = role;
					dataRole.isChecked = selectedUserRoles.contains(role);
					dataRole.isEditable = true;
					managementData.roles.put(role.Id, dataRole);
				}

			} else {
				Role dataRole = new Role();
				dataRole.role = role;
				dataRole.isChecked = selectedUserRoles.contains(role);
				dataRole.isEditable = true;
				managementData.roles.put(role.Id, dataRole);
			}

		}

		for(Contact_Roles__c cuBusinessUnit : currentUserBusinessUnits) {
			BusinessUnit businessUnit = new BusinessUnit();
			businessUnit.businessUnit = cuBusinessUnit;
			businessUnit.isChecked = selectedUserBusinessUnits.contains(cuBusinessUnit);
			businessUnit.isEditable = true;

			managementData.businessUnits.put(cuBusinessUnit.Id, businessUnit);
		}

		for(Contact_Roles__c seBusinessUnit : selectedUserBusinessUnits) {
			if(managementData.businessUnits.get(seBusinessUnit.Id) == null) {
				BusinessUnit businessUnit = new BusinessUnit();
				businessUnit.businessUnit = seBusinessUnit;
				businessUnit.isChecked = true;
				businessUnit.isEditable = currentUserBusinessUnits.contains(seBusinessUnit);

				managementData.businessUnits.put(seBusinessUnit.Id, businessUnit);
			}
		}


		for(Account cuActor : currentUserActors) {
			Actor actor = new Actor();
			actor.actor = cuActor;
			actor.isChecked = selectedUserActors.contains(cuActor);
			actor.isEditable = true;

			managementData.actors .put(cuActor.Id, actor);
		}

		for(Account seActor : selectedUserActors) {
			if(managementData.actors.get(seActor.Id) == null) {
				Actor actor = new Actor();
				actor.actor =seActor;
				actor.isChecked = true;
				actor.isEditable = currentUserActors.contains(seActor);

				managementData.actors.put(seActor.Id, actor);
			}
		}

		managementData = disableEditIfRunningUserIsSelectedUser(managementData, selectedUserInfo.con);
		managementData = checkAllowedDomainsAndUserCount(managementData, selectedUserInfo);

		return managementData;

	}

	private static UserManagementData checkAllowedDomainsAndUserCount(UserManagementData userManagementData, Contact_Roles_Helper.AggregatedRecordWrapper selectedUserInfo) {

		Contact selectedContact = selectedUserInfo.con;

		String userDomain = '';
		if(selectedContact.Email != null) {
			userDomain = selectedContact.Email.substringAfter('@');
		}

		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		List<Account_Contact_Role__c> accountContactRoles = [SELECT Id, Account_Role__r.Account__c FROM Account_Contact_Role__c WHERE Contact__c = :selectedContact.Id AND Contact_Roles__r.Name = 'GADM User' AND Service_Rendered__c = 'GADM' AND RecordTypeId = :functionalRecordTypeId];

		if(! accountContactRoles.isEmpty()) {

			String mainActorId = accountContactRoles[0].Account_Role__r.Account__c;
			if(String.isNotBlank(mainActorId)) {

				List<GADM_Account_Service_Detail__c> serviceDetails = [SELECT Id, Active_User_Count__c, Allowed_email_domain__c, Account_Role_Service__r.Account_Role__r.Account__c FROM GADM_Account_Service_Detail__c WHERE Account_Role_Service__r.Account_Role__r.Account__c = :accountContactRoles[0].Account_Role__r.Account__c];
				if (!serviceDetails.isEmpty()) {

					//get allowed domains
					List<String> domains = new List<String>();
					if (serviceDetails[0].Allowed_email_domain__c != null) {
						if (serviceDetails[0].Allowed_email_domain__c.indexOf(';') > -1) {
							domains = serviceDetails[0].Allowed_email_domain__c.split(';');
						} else {
							domains.add(serviceDetails[0].Allowed_email_domain__c);
						}

					}

					//check user actor against allowed domains
					GADM_ExternalUserContactDetail_CTRL.Actor actor = userManagementData.actors.get(mainActorId);
					if (actor != null) {
						actor.isDomainBlocked = !domains.contains(userDomain);

						//fill max count of active users for actor
						Integer maxUserCount = (Integer) serviceDetails[0].Active_User_Count__c;
						if (maxUserCount != null) {
							actor.maxUserCount = maxUserCount;
						} else {
							maxUserCount = 0;
							actor.maxUserCount = 0;
						}

						//check how many users are now active for actor
						Integer actualUserCount = 0;
						List<Contact_Role_Service_Access__c> accesses = [SELECT Id FROM Contact_Role_Service_Access__c WHERE Status__c = 'Granted' AND Contact_Role__r.Account_Role__r.Account__c = :mainActorId AND Contact_Role__r.Contact_Roles__r.Name = 'GADM User' AND Contact_Role__r.RecordTypeId = :functionalRecordTypeId];
						if (!accesses.isEmpty()) {
							actualUserCount = accesses.size();
						}

						//check GADM User role against allowed domains
						for (Id roleId : userManagementData.roles.keySet()) {
							Role role = userManagementData.roles.get(roleId);
							if (role.role.Name == 'GADM User') {
								if (domains != null) {
									role.isDomainBlocked = !domains.contains(userDomain);
								} else {
									role.isDomainBlocked = true;
								}

								break;
							}
						}

						actor.currentUserCount = actualUserCount;

					}
				}
			}

		}

		//fill allowed domains for other actors
		Set<Id> actorsIds = userManagementData.actors.keySet();

		if(! actorsIds.isEmpty()) {
			List<GADM_Account_Service_Detail__c> serviceDetailsList = [SELECT Id, Allowed_email_domain__c, Account_Role_Service__r.Account_Role__r.Account__c FROM GADM_Account_Service_Detail__c WHERE Account_Role_Service__r.Account_Role__r.Account__c = :actorsIds];

			Map<Id, List<String>> idToDomainsMap = new Map<Id, List<String>>();
			for(GADM_Account_Service_Detail__c detail : serviceDetailsList) {
				if(detail.Allowed_email_domain__c != null) {
					List<String> domainsList = new List<String>();
					if(detail.Allowed_email_domain__c.indexOf(';') > -1) {
						domainsList = detail.Allowed_email_domain__c.split(';');
					}else{
						domainsList.add(detail.Allowed_email_domain__c);
					}

					idToDomainsMap.put(detail.Account_Role_Service__r.Account_Role__r.Account__c, domainsList);

				}else{//nothing in Allowed_email_domain__c field
					idToDomainsMap.put(detail.Account_Role_Service__r.Account_Role__r.Account__c, new List<String>());
				}
			}


			for(Id actorId : userManagementData.actors.keySet()) {
				GADM_ExternalUserContactDetail_CTRL.Actor actorObj = userManagementData.actors.get(actorId);
				if(actorObj != null) {
					List<String> actorDomains = idToDomainsMap.get(actorId);
					if(actorDomains != null) {
						actorObj.isDomainBlocked = !actorDomains.contains(userDomain);
					}
				}
			}

		}

		return userManagementData;

	}

	private static UserManagementData disableEditIfRunningUserIsSelectedUser(UserManagementData managementData, Contact selectedContact) {

		boolean isCurrentUserSelectedUser = false;

		List<User> users = [SELECT Id FROM User WHERE ContactId = :selectedContact.Id LIMIT 1];
		if(! users.isEmpty()) {

			if(users[0].Id == UserInfo.getUserId()) {
				isCurrentUserSelectedUser = true;
			}
		}

		if(isCurrentUserSelectedUser) {

			Map<Id, GADM_ExternalUserContactDetail_CTRL.Role> roles = managementData.roles;
			Map<Id, GADM_ExternalUserContactDetail_CTRL.BusinessUnit> businessUnits = managementData.businessUnits;
			Map<Id, GADM_ExternalUserContactDetail_CTRL.Actor> actors = managementData.actors;

			for(GADM_ExternalUserContactDetail_CTRL.Role role: roles.values()) {
				role.isEditable = false;
			}

			for(GADM_ExternalUserContactDetail_CTRL.BusinessUnit businessUnit : businessUnits.values()) {
				businessUnit.isEditable = false;
			}

			for(GADM_ExternalUserContactDetail_CTRL.Actor actor : actors.values()) {
				actor.isEditable = false;
			}

			managementData.currentUserIsSelectedUser = true;

		}

		return managementData;


	}


	/*@AuraEnabled - keep commented for now
	public static Contact_Roles_Helper.AggregatedRecordWrapper reloadData(Id userId, Boolean isSuperUser, Boolean isGadmUser, List<Id> businessUnits, Boolean sortDesc, Contact selectedContact) {

		List<Contact_Roles_Helper.AggregatedRecordWrapper> wrappers = Contact_Roles_Helper.getContactsVisibleToUser(userId, isSuperUser, isGadmUser, businessUnits, selectedContact, sortDesc);
		System.debug('wrappers:: ' + wrappers);

		Contact_Roles_Helper.AggregatedRecordWrapper selectedUserData = wrappers[0];

		return selectedUserData;

	}*/


	@AuraEnabled
	public static boolean saveManagementData(String originalData, String modifiedData, String selectedUserInfo) {

		UserManagementData original = (UserManagementData)JSON.deserialize(originalData, UserManagementData.class);
		UserManagementData modified = (UserManagementData)JSON.deserialize(modifiedData, UserManagementData.class);
		Contact_Roles_Helper.AggregatedRecordWrapper userInfo = (Contact_Roles_Helper.AggregatedRecordWrapper)JSON.deserialize(selectedUserInfo, Contact_Roles_Helper.AggregatedRecordWrapper.class);

		//roles:
		Map<Id, Role> originalRoles = original.roles;
		Map<Id, Role> modifiedRoles = modified.roles;
		Map<Id, Contact_Role_Service_Access__c> userRoles = userInfo.rolesData;

		//business units
		Map<Id, BusinessUnit> originalBusinessUnits = original.businessUnits;
		Map<Id, BusinessUnit> modifiedBusinessUnits = modified.businessUnits;
		Map<Id, Contact_Role_Service_Access__c> userBusinessUnits = userInfo.buData;


		//actors
		Map<Id, Actor> originalActors = original.actors;
		Map<Id, Actor> modifiedActors = modified.actors;
		Map<Id, Account_Contact_Role__c> userActors = userInfo.actorsData;

		Contact con  = userInfo.con;

		Savepoint sp = Database.setSavepoint();

		try{

			handleRoles(originalRoles, modifiedRoles, userRoles, con);
			handleBusinessUnits(originalBusinessUnits, modifiedBusinessUnits, userBusinessUnits, con);
			handleActors(originalActors, modifiedActors, userActors, con);

			return true;

		}catch(Exception e) {

			Database.rollback(sp);

			return false;

		}

	}


	private static void handleRoles(Map<Id, Role> originalRoles, Map<Id, Role> modifiedRoles, Map<Id, Contact_Role_Service_Access__c> userRoles, Contact con) {
		List<Contact_Role_Service_Access__c> accessDeniedToUpdate = new List<Contact_Role_Service_Access__c>();
		List<Id> rolesForAccessGrantedIds = new List<Id>();


		for(Id origRoleId : originalRoles.keySet()) {

			//was checked and now is not - we have crsa
			if(originalRoles.get(origRoleID).isChecked) {
				if(! modifiedRoles.get(origRoleID).isChecked) {
					//role was de-selected
					Contact_Role_Service_Access__c access = userRoles.get(origRoleID);
					access.Status__c = 'Denied';
					accessDeniedToUpdate.add(access);
				}
			}
			//was not checked and now is - find out i crsa exist (and change to granted) or create new crsa
			if(! originalRoles.get(origRoleId).isChecked) {
				if(modifiedRoles.get(origRoleId).isChecked) {
					Contact_Roles__c role = originalRoles.get(origRoleId).Role;
					rolesForAccessGrantedIds.add(role.Id);
				}
			}
		}

		if(! rolesForAccessGrantedIds.isEmpty()) {

			Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
			List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__r.Name, Contact_Role__r.Contact_Roles__r.Category__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = : con.Id AND Contact_Role__r.Contact_Roles__c = :rolesForAccessGrantedIds AND Contact_Role__r.RecordTypeId = :functionalRecordTypeId  AND (Contact_Role__r.Contact_Roles__r.Category__c = null OR Contact_Role__r.Contact_Roles__r.Category__c = '') AND Service__r.Name = 'GADM' AND Status__c != 'Granted'];

			Map<Id, Contact_Role_Service_Access__c> rolesToAccessMap = new Map<Id, Contact_Role_Service_Access__c>();
			for(Contact_Role_Service_Access__c access : serviceAccesses) {
				rolesToAccessMap.put(access.Contact_Role__r.Contact_Roles__c, access);
			}

			List<Contact_Role_Service_Access__c> accessGrantedToUpdate = new List<Contact_Role_Service_Access__c>();
			List<Id> createNewRolesIds = new List<Id>();

			for(Id roleId : rolesForAccessGrantedIds) {
				if(rolesToAccessMap.get(roleId) != null) {
					accessGrantedToUpdate.add(rolesToAccessMap.get(roleId));
				}else{
					createNewRolesIds.add(roleId);
				}
			}

			//update
			for(Contact_Role_Service_Access__c access : accessGrantedToUpdate) {
				access.Status__c = 'Granted';
			}

			//create new granted access
			if(! createNewRolesIds.isEmpty()) {

				List<Portal_Applications__c> gadm = [SELECT Id FROM Portal_Applications__c WHERE Name = 'GADM'];

				//check if there are some Account Contact Roles without Account Contact Roles Service Access
				List<Account_Contact_Role__c> existingAccountContactRoles = [SELECT Id, Contact_Roles__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact__c = :con.Id AND Contact_Roles__c = :createNewRolesIds];

				Map<Id,Account_Contact_Role__c> accountContactRoleMap = new Map<Id, Account_Contact_Role__c>();
				for(Account_Contact_Role__c accountContactRole : existingAccountContactRoles) {
					accountContactRoleMap.put(accountContactRole.Contact_Roles__c, accountContactRole);
				}

				Set<Id> accountContactRoleExists = new Set<Id>();
				Set<Id> accountContactRoleMissing = new Set<Id>();

				for(Id roleId : createNewRolesIds) {
					if(accountContactRoleMap.get(roleId) == null) {
						accountContactRoleMissing.add(roleId);
					}else{
						accountContactRoleExists.add(roleId);
					}
				}

				//if yes - use it and create new Account Contact Role Service Access
				if(! accountContactRoleExists.isEmpty()) {

					List<Contact_Role_Service_Access__c> accessToCreate = new List<Contact_Role_Service_Access__c>();
					for(Id roleId : accountContactRoleExists) {
						Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
						access.Service__c = gadm[0].Id;
						access.Status__c = 'Granted';
						access.Contact_Role__c = accountContactRoleMap.get(roleId).Id;
						accessToCreate.add(access);
					}

					insert accessToCreate;
				}

				//if not - create new Account Contact Roles and new Account Contact Role Service Access for them
				if(! accountContactRoleMissing.isEmpty()){
					List<Account_Contact_Role__c> accountContactRoles = [SELECT Id, Account_Role__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact__c = :con.Id AND Contact_Roles__r.Name = 'GADM User'];

					Map<Id, Account_Contact_Role__c> accountContactRolesToCreate = new Map<Id, Account_Contact_Role__c>();
					Map<Id, Contact_Role_Service_Access__c> accessToCreate = new Map<Id, Contact_Role_Service_Access__c>();

					for(Id roleId : accountContactRoleMissing) {

						Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
						accountContactRole.Contact__c = con.Id;
						accountContactRole.Contact_Roles__c = roleId;
						accountContactRole.Service_Rendered__c = 'GADM';
						accountContactRole.RecordTypeId = functionalRecordTypeId;
						accountContactRole.Account_Role__c = accountContactRoles[0].Account_Role__c;
						accountContactRolesToCreate.put(roleId, accountContactRole);

						Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
						access.Service__c = gadm[0].Id;
						access.Status__c = 'Granted';
						accessToCreate.put(roleId, access);
					}

					insert accountContactRolesToCreate.values();

					for(Id roleId : accountContactRolesToCreate.keySet()) {
						Account_Contact_Role__c acr = accountContactRolesToCreate.get(roleId);
						Contact_Role_Service_Access__c crsa = accessToCreate.get(roleId);
						crsa.Contact_Role__c = acr.Id;
					}

					insert accessToCreate.values();
				}
			}
			update accessGrantedToUpdate;
		}

		update accessDeniedToUpdate;

	}


	private static void handleBusinessUnits(Map<Id, BusinessUnit> originalBusinessUnits, Map<Id, BusinessUnit> modifiedBusinessUnits, Map<Id, Contact_Role_Service_Access__c> userBusinessUnits, Contact con) {

		List<Contact_Role_Service_Access__c> accessDeniedToUpdate = new List<Contact_Role_Service_Access__c>();
		List<Id> businessUnitsForAccessGrantedIds = new List<Id>();

		for(Id origBuId : originalBusinessUnits.keySet()) {

			//was checked and now is not - we have crsa
			if(originalBusinessUnits.get(origBuId).isChecked) {
				if(! modifiedBusinessUnits.get(origBuId).isChecked) {
					//role was de-selected
					Contact_Role_Service_Access__c access = userBusinessUnits.get(origBuId);
					access.Status__c = 'Denied';
					accessDeniedToUpdate.add(access);
				}
			}
			//was not checked and now is - find out i crsa exist (and change to granted) or create new crsa
			if(! originalBusinessUnits.get(origBuId).isChecked) {
				if(modifiedBusinessUnits.get(origBuId).isChecked) {
					Contact_Roles__c businessUnit = originalBusinessUnits.get(origBuId).BusinessUnit;
					businessUnitsForAccessGrantedIds.add(businessUnit.Id);
				}
			}
		}

		if(! businessUnitsForAccessGrantedIds.isEmpty()) {

			Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
			List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__c, Contact_Role__r.Contact_Roles__r.Name, Contact_Role__r.Contact_Roles__r.Category__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = : con.Id AND Contact_Role__r.Contact_Roles__c = :businessUnitsForAccessGrantedIds AND Contact_Role__r.RecordTypeId = :groupRecordTypeId AND Contact_Role__r.Contact_Roles__r.Category__c = 'Business Unit' AND Service__r.Name = 'GADM' AND Status__c != 'Granted'];

			Map<Id, Contact_Role_Service_Access__c> roleToAccessMap = new Map<Id, Contact_Role_Service_Access__c>();
			for(Contact_Role_Service_Access__c access : serviceAccesses) {
				roleToAccessMap.put(access.Contact_Role__r.Contact_Roles__c, access);
			}

			List<Contact_Role_Service_Access__c> accessGrantedToUpdate = new List<Contact_Role_Service_Access__c>();
			List<Id> createNewBusinessUnitIds = new List<Id>();

			for(Id roleId : businessUnitsForAccessGrantedIds) {
				if(roleToAccessMap.get(roleId) != null) {
					accessGrantedToUpdate.add(roleToAccessMap.get(roleId));
				}else{
					createNewBusinessUnitIds.add(roleId);
				}
			}

			//update
			for(Contact_Role_Service_Access__c access : accessGrantedToUpdate) {
				access.Status__c = 'Granted';
			}

			//create new granted access
			if(! createNewBusinessUnitIds.isEmpty()) {

				List<Portal_Applications__c> gadm = [SELECT Id FROM Portal_Applications__c WHERE Name = 'GADM'];
				Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');

				//check if there are some Account Contact Roles without Account Contact Role Service Access
				List<Account_Contact_Role__c> existingAccountContactRoles = [SELECT Id, Contact_Roles__c FROM Account_Contact_Role__c WHERE RecordTypeId = :groupRecordTypeId AND Contact__c = :con.Id AND Contact_Roles__c = :createNewBusinessUnitIds];

				Map<Id,Account_Contact_Role__c> accountContactRoleMap = new Map<Id, Account_Contact_Role__c>();
				for(Account_Contact_Role__c accountContactRole : existingAccountContactRoles) {
					accountContactRoleMap.put(accountContactRole.Contact_Roles__c, accountContactRole);
				}

				Set<Id> accountContactRoleExists = new Set<Id>();
				Set<Id> accountContactRoleMissing = new Set<Id>();

				for(Id roleId : createNewBusinessUnitIds) {
					if(accountContactRoleMap.get(roleId) == null) {
						accountContactRoleMissing.add(roleId);
					}else{
						accountContactRoleExists.add(roleId);
					}
				}

				//if there are some - create Contact Service Role Access for them
				if(! accountContactRoleExists.isEmpty()) {

					List<Contact_Role_Service_Access__c> accessToCreate = new List<Contact_Role_Service_Access__c>();
					for(Id roleId : accountContactRoleExists) {
						Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
						access.Service__c = gadm[0].Id;
						access.Status__c = 'Granted';
						access.Contact_Role__c = accountContactRoleMap.get(roleId).Id;
						accessToCreate.add(access);
					}

					insert accessToCreate;

				}

				//if not - create Account Contact Roles and Contact Role Service Access for them
				if(! accountContactRoleMissing.isEmpty()){

					List<Account_Contact_Role__c> accountContactRoles = [SELECT Id, Account_Role__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact__c = :con.Id AND Contact_Roles__r.Name = 'GADM User'];

					Map<Id, Account_Contact_Role__c> accountContactRolesToCreate = new Map<Id, Account_Contact_Role__c>();
					Map<id, Contact_Role_Service_Access__c> accessToCreate = new Map<Id, Contact_Role_Service_Access__c>();

					for(Id roleId : accountContactRoleMissing) {

						Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
						accountContactRole.Contact__c = con.Id;
						accountContactRole.Contact_Roles__c = roleId;
						accountContactRole.Service_Rendered__c = 'GADM';
						accountContactRole.RecordTypeId = groupRecordTypeId;
						accountContactRole.Account_Role__c = accountContactRoles[0].Account_Role__c;
						accountContactRolesToCreate.put(roleId, accountContactRole);

						Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
						access.Service__c = gadm[0].Id;
						access.Status__c = 'Granted';
						accessToCreate.put(roleId, access);
					}

					insert accountContactRolesToCreate.values();

					for(Id roleId : accountContactRolesToCreate.keySet()) {
						Account_Contact_Role__c acr = accountContactRolesToCreate.get(roleId);
						Contact_Role_Service_Access__c crsa = accessToCreate.get(roleId);
						crsa.Contact_Role__c = acr.Id;
					}

					insert accessToCreate.values();
				}
			}

			update accessGrantedToUpdate;

		}

		update accessDeniedToUpdate;

	}



	private static void handleActors(Map<Id, Actor> originalActors, Map<Id, Actor> modifiedActors, Map<Id, Account_Contact_Role__c> userActors, Contact con) {

		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
		List<Account_Contact_Role__c> toDelete = new List<Account_Contact_Role__c>();
		List<Id> accIdtoCreate = new List<Id>();

		for(Id origActorId : originalActors.keySet()) {
			//was checked and now is not - we have crsa
			if(originalActors.get(origActorId).isChecked) {
				if(! modifiedActors.get(origActorId).isChecked) {
					//role was de-selected
					Account_Contact_Role__c accountContactRole = userActors.get(origActorId);
					toDelete.add(accountContactRole);
				}
			}
			//was not checked and now is - find out i crsa exist (and change to granted) or create new crsa
			if(! originalActors.get(origActorId).isChecked) {
				if(modifiedActors.get(origActorId).isChecked) {
					Account acc = originalActors.get(origActorId).actor;
					accIdtoCreate.add(acc.Id);
				}
			}
		}

		if(! toDelete.isEmpty()) {
			delete toDelete;
		}


		if(! accIdtoCreate.isEmpty()) {

			List<Account_Contact_Role__c> accountContactRolesToCreate = new List<Account_Contact_Role__c>();

			List<Account_Role__c> accountRoles = [SELECT Id, Account__c FROM Account_Role__c WHERE Account__c = :accIdtoCreate AND Account_Roles__r.Name = 'GADM Participant'];
			List<Contact_Roles__c> roles = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];

			Map<Id, Account_Role__c> accIdToAccountRoleMap = new Map<Id, Account_Role__c>();
			for(Account_Role__c accountRole : accountRoles) {
				accIdToAccountRoleMap.put(accountRole.Account__c, accountRole);
			}

			for(Id accId : accIdtoCreate) {
				Account_Contact_Role__c acr = new Account_Contact_Role__c();
				acr.Service_Rendered__c = 'GADM';
				acr.Contact__c = con.Id;
				acr.Account_Role__c = accIdToAccountRoleMap.get(accId).Id;
				acr.RecordTypeId = groupRecordTypeId;
				acr.Contact_Roles__c = roles[0].Id;

				accountContactRolesToCreate.add(acr);
			}

			if(! accountContactRolesToCreate.isEmpty()) {
				insert accountContactRolesToCreate;
			}

		}

	}


	public class UserManagementData {
		@AuraEnabled
		public boolean currentUserIsSelectedUser {get; set;}
		@AuraEnabled
		public Map<Id, Role> roles {get; set;}
		@AuraEnabled
		public Map<Id, BusinessUnit> businessUnits {get; set;}
		@AuraEnabled
		public Map<Id, Actor> actors {get; set;}

	}

	public class Role {
		@AuraEnabled
		public Contact_Roles__c role {get; set;}
		@AuraEnabled
		public Boolean isChecked {get; set;}
		@AuraEnabled
		public Boolean isEditable {get; set;}
		@AuraEnabled
		public Boolean isDomainBlocked {get; set;}
	}

	public class BusinessUnit {
		@AuraEnabled
		public Contact_Roles__c businessUnit {get; set;}
		@AuraEnabled
		public Boolean isChecked {get; set;}
		@AuraEnabled
		public Boolean isEditable {get; set;}
	}

	public Class Actor {
		@AuraEnabled
		public Account actor {get; set;}
		@AuraEnabled
		public Boolean isChecked {get; set;}
		@AuraEnabled
		public Boolean isEditable {get; set;}
		@AuraEnabled
		public Boolean isDomainBlocked {get; set;}
		@AuraEnabled
		public Integer maxUserCount {get; set;}
		@AuraEnabled
		public Integer currentUserCount {get; set;}
	}

}
