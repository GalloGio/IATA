global class IDCard_RenewalReminder_Batch implements Database.Batchable<sObject> {


	global  list<Contact> ContactScope = new  list<Contact>();


	global list<Contact> start(Database.BatchableContext BC) {
		return ContactScope ;
	}

	//changes case status to Financial Security requested
	global void execute(Database.BatchableContext BC, list<Contact>  scope) {

		try {

			//Cleans the list in case a contact applied for a new IDCard
			//check if theres a new card in the process if so remove Contact from list
			List <Contact> toBeUpdated = new  list<Contact>();
			Integer nextYear = Date.Today().addYears(1).Year();
			Integer next2Year = Date.Today().addYears(2).Year();

			//create set of Ids to use in query
			Set<String> contactsEmails = new Set<String>();
			for (Contact c : scope) {
				contactsEmails.add(c.Email);
			}

			//create list of idcards already renewed
			ID_Card__c[] renewedIDCards = [Select Valid_To_Date__c, Email__c From ID_Card__c
										   where Email__c IN :contactsEmails and (Is_Active_Card__c = True OR Card_Status__c = 'Valid ID Card')
												   and Valid_To_Date__c > 2020-06-30];
												   System.debug('renewedIDCards: '+renewedIDCards);

			Case[] pendingCases = [Select Id, Contact.Email From Case where Contact.Email IN :contactsEmails and RecordType.Name = 'ID Card Application' and Status != 'Closed' limit 100];

			//create set of contacts that will be removed from renewal noticed if already have renewed their idcards or have pending idcard case
			Set<String> contactsIdstoIgnore = new Set<String>();
			for (ID_Card__c idc : renewedIDCards) {
				contactsIdstoIgnore.add(idc.Email__c);
			}

			for (Case cs : pendingCases) {
				contactsIdstoIgnore.add(cs.Contact.Email);
			}

			//if contact in scope is not included in the list of contacts to ignore we send the renewal
			for (Contact c : scope) {

				if (!contactsIdstoIgnore.contains(c.Email)) {
					c.SendIDCardRenewalNotice__c = true;
					toBeUpdated.add(c);
				}

			}
			Update toBeUpdated;

		}

		catch (Exception e) {
			System.debug(' IDCard_RenewalReminder_Batch  Error ' + e);
		}

	}

	global void finish(Database.BatchableContext BC) {
	}
}
