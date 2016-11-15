@isTest
private class TransferAttachmentToCaseControllerTest {
	
	
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



  @isTest static void test_method_one() {


    loadCredentials();




        EF_AttachmentListController.runningForEF = false;
        ID hqrt = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
       // ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review');
        ID europeRTId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CasesEurope');
        ID chinaRTID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('Cases_China_North_Asia');
        
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c = 'CH', AIMS_Area_Name__c = 'Suisse', AIMS_Area_ID__c = '1' );
        insert isoCountry;
        
        Account a = new Account( name ='IFAP ACCT',
                                 industry = 'pluto',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234567',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'CH',Location_Type__c = 'AO');
        insert a;
        
        Contact con =new contact(lastname = 'pluto' ,
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true,
                                 email = 'asd.arg@wewt.et',
                                 HasOptedOutOfEmail = false
                                 );
        insert con;
                                
        // Create cases
        Date dead = date.today().addDays(40);
        Date twoweeksAgo = date.today().addDays(- 14);
        
        Case c1 = new Case(recordtypeID = chinaRTID,
                          Region__c = 'China & North Asia',
                          BSPCountry__c = 'China',
                          Status = 'Financial Security Requested',
                          FS_Submitted_Date__c = date.today(),
                          FS_Deadline_Date__c = twoweeksAgo,
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          CaseArea__c = 'Accreditation',
                          Reason1__c = 'Annual Fees',
                          Financial_Review_Type__c ='bla',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead,
                          contactid = con.id,
                          AccountId = a.id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'very good' ,
                          Subject = 'c1');
        insert c1;
        
        // create a child case to the first case
     /*   Case c2 = new Case(recordtypeID = IFAPcaseRecordTypeID,
        				  ParentId = c1.Id,
                          Status = 'Financial Security Requested',
                          Financial_Review_Result__c = 'Satisfactory - New Financial Security',
                          Financial_Review_Type__c = 'Annual',
                          BSPCountry__c = 'Viet Nam',
                          Type_of_customer__c = 'asfg',
                          FS_Submitted_Date__c = date.today(),
                          FS_Deadline_Date__c = twoweeksAgo,
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead,
                          contactid = con.id,
                          AccountId = a.id,
                          Region__c = 'Europe',
                          Assessment_Performed_Date__c = date.today(),
                          Subject = 'c2',
                          Phone_Redirected_to_Web__c = false);
        insert c2;**/
        
        // create 2 child cases for c2
        Case c3 = new Case(recordtypeID = europeRTId,
        				  ParentId = c1.Id,
                          Region__c = 'Europe (Americas Countries)',
                          BSPCountry__c = 'Turkey',
                          Status = 'Financial Security Requested',
                          FS_Submitted_Date__c = date.today(),
                          FS_Deadline_Date__c = twoweeksAgo,
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          CaseArea__c = 'Accreditation',
                          Reason1__c = 'Annual Fees',
                          Financial_Review_Type__c ='bla',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead,
                          contactid = con.id,
                          AccountId = a.id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'very good' ,
                          Subject = 'c3');
        //insert c3;
        
        Case c4 = new Case(recordtypeID = europeRTId,
        				  ParentId = c1.Id,
                          Region__c = 'Europe',
                          BSPCountry__c = 'France',
                          Status = 'Financial Security Requested',
                          FS_Submitted_Date__c = date.today(),
                          FS_Deadline_Date__c = twoweeksAgo,
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          CaseArea__c = 'Accreditation',
                          Reason1__c = 'Annual Fees',
                          Financial_Review_Type__c ='bla',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead,
                          contactid = con.id,
                          AccountId = a.id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'very good' ,
                          Subject = 'c4');
        //insert c4;
        
        // create an unrelated case
        Case c5 = new Case(recordtypeID = europeRTId,
                          Region__c = 'Europe',
                          BSPCountry__c = 'France',
                          Status = 'Financial Security Requested',
                          FS_Submitted_Date__c = date.today(),
                          FS_Deadline_Date__c = twoweeksAgo,
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          CaseArea__c = 'Accreditation',
                          Reason1__c = 'Annual Fees',
                          Financial_Review_Type__c ='bla',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead,
                          contactid = con.id,
                          AccountId = a.id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'very good' ,
                          Subject = 'c4');
       






        AmazonFile__C AmzFile = new AmazonFile__C(name ='file',Full_Name_Unique__c = 'test name', case__c = c1.id);
        insert AmzFile;

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
                            + string.valueof(c1.id).substring(0,3)+ 
                            '/' +string.valueof(c1.id)+ '/' + AmzFile.name

                                ,fakeAccountResp);
        endpoint2TestResp.put('asdasd'+ '/' 
                            + string.valueof(c1.id).substring(0,3)+ 
                            '/' +string.valueof(c1.id)+ '/' + AmzFile.name
                            ,fakeContactsResp);

        HttpCalloutMock multiCalloutMock =
                                   new AmazonFileTrgHelperMultiMockUp(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);










        //insert c5;
        list<Case> lstCasesToInsert = new list<Case>{c3, c4, c5};
        insert lstCasesToInsert;
        
        // Create attachments on c2
        Attachment att1 = new Attachment(ParentId = c1.Id, Name='att 1', Body = Blob.valueOf('Unit Test Attachment Body'));
        //insert att1;
        
        Attachment att2 = new Attachment(ParentId = c1.Id, Name='test2', Body = Blob.valueOf('Unit Test Attachment Body'));
        //insert att2;
        list<Attachment> lstAttachmentToInsert = new list<Attachment>{att1, att2};
        insert lstAttachmentToInsert;
        
        test.startTest();
        	
        	// check there are 2 available attachments
        	list<Attachment> lstAllAttachments = [SELECT Id FROM Attachment];
        	system.assertEquals(2, lstAllAttachments.size());
        	
        	// instantiate the attachment transfer page controller 
	        ApexPages.StandardController std = new ApexPages.StandardController(c1);
	        TransferAttachmentToCaseController controller = new TransferAttachmentToCaseController(std);
	        
	        // check that the 3 related cases were correctly identified
	        system.assertEquals(2, controller.lstRelatedCases.size());
	        
	        // check that the 2 attachments were correctly taken into account
	     //   throw new transformationException(''+controller.lstAttachments);
	        system.assertEquals(4, controller.lstAttachments.size());
	        
	        // simultate the selection of the first attachment and of 2 of the related cases
	        controller.lstAttachments[0].isSelected = true;
	        controller.lstRelatedCases[0].isSelected = true;
	        controller.lstRelatedCases[1].isSelected = true;
	        
	        // request the transfer
	        controller.TransferAttachments();
	        
	        // check that the attachments have correctly been copied - there should be 4 now
	        lstAllAttachments = [SELECT Id FROM Attachment];
        	system.assertEquals(4, lstAllAttachments.size());
	        controller.cancel();
        test.stopTest();
	}
	

	
}