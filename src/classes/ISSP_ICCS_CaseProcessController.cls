public abstract class ISSP_ICCS_CaseProcessController{

    public ISSP_ICCS_CaseProcessesController caseProcessesController {
    	get;
    	set{
			System.debug('ISSP_ICCS_CaseProcessController setting caseProcessesController : increment ' + ++ISSP_ICCS_ServiceController.increment);
            if(value != null && caseProcessesController == null){
				System.debug('ISSP_ICCS_CaseProcessController setting caseProcessesController : value != null && caseProcessesController == null increment ' + ++ISSP_ICCS_ServiceController.increment);
				caseProcessesController =  value;
                caseProcessesController.caseProcessTypesMap.put(getCaseProcessType(),this);
				resetControllerAndParentController(caseProcessesController);
            }
		}
    }

    public Map<String,ISSP_ICCS_CaseProcessController.TypedDocument> typedDocumentsMap {
    	get{ 
    		if(typedDocumentsMap == null){
    			typedDocumentsMap = getCaseProcessTypedDocumentMap();
    		}
    		return typedDocumentsMap;
    	}
    	set;
    }

	public void resetControllerAndParentController(ISSP_ICCS_CaseProcessesController caseProcessesController){
		System.debug('ISSP_ICCS_CaseProcessController.resetControllerAndParentController(ISSP_ICCS_CaseProcessesController caseProcessesController) : increment ' + ++ISSP_ICCS_ServiceController.increment);

		// Reset Case Process controller
		resetController(caseProcessesController);

		// Reset CaseProcesses controller
		caseProcessesController.resetControllerFromCaseProcess();

		// Clean previous component
		if(caseProcessesController.pageController.componentControllersMap.get(caseProcessesController.pageController.previousComponent) != null){
			caseProcessesController.pageController.componentControllersMap.get(caseProcessesController.pageController.previousComponent).cleanController();
		}
		
		// Clean pageController
		caseProcessesController.pageController.caseIdParameter = null;
	}

	public void baseClassCleanController(){
		cleanController();
		
		typedDocumentsMap = null;		
	}

    
	/*******************************************************/
	/***** CASE PROCESSES ABSTRACT AND VIRTUAL METHODS *****/
	/*******************************************************/
	
	public abstract void resetController(ISSP_ICCS_CaseProcessesController caseProcessesController);
	public abstract void cleanController();

	public abstract ISSP_ICCS_Utils.CaseProcessType getCaseProcessType();
	
	// Called in ISSP_ICCS_CaseProcessController.resetController()
	public abstract String getCaseProcessName();
	public abstract List<String> getCaseProcessDocuments();
	public abstract Map<String, ISSP_ICCS_CaseProcessController.TypedDocument> getCaseProcessTypedDocumentMap();
	public abstract Map<Integer,ISSP_ICCS_CaseProcessesController.Step> getSteps();
	
    public virtual void fillAdditionalMessages(){}
    public abstract Case createCase();
    public abstract Case retrieveCase(Id caseId);
    public abstract void resetVariables();

	// Called in ISSP_ICCS_CaseProcessController.saveAndLeave() and ISSP_ICCS_CaseProcessController.submit()
    public abstract void setCaseFieldValues();
    public virtual void handleSubmittedCase(){}
    public virtual void postSubmit(){}    
    public abstract Boolean validateStep();

    public virtual Boolean displaySaveAndLeave(){return true;}
    
    
    /* INNER CLASS */
    public class TypedDocument{
    	public ISSP_ICCS_CaseProcessController caseProcessController {get;set;}
    	
	    public String documentType {get;set;}
	
	    public Boolean isMandatory {get;set;}
	
		// Status of the attachment
	    public Boolean markedForDeletion {get;set;}
	    public Boolean markedForReplacement {get;set;}
	
	    public String docId {get;set;}
	    public String docName {get;set;}
	
	    public List<AmazonFile__c> amazonFiles {get;set;}
	
	    public AmazonFile__c latestAmazonFile {get{ return amazonFiles.isEmpty() ? null : amazonFiles[0]; }}
	
		public String amazonFileName { get{ return amazonFiles.isEmpty() ? null : amazonFiles[0].Name; }}
	
		public String amazonFileUniqueName { get{ return amazonFiles.isEmpty() ? null : amazonFiles[0].Full_Name_Unique__c; }}
	
	    public Boolean documentExists { get{ System.debug('DOC TYPE : ' + documentType);System.debug('AMAZON FILES NULL ? : ' + (amazonfiles == null));return (!amazonFiles.isEmpty() || docId != null) && !markedForDeletion; }}
	
	
		/* CONSTRUCTOR */
	
	    public TypedDocument(ISSP_ICCS_CaseProcessController caseProcessController, String documentType, Boolean isMandatory){
			this.caseProcessController = caseProcessController;
	    	this.documentType = documentType;
	    	this.isMandatory = isMandatory;
	    	
	    	markedForDeletion = false;
	    	markedForReplacement = false;
	    	
	    	amazonFiles = new List<AmazonFile__c>();
	    }
	    
	    
	    public void cancelReplacement(){
	        markedForReplacement = false;
	
	        Document doc = [select Id from Document where Id =: docId];
	        delete doc;
	        
	        docId = null;
	        docName = null;    
	    }
	    
	    public void showFileUploadComponent(){
	        caseProcessController.caseProcessesController.uploadType = documentType;
	        caseProcessController.caseProcessesController.showFileUploadComponent = true;
	    }
	    
	    public void deleteDocument(){
	        if(caseProcessController.caseProcessesController.caseStatusBeforeSaving != 'OPEN'){
	            if(latestAmazonFile != null){
	                markedForDeletion = true;
	            }
	            else{
	                Document doc = [select Id from Document where Id =: docId];
	                delete doc;
	
			        docId = null;
			        docName = null;
	            }
	        }
	    }
	
	    public void cancelDeletion(){
	        markedForDeletion = false;
	    }
    }
}