public with sharing class ISSP_EditPortalServiceAccessExt {
	public Portal_Application_Right__c serviceAccess {get;set;}
	public Boolean pendingApproval {get; set;}
	public Boolean noUser {get; set;}
	public Boolean inactiveUser {get; set;}
	public Contact thisContact {get; set;}
	public String contactStatus {get; set;}
	public List<SelectOption> currencyOptions {get; set;}
	public List<SelectOption> mainCurrencyOptions {get; set;}
	public Boolean isTD {get; set;}
	public Boolean showOAG {get; set;}

	public ISSP_EditPortalServiceAccessExt(ApexPages.StandardController controller) {
		showOAG = false;
		isTD = false;
		serviceAccess = (Portal_Application_Right__c)controller.getRecord();
		Map<Id, Portal_Applications__c> portalApplicationsMap = PortalApplicationSelector.selectFunctionalRoleMapByServiceNameSet(new Set<String>{serviceAccess.Application_Name__c});
		String functionalRole = '';
		if(!Test.isRunningTest() && !portalApplicationsMap.isEmpty()) 
			functionalRole = portalApplicationsMap.get(serviceAccess.Portal_Application__c).Functional_Role__c;
		pendingApproval = false;
		noUser = false;
		inactiveUser = false;
		currencyOptions = new List<SelectOption>();
		mainCurrencyOptions = new List<SelectOption>();
		if (serviceAccess.Contact__c != null){
			List <Contact> contactList = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Id = :serviceAccess.Contact__c];
			if (!contactList.isEmpty()){
				thisContact = contactList[0];
				contactStatus = thisContact.User_Portal_Status__c;
				if (thisContact.User_Portal_Status__c == 'Pending Approval'){
					pendingApproval = true;
				}
				else if (thisContact.User_Portal_Status__c == 'Inactive'
						|| thisContact.User_Portal_Status__c == 'Rejected'
						|| thisContact.User_Portal_Status__c == 'Deactivated'){
			inactiveUser = true;
				}
				else{
					List <User> userList = [SELECT Id, IsActive FROM User WHERE ContactId = :thisContact.Id];
					if (userList.isEmpty()){
						noUser = true;
					}
				}
			}
		}
		if (serviceAccess.Portal_Application__c != null){
			if (serviceAccess.Application_Name__c != null){
				if (functionalRole.equals('Airport IS'))
					showOAG = true;
				if (serviceAccess.Application_Name__c.contains('Treasury Dashboard')){
					isTD = true;
					List <ISSP_TD_Currencies__c> currencyList = [SELECT Id, Name, Currency_Label__c FROM ISSP_TD_Currencies__c ORDER BY Name];

					List<SelectOption> options = new List<SelectOption>();
					List<SelectOption> mainOptions = new List<SelectOption>();

					for (ISSP_TD_Currencies__c a : currencyList)
					{
				options.add(new SelectOption(a.Name, a.Name + ' - ' + a.Currency_Label__c));
				if (a.Name == 'USD' || a.Name == 'EUR'){
					mainOptions.add(new SelectOption(a.Name, a.Name + ' - ' + a.Currency_Label__c));
				}
					}
					currencyOptions = options;
					mainCurrencyOptions = mainOptions;
				}
			}
		}
	}

	public Pagereference saveUpdate(){
		try{
			upsert serviceAccess;
		}catch (Exception e){
			ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getdmlMessage(0) );
			ApexPages.addMessage(msg);
			return null;
		}
		Pagereference p  = new Pagereference ('/' + serviceAccess.Id );
		p.setredirect(true);
		return p;
	}

	public Pagereference save(){
		try{
			upsert serviceAccess;
		}catch (Exception e){
			ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getdmlMessage(0) );
			ApexPages.addMessage(msg);
			return null;
		}
		if (pendingApproval){
			thisContact.User_Portal_Status__c = 'Approved User';
			update thisContact;
			updateUserProfile(thisContact.Id);
		}
		else if (noUser){
			Set <Id> idSet = new Set <Id>();
			idSet.add(serviceAccess.Contact__c);
			ISSP_ContactList ctrl = new ISSP_ContactList();
			ctrl.processMultiplePortalUserStatusChange(idSet, 'Approved User', 'Active');
		}
		Pagereference p  = new Pagereference ('/' + serviceAccess.Id );
		p.setredirect(true);
		return p;
	}

	@future
	public static void updateUserProfile(String conId){
		string userType = ISSP_Utilities.getContactTypeById(conId);
		string profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get(userType);
		string profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
		List <User> userList = [SELECT Id, IsActive, ProfileId FROM User WHERE ContactId = :conId AND IsActive = true];
		if (!userList.isEmpty()){
			User thisUser = userList[0];
			thisUser.ProfileId = profileId;
			WithoutSharingOperations.updateUser(thisUser);
		}
	}

	@future
	public static void updateUserProfiles(List <String> conIdList){
		string userType = ISSP_Utilities.getContactTypeById(conIdList[0]);
		string profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get(userType);
		string profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
		Set <String> idSet = new Set <String>();
		for (String thisId : conIdList){
			idSet.add(thisId);
		}
		List <User> userList = [SELECT Id, IsActive, ProfileId FROM User WHERE ContactId IN :idSet AND IsActive = true];
		if (!userList.isEmpty()){
			for (User thisUser : userList){
				thisUser.ProfileId = profileId;
			}
			WithoutSharingOperations.updateUserList(userList);
		}
	}
}