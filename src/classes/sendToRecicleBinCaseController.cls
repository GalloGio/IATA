public class sendToRecicleBinCaseController {

//Method used to Find Recycle Queue Based on the Record's Region
@AuraEnabled(cacheable=true)
public static String findRecycleQueue(String searchKey) {
    //checks searchKey
    if (String.isBlank(searchKey)) {
        return '';
    }   
    
    //grabs Case
    Case c = [SELECT Id, Region__c FROM Case WHERE Id =:searchKey LIMIT 1];

    //Recycle Queues are always set as "Recycle Bin + (Region of Case)"
    String queueName = 'Recycle Bin ' + c.Region__c;

    //Grabs the Queue
    Group g = [select Id from Group where Type = 'Queue' and Name =: queueName LIMIT 1];

    if(g != null){
        //Returns Queue Id to Web Component to assign the Owner of the Case
        return g.id;
    }
    return '';
}
}
