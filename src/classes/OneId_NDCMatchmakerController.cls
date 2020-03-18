public without sharing class OneId_NDCMatchmakerController {

	@AuraEnabled
	public static UserInformation initialize(){
		UserInformation info = getUserInfo();
		return info;
	}

	@AuraEnabled
	public static UserInformation getUserInfo(){
		// Retrieve user information
		UserInformation info = new UserInformation();

		// Step 1 : check if this is a guest user
		info.isGuestUser = [SELECT count()
							FROM User
							WHERE Name = 'identity Site Guest User'
							AND Id =: UserInfo.getUserId()] == 1;

		// if guest user, we can stop here
		if(info.isGuestUser){
			return info;
		}

		// Step 2 : check if user requested access to NDC Matchmaker Service

		// Step 2.1 : Retrieve the NDC Matchmaker Portal Service Id
		One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__r.Id
														  FROM One_Id_Service_Provider_Config__c
														  WHERE Service_Provider_Name__c = 'NDCMM'
														  AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];

		// Step 2.2 : Retrieve the Contact Id
		User usr = [SELECT AccountId, ContactId
					FROM User
					WHERE Id =: UserInfo.getUserId()];

		// Step 2.3 : Retrieve the Portal Service Access record
		List<Portal_Application_Right__c> portalApplicationRights = [SELECT Right__c, Access_Pending_Detail__c
																	 FROM Portal_Application_Right__c
																	 WHERE Portal_Application__c =: oneIdService.Portal_Service__r.Id
																	 AND Contact__c =: usr.ContactId];

		info.accessRequested = !portalApplicationRights.isEmpty();

		// if access has not been requested yet, we can stop here
		if(!info.accessRequested){
			return info;
		}

		// Step 3 : check the request access to NDC Matchmaker Service status
		info.accessStatus = portalApplicationRights[0].Right__c;

		// if Status is Pending, we can stop here
		if(info.accessStatus == 'Pending'){
			info.pendingAccessReason = portalApplicationRights[0].Access_Pending_Detail__c;
			return info;
		}

		// if Status is not Access Granted, we can stop here
		if(info.accessStatus != 'Access Granted'){
			return info;
		}

		// Step 4 : check if the user accepted the latest terms and conditions
		try{
			// Step 4.1 : retrieve the latest steps and conditions record
			Term_And_Condition__c latest = TermAndConditionUtils.getPortalServiceLatestTC(oneIdService.Portal_Service__c);

			if(latest == null){
				info.exceptionTC = 'Latest terms & Conditions couldn\'t be find';
				return info;
			}

			info.tcDocumentId = latest.T_C_Id__c;

			// Step 4.2 : Check if there is a Term And Condition Acceptance record
			List<Term_And_Condition_Acceptance__c> tcAcceptanceList = [SELECT Is_Accepted__c
																	   FROM Term_And_Condition_Acceptance__c
																	   WHERE Term_Condition__c =: latest.Id
																	   AND Contact__c =: usr.ContactId];

			// if T&C Acceptance record doesn't exists, we create one
			if(tcAcceptanceList.isEmpty()){
				info.tcAcceptance = new Term_And_Condition_Acceptance__c(
					Term_Condition__c = latest.Id,
					Contact__c = usr.ContactId,
					Is_Accepted__c = false
				);
				return info;
			}
			// Otherwise, we use the existing one (might be not accepted)
			else{
				info.tcAcceptance = tcAcceptanceList[0];
			}
			info.exceptionTC = '';
		}
		catch(TermAndConditionUtils.TermAndConditionException e){
			info.exceptionTC = e.getMessage();
		}

		info.usr = getUser();
		info.ndcCapabilities = getNDCCapabilities(info.usr);

		info.displayRichContentTypes = info.ndcCapabilities.NDC_Rich_Content__c != null && ((String) info.ndcCapabilities.NDC_Rich_Content__c) == 'Yes';
		info.displayTypesOfCCAccepted = info.ndcCapabilities.NDC_Forms_of_Payment_Accepted__c != null && ((String) info.ndcCapabilities.NDC_Forms_of_Payment_Accepted__c).contains('Credit Cards');

		info.ndcCapable = info.ndcCapabilities.NDC_Capable__c;

		return info;
	}

	@AuraEnabled
	public static User getUser(){
		User usr = [SELECT Id,
					AccountId,
					Account.Sector__c,
					Account.Category__c,
					Account.RecordType.DeveloperName,
					Account.Name,
					Account.IATACode__c,
					Account.Website,
					Account.IATA_ISO_Country__r.Name,
					Account.Region_formula__c
					FROM User
					WHERE Id =: UserInfo.getUserId()];
		return usr;
	}

	@AuraEnabled
	public static NDC_Account_Service_Detail__c getNDCCapabilities(User usr){
		Account acc = [SELECT Id, Sector__c, Category__c
					   FROM Account
					   WHERE Id =: usr.AccountId];


		// Step 1: retrieve Account Roles record, based on Account's sector and category
		// The record should exist as this method is called if the user has access to NDC in 1Id
		Account_Roles__c accountsRoles = [SELECT Id
										  FROM Account_Roles__c
										  WHERE Sector__c =: acc.Sector__c
										  AND Category__c =: acc.Category__c
										  LIMIT 1];

		// Step 2: retrieve the Account Role record linked to the Account record and the Account Roles record
		// This one might not exist
		List<Account_Role__c> accountRoleList = [SELECT Id
												 FROM Account_Role__c
												 WHERE Account__c =: usr.AccountId
												 AND Account_Roles__c =: accountsRoles.Id
												 AND RecordType.DeveloperName = 'Default'
												 LIMIT 1];

		Account_Role__c accountRole;
		if(!accountRoleList.isEmpty()){
			accountRole = accountRoleList[0];
		}
		else{
			Id defaultRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');

			accountRole = new Account_Role__c(
				Account__c = usr.AccountId,
				Account_Roles__c = accountsRoles.Id,
				RecordTypeId = defaultRecordTypeId
			);
			insert accountRole;
		}

		// Step 3: retrieve the NDC Portal Service
		// This one should exist as it's admin configuration
		One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c
														  FROM One_Id_Service_Provider_Config__c
														  WHERE Service_Provider_Name__c = 'NDCMM'
														  AND RecordType.DeveloperName = 'Service_Provider'
														  LIMIT 1];

		// Step 4: retrieve the Account Role Services record
		// This one should exist as it's admin configuration
		Account_Role_Services__c accountRoleServices = [SELECT Id
														FROM Account_Role_Services__c
														WHERE Account_Roles__c =: accountsRoles.Id
														AND Portal_Service__c =: oneIdService.Portal_Service__c
														LIMIT 1];

		// Step 5: retrieve the Account Role Service record
		// This one might not exist
		List<Account_Role_Service__c> accountRoleServiceList = [SELECT Id
																FROM Account_Role_Service__c
																WHERE Account_Role__c =: accountRole.Id
																AND Account_Role_Services__c =: accountRoleServices.Id
																LIMIT 1];

		Account_Role_Service__c accountRoleService;
		if(!accountRoleServiceList.isEmpty()){
			accountRoleService = accountRoleServiceList[0];
		}
		else{
			accountRoleService = new Account_Role_Service__c(
				Account_Role__c = accountRole.Id,
				Account_Role_Services__c = accountRoleServices.Id
			);
			insert accountRoleService;
		}

		// Step 6: retrieve the NDC Account Service Detail record
		// This one might not exist
		List<NDC_Account_Service_Detail__c> accountServiceDetails = [SELECT Id, NDC_Capable__c, Company_Type__c, NDC_Rich_Content__c, NDC_Forms_of_Payment_Accepted__c, Submittable_for_Approval__c, Submitted_for_Approval__c
																	 FROM NDC_Account_Service_Detail__c
																	 WHERE Account_Role_Service__c =: accountRoleService.Id LIMIT 1];

		if(!accountServiceDetails.isEmpty()) {
			return accountServiceDetails[0];
		} else {
			NDC_Account_Service_Detail__c newAccountServiceDetails = new NDC_Account_Service_Detail__c(Account_Role_Service__c = accountRoleService.Id, NDC_Capable__c = false, Submittable_for_Approval__c = false, Submitted_for_Approval__c = false);
			insert newAccountServiceDetails;

			NDC_Account_Service_Detail__c newNdcCapabilitiesDetails = [SELECT Id, NDC_Capable__c, Company_Type__c, NDC_Rich_Content__c, NDC_Forms_of_Payment_Accepted__c, Submittable_for_Approval__c, Submitted_for_Approval__c
																	   FROM NDC_Account_Service_Detail__c
																	   WHERE Account_Role_Service__c =: accountRoleService.Id];
			return newNdcCapabilitiesDetails;
		}
	}

	@AuraEnabled
	public static Term_And_Condition_Acceptance__c acceptTermsAndConditions(Term_And_Condition_Acceptance__c tcAcceptance){
		tcAcceptance.Is_Accepted__c = true;
		tcAcceptance.Date_Accepted__c = Date.today();
		upsert tcAcceptance;

		return tcAcceptance;
	}

	@AuraEnabled
	public static Boolean submitCaseForApproval(){
		NDC_Account_Service_Detail__c ndcCapabilities = getNDCCapabilities(getUser());

		ndcCapabilities.Submitted_for_Approval__c = true;
		update ndcCapabilities;

		//Fetching the assignment rules on case
		List<AssignmentRule> arList = [SELECT Id
									   FROM AssignmentRule
									   WHERE SobjectType = 'Case'
									   AND Active = true LIMIT 1];

		//Creating the DMLOptions for "Assign using active assignment rules" checkbox
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		if(arList.size() > 0) {
			dmlOpts.assignmentRuleHeader.assignmentRuleId = arList[0].id;
		}

		User u = [SELECT ContactId
				  FROM User
				  WHERE Id =: UserInfo.getUserId()];
		Contact c = [SELECT Id, Email
					 FROM Contact
					 WHERE Id =: u.ContactId];

		Case cse = new Case();

		try{
			cse.Contact = c;
			cse.Subject = 'NDC Matchmaker - Validate NDC Capability';
			//cse.Description = 'Account';
			cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NDC Management').getRecordTypeId();
			cse.setOptions(dmlOpts);
			cse.Origin = 'NDCMatchmaker';
			insert cse;
			return true;
		}
		catch(Exception e){
			System.debug(e.getMessage());
			return false;
		}
	}

	public class UserInformation{

		@AuraEnabled
		public User usr {get; set;}

		@AuraEnabled
		public Boolean isGuestUser {get; set;}

		@AuraEnabled
		public Boolean accessRequested {get; set;}

		@AuraEnabled
		public String accessStatus {get; set;}

		@AuraEnabled
		public String pendingAccessReason {get; set;}

		@AuraEnabled
		public String tcDocumentId {get;set;}

		@AuraEnabled
		public Boolean tcAccepted {get;set;}

		@AuraEnabled
		public Term_And_Condition_Acceptance__c tcAcceptance {get;set;}

		@AuraEnabled
		public String exceptionTC {get;set;}

		@AuraEnabled
		public NDC_Account_Service_Detail__c ndcCapabilities {get;set;}

		@AuraEnabled
		public Boolean displayRichContentTypes {get;set;}

		@AuraEnabled
		public Boolean displayTypesOfCCAccepted {get;set;}

		@AuraEnabled
		public Boolean ndcCapable {get;set;}
	}
}
