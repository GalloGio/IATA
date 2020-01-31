public class AttachmentTriggerHelper {

	public static Boolean preventTrigger = false;

	public static void onAfterInsert(list<Attachment> newAttachmentList, map<ID, Attachment> newAttachmentMap, List<Profile> profileList) {

		//Boolean hasUserLimitedPermissions  = ArchiveAttachmentListController.hasUserLimitedPermissions();
		//system.debug('SFII After hasUserLimitedPermissions' +hasUserLimitedPermissions);

		Boolean isEmail2Case = false;
		//List<Profile> profileList = [Select Id,Name from Profile where Id = :Userinfo.getProfileId()];
		List<ISSPAttachmentPermission__c> newPermToInsert_List =  new 	List<ISSPAttachmentPermission__c>();
		if (!profileList.isEmpty())
		{
			String profileName = profileList[0].Name;
			if (profileName == 'System Administrator - Email2Case'){
				isEmail2Case = true;
			}
		}

		for(Attachment att : newAttachmentList) {

			if(null == att.ParentId || !'case'.equalsIgnoreCase(att.ParentId.getSObjectType().getDescribe().getName()))
				  continue;

			//if(!hasUserLimitedPermissions && !isEmail2Case){
			if(!isEmail2Case){
				Boolean hasUserLimitedPermissions  = ArchiveAttachmentListController.hasUserLimitedPermissions();
				system.debug('SFII After hasUserLimitedPermissions' +hasUserLimitedPermissions);
				if (!hasUserLimitedPermissions){
					//TF - SP8-US196
					ISSPAttachmentPermission__c newPerm = new ISSPAttachmentPermission__c();
					newPerm.AttachmentId__c = att.Id;
					newPerm.ShowToPortalUsers__c = false;
					newPermToInsert_List.add(newPerm);
				}
			}
		}

		if(newPermToInsert_List != null && newPermToInsert_List.size() > 0){
			insert newPermToInsert_List ;
		}
	}

	@future
	public static void makeAllPublic (Set <Id> caseIds){
		system.debug('Starting makeAllPublic future');
		List <Attachment> attachList = [SELECT Id FROM Attachment WHERE ParentId IN :caseIds];
		if (!attachList.isEmpty()){
			Set <Id> attachIds = new Set <Id>();
			Map <Id, Id> attachIdMap = new Map <Id, Id>();
			for (Attachment thisAttach : attachList){
				attachIds.add(thisAttach.Id);
				attachIdMap.put(thisAttach.Id, thisAttach.Id);
			}
			if (!attachIds.isEmpty()){
				List <ISSPAttachmentPermission__c> listPerm = [SELECT Id, ShowToPortalUsers__c,
														AttachmentId__c
														FROM ISSPAttachmentPermission__c
														WHERE AttachmentId__c IN :attachIds];
				if (!listPerm.isEmpty()){
					for (ISSPAttachmentPermission__c thisPerm : listPerm){
						attachIdMap.remove(thisPerm.AttachmentId__c);
						if (!thisPerm.ShowToPortalUsers__c){
							thisPerm.ShowToPortalUsers__c = true;
						}
					}
					system.debug('update: ' + listPerm.size());
					update listPerm;
				}
				List <Id> attachIdsToCreate = attachIdMap.values();
				List <ISSPAttachmentPermission__c> newPermList = new List <ISSPAttachmentPermission__c>();
				for (Id thisId : attachIdsToCreate){
					ISSPAttachmentPermission__c newPerm = new ISSPAttachmentPermission__c();
					newPerm.AttachmentId__c = thisId;
					newPerm.ShowToPortalUsers__c = true;
					newPermList.add(newPerm);
				}

				if (!newPermList.isEmpty()){
					system.debug('insert: ' + newPermList.size());
					insert newPermList;
				}
			}
		}

	}

}
