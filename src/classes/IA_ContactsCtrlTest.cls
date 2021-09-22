@isTest
public class IA_ContactsCtrlTest {

	private static Account airline;
	private static Contact contact;

	@TestSetup
	public static void setup(){
		airline = TestDataFactory_Accounts.createAirlineAccounts(1).get(0);
		insert airline;

		contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		contact.AccountId = airline.Id;
		contact.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact') ;
		contact.Phone = '123456789';
		contact.Status__c = 'Active';
		contact.MITA_Contact_Type__c = null;
		contact.MITA_Contact__c = false;
		insert contact;
	}

	private static void queryRecords() {
		airline = [
			SELECT Name, Airline_Prefix__c, Airline_designator__c, IATAcode__c, Membership_status__c, MITA_Member__c, BIETA_Member__c, Company_Logo__c,
			MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Cargo__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
			BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c,
			BIETA_One_way_Intermodal_Participating__c
			FROM Account
			WHERE Name = :(TestDataFactory_Accounts.DEFAULTNAME + ' 0')];

		contact = [
			SELECT Id, RecordTypeId, AccountId, Name, FirstName, LastName, Email, Phone, Status__c, MITA_Contact_Type__c, MITA_Contact__c
			FROM Contact
			WHERE Email = :(TestDataFactory_Contacts.DEFAULTEMAIL + '0')];
	}

	static testMethod void testController(){
		queryRecords();

		Test.StartTest();
		IA_ContactsCtrl ctrl = new IA_ContactsCtrl();
		ctrl.resetAlertModal();
		ctrl.account = airline;
		ctrl.hasEditContactsPermission = true;

		System.assert(ctrl.contactRows!=null);
		System.assertEquals(0,ctrl.contactRows.size());
		Test.stopTest();
	}

	static TestMethod void testAddContact(){
		queryRecords();

		IA_ContactsCtrl ctrl = new IA_ContactsCtrl();
		ctrl.account = airline;
		ctrl.hasEditContactsPermission = true;

		Test.StartTest();

		// open modal to show add contact modal
		ctrl.openModalAddContact();
		System.assertEquals(null,ctrl.selectedContactSearchKey);
		System.assertEquals(true,ctrl.showModalAddContact);
		System.assertEquals(false,ctrl.showSearchedContact);
		System.assertEquals(null,ctrl.alertModal);

		// get serachable contacts
		System.assertEquals(1, ctrl.searchableContactOptions.size());
		System.assertEquals(contact.Name, ctrl.searchableContactOptions[0]);

		//search a contact
		ctrl.selectedContactSearchKey = contact.Name;
		ctrl.openSearchedContact();
		System.assertEquals(contact.Id,ctrl.selectedContact.Id);

		//save a contact
		ctrl.selectedContact.MITA_Contact_Type__c = IA_util.GENERIC_CONTACT;
		
		ctrl.MITAContactOptionWrappers[0].checked = true;
		ctrl.saveContact();
		System.assertEquals(contact.Id,ctrl.selectedContact.Id);
		System.assertEquals(true,ctrl.selectedContact.MITA_Contact__c);
		System.assertEquals(true,ctrl.showModalAddContact);
		System.assert(ctrl.alertModal!=null);
		System.assertEquals(IA_util.ALERTMODAL_SUCCESSNEW,ctrl.alertModal.msgType);

		// close modal
		ctrl.closeModalAddContact();
		System.assertEquals(false,ctrl.showModalAddContact);
		System.assertEquals(null,ctrl.selectedContactSearchKey);
		System.assertEquals(null,ctrl.alertModal);

		Test.stopTest();
	}

