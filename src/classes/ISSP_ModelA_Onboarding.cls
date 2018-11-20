public class ISSP_ModelA_Onboarding {
	
	public Case onBoardingOSCARCase {get; private set;}
	public AMS_Accreditation_Country_CheckList__c countryChecklist {get; private set;}
	public List<AMS_Accreditation_Requirement__c> countryRequirementsList {get; private set;}
	public String region {private get; private set;}

	public ISSP_ModelA_Onboarding() {

		fetchOnBoardingOSCARCase();
		fetchCountryRequirementsList();
	}

	private void fetchOnBoardingOSCARCase() {
		if (ApexPages.currentPage().getParameters().containsKey('caseId')) {
			this.onBoardingOSCARCase = [SELECT Id, AccountId, Region__c, OSCAR__c, Owner.Name FROM Case WHERE Id = :ApexPages.currentPage().getParameters().get('caseId')];
		}
	}

	private void fetchCountryRequirementsList() {
		String userLanguage = UserInfo.getLanguage();
        if(userLanguage == null) userLanguage = 'en_US';
        List<AMS_Accreditation_Requirement__c> auxCountryRequirementsList;

		if (this.onBoardingOSCARCase != null) {
			this.countryChecklist = [SELECT Id, IATA_ISO_Country__c, IATA_ISO_Country__r.Region__c FROM AMS_Accreditation_Country_CheckList__c WHERE IATA_ISO_Country__c IN (SELECT IATA_ISO_Country__c FROM Account WHERE Id = :this.onBoardingOSCARCase.AccountId) and Operation__c = 'Travel Agent'];
			if (this.countryChecklist != null) {
				this.region = this.countryChecklist.IATA_ISO_Country__r.Region__c;
				auxCountryRequirementsList = [SELECT Id, File_Identifier2__c, Requirement_text__c, Name, File_to_Upload__c, Language__c FROM AMS_Accreditation_Requirement__c WHERE AMS_Accreditation_Country_CheckList__c = :this.countryChecklist.Id AND RecordTypeId = :AMS_Utils.RECTYPE_IEP_MODEL_A];
			}

			if(!auxCountryRequirementsList.isEmpty()){
				this.countryRequirementsList = new List<AMS_Accreditation_Requirement__c>();
            	Set<String> availableLanguages = new Set<String>();
                Boolean first = false;
                String firstLanguage = '';

            	for(AMS_Accreditation_Requirement__c req : auxCountryRequirementsList){
            		if(!first) {
                        firstLanguage = req.Language__c;
                        first = true;
                    }
                    availableLanguages.add(req.Language__c);
            	}

            	String filterLanguage = '';
                String checkLanguage = '';

                Map<String, String> languagesMap = ISSP_Selector.getLanguagesMap();

                if (languagesMap.containsKey(userLanguage)) {
                    checkLanguage = languagesMap.get(userLanguage);
                } else {
                    checkLanguage = 'English';
                }

                // User's language is in the list of requirements
                if(availableLanguages.contains(checkLanguage)) {
                    filterLanguage = checkLanguage;
                } else if (availableLanguages.contains('English')) {
                    filterLanguage = 'English';
                } else {
                    filterLanguage = firstLanguage;
                }

                for(AMS_Accreditation_Requirement__c req : auxCountryRequirementsList) {

                    if (filterLanguage == req.Language__c) {

                        if (req.Requirement_text__c != null) {
                            req.Requirement_text__c = req.Requirement_text__c.replaceAll('style[/a-zA-Z0-9="-: ;]*','');
                            req.Requirement_text__c = req.Requirement_text__c.replaceAll('<b>','');
                            req.Requirement_text__c = req.Requirement_text__c.replaceAll('</b>','');
                        }

                        this.countryRequirementsList.add(req);
                    }
                }
            }
		}
	}

	public PageReference submitForm() {
		if (validateAttachedFiles()) {
			AMS_OSCAR__c oscar = [SELECT Id, Account__c, Account__r.Id, OwnerId FROM AMS_OSCAR__c WHERE Id = :this.onBoardingOSCARCase.OSCAR__c];

			oscar.OwnerId = getRegionalQueue();
			update oscar;

			this.onBoardingOSCARCase.Dossier_reception_date__c = Datetime.now();
			update this.onBoardingOSCARCase;

			return new PageReference('/ISSP_Homepage');
		}

		return null;
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

    public PageReference cancel(){

        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if (retURL == null) {
            return new Pagereference('/ISSP_Homepage');
        } else {
            return new Pagereference(retURL);
        }
    }

    private Id getRegionalQueue() {
        //Available queue names
        Id qId;

        Set<String> queueNames = new Set<String> {'AgencyManagementAP', 'AgencyManagementAfricaME', 'AgencyManagementAmericas', 'AgencyManagementChinaNAsia', 'CasesACCEuropeOffOnshore'};
        Map<String, QueueSobject> mapRegionalQueue = new Map<String, QueueSobject>();
        //Build map queue.name -> queue
        for (QueueSobject queue : [Select Queue.Id, Queue.DeveloperName From QueueSobject Where Queue.DeveloperName in: queueNames]) {
            mapRegionalQueue.put(queue.Queue.DeveloperName, queue);
        }

        //Assigns queue according to region
        if (this.region == 'Africa & Middle East') {
            if (mapRegionalQueue.get('AgencyManagementAfricaME') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAfricaME').Queue.Id;
            }

        } else if (this.region == 'Americas') {
            if (mapRegionalQueue.get('AgencyManagementAmericas') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAmericas').Queue.Id;
            }

        } else if (this.region == 'Asia & Pacific') {
            if (mapRegionalQueue.get('AgencyManagementAP') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAP').Queue.Id;
            }
        } else if (this.region == 'China & North Asia') {
            if (mapRegionalQueue.get('AgencyManagementChinaNAsia') != null) {
                qId = mapRegionalQueue.get('AgencyManagementChinaNAsia').Queue.Id;
            }
        } else if (this.region == 'Europe') {
            if (mapRegionalQueue.get('CasesACCEuropeOffOnshore') != null) {
                qId = mapRegionalQueue.get('CasesACCEuropeOffOnshore').Queue.Id;
            }
        }

        return qId;
    }

    public Pagereference securityCheck() {

        if (this.onBoardingOSCARCase.Id != null && !this.onBoardingOSCARCase.Owner.Name.startsWith('Model A Onboarding')) {
            return new Pagereference('/ISSP_Case?caseId=' + this.onBoardingOSCARCase.Id);
        }

        return null;
    }
}