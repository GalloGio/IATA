public class ISSP_ICCS_ProcessAspUpdController extends ISSP_ICCS_CaseProcessController {

	/* PROCESS TYPE SPECIFIC VARIABLES */

    public ISSP_ICCS_ProcessAspUpdController thisCtrl {get{return this;}}
    
    public String description {get;set;}

	public String selectedTypeOfChange {get;set;}
    public List<SelectOption> typesOfChange {get;set;}


    /* CONSTRUCTOR */

    public ISSP_ICCS_ProcessAspUpdController(){}


	public override ISSP_ICCS_Utils.CaseProcessType getCaseProcessType(){
		return ISSP_ICCS_Utils.CaseProcessType.ASP_UPD;
	}

	public override String getCaseProcessName(){
		return 'Update Authorized Signatories Package';
	}

	public override Map<Integer, ISSP_ICCS_CaseProcessesController.Step> getSteps(){
        return new Map<Integer,ISSP_ICCS_CaseProcessesController.Step>{
		        1 => new ISSP_ICCS_CaseProcessesController.Step('Step 1 - Select Type of Change', 50, 50),
		        2 => new ISSP_ICCS_CaseProcessesController.Step('Step 2 - Upload ASP File', 100, 50)};
	}

	public override List<String> getCaseProcessDocuments(){
	    return new List<String>{
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP};
	}

	public override Map<String, ISSP_ICCS_CaseProcessController.TypedDocument> getCaseProcessTypedDocumentMap(){
		return new Map<String, ISSP_ICCS_CaseProcessController.TypedDocument>{
			ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP, true)
		};
	}
    
    public override void resetController(ISSP_ICCS_CaseProcessesController caseProcessesController){
		System.debug('ISSP_ICCS_ProcessAspUpdController.resetController(ISSP_ICCS_ServiceController pageController)');
		typesOfChange = new List<SelectOption>();
		
		typesOfChange.add(new SelectOption(ISSP_ICCS_Utils.NONE,ISSP_ICCS_Utils.NONE));
        typesOfChange.add(new SelectOption('ASP - Signatory Replacement','ASP - Signatory Replacement'));
        typesOfChange.add(new SelectOption('ASP - Signatory Replacement for Exec. Officer specifically','ASP - Signatory Replacement for Exec. Officer specifically'));
        typesOfChange.add(new SelectOption('ASP - Signatory Deletion','ASP - Signatory Deletion'));
        typesOfChange.add(new SelectOption('ASP - Signatory Addition','ASP - Signatory Addition'));
    }

	public override void cleanController(){
		System.debug('ISSP_ICCS_ProcessAspUpdController.cleanController()');

		selectedTypeOfChange = null;
		typesOfChange = null;
		description = null;
	}

    public override void fillAdditionalMessages(){
        caseProcessesController.displayMessages.put('selectedTypeOfChange', false);
	}

    public override Case createCase(){
		return new Case(
			Subject = 'ICCS Service Update ASP - ' + caseProcessesController.pageController.topAccount.Name,
			Origin = 'Portal',
			Status = 'Draft',
			CaseArea__c = ISSP_ICCS_Utils.CASE_AREA_UPDATE_ASP,
//			Reason1__c = 'Change Request',
			Visible_on_ISS_Portal__c = true,
			contactId = caseProcessesController.pageController.portalUserContact.Id,
			AccountId = caseProcessesController.pageController.topAccount.Id,
			Priority = 'Medium',
			RecordTypeId = ISSP_ICCS_Utils.CASE_RECORD_TYPE_ASP);
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
					Type_of_Change__c,
					Description
				from Case 
				where Id =: caseId];
	}

	public override void resetVariables(){
		if(caseProcessesController.cse.Id == null){
			caseProcessesController.cse.Expected_Deadline__c = Date.today() + 15;
			description = null;
			selectedTypeOfChange = ISSP_ICCS_Utils.NONE;
		}
		else{
			description = caseProcessesController.cse.Description;		
            selectedTypeOfChange = caseProcessesController.cse.Type_of_Change__c;
		}
	}

    public override Boolean validateStep(){
        Boolean stepValid = true;
        if(caseProcessesController.currentStep == 1){
            caseProcessesController.displayMessages.put('selectedTypeOfChange', selectedTypeOfChange == ISSP_ICCS_Utils.NONE);
            
            return  !caseProcessesController.displayMessages.get('selectedTypeOfChange');
        }
        else if(caseProcessesController.currentStep == 2){
            caseProcessesController.displayMessages.put(ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP, !typedDocumentsMap.get(ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP).documentExists);

            return ! caseProcessesController.displayMessages.get(ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP);
        }
        return true;
    }

	public override void setCaseFieldValues(){
		caseProcessesController.cse.Expected_Deadline__c = caseProcessesController.cse.Expected_Deadline__c != null ? caseProcessesController.cse.Expected_Deadline__c : Date.today() + 15;

        caseProcessesController.cse.Description = description;
        caseProcessesController.cse.Type_of_Change__c = selectedTypeOfChange == ISSP_ICCS_Utils.NONE ? null : selectedTypeOfChange;
        
        if(selectedTypeOfChange == 'ASP - Signatory Replacement' || selectedTypeOfChange == 'ASP - Signatory Deletion' || selectedTypeOfChange == 'ASP - Signatory Addition'){
        	caseProcessesController.cse.Reason1__c = 'Change of ASP';
        }
        else if(selectedTypeOfChange == 'ASP - Signatory Replacement for Exec. Officer specifically'){
        	caseProcessesController.cse.Reason1__c = 'Replacement of ASP';
        }
	}
}