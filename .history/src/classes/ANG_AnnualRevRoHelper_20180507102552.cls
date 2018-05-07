public with sharing class ANG_AnnualRevRoHelper {
	public ANG_AnnualRevRoCurrentAccount ca {get; set;}
	public AMS_Pax_Accreditation_Form__c newForm {
		get {return this.ca.fw.newForm;}
		set;
	}
	public Account currentAccount {
		get {return this.ca.account;}
		set;
	}


	public ANG_AnnualRevRoHelper(ANG_AnnualRevRoCurrentAccount ca) {
		this.ca = ca;
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