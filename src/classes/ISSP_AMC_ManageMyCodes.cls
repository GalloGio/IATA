/*
	Class Name: ISSP_AMC_ManageMyCodes
	Related Classes:

	Copyright @Right IT Services

	Purpose: Controller Class for ISSP_AMC_ManageMyCodes.component

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	Filipa Martins		30-10-2018   	INITIAL DEVELOPMENT
*/
public class ISSP_AMC_ManageMyCodes {
	public Account accountRecord {get; set;}
	public Boolean hasDesignatorValue {get; set;}
	public Boolean hasAccountingCode {get; set;}
	public Boolean hasPrefixCode {get;set;}
	public Boolean hasLocationCode {get;set;}
	public Boolean hasBaggageCode {get;set;}
	public String scenario {get;set;}
	public String description {get;set;}
	public String labelName {get;set;}
	public String value {get;set;}
	public String subtopic {get;set;}
	public String reason {get;set;}
	public String question {get;set;}
	//public List<Participation_Code__c> pcodeListObj {get;set;}
	//public List<String> pcodeList {get;set;}
	//public List<String> pcodeListBag {get;set;}
	public String erro {get;set;}
	public Boolean answer {get;set;}
	public List <Case> AMCDraftCases { get; set; }
	public Id designatorApplicationId {get;set;}
	//public Id locationCodeApplicationId {get;set;}
	public Id baggageApplicationId {get;set;}
	public Id accountingOrPrefixApplicationId {get;set;}
	public Id caseDesignatorApplicationId {get;set;}
	//public Id caseLocationCodeApplicationId {get;set;}
	public Id caseBaggageApplicationId {get;set;}
	public Id caseAccountingOrPrefixApplicationId {get;set;}

	public ISSP_AMC_ManageMyCodes(){
		answer = false;
		hasDesignatorValue = true;
		hasAccountingCode = true;
		hasPrefixCode = true;
		hasBaggageCode = true;
		hasLocationCode = true;
		/*pcodeListObj = new List<Participation_Code__c>();
		pcodeList = new List<String>();
		pcodeListBag = new List<String>();*/
		getAccountInfo();
		erro = '';
		question = '';
		AMCDraftCases = ISSP_AMC_DAO.getOngoingApplicationsChanges();
		for(Case eachExistingCase : AMCDraftCases){
			for(Participation_Online_Application__c participation : eachExistingCase.Participation_Online_Applications__r){
				if (eachExistingCase.Reason1__c == ISSP_AMC_Constants.AMC_CASE_REASON_DESIGNATOR_FORM) {
					if(eachExistingCase.Status == 'Open'){
						designatorApplicationId = participation.Id;
					}
					else {
						if(eachExistingCase.Status != 'Closed'){
							caseDesignatorApplicationId = eachExistingCase.Id;
						}
					}
				/*} else if (eachExistingCase.CaseArea__c == ISSP_AMC_Constants.AMC_CASE_CASEAREA_CODES_LOCATION_CODE) {
					if(eachExistingCase.Status == 'Open'){
						locationCodeApplicationId = participation.Id;
					}
					else {
						if(eachExistingCase.Status != 'Closed'){
							caseLocationCodeApplicationId = eachExistingCase.Id;
						}
					}*/
				} else if (eachExistingCase.Reason1__c == ISSP_AMC_Constants.AMC_CASE_REASON_BAGGAGE_FORM) {
					if(eachExistingCase.Status == 'Open'){
						baggageApplicationId = participation.Id;
					}
					else {
						if(eachExistingCase.Status != 'Closed'){
							caseBaggageApplicationId = eachExistingCase.Id;
						}
					}
				} else if (eachExistingCase.Reason1__c == ISSP_AMC_Constants.AMC_CASE_REASON_ACCOUNTING_OR_PREFIX_FORM) {
					if(eachExistingCase.Status == 'Open'){
						accountingOrPrefixApplicationId = participation.Id;
					}
					else {
						if(eachExistingCase.Status != 'Closed'){
							caseAccountingOrPrefixApplicationId = eachExistingCase.Id;
						}
					}
				}
			}
		}

	}

	public PageReference requestAirlineDesignators() {
		String caseUrl;
		erro= '';
		if(caseDesignatorApplicationId != null){
			caseUrl = '/ISSP_Case?caseId=' + caseDesignatorApplicationId + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}
		else {
			String participationId = designatorApplicationId == null ? '' : 'participationId=' + designatorApplicationId + '&';
			caseUrl = '/ISSP_AMC_Airline_Designators?' + participationId + 'mid=M3S1&retURL=/ISSP_AMC_Home';	
		}
		PageReference pr = new PageReference(caseUrl);
		pr.setRedirect(true);
		return pr;
	}

	/*public PageReference navigateLocationIdentifier(){
		String caseUrl;
		if(caseDesignatorApplicationId != null){
			caseUrl = '/ISSP_Case?caseId=' + caseDesignatorApplicationId + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}
		else {
			String participationId = locationCodeApplicationId == null ? '' : 'participationId=' + locationCodeApplicationId + '&';
			caseUrl = '/ISSP_AMC_Location_Identifier?' + participationId + '&mid=M3S1&retURL=/ISSP_AMC_Home';
		}
		PageReference pr = new PageReference(caseUrl);
		pr.setRedirect(true);
		return pr;
	}*/

