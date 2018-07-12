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


}