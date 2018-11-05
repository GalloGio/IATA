public class CloseCasesForCancelledIDCardApplications extends TriggerAction {
	
	/**
	 * Method that checks if the relevant fields for this action were changed
	 * @param s the affected record
	 * @return true if the relevant fields for this action were changed and false if not
	 */
	protected override Boolean isRelevant(SObject s) {

		ID_Card_Application__c idCardAppRecord = (ID_Card_Application__c) s;

		if(idCardAppRecord.RecordTypeId == IDCardUtil.IDCARDMASSAPPLICATION_RTID 
			&& idCardAppRecord.Application_Status__c == 'Cancelled')
			return true;

		return false;
	}

	/**
	 * Method that adds a error for duplicate records
	 * @param records duplicated records
	 * @param uw 	  unit of work to include all DML operations
	 * @return
	 */
	protected override void execute(List<SObject> records, UnitOfWork uw) {

		Set<Id> recordIds = new Set<Id>();

		for(ID_Card_Application__c idCardApp : (List<ID_Card_Application__c>) records) {
			recordIds.add(idCardApp.Id);
		}

		List<Case> casesToClose = [SELECT Id, Status, ID_Card_Status__c FROM Case WHERE Related_ID_Card_Application__c in :recordIds];

		for(Case c : casesToClose) {
			c.Status = 'Closed';
			c.ID_Card_Status__c = 'Cancelled';
		}

		Map<String, SObjectField> sObjectFieldMap = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();

		uw.registerDirty(casesToClose, new List<SObjectField>{sObjectFieldMap.get('Status'),sObjectFieldMap.get('ID_Card_Status__c')});
	}
}