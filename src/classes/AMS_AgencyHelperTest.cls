@isTest
public class AMS_AgencyHelperTest {

    @testSetup static void testData(){

        

    }

    @isTest static void testUpdateAgenciesOperations(){

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Map<string, Id> settlementsRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Settlement_System__c'}).get('AMS_Settlement_System__c');

        AMS_Settlement_System__c ssCass = new AMS_Settlement_System__c(Name = 'Test', recordTypeId = settlementsRT.get('CASS'));
        insert ssCass;
        
        AMS_Settlement_System__c ssBSP = new AMS_Settlement_System__c(Name = 'Test', recordTypeId = settlementsRT.get('BSP'));
        insert ssBSP;

        AMS_Operation__c opCass = new AMS_Operation__c(Settlement__c = ssCass.id, Country__c = ctry.id, CASS_Operations__c = 'Local');
        insert opCass;

        AMS_Operation__c opBSP = new AMS_Operation__c(Settlement__c = ssBSP.id, Country__c = ctry.id);
        insert opBSP;

        Test.startTest();

        Account accCargo = new Account(Name='Test Account', IATAcode__c = '12345678', IATA_ISO_Country__c = ctry.id, Sector__c = 'Cargo Agent', Location_Type__c ='HO');
        insert accCargo;

        Account accTravel = new Account(Name='Test Account', IATAcode__c = '12345671', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent');
        insert accTravel;

        List<AMS_Agency_Operations__c> agoperations = [SELECT Account__c, Operation__c FROM AMS_Agency_Operations__c];

        System.assert(agoperations.size()==2, true);


        AMS_AgencyHelper.transformGDS('ABAC');
        AMS_AgencyHelper.transformGDS('AGTD');
        AMS_AgencyHelper.transformGDS('AXSS');
        AMS_AgencyHelper.transformGDS('CMAS');
        AMS_AgencyHelper.transformGDS('DERD');
        AMS_AgencyHelper.transformGDS('FLGX');
        AMS_AgencyHelper.transformGDS('GDSL');
        AMS_AgencyHelper.transformGDS('INFI');
        AMS_AgencyHelper.transformGDS('KOTI');
        AMS_AgencyHelper.transformGDS('MINS');
        AMS_AgencyHelper.transformGDS('RESI');
        AMS_AgencyHelper.transformGDS('SABR');
        AMS_AgencyHelper.transformGDS('SITA');
        AMS_AgencyHelper.transformGDS('STRA');
        AMS_AgencyHelper.transformGDS('TOPAS');
        AMS_AgencyHelper.transformGDS('UALA');
        AMS_AgencyHelper.transformGDS('WSPN');
        AMS_AgencyHelper.transformGDS(null);

        AMS_AgencyHelper.transformCompanyType('A');
        AMS_AgencyHelper.transformCompanyType('C');
        AMS_AgencyHelper.transformCompanyType('P');
        AMS_AgencyHelper.transformCompanyType('R');
        AMS_AgencyHelper.transformCompanyType('S');
        AMS_AgencyHelper.transformCompanyType('T');
        AMS_AgencyHelper.transformCompanyType('V');
        AMS_AgencyHelper.transformCompanyType('J');
        AMS_AgencyHelper.transformCompanyType('L');
        AMS_AgencyHelper.transformCompanyType('E');
        AMS_AgencyHelper.transformCompanyType('O');
        AMS_AgencyHelper.transformCompanyType(null);

        AMS_AgencyHelper.fillType('A');
        AMS_AgencyHelper.fillType('C');
        AMS_AgencyHelper.fillType('D');
        AMS_AgencyHelper.fillType('G');
        AMS_AgencyHelper.fillType('K');
        AMS_AgencyHelper.fillType('P');
        AMS_AgencyHelper.fillType('Q');
        AMS_AgencyHelper.fillType('R');
        AMS_AgencyHelper.fillType('T');
        AMS_AgencyHelper.fillType('X');
        AMS_AgencyHelper.fillType('M');
        AMS_AgencyHelper.fillType('I');
        AMS_AgencyHelper.fillType(null);


        AMS_AgencyHelper.fillIndustry('IATA Cargo Agent');
        AMS_AgencyHelper.fillIndustry('Other value');
        AMS_AgencyHelper.fillIndustry(null);


        Test.stopTest();

    }


    /*#AMSFTS
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

    public static testmethod void assignRTAgencies(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;
        
        Account a = new Account(Name='Test Account');
        insert a;

        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        
        
        AMS_Agency__c ag = new AMS_Agency__c(Name = 'Test Agent', Account__c = a.ID, Country__c =ctry.Id, RecordTypeId = agenciesRT.get('PASSENGER'), Location_Class__c = 'P');
        insert ag;

        List<AMS_Agency__c> agencies = [SELECT Id, CASS_Number__c FROM AMS_Agency__c];

        AMS_AgencyHelper.assignRT(agencies);

        ag = agencies.get(0);

        update ag;

        Test.stopTest();

    }*/
    
    /*#AMSFTS
    public static testmethod void updateTypeCatSectorIndustry(){
        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;
        
        Account a = new Account(Name='Test Account');
        insert a;

        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        
        
        AMS_Agency__c ag = new AMS_Agency__c(Name = 'Test Agent', Account__c = a.ID, Country__c =ctry.Id, RecordTypeId = agenciesRT.get('PASSENGER'), Location_Class__c = 'P');
        insert ag;

        List<AMS_Agency__c> agencies = [SELECT Id, CASS_Number__c FROM AMS_Agency__c];

        ag = agencies.get(0);

        ag.Location_Class__c = 'I';

        update ag;

        List<Account> accounts = [SELECT id, Type, Category__c, Industry, Sector__c FROM Account LIMIT 1];

        a = accounts.get(0);

        system.assertEquals(a.Type, 'Import Agent');
        system.assertEquals(a.Category__c, 'Import Agent');
        system.assertEquals(a.Sector__c, 'Cargo Agent');
        system.assertEquals(a.Industry, 'Cargo Agent');

        Test.stopTest();
    }*/
    
    /*#AMSFTS
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
        a.Trading_Name_1__c = 'Test';
        a.C_Code__c = '99';
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
        a  =[select Id,CASS_Number__c, IATACode__c from AMS_agency__c where Id =  :a.Id ];
        system.assert(a.CASS_Number__c  =='003');
        system.assert(a.IATACode__c == '9934567');
        Test.stopTest();
    }*/
}