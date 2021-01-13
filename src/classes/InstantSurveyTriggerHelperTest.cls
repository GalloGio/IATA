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
private class InstantSurveyTriggerHelperTest {

    static testMethod void TestPreventMultipleSurveysOnSameCase() {
        ID hqrt = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        
        ID SF_ACR_RTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request_Salesforce');
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
                                 firstname = 'Name',
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true,
                                 email = 'asd.arg@wewt.et',
                                 HasOptedOutOfEmail = false
                                 );
        insert con;
                                
        // Create cases and close them
        Date dead = date.today().addDays(40);
        Date twoweeksAgo = date.today().addDays(- 14);
        
        
        // query case, matches filters        
        Case c1 = new Case(recordtypeID = chinaRTID,
                          Region__c = 'China & North Asia',
                          BSPCountry__c = 'China',
                          Status = 'Open',
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
                          Instant_Survey_Feedback_requested__c = true,
                          Subject = 'c1');
        insert c1;
        
        c1.Status = 'Closed';
        update c1;
        
        
        Case c2 = new Case(recordtypeID = SF_ACR_RTId,
                          contactid = con.id,
                          AccountId = a.id,
                          Status = 'In progress',
                          Origin = 'Internal Case',
                          Subject = 'SF ACR');
        insert c2;
        
        c2.Status = 'Closed';
        update c2;
        
        
        // create an instant survey for the cases
        Instant_Surveys__c is1 = new Instant_Surveys__c(Name = 'is - c1', X2015_Overall_Satisfaction__c = '2', Relationship_to_Case__c = c1.Id);
        insert is1;
        
        Instant_Surveys__c is2 = new Instant_Surveys__c(Name = 'is - c2', X2015_Overall_Satisfaction__c = '2', Relationship_to_Case__c = c2.Id);
        insert is2;
        
        
        test.startTest();
        	
        	// check there is a single survey in the DB for this case
        	list<Instant_Surveys__c> lstAllSurveysForC1 = [SELECT Id FROM Instant_Surveys__c WHERE Relationship_to_Case__c = :c1.Id];
        	system.assertEquals(1, lstAllSurveysForC1.size());
        	
        	// try to create a 2nd survey on the case c1, check that it didn't get inserted
	        Boolean exceptionRaised = false;
	        try{
	            Instant_Surveys__c is3 = new Instant_Surveys__c(Name = 'is2 - c1', X2015_Overall_Satisfaction__c = '4', Relationship_to_Case__c = c1.Id);
        		insert is3;
	        }catch(Exception e){
	            exceptionRaised = true;
	        }
	        system.assertEquals(true,exceptionRaised);
	        
	        // check there is still a single survey in the DB for the case
        	lstAllSurveysForC1 = [SELECT Id FROM Instant_Surveys__c WHERE Relationship_to_Case__c = :c1.Id];
        	system.assertEquals(1, lstAllSurveysForC1.size());
        	
        	
        	
        	// try to create a 2nd survey on the case c2, check that it's inserted (the SF ACR exception)
	        exceptionRaised = false;
	        try{
	            Instant_Surveys__c is4 = new Instant_Surveys__c(Name = 'is2 - c2', X2015_Overall_Satisfaction__c = '4', Relationship_to_Case__c = c2.Id);
        		insert is4;
	        }catch(Exception e){
	            exceptionRaised = true;
	        }
	        system.assertEquals(false,exceptionRaised);
	        
	        // check the survey was inserted in the DB for the case
        	list<Instant_Surveys__c> lstAllSurveysForC2 = [SELECT Id FROM Instant_Surveys__c WHERE Relationship_to_Case__c = :c2.Id];
        	system.assertEquals(2, lstAllSurveysForC2.size());
        	
        	
        	
	        
        test.stopTest();
    }
}