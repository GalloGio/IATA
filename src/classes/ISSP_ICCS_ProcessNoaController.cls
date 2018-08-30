public class ISSP_ICCS_ProcessNoaController extends ISSP_ICCS_CaseProcessController {

    public ISSP_ICCS_ProcessNoaController thisCtrl {get{return this;}}

	/* Process specific variables */

	public Integer participationId {get;set;}

	public String selectedProductType {get;set;}
    public String selectedCountry {get;set;}
    public String selectedCurrency {get;set;}


    /* Constructor */
    public ISSP_ICCS_ProcessNoaController(){}


	public override ISSP_ICCS_Utils.CaseProcessType getCaseProcessType(){
		return ISSP_ICCS_Utils.CaseProcessType.NOA;
	}

	public override String getCaseProcessName(){
		return 'Terminate Notice of Assignment';
	}

	public override Map<Integer, ISSP_ICCS_CaseProcessesController.Step> getSteps(){
		/* CHECK IF YOU SHOULDN'T RETURN AN EMPTY OR A NULL MAP */
        return new Map<Integer,ISSP_ICCS_CaseProcessesController.Step>{
		        1 => new ISSP_ICCS_CaseProcessesController.Step('Step 1 - BLA BLA BLA', 100, 100)};
	}

	public override List<String> getCaseProcessDocuments(){
	    return new List<String>{
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_NOA_RELEASE,
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_REVISED_INSTRUCTIONS};
	}

	public override Map<String, ISSP_ICCS_CaseProcessController.TypedDocument> getCaseProcessTypedDocumentMap(){
		return new Map<String, ISSP_ICCS_CaseProcessController.TypedDocument>{
			ISSP_ICCS_Utils.ICCS_DOCUMENT_NOA_RELEASE => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_NOA_RELEASE, false),
			ISSP_ICCS_Utils.ICCS_DOCUMENT_REVISED_INSTRUCTIONS => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_REVISED_INSTRUCTIONS, false)
		};
	}


    public override void resetController(ISSP_ICCS_CaseProcessesController caseProcessesController){
    	ISSP_ICCS_ComponentController componentController = caseProcessesController.pageController.componentControllersMap.get(caseProcessesController.pageController.previousComponent);
    	
    	if(componentController instanceof ISSP_ICCS_ServiceMgmtController){
	    	ISSP_ICCS_ServiceMgmtController serviceMgmtController = (ISSP_ICCS_ServiceMgmtController) componentController;

			participationId = serviceMgmtController.participationIdParameter;
    	}
    }

	public override void cleanController(){
		participationId = null;
		
		selectedProductType = null;
		selectedCountry = null;
		selectedCurrency = null;
	}

    public override Case createCase(){
		return new Case(
			Subject = 'ICCS Terminate Notice of Assignment - ' + caseProcessesController.pageController.topAccount.Name,
			Origin = 'Portal',
			Status = 'Draft',
			CaseArea__c = ISSP_ICCS_Utils.CASE_AREA_TERMINATE_NOA,
			Visible_on_ISS_Portal__c = true,
			contactId = caseProcessesController.pageController.portalUserContact.Id,
			AccountId = caseProcessesController.pageController.topAccount.Id,
			Priority = 'Medium',
	        ICCS_Product__c = selectedProductType,
	        ICCS_Country__c = selectedCountry,
	        ICCS_Currencies__c = selectedCurrency,
	        Notice_of_Assignment__c = true,
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
					Expected_Deadline__c, 
					Origin,
					CaseArea__c,
			        ICCS_Product__c,
			        ICCS_Country__c,
			        ICCS_Currencies__c,
					Type_of_Change__c
				from Case 
				where Id =: caseId];
	}

	public override void resetVariables(){
		if(caseProcessesController.cse.Id == null){
			caseProcessesController.cse.Expected_Deadline__c = Date.today() + 15;

			try{
				// Set "NONE" as default value, then retrieve the data from the core, based on the participationId
		        selectedProductType = ISSP_ICCS_Utils.NONE;
		        selectedCountry = ISSP_ICCS_Utils.NONE;
		        selectedCurrency = ISSP_ICCS_Utils.NONE;

				for(ISSP_ICCS_CoreRest.Participation participation : caseProcessesController.pageController.coreRest.getParticipations()){
					if(participation.id == participationId){
//						for(ISSP_ICCS_CoreRest.Cashflow cashflow : ISSP_ICCS_CoreRest.getCashflows(caseProcessesController.pageController.participantId)){
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
            selectedProductType = caseProcessesController.cse.ICCS_Product__c == null ? ISSP_ICCS_Utils.NONE : caseProcessesController.cse.ICCS_Product__c;
            selectedCountry = caseProcessesController.cse.ICCS_Country__c == null ? ISSP_ICCS_Utils.NONE : caseProcessesController.cse.ICCS_Country__c;
            selectedCurrency = caseProcessesController.cse.ICCS_Currencies__c == null ? ISSP_ICCS_Utils.NONE : caseProcessesController.cse.ICCS_Currencies__c;
		}
	}

    public override Boolean validateStep(){
        return true;
    }

	public override void setCaseFieldValues(){
		caseProcessesController.cse.Expected_Deadline__c = caseProcessesController.cse.Expected_Deadline__c != null ? caseProcessesController.cse.Expected_Deadline__c : Date.today() + 15;
		caseProcessesController.cse.ICCS_Product__c = selectedProductType == ISSP_ICCS_Utils.NONE ? null : selectedProductType;
		caseProcessesController.cse.ICCS_Country__c = selectedCountry == ISSP_ICCS_Utils.NONE ? null : selectedCountry;
		caseProcessesController.cse.ICCS_Currencies__c = selectedCurrency == ISSP_ICCS_Utils.NONE ? null : selectedCurrency;
	}
}