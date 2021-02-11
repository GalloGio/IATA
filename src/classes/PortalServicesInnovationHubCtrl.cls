public without sharing class PortalServicesInnovationHubCtrl {

	private static String IH_ACCOUNT_ROLE_DETAIL = 'IH_Account_Role_Detail__c';
	private static String IH_ACCOUNT_ROLE_DETAILS_STATUS_DRAFT = 'Draft';
	private static String IH_ACCOUNT_ROLE_DETAILS_STATUS_SUBMITTED = 'Submitted';
	private static String IH_ACCOUNT_ROLE_DETAILS_STATUS_APPROVED = 'Approved';
	private static String IH_LOGO_PATH = '/sfc/servlet.shepherd/version/download/';

	private static String accountRoleRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Innovation_Hub');
	private static String accountRoleDetailConsumerRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('IH_Account_Role_Detail__c', 'Consumer');
	private static String accountRoleDetailProviderRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('IH_Account_Role_Detail__c', 'Provider');
	private static String accountRoleDetailConsumerProviderRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('IH_Account_Role_Detail__c', 'Consumer_and_Provider');

	@AuraEnabled (cacheable = false)
	public static PortalWrapperClasses.ListCardsAndPropertiesWrapper getProviderPropertiesAndCardsList(){
		
		PortalWrapperClasses.ListCardsAndPropertiesWrapper propertiesAndLstCards = new PortalWrapperClasses.ListCardsAndPropertiesWrapper();
		propertiesAndLstCards.objectAPIName = IH_ACCOUNT_ROLE_DETAIL;

		Map<String, String> extraDetails = new Map<String, String>();

		//get the provider profile for view 
		IH_Account_Role_Detail__c providerProfileForView = PortalServicesInnovationHubCtrl.getLastestPublishedProviderUserIHAccountRoleDetail();

		if(providerProfileForView != null){
			propertiesAndLstCards.recordId = providerProfileForView.Id;
			propertiesAndLstCards.lstCards = PortalServicesInnovationHubCtrl.getProviderProfileCards();
			propertiesAndLstCards.viewNavigation = true;
			extraDetails.put('viewStatus', 'Published');
		}else{
			extraDetails.put('viewStatus', 'None');
		}

		IH_Account_Role_Detail__c accountRoleDetailsDraft = getUserIHAccountRoleDetailWithStatus(IH_ACCOUNT_ROLE_DETAILS_STATUS_DRAFT);
		extraDetails.put('viewComments', 'No');
		if(accountRoleDetailsDraft != null){
			String viewComments = accountRoleDetailsDraft.Marked_For_Review__c ? 'Yes' : 'No';
			extraDetails.put('viewComments', viewComments);
		}

		//check if there is a submited provider profile
		IH_Account_Role_Detail__c providerProfileSubmitted = getUserIHAccountRoleDetailWithStatus(IH_ACCOUNT_ROLE_DETAILS_STATUS_SUBMITTED);
		if(providerProfileSubmitted != null){
			extraDetails.put('editButtonStatus', IH_ACCOUNT_ROLE_DETAILS_STATUS_SUBMITTED);
		}else{
			extraDetails.put('editButtonStatus', 'None');
		}
		
		propertiesAndLstCards.extraDetails = JSON.Serialize(extraDetails);

		return propertiesAndLstCards;
	}

	private static List<PortalWrapperClasses.CardWrapper> getProviderProfileCards(){
		//stores each card
		List<PortalWrapperClasses.CardWrapper> lstCardWrapper = new List<PortalWrapperClasses.CardWrapper>();

		//COMPANY INFORMATION
		List<PortalWrapperClasses.FieldWrapper> lstfw1 = new List<PortalWrapperClasses.FieldWrapper>();
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_Name__c',true,true));
		PortalWrapperClasses.FieldWrapper logo = new PortalWrapperClasses.FieldWrapper('Logo_File_Id__c',true,false);
		logo.isLogo = true;
		lstfw1.add(logo);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Legal_Name__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Also_Known_As__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_Description__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Location__c',true,true));
		PortalWrapperClasses.FieldWrapper focusAreas = new PortalWrapperClasses.FieldWrapper('Focus_Areas__c',true,false,'',System.Label.CSP_FocusAreas);
		focusAreas.isMultipick = true;
		lstfw1.add(focusAreas);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Founding_Date__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Number_Of_Employees__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_info_of_startup__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_Position__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_Email__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_Phone_Number__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Website__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Facebook__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Instagram__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Twitter__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('LinkedIn__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('GitHub__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Telegram__c',true,true));

		lstCardWrapper.add(new PortalWrapperClasses.CardWrapper('Company Information', lstfw1, false,'Company Information'));

		//SERVICE INFORMATION
		List<PortalWrapperClasses.FieldWrapper> lstfw2 = new List<PortalWrapperClasses.FieldWrapper>();
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Solution__c',true,true));
		PortalWrapperClasses.FieldWrapper technology = new PortalWrapperClasses.FieldWrapper('Technology__c',true,false,'',System.Label.CSP_Technology);
		technology.isMultipick = true;
		lstfw2.add(technology);
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Description__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Industry_Perspectives__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Funding_Amount__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Funding_Stage__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Investors__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Competition_Competitors__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Competitive_Advantage__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Recent_News__c',true,true));
		PortalWrapperClasses.FieldWrapper tagsOfCategories = new PortalWrapperClasses.FieldWrapper('Tags_Of_Categories__c',true,false,'',System.Label.CSP_Categories);
		tagsOfCategories.isMultipick = true;
		lstfw2.add(tagsOfCategories);
		lstCardWrapper.add(new PortalWrapperClasses.CardWrapper('Service Information', lstfw2, false,'Service Information'));

		return lstCardWrapper;
	}

	@AuraEnabled (cacheable = false)
	public static PortalWrapperClasses.ListCardsAndPropertiesWrapper getProviderPropertiesAndEditCardsList(){
	
		PortalWrapperClasses.ListCardsAndPropertiesWrapper propertiesAndLstCards = new PortalWrapperClasses.ListCardsAndPropertiesWrapper();
		propertiesAndLstCards.objectAPIName = IH_ACCOUNT_ROLE_DETAIL;

		Map<String, String> extraDetails = new Map<String, String>();

		//Try to get a draft provider profile
		IH_Account_Role_Detail__c accountRoleDetailsAux = getUserIHAccountRoleDetailWithStatus(IH_ACCOUNT_ROLE_DETAILS_STATUS_DRAFT);
		String profileStatus = IH_ACCOUNT_ROLE_DETAILS_STATUS_DRAFT;

		//if there is no draft, try to get the submitted profile
		if(accountRoleDetailsAux == null){
			accountRoleDetailsAux = getUserIHAccountRoleDetailWithStatus(IH_ACCOUNT_ROLE_DETAILS_STATUS_SUBMITTED);
			profileStatus = IH_ACCOUNT_ROLE_DETAILS_STATUS_SUBMITTED;
		}

		if(accountRoleDetailsAux == null){
			//If there is no draft then get the latest published version
			accountRoleDetailsAux = getLastestPublishedProviderUserIHAccountRoleDetail();
			profileStatus = IH_ACCOUNT_ROLE_DETAILS_STATUS_APPROVED;
		}

		propertiesAndLstCards.recordId = accountRoleDetailsAux.Id;
		if(accountRoleDetailsAux.Status__c == IH_ACCOUNT_ROLE_DETAILS_STATUS_DRAFT){
			String viewComments = accountRoleDetailsAux.Marked_For_Review__c ? 'Yes' : 'No';
			extraDetails.put('viewComments', viewComments);
			extraDetails.put('comments', accountRoleDetailsAux.Internal_comments__c + '');
		}

		propertiesAndLstCards.lstCards = PortalServicesInnovationHubCtrl.getProviderProfileCardsForEdit();
		propertiesAndLstCards.viewNavigation = true;

		extraDetails.put('editStatus', profileStatus);
		propertiesAndLstCards.extraDetails = JSON.Serialize(extraDetails);

		return propertiesAndLstCards;
	}

	private static List<PortalWrapperClasses.CardWrapper> getProviderProfileCardsForEdit(){
		//stores each card
		List<PortalWrapperClasses.CardWrapper> lstCardWrapper = new List<PortalWrapperClasses.CardWrapper>();

		//COMPANY INFORMATION
		List<PortalWrapperClasses.FieldWrapper> lstfw1 = new List<PortalWrapperClasses.FieldWrapper>();
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_Name__c',true,true));
		PortalWrapperClasses.FieldWrapper logo = new PortalWrapperClasses.FieldWrapper('Logo_File_Id__c',true,false);
		logo.isLogo = true;
		lstfw1.add(logo);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Legal_Name__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Also_Known_As__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_Description__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Location__c',true,true));
		PortalWrapperClasses.FieldWrapper focusAreas = new PortalWrapperClasses.FieldWrapper('Focus_Areas__c',true,true);
		focusAreas.isMultipick = true;
		lstfw1.add(focusAreas);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Founding_Date__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Number_Of_Employees__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_info_of_startup__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_Position__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_Email__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_Phone_Number__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Website__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Facebook__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Instagram__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Twitter__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('LinkedIn__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('GitHub__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Telegram__c',true,true));

		//SERVICE INFORMATION
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Solution__c',true,true));
		PortalWrapperClasses.FieldWrapper technology = new PortalWrapperClasses.FieldWrapper('Technology__c',true,true);
		technology.isMultipick = true;
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Description__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Industry_Perspectives__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Funding_Amount__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Funding_Stage__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Investors__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Competition_Competitors__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Competitive_Advantage__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Recent_News__c',true,true));
		PortalWrapperClasses.FieldWrapper tagsOfCategories = new PortalWrapperClasses.FieldWrapper('Tags_Of_Categories__c',true,true);
		tagsOfCategories.isMultipick = true;
		lstfw1.add(tagsOfCategories);	
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Status__c',true,false));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Id',true,false));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('RecordTypeId',true,false));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Account_Role__c',true,false));
		lstCardWrapper.add(new PortalWrapperClasses.CardWrapper('New Details', lstfw1, false,'New Details'));

		return lstCardWrapper;
	}

	@AuraEnabled (cacheable = false)
	public static PortalWrapperClasses.ListCardsAndPropertiesWrapper getProviderDetailsPropertiesAndCardsList(String providerId){
	
		PortalWrapperClasses.ListCardsAndPropertiesWrapper propertiesAndLstCards = new PortalWrapperClasses.ListCardsAndPropertiesWrapper();
		propertiesAndLstCards.objectAPIName = IH_ACCOUNT_ROLE_DETAIL;
		propertiesAndLstCards.recordId = providerId;
		propertiesAndLstCards.lstCards = PortalServicesInnovationHubCtrl.getProviderDetailsPageCardDetails();
		propertiesAndLstCards.viewNavigation = false;

		return propertiesAndLstCards;
	}

	private static List<PortalWrapperClasses.CardWrapper> getProviderDetailsPageCardDetails(){
		//stores each card
		List<PortalWrapperClasses.CardWrapper> lstCardWrapper = new List<PortalWrapperClasses.CardWrapper>();

		//COMPANY INFORMATION
		List<PortalWrapperClasses.FieldWrapper> lstfw1 = new List<PortalWrapperClasses.FieldWrapper>();
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_Name__c',true,true));
		PortalWrapperClasses.FieldWrapper logo = new PortalWrapperClasses.FieldWrapper('Logo_File_Id__c',true,false);
		logo.isLogo = true;
		lstfw1.add(logo);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Legal_Name__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Also_Known_As__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_Description__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Location__c',true,true));
		PortalWrapperClasses.FieldWrapper focusAreas = new PortalWrapperClasses.FieldWrapper('Focus_Areas__c',true,false,'',System.Label.CSP_FocusAreas);
		focusAreas.isMultipick = true;
		lstfw1.add(focusAreas);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Founding_Date__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Number_Of_Employees__c',true,true));

		//SERVICE INFORMATION
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Solution__c',true,true));
		PortalWrapperClasses.FieldWrapper technology = new PortalWrapperClasses.FieldWrapper('Technology__c',true,false,'',System.Label.CSP_Technology);
		technology.isMultipick = true;
		lstfw1.add(technology);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Description__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_info_of_startup__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_Position__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_Email__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_Phone_Number__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Industry_Perspectives__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Funding_Amount__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Funding_Stage__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Investors__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Competition_Competitors__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Competitive_Advantage__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Recent_News__c',true,true));
		PortalWrapperClasses.FieldWrapper tagsOfCategories = new PortalWrapperClasses.FieldWrapper('Tags_Of_Categories__c',true,false,'',System.Label.CSP_Categories);
		tagsOfCategories.isMultipick = true;
		lstfw1.add(tagsOfCategories);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Website__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Facebook__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Instagram__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Twitter__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('LinkedIn__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('GitHub__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Telegram__c',true,true));

		lstCardWrapper.add(new PortalWrapperClasses.CardWrapper('Provider Information', lstfw1, false,'Provider Information'));

		return lstCardWrapper;
	}

	@InvocableMethod(label='Create Account Role and Account Role Detail from Portal Application Right' 
					description='Given a list of Portal Application Rights IDs create a list of Acount Roles and Account Role Details for Innovation Hub')
	public static List<String> createAccountRoleAndAccountRoleDetails(List<ID> ids) {

		Set<Id> accWoArd = new Set<Id>(); // Accounts without IH-ARD
		Map<Id, Id> mapAccRoles = new Map<Id, Id>(); // map Account Role -> Account Role Id
		Map<Id, Id> mapARDetail = new Map<Id, Id>(); 
		List<Account_Role__c> lstAccountRoles = new List<Account_Role__c>();
		List<IH_Account_Role_Detail__c> lstAccountRoleDetails = new List<IH_Account_Role_Detail__c>();

		// Insert IH Account Role Details
		lstAccountRoles =[SELECT Id, Account__c FROM Account_Role__c WHERE Account__c IN :ids and RecordTypeId = :accountRoleRecordTypeId];		
		for(Account_Role__c ar : lstAccountRoles) {
			mapAccRoles.put(ar.Account__c, ar.Id);
		}
		lstAccountRoles.clear();
		// If IH-AR does not exists, create a new one
		for(Id accountId : ids){
			if(mapAccRoles.isEmpty() || (!mapAccRoles.isEmpty() && !mapAccRoles.containsKey(accountId))) {
				lstAccountRoles.add(new Account_Role__c(Account__c = accountId,  RecordTypeId = accountRoleRecordTypeId, Status__c = 'Active',  Functional_Role__c = 'InnovationHub CRM'));
			}
		}
		if(!lstAccountRoles.isEmpty()){
			insert lstAccountRoles;
			for(Account_Role__c ar : lstAccountRoles) {
				mapAccRoles.put(ar.Account__c, ar.Id);
			}
		}
		

		// Insert IH Account Role Details
		lstAccountRoleDetails = [SELECT Id, Account_Role__r.Account__c FROM IH_Account_Role_Detail__c WHERE Account_Role__c IN :mapAccRoles.values() AND (RecordTypeId = :accountRoleDetailConsumerRecordTypeId OR RecordTypeId = :accountRoleDetailProviderRecordTypeId)];

		
		for(IH_Account_Role_Detail__c ar : lstAccountRoleDetails) {
			mapARDetail.put(ar.Account_Role__r.Account__c, ar.Id);
		}
		for(Id accId : ids){
			if(mapARDetail.isEmpty() || (!mapARDetail.isEmpty() && !mapARDetail.containsKey(accId))) {
				accWoArd.add(accId);
			}
		}
		List<Account> accs = [Select Id, Sector__c FROM Account WHERE Id IN :accWoArd];
		lstAccountRoleDetails.clear();
		for(Account acc : accs){
			if(acc.Sector__c == 'Airline' || acc.Sector__c == 'Airline Supplier'){
				lstAccountRoleDetails.add(new IH_Account_Role_Detail__c(Account_Role__c = mapAccRoles.get(acc.Id),
																	RecordTypeId = accountRoleDetailConsumerRecordTypeId,
																	Status__c = 'Approved'));
			}
			else {
				lstAccountRoleDetails.add(new IH_Account_Role_Detail__c(Account_Role__c = mapAccRoles.get(acc.Id),
																	RecordTypeId = accountRoleDetailProviderRecordTypeId,
																	Status__c = 'Draft'));
			}
		}
		if(!lstAccountRoleDetails.isEmpty())
			insert lstAccountRoleDetails;
		
		return ids;
	}

	@AuraEnabled(cacheable = false)
	public static List<TabWrapper> getInnovationHubTabs(){
		List<TabWrapper> lstTabs = new List<TabWrapper>();

		lstTabs.add(new TabWrapper(0, Label.CSP_Service_InnovationHub_SearchTab, false, '', true));
		lstTabs.add(new TabWrapper(1, Label.CSP_Service_InnovationHub_ProviderProfileTab, false, '', true));

		//get the users account role 
		IH_Account_Role_Detail__c userAccountRole = getUserIHAccountRoleDetailWithStatus(''); //ANY STATUS
		
		//no account role -> no access to service
		if(userAccountRole == null){
			lstTabs = new List<TabWrapper>();
		}else{
			//Functional role = "provider" -> provider profile tab
			if(userAccountRole.RecordTypeId == accountRoleDetailProviderRecordTypeId){
				lstTabs.get(1).tabIsHidden = false;
				lstTabs.get(1).tabIsActive = true;
			}
			//Functional role = "consumer" -> view search tab
			if(userAccountRole.RecordTypeId == accountRoleDetailConsumerRecordTypeId){
				lstTabs.get(0).tabIsHidden = false;
				lstTabs.get(0).tabIsActive = true;
			}
			//Functional role = "provider & consumer" -> view all tabs
			if(userAccountRole.RecordTypeId == accountRoleDetailConsumerProviderRecordTypeId){
				lstTabs.get(0).tabIsHidden = false;
				lstTabs.get(1).tabIsHidden = false;
				lstTabs.get(0).tabIsActive = true;
			}
		}
		return lstTabs;
	}

	@AuraEnabled(cacheable = false)
	public static List<ProviderWrapper> getLstProviders(String searchText, String filteringObject){
		List<ProviderWrapper> lstProviders = new List<ProviderWrapper>();

		filterWrapper filterWrapperAux = (filterWrapper) JSON.deserialize(filteringObject, filterWrapper.class);
		List<String> technologies = filterWrapperAux.technologies;
		List<String> focusAreas = filterWrapperAux.focusAreas;
		List<String> categories = filterWrapperAux.categories;

		String query = 'SELECT Id,Name,Description__c,Company_Description__c,Logo__c,Logo_File_Id__c,Company_Name__c,Funding_Stage__c,Focus_Areas__c,Tags_Of_Categories__c FROM IH_Account_Role_Detail__c ';
		query+= 'WHERE (RecordTypeId = :accountRoleDetailProviderRecordTypeId OR RecordTypeId = :accountRoleDetailConsumerProviderRecordTypeId) AND Published__c = true';

		if(searchText.length()>0){
			String aux = '%' + String.escapeSingleQuotes(searchText) + '%';
			query+= ' AND Company_Name__c LIKE \'' + aux + '\'';	
		}

		if(filterWrapperAux.fundingStage.length()>0){
			String fs = String.escapeSingleQuotes(filterWrapperAux.fundingStage);
			query+= ' AND Funding_Stage__c = \'' + fs + '\'';	
		}

		if(technologies.size()>0){
			String techOptions = String.join(technologies,';');
			query+= ' AND Technology__c includes ( \'' + techOptions + '\'' + ')';	
		}

		if(focusAreas.size()>0){
			String focusOptions = String.join(focusAreas,';');
			query+= ' AND Focus_Areas__c includes ( \'' + focusOptions + '\'' + ')';
		}

		if(categories.size()>0){
			String categoriesOptions = String.join(categories,';');
			query+= ' AND Tags_Of_Categories__c includes ( \'' + categoriesOptions + '\'' + ')';	
		}

		query+= ' ORDER BY Company_Name__c ASC';

		List<IH_Account_Role_Detail__c> lstProvidersAux = Database.query(query);	
		
		for(IH_Account_Role_Detail__c provider : lstProvidersAux){
			lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper(provider.id, provider.Company_Name__c, provider.Company_Description__c,getProviderImgURL(provider.Logo_File_Id__c), provider.Logo_File_Id__c));
		}	
		
		return lstProviders;
	}

	@AuraEnabled(cacheable = false)
	public static String getProviderImgURL(String logoId) {
		if(logoId != null){
			return URL.getOrgDomainUrl().toExternalForm() + IH_LOGO_PATH + logoId;
		}

		return null;
	}

	@AuraEnabled(cacheable = false)
	public static String getProviderImgURLById(String providerId) {
		String logoId = '';
		if(providerId != null && providerId != ''){
			logoId = [SELECT Logo_File_Id__c FROM IH_Account_Role_Detail__c 
					 WHERE Id = :providerId LIMIT 1].Logo_File_Id__c;
		}
		else{
			logoId = getUserIHAccountRoleDetailWithStatus('').Logo_File_Id__c;
		}
		
		return getProviderImgURL(logoId);

	}

	@AuraEnabled(cacheable = false)
	public static List<IH_Account_Role_Detail__c> getProviderFieldLists(String providerId,String field) {

		if(providerId == null || providerId == '' ){
			providerId = getUserIHAccountRoleDetailWithStatus('').Id;
		}

		String queryAux = 'SELECT ' + field + ' FROM IH_Account_Role_Detail__c WHERE Id = ';
		queryAux += '\'' + providerId + '\'' + ' LIMIT 1';	

		List<IH_Account_Role_Detail__c> detail = Database.query(queryAux); 	

		return detail;

	}

	private static IH_Account_Role_Detail__c getUserIHAccountRoleDetailWithStatus(String status){
		//get the users account role detail
		User currentUser = CSP_Utils.getLoggedUser();
		String statusAux = '%' + status + '%';
		List<IH_Account_Role_Detail__c> lstAccountRoles = [SELECT Id,RecordTypeId, Logo_File_Id__c,Internal_comments__c,Status__c,Marked_For_Review__c
															FROM IH_Account_Role_Detail__c 
															WHERE Account_Role__r.Account__c = :currentUser.Contact.AccountId
															AND Account_Role__r.RecordTypeId = :accountRoleRecordTypeId 
															AND Status__c LIKE :statusAux LIMIT 1];
		return lstAccountRoles != null && !lstAccountRoles.isEmpty() ? lstAccountRoles.get(0) : null;
	}

	public static IH_Account_Role_Detail__c getLastestPublishedProviderUserIHAccountRoleDetail(){
		//get the users account role detail
		User currentUser = CSP_Utils.getLoggedUser();
		List<IH_Account_Role_Detail__c> lstAccountRoles = [SELECT Id, Internal_comments__c, Status__c, Marked_For_Review__c 
															FROM IH_Account_Role_Detail__c 
															WHERE Account_Role__r.Account__c = :currentUser.Contact.AccountId
															AND (RecordTypeId = :accountRoleDetailProviderRecordTypeId OR 
															RecordTypeId = :accountRoleDetailConsumerProviderRecordTypeId) 
															AND Published__c = true
															AND Status__c = :IH_ACCOUNT_ROLE_DETAILS_STATUS_APPROVED 
															ORDER BY LastModifiedDate DESC LIMIT 1];
		return lstAccountRoles != null && !lstAccountRoles.isEmpty() ? lstAccountRoles.get(0) : null;
	}

	@AuraEnabled(cacheable = false)
	public static PicklistPropertiesWrapper getLabelPicklistValuesAndSelected(String objectName, String fieldName, String recordId){
		//get the object field label 
		String fieldLabel = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
		
		//get the available picklist options
		List<CSP_Utils.PickListWrapper> lstPickOptions = CSP_Utils.getPickListValues(objectName, fieldName);
		
		//get the selected options from the record id
		String queryStr = 'SELECT ' + fieldName + ' FROM ' + objectName + ' WHERE Id = :recordId ';
		sObject queryObject = Database.query(queryStr);
		String fieldContent = (String) queryObject.get(fieldName);
		List<String> fieldContentSplit = fieldContent != null && fieldContent != '' ? fieldContent.split(';') : new List<String>();
		Set<String> selectedValues = new Set<String>(fieldContentSplit);

		for(CSP_Utils.PickListWrapper pickValueAux : lstPickOptions){
			pickValueAux.checked = selectedValues.contains(pickValueAux.value);
		}

		return new PicklistPropertiesWrapper(fieldLabel, lstPickOptions);
	}

	@AuraEnabled(cacheable = false)
	public static String saveProviderProfile(String innoHubAccountRoleDetailsStr, String mode){

		try{
			IH_Account_Role_Detail__c innoHubAccountRoleDetails = (IH_Account_Role_Detail__c) JSON.deserialize(innoHubAccountRoleDetailsStr, IH_Account_Role_Detail__c.class);
			IH_Account_Role_Detail__c innoHubAccountRoleDetailsAux = null;

			if(innoHubAccountRoleDetails.Status__c == IH_ACCOUNT_ROLE_DETAILS_STATUS_APPROVED){
				//if the status is approved then it means that a new record needs to be created 
				innoHubAccountRoleDetailsAux = innoHubAccountRoleDetails.clone(false, true, false, false);
				innoHubAccountRoleDetailsAux.Published__c = false;

				IH_Account_Role_Detail__c iharlForExtraFields = [SELECT Id, RecordTypeId, Account_Role__c 
																FROM IH_Account_Role_Detail__c WHERE Id = :innoHubAccountRoleDetails.Id];
				innoHubAccountRoleDetailsAux.RecordTypeId = iharlForExtraFields.RecordTypeId;
				innoHubAccountRoleDetailsAux.Account_Role__c = iharlForExtraFields.Account_Role__c;
				innoHubAccountRoleDetailsAux.Marked_For_Review__c = false;
				innoHubAccountRoleDetailsAux.Internal_comments__c = '';
			}else{
				//not approved means that is a draft and therefore can be used to persist the new changes
				innoHubAccountRoleDetailsAux = innoHubAccountRoleDetails;
			}

			if(mode == 'save'){
				//when the user clicks on save button
				innoHubAccountRoleDetailsAux.Status__c = IH_ACCOUNT_ROLE_DETAILS_STATUS_DRAFT;
			}else{
				//when the user clicks on submit button
				innoHubAccountRoleDetailsAux.Status__c = IH_ACCOUNT_ROLE_DETAILS_STATUS_SUBMITTED;
			}

			upsert innoHubAccountRoleDetailsAux;
			return innoHubAccountRoleDetailsAux.Id;
		} catch( Exception e){
			System.debug('____ [cls PortalServicesInnovationHubCtrl - saveProviderProfile] innoHubAccountRoleDetailsAux: ' + e.getMessage());
			throw e;
		}
	}

	@AuraEnabled(cacheable = false)
	public static String saveLogoId(String providerProfileId, String contentDocumentId){
		try{
			IH_Account_Role_Detail__c providerProfileDetails = new IH_Account_Role_Detail__c(Id =providerProfileId, Logo_File_Id__c = contentDocumentId);
			update providerProfileDetails;
			return providerProfileDetails.Id;
		}catch( Exception e){
			System.debug('____ [cls PortalServicesInnovationHubCtrl - saveLogoId] error: ' + e.getMessage());
			throw e;
		}
	}

