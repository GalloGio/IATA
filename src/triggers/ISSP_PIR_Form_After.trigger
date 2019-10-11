trigger ISSP_PIR_Form_After on PIR_Form__c (after insert, after update) {

	Set <Id> addAccountIds = new Set<Id>();
	Map <Id, Id> addAccountMap = new Map <Id, Id>();
	Set <Id> removeAccountIds = new Set<Id>();
	Map <Id, Id> removeAccountMap = new Map <Id, Id>();
	for(PIR_Form__c newForm:trigger.new){
        if (trigger.isInsert){
        	system.debug('ADDING ID: ' + newForm.Id);
        	system.debug('ADDING ACCOUNT ID: ' + newForm.Airline_issuing__c);
        	addAccountMap.put(newForm.Id, newForm.Airline_issuing__c);
        	addAccountIds.add(newForm.Airline_issuing__c);
        }
        else if (trigger.isUpdate){
        	PIR_Form__c oldForm = trigger.oldMap.get(newForm.Id);
        	if (newForm.Airline_issuing__c != oldForm.Airline_issuing__c){
        		if (newForm.Airline_issuing__c != null && newForm.Airline_issuing__c != ''){
        			system.debug('CHANGING ID: ' + newForm.Id);
        			system.debug('CHANGING ACCOUNT ID: ' + newForm.Airline_issuing__c);
        			addAccountMap.put(newForm.Id, newForm.Airline_issuing__c);
        			addAccountIds.add(newForm.Airline_issuing__c);
        		}
        		if (oldForm.Airline_issuing__c != null && oldForm.Airline_issuing__c != ''){
        			removeAccountMap.put(newForm.Id, oldForm.Airline_issuing__c);
        			removeAccountIds.add(oldForm.Airline_issuing__c);
        		}
        	}
        }
    }
    
    /*
    if (!removeAccountIds.isEmpty()){
    	List <Contact> removeContactList = [SELECT Id,
    					(SELECT Id FROM Portal_Application_Right__c WHERE Right__c = 'Access Granted'
    					AND Application_Name__c = 'Baggage Proration')
    					FROM PIR_Form__c
    					WHERE AccountId IN :removeAccountIds OR Account.Top_Parent__c IN :removeAccountIds];
		for(PIR_Form__c newForm:trigger.new){
			if (removeAccountIds.containsKey(newForm.Id)){
				
			}
		}
    }
    */
    
    if (!addAccountIds.isEmpty()){
    	List <Contact> addContactList = [SELECT Id,
    					(SELECT Id FROM Portal_Application_Rights__r WHERE Right__c = 'Access Granted'
    					AND Application_Name__c = 'Baggage Proration')
    					FROM Contact
    					WHERE AccountId IN :addAccountIds OR Account.Top_Parent__c IN :addAccountIds];
    	List <PIR_Form__Share> insertShareList = new List <PIR_Form__Share>();
		Set <Id> addContactIds = new Set <Id>();
		for (Contact thisContact : addContactList){
			if (!thisContact.Portal_Application_Rights__r.isEmpty()){
				system.debug('CONTACT WITH ACCESS: ' + thisContact.Id);
				addContactIds.add(thisContact.Id);
			}
		}
		List <User> addUserList = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.Top_Parent__c
								FROM User WHERE ContactId IN :addContactIds];
		for (User thisUser : addUserList){
			if (thisUser.Id != UserInfo.getUserId()){
				for(PIR_Form__c newForm:trigger.new){
					if (addAccountMap.containsKey(newForm.Id)){
						if (addAccountMap.get(newForm.Id) == thisUser.Contact.AccountId
							|| addAccountMap.get(newForm.Id) == thisUser.Contact.Account.Top_Parent__c){
							
							system.debug('NEW SHARE');
							PIR_Form__Share newShare = new PIR_Form__Share();
				    		newShare.AccessLevel = 'Edit';
				    		newShare.ParentId = newForm.Id;
				    		newShare.UserOrGroupId = thisUser.Id;
				    		insertShareList.add(newShare);
						}
					}
				}
			}
			else{
				system.debug('IS THE RUNNING USER');
			}
		}
		if (!insertShareList.isEmpty()){
			insert insertShareList;
		}
    }
    
}