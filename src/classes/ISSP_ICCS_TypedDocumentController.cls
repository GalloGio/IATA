public class ISSP_ICCS_TypedDocumentController{

    // parameter
	public ISSP_ICCS_CaseProcessController caseProcessController {get;set;}

    // parameter
    public String documentType {get;set;}
    
    public ISSP_ICCS_CaseProcessController.TypedDocument typedDocument { get{ System.debug('documentType : ' + documentType);return caseProcessController.typedDocumentsMap.get(documentType); }}
    
    public void showFileUploadComponent(){
        caseProcessController.caseProcessesController.uploadType = documentType;
        caseProcessController.caseProcessesController.showFileUploadComponent = true;
    }
}