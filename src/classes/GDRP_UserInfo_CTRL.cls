public without sharing class GDRP_UserInfo_CTRL {
	@AuraEnabled
    public static Individual retrieveUserInfo(String email) {
		
		// Retrieve from Pardot based on email
		Individual indiv = new Individual();
		Pardot_API.Pardot_Prospect prospect = new Pardot_API.Pardot_Prospect();
		try {
			prospect = Pardot_API.getProspect(email);
			if(prospect != null) {
				indiv = prospectToIndividual(indiv, prospect);
			}
		} catch(Exception e) {
			return null;
		} 
		return indiv;
	}

	private static Individual prospectToIndividual(Individual indiv, Pardot_API.Pardot_Prospect prospect) {
		if(prospect == null) return null;

		//indiv.Name = prospect.last_name; // not writable
		indiv.Email__c = prospect.email;
		indiv.FirstName = prospect.first_name;
		indiv.LastName = prospect.last_name;
		indiv.Salutation = prospect.salutation;
		indiv.Company__c = prospect.company;
		indiv.Job_Title__c = prospect.job_title;
		indiv.Phone__c = prospect.phone;
		indiv.Country__c = prospect.country;
		indiv.Industry__c = prospect.industry;

		return indiv;
	}

	private static Pardot_API.Pardot_Prospect individualToPropect(Individual indiv, Pardot_API.Pardot_Prospect prospect) {
		if(indiv == null) return null;

		//indiv.Name = prospect.last_name; // not writable
		prospect.email = indiv.Email__c;
		prospect.first_name = indiv.FirstName;
		prospect.last_name = indiv.LastName;
		prospect.salutation = indiv.Salutation ;
		prospect.company = indiv.Company__c;
		prospect.job_title = indiv.Job_Title__c;
		prospect.phone = indiv.Phone__c;
		prospect.country = indiv.Country__c;
		prospect.industry = indiv.Industry__c;

		return prospect;
	}

	@AuraEnabled
    public static Boolean updateUserInfo(String prospect) {
		
		Pardot_API.Pardot_Prospect prospectObj = (Pardot_API.Pardot_Prospect)JSON.deserializeStrict( prospect, Pardot_API.Pardot_Prospect.class);

		return Pardot_API.updateProspect(prospectObj);
	}


	@AuraEnabled
	public static PicklistWrapper getPickListValues() {
		PicklistWrapper picklists = new PicklistWrapper();

		List<InnerPicklistWrapper> salutations = new List<InnerPicklistWrapper>();
		List<InnerPicklistWrapper> industries = new List<InnerPicklistWrapper>();
		List<InnerPicklistWrapper> countries = new List<InnerPicklistWrapper>();

		// get Salutation values from Individual object setup
		Schema.DescribeFieldResult fieldResultSalutation = Individual.Salutation.getDescribe();
		List<Schema.PicklistEntry> pleSalutations = fieldResultSalutation.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : pleSalutations){
			salutations.add(new InnerPicklistWrapper(pickListVal.getLabel(), pickListVal.getValue(), false));
		}
		// get Industries values from Individual object setup
		Schema.DescribeFieldResult fieldResultIndustries = Individual.Industry__c.getDescribe();
		List<Schema.PicklistEntry> pleIndustries = fieldResultIndustries.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : pleIndustries){
			industries.add(new InnerPicklistWrapper(pickListVal.getLabel(), pickListVal.getValue(), false));
		}
		// get Countries values from Individual object setup
		Schema.DescribeFieldResult fieldResultCountries = Individual.Country__c.getDescribe();
		List<Schema.PicklistEntry> pleCountries = fieldResultCountries.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : pleCountries){
			countries.add(new InnerPicklistWrapper(pickListVal.getLabel(), pickListVal.getValue(), false));
		}

		picklists.salutations = salutations;
		picklists.industries = industries;
		picklists.countries = countries;

		return picklists;
	}

	@AuraEnabled
	public static String grantAccessToPortal(String indivJson) {
		
		Individual indiv = (Individual)JSON.deserialize(indivJson, Individual.class);
		String encryptedToken = null;
		// Create prospect in Pardot so the lead will be created by the connector in SF
		Pardot_API.Pardot_Prospect prospectObj = new Pardot_API.Pardot_Prospect();

		prospectObj = individualToPropect(indiv, prospectObj);
		if(Pardot_API.createProspect(prospectObj) ) {
			
			Individual indivInSF = GDPR_Helper.createIndividual(indiv.firstName, indiv.LastName, indiv.Email__c);
			String tokenizedLink = GDPR_Helper.updateEncryptEmailProcessWithLink(indivInSF, indiv.Email__c);
			GDPR_Helper.sendWelcomeEmail(indiv.Email__c);
			return tokenizedLink;
		}
		return null;

	}

	@AuraEnabled
    public static String checkIfValidToken(String encryptedToken){
		System.debug(encryptedToken);
		String token = Comm_User_Helper.DecryptString(encryptedToken);
		System.debug(token);
		System.debug(String.valueOf(System.TODAY()).left(10));
		System.debug(token.left(10));
		if(token.left(10) == String.valueOf(System.TODAY()).left(10)) {
			String email = token.substring(10);
			// Check if there is already a individual created - means that the guest already access to the portal at least once and individual was created
			if( [SELECT count() FROM Individual WHERE email__c =: email] > 0) return null;
			return email;
		}
		return null;
    }

	public class PicklistWrapper {
		@AuraEnabled
		public List<InnerPicklistWrapper> salutations {get;set;}
		@AuraEnabled
		public List<InnerPicklistWrapper> industries {get;set;}
		@AuraEnabled
		public List<InnerPicklistWrapper> countries {get;set;}
	}

	public class InnerPicklistWrapper {
		@AuraEnabled
		public String label {get;set;}
		@AuraEnabled
		public String value {get;set;}
		@AuraEnabled
		public Boolean isSelected {get;set;}

		public InnerPicklistWrapper(String lab, String val, Boolean selected){
			label = lab;
			value = val;
			isSelected = selected;
		}
	}
}