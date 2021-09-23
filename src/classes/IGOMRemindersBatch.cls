/**
 * @author        Jorge Corral <jorge.corral@adesso.es>
 * @description   igMainContainer LWC component's controller
 * @history       2020/11/18  |  Jorge Corral <jorge.corral@adesso.es>  |  Class creation and execute method creation.
 */
global class IGOMRemindersBatch implements Schedulable {
	global void execute(SchedulableContext ctx) {
		Date today = Date.today();
		// Last date must be following the yyyy/mm/dd format
		List<String> lastReminderDateInfo = IGOMConstants.METADATA.REMINDERS_LAST_DATE.split('/');

		Document__c activeManual = [SELECT Id, Effective_Date__c FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM AND Is_Active__c = true AND Language__c = :IGOMConstants.GLOBALS.LANGUAGE_ENGLISH ORDER BY CreatedDate DESC LIMIT 1];
		Date lastReminderDate = Date.newInstance(Integer.valueOf(lastReminderDateInfo.get(0)), Integer.valueOf(lastReminderDateInfo.get(1)), Integer.valueOf(lastReminderDateInfo.get(2)));
		Boolean executeFirstReminder = false;
		Boolean executeLastReminder = false;

		//Check if IGOM related reminders must be sent - START
		if(today == activeManual.Effective_Date__c || Test.isRunningTest()){ //Date.newInstance(today.year(), 4, 1)
			executeFirstReminder = true;
		}else if(today == lastReminderDate || Test.isRunningTest()){ //Date.newInstance(today.year(), 11, 30)
			executeLastReminder = true;
		}

		if(executeFirstReminder || executeLastReminder){
			//Find for each manager if it has any published gap analysis or not related to the active IGOM
			List<Compliance_Review__c> gapAnalyses = [SELECT Id, Publish_Status__c, Station__c
			FROM Compliance_Review__c WHERE Document__c = :activeManual.Id];

			Map<Id, Boolean> publishingStatusPerStation = getPublishingInfoPerStation(gapAnalyses);
			Set<Id> stationIds = publishingStatusPerStation.keySet();

			Map<Id, String> stationNamesPerId = getStationNamesById(stationIds);
			Map<Id, List<IGOM_Contact_Role_Detail__c>> managersPerStation = getManagersInStationList(stationIds);

			//Create a map containing all the notifications per stationId
			Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>> notificationsPerStation = new Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>>();
			List<IGOM_Contact_Role_Procedure_Compliance__c> newNotifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
			for(Id stationId : stationIds){
				//Send a reminder when it has not been published
				if(!publishingStatusPerStation.get(stationId)){
					newNotifications.addAll(createListReminderNotificationsForStation(managersPerStation.get(stationId), executeFirstReminder, stationNamesPerId.get(stationId)));
				}
			}
			insert newNotifications;

		}
		//Check if IGOM related reminders must be sent - END

		//Check if published GAP related reminders must be sent - START
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications =
			[SELECT Id, IGOM_Contact_Role_Detail__c, IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c,
					Compliance_Review_Part__r.Compliance_Review__r.Notification_Date__c, Compliance_Review_Part__c
			 FROM IGOM_Contact_Role_Procedure_Compliance__c
			 WHERE Compliance_Review_Part__r.Compliance_Review__r.Document__r.Is_Active__c = true AND Compliance_Review_Part__r.Status__c = :IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION
			 	   AND Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD];
		Set<Id> complianceReviewPartIds = new Set<Id>();
		for (IGOM_Contact_Role_Procedure_Compliance__c notif : notifications) {
			complianceReviewPartIds.add(notif.Compliance_Review_Part__c);
		}

		//Get compliance review parts related to the notifications
		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewParts = IGOMComplianceReviewPartUtil.getComplianceReviewPartById(new List<Id>(complianceReviewPartIds));
		Map<Id, IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewPartIdToObject = new Map<Id, IGOMComplianceReviewPartUtil.ComplianceReviewPart>();
		for (IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart : complianceReviewParts) {
			complianceReviewPartIdToObject.put(complianceReviewPart.id, complianceReviewPart);
		}

		List<Messaging.SingleEmailMessage> emailsToBeSent = createEmailsToSend(notifications, complianceReviewPartIdToObject, today);
		Messaging.sendEmail(emailsToBeSent);
		//Check if published GAP related reminders must be sent - END
	}

	/**
	 * @description	Method to get the list of managers that exist in each station
	 * @param		stations <List of the stations from which the managers want to be taken from>
	 * @return		Map<Id, List<IGOM_Contact_Role_Detail__c>> <map of the list of managers per station id>
	 */
	private static Map<Id, List<IGOM_Contact_Role_Detail__c>> getManagersInStationList(Set<Id> stations){
		Map<Id, List<IGOM_Contact_Role_Detail__c>> managersByStation = new Map<Id, List<IGOM_Contact_Role_Detail__c>>();
		for (IGOM_Contact_Role_Detail__c roleDetail : [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Email
		FROM IGOM_Contact_Role_Detail__c WHERE Account_Role_Detail__c IN :stations AND Role__c = :IGOMConstants.ROLES.ADMIN]) {
			List<IGOM_Contact_Role_Detail__c> managersInStation = managersByStation.get(roleDetail.Account_Role_Detail__c) != null ? managersByStation.get(roleDetail.Account_Role_Detail__c) : new List<IGOM_Contact_Role_Detail__c>();
			managersInStation.add(roleDetail);
			managersByStation.put(roleDetail.Account_Role_Detail__c, managersInStation);
		}
		return managersByStation;
	}

	/**
	 * @description	Method to identify the stations that have a published gap analysis
	 * @param		gapAnalyses <List of gaps related to active IGOM>
	 * @return		Map<Id, Boolean> <Map containing whether a station has published a gap or not for active IGOM>
	 */
	private static Map<Id, Boolean> getPublishingInfoPerStation(List<Compliance_Review__c> gapAnalyses){
		Map<Id, Boolean> stationHasGapPublished = new Map<Id, Boolean>();
		//Put the stations in the list of gap analysis
		for(Compliance_Review__c gap : gapAnalyses){
			Boolean hasPublishedGap = stationHasGapPublished.get(gap.Station__c) != null ? stationHasGapPublished.get(gap.Station__c) : false;
			if(gap.Publish_Status__c == IGOMConstants.COMPLIANCE_REVIEW.STATUS.DRAFT && !hasPublishedGap){
				hasPublishedGap = false;
			}else{
				hasPublishedGap = true;
			}
			stationHasGapPublished.put(gap.Station__c, hasPublishedGap);
		}

		// Put all the stations without a related GAP analysis in map, marked as not having a published GAP
		for (IGOM_Account_Role_Detail__c station : [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c WHERE Id NOT IN :stationHasGapPublished.keySet()]) {
			if(!stationHasGapPublished.keySet().contains(station.Account_Role__c)){
				stationHasGapPublished.put(station.Id, false);
			}
		}
		return stationHasGapPublished;
	}

	/**
	 * @description	Method to create a list of reminders for a specific station
	 * @param		managerList <List of station managers>
	 * @param		isFirstReminderDate <Indicator of whether the date of reminder is the first or last date (there are only those two options)>
	 * @param		stationName <Name of the station>
	 * @return		List<IGOM_Contact_Role_Procedure_Compliance__c> <List of notifications for the station>
	 */
	private static List<IGOM_Contact_Role_Procedure_Compliance__c> createListReminderNotificationsForStation(List<IGOM_Contact_Role_Detail__c> managerList, Boolean isFirstReminderDate, String stationName){
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		if (managerList != null) {
			for (IGOM_Contact_Role_Detail__c contactDetail : managerList) {
				IGOMNotificationUtil.Notification noti = new IGOMNotificationUtil.Notification();
				noti.contactRoleDetailId = contactDetail.Id;
				noti.notificationSubject = isFirstReminderDate ? IGOMConstants.METADATA.REMINDERS_FIRST_DATE_SUBJECT : IGOMConstants.METADATA.REMINDERS_LAST_DATE_SUBJECT;
				noti.notificationBody = String.format(isFirstReminderDate ? IGOMConstants.METADATA.REMINDERS_FIRST_DATE_BODY : IGOMConstants.METADATA.REMINDERS_LAST_DATE_BODY, new List<Object>{ stationName });
				notifications.add(noti.toSalesforce());
			}	
		}
		return notifications;
	}

	/**
	 * @description	Method to get the station names by their id
	 * @param		stationIds <Set of station ids>
	 * @return		Map<Id, String> <Map of the name of each station by their id>
	 */
	private static Map<Id, String> getStationNamesById(Set<Id> stationIds){
		Map<Id, String> stationNamePerId = new Map<Id, String>();
		for (IGOMStationUtil.Station stationInfo : IGOMStationUtil.getIGOMAccountRoleDetailByIds(new List<Id>(stationIds))){
			stationNamePerId.put(stationInfo.id, stationInfo.name);
		}
		return stationNamePerId;
	}

	/**
	 * @description	Method to create a list of emails to remind a list of notifications
	 * @param		notifications <List of notifications that could be reminded>
	 * @param		notificationDate <Date to compare the notifications Notification_Date__c field to>
	 * @return		List<Messaging.SingleEmailMessage> <List of emails that should be sent>
	 */
	private static List<Messaging.SingleEmailMessage> createEmailsToSend(List<IGOM_Contact_Role_Procedure_Compliance__c> notifications, Map<Id, IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewPartsById, Date notificationDate){
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>> notificationsPerContact = mapProcedureCompliancesByContact(notifications);

		// Get the email template for the GAP notifications reminder
		EmailTemplate reminderTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName LIKE :(IGOMConstants.GLOBALS.EMAIL_TEMPLATE_GAP_REMINDER) LIMIT 1];
		for(Id contactId: notificationsPerContact.keySet()){
			String notificationListString = '';
			for(IGOM_Contact_Role_Procedure_Compliance__c notification : notificationsPerContact.get(contactId)){
				if(notificationDate == notification.Compliance_Review_Part__r.Compliance_Review__r.Notification_Date__c){
					IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart = complianceReviewPartsById.get(notification.Compliance_Review_Part__c);
					notificationListString = notificationListString + '- ' + complianceReviewPart.igomAuditableProcedureName + ': ' + complianceReviewPart.variationStatus + ' ' + complianceReviewPart.userProvisionDocument + ' - ' + complianceReviewPart.userProvisionProcedure;
				}
			}
			if(notificationListString != ''){
				String htmlBody = reminderTemplate.HtmlValue;
				htmlBody = htmlBody.replace('{!Notifications}', notificationListString);

				String plainTextBody = reminderTemplate.Body;
				plainTextBody = plainTextBody.replace('{!Notifications}', notificationListString);

				// Create the email
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setTargetObjectId(contactId);
				email.setSubject(reminderTemplate.Subject);
				email.setHtmlBody(htmlBody);
				email.setPlainTextBody(plainTextBody);
				emails.add(email);
			}
		}
		return emails;
	}

	/**
	 * @description	Method to create a map of all the notifications for each contact
	 * @param		notifications <List of notifications to be mapped>
	 * @return		List<Messaging.SingleEmailMessage> <List of emails that should be sent>
	 */
	private static Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>> mapProcedureCompliancesByContact(List<IGOM_Contact_Role_Procedure_Compliance__c> notifications){
		Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>> notificationsPerContactId = new Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>>();
		for (IGOM_Contact_Role_Procedure_Compliance__c notif : notifications) {
			List<IGOM_Contact_Role_Procedure_Compliance__c> notificationListTemp = notificationsPerContactId.get(notif.IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c) != null ?
			notificationsPerContactId.get(notif.IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c) : new List<IGOM_Contact_Role_Procedure_Compliance__c>();

			notificationListTemp.add(notif);
			notificationsPerContactId.put(notif.IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c, notificationListTemp);
		}
		return notificationsPerContactId;
	}
}