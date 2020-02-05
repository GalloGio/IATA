/**
	* Description: This class count the number of records
	* Author: Sonny Leman
	* Version: 1.0
	* History:
	*   2016-06-07-sl: initial version
	*
	* Important note (Sonny Leman):
	*   -
	*
	*/

global without sharing class BtchEBCCountGdpAgencies implements Database.Batchable<sObject>, Database.Stateful
{
	global List<IEC_Error_Log__c> logs;

	public String query;
	public Id idRecordTypeGDP;
	public DateTime dtSystemNow;
	private Boolean bErrorFound;
	private List<String> queryList;

	private Integer totalCount;

	// constructor
	global BtchEBCCountGdpAgencies () {
		totalCount =0;
		queryList = new List<String>();
	}
	global BtchEBCCountGdpAgencies (List<String> queries) {
		System.debug( 'BtchEBCCountGdpAgencies: num of queries:' + queries.size());
		System.debug( 'BtchEBCCountGdpAgencies: queries:' + queries);
		totalCount =0;
		queryList = queries;
		if (queryList.size() > 0) {
			query = queryList.remove(0);
		}
	}

	global Database.querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	} // end of queryLocator


	// ========================================================================
	// batch execution method
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		System.debug( 'BtchEBCCountGdpAgencies: execute(), scope length:' + scope.size());
		totalCount += scope.size();

	} // end of execute

	// ========================================================================
	// when this batch is finish, create another batch with next query
	global void finish(Database.BatchableContext BC) {
		System.debug( 'BtchEBCCountGdpAgencies: finish()');
		System.debug( 'totalCount: ' + totalCount);

		if (queryList.size() > 0)
		{ // get next query from the list and run another batch
			System.debug( 'BtchEBCCountGdpAgencies: continue with ' + queryList.size() + ' queries.');

			BtchEBCCountGdpAgencies btchProc = new BtchEBCCountGdpAgencies(queryList);
			Database.executeBatch(btchProc);
		} else {
			System.debug( 'BtchEBCCountGdpAgencies: done with ' + queryList.size() + ' queries.');
		}

	} // end of finish


	// ========================================================================
	// use callBatch to do standard call to this batch class, incl setting the query
	//
	//
	private static final string DEFAULT_SOQL_QUERY_AGENCY = 'select count() from GDP_Products_Account_View__c ';
	public static void callBatch(String soqlQuery)
	{
		System.debug( 'BtchEBCCountGdpAgencies.callBatch :' + soqlQuery);

		BtchEBCCountGdpAgencies btchProc = new BtchEBCCountGdpAgencies();

		btchProc.query = String.isBlank(soqlQuery) ? DEFAULT_SOQL_QUERY_AGENCY : soqlQuery;


		// showQuery(btchProc.query); // this is only for debugging
		Database.executeBatch(btchProc);
	} // callBatchReplicateTerritories


} // end of BatchEBCCountGdp class
