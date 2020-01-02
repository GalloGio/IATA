public with sharing class AMS_OSCAR_RelatedCasesController {

	public String oscarId {get;set;}
	public AMS_IntegerCarrier intVal {get; set;}

	public AMS_OSCAR_RelatedCasesController() {
	}

	public List<Case> getcases(){
		List<Case> cases = [select id, CaseNumber, Type, CreatedDate from Case where OSCAR__c = :oscarId and RecordType.Name != 'OSCAR Communication'];
		intVal.value = cases.size();
		return cases;
	}

	public PageReference createNewCase()
	{
		return new PageReference('/500/e?retURL=%2F500%2Fo');
	}
}
