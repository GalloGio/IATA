global class BatchCreateCasesFromPWC implements Database.Batchable<WSCreateCasesFromPWC.SecurityCase>, Database.Stateful {

	private final Id CASE_RECORDTYPE_FSM = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Security_Monitoring');
	private final String ERROR_REQUEST_FILE = 'Request file has a problem, cannot be processed';
	
	private String jsonString;
	private BatchNumber__c batchNumber;
	private Attachment request;
	private responsePWC response;
	private EmailTemplateCustomHandler templateHandler;
	private set<String> setAIMSID;
	
	private DateTime period;
	
	global BatchCreateCasesFromPWC( String batchName ){
		this( batchName, DateTime.now().addMonths(-1).date() );
	}

	global BatchCreateCasesFromPWC( String batchName, Date period){
		this.period = period;
		this.templateHandler = new EmailTemplateCustomHandler();
		this.setAIMSID = new set<String>();
		
		//find batch process
		this.batchNumber = [ Select Id from BatchNumber__c where Name = :batchName ];
		if ( this.batchNumber == null ) {
			system.debug('ERROR - batch name called ' + batchName );
			return;
		}
		//find request file
		this.request = [ Select Id, Body 
			from Attachment 
			where parentId = :this.batchNumber.Id 
			and Name = :WSCreateCasesFromPWC.FILE_NAME_REQUEST
		];
		// remove any other response file if exists
		list<Attachment> listResponse = [select id from Attachment where parentId = :this.batchNumber.Id and Name = :WSCreateCasesFromPWC.FILE_NAME_RESPONSE ];
		if ( ! listResponse.isEmpty() ) {
			delete listResponse;
		}
		// initialize response variable
		this.response = new responsePWC();
		// prepare batchable context
		try {
			this.jsonString = this.request.body.toString();
		} catch ( Exception e ) {
			system.debug('ERROR - no input request file in batch. ' + e.getMessage() );
			setErrorResponseFile(ERROR_REQUEST_FILE);
		}
	}
	
	
	global List<WSCreateCasesFromPWC.SecurityCase> start(Database.BatchableContext BC){
		return (List<WSCreateCasesFromPWC.SecurityCase>) JSON.deserialize(this.jsonString, List<WSCreateCasesFromPWC.SecurityCase>.class);
	}

	global void execute(Database.BatchableContext BC, list<WSCreateCasesFromPWC.SecurityCase> scope){
		processScope(scope);
	}

	global void finish(Database.BatchableContext BC){
		setFinishedResponseFile();
	}
	
	public void setFinishedResponseFile() {
		String text = JSON.serialize( this.response );
		Attachment att = createAttachment( WSCreateCasesFromPWC.FILE_NAME_RESPONSE, this.batchNumber.Id, text );
		insert att;
	}
	
	public void processScope( list<WSCreateCasesFromPWC.SecurityCase> scope ) {
		// get cases to insert
		list<Case> listCase = createListCase(scope);
		
		// insert cases
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule = true;
		Database.SaveResult[] listResults = Database.insert(listCase, dmo);
		
		// add succesful cases to Json response
		for ( Case caseObj: [Select Id, Account.AIMS_ID__c, CaseNumber from Case where id in :listCase ] ) {
			this.response.addSuccess( caseObj );
		}
	}
	
	private list<Case> createListCase( list<WSCreateCasesFromPWC.SecurityCase> listSecurityCases ) {
		map<String,Account> mapAimsidAccount = getmapAimsidAccount(listSecurityCases);
		list<Case> listCase = new list<Case>();
		for ( WSCreateCasesFromPWC.SecurityCase securityCase: listSecurityCases ) {
			Account account = mapAimsidAccount.get( securityCase.AIMSID );
			
			if ( account == null ) {
				// if account doesnt exist append to temp file
				this.response.addError( securityCase.aimsId, 'Account not found');
			} else if ( account.Contacts.isEmpty()) {
				// If there is no contact attached to the account append error
				this.response.addError( securityCase.aimsId, 'Account found but hasn\'t Financial Assessment Contacts');
			} else if ( aimsidAlreadyInFile(securityCase.AIMSID) ) {
				// if the current aimsid is already in the same file send error
				this.response.addError( securityCase.aimsId, 'This AIMSID is already in the file');
			} else if ( caseAlreadyExists(account.Cases) ) {
				// if there is a case in the same account and in the same month we add an error
				this.response.addError( securityCase.aimsId, 'There is already a case for this month and for this account');
			} else {
				// Success
				Case newCase = createCase(securityCase, account);
				listCase.add( newCase );
			}
		}
		return listCase;
	}

	// is not allowed to insert more than one aimsid per file, this function checks it
	private Boolean aimsidAlreadyInFile( String aimsid ) {
		if ( this.setAIMSID.contains(aimsid) ) {
			return true;
		}
		this.setAIMSID.add( aimsid );
		return false;
	}
	
	// is not allowed to insert more than one case per aims id and month
	private Boolean caseAlreadyExists( list<Case> listCases ) {
		for ( Case caseObj: listCases ) {
			if ( caseObj.Reporting_date__c.toStartOfMonth() == this.period.date().toStartOfMonth() ) {
				return true;
			}
		}
		return false;
	}
	
	private map<String,Account> getmapAimsidAccount( list<WSCreateCasesFromPWC.SecurityCase> listSecurityCases ) {
		list<String> listAimsId = new list<String>();
		for ( WSCreateCasesFromPWC.SecurityCase securityCase: listSecurityCases ) {
			listAimsId.add( securityCase.AIMSID );
		}
		
		map<String,Account> mapAimsidAccount = new map<String,Account>();
		for ( Account account: [ Select Id, AIMS_ID__c, Region_formula__c, Country_ISO_Code__c, CCG_Participant__c, Guaranteed_amount__c, CurrencyISOCode, Industry, 
								(select id, Preferred_Language__c from Contacts where Financial_Assessment_Contact__c=:true),
								(select Id, isClosed, ParentId, Reporting_date__c from Cases where recordtypeId = :CASE_RECORDTYPE_FSM order by Reporting_date__c desc, createdDate desc )
								from Account where AIMS_ID__c in :listAimsId] ) {
			mapAimsidAccount.put( account.AIMS_ID__c, account );
		}
		return mapAimsidAccount;
	}
	
	private Case createCase( WSCreateCasesFromPWC.SecurityCase securityCase, Account account ) {
		Case newCase = new Case();
		newCase.RecordTypeId = CASE_RECORDTYPE_FSM;
		newCase.Reporting_date__c = this.period.date();
		newCase.Subject = account.Country_ISO_Code__c + '-FS_UPDATE-Sales_Monitoring-' + this.period.format('YYYY-MM'); 
		newCase.Description = 'Financial Security Monitoring ' + this.period.format('YYYY');
		newCase.ParentId = getParentId( account.Cases );
		newCase.ContactId = account.Contacts.isEmpty()?null:account.Contacts[0].Id;
		newCase.AccountId = account.Id;
		newCase.Region__c = account.Region_formula__c;
		//newCase.Status = 'Financial Statements Uploaded'; //going to be set to "Open" by default by the support process associated with the RT
		newCase.CCG_Participant__c = account.CCG_Participant__c;
		// get guaranteed amount from parent account but with currency conversted to case Currency
		newCase.Current_held_FS_amount__c = CurrencySingleton.getInstance().convertCurrency( account.Guaranteed_amount__c, account.CurrencyISOCode, securityCase.currencyISO );
		///newCase.Financial_Security_Amount__c = securityCase.Amount;
		///newCase.Financial_Security_Currency__c = securityCase.currencyISO;
		newCase.Financial_Security_Amount_2__c = securityCase.Amount;
		newCase.CurrencyISOCode = securityCase.currencyISO;
		//newCase.Expiry_Date_chkbx__c = securityCase.extractReason();
		newCase.Request_Expiry_Date__c = securityCase.extractExpiryDate();
		newCase.BatchNumber__c = this.batchNumber.Id;
		
		// find and set Email Template
		try {
			String country = account.Country_ISO_Code__c;
			//String language = account.Contacts[0].Preferred_Language__c; //DECOMMENT AND COMMENT NEXT LINE IF WANT TO USE CONTACT'S PREFEREDD LANGUAGE. NEED TO LOAD TEMPLATES IF USED! 
			string language = 'English';
			newCase.Reminder_EmailTemplate__c = this.templateHandler.getTemplateByCountryLang(country, language, account.Industry).Id;
		} catch ( Exception e ) {
			system.debug('set default template ' + newCase.Subject);
			newCase.Reminder_EmailTemplate__c = this.templateHandler.DEFAULT_FSM_TEMPLATE.Id;
		}
		return newCase;
	}
	
	// Complex retrieval of the parent case
	// input, list of FSM cases of the account
	// output, Id of the case that is the parent case, or null if not
	private Id getParentId( list<Case> listCase ) {
		Date periodMinusOneMonth = this.period.date().addMonths(-1);
		for ( Case caseObj: listCase ) {
			//If there is a case in the las 30 days this will be the parent case, or its parent
			if ( caseObj.Reporting_date__c >= periodMinusOneMonth ) {
				return (caseObj.ParentId == null)? caseObj.Id: caseObj.parentId;
				
			// if this is a further case but is opened, then do the same
			} else if ( caseObj.isClosed == false ) {
				return (caseObj.ParentId == null)? caseObj.Id: caseObj.parentId;
			}
		}
		return null;
	}
	
	private void setErrorResponseFile( String errorMsg ) {
		responsePWCError response = new responsePWCError('ERROR', errorMsg);
		Attachment att = createAttachment( WSCreateCasesFromPWC.FILE_NAME_RESPONSE, this.batchNumber.Id, JSON.serialize(response) );
		insert att;
	}
	
	private void setQueuedResponseFile() {
		responsePWCError response = new responsePWCError('IN_PROGRESS', '');
		Attachment att = createAttachment( WSCreateCasesFromPWC.FILE_NAME_RESPONSE, this.batchNumber.Id, JSON.serialize(response) );
		insert att;
	}
	
	private Attachment createAttachment( String filename, Id parentId, String data ) {
		Attachment att = new Attachment(
			Body = Blob.valueOf(data),
			Name = filename,
			parentId = parentId
		);
		return att;
	}
	
	//Classes for JSON answer definition
	public class responsePWCError  {
		public String status { get; set; }
		public String Msg { get; set; }
		
		public responsePWCError( String status, String errorMsg) {
			this.status = status;
			this.Msg = errorMsg;
		}
	}

	public class responsePWC {
		public String status { get; set; }
		public String Msg { get; set; }
		public list<ResponsePWCCase> ResultList { get; set; }
		
		public responsePWC() {
			this.status = 'FINISHED';
			this.Msg = '';
			this.ResultList = new list<ResponsePWCCase>();
		}
		
		public void addSuccess( Case caseObj ) {
			this.ResultList.add( new ResponsePWCCase('SUCCESS', caseObj.CaseNumber, caseObj.Account.AIMS_ID__c, '') );
		}
		
		public void addError( String aimsId, String errorMsg ) {
			this.ResultList.add( new ResponsePWCCase('ERROR', '', aimsId, errorMsg) );
		}
		public list<ResponsePWCCase> getList() {
			return ResultList;
		}
	}
	
	public virtual class ResponsePWCCase {
		public String AimsId { get; set; }
		public String Status { get; set; }
		public String CaseNumber { get; set; }
		public String Msg { get; set; }
		
		public ResponsePWCCase( String status, String caseNumber, String aimsId, String errorMsg ) {
			this.AimsId = aimsId;
			this.Status = status;
			this.CaseNumber = caseNumber;
			this.Msg = errorMsg;
		}
	}
	
}