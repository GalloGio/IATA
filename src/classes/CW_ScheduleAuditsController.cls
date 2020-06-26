public without sharing class CW_ScheduleAuditsController {
	@AuraEnabled
	public static string saveAudit(String icgNotificationObj, String certificationList) {
		List<ICG_Notification__c> auditsToInsert = new List<ICG_Notification__c>();
		List<CertData> certListDeserialized = (List<CertData>) JSON.deserialize(certificationList, List<CertData>.class);
		Set<Id> selectedCertifications = new Set<Id>();
		//Create one notification per certification selected to be audited.
		for (CertData cdt : certListDeserialized) {
			ICG_Notification__c icgNotif = (ICG_Notification__c) JSON.deserialize(icgNotificationObj, ICG_Notification__c.class);
			icgNotif.ICG_Certification__c = cdt.id;
			icgNotif.Short_Description__c = 'Audit Schedule';
			icgNotif.Status__c = 'Requested';
			icgNotif.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Notification__c', 'Audit');
			auditsToInsert.add(icgNotif);
			selectedCertifications.add(cdt.id);
		}
		List<ICG_Certification__c> certifs = [SELECT id, Name, Department__c FROM ICG_Certification__c WHERE Id IN :selectedCertifications];
		Map<String, Set<Id>> queuesToGet = new Map<String, Set<Id>>();
		//Get all the Queues assigned per certification.
		for (ICG_Certification__c cert : certifs) {
			if (cert.Department__c != null) {
				Set<Id> certIds = queuesToGet.get(cert.Department__c) != null ? queuesToGet.get(cert.Department__c) : new Set<Id>();
				certIds.add(cert.Id);
				queuesToGet.put(cert.Department__c, certIds);
			}
		}
		List<Group> queues = [SELECT id, DeveloperName, (Select Id, UserOrGroupId from GroupMembers) FROM Group WHERE DeveloperName IN :queuesToGet.keySet() and Type='Queue'];
		Map<Id,List<String>> managersPerQueueId = new Map<Id,List<String>>();
		Set<Id> usersToQuery = new Set<Id>();
		for(Group gr : queues){
			for (GroupMember grm : gr.GroupMembers){
				usersToQuery.add(grm.UserOrGroupId);
			}
		}
		Map<Id,User> users = new Map<Id,User>([Select id, Email From User where id IN : usersToQuery and Email != null]);
		for(Group gr : queues){
			for (GroupMember grm : gr.GroupMembers){
				if(managersPerQueueId.get(gr.id) == null) managersPerQueueId.put(gr.id,new List<String>());
				managersPerQueueId.get(gr.id).add(users.get(grm.UserOrGroupId).Email);
			}
		}
		Map<Id, Id> mapCertIdQueueId = new Map<Id, Id>();
		//Get all the groups and create a map certification Id with Queue Id.
		for (Group gc : queues) {
			Set<Id> certs = queuesToGet.get(gc.DeveloperName);
			for (Id crtId : certs) {
				mapCertIdQueueId.put(crtId, gc.Id);
			}
		}
		Id stakeHoldersId;
		List<Group> stakeholders = [SELECT Id FROM group WHERE DeveloperName = 'ICG_Stakeholders'];
		if (!stakeholders.isEmpty()){
			stakeHoldersId = stakeholders[0].Id;
			for(User u : CW_Utilities.getIATAStakeHoldersUsersList()) {
				if(u.Email != null) {
					if(managersPerQueueId.get(stakeHoldersId) == null) managersPerQueueId.put(stakeHoldersId,new List<String>());
					managersPerQueueId.get(stakeHoldersId).add(u.Email);
				}
			}
		}
		//Assign each notification to the corresponding queue, depending on selected certification.
		for (ICG_Notification__c notif : auditsToInsert) {
			notif.OwnerId = mapCertIdQueueId.get(notif.ICG_Certification__c) != null ? mapCertIdQueueId.get(notif.ICG_Certification__c) : stakeHoldersId;
		}



		if (!auditsToInsert.isEmpty()){
			insert auditsToInsert;
			User u = [Select id, Email from User where id =:UserInfo.getUserId()];
			//Send confirmation to requestor
			CW_Utilities.sendEmailTemplate('Request_for_Audit_Conf_to_User', auditsToInsert[0].Id, u.Id, new List<String> {u.Email});
			//Send to IATA SME
			for(ICG_Notification__c nt : auditsToInsert){
				if(Limits.getLimitEmailInvocations()>0){
					if(nt.OwnerId != null && managersPerQueueId.get(nt.OwnerId) != null && !managersPerQueueId.get(nt.OwnerId).isEmpty()) CW_Utilities.sendEmailTemplate('Request_for_Audit_to_IATA_SME', nt.Id, u.Id, managersPerQueueId.get(nt.OwnerId));
				}
			}

		}
			
		return 'ok';
	}

	@AuraEnabled
	public static string getUserRequestedAudits(List<String> managedFacilitiesIds) {
		Set<String> managedFacilitiesSet = managedFacilitiesIds != null ? new Set<String>(managedFacilitiesIds) : new Set<String>();
		return JSON.serialize([SELECT id, name, Station__r.Name, Station__c, CreatedDate, ICG_certification__c, ICG_certification__r.Name, Station__r.Formatted_Address__c, Preferable_Audit_Date__c, Contact_Email__c, Contact_Name__c, Contact_Phone__c, Target_Contact__c, Short_Description__c, Status__c FROM ICG_Notification__c WHERE Station__c IN :managedFacilitiesSet AND Station__c != null]);
	}

	public class CertData {
		public String id { get; set; }
		public String name { get; set; }
	}
}