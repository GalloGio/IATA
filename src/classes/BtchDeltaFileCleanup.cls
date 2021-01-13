/**
	* Description: This class to run daily for Delta entries cleanup older than 2 months
	* the Recycle Bin is emptyed for the given scope of sobjects deleted
	* Author: Abdellah Bellahssan
	* Version: 1.0
	* History:
	*/

global class BtchDeltaFileCleanup implements Database.Batchable<sObject> {
	 public String query;
	 global Database.QueryLocator start(Database.BatchableContext BC){
			return Database.getQueryLocator(query);
	 }
	 global void execute(Database.BatchableContext BC, List<sObject> scope){
			delete scope;
			DataBase.emptyRecycleBin(scope);
	 }
	 global void finish(Database.BatchableContext BC){
	 }
}
