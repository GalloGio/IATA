public without sharing class ANG_AnualRevalCaseCreationController {

	private static final String HE_LOCATION_TYPE = AMS_Utils.HE;
	private static final String ACCRED_MODEL_MULTICOUNTRY = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
	private static final String ANNUAL_REV_PROCESS = AMS_Utils.NGANNUALREVAL;
	private static final String MAJOR_CHANGES_PROCESS = AMS_Utils.NGCHANGES;
	private static final String OWNERSHIP_CHG = AMS_Utils.ANG_OWNERSHIP;
	private static final String MAJOR_SHAREHOLDING_CHG = AMS_Utils.ANG_MAJOR_SHAREHOLDING;
	private static final String HIERARCHY_CHG = AMS_Utils.ANG_HIERARCHY;
	private static final String LOC_TYPE_DIFF_LEGAL_CHG = AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY;
	private static final String LEGAL_NAME_CHG = AMS_Utils.ANG_LEGAL_NAME;
	private static final String LEGAL_STATUS_CHG = AMS_Utils.ANG_LEGAL_STATUS;

	private static final List<String> TARGET_ACCOUNT_STATUS = new List<String>{AMS_Utils.ACC_S9_APPROVED, AMS_Utils.ACC_S8_CHANGESPROCESSED};
	private static final List<String> INVALID_OSCAR_STATUS = new List<String>{
		AMS_Utils.OSCAR_CLOSED, 
		AMS_Utils.OSCAR_CLOSED_CLOSED, 
		AMS_Utils.OSCAR_CLOSED_NOT_ACCEPTED, 
		AMS_Utils.OSCAR_CLOSED_REJECTED, 
		AMS_Utils.OSCAR_CLOSED_WITHDRAWN
	};

	private static final List<String> ON_GOING_MAJOR_CHANGES_STATUS = new List<String>{
		AMS_Utils.OSCAR_CLOSED, 
		AMS_Utils.OSCAR_ACCEPTED_FUTURE, 
		AMS_Utils.OSCAR_ACCEPTED_PENDING_AGREEMENT, 
		AMS_Utils.OSCAR_ACCEPTED_PENDING_BG, 
		AMS_Utils.OSCAR_ACCEPTED_PENDING_DOCS, 
		AMS_Utils.OSCAR_REOPEN, 
		AMS_Utils.OSCAR_PENDING_APPROVAL, 
		AMS_Utils.OSCAR_PENDING_VALIDATION, 
		AMS_Utils.OSCAR_OPEN_EDMC,
		AMS_Utils.OSCAR_OPEN
	};

	public List<SelectOption> paginationSizeOptions{get;set;}
	public Integer size{get;set;}
	public string region{get; private set;}
	public string mode{get; private set;}
	public String country{get;private set;}
	public String year{get; private set;}

	public List<String> countriesLst{get; set;}
	public Account account{get; set;}
	public boolean shouldDisableButton;

	public String infoNote {
		get {
			infoNote = '<p>The accounts selected for the campaign are hierarchies with HE locations:</p>';
			infoNote += '<ul>';
			infoNote += '<li>With Status Approved or Changes processed</li>';
			infoNote += '<li>Accredited more than 6 months ago</li>';
			infoNote += '<li>No major change in progress or finalized in the last 6 months</li>';
			infoNote += '</ul>';
			return infoNote;
		}
		set;
	}

	public class AccountWrapper {
		public Account account{get; set;}
		public Case oscarCase {get; set;}
		public AccountWrapper(Account acct, Case oscarCase){
			this.account = acct;
			this.oscarCase = oscarCase;
		}
	}

	public List<AccountWrapper> accountsToCreate{
		get{
			if(con != null){
			accountsToCreate = new List<AccountWrapper>();
			for(Account acct : (List<Account>)con.getRecords()){
				AccountWrapper aw = new AccountWrapper(acct, annualRevalidationCaseOscar.get(acct.Id));
				accountsToCreate.add(aw);
			}
		}
				return accountsToCreate;
			}
		set;
	}

	private Map<Id, Case> annualRevalidationCaseOscar{get;set;}

	public boolean batchStatusBool{get;set;}
	public Id batchId {get;set;}
	public AsyncApexJob batchJob{get;set;}
	public boolean pollerBool{get;set;}
	public Integer getBatchStatus{get;set;}

	public ApexPages.StandardSetController con{get; set;}

	public ANG_AnualRevalCaseCreationController() {
		countriesLst = new List<String>();
		account = new Account();
		accountsToCreate = new List<AccountWrapper>();
		annualRevalidationCaseOscar = new Map<Id, Case>();
		batchStatusBool = false;
		getBatchStatus = 0;
		setPaginationOptions();
	}

	public void setPaginationOptions(){
		size=10;
		paginationSizeOptions = new List<SelectOption>();
		paginationSizeOptions.add(new SelectOption('5','5'));
		paginationSizeOptions.add(new SelectOption('10','10'));
		paginationSizeOptions.add(new SelectOption('20','20'));
		paginationSizeOptions.add(new SelectOption('50','50'));
		paginationSizeOptions.add(new SelectOption('100','100'));
	}

	//Changes the size of pagination
	public PageReference refreshPageSize() {
		con.setPageSize(size);
		return null;
	}

	public void setcountry(String value){
		if(country != value){
			accountsToCreate = new List<AccountWrapper>();
			con = null;
		}
		country = value;
	}

	public void setregion(String value){
		if(region != value){
			accountsToCreate = new List<AccountWrapper>();
			con = null;
		}
		region = value;
	}

	public void setmode(String value){
		if(mode != value){
			accountsToCreate = new List<AccountWrapper>();
			con = null;
		}
		mode = value;
	}

	public void setyear(String value){
		if(year != value){
			accountsToCreate = new List<AccountWrapper>();
			con = null;
		}
		year = value;
	}

	public list<selectoption> getregionobj(){

		list<selectoption> options= new list<selectoption>();

		options.add(new selectoption('Select Region', 'Select Region'));

		options.add(new selectoption('Africa & Middle East','Africa & Middle East'));
		options.add(new selectoption('Americas','Americas'));
		options.add(new selectoption('Asia & Pacific','Asia & Pacific'));
		options.add(new selectoption('China & North Asia','China & North Asia'));
		options.add(new selectoption('Europe','Europe'));

		return options;

	}

	public list<selectoption> getmodeObj(){

		list<selectoption> options= new list<selectoption>();

		options.add(new selectoption('Select Mode', 'Select Mode'));

		options.add(new selectoption('Financial year end','Financial year end'));
		options.add(new selectoption('Country','Country'));
		options.add(new selectoption('IATA Code','IATA Code'));

		return options;

	}

	public list<selectoption> getyearobj(){

		list<selectoption> options= new list<selectoption>();

		options.add(new selectoption('Please Select a Month','Please Select a Month'));
		options.add(new selectoption('January','January'));
		options.add(new selectoption('February','February'));
		options.add(new selectoption('March','March'));
		options.add(new selectoption('April','April'));
		options.add(new selectoption('May','May'));
		options.add(new selectoption('June','June'));
		options.add(new selectoption('July','July'));
		options.add(new selectoption('August','August'));
		options.add(new selectoption('September','September'));
		options.add(new selectoption('October','October'));
		options.add(new selectoption('November','November'));
		options.add(new selectoption('December','December'));

		return options;

	}

	public list<selectoption> getcountryobj(){

		list<selectoption> options= new list<selectoption>();

		list<IATA_ISO_Country__c> contr= IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByRegion(new Set<String>{region}), 'Name');

		if(contr.isEmpty()){
			options.add(new selectoption('Select Country', 'Select Country'));
			countriesLst.clear();

		}
		for( IATA_ISO_Country__c c:contr){

				options.add(new selectoption(c.Id,c.name));
		}

		return options;

	}

	public boolean getshouldDisableButton(){

		boolean value = false;

		if(region == 'Select Region' || mode == 'Select Mode' || region == null || mode == null)
			value = true;

		if(mode == 'Financial year end' && (year == null || year == '' || year == 'Please Select a Month'))
			value =  true;

		return value;
	}

	private String getOscarCasesSubquery(){
		String subQuery = 
		'   (SELECT Id, OSCAR__r.Name, OSCAR__r.Process__c, OSCAR__r.ANG_Type_of_Change__c, OSCAR__r.Status__c, ClosedDate ' + 
		'    FROM Cases ' +
		'    WHERE (OSCAR__r.Process__c = :ANNUAL_REV_PROCESS AND Oscar__r.Status__c NOT IN :INVALID_OSCAR_STATUS) ' +
		'       OR (OSCAR__r.Process__c = :MAJOR_CHANGES_PROCESS ' +
		' 			AND Oscar__r.ANG_Type_of_Change__c INCLUDES (:OWNERSHIP_CHG, :MAJOR_SHAREHOLDING_CHG, ' +
		'			 :HIERARCHY_CHG, :LOC_TYPE_DIFF_LEGAL_CHG, :LEGAL_NAME_CHG, :LEGAL_STATUS_CHG)) ' +
		'    ORDER BY OSCAR__r.Process__c, OSCAR__r.CreatedDate DESC) ';
		return subQuery;
	}

	private Boolean processAccountRelatedCases(Account acct) {
		if(!acct.Cases.isEmpty()){
			boolean foundAnnualRevalidation = false;
			for(Case cse : acct.Cases){
				if(cse.OSCAR__c != null){
					if(!foundAnnualRevalidation && cse.oscar__r.Process__c == AMS_Utils.NGANNUALREVAL){
						foundAnnualRevalidation = true;
						annualRevalidationCaseOscar.put(acct.Id, cse);
					}
					else if(cse.oscar__r.Process__c == AMS_Utils.NGCHANGES && 
							(ON_GOING_MAJOR_CHANGES_STATUS.contains(cse.Oscar__r.Status__c) || 
							(cse.Oscar__r.Status__c == AMS_Utils.OSCAR_CLOSED && 
								(System.today().daysBetween(Date.valueOf(cse.ClosedDate)) < 180)))
						)
					{
						return true;
					}
				}
			}
		}
		return false;
	}

	public void searchAgencies(){

		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] Running for Financial year end with value:'+ year);
		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] Running for Country with value:'+ country);
		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] Running for IATA Code with value:'+ account.IATACode__c);

		String queryAccount = null;
		con = null;
		annualRevalidationCaseOscar.clear();

		queryAccount =  
			'SELECT Id, IATACode__c, Name, RecordType.Name, Status__c, Location_Class__c, ' + 
			'   Location_Type__c, IATA_ISO_Country__r.Region__c, IATA_ISO_Country__r.Name, Financial_Year_End__c, ' +
			getOscarCasesSubquery() +
			'FROM Account ' +
			'WHERE RecordType.DeveloperName = \'IATA_Agency\' ' + 
			'AND Location_Type__c = :HE_LOCATION_TYPE ' +
			'AND ANG_Accreditation_Model__c != :ACCRED_MODEL_MULTICOUNTRY ' +
			'AND IATA_ISO_Country__r.Region__c = :region ' +
			'AND Status__c IN :TARGET_ACCOUNT_STATUS ' + 
			'AND Accreditation_date__c < LAST_N_MONTHS:6 ';

		String iataCode = account.IATACode__c;

		if(mode == 'Financial year end')
			queryAccount += ' AND Financial_Year_End__c = :year ';
		else if(mode == 'Country')
			queryAccount += ' AND IATA_ISO_Country__c = :country ';
		else if(mode == 'IATA Code')
			queryAccount += ' AND IATACode__c = :iataCode ';

		if(queryAccount <> null){

			System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] queryAccount is ' + queryAccount);

			List<Account> queriedAccountLst = Database.query(queryAccount);

			System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] Size of account list is: ' + queriedAccountLst.size());

			List<Account> accountLst = new List<Account>();
			for(Account acct : queriedAccountLst){
				Boolean isToExcludeAcct = processAccountRelatedCases(acct);
				if(!isToExcludeAcct){
					accountLst.add(acct);
				}
			}

			con = new ApexPages.StandardSetController(accountLst);
			con.setPageSize(size);

		} else{
			System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] queryAccount is null.');
		}

	}

	public Boolean hasNext
	{
		get
		{
			return con.getHasNext();
		}
		set;
	}

	public Boolean hasPrevious
	{
		get
		{
			return con.getHasPrevious();
		}
		set;
	}

	public Integer pageNumber
	{
		get
		{
			return con.getPageNumber();
		}
		set;
	}

	public void previous()
	{
		con.previous();
	}

	public void next()
	{
		con.next();
	}

	public void last()
	{
		con.last();
	}

	public void first()
	{
		con.first();
	}

	public void launchCampaign(){

		Set<Id> accountsToCreateIds = new Set<Id>();

		con.setPageSize(con.getResultSize());
		List<Account> tempAccountsToCreate = (List<Account>)con.getRecords();
		con.setPageSize(size);

		for(Account acct: tempAccountsToCreate){
			Case annualRevCase = annualRevalidationCaseOscar.get(acct.Id);
			if(annualRevCase == null){
				accountsToCreateIds.add(acct.Id);
			}
		}

		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - launchCampaign] accountsToCreateIds is ' + accountsToCreateIds);
		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - launchCampaign] total size: ' + accountsToCreateIds.size());

		if(!accountsToCreateIds.isEmpty()){

			System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - launchCampaign] Running batch !');

			batchStatusBool = true;
			pollerBool = true;

			ANG_AnualRevalCaseCreationBatch aRCCbatch = new ANG_AnualRevalCaseCreationBatch(accountsToCreateIds);
			batchId = Database.executeBatch(aRCCbatch,1);
		}

	}

	public void getBatchStatus(){

		if(batchId == null){
			pollerBool = true;
			return;
		}

		batchJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchId];

		if(batchJob.status == 'Ended' || batchJob.status == 'Completed')
			pollerBool = false;
		else
			pollerBool = true;

		getBatchStatus++;

	}
}
