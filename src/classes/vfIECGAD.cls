/**
  * Description: This class contains the controller for the Visualforce page (Global Agency Directory - Advanced Search)
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */

public without sharing class vfIECGAD extends IECPageController {

   public static final Integer MAX_RESULTS = Integer.valueof(Label.IEC_GAD_Max_Results);//250;

	public vfIECSubscriptionInfo 	ctrSubsInfo		    {get; set;}
	public vfIECSavedFilters 		ctrSavedFilters     {get; set;}


	//Display variables
	public list<String> lstErrorMessage     {get; set;}
	public boolean bShowAgent               {get; set;}
	public boolean bShowAgency              {get; set;}
	public String sValidationCode           {get; set;}
	public String sCASSCode                 {get; set;}
	public Boolean bshowInvalidCode         {get; set;}
	public Boolean baskCASSCode             {get; set;}
	public Boolean bShowNoAgencyResults     {get; set;}
	public Boolean bShowNoAgentResults      {get; set;}

	public String sProdCACPro               {get; set;}

	public Boolean bIsValid                 {get; set;}
	public String sAgencyCode               {get; set;}
	public String sAgentCode                {get; set;}
	public IEC_Application_Filter__c filter     {get; set;}

	public boolean bDisplayError			{get; set;}
	public String sErrorMessage				{get; set;}

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

	public List<SelectOption> optAgencyNameSearchCondition {
		get {return IECApplicationsManager.GetListOptions(IEC_Application_Filter__c.Agency_Name_Search_Condition__c.getDescribe());}
	}

	public List<SelectOption> optAgencyNameSearchType {
		get {return IECApplicationsManager.GetListOptions(IEC_Application_Filter__c.Agency_Name_Search_Type__c.getDescribe());}
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

	/**
	 * Constructor Method
	 **/
	public vfIECGAD() {
		bDisplayError = false;
		sErrorMessage = '';
		filter = new IEC_Application_Filter__c(
			Agency_Name_Search_Condition__c = 'Both'
			,Agency_Name_Search_Type__c = 'Contains'
			, Area_of_Activity__c = 'All'
			, Hierarchy__c = 'All');

		filter.Product_Line__c = sProductCode;

		lstErrorMessage = new list<string>();

		//Initilize subscription component
		ctrSubsInfo = new vfIECSubscriptionInfo();
		ctrSubsInfo.loggedCustomer = loggedCustomer;
		ctrSubsInfo.sApplicationName = sProductCode;

		ctrSavedFilters = new vfIECSavedFilters();
		ctrSavedFilters.loggedCustomer = loggedCustomer;
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
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		return null;
	}



	 public Pagereference searchAgenciesCode() {
	 	bDisplayError = false;
		try {

			//Trim any leading or trailing spaces
			if (filter.IATA_Code__c != null)
				filter.IATA_Code__c = filter.IATA_Code__c.trim();

			//Validate numerica values only
			Pattern isnumbers = Pattern.Compile('^[0-9]+$');
			Matcher numMatch = isnumbers.matcher(filter.IATA_Code__c);

			if (sProductCode != 'CAL') {
				if(!numMatch.Matches()
					|| filter.IATA_Code__c.length() > 8
				|| filter.IATA_Code__c.length() < 7){
					addErrorMessage('IATA Code format must only be 7 or 8 digits');
					return null;
				}
			} else if(!numMatch.Matches()
				|| filter.IATA_Code__c.length() > 11
				|| filter.IATA_Code__c.length() < 7){
				addErrorMessage('IATA Agency Code format must only be between 7 and 11 digits');
				return null;
			}

			// reset all fields
			resetFilter();
			filter.Agency_Name__c = '';
			filter.Agency_Name_Search_Condition__c = 'Both';
			filter.Agency_Name_Search_Type__c = 'Contains';


		List<IEC_Application_Filter__c> sysFilter = IECApplicationsManager.LoadFilterByContact(sProductCode, loggedCustomer.RelatedContact.Id, true);
		 if (sysFilter.size() > 0)
			filter.Id = sysFilter.get(0).Id;

		  upsert filter;

		  return NavigateToResult();

		}
		catch(Exception ex) {
		  addErrorMessage(ex.getMessage());
		}

		return null;
  }


  private void resetFilter(){

				// reset all fields
				//filter.Agency_Name__c = '';
				//filter.Agency_Name_Search_Condition__c = '';
				//filter.Agency_Name_Search_Type__c = '';
				filter.Agency_Program__c = '';
				filter.Area_of_Activity__c = '';
				filter.City__c = '';
				filter.City_Search_Type__c = '';
				filter.Country__c = '';
				filter.Filter_Name__c = '';
				filter.Filter_Type__c = 'Basic';
				filter.Hierarchy__c = '';
				//filter.IATA_Code__c = '';
				filter.Related_Contact__c = loggedCustomer.RelatedContact.Id;
				filter.State__c = '';
				filter.Sub_Continent__c = '';
				filter.System_Generated__c = true;
				filter.Zip_Code__c = '';
				filter.Zip_Code_Search_Type__c ='';
	  			filter.Product_Line__c = sProductCode;
  }


	public Pagereference searchAgenciesName() {
		bDisplayError = false;
	  try {

	  		if(String.isEmpty(filter.Agency_Name__c))
	  			throw new IECApplicationException(Label.IEC_Error_One_Filter_Required);

		   // reset all fields
			resetFilter();
			filter.IATA_Code__c  = '';

			List<IEC_Application_Filter__c> sysFilter = IECApplicationsManager.LoadFilterByContact(sProductCode, loggedCustomer.RelatedContact.Id, true);
			if (sysFilter.size() > 0)
				filter.Id = sysFilter.get(0).Id;

			upsert filter;

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

		//Update usage counter (UI Only)
		ctrSubsInfo.dUnitsConsumed++;
		if (ctrSubsInfo.iUsageLeft > 0)
			ctrSubsInfo.iUsageLeft--;

		if (searchCount > MAX_RESULTS) {
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

	public void onClickOKError() {
		bDisplayError = false;
		sErrorMessage = '';
	}
}
