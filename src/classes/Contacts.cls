public with sharing class Contacts {
	// the values of the Status__c picklist field
	public enum Status {ACTIVE, LEFTCOMPANYRELOCATED, RETIRED, INACTIVE}
	// the values of Status field in a Map to enable map functions e.g. .contains(String)
	public Map<String, Status> statusValueMap { get; private set; }

	public List<Contact> records { get; private set; }

	public Contacts(){
		records = new List<Contact>();
		initialise();
	}
	
	public Contacts(List<Contact> contactList){
		records = contactList.clone();
		initialise();
	}
		
	// perform any domain class initialisation logic
	private void initialise(){
		statusValueMap = new Map<String, Status>();
		//populate statusValueMap
		for(Status status : Status.values()){
			statusValueMap.put(status.name(), status);
		}
	}
	
	public List<Contact> updateStatus(String statusValue){
		if(!statusValueMap.containsKey(statusValue))
			throw new ContactDomainException('Invalid Status value provided');

		for (Contact record : records){
			record.Status__c = statusValue;
		}
		return records;
	}

	// public void onAfterInsert(){
	// }
	// public void onAfterUpdate(){
	// }
	// public void onAfterDelete(){
	// }
	// public void onAfterUndelete(){
	// }
	
	// public void onBeforeInsert(){
	// }
	// public void onBeforeDelete(){
	// }
	
	//return a 'default' Contact record (ONLY USED TO DEFAULT AND RETURN MANDATORY FIELDS)
	public List<Contact> createDefaultContact(Integer numberOfRecords){
		for(Integer x = 0; x < numberOfRecords; x++){
			Contact contact = (Contact) Schema.getGlobalDescribe().get('Contact').newSObject();
			contact.LastName = TestDataFactory_Contacts.DEFAULTLASTNAME + x;
			contact.Email = TestDataFactory_Contacts.DEFAULTEMAIL + x;
			records.add(contact);
		}
		return records;
	}

	public class ContactDomainException extends Exception {}
}