global class AMS_GetAccountContact {
	
	@InvocableMethod(label = 'Get Contacts')
	public static List<Contact> getContactId(List<Id> accountIds) {
		Id accountIdBR = accountIds[0];
		List<Contact> contactsBR = getContacts(accountIdBR);

		Map<String, List<Contact>> mapContacts = new Map<String, List<Contact>>();
		List<Contact> appLst = new List<Contact>();
		List<Contact> finLst = new List<Contact>();
		List<Contact> bspLst = new List<Contact>();
		mapContacts.put('Approved Admin', appLst);
		mapContacts.put('Financial contact', finLst);
		mapContacts.put('BSP Cass contact', bspLst);
		Boolean needsHOContacts = populateMapContacts(contactsBR, mapContacts);

		if(needsHOContacts) {
			Account accountBR = [SELECT Id, Top_Parent__c, Location_Type__c FROM Account WHERE Id = :accountIdBR];
			if(accountBR.Location_Type__c != 'HO' && accountBR.Location_Type__c != 'AO') {
				List<Contact> contactsHO = getContacts(accountBR.Top_Parent__c);
				populateMapContacts(contactsHO, mapContacts);
			}
		}
		
		if(!appLst.isEmpty()) {
			return new List<Contact> {new Contact(Id= appLst[0].Id)};
		} else if(!finLst.isEmpty()) {
			return new List<Contact> {new Contact(Id= finLst[0].Id)};
		} else if(!bspLst.isEmpty()) {
			return new List<Contact> {new Contact(Id= bspLst[0].Id)};
		} else {
			return null;
		}
	}

	private static List<Contact> getContacts(Id accountId) {
		return [SELECT Id, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c
			  	FROM Contact
			  	WHERE AccountId = :accountId AND IsEmailBounced = false AND 
			  	(BSP_CASS_Payment_contact__c = true OR Financial_Assessment_Contact__c = true OR User_Portal_Status__c = 'Approved Admin')];
	}

	//Returns true if all the map lists are empty
	private static Boolean populateMapContacts(List<Contact> contacts, Map<String, List<Contact>> mapContacts) {
		List<Contact> appLst = mapContacts.get('Approved Admin');
		List<Contact> finLst = mapContacts.get('Financial contact');
		List<Contact> bspLst = mapContacts.get('BSP Cass contact');
		for(Contact c : contacts) {
			if(c.User_Portal_Status__c == 'Approved Admin') {
				appLst.add(c);
			}

			if(c.Financial_Assessment_Contact__c) {
				finLst.add(c);
			}

			if(c.BSP_CASS_Payment_contact__c) {
				bspLst.add(c);
			}
		}
		return appLst.isEmpty() && finLst.isEmpty() && bspLst.isEmpty();
	}

}