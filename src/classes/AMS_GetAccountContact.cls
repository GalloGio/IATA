global class AMS_GetAccountContact {
	
	@InvocableMethod(label = 'Get Contacts')
	public static List<Contact> getContactId(List<Id> accountIds) {
		Id accountId = accountIds[0];
		Account account = [SELECT Id, Top_Parent__c, Location_Type__c FROM Account WHERE Id = :accountId];
		
		Set<Id> accounts = new Set<Id>();
		accounts.add(accountId);

		if(account.Location_Type__c != 'HO' && account.Location_Type__c != 'AO') {
			accounts.add(account.Top_Parent__c);
		}

		List<Contact> contacts = [SELECT Id, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c
								  FROM Contact
								  WHERE AccountId IN :accounts AND IsEmailBounced = false AND 
								  (BSP_CASS_Payment_contact__c = true OR Financial_Assessment_Contact__c = true OR User_Portal_Status__c = 'Approved Admin')];

		Id contactId;
		for(Contact c : contacts) {
			if(c.User_Portal_Status__c == 'Approved Admin') {
				contactId = c.Id;
				break;
			}

			contactId = c.Id;
		}

		return new List<Contact> {new Contact(Id= contactId)};
	}

}