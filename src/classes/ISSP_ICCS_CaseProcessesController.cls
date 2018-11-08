global class ISSP_ICCS_CaseProcessesController extends ISSP_ICCS_ComponentController{

	// Used to pass as a parameter to the ISSP_ICCS_FileUploadController
    public ISSP_ICCS_CaseProcessesController thisCtrl{ get{ return this; }}

	public ISSP_ICCS_FileUploadController fileUploadController {get;set;}
	
	public Boolean scrollToCaseProcessesPanel {get;set;}

	// Map of case process type controllers
    public Map<ISSP_ICCS_Utils.CaseProcessType,ISSP_ICCS_CaseProcessController> caseProcessTypesMap {
    	get{
    		if(caseProcessTypesMap == null){
		        caseProcessTypesMap = new Map<ISSP_ICCS_Utils.CaseProcessType,ISSP_ICCS_CaseProcessController>();
    		}
    		return caseProcessTypesMap;
    	}
    	set;
    }
    
	// Controller of the current case process type
	public ISSP_ICCS_CaseProcessController currentCaseProcessController { get{ return caseProcessTypesMap.get(pageController.currentCaseProcessType); }}


	/*******************************************/
	/***** CASE PROCESSES COMMON VARIABLES *****/
	/*******************************************/

    public String caseProcessName { get{ return currentCaseProcessController.getCaseProcessName(); }}

	/* Case variables */
	
    public Case cse {get;set;}
    public String caseStatusBeforeSaving {get;set;}


	/* Comments variables */
    
    public List<CaseComment> cseComments {get;set;}
    public Integer cseCommentsSize { get{ return cseComments.size(); }}
	public Boolean displayAddComment {get;set;}
    public CaseComment portalUserComment {get;set;}


	/* post-submit variables */

	public ISSP_AmazonS3_Ctrl amazonFilesController {get;set;}
	public Boolean savedOrSubmitted {get;set;}
	public Boolean submitFailed {get;set;}
	public Boolean documentsUploaded {get;set;}

	
	/* Uploaded documents variables */

	public Boolean showFileUploadComponent {get;set;}
    public String uploadType {get;set;}


	/* Step related variables */

    public Map<Integer,Step> steps {
    	get{
    		if(steps == null){
    			return new Map<Integer,Step>();
    		}
    		else{
    			return steps;
    		}
    	}
    	set;
    }
    public Integer currentStep {get;set;}
    public Boolean singleStep {get{return steps == null || steps.keySet().size() < 2;}}
    public List<Integer> stepNumbers {
    	get{
			List<Integer> stepNumbers = new List<Integer>(steps.keySet());
        	stepNumbers.sort();
    		return stepNumbers;
    	}
    }

	public Boolean displayPrevious 		{ get{ return currentStep > 1 && caseStatusBeforeSaving != 'OPEN'; }}
	public Boolean displayNext 			{ get{ return currentStep != null && currentStep < steps.size() && caseStatusBeforeSaving != 'OPEN'; }}
	public Boolean displaySaveAndLeave 	{ get{ return currentCaseProcessController.displaySaveAndLeave(); }}
	public Boolean displaySubmit 		{ get{ return currentStep == steps.size() || caseStatusBeforeSaving == 'OPEN'; }}


	/* Step validation variables */

    public Map<String,Boolean> displayMessages {get;set;}


	/* Attachments list variables */

   	// Whole attachments list
    public List<AmazonFileRow> amazonFileTable {
    	get{
			if(amazonFileTable == null){
	    		amazonFileTable = new List<AmazonFileRow>();
	    		
	    		for(String docType : currentCaseProcessController.typedDocumentsMap.keySet()){
	    			ISSP_ICCS_CaseProcessController.TypedDocument typedDocument = currentCaseProcessController.typedDocumentsMap.get(docType);
	
					if(typedDocument.amazonFiles.isEmpty()){
						AmazonFileRow row = new AmazonFileRow(typedDocument, null, true);
						amazonFileTable.add(row);
					}
					else{
						// Add first row
						AmazonFileRow row = new AmazonFileRow(typedDocument, typedDocument.amazonFiles.get(0), true);
	
						// Add other rows if any
						if(typedDocument.amazonFiles.size() > 1){
							for(Integer i = 1; i < typedDocument.amazonFiles.size(); i++){
								row.subRows.add(new AmazonFileRow(typedDocument, typedDocument.amazonFiles.get(i), false));
							}
						}
						amazonFileTable.add(row);
					}
	    		}
			}
			return amazonFileTable;
		}
		set;
    }

	// Filtered list to be displayed
	public List<AmazonFileRow> flattenedAmazonFileTable {
		get{
    		List<AmazonFileRow> table = new List<AmazonFileRow>();

			for(AmazonFileRow amazonFileRow : amazonFileTable){
				table.add(amazonFileRow);
				if(amazonFileRow.isExpanded){
					for(AmazonFileRow subRow : amazonFileRow.subRows){
						table.add(subRow);
					}
				}
			}
			return table;
		}
	}

	// Used to determinate if the New Attachment column must be displayed or not
	public Boolean newAttachmentUploaded {
		get{
			for(AmazonFileRow amazonFileRow : flattenedAmazonFileTable){
				if(amazonFileRow.typedDocument.docId != null && amazonFileRow.typedDocument.docId != ''){
					return true;
				}
			}
			return false;
		}
	}


	/* CONSTRUCTOR */
	public ISSP_ICCS_CaseProcessesController(){}


	public override ISSP_ICCS_Utils.Page getComponentType(){
		return ISSP_ICCS_Utils.Page.CASE_PROCESSES;
	}


	/*******************************************/
	/***** CASE PROCESSES COMMON METHODS *****/
	/*******************************************/

	public override Boolean resetController(ISSP_ICCS_ServiceController pageController){
		System.debug('ISSP_ICCS_CaseProcessesController.resetController(ISSP_ICCS_ServiceController pageController) : increment ' + ++ISSP_ICCS_ServiceController.increment);

		/* If the current Case Process has already been visited, call its resetControllerAndParentController method
		 Otherwise, don't do anything, the method will be called by Case Process later */
        if(currentCaseProcessController != null){
	        currentCaseProcessController.resetControllerAndParentController(this);
        }
        return false;
	}

	public void resetControllerFromCaseProcess(){
		System.debug('ISSP_ICCS_CaseProcessesController.resetControllerFromCaseProcess() : increment ' + ++ISSP_ICCS_ServiceController.increment);
        savedOrSubmitted = false;
        submitFailed = false;
        documentsUploaded = false;
        
        scrollToCaseProcessesPanel = false;

        displayAddComment = false;

		showFileUploadComponent = false;
        
        displayMessages = new Map<String,Boolean>();
        for(String processDocument: currentCaseProcessController.getCaseProcessDocuments()){
            displayMessages.put(processDocument, false);
        }
        currentCaseProcessController.fillAdditionalMessages();

		// Retrieve the steps from the current CaseProcess controller
		steps = currentCaseProcessController.getSteps();
        currentStep = 1;

		// Retrieve the Case Id Parameter from the page Controller
		Id caseId = pageController.caseIdParameter;

        // Case 1 : Create a new case
        if(caseId == null){
            cse = currentCaseProcessController.createCase();
            caseStatusBeforeSaving = 'NEW';

			cseComments = new List<CaseComment>();
        }
        // Case 2 : Load an existing case
        else{
            cse = currentCaseProcessController.retrieveCase(caseId);
            
            if(cse.Status == 'Draft'){
                caseStatusBeforeSaving = 'DRAFT';
            }
            else{
                caseStatusBeforeSaving = 'OPEN';
            }

            cseComments = [select CommentBody, CreatedBy.FirstName, CreatedBy.LastName, CreatedDate from CaseComment where ParentId =: cse.Id order by CreatedDate desc];
            amazonFilesController = new ISSP_AmazonS3_Ctrl(new ApexPages.StandardController(cse));
            portalUserComment = new CaseComment(CommentBody = '');
            
            loadAttachments();
        }
        
        currentCaseProcessController.resetVariables();	
	}

	/* TO BE REVIEWED */ 
	public override void cleanController(){
		System.debug('ISSP_ICCS_CaseProcessesController.cleanController() : increment ' + ++ISSP_ICCS_ServiceController.increment);
		
		currentCaseProcessController.baseClassCleanController();
		
		fileUploadController.cleanController();
		
		cse = null;
		caseStatusBeforeSaving = null;
		
		cseComments = null;
		displayAddComment = null;
		portalUserComment = null;
		
		amazonFilesController = null;
		savedOrSubmitted = null;
		submitFailed = null;
		documentsUploaded = null;
		
		scrollToCaseProcessesPanel = null;
		
		showFileUploadComponent = null;
		uploadType = null;
		
		steps = null;
		currentStep = null;
		
		displayMessages = null;
		
		amazonFileTable = null;		
	}
	
    public void loadAttachments(){
		System.debug('ISSP_ICCS_CaseProcessesController.loadAttachments() : increment ' + ++ISSP_ICCS_ServiceController.increment);
        // Retrieve AmazonFile__c items
        List<AmazonFile__c> amazonFiles = [select Id, Name, Case__c, File_Identifier__c, Category__c, Subcategory__c, Review_Status__c, Full_Name_Unique__c, Internal_Comments__c, Original_Received__c, CreatedDate from AmazonFile__c where Case__c =: cse.Id order by CreatedDate desc];

		// Assign them to the Case Process Typed Documents if already set
		System.debug('currentCaseProcessController.typedDocumentsMap.keySet() : ' + currentCaseProcessController.typedDocumentsMap.keySet());
        for(AmazonFile__c amazonFile : amazonFiles){
        	System.debug('amazonFile.File_Identifier__c : ' + amazonFile.File_Identifier__c);
            currentCaseProcessController.typedDocumentsMap.get(amazonFile.File_Identifier__c).amazonFiles.add(amazonFile);
        }
    }

    /**
        Get alink to access to an amazon file, this link is time limited
    **/
    @RemoteAction
    global static String getExpiringLink(string fileName) {
        Integer secondsValid = 300;
        String link = AmazonRest.genPublicExpiringAWSLink( fileName, AmazonCredentials.getCredentials('GenericAttach'), secondsValid);
        return link;
    }

	/* Navigation methods */

    public void previous(){
		pageController.resetMessage();
    	currentStep--;
        scrollToCaseProcessesPanel = true;
    }

    public void next(){
		pageController.resetMessage();
    	if(currentCaseProcessController.validateStep()){
	        currentStep++;
    	}
    	else{
    		pageController.setMessage('Please, review the errors below', false);
    	}
        scrollToCaseProcessesPanel = true;
    }
    
    public void closePage(){
        pageController.saveAndClose(cse.Id);
    }

	/* Comments methods */

    public void showAddComment(){
        displayAddComment = true;
    }
    
    public void hideAddComment(){
        displayAddComment = false;
        portalUserComment.CommentBody = '';
    }

	/* Save methods */

    public virtual void saveAndLeave(){
		System.debug('ISSP_ICCS_CaseProcessesController.saveAndLeave() : increment ' + ++ISSP_ICCS_ServiceController.increment);

		pageController.resetMessage();

        try{
            currentCaseProcessController.setCaseFieldValues();
            
            upsert cse;
            
            currentCaseProcessController.postSubmit();
            
            savedOrSubmitted = true;
        }
        catch(Exception e){
			System.debug('ISSP_ICCS_CaseProcessesController.saveAndLeave() ERROR ' + e.getMEssage() + ' : increment ' + ++ISSP_ICCS_ServiceController.increment);
            pageController.setMessage(e.getMessage(), false);
            submitFailed = true;
	        scrollToCaseProcessesPanel = true;
        }
    }

    public void submit(){
		System.debug('ISSP_ICCS_CaseProcessesController.submit() : increment ' + ++ISSP_ICCS_ServiceController.increment);

		pageController.resetMessage();

        if(currentCaseProcessController.validateStep()){
	        try{
	            // New or Draft Case
	            if(cse.Id == null || cse.Status == 'Draft'){
	                currentCaseProcessController.setCaseFieldValues();
	
	                List<Group> queue = [select Id from Group where DeveloperName = 'AirlineParticipationHeadOffice' and Type = 'Queue'];
	                cse.OwnerId = queue[0].id;
	            }
	            // Opened Case
	            else{
	                currentCaseProcessController.handleSubmittedCase();
	                
	                // Create portal user comment if necessary 
	                if(portalUserComment.CommentBody != ''){
	                    portalUserComment.ParentId = cse.Id;
	                    insert portalUserComment;
	                }
	            }
	            
	            cse.Status = 'For Review and Acceptance';
	            upsert cse;
	
	            currentCaseProcessController.postSubmit();
	
	            savedOrSubmitted = true;
	        }
	        catch(Exception e){
				System.debug('ISSP_ICCS_CaseProcessesController.submit() ERROR ' + e.getMEssage() + ': increment ' + ++ISSP_ICCS_ServiceController.increment);
	            pageController.setMEssage(e.getMessage(), false);
	        	submitFailed = true;
		        scrollToCaseProcessesPanel = true;
	        }
        }
        else{
    		pageController.setMessage('Please, review the errors below', false);
        	submitFailed = true;
	        scrollToCaseProcessesPanel = true;
        }
    }    

	public void resetSubmitFailed(){
		submitFailed = false;
	}

	/* Post-save methods */

    public void saveAttachmentsToAmazon(){
		System.debug('ISSP_ICCS_CaseProcessesController.saveAttachmentsToAmazon() : increment ' + ++ISSP_ICCS_ServiceController.increment);
        // amazonFilesController is null if the case has not been inserted yet
        if(amazonFilesController == null){
            amazonFilesController = new ISSP_AmazonS3_Ctrl(new ApexPages.StandardController(cse));
        }

        List<String> createAmazonFileFromDocument = new List<String>();

        List<AmazonFile__c> amazonFilesToDelete = new List<AmazonFile__c>();


        for(ISSP_ICCS_CaseProcessController.TypedDocument typedDocument : currentCaseProcessController.typedDocumentsMap.values()){
            if(typedDocument.markedForDeletion){
                amazonFilesToDelete.add(typedDocument.latestAmazonFile);
            }
            else if(typedDocument.markedForReplacement){
                createAmazonFileFromDocument.add(typedDocument.docId);

                if(caseStatusBeforeSaving != 'OPEN'){
                    // If the case has not been submitted yet but only saved in Draft Status, an Amazon File will be deleted if user replaces it
                    amazonFilesToDelete.add(typedDocument.latestAmazonFile);
                }
            }
            else if(typedDocument.docId != null){
                createAmazonFileFromDocument.add(typedDocument.docId);
            }
        }

        // Retrieve the list of documents that will be uploaded to Amazon and for which an amazonFile__c will be created
        List<Document> documentsToUpload = [select Id, Name, Body, BodyLength, Description, ContentType from Document where Id in :createAmazonFileFromDocument];

        // Delete the replaced Amazon Files if the Case has not been submitted yet
        for(AmazonFile__c amazonFile : amazonFilesToDelete){
            AmazonRest.deleteFile(amazonFile.Full_Name_Unique__c, AmazonCredentials.getCredentials('GenericAttach'));
        }

        // Upload the documents to Amazon
        for(Document doc : documentsToUpload){
            AmazonRest.uploadFile(UploadMultipleFileToAmazonButtonCtrl.createUploadFile(cse.Id, doc.Name, doc.ContentType, doc.BodyLength, WrapperAttach.getAmazonFolder(cse.Id), 'GenericAttach'), doc.Body);
        }
        
        // Delete the AmazonFile__c records in SF
        delete amazonFilesToDelete;
        
        // Create the new AmazonFiles in SF
        List<AmazonFile__c> amazonFilesToCreate = new List<AmazonFile__c>();

        for(Document doc : documentsToUpload){          
            AmazonFile__c amazonFile = new AmazonFile__c(
                Name = doc.Name,
                Full_Name_Unique__c = '500/' + String.valueOf(cse.Id) + '/' + doc.Name,
                File_Identifier__c = doc.Description,
                File_Identifier_picklist__c = doc.Description,
                Review_Status__c = 'Pending',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AmazonFile__c', 'ICCS_File');
                Size_MB__c = doc.BodyLength* 0.000001, //convert to MB
                isPublic__c = true,
                Case__c = cse.Id
            );
            amazonFilesToCreate.add(amazonFile);
        }
        
        insert amazonFilesToCreate;
        
        delete documentsToUpload;
        
        documentsUploaded = true;
    }


	/* INNER CLASSES */

    public class Step{
        public String navTitle {get;set;}
        public Integer ariaValuenow {get;set;}
        public Integer width {get;set;}

        public Step(String navTitle, Integer ariaValuenow, Integer width){
            this.navTitle = navTitle;
            this.ariaValuenow = ariaValuenow;
            this.width = width;
        }
    }


    public class AmazonFileRow{
    	public ISSP_ICCS_CaseProcessController.TypedDocument typedDocument {get;set;}
    	public AmazonFile__c amazonFile {get;set;}
    	public List<AmazonFileRow> subRows {get;set;}

    	public String name 				{ get{ return amazonFile == null ? 'No File' : amazonFile.Name; }}
    	public String fullUniqueName 	{ get{ return amazonFile == null ? null : amazonFile.Full_Name_Unique__c; }}
    	public String status 			{ get{ return amazonFile == null ? '' : amazonFile.Review_Status__c; }}
    	public Boolean originalReceived { get{ return amazonFile == null ? false : amazonFile.Original_Received__c; }set;}
    	public String comments 			{ get{ return amazonFile == null ? '' : amazonFile.Internal_Comments__c; }}    	
    	public DateTime createdDate 	{ get{ return amazonFile == null ? null : amazonFile.CreatedDate; }}
    	
    	public Boolean isFirstRow {get;set;}
    	public Boolean isExpandable { get{ return subRows.size() > 0; }}
    	public Boolean isExpanded {get;set;}
    	
    	public AmazonFileRow(ISSP_ICCS_CaseProcessController.TypedDocument typedDocument, AmazonFile__c amazonFile, Boolean isFirstRow){
    		this.typedDocument = typedDocument;
    		this.amazonFile = amazonFile;
    		subRows = new List<AmazonFileRow>();
    		this.isFirstRow = isFirstRow;
    		isExpanded = false;
    	}
    	
    	public void expand(){
    		isExpanded = true;
    	}
    	
    	public void collapse(){
    		isExpanded = false;
    	}
    }   
}