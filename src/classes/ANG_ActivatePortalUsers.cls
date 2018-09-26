public class ANG_ActivatePortalUsers {
	
	public static void activate(list<Contact> listNews){
		system.debug('ANG_ActivatePortalUsers activate insert');
		if(AMS_Utils.runningContactInsertUpdateFromOSCAR)
			activateUsers(listNews, null);
	}

	public static void activate(list<Contact> listNews, list<Contact> listOlds){
		system.debug('ANG_ActivatePortalUsers activate update');
		if(AMS_Utils.runningContactInsertUpdateFromOSCAR)
			activateUsers(listNews, listOlds);
	}

	/*
		When inserting a contact that is portal admin we should activate it
		On updates only activate the portal user if it's going from false to true
	*/
	public static void activateUsers(list<Contact> listNews, list<Contact> listOlds){
		
		system.debug('ANG_ActivatePortalUsers activateUsers');

		List<Contact> contactsToActivatePortalUser = new List<Contact>();

		for (Integer i = 0; i<listNews.size(); i++) {
			if(Trigger.isInsert && listNews[i].Designated_Portal_Admin__c){
				contactsToActivatePortalUser.add(listNews[i]);
			}else if(Trigger.isUpdate && listNews[i].Designated_Portal_Admin__c && !listOlds[i].Designated_Portal_Admin__c){
				contactsToActivatePortalUser.add(listNews[i]);
			}
		}

		system.debug('ANG_ActivatePortalUsers contactsToActivatePortalUser ' + contactsToActivatePortalUser);
		ANG_ActivatePortalUsersBatch b = new ANG_ActivatePortalUsersBatch(contactsToActivatePortalUser);
        database.executebatch(b,1);

	}

}