public with sharing class AccountDashboardCTIContactsCtrl {

	@AuraEnabled
	public static List<KeyContact> getKeyContacts(Id accountId, Id contactId) {
		List<KeyContact> keyContactsWrapper = new List<KeyContact>();
		List<Contact> keyContacts = searchKeyContacts(accountId, contactId, 5);
		if (keyContacts.size()>0) {
			Set<Id> contactsIds = (new Map<Id,Contact>(keyContacts)).keySet();
			List<Portal_Application_Right__c> portalServices = searchPortalServicesForAccountAndContacts(accountId, contactsIds);
			Map<Id, List<Portal_Application_Right__c>> contactPortalServices = getPortalServicesByContact(keyContacts, portalServices);
			Boolean contactSelected = false;
			for(Contact con : keyContacts) {
				contactSelected = (con.Id == contactId);
				keyContactsWrapper.add(new KeyContact(con, contactPortalServices.get(con.Id), contactSelected));
			}
		}
		return keyContactsWrapper;
	}

	/*
	 *******************************
		For an Account get a list of x Contacts ordered by: Admin, IFAP contact if is an Agent, recent contacts with interactions (?)
	 *******************************
	*/
	public static List<Contact> searchKeyContacts(Id accountId, Id contactId, Integer recs) {
		List<Contact> keyContacts = new List<Contact>();
		Contact selectedContact = new Contact();
		if (contactId != null) {
			selectedContact = [SELECT Id, AccountId, Account.IATA_Iso_Country_Name__c, Account.Region_formula__c, Account.Account_Type__c, Account.IATACode__c, 
				Name, Title, Email, User_Portal_Status__c, LastActivityDate, Status__c, Phone, (SELECT Id, CreatedDate FROM Cases ORDER BY CreatedDate DESC LIMIT 1), 
				Airline_Contact_Type__c, MobilePhone, Account.Name 
				FROM Contact 
				WHERE AccountId = :accountId AND Id = :contactId 
				LIMIT 1
			];
		}

		if (selectedContact.Id != null) {
			keyContacts.add(selectedContact);
			recs=recs-1;
			List<Contact> keyContactsTmp = [SELECT Id, AccountId, Account.IATA_Iso_Country_Name__c, Account.Region_formula__c, Account.Account_Type__c, Account.IATACode__c, 
					Name, Title, Email, User_Portal_Status__c, LastActivityDate, Status__c, Phone, (SELECT Id, CreatedDate FROM Cases ORDER BY CreatedDate DESC LIMIT 1),
					Airline_Contact_Type__c, MobilePhone, Account.Name 
					FROM Contact 
					WHERE AccountId = :accountId AND Id != :contactId
					ORDER BY User_Portal_Status__c DESC, Designated_IFAP_Contact__c  DESC
					LIMIT :recs
				];
				if (keyContactsTmp.size()>0){
					keyContacts.addAll(keyContactsTmp);
				}
		}else{
			keyContacts = [SELECT Id, AccountId, Account.IATA_Iso_Country_Name__c, Account.Region_formula__c, Account.Account_Type__c, Account.IATACode__c, 
					Name, Title, Email, User_Portal_Status__c, LastActivityDate, Status__c, Phone, (SELECT Id, CreatedDate FROM Cases ORDER BY CreatedDate DESC LIMIT 1),
					Airline_Contact_Type__c, MobilePhone, Account.Name 
					FROM Contact 
					WHERE AccountId = :accountId 
					ORDER BY User_Portal_Status__c DESC, Designated_IFAP_Contact__c DESC
					LIMIT :recs
				];
		}
		return keyContacts;
	}

	public static List<Portal_Application_Right__c> searchPortalServicesForAccountAndContacts(Id accountId, Set<Id> contactsIds) {
		String account_15_digit_id = accountId.to15();
		List<Portal_Application_Right__c> portalServicesList = [SELECT Id, Name, Application_Name__c, Access_Status_Reason__c, Right__c, Contact__c 
										FROM Portal_Application_Right__c  
										WHERE Account__c = :account_15_digit_id AND Contact__c IN :contactsIds
										ORDER BY Contact__c
									];
		return portalServicesList;
	}

	public static Map<Id, List<Portal_Application_Right__c>> getPortalServicesByContact(List<Contact> contactList, List<Portal_Application_Right__c> portalServicesList) {
		Map<Id, List<Portal_Application_Right__c>> tmpContactPortalServices = new Map<Id, List<Portal_Application_Right__c>>();
		for(Contact con : contactList) {
			List<Portal_Application_Right__c> tmpPortalServices = new List<Portal_Application_Right__c>();
			for (Portal_Application_Right__c par: portalServicesList) { 
				if (con.Id == par.Contact__c) {
					tmpPortalServices.add(par);
				}
			}
			if (tmpPortalServices.size()> 0) {
				tmpContactPortalServices.put(con.Id, tmpPortalServices);
			}
		}
		return tmpContactPortalServices;
	}



	public class KeyContact {
		@AuraEnabled public Id contactId {get;set;}
		@AuraEnabled public String contactLink {get;set;}
		@AuraEnabled public String contactName {get;set;}
		@AuraEnabled public String accountName {get;set;}
		@AuraEnabled public String accountLink {get;set;}
		@AuraEnabled public String accountIATACode {get;set;}
		@AuraEnabled public String contactType {get;set;}
		@AuraEnabled public String title {get;set;}
		@AuraEnabled public String phone {get;set;}
		@AuraEnabled public String mobile {get;set;}
		@AuraEnabled public String email {get;set;}
		@AuraEnabled public String status {get;set;}
		@AuraEnabled public String AccountCountryName {get;set;}
		@AuraEnabled public String AccountRegionName {get;set;}
		@AuraEnabled public String AccountTypeCustomer {get;set;}
		@AuraEnabled public String lastActivityDate {get;set;}
		@AuraEnabled public Boolean selected {get;set;}
		@AuraEnabled public List<Portal_Application_Right__c> portalServices {get;set;}

		public KeyContact(Contact con, List<Portal_Application_Right__c> portalServices, Boolean selected) {
			Case contactCase = new Case();
			if (con.Cases != null && !con.Cases.isEmpty()) { contactCase = con.Cases; }
			

			this.contactId = con.Id;
			this.contactLink = '/' + con.Id;
			this.contactName = con.Name;
			this.accountName = con.Account.Name;
			this.accountLink = '/' + con.AccountId;
			this.contactType = con.Airline_Contact_Type__c;
			this.title = con.Title;
			this.phone = con.Phone;
			this.mobile = con.MobilePhone;
			this.email = con.Email;
			this.status = con.Status__c;
			this.lastActivityDate = (contactCase.CreatedDate != null) ? String.valueOf(contactCase.CreatedDate) : '';
			this.AccountCountryName = con.Account.IATA_Iso_Country_Name__c;
			this.AccountRegionName = con.Account.Region_formula__c;
			this.AccountTypeCustomer = con.Account.Account_Type__c;
			this.accountIATACode = con.Account.IATACode__c;
			this.portalServices = portalServices;
			this.selected = selected;
		}
	}
}