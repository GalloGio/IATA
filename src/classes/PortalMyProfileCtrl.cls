public without sharing class PortalMyProfileCtrl {

	/*
	* @description Return the Contact Details.
	* @params
	* @return Contact
	*/
	@AuraEnabled
	public static ContactWrapper getContactInfo() {
		User loggedUser = CSP_Utils.getLoggedUser();

		List<Contact> con = [SELECT Id, Name, Title, DSE__DS_Company__c, Email, Membership_Function__c, FirstName, LastName, ID_Card_Holder__c, Birthdate
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
	}
}
