public with sharing class FunctionalRoles_mdt {
	public List<Functional_Role__mdt> records { get; private set; }

	public FunctionalRoles_mdt(){
		records = new List<Functional_Role__mdt>();
	}

	public FunctionalRoles_mdt(List<Functional_Role__mdt> functionalRoleMDTList){
		records = functionalRoleMDTList.clone();
	}

	//return a 'default' Functional_Role_mdt record (ONLY USED TO DEFAULT AND RETURN MANDATORY FIELDS)
	public Functional_Role__mdt createDefaultFunctionalRoleMDT(){
		Functional_Role__mdt functionalRole_mdt = (Functional_Role__mdt) Schema.getGlobalDescribe().get('Functional_Role__mdt').newSObject();
		functionalRole_mdt.MasterLabel = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		return functionalRole_mdt;
	}

	public class FunctionalRoles_mdtDomainException extends Exception {}
}