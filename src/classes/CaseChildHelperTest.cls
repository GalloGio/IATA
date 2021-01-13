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
private class CaseChildHelperTest {

    static testMethod void myUnitTest() {
        ID hqrt =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review'); 
        
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
                                 firstName = 'Name',
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true);
        insert con;
                                
        date dead = date.today().addDays(40);
        
        
        test.startTest();
        boolean exceptionRaised = false;
        
        
        // Insert correctly a case
        Case cas = new Case(recordtypeID = IFAPcaseRecordTypeID,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          Financial_Review_Type__c ='bla',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead,
                          FS_Deadline_Date__c = dead,
                          FS_Submitted_Date__c = date.today(),
                          contactid = con.id,
                          AccountId = a.id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'Satisfactory - No Action'                                                    
        );
        //try{ insert cas; }catch(Exception e){ exceptionRaised = true;}
        //system.assertEquals(false, exceptionRaised);
        insert cas; 


        // This is a second case for the same account and contact and it should not be inserted
        Case cas2 = new Case(recordtypeID = IFAPcaseRecordTypeID,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          Financial_Review_Type__c ='bla',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead,
                          FS_Submitted_Date__c = date.today(),
                          contactid = con.id,
                          AccountId = a.id,
                          FS_Deadline_Date__c = dead,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'Satisfactory - No Action'                                                    
        );
        try{ insert cas; }catch(Exception e){ exceptionRaised = true;}
        system.assertEquals(true,exceptionRaised);
        
        // When I set the status to Assessment Performed and I chose a value for resubmittion of accounts, a child case should be created
        exceptionRaised = false;
        cas.resubmission_of_accounts__c = 'resubmission to tax authorities';
        try{ update cas; }catch(Exception e){ exceptionRaised = true;}
        system.assertEquals(false,exceptionRaised);
        
        List<Case> children = [SELECT Status FROM Case WHERE ParentId = :cas.Id];
        system.assertEquals(1, children.size());
        system.assertNotEquals(children[0].Status, 'Assessment Performed');
    
    
        
        
    }
    
    
    
    
    
    
    
    
        static testMethod void myUnitTest2() {
        ID hqrt =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review'); 
        
        insert new UtilityCS__c(Name='IFAP Bypass Rules', Value__c='Test');
        
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
                                 firstName = 'Name',
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true);
        insert con;
                                
        date dead = date.today().addDays(40);
        
        
        
        boolean exceptionRaised = false;
        
        
        // Insert correctly a case that will generate a child
        Case cas = new Case(recordtypeID = IFAPcaseRecordTypeID,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          Financial_Review_Type__c ='bla',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead,
                          FS_Deadline_Date__c = dead,
                          FS_Submitted_Date__c = date.today(),
                          contactid = con.id,
                          AccountId = a.id,
                          Assessment_Performed_Date__c = date.today(),
                          Financial_Review_Result__c = 'Satisfactory - No Action',
                          resubmission_of_accounts__c = 'resubmission to tax authorities'                                               
        );
        //try{ insert cas; }catch(Exception e){ exceptionRaised = true;}
        insert cas;

        List<Case> children = [SELECT Status, ParentId, RecordType.Name FROM Case WHERE ParentId = :cas.Id];
        test.startTest();
        
        
      //  system.assertEquals(1, children.size());
        system.assertEquals(cas.id, children[0].ParentId);
        system.assertNotEquals(children[0].Status, 'Assessment Performed');
        
        
        
        // When I set the status = "Assessment Performed" o0n the child case the parent should be closed by a trigger
        children[0].Status = 'Assessment Performed';
        exceptionRaised = false;
        //try{ update children; }catch(Exception e){ exceptionRaised = true;}
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
        update children;
        system.assertEquals(false, exceptionRaised);
        cas = [SELECT Status FROM Case WHERE Id = :cas.id LIMIT 1];
        system.assertEquals('Closed',cas.Status);
        system.assertNotEquals(children[0].ParentId, null);
        system.assertEquals(children[0].Status, 'Assessment Performed');
        system.assertEquals(children[0].RecordTypeId, IFAPcaseRecordTypeID);
        
        // It should not be possible to remove the parentid from the child case
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
        children[0].ParentId = null;
        try{ update children[0]; }catch(Exception e){ exceptionRaised = true;}
        system.assertEquals(true, exceptionRaised);
        
    }
    
}