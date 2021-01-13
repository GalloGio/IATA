@isTest
private class IDCard_CropperCtrlTest {

	@isTest static void test_method_one() {

		Amazon_Cred__c amc = new Amazon_Cred__c(Name = 'IdCard', Dev_Configuration__c = 'IdCardDev', Prod_Configuration__c = 'IdCardProd');
		insert amc;

		AWSKey__c awsk_dev = new AWSKey__c(Name = 'IdCardDev', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
		AWSKey__c awsk_prd = new AWSKey__c(Name = 'IdCardProd', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
		insert awsk_dev;
		insert awsk_prd;

		// cropper for a new file
		IDCard_CropperCtrl ctrl_new_file = new IDCard_CropperCtrl();
		ctrl_new_file.controllerSessionId = 'sessid';
		ctrl_new_file.controllerFileId = 'filename';

		system.assertEquals('sessid/filename.jpg',ctrl_new_file.controllerFileName);

		system.assertNotEquals(null, ctrl_new_file.getUploadAuthorizationPath());
		system.assertNotEquals(null, ctrl_new_file.getUploadAuthorizationSignature());
		system.assertNotEquals(null, ctrl_new_file.getUploadAuthorizationXAmzDate());


		// cropper with existing file name given
		IDCard_CropperCtrl ctrl_existing_file = new IDCard_CropperCtrl();
		ctrl_existing_file.controllerSessionId = 'sessid';
		ctrl_existing_file.controllerFileId = 'filename.jpg';

		system.assertEquals('filename.jpg',ctrl_existing_file.controllerFileName);
		system.assertNotEquals(null, ctrl_existing_file.awsImageViewLink);

	}

}
