trigger AMP_ContactTrigger on Contact (before insert, before update) {

	for (Contact so : Trigger.new) {
		//friends remind friends to bulkify
        if(so.Function__c != null ) {
					if(so.Membership_Function__c == null) {
						so.addError('Contact can only be Primary for values included in Job Functions');
					} else {
						List<String> functions = so.Function__c.split(';');

						for(String s: functions) {
							if(!so.Membership_Function__c.contains(s)) {
								so.addError('Contact can only be Primary for values included in Job Functions');
							}
						}

				}
      }
	}

}