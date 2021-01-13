public without sharing class VfIECBrowseProducts extends IECPageController {

	public List<Product_Category__c> lstProductsToShow {get; private set;}

	public String selectedProductCategoryCode { set; get; }

	public Boolean isUserLoggedIn {
		get {
			return IECUserManager.isUserLoggedIn();
		}
	}

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


	/**
	 * Constructor
	 */
	public VfIECBrowseProducts() {
		try {

			lstProductsToShow = new List<Product_Category__c>();


			// on page load, get all available product categories
			List<Product_Category__c> lstTempAllProductCategories = IECProductManager.getAllProductsCategory();

			// for each product cateory in each product feature, add the product category only if there is at least 1 available product to the current user
			addProductCategoriesIfAtLeastOneProductAvailable(lstTempAllProductCategories, lstProductsToShow);

			if (isUserLoggedIn) {
					validUserProfile();
					bProdAccessCACPro = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_CACPRO) != -1);
					bProdAccessGAD = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_GAD) != -1);
					bProdAccessGSS = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_GSS) != -1);
					bProdAccessMDP = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_MDP) != -1);
					bProdAccessEBro = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_EBROADCAST) != -1);
			}

		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}


	/**
	 * For each given Product Category, check if the current user has access to at least 1 Product
	 * @param listUnfilteredProductCategories All product categories
	 * @param listFilteredProductCategory The target filtered product category list
	 */
	private void addProductCategoriesIfAtLeastOneProductAvailable(List<Product_Category__c> listUnfilteredProductCategories, List<Product_Category__c> listFilteredProductCategory) {

		// For each given Product Category, check if the current user has access to at least 1 Product
		for (Product_Category__c productCategory : listUnfilteredProductCategories) {

			// logged in user
			if (IECUserManager.isUserLoggedIn() && IECUserManager.getClientType() != null) {
				if (!IECProductManager.getProductInformationsByCategoryByClientType(productCategory.Name, IECUserManager.getClientType()).isEmpty())
					listFilteredProductCategory.add(productCategory);
				else if (!IECProductManager.getProductInformationsByCategoryForAnonymousUser(productCategory.Name).isEmpty()) {
					listFilteredProductCategory.add(productCategory);
				}
			}
			// anonymous user
			else {
				if (!IECProductManager.getProductInformationsByCategoryForAnonymousUser(productCategory.Name).isEmpty())
					listFilteredProductCategory.add(productCategory);
			}
		}
	}

	/**
	 * Redirects the user to the selected product category (product viewer page)
	 */
	public Pagereference browseToProductCategory() {
		try {
			Pagereference productViewerPage = Page.IECProductViewer;
			productViewerPage.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(selectedProductCategoryCode));
			productViewerPage.setRedirect(true);
			return productViewerPage;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	/**
	 * Redirects the user to the selected product category pricing
	 */
	public Pagereference browseToProductCategoryPricing() {
		try {
			Pagereference productViewerPage = Page.IECProductViewer;
			productViewerPage.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(selectedProductCategoryCode));
			productViewerPage.setAnchor('pricing');
			productViewerPage.setRedirect(true);
			return productViewerPage;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	public void pageLoad() {
		// Validate Logged in user profile and ensure profile is complete
		validUserProfile();
	}
}
