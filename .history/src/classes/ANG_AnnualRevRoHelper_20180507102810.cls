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
	public List<AMS_Accreditation_Contact__c> previousOwners {
		get {return this.ca.fw.previousOwners;}
		set;
	}
	public List<AMS_Accreditation_Contact__c> currentOwners {
		get {return this.ca.fw.currentOwners;}
		set;
	}
	public List<AMS_Accreditation_Contact__c> previousCompanies {
		get {return this.ca.fw.previousCompanies;}
		set;
	}
	public List<AMS_Accreditation_Contact__c> currentCompanies {
		get {return this.ca.fw.currentCompanies;}
		set;
	}

	// CONSTRUCTOR
	public ANG_AnnualRevRoHelper(ANG_AnnualRevRoCurrentAccount ca) {
		this.ca = ca;
	}
}