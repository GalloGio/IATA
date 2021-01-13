@isTest
private class testIFAPContactAndAccounts
{

    static testMethod void myUnitTest()
    {
        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        
        IATA_ISO_Country__c Country = new IATA_ISO_Country__c(Name='Canada', ISO_Code__c='CA', AIMS_Area_ID__c='1');
        insert Country;
        
        Account a = new Account(name = 'testaccoppclone', site = 'test',BillingCity='test',BillingCountry='Canada', type='IATA Passenger Sales Agent', Location_Type__c='BR');
        Insert a;
        
        Account a2 = new Account(name = 'testaccoppclone2', site = 'test2',BillingCity='test2',BillingCountry='Canada', type='IATA Passenger Sales Agent', Location_Type__c='BR');
        Insert a2;
        
        Contact c = new Contact(FirstName = 'bob', LastName = 'test', AccountId = a.Id, email = 'bob@test.com', Financial_Assessment_Contact__c = true);
        Insert c;

		Case ca = new Case(AccountID = a.id, RecordTypeId = rtId, ContactId = c.id, CurrencyISOCode = 'EUR', Origin = 'test', Reason = 'test', Subject = 'test case', Description = 'this is a test case', Status = 'New', Financial_Review_Type__c='New applications', IFAP_Financial_Year__c='2013');
		Insert ca;

		System.debug('Current User: ' + UserInfo.getUserName());
		System.debug('Current Profile: ' + UserInfo.getProfileId());
		c.AccountId = a2.Id;
		// No one should  be able to change the Contact's AccountId because there is an open IFAP Case related to that Account
		try
		{
			update c;
		}
		catch(DmlException e)
		{
			system.assertEquals(e.getMessage().contains('Cannot dissociate this contact from the account because it has an open IFAP Case'),true);
		}
        
        
    }
}