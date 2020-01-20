/**
*
* This class can be run as a scheduler.
*  It will check if new case have to be processed for an AWS S3 attachment migration
*
*
*
**/
global  class AwsCaseMigrationJob implements Schedulable {
	public static String CRON_EXP = '0 0 1 * * ?';

	public static String MONITOR_NAME = 'AWS Migration Monitor';


	/**
	* look for cases to process in two separated list (and run it in two separated Futur)
	use system.debug('[Attachment Migration Process debug]'); for debug

	*/
	global void execute(SchedulableContext SC) {

		Date dt =  system.today().addDays(-365);
		 Date dt2 =  system.today().addDays(-372);
		List<Attachment> attachments2Process = null;
		if(Test.isRunningTest())
			 attachments2Process = [select  ParentId from Attachment where Parentid in (select Id from Case where  Subject = 'testingS3MigrationCase'  and Status = 'Closed' ) and  Name = '[UNITTEST][FILE][SMALL]'   limit 50];
		 else
			 attachments2Process = [select  ParentId from Attachment where Parentid in (select Id from Case where  createdDate < :dt  and  createdDate >= :dt2  and Status = 'Closed' ) and BodyLength < 2900000 limit 50 ];

		Set<String> casesWithAttachments = new Set<String>();
		for (Attachment a:attachments2Process)
			casesWithAttachments.add(a.ParentId);
		if(casesWithAttachments.size()>0){
			system.debug('[Attachment Migration Process debug] found '+casesWithAttachments.size()+' Attachment  to process ');
			ArchivedFuturAdapter.archivedCasesAttachment(casesWithAttachments);
		}
		//Email message :
		//we get message linked to older case
		Set<String> emailsWithAttachments = new Set<String>();

		List<EmailMessage>  emailmessage2Process =null;
		if(Test.isRunningTest())
			 emailmessage2Process =  [SELECT Id FROM EmailMessage where  HasAttachment = true and Parentid in (select Id from Case where   Subject = 'testingS3MigrationCase' and Status = 'Closed' ) ];
		 else
			 emailmessage2Process =  [SELECT Id FROM EmailMessage where  HasAttachment = true and Parentid in (select Id from Case where  (createdDate < :dt  and  createdDate >= :dt2 ) and Status = 'Closed' )];

		system.debug('[Attachment Migration Process debug] found '+emailmessage2Process.size()+' emailMessages with attachment');
		for (EmailMessage em:emailmessage2Process)
			emailsWithAttachments.add(em.Id);

		// remove from processing list emailsmessage with big attachment : must be done separatly because can't  create sub reauest on attachment
		List<Attachment> allAttachment4emailCases = [select ParentId , BodyLength, Id from Attachment where ParentId in :emailsWithAttachments and (BodyLength > 2900000 or Name = '[UNITTEST][BIGFILE]') ];
		for (Attachment a:attachments2Process){
			emailsWithAttachments.remove(a.ParentId);
			system.debug('[Attachment Migration Process debug] remove Email from processing lsit due to too big attachment  '+a.ParentId);
		}
		if(emailsWithAttachments.size() > 0 ) {
			ArchivedFuturAdapter.archivedEmailMessages(emailsWithAttachments);
			system.debug('[Attachment Migration Process debug] will process  '+emailmessage2Process.size()+' email Messages  ');
		}

		if (attachments2Process.size()==50 ){
			//schedule new job every 5 min
			try {
				system.schedule(AwsCaseMigrationJob.MONITOR_NAME+'TMP', '0 15 * * * ?', new AwsCaseMigrationJob() );
			}
			catch(Exception e) {
				//nothing to do here it was already sstarted
			}
		}else if (attachments2Process.size()<50) {
			try {
				System.abortJob(AwsCaseMigrationJob.MONITOR_NAME+'TMP');
			}
			catch(Exception e) {
				//nothing to do here scheduler perhasps wan's started
			}
		}
	}
}
