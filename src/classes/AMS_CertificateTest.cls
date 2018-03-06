@isTest
private class AMS_CertificateTest {

	@testSetup static void createData() {
		id Art =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
		Account acc1 = new Account(Name = 'Test Account', IataCode__c = '1', Certificate_Generated_Current_Year__c = true, recordtypeid = Art);
		Account acc2 = new Account(Name = 'Test Account', IataCode__c = '2', Certificate_Generated_Current_Year__c = false, recordtypeid = Art);
		insert new List<Account>{acc1, acc2};
	}
	
	static testMethod void manager() {
		AMS_CertificateManagerController con = new AMS_CertificateManagerController();

		Test.startTest();

			System.assert(!con.noteList.isEmpty());
			System.assert(!con.years.isEmpty());
			System.assert(!con.showWarning);
			System.assert(!con.ignoreWarning);

			//test null file
			con.parseFile();

			//test invalid file
			con.fileBody = Blob.valueOf('');
			con.parseFile();

			//test no accounts file
			con.fileBody = Blob.valueOf('"3"');
			con.parseFile();

			//test success
			con.fileBody = Blob.valueOf('"Iata Code"\n"1"\n"2"\n"3"');
			con.yearText = System.today().year()+'';
			con.parseFile();

			System.assert(con.parsedFile);
			System.assert(con.showWarning);
			con.ignoreWarning = true;
			con.generateCertificates();

		Test.stopTest();
	}

	static testMethod void print() {
		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id FROM Account]);

		AMS_Certificate_Request__c request = new AMS_Certificate_Request__c();
		request.AccountIds__c = JSON.serializePretty(accounts.keySet());
		insert request;

		System.debug(loggingLevel.Debug, '____ [cls AMS_CertificateTest - print] request.Id - ' + request.Id);
		System.debug(loggingLevel.Debug, '____ [cls AMS_CertificateTest - print] request.AccountIds__c - ' + request.AccountIds__c);

	    PageReference pdf = Page.AMSCertificateForPrint;
		pdf.getParameters().put('Id', request.Id);

		Test.setCurrentPage(pdf);

		Test.startTest();

		AMS_CertificateForPrintController con = new AMS_CertificateForPrintController();
		System.assertEquals(con.certificates[0].size(), accounts.size());

		Test.stopTest();
	}

	static testMethod void uploadFile(){
		AmazonRestTest.createCredentials(AMS_CertificateHelper.CREDENTIAL_NAME);
		AmazonRestTest.createCredentials('RecycleBin');

		Account acc = [SELECT Id FROM Account LIMIT 1];
		AMS_Oscar__c oscar = new AMS_Oscar__c(Account__c = acc.Id);
		insert oscar;

		insert new Case(AccountId = acc.Id, OSCAR__c = oscar.Id);

		AMS_Certificate_Request__c request = new AMS_Certificate_Request__c();
		request.AccountIds__c = JSON.serializePretty(new List<Id>{acc.Id});
		request.OSCAR__c = oscar.Id;
		insert request;

		Test.startTest();

		System.assertEquals('Certificate Generated', AMS_CertificateHelper.createCertificate(request));

		Test.stopTest();
	}
	
}