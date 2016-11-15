/**
 * Trigger that creates a Service Rendered record if the Case Area is Airline Joining / Leaving, 
 * the case record type is "IDFS Airline Participation Process" and the case is approved
 */

trigger trgCreateUpdateServiceRenderedRecord on Case (after insert, after update,
                                                        before insert , before update) {
 
 
     
     string airlineLeaving = 'Airline Leaving';
     string airlineJoining = 'Airline Joining';
     string airlineSuspension = 'Airline Suspension Process';
     String separator = '%%%__%%%';
     
     string APCaseRTID =Schema.SObjectType.Case.RecordTypeInfosByName.get('IDFS Airline Participation Process').RecordTypeId ;
   //  date pretrasfomrationDate =  date.newinstance(2013, 11, 30);
     
     list<case> casesToTrigger = new list<Case>();
        
    for(case c:trigger.new)
        if(  !TransformationHelper.triggerOnCaseNSerRen 
                    &&  c.recordtypeId == APCaseRTID 
                    && (c.CaseArea__c == airlineJoining || c.CaseArea__c  == airlineLeaving || c.CaseArea__c  == airlineSuspension )
                 //   && (c.CaseArea__c == airlineJoining ||c.CaseArea__c  == airlineLeaving)
                 //   && (c.createddate == null ||  c.createddate > pretrasfomrationDate )
                    )
                casesToTrigger.add(c);
                
    if(!casesToTrigger.isEmpty() ){

                 map<string,id> AcccRtNamePerId = TransformationHelper.AccRtNamePerIds();
                 set<String> ServicesToCheck = new set<String>();
                 map<String,Case_Reason_Service__c> ServicesPerReason  = new map<String,Case_Reason_Service__c>();
                 list<Case> cases = new list<Case>();
                 list<Case> casesValidation = new list<Case>();
                 // this custom setting contains the infos regargind the need to reparent the provider to the hq to which the consumer belongs to.
                 for(Case_Reason_Service__c ReasonServiceMapping:Case_Reason_Service__c.getall().values()) {
                        ServicesPerReason.put(ReasonServiceMapping.name,ReasonServiceMapping);
                        ServicesToCheck.add(ReasonServiceMapping.name);
                 } 
                 
                 string STC = '';
                 for (string s:ServicesToCheck) {
                 	STC += s + ', ';
                 }
                 system.debug('STC: ' + STC);

                 
           /*   this logic is fired just when the case is inserted but not approved yet we just see if there's the need to reassign the provider by
                taking a look at the custom setting where we keep this information */   
            if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
                   //  throw new transformationException(' casesToTrigger? ' + casesToTrigger);             
                            ServiceRenderedCaseLogic.reparentProvider(casesToTrigger,AcccRtNamePerId,ServicesToCheck,ServicesPerReason);   
              }
                
                
                 
            /* this logic is fired just when the case gets approved and therefore we need to create the 
                    associated service rendered record and we need to cerate the airline branch out from the standard account if
                    needed */   
            if(trigger.isAfter && (trigger.isInsert ||trigger.isUpdate)){
                 
                 map<Id,Id> caseIdPerAccID = new map<Id,Id>();                      
                 map<Id,Case> caseMap = new map<Id,Case>();  
                 /*Initial Validation */
                        for (Case c : casesToTrigger) {
                                 if ( ServicesToCheck.contains(c.reason1__c) &&  c.Status == 'Closed' //c.Process_Approved__c <> null 
                                                    && (trigger.isInsert || trigger.oldmap.get(c.id).Status != 'Closed') // c.Process_Approved__c <> trigger.oldmap.get(c.id).Process_Approved__c)
                                                    ){
                                                            caseMap.put(c.id,c);
                                                            caseIdPerAccID.put(c.accountID,c.id);
                                                            
                                    }else if( !ServicesToCheck.contains(c.reason1__c)){
                                                    
                                              c.addError(' The reason you entered is not mapped to a service. \n Please contact the administrators.\n Administration Error:Custom Setting ' );                  
                                    }
                        }
                                           

                        

                    
                   if(caseMap.size()>0){
                                
                                /* validation and at the same time change of recordtype of the accts if they were standard */
                        map<Id,Case> casesWithErrorOnAcct = ServiceRenderedCaseLogic.changeRTtoBranchAccts(caseIdPerAccID, AcccRtNamePerId, caseMap);
                         
                             for (Id idc : caseMap.keySet()) {
                                    if(casesWithErrorOnAcct.get(idc) <> null){  
                                        casesWithErrorOnAcct.get(idc)
                                        .addError(' Errors during the validation of the Account related to the case: Wrong recordtype or not linked to a proper Headquarter ');
                                    }else{
                                        cases.add(caseMap.get(idc));
                                    }   
                                 }
                        /* putting this step just to ensure that the logic is working properly and the consumer is an airline */
                        
                        list<Case> casesConsValid = ServiceRenderedCaseLogic.airlineConsumerValidation(cases);
                    
                        /*  take a look at this just in case of mass upload of the cases 
                                    it checks if within the list of cases there's 2 times 
                                    the same case.
                                    start (it adds an error to the wrong ones)*/  
                        ServiceRenderedCaseLogic.massInsertDuplicateCheck(casesConsValid,ServicesPerReason);
            
                   
                        /* VALIDATION OF THE SERVICES RENDERED: WE LOOK IF WE HAVE DUPLICATES IN THE DATABASE NOT IN THE MASS ENTRY...*/  
                        list<Case> caseWithServicesOK =ServiceRenderedCaseLogic.ServicesValidation(casesConsValid,ServicesPerReason);
                        
                                      /* separating leaving case from Joining cases and then saving the services rendered*/              
                        if(!caseWithServicesOK.isEmpty()){
                                            ServiceRenderedCaseLogic.saveTheServices(caseWithServicesOK,ServicesPerReason);
                       }

                  } 
                       
               }
                
     }
    
 }