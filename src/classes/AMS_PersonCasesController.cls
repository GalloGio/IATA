public class AMS_PersonCasesController {

	private AMS_Person__c person;
	public List<Case> cases;
	public Boolean casesAvailable {get;set;}

	public AMS_PersonCasesController(ApexPages.StandardController stdController) {

		this.person = (AMS_Person__c)stdController.getRecord();
		this.person = [select Contact__c from AMS_Person__c where id =: this.person.id];


	}

	public List<Case> getCases(){

		if(person.Contact__c != null){
			if(cases == null)
				cases = [SELECT Id, CaseNumber, Subject, CreatedDate, Status, Account.Name, AccountId, Owner.Name, OwnerId FROM Case WHERE ContactId =: person.Contact__c];
		}

		casesAvailable = false;

		if(cases!=null && cases.size() > 0)
			casesAvailable = true;

		return cases;

	}

}
