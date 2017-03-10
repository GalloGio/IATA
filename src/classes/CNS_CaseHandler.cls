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

    //Query for custom setting holding the topics and subtopics considered to be cns.
    Map <Id, ISSP_CNS_Topics_Subtopics__c> cnsTopics = new Map <Id, ISSP_CNS_Topics_Subtopics__c> ([select Id, Topic__c, Subtopics__c, Subtopics2__c from ISSP_CNS_Topics_Subtopics__c]);

    Map <String, ISSP_CNS_Topics_Subtopics__c> cnsTopicMap = new Map <String, ISSP_CNS_Topics_Subtopics__c> ();
    for(ISSP_CNS_Topics_Subtopics__c ct: cnsTopics.values()){
        cnsTopicMap.put(ct.Topic__c, ct);
    }

    for(Case c: newCases){

      if(c.Origin == 'Portal' && c.Topic__c!=null){

         //for agencies and standard accounts set as CNS Account, cases will be considered to be CNS       
        if(accountMap.containsKey(c.AccountId) && (accountMap.get(c.AccountId).CNS_Agency__c || accountMap.get(c.AccountId).CNS_Account__c) && 
          (accountMap.get(c.AccountId).RecordType.DeveloperName == 'IATA_Agency' || accountMap.get(c.AccountId).RecordType.DeveloperName == 'Standard_Account' )){ 
            c.CNSCase__c= true;
            c.Groups__c = 'CNS Team'; // important field to be used on E2C premium
        }
        //Management for other types of accounts: airlines, GSSAS, public etc
        //Based on topics set on the custom setting: 
        if(cnsTopicMap.containsKey(c.Topic__c)){
          c.CNSCase__c = true;
          c.Groups__c = 'CNS Team'; // important field to be used on E2C premium
        }

      }
      
      
    }
    
  }

}