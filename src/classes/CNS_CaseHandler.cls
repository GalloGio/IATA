public without sharing class CNS_CaseHandler {
 

  public static void ManageCNSCaseOnBeforeInsertUpdate(List<Case> newCases){

    Set <Id> accountIdSet = new Set <Id> ();
    
    for(Case c: newCases){
      if(c.Origin=='Portal' && c.AccountId!=null){
        accountIdSet.add(c.AccountId);  
      }
    }

    
    Map <Id, Account> accountMap = new Map <Id, Account> ([select Id, CNS_Account__c, CNS_Agency__c, RecordType.DeveloperName, (select Id, CNS_Contact__c from Contacts) from Account where Id in: accountIdSet]);
    Map <Id, Contact> contactMap = new Map <Id, Contact> ();

   for(Account a: accountMap.values()){
      for(Contact c: a.Contacts){
        contactMap.put(c.Id, c);
      }      
    }

    for(Case c: newCases){

      //for agencies and standard accounts set as CNS Account, cases will be considered to be CNS
       
      if(accountMap.containsKey(c.AccountId) && (accountMap.get(c.AccountId).CNS_Agency__c || accountMap.get(c.AccountId).CNS_Account__c) && 
        (accountMap.get(c.AccountId).RecordType.DeveloperName == 'IATA_Agency' || accountMap.get(c.AccountId).RecordType.DeveloperName == 'Standard_Account' )){ 
          c.CNSCase__c=true;
      }

      //TBD management for other types of accounts: airlines, GSSAS, public etc
      
    }
    
  }

}