public without sharing class File_Upload_Lookup_CTRL {

    /**
     * Aura enabled method to search a specified SObject for a specific string
     */
    @AuraEnabled
    public static Result[] lookup(String searchString, String sObjectAPIName, String searchConditions)
    {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        //String sanitizedSearchConditions = String.escapeSingleQuotes(searchConditions);

        List<Result> results = new List<Result>();

        // Build our SOSL query
        String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id ' + searchConditions + ')';

        // Execute the Query
        List<List<SObject>> searchList = search.query(searchQuery);

        Set<Id> contactIds = new Set<Id>();

        // Create a list of matches to return
        for (SObject so : searchList[0])
        {
            contactIds.add(so.Id);
        }


        //filter out duplicates
        Map<Id, String> resultsMap = new Map<Id, String>();

        List<Contact_Role_Service_Access__c> accesses = [SELECT Id, Contact__c, Contact__r.Name FROM Contact_Role_Service_Access__c WHERE Contact__c = :contactIds AND Status__c = 'Granted' AND Contact_Role__r.Contact_Roles__r.Name = 'GADM User'];
        for(Contact_Role_Service_Access__c access : accesses) {
            resultsMap.put(access.Contact__c, access.Contact__r.Name);
        }

        for(Id contactId : resultsMap.keySet()) {
            results.add(new Result(resultsMap.get(contactId), contactId));
        }

        return results;
    }

    /**
     * Inner class to wrap up an SObject Label and its Id
     */
    public class Result
    {
        @AuraEnabled
        public String SObjectLabel {get; set;}
        @AuraEnabled
        public Id SObjectId {get; set;}

        public Result(String sObjectLabel, Id sObjectId)
        {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }

}