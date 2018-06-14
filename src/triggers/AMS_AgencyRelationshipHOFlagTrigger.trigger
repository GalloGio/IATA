trigger AMS_AgencyRelationshipHOFlagTrigger on AMS_Agencies_relationhip__c (before insert, before update) {

  //List<AMS_Agencies_relationhip__c> agParentToBeChecked = new List<AMS_Agencies_relationhip__c>();
  //List<AMS_Agencies_relationhip__c> agChildToBeChecked = new List<AMS_Agencies_relationhip__c>();
  //List<AMS_Agencies_relationhip__c> agToUpdate = new List<AMS_Agencies_relationhip__c>();

  //Map<Id, List<AMS_Agencies_relationhip__c>> mAgParentToBeChecked = new Map<Id, List<AMS_Agencies_relationhip__c>>();
  //Map<Id, List<AMS_Agencies_relationhip__c>> mAgChildToBeChecked = new Map<Id, List<AMS_Agencies_relationhip__c>>();

  //SET<Id> setAgencyParentKeys = new SET<Id>();
  //SET<Id> setRelationshipKeys = new SET<Id>();
  
  //List<AMS_Agencies_relationhip__c> relationshipsForDeletion = new List<AMS_Agencies_relationhip__c>();
  
  //SET<Id> agencyAccounts = new Set<Id>();
  //List<Account> accountsToCleanup = new List<Account>();

  //Id rtMain = Schema.SObjectType.AMS_Agencies_Hierarchy__c.getRecordTypeInfosByName().get('MAIN').getRecordTypeId();


  //if(Trigger.isInsert || Trigger.isUpdate){
  
  //  try{
    
  //      for(AMS_Agencies_relationhip__c agRel : Trigger.new){
  //        setAgencyParentKeys.add(agRel.Parent_Account__c);
  //        setRelationshipKeys.add(agRel.Id);
  //      }
        
  //      if(Trigger.isInsert){
  //          //get all the relationships having the child agency equal to the parent agency of the relation we are trying to insert
  //          List<AMS_Agencies_relationhip__c> allRelationships = [SELECT Id, Child_Account__c, Parent_Account__c FROM AMS_Agencies_relationhip__c WHERE Child_Account__c IN :setAgencyParentKeys];
              
  //          for(AMS_Agencies_relationhip__c agRel : Trigger.new){
  //              Id parentID = agRel.Parent_Account__c;
  //              Id childID = agRel.Child_Account__c;
                    
  //              for(AMS_Agencies_relationhip__c agRelAux : allRelationships){
  //                  if(agRelAux.Parent_Account__c == childID && agRelAux.Child_Account__c == parentID){
  //                      System.debug('Found a reverse relationship: ' + agRelAux);
  //                      relationshipsForDeletion.add(agRelAux);
  //                      //save the agency account because we need to delete the respective account ParentId
  //                      agencyAccounts.add(agRelAux.Child_Account__c);
  //                  }
  //              }
  //          }
  //      }
        
  //      accountsToCleanup = [SELECT Id, ParentId FROM Account WHERE Id IN: agencyAccounts];
        
  //      for(Account acc: accountsToCleanup){
  //          System.debug('Deleting parentID from Account: '+ acc.ID);
  //          acc.parentID = null;
  //      }
        
  //      if(accountsToCleanup != null && accountsToCleanup.size() > 0)
  //          update accountsToCleanup;
        
  //      if(relationshipsForDeletion != null && relationshipsForDeletion.size() > 0)
  //          delete relationshipsForDeletion;

  //        //get relationship where the agencies are parents
  //        agParentToBeChecked = [SELECT Child_Account__c,Hierarchy__r.Hierarchy_Name__c,HO_Flag__c,Id,Name,Parent_Account__c FROM AMS_Agencies_relationhip__c
  //                    where Parent_Account__c in :setAgencyParentKeys
  //                    and id not in :setRelationshipKeys
  //                    and Hierarchy__r.RecordTypeId = :rtMain];

  //      //get relationship where the agencies are Childrens
  //        agChildToBeChecked = [SELECT Child_Account__c,Hierarchy__r.Hierarchy_Name__c,HO_Flag__c,Id,Name,Parent_Account__c FROM AMS_Agencies_relationhip__c 
  //                    where Child_Account__c in :setAgencyParentKeys 
  //                    and id not in :setRelationshipKeys
  //                    and Hierarchy__r.RecordTypeId = :rtMain];

  //        for(AMS_Agencies_relationhip__c agRel : agParentToBeChecked){
  //          List<AMS_Agencies_relationhip__c> auxAgRel = mAgParentToBeChecked.get(agRel.Parent_Account__c);
  //          if(auxAgRel != Null && auxAgRel.size() > 0){
  //            auxAgRel.add(agRel);
  //            mAgParentToBeChecked.remove(agRel.Parent_Account__c);

  //            mAgParentToBeChecked.put(agRel.Parent_Account__c,auxAgRel);
  //          }
  //          else{
  //            auxAgRel = new List<AMS_Agencies_relationhip__c>();
  //            auxAgRel.add(agRel);
  //            mAgParentToBeChecked.put(agRel.Parent_Account__c,auxAgRel);  
  //          }
          
  //      }  

  //      for(AMS_Agencies_relationhip__c agRel : agChildToBeChecked){
  //        List<AMS_Agencies_relationhip__c> auxAgRel = mAgChildToBeChecked.get(agRel.Child_Account__c);
  //          if(auxAgRel != Null && auxAgRel.size() > 0){
  //            auxAgRel.add(agRel);
  //            mAgChildToBeChecked.remove(agRel.Child_Account__c);
  //            mAgChildToBeChecked.put(agRel.Child_Account__c,auxAgRel);
  //          }
  //          else{
  //            auxAgRel = new List<AMS_Agencies_relationhip__c>();
  //            auxAgRel.add(agRel);
  //            mAgChildToBeChecked.put(agRel.Child_Account__c,auxAgRel);  
  //          }
  //      }

  //      Boolean bHOFlag = False;

  //      //Logic for Insert/Update
  //      if(Trigger.isInsert || Trigger.isUpdate){
           
  //         for(AMS_Agencies_relationhip__c agRel : Trigger.new){
          
  //          //Check if Parent and not a children! if so HO_FLAG = true
  //           if(mAgParentToBeChecked.containsKey(agRel.Parent_Account__c) && !mAgChildToBeChecked.containsKey(agRel.Parent_Account__c)){ 
  //             bHOFlag = True;
  //           }else if(mAgParentToBeChecked.containsKey(agRel.Parent_Account__c) && mAgChildToBeChecked.containsKey(agRel.Parent_Account__c)){
  //             bHOFlag = False;

  //             List<AMS_Agencies_relationhip__c> auxAgParentToBeChecked = mAgParentToBeChecked.get(agRel.Parent_Account__c);

  //             for(AMS_Agencies_relationhip__c auxAgRel: auxAgParentToBeChecked){

  //              if(auxAgRel.HO_Flag__c != Null && !auxAgRel.HO_Flag__c.equalsIgnoreCase(String.valueOf(bHOFlag))){
  //                 auxAgRel.HO_Flag__c = String.valueOf(bHOFlag);

  //                if(auxAgRel.Id != agRel.Id){
  //                   agToUpdate.add(auxAgRel);
  //                 }else{
  //                   agRel.HO_Flag__c = String.valueOf(bHOFlag);
  //                 }
  //               }
  //             } 
  //           }

  //           if(agRel.HO_Flag__c == Null || !agRel.HO_Flag__c.equalsIgnoreCase(String.valueOf(bHOFlag))){
  //             agRel.HO_Flag__c = String.valueOf(bHOFlag);
  //           }
  //        }

  //        if(agToUpdate != Null && agToUpdate.size() > 0){
  //           update agToUpdate;
  //         }
  //      }
    
  //  }catch(Exception ex){
  //          transformationHelper.sendSFDevsAlertMessage('error',
  //                   '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'macaricol@iata.org', 'portelar@iata.org', 'goncalvesd@iata.org', 'mouzinhof@iata.org', 'fonterayj@iata.org'});
  //  }
  // }
}