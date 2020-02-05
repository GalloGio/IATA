/*
	* Controller for the IECGDPFooter, IECSiteFooter, IECSiteHeader components.
	*
	* Description:
	*
	* History:
	*  - 20160727: bamboo deployment to prod.
	*  - 20160804-sl: merge from eBroadcast branch updates GDP-75,717,723 by Mathieu Beausoleil.
	*
	*/

public without sharing class VfIECSiteHeaderComponent {

	public Integer iNbrCartItems { get; private set;}

	public String sProdCACPro 	{get; set;}
	public String sProdGAD	 	{get; set;}
	public String sProdMDP		{get; set;}
	public String sProdGSS 		{get; set;}
	//public String sProdCACWeb 	{get; set;}
	public String sProdEBro 	{get; set;}

	public Boolean bAvailCACPro 	{get; set;}
	public Boolean bAvailGAD		{get; set;}
	public Boolean bAvailMDP		{get; set;}
	public Boolean bAvailGSS 		{get; set;}
	//public Boolean bAvailCACWeb 	{get; set;}
	public Boolean bAvailEBro 		{get; set;}

	public Decimal shoppingCartTotalBeforeTax {get; private set;}
	public Decimal shoppingCartTax {get; private set;}
	public Decimal shoppingCartTotal {get; private set;}

	public String sContactEmail { get { return IEC_Settings__c.getOrgDefaults().IEC_Contact_Us_Email__c; } }
	public String sContactSubject { get { return IEC_Settings__c.getOrgDefaults().IEC_Contact_Us_Subject__c; } }

	public Boolean isUserLoggedIn {
		get {
			return IECUserManager.isUserLoggedIn();
		}
	}

	/**
	 * Constructor
	 */
	public VfIECSiteHeaderComponent(IECPageController controller) {
		init();
	}

	public VfIECSiteHeaderComponent() {
		try {
			init();

			Map<String, Boolean> mapProductCategoryAvailable = IECProductManager.isProductCategoryAvailable(new Set<String>
				{
					IECConstants.ProductCategory_SF_CACPRO
					, IECConstants.ProductCategory_SF_GAD
					, IECConstants.ProductCategory_SF_MDP
					, IECConstants.ProductCategory_SF_GSS
					//, IECConstants.ProductCategory_SF_CACWEB
					, IECConstants.ProductCategory_SF_EBROADCAST
				});

			bAvailCACPro = mapProductCategoryAvailable.get(IECConstants.ProductCategory_SF_CACPRO);
			bAvailGAD = mapProductCategoryAvailable.get(IECConstants.ProductCategory_SF_GAD);
			bAvailMDP = mapProductCategoryAvailable.get(IECConstants.ProductCategory_SF_MDP);
			bAvailGSS = mapProductCategoryAvailable.get(IECConstants.ProductCategory_SF_GSS);
			//bAvailCACWeb = mapProductCategoryAvailable.get(IECConstants.ProductCategory_SF_CACWEB);
			bAvailEBro = mapProductCategoryAvailable.get(IECConstants.ProductCategory_SF_EBROADCAST);

			shoppingCartTotalBeforeTax = 0.0;

			/*
			// get the current shopping cart (if any)
			IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getCurrentShoppingCart();

			if (cart != null)
				iNbrCartItems = cart.Total_Items_in_Cart__c.intValue();
			else
				iNbrCartItems = 0;
			*/

			refresh();
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}

	private void init() {
		//IEC_Settings__c.getOrgDefaults().Account_Owner_Id__c;
		sProdCACPro = IECUtil.DecodeDecryptParameter(IEC_Settings__c.getOrgDefaults().Prod_CACPro__c);
		sProdGAD 	= IECUtil.DecodeDecryptParameter(IEC_Settings__c.getOrgDefaults().Prod_GAD__c);
		sProdMDP 	= IECUtil.DecodeDecryptParameter(IEC_Settings__c.getOrgDefaults().Prod_MDP__c);
		sProdGSS 	= IECUtil.DecodeDecryptParameter(IEC_Settings__c.getOrgDefaults().Prod_GSS__c);
		//sProdCACWeb = IEC_Settings__c.getOrgDefaults().Prod_CACWeb__c;
		sProdEBro 	= IECUtil.DecodeDecryptParameter(IEC_Settings__c.getOrgDefaults().Prod_EBro__c);
	}

	public Pagereference refresh() {
		try {
			// get the current shopping cart (if any)
			IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getCurrentShoppingCart();

			if (cart != null)
				iNbrCartItems = cart.Total_Items_in_Cart__c.intValue();
			else
				iNbrCartItems = 0;

			//*************************

			List<IEC_Cart_Item__c> listCartItems = IECShoppingCartHelper.getCartItems(cart);
			IECCustomer loggedCustomer  = IECCustomer.getCurrentIECCustomer();

			// if cart is no empty
			if (listCartItems != null && listCartItems.size() > 0) {
				List<Zuora.zObject> listRatePlanDataObject = IECShoppingCartHelper.createRatePlanDataObjectFromCart(cart);
				Zuora.zObject invoice = IECSubscriptionManager.previewInvoice(listRatePlanDataObject, ((isUserLoggedIn) ? loggedCustomer.RelatedContact : null));

				shoppingCartTotalBeforeTax = (Decimal) invoice.getValue('AmountWithoutTax');
			}


			//*************************
			return null;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	/**
	 * Handles the logout link
	 */
	public Pagereference logout() {
		try {
			// delete shopping cart cookie
			IECCookieHelper.deleteShoppingCartCookie();

			//added 2016-01-11
			IECOrder_Svc.deleteAllCookies();
			Cookie Cookie_Sync = new Cookie('Cookie_Sync', '', null, 0, false);
			ApexPages.currentPage().setCookies(new Cookie[]{Cookie_Sync});

			PageReference pr = Page.IECLogout; //new PageReference('/secur/logout.jsp');
			pr.setRedirect(true);
			return pr;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}
}
