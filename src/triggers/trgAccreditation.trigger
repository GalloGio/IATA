trigger trgAccreditation on Accreditation__c (before insert, before update, after insert, after update) {
		
	/* Before Insert && Before Update*/
	if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
		if (!IECConstants.GDPReplication_ProfileIDswithAccess.contains(UserInfo.getProfileId().substring(0, 15))) {
			for (Accreditation__c obj : trigger.new) {
				if (obj.AIMS_ID__c != null || obj.WebStar_ID__c != null)
					obj.addError(Label.Cannot_Update_AIMS_values);
			}
		}
	}

	/* After Insert && After Update
	else if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {

		Set<Id> accIds = new Set<Id>();
		List<Account> accList = new List<Account>();

		for (Accreditation__c obj : trigger.new) {
			accIds.add(obj.Related_Account__c);
		}
		accList = [SELECT Id from Account WHERE Id in :accIds];

		list<Database.SaveResult> results = database.update( accList, false);

		// Iterate through each returned result
		for (Integer i = 0; i < results.size(); i++) {
			if (!results.get(i).isSuccess()) {
				// DML operation failed
				Database.Error error = results.get(i).getErrors().get(0);
				String failedDML = error.getMessage();
				accList.get(i);//failed record from the list				

				//send an email to support and you can put on the email the record ID !
				system.debug('Failed ID' + accList.get(i).Id);
				transformationHelper.sendEmailSupport('trgAccreditation fail to update account', 'failed to udpated account ID:  '+accList.get(i).Id);
			}
		}
	}*/
}