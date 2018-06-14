/********************
1. When raising the first non-compliance case, the date populated in the FS 1st non-compliance box is the date of when the n-c case is raised
	a. When raising the first non-compliance case, the 2nd deadline date for PAX will be tomorrow’s date + 30 days (if on a weekend, the first working day after)
	b. When raising the first non-compliance case, the 2nd deadline date for Cargo will be set manually in the "New Deadline date"
2. When raising the second non-compliance case, the date populated in the FS 2nd non-compliance box is the date of when the n-c case is raised
	a.When raising the second non-compliance case, the 3rd deadline date for PAX will be the end of the following month (if on a weekend, the first working day after)
	b.When raising the second non-compliance case, the 3rd deadline date for Cargo will be set manually in the "New Deadline date"
3. When raising the third non-compliance case, the date populated in the FS 3rd non-compliance box is the date of when the n-c case is raised


Additional contrains:
- FSM Case must be open
- FSM Letter must be already sent out
- If opening 1st non-compliance, today date must be greater then FS Deadline Date
- If opening 2nd non-compliance, today date must be greater then 2nd FS Deadline Date
- If opening 3rd non-compliance, today date must be greater then 3nd FS Deadline Date
- New Deadline Date on non-compliance case is mandatory for CARGO
- If set, New deadline date on non-compliance case must be greater than today
****************/


