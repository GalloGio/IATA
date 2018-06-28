trigger trgCaseIFAP_AfterInsertDeleteUpdateUndelete on Case (after delete, after insert, after undelete, after update) {
   // the test class for IFAP 5.0 are  TriggerIFAPAfterClassTEst  and caschildhelpertest
   
    if(CaseChildHelper.noValidationsOnTrgCAseIFAP )return;


    ID IFAPcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');
    List<Case> cases;
    Boolean caseRecType = false;
    list<Case> casesToConsider = new list<Case>();

    Map<Id,IFAP_Quality_Issue__c> RelatedQualityIssues = new Map<Id,IFAP_Quality_Issue__c>();
    
    if (Trigger.isDelete) 
        cases = Trigger.old;
    else
        cases = Trigger.new;

    // If we are in the After update state and we have to process IFAP Cases, we need to get some values for all cases to avoid getting these values for each cases (101 too many soql queries Limitation)
    if (Trigger.isUpdate && Trigger.isAfter)
    {
        Set<Id> sCaseIds = new Set<Id>();
        
        // Check if received cases are IFAP Cases
        for(Case cse : cases){
            if(cse.RecordTypeId == IFAPcaseRecordTypeID){
                caseRecType = true;
            }else{
              break;
            }
            sCaseIds.add(cse.Id);
        }
        
        if (caseRecType){
            List<IFAP_Quality_Issue__c> QIs = [Select Status__c , Approved_Date__c, Related_Case__c from IFAP_Quality_Issue__c where Related_Case__r.Id IN: sCaseIds and Status__c = 'Pending approval'];
            
            // Create the map containing the quality issue 
            if (!QIs.isEmpty())
            {
                for(IFAP_Quality_Issue__c issue : QIs){
                    RelatedQualityIssues.put(issue.Related_Case__c, issue);
                }
            }
        }
    }
    
    list<IFAP_Quality_Issue__c> issues = new list<IFAP_Quality_Issue__c>();
    // get list of accounts
    System.debug('***Before checking record type');
    for(Case cse : cases) {


        if(cse.RecordTypeId == IFAPcaseRecordTypeID){
            caseRecType = true;
            casesToConsider.add(cse);
            
            
            if (Trigger.isUpdate){
                if (Trigger.isAfter){
                    // Bellow logic used for Quality issue  
                    Case OldCase =  Trigger.oldMap.get(cse.Id);
                    // approval
                    if(cse.Status == 'Quality Issue Request Approved' && OldCase.Status == 'Quality Issue Request Pending Approval')
                    {
                        IFAP_Quality_Issue__c QI = RelatedQualityIssues.get(cse.id);
                        //IFAP_Quality_Issue__c QI = [Select Status__c , Approved_Date__c from IFAP_Quality_Issue__c where Related_Case__r.Id =: cse.Id and Status__c = 'Pending approval' limit 1];
                        if (QI <> null){
                            //update Quality issue status to Approved
                            QI.Status__c = 'Approved';
                            //set approval date
                            QI.Approved_Date__c = system.now();
                            update QI;
                        }
                    }
                    if(cse.Status == 'Quality Issue Rejected' && OldCase.Status == 'Quality Issue Request Pending Approval')
                    {
                        IFAP_Quality_Issue__c QI = RelatedQualityIssues.get(cse.id);
                        //IFAP_Quality_Issue__c QI = [ Select Status__c , Approved_Date__c from IFAP_Quality_Issue__c where Related_Case__r.Id =: cse.Id and Status__c = 'Pending approval' limit 1];
                        if (QI <> null){
                            //update Quality issue status to rejected
                            QI.Status__c = 'Rejected';
                            QI.Approved_Date__c = system.now();
                            issues.add(QI);
                            //update QI;
                        }
                    }
                }
            }
             //break;*/

        }
        
    }
    update issues;
    
    /* IFAP P 5 start */  

    map<Id,Account> AcctToBeUpdatedPerId = new map<Id,Account>(); 
    if(trigger.isInsert || trigger.isUpdate){ 
        if(!casesToConsider.isEmpty() 
          && (trigger.isUpdate || trigger.isInsert)){
          list<Case> casesToUdpateTheAccts = new list<Case>();
          for(Case c: CasesToConsider)
            if(c.status == 'Assessment Performed' && c.Financial_Review_Result__c <> null &&
                    c.Assessment_Performed_Date__c <> null &&
                (trigger.isInsert   ||  //if not is update and we check if there were any changes
                              (trigger.newMap.get(c.id).Assessment_Performed_Date__c <> trigger.oldMap.get(c.id).Assessment_Performed_Date__c 
                                ||
                               trigger.newMap.get(c.id).Financial_Review_Result__c <> trigger.oldMap.get(c.id).Financial_Review_Result__c
                               ||
                              trigger.newMap.get(c.id).status  <> trigger.oldMap.get(c.id).status 
                              )
                )
              ){ 
                                       //   throw new transformationException('' + casesToUdpateTheAccts);  
            casesToUdpateTheAccts.add(c);
              }
              
          if(!casesToUdpateTheAccts.isEmpty())  {              
               // throw new transformationException();
                //AcctToBeUpdatedPerId =IFAP_AfterTrigger.updateTheAcctsTrigger(casesToUdpateTheAccts);
            }
      }          
    } 

    
    
    System.debug('***After checking record type ' + caseRecType);
    if(!casesToConsider.isEmpty()){
    //if(caseRecType){
        
        System.debug('***Do blah blah blah only for IFAP case related accounts ');
        Set<ID> acctIds = new Set<ID>();
        for (Case cse : casesToConsider) {
        //for (Case cse : cases) {

                acctIds.add(cse.AccountId);
        }
        
        //Re-open/ed is not considered as Closed Status anymore.
        //Map<ID, Case> casesForAccounts = new Map<ID, Case>([select Id
        //                                                        ,AccountId
        //                                                        from Case
        //                                                        where RecordTypeID =: IFAPcaseRecordTypeID AND (status != 'Closed' and status != 'Re-open/ed' and status != 'Assessment Cancelled') AND  AccountId in :acctIds]);
    
    Map<ID, Case> casesForAccounts = new Map<ID, Case>([select Id
                                                              ,AccountId
                                                              from Case
                                                              where


                                                              RecordTypeID =: IFAPcaseRecordTypeID
                                                                AND (status != 'Closed' and status != 'Assessment Cancelled') 
                                                              AND  AccountId in :acctIds]);



        Map<ID, Account> acctsToUpdate = new Map<ID, Account>([select Id
                                                                     ,Number_of_open_Financial_Review_Cases__c
                                                                      from Account
                                                                      where Id in :acctIds]);
        
        List<Account> accountUpdated = new List<Account>();
                                                                     
        for (Account acct : acctsToUpdate.values()) {
            Set<ID> caseIds = new Set<ID>();
            for (Case cse : casesForAccounts.values()) {
                if (cse.AccountId == acct.Id)
                    caseIds.add(cse.Id);
            }
            
            if (acct.Number_of_open_Financial_Review_Cases__c != caseIds.size()){
                acct.Number_of_open_Financial_Review_Cases__c = caseIds.size();
                
                if (caseIds.size() > 0){
                    acct.Has_Financial_Review_Open_Cases__c = true;
                }else{


                    acct.Has_Financial_Review_Open_Cases__c = false;
                }
                if(AcctToBeUpdatedPerId.get(acct.id) == null){
                
                AcctToBeUpdatedPerId.put(acct.id, acct);
             
              }else{
                
                acctToBeUpdatedPerId.get(acct.id).Has_Financial_Review_Open_Cases__c = acct.Has_Financial_Review_Open_Cases__c;
                

               }
                //accountUpdated.add(acct);
            }
        }
        /*if(accountUpdated.size() > 0) {
            update accountUpdated;
        }*/
        
        if(!acctToBeUpdatedPerId.isEmpty() && !acctToBeUpdatedPerId.values().isEmpty()) {
            update acctToBeUpdatedPerId.values();
        }
        
   /* IFAP P 5 end*/  




    
    /*Case child creation if Status = Assessment performed*/
    CaseChildHelper.CreateChildCase(Trigger.old, Trigger.new);
    /*END*/
        
        
    }
}