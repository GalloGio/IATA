public without sharing class CW_ScheduleAuditsController {
	@AuraEnabled
	public static string saveAudit(String icgNotificationObj, String certificationList) {
		Set<Id> setQueuesIds = new Set<Id>();
		Map<Id,Set<Id>> managersPerQueueId = new Map<Id,Set<Id>>();
		List<CertData> certListDeserialized = (List<CertData>) JSON.deserialize(certificationList, List<CertData>.class);
		List<ICG_Notification__c> auditsToInsert = generateAuditsToInsert(icgNotificationObj, certListDeserialized);
		Set<Id> selectedCertifications = generateSelectedCertificationsIds(certListDeserialized);
		Map<String, Set<Id>> queuesToGet = generateQueuesToGet(selectedCertifications);
		
		List<Group> queues = [SELECT id, DeveloperName, (Select Id, UserOrGroupId from GroupMembers) FROM Group WHERE DeveloperName IN :queuesToGet.keySet() and Type='Queue'];
			
		for(Group queue :queues){
			setQueuesIds.add(queue.Id);
		}
		setGroupUsersMap(managersPerQueueId, setQueuesIds, null);
		Map<Id, Id> mapCertIdQueueId = generateMapCertIdQueueId(queues, queuesToGet);
		
		Id stakeHoldersId = generateStakeholdersId();

		managersPerQueueId = includeStakeholders(stakeHoldersId, managersPerQueueId);

		handleEmailsAndNotifications(stakeHoldersId, auditsToInsert, managersPerQueueId, mapCertIdQueueId);
			
		return 'ok';
	}

	private static Map<Id,Set<Id>> includeStakeholders(Id stakeHoldersId, Map<Id,Set<Id>> managersPerQueueId){
		if(stakeHoldersId != null){
			if(managersPerQueueId.get(stakeHoldersId) == null) {
				managersPerQueueId.put(stakeHoldersId,new Set<Id>());
			}
			managersPerQueueId.get(stakeHoldersId).addAll(CW_EmailManager.getIataAdminsIds());
		}

		return managersPerQueueId;
	}

	private static void handleEmailsAndNotifications(Id stakeHoldersId, List<ICG_Notification__c> auditsToInsert, Map<Id,Set<Id>> managersPerQueueId, Map<Id, Id> mapCertIdQueueId) {
		List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
	
		for (ICG_Notification__c notif : auditsToInsert) {
			notif.OwnerId = mapCertIdQueueId.get(notif.ICG_Certification__c) != null ? mapCertIdQueueId.get(notif.ICG_Certification__c) : stakeHoldersId;			
		}

		if (!auditsToInsert.isEmpty() && ICG_Notification__c.SObjectType.getDescribe().isAccessible()){			
			insert auditsToInsert;			

			//Share inserted notification records to Requestor (current owner is the certification queue)
			shareAuditNotificationsWithRequetor(auditsToInsert);			

			String subject = 'Audit request sent';
			List<String> notificationReceivers = new List<String>();			
		
			for(ICG_Notification__c nt : auditsToInsert){
				//notification requestor norification 
				notificationReceivers.add(nt.Target_Contact__c);
				if(Limits.getLimitEmailInvocations() > 0){
					//Prepare emails to requestor							
					emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Request_for_Audit_Conf_to_User', nt.Id, new Set<Id> {UserInfo.getUserId()}));
					if(nt.OwnerId != null && managersPerQueueId.get(nt.OwnerId) != null && !managersPerQueueId.get(nt.OwnerId).isEmpty()) {	
						//Prepare emails to IATA admis	
						emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Request_for_Audit_to_IATA_SME', nt.Id, managersPerQueueId.get(nt.OwnerId)));	
					}
				}
			}
			
			//Add Community notification to requestor
			CW_NotificationsController.setNotificationCustom(subject, subject, 'Requested', notificationReceivers, auditsToInsert[0].Station__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA);
				
			//Send emails
			CW_EmailManager.sendInternalEmails(emailsToBeSent);			
		}
	}

	private static Id generateStakeholdersId(){
		Id stakeHoldersId;
		List<Group> stakeholders = [SELECT Id FROM group WHERE DeveloperName = 'ICG_Stakeholders'];
		if (!stakeholders.isEmpty()){
			stakeHoldersId = stakeholders[0].Id;	
		}

		return stakeHoldersId;
	}

	private static Map<Id, Id> generateMapCertIdQueueId(List<Group> queues, Map<String, Set<Id>> queuesToGet){

		Map<Id, Id> mapCertIdQueueId = new Map<Id, Id>();

		for (Group gc : queues) {
			Set<Id> certs = queuesToGet.get(gc.DeveloperName);
			for (Id crtId : certs) {
				mapCertIdQueueId.put(crtId, gc.Id);
			}
		}

		return mapCertIdQueueId;
	}
	
	private static void setGroupUsersMap(Map<Id,Set<Id>> mapUsersByGroup, Set<Id> groupIds, Map<Id, Id> subgroupsbyParentMap){
		Map<Id, Id> subgroupbyParentIds = new Map<Id, Id>();
		for(GroupMember grm: [SELECT Id, UserOrGroupId, groupId FROM GroupMember where groupId IN :groupIds]){			
			if((grm.UserOrGroupId).getSobjectType() == Schema.User.SObjectType){
				addMapMember(mapUsersByGroup, subgroupsbyParentMap != null && subgroupsbyParentMap.containskey(grm.groupId) ? subgroupsbyParentMap.get(grm.groupId) : grm.groupId, grm.UserOrGroupId);
			}else if((grm.UserOrGroupId).getSobjectType() == Schema.Group.SObjectType){
				subgroupbyParentIds.put(grm.UserOrGroupId, grm.groupId);
			}
		}
		if(!subgroupbyParentIds.isEmpty()){			
			setGroupUsersMap(mapUsersByGroup, subgroupbyParentIds.keySet(), subgroupbyParentIds);
		}			
	}

	private static void addMapMember(Map<Id,Set<Id>> mapValuesBykey, Id key, Id value){
		if(mapValuesBykey != null){
			if(mapValuesBykey.containsKey(key)){
				mapValuesBykey.get(key).add(value);
			}else{
				Set<Id> setValues = new Set<Id>();
				setValues.add(value);
				mapValuesBykey.put(key, setValues);
			}
		}else{
			mapValuesBykey = new Map<Id,Set<Id>>();
			Set<Id> setValues = new Set<Id>();
			setValues.add(value);
			mapValuesBykey.put(key, setValues);
		}
	}

	private static Map<String, Set<Id>> generateQueuesToGet(Set<Id> selectedCertifications){
		List<String> listValidationPrograms = String.isNotBlank(CW_Utilities.VALIDATION_PROGRAMS) ? CW_Utilities.VALIDATION_PROGRAMS.split(',') : new List<String>();

		Map<String, Set<Id>> queuesToGet = new Map<String, Set<Id>>();
		for (ICG_Certification__c cert : [SELECT id, Name, Department__c FROM ICG_Certification__c WHERE Id IN :selectedCertifications AND ValidationPrograms__c IN: listValidationPrograms]) {
			if (cert.Department__c != null) {
				Set<Id> certIds = queuesToGet.get(cert.Department__c) != null ? queuesToGet.get(cert.Department__c) : new Set<Id>();
				certIds.add(cert.Id);
				queuesToGet.put(cert.Department__c, certIds);
			}
		}
		return queuesToGet;
	}

	private static void shareAuditNotificationsWithRequetor(List<ICG_Notification__c> auditNotifications){
		List<ICG_Notification__Share> notifShrLst  = new List<ICG_Notification__Share>();  
		Schema.DescribeSObjectResult notifDescribe = ICG_Notification__c.sObjectType.getDescribe();
		
		for (ICG_Notification__c notif : auditNotifications) {	
			ICG_Notification__Share notifShr  = new ICG_Notification__Share();
			// Set the ID of record being shared.
			notifShr.ParentId = notif.Id;			  
			// Set the ID of user or group being granted access.
			notifShr.UserOrGroupId = UserInfo.getUserId();
			notifShr.AccessLevel = 'Read';			 
			notifShrLst.add(notifShr);
		}	

		if(!notifShrLst.isEmpty() && notifDescribe.isAccessible()){			
			for(Database.SaveResult sr :Database.insert(notifShrLst, false)){
				if(!sr.isSuccess()){					
					Database.Error err = sr.getErrors()[0];
					System.debug(LoggingLevel.FINE, '____[CW_ScheduleAuditsController - shareAuditNotificationsWithRequetor] Error sharing audit notifications with requestor: ' + err.getMessage());
					throw new AuraHandledException('Error sharing audit notifications with requestor: ' + err.getMessage());
				}
			}			
		}
	}

	private static Set<Id> generateSelectedCertificationsIds(List<CertData> certListDeserialized) {
		Set<Id> selectedCertifications = new Set<Id>();
		for (CertData cdt : certListDeserialized) {
			selectedCertifications.add(cdt.id);
		}
		return selectedCertifications;
	}

	private static List<ICG_Notification__c> generateAuditsToInsert (String icgNotificationObj, List<CertData> certListDeserialized) {
		List<ICG_Notification__c> auditsToInsert = new List<ICG_Notification__c>();

		for (CertData cdt : certListDeserialized) {
			ICG_Notification__c icgNotif = (ICG_Notification__c) JSON.deserialize(icgNotificationObj, ICG_Notification__c.class);
			icgNotif.ICG_Certification__c = cdt.id;
			icgNotif.Short_Description__c = 'Audit Schedule';
			icgNotif.Status__c = 'Requested';
			icgNotif.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Notification__c', 'Audit');
			auditsToInsert.add(icgNotif);
		}

		return auditsToInsert;
	}

	@AuraEnabled
	public static string getUserRequestedAudits(List<String> managedFacilitiesIds) {
		Set<String> managedFacilitiesSet = managedFacilitiesIds != null ? new Set<String>(managedFacilitiesIds) : new Set<String>();
		Id auditRT = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Notification__c', 'Audit');
		return JSON.serialize([SELECT id, name, Station__r.Name, Station__c, CreatedDate, ICG_certification__c, ICG_certification__r.Name, ICG_certification__r.Label__c, Station__r.Formatted_Address__c, Preferable_Audit_Date__c, Contact_Email__c, Contact_Name__c, Contact_Phone__c, Target_Contact__c, Short_Description__c, Status__c FROM ICG_Notification__c WHERE Station__c IN :managedFacilitiesSet AND Station__c != null AND RecordTypeId = :auditRT ORDER BY CreatedDate DESC]);
	}

	public class CertData {
		public String id { get; set; }
		public String name { get; set; }
	}
}