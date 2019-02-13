/*
	Class Name: ISSP_AMC_Airline_Designators
	Related Classes:

	Copyright @Right IT Services

	Purpose: Controller Class for ISSP_AMC_Airline_Designators.page

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	João Ferreira		30-10-2018   	INITIAL DEVELOPMENT
 	2.0		  	Miguel
*/
	public without sharing class ISSP_AMC_Accounting_Or_Prefix_Code {

		/* GENERAL */
		public Participation_Online_Application__c participation {get;set;}
		public String displayLanguage {
			get {
				if(displayLanguage == null)
					return UserInfo.getLanguage();
				else
					return displayLanguage;
			}
		}
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

		public void showMessages(){

			//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Saved successfully!'));

			if((participation.AOC_Scheduled_Passenger__c == true) && (participation.AOC_Scheduled_Cargo__c == true)){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = 'Accounting Code & Airline Prefix Code';
			}
			else if((participation.AOC_Non_Scheduled_Passenger__c == true) && (participation.AOC_Non_Scheduled_Cargo__c == true)){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = 'Accounting Code & Airline Prefix Code';
			}
			else if(participation.AOC_Scheduled_Passenger__c == true){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = 'Accounting Code';
			}
			else if(participation.AOC_Scheduled_Cargo__c == true){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = 'Airline Prefix Code';
			}
			else if(participation.AOC_Non_Scheduled_Passenger__c == true){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = 'Accounting Code';
			}
			else if(participation.AOC_Non_Scheduled_Cargo__c == true){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = 'Airline Prefix Code';
			}
			else if(participation.AOC_CRS__c == true){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = 'Accounting Code & Airline Prefix Code';
			}
			else if(participation.AOC_Ferry_Company__c == true){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = 'Accounting Code';
			}
			else if(participation.AOC_Bus_Company__c == true){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = 'Accounting Code';
			}
			else if(participation.AOC_Railway_Company__c == true){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = 'Accounting Code';
			}
			else if((participation.AOC_Scheduled_Passenger__c == false) && (participation.AOC_Scheduled_Cargo__c == false) && (participation.AOC_Non_Scheduled_Passenger__c == false) && (participation.AOC_Non_Scheduled_Cargo__c == false)
				&& (participation.AOC_CRS__c == false) && (participation.AOC_Ferry_Company__c == false) && (participation.AOC_Bus_Company__c == false) && (participation.AOC_Railway_Company__c == false)){
				participation.Accounting_Code_Airline_Prefix_Purpose__c = '';
			}

			
		}


		public Map <String, String> componentByOperation { get;set; }

		/* STEP 1 */
		public String selectedOperationType { get; set; }
		public List <SelectOption> operationTypes { get; set; }
		public Boolean isSaved { get; set; }
		public Boolean displayMessage { get; set; }
		public Boolean hasError { get; set; }
		public String message { get; set; }
		public String severity { get; set; }

		public PageReference saveParticipation(){

			displayMessage = false;
			message = '';
			severity = '';
			hasError = false;

			ISSP_AMC_DAO.saveForm(participation, appRequirementList, step,ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_ACCOUNTING_OR_PREFIX_CODE);
			//ISSP_AMC_DAO.saveDesignatorCode(participation, appRequirementList, step);

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

			calculateApplicationRequirementsToShow();
			return null;

		}

		public PageReference init(){
			if(participation.Case__c != null && participation.Case__r.Status != ISSP_AMC_Constants.AMC_CASE_STATUS_OPEN){
				PageReference pr = new PageReference('/ISSP_Case?caseId=' + participation.Case__c + '&mid=M1S2');
                pr.setRedirect(true);
                return pr;
			}
			return null;
		}

		public String step { get; set; }
		public Account accountRecord {get;set;}
    	public Boolean isSISUser {get;set;}


		public ISSP_AMC_Accounting_Or_Prefix_Code() {
			accountRecord = ISSP_AMC_DAO.getAccountInfo();
	        if(accountRecord.SIS_Status__c == 'Active'){
	            isSISUser = true;
	        }

			displayMessage = false;
			String participationId = Apexpages.currentPage().getParameters().get('participationId');
			step = Apexpages.currentPage().getParameters().get('step');
			appRequirementList = new List <ISSP_AMC_DAO.AplicationRequirements>();
			
			if(participationId == null){
				participation = ISSP_AMC_DAO.getCompleteParticipation(ISSP_AMC_Constants.AMC_CASE_REASON_ACCOUNTING_OR_PREFIX_FORM);
			}
			else {
				participation = ISSP_AMC_DAO.getCompleteDesignatorCode(participationId);
			}

			if(participation.Id != null){
				if(participation.AOC_Scheduled_Passenger__c || participation.AOC_Scheduled_Cargo__c){
					selectedOperationType = 'ScheduledAirline';
				}
				else if (participation.AOC_Non_Scheduled_Passenger__c || participation.AOC_Non_Scheduled_Cargo__c){
					selectedOperationType = 'NonScheduledAirline';
				}
				else if (participation.AOC_CRS__c){
					selectedOperationType = 'CRS';
				}
				else if (participation.AOC_Ferry_Company__c){
					selectedOperationType = 'Ferry';
				}
				
				/*else if (participation.AOC_ULD__c){
					selectedOperationType = 'ULD';
				}*/
				else if (participation.AOC_Bus_Company__c) {
					selectedOperationType = 'Bus';
				}
				else if (participation.AOC_Railway_Company__c){
					selectedOperationType = 'Railway';
				}

				CalculateWhichComponentsToShow();

			}
		}

		private void calculateCheckboxes(){

			switch on selectedOperationType {
				when 'ScheduledAirline' {
					participation.AOC_Non_Scheduled_Passenger__c = false;
					participation.AOC_Non_Scheduled_Cargo__c = false;
					participation.AOC_Ferry_Company__c = false;
					participation.AOC_CRS__c = false;
					//participation.AOC_ULD__c = false;
					participation.AOC_Bus_Company__c = false;
					participation.AOC_Railway_Company__c = false;
				}
				when 'NonScheduledAirline' {
					participation.AOC_Scheduled_Passenger__c = false;
					participation.AOC_Scheduled_Cargo__c = false;
					participation.AOC_Ferry_Company__c = false;
					participation.AOC_CRS__c = false;
					//participation.AOC_ULD__c = false;
					participation.AOC_Bus_Company__c = false;
					participation.AOC_Railway_Company__c = false;
				}
				when 'CRS' {
					participation.AOC_Scheduled_Passenger__c = false;
					participation.AOC_Scheduled_Cargo__c = false;
					participation.AOC_Non_Scheduled_Passenger__c = false;
					participation.AOC_Non_Scheduled_Cargo__c = false;

					participation.AOC_Ferry_Company__c = false;
					//participation.AOC_ULD__c = false;
					participation.AOC_Bus_Company__c = false;
					participation.AOC_Railway_Company__c = false;
				}
				when 'Ferry' {
	                participation.AOC_Scheduled_Passenger__c = false;
	                participation.AOC_Scheduled_Cargo__c = false;
	                participation.AOC_Non_Scheduled_Passenger__c = false;
	                participation.AOC_Non_Scheduled_Cargo__c = false;

	                participation.AOC_CRS__c = false;
	                //participation.AOC_ULD__c = false;
	                participation.AOC_Bus_Company__c = false;
	                participation.AOC_Railway_Company__c = false;
	            }
	            when 'Bus' {
	                participation.AOC_Scheduled_Passenger__c = false;
	                participation.AOC_Scheduled_Cargo__c = false;
	                participation.AOC_Non_Scheduled_Passenger__c = false;
	                participation.AOC_Non_Scheduled_Cargo__c = false;

	                participation.AOC_Ferry_Company__c = false;
	                participation.AOC_CRS__c = false;
	                //participation.AOC_ULD__c = false;
	                participation.AOC_Railway_Company__c = false;
	            }
	            when 'Railway' {
	                participation.AOC_Scheduled_Passenger__c = false;
	                participation.AOC_Scheduled_Cargo__c = false;
	                participation.AOC_Non_Scheduled_Passenger__c = false;
	                participation.AOC_Non_Scheduled_Cargo__c = false;

	                participation.AOC_Ferry_Company__c = false;
	                participation.AOC_CRS__c = false;
	                //participation.AOC_ULD__c = false;
	                participation.AOC_Bus_Company__c = false;
	            }
			}

			selectedOperationTypeForRequirements = new List <String>();
			if(participation.AOC_Scheduled_Passenger__c){
				selectedOperationTypeForRequirements.add('\'Scheduled Passenger\'');
			}

			if(participation.AOC_Scheduled_Cargo__c){
				selectedOperationTypeForRequirements.add('\'Scheduled Cargo\'');
			}

			if(participation.AOC_Non_Scheduled_Passenger__c){
				selectedOperationTypeForRequirements.add('\'Non-Scheduled Passenger\'');
			}

			if(participation.AOC_Non_Scheduled_Cargo__c){
				selectedOperationTypeForRequirements.add('\'Non-Scheduled Cargo\'');
			}

			if(participation.AOC_CRS__c){
				selectedOperationTypeForRequirements.add('\'CRS\'');
			}
			if(participation.AOC_Ferry_Company__c){
	            selectedOperationTypeForRequirements.add('\'Ferry Company\'');
	        }
	        if(participation.AOC_Bus_Company__c){
	            selectedOperationTypeForRequirements.add('\'Bus Company\'');
	        }

	        if(participation.AOC_Railway_Company__c){
	            selectedOperationTypeForRequirements.add('\'Railway Company\'');
	        }
			calculateApplicationRequirementsToShow();
		}

		/* STEP 2 */

		public Boolean ISSP_AMC_Authorized_Areas_Operation { get; set; }
		public Boolean ISSP_AMC_PreviousIATACode { get; set; }
		public Boolean ISSP_AMC_ICAOCode { get; set; }
		public Boolean ISSP_AMC_SchedulesPublication { get; set; }
		public Boolean ISSP_AMC_FleetInformation { get; set; }
		public Boolean ISSP_AMC_PreferenceOfCode { get; set; }
		public Boolean ISSP_AMC_TermsAndConditions { get; set; }
		public Boolean ISSP_AMC_BreakdownOfShareholders { get; set; }
		public Boolean ISSP_AMC_Intermodal_Agreement{get; set;}
		public Boolean ISSP_AMC_Rail_Ferry_Or_Bus{get; set;}
		//public Boolean ISSP_AMC_ULD{get; set;}
		public Boolean ISSP_AMC_CRS{get; set;}
		public Boolean ISSP_AMC_Upload_Files{ get; set; }
		public Boolean ISSP_AMC_Non_Scheduled{ get; set; }
		public Boolean ISSP_AMC_TrafficAgreement_Valid_IATA_Code{ get; set; }
		public Boolean ISSP_AMC_Authorization_Transportation_Services{ get; set; }
		public Boolean ISSP_AMC_Signed_Letter_CRS{ get; set; }
		public Boolean ISSP_AMC_Passenger{ get; set; }
		public Boolean ISSP_AMC_Cargo{ get; set; }
		public Boolean ISSP_AMC_CertificateIncorporationRegistration{ get; set; }
		public Boolean ISSP_AMC_Airline_Issued_AOC{ get; set; }

		public Boolean ISSP_AMC_Freight_Forwarder{ get; set; }
		public Boolean ISSP_AMC_Reciprocal_Two_Way{ get; set; }

		public void CalculateWhichComponentsToShowWithCases(){
			displayMessage = false; 
			CalculateWhichComponentsToShow();
			if(participation.Case__c == null){
				ISSP_AMC_DAO.saveForm(participation, appRequirementList, step,ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_ACCOUNTING_OR_PREFIX_CODE);
				//ISSP_AMC_DAO.getCase(participation, ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_ACCOUNTING_OR_PREFIX_CODE);
			}
		}
		public void CalculateWhichComponentsToShow(){
			
			ISSP_AMC_Authorized_Areas_Operation = false;
			ISSP_AMC_PreviousIATACode = false;
			ISSP_AMC_ICAOCode = false;
			ISSP_AMC_SchedulesPublication = false;
			ISSP_AMC_FleetInformation = false;
			ISSP_AMC_PreferenceOfCode = false;
			ISSP_AMC_TermsAndConditions = false;
			ISSP_AMC_CertificateIncorporationRegistration = false;
			ISSP_AMC_BreakdownOfShareholders = false;
			ISSP_AMC_Intermodal_Agreement = false;
			ISSP_AMC_Rail_Ferry_Or_Bus = false;
			//ISSP_AMC_ULD = false;
			ISSP_AMC_CRS = false;
			ISSP_AMC_Upload_Files = false;
			ISSP_AMC_Non_Scheduled = false;
			ISSP_AMC_TrafficAgreement_Valid_IATA_Code = false;
			ISSP_AMC_Authorization_Transportation_Services = false;
			ISSP_AMC_Signed_Letter_CRS = false;
			ISSP_AMC_Passenger = false;
			ISSP_AMC_Cargo = false;
			ISSP_AMC_Airline_Issued_AOC = false;

			ISSP_AMC_Freight_Forwarder = false;
			ISSP_AMC_Reciprocal_Two_Way = false;

			calculateCheckboxes();
			

			if(componentByOperation != null){
				for(String componentKey : componentByOperation.keySet()){
					switch on componentKey{
						when 'ISSP_AMC_Authorized_Areas_Operation' {
							ISSP_AMC_Authorized_Areas_Operation = IsToShowComponent('ISSP_AMC_Authorized_Areas_Operation');
						}
						when 'ISSP_AMC_PreviousIATACode' {
							ISSP_AMC_PreviousIATACode = IsToShowComponent('ISSP_AMC_PreviousIATACode');
						}
						when 'ISSP_AMC_ICAOCode' {
							ISSP_AMC_ICAOCode = IsToShowComponent('ISSP_AMC_ICAOCode');
						}
						when 'ISSP_AMC_SchedulesPublication' {
							ISSP_AMC_SchedulesPublication = IsToShowComponent('ISSP_AMC_SchedulesPublication');
						}
						when 'ISSP_AMC_PreferenceOfCode' {
							ISSP_AMC_PreferenceOfCode = IsToShowComponent('ISSP_AMC_PreferenceOfCode');
						}
						when 'ISSP_AMC_TermsAndConditions' {
							ISSP_AMC_TermsAndConditions = IsToShowComponent('ISSP_AMC_TermsAndConditions');
						}

						when 'ISSP_AMC_TrafficAgreement_Valid_IATA_Code' {
							ISSP_AMC_TrafficAgreement_Valid_IATA_Code = IsToShowComponent('ISSP_AMC_TrafficAgreement_Valid_IATA_Code');
						}

						when 'ISSP_AMC_Signed_Letter_CRS' {
							ISSP_AMC_Signed_Letter_CRS = IsToShowComponent('ISSP_AMC_Signed_Letter_CRS');
						}

						when 'ISSP_AMC_Authorization_Transportation_Services' {
							ISSP_AMC_Authorization_Transportation_Services = IsToShowComponent('ISSP_AMC_Authorization_Transportation_Services');
						}

						when 'ISSP_AMC_Intermodal_Agreement' {
							ISSP_AMC_Intermodal_Agreement = IsToShowComponent('ISSP_AMC_Intermodal_Agreement');
						}
						when 'ISSP_AMC_Rail_Ferry_Or_Bus' {
							ISSP_AMC_Rail_Ferry_Or_Bus = IsToShowComponent('ISSP_AMC_Rail_Ferry_Or_Bus');
						}
						/*
						when 'ISSP_AMC_ULD' {
							ISSP_AMC_ULD = IsToShowComponent('ISSP_AMC_ULD');
						}*/

						when 'ISSP_AMC_CRS' {
							ISSP_AMC_CRS = IsToShowComponent('ISSP_AMC_CRS');
						}

						when 'ISSP_AMC_Upload_Files' {
							ISSP_AMC_Upload_Files = IsToShowComponent('ISSP_AMC_Upload_Files');
						}

						when 'ISSP_AMC_Non_Scheduled' {
							ISSP_AMC_Non_Scheduled = IsToShowComponent('ISSP_AMC_Non_Scheduled');
						}

						when 'ISSP_AMC_Passenger' {
							ISSP_AMC_Passenger = IsToShowComponent('ISSP_AMC_Passenger');
						}
						when 'ISSP_AMC_Cargo' {
							ISSP_AMC_Cargo = IsToShowComponent('ISSP_AMC_Cargo');
						}

						when 'ISSP_AMC_Freight_Forwarder' {
							ISSP_AMC_Freight_Forwarder = IsToShowComponent('ISSP_AMC_Freight_Forwarder');
						}

						when 'ISSP_AMC_BreakdownOfShareholders' {
							ISSP_AMC_BreakdownOfShareholders = IsToShowComponent('ISSP_AMC_BreakdownOfShareholders');
						}

						when 'ISSP_AMC_CertificateIncorporationRegistration' {
							ISSP_AMC_CertificateIncorporationRegistration = IsToShowComponent('ISSP_AMC_CertificateIncorporationRegistration');
						}

						when 'ISSP_AMC_Airline_Issued_AOC' {
							ISSP_AMC_Airline_Issued_AOC = IsToShowComponent('ISSP_AMC_Airline_Issued_AOC');
						}

						when else {

						}
					}
				}
				showMessages();
			}
		}

		public Boolean IsToShowComponent(String componentKey){
			Boolean isToShow = false;
			if(componentByOperation != null && componentByOperation.get(componentKey) != null){
				String []componentKeyList = componentByOperation.get(componentKey).split(';');
				for(String componentKetItem : componentKeyList){
					if(participation.AOC_Scheduled_Passenger__c && componentKetItem.trim() == 'Scheduled Passenger'){
						isToShow = true;
					}
					if(participation.AOC_Scheduled_Cargo__c && componentKetItem.trim() == 'Scheduled Cargo'){
						isToShow = true;
					}
					if(participation.AOC_Non_Scheduled_Passenger__c && componentKetItem.trim() == 'Non-Scheduled Passenger'){
						isToShow = true;
					}
					if(participation.AOC_Non_Scheduled_Cargo__c && componentKetItem.trim() == 'Non-Scheduled Cargo'){
						isToShow = true;
					} 
					if(participation.AOC_CRS__c && componentKetItem.trim() == 'CRS'){
						isToShow = true;
					}
					if(participation.AOC_Ferry_Company__c && componentKetItem.trim() == 'Ferry Company'){
	                    isToShow = true;
	                }	                
	                if(participation.AOC_Bus_Company__c && componentKetItem.trim() == 'Bus Company'){
	                    isToShow = true;
	                }
	                if(participation.AOC_Railway_Company__c && componentKetItem.trim() == 'Railway Company'){
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
	            if(selectedOperationTypeForRequirements == null){
                	selectedOperationTypeForRequirements = new List <String>();
            	}
	            if(selectedOperationTypeForRequirements.isEmpty()){
	                selectedOperationTypeForRequirements.add('\'NO_OPERATION_TYPE_WAS_CHOOSEN\'');
	            }
	            ISSP_AMC_DAO.calculateApplicationRequirementsToShow(appRequirementList, selectedOperationTypeForRequirements, componentByOperation, participation, step, ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_ACCOUNTING_OR_PREFIX_CODE);
	    }

	}