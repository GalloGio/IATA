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
private class AirlineInputHandlerTest {

    static testMethod void myUnitTest() {
        ID hqrt = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
        ID chinaRTID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_China_North_Asia');
        
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
                                 firstname = 'name' ,
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true,
                                 email = 'asd.arg@wewt.et',
                                 HasOptedOutOfEmail = false
                                 );
        insert con;
        
        Date dead = date.today().addDays(40);
        Date twoweeksAgo = date.today().addDays(- 14);
        
        // Create a query case
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
                          Financial_Review_Result__c = 'Satisfactory' ,
                          Subject = 'c1');
        insert c1;
        
        // create new airline input
        Airline_Input__c ai = new Airline_Input__c(Airline__c = a.Id, Airline_Input__c = 'asdfg', Parent_Case__c = c1.Id);
        
        test.startTest();
            // check there were no case comments before
            list<CaseComment> lstCommentsToInsert = [SELECT Id FROM CaseComment WHERE ParentId = :c1.Id];
            system.assertEquals( 0, lstCommentsToInsert.size() );
            
            // insert the airline input
            insert ai;
            
            // check that a case comment was automatically created
            lstCommentsToInsert = [SELECT Id FROM CaseComment WHERE ParentId = :c1.Id];
            system.assertEquals( 1, lstCommentsToInsert.size() );
        
        test.stopTest();
    }
    
}