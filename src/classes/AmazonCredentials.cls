public without sharing class AmazonCredentials {

	//
	private static map<string,AmazonCredentials> CredPerName;
	//this connect to the S3 data server
	@AuraEnabled
	public string ConfigurationName {get; set;}
	@AuraEnabled
	public String EndpointBaseURL {get; set;}
	@AuraEnabled
	public String Bucket {get; set;}
	@AuraEnabled
	public String AWSAccessKeyId {get; set;}
	@AuraEnabled
	public String Secret {get; set;}
	// this to connect to the app server where ifap java tool is running
	@AuraEnabled
	public string IAS_configurationName{get; set;}
	@AuraEnabled
	public string IAS_endpoint{get; set;}
	@AuraEnabled
	public string sNamedCredential{get; set;}

	private AmazonCredentials(String EndpointBaseURL,String Bucket,String AWSAccessKeyId,String Secret, string IAS_configurationName, string IAS_endpoint, string sNamedCredential){
		this.EndpointBaseURL = EndpointBaseURL;
		this.Bucket = Bucket;
		this.AWSAccessKeyId = AWSAccessKeyId;
		this.Secret = Secret;
		this.IAS_configurationName = IAS_configurationName;
		this.IAS_endpoint = IAS_endpoint;
		this.sNamedCredential = sNamedCredential;
	}

	//IFAP_AWS_S3_ISSPATTACH for ifap and issp ?
	public static AmazonCredentials getCredentials(string configurationName){

		if( CredPerName == null || CredPerName.keyset() == null || CredPerName.keyset().size() == 0  || CredPerName.get(configurationName) == null ){
			// EF_AttachmentListController.runningForEF = false;
			Amazon_Cred__c Amazon_Cred = Amazon_Cred__c.getInstance(configurationName);
			if(Amazon_Cred == null){

				TransformationHelper.sendEmailSupport('FATAL: AmazonCredentials ' + configurationName ,'AmazonCredentials   ' + configurationName );
				throw new transformationException('Error Credentials: no value found on the settings!');

			}

			string tmpconfigurationName = UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF'  ? Amazon_Cred.Prod_Configuration__c : Amazon_Cred.Dev_Configuration__c ;

			list<AWSKey__c> AWS_KEYs = [
				Select key_encrypted__c, secret_encrypted__c,  IAS_configuration_name__c,
				IAS_Access_Point__c, Bucket__c, AWS_ENDPOINT_URL__c, Named_Credential__c
				From AWSKey__c
				Where Name = :tmpconfigurationName
			];
			string message = '';
			if(AWS_KEYs == null || AWS_KEYs.size() == 0) message += ' No credendials record found';
			else if(AWS_KEYs.size() <> 1) message += ' More than one record found with the same credentials';
			if(message <> '') {
				TransformationHelper.sendEmailSupport('FATAL: AmazonCredentials ' + configurationName ,'AmazonCredentials   ' + configurationName  );
				throw new transformationException('Error Credentials '+ message  );
			}

			AmazonCredentials instance = new AmazonCredentials(AWS_KEYs[0].AWS_ENDPOINT_URL__c,AWS_KEYs[0].Bucket__c,AWS_KEYs[0].key_encrypted__c,AWS_KEYs[0].secret_encrypted__c,AWS_KEYs[0].IAS_configuration_name__c,AWS_KEYs[0].IAS_Access_Point__c, AWS_KEYs[0].Named_Credential__c);
			if(CredPerName == null || CredPerName.keyset() == null) CredPerName = new map<string,AmazonCredentials>();
			CredPerName.put(configurationName,instance);

		}


		return CredPerName.get(configurationName);
	}
}
