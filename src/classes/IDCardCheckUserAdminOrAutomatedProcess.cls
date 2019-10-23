public class IDCardCheckUserAdminOrAutomatedProcess extends TriggerAction {
	/**
	 * Method that checks if Sent_to_AIMS_on__c field is null
	 * @param s the affected record
	 * @return true if the field is not null false if it is null
	 */
	protected override Boolean isRelevant(SObject s) {

		ID_Card__c idCardRecord = (ID_Card__c) s;

		if(idCardRecord.Sent_to_AIMS_on__c == null)
			return false;

		return true;
	}

	/**
	 * Method that adds a error if the user is not administrator or automated process
	 * @param records records with Sent_to_AIMS_on__c not null
	 * @param uw 	  unit of work to include all DML operations
	 * @return
	 */
	protected override void execute(List<SObject> records, UnitOfWork uw) {

		list<Profile> profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1];

		for(ID_Card__c idcard : (List<ID_Card__c>) records) {

			if (profileName[0].name.toLowerCase() != 'restricted profile - automated process' && !profileName[0].name.containsIgnoreCase('system administrator')){

                if(idcard.Received_From_AIMS__c == null)
                    idcard.addError(Label.Card_can_t_be_updated);
            }
		}
	}
}