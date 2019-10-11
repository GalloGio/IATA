trigger ISSP_Baggage_Claim_Bags_Info on PIR_Bag_Information__c (after insert, after update) {
  system.debug('on trigger ISSP_Baggage_Claim_Flight_Info');
  Set <Id> addAccountIds = new Set<Id>();
  Map <Id, Set<Id>> addAccountMap = new Map <Id, Set<Id>>();
  Map <Id, Set<Id>> addAccountReceivingMap = new Map <Id, Set<Id>>();
  List <User> userList = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.Top_Parent__c
              FROM User WHERE Id = :UserInfo.getUserId()];

  Set<Id> pirFormIds = new Set<Id>();
  for(PIR_Bag_Information__c newBagsInfo:trigger.new){
      if (newBagsInfo.PIR_Form__c != null)
         pirFormIds.add(newBagsInfo.PIR_Form__c);
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
  for(PIR_Bag_Information__c newBagsInfo:trigger.new){
        if (trigger.isInsert){
          system.debug('ADDING ID: ' + newBagsInfo.Id);
          system.debug('PIR_Form__c: ' + newBagsInfo.PIR_Form__c);
          if (newBagsInfo.PIR_Form__c != null && BaggageClaimsMap.containsKey(newBagsInfo.PIR_Form__c)){
          	  for(Baggage_Claim__c claim:BaggageClaimsMap.get(newBagsInfo.PIR_Form__c)){
		          if (claim.Airline_receiving__c != null){
		            system.debug('ADDING ACCOUNT ID: ' + claim.Airline_receiving__c);
		            if(addAccountReceivingMap.containsKey(newBagsInfo.Id))
				  		addAccountReceivingMap.get(newBagsInfo.Id).add(claim.Airline_receiving__c);
				  	else
				  		addAccountReceivingMap.put(newBagsInfo.Id,new Set<Id>{claim.Airline_receiving__c});
		            addAccountIds.add(claim.Airline_receiving__c);
		          }
		          if (claim.Airline_Issuing_Id__c != ''){
		            system.debug('ADDING ACCOUNT ID: ' + claim.Airline_Issuing_Id__c);
		            if(addAccountMap.containsKey(newBagsInfo.Id))
				  		addAccountMap.get(newBagsInfo.Id).add(claim.Airline_Issuing_Id__c);
				  	else
				  		addAccountMap.put(newBagsInfo.Id,new Set<Id>{claim.Airline_Issuing_Id__c});
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
      List <PIR_Bag_Information__Share> insertShareList = new List <PIR_Bag_Information__Share>();
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
        for(PIR_Bag_Information__c newBagsInfo:trigger.new){
          if (addAccountMap.containsKey(newBagsInfo.Id)){
            system.debug('CHECK READ SHARE');
            system.debug('ACCOUNT ID: ' + thisUser.Contact.AccountId);
            system.debug('PARENT ACCOUNT ID: ' + thisUser.Contact.Account.Top_Parent__c);
            if (addAccountMap.get(newBagsInfo.Id).contains(thisUser.Contact.AccountId)
              || addAccountMap.get(newBagsInfo.Id).contains(thisUser.Contact.Account.Top_Parent__c)){
              
              system.debug('NEW READ SHARE: ' + addAccountMap.get(newBagsInfo.Id));
              
              PIR_Bag_Information__Share newShare = new PIR_Bag_Information__Share();
                newShare.AccessLevel = 'Read';
                newShare.ParentId = newBagsInfo.Id;
                newShare.UserOrGroupId = thisUser.Id;
                insertShareList.add(newShare);
               
            }
          }
          if (addAccountReceivingMap.containsKey(newBagsInfo.Id)){
            system.debug('CHECK READ SHARE');
            system.debug('ACCOUNT ID: ' + thisUser.Contact.AccountId);
            system.debug('PARENT ACCOUNT ID: ' + thisUser.Contact.Account.Top_Parent__c);
            if (addAccountReceivingMap.get(newBagsInfo.Id).contains(thisUser.Contact.AccountId)
              || addAccountReceivingMap.get(newBagsInfo.Id).contains(thisUser.Contact.Account.Top_Parent__c)){
              
              PIR_Bag_Information__Share newShare = new PIR_Bag_Information__Share();
                newShare.AccessLevel = 'Read';
                newShare.ParentId = newBagsInfo.Id;
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