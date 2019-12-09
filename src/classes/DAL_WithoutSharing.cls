public without sharing class DAL_WithoutSharing {

private static Id USERID = Userinfo.getUserId();

@AuraEnabled(cacheable=false)
public static String performCheckonPoll(String permSetSSO, Integer failedCount){
	List<PermissionSetAssignment> permissionSetList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: USERID AND PermissionSetId IN (select id from PermissionSet Where name =: permSetSSO)];

	if(!permissionSetList.isEmpty()) {
		return 'Success';
	} else {
		List<UserProvisioningRequest> userProvisioningList = [SELECT id FROM UserProvisioningRequest WHERE SalesforceUserId =: USERID AND State = 'Failed'];
		if(userProvisioningList.size() != failedCount) {
			return 'Error';
		}
	}
	return 'Incomplete';
}

@AuraEnabled(cacheable=true)
public static Map<String, String> getUserOptions(String portalUser){

	Map<String,String> userOptions = new Map<String,String>();

	List<User> userContactAccountOptions = [SELECT id, Contact.Account.ANG_IEP_Status_FF__c, Contact.Authorized_Signatory__c,
	                                        Contact.User_Portal_Status__c, ContactId, Contact.Account.ICCS_Membership_Status__c,
	                                        Contact.Account.Top_Parent__r.ICCS_Membership_Status__c, Contact.Account.Top_Parent__c
	                                        FROM User WHERE Id =:portalUser];

	if(!userContactAccountOptions.isEmpty()) {
		for(User u : userContactAccountOptions) {
			if(u.Contact.Account.ANG_IEP_Status_FF__c != null) {
				userOptions.put('IEP_Status', u.Contact.Account.ANG_IEP_Status_FF__c);
			}
			if(u.Contact.Authorized_Signatory__c != null) {
				userOptions.put('Legal_Auth_Signature', String.valueOf(u.Contact.Authorized_Signatory__c));
			}
			if(u.Contact.User_Portal_Status__c != null  && u.Contact.User_Portal_Status__c != '') {
				userOptions.put('User_Portal_Status', u.Contact.User_Portal_Status__c);
			}
			if(u.ContactId != null) {
				userOptions.put('User_ContactId', u.ContactId);
			}
			if(u.Contact.Account.Top_Parent__c != null) {
				userOptions.put('User_ICCS_Membership_Status', u.Contact.Account.Top_Parent__r.ICCS_Membership_Status__c);
			}
			else{
				userOptions.put('User_ICCS_Membership_Status', u.Contact.Account.ICCS_Membership_Status__c);
			}
		}
	}
	return userOptions;
}

	/*
	* Used in portal company profile contacts list
	* Search for either a specific contact name or nothing.
	* Currently pagination is beeing done at the component side.
	*/
	public static CSP_Utils.PagedResult searchForCompanyContacts(String companybranchFilterWrapper, Integer requestedPage, Integer batchSize, Id accountId){
        PortalProfileCtrl.CompanyInformationContactsFiltersWrapper filtersWrapper = (PortalProfileCtrl.CompanyInformationContactsFiltersWrapper) JSON.deserialize(companybranchFilterWrapper, PortalProfileCtrl.CompanyInformationContactsFiltersWrapper.class);

		//Fetch all account branches/HQs to return a complete hierarchy of account's contacts.
		Map<Id,Account> allBranches = new Map<Id,Account>([select id from account where (id =: accountId or parentId=: accountId or top_parent__c =: accountId)
			and (Status__c NOT IN ('Terminated','Not accredited', 'No longer a customer'))]);
		Set<Id> allBranchesSet = allBranches.keySet();

        String baseQuery = 'SELECT Id, Name, FirstName, LastName, Title, Email, Phone, Fax, OtherPhone,Type_of_Contact__c, ' +
								'OtherCity, OtherStreet, OtherState,OtherPostalCode, OtherCountry, Function__c, Membership_Function__c, ' +
								'User_Portal_Status__c, MobilePhone, Preferred_Language__c,Salutation,Airline_Contact_Type__c, Services__c, ' +
								'Area__c,AccountId, Account.Name,IATA_Code__c,Account.Location_Type__c,Account.IATA_ISO_Country__r.Name, ' +
								'Account.RecordTypeId,Account.RecordType.Name ' + 
								'FROM Contact ';
        /*String baseQueryCount = 'SELECT COUNT() ' + 
                                'FROM Contact ';*/
		String conditionsQuery = 'WHERE AccountId IN :allBranchesSet ' + 
								 'AND User_Portal_Status__c IN (\'Pending Approval\', \'Approved Admin\', \'Approved User\') ' + 
								 'AND Status__c = \'Active\' ';

        

        if(filtersWrapper != null) {
            // evaluate filter if they exist 
            if(!String.isBlank(filtersWrapper.searchInput)){
                String searchText = '%' + String.escapeSingleQuotes(filtersWrapper.searchInput) + '%';
                conditionsQuery += ' AND (FirstName LIKE \'' + searchText + '\' OR LastName LIKE \'' + searchText + '\' OR Name LIKE \'' + searchText + '\' OR Email LIKE \'' + searchText + '\' OR Name LIKE \'' + searchText + '\' ) ';
            }

			if(!String.isBlank(filtersWrapper.firstLetter)){
                String searchText = String.escapeSingleQuotes(filtersWrapper.firstLetter) + '%';
                //conditionsQuery += ' AND (FirstName LIKE \'' + searchText + '\' ) ';

				if (filtersWrapper.firstLetter != 'All' && filtersWrapper.firstLetter != 'Other'){
					conditionsQuery += ' AND Name like \'' + String.escapeSingleQuotes(filtersWrapper.firstLetter) + '%\' ';
				}
                else if (filtersWrapper.firstLetter == 'Other'){
					conditionsQuery += ' AND (Name < \'A\' OR Name > \'Z\') AND (NOT Name LIKE \'Z%\') ';
				}
            }
        }

        String orderQuery = ''; 
        if(requestedPage == 0){ //just for the first time
            orderQuery = ' ORDER BY ' + filtersWrapper.sortField + ' ' + filtersWrapper.sortDirection + ' ';
        }

        //pagination 
        /*Integer offset = requestedPage * batchSize;
        String offsetQuery = ' LIMIT ' + batchSize + ' OFFSET ' + offset + ' ';*/ 

        CSP_Utils.PagedResult pageResult = new CSP_Utils.PagedResult();
	    pageResult.records = Database.query(baseQuery + conditionsQuery + orderQuery /*+ offsetQuery*/);
        /*if(requestedPage == 0){
            //first page -> get total count
            pageResult.totalItemCount = Database.countQuery(baseQueryCount + conditionsQuery);
        }*/

        return pageResult;
    }

	@AuraEnabled
    public static List<Account> getRelatedAccounts(String finalQuery){

	    return Database.query(finalQuery);
    }

	//returns user Information wihtout visibility control
	@AuraEnabled
	public static user getUserDetails(Id userId){
		return [select id,userRoleId, UserRole.Name from user where id=:userId];
	}

	@AuraEnabled
	public static void ActivateIEPUsers(List<String> contactIds){
	
		List<User> usersList = [select id, isActive, contactId from User where contactId in : contactIds];
		if(!usersList.isEmpty()) {
			List<User> usersToActivate = new List<User>();
	
			for(User user : usersList) {
				if(!user.isActive) {
					user.isActive = true;
					usersToActivate.add(user);
				}
			}
	
			if(usersToActivate.size() != 0) {
				update usersToActivate;
			}
		}
	
	}

	/* 
    * @description Return if a specific user has Access to a specific service
    * @return boolean 
    */
	
    @AuraEnabled
    public static Boolean hasAccessToService(string str,string conId) {       
		if(conId==null) conId=CSP_Utils.getLoggedUser().contactId; // if conId, checks current user
        return [select id from Portal_Application_Right__c where Contact__c =:conId and Right__c ='Access Granted' and Application_Name__c like :str limit 1].size()>0;
    }
	
	@AuraEnabled
    public static ReturnWrapper submitNewMessage(String caseId, String messageTextAux){
        ReturnWrapper returnWrapper = new ReturnWrapper();
        Savepoint sp = Database.setSavepoint();
        Case caseAux = new Case();
        caseAux.Id = caseId;
        caseAux.New_interaction__c = 'New Comment';
        caseAux.New_Comment_From_Connection_User__c = true;
        CaseComment caseCommentAux = new CaseComment();
        caseCommentAux.ParentId = caseId;
        caseCommentAux.CommentBody = messageTextAux;

        try{
            insert caseCommentAux;
            update caseAux;
            returnWrapper = new ReturnWrapper(true, Label.CSP_CaseMessage_SubmitSuccess, ''); 
        }catch(Exception e){
            Database.rollback(sp);
            returnWrapper = new ReturnWrapper(false, e.getMessage(), '');
        }

        return returnWrapper;
    }

