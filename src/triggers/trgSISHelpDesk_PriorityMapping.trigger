trigger trgSISHelpDesk_PriorityMapping on Priority_Mapping__c (before insert, before update)
{
	List<Priority_Mapping__c> priorityMappingList;
	if(trigger.isInsert)
	{
		if(trigger.isBefore)
		{
			priorityMappingList = [SELECT Application__c, Case_Classification__c, Case_Reason__c, Case_Type__c FROM Priority_Mapping__c];
			for(Priority_Mapping__c newPriorityMapping : Trigger.new)
			{
				for(Priority_Mapping__c priorityMapping : priorityMappingList)
				{
					if(newPriorityMapping.Application__c == priorityMapping.Application__c
					   && newPriorityMapping.Case_Classification__c == priorityMapping.Case_Classification__c
					   && newPriorityMapping.Case_Reason__c == priorityMapping.Case_Reason__c
					   && newPriorityMapping.Case_Type__c == priorityMapping.Case_Type__c)
					{
						newPriorityMapping.addError(Label.SISHelpDesk_ExistingPriorityMapping);

					}
				}
			}
		}
	}
	if(trigger.isUpdate)
	{
		if(trigger.isBefore)
		{
			priorityMappingList = [SELECT Application__c, Case_Classification__c, Case_Reason__c, Case_Type__c FROM Priority_Mapping__c];
			for(Priority_Mapping__c newPriorityMapping : Trigger.new)
			{
				for(Priority_Mapping__c priorityMapping : priorityMappingList)
				{
					if(newPriorityMapping.Application__c == priorityMapping.Application__c
					   && newPriorityMapping.Case_Classification__c == priorityMapping.Case_Classification__c
					   && newPriorityMapping.Case_Reason__c == priorityMapping.Case_Reason__c
					   && newPriorityMapping.Case_Type__c == priorityMapping.Case_Type__c)
					{
						newPriorityMapping.addError(Label.SISHelpDesk_ExistingPriorityMapping);

					}
				}
			}
		}
	}

}
