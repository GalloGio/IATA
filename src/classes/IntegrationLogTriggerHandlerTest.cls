/*
* Company    : HARDIS Bordeaux
* Created on : 21-10-2019
* Author     : BTH
*/
@IsTest
private class IntegrationLogTriggerHandlerTest {
    static User admin;
    static Integration_Log__c integrationLog;
    static Integer fakeIdCount = 0;
    static final String ID_PATTERN = '000000000000';

    /**
     * Generate a fake Salesforce Id for the given SObjectType
     */
    static Id generate(Schema.SObjectType sobjectType) {
        String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
        fakeIdCount++;

        String fakeIdPrefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());

        return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
    }

    static {
        admin = TestUtilities.createAdminUser();
        System.runAs(admin) {
            integrationLog = new Integration_Log__c(
                Object_Type__c = Address_Role_Business_Context__c.SObjectType.getDescribe().getName(),
                Record_Id__c = generate(Address_Role_Business_Context__c.SObjectType),
                Status__c = 'In progress'
            );
            insert integrationLog;
        }
    }

    @IsTest
    static void testSpreadEventWhenIntegrationLogStatusIsUpdated(){
        System.runAs(admin){
            Test.startTest();
            update new Integration_Log__c(Id = integrationLog.Id, Status__c = 'Success');
            Test.stopTest();
            System.assertEquals(1, IntegrationLogTriggerHandler.sapEvents.size(), 'There should be one element in the list' );
        }
    }
}