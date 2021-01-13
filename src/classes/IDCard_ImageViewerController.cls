public with sharing class IDCard_ImageViewerController {
	private static final String CREDENTIAL_NAME = 'IdCard';
	private static final String FOLDER = 'a0W';

	public ID_Card__c idcard {get; set;}

	public String authorizationLink {get; set;}


	public IDCard_ImageViewerController(ApexPages.StandardController stdController) {
		if (!Test.isRunningTest())
			stdController.addFields( new list<string>{'Photo__c'});
		this.idcard = (ID_Card__c)stdController.getRecord();

		if (idcard.Photo__c != null && IdCard.Photo__c != '') {
			AmazonCredentials credential = AmazonCredentials.getCredentials(CREDENTIAL_NAME);

			Long timestamp = System.now().getTime()/1000 + 300;
			String filename = '/' + credential.Bucket + '/' + FOLDER + '/' + idcard.Photo__c;

			String canonical = 'GET\n\n\n' + timestamp + '\n' + filename;
			Blob bsig = Crypto.generateMac('HmacSHA1', Blob.valueOf(canonical), Blob.valueOf(credential.Secret));
			String signature = EncodingUtil.base64Encode(bsig);

			//String formattednow = timestamp.formatGmt('yyyy-MM-dd')+'T'+timestamp.formatGmt('HH:mm:ss')+'.'+timestamp.formatGMT('SSS')+'Z';

			authorizationLink = credential.EndpointBaseURL + filename.removeStart('/') + '?AWSAccessKeyId=' + credential.AWSAccessKeyId + '&Expires=' + timestamp + '&Signature=' + EncodingUtil.urlEncode(signature,'UTF-8');
		}
	}
}
