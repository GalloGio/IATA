@isTest
private class IDCard_CropperCtrlTest {

	@isTest static void test_method_one() {
		TestDataFactory_AWSKeys.createAllEntries();

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
