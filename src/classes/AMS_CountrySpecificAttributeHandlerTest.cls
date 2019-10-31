@isTest
private class AMS_CountrySpecificAttributeHandlerTest {

    @testSetup static void setup() {
        /*** Set IATA ISO Country ***/
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Country';
		country.ISO_Code__c = 'CC';
		country.ISO_Code_Numeric__c = 11;
		country.Region__c = 'Europe';
		insert country;

        /*** Set IRR Attribute ***/
        AMS_Country_Specific_Attribute__c attr = new AMS_Country_Specific_Attribute__c();
        attr.IATA_ISO_Country__c = country.Id;
        attr.Threshold__c = 2;
        attr.Location_Class__c = 'P';
        attr.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Irregularity_Threshold');
        insert attr;
    }

    @isTest static void test_01() { 
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
        Test.startTest();
        AMS_Country_Specific_Attribute__c attr = new AMS_Country_Specific_Attribute__c();
        attr.IATA_ISO_Country__c = country.Id;
        attr.Threshold__c = 1;
        attr.Location_Class__c = 'P';
        attr.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Irregularities_for_FS_Request');
        insert attr;
        Test.stopTest();
    }

    @isTest static void test_02() { 
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
        Test.startTest();
        AMS_Country_Specific_Attribute__c attr = new AMS_Country_Specific_Attribute__c();
        attr.IATA_ISO_Country__c = country.Id;
        attr.Threshold__c = 2;
        attr.Location_Class__c = 'P';
        attr.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Irregularities_for_FS_Request');
        String error;
        
        try {
            insert attr;
        } catch(DmlException e) {
            error = e.getDmlMessage(0);
        }
        
        System.assertEquals(Label.AMS_CountrySAttr_Validation,error);
        Test.stopTest();
    }
}