/* 
	*	Methods used for uploading new logo file 
	*/
	
	@AuraEnabled(cacheable = false)
	public static String uploadFile(String base64, String filename, String recordId) {
		ContentVersion cv = createContentVersion(base64, filename);
		if (cv == null || recordId == null) { return null; }
		ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
		return cv.Id;
  	}

	//Creates a content version from a given file's base64 and name
	private static ContentVersion createContentVersion(String base64, String filename) {
		ContentVersion cv = new ContentVersion();
		cv.VersionData = EncodingUtil.base64Decode(base64);
		cv.Title = filename;
		cv.PathOnClient = filename;
		try {
			insert cv;
			return cv;
		} catch(DMLException e) {
			System.debug(loggingLevel.FINE, '____ [cls PortalServicesInnovationHubCtrl - createContentVersion] cv - ' + e);
			return null;
		}
	}

	//Creates a content link for a given ContentVersion and record
	private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
		
		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
		cdl.LinkedEntityId = recordId;
		// ShareType is either 'V', 'C', or 'I'
		// V = Viewer, C = Collaborator, I = Inferred
		cdl.ShareType = 'V';
		try {
			insert cdl;
			return cdl;
		} catch(DMLException e) {
			System.debug(loggingLevel.FINE, '____ [cls PortalServicesInnovationHubCtrl - createContentLink] cdl - ' + e);
			return null;
		}
	}


	public class PicklistPropertiesWrapper {
		@AuraEnabled
		public String fieldLabel {get; set;}
		@AuraEnabled
		public List<CSP_Utils.PickListWrapper> lstPickOptions {get; set;}

		public PicklistPropertiesWrapper(String fieldLabel, List<CSP_Utils.PickListWrapper> lstPickOptions ){
			this.fieldLabel = fieldLabel;
			this.lstPickOptions = lstPickOptions;
		}
	}


	public class TabWrapper {
		@AuraEnabled
		public Integer tabId {get; set;}
		@AuraEnabled
		public String tabLabel {get; set;}
		@AuraEnabled
		public Boolean tabIsActive {get; set;}
		@AuraEnabled
		public String tabStyle {get; set;}
		@AuraEnabled
		public Boolean tabIsHidden {get; set;}
		
		public TabWrapper(Integer tabId, String tabLabel, Boolean tabIsActive, String tabStyle, Boolean tabIsHidden){
			this.tabId = tabId;
			this.tabLabel = tabLabel;
			this.tabIsActive = tabIsActive;
			this.tabStyle = tabStyle;
			this.tabIsHidden = tabIsHidden;
		}
	}

	public class ProviderWrapper {
		@AuraEnabled
		public String id {get; set;}
		@AuraEnabled
		public String name {get; set;}
		@AuraEnabled
		public String description {get; set;}
		@AuraEnabled
		public String imageUrl {get; set;}
		@AuraEnabled
		public String logoId {get; set;}
		
		public ProviderWrapper(String idAux, String nameAux, String descriptionAux, String imageUrlAux, String logoIdAux){
			id = idAux;
			name = nameAux;
			description = descriptionAux;
			imageUrl = imageUrlAux;
			logoId = logoIdAux;
		}

	}

	public class filterWrapper {
		@AuraEnabled
		public String fundingStage {get; set;}
		@AuraEnabled
		public List<String> technologies {get; set;}
		@AuraEnabled
		public List<String> focusAreas {get; set;}
		@AuraEnabled
		public List<String> categories {get; set;}

	}
}