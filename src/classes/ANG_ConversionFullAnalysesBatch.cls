global class ANG_ConversionFullAnalysesBatch implements Database.Batchable<sObject> , Database.Stateful{
	
	String query;

	global List<ANG_ConversionHelper.HierarchyStructure> structures;

	global Integer run;

	global List<Account> totalAccounts;
	
	global List<String> columnsCSV;

	global String errorsFound;

	global String country;

	global Map<Id,Contact> contactGlobal;

	global ANG_ConversionFullAnalysesBatch(List<ANG_ConversionHelper.HierarchyStructure> structuresToMigrate, String countryIn) {
		
		ANG_ConversionHelper.isMigrationToolAnalyses=true;

		this.structures = structuresToMigrate;

		this.country = countryIn;

		Integer queryResults = structures.size();

		this.query = 'SELECT Id from Account LIMIT ' + queryResults;
		
		this.run = -1;

		totalAccounts = new List<Account>();

		columnsCSV = new List<String>{'Salesforce ID','IATA Code','Agency Name','Location Type','Location Class','Status','Contact Name','Contact Email','Risk Status','Cash Conditions','Risk History Assessment','Last Financial Review Result','RHC Amount','Current FS','BSP Currency'};

		errorsFound = '';

		contactGlobal = new Map<Id,Contact>();
	}	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		try{

   			this.run++;

   			ANG_ConversionHelper.isMigrationToolAnalyses=true;

	   		Set<Id> accounts = new Set<Id>();

	   		List<ANG_ConversionHelper.HierarchyStructure> structs = new List<ANG_ConversionHelper.HierarchyStructure>();

	   		structs.add(structures.get(this.run));

			Map<Id,List<Account>> allAgenciesMap = ANG_ConversionHelper.fetchAllAgenciesInvolved(structs);

			Map<Id,AMS_Agencies_Hierarchy__c> allHierarchiesInvolvedMap = ANG_ConversionHelper.fetchAllHierarchiesInvolved(structs);

			Set<Account> allAgencies = new Set<Account>();
			allAgencies.addAll(allAgenciesMap.get(structs.get(0).hierarchyId));

			Map<Id,Account> allAgenciesFinalMap = new Map<Id,Account>();

			for(Account acct: allAgencies)
				allAgenciesFinalMap.put(acct.Id,acct);

			AMS_Agencies_Hierarchy__c hierarchy = allHierarchiesInvolvedMap.get(structs.get(0).hierarchyId);

			ANG_ConversionHelper.MigrationContainer container = ANG_ConversionHelper.changeStructure(structs.get(0),allAgenciesFinalMap,hierarchy);

			//System.debug('container.accountsToUpdate is:' + container.accountsToUpdate);

			// the list of all changed accounts
			Set<Account> accountsToUpdate = container.accountsToUpdate;

			ANG_RiskEventMigrationHelper.getRiskForecast(accountsToUpdate);

			for(Account acct: accountsToUpdate){

				accounts.add(acct.Id);
				
				if(acct.Location_Type__c == AMS_Utils.HE)
					totalAccounts.add(acct);
					
			}

			List<Contact> contact = [Select Id, Email, Name, User_Portal_Status__c from Contact where accountId in : accounts and User_Portal_Status__c = 'Approved Admin' LIMIT 1 ];

			if(!contact.isEmpty()){
				List<Account> accountsToUpdateLst = new List<Account>();
				accountsToUpdateLst.addAll(accountsToUpdate);
				contactGlobal.put(accountsToUpdateLst.get(0).Top_Parent__c != null ? accountsToUpdateLst.get(0).Top_Parent__c : accountsToUpdateLst.get(0).Id, contact.get(0));
			}

			if(Limits.getDMLStatements() > 0)
				throw new AMS_ApplicationException('There are DML actions being made (' +Limits.getDMLStatements()+'), since this is a report only, please contact the admin.');

		}catch(Exception e){

			errorsFound += 'Error for Hierarchy ' + structures.get(this.run).topParentId + ':' + e.getStackTraceString();
			errorsFound += '\n';

			throw e;
		}

		//public static Map<Account, Map<String, Integer>> getRiskForecast(Set<Account> accountsInTheHierarchy) ANG_RiskEventMigrationHelper
	}
	
	global void finish(Database.BatchableContext BC) {

		String csvFile = '';
		
		try{

			for(String column:columnsCSV){
				csvFile += '"'+column+'"' + ',';
			}

			csvFile.removeEnd(',');
			csvFile+='\n';

			Decimal rhcAmt = null;
			Decimal currentFS = null;
			String contactEmail = null;
			String contactName = null;
			String currencyCode = null;

			For(Account acct:totalAccounts){

				csvFile+= '"' + unNullify(acct.Id) + '"' + ',';
				csvFile+= '"' + unNullify(acct.IATACode__c) + '"' + ',';
				csvFile+= '"' + unNullify(acct.Name) + '"' + ',';
				csvFile+= '"' + unNullify(acct.Location_Type__c) + '"' + ',';
				csvFile+= '"' + unNullify(acct.Location_Class__c) + '"' + ',';
				csvFile+= '"' + unNullify(acct.Status__c) + '"' + ',';
				
				contactEmail = null;
				contactName = null;

			/*
				if(!acct.Contacts.isEmpty()){
					contactEmail = acct.Contacts.get(0).Email;
					contactName = acct.Contacts.get(0).Name;
				}
			*/

				if(contactGlobal.get(acct.id) != null){

					contactEmail = contactGlobal.get(acct.id).Email;
					contactName = contactGlobal.get(acct.id).Name;
				}


				csvFile+= '"' + unNullify(contactName) + '"' + ',';
				csvFile+= '"' + unNullify(contactEmail) + '"' + ',';

				csvFile+= '"' + unNullify(acct.ANG_HE_RiskStatus__c) + '"' + ',';
				csvFile+= '"' + unNullify(acct.ANG_HE_CashCondition__c) + '"' + ',';
				csvFile+= '"' + unNullify(acct.ANG_HE_RiskHistoryAssessment__c) + '"' + ',';
				csvFile+= '"' + unNullify(acct.Financial_Review_Result__c) + '"' + ',';

				rhcAmt = null;
				currentFS = null;
				currencyCode = null;

				if(!acct.RHC_Informations__r.isEmpty()){

					if(acct.RHC_Informations__r.get(0).ANG_RHC_Amount__c != null)
						rhcAmt = acct.RHC_Informations__r.get(0).ANG_RHC_Amount__c;

					if(acct.RHC_Informations__r.get(0).ANG_Financial_Security__c != null)
						currentFS = acct.RHC_Informations__r.get(0).ANG_Financial_Security__c;

					currencyCode = acct.IATA_ISO_Country__r.CurrencyIsoCode;

				}else{

						currentFS = acct.Guaranteed_amount__c; // USD
						rhcAmt = null;
						currencyCode = acct.IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode;

				}

				csvFile+= '"' + unNullify(rhcAmt) + '"' + ',';
				csvFile+= '"' + unNullify(currentFS) + '"' + ',';
				csvFile+= '"' + unNullify(currencyCode) + '"';
				csvFile+='\n';
			}

		}catch(Exception e){
			csvFile = 'Error Occured:' + e.getStackTraceString();
			csvFile = String.valueOf(e.getCause());
		}

		Blob csvBlob;

		if(csvFile == '')
			csvBlob = Blob.valueOf('No agencies were found to migrate.');
		else
			csvBlob = Blob.valueOf(csvFile);

		String csvName = String.valueOf(Date.today())+'_'+'ConversionReport_' + country +'.csv';

		Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();

		csvAttachment.setFilename(csvName);
		csvAttachment.setBody(csvBlob);

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		String[] toAddress = new List<String>{'goncalvesd@iata.org',UserInfo.getUserEmail()};

		String subject = 'Conversion Report for ' + country;

		email.setSubject(subject);
		email.setToAddresses(toAddress);
		email.setPlainTextBody('Conversion Report for '  + country + ' in attachment. \n\n\n ' + errorsFound);

		email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});

		if(!Test.isRunningTest())
			Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});


	}

	private static String unNullify(Object o){
		if(o == null)
			return '';

		return String.valueOf(o);	
	}
	
}