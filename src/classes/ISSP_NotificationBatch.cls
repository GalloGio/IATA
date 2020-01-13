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

		/**
				This is an enhancement for MessagesByGroupMap,
				If MessagesByGroupMap is Empty, but there is a ContactGroupField then this map will apply
				It contains 2 nested maps, the key works as in MessagesByGroupMap, having the value representing a group: Contact.Id for example
				The list inside the value contains a list of strings to be replaced in the message with the tags {0},{1},{2}...
		**/
		global Map<String, list<String>> FieldBindingByGroupMap;

	global String ContactGroupField; //Field which grouped the messages for contact, as described above.

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
		FieldBindingByGroupMap = null;
		ContactGroupField = '';
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
				ISSP_NotificationUtilities.insertNotifications((List<Contact>)scope, NotificationTemplate, MessagesByGroupMap, FieldBindingByGroupMap, ContactGroupField);
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
