Global with sharing class iecWebUpload_Ctrl {

	public String productId{get;set;}
	public String accessKeyId {get;set;}
	public String secretAccessKey {get;set;}
	public String awsRegion{get;set;}
	public String folderHierachy{get;set;}
	public String fileName{get;set;}


	Product2 product;

	public iecWebUpload_Ctrl() {}

	public iecWebUpload_Ctrl(ApexPages.StandardController str){
		folderHierachy = '';

		//Set the AWS access and secret key
		if(!Test.isRunningTest()){
			accessKeyId = IECUtil.DecryptParameter(Utility.getTextSetting('AWS accessKeyId'));
			secretAccessKey = IECUtil.DecryptParameter(Utility.getTextSetting('AWS secretAccessKey'));
		}

		//set the AWS account region
		awsRegion =  Utility.getTextSetting('AWS Region');

		//Get the current product Id
		productId = ApexPages.currentPage().getParameters().get('id');
		product = [SELECT Id, SAP_Material_Number__c, File_Path__c FROM Product2 WHERE Id = : productId][0];

		//set the product bucket hierachy in AWS
		if(productId != null && productId.startsWith('01t')){
			folderHierachy = Utility.getTextSetting('AWS bucket name') + '/' + product.SAP_Material_Number__c;
			fileName = product.File_Path__c;
		}
	}

	@RemoteAction
	Global Static String getS3Values(String ojbId,String resultat, String s3Url){

		//Update the product object with AWS file url
		if(ojbId != null && ojbId.startsWith('01t') && resultat == 'UPLOADED.' && s3Url != null){
			Product2 product = [SELECT Id, SAP_Material_Number__c FROM Product2 WHERE Id = : ojbId][0];
			String encoded = EncodingUtil.urlDecode(s3Url, 'UTF-8');
			List<String> urlSplit = encoded.split('/');
			product.File_Path__c = urlSplit[urlSplit.size() - 1 ];
			update product;
			return product.Id;
		}
		return '';
	}


	//restort the product back to a regular product
	@RemoteAction
	Global Static String backToRegularProduct(String productId){
		Product2 product = [SELECT Id, SAP_Material_Number__c, File_Path__c FROM Product2 WHERE Id = : productId][0];
		if(product != null){
			product.File_Path__c = '';
			update product;
		}

		return productId;
	}

}
