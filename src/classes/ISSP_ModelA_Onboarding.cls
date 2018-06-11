public with sharing class ISSP_ModelA_Onboarding {
	
	public Case onBoardingOSCARCase {get; private set;}
	public AMS_Accreditation_Country_CheckList__c countryChecklist {get; private set;}
	public List<AMS_Accreditation_Requirement__c> countryRequirementsList {get; private set;}

	public ISSP_ModelA_Onboarding() {
		fetchOnBoardingOSCARCase();
		fetchCountryRequirementsList();
	}

	private void fetchOnBoardingOSCARCase() {
		if (ApexPages.currentPage().getParameters().containsKey('caseId')) {
			this.onBoardingOSCARCase = [SELECT Id, BSPCountry__c FROM Case WHERE Id = :ApexPages.currentPage().getParameters().get('caseId')];
		}
	}

	private void fetchCountryRequirementsList() {
		if (this.onBoardingOSCARCase != null) {
			//ONLY ONE CHCKLIST FOR TRAVEL AGENT??
			this.countryChecklist = [SELECT Id, IATA_ISO_Country__c FROM AMS_Accreditation_Country_CheckList__c WHERE IATA_ISO_Country__c = :this.onBoardingOSCARCase.BSPCountry__c AND Operation__c = 'Travel Agent'];
			if (this.countryChecklist != null) {
				this.countryRequirementsList = [SELECT Id FROM AMS_Accreditation_Requirement__c WHERE AMS_Accreditation_Requirement__c = this.countryChecklist.Id];
			}
		}
	}
}