public class sendToRecicleBinCaseController {

//Method used to Find Recycle Queue Based on the Record's Region
@AuraEnabled(cacheable=true)
public static String findRecycleQueue(String searchKey) {
	//checks searchKey
	if (String.isBlank(searchKey)) {
		return '';
	}

	//grabs Case
	list<Case> caseList = [SELECT Id, Region__c FROM Case WHERE Id =:searchKey LIMIT 1];

	if(caseList.isEmpty())return '';
	//Recycle Queues are always set as "Recycle Bin + (Region of Case)"
	String queueName = 'RecycleBin' + caseList.get(0).Region__c;
	queueName=queueName.replace('&','').replace(' ','').replace('China',''); // removes extra characters and China scenario
	//Grabs the Queue
	list<Group> groupList = [select Id from Group where Type = 'Queue' and developername =: queueName LIMIT 1];

	if(!groupList.isEmpty()){
		//Returns Queue Id to Web Component to assign the Owner of the Case
		return groupList.get(0).id;
	}
	return '';
}
}
