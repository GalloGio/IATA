@isTest
public class ISSP_InterlineAgreementsContactsCtrlTest {

	private static Id RT_AIRLINE = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
	private static Id RT_CONTACT = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
	private static Account airline;
	private static Contact contact;

	@TestSetup
	public static void setup(){
		airline = new Account(
			RecordTypeId = RT_AIRLINE,
			Name='MyAirline1',
			ACLI_Status__c = 'Active Company',
			MITA_Member__c = true,
			BIETA_Member__c = true,
			Airline_designator__c = 'AA',
			IATACode__c = '111',
			Airline_Prefix__c = '111'
		);

		insert airline;

		contact = new Contact (
			RecordTypeId = RT_CONTACT,
			AccountId = airline.Id,
			FirstName = 'first1',
			LastName = 'last1',
			Email = 'test1email@test.com',
			Phone = '123456789',
			Status__c = 'Active',
			MITA_Contact_Type__c = null
		);
		insert contact;
	}

	private static void queryRecords() {
		airline = [
			SELECT Name, Airline_Prefix__c, Airline_designator__c, IATAcode__c, Membership_status__c, MITA_Member__c, BIETA_Member__c, Logo_File_ID__c,
			MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Cargo__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
			BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c,
			BIETA_One_way_Intermodal_Participating__c
			FROM Account
			WHERE Name = 'MyAirline1'];

		contact = [
			SELECT Id, RecordTypeId, AccountId, FirstName, LastName, Email, Phone, Status__c, MITA_Contact_Type__c
			FROM Contact
			WHERE Email = 'test1email@test.com'];
	}

	static TestMethod void testController(){
		queryRecords();

		Test.StartTest();
		ISSP_InterlineAgreementsContactsCtrl ctrl = new ISSP_InterlineAgreementsContactsCtrl();
		ctrl.resetAlertModal();
		ctrl.account = airline;
		ctrl.hasEditContactsPermission = true;

		System.assert(ctrl.contactRows!=null);
		System.assertEquals(0,ctrl.contactRows.size());
		//System.assertEquals(0,ctrl.getOptionTypes().size());
		//System.assertEquals(0,ctrl.getOptionNames().size());
		//System.assertEquals(0,ctrl.getOptionStatus().size());
		Test.stopTest();
	}

	static TestMethod void testEditContact(){
		queryRecords();

		contact.MITA_Contact_Type__c = 'Interline Airline Generic Contact';
		update contact;

		ISSP_InterlineAgreementsContactsCtrl ctrl = new ISSP_InterlineAgreementsContactsCtrl();
		ctrl.account = airline;
		ctrl.hasEditContactsPermission = true;

		Test.StartTest();

		System.assert(ctrl.contactRows!=null);
		System.assertEquals(1,ctrl.contactRows.size());

		System.assertEquals(null,ctrl.selectedContact);
		System.assertEquals(null,ctrl.showModalContact);
		System.assertEquals(null,ctrl.alertModal);

		// open modal to show detail contact
		ctrl.selectedContactId = MITAutil.Encrypt(ISSP_InterlineAgreementsContactsCtrl.EncDecKey,contact.Id);
		ctrl.openModalContact();
		System.assertEquals(contact.Id,ctrl.selectedContact.Id);
		System.assertEquals(true,ctrl.showModalContact);
		System.assertEquals(null,ctrl.alertModal);

		// update contact
		contact.MITA_Contact_Type__c = MITAutil.GENERIC_CONTACT;
		ctrl.saveContact();
		System.assertEquals(contact.Id,ctrl.selectedContact.Id);
		System.assertEquals(true,ctrl.showModalContact);
		System.assert(ctrl.alertModal!=null);
		System.assertEquals('successMsgNew',ctrl.alertModal.msgType);

		// close modal
		contact.MITA_Contact_Type__c = MITAutil.GENERIC_CONTACT + ';' + MITAutil.CARGO_MANAGER;
		ctrl.closeModalContact();
		System.assertEquals(false,ctrl.showModalContact);
		System.assertEquals(null,ctrl.selectedContactId);
		System.assertEquals(null,ctrl.alertModal);

		//check tthat the contact is still in the page
		System.assertEquals(1,ctrl.contactRows.size());

		Test.stopTest();
	}

	static TestMethod void testDeleteContact(){
		queryRecords();

		contact.MITA_Contact_Type__c = MITAutil.GENERIC_CONTACT;
		update contact;

		ISSP_InterlineAgreementsContactsCtrl ctrl = new ISSP_InterlineAgreementsContactsCtrl();
		ctrl.account = airline;
		ctrl.hasEditContactsPermission = true;

		Test.StartTest();

		System.assert(ctrl.contactRows!=null);
		System.assertEquals(1,ctrl.contactRows.size());

		System.assertEquals(null,ctrl.selectedContact);
		System.assertEquals(null,ctrl.showModalContact);
		System.assertEquals(null,ctrl.alertModal);

		// open modal to show detail contact
		ctrl.selectedContactId = MITAutil.Encrypt(ISSP_InterlineAgreementsContactsCtrl.EncDecKey,contact.Id);
		ctrl.openModalContact();
		System.assertEquals(contact.Id,ctrl.selectedContact.Id);
		System.assertEquals(true,ctrl.showModalContact);
		System.assertEquals(null,ctrl.alertModal);

		// update contact
		ctrl.deleteContact();
		System.assertEquals(contact.Id,ctrl.selectedContact.Id);
		System.assertEquals(true,ctrl.showModalContact);
		System.assert(ctrl.alertModal!=null);
		System.assertEquals('successMsgNew',ctrl.alertModal.msgType);

		// close modal
		contact.MITA_Contact_Type__c = MITAutil.GENERIC_CONTACT + ';' + MITAutil.CARGO_MANAGER;
		ctrl.closeModalContact();
		System.assertEquals(false,ctrl.showModalContact);
		System.assertEquals(null,ctrl.selectedContactId);
		System.assertEquals(null,ctrl.alertModal);

		//check tthat the contact is not visible in the page
		System.assertEquals(0,ctrl.contactRows.size());

		Test.stopTest();
	}
}
