public class AMS_AgencyAChangeCodeHandler {
    public static boolean firstRun{
        get{
            if(firstRun == null) firstRun = true;
            return firstRun;
        }
        set;
    }
     
    public static void handleAfterInsert(List<Agency_Applied_Change_code__c> aacc) {
        if(!ANG_OscarProcessHelper.isIATACodeGenerationRunning)
            verifyActiveAACCuniqueness(aacc);
        set<id> setIdAACC = new set<id>();
        
        Id irregRtId = AMS_Utils.getId('Agency_Applied_Change_code__c', 'Irregularities');
        List<Agency_Applied_Change_code__c> aaccToBeProcessed = new List<Agency_Applied_Change_code__c>();
         //INC415109 - Account Reason cannot be empty when agency status becomes New application pending
        set<id> setIdAACCForNewApplicationPending = new set<id>();

        /*** AMSU-198 ***/
        List<Agency_Applied_Change_code__c> accToProcessPayment = new List<Agency_Applied_Change_code__c>();
        Set<String> accPaymentDefault = new Set<String> {'DFE','DEF'};

        for(Agency_Applied_Change_Code__c aaccRecord : aacc) {
        	setIdAACC.add(aaccRecord.id);
            if(aaccRecord.RecordTypeId == irregRtId)
            {
                aaccToBeProcessed.add(aaccRecord);
            }
            //INC415109 - Account Reason cannot be empty when agency status becomes New application pending
            if(aaccRecord.Change_Code__c == 'NEW' && aaccRecord.AccountNewStatus__c == 'New application pending' && aaccRecord.Reason_Code__c == '21')
                setIdAACCForNewApplicationPending.add(aaccRecord.id);

            /*** AMSU-198 ***/
            if(accPaymentDefault.contains(aaccRecord.Change_Code__c)) {
                accToProcessPayment.add(aaccRecord);
            }
        }
        AMS_Irregularities_Utils.CalculateAccumulatedIrregularitiesFromChangeCode(aaccToBeProcessed);
		system.debug('SALVES handleAfterInsert -->  processMinorChangesValidationFlag: ' + AMS_AccountTriggerHandler.processMinorChangesValidationFlag);
        system.debug('SALVES handleAfterInsert -->  minorChangesComingFromOSCAR: ' + AMS_AccountTriggerHandler.minorChangesComingFromOSCAR);
        if(AMS_AccountTriggerHandler.processMinorChangesValidationFlag || AMS_AccountTriggerHandler.minorChangesComingFromOSCAR){
		   updateAccountReason(setIdAACC, false);
        }else{
             if(!setIdAACCForNewApplicationPending.isEmpty()) 
                updateAccountReason(setIdAACCForNewApplicationPending, true);
        }
		
        //FM 22-09-2016 - Create "Agency Update" records
        if(!ANG_OscarProcessHelper.isIATACodeGenerationRunning)
            AMS_AgencyUpdateHelper.agencyUpdate( (List<SObject>) aacc);

        /*** AMSU-198 ***/
        if(!accToProcessPayment.isEmpty()) {
            notifyAirlines(accToProcessPayment);
        }

    }
    
    /*** AMSU-198 ***/
    public static void notifyAirlines(List<Agency_Applied_Change_code__c> aaccs) {
        Database.executeBatch(new AMS_MajorDefaultCommunication(aaccs), 50);
    }
    
    public static void handleBeforeUpdate(List<Agency_Applied_Change_code__c> aacc){
    	UpdateReasonCode(aacc, true);
    }

