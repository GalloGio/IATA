/**
 * This class handle notificaitons for contacts.
 * Created By:  Niv.Goldenberg 19-11-2014
 * Modified By: Tiago.Ferreira 12-12-2014
 * Modified By: Niv.Goldenberg 13-12-2014
 */
public class ISSP_NotificationUtilities 
{
    /**
     * [
     * Send notification to list of contact
     * ]
     * @param lstContacts           [List of contacts to send notificaiton to]
     * @param notificationTemplate  [Template of the notification holds the main message format: Hello {0}, how are you {1}]
     * @param MessagesByGroupMap    [A map which give the possibility to give different contacts different messages 
     *                               'grouped by contact specific field name', 
     *                               which is the contactGroupField parameter, for example:
     *                               If we want to give contacts of account with id 1 a message A, 
     *                               and to contacts of account with id 2 a message B, 
     *                               the map will look like this: 1-->A, 2-->B, and the contactGroupField will be AccountId]
     * @param contactGroupField     [Field which grouped the messages for contact, as described above]
     * Created By:  Niv.Goldenberg 19-11-2014
     * Modified By: Tiago.Ferreira 12-12-2014
     * Modified By: Niv.Goldenberg 13-12-2014
     */
	public static void sendNotification(List<Contact> lstContacts, Notification_template__c notificationTemplate, 
                                        Map<String, String> messagesByGroupMap, String contactGroupField)
	{
		List<Id> lstContactIds = new List<Id>();
		for (Contact con : lstContacts)
		{
			lstContactIds.add(con.Id);
		}

        if (!lstContactIds.isEmpty())
        {
    		String inList = generateInListForDynamicQuery(lstContactIds);
            
            String queryString = 'SELECT ' + String.join(ISSP_NotificationUtilities.getAllContactFields(), ',') + ' FROM Contact WHERE Id IN ' + inList;
            List<Contact> contactList = Database.query(queryString);
            ISSP_NotificationUtilities.insertNotifications(contactList, notificationTemplate, messagesByGroupMap, contactGroupField);

        }
	}

    /**
     * [Insert Notifications by contacts]
     * @param lstContacts           [List of contacts to send notificaiton to]
     * @param notificationTemplate  [Template of the notification holds the main message format: Hello {0}, how are you {1}]
     * @param MessagesByGroupMap    [A map which give the possibility to give different contacts different messages 
     *                               'grouped by contact specific field name', 
     *                               which is the contactGroupField parameter, for example:
     *                               If we want to give contacts of account with id 1 a message A, 
     *                               and to contacts of account with id 2 a message B, 
     *                               the map will look like this: 1-->A, 2-->B, and the contactGroupField will be AccountId]
     * @param contactGroupField     [Field which grouped the messages for contact, as described above]
     * Created By:  Niv.Goldenberg 13-12-2014
     * Modified By: Niv.Goldenberg 13-12-2014
     */
    public static void insertNotifications(List<Contact> lstContacts, Notification_template__c notificationTemplate, 
                                        Map<String, String> messagesByGroupMap, String contactGroupField)
    {
        List<Notification__c> lstNotifications = new List<Notification__c>();
        for (Contact con : lstContacts)
        {
            Notification_template__c selectedTemplate = findLanguageTemplate(con, notificationTemplate);
            
            //Set default message by notification template message.
            String message = selectedTemplate != null ? selectedTemplate.Message__c : '';

            //Check if there is a message by group field, if there is set is as the curreny message.
            if (contactGroupField != null && contactGroupField != '')
            {
                String key = String.valueOf(con.get(contactGroupField));
                if (messagesByGroupMap !=null && messagesByGroupMap.containsKey(key))
                {
                    message = messagesByGroupMap.get(key) != null ? messagesByGroupMap.get(key) : message;
                }
            }
			
			DateTime expirationDate = null;
			if (selectedTemplate.Expire_in_days__c != null){
        		expirationDate = system.Now() + selectedTemplate.Expire_in_days__c;
        	}
            
            
			
            //Create notification and add it the list of notifications to be sent.
            lstNotifications.add( 
                new Notification__c(
                contact__c = con.Id,
                Message__c = message,
                Alert_Contact_By_Email__c = selectedTemplate.Alert_Contact_By_Email__c,
                Subject__c = selectedTemplate.Subject__c,
                Type__c = selectedTemplate.Type__c,
                Notificatin_color__c = selectedTemplate.Notification_color__c ,
                Notification_Campagne_Name__c = null,
                Critical_notification__c = selectedTemplate.CriticalNotification__c,
                Expiry_Date__c = expirationDate
            ));
        }
        
        if (!lstNotifications.isEmpty())
        {
            System.debug('CREATING NOTIFICATIONS: ' + lstNotifications.size());
            insert lstNotifications;
        }
    }
    
    /**
        Finds a template in the related templates list(if it exists) with the same 
        language as the input contact.
        Otherwise the same input template is returned
    **/
    private static Notification_template__c findLanguageTemplate(Contact contact, Notification_template__c template) {
        if (template.Language__c == contact.Preferred_Language__c || template.Notification_templates__r == null) {
            return template;
        }
        for (Notification_template__c languageTemplate: template.Notification_templates__r) {
            if (languageTemplate.Language__c == contact.Preferred_Language__c) {
                return languageTemplate;
            }
        }
        return template;
    }

    /**
     * [
     * Get all contact fields by schema meta data of contact
     * ]
     * @return [List of api name fields of contact]
     * Created By:  Niv.Goldenberg 19-11-2014
     * Modified By: Niv.Goldenberg 20-11-2014
     */
    public static List<String> getAllContactFields()
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Contact.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        List<String> allContactFields = new List<String>();
        for(Schema.SObjectField s : fldObjMapValues)
        {
            allContactFields.add(s.getDescribe().getName());
        }

        return allContactFields;
    }

    /**
     * [
     * build In list dynamically.
     * ]
     * @param  lstObj  [Objects to build as In list]
     * @return         [In list format]
     * Created By:  Niv.Goldenberg 19-11-2014
     * Modified By: Niv.Goldenberg 20-11-2014
     */
    public static String generateInListForDynamicQuery(List<Object> lstObj)
    {
        if (lstObj == null || lstObj.isEmpty())
        {
            return '()';
        }

        String query='(';
        Boolean first = true;
        for(Object obj : lstObj)
        {
            if (!first)
            {
                query += ',';
            }
            else
            {
                first = false;
            }
            query += '\'' + obj + '\'';
        }

        query += ')';
        return query;
    } 
}