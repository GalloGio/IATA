trigger Term_And_Conditions on Term_And_Condition__c (before insert, before update,	before delete, after insert, after update, after delete) 
{
	Term_And_Condition_Dom.triggerHandler();
}