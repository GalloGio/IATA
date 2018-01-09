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
        if(Trigger.isDelete){
            EF_LocationCodeHandler.verifyBaLocationCodeExistsOnContract(Trigger.old, Trigger.oldMap);
        }else{
            EF_LocationCodeHandler.verifyBaLocationCodeExistsOnContract(Trigger.new, Trigger.oldMap);
        }		
	}

}