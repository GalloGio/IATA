/**
* This class is in charge of moving aatchment from SFDC to Amazon && to create records to preserve system architecture
*/
public with sharing class ArchivedFuturAdapter {
	private static AWSTools aws = null;
	private static String bucket  = '';

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
}
