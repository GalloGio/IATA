public with sharing class IDCardApplicationImageViewerController {
	private static final String CREDENTIAL_NAME = 'IdCard';
	private static final String FOLDER = 'a0W';

	public ID_Card_Application__c idCardApp {get; set;}

	public String authorizationLink {get; set;}

	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	public IDCardApplicationImageViewerController(ApexPages.StandardController stdController) {
		if (!Test.isRunningTest())
			stdController.addFields( new list<string>{'Photo__c'});
		this.idCardApp = (ID_Card_Application__c)stdController.getRecord();

		if (idCardApp.Photo__c != null) {
			AmazonCredentials credential = AmazonCredentials.getCredentials(CREDENTIAL_NAME);

			Long timestamp = System.now().getTime()/1000 + 1000;
			/*String filename = idCardApp.Photo__c.removeStart( credential.EndpointBaseURL );
			filename = filename.startsWith('/') ? filename : '/' + filename;*/
			String filename = '/' + credential.Bucket + '/' + FOLDER + '/' + idCardApp.Photo__c;

			String canonical = 'GET\n\n\n' + timestamp + '\n' + filename;
			Blob bsig = Crypto.generateMac('HmacSHA1', Blob.valueOf(canonical), Blob.valueOf(credential.Secret));
			String signature = EncodingUtil.base64Encode(bsig);

			//String formattednow = timestamp.formatGmt('yyyy-MM-dd')+'T'+timestamp.formatGmt('HH:mm:ss')+'.'+timestamp.formatGMT('SSS')+'Z';

			authorizationLink = credential.EndpointBaseURL + filename.removeStart('/') + '?AWSAccessKeyId=' + credential.AWSAccessKeyId + '&Expires=' + timestamp + '&Signature=' + EncodingUtil.urlEncode(signature,'UTF-8');
		}
	}

}
