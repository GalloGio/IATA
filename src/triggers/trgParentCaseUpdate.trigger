trigger trgParentCaseUpdate on Case (after insert, before update){
    
    /* Created Date - 16-12-2010 */
    
      //  TO FUTURE REVIEWER....IT WILL BE NICE TO FIND OUT WHY THIS TRIGGER WAS DEVELOPED AND WHY THE CONDITION ON LINE 18 FOR ALL CASES BUT IFAP
      // PLEASE REVIEW IT...
    Set<Id> CaseIdsNew = new Set<Id>();    
    Integer futureLimit = Limits.getFutureCalls();
    
    System.Debug('futureLimit : ----- '+ futureLimit);         
    /*get the IFAP case recordtype*/
    ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
    ID FSMcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Security_Monitoring');
    Boolean isIFAPCase = false;
    
    
    list<Case> cases = new list<Case>(); 
    for(Case c: trigger.new){
    
      if(c.parentId != null
      	&& ! (c.RecordTypeId == IFAPcaseRecordTypeID || c.Reason1__c == 'FA/ FS Non-Compliance')
      	&& ( c.RecordTypeId != FSMcaseRecordTypeID )
      ){
    
    		cases.add(c);
    	
    	}
    }

    if(!cases.isempty()){    
      if(futureLimit < 10){ 
          if (!FutureProcessorControl.inFutureContext && !System.isBatch()){  // do not execute if in a Batch context - added 2014-12-10 Constantin Buzduga
              //Passing and calling the class according to the event     
              If(Trigger.isInsert){ 
                  for(Case ObjCaseNew: cases){
                    
                    // do not execute for IFAP cases - 2012-01-13 Alexandre McGraw
                    if (ObjCaseNew.RecordTypeId == IFAPcaseRecordTypeID)
                      continue;
                    
                      CaseIdsNew.add(ObjCaseNew.Id);
                      
                  }
                  if(CaseIdsNew.Size() > 0){
                      clsInternalCaseDML.InternalCaseDMLMethod(CaseIdsNew, 'Insert');
                  }                           
              }
              else if(Trigger.isUpdate){ 
                  /*Adding the new case records in the List*/    
                  for(Case ObjCaseNew: Trigger.New){    
                    
                    /* do not execute for IFAP cases - 2012-01-13 Alexandre McGraw*/
                    if (ObjCaseNew.RecordTypeId == IFAPcaseRecordTypeID)
                      continue;
                        
                     
                      for(Case ObjCaseOld : Trigger.Old){         
                          
                          if(ObjCaseNew.Status != ObjCaseOld.Status && ObjCaseOld.Status != 'Closed' && ObjCaseNew.Status == 'Closed'){
                              CaseIdsNew.add(ObjCaseNew.Id);
                                
                          }                   
                      }        
                  } 
                  if(CaseIdsNew.Size() > 0){       
                      clsInternalCaseDML.InternalCaseDMLMethod(CaseIdsNew, 'Update');
                  }
              }
          }       
      } 
    
   }                   
}