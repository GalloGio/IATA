public class ISSP_ICCS_ProcessPartDelController extends ISSP_ICCS_CaseProcessController {

	/* PROCESS TYPE SPECIFIC VARIABLES */

    public ISSP_ICCS_ProcessPartDelController thisCtrl {get{return this;}}

	public Integer participationId {get;set;}

	public String selectedProductType {get;set;}
    public String selectedCountry {get;set;}
    public String selectedCurrency {get;set;}

    public String description {get;set;}

    public String reason {get;set;}

    public List<SelectOption> reasonsList {
        get{
            if(reasonsList == null){
                reasonsList = new List<SelectOption>();
                reasonsList.add(new SelectOption(ISSP_ICCS_Utils.NONE,ISSP_ICCS_Utils.NONE));
                reasonsList.add(new SelectOption('Closing BSP/CASS','Closing BSP/CASS'));
                reasonsList.add(new SelectOption('Switching to Local Bank Account','Switching to Local Bank Account'));
                reasonsList.add(new SelectOption('Other - Please Specify','Other - Please Specify'));
            }
            return reasonsList;
        }
        set;
    }
    
    public AP_Process_Form__c contactForm {get;set;}


    /* CONSTRUCTOR */

    public ISSP_ICCS_ProcessPartDelController(){}


	public override ISSP_ICCS_Utils.CaseProcessType getCaseProcessType(){
		return ISSP_ICCS_Utils.CaseProcessType.PART_DEL;
	}

	public override String getCaseProcessName(){
		return 'Leave Participation';
	}

	public override Map<Integer, ISSP_ICCS_CaseProcessesController.Step> getSteps(){
        return new Map<Integer,ISSP_ICCS_CaseProcessesController.Step>{
                1 => new ISSP_ICCS_CaseProcessesController.Step('Step 1 - Selected Participation', 25, 25),
                2 => new ISSP_ICCS_CaseProcessesController.Step('Step 2 - Select Contact', 50, 25),
                3 => new ISSP_ICCS_CaseProcessesController.Step('Step 3 - Upload Files', 75, 25),
                4 => new ISSP_ICCS_CaseProcessesController.Step('Step 4 - Terms and Conditions', 100, 25)};
	}

	public override List<String> getCaseProcessDocuments(){
	    return new List<String>{
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_LEAVE_PARTICIPATION,
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS};
	}

	public override Map<String, ISSP_ICCS_CaseProcessController.TypedDocument> getCaseProcessTypedDocumentMap(){
		return new Map<String, ISSP_ICCS_CaseProcessController.TypedDocument>{
			ISSP_ICCS_Utils.ICCS_DOCUMENT_LEAVE_PARTICIPATION => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_LEAVE_PARTICIPATION, true),
			ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS, false)
		};
	}

    
    public override void resetController(ISSP_ICCS_CaseProcessesController caseProcessesController){
		System.debug('ISSP_ICCS_ProcessPartDelController.resetController(ISSP_ICCS_CaseProcessController caseProcessController) : increment ' + ++ISSP_ICCS_ServiceController.increment);

    	ISSP_ICCS_ComponentController componentController = caseProcessesController.pageController.componentControllersMap.get(caseProcessesController.pageController.previousComponent);
    	
    	if(componentController instanceof ISSP_ICCS_ServiceMgmtController){
	    	ISSP_ICCS_ServiceMgmtController serviceMgmtController = (ISSP_ICCS_ServiceMgmtController) componentController;

			participationId = serviceMgmtController.participationIdParameter;
    	}
    }

	public override void cleanController(){
		System.debug('ISSP_ICCS_ProcessPartDelController.cleanController() : increment ' + ++ISSP_ICCS_ServiceController.increment);

		participationId = null;
		
		selectedProductType = null;
		selectedCountry = null;
		selectedCurrency = null;
		
		description = null;
		reason = null;
		reasonsList = null;
		
		contactForm = null;
	}

    public override void fillAdditionalMessages(){
        // step 1
        caseProcessesController.displayMessages.put('reason', false);
        caseProcessesController.displayMessages.put('description', false);

        // step 2
        caseProcessesController.displayMessages.put('desiredStartDate', false);
        caseProcessesController.displayMessages.put('socialTitle', false);
        caseProcessesController.displayMessages.put('firstName', false);
        caseProcessesController.displayMessages.put('lastName', false);
        caseProcessesController.displayMessages.put('phone', false);
        caseProcessesController.displayMessages.put('jobTitle', false);
        caseProcessesController.displayMessages.put('email', false);
        
        // step 4
        caseProcessesController.displayMessages.put('termsAndConditionsAccepted', false);
	}

	public override Case createCase(){
		return new Case(
            Subject = 'ICCS Service Leave Participation - ' + caseProcessesController.pageController.topAccount.Name,
			Status = 'Draft',
			Origin = 'Portal',
			Visible_on_ISS_Portal__c = true,
			CaseArea__c = ISSP_ICCS_Utils.CASE_AREA_LEAVE_PARTICIPATION,
			contactId = caseProcessesController.pageController.portalUserContact.Id,
			AccountId = caseProcessesController.pageController.topAccount.Id,
			Priority = 'Medium',
	        ICCS_Product__c = selectedProductType,
	        ICCS_Country__c = selectedCountry,
	        ICCS_Currencies__c = selectedCurrency,
	        RecordTypeId = ISSP_ICCS_Utils.CASE_RECORD_TYPE_PARTICIPATION);
	}

	public override Case retrieveCase(Id caseId){
		return [select	
					Id, 
			        CaseNumber, 
			        Subject, 
			        Status,
			        Account.Name,
			        IATA_Code__c,
			        Contact.Name, 
			        Contact.Email, 
			        Contact.Phone, 
			        Adjustment_Date__c, 
			        Expected_Deadline__c, 
			        Origin,
			        CaseArea__c,
			        Description,
			        Reason1__c,
			        ICCS_Product__c,
			        ICCS_Country__c,
			        ICCS_Currencies__c
				from Case 
				where Id =: caseId];
	}

	public override void resetVariables(){
		if(caseProcessesController.cse.Id == null){
			caseProcessesController.cse.Expected_Deadline__c = Date.today() + 15;

            contactForm = new AP_Process_Form__c(
                Contact_Resp_F_Name__c = caseProcessesController.pageController.portalUserContact.FirstName,
                Contact_Resp_Job_Title__c = caseProcessesController.pageController.portalUserContact.Title,
                Contact_Resp_L_Name__c = caseProcessesController.pageController.portalUserContact.LastName,
                Contact_Resp_Email__c = caseProcessesController.pageController.portalUserContact.Email,
                Accept_terms_and_conditions__c = false);

			try{
				// Set "NONE" as default value, then retrieve the data from the core, based on the participationId
		        selectedProductType = ISSP_ICCS_Utils.NONE;
		        selectedCountry = ISSP_ICCS_Utils.NONE;
		        selectedCurrency = ISSP_ICCS_Utils.NONE;
		        
				for(ISSP_ICCS_CoreRest.Participation participation : caseProcessesController.pageController.coreRest.getParticipations()){
					if(participation.id == participationId){
						for(ISSP_ICCS_CoreRest.Cashflow cashflow : caseProcessesController.pageController.coreRest.getCashflows()){
							if(cashflow.id == participation.cashflow.id){
								selectedProductType = cashflow.type.code;
								selectedCountry = cashflow.country.name;
								selectedCurrency = cashflow.processingCurrency;
								break;
							}
						}
					}
				}
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				caseProcessesController.pageController.setMessage(e.getMessage(), false);		
			}
		}
		else{
            List<AP_Process_Form__c> contactForms = [select Id, Accept_terms_and_conditions__c, Contact_Resp_Salutation__c, Contact_Resp_F_Name__c, Contact_Resp_Job_Title__c, Contact_Resp_L_Name__c, Contact_Resp_Email__c, Contact_Resp_Phone__c, Case__c from AP_Process_Form__c where Case__c =: caseProcessesController.cse.Id];
            if(!contactForms.isEmpty()){
                contactForm = contactForms[0];
            }
            else{
                contactForm = new AP_Process_Form__c(
                    Contact_Resp_F_Name__c = caseProcessesController.pageController.portalUserContact.FirstName,
                    Contact_Resp_Job_Title__c = caseProcessesController.pageController.portalUserContact.Title,
                    Contact_Resp_L_Name__c = caseProcessesController.pageController.portalUserContact.LastName,
                    Contact_Resp_Email__c = caseProcessesController.pageController.portalUserContact.Email
                );            
            }
	        selectedProductType = caseProcessesController.cse.ICCS_Product__c == null ? ISSP_ICCS_Utils.NONE : caseProcessesController.cse.ICCS_Product__c;
	        selectedCountry = caseProcessesController.cse.ICCS_Country__c == null ? ISSP_ICCS_Utils.NONE : caseProcessesController.cse.ICCS_Country__c;
	        selectedCurrency = caseProcessesController.cse.ICCS_Currencies__c == null ? ISSP_ICCS_Utils.NONE : caseProcessesController.cse.ICCS_Currencies__c;
        }

        description = caseProcessesController.cse.Description;
        reason = caseProcessesController.cse.Reason1__c == null ? ISSP_ICCS_Utils.NONE : caseProcessesController.cse.Reason1__c;
	}

    public override Boolean validateStep(){
        Boolean stepValid = true;
        if(caseProcessesController.currentStep == 1){

	        Boolean reasonInvalid = reason == null || reason == ISSP_ICCS_Utils.NONE;
	        caseProcessesController.displayMessages.put('reason', reasonInvalid);
	        
	        Boolean descriptionInvalid = reason == 'Other - Please Specify' && (description == null || description == '');
	        caseProcessesController.displayMessages.put('description', descriptionInvalid);
        
			return !(reasonInvalid || descriptionInvalid);
        }
        else if(caseProcessesController.currentStep == 2){
            caseProcessesController.displayMessages.put('socialTitle', contactForm.Contact_Resp_Salutation__c == null);
            caseProcessesController.displayMessages.put('firstName', contactForm.Contact_Resp_F_Name__c == null);
            caseProcessesController.displayMessages.put('lastName', contactForm.Contact_Resp_L_Name__c == null);
            caseProcessesController.displayMessages.put('phone', contactForm.Contact_Resp_Phone__c == null);
            caseProcessesController.displayMessages.put('jobTitle', contactForm.Contact_Resp_Job_Title__c == null);
            caseProcessesController.displayMessages.put('email', contactForm.Contact_Resp_Email__c == null);

            return  !(caseProcessesController.displayMessages.get('socialTitle')
                    || caseProcessesController.displayMessages.get('firstName')
                    || caseProcessesController.displayMessages.get('lastName')
                    || caseProcessesController.displayMessages.get('phone')
                    || caseProcessesController.displayMessages.get('jobTitle')
                    || caseProcessesController.displayMessages.get('email'));
        }
        else if(caseProcessesController.currentStep == 3){
            caseProcessesController.displayMessages.put(ISSP_ICCS_Utils.ICCS_DOCUMENT_LEAVE_PARTICIPATION, !typedDocumentsMap.get(ISSP_ICCS_Utils.ICCS_DOCUMENT_LEAVE_PARTICIPATION).documentExists);

            return !caseProcessesController.displayMessages.get(ISSP_ICCS_Utils.ICCS_DOCUMENT_LEAVE_PARTICIPATION);
        }
        else if(caseProcessesController.currentStep == 4){
            caseProcessesController.displayMessages.put('termsAndConditionsAccepted', contactForm.Accept_terms_and_conditions__c != true);

            return !caseProcessesController.displayMessages.get('termsAndConditionsAccepted');
        }
        return true;
    }

	public override void setCaseFieldValues(){
		if(reason == 'Other - Please Specify'){
			caseProcessesController.cse.Description = description;
		}
		caseProcessesController.cse.Reason1__c = reason == ISSP_ICCS_Utils.NONE ? null : reason;
		caseProcessesController.cse.Expected_Deadline__c = caseProcessesController.cse.Expected_Deadline__c != null ? caseProcessesController.cse.Expected_Deadline__c : Date.today() + 15;
		caseProcessesController.cse.ICCS_Product__c = selectedProductType == ISSP_ICCS_Utils.NONE ? null : selectedProductType;
		caseProcessesController.cse.ICCS_Country__c = selectedCountry == ISSP_ICCS_Utils.NONE ? null : selectedCountry;
		caseProcessesController.cse.ICCS_Currencies__c = selectedCurrency == ISSP_ICCS_Utils.NONE ? null : selectedCurrency;
	}
	
	public override void postSubmit(){
		if(contactForm.Id == null){
		    contactForm.Case__c = caseProcessesController.cse.Id;
		}
		upsert contactForm;
	}
}