	static testMethod void testEditContact(){
		queryRecords();

		contact.MITA_Contact_Type__c = IA_util.GENERIC_CONTACT;
		contact.MITA_Contact__c = true;
		update contact;

		IA_ContactsCtrl ctrl = new IA_ContactsCtrl();
		ctrl.account = airline;
		ctrl.hasEditContactsPermission = true;

		Test.StartTest();

		System.assert(ctrl.contactRows!=null);
		System.assertEquals(1,ctrl.contactRows.size());

		System.assertEquals(null,ctrl.selectedContact);
		System.assertEquals(null,ctrl.showModalContact);
		System.assertEquals(null,ctrl.alertModal);

		// open modal to show detail contact
		ctrl.selectedContactId = IA_util.Encrypt(IA_ContactsCtrl.EncDecKey,contact.Id);
		ctrl.openModalContact();
		System.assertEquals(contact.Id,ctrl.selectedContact.Id);
		System.assertEquals(true,ctrl.showModalContact);
		System.assertEquals(null,ctrl.alertModal);

		// update contact
		ctrl.MITAContactOptionWrappers[0].checked = true;
		ctrl.saveContact();
		System.assertEquals(contact.Id,ctrl.selectedContact.Id);
		System.assertEquals(true,ctrl.selectedContact.MITA_Contact__c);
		System.assertEquals(true,ctrl.showModalContact);
		System.assert(ctrl.alertModal!=null);
		System.assertEquals(IA_util.ALERTMODAL_SUCCESSNEW,ctrl.alertModal.msgType);

		// close modal
		contact.MITA_Contact_Type__c = IA_util.GENERIC_CONTACT + ';' + IA_util.CARGO_MANAGER;
		ctrl.closeModalContact();
		System.assertEquals(true,ctrl.selectedContact.MITA_Contact__c);
		System.assertEquals(false,ctrl.showModalContact);
		System.assertEquals(null,ctrl.selectedContactId);
		System.assertEquals(null,ctrl.alertModal);

		//check tthat the contact is still in the page
		System.assertEquals(1,ctrl.contactRows.size());

		Test.stopTest();
	}

	static testMethod void testDeleteContact(){
		queryRecords();

		contact.MITA_Contact_Type__c = IA_util.GENERIC_CONTACT;
		contact.MITA_Contact__c = true;
		update contact;

		IA_ContactsCtrl ctrl = new IA_ContactsCtrl();
		ctrl.account = airline;
		ctrl.hasEditContactsPermission = true;

		Test.StartTest();

		System.assert(ctrl.contactRows!=null);
		System.assertEquals(1,ctrl.contactRows.size());

		System.assertEquals(null,ctrl.selectedContact);
		System.assertEquals(null,ctrl.showModalContact);
		System.assertEquals(null,ctrl.alertModal);

		// open modal to show detail contact
		ctrl.selectedContactId = IA_util.Encrypt(IA_ContactsCtrl.EncDecKey,contact.Id);
		ctrl.openModalContact();
		System.assertEquals(contact.Id,ctrl.selectedContact.Id);
		System.assertEquals(true,ctrl.showModalContact);
		System.assertEquals(null,ctrl.alertModal);

		// update contact
		ctrl.selectedContactId = IA_util.Encrypt(IA_ContactsCtrl.EncDecKey,contact.Id);
		ctrl.openModalRemoveContact();
		ctrl.deleteContact();
		System.assertEquals(false,ctrl.selectedContact.MITA_Contact__c);
		System.assertEquals(null,ctrl.selectedContactId);
		System.assertEquals(null,ctrl.selectedContact);
		System.assertEquals(true,ctrl.showModalContact);
		System.assert(ctrl.alertModal!=null);
		System.assertEquals(IA_util.ALERTMODAL_SUCCESSNEW,ctrl.alertModal.msgType);
		System.assertEquals(null, [SELECT MITA_Contact_Type__c FROM Contact WHERE Id = :contact.Id].MITA_Contact_Type__c);

		// close modal
		contact.MITA_Contact_Type__c = IA_util.GENERIC_CONTACT + ';' + IA_util.CARGO_MANAGER;
		ctrl.closeModalContact();
		System.assertEquals(false,ctrl.selectedContact.MITA_Contact__c);
		System.assertEquals(false,ctrl.showModalContact);
		System.assertEquals(null,ctrl.selectedContactId);
		System.assertEquals(null,ctrl.alertModal);

		//check tthat the contact is not visible in the page
		System.assertEquals(0,ctrl.contactRows.size());

		Test.stopTest();
	}
}