/**
 * A Sync batch that update information in Zuora if there is any changes made on either the Contact or IEC Address objects.
 * The batch takes a set of either Location Ids that has a link to both contact/address information required for the sync or Address IDs to pull all locations that has a link to that address
 *
 * Test Coverage: Provided in the class Location_Dom_Test
 **/

global class ContactAddressZSync_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	// List of either IECAddress__c IDs or Location__c IDs
	Set<Id> setSourceId;

	// Can either be a "Location" or "IECAddress" which dictates which filter to use in the query to initialize the batch
	String sSource;

	// Constructor
	//	param: SourceIds: Set of unique IECAddress/Locations Ids that will be used to sync data to zuora
	//	param: Source: define which source the Ids coming from, either "Location" or "IECAddress"
	global ContactAddressZSync_Batch(Set<Id> SourceIds, String Source) {
		setSourceId = SourceIds;
		sSource = Source;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(
			' SELECT Id, Contact__c, Account__c, Address__c, Type__c, Account_Contact_ID__c' +
			' 	, Contact_First_Name__c, Contact_Last_Name__c, Contact_Email__c, Email__c, Contact_Phone__c, Phone__c' +
			' 	, Country__c, State__c, City__c, ZipCode__c, Street__c, VAT_Number__c, SAP_Id__c' +
			' FROM Location__c' +
			' WHERE Account__c <> NULL' +
			' 	AND Contact__c <> NULL' +
			' 	AND ' + ((sSource == 'Location') ? 'Id ' : 'Address__c') + ' IN :setSourceId' +
			' 	AND Active__c = true' +
			' 	AND Type__c = \'Bill To\''
		);
	}

	 	global void execute(Database.BatchableContext BC, List<Location__c> scope) {
	 		//update information in Zuora if there is any changes made on either the Contact or IEC Address objects.
	 		ContactAddressZSync.contactAddressZuoraSync(scope, setSourceId, sSource);
	}

	global void finish(Database.BatchableContext BC) {}
}
