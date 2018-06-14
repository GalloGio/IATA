/*
 * This class contains helper methods for the trigger FinancialSecurityHandler. These methods handle the creation of the renewal cases for Financial Security records 
 * that are close to expiry.
 */
public with sharing class FinancialSecurityUtil {
	
	/*
     *  Handles the actions of the Before Update trigger for Financial Security records
     */
    public static void HandleFSBeforeUpdate (Map<Id, Financial_Security__c> mapTriggerNew, Map<Id, Financial_Security__c> mapTriggerOld) {
    	// Create a renewal Case for all the Financial_Security__c records that are switched to the status "close to expiry"
    	
    	// Select the IDs of the Financial Security records of interest
    	List<Id> lstFSRecordIds = new List<Id>();
    	// Select the IDs of the related accounts
    	List<Id> lstRelatedAccountIds = new List<Id>();
    	
    	for (Financial_Security__c fs : mapTriggerNew.values()) {
    		if (fs.Security_Status__c == 'Close to Expiry Date' && mapTriggerOld.get(fs.Id).Security_Status__c != 'Close to Expiry Date') {
    			lstFSRecordIds.add(fs.Id);
    			lstRelatedAccountIds.add(fs.Account__c);
    		}
    	}
    	
    	// Get extra information on these FS records (information not available in the Trigger.new map, like the account name)
    	List<Financial_Security__c> lstFSRecordsWithExtraInfo = [SELECT Id, Name, Region__c, Account_Country__c, IATA_code__c, Expiry_Date__c, Account__c, Account__r.Name, Account__r.Industry, Account__r.Type,
    						Financial_Institution__r.Name, Amount__c, Security_Type__c, Remarks__c FROM Financial_Security__c WHERE Id IN :lstFSRecordIds];
    	
    	// Get all financial assessment contacts from the accounts related to the FS records (keep 1 contact per account), to add them on the cases
    	List<Contact> lstFAContacts = [SELECT Id, AccountId FROM Contact WHERE Financial_Assessment_Contact__c = true AND AccountId IN :lstRelatedAccountIds];
    	map<Id, Id> mapFAContactIdsPerAccountIds = new map<Id, Id>();
    	for (Contact c : lstFAContacts) {
    		mapFAContactIdsPerAccountIds.put(c.AccountId, c.Id);
    	}
    	
    	
    	// a map to hold the newly created cases per the corresponding Financial Security record Id
    	Map<Id, Case> mapNewCasesPerFSId = new Map<Id, Case>();
    	
    	// create the renewal cases for the records of interest
    	for (Financial_Security__c fs : lstFSRecordsWithExtraInfo) {
    		// create the case object
    		Case tmpCase = CaseFactory.CreateFinancialSecurityCase(fs, false);
    		    		
    		// fill in the contact info, if available
    		tmpCase.ContactId = mapFAContactIdsPerAccountIds.get(fs.Account__c);
    		
    		mapNewCasesPerFSId.put(fs.Id, tmpCase);
    	}
    	
    	if (!mapNewCasesPerFSId.values().isEmpty()) {
    		try {
    			insert mapNewCasesPerFSId.values();
    			
    			// take the newly created cases Ids and fill it on the original Financial Security record
    			for (Id fsId : mapNewCasesPerFSId.keyset()) {
    				mapTriggerNew.get(fsId).Renewal_Case__c = mapNewCasesPerFSId.get(fsId).Id;
    			}
    			
    		} catch (Exception e) {
    			system.debug('## ERROR: ' + e.getMessage());
    		}
    	}
    }
}