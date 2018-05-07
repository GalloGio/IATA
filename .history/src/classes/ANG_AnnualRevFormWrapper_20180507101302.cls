public with sharing class ANG_AnnualRevFormWrapper {
	public AMS_Pax_Accreditation_Form__c newForm {get; set;}
	public List<AMS_Accreditation_Contact__c> previousOwners {get; set;}
	public List<AMS_Accreditation_Contact__c> previousCompanies {get; set;}
	public List<AMS_Accreditation_Contact__c> currentOwners {get; set;}
	public List<AMS_Accreditation_Contact__c> currentCompanies {get; set;}

	public FormWrANG_AnnualRevFormWrapperapper(AMS_Pax_Accreditation_Form__c newForm,
						List<AMS_Accreditation_Contact__c> previousOwners,
						List<AMS_Accreditation_Contact__c> previousCompanies,
						List<AMS_Accreditation_Contact__c> currentOwners,
						List<AMS_Accreditation_Contact__c> currentCompanies) {

		this.previousOwners = previousOwners;
		this.previousCompanies = previousCompanies;
		this.currentOwners = currentOwners;
		this.currentCompanies = currentCompanies;
	}

	public ANG_AnnualRevFormWrapper() {}
}