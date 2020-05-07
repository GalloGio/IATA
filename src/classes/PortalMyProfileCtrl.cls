public without sharing class PortalMyProfileCtrl {

	/*
	* @description Return the Contact Details.
	* @params
	* @return Contact
	*/
	@AuraEnabled
	public static ContactWrapper getContactInfo() {
		User loggedUser = CSP_Utils.getLoggedUser();

		List<Contact> con = [SELECT Id, Name, Title, DSE__DS_Company__c, Email, Membership_Function__c, FirstName, LastName, ID_Card_Holder__c, Birthdate, Additional_Email__c
		FROM Contact
		WHERE Id = :loggedUser.contactId];


		ContactWrapper wrapper = new ContactWrapper();
		wrapper.contact = con[0];

		List <ID_Card__c> cardList = [SELECT Id, VER_Number__c, Valid_To_Date__c, Photo__c, Card_Status__c, Name_on_ID_Card__c FROM ID_Card__c
		WHERE Related_Contact__c = :loggedUser.contactId
		//AND Is_Active_Card__c = :true
		ORDER BY Valid_To_Date__c DESC];

		if (!cardList.isEmpty()){
			wrapper.cardNumber = (cardList[0].VER_Number__c != null) ? cardList[0].VER_Number__c : '';
			wrapper.cardDate   = (cardList[0].Valid_To_Date__c != null) ? cardList[0].Valid_To_Date__c.format() : '';
			wrapper.cardPhoto  = (cardList[0].Photo__c != null) ? cardList[0].Photo__c : '';
			wrapper.cardName   = (cardList[0].Name_on_ID_Card__c != null) ? cardList[0].Name_on_ID_Card__c : '';
			wrapper.cardStatus = (cardList[0].Card_Status__c != null) ? cardList[0].Card_Status__c : '';
		}

		List<Training_Contact_Role_Details__c> trainingList = [SELECT Id, UserId__c, Username__c, 
						Country_Reference__c, Country__c, 
						State_Reference__c, State_Name__c, State_Reference__r.iso_code__c,
						City_Reference__c, City_Name__c,
						Street__c, Street2__c,
						Postal_Code__c,PO_Box_Address__c
					FROM Training_Contact_Role_Details__c
					WHERE Account_Contact_Role__r.Contact__c = :loggedUser.contactId 
					AND Account_Contact_Role__r.Contact_Role_Name__c = 'Trainee'];

		//we are only expecting to have a unique account contact role with contact role name equal to trainee
		if(!trainingList.isEmpty()){
			
			Training_Contact_Role_Details__c tcrd = trainingList[0];
			wrapper.trainingUserId = (tcrd.UserId__c != null) ? tcrd.UserId__c : '';
			wrapper.trainingUsername = (tcrd.Username__c != null) ? tcrd.Username__c : '';
			wrapper.shippingCountryRef = (tcrd.Country_Reference__c != null) ? tcrd.Country_Reference__c : '';
			wrapper.shippingCountry = (tcrd.Country__c != null) ? tcrd.Country__c : '';
			// wrapper.shippingStateRef = ((String)tcrd.State_Reference__c != null) ? (String)tcrd.State_Reference__c : '';
			wrapper.shippingState = (tcrd.State_Name__c != null) ? tcrd.State_Name__c : '';
			wrapper.shippingPostalCode = (tcrd.Postal_Code__c != null) ? tcrd.Postal_Code__c : '';
			wrapper.shippingPOBoxAddress = (tcrd.PO_Box_Address__c != null) ? tcrd.PO_Box_Address__c : '';
			wrapper.shippingCityRef = ((String)tcrd.City_Reference__c != null) ? (String)tcrd.City_Reference__c : '';
			wrapper.shippingCity = (tcrd.City_Name__c != null) ? tcrd.City_Name__c : '';
			wrapper.shippingStreet1 = (tcrd.Street__c != null) ? tcrd.Street__c : '';
			wrapper.shippingStreet2 = (tcrd.Street2__c != null) ? tcrd.Street2__c : '';
			wrapper.trainingId = (tcrd.Id != null) ? tcrd.Id : '';

		
		}

		return wrapper;
	}


	public class ContactWrapper{
		@AuraEnabled
		public Contact contact;

		@AuraEnabled
		public String cardNumber;

		@AuraEnabled
		public String cardDate;

		@AuraEnabled
		public String cardPhoto;

		@AuraEnabled
		public String cardName;

		@AuraEnabled
		public String cardStatus;

		@AuraEnabled
		public String trainingUsername;

		@AuraEnabled
		public String trainingUserId;

		@AuraEnabled
		public String shippingCountryRef;

		@AuraEnabled
		public String shippingCountry;

		@AuraEnabled
		public String shippingStateRef;

		@AuraEnabled
		public String shippingState;

		@AuraEnabled
		public String shippingPostalCode;
		
		@AuraEnabled
		public String shippingPOBoxAddress;
		
		@AuraEnabled
		public String shippingCityRef;

		@AuraEnabled
		public String shippingCity;

		@AuraEnabled
		public String shippingStreet1;

		@AuraEnabled
		public String shippingStreet2;

		@AuraEnabled
		public String trainingId;
	}
}