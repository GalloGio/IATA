public class AMS_PersonHelper {

	public static void updateContactInfo(Set<ID> contactIDS){
		List<Contact> cts = [select id, email,phone, MobilePhone, Fax, Person__r.Email__c, Person__r.Phone__c, Person__r.DOB__c, Person__r.Mobile__c, Person__r.Fax__c from contact where Id in :contactIDS];
		for(Contact c:cts){

			c.email = c.Person__r.Email__c; //trigger.newMap.get(personPerContact.get(c.id)).Email__c;#AMSFTS
			c.phone  = c.Person__r.Phone__c;//trigger.newMap.get(personPerContact.get(c.id)).Phone__c;#AMSFTS
			c.Birthdate= c.Person__r.DOB__c;//trigger.newMap.get(personPerContact.get(c.id)).DOB__c;#AMSFTS
			c.MobilePhone= c.Person__r.Mobile__c;//trigger.newMap.get(personPerContact.get(c.id)).Mobile__c;#AMSFTS
			c.Fax= c.Person__r.Fax__c;//trigger.newMap.get(personPerContact.get(c.id)).Fax__c;#AMSFTS

		}
		update cts;
	}
/*
	public static void Ensure0to1ContactLookup(list<AMS_Person__c> persons){
		Map<Id,AMS_Person__c> contactIdToPerson = new Map<Id,AMS_Person__c>();

		for(AMS_Person__c p : persons){
			if(p.Contact__c!=null){
				if(contactIdToPerson.get(p.Contact__c)!=null){
					p.addError('There is already an Person related to this Contact');
					continue;
				}
				contactIdToPerson.put(p.Contact__c,p);
			}
		}

		List<AMS_Person__c> alreadyRelated = [SELECT Id, Contact__c FROM AMS_Person__c WHERE Contact__c IN :contactIdToPerson.keySet()];
		for(AMS_Person__c p : alreadyRelated){
			AMS_Person__c newP = contactIdToPerson.get(p.Contact__c);
			newP.addError('There is already an Person related to this Contact');
		}

		return;
	}


	public static void addContactIfEmpty (list<AMS_Person__c> persons){
		Map<String,Contact> AccountAndNameToContact = new Map<String,Contact>();
		Set<String> LastNames = new Set<String>();
		Set<ID> AgencyIDs = new Set<ID>();
		Map<ID,ID> AgencyToAccount = new Map<ID,ID>();


		for(AMS_Person__c p : persons){
			AgencyIDs.add(p.Agency__c);
			LastNames.add(p.Name);
		}

		// Retrieve the links Agency -> Account
		for(AMS_Agency__c agency : [SELECT Account__c FROM AMS_Agency__c WHERE ID IN :AgencyIDs])
			AgencyToAccount.put(agency.ID,agency.Account__c);


		// Look for existing Contacts
		for(Contact c : [SELECT AccountId, FirstName, LastName, Name, (SELECT Id FROM Contact.Persons__r)
						 FROM Contact
						 WHERE AccountId IN : AgencyToAccount.values()
						 AND LastName IN :LastNames]){
			AccountAndNameToContact.put(c.AccountId+'-'+c.FirstName+'-'+c.LastName, c);
		}



		// Try to match persons with existing contacts using AccountId-FirstName-LastName
		Map<Id,Contact> newContacts = new Map<Id,Contact>();
		for(AMS_Person__c p : persons){
			ID myAccount = AgencyToAccount.get(p.Agency__c);
			Contact theContact = AccountAndNameToContact.get(myAccount+'-'+p.Firstname__c+'-'+p.Name);

			if(theContact != null){
				p.Contact__c = theContact.ID;

				if(theContact.Persons__r.size()>0)
					p.addError('There is already an Person related to the Contact '+theContact.FirstName+' '+theContact.LastName);
			}

			if(p.Contact__c == null){
				newContacts.put(
					p.Id,
					new Contact(AccountId=myAccount, FirstName=p.Firstname__c, LastName=p.Name)
				);
			}
		}




		// If I needed to create new Contacts I'll insert them in DB and I'll reference them from the persons
		if(newContacts.size()>0){
			insert newContacts.values();
			for(AMS_Person__c p : persons){
				if(p.Contact__c == null)
					p.Contact__c = newContacts.get(p.ID).ID;
			}
		}

		return;
	}


	public static void EnsureMax1ManagerPerAgency(list<AMS_Person__c> persons){
		Map<Id,AMS_Person__c> agencyIdToPerson = new Map<Id,AMS_Person__c>();
		for(AMS_Person__c p : persons){
			if(agencyIdToPerson.get(p.Agency__c)!=null){
				p.addError('There is already a Manager Person related to this Agency');
				continue;
			}
			agencyIdToPerson.put(p.Agency__c,p);
		}

		List<AMS_Person__c> alreadyRelated = [SELECT Id, Contact__c FROM AMS_Person__c
												WHERE Agency__c IN :agencyIdToPerson.keySet()
												AND isManager__c = true];
		for(AMS_Person__c p : alreadyRelated){
			AMS_Person__c newP = agencyIdToPerson.get(p.Contact__c);
			newP.addError('There is already a Manager Person related to this Agency');
		}

		return;
	}
*/

}
