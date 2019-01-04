@RestResource(urlMapping='/newgenapp/v1/iceGetBalances/*')
global class ISSP_Ctrl_AccountStatements {

	public static final String APP_NAME = 'ICE – IATA Customer E-Statement';

	public ContentVersion faq {get;set;}
	public ContentVersion document {get;set;}
	public Account account {get; set;}
    public Account headofficeAccount {get; set;}
	public DateTime lastUpdatedOn {get; set;}
	public list<Account_Statement__c> listStatements {get; set;}
	public list<WrapperStatement> listWrapper {get; set;}
    public list<String> listCurrency {get; set;}
	public list<String> listMessages {get; set;}
	private User currentUser;
    public Portal_Application_Right__c appRight {get; set;}
	public String accountSelectedId {get; set;}
	public String accountStatementSelectedId {get; set;}
	public String accountSelectedName {get; set;}
	public String accountStatementPeriod {get; set;}
	public String billingAmount {get; set;}
	public String amazonFileName {get; set;}
	public Boolean showPopUp {get; set;}
	public List<AmazonFile__c> listAttachments
	{
		get
		{
			if(accountSelectedId!= null && amazonFileName != null && listAttachments == null)
			{
				listAttachments = AmazonFile.getAccountRelatedAmazonFiles(accountSelectedId, amazonFileName);
				for(AmazonFile__c recordAux : listAttachments)
					{
						String fileName = recordAux.Full_Name_Unique__c;
						fileName = fileName.split('/')[2];
						recordAux.Full_Name_Unique__c = fileName;
					}
			}
			return listAttachments;
		}
		set;
	}
	public Id amazonRecordTypeId
	{
		get{
			Id RecordTypeId;
			RecordTypeInfo rtInfo = Schema.SObjectType.AmazonFile__c.getRecordTypeInfosByName().get('File');
			if (rtInfo != null) {
				RecordTypeId = rtInfo .getRecordTypeId();
			}
			return RecordTypeId;
		}
	}
	public static final String amazonFileStartName
	{
		get
		{
			return AmazonFile.ICE_proofOfPayment;
			//return 'ICE POP';
		}
	}
	public static final String amazonFileNameIdentifier
	{
		get
		{
			return amazonFileStartName.replace(' ','_');
		}
	}
	public List<String> treePlacesCurrency{
		get{
			if (treePlacesCurrency == null) {
				treePlacesCurrency = new List<String>();
				Set<String> treePlacesCurrencySet = new Set<String>();
				List<CurrencyType> treePlacesCurrList = new List<CurrencyType>();
				treePlacesCurrList = [select id, IsoCode, DecimalPlaces from CurrencyType where DecimalPlaces = 3];
				for (CurrencyType crrncTp : treePlacesCurrList) {
					if(!treePlacesCurrencySet.contains(crrncTp.IsoCode)){
						treePlacesCurrencySet.add(crrncTp.IsoCode);
						treePlacesCurrency.add(crrncTp.IsoCode);
					}
				}
				return treePlacesCurrency;
			} else {
				return treePlacesCurrency;
			}
		}
		set;
	}

	/**
		Start actions, check rights and terms and conditions
	**/
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

    public Pagereference updateAppRight() {
        update this.appRight;
        return null;
    }

	/**
		CONSTRUCTOR
	**/
	public ISSP_Ctrl_AccountStatements() {
		this.faq = getContentDoc('IATA Customer E-Statement (ICE)');
		this.document = getContentDoc('IATA Customer E-Statement (ICE) User Guide');
		this.showPopUp = false;
		this.listMessages = new list<String>();
		// get current user
		this.currentUser = [
			Select Id, ContactId, Contact.AccountId, Contact.Account.Status__c,
				Contact.Account.Sector__c,Contact.Name,
				Contact.Account.Country_ISO_Code__c
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
		Id parentAccountId = getMaxParentAccount(this.account.Id);
		this.headofficeAccount = [Select Id, IATACode__c from Account where id = :parentAccountId];
		list<Account> listAccount = getAllHierarchy(this.currentUser.Contact.AccountId);

		// get Account Statements related with all accounts in the hierarchy
		this.listStatements = [
							Select Id,
								   Period__c,
								   Operation__c,
								   Name,
								   Key__c,
								   CurrencyIsoCode,
								   Account__c,
								   Amount_to_be_Paid__c,
								   Balance__c,
								   Billing_Amount__c,
								   Paid__c,
								   Remittance_Date__c,
								   Status__c,
								   Billing_Adjustment__c,
								   Group__c,
								   Account__r.Site,
								   Account__r.Name,
								   LastModifiedDate
								   From Account_Statement__c
								   Where Account__c in :listAccount
								   And Remittance_Date__c >= :getMinimumRemmitanceDateToSearch(listAccount)
								   Order By Remittance_Date__c desc, Operation__c asc
								   ];
		system.debug('ISSP_Ctrl_AccountStatements AccountStatement' +this.listStatements);
		// create a list of wrappers with collected Account Statements
		map<String,WrapperStatement> mapWrapper = new map<String,WrapperStatement>();
		this.lastUpdatedOn = Datetime.newInstance(1900, 1, 1);
		for (Account_Statement__c statement: this.listStatements) {
			//String key = statement.Period__c + statement.Group__c + statement.Operation__c;
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

		this.listWrapper = new list<WrapperStatement>();
		for (String period: mapWrapper.keyset() ) {
			WrapperStatement wrapper = mapWrapper.get(period);
			wrapper.calculeLastUpdatedDate();
			this.listWrapper.add(wrapper);
		}
		this.listWrapper.sort();
		markLastUpdated();
		markFirstOldPeriod();
        initListCurrency();
	}

	/**
		Get method for NewGenAPP mobile
	**/
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
		Get File document object from the library with given name
	**/
	private ContentVersion getContentDoc(String name) {
		try {
			return [
				Select Id
				From ContentVersion
				Where isLatest = true
				And title = :name
				Limit 1];
		} catch (Exception e) {
			System.debug('ERROR, document "' + name + '" not found: ' + e.getMessage());
			return null;
		}
	}

	/**
		Find the lowest remitance date in last valid periods
	**/
	private Date getMinimumRemmitanceDateToSearch(list<Account> listAccount) {
		try {
			list<AggregateResult> listResult = [
			  Select Remittance_Date__c
			  from Account_Statement__c
			  Where Account__c in :listAccount
			  and Remittance_Date__c <= TODAY
			  group by Remittance_Date__c
			  order by Remittance_Date__c desc
			  limit 3
			]; // search last 3 Remittance dates
			AggregateResult ar = listResult.get( listResult.size()-1 );
			return (Date)ar.get('Remittance_Date__c');
		} catch (Exception e) {
			return Date.today();
		}
	}

	/**
		populate list of available currencies
	**/
	private void initListCurrency() {
		set<String> setCurrency = new set<String>();
		for(WrapperStatement wrapper: this.listWrapper) {
			setCurrency.add(wrapper.parent.CurrencyIsoCode);
		}
		this.listCurrency = new list<String>(setCurrency);
	}

	/**
		Mark last updated Wrapper in the warapper statements list
	**/
	private void markLastUpdated() {
		WrapperStatement mark = null;
		for (WrapperStatement wrapper: this.listWrapper) {
			mark = mark!=null && mark.lastUpdatedDate>wrapper.lastUpdatedDate? mark: wrapper;
		}
		if (mark!=null) mark.lastUpdatedMark = true;
	}

	/**
		Searches in the list of Account statments and marks first statement with an old date
	**/
	private void markFirstOldPeriod() {
		for(WrapperStatement wrapper: this.listWrapper) {
			wrapper.showSeparation = false;
		}
		for(WrapperStatement wrapper: this.listWrapper) {
			if (wrapper.parent.Remittance_Date__c.addDays(2) < Date.today()) {
				wrapper.showSeparation = true;
				return;
			}
		}
	}

	/**
		Get a list containing all account in the input account hirarchy
	**/
	private list<Account> getAllHierarchy(Id AccountId) {
		Id maxParentId = getMaxParentAccount(accountId);
		return [
			Select id, Name, ParentId
			From Account
			Where Id =:maxParentId
			Or ParentId = :maxParentId
			or Parent.ParentId = :maxParentId
			or Parent.Parent.ParentId = :maxParentId
			or Parent.Parent.Parent.ParentId = :maxParentId
			or Parent.Parent.Parent.Parent.ParentId = :maxParentId
		];
	}

	/**
		Find Headquart account (parent top account in the hierarchy)
	**/
	private Id getMaxParentAccount(Id accountId) {
		try {
			Account account = [
				Select id, Name,
					ParentId,
					Parent.ParentId,
					Parent.Parent.ParentId,
					Parent.Parent.Parent.ParentId,
					Parent.Parent.Parent.Parent.ParentId
				From Account
				Where id = :accountId ];

			if (account.ParentId == null ) {
				return account.Id;
			}
			if (account.Parent.ParentId == null ) {
				return account.ParentId;
			}
			if (account.Parent.Parent.ParentId == null ) {
				return account.Parent.ParentId;
			}
			if (account.Parent.Parent.Parent.ParentId == null ) {
				return account.Parent.Parent.ParentId;
			}
			if (account.Parent.Parent.Parent.Parent.ParentId == null ) {
				return account.Parent.Parent.Parent.ParentId;
			}
			return account.Parent.Parent.Parent.Parent.ParentId;

		} catch (Exception e) {
			return accountId;
		}
	}

	/**
	class to Show attachmenst Popup
	**/

	public void addAttachment()
	{

		//System.debug(accountSelectedId+' ###### '+ accountStatementSelectedId);
		amazonFileName =amazonFileStartName+' '+accountStatementPeriod+' '+ billingAmount;
		//listAttachments = AmazonFile.getAccountRelatedAmazonFiles(accountSelectedId, amazonFileName);
		refreshList();

		this.showPopUp = true ;


	}


	/**
	class to close attachmenst Popup
	**/

	public void saveAttachment()
	{
        //System.debug('===============saveAttachment======== ');
		this.showPopUp =false ;
		//System.debug('===============saveAttachment======== '+this.showPopUp);

	}

	// UploadMultipleFileToAmazonButton compoenent attributes
	// credentialName
	public String credentialName  {
		get { return WrapperAttach.CREDENTIAL_NAME; }
	}

	// amazonPath
	public String amazonPath  {
		get {
			//String suffix = String.ValueOf(accountSelectedId).substring(0,3);
			//return ''+ suffix + '/' + String.valueOf(accountSelectedId) + '/';}

			return WrapperAttach.getAmazonFolder(this.accountSelectedId); }
	}


	/**
		class to update attachmenst list
	**/
	public Pagereference refreshList() {

		try {
				this.listAttachments = AmazonFile.getAccountRelatedAmazonFiles(accountSelectedId, amazonFileName);
				this.listAttachments.sort();
				for(AmazonFile__c recordAux : this.listAttachments)
					{
						String fileName = recordAux.Full_Name_Unique__c;
						fileName = fileName.split('/')[2];
						recordAux.Full_Name_Unique__c = fileName;
					}
			} catch (Exception e ) {
			System.debug('FATAL: ListController in function refreshList()  '  + e.getStackTraceString()  + '  '  + e.getMessage());
		}
		return null;
	}



	/**
		class to store a list of Account Statements and the sumarized data
	**/
	global class WrapperStatement implements Comparable {
		global Account_Statement__c parent {get;set;}
		global list<Account_Statement__c> listStatements {get; set;}
		global String accountSite {get;set;}
		global Boolean showDetail {get;set;}
		global DateTime lastUpdatedDate {get; set;}
		global Boolean lastUpdatedMark {get; set;}
        global Boolean showSeparation {get; set;}
        global String disclaimer { get; set; }
        global List <String> listCurrency {get; set;}
        global String location { get; set;}
		global String accountSatementId {get;set;}
		global String accountName {get;set;}

		global WrapperStatement(Account_Statement__c statement) {
			this.parent = statement.clone();
			this.accountSatementId =statement.Id;
			this.listStatements = new list<Account_Statement__c>();
			this.listStatements.add(statement);
			this.showDetail = false;
			this.accountSite = statement.Account__r.Site;
			this.accountName = statement.Account__r.Name;
			this.showSeparation = false;
			this.lastUpdatedMark = false;
			this.disclaimer = '';
			this.listCurrency = new List <String>();
			this.location = '';
		}

		/**
			Get most recent modification date for all statements in this wrapper
		**/
		public void calculeLastUpdatedDate() {
			DateTime lastUpdated = Datetime.newInstance(1900, 1, 1);
			for (Account_Statement__c statement: this.listStatements) {
				lastUpdated = statement!=null && lastUpdated>statement.LastModifiedDate? lastUpdated: statement.LastModifiedDate;
			}
			this.lastUpdatedDate = lastUpdated;
		}

		/**
			Add a new statement in current statements list
		**/
		public void addStatement(Account_Statement__c statement) {
			this.listStatements.add(statement);
			this.parent.Amount_to_be_Paid__c += statement.Amount_to_be_Paid__c;
			this.parent.Billing_Amount__c += statement.Billing_Amount__c;
			this.parent.Paid__c += statement.Paid__c;
			this.parent.Balance__c += statement.Balance__c;
			this.parent.Group__c = statement.Group__c;
		}

		/**
			Get current status for parent statement
		**/
		public String getParentStatus() {
			if (this.parent.Balance__c == 0 ) {
				return Label.ISSP_Fullpayment;
			}
			if (this.parent.Balance__c > 0 ) {
				return Label.ISSP_Pending;
			}
			return Label.ISSP_Excess;
		}

		/** WMO358 2018/11/02
			Get payment prove available
		**/
		public Boolean getParentPaymentProof() {
			if (this.parent.Balance__c == 0 ) {
				return false;
			}
			if (this.parent.Balance__c > 0 ) {
				return true;
			}
			return false;
		}


		public Decimal getParentBillingAdjustment() {
			return this.parent.Billing_Amount__c - this.parent.Amount_to_be_Paid__c;
		}

		public Integer compareTo(Object compareTo) {

			return this.parent.Period__c > ((WrapperStatement)compareTo).parent.Period__c? -1: 1;
		}
	}
}