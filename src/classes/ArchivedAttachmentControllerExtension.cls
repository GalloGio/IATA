global with sharing class ArchivedAttachmentControllerExtension {

	public AWSKey__c  awsCredential {get; set;}


	// The extension constructor initializes the private member
	// variable acct by using the getRecord method from the standard
	// controller.
	public ArchivedAttachmentControllerExtension(ApexPages.StandardController stdController) {
	   Archived_Attachment__c att= (Archived_Attachment__c)stdController.getRecord();
	   if(att==null){
			String temp = ApexPages.currentPage().getParameters().get('fieldValue');
			att = [SELECT AWS_S3_URL__c, Name, ArchivedMessage__c, Bucket__c, Case__c, Id, BodyLength__c, Original_Creation_Date__c, OriginalCreatedBy__c, ContentType__c FROM Archived_Attachment__c where id = :temp];
	   }else
			att = [SELECT AWS_S3_URL__c, Name, ArchivedMessage__c, Bucket__c, Case__c, Id, BodyLength__c, Original_Creation_Date__c, OriginalCreatedBy__c, ContentType__c FROM Archived_Attachment__c where id = :att.Id];
	   if(att!=null)
		   this.awsCredential = [SELECT Name, Key__c, Secret__c, Id, AWS_ENDPOINT_URL__c, Bucket__c FROM AWSKey__c where Bucket__c = :att.Bucket__c limit 1];
		else
			this.awsCredential = [SELECT Name, Key__c, Secret__c, Id, AWS_ENDPOINT_URL__c, Bucket__c FROM AWSKey__c limit 1];}


}
