@isTest
private class AmazonFileTrgHelperTest {
    

    private static void loadCredentials() {
        
        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        insert Amazon_Cred;
        Amazon_Cred__c Amazon_Cred2 =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        insert Amazon_Cred2;

        list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
            new AWSKey__c(
                name = 'adevconf',
                Key__c = 'asd', 
                Secret__c = 'asd',  
                IAS_configuration_name__c = 'asdas', 
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd')
        };
        insert AWS_KEYs;
    }


    static Case initializeCase() {

        String sSapNumberRequiredJSON = AmazonFileTrgHelper.sapNumberRequiredJSON;
        String sExpiryDateRequiredJSON = AmazonFileTrgHelper.expiryDateRequiredJSON;
        String sExpiredRequiredJSON = AmazonFileTrgHelper.expiredRequiredJSON;

        Account account = new Account();
        account.Name = 'TestAccount';
        account.Type = 'Airport';
        account.IATACode__c = '12345678';
        insert account;

        AMS_OSCAR__c oscar1 = new AMS_OSCAR__c();
        AMS_OSCAR_TestDataFactory.createOSCARtestData();

        oscar1 = [Select Id from AMS_OSCAR__c Limit 1];

        oscar1.Process__c = AMS_Utils.CERTIFICATION; 
        oscar1.Status__c = 'Accepted_Future Date';
        Update oscar1;

        Case caseObj = new Case();
        caseObj.ArchivedDate__c = null;
        caseObj.AccountId = account.Id;
        caseObj.OSCAR__c = oscar1.Id;
        insert caseObj;
        return caseObj;
    }


    @isTest static void test_method_one() {
        // Implement test code

        Test.startTest();
        loadCredentials();

        RecordType IFAPcaseRecordType = [Select r.Id, r.Name from RecordType r where r.Name = 'IATA Financial Review' limit 1];

        Case case1 =  initializeCase();
  
        AmazonFile__C AmzFile = new AmazonFile__C(name ='file',Full_Name_Unique__c = 'test name', case__c = case1.id, Category__c = 'Contractual', Subcategory__c = 'Signatory Authority');
        insert AmzFile;
		
		Test.stopTest();
		
        AmazonFile__C AmzFile2 = new AmazonFile__C(name ='file2',Full_Name_Unique__c = 'test name2', case__c = case1.id, Category__c = 'Contractual', Subcategory__c = 'Signatory Authority');
        insert AmzFile2;
        
        delete AmzFile;
        delete AmzFile2;
        

        list<AmazonFile__C> amzFiledelete = [SELECT Id FROM AmazonFile__C WHERE isDeleted =: true and id =: AmzFile.id All ROWS];

        system.assert(amzFiledelete.size() == 1);



        SingleRequestMockAmazonRest fakeAccountResp = new SingleRequestMockAmazonRest(200,
                                                         'Complete',
                                                         '[{"Name": "sForceTest1"}]',
                                                         null);

        SingleRequestMockAmazonRest fakeContactsResp = new SingleRequestMockAmazonRest(200,
                                                  'Complete',
                                                  '[{"LastName": "Test Last Name"}]',
                                                   null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                                   new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('asdasd'+ '/' 
                            + string.valueof(case1.id).substring(0,3)+ 
                            '/' +string.valueof(case1.id)+ '/' + AmzFile.name

                                ,fakeAccountResp);
        endpoint2TestResp.put('asdasd'+ '/' 
                            + string.valueof(case1.id).substring(0,3)+ 
                            '/' +string.valueof(case1.id)+ '/' + AmzFile.name
                            ,fakeContactsResp);

        HttpCalloutMock multiCalloutMock =
                                   new AmazonFileTrgHelperMultiMockUp(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        undelete AmzFile;
   //  System.assertEquals(/*check for expected results here...*/);


        list<AmazonFile__C> amzFileUndelete = [SELECT Id FROM AmazonFile__C WHERE isDeleted =: true and id =: AmzFile.id All ROWS];

        system.assert(amzFileUndelete == null || amzFileUndelete.size() == 0);
        


    }
    

}