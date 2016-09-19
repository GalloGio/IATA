public class EF_ContactHandler {

	public static void handleAfterUpdate() {
        System.debug('#### CALLING METHOD');

		List<Contact> contactListNew = (List<Contact>) Trigger.new;

		Map<Id, Contact> contactMapNew = (Map<Id, Contact>) Trigger.newMap;
		Map<Id, Contact> contactMapOld = (Map<Id, Contact>) Trigger.oldMap;

		Map<id, String> contactMap = new Map<id, String>();

		for (Contact c : contactListNew) {
			if(contactMapOld != null && contactMapOld.containsKey(c.id)) {
				if (contactMapOld.get(c.id).EF_Status__c != contactMapNew.get(c.id).EF_Status__c) {
					contactMap.put(c.id, contactMapNew.get(c.id).EF_Status__c);
				}				
			} else {
				contactMap.put(c.id, contactMapNew.get(c.id).EF_Status__c);
			}
		}

        if(contactMap.size() != 0) {
            List<EF_Contact_Relationship__c> crList = [Select id, status__c, Contact__c From EF_Contact_Relationship__c Where Contact__c in :contactMap.keySet()];
    		
            if(crList.size() != null) {
                System.debug('#### the list was not null ' + crList.size());
                for (EF_Contact_Relationship__c cr : crList) {
                    cr.Status__c = contactMap.get(cr.Contact__c);
                }
                
                try{update crList; System.debug('#### normally updating the cr ');}catch(Exception e){System.debug('## [EF_ContactHandler.handleAfterUpdate]  error ' +e);}
            }
        }
	}	
}