	public PageReference requestBaggageTagRange(){
		String caseUrl;
		erro= '';
		if(caseBaggageApplicationId != null){
			caseUrl = '/ISSP_Case?caseId=' + caseBaggageApplicationId + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}
		else {
			String participationId = baggageApplicationId == null ? '' : 'participationId=' + baggageApplicationId + '&';
			caseUrl = '/ISSP_AMC_Baggage_Tag_Range?' + participationId + 'mid=M3S1&retURL=/ISSP_AMC_Home';
		}
		PageReference pr = new PageReference(caseUrl);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference requestAccountingOrPrefixCode(){
		String caseUrl;
		erro= '';
		if(caseAccountingOrPrefixApplicationId != null){
			caseUrl = '/ISSP_Case?caseId=' + caseAccountingOrPrefixApplicationId + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}
		else {
			String participationId = accountingOrPrefixApplicationId == null ? '' : 'participationId=' + accountingOrPrefixApplicationId + '&';
			caseUrl = '/ISSP_AMC_Accounting_Or_Prefix_Code?' + participationId + 'mid=M3S1&retURL=/ISSP_AMC_Home';
		}
		PageReference pr = new PageReference(caseUrl);
		pr.setRedirect(true);
		return pr;
	}

	

	/*public List<Participation_Code__c> getCodes(){
		accountRecord = ISSP_AMC_DAO.getAccountInfo();
		System.debug('ID:::: ' + accountRecord.Id);
		List<Participation_Code__c> pcodeListObj =[
			SELECT 
				Id, Account__c, Code_Type__c, Code_Value__c
			FROM
				Participation_Code__c
			WHERE
				Account__c = :accountRecord.Id];

        return pcodeListObj;
	}

	public List<String> getLocationCodes(){
		pcodeListObj = getCodes();

		for(Participation_Code__c pc : pcodeListObj){
			if(pc.Code_Type__c == 'Location Code'){
				if(!pcodeList.Contains(pc.Code_Value__c)){
					pcodeList.add(pc.Code_Value__c);
				}
			}
		}

		return pcodeList;
	}

	public List<String> getBaggageCodes(){
		pcodeListObj = getCodes();
		for(Participation_Code__c pc : pcodeListObj){
			if(pc.Code_Type__c == 'Baggage Code'){
				if(!pcodeListBag.Contains(pc.Code_Value__c)){
					pcodeListBag.add(pc.Code_Value__c);
				}
			}
		}

		return pcodeListBag;
	}*/



	public void getAccountInfo(){
		accountRecord = ISSP_AMC_DAO.getAccountInfo();
		/*List<String> pcodeListRend = getLocationCodes();
		List<String> pcodeListBagRend = getBaggageCodes();*/
		if(accountRecord.Airline_designator__c == null || accountRecord.Airline_designator__c == ''){
			hasDesignatorValue = false;
		}

		if(accountRecord.Accounting_Code__c == null || accountRecord.Accounting_Code__c == ''){
			hasAccountingCode = false;
		}
		if(accountRecord.Airline_Prefix__c == null || accountRecord.Airline_Prefix__c == ''){
			hasPrefixCode = false;
		}
		/*if(pcodeListRend == null || pcodeListRend.isEmpty()){
			hasLocationCode = false;
		}*/
		if(accountRecord.Baggage_Tag_Range_Code__c == null || accountRecord.Baggage_Tag_Range_Code__c == ''){
			hasBaggageCode = false;
		}
	}

	public void createCase(){
		Case newCase = new Case();
		erro= '';
		description = labelName + ' ' + value;
		scenario = ISSP_AMC_Constants.AMC_CASE_SCENARIO_WITHDRAW;

			newCase = ISSP_AMC_DAO.getCase(scenario, description, subtopic, reason, false);
			if(newCase.Id == null){
				question = Label.ISSP_AMC_WITHDRAW_QUESTION;
			}
			else{
				question = '';
				erro = Label.ISSP_AMC_EXISTING_CASE_ERROR_MESSAGE + ' ' + newCase.CaseNumber;
			}

	}

	public void clearMessage(){
		answer = false;
		erro = ' ';
		question = '';
	}
	public class errorPageException extends Exception {
	}

	public PageReference changeAnswer(){
		Case newCase = new Case();
		description = labelName + ' ' + value;
		scenario = ISSP_AMC_Constants.AMC_CASE_SCENARIO_WITHDRAW;
		try {
			newCase = ISSP_AMC_DAO.getCase(scenario, description, subtopic, reason, true);
			PageReference pr = new PageReference('/ISSP_Case?caseId=' + newCase.Id + '&mid=M1S2');
			pr.setRedirect(true);
			return pr;
		}
		catch(Exception ex){
			if(ex.getMessage().contains('There is already an open Airline Coding Application case with Reason')) {
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'There is already an open Airline Coding Application case with Reason "Manage Changes / Minor" on the selected Account'));
				question = '';
				erro = Label.ISSP_AMC_EXISTING_CASE_ERROR_MESSAGE + ' ' + newCase.CaseNumber;
			}
			else {
				throw new errorPageException(ex.getMessage());
			}
		}
		return null;
	}
}