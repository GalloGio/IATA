trigger Product_Term_Conditions on Product_Term_Condition__c (before insert, before update, before delete, after insert, after update, after delete)
{
	Product_Term_Condition_Dom.triggerHandler();
}
