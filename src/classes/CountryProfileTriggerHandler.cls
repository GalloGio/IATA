public class CountryProfileTriggerHandler{

    public static final String CURRENCYCENTERAPPURL = '/ISSP_CurrencyCenterHome';

    public static boolean firstExec = true; 

    /*** HANDLE BEFORE UPDATE METHOD ***/
    public static void handleBeforeUpdate(Map<Id, Country_Profile__c> newItems, Map<Id, Country_Profile__c> oldItems){

        List<Country_Profile_History__c> historiesToInsert = new List<Country_Profile_History__c>();
        List<Country_Profile_History_Tracking__c> trackingCSList = new List<Country_Profile_History_Tracking__c>();
        Set<String> trackingFields = new Set<String>();


        trackingCSList = [SELECT Name FROM Country_Profile_History_Tracking__c];

        if(trackingCSList.size() > 0){

            for(Country_Profile_History_Tracking__c cs : trackingCSList){
                trackingFields.add(cs.Name);
            }
    
            /*** CHECK FOR CHANGES ON SELECTED FIELDS ***/
            for(Country_Profile__c newProfile : newItems.values()){
                Country_Profile__c oldProfile = oldItems.get(newProfile.Id);
    
                for(String field : trackingFields){
                    String oldValue;
                    String newValue;

                    //embed below into try/catch to prevent attempts of tracking non-existent fields
                    try{
                        oldValue = (String.valueOf(oldProfile.get(field)));
                        newValue = (String.valueOf(newProfile.get(field)));
                    } catch (Exception e){
                        // if error caught just ignore the field, set it as null
                        oldValue = null;
                        newValue = null;
                    }

                    //check if not null to avoid errors from String functions
                    if(oldValue != null){
                        //replace <li> with <br> to have line breaks on lists
                        oldValue = oldValue.replaceAll('<li>','<br>');
                        //remove double spaces
                        oldValue = oldValue.normalizeSpace();
                        //remove html tags
                        oldValue = oldValue.stripHtmlTags();
                        //remove preceding and succeeding spaces left after striping html
                        oldValue = oldValue.trim();
                    }
                    //check if not null to avoid errors from String functions
                    if(newValue != null){
                        //replace <li> with <br> to have line breaks on lists
                        newValue = newValue.replaceAll('<li>','<br>');
                        //remove double spaces
                        newValue = newValue.normalizeSpace();
                        //remove html tags
                        newValue = newValue.stripHtmlTags();
                        //remove preceding and succeeding spaces left after striping html
                        newValue = newValue.trim();
                    }
    
                    //compare plain values
                    if(oldValue != newValue){
                        system.debug('***oldValue: '+oldValue);
                        system.debug('***newValue: '+newValue);
                        Country_Profile_History__c countryProfileHistory = createHistoryRecord(field, oldProfile.Id, newValue, oldValue);
                        historiesToInsert.add(countryProfileHistory);
                    }
                }
            }
    
            /*** INSERT HISTORY RECORDS ***/
            insert(historiesToInsert);

        }

        
        // Validate the publish news / send notifications instructions
        /*
        for(Country_Profile__c newProfile : newItems.values()){
            // NEWS 
            if(newProfile.Publish_News__c == 'Yes'){
                // we need to do custom validation rather than validation rule, as the fields will be emptied before saving...
                if(newProfile.News_Text__c == null)
                    newProfile.addError('You cannot broadcast an empty message. Please fill "News Text" or switch "Publish News?" to "No".');
            }

            // NOTIFICATIONS 
            if (newProfile.Send_Notifications__c == 'Yes') {
                if(newProfile.Notification_Message__c == null)
                    newProfile.addError('You cannot send an empty notification. Please fill in the Notification Message or switch "Send Notifications?"" to "No".');
            }
        }*/
    }

    /*  PUBLISH THE UPDATE FEEDS AND SEND NOTIFICATIONS 
     *  to be run in AFTER Update and AFTER Insert
     */
    public static void CreateUpdateFeedsSendNotifications(Map<Id, Country_Profile__c> newItems) {
        List<Comment__c> newsToInsert = new List<Comment__c>();

        map<Id, String> mapNotificationsPerCountryProfileId = new map<Id, String>();
        List<Notification__c> lstNotificationsToInsert = new List<Notification__c>();

        Id newsRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Comment__c', 'Country_Profile_News');
        // We need to do another loop as it's independent from history, and will be executed even if there are no changes to other fields.
        for(Country_Profile__c newProfile : newItems.values()){
            /* NEWS Update */
            if(newProfile.Publish_News__c == 'Yes'){
                // validation for empty text already done in BEFORE trigger
                if(newProfile.News_Text__c == null)
                    newProfile.addError('You cannot broadcast an empty message. Please fill "News Text" or switch "Publish News?" to "No".');
                newsToInsert.add(new Comment__c(ICCS_Country_Profile__c = newProfile.Id, Detail__c = newProfile.News_Text__c, RecordTypeId = newsRtId));
            }

            /* SEND NOTIFICATIONS */
            if (newProfile.Send_Notifications__c == 'Yes') {
                // validation for empty text already done in BEFORE trigger
                if(newProfile.Notification_Message__c == null)
                    newProfile.addError('You cannot send an empty notification. Please fill in the Notification Message or switch "Send Notifications?"" to "No".');
                mapNotificationsPerCountryProfileId.put(newProfile.Id, newProfile.Notification_Message__c);
            }
        }

        /*** INSERT NEWS ***/
        insert(newsToInsert);

        /* Handle the sending of notifications */
        if (!mapNotificationsPerCountryProfileId.isEmpty()) {
            // Get the community Id
            Id communityId = [SELECT Id FROM Network WHERE Name = 'IATA Portal'].Id;

            map<Id, list<Id>> mapSubscribedContactsPerCountryProfile = new  map<Id, list<Id>>();
            for (EntitySubscription es : [SELECT Id, Subscriber.ContactId, ParentId FROM EntitySubscription WHERE ParentId IN :mapNotificationsPerCountryProfileId.keyset() AND NetworkId = :communityId]) {
                if (es.Subscriber.ContactId != null) {
                    if (mapSubscribedContactsPerCountryProfile.get(es.ParentId) != null) {
                        mapSubscribedContactsPerCountryProfile.get(es.ParentId).add(es.Subscriber.ContactId);
                    } else {
                        mapSubscribedContactsPerCountryProfile.put(es.ParentId, new list<Id>{es.Subscriber.ContactId});
                    }
                }
            }

            if (!mapSubscribedContactsPerCountryProfile.isEmpty()) {
                for (Id countryProfileId : mapSubscribedContactsPerCountryProfile.keyset()) 
                    for (Id contactId : mapSubscribedContactsPerCountryProfile.get(countryProfileId)) {
                        Notification__c notification = new Notification__c();
                        notification.Contact__c = contactId;
                        notification.Subject__c = 'Currency Center ' + newItems.get(countryProfileId).Name + ' Update';
                        notification.Message__c = mapNotificationsPerCountryProfileId.get(countryProfileId) + '<p><a href="/ISSP_CurrencyCenterCountry?Id=' + countryProfileId + '">Click here to access the country profile</a></p>';
                        notification.Type__c= 'Information';
                        notification.Notificatin_color__c = '#007FFF';
                        notification.Alert_Contact_By_Email__c = true;
                        notification.Expiry_date__c = Datetime.now().addDays(14);
                        
                        lstNotificationsToInsert.add(notification);
                    }
            }
        }

        insert lstNotificationsToInsert;
    }


    /*** Automatically subscribe the existing users to the new Country Profile records***/
    public static void SubscribeUsersToNewCountryProfile(Map<Id, Country_Profile__c> newItems){
        list<EntitySubscription> lstUserSubscriptions = new list<EntitySubscription>();
        set<Id> setRelatedContactIds = new set<Id>();

        Portal_Applications__c pa;

        // Get application ID --- cannot get it directly in the Portal_application_right query below because it makes the query non-selective
        try {
            pa = [SELECT Id FROM Portal_Applications__c WHERE Application_URL__c = :CURRENCYCENTERAPPURL LIMIT 1];
        } catch (Exception e) {
            system.debug('Error getting the Currency Center service Id - not found !');
            return;
        }

        // Get contacts that can access the service
        for (Portal_Application_Right__c par : [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE Portal_Application__c = :pa.Id AND Right__c = 'Access Granted']) {
            setRelatedContactIds.add(par.Contact__c);
        }

        if (!setRelatedContactIds.isEmpty()) {
            // Get the actual user IDs
            list<Id> lstRelatedUserIds = new list<Id>();
            for (User usr : [SELECT Id, ContactId FROM User WHERE IsActive = True AND ContactId <> null AND ContactId IN :setRelatedContactIds]) {
                lstRelatedUserIds.add(usr.Id);
            }

            // Get the community Id
            Id communityId = [SELECT Id FROM Network WHERE Name = 'IATA Portal'].Id;

            // Create the chatter subscription records
            for (Id userId : lstRelatedUserIds) {
                for (Country_Profile__c cp : newItems.values()) {
                    EntitySubscription newSubscription = new EntitySubscription(SubscriberId = userId, ParentId = cp.Id, NetworkId = communityId);
                    lstUserSubscriptions.add(newSubscription);
                }
            }

            // Insert the records. Will fail if Chatter Feeds has not been previously activated on the Country Profile object
            insert lstUserSubscriptions;
        }
    }

    /*** Populate ISO Code on Country Profile from parent record ***/
    public static void PopulateIsoCode(List<Country_Profile__c> triggerNew){
        Set<Id> isoCountries = new Set<Id>();

        for(Country_Profile__c cp : triggerNew){
            isoCountries.add(cp.Country_Name__c);
        }

        Map<Id,IATA_ISO_Country__c> parentAccounts = new Map<Id,IATA_ISO_Country__c>(IATAIsoCountryDAO.getIsoCountriesByIds(isoCountries));

        for (Country_Profile__c cp : triggerNew){
            IATA_ISO_Country__c parentAccount = parentAccounts.get(cp.Country_Name__c);
            if (parentAccount != NULL && parentAccount.ISO_Code__c != NULL){
                cp.ISO_Code__c = parentAccount.ISO_Code__c;
            } else {
                cp.ISO_Code__c = '';
            }
        }

    }

    /*** UTIL METHODS ***/
    public static Country_Profile_History__c createHistoryRecord(String fieldName, String id, String newV, String oldV) {
        Country_Profile_History__c historyObj = new Country_Profile_History__c();
        historyObj.Country_Profile__c = id;
        historyObj.Field__c = fieldName;
        historyObj.NewValue__c = newV;
        historyObj.OldValue__c = oldV;
        return historyObj;
    }

}