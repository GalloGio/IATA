public with sharing class IDCardCryptoUtil {

    @RemoteAction
    private static IDCardCryptoUtil self {get; private set;}
    
    /**
     * Private constructor
     */
    private IDCardCryptoUtil() {
    }
    
    
    public static IDCardCryptoUtil getInstance() {
        if (self == null)
            self = new IDCardCryptoUtil();
        
        return self;
    }
    
    /**
     * Encrypts a string
     */
    public String EncryptString(String key, String str) {
        Blob dataToEncrypt = Blob.valueOf(str);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', EncodingUtil.base64Decode(key), dataToEncrypt);
        return EncodingUtil.base64Encode(encryptedData);
    }
    
    /**
     * Decrypts a string
     */
     public String DecryptString(String key, String str) {
        Blob encryptedData = Encodingutil.base64Decode(str);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES128', EncodingUtil.base64Decode(key), encryptedData);
        return decryptedData.toString();
     }
     
     // TEST METHOD
     public static testmethod void testIDCardCryptoUtil() {
        
        // TO GENERATE A VALID KEY:
        system.debug('ALEX - generated valid key: ' + EncodingUtil.base64Encode(Crypto.generateAesKey(128)));
        
        string strTest = 'something to encrypt';
        string encryptedString = IDCardCryptoUtil.getInstance().EncryptString(Label.ID_Card_Encryption_Key, strTest);
        system.debug('ALEX - encryptedString: ' + encryptedString);
        string urlEncoded = EncodingUtil.urlEncode(encryptedString, 'UTF-8');
        system.debug('ALEX - urlEncode encryptedString: ' + urlEncoded);
        string urlDecoded = Encodingutil.urlDecode(urlEncoded, 'UTF-8');
        string decryptedString = IDCardCryptoUtil.getInstance().DecryptString(Label.ID_Card_Encryption_Key, urlDecoded);
        system.debug('ALEX - decryptedString: ' + decryptedString);
        system.assertEquals(strTest, decryptedString);
     }
}