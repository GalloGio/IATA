trigger EventReleases on IEC_Event_Release__c (after delete, after insert, after update, before delete, before insert, before update)
{
	IEC_EventRelease_Dom.triggerHandler();
}
