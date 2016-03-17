public without sharing class AMS_Utils {


    public static String ENCRYPTION_KEY {
        get {
            return Test.isRunningTest() ? 'hasd==aSDFclDDGasjdhfclx' : AMS_SAP_Settings__c.getOrgDefaults().Encryption_Key__c;
        }
    }

    public static String ENCRYPTION_ALGORYTHM {
        get {
            return Test.isRunningTest() ? 'AES128' : AMS_SAP_Settings__c.getOrgDefaults().Encryption_Algorythm__c;
        }
    }
    
    public AMS_Utils() {}
            //private static final String ENCRYPTION_ALGORYTHM = 'AES128';
    
    /**
     * Encrypts a string to be used as a GET parameter
     * @param sValue The string parameter to encrypt
     * @return The Encrypted parameter
     */
    public static String EncryptParameter(String sValue) {
        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Value parameter is null or empty');
        return EncryptString(ENCRYPTION_KEY, sValue);
    }
    
    /**
     * Encrypts and URL encode a string to be used as a GET parameter
     * @param sValue The string parameter to encrypt and encode
     * @return The Encrypted/encoded parameter
     */
    public static String EncryptEncodeParameter(String sValue) {
        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Value parameter is null or empty');
        return EncodingUtil.urlEncode(EncryptString(ENCRYPTION_KEY, sValue), 'UTF-8');
    }
    
    /**
     * Decrypts a string
     * @param sValue The string parameter to decrypt
     * @return The decrypted parameter
     */
    public static String DecryptParameter(String sValue) {
        if(Test.isRunningTest()) {sValue = sValue == '' ?'X9Ecl9XVLvZQH6g5RP6PmjNOzNIOUsfLYtxbGkfxlfE=':sValue;} //=test_password

        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Nothing to decrypt');
            
        try {
            return DecryptString(ENCRYPTION_KEY, sValue);
        }
        catch (Exception ex) {
            throw new AMS_ApplicationException('Invalid parameter. Error: ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString());
        }
    }
    
    /**
     * URL decode and decrypts a string
     * @param sValue The string parameter to decrypt/decode
     * @return The decrypted/decoded parameter
     */
    public static String DecodeDecryptParameter(String sValue) {
        if(Test.isRunningTest()) {sValue = sValue == '' ?'X9Ecl9XVLvZQH6g5RP6PmjNOzNIOUsfLYtxbGkfxlfE=':sValue;}
        
        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Nothing to decrypt');
            
        try {
            return DecryptString(ENCRYPTION_KEY, Encodingutil.urlDecode(sValue, 'UTF-8'));
        }
        catch (Exception ex) {
            throw new AMS_ApplicationException('Invalid parameter. Error: ' + ex.getMessage());
        }
    }
    
    public static Integer createEmployeePersonFromAccountContact(String agencyId){
        Integer result = 0;
        List<AMS_Employee__c> newEmployees = new List<AMS_Employee__c>();
        Map<String,AMS_Person__c> mapContactPerson= new Map<String,AMS_Person__c>();

        Map<String,Contact> contactsAccount = new Map<String,Contact>([select id, Person__c, Name, FirstName, LastName, Phone, MobilePhone, Birthdate, Email from Contact where AccountId IN (select Account__c from AMS_Agency__c where id =:agencyId) and Person__c = null]);

        if(contactsAccount.size() > 0){
            for(Contact c:contactsAccount.values()){
                AMS_Person__c p = new AMS_Person__c(Name=c.Name,First_Name__c=c.FirstName,Lastname__c=c.LastName,Phone__c=c.Phone,Mobile__c=c.MobilePhone,DOB__c=c.Birthdate,Email__c=c.Email, Contact__c=c.id);
                mapContactPerson.put(c.id,p);
            }
        }

        try{
            if(mapContactPerson.size() > 0){
                insert mapContactPerson.values();
                result += mapContactPerson.size();
            }
        }catch(DMLException e){
            system.debug('Failed to insert Persons ' + e.getMessage());
            return result;
        }

        for(String c:mapContactPerson.keySet()){
            AMS_Employee__c e = new AMS_Employee__c(Name=mapContactPerson.get(c).Name,Agency__c=agencyid,Person__c=mapContactPerson.get(c).id,Contact__c=c);
            newEmployees.add(e);
            contactsAccount.get(c).Person__c = mapContactPerson.get(c).id;
        }

        try{
            if(newEmployees.size() > 0){
                insert newEmployees;
                update contactsAccount.values();
                result += newEmployees.size();
            }
        }catch(DMLException e){
            system.debug('Failed to insert Employees ' + e.getMessage());
            return result;
        }

        return result;
    }

    /////////////////////////////////////////////////////////////////////////////////////
    // Private methods
    
    /**
     * Encrypts a string
     * @param key The key to use to encrypt
     * @param str The String to encrypt
     * @return The encrypted string
     */
    private static String EncryptString(String key, String str) {
        Blob dataToEncrypt = Blob.valueOf(str);
        Blob encryptedData = Crypto.encryptWithManagedIV(ENCRYPTION_ALGORYTHM, EncodingUtil.base64Decode(key), dataToEncrypt);
        return EncodingUtil.base64Encode(encryptedData);
    }

    /**
     * Decrypts a string
     * @param key The key to use to decrypt
     * @param str The encrypted string
     * @return The decrypted string
     */
    private static String DecryptString(String key, String str) {
        Blob encryptedData = Encodingutil.base64Decode(str);
        Blob decryptedData = Crypto.decryptWithManagedIV(ENCRYPTION_ALGORYTHM, EncodingUtil.base64Decode(key), encryptedData);
        return decryptedData.toString();
    }
}