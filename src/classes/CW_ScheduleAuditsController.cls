public without sharing class CW_ScheduleAuditsController {
	@AuraEnabled
	public static string saveAudit(String icgNotificationObj, String certificationList) {
		List<CertData> certListDeserialized = (List<CertData>) JSON.deserialize(certificationList, List<CertData>.class);
		List<ICG_Notification__c> auditsToInsert = generateAuditsToInsert(icgNotificationObj, certListDeserialized);
		Set<Id> selectedCertifications = generateSelectedCertificationsIds(certListDeserialized);
		Map<String, Set<Id>> queuesToGet = generateQueuesToGet(selectedCertifications);
		
		List<Group> queues = [SELECT id, DeveloperName, (Select Id, UserOrGroupId from GroupMembers) FROM Group WHERE DeveloperName IN :queuesToGet.keySet() and Type='Queue'];
		Map<Id,User> users = queryUsers(queues);

		Map<Id,List<String>> managersPerQueueId = generateManagersPerQueueId(queues, users);

		Map<Id, Id> mapCertIdQueueId = generateMapCertIdQueueId(queues, queuesToGet);
		
		Id stakeHoldersId = generateStakeholdersId();

		managersPerQueueId = includeStakeholders(stakeHoldersId, managersPerQueueId);

		handleEmailsAndNotifications(stakeHoldersId, auditsToInsert, managersPerQueueId, mapCertIdQueueId);
			
		return 'ok';
	}

	private static Map<Id,List<String>> includeStakeholders(Id stakeHoldersId, Map<Id,List<String>> managersPerQueueId){
		if(stakeHoldersId != null){
			for(String email : CW_Utilities.getIATAStakeholdersEmails()) {
				if(managersPerQueueId.get(stakeHoldersId) == null) {
					managersPerQueueId.put(stakeHoldersId,new List<String>());
				}
				managersPerQueueId.get(stakeHoldersId).add(email);
			}
		}

		return managersPerQueueId;
	}

	private static Map<Id,List<String>> generateManagersPerQueueId(List<Group> queues, Map<Id,User> users) {
		Map<Id,List<String>> managersPerQueueId = new Map<Id,List<String>>();
		
		for(Group gr : queues){
			for (GroupMember grm : gr.GroupMembers){
				if(managersPerQueueId.get(gr.id) == null){
					managersPerQueueId.put(gr.id,new List<String>());
				} 
				managersPerQueueId.get(gr.id).add(users.get(grm.UserOrGroupId).Email);
			}
		}
		return managersPerQueueId;
	}

	private static void handleEmailsAndNotifications(Id stakeHoldersId, List<ICG_Notification__c> auditsToInsert, Map<Id,List<String>> managersPerQueueId, Map<Id, Id> mapCertIdQueueId) {
		for (ICG_Notification__c notif : auditsToInsert) {
			notif.OwnerId = mapCertIdQueueId.get(notif.ICG_Certification__c) != null ? mapCertIdQueueId.get(notif.ICG_Certification__c) : stakeHoldersId;
		}

		if (!auditsToInsert.isEmpty()){
			insert auditsToInsert;
			User u = [Select id, Email from User where id =:UserInfo.getUserId()];

			CW_Utilities.sendEmailTemplate('Request_for_Audit_Conf_to_User', auditsToInsert[0].Id, u.Id, new List<String> {u.Email}, true);

			for(ICG_Notification__c nt : auditsToInsert){
				if(Limits.getLimitEmailInvocations()>0){
					if(nt.OwnerId != null && managersPerQueueId.get(nt.OwnerId) != null && !managersPerQueueId.get(nt.OwnerId).isEmpty()) {
						CW_Utilities.sendEmailTemplate('Request_for_Audit_to_IATA_SME', nt.Id, u.Id, managersPerQueueId.get(nt.OwnerId), false);
					}
				}
			}

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
		return JSON.serialize([SELECT id, name, Station__r.Name, Station__c, CreatedDate, ICG_certification__c, ICG_certification__r.Name, Station__r.Formatted_Address__c, Preferable_Audit_Date__c, Contact_Email__c, Contact_Name__c, Contact_Phone__c, Target_Contact__c, Short_Description__c, Status__c FROM ICG_Notification__c WHERE Station__c IN :managedFacilitiesSet AND Station__c != null ORDER BY CreatedDate]);
	}

	public class CertData {
		public String id { get; set; }
		public String name { get; set; }
	}
}