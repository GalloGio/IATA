trigger ISSP_Baggage_Claim_Flight_Info on Flight_Information__c (after insert, after update) {
  system.debug('on trigger ISSP_Baggage_Claim_Flight_Info');
  Set <Id> addAccountIds = new Set<Id>();
  Map <Id, Set<Id>> addAccountMap = new Map <Id, Set<Id>>();
  Map <Id, Set<Id>> addAccountReceivingMap = new Map <Id, Set<Id>>();
  List <User> userList = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.Top_Parent__c
              FROM User WHERE Id = :UserInfo.getUserId()];

  Set<Id> pirFormIds = new Set<Id>();
  for(Flight_Information__c newFlightInfo:trigger.new){
      if (newFlightInfo.PIR_Ref__c != null)
         pirFormIds.add(newFlightInfo.PIR_Ref__c);
  }

  List<Baggage_Claim__c> baggageClaims = [SELECT Airline_Issuing_Id__c,Airline_receiving__c,Parent_PIR_Form__c FROM Baggage_Claim__c WHERE Parent_PIR_Form__c IN :pirFormIds];
  Map<Id,List<Baggage_Claim__c>> BaggageClaimsMap = new Map<Id,List<Baggage_Claim__c>>(); 
  String accountId = '';
  String topAccountId = '';
  if (!userList.isEmpty()){
    if (userList[0].ContactId != null){
      accountId = userList[0].Contact.AccountId;
      topAccountId = userList[0].Contact.Account.Top_Parent__c;
    }
  }
  for(Baggage_Claim__c claim :baggageClaims){
  	if(BaggageClaimsMap.containsKey(claim.Parent_PIR_Form__c))
  		BaggageClaimsMap.get(claim.Parent_PIR_Form__c).add(claim);
  	else
  		BaggageClaimsMap.put(claim.Parent_PIR_Form__c,new List<Baggage_Claim__c>{claim});
  }

  system.debug('accountId: ' + accountId);
  system.debug('topAccountId: ' + topAccountId);
  for(Flight_Information__c newFlightInfo:trigger.new){
        if (trigger.isInsert){
          system.debug('ADDING ID: ' + newFlightInfo.Id);
          system.debug('PIR_Ref__c: ' + newFlightInfo.PIR_Ref__c);
          if (newFlightInfo.PIR_Ref__c != null && BaggageClaimsMap.containsKey(newFlightInfo.PIR_Ref__c)){
          	  for(Baggage_Claim__c claim:BaggageClaimsMap.get(newFlightInfo.PIR_Ref__c)){
		          if (claim.Airline_receiving__c != null){
		            system.debug('ADDING ACCOUNT ID: ' + claim.Airline_receiving__c);
		            if(addAccountReceivingMap.containsKey(newFlightInfo.Id))
				  		addAccountReceivingMap.get(newFlightInfo.Id).add(claim.Airline_receiving__c);
				  	else
				  		addAccountReceivingMap.put(newFlightInfo.Id,new Set<Id>{claim.Airline_receiving__c});
		            addAccountIds.add(claim.Airline_receiving__c);
		          }
		          if (claim.Airline_Issuing_Id__c != ''){
		            system.debug('ADDING ACCOUNT ID: ' + claim.Airline_Issuing_Id__c);
		            if(addAccountMap.containsKey(newFlightInfo.Id))
				  		addAccountMap.get(newFlightInfo.Id).add(claim.Airline_Issuing_Id__c);
				  	else
				  		addAccountMap.put(newFlightInfo.Id,new Set<Id>{claim.Airline_Issuing_Id__c});
		            addAccountIds.add(claim.Airline_Issuing_Id__c);
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
      List <Flight_Information__Share> insertShareList = new List <Flight_Information__Share>();
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
        for(Flight_Information__c newFlightInfo:trigger.new){
          if (addAccountMap.containsKey(newFlightInfo.Id)){
            system.debug('CHECK READ SHARE');
            system.debug('ACCOUNT ID: ' + thisUser.Contact.AccountId);
            system.debug('PARENT ACCOUNT ID: ' + thisUser.Contact.Account.Top_Parent__c);
            if (addAccountMap.get(newFlightInfo.Id).contains(thisUser.Contact.AccountId)
              || addAccountMap.get(newFlightInfo.Id).contains(thisUser.Contact.Account.Top_Parent__c)){
              
              system.debug('NEW READ SHARE: ' + addAccountMap.get(newFlightInfo.Id));
              
              Flight_Information__Share newShare = new Flight_Information__Share();
                newShare.AccessLevel = 'Read';
                newShare.ParentId = newFlightInfo.Id;
                newShare.UserOrGroupId = thisUser.Id;
                insertShareList.add(newShare);
               
            }
          }
          if (addAccountReceivingMap.containsKey(newFlightInfo.Id)){
            system.debug('CHECK READ SHARE');
            system.debug('ACCOUNT ID: ' + thisUser.Contact.AccountId);
            system.debug('PARENT ACCOUNT ID: ' + thisUser.Contact.Account.Top_Parent__c);
            if (addAccountReceivingMap.get(newFlightInfo.Id).contains(thisUser.Contact.AccountId)
              || addAccountReceivingMap.get(newFlightInfo.Id).contains(thisUser.Contact.Account.Top_Parent__c)){
              
              Flight_Information__Share newShare = new Flight_Information__Share();
                newShare.AccessLevel = 'Read';
                newShare.ParentId = newFlightInfo.Id;
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