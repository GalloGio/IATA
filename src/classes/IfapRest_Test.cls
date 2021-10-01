@isTest
public class IfapRest_Test {

static void createAmazonCredential() {
		insert new UtilityCS__c(name='ifapBatchSize', Value__c = '5');
		TestDataFactory_AWSKeys.createAllEntries();
	}

static testMethod void test_I() {
		createAmazonCredential();

		Account account1 = new Account(IATACode__c = '1234567');    // 7 digits
		account1.Name = 'Test account';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.Location_Type__c = 'HO';
		insert account1;


		Contact con = new Contact();
			con.FirstName = 'Dummy';
			con.LastName = 'Contact';
			con.Type_of_Contact__c = 'IFAP Contact';
			con.AccountId = account1.Id;
			con.Email = 'some@email.org';
			con.Financial_Assessment_Contact__c = true;
		insert con;

		Case aCase = new Case();
				aCase.ContactId = con.Id;
				aCase.AccountId = con.accountId;
				aCase.Origin = 'Agent Financial Review Notification';
				aCase.Status = 'Financial Security Requested';
				aCase.Subject = 'subject';
				aCase.Description = 'description';
				aCase.Financial_Review_Type__c =  'Adhoc';
				aCase.New_IFAP_Deadline_date__c = Date.today();


		Insert aCase;

		AmazonFile__C amzFile = new AmazonFile__C(Name = 'file', Full_Name_Unique__c = 'test name', Case__c = aCase.id);
		insert amzFile;

		List<Id> amzId = new List<Id>();
		amzId.add(amzFile.Id);

		List<Case> testCase = [SELECT id, CaseNumber FROM Case where id =:aCase.Id];

		String Case_Number;
		String FileName = 'test.pdf';
		Double FileSize = 1;

		if(!testCase.isEmpty()){
			for(Case c : testCase){
				Case_Number = c.CaseNumber;
			}
		}

		Test.startTest();

			IfapRest.changeStatus(Case_Number, FileName,FileSize);
			IfapRest.deleteRemainingFiles(amzId);

		Test.stopTest();

	}
}
