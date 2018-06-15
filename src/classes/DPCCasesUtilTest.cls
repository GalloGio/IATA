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
private class DPCCasesUtilTest {

    static testMethod void StatusHandlingTest() {
        // gather necessary record type Ids
        Id RT_ACR_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request');
        ID RT_StdAcc_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c = 'CH', AIMS_Area_Name__c = 'Suisse', AIMS_Area_ID__c = '1' );
        insert isoCountry;
        
        Account a = new Account( name ='Test ACCT',
                                 industry = 'Academic',
                                 IATA_ISO_Country__c = isoCountry.id,
                                 recordtypeID = RT_StdAcc_Id,
                                 IATACode__c ='1234567',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'CH',
                                 Location_Type__c = 'AO');
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
        
        
        Case c1 = new Case(recordtypeID = RT_ACR_Id,
                          Region__c = 'Europe',
                          BSPCountry__c = 'China',
                          Status = '0. New - pending case assignment',
                          Origin = 'asd',
                          contactid = con.id,
                          AccountId = a.id,
                          Subject = 'c1');
        insert c1;
        
        
        Test.startTest();
        
            // Change the case status to 2.0 and check that the Escalated Status DPC has been correctly updated
            c1.Status = '2.0 IE approved - Escalated DPC for PQ';
            c1.Source_of_Case__c = 'email';
            update c1;
            
            c1 = [SELECT Id, Escalated_Status_ACCA__c, Status FROM Case WHERE Id = :c1.Id];
            system.assertEquals('2.0 New',c1.Escalated_Status_ACCA__c);
            
            // update the Escalated Status DPC field and check that the main Status of the case is correctly updated
            c1.Escalated_Status_ACCA__c = '2.1 BC - pending IATA feedback';
            update c1;
            
            c1 = [SELECT Id, Escalated_Status_ACCA__c, Status FROM Case WHERE Id = :c1.Id];
            system.assertEquals('2.1 BC - Pending DPCM feedback',c1.Status);
            
            
            // update the main Status of the case and check that the Escalated Status DPC has been updated
            c1.Status = '2.3 BC - Pending DPC feedback';
            update c1;
            
            c1 = [SELECT Id, Escalated_Status_ACCA__c, Status FROM Case WHERE Id = :c1.Id];
            system.assertEquals('2.3 BC - IATA feedback provided',c1.Escalated_Status_ACCA__c);
            
            // check that the Case Milestone record for the first phase (0. New - pending case assignment) 
            // and the skipped one (1.0 IE - Case Assigned) have been created
            List<Case_Milestone__c> lstCaseMilestones = [SELECT Id, StatusName__c FROM Case_Milestone__c WHERE Case__c = :c1.Id ORDER BY Id ASC];
            system.assertEquals(2, lstCaseMilestones.size());
            system.assertEquals('0. New - pending case assignment', lstCaseMilestones[0].StatusName__c);
            system.assertEquals('1.0 IE - Case Assigned', lstCaseMilestones[1].StatusName__c);
            
