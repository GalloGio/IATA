@isTest
private class CNS_CaseHandlerTest {

	@testSetup
    static void createTestData()
    {

    	IATA_ISO_Country__c iso_country = new IATA_ISO_Country__c (
            name='United States',
            ISO_Code__c ='US',
            ISO_Code_Numeric__c=1,
            currencyIsoCode = 'USD');
        insert iso_country;

        Account a = new Account (
        	Name='test cns portal agency',
        	Sector__c='Travel Agent',
        	Category__c ='Non-IATA Cargo Agent',
        	RecordTypeId= AMS_Utils.getId('Account', 'Standard_Account'),
        	CNS_Account__c=true,
        	IATA_ISO_Country__c = iso_Country.Id
        	);
        insert a;

        Contact c = new Contact (
        	LastName='cns contact test',
        	AccountId = a.Id,
        	RecordTypeId = AMS_Utils.getId('Contact', 'Standard_Contact'),
        	CNS_Contact__c=true
        	);
        insert c;
    }
	
	@isTest static void manageCNSCaseOnBeforeInsertUpdateTest() {

		Account agency = [select Id, CNS_Account__c, Name, Sector__c, Category__c, RecordTypeId from Account where Name='test cns portal agency' limit 1];
		Contact cnsContct = [select Id, LastName, CNS_Contact__c, RecordTypeId, AccountId from Contact where AccountId =: agency.Id];

		Case cnsCase = new Case(
			AccountId=agency.Id,
			ContactId = cnsContct.Id,
			RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Cases - Americas').RecordTypeId,
			Origin ='Portal',
			Subject='cns case test'
			);
		insert cnsCase;
		
	}
	
	
	
}