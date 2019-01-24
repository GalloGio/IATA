trigger InstantSurveyTrigger on Instant_Surveys__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
	if (trigger.isInsert && trigger.isBefore) {
		InstantSurveyTriggerHelper.PreventMultipleSurveysOnSameCase(trigger.new);
		InstantSurveyTriggerHelper.fillDataFromCase(trigger.new); //ACAMBAS - WMO-392
	}
	
}