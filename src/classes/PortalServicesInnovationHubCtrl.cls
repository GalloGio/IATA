public without sharing class PortalServicesInnovationHubCtrl {

	private static String ACCOUNT_ROLE_INNOVATIONHUB_RTYPE_DEVNAME = 'Innovation_Hub';
	private static String ACCOUNT_ROLE_DETAIL_CONSUMER_RTYPE_DEVNAME = 'Consumer';
	private static String ACCOUNT_ROLE_DETAIL_PROVIDER_RTYPE_DEVNAME = 'Provider';
	private static String ACCOUNT_ROLE_DETAIL_CONSUMERANDPROVIDER_RTYPE_DEVNAME = 'Consumer_and_Provider';
	private static String INNOVATION_HUB_SERVICE_NAME = Label.InnovationHub_ServiceName;

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

	@AuraEnabled(cacheable = false)
	public static ProviderInfoWrapper getInnovationHubProviderDetails(String providerId){
		IH_Account_Role_Detail__c provider = [SELECT Id,Name,Description__c,Logo__c,Logo_File_Id__c,Legal_Name__c,Founding_Date__c,
								Company_name__c,Funding_Stage__c,Focus_Areas__c,Tags_of_categories__c,Also_known_as__c,	Location__r.Name,
								Solution__c,Technology__c,IATA_touchpoints__c,Number_of_employees__c,Case_Studies_Pilots__c,Recent_News__c,
								Website__c,Link_to_Social_Media_accounts__c,Company_Description__c
								FROM IH_Account_Role_Detail__c WHERE Id =: providerId LIMIT 1];

								ProviderInfoWrapper providerWp = new PortalServicesInnovationHubCtrl.ProviderInfoWrapper(provider);
		
		return providerWp;
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

		//Home tab always visible
		lstTabs.add(new TabWrapper(0, Label.CSP_Service_InnovationHub_HomeTab, true, '', true));
		lstTabs.add(new TabWrapper(1, Label.CSP_Service_InnovationHub_SearchTab, false, '', true));
		lstTabs.add(new TabWrapper(2, Label.CSP_Service_InnovationHub_ProviderProfileTab, false, '', true));

		//get the users account role 
		User currentUser = CSP_Utils.getLoggedUser();
		List<IH_Account_Role_Detail__c> lstAccountRoles = [SELECT Id, RecordType.DeveloperName FROM IH_Account_Role_Detail__c 
															WHERE Account_Role__r.Account__c = :currentUser.Contact.AccountId
															AND Account_Role__r.RecordType.DeveloperName = :ACCOUNT_ROLE_INNOVATIONHUB_RTYPE_DEVNAME];
		
		//no account role -> view just home
		if(lstAccountRoles == null || lstAccountRoles.isEmpty()){
			lstTabs.get(0).tabIsHidden = false;
		}else{

			//Functional role = "provider" -> view home and provider profile tabs
			if(lstAccountRoles.get(0).RecordType.DeveloperName == ACCOUNT_ROLE_DETAIL_PROVIDER_RTYPE_DEVNAME){
				lstTabs.get(0).tabIsHidden = false;
				lstTabs.get(2).tabIsHidden = false;
			}
			//Functional role = "consumer" -> view home and search tabs
			if(lstAccountRoles.get(0).RecordType.DeveloperName == ACCOUNT_ROLE_DETAIL_CONSUMER_RTYPE_DEVNAME){
				lstTabs.get(0).tabIsHidden = false;
				lstTabs.get(1).tabIsHidden = false;
			}
			//Functional role = "provider & consumer" -> view all tabs
			if(lstAccountRoles.get(0).RecordType.DeveloperName == ACCOUNT_ROLE_DETAIL_CONSUMERANDPROVIDER_RTYPE_DEVNAME){
				lstTabs.get(0).tabIsHidden = false;
				lstTabs.get(1).tabIsHidden = false;
				lstTabs.get(2).tabIsHidden = false;
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
			query+= ' AND Technology__c IN :technologies';	
		}

		if(focusAreas.size()>0){
			query+= ' AND Focus_Areas__c IN :focusAreas';	
		}

		if(categories.size()>0){
			query+= ' AND Tags_of_categories__c IN :categories';	
		}


		query+= ' ORDER BY Company_name__c ASC';

		List<IH_Account_Role_Detail__c> lstProvidersAux = Database.query(query);	
		
		for(IH_Account_Role_Detail__c provider : lstProvidersAux){
			lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper(provider.id, provider.company_name__c, provider.Company_Description__c,getProviderImgURL(provider.Logo_File_Id__c), provider.Logo_File_Id__c));
		}	
		
		return lstProviders;
	}

	public static String getProviderImgURL(String logoId) {
		return URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + logoId;
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

	public class ProviderInfoWrapper {
		@AuraEnabled
		public String id {get; set;}
		@AuraEnabled
		public String imageUrl {get; set;}
		@AuraEnabled
		public String legalName {get; set;}
		@AuraEnabled
		public String alsoKnownAs {get; set;}
		@AuraEnabled
		public String companyDescription {get; set;}
		@AuraEnabled
		public Decimal foundingDate {get; set;}
		@AuraEnabled
		public String location {get; set;}
		@AuraEnabled
		public String solution {get; set;}
		@AuraEnabled
		public List<String> technologies {get; set;}
		@AuraEnabled
		public List<String> focusAreas {get; set;}
		@AuraEnabled
		public List<String> categories {get; set;}
		@AuraEnabled
		public List<String> iataTouchPoints {get; set;}
		@AuraEnabled
		public String numEmployees {get; set;}
		@AuraEnabled
		public String pilots {get; set;}
		@AuraEnabled
		public String recentNews {get; set;}
		@AuraEnabled
		public String website {get; set;}
		@AuraEnabled
		public String socialMedia {get; set;}

		public ProviderInfoWrapper(IH_Account_Role_Detail__c providerAux){
			id = providerAux.id;
			imageUrl = getProviderImgURL(providerAux.Logo_File_Id__c);
			legalName = providerAux.Legal_Name__c;
			alsoKnownAs = providerAux.Also_known_as__c;
			companyDescription = providerAux.Company_Description__c;
			foundingDate = providerAux.Founding_Date__c;
			location = providerAux.Location__r.Name;
			solution = providerAux.Solution__c;
			solution = solution.replaceAll('<[^>]+>',' ');
			technologies = providerAux.Technology__c.split(';');
			focusAreas = providerAux.Focus_Areas__c.split(';');
			categories = providerAux.Tags_of_categories__c.split(';');
			iataTouchPoints = providerAux.IATA_touchpoints__c.split(';');
			numEmployees = providerAux.Number_of_employees__c;
			pilots = providerAux.Case_Studies_Pilots__c;
			recentNews = providerAux.Recent_News__c;
			website = providerAux.Website__c;
			socialMedia = providerAux.Link_to_Social_Media_accounts__c;

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