    public static void handleAfterUpdate(List<Agency_Applied_Change_code__c> aacc, map<Id, Agency_Applied_Change_code__c> triggerOldMap) {
        verifyActiveAACCuniqueness(aacc);
        set<id> setIdAACC = new set<id>();
        //INC415109 - Account Reason cannot be empty when agency status becomes New application pending
        set<id> setIdAACCForNewApplicationPending = new set<id>();
        Id irregRtId = AMS_Utils.getId('Agency_Applied_Change_code__c', 'Irregularities');
        List<Agency_Applied_Change_code__c> aaccToBeProcessed = new List<Agency_Applied_Change_code__c>();
        for(Agency_Applied_Change_Code__c aaccRecord : aacc)
        {
        	system.debug('DTULLO 42 --> NewValue: ' + aaccRecord.Sent_to_external_system__c +  ' - OldaValue: ' + triggerOldMap.get(aaccRecord.Id).Sent_to_external_system__c);
        	if(aaccRecord.Sent_to_external_system__c == triggerOldMap.get(aaccRecord.Id).Sent_to_external_system__c){
        		setIdAACC.add(aaccRecord.id);
        	}
            
            if(aaccRecord.RecordTypeId == irregRtId)
            {
                aaccToBeProcessed.add(aaccRecord);
            }

            if(aaccRecord.Change_Code__c == 'NEW' && aaccRecord.AccountNewStatus__c == 'New application pending' && aaccRecord.Reason_Code__c == '21')
                setIdAACCForNewApplicationPending.add(aaccRecord.id);
        }
        AMS_Irregularities_Utils.CalculateAccumulatedIrregularitiesFromChangeCode(aaccToBeProcessed);
        
        system.debug('SALVES handleAfterUpdate -->  processMinorChangesValidationFlag: ' + AMS_AccountTriggerHandler.processMinorChangesValidationFlag);
        system.debug('SALVES handleAfterUpdate -->  minorChangesComingFromOSCAR: ' + AMS_AccountTriggerHandler.minorChangesComingFromOSCAR);
        if(!setIdAACC.isEmpty() && (AMS_AccountTriggerHandler.processMinorChangesValidationFlag || AMS_AccountTriggerHandler.minorChangesComingFromOSCAR)){
	        if(!setIdAACCForNewApplicationPending.isEmpty()) 
                setIdAACC.addAll(setIdAACCForNewApplicationPending);

            updateAccountReason(setIdAACC, true);
        } else {
             if(!setIdAACCForNewApplicationPending.isEmpty()) 
                updateAccountReason(setIdAACCForNewApplicationPending, true);
        }
    }

    public static void handleBeforeInsert(List<Agency_Applied_Change_code__c> aacc){
    	UpdateReasonCode(aacc, false);
        if(!ANG_OscarProcessHelper.isIATACodeGenerationRunning)
            migrateFieldsFromStagingToAccount(aacc);
    }
    
    //DTULLO: marked as future because some change codes are generated from account changes (minor changes)
    //thus, we try to re-update the same account again
    //public static void updateAccountReason(list<Agency_Applied_Change_code__c> lsAACC){
	//@future
    //SUSANA ALVES: removed @future because we don't need to update account for minor changes 
    public static void updateAccountReason(set<id> setAACC, boolean bIsUpdate){
        system.debug('SALVES --> updateAccountReason - setAACC : ' + setAACC);
    	list<Agency_Applied_Change_code__c> lsAACC = [select id, Change_Code__c, Reason_Code__c, Reason_Description__c, Active__c, Account__c, AccountNewStatus__c, Account__r.Reason__c, Account__r.Previous_Reason__c, Account__r.Status__c, Account__r.PreviousStatus__c  from Agency_Applied_Change_code__c where id in:setAACC];
    	set<id> setAccntId = new set<id>();
    	map<id, account> mapAccntToUpdate = new map<id, account>();
    	
    	//for(Agency_Applied_Change_code__c aacc:lsAACC){
    	//	setAccntId.add(aacc.Account__c);
    	//}
    	
        //[select id, reason__c, Previous_Reason__c, Status__c, PreviousStatus__c from account where id in:setAccntId]
    	
    	for(Agency_Applied_Change_code__c aacc:lsAACC){
            /*** AMSU-176 ***/
            //Only active changes codes can update account status and reason
            if(!aacc.Active__c) {
                continue;
            }

    		string sReason = (aacc.Reason_Code__c==null?'':aacc.Reason_Code__c)+ '-' + (aacc.Reason_Description__c==null?'':aacc.Reason_Description__c);
    		string sStatus = (aacc.AccountNewStatus__c==null?'':aacc.AccountNewStatus__c);
    		boolean bUpdateAccnt = false;
    		Account acc = new Account(id = aacc.Account__c);
    		if(!bIsUpdate) acc.Organization_Last_Change_Date__c = Date.Today();
    		if(sReason != '-'){
    			if(aacc.Account__c != null){
	    			string sAccntReason = aacc.Account__r.reason__c;
	    			if(sReason != sAccntReason){
	    				acc.reason__c = sReason;
	    				acc.Previous_Reason__c = sAccntReason;
	    				bUpdateAccnt = true;
	    			}
    			}
    		}
    		
    		//Update Account Status, but only if it's blank and different from the previous one
    		if(sStatus != ''){
    			if(aacc.Account__c != null){
	    			string sAccntStatus = aacc.Account__r.status__c;
	    			if(sAccntStatus != aacc.AccountNewStatus__c) {
                        acc.Date_Organisation_Status_attained__c = Date.Today();
	    				acc.status__c = sStatus;
	    				acc.PreviousStatus__c = acc.Status__c;
	    				bUpdateAccnt = true;
	    			}
    			}
    		}
    		
    		if(bUpdateAccnt)
    			mapAccntToUpdate.put(aacc.Account__c, acc);
    	}
    	
    	if(!mapAccntToUpdate.isEmpty()){
            System.debug('[AMS_AgencyAChangeCodeHandler] Preparing to update ' + mapAccntToUpdate.size() + ' accounts.');
    		update mapAccntToUpdate.values();
        }
    }
    
