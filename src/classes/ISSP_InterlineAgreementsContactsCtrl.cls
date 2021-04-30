public without sharing class ISSP_InterlineAgreementsContactsCtrl {
	@testVisible
	private static Blob EncDecKey = Blob.valueOf('I@T@M!tAS3rvIc3!');

	public Account account {get;set;}
	public Boolean hasEditContactsPermission {get;set;}
	public MITAutil.AlertModal alertModal{get;set;}

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
					[SELECT id, Name, Email, Phone, MITA_Contact_Type__c, Title
					FROM Contact
					WHERE Recordtype.Developername = 'Standard_Contact'
					AND Status__c = 'Active'
					AND MITA_Contact_Type__c != null
					AND (AccountId = :this.account.Id OR Account.Top_Parent__c = :this.account.Id)
					ORDER BY Name ASC]
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
				//initialize filters
				//this.setFilterNames = new Set<String>();
				//this.setFilterTypes = new Set<String>();
				//this.setFilterStatus = new Set<String>();


				for(Contact contact : mapContacts.values()){
					contactRows.add(new ContactRow(contact));
	
					//store filters
					//this.setFilterNames.add(row.agreementName);
					//this.setFilterTypes.add(row.agreementType);
					//this.setFilterStatus.add(row.agreementStatus);
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
			this.contactId = MITAutil.Encrypt(EncDecKey,contact.Id);
			this.name = contact.Name;
			this.phone = contact.Phone;
			this.email = contact.Email;
			this.types = contact.MITA_Contact_Type__c.split(';');
			this.title = contact.Title;
		}
	}

	/***
	 * MODAL EDIT CONTACT
	 **/
	public String selectedContactId {get;set;}
	public Contact selectedContact {get;set;}
	public Boolean showModalContact {get;set;}

	/**
	 * Opens the modal to edit a contact
	 **/
	public void openModalContact() {
		this.selectedContact = this.mapContacts.get(MITAutil.Decrypt(EncDecKey,this.selectedContactId));
		if (this.selectedContact==null) return;

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
			Database.SaveResult result = Database.update(this.selectedContact);
			if (result.isSuccess()) {
				refreshPage();
				this.selectedContactId = null;
				this.alertModal = new MITAutil.AlertModal('successMsgNew','Contact updated','','');
			}
		} catch (Exception e) {
			this.alertModal = new MITAutil.AlertModal('errorMsg','','There was a problem saving the contact','');
		}
	}

	public void deleteContact(){
		if(!this.hasEditContactsPermission || this.selectedContact==null) return;

		this.selectedContact.MITA_Contact_Type__c = '';
		saveContact();
	}

	/**
	 * Clean the alert modal
	 */
	public void resetAlertModal() {
		this.alertModal = null;
	}
}