/**
 * This class handle the trigger logic of after account update,
 * The main logic checks for the following terms:
 * oldAcc.Accumulated_Irregularities__c != newAcc.Accumulated_Irregularities__c
 * AND mapRecordTypeNamesById.get(newAcc.RecordTypeId) = 'Agency' AND newAcc.Type = 'IATA Cargo Agent' .
 * If those terms are met a notification are sends to all contact of the account.
 * Created By:  Niv.Goldenberg 19-11-2014
 * Modified By: Niv.Goldenberg 20-11-2014
 */
public with sharing class ISSP_AccountTriggerHandler 
{
	public static Boolean preventTrigger = false; //The ability to prevent trigger if needed.

	/**
	 * [
	 * Main method called from trigger, and starts the process of sending notificaitons.  
 	 * ]
	 * @param oldAccountMap [Old accounts map from trigger]
	 * @param newAccountMap [New accounts map from trigger]
	 * Created By:  Niv.Goldenberg 19-11-2014
 	 * Modified By: Niv.Goldenberg 20-11-2014
	 */
	public static void onAfterUpdate(Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap)
	{
	    Set<Id> newAccountsIds = new Set<Id>();
		list<Portal_Application_Right__c> kaviList = [SELECT Id, Right__c, Contact__r.AccountId, Contact__r.Account.Field_Head_Office__c, Contact__r.Account.Location_Type__c, Contact__r.Account.ParentId, Contact__r.Account.Parent.ParentId
                                                	  FROM Portal_Application_Right__c
                                                	  WHERE ((Contact__r.Account.Field_Head_Office__c!='Branch' AND Contact__r.Account.ParentId=null AND Contact__r.AccountId in:newAccountMap.keySet())
                                                	  	OR (((Contact__r.Account.Field_Head_Office__c='Branch' OR Contact__r.Account.ParentId!=null) AND Contact__r.Account.Parent.ParentId=null) AND Contact__r.Account.ParentId in:newAccountMap.keySet())
                                                	   	OR (Contact__r.Account.ParentId!=null AND Contact__r.Account.Parent.ParentId!=null AND Contact__r.Account.Parent.ParentId in:newAccountMap.keySet()))
                                                	  AND Right__c = 'Access Granted'
                                                	  AND Portal_Application__r.Name LIKE 'Standards Setting Workspace%'];

        for(Portal_Application_Right__c par : kaviList){
        	String accId = par.Contact__r.AccountId;
        	if((par.Contact__r.Account.Field_Head_Office__c=='Branch' || par.Contact__r.Account.ParentId!=null) && par.Contact__r.Account.Parent.ParentId==null)
        		accId = par.Contact__r.Account.ParentId;
        	else if (par.Contact__r.Account.ParentId!=null && par.Contact__r.Account.Parent.ParentId!=null)
        		accId = par.Contact__r.Account.Parent.ParentId;
        	if(oldAccountMap.get(accId).Name != newAccountMap.get(accId).Name ||
        	   oldAccountMap.get(accId).Website != newAccountMap.get(accId).Website ||
        	   oldAccountMap.get(accId).Email__c != newAccountMap.get(accId).Email__c ||
        	   oldAccountMap.get(accId).BillingCity != newAccountMap.get(accId).BillingCity ||
        	   oldAccountMap.get(accId).Iso_State__c != newAccountMap.get(accId).Iso_State__c ||
        	   oldAccountMap.get(accId).IATA_ISO_Country__c != newAccountMap.get(accId).IATA_ISO_Country__c ||
        	   oldAccountMap.get(accId).BillingStreet != newAccountMap.get(accId).BillingStreet ||
        	   oldAccountMap.get(accId).BillingPostalCode != newAccountMap.get(accId).BillingPostalCode)

        	   newAccountsIds.add(accId);
        }

        if (newAccountsIds.size() > 0 && !System.isBatch())
        	ISSP_WS_KAVI.createOrUpdateKaviAccountsFuture(newAccountsIds);

		sendAccountNotifications(oldAccountMap, newAccountMap);
	}
    
    /**
     * [
     * This memeber checkes first (get) if custom settings ISSP_Notifications_Trigger__c with the Name='Account' is available,
     * if so it's takes it, otherwise returns null, then in the test class (ISSP_AccountTriggerHandlerTest) 
     * we set it for a fake data for testing.
     * ]
     * Created By:  Efraim Fligil 19-11-2014
 	 * Modified By: Niv.Goldenberg 20-11-2014
     */
    public static ISSP_Notifications_Trigger__c notificationsTrigger 
    {
        get
        {
            if(null == notificationsTrigger) 
            {
                if(!ISSP_Notifications_Trigger__c.getAll().isEmpty() && ISSP_Notifications_Trigger__c.getAll().containsKey('Account')) 
                {
                	notificationsTrigger = ISSP_Notifications_Trigger__c.getValues('Account');
                }
            }
            return notificationsTrigger;
        }
        set;
    }

	/**
	 * [
	 * This method checks if there are any relevant accounts to send notificaitons by their accounts.
	 * If relevant accounts are found, and notification is sent using the ISSP_NotificationUtilities.sendNotification
	 * which call a batch to handle massive notify of contacts. 
 	 * ]
	 * @param oldAccountMap [Old accounts map from trigger]
	 * @param newAccountMap [New accounts map from trigger]
	 * Created By:  Niv.Goldenberg 19-11-2014
 	 * Modified By: Niv.Goldenberg 20-11-2014
	 */
	private static void sendAccountNotifications(Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap)
	{
		Set<Id> setAccountsToNotify = getRelevantAccountIds(oldAccountMap, newAccountMap);
		system.debug('setAccountsToNotify: ' + setAccountsToNotify);
		system.debug('notificationsTrigger: ' + notificationsTrigger);
		if (!setAccountsToNotify.isEmpty())
		{
			if (null != notificationsTrigger)
			{
				ISSP_Notifications_Trigger__c cs = notificationsTrigger;
				List<Notification_template__c> lstNotificationTemplate = [SELECT Name, Message__c, Admins_Users__c, 
																		  Alert_Contact_By_Email__c, CriticalNotification__c, 
																		  Due_date__c, Expire_in_days__c, Language__c, 
																		  Master_Notification_template__c, Notification_color__c, 
																		  Subject__c, Type__c 
		                                    							  FROM Notification_template__c 
		                                    							  WHERE Id = :cs.Notification_Template_Id__c];
				system.debug('lstNotificationTemplate: ' + lstNotificationTemplate);
				if (!lstNotificationTemplate.isEmpty())
				{
					Notification_template__c notificationTemplate = lstNotificationTemplate[0];
			        String messageFormat = notificationTemplate.Message__c;

			        //Build fields for dynamic messaging by given account field set.
			        //cs.FieldSetAPIName__c holds the API Name of the field set which will show dynamically 
			        //as part of the notification message, for example:
					//Field Set: Name, Phone Number
					//Notification Message: Hello {0}, your phone number is: {1}
					//Message shown to user: Hello User, your phone number is: 123456789
					List<String> lstFields = new List<String>();
			        Schema.FieldSet fs = Schema.SObjectType.Account.fieldSets.getMap().get(cs.FieldSetAPIName__c);
			        for(Schema.FieldSetMember f : fs.getFields()) 
			        {
			            lstFields.add(f.getFieldPath());
			        }

					//Map contacts for each account by group field id.
					List<Contact> lstContacts = getRelevantContacts(setAccountsToNotify);
					Map<String, String> mapMessageByGroupField = getMapMessageByGroupField(lstFields, newAccountMap, lstContacts, messageFormat);

					if (!mapMessageByGroupField.isEmpty() && !lstContacts.isEmpty())
					{
				   		//send notification for each account contacs.
						ISSP_NotificationUtilities.sendNotification(lstContacts, notificationTemplate, mapMessageByGroupField, 'AccountId');
					}
				}
			}
		}
	}

	/**
	 * [
	 * Get relevant accounts by the following rule:
	 * oldAcc.Accumulated_Irregularities__c != newAcc.Accumulated_Irregularities__c
     * AND mapRecordTypeNamesById.get(newAcc.RecordTypeId) = 'Agency' AND newAcc.Type = 'IATA Cargo Agent'
     * ]
	 * @param oldAccountMap [Old accounts map from trigger]
	 * @param newAccountMap [New accounts map from trigger]
	 * @return				[Set of relevant account ids]
	 * Created By:  Niv.Goldenberg 19-11-2014
 	 * Modified By: Niv.Goldenberg 20-11-2014
	 */
	private static Set<Id> getRelevantAccountIds(Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap)
	{
		Set<Id> setAccountsToNotify = new Set<Id>();
		for (Id accId : oldAccountMap.keySet())
		{
			Account oldAcc = oldAccountMap.get(accId);
			Account newAcc = newAccountMap.get(accId);
			String newAccRname = RecordTypeSingleton.getInstance().getRecordTypeById('Account', newAcc.RecordTypeId).Name;
			if (oldAcc.Accumulated_Irregularities__c != newAcc.Accumulated_Irregularities__c
				&& newAccRname == 'Agency')// && newAcc.Type == 'IATA Cargo Agent')
			{
				setAccountsToNotify.add(accId);
			}
		}

		return setAccountsToNotify;
	}

	/**
	 * [
	 * Get relevant contact by given account ids
	 * ]
	 * @param  setAccountsToNotify [Account ids]
	 * @return                     [Relevant contacts by account ids]
	 * Created By:  Niv.Goldenberg 19-11-2014
 	 * Modified By: Niv.Goldenberg 20-11-2014
	 */
	private static List<Contact> getRelevantContacts(Set<Id> setAccountsToNotify){

	    String queryString = 'SELECT ' + String.join(ISSP_NotificationUtilities.getAllContactFields(), ',') 
	    + ' FROM Contact ' 
	    + ' WHERE AccountId IN :setAccountsToNotify '
	    + ' AND (User_Portal_Status__c = \'Approved Admin\' OR BSP_CASS_Payment_contact__c = true OR Financial_Assessment_Contact__c = true)';

	    return Database.query(queryString); 					
	}

	/**
	 * [
	 * getMapMessageByGroupField description
	 * ]
	 * @param  lstFields		[List of fields to get values from, for the message: Hello {val-0}, how are you {val-1}]
	 * @param  newAccountMap	[New accounts map from trigger]
	 * @param  lstContacts		[Contacts to send message for]
	 * @param  messageFormat	[Message format to send: Hello {0}, how are you {1}] 
	 * @return					[Map of messages by field which defines the gorup for each batch of messages]
	 * Created By:  Niv.Goldenberg 19-11-2014
 	 * Modified By: Niv.Goldenberg 20-11-2014
	 */
	private static Map<String, String> getMapMessageByGroupField(List<String> lstFields, Map<Id, Account> newAccountMap, List<Contact> lstContacts, String messageFormat)
	{
		//Map contacts for each account by group field id
   		Map<String, String> mapMessageByGroupField = new Map<String, String>();
   		for (Contact con : lstContacts)
   		{
			Account acc = newAccountMap.get(con.AccountId);
			List<String> lstFormatArgs = new List<String>();
			for (String fieldName : lstFields)
			{
				String fieldValue = acc.get(fieldName) != null ? String.valueOf(acc.get(fieldName)) : '';
				lstFormatArgs.add(fieldValue);
			}
			String accMessage = String.format(messageFormat, lstFormatArgs);

   			String key = String.valueOf(con.AccountId);
			mapMessageByGroupField.put(key, accMessage);
   		}

   		return mapMessageByGroupField;
	}
}