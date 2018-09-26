global class OSCARstatusBatch implements Database.Batchable<sObject> {

	String query;


	global List<AMS_OSCAR__c> start(Database.BatchableContext BC) {
		system.debug('start');
		List<AMS_OSCAR__c> oscarList = [SELECT id, Recordtype.Developername, Change_effective_as_of__c, OSCAR_Deadline__c, Termination_Date__c, Status__c, Sanity_check_deadline__c, Process__c from AMS_OSCAR__c
		                                where Status__c = 'Accepted_Future Date' and ( Recordtype.Developername = 'Voluntary_Relinquishment' or Recordtype.Developername = 'certification' or Recordtype.Developername = 'change')];
		system.debug(oscarList);
		return oscarList;
	}

	global void execute(Database.BatchableContext BC, List<AMS_OSCAR__c> scope) {
		system.debug('execute: ' + scope);
		List<AMS_OSCAR__c> listToUpdate = new List<AMS_OSCAR__c>();
		for (AMS_OSCAR__c oscarToUpdate : scope) {
			if (oscarToUpdate.recordtype.developername == 'Voluntary_Relinquishment' && oscarToUpdate.Change_effective_as_of__c != null
			        && oscarToUpdate.Termination_Date__c == null) {
				if (oscarToUpdate.Change_effective_as_of__c == System.today()) {
					oscarToUpdate.status__c = 'Open';
					listToUpdate.add(oscarToUpdate);
				}

			} else if (oscarToUpdate.Recordtype.Developername == 'Voluntary_Relinquishment' && oscarToUpdate.Termination_Date__c != null) {
				if (oscarToUpdate.Termination_Date__c == System.today()) {
					oscarToUpdate.status__c = 'Open';
					listToUpdate.add(oscarToUpdate);
				}

			} else if ((oscarToUpdate.Recordtype.Developername == 'Change' || oscarToUpdate.Recordtype.Developername == AMS_Utils.RECTYPE_NGCHANGES) && oscarToUpdate.Change_effective_as_of__c != null) {
				if (oscarToUpdate.Change_effective_as_of__c == System.today()) {
					oscarToUpdate.status__c = 'Open';
					listToUpdate.add(oscarToUpdate);
				}

			} else if (oscarToUpdate.Process__c == 'BANK.ACCOUNT.CHANGES' && oscarToUpdate.OSCAR_Deadline__c != null) {
				if (oscarToUpdate.OSCAR_Deadline__c == System.today()) {
					oscarToUpdate.status__c = 'Open';
					listToUpdate.add(oscarToUpdate);
				}
			} if (oscarToUpdate.Recordtype.Developername == 'certification' && oscarToUpdate.Sanity_check_deadline__c != null) {
				if (oscarToUpdate.Sanity_check_deadline__c == System.today()) {
					oscarToUpdate.status__c = 'Open';
					listToUpdate.add(oscarToUpdate);
				}
			}
		}
		update listToUpdate;
	}

	global void finish(Database.BatchableContext BC) {

	}

}