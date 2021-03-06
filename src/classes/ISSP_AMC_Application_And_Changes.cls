public without sharing class  ISSP_AMC_Application_And_Changes {

	public List <Case> AMCDraftCases { get; set; }
	public Id designatorApplicationId {get;set;}
	public Id locationCodeApplicationId {get;set;}
	public Id baggageApplicationId {get;set;}
	public Id accountingOrPrefixApplicationId {get;set;}

	public Id caseDesignatorApplicationId {get;set;}
	public Id caseLocationCodeApplicationId {get;set;}
	public Id caseBaggageApplicationId {get;set;}
	public Id caseAccountingOrPrefixApplicationId {get;set;}

	public User userInformation {get;set;}
	public User userInformation(){
			id userId = UserInfo.getUserId();
			userInformation = [SELECT Contact.Name
			FROM User
			WHERE Id = :userId
			];

			return userInformation;
	}

	public User myUser{get;set;}

	public ISSP_AMC_Application_And_Changes(){
		AMCDraftCases = ISSP_AMC_DAO.getOngoingApplicationsChanges();

		system.debug('AMCDraftCases' + AMCDraftCases);
		system.debug('Contact no Portal ' + DAL_ISSP.getContact(userInformation().ContactId));

		for(Case eachExistingCase : AMCDraftCases){
			for(Participation_Online_Application__c participation : eachExistingCase.Participation_Online_Applications__r){
				if (eachExistingCase.Reason1__c == ISSP_AMC_Constants.AMC_CASE_REASON_DESIGNATOR_FORM) {
					if(eachExistingCase.Status == ISSP_AMC_Constants.AMC_CASE_STATUS_DRAFT){
						designatorApplicationId = participation.Id;

					}
					else {
						if(eachExistingCase.Status != 'Closed' && eachExistingCase.Status != 'Closed_Rejected'){

							caseDesignatorApplicationId = eachExistingCase.Id;
						}
						
					}
				} else if (eachExistingCase.Reason1__c == ISSP_AMC_Constants.AMC_CASE_REASON_BAGGAGE_FORM) {
					if(eachExistingCase.Status == ISSP_AMC_Constants.AMC_CASE_STATUS_DRAFT){
						baggageApplicationId = participation.Id;
					}
					else {
						if(eachExistingCase.Status != 'Closed' && eachExistingCase.Status != 'Closed_Rejected'){

							caseBaggageApplicationId = eachExistingCase.Id;
						}
					}
				} else if (eachExistingCase.Reason1__c == ISSP_AMC_Constants.AMC_CASE_REASON_ACCOUNTING_OR_PREFIX_FORM) {
					if(eachExistingCase.Status == ISSP_AMC_Constants.AMC_CASE_STATUS_DRAFT){
						accountingOrPrefixApplicationId = participation.Id;
					}
					else {
						if(eachExistingCase.Status != 'Closed' && eachExistingCase.Status != 'Closed_Rejected'){
							caseAccountingOrPrefixApplicationId = eachExistingCase.Id;
						}
					}
				}
			}
		}
		myUser	= [SELECT Id,Profile_Name__c FROM User WHERE Id =:UserInfo.getUserId()];
	}




	public Boolean isThereACase{get;set;}
	public Boolean isThereAParticipation{get;set;}
	public Boolean displayPopupDeleteSection { get; set; }
	public String caseNum {get;set;}

	public Boolean noPermissionToViewCase {get;set;}
	public Boolean isDesignator {get;set;}
	public Boolean isAccountingPrefix {get;set;}
	public Boolean isLocation {get;set;}
	public Boolean isBaggage {get;set;}

	public String getCaseNumber(Id caseId){

		return [SELECT Id,CaseNumber FROM Case WHERE Id=:caseId].CaseNumber;

	}

	public String getCaseNum(Id participationId){
		String numCase = [SELECT Id,Case__c FROM Participation_Online_Application__c WHERE Id=:participationId].Case__c;
		return getCaseNumber(numCase);
	}

  public void  closePopupDeleteSection() {
		isThereACase = false;
		isThereAParticipation = false;
		noPermissionToViewCase = false;
		isDesignator = false;
		isAccountingPrefix = false;
		isLocation = false;
		isBaggage = false;
		isManageMyCodes = false;
	}

	String caseUrl;
	public PageReference redirectToCase(){
		system.debug(isDesignator);
		system.debug(isAccountingPrefix);
		system.debug(isLocation);
		system.debug(isBaggage);


		if(isDesignator == true){
			//getCaseNumber(caseDesignatorApplicationId);
		  	caseUrl = '/ISSP_Case?caseId=' + caseDesignatorApplicationId + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}
		if(isAccountingPrefix == true){
			//getCaseNumber(caseAccountingOrPrefixApplicationId);
			caseUrl = '/ISSP_Case?caseId=' + caseAccountingOrPrefixApplicationId + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}
		if(isLocation == true){
			//getCaseNumber(caseLocationCodeApplicationId);
			caseUrl = '/ISSP_Case?caseId=' + caseLocationCodeApplicationId + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}
		if(isBaggage == true){
			//getCaseNumber(caseBaggageApplicationId);
			caseUrl = '/ISSP_Case?caseId=' + caseBaggageApplicationId + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}
		if(isManageMyCodes == true){
			system.debug('DB---- ' + caseManageId);
			caseurl =  '/ISSP_Case?caseId='+ caseManageId +'&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}



		PageReference pr = new PageReference(caseUrl);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference redirectToParticipation(){
		system.debug(isDesignator);
		system.debug(isAccountingPrefix);
		system.debug(isLocation);
		system.debug(isBaggage);


		if(isDesignator == true){
		  	caseUrl = '/ISSP_AMC_Airline_Designators?participationId='+ designatorApplicationId + '&mid=M3S1&retURL=/ISSP_AMC_Home';
		}
		if(isAccountingPrefix == true){
			caseUrl = '/ISSP_AMC_Accounting_Or_Prefix_Code?participationId=' + accountingOrPrefixApplicationId + '&mid=M3S1&retURL=/ISSP_AMC_Home';
		}
		if(isLocation == true){
			caseUrl = '/ISSP_AMC_Location_Identifier?participationId=' + locationCodeApplicationId + '&mid=M3S1&retURL=/ISSP_AMC_Home';
		}
		if(isBaggage == true){
			caseUrl = '/ISSP_AMC_Baggage_Tag_Range?participationId=' + baggageApplicationId + '&mid=M3S1&retURL=/ISSP_AMC_Home';
		}


		PageReference pr = new PageReference(caseUrl);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference navigateAirlineDesignators() {
		String caseUrl;
		if(caseDesignatorApplicationId != null){
			UserRecordAccess recordAccess = [SELECT RecordId, HasTransferAccess, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess
					FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :caseDesignatorApplicationId];


			if(!recordAccess.hasReadAccess){
				noPermissionToViewCase = true;
			}
			//system.debug('CASE NUMBER '+ [SELECT Id,CaseNumber FROM Case WHERE Id=:'caseDesignatorApplicationId'].CaseNumber);
			caseNum = getCaseNumber(caseDesignatorApplicationId);
			isThereACase = true;
			isDesignator = true;
			return null;
		}
		else{

			if(designatorApplicationId != null){
				if(myUser.Profile_Name__c != 'ISS Portal Airline Delegated Admin User'){
					UserRecordAccess recordAccess = [SELECT RecordId, HasTransferAccess, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess
						FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :designatorApplicationId];


					if(!recordAccess.hasReadAccess && !recordAccess.hasEditAccess){
						noPermissionToViewCase = true;
					}
				}
				caseNum = getCaseNum(designatorApplicationId);
				isThereAParticipation = true;
				isDesignator = true;
				return null;
			}
			else{
				String participationId = designatorApplicationId == null ? '' : 'participationId=' + designatorApplicationId + '&';
				caseUrl = '/ISSP_AMC_Airline_Designators?' + participationId + '&mid=M3S1&retURL=/ISSP_AMC_Home';
			}

		}
		PageReference pr = new PageReference(caseUrl);
		pr.setRedirect(true);
		return pr;
	}



	public PageReference navigateAccountingOrPrefixCode(){
		String caseUrl;

		if(caseAccountingOrPrefixApplicationId != null){
			UserRecordAccess recordAccess = [SELECT RecordId, HasTransferAccess, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess
				FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :caseAccountingOrPrefixApplicationId];

			if(!recordAccess.hasReadAccess){
				noPermissionToViewCase = true;
			}
			caseNum = getCaseNumber(caseAccountingOrPrefixApplicationId);
			isThereACase = true;
			isAccountingPrefix = true;
			return null;
		}
		else {

			if(accountingOrPrefixApplicationId != null){
				if(myUser.Profile_Name__c != 'ISS Portal Airline Delegated Admin User'){
					UserRecordAccess recordAccess = [SELECT RecordId, HasTransferAccess, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess
						FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :accountingOrPrefixApplicationId];


					if(!recordAccess.hasReadAccess && !recordAccess.hasEditAccess){
						noPermissionToViewCase = true;
					}
				}

				caseNum = getCaseNum(accountingOrPrefixApplicationId);
				isThereAParticipation = true;
				isAccountingPrefix = true;
				return null;
			}
			else{
				String participationId = accountingOrPrefixApplicationId == null ? '' : 'participationId=' + accountingOrPrefixApplicationId + '&';
				caseUrl = '/ISSP_AMC_Accounting_Or_Prefix_Code?' + participationId + '&mid=M3S1&retURL=/ISSP_AMC_Home';
			}

		}
		PageReference pr = new PageReference(caseUrl);
		pr.setRedirect(true);
		return pr;
	}



	public List <ISSP_AMC_DAO.AplicationRequirements> appRequirementList;
	public String step = '1';
	public Participation_Online_Application__c participation ;

	//public String locationCaseNumber {get;set;}

	public PageReference navigateLocationIdentifier(){

		participation = new Participation_Online_Application__c();
		appRequirementList = new List<ISSP_AMC_DAO.AplicationRequirements>();

		String caseUrl;

		String locationCaseNumber = ApexPages.CurrentPage().getParameters().get('locationCaseNumber');

		system.debug('DB :: Number do case'+locationCaseNumber);

		Case locationCase = [SELECT Id,CaseNumber,Status FROM Case WHERE CaseNumber=:locationCaseNumber];
		Participation_Online_Application__c locationParticipation = [SELECT Id FROM Participation_Online_Application__c WHERE Case__c=:locationCase.Id];
		caseLocationCodeApplicationId = locationCase.Id;
		locationCodeApplicationId = locationParticipation.Id;

		if(caseLocationCodeApplicationId != null && locationCase.Status == ISSP_AMC_Constants.AMC_CASE_STATUS_OPEN){
			UserRecordAccess recordAccess = [SELECT RecordId, HasTransferAccess, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess
				FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :caseLocationCodeApplicationId];
			if(!recordAccess.hasReadAccess){
				noPermissionToViewCase = true;
			}
			caseNum = getCaseNumber(caseLocationCodeApplicationId);
			isThereACase = true;
			isLocation = true;
			return null;
			//caseUrl = '/ISSP_Case?caseId=' + caseLocationCodeApplicationId + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}
		else {

			if(locationCodeApplicationId != null){
				if(myUser.Profile_Name__c != 'ISS Portal Airline Delegated Admin User'){
					UserRecordAccess recordAccess = [SELECT RecordId, HasTransferAccess, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess
						FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :locationCodeApplicationId];


					if(!recordAccess.hasReadAccess && !recordAccess.hasEditAccess){
						noPermissionToViewCase = true;
					}
				}
				caseNum = getCaseNum(locationCodeApplicationId);
				isThereAParticipation = true;
				isLocation = true;
				return null;
			}

			/*if(locationCodeApplicationId == null){
				ISSP_AMC_Location_Identifier location = new ISSP_AMC_Location_Identifier();
				location.CalculateWhichComponentsToShow();
				ISSP_AMC_DAO.saveForm(location.participation, location.appRequirementList, step, ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE);
				locationCodeApplicationId = location.participation.Id;

				caseUrl = '/ISSP_AMC_Location_Identifier?' + 'participationId=' + locationCodeApplicationId + '&mid=M3S1&retURL=/ISSP_AMC_Home';
			}*/

		}
		PageReference pr = new PageReference(caseUrl);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference navigateBaggageTagRange(){
		String caseUrl;


		if(caseBaggageApplicationId != null){
			UserRecordAccess recordAccess = [SELECT RecordId, HasTransferAccess, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess
				FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :caseBaggageApplicationId];
			if(!recordAccess.hasReadAccess){
				noPermissionToViewCase = true;
			}
			caseNum = getCaseNumber(caseBaggageApplicationId);
			isThereACase = true;
			isBaggage = true;
			return null;
			//caseUrl = '/ISSP_Case?caseId=' + caseBaggageApplicationId + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
		}
		else {

			if(baggageApplicationId != null){
				if(myUser.Profile_Name__c != 'ISS Portal Airline Delegated Admin User'){
					UserRecordAccess recordAccess = [SELECT RecordId, HasTransferAccess, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess
					FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :baggageApplicationId];


					if(!recordAccess.hasReadAccess && !recordAccess.hasEditAccess){
						noPermissionToViewCase = true;
					}
				}
				caseNum = getCaseNum(baggageApplicationId);
				isThereAParticipation = true;
				isBaggage = true;
				return null;
			}

			if(baggageApplicationId == null){
				ISSP_AMC_Baggage_Tag_Range baggage = new ISSP_AMC_Baggage_Tag_Range();
				baggage.calculateApplicationRequirementsToShow();
				ISSP_AMC_DAO.saveForm(baggage.participation, baggage.appRequirementList, step, ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_BAGGAGE_CODE);
				baggageApplicationId = baggage.participation.Id;

				caseUrl = '/ISSP_AMC_Baggage_Tag_Range?' + 'participationId=' + baggageApplicationId + '&mid=M3S1&retURL=/ISSP_AMC_Home';
			}

		}
		PageReference pr = new PageReference(caseUrl);
		pr.setRedirect(true);
		return pr;
	}
	public Boolean isManageMyCodes{get;set;}
	public Integer caseManageNumber{get;set;}
	public Id caseManageId{get;set;}
	public void navigateToManageCases() {
		String caseUrl;

		UserRecordAccess recordAccess = [SELECT RecordId, HasTransferAccess, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess
						FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :caseManageId];

		caseNum = getCaseNumber(caseManageId);

		if(!recordAccess.hasReadAccess){
			noPermissionToViewCase = true;
		}
		isManageMyCodes = true;
		isThereACase = true;

		//return null;

	}


}