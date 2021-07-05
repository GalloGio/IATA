public without sharing class CW_EmailTemplateData {
	public String stationId {get; set;}
	public String notificationId {get; set;}
	public String contactRoleDetailId {get; set;}
	public String orderItemId {get; set;}
	public Boolean isRemove {get;set;}
	public Boolean isToIata {get;set;}
	public Boolean isCompanyAdmin {
		get{
			return stationId != null ? CW_Utilities.getUserRole(stationId) == CW_Utilities.COMPANY_ADMIN : false;
		}
		set;
	}
	List<ICG_Account_Role_Detail__c> station;
	List<ICG_Notification__c> notifications;
	List<ICG_Contact_Role_Detail__c> contactRoleDetail;
	List<OrderItem> orderItem;
	List<User> userRequestor;
	List<Account> accountDetail;
	public Boolean isPurchaseRemoteValidation {get;set;}
	List<ICG_Capability_Assignment_Group__c> ICGCapabilityAssignmentGroups{get; set;}

	public ICG_Notification__c getnotificationDetails(){
		if(notifications == null && notificationId != null){
			notifications = [SELECT Id, Certification_Name__c, Contact_Email__c, Contact_Name__c, Preferable_Audit_Date__c, ICG_Certification__r.Label__c FROM ICG_Notification__c WHERE Id = :notificationId LIMIT 1];
		}
		return listHasValues(notifications) ? notifications[0] : null;
	}

	public ICG_Account_Role_Detail__c getStationDetails(){
		if(station == null && stationId != null){
			station = [SELECT Id, Name, Company_FOR__c, Country_FOR__c, City_FOR__c, Street_Nr_FOR__c, CreatedById, Account_Role__c, Account_Role__r.Account__c, RecordType.DeveloperName, RecordType.Name, Company_Admin_Approver_Rejector__c, LastModifiedById, Reject_Reason__c FROM ICG_Account_Role_Detail__c WHERE Id = :stationId LIMIT 1];
		} 
		return listHasValues(station) ? station[0] : null;
	}

 
	public ICG_Contact_Role_Detail__c getContactRoleDetails(){
		if(contactRoleDetail == null && contactRoleDetailId != null){
			contactRoleDetail = [SELECT Id, CreatedById, ICG_Account_Role_Detail__c, Contact_Role_Remove_Requestor__c, ContactId__c, ICG_Account_Role_Detail__r.Account_Role__r.Account__c, Account_Role__r.Account__c, Company_Admin_Approver_Rejector__c, LastModifiedById, Reject_Reason__c FROM ICG_Contact_Role_Detail__c WHERE Id = :contactRoleDetailId LIMIT 1];
		} 
		return listHasValues(contactRoleDetail) ? contactRoleDetail[0] : null;
	}

	public List<ICG_Capability_Assignment_Group__c> getICGCapabilityAssignmentGroups(){
		if(ICGCapabilityAssignmentGroups == null && stationId != null){
			ICGCapabilityAssignmentGroups = new List<ICG_Capability_Assignment_Group__c>([SELECT Id, ICG_Certification__r.Name, ICG_Certification__r.Label__c, toLabel(CEIV_Scope_List__c), SFOC_Scope__c, CreatedDate FROM ICG_Capability_Assignment_Group__c WHERE ICG_Account_Role_Detail__c = :stationId AND ICG_Certification__c != null]);
		} 
		return listHasValues(ICGCapabilityAssignmentGroups) ? ICGCapabilityAssignmentGroups : new List<ICG_Capability_Assignment_Group__c>();
	}


	public OrderItem getOrderItemDetails(){
		if(orderItem == null && orderItemId != null){
			orderItem = [SELECT Id, OrderId, (Select Id FROM ICG_Capability_Assignment_Groups__r), CreatedById FROM OrderItem where Id =:orderItemId];
		} 
		return listHasValues(orderItem) ? orderItem[0] : null;
	}

	public Order getOrderDetails(){
		Order orderDetails;
		if(orderItem == null && orderItemId != null){
			orderDetails = [SELECT Id, OrderNumber FROM Order where Id =:getOrderItemDetails().OrderId LIMIT 1];
		} 
		return orderDetails;
	}


	public List<ICG_Contact_Role_Detail__c> getStationManagersContactRoleDetails(){
		return (stationId != null) ? CW_Utilities.getStationManagersContactRoleDetails(stationId) : new List<ICG_Contact_Role_Detail__c>();
	}

	public User getRequestedBy()
	{
		if(userRequestor == null){
			String requestorId;
			if(getContactRoleDetails() != null){
				requestorId = contactRoleDetail[0].Contact_Role_Remove_Requestor__c != null ? contactRoleDetail[0].Contact_Role_Remove_Requestor__c : contactRoleDetail[0].CreatedById;
			}
			else if(getOrderItemDetails() != null){
				requestorId = orderItem[0].CreatedById;
			}
			else if (getStationDetails() != null){
				requestorId = station[0].CreatedById;
			}

			userRequestor = queryUserById(requestorId);
		}
		
		return listHasValues(userRequestor) ? userRequestor[0] : null;
	}

	public String getRequestedByCompanyAddress()
	{
		String address='';
		User u = getRequestedBy();
		if (u != null){
			address = buildAddress(u);
		}

		return address;
	}

	public Account getAccountDetail()
	{
		if (getStationDetails() != null){
			accountDetail = [SELECT Id, TradeName__c,Legal_name__c,Phone,Email__c,Website, Category__c, Sector__c FROM Account WHERE Id = :station[0].Account_Role__r.Account__c LIMIT 1];
		}
		return listHasValues(accountDetail) ? accountDetail[0] : null;
	}

	public String getCommunityUrl(){
		return CW_Utilities.getCommunityUrlBase();
	}

	public String getCommunityUrlForResources(){
		return CW_Utilities.getCommunityUrlBase().removeEnd('s/');
	}

	public String getPrivateAreaUrl(){
		return CW_Utilities.getURLPage('URL_ICG_PrivateArea');
	}

	public String getFacilityPageUrl(){
		return CW_Utilities.getURLPage('URL_ICG_FacilityPage');
	}

	public String getOperationalHierarchyFromStation(){
		String opsHierarchy = getStationDetails() != null ? CW_Utilities.getOpsHierarchyNameFromStationId(station[0].Id) : 'N/A';
		return opsHierarchy;
	}

	public String getOperationalHierarchyFromCrd(){
		String opsHierarchy = 'N/A';
		if(getContactRoleDetails() != null){
			if(contactRoleDetail[0].ICG_Account_Role_Detail__c != null){
				return CW_Utilities.getOpsHierarchyNameFromStationId(contactRoleDetail[0].ICG_Account_Role_Detail__c);
			} 
			else if (contactRoleDetail[0].Account_Role__c != null) {
				return CW_Utilities.getOpsHierarchyNameFromAccountId(contactRoleDetail[0].Account_Role__r.Account__c);
			} 
		}
		return opsHierarchy;
	}

	public String getOperationalHierarchyFromCrdOrStation(){
		if(getOperationalHierarchyFromCrd() != 'N/A'){
			return getOperationalHierarchyFromCrd();
		}
		else {
			return getOperationalHierarchyFromStation();
		}
	}

	public String getOperationalHierarchyFromRequestor(){
		String opsHierarchy = getRequestedBy() != null ? CW_Utilities.getOpsHierarchyNameFromUserId(getRequestedBy().Id) : 'N/A';
		return opsHierarchy;
	}

	public String getOperationalHierarchyGroupFromRequestor(){
		String opsHierarchy = getRequestedBy() != null ? CW_Utilities.getOpsHierarchyGroupFromUserId(getRequestedBy().Id) : 'N/A';
		return opsHierarchy;
	}

	public List<ICG_Account_Role_Detail__c> getDuplicatedStations(){
		List<ICG_Account_Role_Detail__c> duplicatedStations;
		if (getStationDetails() != null){
			duplicatedStations = [SELECT Name, Status__c FROM ICG_Account_Role_Detail__c WHERE RecordType.DeveloperName =:station[0].RecordType.DeveloperName and Account_Role__c =:station[0].Account_Role__c and Id !=:station[0].Id];
		}
		return listHasValues(duplicatedStations) ? duplicatedStations : null;
	}

	private Boolean listHasValues(List<Object> listToCheck){
		return listToCheck != null && !listToCheck.isEmpty();
	}

	public String getApproveUrl(){
		String approveUrl = getPrivateAreaUrl();        
		if (isRemove == true){
			if(getContactRoleDetails() != null){
				approveUrl += '?approveRemoveContactRole='+contactRoleDetail[0].Id;
			}
		}else{
			if(getContactRoleDetails() != null){
				approveUrl += '?approveContactRole='+contactRoleDetail[0].Id;
			}
			else if (getStationDetails() != null){
				approveUrl += '?approveStation='+station[0].Id;
			}
		}
		return approveUrl;
	}

	public String getApprovalUrl(){		
		String approvalUrl = getPrivateAreaUrl(); 
		if(getContactRoleDetails() != null){
			approvalUrl += '#Pending%20User%20Approvals';
		}
		else if (getStationDetails() != null){
			approvalUrl += '#Pending%20Facility%20Approvals';
		}
		return approvalUrl;
	}

	public Contact getContactRoleDetailContact(){

		List<Contact> crdContact;
		if(getContactRoleDetails() != null){
			crdContact = queryContactById(contactRoleDetail[0].ContactId__c);
		}

		return listHasValues(crdContact) ? crdContact[0] : null;
	}
	
	public String getContactRoleDetailContactAccountAddress(){
		String address='';
		Contact c = getContactRoleDetailContact();
		if ( c != null){
		   address = buildAddress(c);
		}

		return address;
	}

	public String getRejectUrl(){
		String rejectUrl = getPrivateAreaUrl();

		if (isRemove == true){
			if(getContactRoleDetails() != null){
				rejectUrl += '?rejectRemoveContactRole='+contactRoleDetail[0].Id;
			}
		}else{
			if(getContactRoleDetails() != null){
				rejectUrl += '?rejectContactRole='+contactRoleDetail[0].Id;
			}
			else if (getStationDetails() != null){
				rejectUrl += '?rejectStation='+station[0].Id;
			}
		}

		return rejectUrl;
	}

	public String getStationUrl(){
		String url = isToIata == true ? CW_Utilities.getEnvironmentVariables().InternalRequestURL__c : getPrivateAreaUrl() + '/#ID:';
		if (getStationDetails() != null){
			url += String.valueOf(station[0].Id);
		}
		
		return url;
	}

	public String getPublicStationUrl(){
		String url = getFacilityPageUrl();
		if (getStationDetails() != null){
			url += '?eid='+station[0].Id;
		}
		return url;
	}

	public String getManageCompanyAdminsUrl(){
		String url = getPrivateAreaUrl();
		url += '#Company%20Admins';
		return url;
	}

	public String getIataManageRequest(){
		ICG_Environment_Variables__c environmentVariables = CW_Utilities.getEnvironmentVariables();
		String manageRequestUrl = environmentVariables.InternalRequestURL__c;
		if(getContactRoleDetails() != null){
			manageRequestUrl += String.valueOf(contactRoleDetail[0].Id);
		}
		else if (getStationDetails() != null){
			manageRequestUrl += String.valueOf(station[0].Id);
		}

		return manageRequestUrl;
	}

	public List<Contact> getCompanyAdminContacts(){
		if(contactRoleDetailId != null && getContactRoleDetails() != null){
			return contactRoleDetail[0].ICG_Account_Role_Detail__c != null ? CW_Utilities.getCompanyAdminContactsFromAccountId(contactRoleDetail[0].ICG_Account_Role_Detail__r.Account_Role__r.Account__c) : CW_Utilities.getCompanyAdminContactsFromAccountId(contactRoleDetail[0].Account_Role__r.Account__c);
		} 
		else if(stationId != null && getStationDetails() != null){
			return CW_Utilities.getCompanyAdminContactsFromAccountId(station[0].Account_Role__r.Account__c);
		} 
		else{
			return new List<Contact>();
		} 
	}
	
	public User getApprover (){
		List<User> approver;
		String approverId;
		if(getContactRoleDetails() != null){
			approverId = contactRoleDetail[0].Company_Admin_Approver_Rejector__c != null ? contactRoleDetail[0].Company_Admin_Approver_Rejector__c : contactRoleDetail[0].LastModifiedById;
		}
		else if (getStationDetails() != null){
			approverId = station[0].Company_Admin_Approver_Rejector__c != null ? station[0].Company_Admin_Approver_Rejector__c : station[0].LastModifiedById;
		}

		if(approverId != null){
			approver = queryUserById(approverId);
		}
		
		return listHasValues(approver) ? approver[0] : null;
	}

	public String getRejectReason (){
		String rejectReason;

		if(getContactRoleDetails() != null){
			rejectReason = contactRoleDetail[0].Reject_Reason__c != null ? contactRoleDetail[0].Reject_Reason__c : 'No Reason Provided';
		}
		else if (getStationDetails() != null){
			rejectReason = station[0].Reject_Reason__c != null ? station[0].Reject_Reason__c : 'No Reason Provided';
		}
		
		return rejectReason;
	}

	public String getApproverAddress()
	{
		String address='';
		User u = getApprover();
		if ( u != null){
		   address = buildAddress(u);
		}

		return address;
	}

	public String getContactRoleDetailUserAddress(){
		String address='';
		Contact c = getContactRoleDetailContact();
		if ( c != null){
			address = buildAddress(c);
		}

		return address;
	}

	public String getApproverOpsHierarchy()
	{
		String opsHierarchy='';
		User u = getApprover();
		if ( u != null && u.accountId != null){
			opsHierarchy = CW_Utilities.getOpsHierarchyNameFromAccountId(u.accountId);
		}

		return opsHierarchy; 
	}

	public String buildAddress(Object userOrContact){
		User u = userOrContact instanceOf User ? (User)userOrContact : null;
		Contact c = userOrContact instanceOf Contact ? (Contact)userOrContact : null;

		String address='';
		if( (u!= null && u.AccountId != null) || (c!= null && c.AccountId != null)){
			address += u!= null ? u.Account.Business_Street__c : c.Account.Business_Street__c;
			if(address != ''){
				address+=', ';
			}
			address += u!= null ? u.Account.Business_Postal_Code__c : c.Account.Business_Postal_Code__c;
			if(address != '' && !address.endsWith(', ')){
				address+=', ';
			}
			if(u != null){
				address +=  u.Account.Business_City__c != null ? u.Account.Business_City__r.Name : u.Account.Business_City_Name__c;
			}else{
				address +=  c.Account.Business_City__c != null ? c.Account.Business_City__r.Name : c.Account.Business_City_Name__c;
			}

			if(address != '' && !address.endsWith(', ')){
				address+=', ';
			}
			address += u!= null ? u.Account.IATA_ISO_Country__r.Name : c.Account.IATA_ISO_Country__r.Name;
			address = address.replaceAll('null, ','');
		}
		return address;
	}

	public String getRemoteValidationLink(){
		if(isPurchaseRemoteValidation == true){
			return getPurchaseRemoteValidationLink();
		} 
		else{
			return getOpenRemoteValidationAreaUrl();
		}
	}

	public String getOpenRemoteValidationAreaUrl(){
		return getPrivateAreaUrl() + '#Open%20Remote%20Validations';
	}

	public String getPurchaseRemoteValidationLink(){
		return getPrivateAreaUrl() + '#Purchase%20Remote%20Validation';
	}

	public String getScheduleAuditsUrl(){
		return getPrivateAreaUrl() + '#Schedule%20Audits';
	}

	public String getAccountToApproveUrl(){
		ICG_Environment_Variables__c environmentVariables = CW_Utilities.getEnvironmentVariables();
		String accountToApproveUrl = environmentVariables.InternalRequestURL__c;

		if (getStationDetails() != null){
			accountToApproveUrl += getAccountDetail() != null ? getAccountDetail().Id : ''; 
		}

		return accountToApproveUrl;
	}
	
	public List<User> queryUserById(String id){
		return [SELECT FirstName, LastName, Name, Email, Account.Name, AccountId, Account.Business_Street__c, Account.Business_Postal_Code__c, Account.Business_City__c, Account.Business_City__r.Name, Account.Business_City_Name__c, Account.IATA_ISO_Country__r.Name FROM User WHERE Id = :id LIMIT 1];
	}

	public List<Contact> queryContactById(String id){
		return [SELECT FirstName, LastName, Name, Email, Account.Name, AccountId, Account.Business_Street__c, Account.Business_Postal_Code__c, Account.Business_City__c, Account.Business_City__r.Name, Account.Business_City_Name__c, Account.IATA_ISO_Country__r.Name FROM Contact WHERE Id = :id LIMIT 1];
	}

}