/**
	* Description: This class contains the controller for the Visualforce page (Product Viewer)
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
public with sharing class vfIECProductViewer extends IECPageController {
	// Parameters passed to the page
	public string sParamProductCode {get; set;}

	// Values used to render the product page
	public string sBannerImage {get; set;}
	public string sProductIcon {get; set;}
	public string sButtonType {get; set;}
	public boolean bTryButtonShow {get; set;}
	public string sDisplayName {get; set;}
	public string sShortDescription {get; set;}
	public string sFeature1Description {get; set;}
	public string sFeature1Image {get; set;}
	public string sFeature2Description {get; set;}
	public string sFeature2Image {get; set;}
	public string sFeature3Description {get; set;}
	public string sFeature3Image {get; set;}
	public string sFeature4Description {get; set;}
	public string sFeature4Image {get; set;}
	public string sFeature5Description {get; set;}
	public string sFeature5Image {get; set;}
	public string sFeature6Description {get; set;}
	public string sFeature6Image {get; set;}
	public string sLongDescription {get; set;}
	public string sProductFeature {get; set;}
	public string sSection2Name {get; set;}
	public string sSection2Description {get; set;}
	public string sSection3Name {get; set;}
	public string sSection3Description {get; set;}
	public string sSection5Name {get; set;}
	public string sSection5Description {get; set;}

	// Additional Resources section
	public string sResourceMainText {get; set;}
	public string sResource1File {get; set;}
	public string sResource1Description {get; set;}
	public string sResource2File {get; set;}
	public string sResource2Description {get; set;}
	public string sResource3File {get; set;}
	public string sResource3Description {get; set;}


	// Boolean variables to dynamically show and hide the sections
	public boolean bSection1Show {get; set;}
	public boolean bSection2Show {get; set;}
	public boolean bSection3Show {get; set;}
	public boolean bSection4Show {get; set;}
	public boolean bSection5Show {get; set;}
	public boolean bSection6Show {get; set;}

	// Boolean variables to dynamically show and hide the product features
	public boolean bFeature1Show {get; set;}
	public boolean bFeature2Show {get; set;}
	public boolean bFeature3Show {get; set;}
	public boolean bFeature4Show {get; set;}
	public boolean bFeature5Show {get; set;}
	public boolean bFeature6Show {get; set;}

	// Boolean variables to dynamically show and hide the additional resources
	public boolean bResource1Show {get; set;}
	public boolean bResource2Show {get; set;}
	public boolean bResource3Show {get; set;}
	public boolean bProductTriable {get; set;}

	// Boolean to determine whether to show the price on the rateplans or not
	public boolean bShowPrice {get; set;}

	public vfIECProductViewer() {

	}

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


	public void pageLoad () {
		try {
			// Validate Logged in user profile and ensure profile is complete
			validUserProfile();

			sParamProductCode = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODUCT_CODE);
			if (isUserLoggedIn) {
					bProdAccessCACPro = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_CACPRO) != -1);
				bProdAccessGAD = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_GAD) != -1);
				bProdAccessGSS = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_GSS) != -1);
				bProdAccessMDP = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_MDP) != -1);
				bProdAccessEBro = (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, IECConstants.ProductCategory_SF_EBROADCAST) != -1);
			}

			// Validate that there is parameter passed to the page
			if (String.isEmpty(sParamProductCode)) {
				addErrorMessage(IECConstants.Error_InvalidProductCode);
			}
			else {
				// Decrypt parameter before using it
				sParamProductCode = IECUtil.DecodeDecryptParameter(sParamProductCode);

				// Get the product mapped to the specified product code
				List<Product_Category__c> lstProdCat = IECProductManager.getProductsCategoryByProductCategoryCode(sParamProductCode);

				// Validate that there is product found
				if (lstProdCat.isEmpty()) {
					addErrorMessage(IECConstants.Error_InvalidProductCode);
				}
				else {
					Product_Category__c pc = lstProdCat[0];
					setupTriableProduct(sParamProductCode);

					sButtonType = pc.Button_Type__c;
					bTryButtonShow = pc.Trial_available_for_this_Product__c;
					sBannerImage = pc.Banner_Image__c;
					sProductIcon = pc.Product_Icon__c;

					bShowPrice = (pc.Show_price_on_eCommerce__c == null || pc.Show_price_on_eCommerce__c == 'Yes');
					sDisplayName = pc.Display_Name__c;
					sShortDescription = pc.Short_Description__c;
					sLongDescription = pc.Long_Description__c;
					sFeature1Description = pc.Feature_1_Description__c;
					sFeature1Image = pc.Feature_1_Image__c;
					sFeature2Description = pc.Feature_2_Description__c;
					sFeature2Image = pc.Feature_2_Image__c;
					sFeature3Description = pc.Feature_3_Description__c;
					sFeature3Image = pc.Feature_3_Image__c;
					sFeature4Description = pc.Feature_4_Description__c;
					sFeature4Image = pc.Feature_4_Image__c;
					sFeature5Description = pc.Feature_5_Description__c;
					sFeature5Image = pc.Feature_5_Image__c;
					sFeature6Description = pc.Feature_6_Description__c;
					sFeature6Image = pc.Feature_6_Image__c;
					sProductFeature = pc.Product_Feature__c;
					sSection2Name = pc.Section_2_Name__c;
					sSection2Description = pc.Section_2_Description__c;
					sSection3Name = pc.Section_3_Name__c;
					sSection3Description = pc.Section_3_Description__c;
					sSection5Name = pc.Section_5_Name__c;
					sSection5Description = pc.Section_5_Description__c;
					// Determines which section to show
					bSection1Show = pc.Section_1_Show__c;
					bSection2Show = pc.Section_2_Show__c;
					bSection3Show = pc.Section_3_Show__c;
					bSection4Show = pc.Section_4_Show__c;
					bSection5Show = pc.Section_5_Show__c;
					bSection6Show = pc.Section_6_Show__c;
					// Determines which feature to show
					bFeature1Show = !(String.isEmpty(sFeature1Description) || String.isEmpty(sFeature1Image));
					bFeature2Show = !(String.isEmpty(sFeature2Description) || String.isEmpty(sFeature2Image));
					bFeature3Show = !(String.isEmpty(sFeature3Description) || String.isEmpty(sFeature3Image));
					bFeature4Show = !(String.isEmpty(sFeature4Description) || String.isEmpty(sFeature4Image));
					bFeature5Show = !(String.isEmpty(sFeature5Description) || String.isEmpty(sFeature5Image));
					bFeature6Show = !(String.isEmpty(sFeature6Description) || String.isEmpty(sFeature6Image));

					// Additional Resources
					sResourceMainText = pc.Resources_Main_Text__c;
					sResource1File = pc.Resource_1_File__c;
					sResource1Description = pc.Resource_1_Description__c;
					sResource2File = pc.Resource_2_File__c;
					sResource2Description = pc.Resource_2_Description__c;
					sResource3File = pc.Resource_3_File__c;
					sResource3Description = pc.Resource_3_Description__c;

					// Determines which resources to show
					bResource1Show = !(String.isEmpty(sResource1File) || String.isEmpty(sResource1Description));
					bResource2Show = !(String.isEmpty(sResource2File) || String.isEmpty(sResource2Description));
					bResource3Show = !(String.isEmpty(sResource3File) || String.isEmpty(sResource3Description));
				}
			}
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}

	public void setupTriableProduct(String sProductCategoryCode){
		List<Product_Information__c> listProdInfo = null;
		Product_Information__c oProductInformation = null;
		bProductTriable = false;

		if (IECUserManager.isUserLoggedIn()) {
			// get the user's client type
			String sClientType = IECUserManager.getClientType();

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
			addInfoMessage('Multiple Product Information records found for category ' + sProductCategoryCode);
		}
		// 1 Product Information found
		else {
			oProductInformation = listProdInfo.get(0);
			bProductTriable = IECSubscriptionManager.isProductTriable(oProductInformation.Id);
		}
	}
}
