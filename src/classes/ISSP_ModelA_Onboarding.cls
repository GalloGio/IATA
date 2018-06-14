public class ISSP_ModelA_Onboarding {
	
	public Case onBoardingOSCARCase {get; private set;}
	public AMS_Accreditation_Country_CheckList__c countryChecklist {get; private set;}
	public List<AMS_Accreditation_Requirement__c> countryRequirementsList {get; private set;}

	public ISSP_ModelA_Onboarding() {
		fetchOnBoardingOSCARCase();
		fetchCountryRequirementsList();
	}

	private void fetchOnBoardingOSCARCase() {
		if (ApexPages.currentPage().getParameters().containsKey('caseId')) {
			this.onBoardingOSCARCase = [SELECT Id, AccountId FROM Case WHERE Id = :ApexPages.currentPage().getParameters().get('caseId')];
		}
	}

	private void fetchCountryRequirementsList() {
		if (this.onBoardingOSCARCase != null) {
			//ONLY ONE CHCKLIST FOR TRAVEL AGENT??
			this.countryChecklist = [SELECT Id, IATA_ISO_Country__c FROM AMS_Accreditation_Country_CheckList__c WHERE IATA_ISO_Country__c IN (SELECT IATA_ISO_Country__c FROM Account WHERE Id = :this.onBoardingOSCARCase.AccountId) and Operation__c = 'Travel Agent'];
			if (this.countryChecklist != null) {
				//RecordTypeId iepModelA = AMS_Utils.RECTYPE_IEP_MODEL_A;
				this.countryRequirementsList = [SELECT Id, File_Identifier2__c, Requirement_text__c, Name, File_to_Upload__c FROM AMS_Accreditation_Requirement__c WHERE AMS_Accreditation_Country_CheckList__c = :this.countryChecklist.Id AND RecordTypeId = :AMS_Utils.RECTYPE_IEP_MODEL_A];
			}
		}
	}

	public void submitForm() {
		if (validateAttachedFiles()) {
			for (AMS_Accreditation_Requirement__c thisReq : this.countryRequirementsList) {
				System.debug('rui1: ' + thisReq.File_Identifier2__c);
			}
			System.debug('rui5');
		} else {
			System.debug('rui4');
		}

	}

	private boolean validateAttachedFiles() {

		boolean errorFound = false;

		Map<String, String> folderMap = new Map<String, String>();
    	folderMap = ISSP_SELECTOR.getMapAmazonFileIdentifiers(this.onBoardingOSCARCase.Id);

    	for (AMS_Accreditation_Requirement__c thisReq : this.countryRequirementsList) { 
            if (!folderMap.containsKey(thisReq.File_Identifier2__c) && thisReq.File_to_Upload__c == 'Mandatory') {
                ApexPages.Message myMsg;
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Please_Upload + ' ' + thisReq.Name);
                ApexPages.addMessage(myMsg);

                errorFound = true;
            }
    	}

    	return !errorFound;
    }
}