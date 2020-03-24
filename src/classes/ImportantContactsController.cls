public with sharing class ImportantContactsController {
	public Id AccountId {get; set;}
	public list<Contact> lstImportantContacts {
		get{
			if (AccountId != null) {
				list<Contact> lstTmpContacts = new list<Contact>();
				for (Contact c : [SELECT Id, FirstName, LastName, Email, Phone, Title, Membership_Function__c, Airline_Contact_Type__c FROM Contact WHERE AccountId = :AccountId AND Status__c = 'Active']) {
					if (c.Airline_Contact_Type__c != null && c.Airline_Contact_Type__c.trim() != '') {
						lstTmpContacts.add(c);
					}
				}

				return lstTmpContacts;
			} else {
				return new list<Contact>();
			}
		} set;}

	public ImportantContactsController (ApexPages.StandardController controller) {
		if (controller.getRecord().Id != null ) {
			AccountId = controller.getRecord().Id;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Account'));
			system.debug('Error: invalid account');
		}
	}
}
