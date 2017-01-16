public class AMS_AgencyAChangeCodeHandler {
    public static boolean firstRun{
        get{
            if(firstRun == null) firstRun = true;
            return firstRun;
        }
        set;
    }
     
    public static void handleAfterInsert(List<Agency_Applied_Change_code__c> aacc) {
        verifyActiveAACCuniqueness(aacc);
        set<id> setIdAACC = new set<id>();
        Id irregRtId = AMS_Utils.getId('Agency_Applied_Change_code__c', 'Irregularities');
        List<Agency_Applied_Change_code__c> aaccToBeProcessed = new List<Agency_Applied_Change_code__c>();
        for(Agency_Applied_Change_Code__c aaccRecord : aacc)
        {
        	setIdAACC.add(aaccRecord.id);
            if(aaccRecord.RecordTypeId == irregRtId)
            {
                aaccToBeProcessed.add(aaccRecord);
            }
        }
        AMS_Irregularities_Utils.CalculateAccumulatedIrregularitiesFromChangeCode(aaccToBeProcessed);
		
		updateAccountReason(setIdAACC);
		
        //FM 22-09-2016 - Create "Agency Update" records
        AMS_AgencyUpdateHelper.agencyUpdate( (List<SObject>) aacc);
    }

    public static void handleAfterUpdate(List<Agency_Applied_Change_code__c> aacc) {
        verifyActiveAACCuniqueness(aacc);
        Id irregRtId = AMS_Utils.getId('Agency_Applied_Change_code__c', 'Irregularities');
        List<Agency_Applied_Change_code__c> aaccToBeProcessed = new List<Agency_Applied_Change_code__c>();
        for(Agency_Applied_Change_Code__c aaccRecord : aacc)
        {
            if(aaccRecord.RecordTypeId == irregRtId)
            {
                aaccToBeProcessed.add(aaccRecord);
            }
        }
        AMS_Irregularities_Utils.CalculateAccumulatedIrregularitiesFromChangeCode(aaccToBeProcessed);
    }

    public static void handleBeforeInsert(List<Agency_Applied_Change_code__c> aacc){
        migrateFieldsFromStagingToAccount(aacc);
    }
    
    //DTULLO: marked as future because some change codes are generated from account changes (minor changes)
    //thus, we try to re-update the same account again
    //public static void updateAccountReason(list<Agency_Applied_Change_code__c> lsAACC){
	@future
    public static void updateAccountReason(set<id> setAACC){
    	list<Agency_Applied_Change_code__c> lsAACC = [select id, Reason_Code__c, Reason_Description__c, Account__c  from Agency_Applied_Change_code__c where id in:setAACC];
    	set<id> setAccntId = new set<id>();
    	map<id, string> mapNewReason = new map<id, string>();
    	map<id, account> mapAccntToUpdate = new map<id, account>();
    	
    	for(Agency_Applied_Change_code__c aacc:lsAACC){
    		if(aacc.Reason_Code__c != null && aacc.Reason_Code__c != ''){
    			setAccntId.add(aacc.Account__c);
    			mapNewReason.put(aacc.Account__c, aacc.Reason_Code__c + '-' + aacc.Reason_Description__c);
    		}
    	}
    	map<id, account> mapAccnt = new Map<ID, Account>([select id, reason__c, Previous_Reason__c from account where id in:setAccntId]);
    	
    	for(Agency_Applied_Change_code__c aacc:lsAACC){
    		string sReason = aacc.Reason_Code__c+ '-' + aacc.Reason_Description__c;
    		if(sReason != '-'){
    			if(mapAccnt.containsKey(aacc.Account__c)){
	    			string sAccntReason = mapAccnt.get(aacc.Account__c).reason__c;
	    			if(sReason != sAccntReason){
	    				mapAccntToUpdate.put(aacc.Account__c,new Account(id = aacc.Account__c
	    									,reason__c = sReason
	    									,Previous_Reason__c = sAccntReason));
	    			}
    			}
    		}
    	}
    	
    	if(!mapAccntToUpdate.isEmpty())
    		update mapAccntToUpdate.values();
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


    public static void migrateFieldsFromStagingToAccount(List<Agency_Applied_Change_code__c> aacc){

        // this method aaplies only to change codes that have an OSCAR filled. That OSCAR must be of record type NEW and have process of type AMS_Utils.oscarAMSProcesses
        // when creating a change code of type FIN or DIS, it should copy the information from staging Area (AMS_Pax_Accreditation_Form__c) into Master Data (Account)

        Id rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();

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

        oscarsToCopyData = [SELECT ID, Account__c, AMS_Online_Accreditation__c, RecordTypeId,Process__c from AMS_OSCAR__C where Id in :oscarIds and RecordTypeId = :rtNew and Process__c in :AMS_Utils.oscarAMSProcesses];

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