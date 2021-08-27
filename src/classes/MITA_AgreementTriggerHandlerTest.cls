@isTest
public class MITA_AgreementTriggerHandlerTest {

	private static Id RT_AIRLINE = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
	private static Account airline1;
	private static Account airline2;
	private static Contact contact1;
	private static Contact contact2;

	@TestSetup
	public static void setup(){

		Notification_Template__c template1 = new Notification_template__c (
			Subject__c = MITA_AgreementTriggerHandler.TEMPLATE_REQUESTED,
			Message__c = 'Some message',
			Admins_Users__c = 'User',
			Identifier__c = 'notification'
		);
		Notification_Template__c template2 = new Notification_template__c (
			Subject__c = MITA_AgreementTriggerHandler.TEMPLATE_APPROVED,
			Message__c = 'Some message',
			Admins_Users__c = 'User',
			Identifier__c = 'notification'
		);
		Notification_Template__c template3 = new Notification_template__c (
			Subject__c = MITA_AgreementTriggerHandler.TEMPLATE_REJECTED,
			Message__c = 'Some message',
			Admins_Users__c = 'User',
			Identifier__c = 'notification'
		);
		Notification_Template__c template4 = new Notification_template__c (
			Subject__c = MITA_AgreementTriggerHandler.TEMPLATE_WITHDRAWN,
			Message__c = 'Some message',
			Admins_Users__c = 'User',
			Identifier__c = 'notification'
		);
		insert new list<Notification_Template__c>{template1, template2, template3, template4};

		insert new list<ISSP_Notifications_Trigger__c>{
			new ISSP_Notifications_Trigger__c (
				Name = MITA_AgreementTriggerHandler.TEMPLATE_REQUESTED,
				Notification_Template_Id__c = template1.Id
			),
			new ISSP_Notifications_Trigger__c (
				Name = MITA_AgreementTriggerHandler.TEMPLATE_APPROVED,
				Notification_Template_Id__c = template2.Id
			),
			new ISSP_Notifications_Trigger__c (
				Name = MITA_AgreementTriggerHandler.TEMPLATE_REJECTED,
				Notification_Template_Id__c = template3.Id
			),
			new ISSP_Notifications_Trigger__c (
				Name = MITA_AgreementTriggerHandler.TEMPLATE_WITHDRAWN,
				Notification_Template_Id__c = template4.Id
			)
		};

		airline1 = new Account(
			RecordTypeId = RT_AIRLINE,
			Name='MyAirline1',
			ACLI_Status__c = 'Active Company',
			MITA_Member__c = true,
			BIETA_Member__c = true,
			Airline_designator__c = 'AA',
			IATACode__c = '111',
			Airline_Prefix__c = '111',
			MITA_IATA_Interline_Passenger__c = Date.today(),
			MITA_IATA_Interline_Cargo__c = Date.today(),
			MITA_One_way_Pass_Issuing_Airline__c = Date.today(),
			MITA_One_way_Pass_Participating__c = Date.today(),
			BIETA_Bilateral_Date__c = Date.today(),
			BIETA_One_way_Electronic_Issuing_Airline__c = Date.today(),
			BIETA_One_way_Electronic_Participating__c = Date.today(),
			BIETA_One_way_Intermodal_Issuing_Airline__c = Date.today(),
			BIETA_One_way_Intermodal_Participating__c = Date.today()
		);

		airline2 = new Account(
			RecordTypeId = RT_AIRLINE,
			Name='MyAirline2',
			ACLI_Status__c = 'Active Company',
			MITA_Member__c = true,
			BIETA_Member__c = true,
			Airline_designator__c = 'BB',
			IATACode__c = '222',
			Airline_Prefix__c = '222',
			MITA_IATA_Interline_Passenger__c = Date.today(),
			MITA_IATA_Interline_Cargo__c = Date.today(),
			MITA_One_way_Pass_Issuing_Airline__c = Date.today(),
			MITA_One_way_Pass_Participating__c = Date.today(),
			BIETA_Bilateral_Date__c = Date.today(),
			BIETA_One_way_Electronic_Issuing_Airline__c = Date.today(),
			BIETA_One_way_Electronic_Participating__c = Date.today(),
			BIETA_One_way_Intermodal_Issuing_Airline__c = Date.today(),
			BIETA_One_way_Intermodal_Participating__c = Date.today()
		);

		insert new list<Account>{airline1,airline2};

		contact1 = new Contact (
			AccountId = airline1.Id,
			FirstName = 'first1',
			LastName = 'last1',
			Email = 'test1email@test.com',
			Phone = '123456789',
			Status__c = 'Active',
			MITA_Contact__c = true,
			User_Portal_Status__c = 'Administrator',
			MITA_Contact_Type__c = IA_util.GENERIC_CONTACT
		);
		contact2 = new Contact (
			AccountId = airline2.Id,
			FirstName = 'first2',
			LastName = 'last2',
			Email = 'test2email@test.com',
			Phone = '123456789',
			Status__c = 'Active',
			MITA_Contact__c = true,
			User_Portal_Status__c = 'Administrator',
			MITA_Contact_Type__c = IA_util.CARGO_MANAGER
		);
		insert new list<Contact>{contact1,contact2};
	}

