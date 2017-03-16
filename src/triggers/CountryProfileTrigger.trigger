trigger CountryProfileTrigger on Country_Profile__c (after insert, before update, after update) {

	//execute before methods
	//prevent this to fire twice (there is a WF rule in place to clear the news and notification fields)
	if(Trigger.isBefore) {
		if (Trigger.isUpdate && CountryProfileTriggerHandler.firstExec) {
			CountryProfileTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
		}
		
		if (Trigger.isInsert || Trigger.isUpdate) {
			CountryProfileTriggerHandler.PopulateIsoCode(Trigger.new);
		}
	}
	//execute after methods
	if(Trigger.isAfter) {
		if (Trigger.isInsert) {
			CountryProfileTriggerHandler.SubscribeUsersToNewCountryProfile(Trigger.newMap);
		}
		
		if (Trigger.isInsert || Trigger.isUpdate) {
			CountryProfileTriggerHandler.CreateUpdateFeedsSendNotifications(Trigger.newMap);
		}
	}
	//set firstExec to false to prevent second execution of history-related methods
	CountryProfileTriggerHandler.firstExec = false;

}