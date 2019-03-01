public class ServiceRenderedCaseLogic {
    
     public static final string airlineLeaving = 'Airline Leaving';
     public static final string airlineJoining = 'Airline Joining';
     public static final string airlineChange = 'Airline Change';
     public static final string airlineSuspension = 'Airline Suspension Process';
     public static final String separator = '%%%__%%%';
   
   
   
 /* it returns the list of cases with errors
     this method has the sideeffect of updating the accounts recordtypes */
  public static map<Id,Case> changeRTtoBranchAccts(map<Id,Id> caseIDPerAccId, map<Id,Case> caseMap){
   
            set<Id> AcctIDs = caseIDPerAccId.keySet();
            ID Standard = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
            Id Branch = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
            integer i=0;
            
            map<Integer,Account> AccPerIntAcc = new map<Integer,Account>();
            map<Integer, Case> CasePerInt = new map<Integer, Case>();
            
            
            for(Account a:[SELECT   Id,
                                    Airline_designator__c,
                                    Reason_for_creation__c,
                                    ParentID,                 
                                    IATA_ISO_Country__c,
                                    IATACode__c ,
                                    RecordtypeId
                            FROM Account
                            WHERE ID IN: AcctIDs]){
                            if(a.RecordtypeId == Standard){
                                AccPerIntAcc.put(i,a);
                                CasePerInt.put(i,caseMap.get(caseIDPerAccId.get(a.id)));
                                i++;
                             //   throw new transformationException('' + AccPerIntAcc);
                            }       
                    }
                    
            list<Account> acctToUpdateList = new list<Account>();
            set<Account> acctToUpdate = new set<Account>();
            map<integer, Account> AcctsToSavePerAccInt = new map<integer, Account>();           
            map<Id,Case> casesWithError = new map<Id,Case>();
            if(!AccPerIntAcc.isEmpty()){
                    Map<Integer,Account> AccPerIntAccToMethod = new Map<Integer,Account>();
                    for(Integer iter: AccPerIntAcc.keySet())
                        AccPerIntAccToMethod.put(iter, AccPerIntAcc.get(iter));
                       
                    AcctsToSavePerAccInt = AcctNoDupe.PerformSearch(AccPerIntAccToMethod,CasePerInt); 
            }
                                    
                                    
            for(integer k: AccPerIntAcc.keySet()){
                    if(AcctsToSavePerAccInt.get(k) == null){
                        //adderror to the  ones that did not pass the account validation
                            if(AccPerIntAcc.get(k)<> null && caseIDPerAccId.get(AccPerIntAcc.get(k).id) <> null){
                            casesWithError.put(
                                caseIDPerAccId.get(AccPerIntAcc.get(k).id),
                                caseMap.get(caseIDPerAccId.get(AccPerIntAcc.get(k).id)));
                                        
                                        }
                    }else{  
                        
                            AcctsToSavePerAccInt.get(k).RecordtypeId = Branch;
                            acctToUpdate.add(AcctsToSavePerAccInt.get(k));
                    }
            }
            
           if(!acctToUpdate.IsEmpty()){
                    acctToUpdateList.addAll(acctToUpdate);
                    update acctToUpdateList;            
           }
           
          return  casesWithError;
   }
   
    
   
   public static void saveTheServices(list<Case> caseWithServicesOK, map<String,Case_Reason_Service__c> ServicesPerReason){
        list<Case> joiningCases = new list<Case>();
        list<Case> leavingCases = new list<Case>();
        List<Case> changingCases = new List<Case>();
        list<Id> ConsumerIdsFromNewCases = new list<Id>();
        list<Services_Rendered__c> newSRList = new list<Services_Rendered__c>();
        Set<Id> passCaseIdList = new Set<Id>();

        for (Case c : caseWithServicesOK) {
            if (c.CaseArea__c == airlineJoining  ) {
                joiningCases.add(c);
            } else if (c.CaseArea__c  == airlineLeaving || c.CaseArea__c == airlineSuspension ) {
                ConsumerIdsFromNewCases.add(c.AccountId);
                leavingCases.add(c);
            } else if (c.CaseArea__c == airlineChange) {
                changingCases.add(c);
            }

            if(!joiningCases.isEmpty()) 
                newSRList.addAll(ServiceRenderedCaseLogic.joiningCase(joiningCases,ServicesPerReason));  

            if(!leavingCases.isEmpty()) 
                newSRList.addAll(ServiceRenderedCaseLogic.leavingCases(leavingCases, ConsumerIdsFromNewCases, ServicesPerReason));   

            //The platform event related to PASSLink should only be sent if the case is related to a PASS Country with a PASS Participation or PASS Aggregator parent case
            if(c.Reason1__c.startsWith('PASS')){
              if(c.Reason1__c==AMS_Utils.passCountryCaseReason){
                passCaseIdList.add(c.ParentId);
              }
              passCaseIdList.add(c.Id);
            }
        } 

        if (!changingCases.isEmpty()) {
            newSRList.addAll(servicesRenderendFromChangingCases(changingCases));
        }
                                               
        if (newSRList.size() > 0) {
            TransformationHelper.setComingFromCase();
            upsert(newSRList);
            
            //logic to publish the platform events
            if(passCaseIdList.size()>0){
              Map<Id,sObject> objectMapAPProcessForm=new Map<Id,sObject>();
              Map<Id,sObject> objectMapServiceRendered=new Map<Id,sObject>();

              for(AP_Process_Form__c formRecord: [SELECT Id,RecordTypeId FROM AP_Process_Form__c WHERE Case__c IN: passCaseIdList]){
                  objectMapAPProcessForm.put(formRecord.Id, formRecord);
              }
              if(objectMapAPProcessForm.size()>0){
                PlatformEvents_Helper.publishEvents(objectMapAPProcessForm, 'PASS__e', 'AP_Process_Form__c', true, false, false, false);
              }

              for(Services_Rendered__c serviceRecord:newSRList){
                if(passCaseIdList.contains(serviceRecord.Source_Case__c)){
                  objectMapServiceRendered.put(serviceRecord.Id, serviceRecord);
                }
              }
              if(objectMapServiceRendered.size()>0){
                PlatformEvents_Helper.publishEvents(objectMapServiceRendered, 'PASS__e', 'Services_Rendered__c', false, true, false, false);
              }
            }
        }
   }
   
   public static void massInsertDuplicateCheck(list<Case> Cases, map<String,Case_Reason_Service__c> ServicesPerReason){
   
                    map<String,list<Case>> KeyPerCase = new map<String,list<Case>>();
                                    
                    string key ;    
                    for(Case c: cases ){
                                        key  =    c.accountID  + separator + c.Provider__c + separator + ServicesPerReason.get(c.reason1__c) ;  
            
                                        if(keyPerCase.get(key)== null)
                                            keyPerCase.put(key ,new list<Case>());
                                        keyPerCase.get(key).add(C);
                            }
                            
                    for(String k : KeyPerCase.keyset())
                        if(KeyPerCase.get(key).size()>1)
                            for(Case c: KeyPerCase.get(key))
                                c.addError('The data you are trying to insert has duplicates in terms of Services Rendered');
   
   
   }
  
 
   
   public static void reparentProvider(list<Case>  casesToTrigger, set<String> ServicesToCheck, map<String,Case_Reason_Service__c> ServicesPerReason){
   
                         list<Case> casesWithoutProvider = new list<Case>();
                           for (Case c : casesToTrigger) {
                                  if ( ServicesToCheck.contains(c.reason1__c)
                                       && !ServicesPerReason.get(c.reason1__c).Provider_Required__c){
                                             casesWithoutProvider.add(c);     
                                             
                                      }else if( !ServicesToCheck.contains(c.reason1__c) 
                                               ){
                           
                                     c.addError('The reason you are entered is not mapped to a service. \n Please contact the administrators.\n Administration Error:Custom Setting' );                  
                              }
                     
                           }
                       if(!casesWithoutProvider.isEmpty())
                           ServiceRenderedCaseLogic.ReassignProvider(casesWithoutProvider);
   
   }
 
   public static list<Case> ServicesValidation(list<Case> casesOkConsumer, map<String,Case_Reason_Service__c> ServicesPerReason){
                list<Id> accountIds = new list<Id>();
                list<Case> caseWithServicesOK  = new list<Case>();
                
                map<String,Case> KeyPerCase = new map<String,Case>();
                    
                for(Case c: casesOkConsumer ){
                            accountIds.add(c.AccountId);
                            keyPerCase.put( c.accountID  + separator +
                                            c.Provider__c + separator 
                                             +
                                             ServicesPerReason.get( c.reason1__c).service__C
                                            , C );

                }
                
               
               set<String> servicesFromDb = new set<String>();   
               for(Services_Rendered__c serRen :[SELECT Id, Services_Rendered_to_Airline__c,Services_Rendered_Type__c ,
                                                            Services_Rendered_By__c

                                                FROM Services_Rendered__c 
                                                WHERE Services_Rendered_to_Airline__c In:accountIds
                                                AND  Services_Rendered_Status__c = 'Active'
                                                ]){

                                                servicesFromDb.add(serRen.Services_Rendered_to_Airline__c  + separator +
                                                                    serRen.Services_Rendered_By__c + separator 
                                                                    + serRen.Services_Rendered_Type__c);
                                                }
                        
                    
                    
                for(String key:keyPerCase.keyset()){
                    
                         if(servicesFromDb.contains(key) && keyPerCase.get(key).CaseArea__c == airlineJoining ){
                                 keyPerCase.get(key).addError('There is already a service active for the same Consumer');
                         }else if(!servicesFromDb.contains(key) && (keyPerCase.get(key).CaseArea__c == airlineLeaving || keyPerCase.get(key).CaseArea__c == airlineSuspension)){
                                keyPerCase.get(key).addError('There is no active service for the Consumer and the Provider');
                         }else{
                                 caseWithServicesOK.add(keyPerCase.get(key));
                         }
                
                }           
                            
            return caseWithServicesOK;
    
    }
    
 
        
     private static void ReassignProvider(List<Case> Cases){
          
           map<Id,list<Case>>  CasesPerConsumer = new map<Id,list<Case>>();
            
          for(Case c: cases){
                             if( CasesPerConsumer.get(c.AccountId) == null)
                                    CasesPerConsumer.put(c.AccountId,new list<Case>()); 
                              CasesPerConsumer.get(c.AccountId).add(c);
          } 
    
            set<Id> accIDs = CasesPerConsumer.keySet();          

                    
                    
            for(Account a :[SELECT ParentID,RecordTypeID,ID FROM Account WHERE Id IN:accIDs]){
            
                    if(a.RecordTypeID == RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline')){                          
                        for(Id accID:CasesPerConsumer.keyset()) 
                            for(case c:CasesPerConsumer.get(accID))
                                c.provider__c = a.id;
                           /* modified cause of the possibility that the consumer can be a standard account as well*/ 
                    }else  { 
                            for(Id accID:CasesPerConsumer.keyset()) 
                                for(case c:CasesPerConsumer.get(accID))
                                    c.provider__c = a.ParentID;
                    
                    }
    
            }

     
     }   
     

    private static List<Services_Rendered__c> joiningCase(List<Case> cases, Map<String,Case_Reason_Service__c> ServicesPerReason ){

        List<Services_Rendered__c> services = new List<Services_Rendered__c>();
        Set<String> caseIDs = new Set<String>();

        for (Case c :cases) {
          	caseIDs.add(c.Id);
        }

        List<AP_Process_Form__c> appforms = [SELECT Id, IATA_EasyPay_Opt_In_Opt_Out__c, ANG_Airline_accepts_EasyPay_tr_in_BSP__c, Case__c
                                        FROM AP_Process_Form__c
                                        WHERE Case__c IN :caseIDs];

        for (Case c: cases) {
        	Services_Rendered__c sr = new Services_Rendered__c(Name = 'name shall be copied',
                                                  Services_Rendered_to_Airline__c = c.AccountId,
                                                  Services_Rendered_By__c = c.Provider__c,
                                                  Services_Rendered_Type__c = ServicesPerReason.get(c.reason1__c).service__c,//c.Service__c,
                                                  Services_Rendered_Status__c ='Active',
                                                  Source_Case__c = c.Id,
                                                  Joining_Date__c = Date.ValueOf(c.ClosedDate));
        	
        	if (c.Origin == 'Portal') {
        		for (AP_Process_Form__c appform: appforms) {
        			if (appform.Case__c == c.Id && appform.ANG_Airline_accepts_EasyPay_tr_in_BSP__c == 'No') {
        				sr.ANG_IATA_EasyPay_Opt_out__c = true;
        				break;
        			}
        		}
        	}

        	services.add(sr);
        }
            
        return services;
        
    }
    
    private static list<Services_Rendered__c> leavingCases(list<Case> cases, 
                                                            list<Id> ConsumerIdsFromNewCases,
                                                             map<String,Case_Reason_Service__c> ServicesPerReason ){

        Map<string,map<Id,Services_Rendered__c>> activeServices = new Map<string,map<Id,Services_Rendered__c>>();                                               
        for (Services_Rendered__c sr : [SELECT Id, Services_Rendered_to_Airline__c, Services_Rendered_Type__c
                                        FROM Services_Rendered__c 
                                        WHERE Services_Rendered_to_Airline__c IN :ConsumerIdsFromNewCases 
                                        AND Services_Rendered_Status__c = 'Active' ]) {
            if(activeServices.get(sr.Services_Rendered_Type__c) == null)
                activeServices.put(sr.Services_Rendered_Type__c,new map<Id,Services_Rendered__c>()); 
                activeServices.get(sr.Services_Rendered_Type__c).put(sr.Services_Rendered_to_Airline__c,sr);
            }
            
            list<Services_Rendered__c> services = new list<Services_Rendered__c>();
            for (Case c :cases) {

                if(c.AccountId <> null && activeServices.get(ServicesPerReason.get(c.reason1__c).service__c) <> null &&
                        activeServices.get(ServicesPerReason.get(c.reason1__c).service__c).get(c.AccountId ) <> null  ){

                    services.add(new Services_Rendered__c(Name = 'name shall be copied', 
                                                          Services_Rendered_to_Airline__c = c.AccountId,
                                                          Services_Rendered_By__c = c.Provider__c,
                                                          Services_Rendered_Type__c = ServicesPerReason.get(c.reason1__c).service__c,//c.Service__c,
                                                          Services_Rendered_Status__c ='Inactive',
                                                          Inactivation_Airline_Participation_Case__c = c.Id,
                                                          Id = activeServices.get(ServicesPerReason.get(c.reason1__c).service__c).get(c.AccountId).Id, 
                                                          Leaving_Date__c = Date.ValueOf(c.ClosedDate)));
                  //   throw new transformationException( 'asdasd   ' + activeServices.get(ServicesPerReason.get(c.reason1__c).service__c).get(c.AccountId).Id);
                }
            }

            return services;
    }

    private static List<Services_Rendered__c> servicesRenderendFromChangingCases(List<Case> changingCases) {
        List<String> airlines = new List<String>();
        Map<String, List<String>> casesByParentMap = new Map<String, List<String>>();
        Map<String, String> airlinesByCaseMap = new Map<String, String>();

        for (Case c: changingCases) {
            if (c.Reason1__c == 'IATA Easy Pay') {
                airlines.add(c.Account_Concerned__c);
                airlinesByCaseMap.put(c.Id, c.Account_Concerned__c);
                if (c.ParentId != null) {
                    if (!casesByParentMap.keySet().contains(c.ParentId)) casesByParentMap.put(c.ParentId, new List<String>());
                    casesByParentMap.get(c.ParentId).add(c.Id);
                } else {
                    casesByParentMap.put(c.Id, new List<String>());
                    casesByParentMap.get(c.Id).add(c.Id);
                }
            }
        }

        List<AP_Process_Form__c> appForms = [SELECT Id, IATA_EasyPay_Opt_In_Opt_Out__c, Case__c
                                             FROM AP_Process_Form__c
                                             WHERE Case__c IN :casesByParentMap.keySet()];

        Map<String, AP_Process_Form__c> appFormsByCaseMap = new Map<String, AP_Process_Form__c>();

        for (AP_Process_Form__c a: appForms) appFormsByCaseMap.put(a.Case__c, a);

        List<Services_Rendered__c> services = [SELECT Id, ANG_IATA_EasyPay_Opt_out__c, Services_Rendered_to_Airline__c
                                               FROM Services_Rendered__c
                                               WHERE Services_Rendered_to_Airline__r.IATA_ISO_Country__r.Airline_EasyPay_Opt_Out_Date__c <= :Date.today()
                                                AND Services_Rendered_Type__c = 'BSP Participation'
                                                AND Services_Rendered_to_Airline__c IN :airlines];

        Map<String, Services_Rendered__c> servicesByCaseMap = new Map<String, Services_Rendered__c>();

        for (Services_Rendered__c s: services) {
            for (String caseId: airlinesByCaseMap.keySet()) {
            	if (airlinesByCaseMap.get(caseId) == s.Services_Rendered_to_Airline__c) servicesByCaseMap.put(caseId, s);
            }
        }

        List<Services_Rendered__c> changingServices = new List<Services_Rendered__c>();

        for (String parentCaseId: casesByParentMap.keySet()) {
        	for (String caseId: casesByParentMap.get(parentCaseId)) {        
            	if (appFormsByCaseMap.get(parentCaseId) != null && servicesByCaseMap != null && servicesByCaseMap.get(caseId) != null && appFormsByCaseMap.get(parentCaseId).IATA_EasyPay_Opt_In_Opt_Out__c == 'OUT' && !servicesByCaseMap.get(caseId).ANG_IATA_EasyPay_Opt_out__c) {
                	servicesByCaseMap.get(caseId).ANG_IATA_EasyPay_Opt_out__c = true;
                	changingServices.add(servicesByCaseMap.get(caseId));
            	} else if (appFormsByCaseMap.get(parentCaseId) != null && servicesByCaseMap != null && servicesByCaseMap.get(caseId) != null && appFormsByCaseMap.get(parentCaseId).IATA_EasyPay_Opt_In_Opt_Out__c == 'IN' && servicesByCaseMap.get(caseId).ANG_IATA_EasyPay_Opt_out__c) {
                	servicesByCaseMap.get(caseId).ANG_IATA_EasyPay_Opt_out__c = false;
                	changingServices.add(servicesByCaseMap.get(caseId));
            	}
            }
        }

        return changingServices;
    }

     public static list<Case> airlineConsumerValidation(list<Case> cases){
            list<case> casesOkConsumer = new list<Case>();
            map<Id,list<Case>>  CasesPerConsumer = new map<Id,list<Case>>();
            
          for(Case c: cases){
                             if( CasesPerConsumer.get(c.AccountId) == null)
                                CasesPerConsumer.put(c.AccountId,new list<Case>()); 
                              CasesPerConsumer.get(c.AccountId).add(c);
          }
             
            set<Id> accIDs = CasesPerConsumer.keySet();          
                    
            for(Account a :[SELECT RecordTypeID,ID FROM Account WHERE Id IN:accIDs]){
            
                    if(a.RecordTypeID == RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline')  
                            || a.RecordTypeID == RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR')){
                        
                        for(Id accID:CasesPerConsumer.keyset()) 
                            casesOkConsumer.addAll(CasesPerConsumer.get(accID));
                            
                    }else {
                        for(Id accID:CasesPerConsumer.keyset()) 
                            for(case c:CasesPerConsumer.get(accID) )
                            c.addError('The Consumer must be an Airline');
                    
                    }
    
            }
            return casesOkConsumer;
    }
    
    /*
     *  This method calculates the number of active participations split by CASS / BSP of an airline and stores it at HQ level
     */
    public static void CalculateAirlineParticipations (list<Services_Rendered__c> TriggerOld, list<Services_Rendered__c> TriggerNew, map<id, Services_Rendered__c> TriggerOldMap, Boolean TriggerIsDelete) {
    	// select the accounts where a SR change occured that requires an update of the total
        set<Id> setSRAccountIds = new set<Id>();
        
        for (Services_Rendered__c sr : (TriggerIsDelete ? TriggerOld : TriggerNew)) {
            if (Trigger.isDelete || 
                (Trigger.isInsert && sr.Services_Rendered_Status__c == 'Active') || 
                (Trigger.isUpdate && sr.Services_Rendered_Status__c != TriggerOldMap.get(sr.Id).Services_Rendered_Status__c)) {
                    setSRAccountIds.add(sr.Services_Rendered_to_Airline__c);
                }
        }
        
        if  (!setSRAccountIds.isEmpty()) {
            // for these accounts, search for the airline HQ (might be the account itself)
            map<Id, Account> mapHQAccountsPerId = new map<Id, Account>();
            list<Account> lstTriggerAccountsAndParents = [SELECT Id, ParentId, RecordType.DeveloperName, Airline_BSP_Participations__c, Airline_CASS_Participations__c, 
            													 Parent.Airline_BSP_Participations__c, Parent.Airline_CASS_Participations__c, Parent.Airline_PASS_Participations__c, Parent.RecordType.DeveloperName 
            											  FROM Account WHERE Id IN :setSRAccountIds];
            
            for (Account a : lstTriggerAccountsAndParents) {
            	if (a.RecordType.DeveloperName == 'IATA_Airline') {
            		mapHQAccountsPerId.put(a.Id, a);
            	} else if (a.Parent.RecordType.DeveloperName == 'IATA_Airline') {
            		mapHQAccountsPerId.put(a.ParentId, new Account(Id = a.ParentId, Airline_BSP_Participations__c = a.Parent.Airline_BSP_Participations__c, Airline_CASS_Participations__c = a.Parent.Airline_CASS_Participations__c, Airline_PASS_Participations__c = a.Parent.Airline_PASS_Participations__c));
            	}
            } 
            
            //map<Id, Account> mapHQAccountsPerId = new map<Id, Account>([SELECT Id, Airline_BSP_Participations__c, Airline_CASS_Participations__c FROM Account WHERE RecordType.DeveloperName = 'IATA_Airline' AND (Id IN :setSRAccountIds OR ParentId IN :setSRAccountIds)]);
            
            // get all the active participations for these airline HQs and their branches
            list<Services_Rendered__c> lstParticipations = [SELECT Id, Services_Rendered_Type__c, Services_Rendered_to_Airline__r.RecordType.DeveloperName, Services_Rendered_to_Airline__r.ParentId 
                                                            FROM Services_Rendered__c 
                                                            WHERE Services_Rendered_Status__c = 'Active' AND
                                                            (Services_Rendered_to_Airline__c IN :mapHQAccountsPerId .keyset() OR
                                                            Services_Rendered_to_Airline__r.ParentId IN :mapHQAccountsPerId .keyset())];
            
            // create 2 maps of participations count per airline HQ account Id, in which we count the participations
            /*
            map<Id, Integer> mapCASSParticipationsPerAccountHQId = new map<Id, Integer>();
            map<Id, Integer> mapBSPParticipationsPerAccountHQId = new map<Id, Integer>();
            for (Id i : mapHQAccountsPerId.keyset()) {
                mapCASSParticipationsPerAccountHQId.put(a.Id, 0);
                mapBSPParticipationsPerAccountHQId.put(a.Id, 0);
            }
            */
            // reset the participation totals
            for (Account a : mapHQAccountsPerId.values()) {
                a.Airline_BSP_Participations__c = 0;
                a.Airline_CASS_Participations__c = 0;
                a.Airline_PASS_Participations__c = 0;
            }
            
            set<String> setCASSParticipationNames = new set<String>{'CASS Participation', 'CASS Representation', 'CASS via GSSA', 'CASS Export Direct Participation', 'CASS Import Direct Participation', 'CASS Export via GSSA', 'CASS Import via GHA'};
            set<String> setBSPParticipationNames = new set<String>{'BSP Participation', 'BSP via IBCS'};
            set<String> setPASSParticipationNames = new set<String>{'PASS Participation', 'PASS Country','PASS Country Aggregator'};
            
            // count the participations by type
            for (Services_Rendered__c sr : lstParticipations) {
                // identify the id of the HQ account for the current account: its Id or the one of the parent
                Id HQAccountId = sr.Services_Rendered_to_Airline__r.RecordType.DeveloperName == 'IATA_Airline' ? sr.Services_Rendered_to_Airline__c : sr.Services_Rendered_to_Airline__r.ParentId;
                
                if (setCASSParticipationNames.contains(sr.Services_Rendered_Type__c)) {
                    //mapCASSParticipationsPerAccountHQId.get(HQAccountId) += 1;
                    mapHQAccountsPerId.get(HQAccountId).Airline_CASS_Participations__c += 1;
                }
                
                if (setBSPParticipationNames.contains(sr.Services_Rendered_Type__c)) {
                    //mapBSPParticipationsPerAccountHQId.get(HQAccountId) += 1;
                    mapHQAccountsPerId.get(HQAccountId).Airline_BSP_Participations__c  += 1;
                }

                if (setPASSParticipationNames.contains(sr.Services_Rendered_Type__c)) {
                    mapHQAccountsPerId.get(HQAccountId).Airline_PASS_Participations__c  += 1;
                }
            }
            
            // update the HQ accounts with the totals
            update mapHQAccountsPerId.values();
        }
    }

}