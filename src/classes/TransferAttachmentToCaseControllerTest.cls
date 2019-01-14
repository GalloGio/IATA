@isTest
private class TransferAttachmentToCaseControllerTest {
    
    @isTest static void test_controller() {

        WrapperAttachTest.loadTestCredentials();

        EF_AttachmentListController.runningForEF = false;

        Id hqrt         = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Id europeRTId   = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
        Id chinaRTId    = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_China_North_Asia');
        
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c = 'CH', AIMS_Area_Name__c = 'Suisse', AIMS_Area_ID__c = '1' );
        insert isoCountry;
        
        Account a = new Account( name ='IFAP ACCT',
                                 industry = 'pluto',
                                 IATA_ISO_Country__c=isoCountry.Id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234567',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'CH',Location_Type__c = 'AO');
        insert a;
        
        Contact con =new contact(lastname = 'pluto' ,
                                 firstname = 'Name',
                                 phone = '123',
                                 accountid = a.Id,
                                 Financial_Assessment_Contact__c = true,
                                 email = 'asd.arg@wewt.et',
                                 HasOptedOutOfEmail = false
                                 );
        insert con;
                                
        // Create cases
        Date dead = date.today().addDays(40);
        Date twoweeksAgo = date.today().addDays(- 14);
        
        Case c1 = new Case(recordtypeID = chinaRTId,
                          Region__c = 'China & North Asia',
                          BSPCountry__c = 'China',
                          Status = 'Action Needed',
                          FS_Submitted_Date__c = date.today(),
                          FS_Deadline_Date__c = twoweeksAgo,
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          CaseArea__c = 'Accreditation',
                          Reason1__c = 'Annual Fees',
                          Financial_Review_Type__c ='bla',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead,
                          Contactid = con.Id,
                          AccountId = a.Id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'Satisfactory' ,
                          Subject = 'c1');
        insert c1;
        
        // create 2 child cases for c1
        Case c2 = new Case(recordtypeID = europeRTId,
                          ParentId = c1.Id,
                          Region__c = 'Europe (Americas Countries)',
                          BSPCountry__c = 'Turkey',
                          Status = 'Action Needed',
                          FS_Submitted_Date__c = date.today(),
                          FS_Deadline_Date__c = twoweeksAgo,
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          CaseArea__c = 'Accreditation',
                          Reason1__c = 'Annual Fees',
                          Financial_Review_Type__c ='bla',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead,
                          Contactid = con.Id,
                          AccountId = a.Id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'Satisfactory' ,
                          Subject = 'c2');
        
        Case c3 = new Case(recordtypeID = europeRTId,
                            ParentId = c1.Id,
                            Region__c = 'Europe',
                            BSPCountry__c = 'France',
                            Status = 'Action Needed',
                            FS_Submitted_Date__c = date.today(),
                            FS_Deadline_Date__c = twoweeksAgo,
                            Origin = 'asd',
                            IFAP_Area__c = 'asda',
                            CaseArea__c = 'Accreditation',
                            Reason1__c = 'Annual Fees',
                            Financial_Review_Type__c ='bla',
                            IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                            Deadline_Date__c = dead,
                            Contactid = con.Id,
                            AccountId = a.Id,
                            Assessment_Performed_Date__c = date.today(),
                            Financial_Review_Result__c = 'Satisfactory' ,
                            Subject = 'c3');

        //insert cases
        insert new List<Case>{c2, c3};
        
        //create attachments
        AmazonFile aFile = WrapperAttachTest.createAmazonFile(c1);

        Attachment att1 = new Attachment(ParentId = c1.Id, Name='att 1', Body = Blob.valueOf('Unit Test Attachment Body'));
        Attachment att2 = new Attachment(ParentId = c1.Id, Name='test2', Body = Blob.valueOf('Unit Test Attachment Body'));
        insert new List<Attachment>{att1, att2};

        //set callouts
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
                            + string.valueof(c1.Id).substring(0,3)+ 
                            '/' +string.valueof(c1.Id)+ '/' + aFile.amazonFile.Name

                                ,fakeAccountResp);
        endpoint2TestResp.put('asdasd'+ '/' 
                            + string.valueof(c1.Id).substring(0,3)+ 
                            '/' +string.valueof(c1.Id)+ '/' + aFile.amazonFile.Name
                            ,fakeContactsResp);

        HttpCalloutMock multiCalloutMock =
                                   new AmazonFileTrgHelperMultiMockUp(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        //Start testing
        test.startTest();
            
            // check there are 2 available attachments
            system.assertEquals(2, [SELECT Id FROM Attachment].size());

            // instantiate the attachment transfer page controller with error
            ApexPages.StandardController error = new ApexPages.StandardController(new Case(Subject = 'No Id'));
            TransferAttachmentToCaseController errorCon = new TransferAttachmentToCaseController(error);
            
            // instantiate the attachment transfer page controller 
            ApexPages.StandardController std = new ApexPages.StandardController(c1);
            TransferAttachmentToCaseController controller = new TransferAttachmentToCaseController(std);
            
            // check that the 2 related cases were correctly identified
            system.assertEquals(2, controller.lstRelatedCases.size());
            
            // check that the 2 attachments were correctly taken into account
            System.debug(loggingLevel.INFO, '____ [cls TransferAttachmentToCaseControllerTest - test_controller] controller.lstAttachments - ' + controller.lstAttachments);
            system.assertEquals(4, controller.lstAttachments.size());

            // test validations
            // no attachments
            controller.TransferAttachments();

            //no target
            controller.SelectAllCheckbox = true;
            controller.selectAll();
            controller.TransferAttachments();

            //target is the same case
            controller.targetCase.ParentId = c1.Id;
            controller.TransferAttachments();

            //reset target
            controller.targetCase = new Case();
            
            //two targets
            controller.lstRelatedCases[0].isSelected = true;
            controller.lstRelatedCases[1].isSelected = true;
            controller.TransferAttachments();
            
            // check that the attachments have correctly been copied - there should be 4 now
            system.assertEquals(6, [SELECT Id FROM Attachment].size());
            controller.cancel();

        test.stopTest();
    }
    

    
}