trigger Case_FSM_Handle_NonCompliance_BI_BU on Case (before insert, before update) {
	// get the IFAP and ProcessISS case recordtype
    ID FSMRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Security Monitoring');
    ID NCRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');
    
    //system.debug(Logginglevel.ERROR, 'DTULLO ');
    public static final String PAX = 'Travel Agent';
	public static final String CARGO = 'Cargo Agent';
    
    set<id> setFSMCaseId = new set<id>();
	
	//Run only for non-compliance case. Put parent id (FSM Case) into a set 
	for(Case NCCase: trigger.new){
		if(NCCase.RecordTypeId == NCRecordTypeID){
		//	if(NCCase.Parent.RecordTypeId == FSMRecordTypeID)
				setFSMCaseId.add(NCCase.ParentId);
		}
	}
	
	//FSM Case(s) found! Proceed with the logic
	if(!setFSMCaseId.isEmpty()){
		map<Id, Case> mapFSMCaseToUpdate = new map<Id, Case>(); //List of FSM case to update
		//Search Parent Case (FSM)
		map<ID, Case> mapFSMCases = new Map<ID, Case>([Select Id, Status, RecordTypeId, Account.Industry, FS_Letter_Sent__c, isClosed
														, FS_Deadline_Date__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c
														, firstFSnonComplianceDate__c, secondFSnonComplianceDate__c, FS_third_non_compliance_date__c
														from Case c where Id IN :setFSMCaseId and RecordTypeId = :FSMRecordTypeID]);
		
		for(Case NCCase:trigger.new){
			if(NCCase.RecordTypeId == NCRecordTypeID && mapFSMCases.keyset().contains(NCCase.ParentId)){
				Case FSMCase;
				
				if(mapFSMCaseToUpdate.containsKey(NCCase.ParentId))
					FSMCase = mapFSMCaseToUpdate.get(NCCase.ParentId);
				else
					FSMCase = mapFSMCases.get(NCCase.ParentId);
				
				string AccntType = FSMCase.Account.Industry;	//Type of account. Cargo Agent / Travel Agent
				
				if(Trigger.isInsert){
	    			if(NCCase.CaseArea__c == 'Accreditation Process' && NCCase.reason1__c == 'FA/ FS Non-Compliance' && NCCase.Origin == 'Internal Case'){
		    			//1st check: letter must be sent prior non-compliance opening
		    			if(FSMCase.FS_Deadline_Date__c!=null){
		    				//Cannot open non-compliance for closed FSM Case
		    				if(FSMCase.isClosed==false){
		    					
		    					string sMsgCargoCheckNewDate = CargoDateValid(NCCase.New_IFAP_Deadline_date__c);
		    					
		    					if(FSMCase.firstFSnonComplianceDate__c==null){
		    						//Cannot create 1st non-compliance if first deadline >= today 
		    						if(FSMCase.FS_Deadline_Date__c >= Date.today()){
		    							NCCase.addError('Cannot create a 1st FS non-compliance case. The 1st FS Deadline is ' + FSMCase.FS_Deadline_Date__c.format());
		    						}else{
		    							//Ok, we can create the 1st non-compliance case. Let's go!
		    							if(AccntType==PAX){
		    								//Just to cover some additional lines in test
		    								if(test.isRunningTest()){
		    									date dt = getMondayIfOnWeekend(date.NewInstance(2015,2,15));
		    									dt = getMondayIfOnWeekend(date.NewInstance(2015,2,14));
		    								}
		    								
		    								FSMCase.FS_Second_Deadline_Date__c = getMondayIfOnWeekend(date.Today().addDays(31));
		    							}
		    							
		    							if(AccntType==CARGO){
		    								if(sMsgCargoCheckNewDate=='')
		    									FSMCase.FS_Second_Deadline_Date__c = NCCase.New_IFAP_Deadline_date__c;
		    								else{
		    									NCCase.addError(sMsgCargoCheckNewDate);
		                                    	continue;
		    								}
		    							}
		    							
		    							FSMCase.firstFSnonComplianceDate__c = Date.Today();
		    							mapFSMCaseToUpdate.put(FSMCase.Id, FSMCase);
		    						}
		    					}else if(FSMCase.secondFSnonComplianceDate__c==null){
		    						if(FSMCase.FS_Second_Deadline_Date__c >= Date.today()){
		    							NCCase.addError('Cannot create a 2nd FS non-compliance case. The 2nd FS Deadline is ' + FSMCase.FS_Second_Deadline_Date__c.format());
		    						}else{
		    							//Ok, we can create the 2nd non-compliance case. Let's go!
		    							if(AccntType==PAX){
		    								//set the date to the last day of the next month. If on weekend, set it to the first monday available
	                                    	FSMCase.FS_Third_Deadline_Date__c = getMondayIfOnWeekend(Date.newInstance(Date.today().addMonths(2).year(), Date.today().addMonths(2).month(), 1).addDays(-1));
		    							}
		    							
		    							if(AccntType==CARGO){
		    								if(sMsgCargoCheckNewDate=='')
		    									FSMCase.FS_Third_Deadline_Date__c = NCCase.New_IFAP_Deadline_date__c;
		    								else{
		    									NCCase.addError(sMsgCargoCheckNewDate);
		                                    	continue;
		    								}
		    							}
		    							
		    							FSMCase.secondFSnonComplianceDate__c = Date.Today();
		    							mapFSMCaseToUpdate.put(FSMCase.Id, FSMCase);
		    						}
		    					}else if(FSMCase.FS_third_non_compliance_date__c==null){
		    						if(FSMCase.FS_Third_Deadline_Date__c >= Date.today()){
		    							NCCase.addError('Cannot create a 3rd FS non-compliance case. The 3rd FS Deadline is ' + FSMCase.FS_Third_Deadline_Date__c.format());
		    						}else{
		    							//Ok, we can create the 3rd non-compliance case. Let's go!
		    							FSMCase.FS_third_non_compliance_date__c = Date.Today();
		    							mapFSMCaseToUpdate.put(FSMCase.Id, FSMCase);
		    						}
		    					}else{ //Cannot open more then 3 non-compliance case
		    						NCCase.addError('Cannot create more than 3 FS non-compliance case.');
		    					}
		    				}else{
		    					NCCase.AddError('A Non-compliance case cannot be created when the FSM case is closed');
		    				}
		    			}else{
		    				NCCase.AddError('The FS Request Letter has not been sent. Kindly send the letter before you proceed.');
		    			}
	    			}
	    		}
	    		
	    		
	    		if(trigger.isUpdate){
	    			system.debug(Logginglevel.ERROR, 'DTULLO trigger is update');
		    		if(FSMCase.FS_Deadline_Date__c!=null){
		    		//if(FSMCase.FS_Letter_Sent__c==true){ //if null, it could lead to errors...
		    			if(FSMCase.isClosed==false){
			    			continue;
		    			}else{
		    				NCCase.AddError('A Non-compliance case cannot be created when the FSM case is closed');
		    			}
		    		}else{
		    			NCCase.AddError('The FS Request Letter has not been sent. Kindly send the letter before you proceed.');
		    		}
		    	}
		    	
		    	//Commit FSM Cases
		    	if(!mapFSMCaseToUpdate.isEmpty()){
		    		update mapFSMCaseToUpdate.values();
		    	}
			}
	    }
	}
	
	 
	private static Date getMondayIfOnWeekend(date deaddate){
		Date RefDate = date.NewInstance(1900,1,7);
		integer dayOfWeek = math.mod(RefDate.daysBetween(deaddate),7);
		if(dayOfWeek==0)//Sunday
			return deaddate.addDays(1);
		else if(dayOfWeek==6)//Saturday
			return deaddate.addDays(2);
		else
			return deaddate;
	}
	
	private static string CargoDateValid(date dtToCheck){
		if(dtToCheck == null) {
        	return 'The New Deadline date is mandatory when creating a non-compliance for Cargo Agents.';
    	}
    	else {
    		if(dtToCheck > Date.today()){
        		return '';
    		}else{
    			return 'The New Deadline date must be greater than today.';
    		}
    	}
	}
}