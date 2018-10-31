public class PriceTableTriggerHandler extends TriggerHandler {
	protected override List<Schema.SObjectType> getSObjectTypes(){
		return new List<Schema.SObjectType>();
	}

	protected override List<Type> getBeforeInsertActions(){
		return new List<Type>{
			PriceTableAddErrorForDuplicates.class
		};
	}

	protected override List<Type> getBeforeUpdateActions(){
		return new List<Type>{
			PriceTableAddErrorForDuplicates.class
		};
	}
}