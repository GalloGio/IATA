public class AMS_CertificateManagerController {

	// *****************************
	// ********** variables ********
	// *****************************

	private Set<Schema.SObjectField> accountFields{
		get{
			return new Set<Schema.SObjectField>{
				Account.Certificate_Generated_Current_Year__c,
				Account.Name,
				Account.IATACode__c
			};
		}
	}

	private List<String> accountFieldList{
		get{
			List<String> fieldList = new List<String>();
			for(Schema.SObjectField field : accountFields) fieldList.add(field.getDescribe().getName());
			return fieldList;
		}
	}

	public List<String> noteList{
		get{
			return new List<String>{
				'If your file has the headers on the first line, make the the IATA Code header is "IATA Code"',
				'If your file dosn\'t have headers, the IATA Code must be on the first column',
				'The csv values must be separated by commas (,). Make sure your editor don\'t make the separation by semi-colons  (;)',
				'Your file must contain only headers and records, remove any other information (Example: Copyright and confidentiality)',
				'Your file must NOT contain multi-line text field (rich text, text area or long text area)'
			};
		}
	}

	public String year {
		get{
			if(year == null) year = String.valueOf(System.today().year());
			return year;
		} 
		set;
	}

	public List<SelectOption> years{
		get{
			if(years == null){
				years = new List<SelectOption>();
				Integer noOptions = 7;
				Integer start = System.today().addYears(-2).year();
				for(Integer i = 0; i <= noOptions; i++){
					String y = String.valueOf(start+i);
					years.add(new SelectOption(y, y));
				}
				years.add(new SelectOption('Other', 'Other'));
			}
			return years;
		}
		set;
	}

	public Boolean showWarning{
		get{
			if(showWarning == null) showWarning = false;
			return showWarning;
		}
		set;
	}

	public Boolean ignoreWarning{
		get{
			if(ignoreWarning == null) ignoreWarning = false;
			return ignoreWarning;
		}
		set;
	}

	public Boolean parsedFile{
		get{
			return !accountIds.isEmpty();
		}
	}

	public Set<Id> accountIds{
		get{
			if(accountIds == null) accountIds = new Set<Id>();
			return accountIds;
		}
		set;
	}

	public AsyncApexJob job{
		get{
			if(requestCreation != null) job = [SELECT Status, NumberOfErrors, ExtendedStatus FROM AsyncApexJob WHERE Id = :requestCreation];
			return job;
		}
		set;
	}

	public Set<Id> reqIds{
		get{
			if(reqIds == null) reqIds = new Set<Id>();
			return reqIds;
		}
		set;
	}

	public List<AMS_Certificate_Request__c> requests{
		get{
			return [SELECT Id, Name, (SELECT Id, Name FROM Attachments) FROM AMS_Certificate_Request__c WHERE Id IN :reqids];
		}
	}
	
	public Blob fileBody { get; set; }
	public Id requestCreation { get; set; }
	public String yearText { get; set; }


	// *****************************
	// ********** methods ********
	// *****************************

	public void parseFile() {
		if(fileBody == null){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please, select a file'));
			return;
		}

		String body = fileBody.toString();
		String newLine = '\n';
		if(body.indexOf('\r\n') > 0) newLine = '\r\n';
		else if(body.indexOf('\r') > 0) newLine = '\r';

		//System.debug(loggingLevel.Debug, '____ [cls AMS_CertificateManagerController - parseFile] body - ' + body);
		System.debug(loggingLevel.Debug, '____ [cls AMS_CertificateManagerController - parseFile] newLine - ' + newLine.replace('\r', 'r').replace('\n','n'));
		List<String> lines = body.split(newLine);

		if(lines.isEmpty()){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No content on the file'));
			return;
		}

		Integer iataCodeIndex = 0;
		Boolean hasHeaders = false;
		List<String> headers = lines[0].split(',');

		System.debug(loggingLevel.Debug, '____ [cls AMS_CertificateManagerController - parseFile] headers - ' + headers);
		for(Integer i = 0; i < headers.size(); i++){
			if(headers[i].removeEnd('"').removeStart('"').trim().equalsIgnoreCase('IATA Code')){
				iataCodeIndex = i;
				hasHeaders = true;
				break;
			}
		}

		System.debug(loggingLevel.Debug, '____ [cls AMS_CertificateManagerController - parseFile] iataCodeIndex - ' + iataCodeIndex);

		Map<String, Boolean> iataCodes = new Map<String, Boolean>();
		for(String line : lines){
			if(hasHeaders) hasHeaders = false; //skips first line if is a header
			else{
				List<String> entries = line.split(',');

				System.debug(loggingLevel.Debug, '____ [cls AMS_CertificateManagerController - parseFile] entries - ' + entries);
				iataCodes.put(entries[iataCodeIndex].removeEnd('"').removeStart('"').trim(), false);
			}
		}

		System.debug(loggingLevel.Debug, '____ [cls AMS_CertificateManagerController - parseFile] iataCodes - ' + iataCodes);

		Set<String> iataCodesSet = iataCodes.keySet();
		List<Account> accounts = Database.query('SELECT Id, '+String.join(accountFieldList, ', ')+' FROM Account WHERE recordtype.developername= \'Iata_Agency\' and IataCode__c IN :iataCodesSet order by iata_iso_country__r.name, Name');


		List<Account> warnings = new List<Account>();
		if(accounts.isEmpty()){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No accounts found. Check the formating of the file'));
			return;
		}else{
			for(Account acc : accounts){
				accountIds.add(acc.Id);
				iataCodes.put(acc.IATACode__c, true);
				if(acc.Certificate_Generated_Current_Year__c) warnings.add(acc);
			}
		}

		if(!warnings.isEmpty()){
			showWarning = true;
			String warning = 'The following accounts already received the certificate for the current year: ';
			for(Account acc : warnings) warning += '<br/>- '+acc.Name+' ('+acc.IATACode__c+')';

			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, warning));
		}


		String iataCodewarning = 'The following iata codes on the file were not found on the database: ';
		String errorCodes = '';
		for(String iataCode : iataCodes.keySet()) if(!iataCodes.get(iataCode)) errorCodes += '<br/>- '+iataCode;

		if(String.isNotEmpty(errorCodes)) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, iataCodewarning+errorCodes));
	}

	public void generateCertificates() {
		List<Set<Id>> requestsToCreate = new List<Set<Id>>();
		Set<Id> singleRequest = new Set<Id>();
		for(Id accountId : accountIds){
			singleRequest.add(accountId);

			if(singleRequest.size() == 2000){
				requestsToCreate.add(singleRequest.clone());
				singleRequest.clear();
			}
		}
		requestsToCreate.add(singleRequest.clone());

		List<AMS_Certificate_Request__c> requestsToInsert = new List<AMS_Certificate_Request__c>();
		for(Set<Id> accounts : requestsToCreate){
			AMS_Certificate_Request__c request = new AMS_Certificate_Request__c();
			request.AccountIds__c = JSON.serializePretty(accounts);
			requestsToInsert.add(request);
		}
		insert requestsToInsert;
		reqIds = new Map<Id, AMS_Certificate_Request__c>(requestsToInsert).keySet();
		
		requestCreation = System.enqueueJob(new AMS_CertificateHelper.CertificateCreation(requests, (year == 'Other' ? yearText : year), UserInfo.getUserEmail()));

		updateAccounts(accountIds);
	}

	@future
		private static void updateAccounts(Set<Id> accountIds) {
		Map<Id, Account> accounts = new Map<Id, Account>();
		for(Account a : Database.query('SELECT Id,Certificate_Generated_Current_Year__c, Name, IATACode__c FROM Account WHERE Id IN :accountIds')){
			if(!a.Certificate_Generated_Current_Year__c){
				a.Certificate_Generated_Current_Year__c = true;
				accounts.put(a.Id, a);
			}
		}

		if(accounts.size() > (Limits.getLimitDMLRows() - Limits.getDMLRows())) Database.executeBatch(new AMS_UpdateCertificateCampaign(accounts.keySet()));
		else{
			update accounts.values();
		}
	}

}