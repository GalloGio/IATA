public without sharing class vfIECGADMaps extends IECPageController {



	//Display variables
	public boolean isWW               {get; set;}
	public boolean isCA               {get; set;}
	public boolean isUS               {get; set;}
	public boolean isAU               {get; set;}

	public vfIECSubscriptionInfo    ctrSubsInfo         {get; set;}

	//Handle data elements at level page (setting parameters)
	private String useAgencies = 'no';
	private String useEmails = 'no';
	private String useFlags = 'no';


	//**************************************************************************
	//Page references built with parameters
	//**************************************************************************
	private void clearMaps() {
	   isWW = false;
	   isCA = false;
	   isUS = false;
	   isAU = false;
	}

	public vfIECGADMaps() {
		clearMaps();
		isWW = true;
		useAgencies = 'yes';
		useEmails = 'no';
		useFlags = 'yes';


		if(loggedCustomer != null)
		{
			 //Initilize subscription component
			ctrSubsInfo = new vfIECSubscriptionInfo();
			ctrSubsInfo.loggedCustomer = loggedCustomer;
			ctrSubsInfo.sApplicationName = IECConstants.ProductCategory_SF_GAD;

			// Validate Logged in user profile and ensure profile is complete
			validUserProfile();

			// Make sure to validate user access to application subscription
			 ctrSubsInfo.validateAccess();
		}

	}


	public Pagereference WWMap() {
		clearMaps();
		isWW = true;
		useAgencies = 'yes';
		useEmails = 'no';
		useFlags = 'yes';
		return null;
	}

	public Pagereference AUMap() {
		clearMaps();
		isAU = true;
		useAgencies = 'yes';
		useEmails = 'no';
		useFlags = 'no';
		return null;
	}

	public Pagereference USMap() {
		clearMaps();
		isUS = true;
		useAgencies = 'yes';
		useEmails = 'no';
		useFlags = 'no';
		return null;
	}

	public Pagereference CAMap() {
		clearMaps();
		isCA = true;
		useAgencies = 'yes';
		useEmails = 'no';
		useFlags = 'no';
		return null;
	}


	public Pagereference WWMapEmail() {
		clearMaps();
		isWW = true;
		useAgencies = 'no';
		useEmails = 'yes';
		useFlags = 'yes';
		return null;
	}

	public Pagereference AUMapEmail() {
		clearMaps();
		isAU = true;
		useAgencies = 'no';
		useEmails = 'yes';
		useFlags = 'no';
		return null;
	}

	public Pagereference USMapEmail() {
		clearMaps();
		isUS = true;
		useAgencies = 'no';
		useEmails = 'yes';
		useFlags = 'no';
		return null;
	}

	public Pagereference CAMapEmail() {
		clearMaps();
		isCA = true;
		useAgencies = 'no';
		useEmails = 'yes';
		useFlags = 'no';
		return null;
	}


   public PageReference buildPagereference(String pageURL) {
		Pagereference pageMap = new PageReference(Site.getBaseUrl()  +  pageURL);
		pageMap.getParameters().put(IECConstants.PARAM_SHOWMAPSAGENCIES, useAgencies);
		pageMap.getParameters().put(IECConstants.PARAM_SHOWMAPSEMAILS, useEmails);
		pageMap.getParameters().put(IECConstants.PARAM_SHOWMAPSFLAGS, useFlags);

		return pageMap;
   }

	public PageReference wwAgenciesPage {get {return buildPagereference( Page.IECGADMapsWW.getUrl() );}}
	public PageReference auAgenciesPage {get {return buildPagereference( Page.IECGADMapsAU.getUrl() );}}
	public PageReference caAgenciesPage {get {return buildPagereference( Page.IECGADMapsCA.getUrl() );}}
	public PageReference usAgenciesPage {get {return buildPagereference( Page.IECGADMapsUS.getUrl() );}}



}
