@isTest
private class AMS_UtilsTest {

    static testmethod void testEncriptDecript() {
    	
        AMS_Utils util = new AMS_Utils();
        
        try{
            String sPWDenc = AMS_Utils.EncryptParameter('1');
            String sPWDdec = AMS_Utils.DecryptParameter('sPWDenc');
            //System.assertEquals(sPWDdec , 'test_password');
        }catch(Exception e){}
        
        Test.startTest();
        String sPWDenc2 = AMS_Utils.EncryptParameter('test_password');
        String sPWDdec2 = AMS_Utils.DecryptParameter(sPWDenc2);
        System.assertEquals(sPWDdec2 , 'test_password');
        Test.stopTest();
    
    }
    
    static testmethod void testEncriptDecriptEncoded() {
    	try{
            String sPWDenc = AMS_Utils.EncryptParameter('1');
            String sPWDdec = AMS_Utils.DecryptParameter('sPWDenc');
            //System.assertEquals(sPWDdec , 'test_password');
        }catch(Exception e){}
        
        Test.startTest();
        String sPWDenc = AMS_Utils.EncryptEncodeParameter('test_password');
        String sPWDdec = AMS_Utils.DecodeDecryptParameter(sPWDenc);
    	System.assertEquals(sPWDdec , 'test_password');
    	Test.stopTest();
    }
    
    //Test method for createEmployeePersonFromAccountContact
    
    @isTest static void createEmployeePersonFromAccountContact() {
        
        	Test.startTest();
        	IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='SAUDI ARABIA',ISO_Code__c='SA')  ;
	        insert ctry ;

	        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

	        Account acc1 = new Account(Name='Test Account1', IATAcode__c = '12345678', IATA_ISO_Country__c = ctry.id ,OwnerId = UserInfo.getUserId());
	        insert acc1;
	        
	        AMS_Agency__c a = new AMS_Agency__c(Account__c=acc1.Id, Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test Agency', IATAcode__c = '1234567', Chk_dgt__c = '8', Legal_Name_1__c = 'Test Agency', Legacy_External_ID__c = '12345678', Legacy_System__c = 'AIMS',OwnerId = UserInfo.getUserId());
	        insert a;
        	
        	Contact co1 = new Contact(AccountId = acc1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com',
	                                    Financial_Assessment_Contact__c = false);
	        insert co1;
        	
        	co1 = [select id, Person__c, Name from Contact];
        
        	System.assert(co1.Person__c == null);
        
        	a = [SELECT Id from AMS_Agency__c LIMIT 1 ];
        
        	AMS_Utils.createEmployeePersonFromAccountContact(a.Id);
        	
        	// it should have created AMS_Employee__c and AMS_Person__c
        	
        	co1 = [select id, Person__c, Name from Contact];
            
        	System.assert(co1.Person__c <> null);
        
        	AMS_Employee__c e = [SELECT Id, Agency__c, Contact__c from AMS_Employee__c LIMIT 1];
        
        	System.assertEquals(a.Id,e.Agency__c);
        	System.assertEquals(co1.Id,e.Contact__c);
        
        	Test.stopTest();
        	
    }
    
    @isTest static void encryptDecryptExceptionTester(){
        
         try {
    		AMS_Utils.EncryptEncodeParameter(null);
   			System.assert(false, 'Exception expected'); // garantee that it does not pass here.
		} catch (AMS_ApplicationException e) {
   			 System.assert(e.getMessage().contains('Value parameter is null or empty'), 'message=' + e.getMessage());
		}
        
         try {
    		AMS_Utils.DecryptParameter(null);
   			System.assert(false, 'Exception expected'); // garantee that it does not pass here.
		} catch (AMS_ApplicationException e) {
   			 System.assert(e.getMessage().contains('Nothing to decrypt'), 'message=' + e.getMessage());
		}
        
         try {
    		AMS_Utils.DecodeDecryptParameter(null);
   			System.assert(false, 'Exception expected'); // garantee that it does not pass here.
		} catch (AMS_ApplicationException e) {
   			 System.assert(e.getMessage().contains('Nothing to decrypt'), 'message=' + e.getMessage());
		}
        
         try {
    		AMS_Utils.EncryptParameter(null);
   			System.assert(false, 'Exception expected'); // garantee that it does not pass here.
		} catch (AMS_ApplicationException e) {
   			 System.assert(e.getMessage().contains('Value parameter is null or empty'), 'message=' + e.getMessage());
		}
        
    }
}