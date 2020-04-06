public without sharing class ANG_AnualRevalCaseCreationController {

	private static final String HE_LOCATION_TYPE = AMS_Utils.HE;
	private static final String GE_LOCATION_TYPE = AMS_Utils.GE;
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
	
	public Integer size{get; set;}
	public string region{get; private set;}
	public string mode{get; private set;}
	public String country{get; private set;}
	public String month{get; private set;}

	public List<String> countriesLst{get; set;}
	public Account account{get; set;}
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

	public boolean batchStatusBool{get;set;}
	public Id batchId {get;set;}
	public AsyncApexJob batchJob{get;set;}
	public boolean pollerBool{get;set;}
	public Integer getBatchStatus{get;set;}

	public ApexPages.StandardSetController con{get; set;}

	public String accredModel {
		get; set;
	}
	
	public List<SelectOption> accredModelOptions {
		get {
			if (accredModelOptions == null) {
				return new List<SelectOption> {
					new SelectOption('Cash','Cash'),
					new SelectOption('Cashless','Cashless'),
					new SelectOption('Multicountry','Multicountry')
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

	public ANG_AnualRevalCaseCreationController() {
		countriesLst = new List<String>();
		account = new Account();
		accountsToCreate = new List<AccountWrapper>();
		annualRevalidationCaseOscar = new Map<Id, Case>();
		batchStatusBool = false;
		getBatchStatus = 0;
		size = 1;
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
		return new List<SelectOption>{
			new SelectOption('Select Region', 'Select Region'),
			new SelectOption('Africa & Middle East','Africa & Middle East'),
			new SelectOption('Americas','Americas'),
			new SelectOption('Asia & Pacific','Asia & Pacific'),
			new SelectOption('China & North Asia','China & North Asia'),
			new SelectOption('Europe','Europe')
		};
	}

	public List<SelectOption> getmodeObj() {
		return new List<SelectOption>{
			new SelectOption('Select Mode', 'Select Mode'),
			new SelectOption('Financial year end','Financial year end'),
			new SelectOption('Country','Country'),
			new SelectOption('IATA Code','IATA Code')
		};
	}

	public List<selectoption> getMonthList() {
		return new List<SelectOption>{
			new SelectOption('Please Select a Month','Please Select a Month'),
			new SelectOption('January','January'),
			new SelectOption('February','February'),
			new SelectOption('March','March'),
			new SelectOption('April','April'),
			new SelectOption('May','May'),
			new SelectOption('June','June'),
			new SelectOption('July','July'),
			new SelectOption('August','August'),
			new SelectOption('September','September'),
			new SelectOption('October','October'),
			new SelectOption('November','November'),
			new SelectOption('December','December')
		};
	}

	public List<SelectOption> getcountryobj() {
		List<SelectOption> options = new List<SelectOption>{
			new SelectOption('Select Country', 'Select Country')
		};

		for (IATA_ISO_Country__c c: IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByRegion(new Set<String>{region}), 'Name')){
			options.add(new SelectOption(c.Id, c.name));
		}

		return options;
	}

	public Boolean validRegionSelected() {
		return region != 'Select Region' && region != null;
	}

	public Boolean validModeSelected() {
		return mode != 'Select Mode' && mode != null;
	}

	public Boolean validFinancialYearEndSelected() {
		return mode == 'Financial year end' ? (month != null && month != '' && month != 'Please Select a Month') : true;
	}

	public Boolean validIATACodeSelected() {
		return mode == 'IATA Code' ? (account.IATACode__c != null && account.IATACode__c != '') : true;
	}

	public Boolean getshouldDisableButton() {
		return selectedAccreditations.isEmpty() || cashOrLiteAccreditationModelSelected && (!validRegionSelected() || !validModeSelected() || !validFinancialYearEndSelected() || !validIATACodeSelected());
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
		if(!acct.Cases.isEmpty()){
			Boolean foundAnnualRevalidation = false;
			
			for (Case cse: acct.Cases) {
				if (cse.OSCAR__c != null) {
					if (cse.Oscar__r.Process__c == AMS_Utils.NGANNUALREVAL) {
						if (INVALID_OSCAR_STATUS.contains(cse.Oscar__r.Status__c)) {
							foundAnnualRevalidation = true;
							annualRevalidationCaseOscar.put(acct.Id, cse);
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

		Set<String> selectedAccreditationsSet = new Set<String>();

		for(SelectOption accred: selectedAccreditations) {
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

		String iataCode = account.IATACode__c;

		if (cashOrLiteAccreditationModelSelected) {
			queryAccount += 'AND IATA_ISO_Country__r.Region__c = :region ' +
			'AND Location_Type__c = :HE_LOCATION_TYPE ';
		} else {
			queryAccount += 'AND Location_Type__c = :GE_LOCATION_TYPE ';
		}

		if(mode == 'Financial year end') {
			queryAccount += 'AND Financial_Year_End__c = :month ';
		} else if(mode == 'Country') {
			queryAccount += 'AND IATA_ISO_Country__c = :country ';
		} else if(mode == 'IATA Code') {
			queryAccount += 'AND IATACode__c = :iataCode ';
		}

		List<Account> accountLst = new List<Account>();
		
		for (Account acct : Database.query(queryAccount)) {
			if (!processAccountRelatedCases(acct)) {
				accountLst.add(acct);
			}
		}

		if (!accountLst.isEmpty()) {
			con = new ApexPages.StandardSetController(accountLst);
			con.setPageSize(size);

			populateAccountsToDisplay((List<Account>)con.getRecords());
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

	public void launchCampaign() {
		disableLaunchButton = true;

		Set<Id> accountsToCreateIds = new Set<Id>();

		for(AccountWrapper aw: accountsToCreate) {
			if (aw.selected) {
				accountsToCreateIds.add(aw.account.Id);
			}
		}

		if (!accountsToCreateIds.isEmpty()) {
			batchStatusBool = true;
			pollerBool = true;
			batchId = Database.executeBatch(new ANG_AnualRevalCaseCreationBatch(accountsToCreateIds), 1);
		}
	}

	public void getBatchStatus() {
		if(batchId == null){
			pollerBool = true;
			return;
		}

		batchJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchId];

		pollerBool = !(batchJob.status == 'Ended' || batchJob.status == 'Completed');

		getBatchStatus++;
	}

	public void validateAccreditationModel() {
		accountsToCreate.clear();

		List<String> accredModelList = new List<String>();

		for (SelectOption accredModel: selectedAccreditations) {
			accredModelList.add(accredModel.getValue());
		}

		multicountryAccreditationModelSelected = (accredModelList.contains('Multicountry') && !accredModelList.isEmpty());
		cashOrLiteAccreditationModelSelected = (!accredModelList.contains('Multicountry') && !accredModelList.isEmpty());

		if (multicountryAccreditationModelSelected) {
			mode = 'Select Mode'; 
			region = 'Select Region';
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
		
		for(AccountWrapper aw: accountsToCreate) {
			if (aw.selected) {
				disableLaunchButton = false;
				break;
			}
		}
	}
}
