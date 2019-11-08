/**
*
* This controller is used to override Archive message view.
* It will load the orginal messaage from this Archive one
*
*/
global  class  ArchiveMessageExtensionController{

	public Archived_Message__c archivedMessage {get; set; }

	public EmailMessage originalMessage  {get; set; }

	public String archivedMessageId ;

	public void setArchivedMessageId(String s) {
		this.archivedMessageId = s;
		setArchivedMessage( [SELECT Name,EmailMessage__c,  Case__c, CreatedById, CreatedDate, Id FROM Archived_Message__c where Id = :s]);
	}

	public String getArchivedMessageId() {
		return this.archivedMessageId;
	}

	public void setArchivedMessage(Archived_Message__c m) {
		this.archivedMessage = m;
		this.originalMessage = [SELECT ParentId, IsDeleted, Id, ActivityId, Incoming, Status, BccAddress, CcAddress, CreatedById, CreatedDate, FromAddress, FromName, HtmlBody, HasAttachment, Headers, LastModifiedById, LastModifiedDate, MessageDate, Subject, SystemModstamp, TextBody, ToAddress FROM EmailMessage where Id  = :m.EmailMessage__c ];
	}

	public Archived_Message__c getArchivedMessage() {
		return this.archivedMessage;
	}

	/**
	* Constructor.
	*
	*/
	public ArchiveMessageExtensionController( ) {

	}
}
