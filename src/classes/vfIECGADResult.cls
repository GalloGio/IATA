/**  
  * Description: This class contains the controller for the Visualforce page Global Agency Directory results 
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
public without sharing class vfIECGADResult extends IECPageController {

	private static Integer DEFAULT_NBR_OF_RECORDS_PER_PAGE = 10;

	public Integer iNBR_RECORDS_PER_PAGE { get; set; }

    public vfIECSubscriptionInfo 	ctrSubsInfo		    {get; set;}
    public vfIECSavedFilters 		ctrSavedFilters     {get; set;}

	public String sParamIECApplicationFiltersID {get; set;}
    public String sParamIECApplicationLimitToIDs {get; set;} // Added by Mathieu Beausoleil
	public String sIECApplicationFiltersID {get; set;}
	public IEC_Application_Filter__c oApplicationFilters { get; private set; }
	public List<GDP_Products_Account_View__c> lstAgencies { get; private set; }
	public String sAgencyIDToViewDetail {get; private set;}
	public Integer iTotalResult { get; private set;}
	public Integer iTotalPage { get; private set;}
	public Integer iCurrentAgencyIndex { get; private set;}
	public Integer iCurrentPageIndex { get; private set;} // 0 to iTotalPage-1
	public String sSelectedAgencyId { get; set; }
	public Map<String, String> mapListIndexAndAgencyID { get; private set; }
	public Map<String, String> mapAreaOfActivityByCode {get; private set;}
    //Ashok
    public List<GSA_Territory__c> territoryListToDisplay { get;set;}
    public boolean displayAgentsTab{get;private set;}    
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

	public Boolean bPreviousPageIsEnabled {
		get {
			return (iCurrentPageIndex > 0);
		}
	}
	public Boolean bNextPageIsEnabled {
		get {
			return (iCurrentPageIndex != -1 && iCurrentPageIndex + 1 < iTotalPage);
		}
	}
	
	public Boolean bPreviousAgencyIsEnabled {
		get {
			return (iCurrentAgencyIndex > 0);
		}
	}
	public Boolean bNextAgencyIsEnabled {
		get {
			return (iCurrentAgencyIndex != -1 && iCurrentAgencyIndex + 1 < iTotalResult);
		}
	}
	
	public String sTextRepresentationOfFilters {
		get {
			if (String.isBlank(sTextRepresentationOfFilters)) {
//				try {
				sTextRepresentationOfFilters = (oApplicationFilters == null ? '' : IECApplicationsManager.getStringRepresentationOfApplicationFilter(oApplicationFilters.Id));
/*				}
				catch (Exception e) {
					return null;
				}*/
			}
			return sTextRepresentationOfFilters;
		}
		set;
	}
	
	public Boolean bShowStateProvinceColumn {
		get {
			return (oApplicationFilters != null && String.isNotblank(oApplicationFilters.State__c) && !oApplicationFilters.State__c.startsWith('--') && oApplicationFilters.State__c != '(All)'
				&& oApplicationFilters.State__c != 'All' && oApplicationFilters.State__c != 'None' && oApplicationFilters.State__c != 'null');
		}
	}
	
	public Boolean bShowCityColumn {
		get {
			return oApplicationFilters != null && String.isNotblank(oApplicationFilters.City__c);
		}
	}
	
	public Boolean bShowZipPostalCodeColumn {
		get {
			return oApplicationFilters != null && String.isNotblank(oApplicationFilters.Zip_Code__c);
		}
	}
	
	public Boolean bShowLegalName {
		get {
			return (oApplicationFilters == null ? false : oApplicationFilters.Agency_Name_Search_Condition__c == 'Legal Name');
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

	/**
	 * Constructor
	 */
	public vfIECGADResult() {
	 	this(DEFAULT_NBR_OF_RECORDS_PER_PAGE);
	}
   	public vfIECGADResult(Integer iNbrResultsPerPage) {
   		
        //Initilize subscription component        
        ctrSubsInfo = new vfIECSubscriptionInfo(); 
        ctrSubsInfo.loggedCustomer = loggedCustomer;
        ctrSubsInfo.sApplicationName = sProductCode;
        
        ctrSavedFilters = new vfIECSavedFilters();
        ctrSavedFilters.loggedCustomer = loggedCustomer;   
   		
   		oApplicationFilters = null;
   		lstAgencies = null;
   		iCurrentPageIndex = -1;
   		iCurrentAgencyIndex = -1;
   		
   		iNBR_RECORDS_PER_PAGE = (iNbrResultsPerPage != null && iNbrResultsPerPage > 0 ? iNbrResultsPerPage : DEFAULT_NBR_OF_RECORDS_PER_PAGE);
    
        // Added by Ashok
        displayAgentsTab = false;
        
   	}
   	
    private void fillAreOfActivityMap() {
        mapAreaOfActivityByCode = new Map<String, String>();
        if (sProductCode == 'ASL') {
            mapAreaOfActivityByCode.put('M', 'Member Sales Offices');
            mapAreaOfActivityByCode.put('G', 'General Sales Agents');
            mapAreaOfActivityByCode.put('X', 'Handling Agents and Shipping Lines');
            mapAreaOfActivityByCode.put('K', 'Combined Airlines Ticket Office CATO');
        } else if (sProductCode == 'CAL') {
            mapAreaOfActivityByCode.put('C', 'Cargo');
        } else if (sProductCode == 'PAL') {
            mapAreaOfActivityByCode.put('P', 'Passenger');
            mapAreaOfActivityByCode.put('D', 'Domestic');
        } else {
            mapAreaOfActivityByCode.put('D', 'Travel Agency');
            mapAreaOfActivityByCode.put('E', 'Travel Agency');
            mapAreaOfActivityByCode.put('K', 'Travel Agency');
            mapAreaOfActivityByCode.put('N', 'Travel Agency');
            mapAreaOfActivityByCode.put('O', 'Travel Agency');
            mapAreaOfActivityByCode.put('F', 'Travel Agency');
            mapAreaOfActivityByCode.put('P', 'Travel Agency');
            mapAreaOfActivityByCode.put('T', 'Travel Agency');
            mapAreaOfActivityByCode.put('S', 'Travel Agency');
            mapAreaOfActivityByCode.put('V', 'Travel Agency');
            mapAreaOfActivityByCode.put('G', 'General Sales Agent');
            mapAreaOfActivityByCode.put('M', 'Airline Sales Office');
            mapAreaOfActivityByCode.put('X', 'Airline Sales Office');
        }
    }
   	
   	/**
   	 * Triggered once the page is loaded
   	 */
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
				
				fillAreOfActivityMap();				

				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

                // Make sure to validate user access to application subscription
                ctrSubsInfo.validateAccess(new Set<String>{'GAD', 'CAL', 'PAL', 'ASL'}); 
                
                // if no access, redirect to the unauthorized page
				if (!ctrSubsInfo.hasPageAccess)
					return Page.IECUnauthorized;

                //Load Saved filters
                ctrSavedFilters.loadFilters(sProductCode);


				sParamIECApplicationFiltersID = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_APPFILTER_ID);
                sParamIECApplicationLimitToIDs = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_LIMITTOIDS); // Added by Mathieu Beausoleil

				// Validate that there is parameter passed to the page
				if (String.isBlank(sParamIECApplicationFiltersID)) {
					addErrorMessage(Label.IEC_Error_InvalidPageParameter);
				}
				else {
					
					// Decrypt parameter before using it
					sIECApplicationFiltersID = IECUtil.DecodeDecryptParameter(sParamIECApplicationFiltersID);
					
					// gets the Application Filter
					oApplicationFilters = IECApplicationsManager.LoadFilterById(sIECApplicationFiltersID);
					if (oApplicationFilters == null) {
						return Page.IECGADAdvanced;
						//throw new IECApplicationException(Label.IEC_Error_InvalidPageParameter);
					}

					// run the search
                    lstAgencies = IECApplicationsManager.customerSearchAgencyByAdvancedFilters(oApplicationFilters, sProductCode, loggedCustomer); 
                    // if list of ids available, use it
                    if (!String.isBlank(sParamIECApplicationLimitToIDs)) {
                    	sParamIECApplicationLimitToIDs = IECUtil.DecodeDecryptParameter(sParamIECApplicationLimitToIDs);
                    	IECApplicationsManager.cachedAgencyIds = sParamIECApplicationLimitToIDs.split(',');
                    }

				
					//Update usage counter (UI Only)
					ctrSubsInfo.dUnitsConsumed++;
					if (ctrSubsInfo.iUsageLeft > 0) 
						ctrSubsInfo.iUsageLeft--;



					iTotalResult = (lstAgencies == null ? 0 : lstAgencies.size());
					
					// build map to keep track of what is the list index of each agency
					mapListIndexAndAgencyID = new Map<String, String>();
					Integer iListIndex = 0;
					for (GDP_Products_Account_View__c iAgency : lstAgencies) {
						mapListIndexAndAgencyID.put(iAgency.Id, String.valueOf(iListIndex));
						iListIndex++;
					}
					
					// if 1 result, show agency detail page
                    if (lstAgencies != null && lstAgencies.size() == 1) 
                    {
						sAgencyIDToViewDetail = lstAgencies.get(0).Id;
						iCurrentAgencyIndex = 0;
                        
                        // Added by Ashok
                        fetchGSATerritoryList(lstAgencies.get(0).Id);
                        
                                                
					}
					// 0 or more than 1 agency found, show list
					else {
						iCurrentPageIndex = 0;
						system.debug('ALEX - lstAgencies.size(): ' + lstAgencies.size());
						system.debug('ALEX - iNBR_RECORDS_PER_PAGE: ' + iNBR_RECORDS_PER_PAGE);
						Decimal d = Decimal.valueOf(lstAgencies.size()) / Decimal.valueOf(iNBR_RECORDS_PER_PAGE);
						system.debug('ALEX - d: ' + d);
						iTotalPage = Integer.valueOf(d.round(system.roundingMode.CEILING));
						system.debug('ALEX - iTotalPage: ' + iTotalPage);
					}
				}
			}

			return null;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
			return null;
		}
   	}
   
	/** 
	 * Selects an agency from the list and display the agency detail component
	 */
	public void selectAgency() {
		try {
			sAgencyIDToViewDetail = sSelectedAgencyId;
			
            // Added by Ashok
            fetchGSATerritoryList(sSelectedAgencyId); 
           
			// get the list index associated to this agency
			iCurrentAgencyIndex = Integer.valueOf(mapListIndexAndAgencyID.get(sAgencyIDToViewDetail));
		}
		catch (Exception ex) {
   			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
   		}
	}
	
	/** 
	 * From the agency detail view, browse to the previous agency
	 */
	public void previousAgency() {
		try {
			if (iCurrentAgencyIndex == 0)
				throw new IECApplicationException('Invalid record index');
			
			iCurrentAgencyIndex--;
            
            // Added by Ashok
             fetchGSATerritoryList(lstAgencies.get(iCurrentAgencyIndex).Id);            
			sAgencyIDToViewDetail = lstAgencies.get(iCurrentAgencyIndex).Id;
		}
		catch (Exception ex) {
   			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
   		}
	}
	
	/** 
	 * From the agency detail view, browse to the next agency
	 */
	public void nextAgency() {
		try {
			if (iCurrentAgencyIndex >= lstAgencies.size())
				throw new IECApplicationException('Invalid record index');
			
			iCurrentAgencyIndex++;
            // Added by Ashok
            fetchGSATerritoryList(lstAgencies.get(iCurrentAgencyIndex).Id);
			sAgencyIDToViewDetail = lstAgencies.get(iCurrentAgencyIndex).Id;
		}
		catch (Exception ex) {
   			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
   		}
	}
	
	/** 
	 * From the agency list view, browse to the previous page
	 */
	public void previousPage() {
		try {
			if (iCurrentPageIndex == 0)
				throw new IECApplicationException('Invalid paging index');
			iCurrentPageIndex--;
		}
		catch (Exception ex) {
   			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
   		}
	}
	
	/** 
	 * From the agency list view, browse to the next page
	 */
	public void nextPage() {
		try {
			if (iCurrentPageIndex + 1 >= iTotalPage)
				throw new IECApplicationException('Invalid paging index');
			iCurrentPageIndex++;
		}
		catch (Exception ex) {
   			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
   		}
	}
	
	/** 
	 * From the agency detail page, go to the list view
	 */
	public void backToResultList() {
		try {
			sAgencyIDToViewDetail = null;
			iCurrentAgencyIndex = 0;
		}
		catch (Exception ex) {
   			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
   		}
	}
	
	/**
	 * Redirect to the basic search page or the advanced search page to edit the Application Filter
	 * @return The page to redirect to (GAD home page or GAD Advanced search page)
	 */
	public PageReference backToSearchPage() {
		try {
			if (oApplicationFilters == null || oApplicationFilters.Filter_Type__c == 'Basic')
				return Page.IECGAD;
			else {
				Pagereference prAdvancedSearch = Page.IECGADAdvanced;
				if (oApplicationFilters != null && oApplicationFilters.Id != null)
					prAdvancedSearch.getParameters().put(IECConstants.PARAM_APPFILTER_ID, IECUtil.EncryptEncodeParameter(oApplicationFilters.Id));
				return prAdvancedSearch;
			}
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
			return null;
		}
	}
    
    // Added By Ashok , Method to get GSA Territories
    /************************************************************************
    @ Last modified by: Bhargavi Rayavarapu
    @ Last modified date : 2016 - 03 - 23
    @ Description : For the Product Account selected/searched for, get all the teritories where the Accrediation is General Sales Agent
    *****************************************************************************/
    public void fetchGSATerritoryList(id GDPProductAccountId)
    {
        territoryListToDisplay = new List<GSA_Territory__c>();
        system.debug('ProductAccountID**'+GDPProductAccountId);
        
        if(GDPProductAccountId !=null)
        {
            	territoryListToDisplay = [select id, Name, Related_GDP_Products_Account_View__r.name, Related_Accreditation__r.name,
            	         Airline_Code__c,Airline_Name__c,Territory_ISO_Country__c,Appointment_Date__c,Territory_Description__c
                         from GSA_Territory__c 
                         where Related_Accreditation__r.Related_GDP_Products_Account_View__c = : GDPProductAccountId 
                         and Related_Accreditation__r.Related_GDP_Products_Account_View__r.Accreditation_Class__c = 'General Sales Agent'];              
          
               	if([select Accreditation_Class__c 
               	    from  GDP_Products_Account_View__c 
               	    where id =: GDPProductAccountId].Accreditation_Class__c == 'General Sales Agent')
               	{
                  	displayAgentsTab  = true;
               	}
               	else
               	{
                 	displayAgentsTab   = false;
               	} 
               	// Added by Bhargavi: If no territories are retured for the specified search criteria, then display the message instead of the table
        		if(!(territoryListToDisplay.size()>0))   
               	{
               		territoryListToDisplay = null;
               	}        
        }
    }
    
    public Boolean getHasEBCAccess() {
    	if (ctrSubsInfo==null) return false;
    	if (ctrSubsInfo.loggedCustomer==null) return false;
    	if (ctrSubsInfo.loggedCustomer.RelatedBillingAccount==null) return false;
    	if (ctrSubsInfo.loggedCustomer.RelatedBillingAccount.eBroadcast_Product_Access__c==null) return false;

    	return ctrSubsInfo.loggedCustomer.RelatedBillingAccount.eBroadcast_Product_Access__c;
    }
    
    public PageReference createEBCMailing() {
    	EBC_Master_Filter__c mf = new EBC_Master_Filter__c();
    	mf.Name = 'Audience from GAD Search ' + Datetime.now();
    	mf.Audience__c = 'Custom';
    	mf.Billing_Account__c = ctrSubsInfo.loggedCustomer.RelatedBillingAccount.Id;
    	
    	List<String> codes = new List<String>();
    	for(GDP_Products_Account_View__c gpav : lstAgencies) {
    		codes.add(gpav.IATA_Code__c);
    	}
    	mf.IATA_Codes__c = String.join(codes, ';');
    	insert mf;
    	
    	PageReference pr = new PageReference('/iec/IECEBC_Campaign');
    	pr.setRedirect(true);
    	
    	return pr;
    }
}