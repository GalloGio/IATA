public class IEC_ProductDetailController  extends IEC_PageController
{
	public class SubProductWrapper{
		public EComProduct_DTO ecomProduct{get;set;}
		public Product_Rate_Plan_Information__c ratePlanInformation{get;set;}
		public Product_Information__c productInformation{get;set;}
	}

	public EComProduct_DTO ecomProduct{get;set;}
	public List<SubProductWrapper> subProducts{get;set;}
	public Map<Id, List<zqu__ProductRatePlanCharge__c>> charges{get;set;}
	public Product_Category__c pc{get;set;}

	public Boolean bDisplayPrice {get; set;}
	public String selectedRatePlanInformationId {get; set;}
	public Integer iColWidth {get; set;}

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
	public boolean bSection7Show {get; set;}
	
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
	
	public String selectedTopic{get;set;}
	public String selectedTopicLabel{get;set;}

	public String productWrapper {
		get {
			Map<String,Object> ecommObj = new Map<String,Object>();
			Map<String,Object> detailObj = new Map<String,Object>();
			Map<String,Object> actionObj = new Map<String,Object> {'list' => selectedCategory.getLabel() + ' > ' + selectedTopicLabel};
			Map<String,Object> prodObj = new Map<String,Object>();

			ecommObj.put('detail', detailObj);
			detailObj.put('actionField', actionObj);
			detailObj.put('products', new List<Object> {prodObj});

			prodObj.put('id', ecomProduct.ProductNumber);
			prodObj.put('name', ecomProduct.ProductName);
			prodObj.put('category', ecomProduct.Portfolio);
			prodObj.put('price', ecomProduct.unitPrice == null ? 0.00 : ecomProduct.unitPrice);    
            prodObj.put('brand', ecomProduct.ProductCategory);        
            prodObj.put('dimension1', ecomProduct.Edition);
            prodObj.put('dimension2', ecomProduct.Language);
            prodObj.put('dimension3', ecomProduct.InventoryStatus);
            prodObj.put('dimension4', ecomProduct.AvailabilityDate);
            prodObj.put('dimension5', ecomProduct.Media);
            prodObj.put('dimension6', ecomProduct.EffectiveTo);

			return JSON.serialize(ecommObj);
		}
		set;
	}
	

	public IEC_ProductDetailController() 
	{
		bDisplayPrice= true;
	}

	public PageReference onLoadAction()
	{
		Product_Sel pSelector = new Product_Sel();
		String productNumber = System.currentPageReference().getParameters().get('id') ;
	
		try
		{
			iColWidth = 100;

			String searchCond = 'SAP_Material_Number__c=\''+productNumber+'\'';
			system.debug('susana searchCond : '+searchCond);
			List<EComProduct_DTO> ecomProducts = Product_Sel.getEComProduct(null, false, searchCond, null, true, null);
			system.debug('susana ecomProducts : '+ecomProducts);
			if(ecomProducts.size() > 0)
			{
				//Parent found 
				ecomProduct = ecomProducts[0];
				system.debug('susana ecomProduct : '+ecomProduct);
				//Query sub-products 
				String subCond = 'IEC_Parent_Product__c=\''+ecomProduct.ProductId+'\'';
				system.debug('susana subCond : '+subCond);
				List<EComProduct_DTO> ecomSubProducts = Product_Sel.getEComProduct(null, false, subCond, null, false, null);
				system.debug('susana ecomSubProducts : '+ecomSubProducts);
				//Query sub-product's RatePlanInfo
				Set<Id> productRatePlanInfoIds = new Set<Id>(); 
				for(EComProduct_DTO prod :ecomSubProducts)
					productRatePlanInfoIds.add(prod.ProductRatePlanInfoId);

				List<Product_Rate_Plan_Information__c> plans = IECProductManager.getProductRatePlansInformations(productRatePlanInfoIds);
				Map<Id, Product_Rate_Plan_Information__c> planById = new Map<Id, Product_Rate_Plan_Information__c>(plans);

				Set<Id> planIds = new Set<Id>();				
				subProducts = new List<SubProductWrapper>();
				for(EComProduct_DTO prod : ecomSubProducts)
				{
					if(planById.containsKey(prod.ProductRatePlanInfoId))
					{
						SubProductWrapper subProd = new SubProductWrapper();
							subProd.ecomProduct = prod; 
							subProd.ratePlanInformation = planById.get(prod.ProductRatePlanInfoId);
						subProducts.add(subProd);

						planIds.add(subProd.ratePlanInformation.Product_Rate_Plan__c);
					}
				}

				charges = IECProductManager.getZuoraRatePlanChargesByRatePlanIDs(planIds);
				iColWidth = (subProducts.size() > 0) ? 100/subProducts.size() : 100;
				//*** get category
				selectedCategory = new SelectOption('', '');
				for(SelectOption so : categories)
					if (so.getValue() == ecomProduct.megaMenu)
					{
						selectedCategory = so;
						break;
					}

				//*** get topic
				selectedTopic = [select Display_Ecom_Topic__c from Product2 where Id = :ecomProduct.ProductId limit 1][0].Display_Ecom_Topic__c;
				selectedTopicLabel = '';
				if (!String.isBlank(selectedTopic))
				{
					selectedTopic = selectedTopic.split(';')[0];   //*** take the first topic if contains multiple
					if (subCategories.containsKey(selectedCategory.getValue()))
						for (SelectOption so : subCategories.get(selectedCategory.getValue()))
							if (so.getValue() == selectedTopic)
							{
								selectedTopicLabel = so.getLabel();
								break;
							}
				}
			}
			else
			{
				//-- Product Not found 
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Product_Not_Found));
			}

			//Features
			pc = IECProductManager.getProductCategoryBySFDCProduct(ecomProduct.ProductId);
			system.debug('susana pc : '+pc);
			sButtonType = pc.Button_Type__c;
			bTryButtonShow = pc.Trial_available_for_this_Product__c;
			sBannerImage = pc.Banner_Image__c;
			sProductIcon = pc.Product_Icon__c;
			sProductIcon = 'imgbloc5.png';   //*** default - GSS image
			Map<String,String> mapCategory_ImageName = Utility.buildMapFromString(Utility.getTextSetting('GDP Category-Image'), ',', '=');
			if (mapCategory_ImageName.containsKey(pc.Name))
				sProductIcon = mapCategory_ImageName.get(pc.Name);
			
			bShowPrice = (pc.Show_price_on_eCommerce__c == null || pc.Show_price_on_eCommerce__c == 'Yes');
			system.debug('susana pc : '+pc);
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
			bSection7Show = pc.Section_7_Show__c;
			
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
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + ' :: ' + ex.getStackTraceString()));
		}


		System.debug('Page Loaded');

		return null;
	}

	public PageReference addToCart() 
	{
		System.debug('addToCart CALLED');
		try 
		{
			system.debug('try');
			Product2 p = [
				SELECT Id, IEC_Parent_Product__c, SAP_Material_Number__c , IEC_Product_Rate_Plan_Information__c, Name, IEC_Parent_Product__r.Name 
				FROM Product2 
				WHERE IEC_Product_Rate_Plan_Information__c = :selectedRatePlanInformationId
				LIMIT 1
			];

			system.debug('p::'+p);

			List<Product2> sibblingProducts = [
				SELECT SAP_Material_Number__c FROM Product2 WHERE IEC_Parent_Product__c = :p.IEC_Parent_Product__c AND Id != :p.Id
			];
			Set<String> sibblingProductNumbers = new Set<String>(); 
			for(Product2 prod : sibblingProducts)
			{
				sibblingProductNumbers.add(prod.SAP_Material_Number__c);
			} 

			String productNumber2Add = p.SAP_Material_Number__c;
			//Map<String, Decimal> cookieContent = IECOrder_Svc.getItemsInCookie();
			Map<String, Decimal> cookieContent = new Map<String, Decimal>();

			if (newShoppingCart == false) {
				cookieContent = IECOrder_Svc.getItemsInCookie();
			} else {
				List<IEC_Cart.CartItem> cartItemList = storeCart.getCartContent();

				for (IEC_Cart.CartItem cartItem : cartItemList) {
					cookieContent.put(cartItem.productNumber, cartItem.quantity);
				}
			}

			//-- Validate another sub-product does not exist in the cart 
			Boolean sibblingInCart = false; 
			for(String item : cookieContent.keySet())
			{
				if(sibblingProductNumbers.contains(item))
				{
					sibblingInCart = true;
					break;
				}
			}

			//Verified if the cart already have a time-based subscription
			List<Product2> existingProducts = [Select id, IEC_Product_Rate_Plan_Information__c, IEC_Parent_Product__c 
												from Product2 where SAP_Material_Number__c in :cookieContent.keySet()];

			Boolean existSubscriptionProd = false;								
			if(existingProducts != null && !existingProducts.isEmpty()){
				for(Product2 prd : existingProducts){
					if(prd.IEC_Product_Rate_Plan_Information__c != null && prd.IEC_Parent_Product__c != null){
						existSubscriptionProd = true;
						if(prd.IEC_Product_Rate_Plan_Information__c == selectedRatePlanInformationId){sibblingInCart = true;}
						break;
					}
				}
			}						

			if(!sibblingInCart && !existSubscriptionProd)
			{
				// Ecommerce Enhancements R2 - aosantos, do not redirect immediately when creating cookie, it might not be stored
				
				if (newShoppingCart == false) {
					PageReference pageRef = IECOrder_Svc.addCartToCookie(p.SAP_Material_Number__c, 1);
				} else {
					storeCart.addItem(p.SAP_Material_Number__c, 1, null);
				}

				return null;
			}
			else
			{
				
				String urlParamMsg = (sibblingInCart) ? 'siblingInCart' : 'subscriptionAlreadyExist';

				
				PageReference pageRef = new Pagereference('/IEC_ShoppingCart?msg=' + urlParamMsg);
				pageRef.setRedirect(true);
				return pageRef;

				//--- Sibbling already in Cart 
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
				//	String.format(Label.Item_already_in_your_cart, new List<String> {p.IEC_Parent_Product__r.Name})));

				//return null;
			}
			
		} 
		catch (Exception e) 
		{
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + ' - ' +e.getStackTraceString()));
			return null;
		}		
	}

	public Pagereference register() {
        try {
            Pagereference pr = Page.ISSP_Registration;
            pr.getParameters().put('sRefererCommunity', 'IEC_ProductDetail?id='+ecomProduct.ProductNumber);
            pr.setRedirect(true);
            return pr;
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
		//return null;
		try {
			Pagereference prQuotePage = Page.IECQuote;
		    prQuotePage.getParameters().put(IECConstants.PARAM_RATEPLANINFO_ID, IECUTil.EncryptEncodeParameter(selectedRatePlanInformationId));
		    prQuotePage.setRedirect(true);
		    return prQuotePage;
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}
	
	/**
	 * Redirects the user to the Trial page with the selected product rate plan info
	 */
	public Pagereference tryMe() {
		//return null;
		try {
  			Pagereference prTrialRequest = Page.IECTrialRequest;
  			prTrialRequest.getParameters().put(IECConstants.PARAM_RATEPLAN_ID, IECUTil.EncryptEncodeParameter(selectedRatePlanInformationId));
		    prTrialRequest.setRedirect(true); 
		    return prTrialRequest;
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}
}