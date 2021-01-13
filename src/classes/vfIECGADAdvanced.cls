/**
  * Description: This class contains the controller for the Visualforce page (Global Agency Directory - Advanced Search)
  * Author: Samy Saied ; Raymond Afara
  * Version: 1.2
  * History:
  */

public without sharing class vfIECGADAdvanced extends IECPageController {
	public IEC_Application_Filter__c filter    {get; set;}
	public vfIECSubscriptionInfo ctrSubsInfo  {get; set;}
	public vfIECSavedFilters ctrSavedFilters  {get; set;}

	//Display variables
	public list<String> lstErrorMessage     {get; set;}
	public String sParamFilterId       {get; set;}
	public boolean bDisplayError      {get; set;}
	public String sErrorMessage        {get; set;}
	public boolean bDisableState        {get; set;}
	public String PageTitle        {
		public get {
			if (PageTitle == null) {
				if (sProductCode =='GAD') PageTitle='Global Agency Directory';
				else if (sProductCode =='PAL') PageTitle='Passenger Agency List';
				else if (sProductCode =='CAL') PageTitle='Cargo Agency List';
				else if (sProductCode =='ASL') PageTitle='MSO & GSA List';
			}
			return PageTitle;
		}
		private set;
	}
	public boolean bLoadLocationFilter, bLoadTypeFilter;

	private Set<String> setSubContinent;

	public List<SelectOption> optAgencyNameSearchCondition {
		get {return IECApplicationsManager.GetListOptions(IEC_Application_Filter__c.Agency_Name_Search_Condition__c.getDescribe());}
	}

	public List<SelectOption> optAgencyNameSearchType {
		get {return IECApplicationsManager.GetListOptions(IEC_Application_Filter__c.Agency_Name_Search_Type__c.getDescribe());}
	}

	public List<SelectOption> optCitySearchType {
		get {return IECApplicationsManager.GetListOptions(IEC_Application_Filter__c.City_Search_Type__c.getDescribe());}
	}

	public List<SelectOption> optHierarchy {
		get {return IECApplicationsManager.GetListOptions(IEC_Application_Filter__c.Hierarchy__c.getDescribe());}
	}

	public List<SelectOption> optZipCodeSearchType {
		get {return IECApplicationsManager.GetListOptions(IEC_Application_Filter__c.Zip_Code_Search_Type__c.getDescribe());}
	}

  public String[] sCountry {
	get {
	  return (filter.Country__c != null)
		? RemoveBrackets(filter.Country__c).split(', ')
		: null;
	}
	set {
	  filter.Country__c = IECUtil.ArrayToString(value);
	}
  }

  public String[] sState {
	get {
	  return (filter.State__c != null)
		? RemoveBrackets(filter.State__c).split(', ')
		: null;
	}
	set {
	  filter.State__c = IECUtil.ArrayToString(value);
	}
  }

	public String[] sHierarchy {
		get {
			return (filter.Hierarchy__c != null)
		? filter.Hierarchy__c.split(';')
				: null;
		}
		set {
			filter.Hierarchy__c = RemoveBrackets(IECUtil.ArrayToString(value)).replace(', ', ';');
		}
	}

	public String[] sAgencyProgram {
		get {
			return (filter.Agency_Program__c != null)
		? RemoveBrackets(filter.Agency_Program__c).split(', ')
				: null;
		}
		set {
			filter.Agency_Program__c = IECUtil.ArrayToString(value);
		}
	}

  public String sProductCode {
	get {
			if (sProductCode == null) {
				Cookie storedIECProductCode = ApexPages.currentPage().getCookies().get('IECProductCode');
				if (ApexPages.currentPage().getParameters().containsKey(IECConstants.PARAM_PRODUCT_CODE)) {
					sProductCode = IECUtil.DecodeDecryptParameter(ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODUCT_CODE));
					storedIECProductCode = new Cookie('IECProductCode',sProductCode,null,-1,false);
				} else if (storedIECProductCode != null) {
					sProductCode = (String)storedIECProductCode.getValue();
				}

				ApexPages.currentPage().setCookies(new Cookie[]{storedIECProductCode});
			}
			return sProductCode;
	}
		private set;
  }
   public void defaultproduct()
	{
		sProductCode='GAD';
		ctrSubsInfo.sApplicationName = sProductCode;
	}
	/**
	 * Constructor Method
	 **/
	public vfIECGADAdvanced() {
		//Initilize subscription component
		ctrSubsInfo = new vfIECSubscriptionInfo();
		ctrSubsInfo.loggedCustomer = loggedCustomer;
		ctrSubsInfo.sApplicationName = sProductCode;

		ctrSavedFilters = new vfIECSavedFilters();
		ctrSavedFilters.loggedCustomer = loggedCustomer;


	  bDisplayError = false;
	  sErrorMessage = '';
		clearFilter();

		lstErrorMessage = new list<string>();
	}

	public Pagereference pageLoad() {
		// first check if the user is logged in
		try {
			if (IECUserManager.isUserLoggedIn() == false) {
				Pagereference prLogin = Page.IECLogin;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
				prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				prLogin.setRedirect(true);
				return prLogin;
			}
			else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				// Make sure to validate user access to application subscription
				ctrSubsInfo.validateAccess(new Set<String>{'GAD', 'PAL', 'ASL', 'CAL'});

				// if no access, redirect to the unauthorized page
		if (!ctrSubsInfo.hasPageAccess)
		  return Page.IECUnauthorized;

				//Load Saved filters
				ctrSavedFilters.loadFilters(sProductCode);

				sParamFilterId = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_APPFILTER_ID);

				if (!String.isBlank(sParamFilterId)) {
				// Decrypt parameter before using it
		  sParamFilterId = IECUtil.DecodeDecryptParameter(sParamFilterId);

		  filter = IECApplicationsManager.LoadFilterById(sParamFilterId);

		  if (filter == null) {
			clearFilter();
		  }
		  else {
			bLoadLocationFilter = bLoadTypeFilter = true;
		  }
				}
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		return null;
	}

	public PageReference saveFilter() {
		try {
		  bDisplayError = false;

			if (ctrSavedFilters.lstSavedFilters.size() >= 5)
				addErrorMessage(Label.IEC_Error_Maximum5Filters);
			else {
			  CleanupFilterBeforeSave();
				filter.Id = null;
				filter.Related_Contact__c = loggedCustomer.RelatedContact.Id;
				filter.System_Generated__c = false;
				filter.Filter_Type__c = 'Advanced';
				filter.Product_Line__c=sProductCode;

				insert filter;

				PageReference pgRef = NavigateToResult();

				if (pgRef == null)
				  delete filter;
				else
				  ctrSavedFilters.loadFilters(sProductCode);

				return pgRef;
			}
		}
		catch (Exception e) {
			addErrorMessage('Could not save filter with error: ' + e.getMessage() + e.getStackTraceString());
		}

		return null;
	}

	public void OnChangeCountry() {
		// Disable state if multiple country is selected
	bDisableState = sCountry.size() > 1;
	}

	/**
	 * Gets list options for Sub Continent picklist
	 **/
	public List<SelectOption> getListOptionsSubContinent() {
		List<SelectOption> options = new List<SelectOption>();

		try {
			if (setSubContinent == null){
				setSubContinent = new Set<String>();

				for (GDP_Geo_Detail__c gdpGeoDetail :
				  [SELECT Sub_Continent__c
				  FROM GDP_Geo_Detail__c]) {
					setSubContinent.add(gdpGeoDetail.Sub_Continent__c);
				}
			}

			if (setSubContinent.size() > 0)
			{
				bDisableState = false;
				options.add(new SelectOption('All', 'All'));
				// Sort the sub-continent list options alphabetically
				List<String> lstSubContinent = new List<String>();
				lstSubContinent.addAll(setSubContinent);
				lstSubContinent.sort();

				for(string s : lstSubContinent)
					options.add(new SelectOption(s, s));
			}
			else
				options.add(new SelectOption('None', '--None--'));

			if (!bLoadLocationFilter)
			  filter.Sub_Continent__c = options.get(0).getValue();
		}
		catch (Exception e) {
			addErrorMessage('Could not load Sub-Continents for the following error: ' + e.getMessage() + '\r\n' + e.getStackTraceString());
		}

		return options;
	}

	/**
	 * Gets list options for Country picklist
	 **/
	public List<SelectOption> getListOptionsCountry() {
		List<SelectOption> options = new List<SelectOption>();

		try {
			if (!String.isBlank(filter.Sub_Continent__c) && filter.Sub_Continent__c != 'None') {
				List<GDP_Geo_Detail__c> lstGDPGeoDetail = new List<GDP_Geo_Detail__c>();

				if (filter.Sub_Continent__c == 'All') {
					lstGDPGeoDetail =
						[SELECT IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c
						FROM GDP_Geo_Detail__c
						ORDER BY IATA_ISO_Country__r.Name];
				}
				else {
					lstGDPGeoDetail =
						[SELECT IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c
						FROM GDP_Geo_Detail__c
						WHERE Sub_Continent__c = :filter.Sub_Continent__c
						ORDER BY IATA_ISO_Country__r.Name];
				}

				if (lstGDPGeoDetail.size() > 0) {
					bDisableState = false;
					options.add(new SelectOption('All', 'All'));
					for(GDP_Geo_Detail__c gdpGeoDetail : lstGDPGeoDetail)
						options.add(new SelectOption(gdpGeoDetail.IATA_ISO_Country__r.ISO_Code__c, gdpGeoDetail.IATA_ISO_Country__r.Name));
				}
				else
					options.add(new SelectOption('None', '--None--'));
			}
			else
				options.add(new SelectOption('--Select Sub-Continent--', '--Select Sub-Continent--'));

			if (!bLoadLocationFilter)
			  filter.Country__c = options.get(0).getValue();
			if (!bLoadLocationFilter)
			  filter.State__c = 'All';
		}
		catch (Exception e) {
			addErrorMessage('Could not load Countries for the following error: ' + e.getMessage() + '\r\n' + e.getStackTraceString());
		}

		return options;
	}

	/**
	 * Gets list options for State picklist
	 **/
	public List<SelectOption> getListOptionsState() {
		String sCountry = RemoveBrackets(filter.Country__c);
		List<SelectOption> options = new List<SelectOption>();

		try {
			if (!bDisableState
				&& !String.isBlank(filter.Country__c)
				&& sCountry != 'None'
				&& sCountry != '--Select Sub-Continent--') {
				List<IATA_ISO_State__c> lstState = new List<IATA_ISO_State__c>();

				if (filter.Sub_Continent__c == 'All' && sCountry == 'All') {//RP: 07/12/2015 added Raymond Afara on the query - this is a temp solution, this needs to be reverted once the states requirement is defined and the data is cleaned
					lstState = [SELECT Name, ISO_Code__c
						FROM IATA_ISO_State__c where createdBy.Name = 'Raymond Afara'
						ORDER BY IATA_ISO_Country__r.Name desc, Name asc];
				}
				else if (filter.Sub_Continent__c != 'All' && sCountry == 'All') {//RP: 07/12/2015 added Raymond Afara on the query - this is a temp solution, this needs to be reverted once the states requirement is defined and the data is cleaned
					for (IATA_ISO_Country__c country:
						[SELECT Name
							, (SELECT Name, ISO_Code__c
								FROM IATA_ISO_States__r  where createdBy.Name = 'Raymond Afara'
								ORDER BY Name asc)
							, (SELECT Sub_Continent__c
								FROM IEC_Countries__r
								WHERE Sub_Continent__c = :filter.Sub_Continent__c)
						FROM IATA_ISO_Country__c
						ORDER BY Name desc]) {
						if (country.IEC_Countries__r != null && country.IEC_Countries__r.size() > 0) {
							lstState.addAll(country.IATA_ISO_States__r);
						}
					}
				}
				else {//RP: 07/12/2015 added Raymond Afara on the query - this is a temp solution, this needs to be reverted once the states requirement is defined and the data is cleaned
					lstState = [SELECT Name, ISO_Code__c
						FROM IATA_ISO_State__c
						WHERE IATA_ISO_Country__r.ISO_Code__c = :sCountry and createdBy.Name = 'Raymond Afara'
						ORDER BY Name asc];
				}

				if (lstState.size() > 0) {
					options.add(new SelectOption('All', 'All'));
					for(IATA_ISO_State__c state : lstState)
						options.add(new SelectOption(state.ISO_Code__c, state.Name));
				}
				else
					options.add(new SelectOption('All', '--None--'));
			}
			else
				options.add(new SelectOption('All', '--Select Only One Country--'));

			if (!bLoadLocationFilter)
			  filter.State__c = options.get(0).getValue();
		}
		catch (Exception e) {
			addErrorMessage('Could not load States for the following error: ' + e.getMessage() + '\r\n' + e.getStackTraceString());
		}

		// Reset the load flag
		bLoadLocationFilter = false;

		return options;
	}

	/**
	 * Gets list options for Area of Activity picklist
	 **/
	public List<SelectOption> getListOptionsAreaofActivity() {
		List<SelectOption> options = new List<SelectOption>();

		try {
			Set<String> setAreaofActivity = new Set<String>();
			for (IEC_Agency_Type__c agencyType :
				[SELECT Area_of_Activity__c
						,Agency_Program_Code__c
				FROM IEC_Agency_Type__c]) {
				if (sProductCode == 'GAD' && agencyType.Agency_Program_Code__c=='C') continue;
				if (sProductCode == 'PAL' && !(agencyType.Agency_Program_Code__c=='P'
											|| agencyType.Agency_Program_Code__c=='D'
											))  continue;
				if (sProductCode == 'CAL' && agencyType.Agency_Program_Code__c!='C') continue;
				if (sProductCode == 'ASL' && !(agencyType.Agency_Program_Code__c=='M'
											|| agencyType.Agency_Program_Code__c=='X'
											|| agencyType.Agency_Program_Code__c=='K'
											|| agencyType.Agency_Program_Code__c=='G'
											))  continue;
				setAreaofActivity.add(agencyType.Area_of_Activity__c);
			}

			if (setAreaofActivity.size() > 0) {
				if (sProductCode == 'GAD') options.add(new SelectOption('All', 'All'));
				if (sProductCode == 'ASL') options.add(new SelectOption('All', 'All'));

				// Sort the area of activity list options alphabetically
				List<String> lstAreaofActivity = new List<String>();
				lstAreaofActivity.addAll(setAreaofActivity);
				lstAreaofActivity.sort();
				for(string s : lstAreaofActivity)
					options.add(new SelectOption(s, s));
			}
			else
				options.add(new SelectOption('None', '--None--'));

			if (!bLoadTypeFilter)
			  filter.Area_of_Activity__c = options.get(0).getValue();
		}
		catch (Exception e) {
			addErrorMessage('Could not load Area of Activity for the following error: ' + e.getMessage() + '\r\n' + e.getStackTraceString());
		}

		return options;
	}

	/**
	 * Gets list options for Agency Program picklist
	 **/
	public List<SelectOption> getListOptionsAgencyProgram() {
		List<SelectOption> options = new List<SelectOption>();

		try {
			if (!String.isBlank(filter.Area_of_Activity__c) && filter.Area_of_Activity__c != 'None') {
				List<IEC_Agency_Type__c> lstAgencyProgram = new List<IEC_Agency_Type__c>();

				if (filter.Area_of_Activity__c == 'All') {
					lstAgencyProgram =
						[SELECT Agency_Program__c, Agency_Program_Code__c
						FROM IEC_Agency_Type__c
						ORDER BY Agency_Program__c];
				}
				else {
					lstAgencyProgram =
					  [SELECT Agency_Program__c, Agency_Program_Code__c
						FROM IEC_Agency_Type__c
						WHERE Area_of_Activity__c = :filter.Area_of_Activity__c
						ORDER BY Agency_Program__c];
				}

				if (lstAgencyProgram.size() > 0) {
					bDisableState = false;
					options.add(new SelectOption('All', 'All'));
					for(IEC_Agency_Type__c agType : lstAgencyProgram)
					{
						//if (sProductCode == 'CAL') continue;
						if (sProductCode == 'PAL' && !(agType.Agency_Program_Code__c=='D'
											|| agType.Agency_Program_Code__c=='P'
											))  continue;
						if (sProductCode == 'ASL' && filter.Area_of_Activity__c == 'All'
												 && (agType.Agency_Program_Code__c=='C'
													 || agType.Agency_Program_Code__c=='D'
													 || agType.Agency_Program_Code__c=='P'
													 || agType.Agency_Program_Code__c=='T'
													 || agType.Agency_Program_Code__c=='V'
													 )) continue;
						options.add(new SelectOption(agType.Agency_Program_Code__c, agType.Agency_Program__c));
					}
				}
				else
					options.add(new SelectOption('None', '--None--'));
			}
			else
				options.add(new SelectOption('--Select Area of Activity--', '--Select Area of Activity--'));

			if (!bLoadTypeFilter)
			  filter.Agency_Program__c = options.get(0).getValue();
		}
		catch (Exception e) {
			addErrorMessage('Could not load Agency Programs for the following error: ' + e.getMessage() + '\r\n' + e.getStackTraceString());
		}

		// Reset the load flag
		bLoadTypeFilter = false;

		return options;
	}

	/**
	 * Reset the filters on the page
	 **/
	public void clearFilter() {
	  bLoadLocationFilter = bLoadTypeFilter = bDisableState = false;
		filter = new IEC_Application_Filter__c(
			Agency_Name_Search_Condition__c = 'Both'
			, Area_of_Activity__c = 'All'
			, Hierarchy__c = 'All'
			, Sub_Continent__c = 'All'
			, Product_Line__c = sProductCode);
	}

	/**
	 * Reset the filters on the page
	 **/
  public Pagereference searchAgencies() {
	try {
	  bDisplayError = false;

	  if (IECApplicationsManager.isApplicationFilterEmpty(filter))
		throw new IECApplicationException(Label.IEC_Error_One_Filter_Required);

	  CleanupFilterBeforeSave();
	  if (filter.Id == null) {
		List<IEC_Application_Filter__c> sysFilter = IECApplicationsManager.LoadFilterByContact(sProductCode, loggedCustomer.RelatedContact.Id, true);


		if (sysFilter.size() > 0)
		{
		  //delete sysFilter;
		  filter.Id = sysFilter[0].Id;
		}
		filter.Related_Contact__c = loggedCustomer.RelatedContact.Id;
		filter.System_Generated__c = true;
		filter.Filter_Type__c = 'Advanced';
		filter.IATA_Code__c = '';
		filter.Product_Line__c = sProductCode;
		upsert filter;
	  }
	  else {
		//just in case iata code is entered in basic search this will clear it
		filter.IATA_Code__c = '';
		filter.Product_Line__c = sProductCode;
		update filter;
	  }
	  return NavigateToResult();
	}
	catch(Exception ex) {
	  addErrorMessage(ex.getMessage());
	}

	return null;
  }

  private PageReference NavigateToResult() {

	//check if records returned is more than 250 or zero
		Integer searchCount = IECApplicationsManager.getNumberOfResultsByAppFilterID(loggedCustomer, filter.Id, sProductCode);

		if (searchCount > vfIECGAD.MAX_RESULTS) {
		bDisplayError = true;
		sErrorMessage = Label.IEC_Error_SearchCount250;
	  return null;
		}
		else if (searchCount == 0) {
		bDisplayError = true;
		sErrorMessage = Label.IEC_Error_SearchCount0;
	  return null;
		}

	Pagereference pgRef = Page.IECGADResult;
	pgRef.getParameters().put(IECConstants.PARAM_APPFILTER_ID, IECUtil.EncryptEncodeParameter(filter.Id));
		pgRef.getParameters().put(IECConstants.PARAM_LIMITTOIDS, IECUtil.EncryptEncodeParameter(String.join(IECApplicationsManager.cachedAgencyIds, ','))); // Added by Mathieu Beausoleil
	pgRef.setRedirect(true);
	return pgRef;
  }

  private String RemoveBrackets(String s) {
	if (s.indexOf('(') == 0 || s.indexOf('[') == 0)
	  return s.substring(1, s.length()-1);
	else
	  return s;
  }

  private void CleanupFilterBeforeSave() {
	System.debug('SSS: filter.Hierarchy__c: ' + filter.Hierarchy__c);
	if (filter.Agency_Program__c.indexOf('All') != -1) filter.Agency_Program__c = '(All)';
	if (filter.Country__c.indexOf('All') != -1) filter.Country__c = '(All)';
	if (filter.Hierarchy__c.indexOf('All') != -1) filter.Hierarchy__c = 'All';
	if (filter.State__c.indexOf('All') != -1) filter.State__c = '(All)';
	System.debug('SSS: filter.Hierarchy__c: ' + filter.Hierarchy__c);
  }

  public void onClickOKError() {
	  bDisplayError = false;
	  sErrorMessage = '';
  }
}
