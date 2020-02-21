/**
  * Description: This class contains unit tests for the (Encrypt Utility) webpage
  * Author: Samy Saied
  * Version: 1.0
  * History:
  * - added TestEncryptDecryptWithEncodingDecoding
  */
@isTest (SeeAllData=true)
private class vfIECEncryptUtility_tst {
	static testMethod void TestEncryptDecrypt() {
		System.debug('Unit Test: Start: TestEncryptDecrypt');

		//Set current page to Encryption Utility
		PageReference pgRef = Page.IECEncryptUtility;
		Test.setCurrentPage(pgRef);

		//Instantiate Controller
		vfIECEncryptUtility pgCont = new vfIECEncryptUtility();
		pgCont.txtPlainString = 'This is an encryption test';
		pgCont.bUrlEncode = false;
		pgCont.bUrlDecode = false;
		pgCont.EncryptString();

		// Test the encryption process
		system.assertEquals(IECUtil.DecryptParameter(pgCont.txtEncryptedString), pgCont.txtPlainString);

		pgCont.txtEncryptedString = IECUtil.EncryptParameter('This is a decryption test');
		pgCont.DecryptString();

		// Test the decryption process
		system.assertEquals(pgCont.txtPlainString, 'This is a decryption test');
		System.debug('Unit Test: Finish: TestEncryptDecrypt');
	}

	static testMethod void TestEncryptDecryptWithEncodingDecoding() {

		//Set current page to Encryption Utility
		PageReference pgRef = Page.IECEncryptUtility;
		Test.setCurrentPage(pgRef);

		//Instantiate Controller
		vfIECEncryptUtility pgCont = new vfIECEncryptUtility();
		pgCont.txtPlainString = 'This is an encryption test';
		pgCont.bUrlEncode = true;
		pgCont.bUrlDecode = true;
		pgCont.EncryptString();

		// Test the encryption process
		system.assertEquals(IECUtil.DecodeDecryptParameter(pgCont.txtEncryptedString), pgCont.txtPlainString);

		pgCont.txtEncryptedString = IECUtil.EncryptEncodeParameter('This is a decryption test');
		pgCont.DecryptString();

		// Test the decryption process
		system.assertEquals(pgCont.txtPlainString, 'This is a decryption test');
	}
}
