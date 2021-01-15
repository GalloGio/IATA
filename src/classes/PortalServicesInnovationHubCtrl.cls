public without sharing class PortalServicesInnovationHubCtrl {

	private static String ACCOUNT_ROLE_INNOVATIONHUB_RTYPE_DEVNAME = 'Innovation_Hub';
	private static String ACCOUNT_ROLE_DETAIL_CONSUMER_RTYPE_DEVNAME = 'Consumer';
	private static String ACCOUNT_ROLE_DETAIL_PROVIDER_RTYPE_DEVNAME = 'Provider';
	private static String ACCOUNT_ROLE_DETAIL_CONSUMERANDPROVIDER_RTYPE_DEVNAME = 'Consumer_and_Provider';
	private static String INNOVATION_HUB_SERVICE_NAME = Label.InnovationHub_ServiceName;

	private static String IH_ACCOUNT_ROLE_DETAILS_STATUS_DRAFT = 'Draft';
	private static String IH_ACCOUNT_ROLE_DETAILS_STATUS_SUBMITTED = 'Submitted';
	private static String IH_ACCOUNT_ROLE_DETAILS_STATUS_APPROVED = 'Approved';
	private static String IH_LOGO_PATH = '/sfc/servlet.shepherd/version/download/';


	public static Id accountRoleRecordTypeId {
		get {
			if(accountRoleRecordTypeId == null) {
				accountRoleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByDeveloperName().get(ACCOUNT_ROLE_INNOVATIONHUB_RTYPE_DEVNAME).getRecordTypeId();
			}
			return accountRoleRecordTypeId;
		}
		set;
	}

	public static Id accountRoleDetailConsumerRecordTypeId {
		get {
			if(accountRoleDetailConsumerRecordTypeId == null) {
				accountRoleDetailConsumerRecordTypeId = Schema.SObjectType.IH_Account_Role_Detail__c.getRecordTypeInfosByDeveloperName().get(ACCOUNT_ROLE_DETAIL_CONSUMER_RTYPE_DEVNAME).getRecordTypeId();
			}
			return accountRoleDetailConsumerRecordTypeId;
		}
		set;
	}

	public static Id accountRoleDetailProviderRecordTypeId {
		get {
			if(accountRoleDetailProviderRecordTypeId == null) {
				accountRoleDetailProviderRecordTypeId = Schema.SObjectType.IH_Account_Role_Detail__c.getRecordTypeInfosByDeveloperName().get(ACCOUNT_ROLE_DETAIL_PROVIDER_RTYPE_DEVNAME).getRecordTypeId();
			}
			return accountRoleDetailProviderRecordTypeId;
		}
		set;
	}

	@AuraEnabled (cacheable = false)
	public static PortalWrapperClasses.ListCardsAndPropertiesWrapper getProviderPropertiesAndCardsList(){
	
		PortalWrapperClasses.ListCardsAndPropertiesWrapper propertiesAndLstCards = new PortalWrapperClasses.ListCardsAndPropertiesWrapper();
		propertiesAndLstCards.objectAPIName = 'IH_Account_Role_Detail__c';

		//get the last 
		propertiesAndLstCards.recordId = PortalServicesInnovationHubCtrl.getUserIHAccountRoleDetailWithStatus(IH_ACCOUNT_ROLE_DETAILS_STATUS_APPROVED).Id;
		propertiesAndLstCards.lstCards = PortalServicesInnovationHubCtrl.getProviderProfileCards();
		propertiesAndLstCards.viewNavigation = true;

		return propertiesAndLstCards;
	}

	private static List<PortalWrapperClasses.CardWrapper> getProviderProfileCards(){
		//stores each card
		List<PortalWrapperClasses.CardWrapper> lstCardWrapper = new List<PortalWrapperClasses.CardWrapper>();

		//COMPANY INFORMATION
		List<PortalWrapperClasses.FieldWrapper> lstfw1 = new List<PortalWrapperClasses.FieldWrapper>();
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_name__c',true,true));
		PortalWrapperClasses.FieldWrapper logo = new PortalWrapperClasses.FieldWrapper('Logo_File_Id__c',true,false);
		logo.isLogo = true;
		lstfw1.add(logo);
		PortalWrapperClasses.FieldWrapper fa = new PortalWrapperClasses.FieldWrapper('Focus_Areas__c',true,false);
		fa.isFocusArea = true;
		lstfw1.add(fa);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Legal_Name__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Number_of_employees__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Also_known_as__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_Description__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Location__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Website__c',true,true));
		lstCardWrapper.add(new PortalWrapperClasses.CardWrapper('Company Information', lstfw1, false,'Company Information'));

		//SERVICE INFORMATION
		List<PortalWrapperClasses.FieldWrapper> lstfw2 = new List<PortalWrapperClasses.FieldWrapper>();
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Solution__c',false,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Case_Studies_Pilots__c',true,true));
		PortalWrapperClasses.FieldWrapper tech = new PortalWrapperClasses.FieldWrapper('Technology__c',true,false);
		tech.isTech = true;
		lstfw2.add(tech);
		PortalWrapperClasses.FieldWrapper cat = new PortalWrapperClasses.FieldWrapper('Tags_of_categories__c',true,false);
		cat.isCategory = true;
		lstfw2.add(cat);
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Contact_info_of_startup__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Industry_Perspectives__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Competition_Competitors__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Competitive_Advantage__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Funding_Amount__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Funding_Rounds__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Funding_Stage__c',true,true));
		PortalWrapperClasses.FieldWrapper tp = new PortalWrapperClasses.FieldWrapper('IATA_touchpoints__c',true,false);
		tp.isTouchPoint = true;
		lstfw2.add(tp);
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Investors__c',true,true));
		lstfw2.add(new PortalWrapperClasses.FieldWrapper('Link_to_Social_Media_accounts__c',true,true));
		lstCardWrapper.add(new PortalWrapperClasses.CardWrapper('Service Information', lstfw2, false,'Service Information'));

		return lstCardWrapper;
	}

	@AuraEnabled (cacheable = false)
	public static PortalWrapperClasses.ListCardsAndPropertiesWrapper getProviderPropertiesAndEditCardsList(){
	
		PortalWrapperClasses.ListCardsAndPropertiesWrapper propertiesAndLstCards = new PortalWrapperClasses.ListCardsAndPropertiesWrapper();
		propertiesAndLstCards.objectAPIName = 'IH_Account_Role_Detail__c';
		propertiesAndLstCards.recordId = PortalServicesInnovationHubCtrl.getUserIHAccountRoleDetailWithStatus(IH_ACCOUNT_ROLE_DETAILS_STATUS_DRAFT).Id;
		propertiesAndLstCards.lstCards = PortalServicesInnovationHubCtrl.getProviderProfileCardsForEdit();
		propertiesAndLstCards.viewNavigation = true;

		return propertiesAndLstCards;
	}

	private static List<PortalWrapperClasses.CardWrapper> getProviderProfileCardsForEdit(){
		//stores each card
		List<PortalWrapperClasses.CardWrapper> lstCardWrapper = new List<PortalWrapperClasses.CardWrapper>();

		//COMPANY INFORMATION
		List<PortalWrapperClasses.FieldWrapper> lstfw1 = new List<PortalWrapperClasses.FieldWrapper>();
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_name__c',true,true));
		PortalWrapperClasses.FieldWrapper logo = new PortalWrapperClasses.FieldWrapper('Logo_File_Id__c',true,false);
		logo.isLogo = true;
		lstfw1.add(logo);
		PortalWrapperClasses.FieldWrapper fa = new PortalWrapperClasses.FieldWrapper('Focus_Areas__c',true,false);
		fa.isFocusArea = true;
		lstfw1.add(fa);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Legal_Name__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Number_of_employees__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Also_known_as__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_Description__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Location__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Website__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Solution__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Case_Studies_Pilots__c',true,true));
		PortalWrapperClasses.FieldWrapper tech = new PortalWrapperClasses.FieldWrapper('Technology__c',true,false);
		tech.isTech = true;
		lstfw1.add(tech);
		PortalWrapperClasses.FieldWrapper cat = new PortalWrapperClasses.FieldWrapper('Tags_of_categories__c',true,false);
		cat.isCategory = true;
		lstfw1.add(cat);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_info_of_startup__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Industry_Perspectives__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Competition_Competitors__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Competitive_Advantage__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Funding_Amount__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Funding_Rounds__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Funding_Stage__c',true,true));
		PortalWrapperClasses.FieldWrapper tp = new PortalWrapperClasses.FieldWrapper('IATA_touchpoints__c',true,false);
		tp.isTouchPoint = true;
		lstfw1.add(tp);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Investors__c',true,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Link_to_Social_Media_accounts__c',true,true));
		lstCardWrapper.add(new PortalWrapperClasses.CardWrapper('New Details', lstfw1, false,'New Details'));

		return lstCardWrapper;
	}

	@AuraEnabled (cacheable = false)
	public static PortalWrapperClasses.ListCardsAndPropertiesWrapper getProviderDetailsPropertiesAndCardsList(String providerId){
	
		PortalWrapperClasses.ListCardsAndPropertiesWrapper propertiesAndLstCards = new PortalWrapperClasses.ListCardsAndPropertiesWrapper();
		propertiesAndLstCards.objectAPIName = 'IH_Account_Role_Detail__c';
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
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_name__c',false,true));
		PortalWrapperClasses.FieldWrapper logo = new PortalWrapperClasses.FieldWrapper('Logo_File_Id__c',true,false);
		logo.isLogo = true;
		lstfw1.add(logo);
		PortalWrapperClasses.FieldWrapper fa = new PortalWrapperClasses.FieldWrapper('Focus_Areas__c',true,false);
		fa.isFocusArea = true;
		lstfw1.add(fa);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Legal_Name__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Number_of_employees__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Also_known_as__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Company_Description__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Location__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Website__c',false,true));

		//SERVICE INFORMATION
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Solution__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Case_Studies_Pilots__c',false,true));
		PortalWrapperClasses.FieldWrapper tech = new PortalWrapperClasses.FieldWrapper('Technology__c',true,false);
		tech.isTech = true;
		lstfw1.add(tech);
		PortalWrapperClasses.FieldWrapper cat = new PortalWrapperClasses.FieldWrapper('Tags_of_categories__c',true,false);
		cat.isCategory = true;
		lstfw1.add(cat);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Contact_info_of_startup__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Industry_Perspectives__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Competition_Competitors__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Competitive_Advantage__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Funding_Amount__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Funding_Rounds__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Funding_Stage__c',false,true));
		PortalWrapperClasses.FieldWrapper tp = new PortalWrapperClasses.FieldWrapper('IATA_touchpoints__c',true,false);
		tp.isTouchPoint = true;
		lstfw1.add(tp);
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Investors__c',false,true));
		lstfw1.add(new PortalWrapperClasses.FieldWrapper('Link_to_Social_Media_accounts__c',false,true));

		lstCardWrapper.add(new PortalWrapperClasses.CardWrapper('Company Information', lstfw1, false,'Company Information'));

		return lstCardWrapper;
	}

	@AuraEnabled(cacheable = false)
	public static PortalServicesCtrl.ServiceWrapper getInnovationHubServiceDetails(){
		return PortalServicesCtrl.getPortalServiceDetails(INNOVATION_HUB_SERVICE_NAME);
	}

	@InvocableMethod(label='Create Account Role and Account Role Detail from Portal Application Right' 
					description='Given a list of Portal Application Rights IDs create a list of Acount Roles and Account Role Details for Innovation Hub')
	public static List<String> createAccountRoleAndAccountRoleDetails(List<ID> ids) {

		List<Portal_Application_Right__c> lstPortalApplicationRights = [SELECT Id,Contact__r.Account.Sector__c,Contact__r.AccountId,
																		Portal_Application__r.Name, Right__c 
																		FROM Portal_Application_Right__c WHERE Id IN :ids];
		List<Account_Role__c> lstAccountRoles = new List<Account_Role__c>();
		for(Portal_Application_Right__c portalApplicationRightAux : lstPortalApplicationRights){
			if(portalApplicationRightAux.Portal_Application__r.Name == INNOVATION_HUB_SERVICE_NAME && portalApplicationRightAux.Right__c == 'Access Granted'){
						lstAccountRoles.add(new Account_Role__c(Account__c = portalApplicationRightAux.Contact__r.AccountId, 
																RecordTypeId = accountRoleRecordTypeId,
																Status__c = 'Active', 
																Functional_Role__c = 'InnovationHub CRM'));
			}
		}

		insert lstAccountRoles;

		List<IH_Account_Role_Detail__c> lstAccountRoleDetails = new List<IH_Account_Role_Detail__c>();
		for(Account_Role__c accountRoleAux : lstAccountRoles){
			for(Portal_Application_Right__c portalApplicationRightAux : lstPortalApplicationRights){
				if(portalApplicationRightAux.Contact__r.AccountId == accountRoleAux.Account__c){
					if(portalApplicationRightAux.Contact__r.Account.Sector__c == 'Airline' || portalApplicationRightAux.Contact__r.Account.Sector__c == 'Airline Supplier'){
						lstAccountRoleDetails.add(new IH_Account_Role_Detail__c(Account_Role__c = accountRoleAux.Id,
																			RecordTypeId = accountRoleDetailConsumerRecordTypeId,
																			Status__c = 'Approved'));
					}
					else {
						lstAccountRoleDetails.add(new IH_Account_Role_Detail__c(Account_Role__c = accountRoleAux.Id,
																			RecordTypeId = accountRoleDetailProviderRecordTypeId,
																			Status__c = 'Draft'));
					}
				}
			}
		}
		insert lstAccountRoleDetails;
		
		return ids;
	}

	@AuraEnabled(cacheable = false)
	public static List<TabWrapper> getInnovationHubTabs(){
		List<TabWrapper> lstTabs = new List<TabWrapper>();

		lstTabs.add(new TabWrapper(0, Label.CSP_Service_InnovationHub_SearchTab, false, '', true));
		lstTabs.add(new TabWrapper(1, Label.CSP_Service_InnovationHub_ProviderProfileTab, false, '', true));

		//get the users account role 
		IH_Account_Role_Detail__c userAccountRole = PortalServicesInnovationHubCtrl.getUserIHAccountRoleDetailWithStatus(''); //ANY STATUS
		
		//no account role -> no access to service
		if(userAccountRole == null){
			lstTabs = new List<TabWrapper>();
		}else{
			//Functional role = "provider" -> provider profile tab
			if(userAccountRole.RecordType.DeveloperName == ACCOUNT_ROLE_DETAIL_PROVIDER_RTYPE_DEVNAME){
				lstTabs.get(1).tabIsHidden = false;
				lstTabs.get(1).tabIsActive = true;
			}
			//Functional role = "consumer" -> view search tab
			if(userAccountRole.RecordType.DeveloperName == ACCOUNT_ROLE_DETAIL_CONSUMER_RTYPE_DEVNAME){
				lstTabs.get(0).tabIsHidden = false;
				lstTabs.get(0).tabIsActive = true;
			}
			//Functional role = "provider & consumer" -> view all tabs
			if(userAccountRole.RecordType.DeveloperName == ACCOUNT_ROLE_DETAIL_CONSUMERANDPROVIDER_RTYPE_DEVNAME){
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

		String query = 'SELECT Id,Name,Description__c,Company_Description__c,RecordType.DeveloperName,Logo__c,Logo_File_Id__c,Company_name__c,Funding_Stage__c,Focus_Areas__c,Tags_of_categories__c FROM IH_Account_Role_Detail__c ';
		query+= 'WHERE (RecordType.DeveloperName = :ACCOUNT_ROLE_DETAIL_PROVIDER_RTYPE_DEVNAME OR RecordType.DeveloperName = :ACCOUNT_ROLE_DETAIL_CONSUMERANDPROVIDER_RTYPE_DEVNAME) AND Published__c = true';

		if(searchText.length()>0){
			String aux = '%' + String.escapeSingleQuotes(searchText) + '%';
			query+= ' AND Company_name__c LIKE \'' + aux + '\'';	
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
			query+= ' AND Tags_of_categories__c includes ( \'' + categoriesOptions + '\'' + ')';	
		}

		query+= ' ORDER BY Company_name__c ASC';

		List<IH_Account_Role_Detail__c> lstProvidersAux = Database.query(query);	
		
		for(IH_Account_Role_Detail__c provider : lstProvidersAux){
			lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper(provider.id, provider.company_name__c, provider.Company_Description__c,getProviderImgURL(provider.Logo_File_Id__c), provider.Logo_File_Id__c));
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
		List<IH_Account_Role_Detail__c> lstAccountRoles = [SELECT Id, RecordType.DeveloperName,Logo_File_Id__c FROM IH_Account_Role_Detail__c 
															WHERE Account_Role__r.Account__c = :currentUser.Contact.AccountId
															AND Account_Role__r.RecordType.DeveloperName = :ACCOUNT_ROLE_INNOVATIONHUB_RTYPE_DEVNAME 
															AND Status__c LIKE :statusAux LIMIT 1];
		return lstAccountRoles != null && !lstAccountRoles.isEmpty() ? lstAccountRoles.get(0) : null;
	}

	public static IH_Account_Role_Detail__c getLastestPublishedProviderUserIHAccountRoleDetail(){
		//get the users account role detail
		User currentUser = CSP_Utils.getLoggedUser();
		List<IH_Account_Role_Detail__c> lstAccountRoles = [SELECT Id, RecordType.DeveloperName FROM IH_Account_Role_Detail__c 
															WHERE Account_Role__r.Account__c = :currentUser.Contact.AccountId
															AND (RecordType.DeveloperName = :ACCOUNT_ROLE_DETAIL_PROVIDER_RTYPE_DEVNAME OR 
															RecordType.DeveloperName = :ACCOUNT_ROLE_DETAIL_CONSUMERANDPROVIDER_RTYPE_DEVNAME) 
															AND Published__c = true
															AND Status__c = :IH_ACCOUNT_ROLE_DETAILS_STATUS_APPROVED 
															ORDER BY LastModifiedDate DESC LIMIT 1];
		return lstAccountRoles != null && !lstAccountRoles.isEmpty() ? lstAccountRoles.get(0) : null;
	}

	public static IH_Account_Role_Detail__c getLastestDraftProviderUserIHAccountRoleDetail(){
		//get the users account role detail
		User currentUser = CSP_Utils.getLoggedUser();
		List<IH_Account_Role_Detail__c> lstAccountRoles = [SELECT Id, RecordType.DeveloperName FROM IH_Account_Role_Detail__c 
															WHERE Account_Role__r.Account__c = :currentUser.Contact.AccountId
															AND (RecordType.DeveloperName = :ACCOUNT_ROLE_DETAIL_PROVIDER_RTYPE_DEVNAME OR 
															RecordType.DeveloperName = :ACCOUNT_ROLE_DETAIL_CONSUMERANDPROVIDER_RTYPE_DEVNAME) 
															AND Status__c = :IH_ACCOUNT_ROLE_DETAILS_STATUS_DRAFT
															ORDER BY LastModifiedDate DESC LIMIT 1];
		return lstAccountRoles != null && !lstAccountRoles.isEmpty() ? lstAccountRoles.get(0) : null;
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