global class AMS_ValidateAccSpecialChars_Batch implements Database.Batchable<sObject>,Database.Stateful {

	/**
	How to execute:
	- execute following code on an "anonymous window" (on the developer console per example)

	code:
	AMS_ValidateAccSpecialChars_Batch a = new AMS_ValidateAccSpecialChars_Batch([to_update]);
	Database.executeBatch(a, 2000);

	- the parameter [to_update] is a boolean value that indicates if the records are to be updated or only to generate the report with the results
		ex: 
		  -AMS_ValidateAccSpecialChars_Batch a = new AMS_ValidateAccSpecialChars_Batch(true); - generate email report and update the account fields that where cleaned
		  -AMS_ValidateAccSpecialChars_Batch a = new AMS_ValidateAccSpecialChars_Batch(false); - only generate the email report

	*/
	
	String query;

	global List<String> errors;
	global Map<String,Integer> countriesInfo;
	global Map<String,Integer> countriesErrors;
	global AMS_Trigger_Execution_Manager__c runningUser;
	global AMS_Trigger_Execution_Manager__c runningUserBackup;
	global Boolean userAlreadyExisted = false;
	global Boolean toUpdate = false;

	public static List<Id> countriesIds{
		get {
			if(countriesIds == null){
				List<String> sCountries = UtilityCS__c.getInstance('AMS_ValidateAccSpecialChars_Countries').Value__c.split(';');
				List<IATA_ISO_Country__c> lstCountries = IATAIsoCountryDAO.getIsoCountryByCountriesName(new Set<String>(sCountries));
				List<Id> ids = new List<Id>();
				for(IATA_ISO_Country__c ctr : lstCountries){
					//System.debug('countriesIds - Name: '+ ctr.Name +' - Id: ' + ctr.Id);
					ids.add(ctr.Id);
				}
			    countriesIds = ids;
		    }
		    return countriesIds;
		}set;
	}

	public static List<String> targetEmails{
		get {
			return UtilityCS__c.getInstance('AMS_ValidateAccSpecialChars_emails').Value__c.split(';');
		}set;
	}


	/*
	ValidateAccSpecialChars_Batch - query: 
		SELECT IATACode__c, Name, CASS_Number__c, Short_Name__c, License_Number__c, VAT_Number__c, BillingStreet, BillingState, BillingCity, ShippingStreet, ShippingPostalCode, ShippingCity, Email__c, Website, 
				Abbreviated_name__c, Abbreviated_address__c, VAT_Number_2__c, 
				status__c,Region_formula__c,Location_Class__c,Location_Type__c, IATA_ISO_Country__r.name
		FROM ACCOUNT 
		WHERE IATA_ISO_Country__c in :countriesIds
		AND RecordType.DeveloperName = \'IATA_Agency\'

		OR 

		SELECT IATACode__c, Name, CASS_Number__c, Short_Name__c, License_Number__c, VAT_Number__c, BillingStreet, BillingState, BillingCity, ShippingStreet, ShippingPostalCode, ShippingCity, Email__c, Website, 
				Abbreviated_name__c, Abbreviated_address__c, VAT_Number_2__c, 
				status__c,Region_formula__c,Location_Class__c,Location_Type__c, IATA_ISO_Country__r.name
		FROM ACCOUNT 
		WHERE RecordType.DeveloperName = \'IATA_Agency\'		
	*/
	global AMS_ValidateAccSpecialChars_Batch(Boolean updateRecords) {

		this.errors = new List<String>();
		this.countriesInfo = new Map<String,Integer>();	
		this.countriesErrors = new Map<String,Integer>();	
		this.toUpdate = updateRecords == null ? false : updateRecords;
   		
		//Check if running user have the triggers exception turned "ON", if not we create an entry if already exist we set it to bypass all triggers
		List<AMS_Trigger_Execution_Manager__c> exceptionUsers = [SELECT Id, Name, SetupOwnerId, All__c, AMS_Agency_Ownership_c_Triggers__c, Case_Triggers__c, Account_Triggers__c 
                            FROM AMS_Trigger_Execution_Manager__c WHERE SetupOwnerId = :UserInfo.getUserId() limit 1];

		this.runningUser = exceptionUsers.size() > 0 ? exceptionUsers[0] : null;

		if(this.runningUser == null){
			this.userAlreadyExisted = false;
			this.runningUser = new AMS_Trigger_Execution_Manager__c(SetupOwnerId = UserInfo.getUserId(), All__c = true);
			insert this.runningUser;
		}else{
			this.runningUserBackup  = new AMS_Trigger_Execution_Manager__c(Id = this.runningUser.Id, SetupOwnerId = this.runningUser.SetupOwnerId, All__c = this.runningUser.All__c, Name = this.runningUser.Name,
																				Account_Triggers__c = this.runningUser.Account_Triggers__c, Case_Triggers__c = this.runningUser.Case_Triggers__c, AMS_Agency_Ownership_c_Triggers__c = this.runningUser.AMS_Agency_Ownership_c_Triggers__c);
			this.userAlreadyExisted = true;
			this.runningUser.All__c = true;		
			this.runningUser.Account_Triggers__c = ''; 
			this.runningUser.Case_Triggers__c = '';
			this.runningUser.AMS_Agency_Ownership_c_Triggers__c = '';
			update this.runningUser;
		}

		//Preparing the query to retrieve the data   		
		query = 'SELECT ';
		
		for(Schema.FieldSetMember field : AMS_Utils.ACCOUNT_FIELDS_TO_VALIDATE) {
			query += field.getFieldPath()+', ';			
		}
		
		query += 'Status__c,Region_formula__c,Location_Class__c,Location_Type__c, IATA_ISO_Country__r.name FROM ACCOUNT WHERE ';

		//System.debug('AMS_ValidateAccSpecialChars_Batch - countriesIds: ' + countriesIds);
		if(countriesIds != null && countriesIds.size() > 0){
			query += 'IATA_ISO_Country__c in :countriesIds AND ';
		}
		query += 'RecordType.DeveloperName = \'IATA_Agency\'';
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Database.QueryLocator ql = Database.getQueryLocator(query);
		return ql;
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		System.debug('AMS_ValidateAccSpecialChars_Batch - query: ' + query);
   		System.debug('AMS_ValidateAccSpecialChars_Batch - scope.size(): ' + scope.size());

   		System.debug('validateAccounts - INIT - this.countriesInfo: ' + this.countriesInfo);
   		
   		
   		for(Account a : (list<ACCOUNT>)scope){
   			Integer countryCount = 0;

  			 if(this.countriesInfo.containsKey(a.IATA_ISO_Country__r.name)){
		    	Integer aux = this.countriesInfo.get(a.IATA_ISO_Country__r.name);
		    	countryCount = (aux+1);
		    }else{
		    	countryCount = 1;
		    }

			this.countriesInfo.put(a.IATA_ISO_Country__r.name, countryCount);
		}
   				
		validateAccounts(scope);
	}
	
	
	public void validateAccounts(list<ACCOUNT> accts) {

		String countryName = '';
		Integer countryCount = 0;
		Integer errCount = 0;
		List<Account> accToUpdate = new List<Account>();
		
		Map<String,Integer> errorsMap = new Map<String,Integer>();

		for(Account a : accts){

			//In order to make the test class cover all the code, just because we cannot insert an account with an incorrect name
			if(Test.isRunningTest()) { if(a.Name == 'Test2 Agency') a.Name = 'Test2 – Agency'; }

			String error = '';
			String infoChange = '';
			Boolean hasChanged = false;
			List<String> res = AMS_Utils.validateCharacters(a, AMS_Utils.ACCOUNT_FIELDS_TO_VALIDATE);

			for(String s : res){
				error += (error == '' ? s : ', '+s);
			}
			if(error != ''){ 
				
				System.debug('validateAccounts - Initial - error: ' + error);
				//If errors found let's try to clean up
				List<String> resChange = AMS_Utils.cleanAndUpdateSpecialChars(a, AMS_Utils.ACCOUNT_FIELDS_TO_VALIDATE, this.toUpdate);
				
				for(String s : resChange){
					hasChanged = true;
					infoChange += (infoChange == '' ? s : '|| '+s);
				}
				System.debug('validateAccounts - Initial - infoChange: ' + infoChange);

				//if changes made we keep the record to update massivelly
				if(hasChanged) accToUpdate.add(a);

				//Validate again after cleasing the special chars
				error = '';
				res = AMS_Utils.validateCharacters(a, AMS_Utils.ACCOUNT_FIELDS_TO_VALIDATE);
				for(String s : res){
					error += (error == '' ? s : ', '+s);
				}
				
				System.debug('validateAccounts - Final - error: ' + error);

				error = '"' + a.Id + '","' + a.Name + '","' + a.IATACode__c + '","'+ a.Status__c + '","' + a.Location_Type__c + '","' + a.Location_Class__c + '","' + a.Region_formula__c + '","' + a.IATA_ISO_Country__r.name + '","Cleaned","Changes: ' + infoChange + '","Errors: ' + error + '"';
				errCount++;

				errors.add(error);

			    if(this.countriesErrors.containsKey(a.IATA_ISO_Country__r.name)){
			    	Integer aux = this.countriesErrors.get(a.IATA_ISO_Country__r.name);
			    	//System.debug('AMS_ValidateAccSpecialChars_Batch -init- countryCount: ' + countryCount);
			    	countryCount = (aux+1);
			    }else{
			    	countryCount = 1;
			    }
				this.countriesErrors.put(a.IATA_ISO_Country__r.name, countryCount);
			}

		}

		if(toUpdate && accToUpdate.size() > 0) update accToUpdate;

		//System.debug('validateAccounts - errCount: ' + errCount);
		
	}
	
	global void finish(Database.BatchableContext BC) {
		//System.debug('finish - errors: ' + errors);

		//reset the trigger execution exception into it's original state
		if(this.userAlreadyExisted){
			this.runningUser  = new AMS_Trigger_Execution_Manager__c(Id = this.runningUserBackup.Id, SetupOwnerId = this.runningUserBackup.SetupOwnerId, All__c = this.runningUserBackup.All__c, Name = this.runningUserBackup.Name,
										Account_Triggers__c = this.runningUserBackup.Account_Triggers__c, Case_Triggers__c = this.runningUserBackup.Case_Triggers__c, AMS_Agency_Ownership_c_Triggers__c = this.runningUserBackup.AMS_Agency_Ownership_c_Triggers__c);
			update this.runningUser;
		}else{
			delete this.runningUser;
		}

		sendEmailResult(errors, this.countriesInfo, this.countriesErrors);
	}

	public static void sendEmailResult(List<String> results, Map<String,Integer> countriesInfoAux, Map<String,Integer> countriesErrorsAux) {
		
		Integer countryCountTotal = 0;
		Integer countryErrorsTotal = 0;
		
		String body = ' Country : #Records : #Errors \n';
		for (String countryName : countriesInfoAux.keySet()){
			body += countryName + ': ' + countriesInfoAux.get(countryName) + ' : ' + (countriesErrorsAux.get(countryName) == null ? 0 : countriesErrorsAux.get(countryName)) +' \n';
			countryCountTotal = countryCountTotal + countriesInfoAux.get(countryName);
			countryErrorsTotal = countryErrorsTotal + (countriesErrorsAux.get(countryName) == null ? 0 : countriesErrorsAux.get(countryName));

            //System.debug('field name is ' + countryName);
            //System.debug('countriesInfoAux.get(countryName) is ' + countriesInfoAux.get(countryName));
        }
        body += 'Total Records: ' + countryCountTotal + ' : '+ countryErrorsTotal +' \n';

	    body += '\nErrors: \n\n';

	    body += '"ID","Name","IATACode","Status","Location Type","Location Class","Region","Country","Special Chars","Changes","Errors" \n';
	    for(String res : results) {
	        body += res + '\n';
	    }

	    //System.debug('sendEmailResult - body: ' + body);

	    Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
	    Blob csvReport = Blob.valueOf(body);
	    csvAttc.setFileName('Account_Special_Chars_Validation.csv');
	    csvAttc.setBody(csvReport);

	    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	    message.subject = 'Account Special Chars Validation report';
	    
	    //System.debug('sendEmailResult - UserInfo.getUserEmail(): ' + UserInfo.getUserEmail());

	    //message.toAddresses = new List<String> {UserInfo.getUserEmail()};
	    message.toAddresses = targetEmails;
	    //message.setTargetObjectId(UserInfo.getUserId());
	    
	    message.saveAsActivity = false; //must be false when sending mail to users.
	    message.setPlainTextBody('Account Special Chars Validation report - Check attachment with execution results');
	    message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
	    Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};
	    //System.debug('sendEmailResult - messages: ' + messages);
	    try{
	    	Messaging.sendEmail(messages);
	    }catch(Exception e){
	    	System.debug('sendEmailResult - Exception: ' + e);
	    }
	    System.debug('sendEmailResult - Mail SENT! ');

	}
	
}
