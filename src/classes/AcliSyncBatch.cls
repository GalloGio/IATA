global class AcliSyncBatch implements Database.Batchable<String>, Database.Stateful {
	
	global String fileContent;
    global String backUp;
    global String newAcliAccounts;
    global String updateErrors;
    global String codingCasesLog;
    
    global AcliSyncBatch(String content) {
        fileContent = content;
        codingCasesLog = '';
    }
    
    
    global Iterable<string> start(Database.batchableContext batchableContext){
    	backUp = AcliAccount.firstLineCSV();
    	newAcliAccounts = AcliAccount.firstLineCSV();
    	updateErrors = '';
    	codingCasesLog = '';
    	
        return new UtilityRowIterator(fileContent);
    }
    
    
    // The scope is a list of lines from the ACLI file
    global void execute (Database.BatchableContext batchableContext, List<String> scope){
    	processLines(scope);
    }
    
    
    public void processLines(list<String> listLines) {
        
        //// Create a map of AcliAccounts per SAP ID
        map<String, AcliAccount> mapAcliAccountPerSapId = new map<String, AcliAccount>();
        for(String line : listLines){
        	
            // parse the lines into AcliAccounts
            AcliAccount acliAcc = new AcliAccount(line, true);
            
            if (acliAcc.AcliSAPId != null && acliAcc.AcliSAPId != '' ) {
				mapAcliAccountPerSapId.put(acliAcc.AcliSAPId, acliAcc);
            } 
        }
        
        
        //// Get related data from SF
        // Get corresponding accounts from SF into a map per SAP ID
        list<String> lstAcctRecordTypes = new list<String>{'IATA_Airline', 'Standard_Account', 'Others'};
        list<Account> lstSFaccounts = [SELECT Id,name,IATACode__c,Name_on_AOC__c, Airline_designator__c,ICAO_designator__c,billingStreet, billingCity,billingState, billingCountry,billingPostalCode, 
                               					Membership_SITA__c, Memmership_ARINC__c, IATA_Member__c, Memmership_ATA__c, Type_of__c, Account_code_secondary_flag__c, Airline_Prefix__c, IATA_ISO_Country__c, ACLI_Status__c, 
                               					IATA_ISO_Country__r.ISO_Code__c, Membership_status__c, ACLI_SAP_Id__c, MITA_Member__c, AOC_Expiry_Date__c
                           					 FROM Account 
                           					 WHERE RecordType.DeveloperName IN :lstAcctRecordTypes 
                           					 AND ACLI_SAP_Id__c IN :mapAcliAccountPerSapId.keyset()];

   		list<Id> lstAccountIds = new list<Id>();
   		map<String, Account> mapAccountsPerSapId = new map<String, Account>();
   		for (Account a : lstSFaccounts) {
   			mapAccountsPerSapId.put(a.ACLI_SAP_Id__c, a);
   			lstAccountIds.add(a.Id);
   		}
   		
   		// get related SAP Account records into a map per ACLI SAP Id
   		map<String, SAP_Account__c> mapSapAccountsPerSapId = new map<String, SAP_Account__c>();
   		list<SAP_Account__c> lstSapAccounts = [SELECT Id, Airline_Coding__c, SAP_ID__c, Account__c, Account__r.ACLI_SAP_Id__c FROM SAP_Account__c WHERE Account__c IN :lstAccountIds];
   		for (SAP_Account__c sa : lstSapAccounts) {
   			// only interested if the SAP ID on the record is the same as the SAP Id in the account, because that's the value from the ACLI file (the account was matched based on that)
   			if (sa.SAP_ID__c == sa.Account__r.ACLI_SAP_Id__c) {
   				if ( mapSapAccountsPerSapId.get(sa.SAP_ID__c) == null ) {
   					mapSapAccountsPerSapId.put(sa.SAP_ID__c, sa);
   				} else {
   					// there is another account with the same ID, and this should not happen
   					codingCasesLog += 'There is more than one account with the SAP ID "' + sa.SAP_ID__c + '\r\n';
   				}
   			}
   		}
   		
   		// get related cases into a map per Account Id
   		map<Id, list<Case>> mapCasesPerAccId = new map<Id, list<Case>>();
   		list<Case> listUpdateCases = new list<Case>();
   		list<Case> lstAirlineCodingCases = [SELECT Id, AccountId, Coding_Application_ID__c, Coding_Application_Reception_Date__c, Coding_Application_Status__c, Reason1__c
   												FROM Case 
   												WHERE RecordType.DeveloperName = 'Airline_Coding_Application' AND isClosed = false AND AccountId IN :lstAccountIds];
        for (Case cs : lstAirlineCodingCases) {
        	list<Case> listCases = mapCasesPerAccId.get(cs.AccountId);
        	if (listCases == null) {
        		listCases = new list<Case>();
        	}
        	listCases.add(cs);
        	mapCasesPerAccId.put(cs.AccountId, listCases);
        }
        
        //// Process the accounts from the ACLI file
        map<String, Account> mapAccountsToUpsertPerSapId = new map<String, Account>();

        for (String AcliSapId : mapAcliAccountPerSapId.keyset()) {
        	// get the ACLI account
        	AcliAccount acliAcc = mapAcliAccountPerSapId.get(AcliSapId);
        	// get the match from SF
        	Account SFacc =  mapAccountsPerSapId.get(AcliSapId);
        
        	if (SFacc != null) {
        		///// Handle the Account update
        		// add the SF account info to the ACLI account
        		acliAcc.AcctID = SFacc.Id;
        		acliAcc.Membership_status = SFacc.Membership_status__c;
        
        		// current acli account is updated, but only if any field is changed
        		if (acliAcc.updateAccount(SFacc) ) {
	        		// create the updated account with info from ACLI
	        		mapAccountsToUpsertPerSapId.put( acliAcc.AcliSAPId, SFacc );
        		}

        		// add the old account data to the backup
        		backUp += AcliAccount.lineOfAcliFromACct(SFacc);
        		
        		
        		///// Handle the SAP Account record upsert
        		if (mapSapAccountsPerSapId.get(SFacc.ACLI_SAP_Id__c) != null) {
        			// if the SAP Account record exists, only update the Airline Coding checkbox to true
        			SAP_Account__c tempSapAcct = mapSapAccountsPerSapId.get(SFacc.ACLI_SAP_Id__c);
        			tempSapAcct.Airline_Coding__c = true;
        			
        			mapSapAccountsPerSapId.put(SFacc.ACLI_SAP_Id__c, tempSapAcct);
        		} else {
        			SAP_Account__c tempSapAcct = new SAP_Account__c();
        			tempSapAcct.Account__c = SFacc.Id;
        			tempSapAcct.SAP_ID__c = AcliSapId;
        			tempSapAcct.Airline_Coding__c = true;
        			
        			mapSapAccountsPerSapId.put(SFacc.ACLI_SAP_Id__c, tempSapAcct);
        		}
        		
        		
				///// Find in the list of cases linked to the account, one with the same reason
        		list<Case> listCase = mapCasesPerAccId.get(SFacc.Id);
        		list<Case> listTmpCase = new list<Case>();
        		
        		if ( listCase != null ) {
        			for ( Case tempCase: listCase) {
        				if (tempCase.Reason1__c == acliAcc.reason ) {
		        			tempCase.Coding_Application_ID__c = acliAcc.ApplicationId;
		        			tempCase.Coding_Application_Status__c = acliAcc.CodingApplicationStatus;
		        			tempCase.Coding_Application_Reception_Date__c = acliAcc.CodingApplicationReceptionDate != null ? Date.valueOf(acliAcc.CodingApplicationReceptionDate) : null;
		        			
		        			listTmpCase.add(tempCase);
        				}
        			}
        		}
        		// if there is coding data to sync, but no coding case open or more than one, log this in the coding case log
        		if (acliAcc.CodingApplicationStatus.trim() != '' || acliAcc.CodingApplicationReceptionDate != null) {
	        		if (listTmpCase.isEmpty()) {
	        			codingCasesLog += 'No open coding case found for account "' + acliAcc.AirlineName + '" with the Id "' + SFacc.Id + '" and the SAP Id "' + AcliSapId + '"\r\n';
	        		} else if (listTmpCase.size() > 1) {
	        			codingCasesLog += 'More than one open coding case found for account "' + acliAcc.AirlineName + '" with the Id "' + SFacc.Id + '" and the SAP Id "' + AcliSapId + '"\r\n';
	        		} else {
	        			listUpdateCases.add(listTmpCase.get(0));
	        		}
        		}

        	} else {
        		///// If not account in SF found, create a new account
        		Account newAcc = AcliAccount.createAcctFromAcliAccount(acliAcc);
        		newAcc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        		
        		mapAccountsToUpsertPerSapId.put( acliAcc.AcliSAPId, newAcc );
        		
        		// prepare a new SAP Account record for this account, but without the Account ID - we don't have it yet
        		SAP_Account__c tempSapAcct = new SAP_Account__c();
    			tempSapAcct.SAP_ID__c = acliAcc.AcliSAPId;
    			tempSapAcct.Airline_Coding__c = true;
    			
    			mapSapAccountsPerSapId.put(acliAcc.AcliSAPId, tempSapAcct);
        	}
        }
        
        //// Update the data in SF
        if (!mapAccountsToUpsertPerSapId.values().isEmpty()) {
        	// Accounts
        	Database.UpsertResult[] urList = Database.upsert(mapAccountsToUpsertPerSapId.values(), false);
        	
        	for (Integer i = 0; i < urList.size(); i++) {
        		if (!urList[i].isSuccess()) {
        			updateErrors += 'Error(s) upserting the Account with ID = ' + mapAccountsToUpsertPerSapId.values()[i].Id + ' with the ACLI SAP Id ' + mapAccountsToUpsertPerSapId.values()[i].ACLI_SAP_Id__c + ': \r\n';
        			for(Database.Error err : urList[i].getErrors()) {
			            updateErrors += '\t' + err.getStatusCode() + ': ' + err.getMessage() + '. Fields affected: ' + err.getFields() + '. \r\n';
			        }
        		}
        		
        		// log the Accounts newly INSERTED
        		if (urList[i].isCreated()) {
        			newAcliAccounts += AcliAccount.lineOfAcliFromACct( mapAccountsToUpsertPerSapId.values()[i] );
        		}
        	}
        	
        	
        	// SAP Account records
        	
        	// first, check if there are SAP Accounts without Account Id - it means they are for new accounts just created
        	// get the Account Id for them from the account upsert above
        	for (String strSapId : mapSapAccountsPerSapId.keyset()) {
        		if (mapSapAccountsPerSapId.get(strSapId).Account__c == null) {
        			if (mapAccountsToUpsertPerSapId.get(strSapId).Id != null ) {
        				SAP_Account__c tempSapAcct = mapSapAccountsPerSapId.get(strSapId);
	        			tempSapAcct.Account__c = mapAccountsToUpsertPerSapId.get(strSapId).Id;
	        			mapSapAccountsPerSapId.put(strSapId, tempSapAcct);
        			} else {
        				// Id == null would mean there was an Account insertion error, so we need to remove the corresponding SAP Account from the list
        				mapSapAccountsPerSapId.remove(strSapId);
        			}
        		}
        	}
	        if (!mapSapAccountsPerSapId.values().isEmpty()) {
	        	urList = Database.upsert(mapSapAccountsPerSapId.values(), false);
	        	
	        	for (Integer i = 0; i < urList.size(); i++) {
	        		if (!urList[i].isSuccess()) {
	        			updateErrors += 'Error(s) updating the SAP Account with ID = ' + mapSapAccountsPerSapId.values()[i].Id + ': \r\n';
	        			for(Database.Error err : urList[i].getErrors()) {
				            updateErrors += '\t' + err.getStatusCode() + ': ' + err.getMessage() + '. Fields affected: ' + err.getFields() + '. \r\n';
				        }
	        		}
	        	}
	        }
        }
        
    	// Cases
        if (!mapSapAccountsPerSapId.values().isEmpty()) {
        	Database.SaveResult[] srList = Database.update(listUpdateCases, false);
        	for (Integer i = 0; i < srList.size(); i++) {
        		if (!srList[i].isSuccess()) {
        			codingCasesLog += 'Error(s) updating the Case with ID = ' + listUpdateCases[i].Id + ': \r\n';
        			for(Database.Error err : srList[i].getErrors()) {
			            codingCasesLog += '\t' + err.getStatusCode() + ': ' + err.getMessage() + '. Fields affected: ' + err.getFields() + '. \r\n';
			        }
        		} else {
        			codingCasesLog += 'Successfully updated the Case with ID = ' + listUpdateCases[i].Id + ': \r\n';
        		}
        	}
        }
    }
    
    global void finish (Database.BatchableContext batchableContext){
        // Create the confirmation email, with the logs attached
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        list<string> lstRecipients = new list<string>();
        lstRecipients.add(userInfo.getUserEmail());
        for (String tempStr : String.valueOf(UtilityCS__c.getInstance('AcliConfirmationEmailRecipients').Value__c).split(',')) {
        	lstRecipients.add(tempStr);
        }
        
        email.setSubject('ACLI sync batch ' + datetime.now());
        email.setToAddresses( lstRecipients );
        email.setPlainTextBody( 'The ACLI synchronization batch has finished its execution. Please find attached the log files.' );
        
        // build backup, unmatched log and error log attachment
        Messaging.EmailFileAttachment[] attachements = new Messaging.EmailFileAttachment[]{} ;
    	
        
        // account backup file
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
	        efa.setContentType('application/xml');   
	        efa.setFileName('BackUpSyncedAccounts_'+datetime.now()+'.csv');
	        efa.setBody(blob.valueOf(backUp));
        attachements.add(efa);
        
        
        // new ACLI accounts
        if (newAcliAccounts != AcliAccount.firstLineCSV()) {
        	efa = new Messaging.EmailFileAttachment();
		        efa.setContentType('application/xml');   
		        efa.setFileName('NewAcliAccounts_' + datetime.now() + '.csv');
		        efa.setBody(blob.valueOf(newAcliAccounts));
        	attachements.add(efa);
        }
        
        // error log
        if (updateErrors != '') {
        	efa = new Messaging.EmailFileAttachment();
		        efa.setContentType('text/plain');
		        efa.setFileName('ErrorLog_' + datetime.now() + '.txt');
		        efa.setBody(blob.valueOf(updateErrors));
        	attachements.add(efa);
        }
        
        // coding cases log
        if (codingCasesLog != '') {
        	efa = new Messaging.EmailFileAttachment();
		        efa.setContentType('text/plain');
		        efa.setFileName('CodingCasesLog_' + datetime.now() + '.txt');
		        efa.setBody(blob.valueOf(codingCasesLog));
        	attachements.add(efa);
        }
        
        email.setFileAttachments(attachements);

        // Sends the email
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
    }
    
    
}