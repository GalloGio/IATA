/**
	* Description: This class contains the controller for the Visualforce Component (Recommended Products)
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/

public with sharing class vfIECRecommended {
	public integer iProduct						{get; set;}
	public boolean bDisplayComponent			{get; set;}
	public boolean bDisplayProduct1				{get; set;}
	public boolean bDisplayProduct2				{get; set;}
	public Product_Category__c oProductCategory	{get; set;}

	public String sProduct1Code {get {return (bDisplayProduct1) ? IECUtil.EncryptParameter(oProductCategory.Recommended_Product_Category_1__r.Name) : '';} }
	public String sProduct1Name {get {return (bDisplayProduct1) ? oProductCategory.Recommended_Product_Category_1__r.Display_Name__c : '';} }
	public String sProduct1Desc {get {return (bDisplayProduct1) ? oProductCategory.Recommended_Product_Category_1__r.Short_Description__c: '';} }
	public String sProduct2Code {get {return (bDisplayProduct2) ? IECUtil.EncryptParameter(oProductCategory.Recommended_Product_Category_2__r.Name) : '';} }
	public String sProduct2Name {get {return (bDisplayProduct2) ? oProductCategory.Recommended_Product_Category_2__r.Display_Name__c : '';} }
	public String sProduct2Desc {get {return (bDisplayProduct2) ? oProductCategory.Recommended_Product_Category_2__r.Short_Description__c: '';} }

	public String sProductCode {
		get {
			return sProductCode;
		}
		set {
			sProductCode = value;
			pageLoad();
		}
	}

	public void pageLoad() {
		List<Product_Category__c> lstProdCat =
			[SELECT Recommended_Product_Category_1__c
				, Recommended_Product_Category_2__c
				, Recommended_Product_Category_1__r.Name
				, Recommended_Product_Category_1__r.Display_Name__c
				, Recommended_Product_Category_1__r.Short_Description__c
				, Recommended_Product_Category_2__r.Name
				, Recommended_Product_Category_2__r.Display_Name__c
				, Recommended_Product_Category_2__r.Short_Description__c
			FROM Product_Category__c
			WHERE Name = :sProductCode];

		if (lstProdCat.size() > 0) {
			bDisplayComponent = true;
			oProductCategory = lstProdCat.get(0);
			bDisplayProduct1 = (oProductCategory.Recommended_Product_Category_1__c != null);
			bDisplayProduct2 = (oProductCategory.Recommended_Product_Category_2__c != null);
			bDisplayComponent = (bDisplayProduct1 || bDisplayProduct2);
		}
		else {
			bDisplayComponent =
				bDisplayProduct1 =
				bDisplayProduct2 = false;
			oProductCategory = null;
		}
	}

	public PageReference onClickProduct() {
		Pagereference pgRef = Page.IECProductViewer;

		if (iProduct == 1) {
			pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(oProductCategory.Recommended_Product_Category_1__r.Name));
		}
		else if (iProduct == 2) {
			pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(oProductCategory.Recommended_Product_Category_2__r.Name));
		}

		pgRef.setRedirect(true);
		return pgRef;
	}
}
