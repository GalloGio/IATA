public without sharing class vfIECGADMapDetails extends IECPageController {

	public vfIECSubscriptionInfo    ctrSubsInfo         {get; set;}


	//Handle data elements on the HTML information DIV (based on recived parameters)
	public boolean showAgencies         {get; set;}
	public boolean showFlags            {get; set;}
	public boolean showEmails           {get; set;}

	public list<String> lstErrorMessage             {get; set;}
	public List<Map<String, String>> recordList     {get; set;}

	public List<GDP_Agency_Stats__c> resultList     {get; set;}

	public Boolean hasAccess {get; set;}

	public vfIECGADMapDetails() {

		hasAccess = false;
		showAgencies = true;
		showFlags = false;
		showEmails = false;
		if (IECUserManager.isUserLoggedIn() )
		{
			//Initilize subscription component
			ctrSubsInfo = new vfIECSubscriptionInfo();
			ctrSubsInfo.loggedCustomer = loggedCustomer;
			ctrSubsInfo.sApplicationName = IECConstants.ProductCategory_SF_GAD;

			ctrSubsInfo.validateAccess();

			// if no access, redirect to the unauthorized page
			hasAccess = ctrSubsInfo.hasPageAccess;
		}

	}


	public String htmlInfo {
		get {

			String html = '<b>{point.name}</b><br/>';

			if (showFlags) {
				html = '<span class="f32"><span class="flag {point.flag}"></span></span><br>';
				html += '<b>{point.name}</b><br/>';
			}
			else
				html = '<b>{point.name}</b><br/>';

			if (showAgencies)
				html +=  '{point.locations} Locations <br/>';

			if (showEmails) {
				html +=  '{point.emails} Emails <br/>';
				html +=  '{point.uemails} Unique Emails <br/>';
			}

			return html;
		}
	}


	//**************************************************************************
	//Handle parameter reception
	//**************************************************************************
	public void handleParameters() {

		showAgencies = false;
		showEmails = false;
		showFlags = false;


		String agenciesParam = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SHOWMAPSAGENCIES);
		String flagsParam = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SHOWMAPSFLAGS);
		String emailsParam = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SHOWMAPSEMAILS);

		if (agenciesParam != null && agenciesParam == 'yes')
			showAgencies = true;


		if (emailsParam != null && emailsParam == 'yes')
			showEmails = true;

		if (flagsParam != null && flagsParam == 'yes')
			showFlags = true;
	}

	public void queryUSData() {

		//Line commented to fix the historic data issue
		resultList = queryForScpe('US States');

	   /*
		//**********************************************************************
		//New code to handle live stats queries
		//**********************************************************************
		resultList = queryForCountryStats('US', 'US States');
		handleParameters();
		//**********************************************************************
		//End of New code to handle live stats queries
		//**********************************************************************
	*/
		for (GDP_Agency_Stats__c ar : resultList) {
			if (ar.Emails__c == null) ar.Emails__c = 0;
			if (ar.Unique_Emails__c == null) ar.Unique_Emails__c = 0;
		}


	}

	public void queryCAData() {
		//Line commented to fix the historic data issue
		resultList = queryForScpe('CA Provinces');

/*
		//**********************************************************************
		//New code to handle live stats queries
		//**********************************************************************
		resultList = queryForCountryStats('CA', 'CA Provinces');
		handleParameters();
		//**********************************************************************
		//End of New code to handle live stats queries
		//**********************************************************************
  */
		for (GDP_Agency_Stats__c ar : resultList) {
			if (ar.Emails__c == null) ar.Emails__c = 0;
			if (ar.Unique_Emails__c == null) ar.Unique_Emails__c = 0;
		}


	}

	public void queryAUData() {
		//Line commented to fix the historic data issue
		resultList = queryForScpe('AU Territories');
/*
		//**********************************************************************
		//New code to handle live stats queries
		//**********************************************************************
		resultList = queryForCountryStats('AU', 'AU Territories');
		handleParameters();
		//**********************************************************************
		//End of New code to handle live stats queries
		//**********************************************************************
*/
		for (GDP_Agency_Stats__c ar : resultList) {
			if (ar.Emails__c == null) ar.Emails__c = 0;
			if (ar.Unique_Emails__c == null) ar.Unique_Emails__c = 0;
		}

	}

	public void queryWWData() {

		//Line commented to fix the historic data issue
		resultList = queryForScpe('Country');

/*
		//**********************************************************************
		//New code to handle live stats queries
		//**********************************************************************
		resultList = queryWWDataStats();
		handleParameters();
		//**********************************************************************
		//End of New code to handle live stats queries
		//**********************************************************************
*/
		for (GDP_Agency_Stats__c ar : resultList) {
			ar.Code__c = ar.Code__c.toUpperCase();
			if (ar.Emails__c == null) ar.Emails__c = 0;
			if (ar.Unique_Emails__c == null) ar.Unique_Emails__c = 0;
		}
	}

	//**********************************************************************
	//Begin Code commented to handle live stats queries
	//GDP_Agency_Stats__c table should be populated on the schedulable class "IECMapsResourceData"
	//Which need to be modified due to governor limits doing aggregations on big number of agencies
	//**********************************************************************

	public Date lastMontlhyDate() {
		GDP_Agency_Stats__c[] record = [SELECT Stats_Date__c FROM GDP_Agency_Stats__c WHERE Type__c = 'Monthly' order by Stats_Date__c desc limit 1];

		if (record != null && record.size() > 0)
			return record[0].Stats_Date__c;

		return null;
	}

	public Date snapshotDate {get; set;}

	public List<GDP_Agency_Stats__c> queryForScpe(String scope) {

		handleParameters();


		if (!hasAccess) {

			snapshotDate = lastMontlhyDate();
			//snapshotDate = String.valueOf(monthlyDate);
			return  [
				SELECT Id, Code__c, Locations__c, Emails__c, Unique_Emails__c, Scope__c, Type__c
				FROM GDP_Agency_Stats__c
				WHERE Type__c = 'Monthly' AND Scope__c = : scope AND Stats_Date__c = : snapshotDate];
		}
		else {
			snapshotDate = Date.today();
			return  [
				SELECT Id, Code__c, Locations__c, Emails__c, Unique_Emails__c, Scope__c, Type__c
				FROM GDP_Agency_Stats__c
				WHERE Type__c = 'Daily' AND Scope__c = : scope];
		}
	}

	//**********************************************************************
	//End Code commented to handle live stats queries
	//**********************************************************************


	//***************************************************************************************************
	// Code to handle the live stats queries. This code should be removed when historic data get fixed
	// This code needs to be removed once fixed the governor limits on the schedulable class
	//***************************************************************************************************
 /*
	public List<GDP_Agency_Stats__c> queryWWDataStats() {

		//Query for agency total by country
		AggregateResult[] agencies = [
			SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total
			FROM GDP_Products_Account_View__c
			WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> ''
				and Agency_Status_Code__c >= 4
				and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
				AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN ('A', 'I', 'L', 'Q', 'R', 'U', 'Y', 'Z', 'C', 'X')
			GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
		];


		//Query for agency emails total by country
		AggregateResult[] emails = [
			SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Email_Address__c) Total
			FROM GDP_Products_Account_View__c
			WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> ''
				and Agency_Status_Code__c >= 4
				and Email_Address__c <> null
				and Email_Address__c <> ''
				and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
				AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN ('A', 'I', 'L', 'Q', 'R', 'U', 'Y', 'Z', 'C', 'X')
			GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
		];

		//Query for agency unique emails total by country
		AggregateResult[] uniqueEmails = [
			SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT_DISTINCT(Email_Address__c) Total
			FROM GDP_Products_Account_View__c
			WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> ''
				and Agency_Status_Code__c >= 4
				and Email_Address__c <> null
				and Email_Address__c <> ''
				and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
				AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN ('A', 'I', 'L', 'Q', 'R', 'U', 'Y', 'Z', 'C', 'X')
			GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
		];


		return buildQueryResults('Country', agencies, emails, uniqueEmails);
	}


	public List<GDP_Agency_Stats__c> queryForCountryStats(String countryIsoCode, String scope) {

		//Query for agency total by state / province
		AggregateResult[] agencies = [
			SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Id) Total
			FROM GDP_Products_Account_View__c
			WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c = : countryIsoCode
				and Agency_Status_Code__c >= 4
				and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
				AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN ('A', 'I', 'L', 'Q', 'R', 'U', 'Y', 'Z', 'C', 'X')
			GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
		];


		//Query for agency emails total by state / province
		AggregateResult[] emails = [
			SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Email_Address__c) Total
			FROM GDP_Products_Account_View__c
			WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c = : countryIsoCode
				and Agency_Status_Code__c >= 4
				and Email_Address__c <> null
				and Email_Address__c <> ''
				and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
				AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN ('A', 'I', 'L', 'Q', 'R', 'U', 'Y', 'Z', 'C', 'X')
			GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
		];

		//Query for agency unique emails total by state / province
		AggregateResult[] uniqueEmails = [
			SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT_DISTINCT(Email_Address__c) Total
			FROM GDP_Products_Account_View__c
			WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c = : countryIsoCode
				and Agency_Status_Code__c >= 4
				and Email_Address__c <> null
				and Email_Address__c <> ''
				and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
				AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN ('A', 'I', 'L', 'Q', 'R', 'U', 'Y', 'Z', 'C', 'X')
			GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
		];


		return buildQueryResults(scope, agencies, emails, uniqueEmails);
	}



	public List<GDP_Agency_Stats__c> buildQueryResults( String scope,
		AggregateResult[] agencies,
		AggregateResult[] emails,
		AggregateResult[] uniqueEmails )
	{

		Map<String, GDP_Agency_Stats__c> statData = new Map<String, GDP_Agency_Stats__c>();

		//Build the agency total data from query aggregated result
		for ( AggregateResult ar : agencies) {

			GDP_Agency_Stats__c statRecord = new GDP_Agency_Stats__c();
			String recordCode =  ar.get('Code')==null ? '': (String)ar.get('Code');
			//if(recordCode != null)

			System.debug('*** scope ' + scope + '  recordCode '+recordCode);
			statRecord.Scope__c = scope;
			statRecord.Type__c = 'Daily';
			statRecord.Stats_Date__c = Date.today();
			statRecord.Code__c = recordCode.toLowerCase();
			statrecord.Locations__c =  (integer) ar.get('Total') ;

			System.debug('*** statRecord ' + statRecord);

			//dont insert garbage
			if(recordCode != null)
			   statData.put(recordCode.toLowerCase(), statRecord);
		}


		//Build the  email data from query aggregated result
		for ( AggregateResult ar : emails) {

			String recordCode = (String) ar.get('Code');
			GDP_Agency_Stats__c recordData;

			if(recordCode != null)
				recordData = (GDP_Agency_Stats__c) statData.get(recordCode.toLowerCase());

			if (recordData != null) {
				recordData.Emails__c = (integer) ar.get('Total');
			}
		}

		//Build the unique email data from query aggregated result
		for ( AggregateResult ar : uniqueEmails) {

			String recordCode = (String) ar.get('Code');
			GDP_Agency_Stats__c recordData;

			if(recordCode != null)
			   recordData = (GDP_Agency_Stats__c) statData.get(recordCode.toLowerCase());

			if (recordData != null) {
				recordData.Unique_Emails__c =  (integer) ar.get('Total');
			}
		}


		return statData.values();
	}

	//***************************************************************************************************
	// Code to handle the live stats queries. This code should be removed when historic data get fixed
	// This code needs to be removed once fixed the governor limits on the schedulable class
	//***************************************************************************************************
*/


}
