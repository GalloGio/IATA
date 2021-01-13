/**
	* Description: This class is the page controller for the component IECRatePlans
	* Author: Alexandre McGraw
	* Version: 1.0
	* History:
	*			2014-01-09: Added function to redirect to Trial Request page
	*/
public class VfIECRatePlansComponent {

	public String sProductCategoryCode {get; set;}
	public Boolean bDisplayPrice {get; set;}
	public String selectedRatePlanInformationId {get; set;}
	public Map<ID, Set<zqu__ProductRatePlanCharge__c>> mapRatePlanCharges { get; private set; }
	public Integer iColWidth {get; set;}

	public List<Product_Rate_Plan_Information__c> lstRatePlansInformation {
		get {
			return queryRatePlans();
		}
		private set;
	}

	public Integer iNbrRatePlans {
		get {
			return (lstRatePlansInformation == null ? 0 : lstRatePlansInformation.size());
		}
		private set;
	}

	/**
	 * Constructor
	 */
	public VfIECRatePlansComponent() {
		// can't do nothing
		lstRatePlansInformation = null;
	}

	/**
	 * Query and displays the rate plans
	 */
	private List<Product_Rate_Plan_Information__c> queryRatePlans() {
			try {

				iColWidth = 100;

			// check if the mandatory parameters where passed
			if (sProductCategoryCode == null || sProductCategoryCode == '')
				throw new IECApplicationException('Parameter ProductCategoryCode missing');

			List<Product_Information__c> listProdInfo = new List<Product_Information__c>();
			Product_Information__c oProductInformation = null;

			// get the user's client type
			String sClientType = IECUserManager.getClientType();

			// check if user is logged in
			if (IECUserManager.isUserLoggedIn() && sClientType != null) {

				listProdInfo = IECProductManager.getProductInformationsByCategoryByClientType(sProductCategoryCode, sClientType);

				// if no products are available for the specific Client Type
				if (listProdInfo.isEmpty()) {
					// get the products available for anonymous customers (product Audience 'Default')
					listProdInfo = IECProductManager.getProductInformationsByCategoryForAnonymousUser(sProductCategoryCode);
				}
			}
			else {
				// load available Product Information for anonymous users
				listProdInfo = IECProductManager.getProductInformationsByCategoryForAnonymousUser(sProductCategoryCode);
			}

			// No Product Information found
			if (listProdInfo.isEmpty()) {
				throw new IECApplicationException('Could not find any Product Information for category ' + sProductCategoryCode);
			}
			// Multiple Product Information found
			else if (listProdInfo.size() > 1) {
				// Should not happen...
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Multiple Product_Information__c found for category ' + sProductCategoryCode));
				return null;
			}
			// 1 Product Information found
			else {
				oProductInformation = listProdInfo.get(0);
			}

			// load the rateplans
			List<Product_Rate_Plan_Information__c> lstRatePlansInformation = IECProductManager.getProductRatePlansInformationByProductInformation(oProductInformation);

			// load the RatePlanCharges in the map
			mapRatePlanCharges = new Map<ID, Set<zqu__ProductRatePlanCharge__c>>();
			for (Product_Rate_Plan_Information__c ratePlanInformation : lstRatePlansInformation) {

				if (mapRatePlanCharges.containsKey(ratePlanInformation.Product_Rate_Plan__c) == false) {
					List<zqu__ProductRatePlanCharge__c> listRatePlanCharges = IECProductManager.getZuoraRatePlanChargesByRatePlanID(ratePlanInformation.Product_Rate_Plan__c);
					Set<zqu__ProductRatePlanCharge__c> setRatePlanCharges = new Set<zqu__ProductRatePlanCharge__c>();
					setRatePlanCharges.addAll(listRatePlanCharges);
					mapRatePlanCharges.put(ratePlanInformation.Product_Rate_Plan__c, setRatePlanCharges);
				}
			}

			iColWidth = (lstRatePlansInformation.size() > 0) ? 100/lstRatePlansInformation.size() : 100;
			return lstRatePlansInformation;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	public Pagereference addToCart() {
		try {
			IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getCurrentShoppingCart();

			// create shopping cart if not existing
			if (cart == null) {
				// create new shopping cart and save guid in cookie
				cart = IECShoppingCartHelper.createNewShoppingCart(IECUserManager.getContactId(), !IECUserManager.isUserLoggedIn());
			}

			// by default, quantity is 1
			IECShoppingCartHelper.addCartItem(cart, selectedRatePlanInformationId, 1);
				Pagereference prShoppingCart = Page.IECShoppingCart;
				prShoppingCart.setRedirect(true);
				return prShoppingCart;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	/**
	 * Redirects the user to the quote page with the selected product rate plan info
	 */
	public Pagereference getQuote() {
		try {
			Pagereference prQuotePage = Page.IECQuote;
				prQuotePage.getParameters().put(IECConstants.PARAM_RATEPLANINFO_ID, IECUTil.EncryptEncodeParameter(selectedRatePlanInformationId));
				prQuotePage.setRedirect(true);
				return prQuotePage;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	/**
	 * Redirects the user to the Trial page with the selected product rate plan info
	 */
	public Pagereference tryMe() {
		try {
				Pagereference prTrialRequest = Page.IECTrialRequest;
				prTrialRequest.getParameters().put(IECConstants.PARAM_RATEPLAN_ID, IECUTil.EncryptEncodeParameter(selectedRatePlanInformationId));
				prTrialRequest.setRedirect(true);
				return prTrialRequest;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}
}
