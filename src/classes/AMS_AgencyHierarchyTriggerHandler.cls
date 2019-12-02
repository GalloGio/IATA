public class AMS_AgencyHierarchyTriggerHandler extends TriggerHandler {

	protected override List<Schema.SObjectType> getSObjectTypes(){
		return new List<Schema.SObjectType>{};
	}

	protected override List<Type> getBeforeInsertActions(){
		return new List<Type>{
			ANG_AgencyHierarchyUniqueVerifier.class
			};
	}

	protected override List<Type> getBeforeUpdateActions(){
		return new List<Type>{
			ANG_AgencyHierarchyUniqueVerifier.class
		};
	}
}
