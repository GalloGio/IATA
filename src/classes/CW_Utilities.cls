/**
 * @description		CW_Utilities of OneSource project
 * 						Without sharing in order to be able to get company and station information, and also to become company admin
 */
public without sharing class CW_Utilities {

	public final static String PROFILE_SYSTEM_ADMINISTRATOR  = 'System Administrator';
	public final static String PSET_OS_BACKEND_ADMIN = 'One_Source_Backend_Admin';
	public final static String PSET_OS_CERT_MANAGER = 'One_Source_Certification_Manager';

	public final static string VALIDATION_PROGRAMS = 'IATA';

	public final static string FACILITY_MANAGER = 'Facility Manager';
	public final static string COMPANY_ADMIN = 'Company Admin';
	final static string FIELD_CUSTOM_VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
	final static string STATION_CREATION_REQUEST = 'Station Creation Requests';
	public final static string STATION_MANAGER_REQUEST = 'Station Manager Requests';
	public final static string ADMIN_REQUEST = 'Admin Requests';
	final static string HISTORY_STATUS_APPROVED = 'Approved';
	final static string HISTORY_STATUS_REJECTED = 'Rejected';
	final static string HISTORY_STATUS_PENDINGIATA = 'Pending for IATA Approval';
	final static string HISTORY_STATUS_PENDING = 'Pending for Approval';
	
	final static List<String> ALLOWED_STATUS = new List<String> { HISTORY_STATUS_APPROVED, HISTORY_STATUS_REJECTED, HISTORY_STATUS_PENDING, HISTORY_STATUS_PENDINGIATA };
	final static Id RT_ID_TOUSE = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_History_Track__c', 'Changes_by_Type');

	/*
	 * @description		Retrieves metadata related to Portal
	 * @param			String mtdName: Metadata record name Ex. Footer_Title
	 * @return			ICG_Portal_URL__mdt Metadata record
	 */
	@AuraEnabled (cacheable=true)
	public static ICG_Portal_URL__mdt getMetadataInfo(String mtdName) {
		// Fetch the metadata required
		ICG_Portal_URL__mdt metadata = [SELECT Id,MasterLabel, DeveloperName, Link__c, Description__c 
											  FROM ICG_Portal_URL__mdt WHERE DeveloperName =: mtdName LIMIT 1];
		return metadata;
	}

	/*
	 * @description		Retrieves page URL url community + page name
	 * @param			String page: Portal page metadata name Ex. URL_ICG_ResultPage  
	 * @return			String os community URL + page name
	 */
	@AuraEnabled (cacheable=true)
	public static String getURLPage(String page) {
		String result;
		ICG_Portal_URL__mdt metadata = [SELECT Id,MasterLabel, DeveloperName, Link__c, Description__c 
										FROM ICG_Portal_URL__mdt WHERE DeveloperName =: page LIMIT 1];
		String urlBase = getCommunityUrlBase();
		result = urlBase +  metadata.Description__c;
		return result;
	}

	/*
	 * @description		Retrieves Community URL
	 * @param			
	 * @return			String ICG Url base stored on ISSP_CS__c custom setting.
	 */
	public static String getCommunityUrlBase() {
		return ISSP_CS__c.getValues('ICG_URL_Base').Value__c;
	}

	/*
	 * @description		Retrieves eCommerce Url
	 * @param			
	 * @return			String ecommerce url base stored on ISSP_CS__c custom setting.
	 */
	@AuraEnabled (cacheable = true)
	public static String getEcommerceUrlBase() {
		Boolean isProductionEnvironment = CW_PrivateAreaController.isProductionEnvironment();
		String url;
		if (isProductionEnvironment) {
			url = ISSP_CS__c.getValues('HostIEC').Value__c + '/iec';
		} else {
			url = getCommunityUrlBase();
			if (String.isNotBlank(url)) {
				url = url.removeStart('https://').split('/')[0] + '/iec';
			}
		}
		if (!url.startsWithIgnoreCase('https://')){
			url = 'https://' + url;
		}
		url = url.removeEnd('/');
		return url;
	}

	/*
	 * @description		Retrieves Environment Variables
	 * @param			
	 * @return			ICG_Environment_Variables__c complete instance.
	 */
	@AuraEnabled (cacheable = true)
	public static ICG_Environment_Variables__c getEnvironmentVariables() {
		return ICG_Environment_Variables__c.getInstance();
	}

	/*
	 * @description		Retrieves Setting Values
	 * @param			
	 * @return			IEC_Settings__c complete instance.
	 */
	@AuraEnabled (cacheable = true)
	public static IEC_Settings__c getIECSettingVariables() {
		return IEC_Settings__c.getInstance();
	}

	/*
	 * @description		Retrieves Setting Values
	 * @param			String facilityId: ICG_Account_Role_Detail__c id
	 * @return			String userRole [Not assigned, Guest, Pending Facility Manager, Facility Manager, Company Admin, Pending Company Admin]
	 */
	@AuraEnabled
	public static String getUserRole(String facilityId) {	
		String userRole = 'Not assigned';
		if(UserInfo.getUserType() == 'Guest') {
			userRole = 'Guest';
		} else {
			//If not a guest user
			List<User> usr = [Select Id, Name, Email, ContactId, Account.Name from User where Id = :UserInfo.getUserId()];
			if(!usr.isEmpty() && usr[0].ContactId != null && facilityId != null) {
				List<ICG_Account_Role_Detail__c> station = [Select id, Account_Role__c, Account_Role__r.Account__r.Name from ICG_Account_Role_Detail__c where id =:facilityId];
 
				if(!station.isEmpty()) {
					List<ICG_Contact_Role_Detail__c> userFacilityRelationList = [Select id, ICG_Role__c, Status__c, Account_Role__c, isPendingApproval__c, isApproved__c from ICG_Contact_Role_Detail__c where Account_Contact_Role__r.Contact__c = :usr[0].ContactId and
					(ICG_Account_Role_Detail__c = :facilityId AND ICG_Role__c =: FACILITY_MANAGER)];
					//If user has contact roles related, determine if Facility manager or Pending facility manager
					if (userFacilityRelationList.size()>0) {
						Set<Id> accountRolesCompanyAdmin = new Set<Id>();
						Set<Id> accountRolesPendingCompanyAdmin = new Set<Id>();
						for (ICG_Contact_Role_Detail__c crd : userFacilityRelationList) {
							if (crd.ICG_Role__c == FACILITY_MANAGER && crd.isApproved__c) {
								userRole = FACILITY_MANAGER;
							} else if (crd.ICG_Role__c == FACILITY_MANAGER && crd.isPendingApproval__c) {
								userRole = 'Pending Facility Manager';
							}

						}
					}
					//Get station ops hierarchy
					String opsHierarchyGroup = getOpsHierarchyNameFromStationId(station[0].Id);
					List<Contact> companyAdminsFromGroup = getCompanyAdminContactsFromGroupName(new List<String>{opsHierarchyGroup});

					for(Contact con : companyAdminsFromGroup) {
						if(con.Id == usr[0].contactId) {
							userRole = COMPANY_ADMIN;
						}
					}
					if(userRole != FACILITY_MANAGER && userRole != COMPANY_ADMIN) {
						List<Contact> pendingCompanyAdminsFromGroup = getCompanyAdminContactsFromGroupNameByStatus(new List<String>{opsHierarchyGroup}, new List<String>{'Pending for Approval'});
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

	/*
	 * @description		Checks if the current user is System Administrator
	 * @return			Boolean
	 */
	public static Boolean isCurrentUserSystemAdministrator() {
		List<Profile> profileFound = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() AND Name = :PROFILE_SYSTEM_ADMINISTRATOR];
		return !profileFound.isEmpty();
	}

	/*
	 * @description		Get the permission sets assigned to the current user
	 * @return			List<String> Permission Set Names
	 */
	public static List<String> getCurrentUserPermissionSets() {
		List<String> psets = new List<String>();
		for (PermissionSetAssignment currentPSetAssign : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() ]) {
			psets.add(currentPSetAssign.PermissionSet.Name);
		}
		return psets;
	}

	/*
	 * @description		Check if the user has edit permissions
	 * @return			Bollean result if you have permission
	 */
	@AuraEnabled (cacheable = true)
	public static Boolean getPermissionToEdit() {
		if (isCurrentUserSystemAdministrator()) {
			return true;
		}

		List<String> pSets = getCurrentUserPermissionSets();
		return psets.contains(PSET_OS_BACKEND_ADMIN) || psets.contains(PSET_OS_CERT_MANAGER);
	}

	/*
	 * @description		Checks if the current user is administrator or has the One_Source_Backend_Admin permission set assigned. 
	 * @param			
	 * @return			Boolean true if current user is system admin or One_Source_Backend_Admin
	 */
	public static Boolean hasSpecialPermissionsToEdit(){
		if (isCurrentUserSystemAdministrator()) {
			return true;
		}

		return getCurrentUserPermissionSets().contains(PSET_OS_BACKEND_ADMIN);
	}

	/*
	 * @description		If the user is company admin of station and status os "Pending for Approval", the status mut change and the approver/rejector will be the user
	 * @param			String stationId: ICG_Account_Role_Detail__c id
	 * @return			Boolean true if the user is company admin of station and status os "Pending for Approval", the status mut change and the approver/rejector will be the user 
	 */
	@AuraEnabled
	public static Boolean approveStationAutomaticProcess(String stationId) {
		Boolean approved = false;
		try{
			if (getUserRole(stationId) == COMPANY_ADMIN) {
				//if it does not exists, then go thru exception process
				ICG_Account_Role_Detail__c ard = [Select id, Status__c, Account_Role__r.Account__c, Account_Role__r.Account__r.RecordType.DeveloperName, CreatedBy.ContactId, CreatedBy.Id from ICG_Account_Role_Detail__c Where id =:stationId];
				if (ard.Status__c == 'Pending for Approval') {
					//If the user is company admin of station and status os "Pending for Approval", the status mut change and the approver/rejector will be the user
					Boolean accountAlreadyApproved = ard.Account_Role__r.Account__r.RecordType.DeveloperName != 'Standard_Account';
					ard.Status__c = 'Pending for IATA Approval';
					ard.Company_Admin_Approver_Rejector__c = UserInfo.getUserId();
					update ard;
					String whoId = ard.CreatedBy.ContactId != null ? ard.CreatedBy.ContactId : ard.CreatedById;
					//Check email template to send depend of status
					String templateName = accountAlreadyApproved == true ? 'Approve_Reject_IATA_Adm_after_comp_appro' : 'Approve_Reject_to_IATA_Admin_account';

					List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
					emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(templateName, ard.Id, CW_EmailManager.getIataAdminsIds()));
					approved = CW_EmailManager.sendInternalEmails(emailsToBeSent);
				}
			}
		}catch (Exception ex) {
			throw new AuraHandledException('exception: ' + ex);
		}
		return approved;
	}

	/*
	 * @description		Handles whether a contact removal will be approved or rejected
	 * @param			contactRoleDetailId <The id of the contact role in question>
	 * @param			approvedRemoval <Whether it was approved in front end or not>
	 * @return			String explination of outcome
	 */
	@AuraEnabled
	public static String handleContactRoleDetailRemovalProcess(String contactRoleDetailId, Boolean approvedRemoval) {
		try {
			HandledContactRole handledContactRole = new HandledContactRole();
			List<ICG_Contact_Role_Detail__c> crdList = [SELECT id, ICG_Account_Role_Detail__c, ICG_Role__c, Account_Role__c, Account_Role__r.Account__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name, Status__c FROM ICG_Contact_Role_Detail__c WHERE id = :contactRoleDetailId];
			
			if(crdList.size() > 0){
				ICG_Contact_Role_Detail__c crd = crdList[0];
				String userRole = crd.ICG_Account_Role_Detail__c != null && crd.ICG_Role__c == FACILITY_MANAGER ? getUserRole(crd.ICG_Account_Role_Detail__c) : null;
				User approver = [SELECT id, contactId FROM User WHERE id = :UserInfo.getUserId()];
	
				if (userRole == null && crd.Account_Role__c != null) {
					for (Contact con : getCompanyAdminContactsFromAccountId(crd.Account_Role__r.Account__c)) {
						if (approver.ContactId == con.Id) {
							userRole = COMPANY_ADMIN;
						}
					}
				}
				if (userRole == COMPANY_ADMIN) {
					crd.Status__c = approvedRemoval ? 'Removed' : 'Approved';
					crd.Company_Admin_Approver_Rejector__c = UserInfo.getUserId();
					update crd;
					handledContactRole.contactRole = crd;
					handledContactRole.message = approvedRemoval ? 'Successful' : 'Unsuccessful';
					return JSON.serialize(handledContactRole);
				} else {
					handledContactRole.message = 'MissingRights';
					return JSON.serialize(handledContactRole);
				}
			}
			else {
				handledContactRole.message = 'No matching contact found';
				return JSON.serialize(handledContactRole);
			}


		}catch (Exception ex) {
			throw new AuraHandledException('exception: ' + ex);
		}
	}

	/*
	 * @description		Save a list of the history related to ICG_Account_Role_Detail__c
	 * @param			List<ICG_Account_Role_Detail__c>
	 * @param			Map<Id, ICG_Account_Role_Detail__c>
	 */
	public static void generateAccountRoleDetailHistory(List<ICG_Account_Role_Detail__c> newItems, Map<Id, ICG_Account_Role_Detail__c> oldMap){
		List<ICG_Account_Role_Detail__c> newItemsFiltered = new List<ICG_Account_Role_Detail__c>();
		Map<Id, ICG_Account_Role_Detail__c> oldMapFiltered = new Map<Id, ICG_Account_Role_Detail__c>();
		Map<Id, String> typesById = new Map<Id, String>();
		for (ICG_Account_Role_Detail__c newItem : newItems) {
			if (ALLOWED_STATUS.contains(newItem.Status__c) && (oldMap == null || newItem.Status__c != oldMap.get(newItem.Id).Status__c)) {
				newItemsFiltered.add(newItem);
				if (oldMap != null) {
					oldMapFiltered.put(newItem.Id, oldMap.get(newItem.Id));
				}
				typesById.put(newItem.Id, STATION_CREATION_REQUEST);
			}
		}

		if (!newItemsFiltered.isEmpty()) {
			generateHistoryTrack(RT_ID_TOUSE, newItemsFiltered, oldMapFiltered, typesById, new List<String>{'Status__c'});
		}
	}
	
	/*
	 * @description		Save a list of the history related to ICG_Contact_Role_Detail__c
	 * @param			List<ICG_Contact_Role_Detail__c>
	 * @param			Map<Id, ICG_Contact_Role_Detail__c>
	 */
	public static void generateContactRoleDetailHistory(List<ICG_Contact_Role_Detail__c> newItems, Map<Id, ICG_Contact_Role_Detail__c> oldMap) {
		List<String> allowedRoles = new List<String> { CW_Utilities.FACILITY_MANAGER, CW_Utilities.COMPANY_ADMIN };

		List<ICG_Contact_Role_Detail__c> newItemsFiltered = new List<ICG_Contact_Role_Detail__c>();
		Map<Id, ICG_Contact_Role_Detail__c> oldMapFiltered = new Map<Id, ICG_Contact_Role_Detail__c>();
		Map<Id, String> typesById = new Map<Id, String>();
		for (ICG_Contact_Role_Detail__c newItem : newItems) {
			if (allowedRoles.indexOf(newItem.ICG_Role__c) > -1 && ALLOWED_STATUS.indexOf(newItem.Status__c) > -1 && (oldMap == null || newItem.Status__c != oldMap.get(newItem.Id).Status__c )) {
				newItemsFiltered.add(newItem);
				if (oldMap != null) {
					oldMapFiltered.put(newItem.Id, oldMap.get(newItem.Id));
				}
				typesById.put(newItem.Id, (newItem.ICG_Role__c == CW_Utilities.COMPANY_ADMIN) ? CW_Utilities.ADMIN_REQUEST : CW_Utilities.STATION_MANAGER_REQUEST);
			}
		}

		if (!newItemsFiltered.isEmpty()) {
			generateHistoryTrack(RT_ID_TOUSE, newItemsFiltered, oldMapFiltered, typesById, new List<String>{'Status__c'});
		}
	}

	/*
	 * @description		Generate history track for each record and field
	 * @param			Id historyRtId - of Record Type to use for the object ICG_History_Track__c
	 * @param			List<SObject> newItems - Current Values
	 * @param			Map<Id, SObject> oldMap - Old Values
	 * @param			Map<Id, String> historyTypeById - Type__c to use for each record to insert. The Id is linked to newItems Id field
	 * @param			List<String> fieldsToTrack - Api Name of the fields to be tracked
	 */
	private static void generateHistoryTrack(
		Id historyRtId, 
		List<SObject> newItems, Map<Id, SObject> oldMap, Map<Id, String> historyTypeById, List<String> fieldsToTrack
	) {
		List<ICG_History_Track__c> itemsToInsert = new List<ICG_History_Track__c>();
		Map<String, Map<String, Schema.SObjectField>> fieldsByObject = new Map<String, Map<String, Schema.SObjectField>>();

		if (newItems != null && fieldsToTrack != null) {

			for (SObject currentItem : newItems) {
				if (historyTypeById.containsKey(currentItem.Id)) {

					String objectName = currentItem.getSObjectType().getDescribe().getName();

					if (!fieldsByObject.containsKey(objectName)) {
						fieldsByObject.put(objectName, currentItem.getSObjectType().getDescribe().fields.getMap());
					}
					
					for (String fieldToTrack : fieldsToTrack) {
						if (fieldsByObject.get(objectName).containsKey(fieldToTrack)) {
							ICG_History_Track__c itemToInsert = new ICG_History_Track__c(
								RecordTypeId = historyRtId, 
								Type__c = historyTypeById.get(currentItem.Id), 
								SObject__c = objectName, 
								Target_Id__c = currentItem.Id,
								Field__c = fieldToTrack,
								New_Value__c = (String) currentItem.get(fieldToTrack));
							
								if (oldMap != null && oldMap.containsKey(currentItem.Id)) {
									String oldObjectName = oldMap.get(currentItem.Id).getSObjectType().getDescribe().getName();
									if (!fieldsByObject.containsKey(oldObjectName)) {
										fieldsByObject.put(oldObjectName, oldMap.get(currentItem.Id).getSObjectType().getDescribe().fields.getMap());
									}

									if (fieldsByObject.get(oldObjectName).containsKey(fieldToTrack)) {
										itemToInsert.Old_Value__c = (String) oldMap.get(currentItem.Id).get(fieldToTrack);
									}
								}
							itemsToInsert.add(itemToInsert);
						}
					}
				}
			}
		}

		if (!itemsToInsert.isEmpty()) {
			insert itemsToInsert;
		}
	}
	
	public class HandledContactRole {
		public String message { get; set; }
		public ICG_Contact_Role_Detail__c contactRole { get; set; }
	}

	/*
	 * @description		Handles whether a contact must be approved automatically
	 * @param			contactRoleDetailId <The id of the contact role in question>
	 * @return			ICG_Contact_Role_Detail__c approved
	 */
	@AuraEnabled
	public static ICG_Contact_Role_Detail__c approveContactRoleDetailAutomaticProcess(String contactRoleDetailId) {
		try{
			//if it does not exists, then go thru exception process
			ICG_Contact_Role_Detail__c  crd = [Select id,Status__c, ICG_Role__c, ICG_Account_Role_Detail__c,Account_Role__c,Account_Role__r.Account__c,Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name FROM ICG_Contact_Role_Detail__c where id = :contactRoleDetailId];
			String userRole = crd.ICG_Account_Role_Detail__c != null && crd.ICG_Role__c == FACILITY_MANAGER ? getUserRole(crd.ICG_Account_Role_Detail__c) : null;
			User approver = [Select id, contactId from User where id = :UserInfo.getUserId()];
			if(userRole == null && crd.Account_Role__c != null) {
				for (Contact con : getCompanyAdminContactsFromAccountId(crd.Account_Role__r.Account__c)) {
					if (approver.ContactId == con.Id) {
						userRole = COMPANY_ADMIN;
					}
				}
			}
			if (userRole == COMPANY_ADMIN || userRole == FACILITY_MANAGER && crd.Status__c == 'Pending for Approval') {
				crd.Status__c = 'Approved';
				crd.Company_Admin_Approver_Rejector__c = UserInfo.getUserId();
				crd.Contact_Role_Remove_Requestor__c = null;
				update crd;
				return crd;
			} 
			return null;
		}catch (Exception ex) {
			throw new AuraHandledException('exception: ' + ex);
		}
	}

	/*
	 * @description		Handles whether a contact must be rejected automatically
	 * @param			contactRoleDetailId <The id of the contact role in question>
	 * @return			ICG_Contact_Role_Detail__c rejected
	 */
	@AuraEnabled
	public static ICG_Contact_Role_Detail__c rejectContactRoleDetailAutomaticProcess(String contactRoleDetailId, String rejectReason) {
		try{
			//if it does not exists, then go thru exception process
			ICG_Contact_Role_Detail__c crd = [Select id,Status__c, ICG_Role__c, ICG_Account_Role_Detail__c,Account_Role__c,Account_Role__r.Account__c,Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name FROM ICG_Contact_Role_Detail__c where id = :contactRoleDetailId];
			String userRole = crd.ICG_Account_Role_Detail__c != null && crd.ICG_Role__c == FACILITY_MANAGER ? getUserRole(crd.ICG_Account_Role_Detail__c) : null;
			User approver = [Select id, contactId from User where id = :UserInfo.getUserId()];
			if(userRole == null && crd.Account_Role__c != null) {
				for (Contact con : getCompanyAdminContactsFromAccountId(crd.Account_Role__r.Account__c)) {
					if (approver.ContactId == con.Id) {
						userRole = COMPANY_ADMIN;
					}
				}
			}
			if (userRole == COMPANY_ADMIN || userRole == FACILITY_MANAGER) {
				if (crd.Status__c == 'Pending for Approval') {
					crd.Status__c = 'Rejected';
					crd.Reject_Reason__c = rejectReason;
					crd.Company_Admin_Approver_Rejector__c = UserInfo.getUserId();
					update crd;
					return crd;
				}else {
					return null;
				}
			} else {
				return null;
			}
		}catch (Exception ex) {
			throw new AuraHandledException('exception: ' + ex);
		}
	}

	/*
	 * @description		Handles whether a station must be rejected automatically and why
	 * @param			stationId <The id of the station in question>
	 * @param			rejectReason <String with the reason to reject the station>
	 * @return			Rejected or not
	 */
	@AuraEnabled
	public static Boolean rejectStationAutomaticProcess(String stationId, String rejectReason) {

		try{
			if (getUserRole(stationId) == COMPANY_ADMIN) {
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
			throw new AuraHandledException('exception: ' + ex);
		}
		
	}

	/*
	 * @description		Retrieve Company types
	 * @return			JSON Company types
	 */
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

	/*
	 * @description		Retrieves IATA_ISO_Country__c
	 * @return			Json format of List<IATA_ISO_Country__c>
	 */
	@AuraEnabled (cacheable = true)
	public static String getIATACountries() {
		List<IATA_ISO_Country__c> countries = [select id, name, ISO_Code__c, ISO_Code_Numeric__c from IATA_ISO_Country__c];
		return JSON.serialize(countries);
	}

	/*
	 * @description		Generate the resource url
	 * @param			resourceName Name of a StaticResource
	 * @return			resource name concatenated with datetime and namespace
	 */
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

	/*
	 * @description		Generate the resource url
	 * @param			companyId Id of the company
	 * @param			facilityIds Ids of ICG_Account_Role_Detail__c
	 * @param			contactId If of Contact__c
	 * @param			skipApprovalProcess Flag that sets the Status as 'Approved' when is true or 'Pending for approval' when is false 
	 * @return			JSON format of CW_Utilities.ResponseBody
	 */
	@AuraEnabled
	public static String becomeFacilityAdmin(String companyId, String facilityIds, String contactId, Boolean skipApprovalProcess) {
		//Not cacheable at they can be called more than once in the same context
		//and perform the action
		ResponseBody res = new ResponseBody();
		if(facilityIds != null && contactId != null) {
			try {
				String status = skipApprovalProcess  == true ? 'Approved' : 'Pending for Approval';
				List<ICG_Contact_Role_Detail__c> crdsToInsert = getContactRoleDetailsToInsert(companyId, facilityIds, contactId, status);
				if(crdsToInsert.isEmpty() || crdsToInsert.size()>1) {
					res.success = false;
					res.message = !crdsToInsert.isEmpty() ? Label.icg_one_process_at_time_msg : Label.icg_no_account_role_found_msg;
				} else {
					insert crdsToInsert;
					Boolean submitted = true;
					List<ICG_Notification__c> notifications = new List<ICG_Notification__c>();
					Contact con = [Select id, email from contact where id = :contactId];
					if(skipApprovalProcess != true) {
						//ONLY PREPARED TO BE SENT TO ONE! It's controled above.
						for(ICG_Contact_Role_Detail__c crdti : crdsToInsert) {
							List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();

							//Send Email to Requestor
							emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Station_Manager_Request_sent_to_req', crdti.Id, new Set<Id> {con.id}));

							String subject = 'Station Manager request sent';
							String body = subject;
							notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', new List<String> {con.Id}, crdti.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
							
							Set<Id> stationManagerCompanyAdminIds = new Set<Id>();
							Set<Id> iataAdminIds = CW_EmailManager.getIataAdminsIds();
							List<String> contactIds = new List<String>();
							for (ICG_Contact_Role_Detail__c crd : getStationManagersContactRoleDetails(crdti.ICG_Account_Role_Detail__c)) {
								stationManagerCompanyAdminIds.add(crd.Account_Contact_Role__r.Contact__c);
								contactIds.add(crd.Account_Contact_Role__r.Contact__c);
							}
							for (Contact cadmn : getCompanyAdminContactsFromAccountId(companyId)) {
								stationManagerCompanyAdminIds.add(cadmn.Id);
								contactIds.add(cadmn.Id);
							}
							if(!stationManagerCompanyAdminIds.isEmpty()) {
								emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Approve_Reject_Com_Adm_exis_Stat_Man', crdti.Id, stationManagerCompanyAdminIds));

								String subjectCompAdmin = 'New Station Manager request pending approval';
								String bodyCompAdmin = subjectCompAdmin;
								notifications.addAll(CW_NotificationsController.setNotificationCustom(subjectCompAdmin, bodyCompAdmin, 'Requested', contactIds, crdti.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
								
								if(!iataAdminIds.isEmpty()) {
									emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Approve_Reject_to_IATA_Admin', crdti.Id, iataAdminIds));
								}
							} else {
								emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Approve_Reject_to_IATA_Adm_no_Comp_adm', crdti.Id, iataAdminIds));					
							}

							submitted = CW_EmailManager.sendInternalEmails(emailsToBeSent, true);
						}
					}

					res.success = true;
					res.message = Label.icg_station_manager_request_sent;
					if (submitted != true) {
						res.message += ' ' + Label.icg_something_went_wrong_emails;
					}

					if(notifications.size() > 0) {
						insert notifications;
					}
				}
			} catch(DmlException ex) {
				String errorMessage = ex.getMessage();
				Integer occurence;
				if (ex.getMessage().contains(FIELD_CUSTOM_VALIDATION_EXCEPTION)){
					occurence = errorMessage.indexOf(FIELD_CUSTOM_VALIDATION_EXCEPTION + ',') + 34;
					errorMessage = errorMessage.mid(occurence, errorMessage.length());
					occurence = errorMessage.lastIndexOf(':');
					errorMessage = errorMessage.mid(0, occurence);

					res.success = false;
					res.message = errorMessage + Label.icg_please_contact_iata;
				}
				else {
					throw new AuraHandledException('exception: ' + ex);
				}
			} catch(Exception ex) {
				throw new AuraHandledException('exception: ' + ex);
			}
		} else {
			res.success = false;
			res.message = 'Please, select at least one facility';
		}
		
		
		return JSON.serialize(res);
	}

	/*
	 * @description		Retrieve approved contacts that belong to one station
	 * @param			stationId ICG_Account_Role_Detail__c.Id
	 * @return			List of approved contacts related to the stationId passed by parameter
	 */
	@AuraEnabled
	public static List<ICG_Contact_Role_Detail__c> getStationManagersContactRoleDetails(String stationId) {
		return getFacilityManagerContactRolesFromStationListByStatus(new List<String>{stationId}, new List<String>{'Approved'});
	}

	/*
	 * @description		Create in memory a contact related to one ICG_Account_Role_Detail__c
	 * @param			companyId Id of the company
	 * @param			facilityIds Ids of ICG_Account_Role_Detail__c
	 * @param			contactId If of Contact__c
	 * @param			status of the contact
	 * @return			List of ICG_Contact_Role_Detail__c 
	 */
	public static List<ICG_Contact_Role_Detail__c> getContactRoleDetailsToInsert(String companyId, String facilityIds, String contactId, String status) {
		List<ICG_Contact_Role_Detail__c> crdsToInsert = new List<ICG_Contact_Role_Detail__c>();
		List<String> facilityIdsToLoop = facilityIds.replaceAll('[^a-zA-Z0-9,\\s+]', '').split(',');
		ICG_Contact_Role_Detail__c crd; 	

		List<Account_Role__c> accountRoles = [Select Id from Account_Role__c where Account__c =: companyId and Functional_Role__c = 'One Source'];
		Id accountRoleId = !accountRoles.isEmpty() ? accountRoles[0].Id : null;

		List<Account_Contact_Role__c> acr = getAccountContactRole(companyId, contactId, accountRoleId);
		
		if (!acr.isEmpty()){
			for (String facId : facilityIdsToLoop) {
				crd = new ICG_Contact_Role_Detail__c();
				crd.ICG_Role__c = FACILITY_MANAGER;
				crd.Status__c = status;
				crd.Account_Contact_Role__c = acr[0].id;
				crd.ICG_Account_Role_Detail__c = facId;
				crdsToInsert.add(crd);
			}
		}
		return crdsToInsert;
	}

	/*
	 * @description		Create Role (if accountRoleId is null) and return Account Contacts list by account and contact id
	 * @param			companyId <The id of the Account>
	 * @param			contactId <The id of the Contact>
	 * @param			accountRoleId <If is null, create a new Account Role>
	 * @return			Account Contacts Role list
	 */
	private static List<Account_Contact_Role__c> getAccountContactRole(String companyId, String contactId, Id accountRoleId) {
		String accRoleId = accountRoleId;
		if(accountRoleId == null) {
			Account_Role__c accRole = new Account_Role__c();
			accRole.Account__c = companyId;
			accRole.Functional_Role__c = 'One Source';
			insert accRole;
			accRoleId = accRole.Id;
		}
		
		List<Account_Contact_Role__c> acr = new List<Account_Contact_Role__c>();
		if (String.isNotBlank(contactId)) {
			acr = [Select id from Account_Contact_Role__c where Contact__c = :contactId and Account__c = :companyId and Functional_Role__c = 'One Source'];
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
		}
		return acr;
	}

	@AuraEnabled
	/*
	 * @description		handles user request to be company admin of specific station
	 * @param			stationId <The id of the Account>
	 * @param			companyId <The id of the Account>
	 * @param			contactId <The id of the Contact>
	 * @return			Message to the user's request 
	 */
	public static String becomeCompanyAdminFromStation(String stationId, String companyId, String contactId) {
		return becomeCompanyAdmin(getOpsHierarchyNameFromStationId(stationId), companyId, contactId);
	}


	/*
	 * @description		handles user request to be company admin
	 * @param			groupName <Station group name>
	 * @param			companyId <The id of the Company>
	 * @param			contactId <If is null, create a new Account Role>
	 * @return			Message to the user's request 
	 */
	@AuraEnabled
	public static String becomeCompanyAdmin(String groupName, String companyId, String contactId) {
		ResponseBody res = new ResponseBody();
		Set<Id> accRolesIds = getAccountsRolesToSearch(new List<String>{groupName});
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
				if (!acr.isEmpty()) {
					res = createCompanyAdminContactRoleDetail(acr[0].Id,accountRoleId, groupName, contactId);				
				}
			} else {
				res.success=false;
				res.message = 'You do not belong to any company. Please contact your IATA Administrator.';
			}
		} else {
			List<Account_Contact_Role__c> acr = getAccountContactRole(companyId, contactId, new List<Id>(accRolesIds)[0]);
			if (!acr.isEmpty()) {
				res = createCompanyAdminContactRoleDetail(acr[0].Id,new List<Id>(accRolesIds)[0], groupName, contactId);
			}
		}
		
		return JSON.serialize(res);
	}

	/*
	 * @description		Create Contact Role Detail-Company Admin and handles user request to be company admin emails and message
	 * @param			accContactRole <Account contact role Id>
	 * @param			accRoleId <Account role Id>
	 * @param			contactId <The id of the Contact>
	 * @return			Message result
	 */
	private static ResponseBody createCompanyAdminContactRoleDetail(String accContactRole, String accRoleId, String groupName, Id contactId ) {
		ResponseBody res = new ResponseBody();
		ICG_Contact_Role_Detail__c crd = new ICG_Contact_Role_Detail__c();
		crd.ICG_Role__c = COMPANY_ADMIN;
		crd.Status__c = 'Pending for Approval';
		crd.Account_Contact_Role__c = accContactRole;
		crd.Account_Role__c = accRoleId;
		try {
			insert crd;
			Contact con = [Select id, email from contact where id = :contactId];
			
			
			List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Comp_Adm_req_conf_to_requestor_sent', crd.Id, new Set<Id> {con.id}));
			String subject = 'Company Admin request sent';
			CW_NotificationsController.setNotificationCustom(subject, subject, 'Requested', new List<String> {con.id}, cRd.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA);
			
			Set<Id> companyAdminIds = new Set<Id>();
			List<String> lstCompanyAdminIds = new List<String>();
			for (Contact cadmn : getCompanyadminContactsFromGroupName(new List<String>{groupName})) {
				companyAdminIds.add(cadmn.Id);
				lstCompanyAdminIds.add(cadmn.Id);
			}
			if(!companyAdminIds.isEmpty()) {
				subject = 'New Company Admin request pending approval';
				emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Approve_Reject_to_existing_Comp_Adm', crd.Id, companyAdminIds));
				CW_NotificationsController.setNotificationCustom(subject, subject, 'Requested', lstCompanyAdminIds, cRd.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA);
			}
			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Approve_Reject_to_IATA_admin_CA', crd.Id, CW_EmailManager.getIataAdminsIds()));

			Boolean submitted = CW_EmailManager.sendInternalEmails(emailsToBeSent, true);

			res.success = true;
			res.message = Label.icg_thank_you_iata_contact;

			if (submitted == false) {
				res.message += ' ' + Label.icg_something_went_wrong_emails;
			} 
			
		}catch(Exception ex) {
			res.success = false;
			res.message = ex.getMessage();
		}
		return res;
	}

	/*
	 * @description		Retrieve Users that are group member of ICG_Stakeholders
	 * @return			List of User
	 */
	public static List<User> getIATAStakeHoldersUsersList() {
		return [Select id, name, email from User where Id IN (Select UserOrGroupId from GroupMember where Group.DeveloperName = 'ICG_Stakeholders')];
	}

	/*
	 * @description		Retrieve list of contacts by group name
	 * @param			groupName <Account contact role Id>
	 * @param			statusList <Account role Id>
	 * @return			Message result
	 */
	public static List<Contact> getCompanyAdminContactsFromGroupNameByStatus (List<String> groupName, List<String> statusList) {
		
		Set<Id> contactsIds = new Set<Id>();
		for (ICG_Contact_Role_Detail__c crd : getCompanyAdminContactRolesFromGroupNameByStatus(groupName, statusList)) {
			if(crd.ContactId__c != null) {
				contactsIds.add(crd.ContactId__c);
			}
		}
		List<Contact> adminContacts = [Select Id, Firstname, Lastname, Email, Title, Phone from Contact where ID IN :contactsIds AND Email LIKE '%@%'];
		return adminContacts;
	}

	 /*
	 * @description		Retrieve list of ICG_Contact_Role_Detail__c by group name
	 * @param			List<groupName> <Station group name>
	 * @param			statusList <ICG_Contact_Role_Detail__c.Status__c>
	 * @return			Ids of ICG_Contact_Role_Detail__c
	 */
	public static List<ICG_Contact_Role_Detail__c> getCompanyAdminContactRolesFromGroupNameByStatus(List<String> groupName, List<String> statusList) {
		Set<Id> accountRolesToSearch = getAccountsRolesToSearch(groupName);
		return [Select Id, CreatedDate, ContactId__c, Account_Contact_Role__r.Contact__r.FirstName, Account_Contact_Role__r.Contact__r.LastName, Account_Contact_Role__r.Contact__r.Email, Account_Contact_Role__r.Contact__r.Phone, Account_Contact_Role__r.Contact__r.Title from ICG_Contact_Role_Detail__c where ICG_Role__c =: COMPANY_ADMIN and Status__c IN:statusList and Account_Role__c IN:accountRolesToSearch];
	}

	/*
	 * @description		Retrieve list of ICG_Contact_Role_Detail__c by group name
	 * @param			groupName <Station group name>
	 * @return			Ids of ICG_Contact_Role_Detail__c
	 */
	public static List<ICG_Contact_Role_Detail__c> getRelatedContactsFromGroupName(String groupName) {
		Set<Id> accountRolesToSearch = getAccountsRolesToSearch(new List<String>{groupName});
		return [Select Id, CreatedDate, ContactId__c, Account_Contact_Role__r.Contact__r.FirstName, Account_Contact_Role__r.Contact__r.LastName, Account_Contact_Role__r.Contact__r.Email, Account_Contact_Role__r.Account__c, Account_Contact_Role__r.Contact__r.Phone, Account_Contact_Role__r.Contact__r.Title from ICG_Contact_Role_Detail__c where Account_Role__c IN:accountRolesToSearch];
	}

	/*
	 * @description		Retrieve Accounts related to a Station
	 * @param			stationId ICG_Account_Role_Detail__c.Id
	 * @return			Ids of Accounts
	 */
	public static Set<Id> getRelatedAccountsByStation(String stationId) {
		List<ICG_Contact_Role_Detail__c> relatedContacts = getRelatedContactsFromGroupName(getOpsHierarchyNameFromStationId(stationId));
		Set<Id> accountsIds = new Set<Id>(); 

		for(ICG_Contact_Role_Detail__c crd: relatedContacts) {
			accountsIds.add(crd.Account_Contact_Role__r.Account__c);
		}

		return accountsIds;
	}

	/*
	 * @description		Retrieve list account roles to search by group name
	 * @param			List<groupName> <Account Role Relationship name>
	 * @return			Ids of Accounts
	*/
	private static Set<Id> getAccountsRolesToSearch(List<String> groupName) {
		Set<Id> accountRolesToSearch = new Set<Id>();
		//Select Parent Groups AccountRoles
		Map<Id,Account_Role__c> accRolesParentOfGroups = new Map<Id,Account_Role__c>([Select id from Account_Role__c where ID IN (Select From__c from Account_Role_Relationship__c where Relationship_Name__c IN :groupName)]);

		List<Account_Role_Relationship__c> accountRoleRelatioships = [Select id, From__c, To__c from Account_Role_Relationship__c where Relationship_Name__c IN :groupName or To__c IN :accRolesParentOfGroups.keySet() or (Ops_Hierarchy_Group__c IN :groupName and To__c = null)];
		for (Account_Role_Relationship__c accrRel : accountRoleRelatioships) {
			if(accrRel.To__c != null) {
				accountRolesToSearch.add(accrRel.To__c);
			}
			if(accrRel.From__c != null) {
				accountRolesToSearch.add(accrRel.From__c);
			}
		}
		if(accountRolesToSearch.isEmpty()) {
			List<Account_Role__c> accountsRoleToSearch = [Select Id from Account_Role__c where Functional_Role__c = 'One Source' and Account__r.Name IN :groupName];
			for (Account_Role__c accrRol : accountsRoleToSearch) {
				accountRolesToSearch.add(accrRol.Id);
			}
		}

		return accountRolesToSearch;
	}

	 /*
	 * @description		Retrieve list of approved contacts by group name
	 * @param			List<groupName> <Account contact role Id>
	 * @return			Ids of Contacts
	 */
	@AuraEnabled
	public static List<Contact> getCompanyAdminContactsFromGroupName (List<String> groupName) {
		return getCompanyAdminContactsFromGroupNameByStatus(groupName, new List<String>{'Approved'});
	}

	/*
	 * @description		Retrieve list of pendings contacts by group name
	 * @param			groupName <Account contact role Id>
	 * @return			Ids of ICG_Contact_Role_Detail__c
	 */
	@AuraEnabled (cacheable = false)
	public static List<ICG_Contact_Role_Detail__c> getPendingCompanyAdminContactRolesFromGroupName (String groupName) {
		return getCompanyAdminContactRolesFromGroupNameByStatus(new List<String>{groupName}, new List<String>{'Pending for Approval', 'Pending for Removal'});
	}
	
	/*
	 * @description		Retrieve list of ICG_Contact_Role_Detail__c filtering by stations and status
	 * @param			stationIds <List of station Ids>
	 * @param			statusList <List of status Ids>
	 * @return			Ids of ICG_Contact_Role_Detail__c
	 */
	@AuraEnabled
	public static List<ICG_Contact_Role_Detail__c> getFacilityManagerContactRolesFromStationListByStatus(List<String> stationIds, List<String> statusList) {
		return [Select Id, CreatedDate, Status__c, Account_Contact_Role__r.Account__c, ContactId__c,Account_Contact_Role__c,Account_Contact_Role__r.Contact__r.OtherState, Account_Contact_Role__r.Contact__r.Name,
		Account_Contact_Role__r.Contact__r.OtherCountry,Account_Contact_Role__r.Contact__r.FirstName, ICG_Account_Role_Detail__c,Account_Contact_Role__r.Contact__r.LastName, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Email, Account_Contact_Role__r.Contact__r.Membership_Function__c, Account_Contact_Role__r.Contact__r.Phone, Account_Contact_Role__r.Contact__r.Title from ICG_Contact_Role_Detail__c where ICG_Role__c =: FACILITY_MANAGER and Status__c IN:statusList and ICG_Account_Role_Detail__c IN:stationIds];
	}

	/*
	 * @description		Retrieve list of ICG_Contact_Role_Detail__c filtering by FICG_Role__c=ACILITY_MANAGER and user created
	 * @param			userId <User Id who make the requests>
	 * @return			Ids of ICG_Contact_Role_Detail__c
	 */
	@AuraEnabled
	public static List<ICG_Contact_Role_Detail__c> getFacilityManagerContactRolesFromStationListByUser(String userId) {
		return [Select Id, Status__c,Name, LastModifiedById, isPendingApproval__c, CreatedDate, LastModifiedDate, ContactId__c, 
		Account_Contact_Role__c,
		Account_Contact_Role__r.Account__r.Name, 
		Account_Contact_Role__r.Contact__r.OtherState, 
		Account_Contact_Role__r.Contact__r.Name,
		Account_Contact_Role__r.Contact__r.OtherCountry,Account_Contact_Role__r.Contact__r.FirstName, 
		ICG_Account_Role_Detail__c,
		ICG_Account_Role_Detail__r.Id,
		ICG_Account_Role_Detail__r.Name,
		ICG_Account_Role_Detail__r.RecordType.Name,
		Account_Contact_Role__r.Contact__r.LastName, Account_Contact_Role__r.Contact__r.Email, 
		Account_Contact_Role__r.Contact__r.Phone, Account_Contact_Role__r.Contact__r.Title 
		from ICG_Contact_Role_Detail__c 
		where ICG_Role__c =: FACILITY_MANAGER and (createdById = :userId or LastModifiedById =: userId)];
	}

	public class HistoryDTO {
		@AuraEnabled
		public Id Id { get; set; }

		@AuraEnabled
		public String Type { get; set; }

		@AuraEnabled
		public String Status { get; set; }

		@AuraEnabled
		public Id LastModifiedById { get; set; }

		@AuraEnabled
		public Datetime CreatedDate { get; set; }

		@AuraEnabled
		public Datetime LastModifiedDate { get; set; }

		@AuraEnabled
		public ICG_Contact_Role_Detail__c ICG_Contact_Role_DetailR { get; set; }

		@AuraEnabled
		public Id ICG_Contact_Role_Detail { get; set; }

		@AuraEnabled
		public ICG_Account_Role_Detail__c ICG_Account_Role_DetailR { get; set; }

		@AuraEnabled
		public Id ICG_Account_Role_Detail { get; set; }

		public HistoryDTO () 
		{
		}
	}

	/*
	 * @description		Retrieve the list of History of request done by a user
	 * @param			userId <User Id>
	 * @return			List of HistoryDTO
	 */
	@AuraEnabled
	public static List<HistoryDTO> getFacilityHistoryByUser(String userId) {
		User user = [SELECT Id, ContactId FROM User WHERE id = :userId LIMIT 1];
		String userContactId = user.ContactId;
		List<HistoryDTO> listMyRequest = new List<HistoryDTO>();

		Map<Id, ICG_Contact_Role_Detail__c> crd = new Map<Id, ICG_Contact_Role_Detail__c>(
			[SELECT
				Account_Contact_Role__c, Account_Contact_Role__r.Account__r.Name, Account_Contact_Role__r.Contact__r.OtherState,  Account_Contact_Role__r.Contact__r.Name, 
				Account_Contact_Role__r.Contact__r.OtherCountry, Account_Contact_Role__r.Contact__r.FirstName,
				ICG_Account_Role_Detail__c, ICG_Account_Role_Detail__r.Id, ICG_Account_Role_Detail__r.Name, ICG_Account_Role_Detail__r.RecordType.Name
			FROM ICG_Contact_Role_Detail__c WHERE Account_Contact_Role__r.Contact__c = :userContactId]);

		Map<Id, ICG_Account_Role_Detail__c> ard = new Map<Id, ICG_Account_Role_Detail__c>(
			[SELECT Id, Account_Role__r.Account__c, Name, RecordType.Name, createdById FROM ICG_Account_Role_Detail__c WHERE CreatedById = :userId]);

		List<ICG_History_Track__c> historyTrack = [
			SELECT Id, Type__c, Target_Id__c, New_Value__c, LastModifiedById, CreatedDate, LastModifiedDate 
			FROM ICG_History_Track__c 
			WHERE  (Target_Id__c IN :crd.keySet() AND (Type__C =: ADMIN_REQUEST OR Type__C =: STATION_MANAGER_REQUEST)) 
				OR (Target_Id__c IN :ard.keySet() AND Type__C =: STATION_CREATION_REQUEST)];

		for (ICG_History_Track__c currentItem : historyTrack) {
			if ((currentItem.Type__c == ADMIN_REQUEST || currentItem.Type__c == STATION_MANAGER_REQUEST) && crd.get(currentItem.Target_Id__c).Account_Contact_Role__r.Contact__c == userContactId) {
				HistoryDTO itemToAdd = new HistoryDTO();
				itemToAdd.Id = currentItem.Id;
				itemToAdd.Type = currentItem.Type__c;
				itemToAdd.Status = currentItem.New_Value__c;
				itemToAdd.LastModifiedById = currentItem.LastModifiedById;
				itemToAdd.CreatedDate = currentItem.CreatedDate;
				itemToAdd.LastModifiedDate = currentItem.LastModifiedDate;
				itemToAdd.ICG_Contact_Role_Detail = crd.get(currentItem.Target_Id__c).Id;
				itemToAdd.ICG_Contact_Role_DetailR = crd.get(currentItem.Target_Id__c);
				listMyRequest.add(itemToAdd);

			} else if (currentItem.Type__C == STATION_CREATION_REQUEST && ard.get(currentItem.Target_Id__c).createdById == userId) {
				HistoryDTO itemToAdd = new HistoryDTO();
				itemToAdd.Id = currentItem.Id;
				itemToAdd.Type = currentItem.Type__c;
				itemToAdd.Status = currentItem.New_Value__c;
				itemToAdd.LastModifiedById = currentItem.LastModifiedById;
				itemToAdd.CreatedDate = currentItem.CreatedDate;
				itemToAdd.LastModifiedDate = currentItem.LastModifiedDate;
				itemToAdd.ICG_Account_Role_Detail = ard.get(currentItem.Target_Id__c).Id;
				itemToAdd.ICG_Account_Role_DetailR = ard.get(currentItem.Target_Id__c);
				listMyRequest.add(itemToAdd);
			}
		}

		Map<String, String> hierarchyByStation = new Map<String, String>();	
		for (HistoryDTO item : listMyRequest) {
			if (item.Type == STATION_MANAGER_REQUEST){
				String  company = (item.ICG_Contact_Role_DetailR.Account_Contact_Role__r.Account__r != null) ? item.ICG_Contact_Role_DetailR.Account_Contact_Role__r.Account__r.Name : '';
				String station = (item.ICG_Contact_Role_DetailR.ICG_Account_Role_Detail__r != null) ? item.ICG_Contact_Role_DetailR.ICG_Account_Role_Detail__r.Name : '';
				
				if (company != '' && station != ''){
					hierarchyByStation.put(station, company);
				}
			}
		}

		for (HistoryDTO item : listMyRequest) {
			if (item.Type == STATION_CREATION_REQUEST){

				String station = (item.ICG_Account_Role_DetailR != null) ? item.ICG_Account_Role_DetailR.Name : '';
						
				if (station != '' && hierarchyByStation.containsKey(station)){
					String company = hierarchyByStation.get(station);
					item.ICG_Account_Role_DetailR.Name += ';' + company;	
				}    
			}
		}
		return listMyRequest;
	}
	
	/*
	 * @description		Retrieve the list of facility managers approved or removed by one specific user
	 * @param			userId <User Id who make the requests>
	 * @return			List of ICG_Contact_Role_Detail__c
	 */
	@AuraEnabled
	public static List<ICG_Contact_Role_Detail__c> getFacilityManagerApprovedOrRemovedByUser(String userId) {
		return [Select Id, ICG_Role__c, Status__c, LastModifiedDate,
		Account_Contact_Role__r.Contact__r.Name,
		Account_Contact_Role__r.Account__r.Name,
		Account_Contact_Role__r.Account__c,
		ICG_Account_Role_Detail__c,
		ICG_Account_Role_Detail__r.Name,
		lastModifiedBy.Name 
		from ICG_Contact_Role_Detail__c
		where (ICG_Role__c =: FACILITY_MANAGER OR ICG_Role__c =: COMPANY_ADMIN) AND (Status__c= 'Approved' OR Status__c= 'Removed') AND createdById = :userId];
	}

	/*
	 * @description		Retrieve the admins of a station or company
	 * @param			contactId <Contact Ids>
	 * @return			List of Contact
	 */
	@AuraEnabled
	public static List<Contact> getCompanyAdminContactsFromContactId(String contactId) {
		return contactId != null ? getCompanyAdminContactsFromGroupName(getOpsHierarchyNameFromContactId(contactId, new List<String>{'Approved'})) : new List<Contact>();
	}

	/*
	 * @description		Retrieve the admins of a station or company
	 * @param			accountId <Account Ids>
	 * @return			List of Contact
	 */
	@AuraEnabled
	public static List<Contact> getCompanyAdminContactsFromAccountId(String accountId) {
		return accountId != null ? getCompanyAdminContactsFromGroupName(new List<String>{getOpsHierarchyNameFromAccountId(accountId)}) : new List<Contact>();
	}

	/*
	 * @description		Get the global company name
	 * @param			accountId <Account Id>
	 * @return			Company Name
	*/
	@AuraEnabled
	public static String getOpsHierarchyNameFromAccountId (String accountId) {
		List<String> opsHierarchies = getOpsHierarchyNameFromAccountId(new List<String>{accountId});
		if (opsHierarchies.isEmpty()) {
			return null;
		} else{
			return opsHierarchies[0];
		}
	}

	/*
	 * @description		Get the global company name
	 * @param			List<accountId> <Account Id>
	 * @return			Company Name
	*/
	public static List<String> getOpsHierarchyNameFromAccountId (List<String> accountId) {
		List<String> opsHierarchyFull = new List<String>();
		List<Account_Role__c> accsRole = new List<Account_Role__c>();
		Map<Id, Id> mapRelationshipIdByAccountRoleId = new Map<Id, Id>();
		
		Map<Id, Account> accountById = new Map<Id, Account>();
		Map<String, Account> accountParentByUltimateAccountGlobalId = new Map<String, Account>();

		for (Account currentItem : [SELECT Id, Name, Global_Ultimate_Account_Global_ID__c FROM Account WHERE Id IN :accountId]) {
			accountById.put(currentItem.Id, currentItem);
			if (currentItem.Global_Ultimate_Account_Global_ID__c != null) {
				accountParentByUltimateAccountGlobalId.put(currentItem.Global_Ultimate_Account_Global_ID__c, null);
			}
		}

		for (Account currentItem : [SELECT Id, Name, Global_Ultimate_Account_Global_ID__c FROM Account WHERE Global_ID__c IN : accountParentByUltimateAccountGlobalId.keySet()]) {
			accountParentByUltimateAccountGlobalId.put(currentItem.Global_Ultimate_Account_Global_ID__c, currentItem);
		}

		for (Account_Role__c currentItem : [SELECT Id, Account__c, (SELECT Id, From__c, To__c, Relationship_Name__c, Ops_Hierarchy_Group__c FROM From_Relationships__r) FROM Account_Role__c WHERE Account__c IN :accountId AND Functional_Role__c = 'One Source' ORDER BY CreatedDate DESC]) {
			accsRole.add(currentItem);
			if ( !currentItem.From_Relationships__r.isEmpty() && currentItem.From_Relationships__r[0].To__c != null && currentItem.From_Relationships__r[0].To__c != currentItem.From_Relationships__r[0].From__c) {
				mapRelationshipIdByAccountRoleId.put(currentItem.Id, currentItem.From_Relationships__r[0].To__c);
			}
		}

		Map<Id, Account_Role_Relationship__c> mapRelationships = new Map<Id, Account_Role_Relationship__c>([SELECT Id, From__c, To__c, Relationship_Name__c, Ops_Hierarchy_Group__c FROM Account_Role_Relationship__c WHERE From__c IN :mapRelationshipIdByAccountRoleId.values()]);
		for (Account_Role__c currentItem : accsRole) {
			String opsHierarchy;
			
			if(!currentItem.From_Relationships__r.isEmpty()) {

				if(currentItem.From_Relationships__r[0].To__c != null && currentItem.From_Relationships__r[0].To__c != currentItem.From_Relationships__r[0].From__c) {
					Account_Role_Relationship__c rel = mapRelationships.get(mapRelationshipIdByAccountRoleId.get(currentItem.Id));
					if(rel != null) {
						if(rel.Relationship_Name__c != null) {
							opsHierarchy = rel.Relationship_Name__c;
						}
						else if (rel.Ops_Hierarchy_Group__c != null) {
							opsHierarchy = rel.Ops_Hierarchy_Group__c;
						}
					}
				}
				if(opsHierarchy == null) {
					if(currentItem.From_Relationships__r[0].Relationship_Name__c != null) {
						opsHierarchy = currentItem.From_Relationships__r[0].Relationship_Name__c;
					}
					else if (currentItem.From_Relationships__r[0].Ops_Hierarchy_Group__c != null) {
						opsHierarchy = currentItem.From_Relationships__r[0].Ops_Hierarchy_Group__c;
					}
				}
			}

			if(opsHierarchy == null) {
				Account acc = accountById.get(currentItem.Account__c);
				if(acc != null) {
					if(acc.Global_Ultimate_Account_Global_ID__c != null) {
						Account parentAcc = accountParentByUltimateAccountGlobalId.get(acc.Global_Ultimate_Account_Global_ID__c);
						if(parentAcc != null) {
							opsHierarchy = parentAcc.Name;
						} else {
							opsHierarchy = acc.Name;
						}
					} else {
						opsHierarchy = acc.Name;
					}
				}
			}

			if(opsHierarchy != null) {
				opsHierarchyFull.add(opsHierarchy);
			}
		}

		return opsHierarchyFull;
	}

	/*
	 * @description		Get the global company group
	 * @param			accountId <Account Id>
	 * @return			Company group
	*/
	@AuraEnabled
	public static String getOpsHierarchyGroupFromAccountId (String accountId) {
		String opsHierarchy;
		List<Account_Role__c> accRole = [Select Id, (Select Id, From__c, To__c, Relationship_Name__c, Ops_Hierarchy_Group__c from From_Relationships__r) from Account_Role__c Where Account__c = :accountId AND Functional_Role__c = 'One Source'];
		if (!accRole.isEmpty()) {
			if(!accRole[0].From_Relationships__r.isEmpty()) {
				if(accRole[0].From_Relationships__r[0].To__c != null && accRole[0].From_Relationships__r[0].To__c != accRole[0].From_Relationships__r[0].From__c) {
					List<Account_Role_Relationship__c> rel = [Select Id, From__c, To__c, Relationship_Name__c, Ops_Hierarchy_Group__c from Account_Role_Relationship__c where From__c = :accRole[0].From_Relationships__r[0].To__c];
					if(!rel.isEmpty()) {
						if (rel[0].Ops_Hierarchy_Group__c != null) {
							opsHierarchy = rel[0].Ops_Hierarchy_Group__c;
						}
					}
				}
				if(opsHierarchy == null) {
					if (accRole[0].From_Relationships__r[0].Ops_Hierarchy_Group__c != null) {
						opsHierarchy = accRole[0].From_Relationships__r[0].Ops_Hierarchy_Group__c;
					}
				}
			}
		}
		
		return opsHierarchy;
	}

	/*
	 * @description		Get the global company group name
	 * @param			accountId <Account Id>
	 * @return			Company group
	*/
	@AuraEnabled
	public static String getOpsHierarchyGroupNameFromAccountId (String accountId) {
		String opsHierarchyName;
		List<Account_Role__c> accRole = [Select Id, Account__c, Account__r.Name, (Select Id, Relationship_Name__c, Ops_Hierarchy_Group__c from From_Relationships__r) from Account_Role__c Where Account__c = :accountId AND Functional_Role__c = 'One Source'];
		if (!accRole.isEmpty()) {
			if(!accRole[0].From_Relationships__r.isEmpty()) {
				if(accRole[0].From_Relationships__r[0].Ops_Hierarchy_Group__c != null) {	
					opsHierarchyName = accRole[0].From_Relationships__r[0].Ops_Hierarchy_Group__c;						
				}else{
					opsHierarchyName = accRole[0].Account__r.Name;
				}
			}
		}		
		
		return opsHierarchyName;
	}

	/*
	 * @description		Get the global company group name by userid
	 * @param			contactId <Contact Id>
	 * @return			List<Company group>
	*/
	public static List<String> getOpsHierarchyNameFromContactId (String contactId, List<String> allowedStatus) {
		List<Id> accountIds = new List<Id>();
		for (ICG_Contact_Role_Detail__c currentItem : [SELECT Id, Account_Role__r.Account__r.Id FROM ICG_Contact_Role_Detail__c 
														WHERE ICG_Role__c = :COMPANY_ADMIN AND Status__c IN :allowedStatus AND Account_Contact_Role__r.Contact__r.Id = :contactId]
		) {
			if (!accountIds.contains(currentItem.Account_Role__r.Account__r.Id)) {
				accountIds.add(currentItem.Account_Role__r.Account__r.Id);
			}
		}
		return getOpsHierarchyNameFromAccountId(accountIds);
	}

	/*
	 * @description		Get the global company group name by userid
	 * @param			userId <User Id>
	 * @return			Company group
	*/
	public static String getOpsHierarchyNameFromUserId (String userId) {
		String opsHierarchy;
		List<User> u = [Select id, AccountId from User where id=:userId];
		if(!u.isEmpty() && u[0].AccountId != null) {
			opsHierarchy = getOpsHierarchyNameFromAccountId(u[0].AccountId);
		}
		return opsHierarchy;
	}

	/*
	 * @description		Get the global company group by userid
	 * @param			userId <User Id>
	 * @return			Company group
	*/
	public static String getOpsHierarchyGroupFromUserId (String userId) {
		String opsHierarchy;
		List<User> u = [Select id, AccountId from User where id=:userId];
		if(!u.isEmpty() && u[0].AccountId != null) {
			opsHierarchy = getOpsHierarchyGroupFromAccountId(u[0].AccountId);
		}
		return opsHierarchy;
	}

	/*
	 * @description		Get the global company name by station Id
	 * @param			stationId <Station Id>
	 * @return			Company Name
	*/
	@AuraEnabled
	public static String getOpsHierarchyNameFromStationId (String stationId) {
		String opsHierarchy;
		List<ICG_Account_Role_Detail__c> station = [Select id, Account_Role__r.Account__c FROM ICG_Account_Role_Detail__c where id =:stationId];
		if(!station.isEmpty() && station[0].Account_Role__r.Account__c != null) {
			opsHierarchy = getOpsHierarchyNameFromAccountId (station[0].Account_Role__r.Account__c);
		}
		return opsHierarchy;
	}

	/*
	 * @description		Retrieve picklist enabled languages 
	 * @return			JSON languages
	*/
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

	/*
	 * @description		    Retrieve the pickList structure
	 * @objectName			object Api name
	 * @controllingField	List of fields
	 * @dependentField		List of dependent fields
	 * @saveKeyAsLowerCase	if this flag is true, it will transform the value in lowercase
	 * @return			    Picklist label/value structure
	*/
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


	/*
	 * @description		Send different emails after aprove/reject ICG_Account_Role_Detail__c
	 * @param			newStation <new version of the station>
	 * @param			oldStation <old version of the station>
	*/
	public static void sendApproveOrRejectMails(ICG_Account_Role_Detail__c newStation, ICG_Account_Role_Detail__c oldStation) {
		//only to get the accountid and the created by email
		ICG_Account_Role_Detail__c ard = [Select id, Formatted_Address__c, Name, Account_Role__c, Account_Role__r.Account__c, Account_Role__r.Account__r.RecordType.DeveloperName, Account_Role__r.Account__r.RecordType.Name, CreatedById, CreatedBy.Email, CreatedBy.ContactId, CreatedBy.Contact.Email from ICG_Account_Role_Detail__c where id = :newStation.Id];
		Id whoId = ard.CreatedBy.ContactId != null ? ard.CreatedBy.ContactId : null;
		//Send email to approvers
		Set<Id> whoIds = new Set<Id>();
		whoIds.add(whoId);
		List<String> contactIds = new List<String>();
		contactIds.add(whoId);
		for(Contact c : getCompanyAdminContactsFromAccountId(ard.Account_Role__r.Account__c)) {
			whoIds.add(c.Id);
			contactIds.add(c.Id);
		}
		List<ICG_Notification__c> notifications = new List<ICG_Notification__c>();
		List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();

		String subject = 'Station Creation request for ' + ard.Name;
		String body = 'Station Creation request for ' + ard.Name + ', ' + ard.Account_Role__r.Account__r.RecordType.Name + ', ' + ard.Formatted_Address__c;
		Boolean shouldCleanup = false;
		if (newStation.Status__c == 'Approved' && oldStation.Status__c != 'Approved') {
			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Notification_Approved_to_Req_Comp_Adm', newStation.Id, whoIds));

			subject +=  ' approved';
			body +=  ' approved';
			notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', contactIds, newStation, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
			if(ard.CreatedBy.ContactId != null) {
				List<ICG_Contact_Role_Detail__c> crdsToInsert = CW_Utilities.getContactRoleDetailsToInsert(ard.Account_Role__r.Account__c, newStation.Id, ard.CreatedBy.ContactId, 'Approved');
				if (!crdsToInsert.isEmpty()) {
					insert crdsToInsert;
				}
			}
		} else if (newStation.Status__c == 'Rejected' && oldStation.Status__c != 'Rejected') {
			if(ard.CreatedBy.ContactId != null) {
				updateAllStationManagementRecords(ard.CreatedBy.ContactId, newStation.Id, 'Rejected');
			}

			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Notification_Rejected_to_Req_Comp_Adm', newStation.Id, whoIds));

			subject +=  ' rejected';
			body +=  ' rejected';
			notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', contactIds, newStation, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
			shouldCleanup = false;
		}

		CW_EmailManager.sendInternalEmails(emailsToBeSent);

		if(notifications.size() > 0) {
			insert notifications;
		}

		if(shouldCleanup == true){
			cleanupAccount(ard);
		}
	}

	/*
	 * @description		Delete ICG_Account_Role_Detail__c and its Account related
	 * @param			ard <Load account by ard.Account_Role__r.Account__c>
	*/
	private static void cleanupAccount(ICG_Account_Role_Detail__c ard) {
		if( ard != null && ard.Account_Role__r != null && ard.Account_Role__r.Account__r != null && ard.Account_Role__r.Account__r.RecordType != null && ard.Account_Role__r.Account__r.RecordType.DeveloperName == 'Standard_Account') {
			try{
				Account acc = new Account();
				acc.Id = ard.Account_Role__r.Account__c;
				
				List<ICG_History_Track__c> listHistory = [Select Id from ICG_History_Track__c where SObject__c = 'ICG_Account_Role_Detail__c' AND Target_Id__c = :ard.Id];
				delete listHistory;

				delete ard;
				delete acc;
			}
			catch (Exception ex) {
				throw new AuraHandledException('exception: ' + ex);
			}
		}
	}

	 /*
	 * @description		Send different emails after aprove/reject ICG_Contact_Role_Detail__c
	 * @param			newContactRole <new version of the station>
	 * @param			oldContactRole <old version of the station>
	*/
	public static void sendApproveOrRejectMailsContactRole (ICG_Contact_Role_Detail__c newContactRole, ICG_Contact_Role_Detail__c oldContactRole){
		Set<Id> whoIdsCompAdminStationManagersContacts = new Set<Id>();
		Set<Id> whoIdsCompAdmStationManagersCRDs = new Set<Id>();
		Set<String> notificationReceivers = new Set<String>();
		List<String> companyAdminNotificationIds = new List<String>();
		String templateNameContact;
		String templateNameCompAdmStationManagers;
		String templateNameIata;
		String subject;
		String adminSubject;

		ICG_Contact_Role_Detail__c crd = [Select id, ICG_Account_Role_Detail__r.Account_Role__r.Account__c, Account_Role__r.Account__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Email from ICG_Contact_Role_Detail__c where Id = :newContactRole.Id];
		Set<Id> whoIds = new Set<Id>{crd.Account_Contact_Role__r.Contact__c};		
		notificationReceivers.add(crd.Account_Contact_Role__r.Contact__c);

		for (Contact cadmn : getCompanyAdminContactsFromAccountId(crd.ICG_Account_Role_Detail__r.Account_Role__r.Account__c)) {
			whoIdsCompAdminStationManagersContacts.add(cadmn.Id);
			notificationReceivers.add(cadmn.Id);
		}
		
		if(newContactRole.ICG_Role__c == FACILITY_MANAGER) {
			for (ICG_Contact_Role_Detail__c mngr : getStationManagersContactRoleDetails(newContactRole.ICG_Account_Role_Detail__c)) {
				whoIdsCompAdmStationManagersCRDs.add(mngr.Account_Contact_Role__r.Contact__c);
				notificationReceivers.add(mngr.Account_Contact_Role__r.Contact__c);
			}
			if (newContactRole.Status__c == 'Approved' && oldContactRole.Status__c != 'Approved'){
				templateNameIata = 'Notification_approved_to_IATA';
				templateNameContact = 'Notification_approved_to_User';
				templateNameCompAdmStationManagers = 'Notification_appr_to_Sta_Man_Comp_Adm';
				subject = 'Station Manager request approved';					
			}else if(newContactRole.Status__c == 'Rejected' && oldContactRole.Status__c != 'Rejected'){
				templateNameContact = 'Notification_rejected_to_User';
				subject = 'Station manager request rejected';
			}else if (newContactRole.Status__c == 'Removed' && oldContactRole.Status__c != 'Removed') {
				templateNameContact = 'Remove_notification_to_removed_stat_man';
				templateNameIata = 'Remove_notification_to_IATA';
				templateNameCompAdmStationManagers = 'Remove_notif_to_Stat_Man_Comp_Adm';
				subject = 'Station Manager rights removed';
			}	
		} else if(newContactRole.ICG_Role__c == COMPANY_ADMIN) {
			for (Contact cadmn : getCompanyAdminContactsFromAccountId(crd.Account_Role__r.Account__c)) {
				if(!notificationReceivers.contains(cadmn.Id)){
					companyAdminNotificationIds.add(cadmn.Id);
				}					
			}
			if (newContactRole.Status__c == 'Approved' && oldContactRole.Status__c != 'Approved'){
				templateNameIata = 'Notification_Com_Adm_Req_appr_to_IATA';
				templateNameContact = 'Notification_CA_Approv_to_Requestor';
				templateNameCompAdmStationManagers = 'Notification_CA_Appro_to_Comp_Adm';
				subject = 'Company admin request approved';
				adminSubject = 'New Company Admin request approved';
			}else if(newContactRole.Status__c == 'Rejected' && oldContactRole.Status__c != 'Rejected'){
				templateNameIata = 'Notification_CA_Rejected_to_IATA';
				templateNameContact = 'Notification_CA_Rejected_to_Requestor';
				templateNameCompAdmStationManagers = 'Notification_CA_Rejected_to_Comp_Adm';
				subject = 'Company admin request rejected';
			}				
		}			 

		Set<Id> whoEmailsCompAdmStationManagersCombined = new Set<Id>();
		whoEmailsCompAdmStationManagersCombined.addAll(whoIdsCompAdminStationManagersContacts);
		whoEmailsCompAdmStationManagersCombined.addAll(whoIdsCompAdmStationManagersCRDs);

		//Send emails 
		List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
		if(templateNameIata != null) {
			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(templateNameIata, newContactRole.Id, CW_EmailManager.getIataAdminsIds()));
		}		
		if(templateNameCompAdmStationManagers != null) {
			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(templateNameCompAdmStationManagers, newContactRole.Id, whoEmailsCompAdmStationManagersCombined));
		}
		if (newContactRole.contactId__c != null && templateNameContact != null) {
			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(templateNameContact, newContactRole.Id, whoIds));
		}
		CW_EmailManager.sendInternalEmails(emailsToBeSent);

		//Create notifications
		if(subject != null) {
			CW_NotificationsController.setNotificationCustom(subject, subject, 'Requested', new List<String>(notificationReceivers), crd.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA);
		}
		if(String.isNotBlank(adminSubject)){
			CW_NotificationsController.setNotificationCustom(adminSubject, adminSubject, 'Requested', companyAdminNotificationIds, crd.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA);
		}
	}
	
	/*
	 * @description		Update status station 
	 * @param			contactId <Ontact Id>
	 * @param			stationId <Station ID>
	 * @param			status <New status>
	*/
	public static void updateAllStationManagementRecords(Id contactId, Id stationId, String status) {
		List<ICG_Contact_Role_Detail__c> crds = [Select id from ICG_Contact_Role_Detail__c where ContactId__c = :contactId AND ICG_Account_Role_Detail__c =:stationId];
		for (ICG_Contact_Role_Detail__c crd : crds) {
			crd.Status__c = status;
			crd.Contact_Role_Remove_Requestor__c = null;
		}
		if(!crds.isEmpty()) {
			update crds;
		}
	}

	/*
	 * @description		Retrieve the pick list structure in JSON 
	 * @param			objectApi <Object name>
	 * @param			fieldApi <Field Api name>
	 * @param			Picklist structure
	*/
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

	/*
	 * @description		Retrieve the ICG_Account_Role_Detail__c record types availables by Account.Sector__c and Account.Category__c
	 * @return			JSON [ { "sectorName": "dummy sector", "categories": [ { "categoryName": "dummy category", "allowedTypes": ["type_1", "type_2"] } ] } ]
	 */
	@AuraEnabled (cacheable = true)
	public static String getArdTypesBySectorAndCategory() {
		Map<String, String> sectorMap = new Map<String, String>();
		for (PicklistVal currentValue : (List<CW_Utilities.PicklistVal>) JSON.deserialize(CW_Utilities.getPicklistValues('Account', 'Sector__c'), List<CW_Utilities.picklistVal>.class) ) {
			sectorMap.put(currentValue.api.toLowerCase(), currentValue.label);
		}
		Map<String, String> categoryMap = new Map<String, String>();
		for (PicklistVal currentValue : (List<CW_Utilities.PicklistVal>) JSON.deserialize(CW_Utilities.getPicklistValues('Account', 'Category__c'), List<CW_Utilities.picklistVal>.class) ) {
			categoryMap.put(currentValue.api.toLowerCase(), currentValue.label);
		}
		Map<String, SectorCategoryArdTypesSelector> sectors = new Map<String, SectorCategoryArdTypesSelector>();
		for (ICG_Sector_Category_Selector__mdt currentMd : [SELECT Sector__c, Category__c, ONE_Source_Account_Role_Detail_Type__c FROM ICG_Sector_Category_Selector__mdt ORDER BY Sector__c]) {
			if (String.isNotBlank(currentMd.Sector__c) && String.isNotBlank(currentMd.Category__c) && String.isNotBlank(currentMd.ONE_Source_Account_Role_Detail_Type__c)) {

				if (!sectors.containsKey(currentMd.Sector__c.toLowerCase())) {
					String sectorLabel = sectorMap.containsKey(currentMd.Sector__c.toLowerCase()) ? sectorMap.get(currentMd.Sector__c.toLowerCase()) : '';
					sectors.put(currentMd.Sector__c.toLowerCase(), new SectorCategoryArdTypesSelector(currentMd.Sector__c.toLowerCase(), sectorLabel));
				}

				for (String currentCategory : currentMd.Category__c.split(',')) {
					if ( !sectors.get(currentMd.Sector__c.toLowerCase()).containsCategory(currentCategory.toLowerCase()) ){
						String categoryLabel = categoryMap.containsKey(currentCategory.toLowerCase()) ? categoryMap.get(currentCategory.toLowerCase()) : (currentCategory == '*') ? '*' : '';
						sectors.get(currentMd.Sector__c.toLowerCase()).categories.add(new CategorySelector(currentCategory.toLowerCase(), categoryLabel, currentMd.ONE_Source_Account_Role_Detail_Type__c.toLowerCase().split(',')));
					}
				}
			}
		}

		return JSON.serialize(new Map<String, Object>{ 'sectors' => sectors.values()});
	}

	/*********************************************************************************************************
	 * @name			getUserIdsFromGroup
	 * @author			Beatriz <beatriz.menendez@next-lin.ch>
	 * @created			09 / 12 / 2020
	 * @description		Generates a map for all the requested groups and its related users (and subordinates).
	 *					This map can be used to know all queue member ids for notification purposes as well as
	 *					for any functionality that works with queues and all the child ids must be known.
	 * @param			String param : groupIds -> set of all parent groups to be taken into account.
	 * @return			Map<QueueId, Set<MemmberUsersIds>>
	**********************************************************************************************************/
	public static Map<Id, Set<Id>> getUserIdsFromGroup(Set<Id> groupIds){
		// store the results in a set so we don't get duplicates
		Map<Id, Set<Id>> result					= new Map<Id, Set<Id>>();
		String userType 						= Schema.SObjectType.User.getKeyPrefix(); //005
		String groupType 						= Schema.SObjectType.Group.getKeyPrefix(); //00G
		Map<Id, Set<Id>> groupIdProxysInverse	= new Map<Id, Set<Id>>();
		
		for(GroupMember currentGroupMember : [SELECT Id, UserOrGroupId, Group.Type, Group.RelatedId, GroupId FROM GroupMember WHERE GroupId in :groupIds]){
			// If the user or group id is a user
			if(((String)currentGroupMember.UserOrGroupId).startsWith(userType)){
				addMapMember(result, currentGroupMember.GroupId, currentGroupMember.UserOrGroupId);
			}
			// If the user or group id is a group            
			else if(((String)currentGroupMember.UserOrGroupId).startsWith(groupType)){   
				addMapMember(groupIdProxysInverse, currentGroupMember.userOrGroupId, currentGroupMember.GroupId);
			}
		}
		
		if(!groupIdProxysInverse.isEmpty()){
			Map<Id, Set<Id>> groupIdsMap 			= new Map<Id, Set<Id>>();
			Map<Id, Set<Id>> roleIdInverse			= new Map<Id, Set<Id>>();
			Map<Id, Set<Id>> roleAndSubIdInverse	= new Map<Id, Set<Id>>();		
			for(Group g2 : [SELECT Id, Type, relatedId FROM Group WHERE Id = :groupIdProxysInverse.keySet()]){
				for(Id parentGroup :groupIdProxysInverse.get(g2.Id)){
					if(g2.Type == 'Role'){
						addMapMember(roleIdInverse, g2.relatedId, parentGroup);
					}else if(g2.Type == 'RoleAndSubordinates'){
						addMapMember(roleAndSubIdInverse, g2.relatedId, parentGroup);
					}else if(g2.Type == 'PRMOrganization'){
						addMapMember(roleIdInverse, g2.relatedId, parentGroup);
					}else if(g2.Type == 'Regular'){
						addMapMember(groupIdsMap, g2.Id, parentGroup);						                    
					}					
				}
			}
			//Subordinate roles
			if(!roleAndSubIdInverse.isEmpty()){
				getAllSubRoleIds(roleIdInverse, roleAndSubIdInverse);
			}
			//Roles' users
			if(!roleIdInverse.isEmpty()){
				for(User u: [SELECT id, UserRoleId FROM user WHERE UserRoleId IN: roleIdInverse.keySet()]){
					for(Id groupId:roleIdInverse.get(u.UserRoleId)){
						addMapMember(result, groupId, u.Id);
					}
				}
			}    
			//Subgroup members        
			if(!groupIdsMap.isEmpty()){
				for(GroupMember gm : [SELECT id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN: groupIdsMap.keySet()]){	
					for(Id parentGroupId :groupIdsMap.get(gm.GroupId)){
						addMapMember(result, parentGroupId, gm.UserOrGroupId);
					}					
				}
			}
		}
		return result;
	}

	/******************************************************************************************************
	* @name				getAllSubRoleIds
	* @author			Beatriz <beatriz.menendez@next-lin.ch>
	* @created			09 / 12 / 2020
	* @description		Returns all the depending roles from a set of roles ids
	* @param			Parent users roles ids
	* @return			Returns a set with all the sub-roles depending on the param id roles set.
	******************************************************************************************************/
	private static void getAllSubRoleIds(Map<Id, Set<Id>> roleIds, Map<Id, Set<Id>> roleIdsSubordinates){
		Map<Id, Set<Id>> currentRoleIds = new Map<Id, Set<Id>>();

		for(UserRole userRole :[SELECT Id, ParentRoleId FROM UserRole WHERE ParentRoleId IN :roleIdsSubordinates.KeySet() AND ParentRoleID != null]){
			for(Id parentGroup :roleIdsSubordinates.get(userRole.ParentRoleId)){
				addMapMember(roleIds, userRole.Id, parentGroup);
				addMapMember(currentRoleIds, userRole.Id, parentGroup);
			}
		}
		// go fetch some more rolls!
		if(!currentRoleIds.isEmpty()){
	  		getAllSubRoleIds(roleIds, currentRoleIds);
		}
	}

	/******************************************************************************************************
	* @name				getAllServicesAvailable
	* @description		Get all services available in ONE Source Handling Services picklist 
	* @return			List<String>
	******************************************************************************************************/
	@AuraEnabled
	public static List<CW_Utilities.PicklistVal> getAllServicesAvailable(){
		String thirdPartyField = 'Third_Party_Services__c';
		String inHouseField = 'In_House_Services__c';
		List<CW_Utilities.PicklistVal> result = (List<CW_Utilities.PicklistVal>) JSON.deserialize(CW_Utilities.getPicklistValues('ICG_Account_Role_Detail__c', thirdPartyField), List<CW_Utilities.picklistVal>.class);
		
		Map<String, String> tooltips = new Map<String, String>();
		for (ICG_capability_configuration__mdt item :[SELECT Key__c, Type__c, Data__c FROM ICG_capability_configuration__mdt where Type__c = 'Tooltip_Fields_By_Field']) {
			tooltips.put(item.Key__c, item.Data__c);
		}

		for (CW_Utilities.PicklistVal item :result) {
			if (tooltips.containsKey(thirdPartyField + '#' + item.api)){
				item.tooltip = tooltips.get(thirdPartyField + '#' + item.api);
			} else if (tooltips.containsKey(inHouseField + '#' + item.api)){
				item.tooltip = tooltips.get(inHouseField + '#' + item.api);
			}
		}
		
		return result;
	}

	@AuraEnabled
	public static String getAllServicesAvailableJson() {
		return JSON.serialize(getAllServicesAvailable());
	}
	  
	  /*********************************************************************************************************
	   * @name			addMapMember
	   * @author		Beatriz <beatriz.menendez@next-lin.ch>
	   * @created		09 / 12 / 2020
	   * @description	Adds new map elements (map structure: Map<Id, Set<Id>>)
	   * @param			Map<Id,Set<Id>> mapValuesBykey 	: Map to add the values 
	   * 				Id key : Map key
	   * 				Id value: Map value to add in the key set
	   * @return		No return needed as map is referenced (no new map allowed in the method call process)
	  **********************************************************************************************************/
	  public static void addMapMember(Map<Id,Set<Id>> mapValuesBykey, Id key, Id value){
		if(mapValuesBykey != null){
			if(mapValuesBykey.containsKey(key)){
				mapValuesBykey.get(key).add(value);
			}else{
				Set<Id> setValues = new Set<Id>();
				setValues.add(value);
				mapValuesBykey.put(key, setValues);
			}
		}else{
			mapValuesBykey = new Map<Id,Set<Id>>();
			Set<Id> setValues = new Set<Id>();
			setValues.add(value);
			mapValuesBykey.put(key, setValues);
		}
	}

	public class ResponseBody {
		public String message {get;set;}
		public Boolean success {get;set;}
		public Object obj {get;set;}
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
		public String tooltip;

		public PicklistVal(string api, string label) {
			this.api = api;
			this.label = label;
			this.tooltip = '';
		}
	}

	public class SectorCategoryArdTypesSelector {
		public String sectorName;
		public String sectorLabel;
		public List<CategorySelector> categories;
		public SectorCategoryArdTypesSelector(String sectorName, String sectorLabel) {
			this.sectorName = sectorName;
			this.sectorLabel = sectorLabel;
			this.categories = new List<CategorySelector>();
		}
		public Boolean containsCategory(String category) {
			if (this.categories != null && this.categories.size() > 0) {
				for (CategorySelector currentCategory : categories) {
					if (currentCategory.categoryName.equals(category)) {
						return true;
					}
				}
			}
			return false;
		}
	}
	public class CategorySelector {
		public String categoryName;
		public String categoryLabel;
		public List<String> allowedTypes;
		public CategorySelector(String categoryName, String categoryLabel, List<String> allowedTypes) {
			this.categoryName = categoryName;
			this.categoryLabel = categoryLabel;
			this.allowedTypes = allowedTypes;
		}
	}

	public class CapabilityWrapper {
		public String id;
		public String position;
		public String rtypeId;
		public String category;
		public String equipment;
		public String equipment_label;
		public List<CapabilityFieldsWrapper> fields;

		public CapabilityWrapper() {
		}
	}

	public class CapabilityFieldsWrapper {
		public String field;
		public String value;
		public String label;
		public Boolean required;

		public CapabilityFieldsWrapper() {
		}
	}

	public class AsgmtGroupWrapper implements Comparable {
		final Double defaultOrder = 9999;
		@AuraEnabled
		public Id id;
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String label;
		@AuraEnabled
		public Date expirationDate;
		@AuraEnabled
		public Date issueDate;
		@AuraEnabled
		public String src;
		@AuraEnabled
		public Double order;
		@AuraEnabled
		public String validationProgram;

		public AsgmtGroupWrapper() {
		}

		public Integer compareTo(Object compareTo) {
			AsgmtGroupWrapper asgmtGroupToCompare = (AsgmtGroupWrapper) compareTo;
			if (order == null) {
				this.order = this.defaultOrder;
			}
			if (asgmtGroupToCompare.order == null) {
				asgmtGroupToCompare.order = this.defaultOrder;
			}

			Integer returnValue = 0;
			if (this.order > asgmtGroupToCompare.order) {
				returnValue = 1;
			} else if (this.order < asgmtGroupToCompare.order) {
				returnValue = -1;
			}
			return returnValue;
		}
	}
}