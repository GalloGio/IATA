/**
* This trigger is run when an  Email Message is deleted.
* It will look for related Archvied Message to delete.

	NOTE :  All trigger are launch AFTER delete to be sure we won't have a circle
*
*/
trigger EmailMessageCheckBeforeDelete on EmailMessage (after delete) {
	List<String> ids = new List<String>();
	List<Id> caseIds = new List<Id>();
	for(EmailMessage em:trigger.old){
		ids.add(em.Id);
		caseIds.add(em.ParentId);
	}


	if(ids.size()>0){
		system.debug('[EmailMessageCheckBeforeDelete] deletion of   '+ids.size()+' EmailMessage reauested');
		List<Archived_Message__c> archived = [select Id from Archived_Message__c where Case__c in :caseIds and EmailMessage__c in :ids ];
		if(archived.size()>0){


			system.debug('[EmailMessageCheckBeforeDelete] involve deletion of   '+archived.size()+' Archived_Message__c ');
			delete archived;

		}
	}
}
