@isTest
public class FinancialSecurityUtil_Test {

	@isTest public static void testHandleFSBeforeUpdate() {

		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User u = new User(Alias = 'standt', Email='testusertempname@foo.bar',
	               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
	               LocaleSidKey='en_US', ProfileId = p.Id,
	               TimeZoneSidKey='America/Los_Angeles', UserName='testusertempname@foo.bar',
				   License_Cost_Center__c='ISF005CH01',
				   AMP_Digest_Topics__c = 'test', AMP_Digest_Daily_or_Weekly__c = 'daily');

		System.runAs(u){
			Test.startTest();

			Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'));
        	insert a;   

			// create a reception case
	        Case c = new Case(Subject = 'rception case', Status = 'Open', AccountId = a.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE') );
	        insert c;
                

			// Create a new Financial Institution
	        Financial_Institution__c fi = new Financial_Institution__c(Name = 'Test FI', Region__c = 'Americas', Country__c = 'Canada', Institution_Type__c = 'Bank');
	        insert fi;

			// Create a new Financial Security
	        Financial_Security__c fs = new Financial_Security__c(Region__c = 'Americas', Security_status__c = 'Active', Account__c = a.Id, CurrencyIsoCode = 'USD', Amount__c = 100,
	                        Expiry_date__c = Date.today().addYears(2), Financial_Institution__c = fi.Id, Security_Type__c = 'Cross Border Guarantee', 
	                        Validity_Start_Date__c = Date.today().addDays(-2), Reception_Case__c = c.Id, Reception_Date__c = Date.today(), Reasonforrequest__c = 'New Application');
	        insert fs;

	        // update the FS record to trigger the creation of the renewal Case
	        fs.Security_Status__c = 'Close to Expiry Date';
	        update fs;      
	        
			Test.stopTest();

			//missing the assert - expected results
		}

	}
	
}