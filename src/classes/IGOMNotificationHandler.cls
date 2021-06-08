/**
 * @author		  Axel Martinez <axel.martinez@adesso.es>
 * @description	  IGOM notification sObject handler for trigger execution.
 * @history		  2021/01/18  |  Axel Martinez <axel.martinez@adesso.es>  |  Class creation, sends emails on after insert
 */
public without sharing class IGOMNotificationHandler
{

	// Bypass the handler on tests
	@TestVisible
	private static Boolean bypassEmailsOnTest = true;

	// Sets with the instanced emails
	@TestVisible
	List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
	// Map with the available email templates
	Map<String, EmailTemplate> emailNameToTemplate = new Map<String, EmailTemplate>();
	// Map with the related igom contact role details to contact
	Map<Id, Id> contactRoleDetailIdToContactId = new Map<Id, Id>();

	//Map of all the types of nofitications that should be sent for each contact role detail
	Map<Id, List<String>> contactRoleDetailIdToNotificationTypes = new Map<Id, List<String>>();

	private void bulkAfterInsert(List<IGOM_Contact_Role_Procedure_Compliance__c> notifications) {
		// Query all email templates ids and names
		EmailTemplate complianceReviewPartTemplate;
		for (EmailTemplate emailTemplate : [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name LIKE 'IGOM Notification - %']) {
			emailNameToTemplate.put(emailTemplate.Name, emailTemplate);
			if (emailTemplate.DeveloperName == IGOMConstants.GLOBALS.EMAIL_TEMPLATE_GAP_ANALYSIS) {
				complianceReviewPartTemplate = emailTemplate;
			}
		}
		// Prepare the related id sets
		Set<Id> complianceReviewPartIds = new Set<Id>();
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : notifications) {
			complianceReviewPartIds.add(notification.Compliance_Review_Part__c);

			List<String> notifTypes = contactRoleDetailIdToNotificationTypes.get(notification.IGOM_Contact_Role_Detail__c) != null ?
			contactRoleDetailIdToNotificationTypes.get(notification.IGOM_Contact_Role_Detail__c) : new List<String>();
			if(!notifTypes.contains(notification.Severity__c)){
				notifTypes.add(notification.Severity__c);
			}
			contactRoleDetailIdToNotificationTypes.put(notification.IGOM_Contact_Role_Detail__c, notifTypes);
		}

		// Map for the station names
		Map<Id, String> contactRoleDetailIdToStationName = new Map<Id, String>();
		// Query the related igom contact role details
		for (IGOM_Contact_Role_Detail__c contactRoleDetail : 
				[SELECT Id, Account_Contact_Role__r.Contact__c, Account_Role_Detail__r.Account_Role__r.Account__r.Name FROM IGOM_Contact_Role_Detail__c WHERE Id IN :contactRoleDetailIdToNotificationTypes.keySet()])
		{
			contactRoleDetailIdToContactId.put(contactRoleDetail.Id, contactRoleDetail.Account_Contact_Role__r.Contact__c);
			contactRoleDetailIdToStationName.put(contactRoleDetail.Id, contactRoleDetail.Account_Role_Detail__r.Account_Role__r.Account__r.Name);
		}
		// Group the compliance review part related notifications
		Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>> contactRoleDetailIdToGAPNotifications = new Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>>();
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : notifications) {
			if (notification.Compliance_Review_Part__c != null) {
				List<IGOM_Contact_Role_Procedure_Compliance__c> relatedNotifications = contactRoleDetailIdToGAPNotifications.get(notification.IGOM_Contact_Role_Detail__c);
				if (relatedNotifications == null) {
					relatedNotifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
					contactRoleDetailIdToGAPNotifications.put(notification.IGOM_Contact_Role_Detail__c, relatedNotifications);
				}
				relatedNotifications.add(notification);
			}
		}
		// Generate the grouped emails for the compliance review parts notifications
		if (complianceReviewPartTemplate != null && !complianceReviewPartIds.isEmpty()) {
			// Query the compliance review part data
			List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewParts = IGOMComplianceReviewPartUtil.getComplianceReviewPartById(new List<Id>(complianceReviewPartIds));
			Map<Id, IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewPartIdToObject = new Map<Id, IGOMComplianceReviewPartUtil.ComplianceReviewPart>();
			for (IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart : complianceReviewParts) {
				complianceReviewPartIdToObject.put(complianceReviewPart.id, complianceReviewPart);
			}
			// For every contact role detail id, send one notification group
			for (Id contactRoleDetailId : contactRoleDetailIdToGAPNotifications.keySet()) {
				final Id contactId = contactRoleDetailIdToContactId.get(contactRoleDetailId);
				Id gapAnalysisId;
				// Create the list of changes 
				List<String> notificationList = new List<String>();
				for (IGOM_Contact_Role_Procedure_Compliance__c notification : contactRoleDetailIdToGAPNotifications.get(contactRoleDetailId)) {
					IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart = complianceReviewPartIdToObject.get(notification.Compliance_Review_Part__c);
					if (complianceReviewPart != null) {
						if (gapAnalysisId == null) {
							gapAnalysisId = complianceReviewPart.gapAnalysisId;
						}
						notificationList.add('- ' + complianceReviewPart.igomAuditableProcedureName + ': ' + complianceReviewPart.variationStatus + ' ' + complianceReviewPart.userProvisionDocument + ' - ' + complianceReviewPart.userProvisionProcedure);
					}
				}
				for (String notifType : contactRoleDetailIdToNotificationTypes.get(contactRoleDetailId)) {
					// Create and format the template for each type of notification that has to be sent
					String notificationListHtml = String.join(notificationList, '<br/>');
					String htmlBody = complianceReviewPartTemplate.HtmlValue;
					htmlBody = htmlBody.replace('{!Notifications}', notificationListHtml);
					htmlBody = htmlBody.replace('{!StationName}', contactRoleDetailIdToStationName.get(contactRoleDetailId));
					//Only add action link when action is required
					if(notifType == IGOMConstants.NOTIFICATION.SEVERITY.ACTION_REQUIRED){
						htmlBody = htmlBody.replace('{!ConfirmationText}', 'To acknowledge every item please press <a href=\"' + String.format('{0}?action=confirmAll&gapAnalysisId={1}', new List<String>{ IGOMConstants.METADATA.COMMUNITY_URL, gapAnalysisId }) + '\">THIS LINK</a>');
					}else{
						htmlBody = htmlBody.remove('{!ConfirmationText}');
					}
					String notificationListString = String.join(notificationList, '\n');
					String plainTextBody = complianceReviewPartTemplate.Body;
					plainTextBody = plainTextBody.replace('{!Notifications}', notificationListString);
					plainTextBody = plainTextBody.replace('{!StationName}', contactRoleDetailIdToStationName.get(contactRoleDetailId));

					//Only add action link when action is required
					if(notifType == IGOMConstants.NOTIFICATION.SEVERITY.ACTION_REQUIRED){
						plainTextBody = plainTextBody.replace('{!ConfirmationText}', 'To acknowledge every item please go to this link: ' + String.format('{0}?action=confirmAll&gapAnalysisId={1}', new List<String>{ IGOMConstants.METADATA.COMMUNITY_URL, gapAnalysisId }));
					}else{
						plainTextBody = plainTextBody.remove('{!ConfirmationText}');
					}
					// Create an email
					Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
					email.setTargetObjectId(contactId);
					email.setSubject(complianceReviewPartTemplate.Subject);
					email.setHtmlBody(htmlBody);
					email.setPlainTextBody(plainTextBody);
					emails.add(email);
				}
			}
		}
	}
	
	public void afterInsert(List<SObject> sobjects) {
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = (List<IGOM_Contact_Role_Procedure_Compliance__c>)sobjects;
		this.bulkAfterInsert(notifications);
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : notifications) {
			// If it has a related compliance review part the email has been already grouped, if not, create it individually
			if (notification.Compliance_Review_Part__c == null) {
				for (String notifType : contactRoleDetailIdToNotificationTypes.get(notification.IGOM_Contact_Role_Detail__c)) {
					// Instance a new email for the contact and with the appropriate template
					Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
					email.setTargetObjectId(contactRoleDetailIdToContactId.get(notification.IGOM_Contact_Role_Detail__c));
					// Try to use a template
					if (emailNameToTemplate.containsKey('IGOM Notification - ' + notification.Notification_Subject__c)) {
						email.setTemplateID(emailNameToTemplate.get('IGOM Notification - ' + notification.Notification_Subject__c).Id);
					} else {
						email.setSubject('New notification: ' + notification.Notification_Subject__c);
						email.setPlainTextBody('You have received a new notification\n\n' + notification.Notification_Body__c);
					}
					email.setSaveAsActivity(true);
					emails.add(email);
				}
			}
		}
	}
	
	public void andFinally() {
		if (!emails.isEmpty() && !(Test.isRunningTest() && bypassEmailsOnTest)) {
			Messaging.sendEmail(emails);
		}
	}
}