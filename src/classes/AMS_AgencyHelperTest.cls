@isTest
public class AMS_AgencyHelperTest {

    @testSetup static void testData(){

        

    }

    @isTest static void testUpdateAgenciesOperations(){

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        AMS_Settlement_System__c ssCass = new AMS_Settlement_System__c(Name = 'Test', recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'CASS'));
        insert ssCass;
        
        AMS_Settlement_System__c ssBSP = new AMS_Settlement_System__c(Name = 'Test', recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c','BSP'));
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

}