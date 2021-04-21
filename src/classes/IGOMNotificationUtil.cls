public without sharing class IGOMNotificationUtil {

	/**
     * DAO Object for the Notifications
     */
    public class Notification {
		// Read only
		@AuraEnabled public Id id;
		@AuraEnabled public Id accountRoleId;
		@AuraEnabled public Id contactRoleDetailId;
		@AuraEnabled public Id procedureComplianceId;
		@AuraEnabled public String procedureComplianceAsString;
		@AuraEnabled public String name;
		@AuraEnabled public Datetime notificationDate;
		@AuraEnabled public String notificationBody;
		@AuraEnabled public String notificationSubject;
		@AuraEnabled public String notificationStatus;
		@AuraEnabled public String severity;
		@AuraEnabled public String userName;
		@AuraEnabled public String userEmail;
		@AuraEnabled public Boolean acknowledged;

		public Notification() {
			this.notificationStatus = IGOMConstants.NOTIFICATION.STATUS.UNREAD;
			this.notificationDate = Datetime.now();
		}
		public Notification(IGOM_Contact_Role_Procedure_Compliance__c contactRoleProcedureCompliance) {
			this.id = contactRoleProcedureCompliance.Id;
			this.name = contactRoleProcedureCompliance.Name;
			this.accountRoleId = contactRoleProcedureCompliance.IGOM_Contact_Role_Detail__r.Account_Role_Detail__r.Account_Role__c;
			this.contactRoleDetailId = contactRoleProcedureCompliance.IGOM_Contact_Role_Detail__c;
			this.userName = contactRoleProcedureCompliance.IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__r.Name;
			this.userEmail = contactRoleProcedureCompliance.IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__r.Email;
			this.procedureComplianceId = contactRoleProcedureCompliance.Compliance_Review_Part__c;
			this.acknowledged = contactRoleProcedureCompliance.Notification_Status__c == IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED;
			this.notificationDate = contactRoleProcedureCompliance.Notification_Date__c;
			this.notificationBody = contactRoleProcedureCompliance.Notification_Body__c;
			this.notificationSubject = contactRoleProcedureCompliance.Notification_Subject__c;
            this.notificationStatus = contactRoleProcedureCompliance.Notification_Status__c;
            this.severity = contactRoleProcedureCompliance.Severity__c;
			// Build the readable string
			if (contactRoleProcedureCompliance.Compliance_Review_Part__r != null) { 
				final Compliance_Review_Part__c complianceReviewPart = contactRoleProcedureCompliance.Compliance_Review_Part__r;
				Document__c doc = new Document__c(
					Abbreviated_Name__c = complianceReviewPart.Document__r.Abbreviated_Name__c,
					Edition__c = complianceReviewPart.Document__r.Edition__c,
					Version__c = complianceReviewPart.Document__r.Version__c,
					Revision__c = complianceReviewPart.Document__r.Revision__c
				);
				String provisionDocument = String.isBlank(complianceReviewPart.Standard_Document_Part__c) ? IGOMConstants.GLOBALS.NONE : IGOMDocumentUtil.getDocumentReference(doc);
				this.procedureComplianceAsString = 
					complianceReviewPart.Standard_Document_Part__r.Name__c + ': ' + 
					complianceReviewPart.Status__c + ' ' + 
					provisionDocument + (complianceReviewPart.User_Provision_Procedure__c != null ? ' - ' + 
					complianceReviewPart.User_Provision_Procedure__c : '');
			}
		}

		public IGOM_Contact_Role_Procedure_Compliance__c toSalesforce() {
			return new IGOM_Contact_Role_Procedure_Compliance__c(
				Id = this.id,
				IGOM_Contact_Role_Detail__c = this.contactRoleDetailId,
				Compliance_Review_Part__c = this.procedureComplianceId,
				Notification_Date__c = this.notificationDate,
				Notification_Body__c = this.notificationBody,
				Notification_Subject__c = this.notificationSubject,
				Notification_Status__c = this.notificationStatus,
				Severity__c = this.severity
			);
		}
    }

	public class NotifiableContact {
		@AuraEnabled public Id id;
		@AuraEnabled public Id contactId;
		@AuraEnabled public String origin;
		@AuraEnabled public String fullname;
		@AuraEnabled public String stationName;
		
		public NotifiableContact(IGOM_Contact_Role_Detail__c contactDetail, String origin) {
			this.id = contactDetail.Id;
			this.contactId = contactDetail.Account_Contact_Role__r.Contact__c;
			this.fullname = contactDetail.Account_Contact_Role__r.Contact__r.Name;
			this.stationName = contactDetail.Account_Contact_Role__r.Account__r.Name;
			this.origin = origin;
		}
	}
	
	/**
	 * @description	Auxiliar method to retrieve notifications by a contact role detail id list.
	 * @param		contactRoleDetailIds <List of the contact role detail ids>
	 * @return		List<Notification> <List of the Notifications for the given contact role ids>
	 */
	private static List<Notification> getContactRoleProcCompByContactRoleDetailIds (List<Id> contactRoleDetailIds) {
		List<Notification> notifications = new List<Notification>();
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : 
			[SELECT Id, Name, Compliance_Review_Part__c, Notification_Date__c, IGOM_Contact_Role_Detail__c,
					Notification_Body__c, Notification_Subject__c, Notification_Status__c,
					Severity__c, IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__r.Name,
					IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__r.Email,
					IGOM_Contact_Role_Detail__r.Account_Role_Detail__r.Account_Role__c,
					Compliance_Review_Part__r.Standard_Document_Part__r.Name__c,
					Compliance_Review_Part__r.Document__r.Abbreviated_Name__c, Compliance_Review_Part__r.Document__r.Edition__c,
					Compliance_Review_Part__r.Document__r.Version__c, Compliance_Review_Part__r.Document__r.Revision__c,
					Compliance_Review_Part__r.Status__c, Compliance_Review_Part__r.User_Provision_Procedure__c
					FROM IGOM_Contact_Role_Procedure_Compliance__c
			WHERE IGOM_Contact_Role_Detail__c IN :contactRoleDetailIds
			ORDER BY Notification_Date__c DESC])
		{
			notifications.add(new Notification(notification));
		}
		return notifications;
	}

	/**
	 * @description Mark a notification as read
	 * @param		notificationId <Id of the notification>
	 */
	@AuraEnabled
	public static void markAsRead(Id notificationId) {
		if (notificationId != null && notificationId.getSObjectType() === IGOM_Contact_Role_Procedure_Compliance__c.getSObjectType())  {
			// Check the notification, to see if it belongs to the user
			IGOM_Contact_Role_Procedure_Compliance__c notification =
				[SELECT IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c
				 FROM IGOM_Contact_Role_Procedure_Compliance__c 
				 WHERE Id = :notificationId];
			if (notification.IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c != IGOMCommunityUtil.getCurrentUser().ContactId) {
				throw new AuraHandledException(IGOMConstants.ERRORS.NO_ACCESS_TO_NOTIFICATION);
			}
			// Update the attachment
			update new IGOM_Contact_Role_Procedure_Compliance__c(
				Id = notificationId, 
				Notification_Status__c = IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED
			);
		} else {
			throw new AuraHandledException(IGOMConstants.ERRORS.METHOD_ONLY_FOR_NOTIFICATIONS_ERROR);
		}
	}
	
	/**
	 * @description	Method to retrieve the notifications of the current user.
	 * @return		List<Notification> <List of the Notifications for the user>
	 */
    @AuraEnabled(cacheable=true)
    public static List<Notification> getNotifications() {
		if (!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'check notifications'}));
		}
        return getContactRoleProcCompByContactRoleDetailIds(IGOMPermissions.contactRoleDetailIdsWithPermission(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS));
    }
	
	/**
	 * @description	Method to send the notifications regarding the publishing of a new GAP Analysis.
	 * @param		gapAnalysisId <Id of the gap analysis>
	 * @param		contactDetailIds <Map of all the List of the contact role detail ids per notification type>
	 */
	public static void sendGAPNotifications(Id gapAnalysisId, Map<String, List<Id>> contactDetailIds) {
		//Create a list of all existing contactIds
		List<Id> contactDetailIds_Info = contactDetailIds.get(IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE) != null ? contactDetailIds.get(IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE) : new List<Id>();
		List<Id> contactDetailIds_ActReq = contactDetailIds.get(IGOMConstants.NOTIFICATION.SEVERITY.ACTION_REQUIRED) != null ? contactDetailIds.get(IGOMConstants.NOTIFICATION.SEVERITY.ACTION_REQUIRED) : new List<Id>();

		Set<Id> allContactDetailIds = new Set<Id>();
		allContactDetailIds.addAll(contactDetailIds_Info);
		allContactDetailIds.addAll(contactDetailIds_ActReq);

		// Validate that every user is notifiable
		Map<Id, NotifiableContact> notifiableContactsInfo = getGAPNotifiableContacts(gapAnalysisId, IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE);
		Map<Id, NotifiableContact> notifiableContactsActReq = getGAPNotifiableContacts(gapAnalysisId, IGOMConstants.NOTIFICATION.SEVERITY.ACTION_REQUIRED);
		
		if(!validateNotifiableContacts(contactDetailIds_Info, notifiableContactsInfo)){
			throw new AuraHandledException(IGOMConstants.ERRORS.CONTACT_DETAILS_NOT_NOTIFIABLE_ERROR);
		}
		if(!validateNotifiableContacts(contactDetailIds_ActReq, notifiableContactsActReq)){
			throw new AuraHandledException(IGOMConstants.ERRORS.CONTACT_DETAILS_NOT_NOTIFIABLE_ERROR);
		}
		// Get the variation compliance review parts from the gap analysis
		Id gapToCompareToId = IGOMComplianceReviewUtil.queryFullGapAnalysisById(gapAnalysisId).Previous_Version__c;
		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> newParts = IGOMComplianceReviewPartUtil.getNotifiableParts(gapToCompareToId, gapAnalysisId);

		// Create a notification object for each reference 
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		for (Id contactDetailId : allContactDetailIds) {
			//Be able to create a notification for each type of notification allowing a contact to receive notification of both types
			if(contactDetailIds_Info.contains(contactDetailId)){
				final NotifiableContact notifiableContact = notifiableContactsInfo.get(contactDetailId);
				for (IGOMComplianceReviewPartUtil.ComplianceReviewPart part : newParts) {
					Notification noti = new Notification();
					noti.contactRoleDetailId = notifiableContact.Id;
					noti.procedureComplianceId = part.Id;
					noti.notificationSubject = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_SUBJECT;
					noti.notificationBody = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_BODY;
					noti.severity = IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE;
					notifications.add(noti.toSalesforce());
				}
			}
			if(contactDetailIds_ActReq.contains(contactDetailId)){
				final NotifiableContact notifiableContact = notifiableContactsActReq.get(contactDetailId);
				for (IGOMComplianceReviewPartUtil.ComplianceReviewPart part : newParts) {
					Notification noti = new Notification();
					noti.contactRoleDetailId = notifiableContact.Id;
					noti.procedureComplianceId = part.id;
					noti.notificationSubject = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_SUBJECT;
					noti.notificationBody = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_BODY;
					noti.severity = IGOMConstants.NOTIFICATION.SEVERITY.ACTION_REQUIRED;
					notifications.add(noti.toSalesforce());
				}
			}
		}
		insert notifications;
	}

	/**
	 * @description	Method to validate that a list of contacts can be notified for a type of notification and given a gap analysis.
	 * @param		notificationType <Type of the notification that wants to be validated>
	 * @param		gapAnalysisId <Id of the gap analysis>
	 * @param		contactDetailIds <List of the contact role detail ids>
	 */
	private static Boolean validateNotifiableContacts(List<Id> contactDetailIds, Map<Id, NotifiableContact> notifiableContacts){
		if (!notifiableContacts.keySet().containsAll(new Set<Id>(contactDetailIds))) {
			return false;
		}
		return true;
	}

	/**
	 * @description Method to send a notification to every admin regarding the availability of a new IGOM.
	 * @param		igomDocumentId <Id of the IGOM document>
	 */
	public static void sendIGOMNotifications(Id igomDocumentId) {
		if (igomDocumentId == null || (igomDocumentId != null && igomDocumentId.getSObjectType() != Document__c.getSObjectType())) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.DOCUMENT_WRONG_TYPE_ERROR, new List<Object>{'Id', 'igomDocumentId'}));
		}
		// Get every user that admins a station
		List<Id> stationAdminIds = new List<Id>();
		for (IGOM_Contact_Role_Detail__c contactRoleDetail : 
			 [SELECT Id FROM IGOM_Contact_Role_Detail__c  WHERE Role__c = :IGOMConstants.ROLES.ADMIN]) 
		{
			stationAdminIds.add(contactRoleDetail.Id);
		}
		// Get the document data
		IGOMDocumentUtil.Document igomDocument = IGOMDocumentUtil.getIGOMManualById(igomDocumentId);
		// Create a notification object for each admin 
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		for (Id contactDetailId : stationAdminIds) {
			Notification noti = new Notification();
			noti.contactRoleDetailId = contactDetailId;
			noti.notificationSubject = IGOMConstants.METADATA.NOTIFICATION_NEW_IGOM_SUBJECT;
			noti.notificationBody = String.format(IGOMConstants.METADATA.NOTIFICATION_NEW_IGOM_BODY, new List<Object>{ igomDocument.name, igomDocument.publishDate });
			noti.severity = IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE;
			notifications.add(noti.toSalesforce());
		}
		insert notifications;
	}

	/**
	 * @description Method to send a notification to every admin regarding the availability of a new IGOM.
	 * @param		contactDetailIds <List of the contact role detail ids>
	 * @param		subject <Subject of the notification>
	 * @param		body <Body of the notification>
	 */
	@AuraEnabled
	public static void sendManualNotifications(Id stationId, List<Id> contactDetailIds, String subject, String body) {
		Map<Id, NotifiableContact> notifiableContactsManual = getStationNotifiableContacts(stationId, IGOMConstants.NOTIFICATION.SEVERITY.MANUAL);

		if(!validateNotifiableContacts(contactDetailIds, notifiableContactsManual)){
			throw new AuraHandledException(IGOMConstants.ERRORS.CONTACT_DETAILS_NOT_NOTIFIABLE_ERROR);
		}
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		for (Id contactDetailId : contactDetailIds) {
			//Be able to create a notification for each type of notification allowing a contact to receive notification of both types
			final NotifiableContact notifiableContact = notifiableContactsManual.get(contactDetailId);
			Notification noti = new Notification();
			noti.contactRoleDetailId = notifiableContact.Id;
			noti.notificationSubject = subject;
			noti.notificationBody = body;
			noti.severity = IGOMConstants.NOTIFICATION.SEVERITY.MANUAL;
			notifications.add(noti.toSalesforce());
		}
		insert notifications;
	}

	/**
	 * @description Method to mark every notification regarding a GAP Analysis as read (acknowledged)
	 * @param		gapAnalysisId <Id of the gap analysis>
	 */
	@AuraEnabled
	public static void acknowledgeGapNotifications(Id gapAnalysisId) {
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = 
			[SELECT Notification_Status__c
			 FROM IGOM_Contact_Role_Procedure_Compliance__c 
			 WHERE Compliance_Review_Part__r.Compliance_Review__c = :gapAnalysisId
			 	   AND IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c = :IGOMCommunityUtil.getCurrentUser().ContactId];
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : notifications) {
			notification.Notification_Status__c = IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED;
		}
		update notifications;
	}

	/**
	 * @description	Method to retrieve every notifiable contact for a specific gap analysis.
	 * @param		gapAnalysisId <Id of the gap analysis>
	 * @param		notificationType <Type of the notification, being available INFORMATIVE and ACTION REQUIRED, as of now ACTION REQUIRED is not used>
	 * @return		Map<Id, NotifiableContact> <Map containing the id of the contact and the data for each notifiable contact>
	 */
	@AuraEnabled(cacheable=true)
	public static Map<Id, NotifiableContact> getGAPNotifiableContacts(Id gapAnalysisId, String notificationType) {
		// Validate the notification type
		if (notificationType != IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE && notificationType != IGOMConstants.NOTIFICATION.SEVERITY.ACTION_REQUIRED
		|| notificationType == IGOMConstants.NOTIFICATION.SEVERITY.MANUAL) {
			notificationType = IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE;
		}
		// Validate gapAnalysisId content
		if (gapAnalysisId == null || (gapAnalysisId.getSObjectType() != Compliance_Review__c.getSObjectType())) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.DOCUMENT_WRONG_TYPE_ERROR, new List<Object>{'Id', 'gapAnalysisId'}));
		}
		// Retrieve the gap analysis information
		IGOMComplianceReviewUtil.ComplianceReview gapAnalysis = IGOMComplianceReviewUtil.queryGapAnalysisById(gapAnalysisId);
		if (gapAnalysis.stationId == null) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.NO_ITEM_FOR_ID_ERROR, new List<Object>{'IGOM Station', gapAnalysisId + ' for the GAP analysis'}));
		}
		return getStationNotifiableContacts(gapAnalysis.stationId, notificationType);
	}

	/**
	 * @description	Method to retrieve every notifiable contact for a specific station.
	 * @param		stationId <Id of the station, it must be checked if it is an account role id or an IGOM account role detail id>
	 * @param		notificationType <Type of the notification, being available INFORMATIVE and ACTION REQUIRED, as of now ACTION REQUIRED is not used>
	 * @return		Map<Id, NotifiableContact> <Map containing the id of the contact and the data for each notifiable contact>
	 */
	@AuraEnabled(cacheable=true)
	public static Map<Id, NotifiableContact> getStationNotifiableContacts(Id stationId, String notificationType){
		Id accRoleId = stationId;
		if(stationId.getSObjectType().getDescribe().getName() == 'IGOM_Account_Role_Detail__c'){
			accRoleId = [SELECT Account_Role__c FROM IGOM_Account_Role_Detail__c WHERE Id = :stationId LIMIT 1].Account_Role__c;
		}
		// Query the station
		IGOM_Account_Role_Detail__c station = 
			[SELECT Id, Account_Role__r.Account__r.Name, RecordType.Name, Account_Role__c, Account_Role__r.Account__c, City__c, Country__c
			 FROM IGOM_Account_Role_Detail__c 
			 WHERE Account_Role__c = :accRoleId];
		IGOMStationUtil.Station ownStation = new IGOMStationUtil.Station(station);
		// Get the related station's admins as they are all notifiable if they wish to be
		IGOMAccountRoleRelationshipsUtil.AllRelationships allRelationships = IGOMAccountRoleRelationshipsUtil.getAllRelationships(station.Id);
		// Get every station in the hierarchichal relationship
		List<IGOMStationUtil.RelatedStation> allHierarchichalRelationships = new List<IGOMStationUtil.RelatedStation>();
		Map<Id, IGOMStationUtil.Station> notifiableAccountRoleIdToStation = new Map<Id, IGOMStationUtil.Station>();
		allHierarchichalRelationships.addAll(allRelationships.childStations);
		allHierarchichalRelationships.addAll(allRelationships.parentStations);
		allHierarchichalRelationships.addAll(allRelationships.groupStations);
		// Apply the rules of notification as seen in the document "IGOM Portal Roles and Hierarchies"
		for (IGOMStationUtil.RelatedStation relatedStation : allHierarchichalRelationships) {
			if (notificationType == IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE || notificationType == IGOMConstants.NOTIFICATION.SEVERITY.MANUAL) {
				// Specify the cases in which the notification will be sendable
				if (!(relatedStation.stationInfo.type == 'Airline' && !relatedStation.acceptsNotifications)) {
					notifiableAccountRoleIdToStation.put(relatedStation.stationInfo.accountRoleId, relatedStation.stationInfo);
				}
			} else if (notificationType == IGOMConstants.NOTIFICATION.SEVERITY.ACTION_REQUIRED) {
				if ((ownStation.type == 'Airline' && relatedStation.stationInfo.type.startsWith('Ground Handler')) ||
					(ownStation.type == 'Ground Handler HQ' && relatedStation.stationInfo.type == 'Ground Handler Station')) {
					notifiableAccountRoleIdToStation.put(relatedStation.stationInfo.accountRoleId, relatedStation.stationInfo);
				}
			}
		}
		// Prepare the returned list
		Map<Id, NotifiableContact> notifiableContacts = new Map<Id, NotifiableContact>();
		// Get the current user
		final User currentUser = IGOMCommunityUtil.getCurrentUser();
		IGOM_Contact_Role_Detail__c currentContactRoleDetail;
		// Get all the contacts from the same station, every parent stations (admin and acknowledger) contacts and the current contact
		for (IGOM_Contact_Role_Detail__c contactRoleDetail : 
			 [SELECT Id, Account_Contact_Role__r.Contact__r.Name, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Id, Account_Contact_Role__r.Account__r.Name, Account_Role_Detail__c, Account_Role_Detail__r.Account_Role__c, Role__c
			  FROM IGOM_Contact_Role_Detail__c 
			  WHERE (Role__c = :IGOMConstants.ROLES.ADMIN OR Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER) AND (Account_Role_Detail__c = :station.Id
			  		OR (Account_Role_Detail__r.Account_Role__c IN :notifiableAccountRoleIdToStation.keySet()))]) 
		{
			// Get current contact role detail
			if (contactRoleDetail.Account_Contact_Role__r.Contact__c == currentUser.ContactId) {
				currentContactRoleDetail = contactRoleDetail;
			}
			// Add every contact from the same station that has permission to do it
			if (contactRoleDetail.Account_Role_Detail__c == station.Id 
				&& IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(contactRoleDetail.Role__c).contains(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS)) 
			{
				notifiableContacts.put(contactRoleDetail.Account_Contact_Role__r.Contact__c, new NotifiableContact(
					contactRoleDetail,
					contactRoleDetail.Role__c
				));
			}
			// Add every contact from the notifiable station admins
			if (notifiableAccountRoleIdToStation.keySet().contains(contactRoleDetail.Account_Role_Detail__r.Account_Role__c)) {
				// Only add them if they were not added before
				if (!notifiableContacts.containsKey(contactRoleDetail.Account_Contact_Role__r.Contact__c)) {
					notifiableContacts.put(contactRoleDetail.Account_Contact_Role__r.Contact__c, new NotifiableContact(
						contactRoleDetail,
						contactRoleDetail.Role__c
					));
				}
			}
		}
		// Check the permissions
		if (currentContactRoleDetail == null || !IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(currentContactRoleDetail.Role__c).contains(IGOMConstants.PERMISSIONS.PUBLISH_GAP)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'publish a GAP'}));
		}

		return notifiableContacts;
	}
}