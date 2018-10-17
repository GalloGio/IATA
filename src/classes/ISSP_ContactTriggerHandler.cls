public without sharing class ISSP_ContactTriggerHandler {

    public static void updateKaviIdOnUser(list<Contact> newContactList) {
        List<User> userKaviAdd = new List <User>();

        Map<String, ID> emailList = new Map<String, ID>();

        for(Contact oneContact: newContactList) {
            if(oneContact.Kavi_User__c != null){
                emailList.put(oneContact.Email, oneContact.id);   
            }
        }

        if(emailList.isEmpty()) return;

        for(User usr : [Select Id, Email, ContactKaviId__c From User where Email in :emailList.KeySet() and Is_Kavi_Internal_User__c = true]){
            usr.ContactKaviId__c = emailList.get(usr.email);
            userKaviAdd.add(usr);
        }

        if(!userKaviAdd.isEmpty())
            update userKaviAdd;   
    }
}