        Test.stopTest();
    }
    
    /*
     * This method tests that the required field validations that are dependant on the case values are working correctly
     */
    static testMethod void FieldValidationTest() {
        // gather necessary record type Ids
        Id RT_ACR_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request');
        ID RT_StdAcc_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c = 'CH', AIMS_Area_Name__c = 'Suisse', AIMS_Area_ID__c = '1' );
        insert isoCountry;
        
        Account a = new Account( name ='Test ACCT',
                                 industry = 'Academic',
                                 IATA_ISO_Country__c = isoCountry.id,
                                 recordtypeID = RT_StdAcc_Id,
                                 IATACode__c ='1234567',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'CH',
                                 Location_Type__c = 'AO');
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
        
        
        Case c1 = new Case(recordtypeID = RT_ACR_Id,
                          Region__c = 'Europe',
                          BSPCountry__c = 'China',
                          Status = '0. New - pending case assignment',
                          Origin = 'asd',
                          contactid = con.id,
                          AccountId = a.id,
                          Subject = 'c1');
        insert c1;
        
        
        Test.startTest();
        
            // Try to change the case status to 2.0 - test that the validation rules requiring a source of case work
            c1.Status = '2.0 IE approved - Escalated DPC for PQ';
                    
            boolean exceptionRaised = false;
            try{
                update c1;
            }catch(Exception e){
                exceptionRaised = true;
            }
            system.assertEquals(true,exceptionRaised);
            
            // fill in the the source of case field and update, shouldn't return any error
            c1.Source_of_Case__c = 'email';
            update c1;
            
            
            // Try to update the status to 3.1 without filling the mandatory fields
            c1.Status = '3.1 PQ received - pending DPCM feedback';
            exceptionRaised = false;
            try{
                update c1;
            }catch(Exception e){
                exceptionRaised = true;
            }
            system.assertEquals(true,exceptionRaised);
            
            // fill the required fields, then the update should work
            c1.Evaluation_Effort__c = '123';
            c1.Specification_Effort__c = '123';
            c1.Coding_Effort__c = '123';
            c1.Unit_Test_Effort__c = '123';
            c1.System_Test_Effort__c = '123';
            c1.QA_Effort__c = '123';
            c1.Documentation_Effort__c = '123';
            c1.Implementation_Effort__c = '123';
            c1.Estimated_Total_Person_days__c = 123;
            c1.Estimated_Total_Development_Cost__c = 10000;
            c1.CurrencyIsoCode = 'EUR';
            update c1;
            
            
            // Try to update the status to 3.2 without filling the mandatory fields
            c1.Status = '3.3 PQ approved - Stakeholder comm done';
            exceptionRaised = false;
            try{
                update c1;
            }catch(Exception e){
                exceptionRaised = true;
            }
            system.assertEquals(true,exceptionRaised);
            
            // fill the required fields, then the update should work
            c1.PO_Number__c = '123';
            update c1;
            
            
            // Try to update the status to 4.0 without filling the mandatory fields
            c1.Escalated_Status_ACCA__c = '4.0 UAT date provided - Dev in progress';
            exceptionRaised = false;
            try{
                update c1;
            }catch(Exception e){
                exceptionRaised = true;
            }
            system.assertEquals(true,exceptionRaised);
            
            // fill the required fields, then the update should work
            c1.Estimated_Delivery_Date__c = Date.Today();
            update c1;
            
            
            // Try to update the status to 6.1 without filling the mandatory fields
            c1.Status = '6.1 DD Date Provided - DD in Progress';
            exceptionRaised = false;
            try{
                update c1;
            }catch(Exception e){
                exceptionRaised = true;
            }
            system.assertEquals(true,exceptionRaised);
            
            // fill the required fields, then the update should work
            c1.Planned_Implementation_Date__c = Date.Today();
            c1.Planned_Documentation_Date__c = Date.Today().addDays(-1);
            update c1;
            
            
        Test.stopTest();
    }
    
    /*
     * This method tests that all the required picklist values for the Status and Escalated Status DPC fields on the Case object are present
     */
    static testMethod void TestPicklistValuesIntegrity() {
        list<String> lstRequiredStatusValues = new List<String>{
                        '0. New - pending case assignment',
                        '1.0 IE - Case Assigned',
                        '1.1 IE - pending internal eval/approval',
                        '1.2 IE - pending DPCM eval/ approval',
                        '2.0 IE approved - Escalated DPC for PQ',
                        '2.2 BC - Pending internal feedback',
                        '2.3 BC - Pending DPC feedback',
                        '3.3 PQ approved - Stakeholder comm done',
                        '4.2 Development - pending DPC feedback',
                        '5.1 UAT Approval-Pend Internal Approval',
                        '5.2 UAT approval - pending DPC feedback',
                        '6.0 UAT Approval - DD - s/holder comm',
                        '7.1 Doc review - pending DPC feedback',
                        '8.0 Doc review - completed',
                        '9.0 Closed',
                        '10. Rejected - before PQ',
                        '11. Rejected - after PQ'
                        };
        
        list<String> lstRequiredEscalatedStatusDPCValues = new List<String>{
                        '2.0 DPC Investigating',
                        '2.1 BC - pending IATA feedback',
                        '3.0 BC completed - PQ in progress',
                        '3.1 PQ delivered - waiting IATA approval',
                        '4.0 UAT date provided - Dev in progress',
                        '4.1 Development - Pending IATA feedback',
                        '5.0 UAT results - pending IATA approval',
                        '5.3 UAT approval - DPC feedback provided',
                        '6.1 DD Date Provided - DD in Progress',
                        '7.0 DD completed - Pending IATA review',
                        '7.2 Doc review - DPC Feedback Provided'
                        };
        
        // Get all the picklist values from the Status field on the Case object and put them in a map
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        map<String, String> mapStatusPicklistValuesPerName = new map<String, String>();
        for(Schema.PicklistEntry f : ple) {
            mapStatusPicklistValuesPerName.put(f.getLabel(), f.getLabel());
        }
        
        // Get all the picklist values from the Escalated Status DPC field on the Case object and put them in a map
        fieldResult = Case.Escalated_Status_ACCA__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        map<String, String> mapEscalatedStatusDPCPicklistValuesPerName = new map<String, String>();
        for(Schema.PicklistEntry f : ple) {
            mapEscalatedStatusDPCPicklistValuesPerName.put(f.getLabel(), f.getLabel());
        }
        
        // Flag to indicate whether all the necessary values are present
        Boolean All_Required_Picklist_Values_Present = true;
        
        // Check if all the Status values are present
        for (String picklistValue : lstRequiredStatusValues) {
            if ( mapStatusPicklistValuesPerName.get(picklistValue) == null ) {
                All_Required_Picklist_Values_Present = false;
            }
        } 
        
        // Check if all the Escalated Status DPC values are present
        for (String picklistValue : lstRequiredEscalatedStatusDPCValues) {
            if ( mapEscalatedStatusDPCPicklistValuesPerName.get(picklistValue) == null ) {
                All_Required_Picklist_Values_Present = false;
            }
        }
        
        
        // All values should be present, otherwise the test will fail
        system.assertEquals(true, All_Required_Picklist_Values_Present);
    }
}