/**
 * @description		CW_Utilities of OneSource project
 * 						Without sharing in order to be able to get company and station information, and also to become company admin
 */
public without sharing class CW_Utilities {

	@AuraEnabled (cacheable=true)
	public static ICG_Portal_URL__mdt getMetadataInfo(String mtdName) {

		// Fetch the metadata required
		ICG_Portal_URL__mdt metadata = [SELECT Id,MasterLabel, DeveloperName, Link__c, Description__c 
											  FROM ICG_Portal_URL__mdt WHERE DeveloperName =: mtdName LIMIT 1];

		return metadata;
	}

	@AuraEnabled (cacheable=true)
	public static String getURLPage(String page) {

		String result;

		ICG_Portal_URL__mdt metadata = [SELECT Id,MasterLabel, DeveloperName, Link__c, Description__c 
										FROM ICG_Portal_URL__mdt WHERE DeveloperName =: page LIMIT 1];

		String urlBase = getCommunityUrlBase();

			result = urlBase +  metadata.Description__c;

		return result;
	}
	public static String getCommunityUrlBase() {
		return ISSP_CS__c.getValues('ICG_URL_Base').Value__c;
	}
	@AuraEnabled (cacheable = true)
	public static ICG_Environment_Variables__c getEnvironmentVariables() {
		return ICG_Environment_Variables__c.getInstance();
	}

	@AuraEnabled (cacheable = true)
	public static String getUserRole(String facilityId) {
		
		String userRole = 'Not assigned';
		if(UserInfo.getUserType() == 'Guest') {
			userRole = 'Guest';
		} else {
			List<User> usr = [Select Id, Name, Email, ContactId, Account.Name from User where Id = :UserInfo.getUserId()];
			if(!usr.isEmpty() && usr[0].ContactId != null && facilityId != null) {
				List<ICG_Account_Role_Detail__c> station = [Select id, Account_Role__c, Account_Role__r.Account__r.Name from ICG_Account_Role_Detail__c where id =:facilityId];
 
				if(!station.isEmpty()) {
					List<ICG_Contact_Role_Detail__c> userFacilityRelationList = [Select id, ICG_Role__c, Status__c, Account_Role__c, isPendingApproval__c, isApproved__c from ICG_Contact_Role_Detail__c where Account_Contact_Role__r.Contact__c = :usr[0].ContactId and
                    (ICG_Account_Role_Detail__c = :facilityId AND ICG_Role__c = 'Facility Manager')];
                    
					if (userFacilityRelationList.size()>0) {
						Set<Id> accountRolesCompanyAdmin = new Set<Id>();
						Set<Id> accountRolesPendingCompanyAdmin = new Set<Id>();
						for (ICG_Contact_Role_Detail__c crd : userFacilityRelationList) {
							if (crd.ICG_Role__c == 'Facility Manager' && crd.isApproved__c) {
								userRole = 'Facility Manager';
							} else if (crd.ICG_Role__c == 'Facility Manager' && crd.isPendingApproval__c) {
								userRole = 'Pending Facility Manager';
							}

						}
					}
					//Get station ops hierarchy
					String opsHierarchyGroup = getOpsHierarchyNameFromStationId(station[0].Id);
					List<Contact> companyAdminsFromGroup = getCompanyAdminContactsFromGroupName(opsHierarchyGroup);

					for(Contact con : companyAdminsFromGroup) {
						if(con.Id == usr[0].contactId) {
							userRole = 'Company Admin';
						}
					}
					if(userRole != 'Facility Manager' && userRole != 'Company Admin') {
						List<Contact> pendingCompanyAdminsFromGroup = getCompanyAdminContactsFromGroupNameByStatus(opsHierarchyGroup, 'Pending for Approval');
						for(Contact con : pendingCompanyAdminsFromGroup) {
							if(con.Id == usr[0].contactId) {
								userRole = 'Pending Company Admin';
							}
						}
					}
				}

			}
		}
		
		return userRole;
	}

	@AuraEnabled (cacheable = true)
	public static Boolean getPermissionToEdit() {
		Boolean result=false;
		AggregateResult[] exist = [SELECT count(Id) FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND (PermissionSet.Name = 'One_Source_Backend_Admin' OR PermissionSet.Name = 'One_Source_Certification_Manager')];
		if(exist.size()>0) {
			if(Integer.valueOf(exist[0].get('expr0')) > 0) {
				result = true;
			}
		}
		return result;
	}

	@AuraEnabled
	public static Boolean approveStationAutomaticProcess(String stationId) {
		try{
			if (getUserRole(stationId) == 'Company Admin') {
				//if it does not exists, then go thru exception process
				ICG_Account_Role_Detail__c ard = [Select id, Status__c, Account_Role__r.Account__c, CreatedBy.ContactId, CreatedBy.Id from ICG_Account_Role_Detail__c Where id =:stationId];
				if (ard.Status__c == 'Pending for Approval') {
					ard.Status__c = 'Pending for IATA Approval';
					ard.Company_Admin_Approver_Rejector__c = UserInfo.getUserId();
					update ard;
					String whoId = ard.CreatedBy.ContactId != null ? ard.CreatedBy.ContactId : ard.CreatedById;
					String templateName = 'Approve_Reject_IATA_Adm_after_comp_appro';
					List<String> whoEmails = new List<String>();
					for(User u : CW_Utilities.getIATAStakeHoldersUsersList()) {
						if(u.email != null) {
							whoEmails.add(u.email);
						}
					}
					Boolean approved = CW_Utilities.sendEmailTemplate(templateName, ard.Id, whoId, whoEmails);
					return approved;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}catch (Exception ex) {
			throw new AuraHandledException('Aura handled exception: ' + ex);
		}
	}

	/**
	 * @description		Handles whether a contact removal will be approved or rejected
	 * @param			contactRoleDetailId <The id of the contact role in question>
	 * @param			approvedRemoval <Whether it was approved in front end or not>
	 * @return			String explination of outcome
	 */
	@AuraEnabled
	public static String handleContactRoleDetailRemovalProcess(String contactRoleDetailId, Boolean approvedRemoval) {
		try {
			ICG_Contact_Role_Detail__c crd = [SELECT id, ICG_Account_Role_Detail__c, ICG_Role__c, Account_Role__c, Account_Role__r.Account__c, Account_Contact_Role__r.Contact__c, Status__c FROM ICG_Contact_Role_Detail__c WHERE id = :contactRoleDetailId];
			String userRole = crd.ICG_Account_Role_Detail__c != null && crd.ICG_Role__c == 'Facility Manager' ? getUserRole(crd.ICG_Account_Role_Detail__c) : null;
			User approver = [SELECT id, contactId FROM User WHERE id = :UserInfo.getUserId()];

			if (userRole == null && crd.Account_Role__c != null) {
				for (Contact con : getCompanyadminContactsFromAccountId(crd.Account_Role__r.Account__c)) {
					if (approver.ContactId == con.Id) {
						userRole = 'Company Admin';
					}
				}
			}
			if (userRole == 'Company Admin') {
				crd.Status__c = approvedRemoval ? 'Removed' : 'Approved';
				crd.Company_Admin_Approver_Rejector__c = UserInfo.getUserId();
				update crd;
				return approvedRemoval ? 'Successful' : 'Unsuccessful';
			} else {
				return 'MissingRights';
			}

		} catch (Exception ex) {
			throw new AuraHandledException('Aura handled exception: ' + ex);
		}
	}

	@AuraEnabled
	public static Boolean approveContactRoleDetailAutomaticProcess(String contactRoleDetailId) {
		try{
			//if it does not exists, then go thru exception process
			ICG_Contact_Role_Detail__c crd = [Select id,Status__c, ICG_Role__c, ICG_Account_Role_Detail__c,Account_Role__c,Account_Role__r.Account__c,Account_Contact_Role__r.Contact__c FROM ICG_Contact_Role_Detail__c where id = :contactRoleDetailId];
			String userRole = crd.ICG_Account_Role_Detail__c != null && crd.ICG_Role__c == 'Facility Manager' ? getUserRole(crd.ICG_Account_Role_Detail__c) : null;
			User approver = [Select id, contactId from User where id = :UserInfo.getUserId()];
			if(userRole == null && crd.Account_Role__c != null) {
				for (Contact con : getCompanyadminContactsFromAccountId(crd.Account_Role__r.Account__c)) {
					if (approver.ContactId == con.Id) {
						userRole = 'Company Admin';
					}
				}
			}
			if (userRole == 'Company Admin' || userRole == 'Facility Manager') {
				if (crd.Status__c == 'Pending for Approval') {
					crd.Status__c = 'Approved';
					crd.Company_Admin_Approver_Rejector__c = UserInfo.getUserId();
					update crd;
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}catch (Exception ex) {
			throw new AuraHandledException('Aura handled exception: ' + ex);
		}
	}
	@AuraEnabled
	public static Boolean rejectContactRoleDetailAutomaticProcess(String contactRoleDetailId, String rejectReason) {
		try{
			//if it does not exists, then go thru exception process
			ICG_Contact_Role_Detail__c crd = [Select id,Status__c, ICG_Role__c, ICG_Account_Role_Detail__c,Account_Role__c,Account_Role__r.Account__c,Account_Contact_Role__r.Contact__c FROM ICG_Contact_Role_Detail__c where id = :contactRoleDetailId];
			String userRole = crd.ICG_Account_Role_Detail__c != null && crd.ICG_Role__c == 'Facility Manager' ? getUserRole(crd.ICG_Account_Role_Detail__c) : null;
			User approver = [Select id, contactId from User where id = :UserInfo.getUserId()];
			if(userRole == null && crd.Account_Role__c != null) {
				for (Contact con : getCompanyadminContactsFromAccountId(crd.Account_Role__r.Account__c)) {
					if (approver.ContactId == con.Id) {
						userRole = 'Company Admin';
					}
				}
			}
			if (userRole == 'Company Admin' || userRole == 'Facility Manager') {
				if (crd.Status__c == 'Pending for Approval') {
					crd.Status__c = 'Rejected';
					crd.Reject_Reason__c = rejectReason;
					crd.Company_Admin_Approver_Rejector__c = UserInfo.getUserId();
					update crd;
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}catch (Exception ex) {
			throw new AuraHandledException('Aura handled exception: ' + ex);
		}
	}

	@AuraEnabled
	public static Boolean rejectStationAutomaticProcess(String stationId, String rejectReason) {

		try{
			if (getUserRole(stationId) == 'Company Admin') {
				//if it does not exists, then go thru exception process
				ICG_Account_Role_Detail__c ard = [Select id, Status__c from ICG_Account_Role_Detail__c Where id =:stationId];
				if (ard.Status__c == 'Pending for Approval') {
					ard.Status__c = 'Rejected';
					ard.Reject_Reason__c = rejectReason;
					ard.Company_Admin_Approver_Rejector__c = UserInfo.getUserId();
					update ard;
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}catch (Exception ex) {
			throw new AuraHandledException('Aura handled exception: ' + ex);
		}
		
	}

	@AuraEnabled (cacheable = true)
	public static String getCompanyTypes() {
		Schema.DescribeSObjectResult d = Schema.SObjectType.ICG_Account_Role_Detail__c; 
		Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
		List<CompanyType> companyTypes = new List<CompanyType>();
		String baseResourceUrl = getResourceURL('ICG_Resources');
		for(Id rtid : rtMapById.keySet()) {

			if(rtMapById.get(rtid).getName() != 'Master') {
				CompanyType ct = new CompanyType();
				ct.rtid = rtid;
				ct.name = rtMapById.get(rtid).getName();
				ct.value = rtMapById.get(rtid).getDeveloperName();
				ct.field = 'RecordType.DeveloperName';
				ct.obj = 'ICG_Account_Role_Detail__c';
				ct.selected = false;
				ct.enabled = rtMapById.get(rtid).isActive();
				ct.userAvailable = rtMapById.get(rtid).isAvailable();
			ct.image = baseResourceUrl + '/icons/company_type/'+ct.value.toLowerCase().replaceAll('_','-')+'.svg';
			companyTypes.add(ct);
			}
		}
		return JSON.serialize(companyTypes);
	}

	@AuraEnabled (cacheable = true)
	public static String getIATACountries() {
		List<IATA_ISO_Country__c> countries = [select id, name, ISO_Code__c, ISO_Code_Numeric__c from IATA_ISO_Country__c];
		return JSON.serialize(countries);
	}

	// Pass the resource name
	public static String getResourceURL(String resourceName) {

		// Fetching the resource
		List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

		// Checking if the result is returned or not
		if(resourceList.size() == 1) {

			// Getting namespace
			String namespace = resourceList[0].NamespacePrefix;
			// Resource URL
			return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
		}
		else {
			return '';
		}
	}

	public class CompanyType {
		@AuraEnabled
		public String rtid {get;set;}
		@AuraEnabled
		public String name {get;set;}
		@AuraEnabled
		public String field {get;set;}
		@AuraEnabled
		public String value {get;set;}
		@AuraEnabled
		public String obj {get;set;}
		@AuraEnabled
		public String image {get;set;}
		@AuraEnabled
		public Boolean selected {get;set;}
		@AuraEnabled
		public Boolean enabled {get;set;}
		@AuraEnabled
		public Boolean userAvailable {get;set;}
	}

	//Not cacheable at they can be called more than once in the same context
	//and perform the action
	@AuraEnabled
	public static String becomeFacilityAdmin(String companyId, String facilityIds, String contactId, Boolean skipApprovalProcess) {
		ResponseBody res = new ResponseBody();
		if(facilityIds != null && contactId != null) {
			try {
				String status = skipApprovalProcess  == true ? 'Approved' : 'Pending for Approval';
				List<ICG_Contact_Role_Detail__c> crdsToInsert = getContactRoleDetailsToInsert(companyId, facilityIds, contactId, status);
				if(crdsToInsert.isEmpty() || crdsToInsert.size()>1) {
					res.success = false;
					res.message = crdsToInsert.size()>1 ? 'The process can process One station at a time. Please try by selecting only one station' : 'No Account Contact Role found for this contact. Please contact IATA.';
				} else {
					insert crdsToInsert;
					Boolean submitted = true;
					List<ICG_Notification__c> notifications = new List<ICG_Notification__c>();
					Contact con = [Select id, email from contact where id = :contactId];
					if(skipApprovalProcess != true) {
						//ONLY PREPARED TO BE SENT TO ONE! It's controled above.
						for(ICG_Contact_Role_Detail__c crdti : crdsToInsert) {
							//Send Email to Requestor
							sendEmailTemplate('Station_Manager_Request_sent_to_req', crdti.Id, contactId, new List<String> {con.email});
							String subject = 'Station Manager request sent';
							String body = subject;
							notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', new List<String> {con.Id}, crdti.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
							Set<String> stationManagerCompanyAdminEmails = new Set<String>();
							List<String> iataAdminEmails = new List<String>();
							List<String> contactIds = new List<String>();
							for (ICG_Contact_Role_Detail__c crd : getStationManagersContactRoleDetails(crdti.ICG_Account_Role_Detail__c)) {
								stationManagerCompanyAdminEmails.add(crd.Account_Contact_Role__r.Contact__r.Email);
								contactIds.add(crd.Account_Contact_Role__r.Contact__c);
							}
							for (Contact cadmn : getCompanyadminContactsFromAccountId(companyId)) {
								stationManagerCompanyAdminEmails.add(cadmn.Email);
								contactIds.add(cadmn.Id);
							}
							for (User u :getIATAStakeHoldersUsersList()) {
								iataAdminEmails.add(u.Email);
							}
							if(!stationManagerCompanyAdminEmails.isEmpty()) {
								submitted = sendEmailTemplate('Approve_Reject_Com_Adm_exis_Stat_Man', crdti.Id, contactId, new List<String> (stationManagerCompanyAdminEmails));
								String subjectCompAdmin = 'New Station Manager request pending approval';
								String bodyCompAdmin = subjectCompAdmin;
								notifications.addAll(CW_NotificationsController.setNotificationCustom(subjectCompAdmin, bodyCompAdmin, 'Requested', contactIds, crdti.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
								if(!iataAdminEmails.isEmpty()) {
									submitted = submitted && sendEmailTemplate('Approve_Reject_to_IATA_Admin', crdti.Id, contactId, iataAdminEmails);
								}
							} else {
								submitted = sendEmailTemplate('Approve_Reject_to_IATA_Adm_no_Comp_adm', crdti.Id, contactId, new List<String> (iataAdminEmails));						
							}
						}
					}
					if (submitted == true) {
						res.success = true;
						res.message = 'Thank you for your request. IATA will contact you shortly.';
					} else {
						res.success = false;
						res.message = 'Something went wrong. Please contact IATA. Comment: Approval Process not triggered';                
					}

					if(notifications.size() > 0) {
						insert notifications;
					}
				}
			} catch(Exception ex) {
				res.success = false;
				res.message = ex.getMessage();
			}
		} else {
			res.success = false;
			res.message = 'Please, select at least one facility';
		}
		
		
		return JSON.serialize(res);
	}

	@AuraEnabled
	public static List<ICG_Contact_Role_Detail__c> getStationManagersContactRoleDetails(String stationId) {
		return getFacilityManagerContactRolesFromStationListByStatus(new List<String>{stationId}, 'Approved');
	}

	public static List<ICG_Contact_Role_Detail__c> getContactRoleDetailsToInsert(String companyId, String facilityIds, String contactId, String status) {
		List<ICG_Contact_Role_Detail__c> crdsToInsert = new List<ICG_Contact_Role_Detail__c>();
		List<String> facilityIdsToLoop = facilityIds.replaceAll('[^a-zA-Z0-9,\\s+]', '').split(',');
		ICG_Contact_Role_Detail__c crd; 	

		List<Account_Role__c> accountRoles = [Select Id from Account_Role__c where Account__c =: companyId and Functional_Role__c = 'One Source'];
		Id accountRoleId = !accountRoles.isEmpty() ? accountRoles[0].Id : null;

		List<Account_Contact_Role__c> acr = getAccountContactRole(companyId, contactId, accountRoleId);
		
		for (String facId : facilityIdsToLoop) {
			crd = new ICG_Contact_Role_Detail__c();
			crd.ICG_Role__c = 'Facility Manager';
			crd.Status__c = status;
			crd.Account_Contact_Role__c = acr[0].id;
			crd.ICG_Account_Role_Detail__c = facId;
			crdsToInsert.add(crd);
		}
		return crdsToInsert;
	}

	private static List<Account_Contact_Role__c> getAccountContactRole(String companyId, String contactId, Id accountRoleId) {

		String accRoleId = accountRoleId;


		if(accountRoleId == null) {
			Account_Role__c accRole = new Account_Role__c();
			accRole.Account__c = companyId;
			accRole.Functional_Role__c = 'One Source';
			insert accRole;

			accRoleId = accRole.Id;
		}
		
		List<Account_Contact_Role__c> acr = [Select id from Account_Contact_Role__c where Contact__c = :contactId and Account__c = :companyId and Functional_Role__c = 'One Source'];

		if(acr.isEmpty()) {	


			Account_Contact_Role__c acrObj = new Account_Contact_Role__c();
			acrObj.Account__c = companyId;
			acrObj.Contact__c = contactId;
			acrObj.Functional_Role__c = 'One Source';
			acrObj.Account_Role__c = accRoleId;
			acrObj.Service_Rendered__c = 'TIP';
			acr.add(acrObj);
			insert acr;
		}

		return acr;
	}

    @AuraEnabled
	public static String becomeCompanyAdminFromStation(String stationId, String companyId, String contactId) {
		return becomeCompanyAdmin(getOpsHierarchyNameFromStationId(stationId), companyId, contactId);
	}

	@AuraEnabled
	public static String becomeCompanyAdmin(String groupName, String companyId, String contactId) {
		ResponseBody res = new ResponseBody();
		Set<Id> accRolesIds = getAccountsRolesToSearch(groupName);


		if(accRolesIds.isEmpty()) {
			//Get Ops Hierarchy -- Encapsulate
			List<Account> acc = [Select id,Global_Ultimate_Account_Global_ID__c,(Select id from Account_Roles__r where Functional_Role__c = 'One Source') from Account where Name = :groupName];
			if(!acc.isEmpty()) {
				List<Account_Role__c> accRoles = acc[0].Account_Roles__r;
				if(accRoles.isEmpty()) {
					//Create account roles for the company (parent or user company) if they do not have
					Account_Role__c accr = new Account_Role__c();
					accr.Account__c = acc[0].Id;
					accr.Functional_Role__c = 'One Source';
					accRoles.add(accr);
				}
				
				Id accountRoleId;
				if(!accRoles.isEmpty()) {
					insert accRoles;
					accountRoleId = accRoles[0].id;
				} else {
					for(Account loopacc : acc) {
						//Once the opsHierarchyName is populated, create account roles for the company (parent or user company) if they do not have
						if(!loopacc.Account_Roles__r.isEmpty()) {
							accountRoleId = loopacc.Account_Roles__r[0].Id;
						}	
					}
				}
				List<Account_Contact_Role__c> acr = getAccountContactRole(companyId, contactId, accountRoleId);
				res = createCompanyAdminContactRoleDetail(acr[0].Id,accountRoleId, groupName, contactId);				

			} else {
				res.success=false;
				res.message = 'You do not belong to any company. Please contact your IATA Administrator.';
			}
		} else {
			List<Account_Contact_Role__c> acr = getAccountContactRole(companyId, contactId, new List<Id>(accRolesIds)[0]);
			res = createCompanyAdminContactRoleDetail(acr[0].Id,new List<Id>(accRolesIds)[0], groupName, contactId);
		}
		
		return JSON.serialize(res);
	}
	private static ResponseBody createCompanyAdminContactRoleDetail(String accContactRole, String accRoleId, String groupName, Id contactId ) {
		ResponseBody res = new ResponseBody();
		ICG_Contact_Role_Detail__c crd = new ICG_Contact_Role_Detail__c();
		crd.ICG_Role__c = 'Company Admin';
		crd.Status__c = 'Pending for Approval';
		crd.Account_Contact_Role__c = accContactRole;
		crd.Account_Role__c = accRoleId;
		try {
			insert crd;
			Contact con = [Select id, email from contact where id = :contactId];
			Boolean submitted = true;
			//Send Email to Requestor
			sendEmailTemplate('Comp_Adm_req_conf_to_requestor_sent', crd.Id, contactId, new List<String> {con.email});
			Set<String> companyAdminEmails = new Set<String>();
			List<String> iataAdminEmails = new List<String>();
			for (Contact cadmn : getCompanyadminContactsFromGroupName(groupName)) {
				companyAdminEmails.add(cadmn.Email);
			}
			for (User u :getIATAStakeHoldersUsersList()) {
				iataAdminEmails.add(u.Email);
			}
			if(!companyAdminEmails.isEmpty()) {
				submitted = submitted && sendEmailTemplate('Approve_Reject_to_existing_Comp_Adm', crd.Id, contactId, new List<String> (companyAdminEmails));
			}
			submitted = submitted && sendEmailTemplate('Approve_Reject_to_IATA_admin_CA', crd.Id, contactId, iataAdminEmails);

			if (submitted) {
				res.success = true;
				res.message = 'Thank you for your request. IATA will contact you shortly.';
			} else {
				res.success = false;
				res.message = 'Something went wrong. Please contact IATA. Comment: Approval Process not triggered';                
			}
			
		}catch(Exception ex) {
			res.success = false;
			res.message = ex.getMessage();
		}
		return res;
	}

	public static List<User> getIATAStakeHoldersUsersList() {
		return [Select id, name, email from User where Id IN (Select UserOrGroupId from GroupMember where Group.DeveloperName = 'ICG_Stakeholders')];
	}

	public static List<Contact> getCompanyAdminContactsFromGroupNameByStatus (String groupName, String status) {
		
		Set<Id> contactsIds = new Set<Id>();
		for (ICG_Contact_Role_Detail__c crd : getCompanyAdminContactRolesFromGroupNameByStatus(groupName, status)) {
			if(crd.ContactId__c != null) {
				contactsIds.add(crd.ContactId__c);
			}
		}
		List<Contact> adminContacts = [Select Id, Firstname, Lastname, Email, Title, Phone from Contact where ID IN :contactsIds];
		return adminContacts;
	}
	public static List<ICG_Contact_Role_Detail__c> getCompanyAdminContactRolesFromGroupNameByStatus(String groupName, String status) {
		Set<Id> accountRolesToSearch = getAccountsRolesToSearch(groupName);
		return [Select Id, CreatedDate, ContactId__c, Account_Contact_Role__r.Contact__r.FirstName, Account_Contact_Role__r.Contact__r.LastName, Account_Contact_Role__r.Contact__r.Email, Account_Contact_Role__r.Contact__r.Phone, Account_Contact_Role__r.Contact__r.Title from ICG_Contact_Role_Detail__c where ICG_Role__c = 'Company Admin' and Status__c = :status and Account_Role__c IN:accountRolesToSearch];
	}

	public static List<ICG_Contact_Role_Detail__c> getRelatedContactsFromGroupName(String groupName) {
		Set<Id> accountRolesToSearch = getAccountsRolesToSearch(groupName);
		return [Select Id, CreatedDate, ContactId__c, Account_Contact_Role__r.Contact__r.FirstName, Account_Contact_Role__r.Contact__r.LastName, Account_Contact_Role__r.Contact__r.Email, Account_Contact_Role__r.Account__c, Account_Contact_Role__r.Contact__r.Phone, Account_Contact_Role__r.Contact__r.Title from ICG_Contact_Role_Detail__c where Account_Role__c IN:accountRolesToSearch];
	}

	public static Set<Id> getRelatedAccountsByStation(String stationId) {
		List<ICG_Contact_Role_Detail__c> relatedContacts = getRelatedContactsFromGroupName(getOpsHierarchyNameFromStationId(stationId));
		Set<Id> accountsIds = new Set<Id>(); 

		for(ICG_Contact_Role_Detail__c crd: relatedContacts) {
			accountsIds.add(crd.Account_Contact_Role__r.Account__c);
		}

		return accountsIds;
	}

	private static Set<Id> getAccountsRolesToSearch(String groupName) {
		Set<Id> accountRolesToSearch = new Set<Id>();
		//Select Parent Groups AccountRoles
		Map<Id,Account_Role__c> accRolesParentOfGroups = new Map<Id,Account_Role__c>([Select id from Account_Role__c where ID IN (Select From__c from Account_Role_Relationship__c where Relationship_Name__c =:groupName)]);

		List<Account_Role_Relationship__c> accountRoleRelatioships = [Select id, From__c, To__c from Account_Role_Relationship__c where Relationship_Name__c =:groupName or To__c IN :accRolesParentOfGroups.keySet() or (Ops_Hierarchy_Group__c =:groupName and To__c = null)];
		for (Account_Role_Relationship__c accrRel : accountRoleRelatioships) {
			if(accrRel.To__c != null) {
				accountRolesToSearch.add(accrRel.To__c);
			}
			if(accrRel.From__c != null) {
				accountRolesToSearch.add(accrRel.From__c);
			}
		}
		if(accountRolesToSearch.isEmpty()) {
			List<Account_Role__c> accountsRoleToSearch = [Select Id from Account_Role__c where Functional_Role__c = 'One Source' and Account__r.Name =:groupName];
			for (Account_Role__c accrRol : accountsRoleToSearch) {
				accountRolesToSearch.add(accrRol.Id);
			}
		}

		return accountRolesToSearch;
	}

	@AuraEnabled
	public static List<Contact> getCompanyAdminContactsFromGroupName (String groupName) {
		return getCompanyAdminContactsFromGroupNameByStatus(groupName, 'Approved');
	}

	@AuraEnabled (cacheable = false)
	public static List<ICG_Contact_Role_Detail__c> getPendingCompanyAdminContactRolesFromGroupName (String groupName) {
		return getCompanyAdminContactRolesFromGroupNameByStatus(groupName, 'Pending for Approval');
	}
	@AuraEnabled
	public static List<ICG_Contact_Role_Detail__c> getFacilityManagerContactRolesFromStationListByStatus(List<String> stationIds, String status) {
		return [Select Id, CreatedDate, Account_Contact_Role__r.Account__c, ContactId__c,Account_Contact_Role__c,Account_Contact_Role__r.Contact__r.OtherState, Account_Contact_Role__r.Contact__r.Name,
		Account_Contact_Role__r.Contact__r.OtherCountry,Account_Contact_Role__r.Contact__r.FirstName, ICG_Account_Role_Detail__c,Account_Contact_Role__r.Contact__r.LastName, Account_Contact_Role__r.Contact__r.Email, Account_Contact_Role__r.Contact__r.Phone, Account_Contact_Role__r.Contact__r.Title from ICG_Contact_Role_Detail__c where ICG_Role__c = 'Facility Manager' and Status__c = :status and ICG_Account_Role_Detail__c IN:stationIds];
	}

	@AuraEnabled
	public static List<ICG_Contact_Role_Detail__c> getFacilityManagerContactRolesFromStationListByUser(String userId) {
        return [Select Id, Status__c,Name, isPendingApproval__c, CreatedDate, ContactId__c, 
        Account_Contact_Role__c,
        Account_Contact_Role__r.Account__r.Name, 
        Account_Contact_Role__r.Contact__r.OtherState, 
        Account_Contact_Role__r.Contact__r.Name,
        Account_Contact_Role__r.Contact__r.OtherCountry,Account_Contact_Role__r.Contact__r.FirstName, 
        ICG_Account_Role_Detail__c,
        ICG_Account_Role_Detail__r.Name,
        Account_Contact_Role__r.Contact__r.LastName, Account_Contact_Role__r.Contact__r.Email, 
        Account_Contact_Role__r.Contact__r.Phone, Account_Contact_Role__r.Contact__r.Title 
        from ICG_Contact_Role_Detail__c 
        where ICG_Role__c = 'Facility Manager' and createdById = :userId];
	}

    @AuraEnabled
	public static List<Contact> getCompanyadminContactsFromAccountId(String accountId) {
		return accountId != null ? getCompanyAdminContactsFromGroupName(getOpsHierarchyNameFromAccountId(accountId)) : new List<Contact>();
	}

	public static String getOpsHierarchyNameFromAccountId (String accountId) {
		String opsHierarchy;
		List<Account_Role__c> accRole = [Select Id, (Select Id, From__c, To__c, Relationship_Name__c, Ops_Hierarchy_Group__c from From_Relationships__r) from Account_Role__c Where Account__c = :accountId AND Functional_Role__c = 'One Source'];
		if (!accRole.isEmpty()) {
			if(!accRole[0].From_Relationships__r.isEmpty()) {
				if(accRole[0].From_Relationships__r[0].To__c != null && accRole[0].From_Relationships__r[0].To__c != accRole[0].From_Relationships__r[0].From__c) {
					List<Account_Role_Relationship__c> rel = [Select Id, From__c, To__c, Relationship_Name__c, Ops_Hierarchy_Group__c from Account_Role_Relationship__c where From__c = :accRole[0].From_Relationships__r[0].To__c];
					if(!rel.isEmpty()) {
						if(rel[0].Relationship_Name__c != null) {
							opsHierarchy = rel[0].Relationship_Name__c;
						}
						else if (rel[0].Ops_Hierarchy_Group__c != null) {
							opsHierarchy = rel[0].Ops_Hierarchy_Group__c;
						}
					}
				}
				if(opsHierarchy == null) {
					if(accRole[0].From_Relationships__r[0].Relationship_Name__c != null) {
						opsHierarchy = accRole[0].From_Relationships__r[0].Relationship_Name__c;
					}
					else if (accRole[0].From_Relationships__r[0].Ops_Hierarchy_Group__c != null) {
						opsHierarchy = accRole[0].From_Relationships__r[0].Ops_Hierarchy_Group__c;
					}
				}
			}
		}
		if(opsHierarchy == null) {
			List<Account> acc = [Select id, name, Global_Ultimate_Account_Global_ID__c from Account where Id =:accountId];
			if(!acc.isEmpty()) {
				if(acc[0].Global_Ultimate_Account_Global_ID__c != null) {
					List<Account> parentAcc = [Select id, name, Global_Ultimate_Account_Global_ID__c from Account where Global_ID__c =:acc[0].Global_Ultimate_Account_Global_ID__c];
					if(!parentAcc.isEmpty()) {
						opsHierarchy = parentAcc[0].Name;
					} else {
						opsHierarchy = acc[0].Name;
					}
				} else {
					opsHierarchy = acc[0].Name;
				}
			}
		}
		return opsHierarchy;
	}
	public static String getOpsHierarchyNameFromUserId (String userId) {
		String opsHierarchy;
		List<User> u = [Select id, AccountId from User where id=:userId];
		if(!u.isEmpty() && u[0].AccountId != null) {
			opsHierarchy = getOpsHierarchyNameFromAccountId(u[0].AccountId);
		}
		return opsHierarchy;
	}
	public static String getOpsHierarchyNameFromStationId (String stationId) {
		String opsHierarchy;
		List<ICG_Account_Role_Detail__c> station = [Select id, Account_Role__r.Account__c FROM ICG_Account_Role_Detail__c where id =:stationId];
		if(!station.isEmpty() && station[0].Account_Role__r.Account__c != null) {
			opsHierarchy = getOpsHierarchyNameFromAccountId (station[0].Account_Role__r.Account__c);
		}
		return opsHierarchy;
	}

	@AuraEnabled(cacheable = true)
	public static string getFacilityLanguages() {
		List<PicklistValue> picklistValues = new List<PicklistValue>();
		Schema.DescribeFieldResult fieldResult = ICG_Account_Role_Detail__c.Available_Languages__c.getDescribe();

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
				
		for( Schema.PicklistEntry f : ple)
		{
			picklistValues.add(new PicklistValue(f.getValue(), f.getLabel(),false));
		}       
		return JSON.serialize(picklistValues);
	}

	public static Map<String, List<Map<String, Object>>> getPicklistFieldDependencies(String objectName, String controllingField, String dependentField, Boolean saveKeyAsLowerCase) {
		Map<String, List<Map<String, Object>>> controllingInfo = new Map<String, List<Map<String, Object>>>();
		
		Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
		
		Schema.DescribeSObjectResult describeResult = objType.getDescribe();
		Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
		Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
		
		List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
		List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
		



		for(Schema.PicklistEntry currControllingValue : controllingValues) {
			controllingInfo.put((saveKeyAsLowerCase ? currControllingValue.getValue().toLowerCase() : currControllingValue.getValue()) , new List<Map<String, Object>>());
		}
		
		for(Schema.PicklistEntry currDependentValue : dependentValues)
		{
			// {"active":true,"defaultValue":false,"label":"Other Security Equipment / Measures","validFor":"ABAA","value":"Other_Security_Equipment_Measures"}
			String jsonString = JSON.serialize(currDependentValue);

			Map<String, Object> info = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
			String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode((String)info.get('validFor'))).toUpperCase();
			
			Integer baseCount = 0;
			for(Integer curr : hexString.getChars())
			{
				Integer val = 0;
				String currentKey = '';
				if(curr >= 65) {
					val = curr - 65 + 10;
				} else {
					val = curr - 48;
				}
				
				if((val & 8) == 8) {
					currentKey = controllingValues[baseCount + 0].getValue();
				}
				if((val & 4) == 4) {
					currentKey = controllingValues[baseCount + 1].getValue();
				}
				if((val & 2) == 2) {
					currentKey = controllingValues[baseCount + 2].getValue();
				}
				if((val & 1) == 1) {
					currentKey = controllingValues[baseCount + 3].getValue();
				}

				if (String.isNotBlank(currentKey)) {
					if (saveKeyAsLowerCase) {
						currentKey = currentKey.toLowerCase();
					}
					controllingInfo.get(currentKey).add(new Map<String, Object>{ 'value' => currDependentValue.getValue(), 'label' => currDependentValue.getLabel()});
				}
				
				baseCount += 4;
			}            
		} 
		
		return controllingInfo;
	}

	public static Boolean sendEmailTemplate(String emailTemplateName, Id whatId, Id whoId, List<String> recipientsEmails) {
		
		Set<String> handledRecipients = new Set<String>(recipientsEmails);

		handledRecipients.remove('');
		handledRecipients.remove('null');
		handledRecipients.remove(null);

		recipientsEmails = new List<String>(handledRecipients);

		if (recipientsEmails.isEmpty() || whoId == null) {
			return false;
		}

		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setTargetObjectId(whoId);
		message.setOrgWideEmailAddressId([SELECT id FROM OrgWideEmailAddress WHERE DisplayName = 'IATA Noreply' LIMIT 1].id);
		EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];
		message.setTemplateID(emailTemplate.Id);
		message.setWhatId(whatId); //This is important for the merge fields in template to work
        message.toAddresses = recipientsEmails;
        
        if (!Test.isRunningTest()) {
            message.setSaveAsActivity(false);
        }
        
		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
		Messaging.SendEmailResult[] results;

		try {
            if (Test.isRunningTest()) {
                return true;
            }
        
			results = Messaging.sendEmail(messages);
		} catch (EmailException exc) {
			return false;
		}

		return results != null && !results.isEmpty() ? results[0].success : false;
	}

	public static void sendApproveOrRejectMails(ICG_Account_Role_Detail__c newStation, ICG_Account_Role_Detail__c oldStation) {
		//only to get the accountid and the created by email
		ICG_Account_Role_Detail__c ard = [Select id, Formatted_Address__c, Name, Account_Role__c, Account_Role__r.Account__c, Account_Role__r.Account__r.RecordType.DeveloperName, Account_Role__r.Account__r.RecordType.Name, CreatedById, CreatedBy.Email, CreatedBy.ContactId, CreatedBy.Contact.Email from ICG_Account_Role_Detail__c where id = :newStation.Id];
		String whoEmail = ard.CreatedBy.ContactId != null ? ard.CreatedBy.Contact.Email : ard.CreatedBy.Email;
		String whoId = ard.CreatedBy.ContactId != null ? ard.CreatedBy.ContactId : ard.CreatedById;
		//Send email to approvers
		List<String> whoEmails = new List<String>();
		whoEmails.add(whoEmail);
		List<String> contactIds = new List<String>();
		for(Contact c : getCompanyadminContactsFromAccountId(ard.Account_Role__r.Account__c)) {
			if(c.email != null) {
				whoEmails.add(c.email);
			}
			contactIds.add(c.Id);
		}
		List<ICG_Notification__c> notifications = new List<ICG_Notification__c>();


		String subject = 'Station Creation request for ' + ard.Name + ', ' + ard.Account_Role__r.Account__r.RecordType.Name;
		String body = 'Station Creation request for ' + ard.Name + ', ' + ard.Account_Role__r.Account__r.RecordType.Name + ', ' + ard.Formatted_Address__c;

		if (newStation.Status__c == 'Approved' && oldStation.Status__c != 'Approved') {
			sendEmailTemplate('Notification_Approved_to_Req_Comp_Adm', newStation.Id, whoId, whoEmails);
			subject +=  ' approved';
			body +=  ' approved';
			notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', contactIds, newStation, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
							
			List<ICG_Contact_Role_Detail__c> crdsToInsert = CW_Utilities.getContactRoleDetailsToInsert(ard.Account_Role__r.Account__c, newStation.Id, ard.CreatedBy.ContactId, 'Approved');
			if (!crdsToInsert.isEmpty()) {
				insert crdsToInsert;
			}
		} else if (newStation.Status__c == 'Rejected' && oldStation.Status__c != 'Rejected') {
			if(ard.CreatedBy.ContactId != null) {
				updateAllStationManagementRecords(ard.CreatedBy.ContactId, newStation.Id, 'Rejected');
			}
			sendEmailTemplate('Notification_Rejected_to_Req_Comp_Adm', newStation.Id, whoId, whoEmails);
			subject +=  ' rejected';
			body +=  ' rejected';
			notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', contactIds, newStation, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
			cleanupAccount(ard);
		}

		if(notifications.size() > 0) {
			insert notifications;
		}
	}

	private static void cleanupAccount(ICG_Account_Role_Detail__c ard) {
		if(ard.Account_Role__r.Account__r.RecordType.DeveloperName == 'Standard_Account') {
			try{
				Account acc = new Account();
				acc.Id = ard.Account_Role__r.Account__c;
				delete ard;
				delete acc;
			}
			catch (Exception ex) {
				throw new AuraHandledException('Aura handled exception: ' + ex);
			}
		}
	}

	public static void sendApproveOrRejectMailsContactRole (ICG_Contact_Role_Detail__c newContactRole, ICG_Contact_Role_Detail__c oldContactRole) {
		String whoId = newContactRole.ContactId__c;
		ICG_Contact_Role_Detail__c crd = [Select id, ICG_Account_Role_Detail__r.Account_Role__r.Account__c, Account_Role__r.Account__c, Account_Contact_Role__r.Contact__r.Email from ICG_Contact_Role_Detail__c where Id = :newContactRole.Id];
		String templateNameContact;
		String templateNameCompAdmStationManagers;
		String templateNameIata;
		String subject;

		List<String> whoEmailsContact = new List<String>{crd.Account_Contact_Role__r.Contact__r.Email};
		List<String> whoEmailsCompAdmStationManagersContacts = new List<String>();
		List<String> whoEmailsCompAdmStationManagersCRDs = new List<String>();
		Set<String> notificationReceivers = new Set<String>();
		notificationReceivers.add(crd.Account_Contact_Role__r.Contact__c);
		for (Contact cadmn : getCompanyadminContactsFromAccountId(crd.ICG_Account_Role_Detail__r.Account_Role__r.Account__c)) {
			whoEmailsCompAdmStationManagersContacts.add(cadmn.Email);
			notificationReceivers.add(cadmn.Id);
		}

		List<String> whoEmailIata = new List<String>();
		for(User u : CW_Utilities.getIATAStakeHoldersUsersList()) {
			if(u.email != null) {
				whoEmailIata.add(u.email);
			}
		}

		if (newContactRole.Status__c == 'Approved' && oldContactRole.Status__c != 'Approved') {
			if(newContactRole.ICG_Role__c == 'Facility Manager') {
				templateNameIata = 'Notification_approved_to_IATA';
				templateNameContact = 'Notification_approved_to_User';
				templateNameCompAdmStationManagers = 'Notification_appr_to_Sta_Man_Comp_Adm';
				subject = 'Facility manager approved';
				for (ICG_Contact_Role_Detail__c mngr : getStationManagersContactRoleDetails(newContactRole.ICG_Account_Role_Detail__c)) {
					whoEmailsCompAdmStationManagersCRDs.add(mngr.Account_Contact_Role__r.Contact__r.Email);
				}

			} else if(newContactRole.ICG_Role__c == 'Company Admin') {
				templateNameIata = 'Notification_Com_Adm_Req_appr_to_IATA';
				templateNameContact = 'Notification_CA_Approv_to_Requestor';
				templateNameCompAdmStationManagers = 'Notification_CA_Appro_to_Comp_Adm';
				subject = 'Company admin approved';

			}
		} else if (newContactRole.Status__c == 'Rejected' && oldContactRole.Status__c != 'Rejected') {
			if(newContactRole.ICG_Role__c == 'Facility Manager') {
				templateNameContact = 'Notification_rejected_to_User';
				subject = 'Facility manager rejected';
			} else if(newContactRole.ICG_Role__c == 'Company Admin') {
				templateNameIata = 'Notification_CA_Rejected_to_IATA';
				templateNameContact = 'Notification_CA_Rejected_to_Requestor';
				templateNameCompAdmStationManagers = 'Notification_CA_Rejected_to_Comp_Adm';
				subject = 'Company admin rejected';
			}
		} else if (newContactRole.Status__c == 'Removed' && oldContactRole.Status__c != 'Removed') {
			templateNameContact = 'Remove_notification_to_removed_stat_man';
			templateNameIata = 'Remove_notification_to_IATA';
			templateNameCompAdmStationManagers = 'Remove_notif_to_Stat_Man_Comp_Adm';
			subject = 'Contact role removed';
		}

		List<String> whoEmailsCompAdmStationManagersCombined = new List<String>();
		whoEmailsCompAdmStationManagersCombined.addAll(whoEmailsCompAdmStationManagersContacts);
		whoEmailsCompAdmStationManagersCombined.addAll(whoEmailsCompAdmStationManagersCRDs);

		//Send emails 
		if(templateNameIata != null) {
			CW_Utilities.sendEmailTemplate(templateNameIata, newContactRole.Id, whoId, whoEmailIata);
		}
		
		if(templateNameCompAdmStationManagers != null) {
			CW_Utilities.sendEmailTemplate(templateNameCompAdmStationManagers, newContactRole.Id, whoId, whoEmailsCompAdmStationManagersCombined);
		}

		if (newContactRole.contactId__c != null && templateNameContact != null) {
			CW_Utilities.sendEmailTemplate(templateNameContact, newContactRole.Id, whoId, whoEmailsContact);
		}


		//Create notifications
		if(subject != null) {
			String body = subject;
			CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', new List<String>(notificationReceivers), newContactRole.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA);
		}
	}

	public static void updateAllStationManagementRecords(Id contactId, Id stationId, String status) {
		List<ICG_Contact_Role_Detail__c> crds = [Select id from ICG_Contact_Role_Detail__c where ContactId__c = :contactId AND ICG_Account_Role_Detail__c =:stationId];
		for (ICG_Contact_Role_Detail__c crd : crds) {
			crd.Status__c = status;
		}
		if(!crds.isEmpty()) {
			update crds;
		}
	}

	@AuraEnabled
	public static String getPicklistValues(string objectApi ,string fieldApi) {
		
		List<pickListVal> allOpts = new List<pickListVal>();
		DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectApi).getDescribe();
		for (Schema.PicklistEntry picklistEntry : objResult.fields.getMap().get(fieldApi).getDescribe().getPickListValues()) {
				pickListVal pck = new pickListVal(picklistEntry.getValue(),picklistEntry.getLabel());
				allOpts.add(pck);
		}
		return JSON.serialize(allOpts);
	}

	public class ResponseBody {
		public String message {get;set;}
		public Boolean success {get;set;}
	}
	public class PicklistValue {
		@AuraEnabled
		public String value {get;set;}
		@AuraEnabled
		public String label {get;set;}
		@AuraEnabled
		public Boolean selected {get;set;}
		public PicklistValue (String value, String label, Boolean selected) {
			this.value = value;
			this.label = label;
			this.selected = selected;
		}
	}

	public class PicklistVal {
		public string api;
		public string label;

		public PicklistVal(string api, string label) {
			this.api = api;
			this.label = label;
		}
	}
}