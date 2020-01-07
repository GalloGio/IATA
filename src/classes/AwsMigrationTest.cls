/**

 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest  (SeeAllData=false)
private class AwsMigrationTest {

	static void initTest(){
		String name = 'production';
		if(DevsTools.isRunningInSandbox())
			name = 'sandbox';
		AWSKey__c awsc = new AWSKey__c(Bucket__c='bucket',  Secret__c='secret', Key__c='key' ,Name = name );
		insert awsc;
	}

	static private Attachment attachFileToParent(String parentId){
		Attachment attach=new Attachment();
		attach.Name='[UNITTEST][FILE][SMALL]';
		Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
		attach.body=bodyBlob;
		attach.parentId=parentId;
		return attach;
	}

	static private Attachment attachBigFileToParent(String parentId){
		Attachment attach=new Attachment();
		attach.Name='[UNITTEST][FILE][BIG]';
		String a = '[UNITTEST][BIGFILE]';

		Blob bodyBlob=Blob.valueOf(a);
		attach.body=bodyBlob;
		attach.parentId=parentId;
		return attach;
	}

	static testMethod void testCaseAttachmentMigration() {
		Test.startTest();
		initTest();
		Account[] accounts = new Account[]{new Account(Name='test', Type='Prospect', CurrencyIsoCode='USD', BillingCountry='USA')};
		insert accounts;

		// create the contact a first time
		Contact[] contacts = new Contact[]{new Contact(Email='test@email.com', FirstName='test', LastName='test', AccountId=accounts[0].Id)};
		insert contacts;

		// create a case with no information in salesforce
		Case[] cases = new Case[]{new Case(Subject='test1', AccountId=accounts[0].Id, ContactId =contacts[0].Id,  Status = 'Closed' , Description='le test 1', SuppliedName='Anne Honyme', SuppliedCompany='Fictive', SuppliedEmail='fake@fake.com', Origin='Web'),
								  new Case(Subject='testingS3MigrationCase', AccountId=accounts[0].Id, ContactId =contacts[0].Id, Status = 'Closed' , Description='le test 1', SuppliedName='Anne Honyme', SuppliedCompany='Fictive', SuppliedEmail='fake@fake.com', Origin='Web'),
								  new Case(Subject='testingS3MigrationCase', AccountId=accounts[0].Id, ContactId =contacts[0].Id, Status = 'Open' , Description='le test 1', SuppliedName='Anne Honyme', SuppliedCompany='Fictive', SuppliedEmail='fake@fake.com', Origin='Web')
								  };
		insert cases;

		Attachment[] att =new Attachment[]{ attachFileToParent(cases[0].Id),attachFileToParent(cases[1].Id),attachFileToParent(cases[2].Id)};
		insert att;
		List<String>ids = new List<String>();
		for(Attachment a:att)
			ids.add(a.Id);
		system.assert(ids.size()==3);


		system.debug('[TEST AWS] NB element created : '+att.size());
		//call the Job monitor to process threatment : only Attachment 2 should have been migrated
		new AwsCaseMigrationJob().execute(null);

		//have to wait has the AWS is calling task in futur :/
		Test.stopTest();

		List<Attachment> atts = [select Id from Attachment where id in :ids];
		system.debug('[TEST AWS] TEST if two attachment  still in system '+atts.size());
		system.assert(atts.size()==2);
		//try to get Archived attachmnent
		Archived_Attachment__c aa = [select Id , Name, AWS_S3_URL__c from Archived_Attachment__c where Case__c = :cases[1].id];
		system.debug('[TEST AWS] test if there is one archive Attachement linked to case '+aa.AWS_S3_URL__c);
		system.assert(aa!=null);
		system.debug(aa.Name);
	}



	static testMethod void testEmailMessageMigration() {
		Test.startTest();
		initTest();
		Account accounts = new Account(Name='test', Type='Prospect', CurrencyIsoCode='USD', BillingCountry='USA');
		insert accounts;

		// create the contact a first time
		Contact contacts = new Contact(Email='test@email.com', FirstName='test', LastName='test', AccountId=accounts.Id);
		insert contacts;

		// create a case with no information in salesforce
		Case[] cases = new Case[]{new Case(Subject='test1', AccountId=accounts.Id, ContactId =contacts.Id,  Status = 'Closed' , Description='le test 1', SuppliedName='Anne Honyme', SuppliedCompany='Fictive', SuppliedEmail='fake@fake.com', Origin='Web'),
								  new Case(Subject='testingS3MigrationCase', AccountId=accounts.Id, ContactId =contacts.Id, Status = 'Closed' , Description='le test 1', SuppliedName='Anne Honyme', SuppliedCompany='Fictive', SuppliedEmail='fake@fake.com', Origin='Web'),
								  new Case(Subject='testingS3MigrationCase', AccountId=accounts.Id, ContactId =contacts.Id, Status = 'Closed' , Description='le test 1', SuppliedName='Anne Honyme', SuppliedCompany='Fictive', SuppliedEmail='fake@fake.com', Origin='Web'),
								  new Case(Subject='testingS3MigrationCase', AccountId=accounts.Id, ContactId =contacts.Id, Status = 'Open' , Description='le test 1', SuppliedName='Anne Honyme', SuppliedCompany='Fictive', SuppliedEmail='fake@fake.com', Origin='Web')
								  };
		insert cases;
		// create taask as bases for email nessages
		Task[] tasks = new Task[]{
									new Task( Status='Open', Subject='test1'),
									new Task( Status='Open', Subject='test1'),
									new Task( Status='Open', Subject='testingS3MigrationCase to process'),
									new Task( Status='Open', Subject='testingS3MigrationCase'),
									new Task( Status='Open', Subject='testingS3MigrationCase too big file'),
									new Task( Status='Open', Subject='testingS3MigrationCase small file'),
									new Task( Status='Open', Subject='testingS3MigrationCase not to proceed')
								};
		insert tasks;
		//create email messages
		EmailMessage[]  emails = new EmailMessage[]{
						new EmailMessage( ActivityId=tasks[0].Id, ParentId = cases[0].Id, FromName=contacts.LastName, FromAddress=contacts.Email, Subject= cases[0].Subject ),
						new EmailMessage( ActivityId=tasks[1].Id, ParentId = cases[0].Id, FromName=contacts.LastName, FromAddress=contacts.Email, Subject= cases[0].Subject ),
						new EmailMessage( ActivityId=tasks[2].Id, ParentId = cases[1].Id, FromName=contacts.LastName, FromAddress=contacts.Email, Subject= cases[1].Subject ),
						new EmailMessage( ActivityId=tasks[3].Id, ParentId = cases[1].Id, FromName=contacts.LastName, FromAddress=contacts.Email, Subject= cases[1].Subject ),
						new EmailMessage( ActivityId=tasks[4].Id, ParentId = cases[2].Id, FromName=contacts.LastName, FromAddress=contacts.Email, Subject= cases[2].Subject ),
						new EmailMessage( ActivityId=tasks[5].Id, ParentId = cases[2].Id, FromName=contacts.LastName, FromAddress=contacts.Email, Subject= cases[2].Subject ),
						new EmailMessage( ActivityId=tasks[6].Id, ParentId = cases[3].Id, FromName=contacts.LastName, FromAddress=contacts.Email, Subject= cases[3].Subject )
		};
		insert emails;

		//create attachment to em
		Attachment[] atts =new Attachment[]{
			attachFileToParent(emails[0].Id),
			attachFileToParent(emails[1].Id),
			attachFileToParent(emails[2].Id),
			attachFileToParent(emails[3].Id),
			attachBigFileToParent(emails[4].Id),
			attachFileToParent(emails[5].Id),
			attachFileToParent(emails[6].Id)
		};
		insert atts;

		system.debug('[TEST AWS] system has created  '+atts.size()+' attachements');
		List<String> ids = new List<String>();
		for(Attachment a:atts)
			ids.add(a.Id);
		system.assert(ids.size()==7);


		List<String> emIds = new List<String>();
		for(emailMessage em:emails)
			emIds.add(em.Id);
		system.assert(ids.size()==7);

		//call the Job monitor to process threatment : only Attachment 2 should have been migrated
		new AwsCaseMigrationJob().execute(null);

		//have to wait has the AWS is calling task in futur :/
		Test.stopTest();

		//now check//

		//should have on ly attachment realted to case 1 moved to amazon
		atts = [select Id from Attachment where id in :ids];
		system.debug('[TEST AWS] once performed system have  '+atts.size()+' attachements ');
		//system.assert(atts.size()>0);
		//try to get Archived attachmnent
		List<Archived_Message__c> ams = [select Id , Name from Archived_Message__c where Case__c = :cases[1].id];
		system.debug('[TEST AWS] once performed system have  '+ams.size()+' Archived_Message__c  (expected 2)');


	   // system.assert( ams.size()>0);
		Archived_Message__c am = ams[0];
		List<Archived_Attachment__c> aatts = [select Id from Archived_Attachment__c where ArchivedMessage__c = :am.Id];
		system.debug('[TEST AWS] once performed system have  '+aatts.size()+' Archived_Attachment__c  (expected 2)');
	   //   system.assert(aatts!=null && aatts.size()==2);

		List<Task> updatedTask =  [select Status, Id from Task where Id in (select Activityid from EmailMessage where Parentid in :emIds)];
		Integer archivedTask = 0;
		for(Task atask:updatedTask){
			system.debug('[TEST AWS] Activity '+atask.Id+' has for status '+atask.status);
			if(atask.Status.equals('Archived'))
				archivedTask++;
		}
	}

	/**
	Test triggers

	*/
	 static testMethod void testDeletionTriggersFromEmailMessage() {
		Test.startTest();
		initTest();
	   Account accounts = new Account(Name='test', Type='Prospect', CurrencyIsoCode='USD', BillingCountry='USA');
		insert accounts;

		// create the contact a first time
		Contact contacts = new Contact(Email='test@email.com', FirstName='test', LastName='test', AccountId=accounts.Id);
		insert contacts;

		// create a case with no information in salesforce
		Case acase =  new Case(Subject='testingS3MigrationCase',  CaseArea__c = 'Airline Joining', AccountId=accounts.Id, ContactId =contacts.Id, Status = 'Closed' , Description='le test 1', SuppliedName='Anne Honyme', SuppliedCompany='Fictive', SuppliedEmail='fake@fake.com', Origin='Web');
		insert acase;

		// create taask as bases for email nessages
		Task task = new Task( Status='Open', Subject='testingS3MigrationCase to process');
		insert task;
		//create email messages
		EmailMessage  email = new EmailMessage( ActivityId=task.Id, ParentId = acase.Id, FromName=contacts.LastName, FromAddress=contacts.Email, Subject= acase.Subject );
		insert email;

		//create attachment to em
		Attachment  att =  attachFileToParent(email.Id);
		insert att;
		//call the Job monitor to process threatment : only Attachment 2 should have been migrated
		new AwsCaseMigrationJob().execute(null);
		Test.stopTest();

		List<Archived_Message__c> ams = [select Id , Name from Archived_Message__c where Case__c = :acase.id];
		system.debug('[TEST AWS] once performed system have  '+ams.size()+' Archived_Message__c  (expected 1)');
		system.assert( ams.size()==1);
		Archived_Message__c am = ams[0];
		system.debug('[TEST AWS] am Id '+am.Id);
		List<Archived_Attachment__c> aatts = [select Id from Archived_Attachment__c where ArchivedMessage__c = :am.Id];

		system.debug('[TEST AWS] once performed system have  '+aatts.size()+' Archived_Attachment__c  (expected 1)');
		system.assert( ams.size()==1);
		Archived_Attachment__c aatt = aatts[0];
		system.debug('[TEST AWS] aatt Id '+aatt.Id);

		system.debug('[TEST AWS]call deelet');
		delete email;

		ams =   [select Id , Name from Archived_Message__c where Case__c = :acase.id];
		system.debug('[TEST AWS] once performed system have  '+ams.size()+' Archived_Message__c  (expected 0)');
		//system.assert( ams.size()==0);
		aatts = [select Id from Archived_Attachment__c where ArchivedMessage__c = :am.Id];
		system.debug('[TEST AWS] once performed system have  '+aatts.size()+' Archived_Attachment__c  (expected 0)');
		//.assert( aatts.size()==0);


	}

}
