/**
* This class is in charge of moving aatchment from SFDC to Amazon && to create records to preserve system architecture
*/
public with sharing class ArchivedFuturAdapter {

	private static AWSTools aws = null;
	private static String bucket  = '';
	private static String awsurlPrefix  = 'https://s3.amazonaws.com/';
	private static String default_permission  = 'authenticated-read';
	//use system.debug('[Attachment Migration Process debug]'); for debug

	private static void init(){
		String name = 'production';
		if(DevsTools.isRunningInSandbox())
			name = 'sandbox';
		AWSKey__c awsc = [SELECT Bucket__c, Name, Id, Secret__c, Key__c FROM AWSKey__c where Name = :name limit 1];
		if(awsc !=null){
			ArchivedFuturAdapter.bucket = awsc.Bucket__c;
			aws = AWSTools.getInstance(name);
		}
	}

	/**
	* private method in cahrge of attachment without buisness logic.
	* Be careful: here all space caractere in file name will be remove from amazon uploaded file name
	*/
	private  static Archived_Attachment__c performAWSMigration(Attachment a,list<SObject> toDelete,list<Archived_Attachment__c> toInsert) {
			if(aws==null )
				init();
			Attachment anAttachement = [SELECT Id, Body, ParentId, ContentType, Description, CreatedDate,CreatedById, BodyLength, Name,OwnerId FROM Attachment where Id = :a.Id] ;
			String amazonFileName = a.CreatedDate.getTime()+'_'+ anAttachement.Id+'_'+  anAttachement.Name.replaceAll(' ','') ;
			system.debug('[Attachment Migration Process debug]Ask to move attachment '+anAttachement.Id +' Parent Id = '+anAttachement.parentId);
			system.debug('[Attachment Migration Process debug]AWS Call yith parameters : '+ArchivedFuturAdapter.bucket+ ' /  '+ ArchivedFuturAdapter.default_permission+ '   /   '+anAttachement.Id+'_'+ anAttachement.Name + ' ***** ' +anAttachement.Body.size() + 'lenth = '+ anAttachement.BodyLength );
			if((Limits.getHeapSize() + anAttachement.BodyLength) > Limits.getLimitHeapSize()) {
				// Do something else
				DevsTools.sendSFDevsAlertMessage('Top big file request for attachement '+a.Id, ' Size: '+(Limits.getHeapSize() + a.BodyLength )+' compare to  '+Limits.getLimitHeapSize());
				return null;
			}
			system.debug(' Size: '+(Limits.getHeapSize() + anAttachement.BodyLength )+' compare to '+Limits.getLimitHeapSize());
			boolean fileUploadResult = true;
			fileUploadResult = ArchivedFuturAdapter.aws.pushFileInAWS( ArchivedFuturAdapter.bucket, ArchivedFuturAdapter.default_permission ,  anAttachement.Body  , amazonFileName,  anAttachement.BodyLength);

			if(fileUploadResult){
				//insert awsObject;
				Archived_Attachment__c archivedAttachment = new Archived_Attachment__c();
				archivedAttachment.Bucket__c = ArchivedFuturAdapter.bucket;
				archivedAttachment.Name =anAttachement.Name;
				 archivedAttachment.OriginalCreatedBy__c =anAttachement.CreatedById;
				archivedAttachment.Original_Creation_Date__c =anAttachement.CreatedDate;
				archivedAttachment.BodyLength__c =anAttachement.BodyLength;
				//working on email nessage, parent Id will be replace by EmailMessage Id after...
				archivedAttachment.Case__c = anAttachement.ParentId;
				archivedAttachment.AWS_S3_URL__c = ArchivedFuturAdapter.bucket+'/'+ amazonFileName ;
				toInsert.add(archivedAttachment);

				toDelete.add(a);
				system.debug('[Attachment Migration Process debug]Should have create an attachment in Amazon *******'+ anAttachement.Name + ' has moved to amazon');
				return archivedAttachment;
			}
			system.debug('[Attachment Migration Process debug]Upload to Amazon failed  ***** '+ anAttachement.Name + ' **** stay in  SFDC');
			return null;
	}

	/**
	*
	*    this method will create a file on Amazon and a record on Archived_Attachment__c.
	*    It will also destroy previous records and file from SFDC
	*
	*/
	@future (callout=true)
	public static void archivedCasesAttachment( Set<String> newClosedCase) {
		//Case attachement first
		list<Attachment> caseAttachement = [select Id, Body, ParentId, ContentType, Description, BodyLength, Name,OwnerId , CreatedDate from Attachment where ParentId in :newClosedCase];
		list<Archived_Attachment__c> toInsert = new List<Archived_Attachment__c>();
		list<Attachment> toDelete = new List<Attachment>();
		if(caseAttachement.size()>0){
			for(Attachment a:caseAttachement){
				ArchivedFuturAdapter.performAWSMigration(a,toDelete,toInsert);
			}
		}
		if(toInsert.size()>0)
			insert toInsert;
		delete toDelete;
	}

	/**

	   Ask for deletion of files from AWS

	*/
	@future (callout=true)
	public static void deleteFileOnAmazon( List<String> filesToDelete) {
		if(aws==null)
		   init();
		for(String s:filesToDelete){
			system.debug('[ArchivedAttachmentDeletionTrigger] deletion of   '+s+' on Amazon requested requested ');
			aws.removeFileFromS3(bucket, s);
		}
	}



	/**
	* Process list<Case> for their Email message :
	for each of them, will :
	* upload file onS3
	* create an Archived Message record
	* link EmailMessage to archived Message
	* delete original file from SFDC
	*
	*/
	@future (callout=true)
	public static void archivedEmailMessages( Set<String>  messagesIds ) {
		Map<String,EmailMessage> emailMessages = new Map<String, EmailMessage> ();
		Map<String , Task> emailMessagesActivities = new Map<string,Task>();
		List<String> actIds = new List<String>();
		for(EmailMessage em:[SELECT BccAddress, CcAddress, ActivityId, ParentId, CreatedById, CreatedDate, IsDeleted, Id, FromAddress, FromName, HtmlBody, HasAttachment, Headers, Incoming, LastModifiedById, LastModifiedDate, MessageDate, Status, Subject, SystemModstamp, TextBody, ToAddress FROM EmailMessage where Id in :messagesIds]){
			actIds.add(em.ActivityId);
			emailMessages.put(em.Id,em);
		}
		for(Task t:[SELECT Id, Status FROM Task where Id in :actIds])
			emailMessagesActivities.put(t.Id,t);
		system.debug('[Attachment Migration Process debug]Find '+emailMessages.size()+ ' messages to transform');

		List<Attachment> messageAttachments = [select Id, Body, ParentId, ContentType, Description, BodyLength, Name,OwnerId , CreatedDate from Attachment where ParentId in :emailMessages.keySet()];
		List<Archived_Attachment__c> att2Insert = new List<Archived_Attachment__c>();
		List<Attachment> attDelete = new List<Attachment>();
		List<EmailMessage> em2update = new List<EmailMessage>();

		//use temp Map to prevent from duplicate messages
		Map<EmailMessage , List<Attachment>> attPerMessage = new Map<EmailMessage , List<Attachment>> ();
		Map<Archived_Message__c , List<Archived_Attachment__c>> archivedAttPerArchivedMessage = new Map<Archived_Message__c , List<Archived_Attachment__c>> ();
		for(Attachment a:messageAttachments) {
			EmailMessage tmpEM = emailMessages.get(a.parentId);
			if(attPerMessage.get(tmpEM)==null)
				attPerMessage.put(tmpEM,new List<Attachment>());
			attPerMessage.get(tmpEM).add(a);
		}

		/*
		foreach message, will
		 -   create new Archived message Object
		 -   foreach attachment will
				*  move attached file to amazon,
				*  create new archived attachment linked both to amazom file  && archived  message object
		 - delete by the end nit necessaz records
		*/
		boolean errOccured =false;
		for(EmailMessage originalMessage:attPerMessage.keySet()){
			errOccured =false;
			List<Archived_Attachment__c> archivedAttachmentList = new List<Archived_Attachment__c>();
			Archived_Message__c archivedMessage = createArchivedMessage(originalMessage);
			List<Archived_Attachment__c> createdArchivedAtt = new List<Archived_Attachment__c>();

			for(Attachment a:attPerMessage.get(originalMessage)){
				//be sure we won't process big file
				if(a.BodyLength>2900000)
					break;

				Archived_Attachment__c att = ArchivedFuturAdapter.performAWSMigration(a,attDelete,att2Insert);
				if(att!=null) {
					createdArchivedAtt.add(att);
					att.Case__c  = originalMessage.ParentId;
				}
				else {
					errOccured = true;
				}
			}
			//can't do insert before the end of all callout :/
			if(!errOccured){
				archivedAttPerArchivedMessage.put(archivedMessage,createdArchivedAtt);
				//originalMessage.Status = 'Archived';
				em2update.add(originalMessage);
				emailMessagesActivities.get(originalMessage.ActivityId).status = 'Archived';
			}
			else {
				system.debug('[Attachment Migration Process debug] error occured when migrate '+originalMessage.Id+ '  cancel all file :');
				List<String> filesToDelete = new List<string>();
				emailMessagesActivities.remove(originalMessage.ActivityId);
				for(Archived_Attachment__c aa:createdArchivedAtt){
					filesToDelete.add(aa.AWS_S3_URL__c.replaceFirst('/'+ArchivedFuturAdapter.bucket, ''));
					system.debug('[Attachment Migration Process debug] cancel file  '+aa.AWS_S3_URL__c);
				}
				deleteFileOnAmazon(filesToDelete);
			}
		}
		//insert && deletion are done by the end to limit api call
		for(Archived_Message__c aMessage:archivedAttPerArchivedMessage.keySet()) {
			List<Archived_Attachment__c> atts = archivedAttPerArchivedMessage.get(aMessage);
			insert aMessage;
			//set link betyeen archived message & archived attachment
			for(Archived_Attachment__c att:atts)
				att.ArchivedMessage__c = aMessage.Id;
		}


		//perfom insert operation

		if(att2Insert.size()>0)
			insert att2Insert;
		system.debug('[Attachment Migration Process debug]insert '+att2Insert.size()+ ' archived attachment in System');
		system.debug('[Attachment Migration Process debug]delete '+attDelete.size()+ '  attachment from System');
		delete attDelete;
		update emailMessagesActivities.values();
	}

	 private static Archived_Message__c createArchivedMessage(EmailMessage em){
			Archived_Message__c archive = new Archived_Message__c();
			archive.Case__c = em.ParentId ;
			archive.EmailMessage__c = em.Id ;
			return archive;
		}
}
