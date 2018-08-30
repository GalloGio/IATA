public class ISSP_ICCS_FileUploadController{

	// parameter
    public ISSP_ICCS_CaseProcessesController caseProcessesController {
        get;
        set{
			System.debug('ISSP_ICCS_FileUploadController setting caseProcessesController : increment ' + ++ISSP_ICCS_ServiceController.increment);
            if(caseProcessesController == null && value != null){
				System.debug('ISSP_ICCS_FileUploadController setting caseProcessesController : caseProcessesController == null && value != null : increment ' + ++ISSP_ICCS_ServiceController.increment);
                caseProcessesController = value;
                caseProcessesController.fileUploadController = this;
            }
        }
    }

    public String fileName {get;set;}
    public Blob fileBody {get;set;} 
    public String contentType {get;set;}

    public Boolean isPanelDisplayed {get;set;}
    
    public Boolean filenameExists {get;set;}
    
    public Boolean noFileUploaded {get;set;}
    

	public void resetController(ISSP_ICCS_CaseProcessesController caseProcessesController){
		System.debug('ISSP_ICCS_FileUploadController.resetController(ISSP_ICCS_ServiceController pageController) : increment ' + ++ISSP_ICCS_ServiceController.increment);

		isPanelDisplayed = false;
		fileNameExists = false;
		noFileUploaded = false;
	}

    public void cleanController(){
		System.debug('ISSP_ICCS_FileUploadController.cleanController() : increment ' + ++ISSP_ICCS_ServiceController.increment);

    	fileName = null;
    	fileBody = null;
    	contentType = null;
    	isPanelDisplayed = null;
    	fileNameExists = null;
    	noFileUploaded = null;
    }

    
    public void upload(){
    	System.debug('ISSP_ICCS_FileUploadController.upload()');
    	noFileUploaded = false;
    	filenameExists = false;
    	
    	if(filename == '' || filename == null){
			System.debug('fileName empty or null');
    		noFileUploaded = true;
    		return;
    	}
    	
		// Check if a file with the same name already exists in the related case
		for(String docType : caseProcessesController.currentCaseProcessController.typedDocumentsMap.keySet()){
			ISSP_ICCS_CaseProcessController.TypedDocument typedDocument = caseProcessesController.currentCaseProcessController.typedDocumentsMap.get(docType);
			
			// Check if a file already existing in Amazon has the same name
			for(AmazonFile__c amazonFile : typedDocument.amazonFiles){
				if(amazonFile.Name == filename){
					System.debug('amazon file exists : "' + filename + '"');
					filename = '';
					filebody = null;
					contentType = '';
					filenameExists = true;
					return;
				}
			}

			// Check if a file about to be uploaded has the same name
			if(typedDocument.docName == filename){
				System.debug('uploaded file exists : "' + filename + '"');
				filename = '';
				filebody = null;
				contentType = '';
				filenameExists = true;
				return;
			}
		}

		System.debug('uploaded file is valid');

    	try{
	        Document doc = new Document();
	        doc.Name = filename;
	        doc.Body = filebody;
	        doc.ContentType = contentType;
	        doc.FolderId = caseProcessesController.pageController.portalUser.Id;
	        if(caseProcessesController.uploadType != null){
	        	doc.Description = caseProcessesController.uploadType;
	        }
	        
	        insert doc;
	        
	        filename = '';
	        filebody = null;
	        
			// uploadType should never be null
	        if(caseProcessesController.uploadType != null){
	            ISSP_ICCS_CaseProcessController.TypedDocument typedIccsDocument = caseProcessesController.currentCaseProcessController.typedDocumentsMap.get(caseProcessesController.uploadType);
	
	            typedIccsDocument.docId = doc.Id;
	            typedIccsDocument.docName = doc.Name;
	
	            if(typedIccsDocument.latestAmazonFile != null){
	                typedIccsDocument.markedForReplacement = true;
	                typedIccsDocument.markedForDeletion = false;
	            }
	
		        caseProcessesController.displayMessages.put(caseProcessesController.uploadType, false);
	        }

	        doc.Body = null;
	        doc = null;
	        
	        closePanel();
    	}
    	catch(Exception e){
    		System.debug('upload failed : ' + e);
    	}
    }
    
    public void cancel(){
    	System.debug('ISSP_ICCS_FileUploadController.cancel()');
        closePanel();
    }
    
    public void displayPanel(){
    	System.debug('ISSP_ICCS_FileUploadController.displayPanel()');
		isPanelDisplayed = true;
    }
        
    private void closePanel(){
    	System.debug('ISSP_ICCS_FileUploadController.closePanel()');
		filenameExists = false;
		noFileUploaded = false;
		caseProcessesController.uploadType = null;
        caseProcessesController.showFileUploadComponent = false;
        isPanelDisplayed = false;
    }
    
}