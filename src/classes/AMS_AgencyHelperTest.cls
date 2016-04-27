@isTest
public class AMS_AgencyHelperTest {

    public static testmethod void  testAddAccountIfEmpty(){
    
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;
        
        Account acc = new Account(Name='Test Account2', IATAcode__c = '12345678');
        insert acc;
        
        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');
        
        Test.startTest();
        
        // If I insert an agency without any account but with an existing IATA code it should be related to the account
        AMS_Agency__c a = new AMS_Agency__c(Name='Test Agency', IATAcode__c = '1234567', Chk_dgt__c = '8', Country__c =ctry.Id, RecordTypeId = agenciesRT.get('PASSENGER'));
        insert a;

        AMS_AgencyHelper.isAgencyAccredited(a.id);
        
        List<AMS_Agency__c> ags = [SELECT Account__c FROM AMS_Agency__c];
        system.assertEquals(1, ags.size());
        system.assertEquals(acc.Id, ags[0].Account__c);

        // should not create an agency to an already account associated with an agency
        try{
            a = new AMS_Agency__c(Name='Test Agency', IATAcode__c = '1234567', Chk_dgt__c = '8', Country__c =ctry.Id, RecordTypeId = agenciesRT.get('PASSENGER'));
            insert a;
        }catch(Exception e){}
        
        ags = [SELECT Account__c FROM AMS_Agency__c];
        system.assertEquals(1, ags.size());
        system.assertEquals(acc.Id, ags[0].Account__c);
        
        // If I insert an agency with a new iata code an account should be created
        a = new AMS_Agency__c(Name='Test Agency2', IATAcode__c = '7654321', Country__c =ctry.Id, Legal_Name_1__c = 'Test Agency2', RecordTypeId = agenciesRT.get('PASSENGER'));
        insert a;
        
        List<Account> accs = [SELECT Id, IATAcode__c FROM Account WHERE IATAcode__c = '7654321'];
        //system.assertEquals(1, accs.size());
        
        ags = [SELECT Account__c FROM AMS_Agency__c WHERE Name = 'Test Agency2'];
        system.assertEquals(1, ags.size());
        //system.assertEquals(accs[0].ID, ags[0].Account__c);
        
    }
    
    
    public static testmethod void testEnsure0to1ContactLookup(){
    
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;
        
        Account a = new Account(Name='Test Account');
        insert a;

        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        Test.startTest();
        
        AMS_Agency__c ag = new AMS_Agency__c(Name = 'Test Agent', Account__c = a.ID, Country__c =ctry.Id, RecordTypeId = agenciesRT.get('PASSENGER'));
        insert ag;
        
        // insert should be ok
        List<AMS_Agency__c> agencies = [SELECT Id FROM AMS_Agency__c];
        system.assertEquals(1,agencies.size());
        
        try{
            ag = new AMS_Agency__c(Name = 'Test Agent', Account__c = a.ID, Country__c = ctry.id, IATAcode__c = '1368097', Legal_Name_1__c = 'Test Agent', RecordTypeId = agenciesRT.get('PASSENGER'));
            insert ag;
        }catch(Exception e){}
        
        // it's not possible to insert a second agent related to the same contact
        agencies = [SELECT Id FROM AMS_Agency__c];
        system.assertEquals(1,agencies.size());
        
        
        // if I change the lookup to a different contact insert will succeed
        ag.Account__c = null;
        insert ag;
        
        agencies = [SELECT Id FROM AMS_Agency__c];
        system.assertEquals(2,agencies.size());
        
    }

    public static testmethod void testupdateAccounts(){
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;
        
        Account acc = new Account(Name='Test Account2', IATAcode__c = '12345678');
        insert acc;

        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');
        
        // If I insert an agency without any account but with an existing IATA code it should be related to the account
        AMS_Agency__c a = new AMS_Agency__c(Name='Test Agency', IATAcode__c = '12345678', Chk_dgt__c = '8', Country__c =ctry.Id, RecordTypeId = agenciesRT.get('PASSENGER'));
        insert a;

        Test.startTest();
        a.Legal_Name_1__c = 'Test';
        a.IATACode__c = '234';
        a.Trading_Name_1__c = 'Test';
        a.Phone_Number__c = '911111111';
        a.RecordTypeId = agenciesRT.get('PASSENGER');
        a.Recert_Expiry_Date__c = system.today();
        a.Original_Approval_DAte__c = system.today();
        a.Legacy_System__c = 'AIMS';
        a.Site_Type__c = 'HO';
        a.Tax_Reference_Number__c = '123';
        a.Other_Tax_Reference_Number__c = '123';
        a.CASS_Number__c ='3';
        a.Agency_Site__c = 'test@test.com';
        a.Agency_Status__c = 'Accredited';
        a.Financial_Year_End__c = 'September';
        a.Accumulated_Irregularities__c = 1;
        a.BSP_Code__c = '123';
        a.License_Number__c = '123';

        update a;
        a  =[select Id,CASS_Number__c  from AMS_agency__c where Id =  :a.Id ];
        system.assert(a.CASS_Number__c  =='003');
        Test.stopTest();
    }
}