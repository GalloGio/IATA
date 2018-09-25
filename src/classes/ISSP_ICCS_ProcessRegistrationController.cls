public class ISSP_ICCS_ProcessRegistrationController extends ISSP_ICCS_CaseProcessController {

	/* PROCESS TYPE SPECIFIC VARIABLES */

    public ISSP_ICCS_ProcessRegistrationController thisCtrl {get{return this;}}
    

    /* CONSTRUCTOR */

    public ISSP_ICCS_ProcessRegistrationController(){}


	public override ISSP_ICCS_Utils.CaseProcessType getCaseProcessType(){
		return ISSP_ICCS_Utils.CaseProcessType.REGISTRATION;
	}

	
	public override String getCaseProcessName(){
		return 'Activate ICCS Membership';
	}

	public override Map<Integer, ISSP_ICCS_CaseProcessesController.Step> getSteps(){
        return new Map<Integer,ISSP_ICCS_CaseProcessesController.Step>{
                1 => new ISSP_ICCS_CaseProcessesController.Step('Step 1 - General Information', 33, 33),
                2 => new ISSP_ICCS_CaseProcessesController.Step('Step 2 - Forms', 67, 34),
                3 => new ISSP_ICCS_CaseProcessesController.Step('Step 3 - Registration', 100, 33)};
	}
    
	public override List<String> getCaseProcessDocuments(){
	    return new List<String>{
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_AML,
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_A,
	        ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_K,
	        ISSP_ICCS_Utils.ICCS_DOCUMENT_MEMBERSHIP,
	        ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP,
	        ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS,
	        ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION};
	}


	public override Map<String, ISSP_ICCS_CaseProcessController.TypedDocument> getCaseProcessTypedDocumentMap(){
		return new Map<String, ISSP_ICCS_CaseProcessController.TypedDocument>{
			ISSP_ICCS_Utils.ICCS_DOCUMENT_AML => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_AML, true),
			ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_A => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_A, true),
			ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_K => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_K, true),
			ISSP_ICCS_Utils.ICCS_DOCUMENT_MEMBERSHIP => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_MEMBERSHIP, true),
			ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP, false),
			ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS, true),
			ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION, false)
		};
	}
    
    public override void resetController(ISSP_ICCS_CaseProcessesController caseProcessesController){}

	public override void cleanController(){}

    public override Case createCase(){
		return new Case(
			Subject = 'ICCS Service Join Request - ' + caseProcessesController.pageController.topAccount.Name,
			Status = 'Draft',
			Origin = 'Portal',
			Visible_on_ISS_Portal__c = true,
			CaseArea__c = ISSP_ICCS_Utils.CASE_AREA_JOIN_SERVICE,
			contactId = caseProcessesController.pageController.portalUserContact.Id,
			AccountId = caseProcessesController.pageController.topAccount.Id,
			Priority = 'Medium',
			RecordTypeId = ISSP_ICCS_Utils.CASE_RECORD_TYPE_MEMBERSHIP);
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
					Description
				from Case 
				where Id =: caseId];
	}

	public override void resetVariables(){
		caseProcessesController.cse.Expected_Deadline__c = caseProcessesController.cse.Expected_Deadline__c != null ? caseProcessesController.cse.Expected_Deadline__c : Date.today() + 15;
	}

    public override Boolean validateStep(){
        if(caseProcessesController.currentStep != 3){
            return true;
        }

        Boolean stepInvalid = false;
                
        Boolean isInvalid;

        for(String docType : typedDocumentsMap.keySet()){
            isInvalid = !typedDocumentsMap.get(docType).documentExists && typedDocumentsMap.get(docType).isMandatory;
            caseProcessesController.displayMessages.put(docType, isInvalid);

            stepInvalid |= isInvalid;
        }
        
        return !stepInvalid;
    }

	public override void setCaseFieldValues(){
		caseProcessesController.cse.Expected_Deadline__c = caseProcessesController.cse.Expected_Deadline__c != null ? caseProcessesController.cse.Expected_Deadline__c : Date.today() + 15;
	}
	
	public override void postSubmit(){
        // Update the ICCS Membership Status of the case's related Account
        Account acc = caseProcessesController.pageController.topAccount;
        acc.ICCS_Membership_Status__c = ISSP_ICCS_Utils.ICCS_MEMBERSHIP_PROSPECT;
        update acc;
	}

	public override Boolean displaySaveAndLeave(){
		return !((caseProcessesController.cse.Id == null || caseProcessesController.cse.Status == 'Draft') && caseProcessesController.currentStep != 3);
	}
}