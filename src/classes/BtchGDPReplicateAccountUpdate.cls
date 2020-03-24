/**
  * Description: This class contains batchable class for GDP Replication - Account
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */

global class BtchGDPReplicateAccountUpdate implements Database.Batchable<sObject>, Database.Stateful {
	global List<IEC_Error_Log__c> logs;

	public String query;
	public DateTime dtSystemNow;
	private Boolean bErrorFound;

	// Initialize error log
	global BtchGDPReplicateAccountUpdate () {
		logs = new List<IEC_Error_Log__c>();
	}

	global Database.querylocator start(Database.BatchableContext BC){
		bErrorFound = false;
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		// Build up set of AIMS and WebStar IDs for GDP Address & Phone
		Set<String> setAddressAIMSID = new Set<String>();
		Set<String> setAddressWebStarID = new Set<String>();

		//Mailing in case Location address is not available
		Set<String> setMAddressAIMSID = new Set<String>();
		Set<String> setMAddressWebStarID = new Set<String>();

		Set<String> setPhoneAIMSID = new Set<String>();
		Set<String> setPhoneWebStarID = new Set<String>();
		List<String> lstIATACode = new List<String>();
		List<Id> lstSFID = new List<Id>();

		for(sObject s : scope) {
			GDP_Products_Account_View__c gdpRecord = (GDP_Products_Account_View__c) s;
			if (!String.isBlank(gdpRecord.AIMS_ID__c)) {
				string sAIMSID = gdpRecord.AIMS_ID__c.substring(0, gdpRecord.AIMS_ID__c.length() - 3);
				setAddressAIMSID.add(sAIMSID + 'LOC' + 'GDP');
				setMAddressAIMSID.add(sAIMSID + 'MAI' + 'GDP');
				setPhoneAIMSID.add(sAIMSID + 'P1' + 'GDP');
			}
			else if (!String.isBlank(gdpRecord.WebStar_ID__c)) {
				string sWebStarID = gdpRecord.WebStar_ID__c.substring(0, gdpRecord.WebStar_ID__c.length() - 3);
				setAddressWebStarID.add(sWebStarID + 'LOC' + 'GDP');
				setMAddressWebStarID.add(sWebStarID + 'MAI' + 'GDP');
				setPhoneWebStarID.add(sWebStarID + 'P1' + 'GDP');
			}
		}

		// Prepare maps for existing GDP Address & Phone
		Map<String, Id> mapAddressAIMSIDtoSFID = new Map<String, Id>();
		Map<String, Id> mapAddressWebStarIDtoSFID = new Map<String, Id>();
		Map<String, Id> mapPhoneAIMSIDtoSFID = new Map<String, Id>();
		Map<String, Id> mapPhoneWebStarIDtoSFID = new Map<String, Id>();

		for (GDP_Address__c address : [SELECT ID, AIMS_ID__c, WebStar_ID__c	FROM GDP_Address__c	WHERE AIMS_ID__c IN :setAddressAIMSID OR WebStar_ID__c IN :setAddressWebStarID])
		{
			if (!String.isBlank(address.AIMS_ID__c)) {
				mapAddressAIMSIDtoSFID.put(address.AIMS_ID__c, address.Id);
			}
			else if (!String.isBlank(address.WebStar_ID__c)) {
				mapAddressWebStarIDtoSFID.put(address.WebStar_ID__c, address.Id);
			}
		}

		//get mailing address if needed in case of location address empty
		for (GDP_Address__c Maddress : [SELECT ID, AIMS_ID__c, WebStar_ID__c	FROM GDP_Address__c	WHERE AIMS_ID__c IN :setMAddressAIMSID OR WebStar_ID__c IN :setMAddressWebStarID])
		{
			if (!String.isBlank(Maddress.AIMS_ID__c) && !mapAddressAIMSIDtoSFID.containsKey(Maddress.AIMS_ID__c)) {
				mapAddressAIMSIDtoSFID.put(Maddress.AIMS_ID__c, Maddress.Id);
			}
			else if (!String.isBlank(Maddress.WebStar_ID__c) && !mapAddressWebStarIDtoSFID.containsKey(Maddress.WebStar_ID__c)) {
				mapAddressWebStarIDtoSFID.put(Maddress.WebStar_ID__c, Maddress.Id);
			}
		}


		for (GDP_Phone__c phone :[SELECT ID, AIMS_ID__c, WebStar_ID__c	FROM GDP_Phone__c	WHERE AIMS_ID__c IN :setPhoneAIMSID OR WebStar_ID__c IN :setPhoneWebStarID])
		{
			if (!String.isBlank(phone.AIMS_ID__c)) {
				mapPhoneAIMSIDtoSFID.put(phone.AIMS_ID__c, phone.Id);
			}
			else if (!String.isBlank(phone.WebStar_ID__c)) {
				mapPhoneWebStarIDtoSFID.put(phone.WebStar_ID__c, phone.Id);
			}
		}

		// Now update the accounts
		for(sObject s : scope) {
			GDP_Products_Account_View__c gdpRecord = (GDP_Products_Account_View__c) s;
			try {
				lstIATACode.add(gdpRecord.IATA_Code__c);
				lstSFID.add(gdpRecord.Id);

				if (!String.isBlank(gdpRecord.AIMS_ID__c)) {
					string sAIMSID = gdpRecord.AIMS_ID__c.substring(0, gdpRecord.AIMS_ID__c.length() - 3);
					gdpRecord.Related_Accreditation_Class__r = new Accreditation__c (AIMS_ID__c = sAIMSID + 'ACC1' + 'GDP');

					if (mapAddressAIMSIDtoSFID.containsKey(sAIMSID + 'LOC' + 'GDP')) {
						gdpRecord.Related_GDP_Address__c = mapAddressAIMSIDtoSFID.get(sAIMSID + 'LOC' + 'GDP');
					}
					else if (mapAddressAIMSIDtoSFID.containsKey(sAIMSID + 'MAI' + 'GDP')) {
						gdpRecord.Related_GDP_Address__c = mapAddressAIMSIDtoSFID.get(sAIMSID + 'MAI' + 'GDP');
					}
					else {
						gdpRecord.Related_GDP_Address__c = null;
					}

					if (mapPhoneAIMSIDtoSFID.containsKey(sAIMSID + 'P1' + 'GDP')) {
						gdpRecord.Related_Main_Phone__c = mapPhoneAIMSIDtoSFID.get(sAIMSID + 'P1' + 'GDP');
					}
					else {
						gdpRecord.Related_Main_Phone__c = null;
					}

					if (!String.isBlank(gdpRecord.Parent_Account_AIMS_ID__c)) {
						gdpRecord.Parent_GDP_Account_View__r = new GDP_Products_Account_View__c (AIMS_ID__c = gdpRecord.Parent_Account_AIMS_ID__c + 'GDP');
					}
					else {
						gdpRecord.Parent_GDP_Account_View__r = null;
					}
				}
				else if (!String.isBlank(gdpRecord.WebStar_ID__c)) {
					string sWebStarID = gdpRecord.WebStar_ID__c.substring(0, gdpRecord.WebStar_ID__c.length() - 3);
					gdpRecord.Related_Accreditation_Class__r = new Accreditation__c (WebStar_ID__c = sWebStarID + 'ACC1' + 'GDP');

					if (mapAddressWebStarIDtoSFID.containsKey(sWebStarID + 'LOC' + 'GDP')) {
						gdpRecord.Related_GDP_Address__c = mapAddressWebStarIDtoSFID.get(sWebStarID + 'LOC' + 'GDP');
					}
					else if (mapAddressWebStarIDtoSFID.containsKey(sWebStarID + 'MAI' + 'GDP')) {
						gdpRecord.Related_GDP_Address__c = mapAddressWebStarIDtoSFID.get(sWebStarID + 'MAI' + 'GDP');
					}
					else {
						gdpRecord.Related_GDP_Address__c = null;
					}

					if (mapPhoneWebStarIDtoSFID.containsKey(sWebStarID + 'P1' + 'GDP')) {
						gdpRecord.Related_Main_Phone__c = mapPhoneWebStarIDtoSFID.get(sWebStarID + 'P1' + 'GDP');
					}
					else {
						gdpRecord.Related_Main_Phone__c = null;
					}

					if (!String.isBlank(gdpRecord.Parent_Account_WebStar_ID__c)) {
						gdpRecord.Parent_GDP_Account_View__r = new GDP_Products_Account_View__c (WebStar_ID__c = gdpRecord.Parent_Account_WebStar_ID__c + 'GDP');
					}
					else {
						gdpRecord.Parent_GDP_Account_View__r = null;
					}
				}

				if (Test.isRunningTest()) throw new IECApplicationException('Test');
			}
			catch (Exception e) {
				logs.add(IECErrorLogger.logBatchError('Error processing records.', e.getMessage(), 'GDP Account ID: ' + gdpRecord.Id, 'GDP Replicate: Account Update', e.getStackTraceString()));
			}
		}

		// Process records
		try {
			if (!scope.isEmpty()) {
				List<Database.UpsertResult> lstResult = Database.upsert(scope, false);

				List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(scope, lstResult, 'GDP Replicate: Account Update', new List<String> {'GDP Account ID', 'IATA Code'}, new List<List<String>> {lstSFID, lstIATACode});
				if (lstErrors != null && lstErrors.size() > 0)
					logs.addAll(lstErrors);
			}

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not update records.', e.getMessage(), null, 'GDP Replicate: Account Update', e.getStackTraceString()));
		}

		// Insert error logs if applicable
		if (!logs.isEmpty()) {
			bErrorFound = true;
			insert logs;
			logs.clear();
		}
	}

	global void finish(Database.BatchableContext BC) {
		try {
			// Update the last modified date for the batch
			IECUtil.SetBatchReplication('GDP Replicate: Account Update', dtSystemNow);

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not set Batch Replication last modified date.', e.getMessage(), null, 'GDP Replicate: Account Update', e.getStackTraceString()));
		}

		// Insert error logs if applicable
		if (!logs.isEmpty()) {
			bErrorFound = true;
			insert logs;
		}

		// Send email notification when errors are found
		if (bErrorFound) {
			if (!IECEmailUtility.notificationExistsToday(IECConstants.GDPReplication_SystemAdminEmail, IECConstants.Email_Template_GDPError)) {
				IECEmailUtility.sendEmail(null, IECConstants.GDPReplication_SystemAdminEmail, IECConstants.Email_Template_GDPError, null, null, null, null, null, null, null);
			}
		}
	}
}
