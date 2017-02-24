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

        Account agency = new Account (
        	Name='test cns portal agency',
        	Sector__c='Travel Agent',
        	Category__c ='Non-IATA Cargo Agent',
        	RecordTypeId= AMS_Utils.getId('Account', 'IATA_Agency'),
        	IATA_ISO_Country__c = iso_Country.Id,
        	);
        insert agency;
    }
	
	@isTest static void manageCNSCaseOnBeforeInsertUpdateTest() {

		
	}
	
	
	
}