/*
	 * @description Returns list of Contacts and Accounts for Profile Search
	 * @return List of List of SObjects (Accounts and Contacts)
	 */
	@AuraEnabled(cacheable=false)
	public static CSP_Utils.PagedResult getSearchProfiles(String portalSearchFilterWrapper, Contact myContact) {
		PortalSearchFilterWrapper profileFiltersWrapper = (PortalSearchFilterWrapper) JSON.deserialize(portalSearchFilterWrapper, PortalSearchFilterWrapper.class);
		CSP_Utils.PagedResult result = new CSP_Utils.PagedResult();
		List<PortalProfileCtrl.ProfileWrapper> lstProfileWrapper = new List<PortalProfileCtrl.ProfileWrapper>();

		String searchStr = String.escapeSingleQuotes(profileFiltersWrapper.searchText);
		String wildCardStr = '%'+searchStr+'%';

		String baseQueryContacts = 'SELECT ID, Name, User_Portal_Status__c, ISO_Country__r.Name, Email, Account.BillingCountry, Account.Country_ISO_Code__c FROM Contact ';
		String baseQueryAccounts = 'SELECT ID, Name, IATA_ISO_Country__r.Name, Country_ISO_Code__c FROM Account ';
		String countryPortalStatusFilter = '';
		String countryFilter = '';
		Boolean isAdmin = CSP_Utils.isAdmin();

		List<AccountTeamMember> test = PortalServicesCtrl.getPortalAdmins();

		Set<Id> myContactsIDs = new Set<Id>();

		for(AccountTeamMember t : test) {
			myContactsIDs.add(t.User.ContactId);
		}

		List<SObject> resultsContacts = new List<SObject>();
		List<SObject> resultsAccounts = new List<SObject>();

		Map<Id,Account> allBranches = new Map<Id,Account>([select id from account where (id =: myContact.AccountId or parentId=: myContact.AccountId or top_parent__c =: myContact.AccountId)
		                                                   and (Status__c NOT IN ('Terminated','Not accredited', 'No longer a customer'))]);
		Set<Id> allBranchesSet = allBranches.keySet();

		if(isAdmin) {
			baseQueryContacts += ' WHERE (((Name Like \''+ wildCardStr + '\' OR Email Like \''+ wildCardStr + '\' OR Account.BillingCountry Like \''+ wildCardStr + '\' ) ' +
			                     ' AND User_Portal_Status__c IN (\'Pending Approval\', \'Approved Admin\', \'Approved User\') ' +
			                     ' AND Status__c = \'Active\' AND AccountId IN :allBranchesSet ) OR ' +
			                     ' ((Name Like \''+ wildCardStr + '\' OR Email Like \''+ wildCardStr + '\' OR Account.BillingCountry Like \''+ wildCardStr + '\' ) ' +
			                     ' AND ID IN :myContactsIDs '+
			                     ' AND User_Portal_Status__c = \'Approved Admin\' ' +
			                     ' AND Status__c = \'Active\' )) ';
		}else{
			baseQueryContacts += ' WHERE (Name Like \''+ wildCardStr + '\' OR Email Like \''+ wildCardStr + '\' OR Account.BillingCountry Like \''+ wildCardStr + '\' ) ' +
			                     ' AND ID IN :myContactsIDs'+
			                     ' AND User_Portal_Status__c = \'Approved Admin\' ' +
			                     ' AND Status__c = \'Active\' ';
		}

		baseQueryAccounts += ' WHERE (Name Like \''+ wildCardStr + '\' OR IATA_ISO_Country__r.Name Like \''+ wildCardStr + '\' ) ' +
		                     ' AND (Id = \'' + myContact.AccountId + '\' OR ParentId = \'' +
		                     +myContact.AccountId + '\' OR Top_Parent__c = \'' + myContact.AccountId +'\' ) ';


		if(profileFiltersWrapper.profileComponent.profileCountryFilter != null && profileFiltersWrapper.profileComponent.profileCountryFilter != '') {
			baseQueryContacts += ' AND Account.Country_ISO_Code__c = \'' + profileFiltersWrapper.profileComponent.profileCountryFilter + '\' ';
			baseQueryAccounts += ' AND Country_ISO_Code__c = \'' + profileFiltersWrapper.profileComponent.profileCountryFilter + '\' ';
		}

		if(profileFiltersWrapper.profileComponent.profileStatusFilter != null && profileFiltersWrapper.profileComponent.profileStatusFilter != '') {
			baseQueryContacts += ' AND User_Portal_Status__c = \'' + profileFiltersWrapper.profileComponent.profileStatusFilter + '\' ';
		}

		if (profileFiltersWrapper.profileComponent != null && profileFiltersWrapper.profileComponent.profileTypeFilter != null && profileFiltersWrapper.profileComponent.profileTypeFilter != 'Account') {
			resultsContacts = Database.query(baseQueryContacts);
		}

		if (profileFiltersWrapper.profileComponent != null && profileFiltersWrapper.profileComponent.profileTypeFilter != null && profileFiltersWrapper.profileComponent.profileTypeFilter != 'Contact') {
			resultsAccounts = Database.query(baseQueryAccounts);
		}

		List<List<SObject> > lstListResults = new List<List<SObject> > {resultsContacts,resultsAccounts};

		if(!lstListResults.isEmpty()) {
			result.totalItemCount = lstListResults.size() == 2 ? lstListResults[0].size() + lstListResults[1].size() : lstListResults[0].size();

			for(List<SObject> listfilteredProfiles : lstListResults) {
				for(SObject eachFilteredProfileResult : listfilteredProfiles) {
					if(eachFilteredProfileResult.getSObjectType() == Schema.Contact.getSObjectType()) {
						Contact eachProfileResult = (Contact)eachFilteredProfileResult;
						if (isAdmin || (!isAdmin && eachProfileResult.User_Portal_Status__c == 'Approved Admin')) {
							lstProfileWrapper.add(new PortalProfileCtrl.ProfileWrapper(eachProfileResult.Id,
							                                                           eachProfileResult.Name,
							                                                           eachProfileResult.User_Portal_Status__c,
							                                                           eachProfileResult.ISO_Country__r.Name == null ?
							                                                           (eachProfileResult.Account.BillingCountry == null ? '' :
							                                                            eachProfileResult.Account.BillingCountry) :
							                                                           eachProfileResult.ISO_Country__r.Name, 'Contact' ));
						}
					}
					else if(eachFilteredProfileResult.getSObjectType() == Schema.Account.getSObjectType()) {
						Account eachProfileResult = (Account)eachFilteredProfileResult;
						lstProfileWrapper.add(new PortalProfileCtrl.ProfileWrapper(eachProfileResult.Id,eachProfileResult.Name,'',eachProfileResult.IATA_ISO_Country__r.Name == null ? '' : eachProfileResult.IATA_ISO_Country__r.Name, 'Account'));
					}
				}
			}
			result.recordsString = JSON.Serialize(lstProfileWrapper);
		}

		return result;
	}
}
