/**
 * Class used to split an existing multicountry hierarchy
 * into multiple standard hierarchies (1 per BSP)
 * Intended to be used when: 
 * 	- Passing the "Confirm conversion" step from the OSCAR "Conversion from Multicountry to Standard" 
 * 	- An OSCAR change in a multicountry hierarchy results in an invalid hierarchy that needs to be converted to standard 
 */
global class ANG_SplitMcHierarchyIntoStandardBatch implements Database.Batchable<Account>, Database.Stateful {

	private Id accountGE;
	private Boolean processSingleBsp;

	public ANG_SplitMcHierarchyIntoStandardBatch(Id accountGE, Boolean processSingleBsp) {
		this.accountGE = accountGE;
		this.processSingleBsp = processSingleBsp;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id, Location_Type__c, Location_Class__c, IATA_ISO_Country__r.AMS_Settlement_System__c ';
		query += ' (SELECT Id, Hierarchy__c, Child_Account__c, Parent_Account__c FROM AMS_Agencies_relationships__r) ';
		query += ' FROM Account WHERE (Id = :accountGE OR ParentId = :accountGE) ';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) {

		List<Account> acctsToUpdateLst = new List<Account>();
		List<AMS_Agencies_relationhip__c> relationsToProcessLst = new List<AMS_Agencies_relationhip__c>();

		for(Account acct : scope){

			processAgency(acct);

			acctsToUpdateLst.add(acct);

		}

		if(!acctsToUpdateLst.isEmpty()){
			update acctsToUpdateLst;
		}

	}

	private void processAgency(Account acct){

		switch on acct.Location_Type__c {
			when AMS_Utils.GE {
				acct.Location_Type__c = AMS_Utils.HE;
			}
			when AMS_Utils.HE {
				acct.ParentId = null;
				acct.Top_Parent__c = null;
			}
			when else {
				
			}
		}

		acct.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

	}

	global void finish(Database.BatchableContext BC) {

	}

}