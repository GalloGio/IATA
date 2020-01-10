/**************************************************************************************************
 * @ Last Modified By: Bhargavi Rayavarapu
 * @ Last Edited Date : 2016-04-14
 * @ Description: This batch apex runs as a subbatch of Batch_LocationCounter to delete all the existing records
	from the EBC Statistics object
 * ************************************************************************************************/
global class Batch_DeleteExistingLocationCounter implements Database.Batchable<sObject>
{
   	global final String Query;
	global Batch_DeleteExistingLocationCounter()
   	{
		// initial query to get all the Agencies that are accrediated.
   		Query = 'Select Id '
			   +' from EBC_Statistic__c';
   	}
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		// execute the query
	  	return Database.getQueryLocator(query);
   	}
	global void execute( Database.BatchableContext BC, List<EBC_Statistic__c> existingStats)
	{
		try
		{
			delete existingStats;
		}
		catch(Exception e)
		{
			System.debug(' Exception caused while deleting - '+e.getMessage());
		}
	}
	global void finish(Database.BatchableContext BC)
	{
		//delete all existing entries and insert the new map into the table
		Id batchJobId = Database.executeBatch(new Batch_LocationCounter(), 200);
	}
}
