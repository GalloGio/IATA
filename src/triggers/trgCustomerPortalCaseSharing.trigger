trigger trgCustomerPortalCaseSharing on Case (after insert, before insert, before update) {        
    /* Production */ 
    /* Created Date - 14-June-2010 */
    /* 
       This trigger is used to call the CaseSharing Class 
       to share the case records to Customer portal users 
       and update the Case Owner field displayed in the Customer Portal
    */
    
    Set<Id> AcctIds = new Set<Id>();
    Set<Id> UserIds = new Set<Id>();
    List<User> lstUsers = new List<User>();
    List<QueueSobject> lstQueue = new List<QueueSobject>();
    String caseRecType;
    Integer futureLimit = Limits.getFutureCalls();
    System.Debug('futureLimit : ----- '+ futureLimit);
    BusinessHours bHourObj = new BusinessHours();
    // Get 'External Cases (InvoiceWorks)' record type ID from the singleton instead of getting it from the database 
    ID caseRecordTypeID  = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('External Cases (InvoiceWorks)');
    //RecordType rType = [Select id, name from RecordType where name =: 'External Cases (InvoiceWorks)'];
    try{  
        
        if(!Trigger.isAfter){
            for(Case ObjCaseNew : Trigger.New){ 
            	caseRecType = ObjCaseNew.RecordTypeId;            
                UserIds.add(ObjCaseNew.OwnerId);                                        
            }    
            if(caseRecType == caseRecordTypeID){ 
	            lstUsers = [Select Id, Name FROM User WHERE Id IN : UserIds and IsActive =: True];
	            bHourObj = [Select id, name from BusinessHours where name =: 'EUR - France'];
                for(Case ObjCaseNew : Trigger.New){                	
                    ObjCaseNew.BusinessHoursId = bHourObj.Id;
             
                } 
	            if(lstUsers.Size()>0){
	                for(Case ObjCaseNew : Trigger.New){
	                    for(Integer i=0;i<lstUsers.Size();i++){
	                        if(ObjCaseNew.OwnerId == lstUsers[i].Id){
	                            ObjCaseNew.Case_Owner_CP__c = lstUsers[i].Name;   
	                            System.debug('Owner name: ' + ObjCaseNew.Case_Owner_CP__c);                  
	                            break;
	                        }
	                    }           
	                }   
	            }
	            else{        
	                lstQueue = [SELECT Id, Queue.Id, Queue.Name, Queue.Type FROM QueueSobject WHERE Queue.Id IN : UserIds];         
	                if(lstQueue.Size()>0){
	                    for(Case ObjCaseNew : Trigger.New){
	                        for(Integer i=0;i<lstQueue.Size();i++){
	                            if(ObjCaseNew.OwnerId == lstQueue[i].QueueId){                                                          
	                                ObjCaseNew.Case_Owner_CP__c = lstQueue[i].Queue.Name;                       
	                                break;
	                            }
	                        }           
	                    }
	                }
	            } 
            }  
        } 
        /*      
        If((Trigger.isInsert && Trigger.isAfter) || (Trigger.isBefore && Trigger.isUpdate)){
            if(futureLimit < 10){
                if (!FutureProcessorControl.inFutureContext) {
                    for(Case ObjCase : Trigger.new){    
                        if(ObjCase.Power_User_Account__c != null){
                            AcctIds.add(ObjCase.Power_User_Account__c);
                        }                                   
                    }
                    if(!AcctIds.isEmpty()){
                        CaseSharingClass.CaseShareMethod(AcctIds);
                    }               
                }
            }
                       
        }    */   
    }
    catch(Exception e){
        System.debug('Error Message -----: ' + e.getMessage());
    } 
}