public class AMS_CertificateHelper {

	public static final String CREDENTIAL_NAME = 'GenericAttach';

	public static String createCertificate(AMS_Certificate_Request__c req) {

		Case oscarCommCase = [select Id from Case where OSCAR__c = :req.OSCAR__c AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) limit 1];

		//get content
		PageReference pdf = Page.AMSCertificateForPrint;
		pdf.getParameters().put('AccountIds', req.AccountIds__c);
		Blob pdfArchive = Test.isRunningTest() ? Blob.valueOf('Test Content') : pdf.getContent();
		Long size = pdfArchive.size();

		//get amazon info
		String fileName = 'Certificate.pdf';
		String contentType = 'application/pdf';
		String folder = WrapperAttach.getAmazonFolder(oscarCommCase.Id);

		UploadMultipleFileToAmazonButtonCtrl.UploadFile upF = UploadMultipleFileToAmazonButtonCtrl.createUploadFile(oscarCommCase.Id, fileName, contentType, size, folder,  CREDENTIAL_NAME);

		if(!upf.isSuccess) return 'ERROR: '+upf.errorMessage;

		//upload file to amazon
		if(!AmazonRest.uploadFile(upF, pdfArchive)) return 'ERROR: Couldn\'t send file to amazon. Please review the acess keys or contact the system administrator';


		//safe Amazon_File__c
		if(!UploadMultipleFileToAmazonButtonCtrl.createAmazonFileObject(folder+fileName, size, oscarCommCase.Id, 'AMS_File', 'CERTIFICATE', 'Internal')) return 'ERROR: Couldn\'t save amazon file on Salesforce. Warning: the file was sucessfully sent to amazon.';


		return 'Certificate Generated';
	}


	public class CertificateCreation implements Queueable, Database.AllowsCallouts {

		private List<AMS_Certificate_Request__c> reqs;
		private String year;
		private String userEmail;

		public CertificateCreation(Id reqId, String year, String userEmail){
			this(new Set<Id>{reqId}, year, userEmail);
		}

		public CertificateCreation(Set<Id> reqIds, String year, String userEmail){
			this([SELECT Id, Name FROM AMS_Certificate_Request__c WHERE Id IN :reqIds], year, userEmail);
		}

		public CertificateCreation(List<AMS_Certificate_Request__c> reqs, String year, String userEmail){
			this.reqs = reqs;
			this.userEmail = userEmail;
			this.year = year;
		}

		public void execute(QueueableContext context) {
			List<Attachment> atts = new List<Attachment>();
			for(AMS_Certificate_Request__c req : reqs){
				PageReference pdf = Page.AMSCertificateForPrint;
				pdf.getParameters().put('Id', req.Id);
				if(year != null) pdf.getParameters().put('year', year);

				Blob pdfArchive = Test.isRunningTest() ? Blob.valueOf('Test content') : pdf.getContent();

				Attachment att = new Attachment();
				att.Name = 'Certificates '+req.Name+'.pdf';
				att.Body = pdfArchive;
				att.ParentId = req.Id;
				atts.add(att);
			}
			if(!atts.isEmpty()) insert atts;

			if(userEmail == null) return;

			// grab the email template
			EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where name = 'Certificate Creation Report'];

			// process the merge fields
			String links = '';
			for(AMS_Certificate_Request__c req : reqs) links += '\n' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + req.Id;

			String htmlBody = emailTemplate.HtmlValue;
			htmlBody = htmlBody.replace('##LINKS##', links.replaceAll('\\n', '<br/>'));

			String plainBody = emailTemplate.Body;
			plainBody = plainBody.replace('##LINKS##', links);

				//build the email message
			Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();

			email.setToAddresses(new String[]{userEmail});
			email.setReplyTo('testuserdonotreply@iatas.test');
			email.setSenderDisplayName('IATA PDF Generation Process');

			email.setSubject(emailTemplate.Subject);
			email.setHtmlBody(htmlBody);
			email.setPlainTextBody(plainBody);

			Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
		}
	}
}
