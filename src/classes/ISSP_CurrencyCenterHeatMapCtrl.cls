public with sharing class ISSP_CurrencyCenterHeatMapCtrl {

	public List<Country_Profile__c> cList {get;set;}
	public Date lastUpdateDate {get;set;}
	public String searchText {get;set;}

	public ISSP_CurrencyCenterHeatMapCtrl() {

		if(ApexPages.currentPage().getParameters().get('search') != null){
			searchText = ApexPages.currentPage().getParameters().get('search');
			reSearch();
		} else {
			cList = new List<Country_Profile__c>([SELECT Id, Name, Country_Name__r.Name, HM_Spot_1m_ch__c, HM_Spot_12m_ch__c, 
												HM_Fwd_NDF__c, HM_Credit_spread__c, HM_Cr_Rating__c, HM_GDP__c, 
												HM_CPI__c, HM_CA__c, HM_NPL__c, HM_FX_Res__c, HM_FX_Res_percent__c, 
												ISO_Code__c, Region__c
												FROM Country_Profile__c ORDER BY Name ASC]);
	
			//second query just to get last modified date, not to iterate through whole list...
			try{
				lastUpdateDate = [SELECT HM_Last_Indicators_Update_Date__c 
							FROM Country_Profile__c ORDER BY HM_Last_Indicators_Update_Date__c DESC LIMIT 1].HM_Last_Indicators_Update_Date__c;
			} catch (Exception e) {
				lastUpdateDate = null;
			}
		}		

	}

	public PageReference reSearch() {
        cList = new List<Country_Profile__c>([SELECT Id, Name, Country_Name__r.Name, HM_Spot_1m_ch__c, HM_Spot_12m_ch__c, 
											HM_Fwd_NDF__c, HM_Credit_spread__c, HM_Cr_Rating__c, HM_GDP__c, 
											HM_CPI__c, HM_CA__c, HM_NPL__c, HM_FX_Res__c, HM_FX_Res_percent__c, 
											ISO_Code__c, Region__c
											FROM Country_Profile__c 
											WHERE (Name LIKE: '%'+searchText+'%') OR (Region__c LIKE: searchText+'%')
											ORDER BY Name ASC]);

        try{
        	lastUpdateDate = [SELECT HM_Last_Indicators_Update_Date__c 
						FROM Country_Profile__c 
						WHERE Name LIKE: '%'+searchText+'%' 
						ORDER BY HM_Last_Indicators_Update_Date__c DESC LIMIT 1].HM_Last_Indicators_Update_Date__c;
        } catch (Exception e) {
        	lastUpdateDate = null;
        }

        return null;
    }

}