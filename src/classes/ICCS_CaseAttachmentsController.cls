global class ICCS_CaseAttachmentsController{

    public Case cse {get;set;}

    public List<AttachmentWrapper> wrappedAmazonFiles {get;set;}

    /**
        Get alink to access to an amazon file, this link is time limited
    **/
    @RemoteAction
    global static String getExpiringLink(string fileName) {
        Integer secondsValid = 300;
        String link = AmazonRest.genPublicExpiringAWSLink( fileName, AmazonCredentials.getCredentials('GenericAttach'), secondsValid);
        return link;
    }
    
    
    public ICCS_CaseAttachmentsController(ApexPages.StandardController controller) {
        cse = [select Id, CaseNumber, AccountId, Account.Name from Case where Id =: ((Case)controller.getRecord()).id];
         
        Set<String> fileIdentifiersRetrieved = new Set<String>();

        wrappedAmazonFiles = new List<AttachmentWrapper>();

        for(AmazonFile__c amazonFile : [select Name, Full_Name_Unique__c, File_Identifier__c, File_Identifier_picklist__c, Review_Status__c, Original_Received__c, Internal_Comments__c, CreatedDate from AmazonFile__c where Case__c =: cse.Id order by File_Identifier__c, CreatedDate desc]){
        	if(!fileIdentifiersRetrieved.contains(amazonFile.File_Identifier__c)){
        		fileIdentifiersRetrieved.add(amazonFile.File_Identifier__c);
        		wrappedAmazonFiles.add(new AttachmentWrapper(this, amazonFile));
        	}
        }
    }
    
	public class AttachmentWrapper {
		public ICCS_CaseAttachmentsController ctrl;
		public AmazonFile__c att {get;set;}
		
		public String status {get;set;}
		public Boolean originalReceived {get;set;}
		
		public Boolean editMode {get;set;}
		
		public AttachmentWrapper(ICCS_CaseAttachmentsController ctrl, AmazonFile__c att){
			this.ctrl = ctrl;
			this.att = att;
			this.editMode = false;
		}
		
		public void updateAttachment(){
			status = att.Review_Status__c;
			originalReceived = att.Original_Received__c;
			editMode = true;
		}
		
		public void cancel(){
			att.Review_Status__c = status;
			att.Original_Received__c = originalReceived;
			editMode = false;
		}
		
		public void save(){
			update att;
			editMode = false;
		}		
	}
}