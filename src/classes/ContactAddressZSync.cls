//update information in Zuora if there is any changes made on either the Contact or IEC Address objects.
public without sharing class ContactAddressZSync {

	public static void contactAddressZuoraSync(List<Location__c> lstLocation, Set<Id> setSourceId, String sSource){
		try
	 		{
	 			// During test mode set the limit to only 3 since this batch also runs with another batch "location_Batch" that is of size 10 and we need to minimized the number of records to call both batches.
		 		integer iZuoraAPIObjectLimit = Test.isRunningTest() ? 3 : Utility.getIntegerSetting('Zuora API Object Limit');

			if (!lstLocation.isEmpty()) {
				// Build a list of Account/Contact ID to retrieve the related Billing Account with it
				Set<String> setAccountContactId = new Set<String>();
				for (Location__c loc : lstLocation) {
					setAccountContactId.add(loc.Account_Contact_ID__c);
				}

				// Retrieve ZAccounts related to the location records in
				Map<String, Zuora__CustomerAccount__c> mapAccConId_ZAccount = CustomerAccount_Sel.getZAccountByAccountContactId(setAccountContactId);

				// Create a multi-dimensional array to make a multiple callouts to zuora
				// to workaround zuora limit of updating maximum 50 records at one time
					List<List<Zuora.zObject>> lstAccountToUpdate = new List<List<Zuora.zObject>>();
					List<List<Zuora.zObject>> lstContactToUpdate = new List<List<Zuora.zObject>>();

					integer  i = 0, j = 0;

					for (Location__c loc : lstLocation)
					{
						if (mapAccConId_ZAccount == null  || !mapAccConId_ZAccount.containsKey(loc.Account_Contact_ID__c)) continue;

						// get related Billing Account
						Zuora__CustomerAccount__c oBillingAccount = mapAccConId_ZAccount.get(loc.Account_Contact_ID__c);

						// Update Billing Account details
						Zuora.zObject zAccount = new Zuora.zObject('Account');
						zAccount.setValue('Id', oBillingAccount.Zuora__External_Id__c);
						zAccount.setValue('SAPBillTo__c', (String.isBlank(loc.SAP_Id__c) ? '' : loc.SAP_Id__c));
						zAccount.setValue('VATID__c', (String.isBlank(loc.VAT_Number__c) ? '' : loc.VAT_Number__c));

						// Update Billing Contact Details
					Zuora.zObject zContact = new Zuora.zObject('Contact');
					zContact.setValue('FirstName', loc.Contact_First_Name__c);
					zContact.setValue('LastName', loc.Contact_Last_Name__c);
					zContact.setValue('WorkEmail', loc.Email__c);
					zContact.setValue('WorkPhone', loc.Phone__c);

					zContact.setValue('Country', loc.Country__c);
					zContact.setValue('State', loc.State__c);
					zContact.setValue('City', loc.City__c);
					zContact.setValue('PostalCode', loc.ZipCode__c);
					zContact.setValue('Address1', loc.Street__c);
						zContact.setValue('Id', oBillingAccount.Zuora__BillToId__c);

						// If still first time in the sub-array, then instantiate a new array
						if (j == 0)
						{
							lstAccountToUpdate.add(new List<Zuora.zObject> {zAccount});
							lstContactToUpdate.add(new List<Zuora.zObject> {zContact});
						}
						// Otherwise keep adding to the same array
						else if (j < iZuoraAPIObjectLimit)
						{
							lstAccountToUpdate[i].add(zAccount);
							lstContactToUpdate[i].add(zContact);
						}

						j++;

						// Once the sub-array index reaches to the maximum number allowed per callout
						// then reset the level 2 index J and increment the Level 1 index I to force to create a new sub-array
						if (j == iZuoraAPIObjectLimit)
						{
							j = 0;
							i++;
						}
					}

					// Update Zuora Account
					for (List<Zuora.zObject> lstToUpdate : lstAccountToUpdate)
					{
						// perform the update
						List<Zuora.zApi.SaveResult> lstAccountUpdateResult = null;

						// Try API Call for the first time
						try {
							lstAccountUpdateResult = IECZuoraHelper.updateApiCall(lstToUpdate);
						}
						catch (Exception e) {
							// If call failed for any reason, try again one more time
							try {
								lstAccountUpdateResult = IECZuoraHelper.updateApiCall(lstToUpdate);
							}
							catch (Exception ex) {
								// If all fails, then log the error into the system for further investigations
								IECErrorLogger.logApexException('ContactAddressZSync_Batch.execute'
					 				, 'Exception thrown while making the Zuora API call:\nsetSourceId: ' + setSourceId
					 					+ '\nsSource: ' + sSource
					 					+ '\nlstToUpdate: ' + lstToUpdate
					 				, e.getMessage()
	 								, e.getStackTraceString()
					 			);
							}
						}

						if (Test.isRunningTest())
							lstAccountUpdateResult = new List<Zuora.zApi.SaveResult> { IECTestUtil.createSampleSaveResult(true), IECTestUtil.createSampleSaveResult(false) };

					// check for errors
					for (Zuora.zApi.SaveResult result : lstAccountUpdateResult) {
						if (result.Success) {
							system.debug('DEBUG CALLOUT - address sync success for SaveResult id ' + result.Id);
						}
						else {
							for (Zuora.zObject error: result.errors) {
								IECErrorLogger.logApexError('ContactAddressZSync_Batch.execute'
						 				, 'setSourceId: ' + setSourceId
						 					+ '\nsSource: ' + sSource
						 				, 'Error returned from Zuora from the API call:\nZuora Error Code: ' + (String)error.getValue('Code')
						 					+ '\nZuora Error Message: ' + (String)error.getValue('Message')
						 			);
												}
						}
					}
					}

					// Update Zuora Contact
					for (List<Zuora.zObject> lstToUpdate : lstContactToUpdate)
					{
						// perform the update
						List<Zuora.zApi.SaveResult> lstContactUpdateResult = null;

						// Try API Call for the first time
						try {
							lstContactUpdateResult = IECZuoraHelper.updateApiCall(lstToUpdate);
						}
						catch (Exception e) {
							// If call failed for any reason, try again one more time
							try {
								lstContactUpdateResult = IECZuoraHelper.updateApiCall(lstToUpdate);
							}
							catch (Exception ex) {
								// If all fails, then log the error into the system for further investigations
								IECErrorLogger.logApexException('ContactAddressZSync_Batch.execute'
					 				, 'Exception thrown while making the Zuora API call:\nsetSourceId: ' + setSourceId
					 					+ '\nsSource: ' + sSource
					 					+ '\nlstToUpdate: ' + lstToUpdate
					 				, e.getMessage()
	 								, e.getStackTraceString()
					 			);
							}
						}

						if (Test.isRunningTest())
							lstContactUpdateResult = new List<Zuora.zApi.SaveResult> { IECTestUtil.createSampleSaveResult(true), IECTestUtil.createSampleSaveResult(false) };

					// check for errors
					for (Zuora.zApi.SaveResult result : lstContactUpdateResult) {
						if (result.Success) {
							system.debug('DEBUG CALLOUT - address sync success for SaveResult id ' + result.Id);
						}
						else {
							for (Zuora.zObject error: result.errors) {
								IECErrorLogger.logApexError('ContactAddressZSync_Batch.execute'
						 				, 'setSourceId: ' + setSourceId
						 					+ '\nsSource: ' + sSource
						 				, 'Error returned from Zuora from the API call:\nZuora Error Code: ' + (String)error.getValue('Code')
						 					+ '\nZuora Error Message: ' + (String)error.getValue('Message')
						 			);
												}
						}
					}
					}
			}
	 		}
	 		catch (Exception e)
	 		{
	 			IECErrorLogger.logApexException('ContactAddressZSync_Batch.execute'
	 				, 'Exception thrown while running the execute function:\nsetSourceId: ' + setSourceId
	 					+ '\nsSource: ' + sSource
	 				, e.getMessage()
	 				, e.getStackTraceString()
	 			);
	 		}
	}
}
