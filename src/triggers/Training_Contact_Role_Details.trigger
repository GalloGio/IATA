trigger Training_Contact_Role_Details on Training_Contact_Role_Details__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    //Trigger the platform events
    if(trigger.isAfter)
        PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'Training_Contact_Role_Detail__e', 'Training_Contact_Role_Details__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);

    //Update User record with lms User Id
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
        Set<Id> acrIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Training_Contact_Role_Details__c> toUpdate = new Map<Id,Training_Contact_Role_Details__c>(); 
        Map<Id,Id> acr_vs_contact = new Map<Id,Id>(); 

        for(Training_Contact_Role_Details__c  tcrd : Trigger.new){
            if(tcrd.UserId__c!=null && tcrd.UserId__c != '' && trigger.oldMap.get(tcrd.Id).UserId__c != tcrd.UserId__c){
                // ag.Cass_Number__c = AMS_AgencyHelper.resizeNumericString(ag.Cass_Number__c,3);
                acrIds.add(tcrd.Account_Contact_Role__c);
                toUpdate.put(tcrd.Account_Contact_Role__c, tcrd);
            }
        }
        
        List<Account_Contact_Role__c> listACR = [SELECT Id, Contact__c FROM Account_Contact_Role__c WHERE Id in :acrIds];

        for(Account_Contact_Role__c  acr : listACR){
            contactIds.add(acr.Contact__c);
            acr_vs_contact.put(acr.Contact__c, acr.Id);
        }
        
        List<User> lUsers = [SELECT Id, ContactId, Yardstick_UserId__c FROM User WHERE ContactId in :contactIds];

        for(User u : lUsers){
            Id  acrID =  acr_vs_contact.get(u.ContactId);
            Training_Contact_Role_Details__c trcd2 = toUpdate.get(acrID);
            u.Yardstick_UserId__c = trcd2.UserId__c;
        }

        update lUsers;
    }
    
}