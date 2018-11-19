trigger trgGDPContact_BeforeDelete on Contact (Before delete) {
    
    // Get Id of  the GDP Contact Record Type
    ID gdpContactRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'GDP_Contact');
    
    // Get Id of  the Standard Contact Record Type
    ID standardContactRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
    
    // Get the list of Profiles that have deletion rights on contacts when the record type is equal to GDP Contact
    List<Profile> profiles = [SELECT Name, Id FROM Profile WHERE  Name = 'GDP - Administrator' OR Name = 'System Administrator' ORDER BY Name DESC];
    
    for (Contact c : trigger.old){
        if (c.RecordTypeID == gdpContactRecordTypeID){
            if (UserInfo.getProfileId() != profiles[0].Id && UserInfo.getProfileId() != profiles[1].Id){
                c.addError('GDP Contact cannot be deleted');
            }
        }
    }
    
    //Create list of contacts and their ID Cards
    List<Contact> contacts = [SELECT Id, VER_Number__c, RecordTypeId, (SELECT Id, Related_Contact__c from ID_Cards__r) from Contact 
                              WHERE Id in : Trigger.oldMap.keySet()];
    // add error message for each deletion of ID Card Contact
    for (Contact c : contacts){
        if( UserInfo.getProfileId() != profiles[0].Id && ((c.ID_Cards__r.size()>0) || (c.VER_Number__c != null && c.RecordTypeId == standardContactRecordTypeID))){ 
            Contact actualRecord = Trigger.oldMap.get(c.Id); 
            actualRecord.adderror('You cannot delete or merge this contact. This contact has an IATA/IATAN Travel Agent ID Card.');
        } 
    }    
}