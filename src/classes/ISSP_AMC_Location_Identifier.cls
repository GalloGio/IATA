/*
	Class Name: ISSP_AMC_Location_Identifier.cls
	Related Classes:

	Copyright @Right IT Services

	Purpose: Controller Class for ISSP_AMC_Location_Identifier.page

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	TIAGO MENDES		30-10-2018   	INITIAL DEVELOPMENT
	1.0         DAVID BENTO
*/
public without sharing class ISSP_AMC_Location_Identifier {


	public Account accountRecord {get;set;}
	public Boolean isLocation {get;set;}
	public static Boolean isLoc{get;set;}

	public Boolean isSISUser{get;set;}

	public PageReference init(){
		if(participation.Case__c != null && participation.Case__r.Status != ISSP_AMC_Constants.AMC_CASE_STATUS_DRAFT){
			PageReference pr = new PageReference('/ISSP_Case?caseId=' + participation.Case__c + '&mid=M1S2');
			pr.setRedirect(true);
			return pr;
		}


		return null;
	}


	public List <SelectOption> locationList {
		get{
			List <SelectOption> options = new List<SelectOption>();
			List <Schema.PicklistEntry> fieldResult = Participation_Online_Application__c.Location_Type__c.getDescribe().getPicklistValues();
			for(Schema.PicklistEntry f : fieldResult){
				options.add(new SelectOption(f.getValue(), f.getLabel()));
			}
			return options;
		}
	}


	public void userInformation(){


		accountRecord = ISSP_AMC_DAO.getAccountInfo();
	}

	/* DUMMY TO DELETE */
	public String credentialName  {get;set;}

	/* END DUMMY TO DELETE */

	/* GENERAL */
	public Participation_Online_Application__c participation {get;set;}
	public String displayLanguage { get { return UserInfo.getLanguage(); } }
	public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); } }

	public List <SelectOption> countryList {
		get {

			return ISSP_AMC_DAO.countryList;
		}
	}
	public List <SelectOption> salutationList {
		get {
			if(salutationList == null){
				List <SelectOption> optionList = new List <SelectOption>();

				Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

				for( Schema.PicklistEntry f : ple){
					optionList.add(new SelectOption( f.getValue(),f.getLabel()));
				}
				return optionList;
			}
			return salutationList;
		}
	}

	public Map <String, String> componentByOperation { get;set; }

	/* STEP 1 */
	public String selectedOperationType { get; set; }
	public List <SelectOption> operationTypes { get; set; }
	public Boolean isSaved { get; set; }
	public Boolean displayMessage { get; set; }
	public String message { get; set; }
	public String severity { get; set; }
	public Boolean hasError { get; set; }

	public PageReference saveParticipation(){

		displayMessage = true;
		message = '';
		severity = '';
		hasError = false;

		ISSP_AMC_DAO.saveForm(participation, appRequirementList, step, ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE);

		List <Apexpages.Message> msgs = ApexPages.getMessages();
		if(msgs != null && !msgs.isEmpty()){
			for(Apexpages.Message msg : msgs){
				if(msg.getSeverity() == Apexpages.Severity.CONFIRM){
					severity = 'success';
				}
				else if(msg.getSeverity() == Apexpages.Severity.ERROR){
					severity = 'danger';
					hasError = true;
				}
				else {
					severity = ('' + msg.getSeverity()).toLowerCase();
				}
			}
			if(severity == 'success'){
				message = '<b>Success!</b><br /><br />';
			}
			else if (severity == 'danger'){
				message = '<b>Error!</b><br /><br />';
			}
			else if (severity == 'warning'){
				message = '<b>Warning!</b><br /><br />';
			}
			else if (severity == 'info'){
				PageReference pr = new PageReference('/ISSP_Case?caseId=' + participation.Case__c + '&mid=M1S2');
				pr.setRedirect(true);
				return pr;
			}

			for(Apexpages.Message msg : msgs){
				message += msg.getDetail() + '<br />';
			}
			displayMessage = true;
		}
		CalculateWhichComponentsToShow();
		return null;
	}

	public String step { get; set; }

	public ISSP_AMC_Location_Identifier() {
		isLocation = true;
		isLoc = true;
		userInformation();
		if(accountRecord.SIS_Status__c == 'Active'){
			isSISUser = true;
		}

		displayMessage = false;
		String participationId = Apexpages.currentPage().getParameters().get('participationId');
		appRequirementList = new List <ISSP_AMC_DAO.AplicationRequirements>();

		system.debug('APEXPAGES PARTICIPATION ID LOCATION '+ participationId);

		step = Apexpages.currentPage().getParameters().get('step');

		step = '1';

		participation = ISSP_AMC_DAO.getCompleteDesignatorCode(participationId);

		System.debug('DB : participation ' + participation);
		System.debug('DB : appRequirementList' + appRequirementList);


		CalculateWhichComponentsToShow();
		System.debug('DB : appRequirementList' + appRequirementList);
	}

	public void changeListReqs(){
		step ='1';
		CalculateWhichComponentsToShow();
		ISSP_AMC_DAO.saveForm(participation, appRequirementList, step, ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE);

	}

	/* STEP 2 */

	public Boolean ISSP_AMC_LocationAirportHeliportForm { get; set; }
	public Boolean ISSP_AMC_Metropolitan_Area { get; set; }
	public Boolean ISSP_AMC_LocationOfflinePoint { get; set; }
	public Boolean ISSP_AMC_TermsAndConditions { get; set; }
	public Boolean ISSP_AMC_Upload_Files{ get; set; }
	public Boolean ISSP_AMC_CurrentStructureLocation{ get; set; }
	public Boolean ISSP_AMC_CAALetterOpeningDate{ get; set; }
	public Boolean ISSP_AMC_CommercialScheduledOperations{ get; set; }
	public Boolean ISSP_AMC_TrafficAgreement_Valid_IATA_Code{ get; set; }
	public Boolean ISSP_AMC_Metropolitan_AirportB{get;set;}
	public Boolean ISSP_AMC_EntityContactData{get;set;}


	public void CalculateWhichComponentsToShow(){

		ISSP_AMC_LocationAirportHeliportForm = false;
		ISSP_AMC_Metropolitan_Area = false;
		ISSP_AMC_LocationOfflinePoint = false;
		ISSP_AMC_TermsAndConditions = false;
		ISSP_AMC_Upload_Files = false;
		ISSP_AMC_CurrentStructureLocation = false;
		ISSP_AMC_CAALetterOpeningDate = false;
		ISSP_AMC_CommercialScheduledOperations = false;
		ISSP_AMC_TrafficAgreement_Valid_IATA_Code = false;
		ISSP_AMC_Metropolitan_AirportB = false;
		ISSP_AMC_EntityContactData = false;


		calculateApplicationRequirementsToShow();

		if(componentByOperation != null){
			for(String componentKey : componentByOperation.keySet()){
				switch on componentKey{
					when 'ISSP_AMC_LocationAirportHeliportForm' {
						ISSP_AMC_LocationAirportHeliportForm = IsToShowComponent('ISSP_AMC_LocationAirportHeliportForm');
					}
					when 'ISSP_AMC_Metropolitan_Area' {
						ISSP_AMC_Metropolitan_Area = IsToShowComponent('ISSP_AMC_Metropolitan_Area');
					}
					when 'ISSP_AMC_LocationOfflinePoint' {
						ISSP_AMC_LocationOfflinePoint = IsToShowComponent('ISSP_AMC_LocationOfflinePoint');
					}
					when 'ISSP_AMC_Upload_Files' {
						ISSP_AMC_Upload_Files = IsToShowComponent('ISSP_AMC_Upload_Files');
					}
					when 'ISSP_AMC_TermsAndConditions' {
						ISSP_AMC_TermsAndConditions = IsToShowComponent('ISSP_AMC_TermsAndConditions');
					}
					when 'ISSP_AMC_CurrentStructureLocation' {
						ISSP_AMC_CurrentStructureLocation = IsToShowComponent('ISSP_AMC_CurrentStructureLocation');
					}
					when 'ISSP_AMC_CAALetterOpeningDate' {
						if(participation.Date_when_airport_has_been_operational__c == null || String.isEmpty(participation.Date_when_airport_has_been_operational__c)){
							ISSP_AMC_CAALetterOpeningDate = IsToShowComponent('ISSP_AMC_CAALetterOpeningDate');
						}
						else if(participation.Date_when_airport_has_been_operational__c != null){
							if(!String.isEmpty(participation.Date_when_airport_has_been_operational__c)){
								if(Date.parse(participation.Date_when_airport_has_been_operational__c) > Date.today()){
									ISSP_AMC_CAALetterOpeningDate = IsToShowComponent('ISSP_AMC_CAALetterOpeningDate');
								}
							}
						}
					}
					when 'ISSP_AMC_CommercialScheduledOperations' {
						ISSP_AMC_CommercialScheduledOperations = IsToShowComponent('ISSP_AMC_CommercialScheduledOperations');
					}
					when 'ISSP_AMC_TrafficAgreement_Valid_IATA_Code' {
						ISSP_AMC_TrafficAgreement_Valid_IATA_Code = IsToShowComponent('ISSP_AMC_TrafficAgreement_Valid_IATA_Code');
					}
					when 'ISSP_AMC_Metropolitan_AirportB' {
						ISSP_AMC_Metropolitan_AirportB = IsToShowComponent('ISSP_AMC_Metropolitan_AirportB');
					}
					when else {

					}
				}
			}
		}
	}

	public Boolean IsToShowComponent(String componentKey){
		Boolean isToShow = false;
		if(componentByOperation != null && componentByOperation.get(componentKey) != null){
			String []componentKeyList = componentByOperation.get(componentKey).split(';');
			for(String componentKetItem : componentKeyList){
				if(participation.Location_Type__c == 'Airport' && componentKetItem.trim() == 'Airport'){
					isToShow = true;
				}
				if(participation.Location_Type__c == 'Heliport' && componentKetItem.trim() == 'Heliport'){
					isToShow = true;
				}
				if(participation.Location_Type__c == 'Bus Station' && componentKetItem.trim() == 'Bus Station'){
					isToShow = true;
				}
				if(participation.Location_Type__c == 'Ferry Port' && componentKetItem.trim() == 'Ferry Port'){
					isToShow = true;
				}
				if(participation.Location_Type__c == 'Railway Station' && componentKetItem.trim() == 'Railway Station'){
					isToShow = true;
				}
				if(participation.Location_Type__c == 'Off-line Point' && componentKetItem.trim() == 'Off-line Point'){
					isToShow = true;
				}
				if(participation.Location_Type__c == 'Metropolitan Area' && componentKetItem.trim() == 'Metropolitan Area'){
					isToShow = true;
				}
				if(isToShow){
					break;
				}
			}
		}
		return isToShow;
	}

	/* STEP 3 */

	public List <ISSP_AMC_DAO.AplicationRequirements> appRequirementList { get; set; }
	public List <String> selectedOperationTypeForRequirements { get; set; }

	private void calculateApplicationRequirementsToShow(){
		//try{

			if(appRequirementList == null){
				appRequirementList = new List <ISSP_AMC_DAO.AplicationRequirements>();
			}
			if(componentByOperation == null){
				componentByOperation = new Map <String, String>();
			}

			selectedOperationTypeForRequirements = new List<String>();
			selectedOperationTypeForRequirements.add('\'' + participation.Location_Type__c +'\'');

			ISSP_AMC_DAO.calculateApplicationRequirementsToShow(this.appRequirementList, selectedOperationTypeForRequirements, componentByOperation, participation, step, ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE);

			system.debug('DB2 : '+this.appRequirementList);
			system.debug('DB3 : '+selectedOperationTypeForRequirements);

			for(Integer i = 0; i <appRequirementList.size();i++){

				if(participation.Date_when_airport_has_been_operational__c != null){
					if(participation.Date_when_airport_has_been_operational__c != ''){
						if(Date.parse(participation.Date_when_airport_has_been_operational__c) <= Date.today()){
							if(appRequirementList[i].noteCustomLabel == 'ISSP_AMC_CAALETTEROPENINGDATE_TEXT'){
								appRequirementList[i].isToShow = false;
							}
						}
					}
				}

				if(accountRecord.SIS_Status__c == 'Active'){
					if(appRequirementList[i].noteCustomLabel == 'ISSP_AMC_CONTACT_DATA' ){
						appRequirementList[i].isToShow = false;
					}
				}
				if(appRequirementList[i].noteCustomLabel == 'ISSP_AMC_TERMS_AND_CONDITIONS'){
					appRequirementList[i].isToShow = false;
				}

			}
	}
}
