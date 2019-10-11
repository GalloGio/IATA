trigger ISSP_Baggage_Claim_Comment on Baggage_Claim_Comment__c (after insert, after update) {

	system.debug('on trigger ISSP_Baggage_Claim_Comment');
	Set <Id> addAccountIds = new Set<Id>();
	Map <Id, Id> addAccountMap = new Map <Id, Id>();
	Map <Id, Id> addAccountReceivingMap = new Map <Id, Id>();
	Map <Id, Id> receivedDateMap = new Map <Id, Id>();
	Map <Id, Id> issuingDateMap = new Map <Id, Id>();
	Set <Id> receivedDateIds = new Set <Id>();
	Set <Id> issuingDateIds = new Set <Id>();
	List <User> userList = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.Top_Parent__c
							FROM User WHERE Id = :UserInfo.getUserId()];
	String accountId = '';
	String topAccountId = '';
	if (!userList.isEmpty()){
		if (userList[0].ContactId != null){
			accountId = userList[0].Contact.AccountId;
			topAccountId = userList[0].Contact.Account.Top_Parent__c;
		}
	}
	system.debug('accountId: ' + accountId);
	system.debug('topAccountId: ' + topAccountId);
	for(Baggage_Claim_Comment__c newComment:trigger.new){
        if (trigger.isInsert){
        	system.debug('ADDING ID: ' + newComment.Id);
        	system.debug('Account_Receiving_Id__c: ' + newComment.Account_Receiving_Id__c);
        	system.debug('Account_Issuing_Id__c: ' + newComment.Account_Issuing_Id__c);
        	if (newComment.Account_Receiving_Id__c != null && newComment.Account_Receiving_Id__c != ''){
        		system.debug('ADDING ACCOUNT ID: ' + newComment.Account_Receiving_Id__c);
        		addAccountReceivingMap.put(newComment.Id, newComment.Account_Receiving_Id__c);
        		addAccountIds.add(newComment.Account_Receiving_Id__c);
        		if (newComment.Account_Receiving_Id__c == accountId || newComment.Account_Receiving_Id__c == topAccountId){
        			system.debug('receiving account: ' + newComment.Baggage_Claim__c);
        			if (!receivedDateMap.containsKey(newComment.Baggage_Claim__c)){
        				receivedDateMap.put(newComment.Baggage_Claim__c, newComment.Baggage_Claim__c);
        				receivedDateIds.add(newComment.Baggage_Claim__c);
        			}
        		}
        	}
        	if (newComment.Account_Issuing_Id__c != null && newComment.Account_Issuing_Id__c != ''){
        		system.debug('ADDING ACCOUNT ID: ' + newComment.Account_Issuing_Id__c);
        		addAccountMap.put(newComment.Id, newComment.Account_Issuing_Id__c);
        		addAccountIds.add(newComment.Account_Issuing_Id__c);
        		if (newComment.Account_Issuing_Id__c == accountId || newComment.Account_Issuing_Id__c == topAccountId){
        			system.debug('issuing account: ' + newComment.Baggage_Claim__c);
        			if (!issuingDateMap.containsKey(newComment.Baggage_Claim__c)){
        				issuingDateMap.put(newComment.Baggage_Claim__c, newComment.Baggage_Claim__c);
        				issuingDateIds.add(newComment.Baggage_Claim__c);
        			}
        		}
        	}
        }
    }
    
    if (!addAccountIds.isEmpty()){
    	List <Contact> addContactList = [SELECT Id,
    					(SELECT Id FROM Portal_Application_Rights__r WHERE Right__c = 'Access Granted'
    					AND Application_Name__c = 'Baggage Proration')
    					FROM Contact
    					WHERE AccountId IN :addAccountIds OR Account.Top_Parent__c IN :addAccountIds];
		system.debug('addAccountIds: ' + addAccountIds);
    	List <Baggage_Claim_Comment__Share> insertShareList = new List <Baggage_Claim_Comment__Share>();
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
				for(Baggage_Claim_Comment__c newComment:trigger.new){
					if (addAccountMap.containsKey(newComment.Id)){
						system.debug('CHECK READ SHARE');
						system.debug('ACCOUNT ID: ' + thisUser.Contact.AccountId);
						system.debug('PARENT ACCOUNT ID: ' + thisUser.Contact.Account.Top_Parent__c);
						if (addAccountMap.get(newComment.Id) == thisUser.Contact.AccountId
							|| addAccountMap.get(newComment.Id) == thisUser.Contact.Account.Top_Parent__c){
							
							system.debug('NEW READ SHARE: ' + addAccountMap.get(newComment.Id));
							Baggage_Claim_Comment__Share newShare = new Baggage_Claim_Comment__Share();
				    		newShare.AccessLevel = 'Read';
				    		newShare.ParentId = newComment.Id;
				    		newShare.UserOrGroupId = thisUser.Id;
				    		insertShareList.add(newShare);
						}
					}
					if (addAccountReceivingMap.containsKey(newComment.Id)){
						system.debug('CHECK READ SHARE');
						system.debug('ACCOUNT ID: ' + thisUser.Contact.AccountId);
						system.debug('PARENT ACCOUNT ID: ' + thisUser.Contact.Account.Top_Parent__c);
						if (addAccountReceivingMap.get(newComment.Id) == thisUser.Contact.AccountId
							|| addAccountReceivingMap.get(newComment.Id) == thisUser.Contact.Account.Top_Parent__c){
							
							Baggage_Claim_Comment__Share newShare = new Baggage_Claim_Comment__Share();
				    		newShare.AccessLevel = 'Read';
				    		newShare.ParentId = newComment.Id;
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
    
    system.debug('receivedDateIds: ' + receivedDateIds);
    system.debug('issuingDateIds: ' + issuingDateIds);
    if (!receivedDateIds.isEmpty() || !issuingDateIds.isEmpty()){
    	List <Baggage_Claim__c> claimList = [SELECT Id, PIR_Request_Sent_Date__c, Request_Sent_Date_Formated__c FROM Baggage_Claim__c WHERE Id IN: receivedDateIds
    										OR Id IN: issuingDateIds];
    	if (!claimList.isEmpty()){
    		system.debug('CLAIM LIST NOT EMPTY');
    		for (Baggage_Claim__c thisClaim : claimList){
    			system.debug('CLAIM ID: ' + thisClaim.Id);
    			if (receivedDateIds.contains(thisClaim.Id)){
    				system.debug('updating 1 receiving claim');
    				thisClaim.Tech_Last_Comment_Receiving_Date_Time__c = system.now();
    			}
    			if (issuingDateIds.contains(thisClaim.Id)){
    				system.debug('updating 1 issuing claim');
    				thisClaim.Tech_Last_Comment_Issuing_Date_Time__c = system.now();
    			}
    			if (thisClaim.PIR_Request_Sent_Date__c == null){
    				thisClaim.PIR_Request_Sent_Date__c = system.today();
    				Datetime requestSentDateTime = datetime.newInstance(thisClaim.PIR_Request_Sent_Date__c.year(), thisClaim.PIR_Request_Sent_Date__c.month(),thisClaim.PIR_Request_Sent_Date__c.day());
                    thisClaim.Request_Sent_Date_Formated__c = ISSP_Baggage_Proration.getFormatedDate(requestSentDateTime);
    			}
    		}
    		update claimList;
    	}
    }
}