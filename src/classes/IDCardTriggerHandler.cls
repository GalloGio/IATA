public class IDCardTriggerHandler extends TriggerHandler {
	protected override List<Schema.SObjectType> getSObjectTypes(){
		return new List<Schema.SObjectType>{ID_Card__c.SObjectType, Case.SObjectType, ID_Card_Application__c.SObjectType};
	}

	protected override List<Type> getBeforeInsertActions(){
		return new List<Type>{
			IDCardGenerateAndAssignCIN.class
		};
	}

	protected override List<Type> getBeforeUpdateActions(){
		return new List<Type>{
			IDCardCheckUserAdminOrAutomatedProcess.class
		};
	}

	protected override List<Type> getAfterUpdateActions(){
		return new List<Type>{
			IDCardCloseCaseAndCompleteApplication.class
		};
	}

}