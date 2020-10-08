public without sharing class CW_ScheduleAuditsController {
	@AuraEnabled
	public static string saveAudit(String icgNotificationObj, String certificationList) {
		List<CertData> certListDeserialized = (List<CertData>) JSON.deserialize(certificationList, List<CertData>.class);
		List<ICG_Notification__c> auditsToInsert = generateAuditsToInsert(icgNotificationObj, certListDeserialized);
		Set<Id> selectedCertifications = generateSelectedCertificationsIds(certListDeserialized);
		Map<String, Set<Id>> queuesToGet = generateQueuesToGet(selectedCertifications);
		
		List<Group> queues = [SELECT id, DeveloperName, (Select Id, UserOrGroupId from GroupMembers) FROM Group WHERE DeveloperName IN :queuesToGet.keySet() and Type='Queue'];
		Map<Id,User> users = queryUsers(queues);

		Map<Id,Set<Id>> managersPerQueueId = generateManagersPerQueueId(queues, users);

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

	private static Map<Id,Set<Id>> generateManagersPerQueueId(List<Group> queues, Map<Id,User> users) {
		Map<Id,Set<Id>> managersPerQueueId = new Map<Id,Set<Id>>();
		
		for(Group gr : queues){
			for (GroupMember grm : gr.GroupMembers){
				if(managersPerQueueId.get(gr.id) == null){
					managersPerQueueId.put(gr.id,new Set<Id>());
				} 
				managersPerQueueId.get(gr.id).add(users.get(grm.UserOrGroupId).id);
			}
		}
		return managersPerQueueId;
	}

	private static void handleEmailsAndNotifications(Id stakeHoldersId, List<ICG_Notification__c> auditsToInsert, Map<Id,Set<Id>> managersPerQueueId, Map<Id, Id> mapCertIdQueueId) {
		List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
		
		for (ICG_Notification__c notif : auditsToInsert) {
			notif.OwnerId = mapCertIdQueueId.get(notif.ICG_Certification__c) != null ? mapCertIdQueueId.get(notif.ICG_Certification__c) : stakeHoldersId;
		}

		if (!auditsToInsert.isEmpty()){
			insert auditsToInsert;

			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Request_for_Audit_Conf_to_User', auditsToInsert[0].Station__c, new Set<Id> {UserInfo.getUserId()}));

			for(ICG_Notification__c nt : auditsToInsert){
				if(Limits.getLimitEmailInvocations()>0){
					if(nt.OwnerId != null && managersPerQueueId.get(nt.OwnerId) != null && !managersPerQueueId.get(nt.OwnerId).isEmpty()) {
						emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails('Request_for_Audit_to_IATA_SME', nt.Station__c, managersPerQueueId.get(nt.OwnerId)));
					}
				}
			}

		}

		CW_EmailManager.sendInternalEmails(emailsToBeSent);
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

	private static Map<Id,User> queryUsers(List<Group> queues) {
		Set<Id> usersToQuery = new Set<Id>();
		for(Group gr : queues){
			for (GroupMember grm : gr.GroupMembers){
				usersToQuery.add(grm.UserOrGroupId);
			}
		}
		return new Map<Id,User>([Select id, Email From User where id IN : usersToQuery and Email != null]);
	}

	private static Map<String, Set<Id>> generateQueuesToGet(Set<Id> selectedCertifications){
		Map<String, Set<Id>> queuesToGet = new Map<String, Set<Id>>();
		for (ICG_Certification__c cert : [SELECT id, Name, Department__c FROM ICG_Certification__c WHERE Id IN :selectedCertifications]) {
			if (cert.Department__c != null) {
				Set<Id> certIds = queuesToGet.get(cert.Department__c) != null ? queuesToGet.get(cert.Department__c) : new Set<Id>();
				certIds.add(cert.Id);
				queuesToGet.put(cert.Department__c, certIds);
			}
		}
		return queuesToGet;
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
		return JSON.serialize([SELECT id, name, Station__r.Name, Station__c, CreatedDate, ICG_certification__c, ICG_certification__r.Name, ICG_certification__r.Label__c, Station__r.Formatted_Address__c, Preferable_Audit_Date__c, Contact_Email__c, Contact_Name__c, Contact_Phone__c, Target_Contact__c, Short_Description__c, Status__c FROM ICG_Notification__c WHERE Station__c IN :managedFacilitiesSet AND Station__c != null ORDER BY CreatedDate DESC]);
	}

	public class CertData {
		public String id { get; set; }
		public String name { get; set; }
	}
}