@IsTest
private class AccountContactRolePETest {
    private static String recordTypeName; 
    private static String recordTypeId;

    @TestSetup
    static void makeData(){
        Schema.DescribeSObjectResult describeSObjectResult = Account_Contact_Role__c.SObjectType.getDescribe();
        Schema.RecordTypeInfo recordType = describeSObjectResult.getRecordTypeInfos().get(0);
        recordTypeName = recordType.getDeveloperName();
        recordTypeId = recordType.getRecordTypeId();

        Account account = new Account(Name = 'Test Account');
        insert account;
        Account_Role__c accountRole = new Account_Role__c(Account__c = account.Id);
        insert accountRole;
        Contact contact = new Contact(LastName = 'LastName', Email = 'Test.Contact@test.com.invalid');
        insert contact;
        Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c(Account_Role__c = accountRole.Id, Contact__c = contact.Id, RecordTypeId = recordTypeId);
        insert accountContactRole;
    }

    @IsTest static void testCreateAccountContactRolePE(){
        Account_Contact_Role__c accountContactRole = [SELECT Id FROM Account_Contact_Role__c LIMIT 1];
        AccountContactRole__e accountContactRolePE = new AccountContactRole__e(EventType__c = 'Create', RecordId__c = accountContactRole.Id, RecordType__c = 'ITP');

        Test.startTest();
        Database.SaveResult saveResult = EventBus.publish(accountContactRolePE);
        Test.stopTest();

        System.assert(true, saveResult.isSuccess());

        List<Integration_Log__c> integrationLogsList = [SELECT ID FROM Integration_Log__c WHERE 
                                                        object_type__c = 'Account_Contact_Role__c'
                                                        AND Status__c = 'In Progress'
                                                        AND RecordId__c = :accountContactRole.Id];

        System.assertEquals(1, integrationLogsList.size());
    }  
}