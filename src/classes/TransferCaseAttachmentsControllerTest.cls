/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TransferCaseAttachmentsControllerTest {

    static testMethod void myUnitTest() {
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        // Create test data        
        ID hqrt = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review');
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
                                 firstname = 'Name',
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true,
                                 email = 'asd.arg@wewt.et',
                                 HasOptedOutOfEmail = false
                                 );
        insert con;
        test.startTest();
        // Create cases
        Date dead = date.today().addDays(40);
        Date twoweeksAgo = date.today().addDays(- 14);
        
        Case c1 = new Case(recordtypeID = chinaRTID,
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
                          contactid = con.id,
                          AccountId = a.id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'Satisfactory' ,
                          Subject = 'c1');
        insert c1;
        
        // create a child case to the first case
        Case c2 = new Case(recordtypeID = IFAPcaseRecordTypeID,
                          ParentId = c1.Id,
                          Status = 'Action Needed',
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
        insert c2;
        
        // create 2 child cases for c2
        Case c3 = new Case(recordtypeID = europeRTId,
                          ParentId = c2.Id,
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
                          contactid = con.id,
                          AccountId = a.id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'Satisfactory' ,
                          Subject = 'c3');
        //insert c3;
        
        Case c4 = new Case(recordtypeID = europeRTId,
                          ParentId = c2.Id,
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
                          contactid = con.id,
                          AccountId = a.id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'Satisfactory' ,
                          Subject = 'c4');
        //insert c4;
        
        // create an unrelated case
        Case c5 = new Case(recordtypeID = europeRTId,
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
                          contactid = con.id,
                          AccountId = a.id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'Satisfactory' ,
                          Subject = 'c4');
        //insert c5;
        list<Case> lstCasesToInsert = new list<Case>{c3, c4, c5};
        insert lstCasesToInsert;
        
        // Create attachments on c2
        Attachment att1 = new Attachment(ParentId = c2.Id, Name='att 1', Body = Blob.valueOf('Unit Test Attachment Body'));
        //insert att1;
        
        Attachment att2 = new Attachment(ParentId = c2.Id, Name='test2', Body = Blob.valueOf('Unit Test Attachment Body'));
        //insert att2;
        list<Attachment> lstAttachmentToInsert = new list<Attachment>{att1, att2};
        insert lstAttachmentToInsert;
        
        
            
            // check there are 2 available attachments
            list<Attachment> lstAllAttachments = [SELECT Id FROM Attachment];
            system.assertEquals(2, lstAllAttachments.size());
            
            // instantiate the attachment transfer page controller 
            ApexPages.StandardController std = new ApexPages.StandardController(c2);
            TransferCaseAttachmentsController controller = new TransferCaseAttachmentsController(std);
            
            // check that the 3 related cases were correctly identified
            system.assertEquals(3, controller.lstRelatedCases.size());
            
            // check that the 2 attachments were correctly taken into account
            system.assertEquals(2, controller.lstAttachments.size());
            
            // simultate the selection of the first attachment and of 2 of the related cases
            controller.lstAttachments[0].isSelected = true;
            controller.lstRelatedCases[0].isSelected = true;
            controller.lstRelatedCases[1].isSelected = true;
            
            // request the transfer
            controller.TransferAttachments();
            
            // check that the attachments have correctly been copied - there should be 4 now
            lstAllAttachments = [SELECT Id FROM Attachment];
            system.assertEquals(4, lstAllAttachments.size());
            
        test.stopTest();
    }
}