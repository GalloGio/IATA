public class IDCardApplicationTriggerHandler extends TriggerHandler {
	protected override List<Schema.SObjectType> getSObjectTypes(){
		return new List<Schema.SObjectType>{Case.SObjectType};
	}

	protected override List<Type> getAfterInsertActions(){
		return new List<Type>{
			ProcessIDCardMassApplications.class
		};
	}

	protected override List<Type> getAfterUpdateActions(){
		return new List<Type>{
			CloseCasesForCancelledIDCardApplications.class,
			ProcessIDCardMassApplications.class
		};
	}
}