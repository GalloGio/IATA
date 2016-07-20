public with sharing class vfIECHomePage extends IECPageController {
  	public String sURLProdCACPro 	{get; set;}
	public String sURLProdCACWeb 	{get; set;}
	public String sURLProdGAD	 	{get; set;}
	public String sURLProdGSS 		{get; set;}
	public String sURLProdMDP		{get; set;}
	public String sURLProdEBro 		{get; set;}
	
  	public Boolean bProdAccessCACPro 	{get; set;}
	public Boolean bProdAccessGAD	 	{get; set;}
	public Boolean bProdAccessGSS 		{get; set;}
	public Boolean bProdAccessMDP		{get; set;}
	public Boolean bProdAccessEBro 		{get; set;}

	public Boolean bHasAnyProdAccess {
		get {
			return bProdAccessCACPro
				|| bProdAccessGAD
				|| bProdAccessGSS
				|| bProdAccessMDP
				|| bProdAccessEBro;
		}
	}

	public Boolean isUserLoggedIn {
		get {
			return IECUserManager.isUserLoggedIn();
		}
	}

	/**
	 * Constructor
	 */
	public vfIECHomePage() {
		sURLProdCACPro = IEC_Settings__c.getOrgDefaults().Prod_CACPro__c;
		sURLProdCACWeb = IEC_Settings__c.getOrgDefaults().Prod_CACWeb__c;
		sURLProdGAD 	= IEC_Settings__c.getOrgDefaults().Prod_GAD__c;
		sURLProdGSS 	= IEC_Settings__c.getOrgDefaults().Prod_GSS__c;
		sURLProdMDP 	= IEC_Settings__c.getOrgDefaults().Prod_MDP__c;
		sURLProdEBro 	= IEC_Settings__c.getOrgDefaults().Prod_EBro__c;		
	}	

	/**
	 * triggered when the page loads
	 */
	public void pageLoad() {
		if (isUserLoggedIn) {
			validUserProfile();
			
		  	bProdAccessCACPro = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_CACPRO) != -1);
			bProdAccessGAD = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_GAD) != -1);
			bProdAccessGSS = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_GSS) != -1);
			bProdAccessMDP = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_MDP) != -1);
			bProdAccessEBro = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_EBROADCAST) != -1);
		}		
	}
}