@isTest
private class AMS_UpdateStatesTest {

        @isTest static void test_UpdateStates() {
                List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();
                IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name = 'United States', ISO_Code__c = 'US');
                IATA_ISO_Country__c ctry1 = new IATA_ISO_Country__c (Name = 'Australia', ISO_Code__c = 'AU');
                countries.add(ctry);
                countries.add(ctry1);
                insert countries;

                List<IATA_ISO_State__c> states = new List<IATA_ISO_State__c>();
                IATA_ISO_State__c stt = new IATA_ISO_State__c(Name = 'Alabama', ISO_Code__c = 'US-AL', IATA_ISO_Country__c = ctry.id);
                IATA_ISO_State__c stt1 = new IATA_ISO_State__c(Name = 'ALABAMA-BAD', ISO_Code__c = 'US12', IATA_ISO_Country__c = ctry.id);
                IATA_ISO_State__c stt2 = new IATA_ISO_State__c(Name = 'Australian Capital Territory', ISO_Code__c = 'AU-AC', IATA_ISO_Country__c = ctry1.id);
                IATA_ISO_State__c stt3 = new IATA_ISO_State__c(Name = 'AUSTRALIAN CAPITAL TERR-BAD', ISO_Code__c = 'AU30', IATA_ISO_Country__c = ctry1.id);
                states.add(stt);
                states.add(stt1);
                states.add(stt2);
                states.add(stt3);
                insert states;

                AMS_Agency__c a4 = new AMS_Agency__c(Country__c = ctry1.id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Agency__c', 'PASSENGER'), Name = 'Test Agency4', IATAcode__c = '1234561', Chk_dgt__c = '8', Legal_Name_1__c = 'Test Agency4', Legacy_External_ID__c = '12345618', Legacy_System__c = 'AIMS', OwnerId = UserInfo.getUserId());
                insert a4;

                Test.startTest();
                AMS_Address__c add4 = new AMS_Address__c(Country__c = ctry1.id, State__c = stt3.id, Agency__c = a4.id);
                insert add4;
                Database.executeBatch(new AMS_UpdateStates(), 1);
                Test.stopTest();
                add4 = [select id, State__c from AMS_Address__c];
                system.assertEquals(stt2.id, add4.State__c);
        }

        @isTest static void test_UpdateStates2() {
                IATA_ISO_Country__c ctry1 = new IATA_ISO_Country__c (Name = 'Australia', ISO_Code__c = 'AU');
                insert ctry1;

                List<IATA_ISO_State__c> states = new List<IATA_ISO_State__c>();
                IATA_ISO_State__c stt2 = new IATA_ISO_State__c(Name = 'Com. of Northern Mariana', ISO_Code__c = 'AU-CN', IATA_ISO_Country__c = ctry1.id);
                IATA_ISO_State__c stt3 = new IATA_ISO_State__c(Name = 'COM.OF NORTHERN MARIANA IS-BAD', ISO_Code__c = 'AU33', IATA_ISO_Country__c = ctry1.id);
                states.add(stt2);
                states.add(stt3);
                insert states;

                AMS_Agency__c a4 = new AMS_Agency__c(Country__c = ctry1.id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Agency__c', 'PASSENGER'), Name = 'Test Agency4', IATAcode__c = '1234561', Chk_dgt__c = '8', Legal_Name_1__c = 'Test Agency4', Legacy_External_ID__c = '12345618', Legacy_System__c = 'AIMS', OwnerId = UserInfo.getUserId());
                insert a4;

                Test.startTest();
                AMS_Address__c add4 = new AMS_Address__c(Country__c = ctry1.id, State__c = stt3.id, Agency__c = a4.id);
                insert add4;
                Database.executeBatch(new AMS_UpdateStates(), 1);
                Test.stopTest();
                add4 = [select id, State__c from AMS_Address__c];
                system.assertEquals(stt2.id, add4.State__c);
        }

}