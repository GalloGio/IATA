public class ISSP_ICCS_ProcessDeactivationController extends ISSP_ICCS_CaseProcessController {

	/* PROCESS TYPE SPECIFIC VARIABLES */

    public ISSP_ICCS_ProcessDeactivationController thisCtrl {get{return this;}}

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


    /* CONSTRUCTOR */

    public ISSP_ICCS_ProcessDeactivationController(){}


	public override ISSP_ICCS_Utils.CaseProcessType getCaseProcessType(){
		return ISSP_ICCS_Utils.CaseProcessType.DEACTIVATION;
	}

	public override String getCaseProcessName(){
		return 'Deactivate ICCS Membership';
	}

	public override Map<Integer, ISSP_ICCS_CaseProcessesController.Step> getSteps(){
        return new Map<Integer,ISSP_ICCS_CaseProcessesController.Step>{
            1 => new ISSP_ICCS_CaseProcessesController.Step('A. Fill BLAH BLAH BLA', 100, 100)};
	}

	public override List<String> getCaseProcessDocuments(){
	    return new List<String>{
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_DEACTIVATION};
	}

	public override Map<String, ISSP_ICCS_CaseProcessController.TypedDocument> getCaseProcessTypedDocumentMap(){
		return new Map<String, ISSP_ICCS_CaseProcessController.TypedDocument>{
			ISSP_ICCS_Utils.ICCS_DOCUMENT_DEACTIVATION => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_DEACTIVATION, true)
		};
	}
   
    public override void resetController(ISSP_ICCS_CaseProcessesController caseProcessesController){
		System.debug('ISSP_ICCS_ProcessDeactivationController.resetController(ISSP_ICCS_ServiceController pageController) **** increment : ' + ++ISSP_ICCS_ServiceController.increment);
    }

	public override void cleanController(){
		System.debug('ISSP_ICCS_ProcessDeactivationController Constructor **** increment : ' + ++ISSP_ICCS_ServiceController.increment);

		description = null;

		reason = null;
		reasonsList = null;
	}

	public override Case createCase(){
		return new Case(
			Subject = 'ICCS Service Deactivation Request - ' + caseProcessesController.pageController.topAccount.Name,
			Status = 'Draft',
			Origin = 'Portal',
			CaseArea__c = ISSP_ICCS_Utils.CASE_AREA_LEAVE_SERVICE,
			Visible_on_ISS_Portal__c = true,
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
					Reason1__c,
					Description
				from Case 
				where Id =: caseId];
	}

	public override void resetVariables(){
		if(caseProcessesController.cse.Id == null){
			caseProcessesController.cse.Expected_Deadline__c = Date.today() + 15;

			description = null;
			reason = ISSP_ICCS_Utils.NONE;
		}
		else{
			description = caseProcessesController.cse.Description;
			reason = caseProcessesController.cse.Reason1__c == null ? ISSP_ICCS_Utils.NONE : caseProcessesController.cse.Reason1__c;
		}
	}

    public override Boolean validateStep(){
        Boolean stepInvalid = false;

        Boolean reasonInvalid = reason == null || reason == ISSP_ICCS_Utils.NONE;
        caseProcessesController.displayMessages.put('reason', reasonInvalid);
        
        Boolean descriptionInvalid = reason == 'Other - Please Specify' && (description == null || description == '');
        caseProcessesController.displayMessages.put('description', descriptionInvalid);
        
        stepInvalid = reasonInvalid || descriptionInvalid;
       
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

		if(reason == 'Other - Please Specify'){
			caseProcessesController.cse.Description = description;
		}
        
        caseProcessesController.cse.Reason1__c = reason == ISSP_ICCS_Utils.NONE ? null : reason;
	}
	
	public override void fillAdditionalMessages(){
        caseProcessesController.displayMessages.put('reason', false);
        caseProcessesController.displayMessages.put('description', false);
	}
}