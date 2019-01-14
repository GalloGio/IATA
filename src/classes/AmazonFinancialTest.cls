@isTest
private class AmazonFinancialTest {

    private static void createAmazonCredential() {
        insert new UtilityCS__c(name='ifapBatchSize', Value__c = '5');

        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(
            name = IfapToolManager.IFAPCONFIGARATIONNAME,
            Prod_Configuration__c = IfapToolManager.IFAPCONFIGARATIONNAME,
            Dev_Configuration__c = IfapToolManager.IFAPCONFIGARATIONNAME
        );
        insert Amazon_Cred;

        AWSKey__c credential = new AWSKey__c(
            name = IfapToolManager.IFAPCONFIGARATIONNAME,
            Key__c = 'asd',
            Secret__c = 'asd',
            IAS_configuration_name__c = 'asdas',
            IAS_Access_Point__c = 'asd',
            Bucket__c = 'asd',
            AWS_ENDPOINT_URL__c = 'asd'
        );
        insert credential;
    }

    @isTest
    private static void testArchivedCase(){
        createAmazonCredential();

        Case caseObj = new Case();
        caseObj.ArchivedDate__c = Date.today();
        insert caseObj;

        ENZ__FTPAttachment__c attach = new ENZ__FTPAttachment__c();
        attach.Name = 'testAttachment';
        attach.Case__c = caseObj.Id;
        insert attach;

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);
        AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);
        
        Test.stopTest();

    }

    @isTest
    private static void testNotArchivedCase_ErrorAgentCode(){
        createAmazonCredential();

        Case caseObj = new Case();
        caseObj.ArchivedDate__c = null;
        insert caseObj;

        ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);

        Test.startTest();
            AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);
        
        Test.stopTest();
    }
    
    private static Case initializeCase() {
        Account account = new Account();
        account.Name = 'TestAccount';
        account.Type = 'Airport';
        account.IATACode__c = '12345678';
        insert account;

        Case caseObj = new Case();
        caseObj.ArchivedDate__c = null;
        caseObj.AccountId = account.Id;
        insert caseObj;
        return caseObj;
    }

    private static void testNotArchivedCase(){
        createAmazonCredential();
        Case caseObj = initializeCase();

        ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);

        Test.startTest();
        AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);
        controller.RefreshAll();

        AmazonFinancialCtrl.IfapMessage message = new AmazonFinancialCtrl.IfapMessage();
        message.ISOCountryCodes = '';
        message.AgentType = '';
        message.Country = '';
        message.Documents = '';

        Test.stopTest();
    }

    @isTest
    private static void testProcessResponse_Exception(){
        createAmazonCredential();
        Case caseObj = initializeCase();

        ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);
        AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);
        controller.response = null;

        Test.startTest();
        Object response = controller.processResponse();
        Test.stopTest();

        System.AssertEquals(response, null);
    }

    @isTest
    private static void testProcessResponse_Error(){
        createAmazonCredential();
        Case caseObj = initializeCase();

        ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);
        AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);
        controller.response = new IfapToolManager.Response(
                                    '{"success": false ,"code":"AllFood","message":"error message","response":""}'
                                    );

        Test.startTest();
        Object response = controller.processResponse();
        Test.stopTest();

        System.AssertEquals(response, null);
    }

    @isTest
    private static void testProcessResponse_Success(){
        createAmazonCredential();
        Case caseObj = initializeCase();

        ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);
        AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);
        controller.response = new IfapToolManager.Response(
                                    '{"success": true ,"code":"AllFood","message":"from in a bottle!","response":"my risp"}'
                                    );

        Test.startTest();
        Object response = controller.processResponse();
        Test.stopTest();

        System.AssertEquals(response, null);
    }

    @isTest
    private static void testRemoteFunctions(){
        createAmazonCredential();
        Case caseObj = initializeCase();

        Test.startTest();
        Boolean response = AmazonFinancialCtrl.checkIfFileWasUploaded('key');
        System.AssertEquals(response, false);

        String strResponse = AmazonFinancialCtrl.getExpiringLinkIfap('filename');

        AmazonFinancialCtrl.UploadFile upFile1 = AmazonFinancialCtrl.createUploadFile(caseObj.Id, 'filename', 'applciation/pdf', 10);
        System.AssertEquals(upFile1.isSuccess, false);
        System.AssertEquals(upFile1.errorMessage, System.label.IfapNotPdf);

        AmazonFinancialCtrl.UploadFile upFile2 = AmazonFinancialCtrl.createUploadFile(caseObj.Id, 'filename$.pdf', 'applciation/pdf', 10);
        System.AssertEquals(upFile2.isSuccess, false);

        AmazonFinancialCtrl.UploadFile upFile3 = AmazonFinancialCtrl.createUploadFile(caseObj.Id, 'filename.pdf', 'applciation/pdf', AmazonFinancialCtrl.FILE_SIZE_LIMIT_BYTES);
        System.AssertEquals(upFile3.isSuccess, false);

        AmazonFinancialCtrl.UploadFile upFile4 = AmazonFinancialCtrl.createUploadFile(caseObj.Id, 'filename.pdf', 'applciation/pdf', AmazonFinancialCtrl.FILE_SIZE_LIMIT_BYTES-1);
        System.AssertEquals(upFile4.isSuccess, false);

        AmazonFinancialCtrl.deleteFile(caseObj.Id, 'filename');

        list<string> names = new list<string>();
        names.add('name1.pdf');
        names.add('name2.xml');
        AmazonFinancialCtrl.parseTheIntegerForName(names);
        Test.stopTest();

    }


    @isTest
    private static void secondNotArchived(){
        insert new UtilityCS__c(name='ifapBatchSize', Value__c = '5');
        PageReference pageRef = Page.AmazonFinancial;
        Test.setCurrentPage(pageRef);
        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'aprodconf' , Dev_Configuration__c = 'adevconf');
         insert Amazon_Cred;
         
         list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{new AWSKey__c(name = 'aprodconf',
                                                                      Key__c = 'asd', 
                                                                      Secret__c = 'asd',  
                                                                      IAS_configuration_name__c = 'asdas', 
                                                                      IAS_Access_Point__c = 'asd',
                                                                      Bucket__c = 'asd',
                                                                       AWS_ENDPOINT_URL__c = 'asd'),
                                                         new AWSKey__c(name = 'adevconf' ,
                                                                      Key__c = 'asd', 
                                                                      Secret__c = 'asd',  
                                                                      IAS_configuration_name__c = 'asdas', 
                                                                      IAS_Access_Point__c = 'asd',
                                                                      Bucket__c = 'asd',
                                                                      AWS_ENDPOINT_URL__c = 'asd')
                                                                       };  
        
         insert AWS_KEYs;       
         UtilityCS__c sup = new UtilityCS__c(name = 'Emails',value__c='arandomEmail@gmail.com');
         insert sup;

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
        insert isoCountry;

        Account agent = New Account(name = 'The Agent',
                                    recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
                                    IATACode__c = '1234567' ,
                                    IATA_ISO_Country__c=isoCountry.id,
                                    Type = 'Passenger'      );
        insert agent;
        
        Case testCase1 = new Case(  CaseArea__c = 'TTBS',
                                    status = 'Agent Notified (Mail)',
                                    Financial_Review_Type__c = 'Annual',
                                    //Tax_Effective_Date__c = Date.valueOf('2011-08-29'),
                                    Origin = 'Other',
                                    SuppliedEmail = 'paia@iata.org',
                                    SuppliedPhone = '12456987456',
                                    Type = 'TFC update',
                                    Description = 'Testing...',
                                    Priority = '3',
                                    Subject = 'TTBS Test Case',
                                    accountId = agent.id);
         insert testCase1;
        
        
        ENZ__FTPAttachment__c att = new ENZ__FTPAttachment__c(name = 'asd', case__c = testCase1.id);
        insert att;
        
        
        testCase1  = [select id, Status,CaseNumber,ArchivedDate__c,account.type,
                             account.IATA_ISO_Country__r.iso_code__c ,account.Country_ISO_Code__c, 
                             IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c
                              from Case where id =: testCase1.id ];
        
        
        ApexPages.StandardController stand = new ApexPages.StandardController(testCase1);
        AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stand);
        //system.debug('asdasd '+ controller.listFile);
      // throw new transformationException('asdasd '+ controller.listFile);
        system.assertEquals(controller.listFile.size(),1);
        
        controller.refreshAll();
        //system.assertEquals(controller.docs.size(), 1);
        controller.filenameupload = 'uploadthisone';
        controller.filetypeupload = '.pdf';
        
        system.assertEquals(controller.canUploadAndDelete,true);
        //AmazonFinancialCtrl.UploadFile up2 = AmazonFinancialCtrl.createUploadFile(testCase1.id,'uploadthisone','.pdf');
        controller.sendFileInfo();
        AmazonFinancialCtrl.UploadFile upF = new AmazonFinancialCtrl.UploadFile(testCase1.id,'uploadthisone',testCase1.caseNumber,'.pdf');
        //throw new transformationException(''+controller.file.filenameupload);
        
        //system.assertEquals(up2.filenameupload,upF.filenameupload);
        system.assertEquals(controller.file.filenameupload,upF.filenameupload);
        
        string link = AmazonFinancialCtrl.getExpiringLinkIfap('thefile');
        system.assertEquals(link.contains('thefile'),true);
        controller.mergeFilesAndSubmitParams();
        
        controller.response = new IfapToolManager.Response(
                                    '{"success": true ,"code":"AllFood","message":"from in a bottle!","response":"my risp"}'
                                    );
                                    
                                    
        
        
        controller.processresponse();
        
        Case tC = [SELECT ID, Status from Case where id =: testCase1.id ];
        
        system.assertEquals(tC.Status,'Submitted');
        
        
        controller.response = new IfapToolManager.Response(
                                    '{"success":false,"code":"badlyDone","message":"in a bottle!","response":"my risp"}'
                                    );
                                    
                                    
        
        
        controller.processresponse();
        
        system.assertEquals(controller.hasMessage,true);        
        
        system.assertEquals(ApexPages.getmessages()[0].getSummary().contains('in a bottle'),true);
        
        system.assertEquals(controller.canUploadAndDelete,false);
        
        controller.fileNameFromPage = 'asdasd';
        
        //AmazonFinancialCtrl.UploadFile upF5 =  AmazonFinancialCtrl.createUploadFile(testCase1.id,'uploadthison~e','.pdf');        
        //system.assertEquals(upf5.isSuccess, false);                                   
    }   
    

    @isTest
    private static void firstMethodArchivedPath(){
        insert new UtilityCS__c(name='ifapBatchSize', Value__c = '5');
        PageReference pageRef = Page.AmazonFinancial;
        Test.setCurrentPage(pageRef);
        
          Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'aprodconf' , Dev_Configuration__c = 'adevconf');
         insert Amazon_Cred;
         
         list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{new AWSKey__c(name = 'aprodconf',
                                                                      Key__c = 'asd', 
                                                                      Secret__c = 'asd',  
                                                                      IAS_configuration_name__c = 'asdas', 
                                                                      IAS_Access_Point__c = 'asd',
                                                                      Bucket__c = 'asd',
                                                                       AWS_ENDPOINT_URL__c = 'asd'),
                                                         new AWSKey__c(name = 'adevconf' ,
                                                                      Key__c = 'asd', 
                                                                      Secret__c = 'asd',  
                                                                      IAS_configuration_name__c = 'asdas', 
                                                                      IAS_Access_Point__c = 'asd',
                                                                      Bucket__c = 'asd',
                                                                      AWS_ENDPOINT_URL__c = 'asd')
                                                                       };  
        
         insert AWS_KEYs;       
        
        
         UtilityCS__c sup = new UtilityCS__c(name = 'Emails',value__c='arandomEmail@gmail.com');
         insert sup;


        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
        insert isoCountry;

        Account agent = New Account(name = 'The Agent',
                                    recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
                                    IATACode__c = '1234567' ,
                                    IATA_ISO_Country__c=isoCountry.id,
                                    Type = 'Passenger'      );
        insert agent;
        
        Case testCase1 = new Case(  CaseArea__c = 'TTBS',
                                    ArchivedDate__c = date.today(),
                                    //Tax_Effective_Date__c = Date.valueOf('2011-08-29'),
                                    Origin = 'Other',
                                    SuppliedEmail = 'paia@iata.org',
                                    SuppliedPhone = '12456987456',
                                    Type = 'TFC update',
                                    Description = 'Testing...',
                                    Priority = '3',
                                    Subject = 'TTBS Test Case',
                                    accountId = agent.id);
         insert testCase1;
        
        
        ENZ__FTPAttachment__c att = new ENZ__FTPAttachment__c(name = 'asd', case__c = testCase1.id);
        insert att;
        
        
        testCase1  = [select id,ArchivedDate__c from Case where id =: testCase1.id ];
        
        
        ApexPages.StandardController stand = new ApexPages.StandardController(testCase1);
        AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stand);
        
      //  throw new transformationException('asdasd '+ controller.cse);
        system.assertEquals(controller.Archived, true);
        system.assertEquals(controller.docs.size(), 1);
    
    }
    
}