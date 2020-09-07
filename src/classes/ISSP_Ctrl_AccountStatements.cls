@RestResource(urlMapping='/newgenapp/v1/iceGetBalances/*')
global class ISSP_Ctrl_AccountStatements {

	public static final String APP_NAME = 'ICE – IATA Customer E-Statement';
	public static final String AMAZON_ICE_PROOF_OF_PAYMENT = 'ICE POP';

	private static list<String> SELECT_FIELDS = new list<String>{
		'Id',
		'Period__c',
		'Operation__c',
		'Name',
		'Key__c',
		'CurrencyIsoCode',
		'Account__c',
		'Amount_to_be_Paid__c',
		'Balance__c',
		'Billing_Amount__c',
		'Paid__c',
		'Remittance_Date__c',
		'Status__c',
		'Billing_Adjustment__c',
		'Group__c',
		'Account__r.Site',
		'Account__r.IATAcode__c',
		'Account__r.Name',
		'Account__r.BillingCity',
		'LastModifiedDate'
	};

	/**
	 * Conditions to be used in main Account Statements queries to exclude remittance codes
	 * This list is retrieved from the custom metadata ISSP_ICE_Parameter__mdt
	 */
	public String conditionExcludeRemittance {
		get {
			if (conditionExcludeRemittance==null) {
				conditionExcludeRemittance = '';
				list<ISSP_ICE_Parameter__mdt> listParam = [SELECT Id, Value__c FROM ISSP_ICE_Parameter__mdt WHERE DeveloperName = 'Exclude_remittance_Codes' ];
				if (listParam.size()>0) {
					ISSP_ICE_Parameter__mdt param = listParam[0];
					for (String remmitance : param.Value__c.split(',')) {
						conditionExcludeRemittance += ' AND (NOT Period__c LIKE \'%' + remmitance + '\') ';
					}
				}
			}
			return conditionExcludeRemittance;
		}
		set;
	}

	/**
	 * Number of last remittance dates used to show data, retrieved from the custom metadata ISSP_ICE_Parameter__mdt
	 */
	public Integer nRowsDisplayed {
		get {
			if (nRowsDisplayed==null) {
				nRowsDisplayed = 4;
				list<ISSP_ICE_Parameter__mdt> listParam = [SELECT Id, Value__c FROM ISSP_ICE_Parameter__mdt WHERE DeveloperName = 'Displayed_Rows'];
				if (listParam.size()>0) {
					nRowsDisplayed = Integer.ValueOf(listParam[0].Value__c);
				}
			}
			return nRowsDisplayed;
		}
		set;
	}

	public Account account {get; set;}
	public Account headquarter {get; set;}
	public DateTime lastUpdatedOn {get; set;}
	public list<Account_Statement__c> listStatements {get; set;}
	public map<String,WrapperStatement> mapWrapper {get; set;}
	public list<WrapperStatement> listWrapper {get; set;}
	public list<String> listCurrency {get; set;}
	public list<String> listMessages {get; set;}
	public  User currentUser;
	public Portal_Application_Right__c appRight {get; set;}

	//variabbles for modals
	public String selectedKey {get;set;}
	public WrapperStatement selectedWrapperStatement {get;set;}
	public list<WrapperSummary> listWrapperSummary {get;set;}
	public list<WrapperLocation> listWrapperLocation {get;set;}
	public Boolean showAttachPopup {get; set;}
	public Boolean showDetailPopUp {get; set;}

	/**
	 * map to store currency formats based on the currency
	 */
	public map<String,String> mapCurrencyFormat {
		get{
			if (mapCurrencyFormat == null) {
				mapCurrencyFormat = new map<String,String>();
				for (CurrencyType currencyType : [SELECT id, IsoCode, DecimalPlaces FROM CurrencyType]) {
					mapCurrencyFormat.put(currencyType.IsoCode,'{0, number, ###,##0.' + '0'.repeat(currencyType.DecimalPlaces) + '}');
				}
			}
			return mapCurrencyFormat;
		}
		set;
	}

	/**
	 * Start actions, check rights and terms and conditions
	 */
	public PageReference initActions() {
		try {
			String strId = this.currentUser.ContactId;
			this.appRight = [
				Select Id, Terms_Acceptance__c, Terms_Acceptance_Date__c, Right__c, Enable_Notifications__c,
				ICCS_Currency_Center_Current_Visit__c, ICCS_Currency_Center_Previous_Visit__c
				From Portal_Application_Right__c
				Where ContactId__c = :strId.left(15)
				And Portal_Application__r.Name = :APP_NAME
			];
			// update visit Fields
			this.appRight.ICCS_Currency_Center_Previous_Visit__c = this.appRight.ICCS_Currency_Center_Current_Visit__c;
			this.appRight.ICCS_Currency_Center_Current_Visit__c = System.now();
			update this.appRight;
			// If user has no rights to access to Account statements app then is redirected to Home
			if (appRight.Right__c!='Access Granted') {
				Pagereference pageref = new PageReference('/ISSP_Homepage');
				pageref.setRedirect(true);
				return pageref;
			}
			// if terms and conditions are not accepted is redirected to Terms page
			if (!appRight.Terms_Acceptance__c) {
				Pagereference pageref = new PageReference('/ISSP_AccountStatement_Accept');
				pageref.setRedirect(true);
				return pageref;
			} else {
				return null;
			}
		} catch(Exception e) {
			//if error happens return to home page
		}
		Pagereference pageref = new PageReference('/ISSP_Homepage');
		pageref.setRedirect(true);
		return pageref;
	}

	public String getInstance() {
		return URL.getSalesforceBaseUrl().toExternalForm();
	}

	/**
	 * CONSTRUCTOR
	 */
	public ISSP_Ctrl_AccountStatements() {
		this.showAttachPopup = false;
		this.showDetailPopUp = false;
		this.listMessages = new list<String>();
		// get current user
		this.currentUser = [
			Select Id, ContactId,
				Contact.Name, Contact.AccountId,
				Contact.Account.Status__c,
				Contact.Account.Sector__c,
				Contact.Account.Country_ISO_Code__c,
				Contact.Account.Id,
				Contact.Account.Name,
				Contact.Account.IATACode__c,
				Contact.Account.Top_Parent__c,
				Contact.Account.Top_Parent__r.IATACode__c,
				Contact.Account.Top_Parent__r.Name
			From User
			Where id = :UserInfo.getUserId()];

		// check account status before doing anything to allow or reject access to info
		if (this.currentUser.Contact.Account.Status__c != 'Approved' &&
			this.currentUser.Contact.Account.Status__c != 'Changes Processed' &&
			this.currentUser.Contact.Account.Status__c != 'Listed') {
			this.listMessages.add(Label.ISSP_Account_not_approved);
			return;
		}

		// get HQ account
		this.account = this.currentUser.Contact.Account;
		list<Account> listAccount = getAllHierarchy(this.currentUser.Contact.Account);
		this.headquarter = this.account.Top_Parent__r == null? this.account: this.account.Top_Parent__r;
		
		// get Account Statements related with all accounts in the hierarchy
		Date minimumRemittance = getMinimumRemittanceDateToSearch(listAccount);
		String query = ' SELECT ' + String.join(SELECT_FIELDS,',') +
			' FROM Account_Statement__c' +
			' WHERE Account__c IN :listAccount' +
			' AND Remittance_Date__c >= ' + String.ValueOf(minimumRemittance) +
			ConditionExcludeRemittance +
			' ORDER BY Remittance_Date__c desc, Operation__c ASC';

		this.listStatements = Database.query(query);

		// create a list of wrappers with collected Account Statements
		this.mapWrapper = new map<String,WrapperStatement>();
		this.lastUpdatedOn = Datetime.newInstance(1900, 1, 1);
		for (Account_Statement__c statement: this.listStatements) {
			String key = statement.Period__c + statement.Group__c + statement.CurrencyIsoCode;
			WrapperStatement wrapper = mapWrapper.get(key);
			if (wrapper == null) {
				wrapper = new WrapperStatement(statement);
				mapWrapper.put(key, wrapper);
			} else {
				wrapper.addStatement(statement);
			}
			this.lastUpdatedOn = this.lastUpdatedOn<statement.LastModifiedDate? statement.LastModifiedDate: this.lastUpdatedOn;
		}

		// Assing operational calendars to Wraper Statements
		map<String,Operational_Calendar__c> mapCalendars = getCalendarsPerKey(this.listStatements);
		this.listWrapper = new list<WrapperStatement>();
		for (WrapperStatement wrapper: mapWrapper.values() ) {
			String key = wrapper.parent.Operation__c + '_' + wrapper.parent.Period__c;
			wrapper.calendar = mapCalendars.get(key);
		}

		// Sort map per key
		this.listWrapper = new list<WrapperStatement>();
		for (String period: mapWrapper.keyset() ) {
			WrapperStatement wrapper = mapWrapper.get(period);
			this.listWrapper.add(wrapper);
		}
		this.listWrapper.sort();
		initListCurrency();
	}

	/**
	 * Set all related Operational calendars to wrapper Statements list
	 */
	private map<String,Operational_Calendar__c> getCalendarsPerKey(list<Account_Statement__c> listStatements) {
		// find calendar keys in input Statements
		map<String,Operational_Calendar__c> mapCalendars = new map<String,Operational_Calendar__c>();
		for (Account_Statement__c statement: listStatements) {
			String key = statement.Operation__c + '_' + statement.Period__c;
			mapCalendars.put(key, null);
		}
		// populate the returning map with each calendar per key
		for (Operational_Calendar__c calendar:
				[SELECT Id, Settlement_Day__c, ExternalId__c
				FROM Operational_Calendar__c
				WHERE RecordType.DeveloperName = 'ISS_Calendar'
				AND ExternalId__c IN :mapCalendars.keyset()]) {
			mapCalendars.put(calendar.ExternalId__c, calendar);
		}
		return mapCalendars;
	}

	/**
	 * Get method for NewGenAPP mobile
	 */
	@HttpGet
	global static List <WrapperStatement> doGet(){
		ISSP_Ctrl_AccountStatements acc = new ISSP_Ctrl_AccountStatements();

		if(acc.listWrapper != null && !acc.listWrapper.isEmpty()){
			String disclaimer = Label.ISSP_Account_Statements_Disclaimer;

			if(acc.account.Country_ISO_Code__c == 'CN' && acc.account.Sector__c == 'Travel Agent'){
				disclaimer += Label.ISSP_Account_Statements_Disclaimer_China_TravelAgent;
			}

			for(WrapperStatement wrapper : acc.listWrapper){
				wrapper.disclaimer = disclaimer;
				wrapper.listCurrency = acc.listCurrency;
				wrapper.location = Label.ISSP_Account_Statement_Location;
			}
		}

		return acc.listWrapper;
	}

	/**
	 * Find the lowest remitance date in last valid periods
	 */
	private Date getMinimumRemittanceDateToSearch(list<Account> listAccount) {
		try {
			String query =
				'SELECT Remittance_Date__c ' +
				' FROM Account_Statement__c ' +
				' WHERE Account__c IN :listAccount' +
				' AND Remittance_Date__c <= TODAY ' +
				ConditionExcludeRemittance +
				' GROUP BY Remittance_Date__c ' +
				' ORDER BY Remittance_Date__c DESC ' +
				' LIMIT ' + nRowsDisplayed; // search last n Remittance dates

			list<AggregateResult> listResult = Database.query(query);
			AggregateResult ar = listResult.get( listResult.size()-1 );
			return (Date)ar.get('Remittance_Date__c');
		} catch (Exception e) {
			return Date.today();
		}
	}

	/**
	 * Populate list of available currencies
	 */
	private void initListCurrency() {
		set<String> setCurrency = new set<String>();
		for(WrapperStatement wrapper: this.listWrapper) {
			setCurrency.add(wrapper.parent.CurrencyIsoCode);
		}
		this.listCurrency = new list<String>(setCurrency);
	}

	/**
	 * Get a list containing all account in the input account hirarchy
	 */
	private list<Account> getAllHierarchy(Account account) {
		Id topParentId = account.Top_Parent__c == null? account.Id: account.Top_Parent__c;
		return [
			Select id, Name, ParentId
			From Account
			Where Id =:topParentId
			Or Top_Parent__c = :topParentId
		];
	}

	/**
	 * Update the app right record when the switch for Remittance Date Reminders is modified
	 */
	public Pagereference updateAppRight() {
		try {
			update this.appRight;
		} catch (Exception e) {}
		return null;
	}

	/**
	 * Method to Show attachments Popup
	 */
	public void showAttachModalPopup() {
		this.selectedWrapperStatement = this.mapWrapper.get(this.selectedKey);
		this.showAttachPopup = this.selectedWrapperStatement!=null;
	}

	/**
	 * Show detail Information in Popup
	 */
	public void showDetailModalPopup() {
		this.selectedWrapperStatement = this.mapWrapper.get(this.selectedKey);
		this.showDetailPopUp = this.selectedWrapperStatement!=null;
		if(this.showDetailPopUp){
			//query transactions
			list<Account_Statement_Transaction__c> listTransaction = [
				SELECT Id, Internal_Type__c, Amount__c, Value_Date__c, Details__c, Is_Payment__c,
					Parent__c, Parent__r.CurrencyIsoCode,
					Parent__r.Account__r.IATAcode__c, Parent__r.Account__r.BillingCity
				FROM Account_Statement_Transaction__c
				WHERE Parent__c IN :selectedWrapperStatement.listStatements
				ORDER BY Value_Date__c DESC];

			//populate map for Summary Tab 
			map<String,WrapperSummary> mapWrapperSummary = new map<String,WrapperSummary>();
			for (Account_Statement_Transaction__c trans: listTransaction) {
				String key = trans.Internal_Type__c;
				WrapperSummary wrapperSummary = mapWrapperSummary.get(key);
				if (wrapperSummary==null) {
					wrapperSummary = new wrapperSummary(key);
				}
				wrapperSummary.addTransaction(trans);
				mapWrapperSummary.put(key, wrapperSummary);
			}
			this.listWrapperSummary = mapWrapperSummary.values();

			//populate map for Location Tab 
			map<String,WrapperLocation> mapWrapperLocation = new map<String,WrapperLocation>();
			for (Account_Statement_Transaction__c trans: listTransaction) {
				String key = trans.Parent__r.Account__r.IATAcode__c;
				WrapperLocation wrapperLocation = mapWrapperLocation.get(key);
				if (wrapperLocation==null) {
					wrapperLocation = new wrapperLocation(trans.Parent__r);
				}
				wrapperLocation.addTransaction(trans);
				mapWrapperLocation.put(key, wrapperLocation);
			}
			this.listWrapperLocation = mapWrapperLocation.values();
		}
	}

	/**
	 * Wrapper to create the table Summary
	 */
	global class WrapperSummary {
		global String ref {get;set;}
		global String item {get;set;}
		global Decimal billing {get;set;}
		global Decimal payment {get;set;}
		global list<Account_Statement_Transaction__c> listTransaction {get;set;}

		public WrapperSummary(String item) {
			this.ref = item.replaceAll(' ', '-');
			this.item = item;
			this.billing = 0;
			this.payment = 0;
			this.listTransaction = new list<Account_Statement_Transaction__c>();
		}

		public void addTransaction(Account_Statement_Transaction__c trans) {
			this.listTransaction.add(trans);
			if (trans.Is_Payment__c) {
				this.payment+= trans.Amount__c;
			} else {
				this.billing+= trans.Amount__c;
			}
		}
	}

	/**
	 * Wrapper to create the table Per Location
	 */
	global class WrapperLocation {
		global String code {get;set;}
		global String location {get;set;}
		global Decimal billing {get;set;}
		global Decimal payment {get;set;}
		global String isoCode {get;set;}
		global list<Account_Statement_Transaction__c> listTransaction {get;set;}

		public WrapperLocation(Account_Statement__c statement) {
			this.code = statement.Account__r.IATAcode__c;
			this.location = statement.Account__r.BillingCity;
			this.billing = 0;
			this.payment = 0;
			this.isoCode = statement.CurrencyIsoCode;
			this.listTransaction = new list<Account_Statement_Transaction__c>();
		}

		public void addTransaction(Account_Statement_Transaction__c trans) {
			this.listTransaction.add(trans);
			if (trans.Is_Payment__c) {
				this.payment+= trans.Amount__c;
			} else {
				this.billing+= trans.Amount__c;
			}
		}
	}

	/**
	 * Class to close attachmenst Popup
	 */
	public void closeAttachModalPopup() {
		this.showAttachPopup =false ;
	}

	/**
	 * Close Detail Popup
	 */
	public void closeDetailModalPopup() {
		this.showDetailPopUp = false ;
	}

	/**
	 * Class to store a list of Account Statements and the sumarized data
	 */
	global class WrapperStatement implements Comparable {
		global String key {get;set;}
		global Account_Statement__c parent {get;set;}
		global list<Account_Statement__c> listStatements {get; set;}
		global String disclaimer { get; set; }
		global List <String> listCurrency {get; set;}
		global String location { get; set;}
		global Operational_Calendar__c calendar {get; set;}

		global WrapperStatement(Account_Statement__c statement) {
			this.key = statement.Period__c + statement.Group__c + statement.CurrencyIsoCode;
			this.parent = statement.clone();
			this.parent.Amount_to_be_Paid__c = nvl(this.parent.Amount_to_be_Paid__c);
			this.parent.Billing_Amount__c = nvl(this.parent.Billing_Amount__c);
			this.parent.Paid__c = nvl(this.parent.Paid__c);
			this.parent.Balance__c = nvl(this.parent.Balance__c);
			this.listStatements = new list<Account_Statement__c>();
			this.listStatements.add(statement);
			this.calendar = null;
		}

		/**
		 * Add a new statement in current statements list
		 */
		public void addStatement(Account_Statement__c statement) {
			this.listStatements.add(statement);
			this.parent.Amount_to_be_Paid__c += nvl(statement.Amount_to_be_Paid__c);
			this.parent.Billing_Amount__c += nvl(statement.Billing_Amount__c);
			this.parent.Paid__c += nvl(statement.Paid__c);
			this.parent.Balance__c += nvl(statement.Balance__c);
			this.parent.Group__c = statement.Group__c;
		}

		/**
		 * Get current status for parent statement
		 */
		public String getParentStatus() {
			if (this.parent.Balance__c == 0 ) {
				return 'Fullpayment';
			}
			if (this.parent.Balance__c > 0 ) {
				return 'Pending';
			}
			return 'Excess';
		}

		/**
		 * Used to show or hide the attachment button, only required when a proof of payment is needed
		 */
		public Boolean getShowPaymentProof() {
			return ( this.parent.Balance__c > 0 );
		}

		/**
		 * USed to show or hide settlement info icon
		 */
		public Boolean getShowSettlementInfo() {
			return ( this.parent.Billing_Amount__c < 0
				&& this.calendar != null && this.calendar.Settlement_Day__c != null);
		}

		public Integer compareTo(Object compareTo) {
			return this.parent.Period__c > ((WrapperStatement)compareTo).parent.Period__c? -1: 1;
		}

		/**
		 * Returns the full Amazon file
		 */
		public String getAmazonFileName() {
			String period = this.parent.Period__c;
			Decimal billingAmount = this.parent.Billing_Amount__c;
			return AMAZON_ICE_PROOF_OF_PAYMENT + ' ' + period + ' ' + billingAmount;
		}
	}

	/**
		Helper method for null values
	 */
	private static Decimal nvl(Decimal value) {
		return value==null? 0: value;
	}
}
