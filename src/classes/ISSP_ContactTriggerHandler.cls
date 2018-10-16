public without sharing class ISSP_ContactTriggerHandler {

    //public static Boolean preventTrigger = false;
    //public static Boolean preventOtherTrigger = false;
    public static void updateKaviIdOnUser(list<Contact> newContactList) {
    List <User> userKaviAdd = new List <User>();
    for(Contact oneContact: newContactList) {
            if(oneContact.Kavi_User__c != null)
              
            {
            	//User usr = [Select Id, Email, ContactKaviId__c From User where Email = :oneContact.Email and Profile_Name__c = 'KaviProvisioningUser' ][0];
                User usr = [Select Id, Email, ContactKaviId__c From User where Email = :oneContact.Email and Is_Kavi_Internal_User__c = true][0];
            	usr.ContactKaviId__c = oneContact.Id;
        		//System.debug('KIKE: El ID del usuario en Contact: ' + oneContact.Kavi_User__c);
            	//System.debug('KIKE: El Usuario asociado: ' + usr);
           		userKaviAdd.add(usr);}
            }
        
        update userKaviAdd;
    
}

}
