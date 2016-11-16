trigger EF_LocationCodeTrigger on EF_Location_Code__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete)
{
	
	if(Trigger.isBefore)
	{
		EF_LocationCodeHandler.verifyBaLocationCodeExistsOnContract(Trigger.new, Trigger.oldMap);
	}

}