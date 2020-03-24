public with sharing class AMS_OSCAR_CommunicationController {

	public AMS_OSCAR__c oscar;
	public Case c {get;set;}

	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	public AMS_OSCAR_CommunicationController(ApexPages.StandardController stdController) {

		this.oscar = (AMS_OSCAR__c)stdController.getRecord();

		List<Case> tempCaseList = [Select id from Case where OSCAR__c = :this.oscar.id and RecordType.Name = 'OSCAR Communication' AND ParentId = null limit 1];
		if(tempCaseList.size() > 0)
			c = tempCaseList.get(0);
	}
}