    //DTULLO: NEED to bulkify it. Now change codes are bring via dataloader from aims. batch size = 50.
    //because of a requirement, they are coming as active. so, if more than 1 is coming, we should check inside the trigger to set them to false
    //Use of field "Created_Date_To_Show__c" to set only the last one as active.
    public static void verifyActiveAACCuniqueness(List<Agency_Applied_Change_code__c> aaccodes){
        map<id, list<Agency_Applied_Change_code__c>> mapLastAACC = new map<id, list<Agency_Applied_Change_code__c>>();
        
        List<Agency_Applied_Change_code__c> aACCtoUpdate = new List<Agency_Applied_Change_code__c>();

        Set<Id> agencyIds = new Set<Id>();

        for(Agency_Applied_Change_code__c aacc : aaccodes){
            //DTULLO: get ALL agencies involved
            //if(aacc.Active__c){
                agencyIds.add(aacc.Account__c);
            //}
        }

        if(agencyIds.size() > 0){
            List<Agency_Applied_Change_code__c> allCCPerAgency = [select id, Created_Date_To_Show__c, Active__c , Account__c 
                                                                  from Agency_Applied_Change_code__c
                                                                  where Account__c IN :agencyIds
                                                                  order by Account__c, Created_Date_To_Show__c desc];
            for(Agency_Applied_Change_code__c aac: allCCPerAgency){
                if(mapLastAACC.containsKey(aac.Account__c)){
                    list<Agency_Applied_Change_code__c> ls = mapLastAACC.get(aac.Account__c);
                    if(aac.active__c == true){
                        aac.Active__c = false;
                        ls.add(aac);
                        mapLastAACC.put(aac.Account__c, ls);
                    }
                }else{
                    system.debug('DTULLO: setting the last as active');
                    aac.Active__c = true;
                    mapLastAACC.put(aac.Account__c, new list<Agency_Applied_Change_code__c>{aac});
                }
            }
            
            //do the update
            if(!mapLastAACC.isEmpty()){
                system.debug('DTULLO map is not empty');
                for(id acc:mapLastAACC.keyset())
                    aACCtoUpdate.addAll(mapLastAACC.get(acc));
                
                
                if(!aACCtoUpdate.isEmpty()){
                    system.debug('DTULLO acctoUpdate not empty');
                    for(Agency_Applied_Change_code__c c:aACCtoUpdate){
                        system.debug('DTULLO --> ' + c);
                    }
                    update aACCtoUpdate;
                }
            }
            /*
            DTULLO: FULLY COMMENTED. Need to set only the latest one as active
            List<Agency_Applied_Change_code__c> elementsToUpdate = new List<Agency_Applied_Change_code__c>();
            
            for(Agency_Applied_Change_code__c aacc : [select id, Active__c , Account__c from Agency_Applied_Change_code__c where Active__c = true AND Account__c IN :agencyIds]){
        
                if(Trigger.newMap.containsKey(aacc.id) == false) {
                    
                    aacc.Active__c = false;
                    elementsToUpdate.add(aacc);
                }   
            }
        
            if(elementsToUpdate.size() > 0){
                
                update elementsToUpdate;
            }*/
        }

    }

