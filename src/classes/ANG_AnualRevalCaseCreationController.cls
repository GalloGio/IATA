public without sharing class ANG_AnualRevalCaseCreationController {

	private static final String ANNUAL_REV_PROCESS = AMS_Utils.NGANNUALREVAL;
	private static final String MAJOR_CHANGES_PROCESS = AMS_Utils.NGCHANGES;
	private static final String OWNERSHIP_CHG = AMS_Utils.ANG_OWNERSHIP;
	private static final String MAJOR_SHAREHOLDING_CHG = AMS_Utils.ANG_MAJOR_SHAREHOLDING;
	private static final String HIERARCHY_CHG = AMS_Utils.ANG_HIERARCHY;
	private static final String LOC_TYPE_DIFF_LEGAL_CHG = AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY;
	private static final String LEGAL_NAME_CHG = AMS_Utils.ANG_LEGAL_NAME;
	private static final String LEGAL_STATUS_CHG = AMS_Utils.ANG_LEGAL_STATUS;

	private static final String MONTH_QUESTION = 'Please Select a Month';
	private static final Set<String> MONTHS = new Set<String>{
		'January',
		'February',
		'March',
		'April',
		'May',
		'June',
		'July',
		'August',
		'September',
		'October',
		'November',
		'December'
	};

	private static final String REGION_QUESTION = 'Select Region';
	private static final Set<String> REGIONS = new Set<String>{
		'Europe',
		'Africa & Middle East',
		'Americas',
		'Asia & Pacific',
		'China & North Asia'
	};

	private static final String MODE_QUESTION = 'Select Mode';
	private static final String MODE_FINANCIAL_YEAR = 'Financial year end';
	private static final String MODE_COUNTRY = 'Country';
	private static final String MODE_IATA_CODE = 'IATA Code';

	private static final String SELECT_COUNTRY = 'Select Country';
	private static final String ENDED = 'Ended';
	private static final String COMPLETED = 'Completed';

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

	public List<SelectOption> paginationSizeOptions{
		get {
			return new List<SelectOption>{
				new SelectOption('5', '5'),
				new SelectOption('10', '10'),
				new SelectOption('20', '20'),
				new SelectOption('50', '50'),
				new SelectOption('100', '100')
			};
		}
		set;
	}

	public Boolean hasNext {
		get {
			return con.getHasNext();
		}
		set;
	}
	
	public Boolean hasPrevious {
		get {
			return con.getHasPrevious();
		}
		set;
	}
	
	public Integer pageNumber {
		get {
			return con.getPageNumber();
		}
		set;
	}

	public Integer size { get; set; }
	public string region { get; private set; }
	public string mode { get; private set; }
	public String country { get; private set; }
	public String month { get; private set; }
	
	public List<String> countriesLst { get; set; }
	public String iataCode { get; set; }
	public boolean shouldDisableButton;

	public String infoNote {
		get {
			infoNote = '<p>You cannot select Multicountry accreditation model while selecting Cash or Cashless</p>';
			
			if (multicountryAccreditationModelSelected || cashOrLiteAccreditationModelSelected) {
				infoNote += '<p>The accounts selected for the campaign are hierarchies with ' + (multicountryAccreditationModelSelected ? AMS_Utils.GE : AMS_Utils.HE) + ' locations:</p>';
				infoNote += '<ul>';
				infoNote += '<li>With Status Approved or Changes processed</li>';
				infoNote += '<li>Accredited more than 6 months ago</li>';
				infoNote += '<li>No major change in progress or finalized in the last 6 months</li>';
				infoNote += '<li>Without ongoing Annual Revalidation Oscars</li>';
				infoNote += '</ul>';
			}
			
			return infoNote;
		}
		set;
	}

	public class AccountWrapper {
		public Account account {get; set;}
		public Case oscarCase {get; set;}
		public Boolean selected {get; set;}

		public AccountWrapper(Account acct, Case oscarCase, Boolean selected) {
			this.account = acct;
			this.oscarCase = oscarCase;
			this.selected = selected;
		}
	}

	public List<AccountWrapper> accountsToCreate{
		get; set;
	}

	private Map<Id, Case> annualRevalidationCaseOscar{get;set;}

	public boolean batchStatusBool { get; set; }
	public Id batchId { get; set; }
	public AsyncApexJob batchJob { get; set; }
	public boolean pollerBool { get; set; }
	public Integer getBatchStatus { get; set; }
	
	public ApexPages.StandardSetController con { get; set; }
	
	public List<SelectOption> accredModelOptions {
		get {
			if (accredModelOptions == null) {
				return new List<SelectOption> {
					new SelectOption(AMS_Utils.ACCREDITATIONMODEL_CASH, AMS_Utils.ACCREDITATIONMODEL_CASH),
					new SelectOption(AMS_Utils.ACCREDITATIONMODEL_CASHLESS, AMS_Utils.ACCREDITATIONMODEL_CASHLESS),
					new SelectOption(AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY, AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY)
				};
			}

			return accredModelOptions;
		}
		private set;
	}

	public List<SelectOption> nonSelectedAccreditations {
		get {
			if (nonSelectedAccreditations == null) {
				nonSelectedAccreditations = accredModelOptions;
			}
			return nonSelectedAccreditations;
		}
		set;
	}

	public List<SelectOption> selectedAccreditations {
		get; set;
	}

	public Boolean multicountryAccreditationModelSelected {
		get {
			return multicountryAccreditationModelSelected == null ? false : multicountryAccreditationModelSelected;
		}
		private set;
	}

	public Boolean cashOrLiteAccreditationModelSelected {
		get {
			return cashOrLiteAccreditationModelSelected == null ? false : cashOrLiteAccreditationModelSelected;
		}
		private set;
	}

	public Boolean disableLaunchButton {get; set;}

	public Boolean noResultsFound {get; private set;}

	public ANG_AnualRevalCaseCreationController() {
		countriesLst = new List<String>();
		accountsToCreate = new List<AccountWrapper>();
		annualRevalidationCaseOscar = new Map<Id, Case>();
		batchStatusBool = false;
		getBatchStatus = 0;
		size = 5;
		selectedAccreditations = new List<SelectOption>();
		disableLaunchButton = true;
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

	public void setMonth(String value){
		if(month != value){
			accountsToCreate = new List<AccountWrapper>();
			con = null;
		}
		month = value;
	}

	public List<SelectOption> getregionobj() {
		List<SelectOption> options = new List<SelectOption>{
			new SelectOption(REGION_QUESTION, REGION_QUESTION)
		};

		for (String region: REGIONS) {
			options.add(new SelectOption(region, region));
		}
		
		return options;
	}

	public List<SelectOption> getmodeObj() {
		return new List<SelectOption>{
			new SelectOption(MODE_QUESTION, MODE_QUESTION),
			new SelectOption(MODE_FINANCIAL_YEAR, MODE_FINANCIAL_YEAR),
			new SelectOption(MODE_COUNTRY, MODE_COUNTRY),
			new SelectOption(MODE_IATA_CODE, MODE_IATA_CODE)
		};
	}

	public List<selectoption> getMonthList() {
		List<SelectOption> options = new List<SelectOption>{
			new SelectOption(MONTH_QUESTION, MONTH_QUESTION)
		};

		for (String month: MONTHS) {
			options.add(new SelectOption(month, month));
		}
		
		return options;
	}

	public List<SelectOption> getcountryobj() {
		List<SelectOption> options = new List<SelectOption>{
			new SelectOption(SELECT_COUNTRY, SELECT_COUNTRY)
		};

		for (IATA_ISO_Country__c c: IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByRegion(new Set<String>{region}), 'Name')){
			options.add(new SelectOption(c.Id, c.name));
		}

		return options;
	}

	public Boolean validRegionSelected() {
		return region != REGION_QUESTION && region != null;
	}

	public Boolean validModeSelected() {
		return mode != MODE_QUESTION && mode != null;
	}

	public Boolean validFinancialYearEndSelected() {
		return mode == MODE_FINANCIAL_YEAR ? (String.isNotBlank(month) && month != MONTH_QUESTION) : true;
	}

	public Boolean validIATACodeSelected() {
		return mode == MODE_IATA_CODE ? String.isNotBlank(iataCode) : true;
	}

	public Boolean getshouldDisableSearchButton() {
		return selectedAccreditations.isEmpty() || cashOrLiteAccreditationModelSelected
			&& (!validRegionSelected() || !validModeSelected() || !validFinancialYearEndSelected()
				|| !validIATACodeSelected());
	}

	private String getOscarCasesSubquery() {
		return '(SELECT Id, OSCAR__r.Name, OSCAR__r.Process__c, OSCAR__r.ANG_Type_of_Change__c, OSCAR__r.Status__c, ClosedDate, CreatedDate ' + 
		'FROM Cases ' +
		'WHERE (OSCAR__r.Process__c = :ANNUAL_REV_PROCESS) ' +
		'	OR (OSCAR__r.Process__c = :MAJOR_CHANGES_PROCESS ' +
		'		AND Oscar__r.ANG_Type_of_Change__c INCLUDES (:OWNERSHIP_CHG, :MAJOR_SHAREHOLDING_CHG, ' +
		'			:HIERARCHY_CHG, :LOC_TYPE_DIFF_LEGAL_CHG, :LEGAL_NAME_CHG, :LEGAL_STATUS_CHG)) ' +
		'ORDER BY OSCAR__r.Process__c, OSCAR__r.CreatedDate DESC) ';
	}

	private Boolean processAccountRelatedCases(Account acct) {
		if (!acct.Cases.isEmpty()) {
			Boolean foundAnnualRevalidation = false;
			
			System.debug(LoggingLevel.FINE, '____ [cls ANG_AnualRevalCaseCreationController - processAccountRelatedCases] Processing cases for account: ' + acct);

			for (Case cse : acct.Cases) {
				if (cse.OSCAR__c != null) {
					System.debug(LoggingLevel.FINE, '____ [cls ANG_AnualRevalCaseCreationController - processAccountRelatedCases] Processing Case: ' + cse);

					if (cse.Oscar__r.Process__c == AMS_Utils.NGANNUALREVAL) {
						if (INVALID_OSCAR_STATUS.contains(cse.Oscar__r.Status__c)){ 
							if(!foundAnnualRevalidation) {
								foundAnnualRevalidation = true;
								annualRevalidationCaseOscar.put(acct.Id, cse);
							}
						} else {
							if (annualRevalidationCaseOscar.get(acct.Id) != null) {
								annualRevalidationCaseOscar.get(acct.Id).clear();
							}
							return true;
						}
					} else if (cse.oscar__r.Process__c == AMS_Utils.NGCHANGES
						&& (ON_GOING_MAJOR_CHANGES_STATUS.contains(cse.Oscar__r.Status__c)
							|| (cse.Oscar__r.Status__c == AMS_Utils.OSCAR_CLOSED
								&& (System.today().daysBetween(Date.valueOf(cse.ClosedDate)) < 180)))) {
						return true;
					}
				}
			}
		}

		return false;
	}

	public void searchAgencies() {
		con = null;
		annualRevalidationCaseOscar.clear();
		batchStatusBool = false;
		noResultsFound = false;

		Set<String> selectedAccreditationsSet = new Set<String>();

		for (SelectOption accred: selectedAccreditations) {
			selectedAccreditationsSet.add(accred.getValue());
		}

		String queryAccount =
			'SELECT Id, IATACode__c, Name, RecordType.Name, Status__c, Location_Class__c, ' + 
			'   Location_Type__c, IATA_ISO_Country__r.Region__c, IATA_ISO_Country__r.Name, Financial_Year_End__c, ' +
			getOscarCasesSubquery() +
			'FROM Account ' +
			'WHERE RecordType.DeveloperName = \'IATA_Agency\' ' + 
			'AND ANG_Accreditation_Model__c IN :selectedAccreditationsSet ' + 
			'AND Status__c IN :TARGET_ACCOUNT_STATUS ' + 
			'AND Accreditation_date__c < LAST_N_MONTHS:6 ';

		if (cashOrLiteAccreditationModelSelected) {
			queryAccount += 'AND IATA_ISO_Country__r.Region__c = :region ' +
			'AND Location_Type__c = \'' + AMS_Utils.HE + '\' ';
		} else {
			queryAccount += 'AND Location_Type__c = \'' + AMS_Utils.GE + '\' ';
		}

		if (mode == MODE_FINANCIAL_YEAR) {
			queryAccount += 'AND Financial_Year_End__c = :month ';
			System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] Running for Financial year end with value: '+ month);
		} else if (mode == MODE_COUNTRY) {
			queryAccount += 'AND IATA_ISO_Country__c = :country ';
			System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] Running for Country with value: '+ country);
		} else if (mode == MODE_IATA_CODE) {
			queryAccount += 'AND IATACode__c = :iataCode ';
			System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] Running for IATA Code with value: '+ account.IATACode__c);
		}

		List<Account> accountLst = new List<Account>();

		System.debug(LoggingLevel.FINE, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] Performing Query: ' + queryAccount);

		for (Account acct : Database.query(queryAccount)) {
			if (!processAccountRelatedCases(acct)) {
				accountLst.add(acct);
			}
		}

		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - searchAgencies] Size of account list is: ' + accountLst.size());

		if (!accountLst.isEmpty()) {
			con = new ApexPages.StandardSetController(accountLst);
			con.setPageSize(size);
			populateAccountsToDisplay((List<Account>)con.getRecords());
		} else {
			noResultsFound = true;
		}
	}
	
	public void previous() {
		con.previous();
		populateAccountsToDisplay((List<Account>)con.getRecords());
	}
	
	public void next() {
		con.next();
		populateAccountsToDisplay((List<Account>)con.getRecords());
	}
	
	public void last() {
		con.last();
		populateAccountsToDisplay((List<Account>)con.getRecords());
	}
	
	public void first() {
		con.first();
		populateAccountsToDisplay((List<Account>)con.getRecords());
	}

	public void refreshPageSize() {
		con.setPageSize(size);
		populateAccountsToDisplay((List<Account>)con.getRecords());
	}

	public void launchCampaign() {
		disableLaunchButton = true;

		Set<Id> accountsToCreateIds = new Set<Id>();

		for (AccountWrapper aw : accountsToCreate) {
			if (aw.selected) {
				accountsToCreateIds.add(aw.account.Id);
			}
		}

		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - launchCampaign] accountsToCreateIds: ' + accountsToCreateIds);
		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_AnualRevalCaseCreationController - launchCampaign] total size of accountsToCreateIds: ' + accountsToCreateIds.size());

		if (!accountsToCreateIds.isEmpty()) {
			batchStatusBool = true;
			pollerBool = true;
			batchId = Database.executeBatch(new ANG_AnualRevalCaseCreationBatch(accountsToCreateIds), 1);
		}
	}

	public void getBatchStatus() {
		if (batchId == null) {
			pollerBool = true;
			return;
		}

		batchJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchId];

		pollerBool = batchJob.Status != ENDED && batchJob.Status != COMPLETED;

		getBatchStatus++;
	}

	public void validateAccreditationModel() {
		accountsToCreate.clear();

		List<String> accredModelList = new List<String>();

		for (SelectOption accredModel: selectedAccreditations) {
			accredModelList.add(accredModel.getValue());
		}

		multicountryAccreditationModelSelected = (accredModelList.contains(AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY) && !accredModelList.isEmpty());
		cashOrLiteAccreditationModelSelected = (!accredModelList.contains(AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY) && !accredModelList.isEmpty());

		if (multicountryAccreditationModelSelected) {
			mode = MODE_QUESTION; 
			region = REGION_QUESTION;
		}

		con = null;
	}

	public void populateAccountsToDisplay(List<Account> retrievedAccounts) {
		accountsToCreate = new List<AccountWrapper>();
		
		for (Account acct : retrievedAccounts) {
			AccountWrapper aw = new AccountWrapper(acct, annualRevalidationCaseOscar.get(acct.Id), false);
			accountsToCreate.add(aw);
		}
	}

	public void checkSelectedRecords() {
		disableLaunchButton = true;

		for (AccountWrapper aw: accountsToCreate) {
			if (aw.selected) {
				disableLaunchButton = false;
				break;
			}
		}
	}
}
