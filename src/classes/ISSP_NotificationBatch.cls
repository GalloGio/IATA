/**
 * This Batch handle notificaitons for contacts, we call it from:
 * ISSP_NotificationUtilities.sendNotification
 * Created By:  Niv.Goldenberg 19-11-2014
 * Modified By: Niv.Goldenberg 13-12-2014
 */
global class ISSP_NotificationBatch implements Database.Batchable<sObject> 
{
	
	global String Query; //Query for contacts.
	global Notification_template__c NotificationTemplate; //Template of the notification holds the main message format: Hello {0}, how are you {1}.
	
	/**
	 * A map which give the possibility to give different contacts different messages 
     *                               'grouped by contact specific field name', 
     *                               which is the contactGroupField parameter, for example:
     *                               If we want to give contacts of account with id 1 a message A, 
     *                               and to contacts of account with id 2 a message B, 
     *                               the map will look like this: 1-->A, 2-->B, and the contactGroupField will be AccountId.
	 */
	global Map<String, String> MessagesByGroupMap;

	global String ContactGroupField; //Field which grouped the messages for contact, as described above.
	
	global list<String> listVariables; // map to replaces tags {0},{1},{2}...

	/**
	 * [
	 * Batch constructor, init fields
	 * ]
	 * Created By:  Niv.Goldenberg 19-11-2014
	 * Modified By: Niv.Goldenberg 20-11-2014
	 */
	global ISSP_NotificationBatch() 
	{
		Query = '';
		NotificationTemplate = null;
		MessagesByGroupMap = null;
		ContactGroupField = '';
		listVariables = null;
	}
	
	/**
	 * [
	 * Start the batch
	 * ]
	 * @param  BC [Batch context]
	 * @return    [Database.QueryLocator]
	 * Created By:  Niv.Goldenberg 19-11-2014
	 * Modified By: Niv.Goldenberg 20-11-2014
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		System.debug('KTC - ISSP_NotificationBatch - Start: ' + Query);
		return Database.getQueryLocator(Query);
	}

	/**
	 * [
	 * Execute the batch
	 * ]
	 * @param  BC    [Batch context]
	 * @param  scope [List of contacts]
	 * Created By:  Niv.Goldenberg 19-11-2014
	 * Modified By: Niv.Goldenberg 13-12-2014
	 */
   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
   		System.debug('KTC - ISSP_NotificationBatch - execute - scope: ' + scope);
        ISSP_NotificationUtilities.insertNotifications((List<Contact>)scope, NotificationTemplate, MessagesByGroupMap, ContactGroupField, listVariables);
	}
	
	/**
	 * [
	 * Finish Batch
	 * ]
	 * @param  BC [Batch context]
	 * Created By:  Niv.Goldenberg 19-11-2014
	 * Modified By: Niv.Goldenberg 20-11-2014
	 */
	global void finish(Database.BatchableContext BC) 
	{
		System.debug('KTC - ISSP_NotificationBatch - finish: ');
	}
	
}