	private static void queryRecords() {
		for ( Account account: [
				SELECT Name, Airline_Prefix__c, Airline_designator__c, IATAcode__c, Membership_status__c, MITA_Member__c, BIETA_Member__c, Logo_File_ID__c,
				MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Cargo__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
				BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c,
				BIETA_One_way_Intermodal_Participating__c
				FROM Account])
		{
			if (account.Name == 'MyAirline1') airline1 = account;
			if (account.Name == 'MyAirline2') airline2 = account;
		}
		for ( Contact contact: [
				SELECT Id, RecordTypeId, AccountId, FirstName, LastName, Email, Phone, Status__c, MITA_Contact_Type__c
				FROM Contact])
		{
			if (contact.Email == 'test1email@test.com') contact1 = contact;
			if (contact.Email == 'test2email@test.com') contact2 = contact;
		}
	}

	static testMethod void testRequestNotification(){
		queryRecords();

		MITA_Agreement__c agreement = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PAX,
			Created_date__c = Date.today(),
			Agreement_processed_date__c = Date.today(),
			Effective_date__c = Date.today()
		);

		Test.StartTest();
		insert agreement;
		Test.stopTest();

		list<Notification__c> listNotification = [SELECT Id, Subject__c, Contact__c FROM Notification__c ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(1, listNotification.size());
		System.assertEquals(MITA_AgreementTriggerHandler.TEMPLATE_REQUESTED, listNotification[0].Subject__c);
		System.assertEquals(contact2.Id, listNotification[0].Contact__c);
	}

	static TestMethod void testApprovalNotification(){
		queryRecords();

		MITA_Agreement__c agreement = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PAX,
			Created_date__c = Date.today(),
			Agreement_processed_date__c = Date.today(),
			Effective_date__c = null,
			Cancellation_date__c = null
		);
		insert agreement;

		Test.StartTest();
		agreement.Effective_date__c = Date.today();
		update agreement;
		Test.stopTest();

		list<Notification__c> listNotification = [SELECT Id, Subject__c, Contact__c
			FROM Notification__c
			WHERE Subject__c = :MITA_AgreementTriggerHandler.TEMPLATE_APPROVED
			ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(1, listNotification.size());
		System.assertEquals(MITA_AgreementTriggerHandler.TEMPLATE_APPROVED, listNotification[0].Subject__c);
		System.assertEquals(contact1.Id, listNotification[0].Contact__c);
	}

	static testMethod void testRejectNotification(){
		queryRecords();

		MITA_Agreement__c agreement = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PAX,
			Created_date__c = Date.today(),
			Agreement_processed_date__c = Date.today()
		);
		insert agreement;

		Test.StartTest();
		agreement.Cancellation_date__c = Date.today();
		agreement.Cancellation_Reason__c = 'Rejected by Airline 2';
		update agreement;
		Test.stopTest();

		list<Notification__c> listNotification = [SELECT Id, Subject__c, Contact__c
			FROM Notification__c
			WHERE Subject__c = :MITA_AgreementTriggerHandler.TEMPLATE_REJECTED
			ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(1, listNotification.size(), listNotification);
		System.assertEquals(MITA_AgreementTriggerHandler.TEMPLATE_REJECTED, listNotification[0].Subject__c);
		System.assertEquals(contact1.Id, listNotification[0].Contact__c);
	}

	static testMethod void testWithdrawNotification1(){
		queryRecords();

		MITA_Agreement__c agreement = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PAX,
			Created_date__c = Date.today(),
			Agreement_processed_date__c = Date.today()
		);
		insert agreement;

		Test.StartTest();
		agreement.Cancellation_date__c = Date.today();
		agreement.Cancellation_Reason__c = 'Airline 1 leaves agreement';
		update agreement;
		Test.stopTest();

		list<Notification__c> listNotification = [SELECT Id, Subject__c, Contact__c
			FROM Notification__c
			WHERE Subject__c = :MITA_AgreementTriggerHandler.TEMPLATE_WITHDRAWN
			ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(1, listNotification.size(), listNotification);
		System.assertEquals(MITA_AgreementTriggerHandler.TEMPLATE_WITHDRAWN, listNotification[0].Subject__c);
		System.assertEquals(contact2.Id, listNotification[0].Contact__c);
	}

	static testMethod void testWithdrawNotification2(){
		queryRecords();

		MITA_Agreement__c agreement = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PAX,
			Created_date__c = Date.today(),
			Agreement_processed_date__c = Date.today()
		);
		insert agreement;

		Test.StartTest();
		agreement.Cancellation_date__c = Date.today();
		agreement.Cancellation_Reason__c = 'Airline 2 leaves agreement';
		update agreement;
		Test.stopTest();

		list<Notification__c> listNotification = [SELECT Id, Subject__c, Contact__c
			FROM Notification__c
			WHERE Subject__c = :MITA_AgreementTriggerHandler.TEMPLATE_WITHDRAWN
			ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(1, listNotification.size(), listNotification);
		System.assertEquals(MITA_AgreementTriggerHandler.TEMPLATE_WITHDRAWN, listNotification[0].Subject__c);
		System.assertEquals(contact1.Id, listNotification[0].Contact__c);
	}
}
