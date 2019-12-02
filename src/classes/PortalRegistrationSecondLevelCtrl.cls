public without sharing class PortalRegistrationSecondLevelCtrl {

	@AuraEnabled(cacheable=true)
	public static List<WrappedCountry> getISOCountries(Id countryId) {
		List<WrappedCountry> returnedWrappedCountries = new List<WrappedCountry>();
		List<WrappedCountry> wrappedCountries = new List<WrappedCountry>();
		for(IATA_ISO_Country__c iso : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
			if (iso.Name != 'All Countries' &&  iso.Name != 'NO COUNTRY'){
				wrappedCountries.add(new WrappedCountry(iso, countryId == iso.Id));
			}
			else if(iso.Name == 'NO COUNTRY'){
				returnedWrappedCountries.add(new WrappedCountry(iso, countryId == iso.Id));
			}
		}
		returnedWrappedCountries.addAll(wrappedCountries);
		return returnedWrappedCountries;
	}

	@AuraEnabled
	public static Contact getContactInfo() {
		User loggedUser = CSP_Utils.getLoggedUser();

		List<Contact> con = [SELECT Id, FirstName, LastName, Salutation, Birthdate, Date_of_Birth__c, Title,
									Membership_Function__c, Function__c, User_Portal_Status__c, AccountId,
									Email, Additional_Email__c, Phone, OtherPhone,
									Account.Name, Account.IATA_ISO_Country__r.Id, Account.IATA_ISO_Country__r.Name,
									Account.Sector__c, Account.Category__c, Account.Is_General_Public_Account__c,
									Shipping_Address__c, Shipping_Address__r.city__c, Shipping_Address__r.City_Reference__c,
									Shipping_Address__r.State__c, Shipping_Address__r.State_Reference__c,
									Shipping_Address__r.State_Reference__r.iso_code__c,
									Shipping_Address__r.PO_Box__c,
									Shipping_Address__r.Country__c, Shipping_Address__r.Country_Reference__c,
                                    Shipping_Address__r.Street__c, Shipping_Address__r.Postal_Code__c,
									Shipping_Address__r.Street2__c
		FROM Contact
		WHERE Id = :loggedUser.contactId];

		if(con.isEmpty()){
			return null;
		}

		return con[0];
	}

	@AuraEnabled
	public static List<PicklistEntry> getContactJobFunctionValues(String selectedContactJobFunctions){
		List<PicklistEntry> values =  new  List<PicklistEntry>();

		Set<String> selectedContactJobFunctionsSet;
		if(selectedContactJobFunctions == null){
			selectedContactJobFunctionsSet = new Set<String>();
		}
		else{
			selectedContactJobFunctionsSet = new Set<String>(selectedContactJobFunctions.split(';'));
		}

		List<Schema.PicklistEntry> controllingFieldValues = Schema.Contact.Function__c.getDescribe().getPickListValues();
		for (Schema.PicklistEntry p : controllingFieldValues){
		   values.add(new PicklistEntry(p.getLabel(), p.getValue(), selectedContactJobFunctionsSet.contains(p.getValue())));
		}
		return values;
	}

	@AuraEnabled
	public static void linkContactToExistingAccount(Contact con, Id accountId){
		if(accountId != null) {
			con.AccountId = accountId;
			con.User_Portal_Status__c = 'Pending Approval';
			update con;
		}
	}

	public class WrappedCountry{
		@AuraEnabled
		IATA_ISO_Country__c country { get; private set; }

		@AuraEnabled
		Boolean isSelected { get; set; }

		public WrappedCountry(IATA_ISO_Country__c country, Boolean isSelected){
			this.country = country;
			this.isSelected = isSelected;
		}
	}

	public class PicklistEntry {
		@AuraEnabled
		public String label;

		@AuraEnabled
		public String value;

		@AuraEnabled
		public List<PicklistEntry> dependentValues;

		@AuraEnabled
		public Boolean isSelected;

		public PicklistEntry(String label, String value, Boolean isSelected){
			this.label = label;
			this.value = value;
			this.isSelected = isSelected;
			this.dependentValues = new List<PicklistEntry>();
		}
	}
}