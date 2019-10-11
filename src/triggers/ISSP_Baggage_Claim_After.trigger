trigger ISSP_Baggage_Claim_After on Baggage_Claim__c (after insert, after update) {

	Set <Id> addAccountIds = new Set<Id>();
	Map <Id, Id> addAccountMap = new Map <Id, Id>();
	Map <Id, Id> addEditAccountMap = new Map <Id, Id>();
	Set <Id> removeAccountIds = new Set<Id>();
	Map <Id, Id> removeAccountMap = new Map <Id, Id>();
	Set <Id> pirFormIds = new Set<Id>();
	Map <Id, Set<Id>> flightInfoMap = new Map <Id, Set<Id>>();
	Map <Id, Set<Id>> bagInfoMap = new Map <Id, Set<Id>>();
	for(Baggage_Claim__c newClaim:trigger.new){
        if (trigger.isInsert){
        	system.debug('ADDING ID: ' + newClaim.Id);
        	if (newClaim.Airline_receiving__c != null){
        		system.debug('ADDING ACCOUNT ID: ' + newClaim.Airline_receiving__c);
        		addAccountMap.put(newClaim.Id, newClaim.Airline_receiving__c);
        		addAccountIds.add(newClaim.Airline_receiving__c);
        	}
        	if (newClaim.Airline_Issuing_Id__c != null && newClaim.Airline_Issuing_Id__c != ''){
        		system.debug('PARENT ACCOUNT ID: ' + newClaim.Airline_Issuing_Id__c);
        		addEditAccountMap.put(newClaim.Id, newClaim.Airline_Issuing_Id__c);
        		addAccountIds.add(newClaim.Airline_Issuing_Id__c);
        	}

        	if (newClaim.Parent_PIR_Form__c!=null && (newClaim.Airline_receiving__c != null || (newClaim.Airline_Issuing_Id__c != null && newClaim.Airline_Issuing_Id__c != '')))
        		pirFormIds.add(newClaim.Parent_PIR_Form__c);
        }
        else if (trigger.isUpdate){
        	Baggage_Claim__c oldClaim = trigger.oldMap.get(newClaim.Id);
        	if (newClaim.Airline_receiving__c != oldClaim.Airline_receiving__c){
        		if (newClaim.Airline_receiving__c != null){
        			system.debug('CHANGING ACCOUNT ID: ' + newClaim.Airline_receiving__c);
        			addAccountMap.put(newClaim.Id, newClaim.Airline_receiving__c);
        			addAccountIds.add(newClaim.Airline_receiving__c);
        			if (newClaim.Parent_PIR_Form__c!=null)
        				pirFormIds.add(newClaim.Parent_PIR_Form__c);
        		}
        		if (oldClaim.Airline_receiving__c != null){
        			system.debug('REMOVING ACCOUNT ID: ' + newClaim.Airline_receiving__c);
        			removeAccountMap.put(newClaim.Id, oldClaim.Airline_receiving__c);
        			removeAccountIds.add(oldClaim.Airline_receiving__c);
        		}
        	}
        }
    }

    for(Flight_Information__c flightInfo : [select Id, Name, PIR_Ref__c From Flight_Information__c Where PIR_Ref__c IN: pirFormIds]){
    	if(flightInfoMap.containsKey(flightInfo.PIR_Ref__c))
	  		flightInfoMap.get(flightInfo.PIR_Ref__c).add(flightInfo.Id);
	  	else
	  		flightInfoMap.put(flightInfo.PIR_Ref__c,new Set<Id>{flightInfo.Id});
    }

    for(PIR_Bag_Information__c bagInfo : [select Id, Name, PIR_Form__c From PIR_Bag_Information__c Where PIR_Form__c IN: pirFormIds]){
    	if(bagInfoMap.containsKey(bagInfo.PIR_Form__c))
	  		bagInfoMap.get(bagInfo.PIR_Form__c).add(bagInfo.Id);
	  	else
	  		bagInfoMap.put(bagInfo.PIR_Form__c,new Set<Id>{bagInfo.Id});
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
		system.debug('addAccountIds: ' + addAccountIds);
    	
    	List <Sobject> insertShareList = new List <Sobject>();
    	List <Sobject> baggageClaimShareList = new List <Sobject>();
    	List <Sobject> flightInformationShareList = new List <Sobject>();
    	List <Sobject> pirBagInformationShareList = new List <Sobject>();

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
				for(Baggage_Claim__c newClaim:trigger.new){
					if (addAccountMap.containsKey(newClaim.Id)){
						system.debug('CHECK READ SHARE');
						system.debug('ACCOUNT ID: ' + thisUser.Contact.AccountId);
						system.debug('PARENT ACCOUNT ID: ' + thisUser.Contact.Account.Top_Parent__c);
						if (addAccountMap.get(newClaim.Id) == thisUser.Contact.AccountId
							|| addAccountMap.get(newClaim.Id) == thisUser.Contact.Account.Top_Parent__c){
							
							system.debug('NEW READ SHARE: ' + addAccountMap.get(newClaim.Id));
							Baggage_Claim__Share newShare = new Baggage_Claim__Share();
				    		newShare.AccessLevel = 'Read';
				    		newShare.ParentId = newClaim.Id;
				    		newShare.UserOrGroupId = thisUser.Id;
				    		// insertShareList.add(newShare);
							baggageClaimShareList.add(newShare);

				    		if(newClaim.Parent_PIR_Form__c!=null && flightInfoMap.containsKey(newClaim.Parent_PIR_Form__c)){
				    			for(Id flightInfoId :flightInfoMap.get(newClaim.Parent_PIR_Form__c)){
					    			Flight_Information__Share newFlightShare = new Flight_Information__Share();
					                newFlightShare.AccessLevel = 'Read';
					                newFlightShare.ParentId = flightInfoId;
					                newFlightShare.UserOrGroupId = thisUser.Id;
					                // insertShareList.add(newFlightShare);
									flightInformationShareList.add(newFlightShare);
					            }
				    		}

				    		if(newClaim.Parent_PIR_Form__c!=null && bagInfoMap.containsKey(newClaim.Parent_PIR_Form__c)){
				    			for(Id bagInfoId :bagInfoMap.get(newClaim.Parent_PIR_Form__c)){
					    			PIR_Bag_Information__Share newBagShare = new PIR_Bag_Information__Share();
					                newBagShare.AccessLevel = 'Read';
					                newBagShare.ParentId = bagInfoId;
					                newBagShare.UserOrGroupId = thisUser.Id;
					                // insertShareList.add(newBagShare);
									pirBagInformationShareList.add(newBagShare);
					            }
				    		}

						}
					}
					if (addEditAccountMap.containsKey(newClaim.Id)){
						system.debug('CHECK EDIT SHARE');
						system.debug('ACCOUNT ID: ' + thisUser.Contact.AccountId);
						system.debug('PARENT ACCOUNT ID: ' + thisUser.Contact.Account.Top_Parent__c);
						if (addEditAccountMap.get(newClaim.Id) == thisUser.Contact.AccountId
							|| addEditAccountMap.get(newClaim.Id) == thisUser.Contact.Account.Top_Parent__c){
							
							system.debug('NEW EDIT SHARE: ' + addAccountMap.get(newClaim.Id));
							Baggage_Claim__Share newShare = new Baggage_Claim__Share();
				    		newShare.AccessLevel = 'Edit';
				    		newShare.ParentId = newClaim.Id;
				    		newShare.UserOrGroupId = thisUser.Id;
				    		// insertShareList.add(newShare);
							baggageClaimShareList.add(newShare);
						}

						if(newClaim.Parent_PIR_Form__c!=null && flightInfoMap.containsKey(newClaim.Parent_PIR_Form__c)){
			    			for(Id flightInfoId :flightInfoMap.get(newClaim.Parent_PIR_Form__c)){
				    			Flight_Information__Share newFlightShare = new Flight_Information__Share();
				                newFlightShare.AccessLevel = 'Read';
				                newFlightShare.ParentId = flightInfoId;
				                newFlightShare.UserOrGroupId = thisUser.Id;
				                // insertShareList.add(newFlightShare);
								flightInformationShareList.add(newFlightShare);
				            }
			    		}

			    		if(newClaim.Parent_PIR_Form__c!=null && bagInfoMap.containsKey(newClaim.Parent_PIR_Form__c)){
			    			for(Id bagInfoId :bagInfoMap.get(newClaim.Parent_PIR_Form__c)){
				    			PIR_Bag_Information__Share newBagShare = new PIR_Bag_Information__Share();
				                newBagShare.AccessLevel = 'Read';
				                newBagShare.ParentId = bagInfoId;
				                newBagShare.UserOrGroupId = thisUser.Id;
				                // insertShareList.add(newBagShare);
								pirBagInformationShareList.add(newBagShare);
				            }
			    		}
					}
				}
			}
			else{
				system.debug('IS THE RUNNING USER');
			}
		}

		insertShareList.addAll(baggageClaimShareList);  
		insertShareList.addAll(flightInformationShareList);
		insertShareList.addAll(pirBagInformationShareList);
		if (!insertShareList.isEmpty()){
			insert insertShareList;
		}
    }
}