/**
 * A cleanup batch used to delete all record passed through the parameters provided to the batch.
 * The batch takes a SOQL query to start the cleanup process, and also takes some "Finish" parameters to be executed at the end of the batch
 **/

global class Cleanup_Batch implements Database.Batchable<sObject> {
	// SOQL Query for the records to be cleanedup
	String query;

	// On the finish procedure, there is an option to customize what is the next step based on the "finishAction" parameter passed
	// Finish procedure parameters used to create campaign-members
	public List<Id> idsToProcess;
	public Id idCampaign;
	public String finishAction;
	public String finishQuery;

	// Constructor used for cleaning-up records based on a SOQL query
	//	param: q: Query ofrecords to delete
	global Cleanup_Batch(String q) {
		query = q;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		if (!scope.isEmpty()) {
			delete scope;
		}
	}

	global void finish(Database.BatchableContext BC) {
		// Special handling might be required at the end of the batch.
		if (finishAction != null) {

			// If final action is to save campaign members, then call the batch to save members
			if(finishAction == 'ClearCampaignMemberProducts')
			{
				Cleanup_Batch secondCleanBatch = new Cleanup_Batch('SELECT Id FROM Campaign_Member_Product__c WHERE Campaign__c = \''+idCampaign+'\'');
				secondCleanBatch.finishAction = 'GenerateCampaignMembersAndProducts';
				// provide SOQL Query to pass down to the Generate member batch
				secondCleanBatch.finishQuery = finishQuery;
				// provide campaignId to pass down to the Generate member batch
				secondCleanBatch.idCampaign = idCampaign;
				Database.ExecuteBatch(secondCleanBatch);
			}
			// If final action is to generate campaign members, then call the batch to generate members
			else if (finishAction == 'GenerateCampaignMembersAndProducts')
			{
				OrderItem_Batch	batch = new OrderItem_Batch('GenerateCampaignMembersAndProducts');
				// pass down the query from the cleanup batch to the generate member batch
				batch.query = finishQuery;
				// provide campaignId to pass down to the Generate member batch
				batch.campaignId = idCampaign;

				Database.ExecuteBatch(batch);
			}
		}
	}
}
