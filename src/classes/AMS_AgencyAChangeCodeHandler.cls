public class AMS_AgencyAChangeCodeHandler {
    public static Boolean firstRun{
        get{
            if(firstRun == null) firstRun = true;
            return firstRun;
        }
        set;
    }

    private static Map<Id, Account> mapAccntToUpdate = new Map<Id, Account>();
    private static Id irregRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Irregularities');
    private static Id stdRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Standard');

    public static void handleAfterInsert(List<Agency_Applied_Change_code__c> aacc) {
        if(!ANG_OscarProcessHelper.isIATACodeGenerationRunning)
            verifyActiveAACCuniqueness(aacc);
        Set<Id> setIdAACC = new Set<Id>();
        List<Agency_Applied_Change_code__c> aaccToBeProcessed = new List<Agency_Applied_Change_code__c>();

        /*** AMSU-198 ***/
        List<Agency_Applied_Change_code__c> accToProcessPayment = new List<Agency_Applied_Change_code__c>();
        Set<String> accPaymentDefault = new Set<String> {'DFE','DEF'};

        for(Agency_Applied_Change_Code__c aaccRecord : aacc) {
        	setIdAACC.add(aaccRecord.id);
            if(aaccRecord.RecordTypeId == irregRtId)
            {
                aaccToBeProcessed.add(aaccRecord);
            }

            /*** AMSU-198 ***/
            if(accPaymentDefault.contains(aaccRecord.Change_Code__c)) {
                accToProcessPayment.add(aaccRecord);
            }
        }

        if(!AMS_OscarCase_RiskMgmt.mapAccntToUpdate.isEmpty())
            mapAccntToUpdate = AMS_OscarCase_RiskMgmt.mapAccntToUpdate;

        aaccToBeProcessed.addAll(AMS_OscarCase_RiskMgmt.irrsToExp.values());

        AMS_Irregularities_Utils.CalculateAccumulatedIrregularitiesFromChangeCode(aaccToBeProcessed, mapAccntToUpdate, AMS_OscarCase_RiskMgmt.irrsToExp);

		if(AMS_AccountTriggerHandler.processMinorChangesValidationFlag || AMS_AccountTriggerHandler.minorChangesComingFromOSCAR){
		   updateAccountReason(setIdAACC, false);
        }

        if(!mapAccntToUpdate.isEmpty()){
            update mapAccntToUpdate.values();
            mapAccntToUpdate = new Map<Id, Account>();
        }
		
        if(!ANG_OscarProcessHelper.isIATACodeGenerationRunning)
            AMS_AgencyUpdateHelper.agencyUpdate( (List<SObject>) aacc);

        /*** AMSU-198 ***/
        if(!accToProcessPayment.isEmpty()) {
            notifyAirlines(accToProcessPayment);
        }

        processRelatedCases(aacc);  //WMO-482 - ACAMBAS
    }

    //WMO-482 - ACAMBAS: Begin
    public static void processRelatedCases(List<Agency_Applied_Change_code__c> aaccLst) {
        List<Id> aaccLstCase = new List<Id>();

        for(Agency_Applied_Change_code__c aacc: aaccLst) {
            if(aacc.Change_Code__c == 'RVW' && aacc.SIDRA_Case__c != null) {
                aaccLstCase.add(aacc.SIDRA_Case__c);
            }
        }

        if(aaccLstCase.isEmpty()) return;

        List<Case> casesToUpdate = new List<Case>();

        for(Case caseToProcess : [SELECT Id, Parent.BusinessHoursId, ParentId, Parent.New_IFAP_Deadline_date__c
                                  FROM Case 
                                  WHERE Id IN :aaccLstCase AND RecordType.DeveloperName = 'Sidra_Lite' AND ParentId != null AND Account.CNS_Agency__c = true]) {

            Case parentCase = new Case(Id = caseToProcess.parentId);                         
            Date newDateToUpdate = BusinessDays.addNBusinessDays(DateTime.now(), 7, caseToProcess.Parent.BusinessHoursId).date();

            if(caseToProcess.parent.New_IFAP_Deadline_date__c <> newDateToUpdate){
                parentCase.New_IFAP_Deadline_date__c = newDateToUpdate;
                casesToUpdate.add(parentCase);
            }
        }

        if(!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
    //WMO-482 - ACAMBAS: End
    
    /*** AMSU-198 ***/
    public static void notifyAirlines(List<Agency_Applied_Change_code__c> aaccs) {
        Database.executeBatch(new AMS_MajorDefaultCommunication(aaccs), 50);
    }
    
    public static void handleBeforeUpdate(List<Agency_Applied_Change_code__c> aacc){
    	UpdateReasonCode(aacc, true);

        for(Agency_Applied_Change_code__c aaccRecord : aacc){
            if(aaccRecord.AIMS_ID__c != null && aaccRecord.AIMS_ID__c.right(1) != 'A' && aaccRecord.Operation__c == 'A')
                aaccRecord.AIMS_ID__c = aaccRecord.AIMS_ID__c + '_A';
        }
    }

    public static void handleAfterUpdate(List<Agency_Applied_Change_code__c> aacc, Map<Id, Agency_Applied_Change_code__c> triggerOldMap) {
        verifyActiveAACCuniqueness(aacc);
        Set<Id> setIdAACC = new Set<Id>();
        //INC415109 - Account Reason cannot be empty when agency status becomes New application pending
        Set<Id> setIdAACCForNewApplicationPending = new Set<Id>();
        Id irregRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Irregularities');
        List<Agency_Applied_Change_code__c> aaccToBeProcessed = new List<Agency_Applied_Change_code__c>();
        for(Agency_Applied_Change_Code__c aaccRecord : aacc)
        {
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

        if(!AMS_OscarCase_RiskMgmt.mapAccntToUpdate.isEmpty())
            mapAccntToUpdate = AMS_OscarCase_RiskMgmt.mapAccntToUpdate;

        AMS_Irregularities_Utils.CalculateAccumulatedIrregularitiesFromChangeCode(aaccToBeProcessed, mapAccntToUpdate, AMS_OscarCase_RiskMgmt.irrsToExp);
        
        if(!setIdAACC.isEmpty() && (AMS_AccountTriggerHandler.processMinorChangesValidationFlag || AMS_AccountTriggerHandler.minorChangesComingFromOSCAR)){
	        if(!setIdAACCForNewApplicationPending.isEmpty()) 
                setIdAACC.addAll(setIdAACCForNewApplicationPending);

            updateAccountReason(setIdAACC, true);
        } else {
             if(!setIdAACCForNewApplicationPending.isEmpty()) 
                updateAccountReason(setIdAACCForNewApplicationPending, true);
        }

        if(!mapAccntToUpdate.isEmpty()){
            update mapAccntToUpdate.values();
            mapAccntToUpdate = new Map<Id, Account>();
        }
    }

    public static void handleBeforeInsert(List<Agency_Applied_Change_code__c> aacc){

        Set<String> accIrregularities = new Set<String> {'IRR','IRS','IRW'};
        Set<String> locationClassesUnpublish = new Set<String> {'M','T','G','X'};

        UpdateReasonCode(aacc, false);
        if(!ANG_OscarProcessHelper.isIATACodeGenerationRunning)
            migrateFieldsFromStagingToAccount(aacc);

        Set<Id> changeCodeAccounts = new Set<Id>();
        Set<Id> changeCodeOscars = new Set<Id>();
        List<Agency_Applied_Change_code__c> toCheckUnpublish = new List<Agency_Applied_Change_code__c>();

        for(Agency_Applied_Change_code__c aaccRecord : aacc){

            aaccRecord.RecordTypeId = accIrregularities.contains(aaccRecord.Change_Code__c) ? irregRtId : stdRtId;

            if(aaccRecord.To_Publish_in_e_Bulletin__c){
                changeCodeAccounts.add(aaccRecord.Account__c);

                if(aaccRecord.OSCAR__c != null)
                    changeCodeOscars.add(aaccRecord.OSCAR__c);

                toCheckUnpublish.add(aaccRecord);
            }

            if(aaccRecord.AIMS_ID__c != null && aaccRecord.AIMS_ID__c.right(1) != 'A' && aaccRecord.Operation__c == 'A')
                aaccRecord.AIMS_ID__c = aaccRecord.AIMS_ID__c + '_A';
        }

        if(toCheckUnpublish.isEmpty()) return;

        Map<Id,Account> mapAccounts =  new Map<Id,Account>();
        Map<Id,AMS_OSCAR__c> mapOscars = new Map<Id,AMS_OSCAR__c>();

        if(!changeCodeAccounts.isEmpty())
            mapAccounts = new Map<Id,Account>([SELECT Id, Location_Class__c FROM Account WHERE Id IN: changeCodeAccounts]);

        if(!changeCodeOscars.isEmpty())    
            mapOscars = new Map<Id,AMS_OSCAR__c>([SELECT Id, Process__c FROM AMS_OSCAR__c WHERE Id IN: changeCodeOscars]);

        for(Agency_Applied_Change_code__c aaccRecord : toCheckUnpublish){

            if(locationClassesUnpublish.contains(mapAccounts.get(aaccRecord.Account__c).Location_Class__c) || (aaccRecord.OSCAR__c != null && mapOscars.get(aaccRecord.OSCAR__c).Process__c != null && mapOscars.get(aaccRecord.OSCAR__c).Process__c.contains('CER.1.0')))
                aaccRecord.To_Publish_in_e_Bulletin__c = false;
        }
    }
    
    //DTULLO: marked as future because some change codes are generated from account changes (minor changes)
    //thus, we try to re-update the same account again
    //public static void updateAccountReason(list<Agency_Applied_Change_code__c> lsAACC){
	//@future
    //SUSANA ALVES: removed @future because we don't need to update account for minor changes 
    public static void updateAccountReason(Set<Id> setAACC, Boolean bIsUpdate){
    	List<Agency_Applied_Change_code__c> lsAACC = [SELECT Id, Change_Code__c, Reason_Code__c, Reason_Description__c, Active__c, Account__c, AccountNewStatus__c, Account__r.Reason__c, Account__r.Previous_Reason__c, Account__r.Status__c, Account__r.PreviousStatus__c FROM Agency_Applied_Change_code__c WHERE Id IN: setAACC];
    	Set<Id> setAccntId = new Set<Id>();
    	
    	for(Agency_Applied_Change_code__c aacc:lsAACC){
            /*** AMSU-176 ***/
            //Only active changes codes can update account status and reason
            if(!aacc.Active__c) {
                continue;
            }

    		String sReason = (aacc.Reason_Code__c==null?'':aacc.Reason_Code__c)+ '-' + (aacc.Reason_Description__c==null?'':aacc.Reason_Description__c);
    		String sStatus = (aacc.AccountNewStatus__c==null?'':aacc.AccountNewStatus__c);
    		Boolean bUpdateAccnt = false;
    		Account acc = new Account(id = aacc.Account__c);
    		if(!bIsUpdate) acc.Organization_Last_Change_Date__c = Date.Today();
    		if(sReason != '-'){
    			if(aacc.Account__c != null){
	    			string sAccntReason = aacc.Account__r.Reason__c;
	    			if(sReason != sAccntReason){
                        if(!mapAccntToUpdate.containsKey(acc.Id))
                            mapAccntToUpdate.put(acc.Id, acc);

                        mapAccntToUpdate.get(acc.Id).Reason__c = sReason;
                        mapAccntToUpdate.get(acc.Id).Previous_Reason__c = sAccntReason;
	    			}
    			}
    		}
    		
    		//Update Account Status, but only if it's blank and different from the previous one
    		if(sStatus != ''){
    			if(aacc.Account__c != null){
	    			String sAccntStatus = aacc.Account__r.Status__c;
	    			if(sAccntStatus != aacc.AccountNewStatus__c) {

                        if(!mapAccntToUpdate.containsKey(acc.Id))
                            mapAccntToUpdate.put(acc.Id, acc);

                        mapAccntToUpdate.get(acc.Id).Date_Organisation_Status_attained__c = Date.Today();
                        mapAccntToUpdate.get(acc.Id).Status__c = sStatus;
                        mapAccntToUpdate.get(acc.Id).PreviousStatus__c = sAccntStatus;
	    			}
    			}
    		}
    	}

        if(!mapAccntToUpdate.isEmpty()){
            update mapAccntToUpdate.values();

            mapAccntToUpdate = new Map<Id, Account>();
        }
    }
    
    //DTULLO: NEED to bulkify it. Now change codes are bring via dataloader from aims. batch size = 50.
    //because of a requirement, they are coming as active. so, if more than 1 is coming, we should check inside the trigger to set them to false
    //Use of field "Created_Date_To_Show__c" to set only the last one as active.
    public static void verifyActiveAACCuniqueness(List<Agency_Applied_Change_code__c> aaccodes){
        Map<Id, List<Agency_Applied_Change_code__c>> mapLastAACC = new Map<Id, List<Agency_Applied_Change_code__c>>();
        
        List<Agency_Applied_Change_code__c> aACCtoUpdate = new List<Agency_Applied_Change_code__c>();

        Set<Id> agencyIds = new Set<Id>();

        Map<Id,Agency_Applied_Change_code__c> irrsToExp = AMS_OscarCase_RiskMgmt.irrsToExp;

        for(Agency_Applied_Change_code__c aacc : aaccodes)
            agencyIds.add(aacc.Account__c);

        if(agencyIds.isEmpty() && irrsToExp.isEmpty()) return;

        for(Agency_Applied_Change_code__c aac: [SELECT id, Created_Date_To_Show__c, Active__c , Account__c 
                                                FROM Agency_Applied_Change_code__c
                                                WHERE Account__c IN :agencyIds
                                                ORDER BY Account__c, Created_Date_To_Show__c DESC]){

            if(mapLastAACC.containsKey(aac.Account__c)){

                List<Agency_Applied_Change_code__c> ls = mapLastAACC.get(aac.Account__c);

                if(aac.active__c){

                    if(irrsToExp.containsKey(aac.Id)){

                        irrsToExp.get(aac.Id).Active__c = false;

                    } else{

                        aac.Active__c = false;
                        ls.add(aac);
                        mapLastAACC.put(aac.Account__c, ls);
                    }
                }
            }else{
                aac.Active__c = true;
                mapLastAACC.put(aac.Account__c, new List<Agency_Applied_Change_code__c>{aac});
            }
        }

        if(!irrsToExp.isEmpty())
            aACCtoUpdate.addAll(irrsToExp.values());
        
        //do the update
        for(Id acc : mapLastAACC.keyset())
            aACCtoUpdate.addAll(mapLastAACC.get(acc));

        if(!aACCtoUpdate.isEmpty())
            update aACCtoUpdate;

    }

	public static void UpdateReasonCode(List<Agency_Applied_Change_code__c> aacc, Boolean bIsUpdate){
		Map<String, Map<String,String>> mapStatusReason = new Map<String, Map<String, String>>();
		
		for(AMS_Status_Reason__c lsr : AMS_Status_Reason__c.getAll().values()){
			Map<String, String> mapReason;
			if(mapStatusReason.containsKey(lsr.Status_Description__c))
				mapReason = mapStatusReason.get(lsr.Status_Description__c);
			else
				mapReason = new Map<String, String>();
			
			mapReason.put(lsr.Reason_Description__c, lsr.Reason_Code__c);
			mapStatusReason.put(lsr.Status_Description__c, mapReason);
		}
		if(!mapStatusReason.isEmpty()){
			for(Agency_Applied_Change_code__c ac : aacc){
				if(ac.Reason_Code__c==null || ac.Reason_Code__c == '' || bIsUpdate){
					String sStatus = ac.AccountNewStatus__c;
					String sReasDesc = ac.Reason_Description__c;
					String sReasonCode = 'xx';
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

        Id rtNew = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW');
        Id newNGRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_New_HE');

        //NEWGEN-4852
        Set<Id> oscarRecordTypes = new Set<Id>{rtNew,newNGRT,AMS_Utils.RECTYPE_MCAE, AMS_Utils.RECTYPE_NEWGE};

        Set<Id> oscarIds = new Set<Id>();

        for(Agency_Applied_Change_code__c code: aacc){
            if(code.OSCAR__c != null && ( code.change_code__c == 'FIN' || code.change_code__c == 'DIS')){
                oscarIds.add(code.OSCAR__c);
            }
        }
         
        //let's first find the OSCAR that need to be migrated
        List<AMS_OSCAR__c> oscarsToCopyData = new List<AMS_OSCAR__c>();
        List<AMS_OSCAR__c> oscarsToUpdateAppointments = new List<AMS_OSCAR__c>();

        if(oscarIds.isEmpty()) return;

        oscarsToCopyData = [SELECT ID, STEP10__c, STEP6__c, Account__c, Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, RecordTypeId, RecordType.DeveloperName, Process__c, Is_PCI_compliant__c from AMS_OSCAR__C where Id in :oscarIds and RecordTypeId in :oscarRecordTypes and Process__c in :AMS_Utils.oscarAMSProcesses];

        if(!oscarsToCopyData.isEmpty()){

            AMS_Utils.copyDataToAccount(oscarsToCopyData);
        
            //NEWGEN-4852 - Copy Parent Account (GE/HE) information to the staging area of AE in same BSP - Change Code FIN
            List<ID> accIdList = new List<ID>();
            for(AMS_OSCAR__C oscar : oscarsToCopyData){
                if(oscar.Process__c == AMS_Utils.NEWGESTANDARD || (oscar.Process__c == AMS_Utils.MCAE && oscar.Account__r.Location_Type__c == AMS_Utils.HE))
                    accIdList.add(oscar.Account__c);
            }
            System.debug('[ANG_OscarProcessHelper] List of accounts to be copied: ' + accIdList);
            if(!accIdList.isEmpty()) {
                System.debug('[ANG_OscarProcessHelper] Call asynchronous process ANG_MulticountryCopyParentInfo for Change Code - FIN');
                ID jobID = System.enqueueJob(new ANG_MulticountryCopyParentInfo(accIdList, 'FIN'));
                System.debug('[ANG_OscarProcessHelper] Launching job ID: ' + jobID);
            }       

        }else{
            
            System.debug('Nothing to migrate here.');
        }
    }

}
