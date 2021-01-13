global class AcliNewScheduler implements Schedulable{

	public static final String ACLI_DOC_NAME = UtilityCS__c.getInstance('AcliFileName').Value__c;
	public static final Folder ACLI_FOLDER = [Select Id from Folder where DeveloperName = 'ACLI_Files'];

	public static AcliJavaTool.Response acliResponse;

	global void execute(SchedulableContext SC) {
		readAcliFile();
	}

	@future (callout=true)
	public static void readAcliFile() {

		for(Integer i = 0; i < 10; i++) {
			if ( !test.isRunningTest()) acliResponse = AcliJavaTool.getFile();

			if (acliResponse.success) {
				Document doc = new Document();
				doc.Name = ACLI_DOC_NAME;
				doc.Body = Blob.ValueOf(acliResponse.content);
				doc.FolderId = ACLI_FOLDER.Id;
				upsert doc;

				return;
			}
		}
		sendEmail('Error reading ACLI file ' + datetime.now(), acliResponse.toString());
	}

	public static void sendEmail(String subject, String message) {
		list<string> lstRecipients = new list<string>();
		lstRecipients.add(userInfo.getUserEmail());
		for (String tempStr : String.valueOf(UtilityCS__c.getInstance('AcliConfirmationEmailRecipients').Value__c).split(',')) {
			lstRecipients.add(tempStr);
		}

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setSubject(subject);
		email.setPlainTextBody( 'Error launching the ACLI synchronization batch: ' + message );
		email.setToAddresses( lstRecipients );

		// Sends the email
		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	}

}
