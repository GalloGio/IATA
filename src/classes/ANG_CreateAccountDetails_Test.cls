@isTest
private class ANG_CreateAccountDetails_Test {
	
    @testSetup static void setup() {


        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;         
    
        Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account account = new Account();
        account.Name = 'Main HE Account H1';
        account.Sector__c = 'Travel Agent';
        account.IATACode__c = '12345678';
        account.Category__c = 'IATA Passenger Sales Agent';
        account.Location_Class__c = 'P';
        account.Location_Type__c = 'HE';
        account.ANG_Accreditation_Model__c = 'Cashless';
        account.IATA_ISO_Country__c = ctry.Id;
        account.RecordTypeId = accountAgencyRT;
        account.GDI_Status__c = 'Open';

        insert account;

        Contact con = new Contact(AccountId = account.id, Firstname = 'Lemmy', Lastname='Kilmister', Phone = '33344555666', 
        							MobilePhone = '00555444333', Email = 'lemmy.kilmister@test.com', Financial_Assessment_Contact__c = true);

        insert con;		

    }

     @isTest static void testCreateAccountDetailsSuccess() {
        
    	Test.startTest();

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"offerId":"test123"}');
        RestResponse res = new RestResponse(); 

        req.requestURI = '/account-create-details/12345678/gdi-create-offer'; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        ANG_CreateAccountDetails.doPost();

        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM AMS_OSCAR__c].size(), 'Oscar was not created');
        System.assertEquals(1, [SELECT Id FROM Opportunity].size(), 'Opportunity was not created');

    }

    @isTest static void testCreateAccountDetails400() {
        
    	Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 

        // WRONG URI size
        req.requestURI = 'account-create-details/12345678/gdi-create-offer'; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        ANG_CreateAccountDetails.doPost();



        // WRONG URI - request type
        req = new RestRequest();

        req.requestURI = '/account-create-details/12345678/test400'; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.httpMethod = 'POST';

        RestContext.request = req;

        ANG_CreateAccountDetails.doPost();



        // No Iata code
        req = new RestRequest();

        req.requestURI = '/account-create-details//gdi-create-offer'; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.httpMethod = 'POST';

        RestContext.request = req;

        ANG_CreateAccountDetails.doPost();


        // No Caller
        req = new RestRequest();

        req.requestURI = '/account-create-details/12345678/gdi-create-offer'; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', '');
        req.httpMethod = 'POST';

        RestContext.request = req;

        ANG_CreateAccountDetails.doPost();


        // No accountType
        req = new RestRequest();

        req.requestURI = '/account-create-details/12345678/gdi-create-offer'; 
        req.addParameter('accountType', '');
        req.addParameter('caller', 'GDI');
        req.httpMethod = 'POST';

        RestContext.request = req;

        ANG_CreateAccountDetails.doPost();


        // Invalid accountType
        req = new RestRequest();

        req.requestURI = '/account-create-details/12345678/gdi-create-offer'; 
        req.addParameter('accountType', 'test400');
        req.addParameter('caller', 'GDI');
        req.httpMethod = 'POST';

        RestContext.request = req;

        ANG_CreateAccountDetails.doPost();


        // Invalid caller
        req = new RestRequest();

        req.requestURI = '/account-create-details/12345678/gdi-create-offer'; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'test400');
        req.httpMethod = 'POST';

        RestContext.request = req;

        ANG_CreateAccountDetails.doPost();

        Test.stopTest();

    }

    @isTest static void test_ANG_CreateAccountDetails_Oscar_validations() {

    	Test.startTest();

        RestRequest req = new RestRequest();

        //Empty offer
        req.requestBody = Blob.valueOf('{"offerId":""}');
        RestResponse res = new RestResponse(); 

        req.requestURI = '/account-create-details/12345678/gdi-create-offer'; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        ANG_CreateAccountDetails.doPost();


        //Invalid body
        req = new RestRequest();

        req.requestBody = Blob.valueOf('{"invalid body"}');
        req.requestURI = '/account-create-details/12345678/gdi-create-offer'; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.httpMethod = 'POST';

        RestContext.request = req;

        ANG_CreateAccountDetails.doPost();

        Test.stopTest();

    }

   @isTest static void testCreateAccountDetails404() {
        
    	Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 

        req.requestURI = '/account-create-details/99999999/gdi-create-offer'; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        ANG_CreateAccountDetails.doPost();

        Test.stopTest();

    }

    @isTest static void testCreateAccountDetails403() {

    	Account a = [SELECT Id, GDI_Status__c FROM Account WHERE IATAcode__c ='12345678'];
    	a.GDI_Status__c = 'Rejected';
    	update a;
        
    	Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 

        req.requestURI = '/account-create-details/12345678/gdi-create-offer';
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        ANG_CreateAccountDetails.doPost();

        Test.stopTest();
    }
    	
}