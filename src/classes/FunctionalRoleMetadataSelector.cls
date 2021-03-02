public class FunctionalRoleMetadataSelector {

	public static Functional_Role__mdt selectByName(String functionalRoleName){
		List<Functional_Role__mdt> functionalRoleList = [SELECT Id FROM Functional_Role__mdt WHERE Label = :functionalRoleName];
		if(functionalRoleList.isEmpty())
			return null;
		return functionalRoleList.get(0);
	}
}