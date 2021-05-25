public without sharing class IA_ContactsCtrl {
	@testVisible
	private static Blob EncDecKey = Blob.valueOf('I@T@M!tAS3rvIc3!');

	public Account account {get;set;}
	public Boolean hasEditContactsPermission {get;set;}
	public IA_util.AlertModal alertModal{get;set;}

	public Map<String,String> getMapTypeLabels() {
		return IA_util.MAP_MITA_CONTACT_TYPE_LABELS;
	}

	/**
	 * initialize agreement variables to retrieve them again
	 **/
	public void refreshPage() {
		this.mapContacts = null;
		this.contactRows = null;
	}

	private map<Id,Contact> mapContacts {
		get{
			if (mapContacts==null) {
				mapContacts = new Map<Id,Contact>(
					[SELECT id, Name, Email, Phone, MITA_Contact_Type__c, Title, Account.Name
					FROM Contact
					WHERE Recordtype.Developername = 'Standard_Contact'
					AND Status__c = 'Active'
					AND MITA_Contact_Type__c != null
					AND (AccountId = :this.account.Id OR Account.Top_Parent__c = :this.account.Id)
					ORDER BY Name ASC
					LIMIT 1000]
				);
			}
			return mapContacts;
		}
		private set;
	}

	public list<ContactRow> contactRows {
		get{
			if (contactRows==null) {
				contactRows = new list<ContactRow>();
				for(Contact contact : mapContacts.values()){
					contactRows.add(new ContactRow(contact));
				}
			}
			return contactRows;
		}
		private set;
	}

	public class ContactRow {
		public String contactId {get;set;}
		public String name {get;set;}
		public String phone {get;set;}
		public String email {get;set;}
		public List<String> types {get;set;}
		public String title {get;set;}

		public ContactRow(Contact contact) {
			this.contactId = IA_util.Encrypt(EncDecKey,contact.Id);
			this.name = contact.Name;
			this.phone = contact.Phone;
			this.email = contact.Email;
			this.types = contact.MITA_Contact_Type__c.split(';');
			this.title = contact.Title;
		}
	}

	/**
	 * gets the map for all contacts in the account hierarchy which are NOT mita contacts
	 * (having MITA_Contact_Type__c empty)
	 * they will appear in the search contact popup
	 */
	private map<String,Contact> mapSearchableContacts {
		get{
			mapSearchableContacts = new Map<String,Contact>();
			for (Contact contact:
				[SELECT id, Name, Email, Phone, MITA_Contact_Type__c, Title, Account.Name
				FROM Contact
				WHERE Recordtype.Developername = 'Standard_Contact'
				AND Status__c = 'Active'
				AND MITA_Contact_Type__c = null
				AND (AccountId = :this.account.Id OR Account.Top_Parent__c = :this.account.Id)
				ORDER BY Name ASC
				LIMIT 1000]) {
					mapSearchableContacts.put(contact.Name, contact);
					mapSearchableContacts.put(contact.Email, contact);
			}
			return mapSearchableContacts;
		}
		private set;
	}

	public list<String> searchableContactOptions {
		get{
			list<String> listOptions = new list<String>(mapSearchableContacts.keyset());
			listOptions.sort();
			return listOptions;
		}
		private set;
	}

	/**
	 * COMMON MODAL VARS
	 */
	public Contact selectedContact {get;set;}
	public list<String> selectedMITAContactTypes {get;set;}

	/***
	 * MODAL ADD CONTACT
	 **/
	public Boolean showModalAddContact {get;set;}
	public Boolean showSearchedContact {get;set;}
	public String selectedContactSearchKey {get;set;}

	public void openModalAddContact() {
		this.showModalAddContact = true;
		this.showSearchedContact = false;
		this.selectedContactSearchKey = null;
		this.selectedContact = null;
		this.alertModal = null;
	}

	public void closeModalAddContact() {
		this.showModalAddContact = false;
		this.showSearchedContact = false;
		this.selectedContactSearchKey = null;
		this.selectedContact = null;
		this.alertModal = null;
	}

	public void openSearchedContact() {
		this.selectedContact = this.mapSearchableContacts.get(this.selectedContactSearchKey);
		this.showSearchedContact = (this.selectedContact!=null);
		this.selectedMITAContactTypes = new list<String>();
	}

	/***
	 * MODAL EDIT CONTACT
	 **/
	public Boolean showModalContact {get;set;}
	public String selectedContactId {get;set;}

	/**
	 * Opens the modal to edit a contact
	 **/
	public void openModalContact() {
		if (String.isEmpty(this.selectedContactId)) {
			this.selectedContact = new Contact();
			this.selectedContact.MITA_Contact_Type__c = '';
		} else {
			this.selectedContact = this.mapContacts.get(IA_util.Decrypt(EncDecKey,this.selectedContactId));
			if (this.selectedContact==null) return;
		}

		this.selectedMITAContactTypes = this.selectedContact.MITA_Contact_Type__c.split(';');
		this.showModalContact = true;
		this.alertModal = null;
	}

	/**
	 * Closes the modal to edit a contact
	 **/
	public void closeModalContact() {
		this.showModalContact = false;
		this.selectedContactId = null;
		this.alertModal = null;
	}


	public void saveContact(){
		if(!this.hasEditContactsPermission || this.selectedContact==null) return;

		try {
			Boolean isAdded = String.isEmpty(this.selectedContact.MITA_Contact_Type__c);
			this.selectedContact.MITA_Contact_Type__c = String.join(selectedMITAContactTypes,';');
			Database.SaveResult result = Database.update(this.selectedContact);
			if (result.isSuccess()) {
				refreshPage();
				this.selectedContactId = null;
				String label = isAdded? Label.CSP_Contact_Added: Label.CSP_Contact_Updated;
				this.alertModal = new IA_util.AlertModal(IA_util.ALERTMODAL_SUCCESSNEW,label,'','');
			}
		} catch (Exception e) {
			this.alertModal = new IA_util.AlertModal(IA_util.ALERTMODAL_ERROR,'',Label.IA_Contact_Save_Problem,'');
		}
	}

	/***
	 * MODAL REMOVE CONTACT
	 **/
	public Boolean showModalRemoveContact {get;set;}

	/**
	 * Opens the modal to remove a contact
	 **/
	public void openModalRemoveContact() {
		this.selectedContact = this.mapContacts.get(IA_util.Decrypt(EncDecKey,this.selectedContactId));
		if (this.selectedContact==null) return;

		this.showModalRemoveContact = true;
		this.alertModal = null;
	}

	/**
	 * Closes the modal to remove a contact
	 **/
	public void closeModalRemoveContact() {
		this.showModalRemoveContact = false;
		this.selectedContactId = null;
		this.selectedContact = null;
		this.alertModal = null;
	}

	/**
	 * This removes the contact from the list, but it is not actually removed from databes
	 * Only empties the field MITA_Contact_Type__c
	 */
	public void deleteContact(){
		if(!this.hasEditContactsPermission || this.selectedContact==null) return;

		try {
			this.selectedContact.MITA_Contact_Type__c = '';
			Database.SaveResult result = Database.update(this.selectedContact);
			if (result.isSuccess()) {
				closeModalRemoveContact();
				refreshPage();
				this.alertModal = new IA_util.AlertModal(IA_util.ALERTMODAL_SUCCESSNEW,Label.CSP_Contact_Deleted,'','');
			}
		} catch (Exception e) {
			this.alertModal = new IA_util.AlertModal(IA_util.ALERTMODAL_ERROR,'',Label.IA_Contact_Save_Problem,'');
		}
	}

	/**
	 * Clean the alert modal
	 */
	public void resetAlertModal() {
		this.alertModal = null;
	}

	/**
	 * Get the options for the MITA Contact Type field
	 */
	public list<SelectOption> getMITAContactTypesOptions() {
		list<SelectOption> options = new list<SelectOption>();
		for (String type: IA_util.LIST_MITA_CONTACTS) {
			options.add(new SelectOption(type,type));
		}
		return options;
	}
}