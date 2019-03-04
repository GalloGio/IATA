@isTest
private class ANG_ExposeAccountInfo_Test {

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

        Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Change_Code__c = 'IRR',
                                                                                Account__c = account.Id);
        Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Change_Code__c = 'DFE',
                                                                                Account__c = account.Id);
        Agency_Applied_Change_code__c aacc3 = new Agency_Applied_Change_code__c(Change_Code__c = 'RCR',
                                                                                Account__c = account.Id);
        Agency_Applied_Change_code__c aacc4 = new Agency_Applied_Change_code__c(Change_Code__c = 'IRW',
                                                                                Account__c = account.Id);
        Agency_Applied_Change_code__c aacc5 = new Agency_Applied_Change_code__c(Change_Code__c = 'LSP',
                                                                                Account__c = account.Id);
        Agency_Applied_Change_code__c aacc6 = new Agency_Applied_Change_code__c(Change_Code__c = 'DFW',
                                                                                Account__c = account.Id);
        
        insert new List<Agency_Applied_Change_code__c>{aacc1, aacc2, aacc3, aacc4, aacc5, aacc6};

    }
    
    @isTest static void testAccountDetailsSuccess() {
        
    	Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 

        req.requestURI = '/account-details/12345678/'+ANG_RestServiceHelper.URIRequest_AccountFiles; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        ANG_ExposeAccountInfo.doGet();

        Test.stopTest();

    }

    @isTest static void testAccountFinancialInfoSuccess() {
        
    	Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 

        req.requestURI = '/account-details/12345678/'+ANG_RestServiceHelper.URIRequest_AccountFinancialInfo; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        ANG_ExposeAccountInfo.doGet();

        Test.stopTest();

    }

    @isTest static void testAccountDetails403() {

    	Account a = [SELECT Id, GDI_Status__c FROM Account WHERE IATAcode__c ='12345678'];
    	a.GDI_Status__c = 'Rejected';
    	update a;
        
    	Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 

        req.requestURI = '/account-details/12345678/'+ANG_RestServiceHelper.URIRequest_AccountFiles;  
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        ANG_ExposeAccountInfo.doGet();

        Test.stopTest();

    }

    @isTest static void testAccountDetails404() {
        
    	Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 

        req.requestURI = '/account-details/99999999/'+ANG_RestServiceHelper.URIRequest_AccountFiles; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        ANG_ExposeAccountInfo.doGet();

        Test.stopTest();

    }



    @isTest static void testAccountDetails400() {

    	Test.startTest();
                
        //requestURI.size() < 4
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/account-details';  
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        ANG_ExposeAccountInfo.doGet();


        //invalid requestType
        req = new RestRequest(); 
        req.requestURI = '/account-details/12345678/test'; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
 		ANG_ExposeAccountInfo.doGet();


 		//null iatacode
        req = new RestRequest(); 

        req.requestURI = '/account-details//'+ANG_RestServiceHelper.URIRequest_AccountFiles; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
        ANG_ExposeAccountInfo.doGet();


        //empty caller
        req = new RestRequest(); 

        req.requestURI = '/account-details/12345678/'+ANG_RestServiceHelper.URIRequest_AccountFiles;  
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', '');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
        ANG_ExposeAccountInfo.doGet();

        //invalid caller
        req = new RestRequest(); 

        req.requestURI = '/account-details/12345678/'+ANG_RestServiceHelper.URIRequest_AccountFiles; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'test');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
        ANG_ExposeAccountInfo.doGet();


        //empty accountType
        req = new RestRequest();

        req.requestURI = '/account-details/12345678/'+ANG_RestServiceHelper.URIRequest_AccountFiles;  
        req.addParameter('accountType', '');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
        ANG_ExposeAccountInfo.doGet();


        // invalid accountType
        req = new RestRequest(); 

        req.requestURI = '/account-details/12345678/'+ANG_RestServiceHelper.URIRequest_AccountFiles; 
        req.addParameter('accountType', 'test');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', 'FinancialStatement');
        req.httpMethod = 'GET';

        RestContext.request = req;
        ANG_ExposeAccountInfo.doGet();


        // empty attachmentType
        req = new RestRequest(); 

        req.requestURI = '/account-details/12345678/'+ANG_RestServiceHelper.URIRequest_AccountFiles; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', '');
        req.httpMethod = 'GET';

        RestContext.request = req;
        ANG_ExposeAccountInfo.doGet();


        // invalid attachmentType
        req = new RestRequest(); 

        req.requestURI = '/account-details/12345678/'+ANG_RestServiceHelper.URIRequest_AccountFiles; 
        req.addParameter('accountType', 'Agency');
        req.addParameter('caller', 'GDI');
        req.addParameter('attachmentType', 'test');
        req.httpMethod = 'GET';

        RestContext.request = req;
        ANG_ExposeAccountInfo.doGet();

        Test.stopTest();

    }
    

}