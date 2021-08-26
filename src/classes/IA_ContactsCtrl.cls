public without sharing class IA_ContactsCtrl {
	@testVisible
	private static Blob EncDecKey = Blob.valueOf('I@T@M!tAS3rvIc3!');

	public Account account {get;set;}
	public Boolean hasEditContactsPermission {get;set;}
	public IA_util.AlertModal alertModal{get;set;}

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
					[SELECT id, Name, Email, Phone, MITA_Contact_Type__c, MITA_Contact__c, Title, Account.Name
					FROM Contact
					WHERE Recordtype.Developername = 'Standard_Contact'
					AND Status__c = 'Active'
					AND MITA_Contact__c = true
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
		public List<IA_util.MitaType> types {get;set;}
		public String title {get;set;}

		public ContactRow(Contact contact) {
			this.contactId = IA_util.encrypt(EncDecKey,contact.Id);
			this.name = contact.Name;
			this.phone = contact.Phone;
			this.email = contact.Email;
			this.types = new list<IA_util.MitaType>();
			contact.MITA_Contact_Type__c = contact.MITA_Contact_Type__c == null? '': contact.MITA_Contact_Type__c;
			for (String name: contact.MITA_Contact_Type__c.split(';')) {
				this.types.add(new IA_util.MitaType(name));
			}
			this.title = contact.Title;
		}
	}

	/**
	 * gets the map for all contacts in the account hierarchy which are NOT mita contacts
	 * (having MITA_Contact__c = false)
	 * they will appear in the search contact popup
	 */
	private map<String,Contact> mapSearchableContacts {
		get{
			if (mapSearchableContacts==null) {
				mapSearchableContacts = new Map<String,Contact>();
				for (Contact contact:
					[SELECT id, Name, Email, Phone, MITA_Contact_Type__c, MITA_Contact__c, Title, Account.Name
					FROM Contact
					WHERE Recordtype.Developername = 'Standard_Contact'
					AND Status__c = 'Active'
					AND MITA_Contact__c = false
					AND (AccountId = :this.account.Id OR Account.Top_Parent__c = :this.account.Id)
					ORDER BY Name ASC
					LIMIT 1000]) {
						mapSearchableContacts.put(contact.Name, contact);
				}
			}
			return mapSearchableContacts;
		}
		private set;
	}

	/**
	 * Get map keys sorted to be used in the input search as suggested inputs
	 */
	public list<String> searchableContactOptions {
		get{
			if (searchableContactOptions==null) {
				searchableContactOptions = new list<String>(mapSearchableContacts.keyset());
				searchableContactOptions.sort();
			}
			return searchableContactOptions;
		}
		private set;
	}

	/**
	 * COMMON MODAL VARS
	 */
	public Contact selectedContact {get;set;}
	//Var to handle the Mita contact types in checkboxes
	public list<MITAOptionWrapper> MITAContactOptionWrappers {get;set;}
	public class MITAOptionWrapper {
		public String label {get;set;}
		public Boolean checked {get;set;}
	}

	/**
	 * Reset Mita contact types
	 */
	public void resetMITAContactOptionWrappers() {
		this.MITAContactOptionWrappers = new list<MITAOptionWrapper>();
		for (String type: IA_util.LIST_MITA_CONTACTS) {
			MITAOptionWrapper option = new MITAOptionWrapper();
			option.label = type;
			if (this.selectedContact==null) {
				option.checked = false;
			} else {
				String types = this.selectedContact.MITA_Contact_Type__c;
				option.checked = types!=null && types.contains(type);
			}
			this.MITAContactOptionWrappers.add(option);
		}
	}

	/**
	 * Transform Mita contact types list into a String (; separated) to be used in a multipicklist field
	 */
	public String getMITAContactFieldValue() {
		List<String> result = new List<String>();
		for (MITAOptionWrapper wrapper: this.MITAContactOptionWrappers) {
			if (wrapper.checked) {
				result.add(wrapper.label);
			}
		}
		return String.join(result,';');
	}

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
		this.mapSearchableContacts = null;
		this.searchableContactOptions = null;
		resetMITAContactOptionWrappers();
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
		// if the search key is not in the preselected contact try to find it
		if (this.selectedContact==null) {
			list<Contact> listContact =
				[SELECT id, Name, Email, Phone, MITA_Contact_Type__c, MITA_Contact__c, Title, Account.Name
				FROM Contact
				WHERE Recordtype.Developername = 'Standard_Contact'
				AND Status__c = 'Active'
				AND MITA_Contact__c = false
				AND (AccountId = :this.account.Id OR Account.Top_Parent__c = :this.account.Id)
				AND (Name = :this.selectedContactSearchKey OR Email = :this.selectedContactSearchKey)
				LIMIT 1];
			this.selectedContact = listContact.isEmpty()? null: listContact[0];
		}
		this.showSearchedContact = (this.selectedContact!=null);
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
			this.selectedContact.MITA_Contact__c = false;
			this.selectedContact.MITA_Contact_Type__c = '';
		} else {
			this.selectedContact = this.mapContacts.get(IA_util.decrypt(EncDecKey,this.selectedContactId));
			if (this.selectedContact==null) return;
		}

		this.showModalContact = true;
		this.alertModal = null;
		resetMITAContactOptionWrappers();
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
			this.selectedContact.MITA_Contact_Type__c = getMITAContactFieldValue();
			this.selectedContact.MITA_Contact__c = String.isNotBlank(this.selectedContact.MITA_Contact_Type__c);

			Database.SaveResult result = Database.update(this.selectedContact,false);
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
		this.selectedContact = this.mapContacts.get(IA_util.decrypt(EncDecKey,this.selectedContactId));
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
	 * This removes the contact from the list, but it is not actually removed from database
	 * Only set the field MITA_Contact__c to false and empries the MITA_Contact_Type__c
	 */
	public void deleteContact(){
		if(!this.hasEditContactsPermission || this.selectedContact==null) return;

		try {
			this.selectedContact.MITA_Contact__c = false;
			this.selectedContact.MITA_Contact_Type__c = '';
			Database.SaveResult result = Database.update(this.selectedContact,false);
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
}