public with sharing class PortalServicesInnovationHubCtrl {

	@InvocableMethod(label='Create Account Role and Account Role Detail from Portal Application Right' 
					description='Given a list of Portal Application Rights IDs create a list of Acount Roles and Account Role Details for Innovation Hub')
	public static List<String> createAccountRoleAndAccountRoleDetails(List<ID> ids) {
		
		PortalServicesInnovationHubCtrl.createAccountRoleAndAccountRoleDetailsFuture(ids);
		
		return ids;
	}

	@future(callout=true)
    public static void createAccountRoleAndAccountRoleDetailsFuture(List<ID> ids) {
        Id accountRoleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByDeveloperName().get('Innovation_Hub').getRecordTypeId();
		Id accountRoleDetailConsumerRecordTypeId = Schema.SObjectType.IH_Account_Role_Detail__c.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
		Id accountRoleDetailProviderRecordTypeId = Schema.SObjectType.IH_Account_Role_Detail__c.getRecordTypeInfosByDeveloperName().get('Provider').getRecordTypeId();


		List<Portal_Application_Right__c> lstPortalApplicationRights = [SELECT Id,Contact__r.Account.Sector__c,Contact__r.AccountId,
																		Portal_Application__r.Name, Right__c 
																		FROM Portal_Application_Right__c WHERE Id IN :ids];
		List<Account_Role__c> lstAccountRoles = new List<Account_Role__c>();
		for(Portal_Application_Right__c portalApplicationRightAux : lstPortalApplicationRights){
			if(portalApplicationRightAux.Portal_Application__r.Name == 'Innovation Hub' && portalApplicationRightAux.Right__c == 'Access Granted'){
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
																			RecordTypeId = accountRoleDetailConsumerRecordTypeId));
					}
					else {
						lstAccountRoleDetails.add(new IH_Account_Role_Detail__c(Account_Role__c = accountRoleAux.Id,
																			RecordTypeId = accountRoleDetailProviderRecordTypeId));
					}
				}
			}
		}
		insert lstAccountRoleDetails;
    }

	@AuraEnabled(cacheable = false)
	public static List<TabWrapper> getInnovationHubTabs(){
		List<TabWrapper> lstTabs = new List<TabWrapper>();

		//Home tab always visible
		lstTabs.add(new TabWrapper(0, 'Home', true, '', true));
		lstTabs.add(new TabWrapper(1, 'Search', false, '', true));
		lstTabs.add(new TabWrapper(2, 'Provider Profile', false, '', true));

		//get the users account role 
		User currentUser = CSP_Utils.getLoggedUser();
		List<IH_Account_Role_Detail__c> lstAccountRoles = [SELECT Id, RecordType.DeveloperName FROM IH_Account_Role_Detail__c 
															WHERE Account_Role__r.Account__c = :currentUser.Contact.AccountId
															AND Account_Role__r.RecordType.DeveloperName = 'Innovation_Hub'];
		
		//no account role -> view just home
		if(lstAccountRoles == null || lstAccountRoles.isEmpty()){
			lstTabs.get(0).tabIsHidden = false;
		}else{

			//Functional role = "provider" -> view home and provider profile tabs
			if(lstAccountRoles.get(0).RecordType.DeveloperName == 'Provider'){
				lstTabs.get(0).tabIsHidden = false;
				lstTabs.get(2).tabIsHidden = false;
			}
			//Functional role = "consumer" -> view home and search tabs
			if(lstAccountRoles.get(0).RecordType.DeveloperName == 'Consumer'){
				lstTabs.get(0).tabIsHidden = false;
				lstTabs.get(1).tabIsHidden = false;
			}
			//Functional role = "provider & consumer" -> view all tabs
			if(lstAccountRoles.get(0).RecordType.DeveloperName == 'Consumer_and_Provider'){
				lstTabs.get(0).tabIsHidden = false;
				lstTabs.get(1).tabIsHidden = false;
				lstTabs.get(2).tabIsHidden = false;
			}

		}

		return lstTabs;
	}

	@AuraEnabled(cacheable = false)
	public static List<ProviderWrapper> getLstProviders(){
		List<ProviderWrapper> lstProviders = new List<ProviderWrapper>();
		
		lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper('0', 'Provider 0', '0 provider description', ''));
		lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper('1', 'Provider 1', '1 provider description', ''));
		lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper('2', 'Provider 2', '2 provider description', ''));
		lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper('3', 'Provider 3', '3 provider description', ''));
		lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper('4', 'Provider 4', '4 provider description', ''));
		lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper('5', 'Provider 5', '5 provider description', ''));
		lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper('6', 'Provider 6', '6 provider description', ''));
		lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper('7', 'Provider 7', '7 provider description', ''));
		lstProviders.add(new PortalServicesInnovationHubCtrl.ProviderWrapper('8', 'Provider 9', '8 provider description', ''));

		return lstProviders;
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
		
		public ProviderWrapper(String idAux, String nameAux, String descriptionAux, String imageUrlAux){
			id = idAux;
			name = nameAux;
			description = descriptionAux;
			imageUrl = imageUrlAux;
		}

	}
}