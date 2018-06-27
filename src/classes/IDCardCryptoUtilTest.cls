@isTest
private class IDCardCryptoUtilTest {

	@isTest
	static void testIDCardCryptoUtil() {

		// TO GENERATE A VALID KEY:

		string strTest = 'something to encrypt';
		string encryptedString = IDCardCryptoUtil.getInstance().EncryptString(Label.ID_Card_Encryption_Key, strTest);
		string urlEncoded = EncodingUtil.urlEncode(encryptedString, 'UTF-8');
		string urlDecoded = Encodingutil.urlDecode(urlEncoded, 'UTF-8');
		string decryptedString = IDCardCryptoUtil.getInstance().DecryptString(Label.ID_Card_Encryption_Key, urlDecoded);
		system.assertEquals(strTest, decryptedString);
	}

}