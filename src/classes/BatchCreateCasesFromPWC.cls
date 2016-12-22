global class BatchCreateCasesFromPWC implements Database.Batchable<WSCreateCasesFromPWC.SecurityCase>, Database.Stateful {

	private final Id CASE_RECORDTYPE_FSM = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Security Monitoring');
	private final String ERROR_REQUEST_FILE = 'Request file has a problem, cannot be processed';

	private String jsonString;
	private BatchNumber__c batchNumber;
	private Attachment request;
	private responsePWC response;
	private EmailTemplateCustomHandler templateHandler;
	private set<String> setIATA_code;

	private DateTime period;

	global BatchCreateCasesFromPWC( String batchName ){
		this( batchName, DateTime.now().addMonths(-1).date() );
	}

	global BatchCreateCasesFromPWC( String batchName, Date period){
		this.period = period;
		this.templateHandler = new EmailTemplateCustomHandler();
		this.setIATA_code = new set<String>();

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
		for ( Case caseObj: [Select Id, Account.IATACode__c, CaseNumber from Case where id in :listCase ] ) {
			this.response.addSuccess( caseObj );
		}
	}

	private list<Case> createListCase( list<WSCreateCasesFromPWC.SecurityCase> listSecurityCases ) {
		map<String,Account> mapIATA_codeAccount = getmapIATA_codeAccount(listSecurityCases);
		list<Case> listCase = new list<Case>();
		for ( WSCreateCasesFromPWC.SecurityCase securityCase: listSecurityCases ) {
			Account account = mapIATA_codeAccount.get( securityCase.IATA_code );

			if ( account == null ) {
				// if account doesnt exist append to temp file
				this.response.addError( securityCase.IATA_code, 'Account not found');
			} else if ( account.Contacts.isEmpty()) {
				// If there is no contact attached to the account append error
				this.response.addError( securityCase.IATA_code, 'Account found but hasn\'t Financial Assessment Contacts');
			} else if ( IATA_codeAlreadyInFile(securityCase.IATA_code) ) {
				// if the current IATA_code is already in the same file send error
				this.response.addError( securityCase.IATA_code, 'This IATA_code is already in the file');
			} else if ( caseAlreadyExists(account.Cases) ) {
				// if there is a case in the same account and in the same month we add an error
				this.response.addError( securityCase.IATA_code, 'There is already a case for this month and for this account');
			} else {
				// Success
				Case newCase = createCase(securityCase, account);
				listCase.add( newCase );
			}
		}
		return listCase;
	}

	// is not allowed to insert more than one IATA_code per file, this function checks it
	private Boolean IATA_codeAlreadyInFile( String IATA_code ) {
		if ( this.setIATA_code.contains(IATA_code) ) {
			return true;
		}
		this.setIATA_code.add( IATA_code );
		return false;
	}

	// is not allowed to insert more than one case per IATA code and month
	private Boolean caseAlreadyExists( list<Case> listCases ) {
		for ( Case caseObj: listCases ) {
			if ( caseObj.Reporting_date__c.toStartOfMonth() == this.period.date().toStartOfMonth() ) {
				return true;
			}
		}
		return false;
	}

	private map<String,Account> getmapIATA_codeAccount( list<WSCreateCasesFromPWC.SecurityCase> listSecurityCases ) {
		list<String> listIATA_code = new list<String>();
		for ( WSCreateCasesFromPWC.SecurityCase securityCase: listSecurityCases ) {
			listIATA_code.add( securityCase.IATA_code );
		}

		map<String,Account> mapIATA_codeAccount = new map<String,Account>();
		for ( Account account: [ Select Id, IATACode__c, Region_formula__c, Country_ISO_Code__c, CCG_Participant__c, Guaranteed_amount__c, CurrencyISOCode, Industry,
								(select id, Preferred_Language__c from Contacts where Financial_Assessment_Contact__c=:true),
								(select Id, isClosed, ParentId, Reporting_date__c from Cases where recordtypeId = :CASE_RECORDTYPE_FSM order by Reporting_date__c desc, createdDate desc )
								from Account where IATACode__c in :listIATA_code] ) {
			mapIATA_codeAccount.put( account.IATACode__c, account );
		}
		return mapIATA_codeAccount;
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
			this.ResultList.add( new ResponsePWCCase('SUCCESS', caseObj.CaseNumber, caseObj.Account.IATACode__c, '') );
		}

		public void addError( String IATA_code, String errorMsg ) {
			this.ResultList.add( new ResponsePWCCase('ERROR', '', IATA_code, errorMsg) );
		}
		public list<ResponsePWCCase> getList() {
			return ResultList;
		}
	}

	public virtual class ResponsePWCCase {
		public String IATA_code { get; set; }
		public String Status { get; set; }
		public String CaseNumber { get; set; }
		public String Msg { get; set; }

		public ResponsePWCCase( String status, String caseNumber, String IATA_code, String errorMsg ) {
			this.IATA_code = IATA_code;
			this.Status = status;
			this.CaseNumber = caseNumber;
			this.Msg = errorMsg;
		}
	}

}
