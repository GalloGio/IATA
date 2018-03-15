trigger localgovernanceMeetingTrigger on LocalGovernance_Meeting__c (before delete) {

	if(Trigger.isBefore && Trigger.isDelete) {

		LocalGovernanceMeetingTriggerHelper.deleteOnlyIfLocalGovernanceIsActive(trigger.oldMap);

	}

}
