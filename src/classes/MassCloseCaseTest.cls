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
private class MassCloseCaseTest {

    static testMethod void myUnitTest() {
         TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete =true;   
        CaseChildHelper.noValidationsOnTrgCAseIFAP = true;
        ID hqrt =Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review'); 
        
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
        insert isoCountry;
        
        Account a = new Account( name ='IFAP ACCT',
                                 industry = 'pluto',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234567',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'ss',Location_Type__c = 'AO');
        insert a;
        
        Contact con =new contact(lastname = 'pluto' ,
                                 firstname = 'Name',
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true);
        insert con;
                                
        date dead = date.today().addDays(40);
        
        list<Case> cases = new list<Case>();
        for(integer i=0;i<3;i++)
            cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
                              Status = 'Assessment Performed',
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='bla',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              Deadline_Date__c = dead,
                              contactid = con.id,
                              AccountId = a.id,
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory - No Action'                                                    
                              ));
        
        insert cases;
        
       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete =false;   

        CaseChildHelper.noValidationsOnTrgCAseIFAP = false;
        test.startTest();
        
        ApexPages.StandardSetController standardcontroller = new ApexPages.StandardSetController(cases);
        standardcontroller.setSelected(cases);
        MassCloseCasesCtrl ctrl = new MassCloseCasesCtrl(standardController);
        ctrl.CloseCases();
        system.assertEquals(2,ctrl.pagenumber);
        
        ctrl.CloseCases();
        ctrl.CloseCases();
        
        
        
        test.stopTest();
        
    }
}