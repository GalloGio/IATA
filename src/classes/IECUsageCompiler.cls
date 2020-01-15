/**
 * A scheduled process use this class to compile the live usage into the Compiled usage (by day)
 */
public without sharing class IECUsageCompiler {

	/**
	 * Returns a list of Live Usage trackers that have been created before or on the target end date
	 * @param dtTargetEndDate The end date to limit the query
	 * @return A list of IEC_Usage_Tracker_Live__c
	 */
	public static List<IEC_Usage_Tracker_Live__c> getListOfLiveUsageToCompileDaily(Date dtTargetEndDate) {
		return [SELECT Hash_Value__c
					,Counter__c
					,Date__c
					,Related_Application_Type__c
					,CAC_Subscription_Detail__c
					,Authorized_Consumption__c
					,RelatedContact__c
					,Search_Status__c
					,Search_Target__c
				FROM IEC_Usage_Tracker_Live__c
				WHERE DAY_ONLY(Date__c) <= :dtTargetEndDate
				ORDER by Date__c];
	}

	/**
	 * Compile the live usage trackers by day (sum the usage)
	 * @param lstLiveUsage The list of usage tracker to compile
	 * @return The list of IEC_Compiled_Usage_Tracker__c that were created or updated
	 */
	public static List<IEC_Compiled_Usage_Tracker__c> compileDailyUsage(List<IEC_Usage_Tracker_Live__c> lstLiveUsage) {

		try {

			if (lstLiveUsage.isEmpty())
				return null;

			// list of live usage to purge once it's compiled
			List<IEC_Usage_Tracker_Live__c> lstLiveUsageToDelete = new List<IEC_Usage_Tracker_Live__c>();

			// list of global usage to purge once it's compiled
			List<IEC_Compiled_Usage_Tracker__c> lstCompiledUsageToUpsert = new List<IEC_Compiled_Usage_Tracker__c>();

			// create map where each key (the hash) will be the target of a usage compilation
			Map<String, Integer> mapHashUsageCount = new Map<String, Integer>();

			// create maps of usage to compile (one where the key is the Id, and one where the key is the hash value)
			Map<Id, IEC_Usage_Tracker_Live__c> mapUsageToCompile = new Map<Id, IEC_Usage_Tracker_Live__c>();
			Map<String, IEC_Usage_Tracker_Live__c> mapUsageToCompileByHash = new Map<String, IEC_Usage_Tracker_Live__c>();
			for (IEC_Usage_Tracker_Live__c u : lstLiveUsage) {
				mapUsageToCompile.put(u.Id, u);
				mapUsageToCompileByHash.put(u.Hash_Value__c, u);
			}

			// for all live usage to compile in this batch
			for (IEC_Usage_Tracker_Live__c oUsage : lstLiveUsage) {

				// only process Hash value once
				if (!mapHashUsageCount.containsKey(oUsage.Hash_Value__c)) {

					Integer iCounter = 0;

					// sum all counter usage in the given list having the same Hash
					for (IEC_Usage_Tracker_Live__c oUsageToCount : [SELECT Counter__c FROM IEC_Usage_Tracker_Live__c WHERE Hash_Value__c = :oUsage.Hash_Value__c AND Id IN :mapUsageToCompile.keySet()]) {
						iCounter += Integer.valueOf(oUsageToCount.Counter__c);

						// add to the delete list since it has been counted
						lstLiveUsageToDelete.add(oUsageToCount);
					}

					mapHashUsageCount.put(oUsage.Hash_Value__c, iCounter);
				}
			}

			// update the global usage counter
			for (String hash : mapHashUsageCount.keySet()) {

				// check if a global usage counter has already been created for this hash
				IEC_Compiled_Usage_Tracker__c oCompiledUsageRecord = findCompiledDailyRecordByHash(hash);

				// if not found, create new compiled record
				if (oCompiledUsageRecord == null) {

					// get the first live usage record having the same hash to copy data from
					IEC_Usage_Tracker_Live__c oUsage = mapUsageToCompileByHash.get(hash);

					if (oUsage != null)
						oCompiledUsageRecord = createCompiledUsageRecordFromLiveRecordData(oUsage);
					else {
						system.debug('ALEX - should not happend !');
						break;
					}
				}

				if (oCompiledUsageRecord.Counter__c == null) oCompiledUsageRecord.Counter__c = 0;

				oCompiledUsageRecord.Counter__c += mapHashUsageCount.get(hash);

				lstCompiledUsageToUpsert.add(oCompiledUsageRecord);
			}

			// insert or update the global counters
			List<Database.Upsertresult> upsertResults = Database.upsert(lstCompiledUsageToUpsert, false);
			for (Database.Upsertresult res : upsertResults) {

				// if the upsert failed, log error
				if (!res.isSuccess()) {
					// append errors
					List<String> lstError = new List<String>();
					for(Database.Error err : res.getErrors())
						lstError.add(err.getStatusCode() + ': ' + err.getMessage());
					IECErrorLogger.logError(null, String.join(lstError, '\r\n'), 'Cannot upsert IEC_Compiled_Usage_Tracker__c', 'Record Id: ' + res.getId(), 'IECUsageCompiler.compileDailyUsage()', null);
				}
			}

			// Delete the live usage that was compiled
			delete lstLiveUsageToDelete;

			return lstCompiledUsageToUpsert;
		}
		catch (Exception ex) {
			system.debug('ERROR - Could not compile global usage: ' + ex.getMessage() + '\r\n' + ex.getStacktraceString());
			throw ex;
		}
	}

	/**
	 * Search for a Compiled usage record based on the hash
	 * @param sHash The hash to search for
	 * @return The IEC_Compiled_Usage_Tracker__c object, if found
	 */
	private static IEC_Compiled_Usage_Tracker__c findCompiledDailyRecordByHash(string sHash) {

		List<IEC_Compiled_Usage_Tracker__c> lstCompiledUsage =
			[SELECT Counter__c
				,Date__c
				,Related_Application__c
				,Related_Client__c
				,Validation_Result__c
				,Validation_Type__c
				,Hash_Value__c
			 FROM IEC_Compiled_Usage_Tracker__c
			 WHERE Hash_Value__c = :sHash];

		return (lstCompiledUsage == null || lstCompiledUsage.isEmpty() ? null : lstCompiledUsage.get(0));
	}

	/**
	 * Creates a Compiled usage tracker object based on the data from the live usage ()
	 * @param oLiveUsage
	 * @return The IEC_Compiled_Usage_Tracker__c object that was created
	 */
	private static IEC_Compiled_Usage_Tracker__c createCompiledUsageRecordFromLiveRecordData(IEC_Usage_Tracker_Live__c oLiveUsage) {
		if (oLiveUsage.Authorized_Consumption__c==null) oLiveUsage.Authorized_Consumption__c=0;

		return new IEC_Compiled_Usage_Tracker__c(
			Counter__c = 0,
			Date__c = oLiveUsage.Date__c.date(),
			Related_Application__c = oLiveUsage.Related_Application_Type__c,
			Related_Client__c = oLiveUsage.RelatedContact__c,
			CAC_Subscription_Detail__c = oLiveUsage.CAC_Subscription_Detail__c,
			Max_API_Call_Per_Month__c  = oLiveUsage.Authorized_Consumption__c,
			Validation_Result__c = oLiveUsage.Search_Status__c,
			Validation_Type__c = oLiveUsage.Search_Target__c
		);
	}
}
