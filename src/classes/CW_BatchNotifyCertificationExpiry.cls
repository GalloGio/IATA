/**
 * @description		Batch class to send email notification for expiring certifications
 *
 * Edit Log:
 * @history			2020/04/27  |  sf-621  |  Creation.
 */
public without sharing class CW_BatchNotifyCertificationExpiry implements Database.Batchable<SObject> {
	final String rtCertificationDevName = 'Certification';
	final String rtRemoteValidationDevName = 'Remote_Validation';
	final Map<String, Id> rtDevNameById = RecordTypeSingleton.getInstance().getRecordTypeObjIdMapForSpecfifiedNames('ICG_Capability_Assignment_Group__c', new List<String>{ rtCertificationDevName, rtRemoteValidationDevName });
	final String rtPrivateAreaNotification = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Notification__c', 'PrivateArea');
	
	/**
	 * @description		Method to collect the records or objects to be passed to the interface method execute
	 * @param			context <Database.BatchableContext>
	 * @return			Database.QueryLocator - prepared query
	 */
	public Database.QueryLocator start(Database.BatchableContext context) {
		ICG_Environment_Variables__c environmentVariables = CW_Utilities.getEnvironmentVariables();
		Decimal expiringValidationDays = environmentVariables.EXPIRING_VALIDATION_DAYS__c;
		return Database.getQueryLocator([
			SELECT 
				Id, RecordTypeId, CreatedById, Days_Until_Expiration__c, Upcoming_Expiration_Notification_Sent__c, Expired_Notification_Sent__c, ICG_Account_Role_Detail__c, ICG_Account_Role_Detail__r.Name, ICG_Certification__r.Label__c,
				ICG_Account_Role_Detail__r.Formatted_Address__c, ICG_Account_Role_Detail__r.Account_Role__r.Account__c, ICG_Account_Role_Detail__r.Account_Role__r.Account__r.RecordType.Name, ICG_Certification__r.Name, ICG_Certification__c, ICG_Certification__r.Department__c 
			FROM ICG_Capability_Assignment_Group__c 
			WHERE RecordTypeId IN :rtDevNameById.values() AND Is_Booked__c = false 
			AND ((Upcoming_Expiration_Notification_Sent__c = false AND Days_Until_Expiration__c <= :expiringValidationDays AND Days_Until_Expiration__c > 0)
			OR (Expired_Notification_Sent__c = false AND Days_Until_Expiration__c <= 0))
			]);
	}

	/**
	 * @description		This method sends emails related to the expiration of certifications and creates notifications
	 * @param			context <Database.BatchableContext>
	 * @param			scope <List of objects retrieved by query>
	 */
	public void execute(Database.BatchableContext context, List<ICG_Capability_Assignment_Group__c> scope) {
		List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();

		ICG_Environment_Variables__c environmentVariables = CW_Utilities.getEnvironmentVariables();
		Decimal expiringValidationDays = environmentVariables.EXPIRING_VALIDATION_DAYS__c;
		Set<Id> iataAdminIds = CW_EmailManager.getIataAdminsIds();
		List<ICG_Capability_Assignment_Group__c> asgmtGroupToUpdate = new List<ICG_Capability_Assignment_Group__c>();
		Map<String, Set<Id>> mapQueueDevNameListIds = new Map<String,Set<Id>>();
		for (ICG_Capability_Assignment_Group__c asgmtGroup : scope) {
			if(asgmtGroup.ICG_Certification__c != null && asgmtGroup.ICG_Certification__r.Department__c != null){
				mapQueueDevNameListIds.put(asgmtGroup.ICG_Certification__r.Department__c, new Set<Id>());
			}
		}
		if(!mapQueueDevNameListIds.keySet().isEmpty()){
			List<Group> queues = [SELECT id, DeveloperName, (Select Id, UserOrGroupId from GroupMembers) FROM Group WHERE DeveloperName IN :mapQueueDevNameListIds.keySet()];
			Set<Id> usersToQuery = new Set<Id>();
			for(Group gr : queues){
				for (GroupMember grm : gr.GroupMembers){
					usersToQuery.add(grm.UserOrGroupId);
				}
			}
			Map<Id,User> users = new Map<Id,User>([Select id, Email From User where id IN : usersToQuery and Email != null]);
			for(Group gr : queues){
				for (GroupMember grm : gr.GroupMembers){
					if(mapQueueDevNameListIds.get(gr.DeveloperName) == null){
						mapQueueDevNameListIds.put(gr.DeveloperName,new Set<Id>());
					}
					mapQueueDevNameListIds.get(gr.DeveloperName).add(users.get(grm.UserOrGroupId).id);
				}
			}
			if (!iataAdminIds.isEmpty()){
				for(String queueName : mapQueueDevNameListIds.keySet()) {
					if(mapQueueDevNameListIds.get(queueName).isEmpty()){
						mapQueueDevNameListIds.put(queueName,iataAdminIds);
					} 
				}
			}
		}
		List<ICG_Notification__c> notifications = new List<ICG_Notification__c>();

		for (ICG_Capability_Assignment_Group__c asgmtGroup : scope) {
			List<SObject> contacts = generateStationManagerCompanyAdmins(asgmtGroup);
			List<String> contactIds = generateContactIds(contacts);
			Set<Id> stationManagerCompanyAdminIds = generateStationManagerCompanyAdminIds(contacts);
			Boolean isUpcomingExpiration = (asgmtGroup.Days_Until_Expiration__c > 0);
			Boolean isExpiration = (asgmtGroup.Days_Until_Expiration__c <= 0 && asgmtGroup.Expired_Notification_Sent__c == false);
			Boolean isCertification = rtDevNameById.get(rtCertificationDevName) == asgmtGroup.RecordTypeId;
			String emailTemplateOne = getEmailTemplate('emailTemplateOne', isCertification, isUpcomingExpiration);
			String emailTemplateTwo = getEmailTemplate('emailTemplateTwo', isCertification, isUpcomingExpiration);	
			
			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(emailTemplateOne, asgmtGroup.Id,  stationManagerCompanyAdminIds));
						
			Set<Id> iataManagers = asgmtGroup.ICG_Certification__c != null && asgmtGroup.ICG_Certification__r.Department__c != null && !mapQueueDevNameListIds.get(asgmtGroup.ICG_Certification__r.Department__c).isEmpty() ? mapQueueDevNameListIds.get(asgmtGroup.ICG_Certification__r.Department__c) : iataAdminIds;
			
			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(emailTemplateTwo, asgmtGroup.Id,  iataManagers));

			String subject = getEmailText('subject', isCertification, isUpcomingExpiration, asgmtGroup);
			String body = getEmailText('body', isCertification, isUpcomingExpiration, asgmtGroup);			
			notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', contactIds, asgmtGroup.ICG_Account_Role_Detail__r, rtPrivateAreaNotification, false));
			
			
			Boolean submitted = CW_EmailManager.sendInternalEmails(emailsToBeSent);
			if (submitted || Test.isRunningTest()) {
				if (isUpcomingExpiration) {
					asgmtGroup.Upcoming_Expiration_Notification_Sent__c = true;
				} else {
					asgmtGroup.Expired_Notification_Sent__c = true;
				}
				asgmtGroupToUpdate.add(asgmtGroup);
			}			
		}
		if (asgmtGroupToUpdate.size() > 0) {
			update asgmtGroupToUpdate;
		}
		if(notifications.size() > 0){
			insert notifications;
		}
	}

	/**
	 * @description		This method is called after all batches are processed
	 * @param			context <Database.BatchableContext>
	 */
	public void finish(Database.BatchableContext context) {
		System.debug(LoggingLevel.FINE, '::::getStructurfinisheFacilities - doNothing ');
	}

	private String getEmailTemplate(String template, Boolean isCertification, Boolean isUpcomingExpiration){
		String emailTemplate;
		if(template == 'emailTemplateOne'){
			emailTemplate = isCertification ? (isUpcomingExpiration ? 'Cert_upcoming_exp_to_Stat_Man_Com_Adm' : 'Cert_Exp_to_Stat_Man_Comp_Adm' ) : (isUpcomingExpiration ? 'Expiration_upcoming_to_Sta_Man_Comp_adm' : 'Expired_RV_to_Station_Managers_Com_Adm');
		}else{
			emailTemplate = isCertification ? (isUpcomingExpiration ? 'Cert_upcoming_exp_to_IATA_Cert_Man' : 'Cert_Exp_to_IATA_Certification_Man'): (isUpcomingExpiration ? 'Expiration_upcoming_to_IATA_Cert_Man' : 'Expired_RV_to_IATA_Cert_Man');
		}
		return emailTemplate;
	}

	private String getEmailText(String type, Boolean isCertification, Boolean isUpcomingExpiration, ICG_Capability_Assignment_Group__c asgmtGroup){
		String emailText;
		if(type == 'subject'){
			emailText = isCertification ? (asgmtGroup.ICG_Certification__r.Label__c + ' certification/accreditation of ' + asgmtGroup.ICG_Account_Role_Detail__r.Name + ', '  + (isUpcomingExpiration ? ' about to expire' : ' expired')) 
			: ('Remote validation of ' + asgmtGroup.ICG_Account_Role_Detail__r.Name + ', ' + (isUpcomingExpiration ? ' about to expire' : ' expired'));
		}else{
			emailText = isCertification ? (asgmtGroup.ICG_Certification__r.Label__c + ' certification/accreditation of ' + asgmtGroup.ICG_Account_Role_Detail__r.Name + ', ' + asgmtGroup.ICG_Account_Role_Detail__r.Formatted_Address__c + (isUpcomingExpiration ? ' about to expire' : ' expired')) 
			: ('Remote validation of ' + asgmtGroup.ICG_Account_Role_Detail__r.Name + ', '  + asgmtGroup.ICG_Account_Role_Detail__r.Formatted_Address__c + (isUpcomingExpiration ? ' about to expire' : ' expired'));
		}
		return emailText;
	}

	private static Set<Id> generateStationManagerCompanyAdminIds(List<SObject> contacts) {
		Set<Id> stationManagerCompanyAdminIds = new Set<Id>();

		for (SObject contact : contacts) {
			if (contact instanceof ICG_Contact_Role_Detail__c) {
				ICG_Contact_Role_Detail__c convertedContact = (ICG_Contact_Role_Detail__c) contact;
				stationManagerCompanyAdminIds.add(convertedContact.Account_Contact_Role__r.Contact__c);
			} else if (contact instanceof Contact) {
				Contact convertedContact = (Contact) contact;
				stationManagerCompanyAdminIds.add(convertedContact.Id);
			}
		}

		return stationManagerCompanyAdminIds;
	}

	private static List<String> generateContactIds(List<SObject> listOfUsers) {
		List<String> contactIds = new List<String>();
		for (SObject obj : listOfUsers) {
			if (obj instanceof ICG_Contact_Role_Detail__c) {
				ICG_Contact_Role_Detail__c convertedObj = (ICG_Contact_Role_Detail__c) obj;
				contactIds.add(convertedObj.Account_Contact_Role__r.Contact__c);
			} else if (obj instanceof Contact) {
				Contact convertedObj = (Contact) obj;
				contactIds.add(convertedObj.Id);
			}
		}
		return contactIds;
	}

	private static List<SObject> generateStationManagerCompanyAdmins(ICG_Capability_Assignment_Group__c cert) {
		List<SObject> stationManagerCompanyAdmins = new List<SObject>();
		for (ICG_Contact_Role_Detail__c crd : CW_Utilities.getStationManagersContactRoleDetails(cert.ICG_Account_Role_Detail__c)) {
			stationManagerCompanyAdmins.add(crd);
		}
		for (Contact cadmn : CW_Utilities.getCompanyAdminContactsFromAccountId(cert.ICG_Account_Role_Detail__r.Account_Role__r.Account__c)) {
			stationManagerCompanyAdmins.add(cadmn);
		}

		return stationManagerCompanyAdmins;
	}
}