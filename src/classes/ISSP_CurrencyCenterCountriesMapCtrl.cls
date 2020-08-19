public with sharing class ISSP_CurrencyCenterCountriesMapCtrl {

	public String selectedListType {get; set;}
	public String selectedRegion {get; set;}

	public list<SelectOption> getListRegionOptions() {
		list<SelectOption> listOptions = new list<SelectOption>();
		listOptions.add(new SelectOption('',System.Label.ISSP_All));
		for( Schema.PicklistEntry entry : IATA_ISO_Country__c.Region__c.getDescribe().getPicklistValues()) {
			listOptions.add(new SelectOption(entry.getValue(),entry.getLabel()));
		}
		return listOptions;
	}

	public list<SelectOption> getListTypeOptions() {
		list<SelectOption> listOptions = new list<SelectOption>();
		listOptions.add(new SelectOption('',System.Label.ISSP_All));
		for( Schema.PicklistEntry entry : Country_Profile__c.Listed_In__c.getDescribe().getPicklistValues()) {
			if (entry.getValue()!='Draft') {
				listOptions.add(new SelectOption(entry.getValue(),entry.getLabel()));
			}
		}
		return listOptions;
	}

	public List<Boolean> isChangedList {get{
		List<Boolean> tmpList = new List<Boolean>();
		//get list of record ids existing in history after previous visit
		List<Country_Profile_History__c> cHistoryList = new List<Country_Profile_History__c>(
			[SELECT Country_Profile__c FROM Country_Profile_History__c WHERE CreatedDate >: previousVisit]);
		List<Country_Profile__History> sHistoryList = new List<Country_Profile__History>(
			[SELECT ParentId FROM Country_Profile__History WHERE CreatedDate >: previousVisit]);
		Set<String> changedProfilesIds = new Set<String>();
		//iterate both lists and add Id to combined set of strings
		for(Country_Profile_History__c cph1 : cHistoryList){
			if(!changedProfilesIds.contains(cph1.Country_Profile__c))
				changedProfilesIds.add(cph1.Country_Profile__c);
		}
		for(Country_Profile__History cph2 : sHistoryList){
			if(!changedProfilesIds.contains(cph2.ParentId))
				changedProfilesIds.add(cph2.ParentId);
		}
		//go through country list and populate tmp helper list
		for(CountryWrapper cp : lstCountries){
			if(changedProfilesIds.contains(cp.Id)){
				tmpList.add(true);
			}
			else
				tmpList.add(false);
		}
		return tmpList;
	}set;}

	public Datetime previousVisit {get{
		return ISSP_CurrencyCenterUtil.getPreviousVisitDateTime();
	}set;}

	public list<CountryWrapper> lstCountries {
		get{
			List<Country_Profile__c> listCountryProfile = [
				SELECT Id, Name, Country_Name__r.ISO_Code__c, Country_Name__r.Name, Country_Name__r.Region__c, Actual_Amount_Blocked__c, Issue_Started__c,
					Number_of_Airlines_Reporting_Issues__c, CASS_ICCS_Availability__c, BSP_ICCS_Availability__c, BSP_Launch_Date__c, CASS_Launch_Date__c,
					Currency_Exchange_Rate__c, Currency__c, Listed_In__c
					FROM Country_Profile__c
					WHERE Listed_In__c IN ('Blocked Funds','Watch List','All others')];

			// use the wrapper just for formatting the issue started date in the locale of the user
			list<CountryWrapper> tmpList = new list<CountryWrapper>();
			for (Country_Profile__c cp : listCountryProfile) {

				tmpList.add(new CountryWrapper(
					String.valueOf(cp.Id),
					cp.Country_Name__r.Name,
					cp.Country_Name__r.ISO_Code__c,
					cp.Country_Name__r.Region__c,
					cp.Actual_Amount_Blocked__c,
					formatDate(cp.Issue_Started__c),
					Integer.valueOf(cp.Number_of_Airlines_Reporting_Issues__c),
					cp.CASS_ICCS_Availability__c,
					cp.BSP_ICCS_Availability__c,
					formatDate(cp.BSP_Launch_Date__c),
					formatDate(cp.CASS_Launch_Date__c),
					cp.Currency_Exchange_Rate__c,
					cp.Currency__c,
					cp.Listed_In__c));
			}
			return tmpList;
		} set;}

	public String getLstCountriesJson() {
		return JSON.serialize(lstCountries,true);
	}

	public void ISSP_CurrencyCenterCountriesMapCtrl() {
	}

	public PageReference checkAccess(){
		return ISSP_CurrencyCenterUtil.checkIfUserHasAccessToService();
	}
	
	public static String formatDate(Date dat) {
		if(dat ==null) return '';
		return DateTime.newInstance(dat.year(), dat.month(), dat.day()).format('dd MMM yyyy');
	}

	public class CountryWrapper{
		public String Id {get;set;}
		public String Name {get;set;}
		public String IsoCode {get;set;}
		public String Region {get;set;}
		public String AmtBlocked {get;set;}
		public String IssueStarted {get;set;}
		public Integer NbAirlinesReporting {get; set;}
		public String CASS_ICCS_Availability {get;set;}
		public String BSP_ICCS_Availability {get;set;}
		public String BSP_Launch_Date {get;set;}
		public String CASS_Launch_Date {get;set;}
		public Decimal Currency_Exchange_Rate {get;set;}
		public String Currency_x {get;set;}
		public String listType {get;set;}

		public CountryWrapper(String Id, String Name, String IsoCode, String Region, String AmtBlocked, String IssueStarted, Integer NbAirlinesReporting, String CASS_ICCS_Availability, String BSP_ICCS_Availability, String BSP_Launch_Date, String CASS_Launch_Date, Decimal Currency_Exchange_Rate, String Currency_x, String listType){
			this.Id = Id;
			this.Name = Name;
			this.IsoCode = IsoCode;
			this.Region = Region;
			this.AmtBlocked = AmtBlocked;
			this.IssueStarted = IssueStarted;
			this.NbAirlinesReporting = NbAirlinesReporting;
			this.CASS_ICCS_Availability = CASS_ICCS_Availability;
			this.BSP_ICCS_Availability = BSP_ICCS_Availability;
			this.BSP_Launch_Date = BSP_Launch_Date;
			this.CASS_Launch_Date = CASS_Launch_Date;
			this.Currency_Exchange_Rate = Currency_Exchange_Rate;
			this.Currency_x = Currency_x;
			this.listType = listType;
		}
	}
}
