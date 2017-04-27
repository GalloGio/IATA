public with sharing class ISSP_CurrencyCenterCountriesMapCtrl {

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

    public String listType {
    	get {
    		String tmpVar = ApexPages.currentPage().getParameters().get('type');
    		return tmpVar == null ? 'Blocked Funds' : tmpVar;
		} set;
	}


	public list<CountryWrapper> lstCountries {get{
            // use the wrapper just for formatting the issue started date in the locale of the user
            list<CountryWrapper> tmpList = new list<CountryWrapper>();
            for (Country_Profile__c cp : [SELECT Id, Name, Country_Name__r.ISO_Code__c, Country_Name__r.Name, Actual_Amount_Blocked__c, Issue_Started__c, Number_of_Airlines_Reporting_Issues__c FROM Country_Profile__c WHERE Listed_In__c = :listType]) {
                String tmpDate = '';
                if(cp.Issue_Started__c !=null){
                    DateTime dt = DateTime.newInstance(cp.Issue_Started__c.year(), cp.Issue_Started__c.month(), cp.Issue_Started__c.day());
                    tmpDate = dt.format('dd MMM yyyy');
                }
                tmpList.add(new CountryWrapper(String.valueOf(cp.Id), cp.Country_Name__r.Name, cp.Country_Name__r.ISO_Code__c, cp.Actual_Amount_Blocked__c, tmpDate, Integer.valueOf(cp.Number_of_Airlines_Reporting_Issues__c)));
            }
            return tmpList;
        } set;}

    public void ISSP_CurrencyCenterCountriesMapCtrl() {
    }

    public PageReference checkAccess(){
        return ISSP_CurrencyCenterUtil.checkIfUserHasAccessToService();
    }



    public class CountryWrapper{
        public String Id {get;set;}
        public String Name {get;set;}
        public String IsoCode {get;set;}
        public String AmtBlocked {get;set;}
        public String IssueStarted {get;set;}
        public Integer NbAirlinesReporting {get; set;}

        public CountryWrapper(String Id, String Name, String IsoCode, String AmtBlocked, String IssueStarted, Integer NbAirlinesReporting){
            this.Id = Id;
            this.Name = Name;
            this.IsoCode = IsoCode;
            this.AmtBlocked = AmtBlocked;
            this.IssueStarted = IssueStarted;
            this.NbAirlinesReporting = NbAirlinesReporting;
        }
    }
}