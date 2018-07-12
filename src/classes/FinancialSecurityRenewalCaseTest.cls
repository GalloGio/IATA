@isTest
private class FinancialSecurityRenewalCaseTest {

	@isTest static void test_method_one() {

		// Create a new ISO Country
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
		insert country;

		// Create an Airline HQ account
		Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', RecordTypeId = AirlineHQ_RT_Id);
		insert a;

		// Create a new Financial Institution
		Financial_Institution__c fi = new Financial_Institution__c(Name = 'Test FI', Region__c = 'Americas', Country__c = 'Canada', Institution_Type__c = 'Bank');
		insert fi;

		// create a reception case
		Case c = new Case(Subject = 'rception case', AccountId = a.Id, Status = 'Open',
		                  RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE') );
		insert c;

		// Create a new Financial Security
		Financial_Security__c fs = new Financial_Security__c(Region__c = 'Americas', Security_status__c = 'Active', Account__c = a.Id, CurrencyIsoCode = 'USD', Amount__c = 100,
		        Expiry_date__c = Date.today().addDays(50), Financial_Institution__c = fi.Id, Security_Type__c = 'Cross Border Guarantee',
		        Validity_Start_Date__c = Date.today().addDays(-2), Reception_Case__c = c.Id, Reception_Date__c = Date.today(), Reasonforrequest__c = 'New Application');
		insert fs;

		FSBatch_Alert__c fsb = new FSBatch_Alert__c();
		fsb.Email__c = 'test@email.com';
		fsb.Name = 'abc';
		insert fsb;

		test.startTest();
		//FinancialSecurityRenewalCaseBatch batch = new FinancialSecurityRenewalCaseBatch();
		//Database.executeBatch(batch, 25);

		FinancialSecurityRenewalCase sh1 = new FinancialSecurityRenewalCase();
		String sch = '0 0 23 * * ?'; 
		system.schedule('Test FinancialSecurityRenewalCase', sch, sh1);	

		test.stopTest();
	}

}