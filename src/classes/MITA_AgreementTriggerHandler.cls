public with sharing class MITA_AgreementTriggerHandler {

	public static final String TEMPLATE_REQUESTED = 'Interline Agreement Requested';
	public static final String TEMPLATE_APPROVED = 'Interline Agreement Approved';
	public static final String TEMPLATE_REJECTED = 'Interline Agreement Rejected';
	public static final String TEMPLATE_WITHDRAWN = 'Interline Agreement Withdrawn';

	public void onAfterInsert(list<MITA_Agreement__c> news){
		sendNotificationForRequestedNewAgreements(news);
	}

	public void onBeforeUpdate(list<MITA_Agreement__c> olds, list<MITA_Agreement__c> news, map<Id,MITA_Agreement__c> mapOlds){
		sendNotifications(news, mapOlds);
	}

	/**
		Find the accounts to be notified among the new agreement requests
	 */
	private void sendNotificationForRequestedNewAgreements(list<MITA_Agreement__c> listAgreements) {
		//first find accounts that need to be notified of "new agreement request"
		list<Id> listAccountId = new list<Id>();
		for (MITA_Agreement__c agreement: listAgreements) {
			listAccountId.add(agreement.Airline_2__c);
		}

		//second send notifications to all mita contacts using ISSP_Notifications
		sendNotificationsBatch(listAccountId, TEMPLATE_REQUESTED);
	}

	/**
	 * When a mita agreement record is updated there are 4 types of notification that can be triggered
	 * approvals, rejections and withdrawns
	 */
	private void sendNotifications(list<MITA_Agreement__c> listAgreements, map<Id,MITA_Agreement__c> mapOlds) {
		//first find accounts that need to be notified of "new agreement request"
		list<Id> listApproved = new list<Id>();
		list<Id> listRejected = new list<Id>();
		list<Id> listWithdrawn = new list<Id>();
		for (MITA_Agreement__c newagr: listAgreements) {
			MITA_Agreement__c oldagr = mapOlds.get(newagr.Id);
			// an approval can happen when the effective date is being set and there is no cancellation
			if (newagr.Effective_date__c!=null && oldagr.Effective_date__c==null && newagr.Cancellation_date__c == null) {
				listApproved.add(newagr.Airline_1__c);
			}
			// a withdrawn can happen when the cancellation date is being set
			if (newagr.Cancellation_date__c!=null && oldagr.Cancellation_date__c==null) {
				if (newagr.Cancellation_Reason__c == 'Airline 1 leaves agreement') {
					listWithdrawn.add(newagr.Airline_2__c);
				}
				if (newagr.Cancellation_Reason__c == 'Airline 2 leaves agreement') {
					listWithdrawn.add(newagr.Airline_1__c);
				}
				// except when it's rejected
				if (newagr.Cancellation_Reason__c == 'Rejected by Airline 2') {
					listRejected.add(newagr.Airline_1__c);
				}
			}
		}

		//second send notifications to all mita contacts using ISSP_Notifications
		sendNotificationsBatch(listApproved, TEMPLATE_APPROVED);
		sendNotificationsBatch(listRejected, TEMPLATE_REJECTED);
		sendNotificationsBatch(listWithdrawn, TEMPLATE_WITHDRAWN);
	}

	/**
	 * Get the Notification_template__c name used in the batch to send notifications
	 */
	private Notification_template__c getNotificationTemplate(String templateName) {
		try {
			return
				[SELECT Type__c, Subject__c, Notification_color__c, Name, Message__c, Master_Notification_template__c, Language__c, Id, Expire_in_days__c, Due_date__c, DDS_Update_Request__c, Alert_Contact_By_Email__c, Admins_Users__c, CriticalNotification__c,
					(SELECT Type__c, Subject__c, Notification_color__c, Name, Message__c, Master_Notification_template__c, Language__c, Id, Expire_in_days__c, Due_date__c, DDS_Update_Request__c, Alert_Contact_By_Email__c, Admins_Users__c, CriticalNotification__c
					FROM Notification_templates__r)
				FROM Notification_template__c
				WHERE Id = :ISSP_Notifications_Trigger__c.getValues(templateName).Notification_Template_Id__c
				LIMIT 1];
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * Call the batch process to send the portal notifications
	 */
	private void sendNotificationsBatch(list<Id> listAccountId, String templateName) {
		if (listAccountId.isEmpty()) return;
		Notification_template__c template = getNotificationTemplate(templateName);
		if (template == null) return;

		ISSP_NotificationBatch bc = new ISSP_NotificationBatch();
		bc.Query = 'SELECT ' + String.join(ISSP_NotificationUtilities.getAllContactFields(), ',')
		+ ' FROM Contact'
		+ ' WHERE Status__c = \'Active\''
		+ ' AND User_Portal_Status__c IN (\'Administrator\',\'Approved Admin\')'
		+ ' AND MITA_Contact__c = true'
		+ ' AND MITA_Contact_Type__c != null'
		+ ' AND ('
		+ '   AccountId IN ' + getInParam(listAccountId)
		+ '   OR Account.Top_Parent__c IN ' + getInParam(listAccountId)
		+ ' )';

		bc.NotificationTemplate = template;
		bc.MessagesByGroupMap = null;
		bc.ContactGroupField = null;
		bc.fieldBindingByGroupMap = new Map<String, list<String>>();
		// add variables with null key to use the same values for all records
		//bc.fieldBindingByGroupMap.put(null,new list<String>{remittanceDateStr});
		Integer elemsPerBatch = 1;
		Database.executeBatch(bc, elemsPerBatch);
	}

	/**
	 * converts a list into a string ready to be used with IN operator in a query
	 */
	private static String getInParam(list<String> listParam) {
		return '(\'' + String.join(listParam,'\',\'') + '\')';
	}
}