	public static void UpdateReasonCode(List<Agency_Applied_Change_code__c> aacc, boolean bIsUpdate){
		map<string, map<string,string>> mapStatusReason = new map<string, map<string, string>>();
		
		for(AMS_Status_Reason__c lsr:[select Status_Description__c, Reason_Code__c, Reason_Description__c from AMS_Status_Reason__c]){
			map<string, string> mapReason;
			if(mapStatusReason.containsKey(lsr.Status_Description__c))
				mapReason = mapStatusReason.get(lsr.Status_Description__c);
			else
				mapReason = new map<string, string>();
			
			mapReason.put(lsr.Reason_Description__c, lsr.Reason_Code__c);
			mapStatusReason.put(lsr.Status_Description__c, mapReason);
		}
		if(!mapStatusReason.isEmpty()){
			for(Agency_Applied_Change_code__c ac:aacc){
				if(ac.Reason_Code__c==null || ac.Reason_Code__c == '' || bIsUpdate){
					string sStatus = ac.AccountNewStatus__c;
					string sReasDesc = ac.Reason_Description__c;
					string sReasonCode = 'xx';
					if(sStatus!=null && sStatus!='' && sReasDesc != '' && sReasDesc!=null){
						if(mapStatusReason.containsKey(sStatus)) {
							if(mapStatusReason.get(sStatus).containsKey(sReasDesc))
								ac.Reason_Code__c = mapStatusReason.get(sStatus).get(sReasDesc);
						}
					}
				}
			}
		}
	}
	
	
    public static void migrateFieldsFromStagingToAccount(List<Agency_Applied_Change_code__c> aacc){

        // this method aaplies only to change codes that have an OSCAR filled. That OSCAR must be of record type NEW and have process of type AMS_Utils.oscarAMSProcesses
        // when creating a change code of type FIN or DIS, it should copy the information from staging Area (AMS_Pax_Accreditation_Form__c) into Master Data (Account)

        Id rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        Id newNGRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NG New HE').getRecordTypeId();

        Set<Id> oscarRecordTypes = new Set<Id>{rtNew,newNGRT};

        Set<Id> oscarIds = new Set<Id>();

        for(Agency_Applied_Change_code__c code: aacc){
            if(code.OSCAR__c != null && ( code.change_code__c == 'FIN' || code.change_code__c == 'DIS')){
                oscarIds.add(code.OSCAR__c);
            }
        }

        //let's first find the OSCAR that need to be migrated
        List<AMS_OSCAR__c> oscarsToCopyData = new List<AMS_OSCAR__c>();
        List<AMS_OSCAR__c> oscarsToUpdateAppointments = new List<AMS_OSCAR__c>();

        //aacclist = [SELECT ID, OSCAR__c, OSCAR__r.Account__c , OSCAR__r.AMS_Online_Accreditation__c from Agency_Applied_Change_code__c where id in :aaccIds and OSCAR__r.RecordTypeId = :rtNew and OSCAR__r.Process__c in ('NEW.HO.1.0','NEW.BR','NEW.BR.ABROAD') ];

        oscarsToCopyData = [SELECT ID, Account__c, AMS_Online_Accreditation__c, RecordTypeId,Process__c, Is_PCI_compliant__c from AMS_OSCAR__C where Id in :oscarIds and RecordTypeId in :oscarRecordTypes and Process__c in :AMS_Utils.oscarAMSProcesses];

        if(!oscarsToCopyData.isEmpty()){
            AMS_Utils.copyDataToAccount(oscarsToCopyData);
        
            //moved to oscar trigger, appointment status changes needs to occur in situations without change code generation
            /*for(AMS_OSCAR__C oscar : oscarsToCopyData)
            {
                 if( AMS_Utils.oscarProcessesWithAppointments.contains(oscar.Process__c))
                     oscarsToUpdateAppointments.add(oscar);

            }       

            if(!oscarsToUpdateAppointments.isEmpty())
                AMS_Utils.UpdateInspectionsFromOscar(oscarsToUpdateAppointments);*/

        }else{
            System.debug('Nothing to migrate here.');
        }
    }

}