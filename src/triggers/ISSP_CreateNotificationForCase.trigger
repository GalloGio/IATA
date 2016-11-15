trigger ISSP_CreateNotificationForCase on Case (before update) {
	
	if (!ISSP_Case.preventTrigger){
		for(Case newCase:trigger.new){
			Case oldCase = trigger.oldMap.get(newCase.Id);
			if (newCase.BSPCountry__c != oldCase.BSPCountry__c){
				newCase.Country_concerned_by_the_query__c = newCase.BSPCountry__c;
			}
		}
	}
	
    //if(!Test.isRunningTest())
    ISSP_CreateNotification.CreateNotificationForSobjectList(trigger.new);
}