public with sharing class ANG_AnnualRevRoHelper {
	public ANG_AnnualRevRoCurrentAccount ca {get; set;}

	public ANG_AnnualRevRoHelper(ANG_AnnualRevRoCurrentAccount ca) {
		this.ca = ca;
	}

	public AMS_Pax_Accreditation_Form__c getNewForm() {
		return this.ca.fw.newForm;
	}

	public Account getCurrentAccount() {
		return this.ca.account;
	}

	public List<AMS_Accreditation_Contact__c> getPreviousOwners() {
		return this.ca.fw.previousOwners;
	}

	public List<AMS_Accreditation_Contact__c> getCurrentOwners() {
		return this.ca.fw.currentOwners;
	}

	public List<AMS_Accreditation_Contact__c> getPreviousCompanies() {
		return this.ca.fw.previousCompanies;
	}

	public List<AMS_Accreditation_Contact__c> getCurrentCompanies() {
		return this.ca.fw.currentCompanies;
	}
}