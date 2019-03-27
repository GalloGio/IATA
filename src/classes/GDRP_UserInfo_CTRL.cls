public without sharing class GDRP_UserInfo_CTRL {
	@AuraEnabled
    public static Individual retrieveUserInfo(String email) {
		
		// Retrieve from Salesforce lead or contact based on email
		Individual indiv = new Individual();
		
		// Identify if it's a lead or contact
		list<Contact> contacts = [SELECT ID, LastName, FirstName, email, salutation, account.Name, Title, phone, MailingCountry, Membership_Function__c, Department, Industry__c FROM CONTACT WHERE Email = :email ORDER BY pi__last_activity__c, LastModifiedDate];
		if(! contacts.isEmpty()) {
				return contactToIndividual(indiv, contacts[0]);
		}
		list<Lead> leads = [SELECT ID, LastName, FirstName, email, salutation, company, phone, country, industry, Title , Membership_Function__c, Department__c FROM LEAD WHERE Email = :email ORDER BY pi__last_activity__c, LastModifiedDate];
		if(! leads.isEmpty()) {
				return leadToIndividual(indiv, leads[0]);
		}
		return null;
	}

	private static Individual contactToIndividual(Individual indiv, Contact contact) {
		if(contact == null) return null;
		indiv.Token__c = (String)contact.Id; // it's just to transfer contactID in a text field for the UI logic
		indiv.Email__c = contact.email;
		indiv.FirstName = contact.FirstName;
		indiv.LastName = contact.LastName;
		indiv.Salutation = contact.salutation;
		indiv.Company__c = contact.account.Name;
		indiv.Job_Title__c = contact.Title;
		indiv.Phone__c = contact.phone;
		indiv.Country__c = contact.MailingCountry;
		indiv.Industry__c = contact.Industry__c;
		indiv.Job_Function__c = contact.Membership_Function__c;
		indiv.Department__c = contact.Department;
		indiv.Timestamp__c = 'true'; // Transfer a boolean to indicate temporary it's a contact
		return indiv;
	}

private static Individual leadToIndividual(Individual indiv, Lead lead) {
		if(lead == null) return null;
		// it's just to transfer contactID in a text field for the UI logic
		indiv.Token__c = (String)lead.Id;
		indiv.Email__c = lead.email;
		indiv.FirstName = lead.FirstName;
		indiv.LastName = lead.LastName;
		indiv.Salutation = lead.salutation;
		indiv.Company__c = lead.company;
		indiv.Job_Title__c = lead.Title;
		indiv.Phone__c = lead.phone;
		indiv.Country__c = lead.country;
		indiv.Industry__c = lead.industry;
		indiv.Job_Function__c = lead.Membership_Function__c;
		indiv.Department__c = lead.Department__c;
		indiv.Timestamp__c = 'false'; // Transfer a boolean to indicate temporary it's not a contact

		return indiv;
	}
/*
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
	*/

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
		prospect.job_Function = indiv.Job_Function__c;
		prospect.department = indiv.Department__c;
		return prospect;
	}

	@AuraEnabled
    public static Boolean updateUserInfo(String indivJson) {
		// Save to Salesforce lead or contact. The connector will save to Pardot

		Individual indiv = (Individual)JSON.deserialize(indivJson, Individual.class);
		Id sampleid = indiv.Token__c;
		BOolean isContact = sampleid.getsobjecttype() == Schema.Contact.SObjectType;

		if(! isContact) {
			Lead lead = new Lead();
			lead.Id = indiv.Token__c;
			lead.email = indiv.Email__c;
			lead.FirstName = indiv.FirstName;
			lead.LastName = indiv.LastName;
			lead.salutation = indiv.Salutation;
			lead.company = indiv.Company__c;
			lead.phone = indiv.Phone__c;
			lead.country = indiv.Country__c;
			lead.industry = indiv.Industry__c;
			lead.title = indiv.Job_Title__c;
			lead.Membership_Function__c = indiv.Job_Function__c;
			lead.Department__c = indiv.Department__c;
			update lead;
			return true;
		} else {
			Contact contact = new Contact();
			contact.Id = indiv.Token__c;
			contact.email = indiv.Email__c;
			contact.FirstName = indiv.FirstName;
			contact.LastName = indiv.LastName;
			contact.salutation = indiv.Salutation;
			contact.title = indiv.Job_Title__c;
			contact.industry__c = indiv.Industry__c;
			contact.phone = indiv.Phone__c;
			contact.MailingCountry = indiv.Country__c;
			contact.Membership_Function__c = indiv.Job_Function__c;
			contact.Department = indiv.Department__c;
			
			update contact;
			return true;
		}
	}


	@AuraEnabled
	public static PicklistWrapper getPickListValues() {
		PicklistWrapper picklists = new PicklistWrapper();

		List<InnerPicklistWrapper> salutations = new List<InnerPicklistWrapper>();
		List<InnerPicklistWrapper> industries = new List<InnerPicklistWrapper>();
		List<InnerPicklistWrapper> countries = new List<InnerPicklistWrapper>();
		List<InnerPicklistWrapper> jobFunctions = new List<InnerPicklistWrapper>();

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
		// get job functions values from Individual object setup
		Schema.DescribeFieldResult fieldResultJobFunctions = Individual.Job_Function__c.getDescribe();
		List<Schema.PicklistEntry> pleJobFunctions = fieldResultJobFunctions.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : pleJobFunctions){
			jobFunctions.add(new InnerPicklistWrapper(pickListVal.getLabel(), pickListVal.getValue(), false));
		}

		picklists.salutations = salutations;
		picklists.industries = industries;
		picklists.countries = countries;
		picklists.jobFunctions = jobFunctions;

		return picklists;
	}

	@AuraEnabled
	public static String grantAccessToPortal(String indivJson) {
		
		Individual indiv = (Individual)JSON.deserialize(indivJson, Individual.class);
		String encryptedToken = null;
		// Create the lead in Salesforce and create the prospect in Pardot
		Pardot_API.Pardot_Prospect prospectObj = new Pardot_API.Pardot_Prospect();

		prospectObj = individualToPropect(indiv, prospectObj);
		if(Pardot_API.createProspect(prospectObj) ) {
			
			Individual indivInSF = GDPR_Helper.createIndividual(indiv.firstName, indiv.LastName, indiv.Email__c);
			GDPR_Helper.createLead(indiv.firstName, indiv.LastName, indiv.Email__c, indiv.Company__c);
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
		@AuraEnabled
		public List<InnerPicklistWrapper> jobFunctions {get;set;}
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