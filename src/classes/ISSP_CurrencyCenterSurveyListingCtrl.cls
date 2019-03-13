/**
 * @description This is a controller class for ISSP_CurrencyCenterSurveyListing component
 *
 *
 * @creation  2019-01-17
 * @author    José Cardoso
 */
public with sharing class ISSP_CurrencyCenterSurveyListingCtrl {

	private User user {get;set;}
	private Contact contact {get;set;}
	public Account account {get;set;}

	public Map<String,survey> annualSurveyMap {get; set;}
	public Map<String,String> annualSurveys {get; set;}

	public Map<String,List<survey>> monthlySurveys {get; set;}

	public Set<String> availableYearsAnnual {get; set;}
	public Set<String> availableYearsMonthly {get; set;}

	public ISSP_CurrencyCenterSurveyListingCtrl(){
		this.user = [
				SELECT Id, Profile.Name, ContactId, Contact.Id, Contact.AccountId,
				Contact.Account.Id,
				Contact.Account.IATA_ISO_Country__c,
				Contact.Account.Remittance_frequency__c,
				Contact.Account.Location_Class__c
				FROM User
				WHERE Id = :UserInfo.getUserId()];
		this.contact = this.user.contact;
		this.account = this.user.contact.account;

		this.annualSurveys = new Map<String, String>();
		this.annualSurveyMap = new Map<String, survey>();
		this.monthlySurveys = new Map<String, List<survey>>();

		String airlineId = this.account.Id;

		List<Currency_Center_Survey__c> ccsList = [Select Id, Airline__c, Parent_Id__c, Survey__c, Reporting_Date__c, Status__c, Year_Survey__c, Month_Survey__c, RecordTypeId
													From Currency_Center_Survey__c
													Where (RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdAnnualSurvey OR RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdMonthlySurvey)
															AND Airline__c =:airlineId
													Order By Reporting_Date__c DESC ];
		for(Currency_Center_Survey__c ccs: ccsList){
			String surveyYear = ccs.Year_Survey__c;
			//if(ccs.Survey__c == 'Annual'){
			if(ccs.RecordTypeId == ISSP_CurrencyCenterUtil.rtIdAnnualSurvey){
				this.annualSurveys.put(surveyYear,ccs.Id);
			}
		}
		for(Currency_Center_Survey__c ccs: ccsList){
			String surveyYear = ccs.Year_Survey__c;
			//if(ccs.Survey__c == 'Annual'){
			if(ccs.RecordTypeId == ISSP_CurrencyCenterUtil.rtIdAnnualSurvey){
				survey s = new survey();
				s.Id = ccs.Id;
				s.Status = ccs.Status__c;
				this.annualSurveyMap.put(surveyYear, s);
			}
		}
		for(Currency_Center_Survey__c ccs: ccsList){
			String surveyYear = ccs.Year_Survey__c;

			//if(ccs.Survey__c == 'Monthly'){
			if(ccs.RecordTypeId == ISSP_CurrencyCenterUtil.rtIdMonthlySurvey){
				List<survey> tmpCcsList = new List<survey>();
				if(this.monthlySurveys.keySet().contains(surveyYear)){
					tmpCcsList = this.monthlySurveys.get(surveyYear);
				}
				survey s = new survey();
				s.Id = ccs.Id;
				s.MonthName = getMonthName(Integer.valueOf(ccs.Month_Survey__c));
				s.Status = ccs.Status__c;
				//s.AnnualSurveyId = '';
				if(this.annualSurveys.keySet().contains(surveyYear)){
					s.AnnualSurveyId = this.annualSurveys.get(surveyYear);
					if(this.annualSurveys.containsKey(surveyYear)) {
						s.AnnualSurveyStatus = this.annualSurveyMap.get(surveyYear).Status;
					}
				}
				tmpCcsList.add(s);
				this.monthlySurveys.put(surveyYear, tmpCcsList);
			}
		}
		/*for(String yearKey: this.annualSurveys.keySet()){
			if(!this.monthlySurveys.containsKey(yearKey)){
				List<survey> tmpCcsList = new List<survey>();
				survey s = new survey();
				s.AnnualSurveyId = this.annualSurveys.get(yearKey);
				tmpCcsList.add(s);
				this.monthlySurveys.put(yearKey, tmpCcsList);
			}
		}*/

		this.availableYearsAnnual =  this.annualSurveys.keySet();
		this.availableYearsMonthly =  this.monthlySurveys.keySet();
		System.debug('jmc - ISSP_CurrencyCenterSurveyListingCtrl ctor annualSurveys: ' + annualSurveys);
		System.debug('jmc - ISSP_CurrencyCenterSurveyListingCtrl ctor monthlySurveys: ' + monthlySurveys);
	}


	public String getMonthName(Integer month){
		String result = '';
		switch on month {
			when 1 {
				result = Label.ISSP_AMS_Month_January;
			}
			when 2 {
				result = Label.ISSP_AMS_Month_February;
			}
			when 3 {
				result = Label.ISSP_AMS_Month_March;
			}
			when 4 {
				result = Label.ISSP_AMS_Month_April;
			}
			when 5 {
				result = Label.ISSP_AMS_Month_May;
			}
			when 6 {
				result = Label.ISSP_AMS_Month_June;
			}
			when 7 {
				result = Label.ISSP_AMS_Month_July;
			}
			when 8 {
				result = Label.ISSP_AMS_Month_August;
			}
			when 9 {
				result = Label.ISSP_AMS_Month_September;
			}
			when 10 {
				result = Label.ISSP_AMS_Month_October;
			}
			when 11 {
				result = Label.ISSP_AMS_Month_November;
			}
			when 12 {
				result = Label.ISSP_AMS_Month_December;
			}
		}
		return result;
	}

	public class survey{
		public String Id {get;set;}
		public String MonthName {get; set;}
		public String Status {get; set;}
		public String AnnualSurveyId {get;set;}
		public String AnnualSurveyStatus {get;set;}
	}
}