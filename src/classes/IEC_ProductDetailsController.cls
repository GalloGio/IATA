/******************************************************************************************************************
 *  IEC_ProductDetailsController: IEC_ProductDetails page Controller                                              *
 *  Author: David Daboué - CGI                                                                                    *        
 ******************************************************************************************************************/
public with sharing class IEC_ProductDetailsController extends IEC_PageController
{
	//Page parameters
    public Map<String, String> pageParams;

    //Page Labels 
    public Map<String, String> labels { get; set; }

	//Product to display
	public EComProduct_DTO product{get;set;}
	public List<EComProduct_DTO> recommendedProducts{get;set;}
	public Boolean bIsInStock{get;set;}
	public Boolean bIsOutOfStock{get;set;}
	public Boolean bIsPreOrder{get;set;}
	public Boolean bIsDirectSales{get;set;}
	public Boolean bIsProductCompliant{get;set;}

	public List<EComProduct_DTO> lstRelatedProducts {get;set;}

	//Available Discounts for the product 
	public List<PriceDetail_DTO> discounts{get;set;}

	public String selectedTopic{get;set;}
	public String selectedTopicLabel{get;set;}

	/**************************************************************************************************************
     *  IEC_ProductDetailsController: Class Constructor                                                           *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public IEC_ProductDetailsController() 
	{
		//Fetch Page params 
		pageParams = ApexPages.currentPage().getParameters();

		labels = Utility.buildMapFromString(Label.Labels_IECProductDetail, '\n', ':');

	}

	/**************************************************************************************************************
     *  onLoadAction: method calls when page loaded                                                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference onLoadAction()
	{
		String productNumber = (pageParams.containsKey('id')) ? pageParams.get('id') : '';
		String searchCond = '  SAP_Material_Number__c=\''+productNumber+'\' ';
		String recommendedCond = '  (SAP_Material_Number__c!=\''+productNumber+'\' AND Recommended__c=true) ';

		List<EComProduct_DTO> products = Product_Sel.getEComProduct(null, true, searchCond, null, false, null);

		List<EComProduct_DTO> lst_recommendedProducts = Product_Sel.getEComProduct(null, true, recommendedCond, 'Recommended_Ranking__c', false, null); 
		recommendedProducts = new List<EComProduct_DTO>();
		for(Integer x = 0; x < lst_recommendedProducts.size(); x++)
		{
			if(x<5){
				recommendedProducts.add(lst_recommendedProducts[x]);
			}else{
				break;
			}
		}

		System.debug('products.size(): ' + products.size());

		if(products.size() >0)
		{
			product = products[0];
			Date dt = Date.today();

			System.debug('product: ' + product);

			if(product.ProductInfoId != null)
		    {
		        //-- Redirect to 3B detail View 
		        PageReference ret = new PageReference('/IEC_ProductDetail?id=' + productNumber);
		        ret.setRedirect(true);
		        return ret;
		    }

		    //set the list of Related Products
		    lstRelatedProducts = new List<EComProduct_DTO>();
		    List<Recommended_Product__c> lstRecommendedProducts = [Select Id, Related_Product__r.Name, Related_Product__r.Short_Description__c, 
		    															Related_Product__c, Related_Product__r.SAP_Material_Number__c 
		    														FROM Recommended_Product__c 
		    														where Product__c =:product.ProductId
                                                                      and Related_Product__r.Display_to_ECommerce__c = true
		    													];
		    if(lstRecommendedProducts != null && lstRecommendedProducts.size() > 0){
		    	for(Recommended_Product__c recomProd : lstRecommendedProducts){
		    		EComProduct_DTO ecomProd = new EComProduct_DTO();
		    		ecomProd.ProductId = String.valueOf(recomProd.Related_Product__c).left(15);
		    		ecomProd.ProductNumber = recomProd.Related_Product__r.SAP_Material_Number__c;
		    		ecomProd.ProductName = recomProd.Related_Product__r.Name;
		    		ecomProd.ProductShortDesc = recomProd.Related_Product__r.Short_Description__c;
		    		lstRelatedProducts.add(ecomProd);
		    	}
		    }



		    Product2 sfProduct = [SELECT Id, Sell_through_eCommerce__c, Display_Ecom_Topic__c FROM Product2 WHERE Id = :product.ProductId LIMIT 1];


			bIsInStock 		= 	(product.InventoryStatus == 'In stock' || product.InventoryStatus == 'Available Now');
			bIsOutOfStock 	= 	(product.InventoryStatus != 'In stock' && product.InventoryStatus != 'Available Now');
			bIsPreOrder 	= 	((product.InventoryStatus != 'In stock' && product.InventoryStatus != 'Available Now') && !product.Is_Electronic_Product);
			bIsDirectSales 	= 	((product.RegularPrice==null && product.CustomerPrice==null) || !sfProduct.Sell_through_eCommerce__c);

			//Product discounts
			discounts = new List<PriceDetail_DTO>();
			if (product.PriceInfo != null) 
			{
				//Standard discount
	            discounts.addAll(Order_Svc.getDiscountPlans(product.PriceInfo.standardPrice, null, false));
	            
	            //Pre sale discount
	            discounts.addAll(Order_Svc.getDiscountPlans(product.PriceInfo.preSalePrice, null, false));

	            if(loggedCustomer != null)
	            {
	            	//Customer Type discount
	            	discounts.addAll(Order_Svc.getDiscountPlans(product.PriceInfo.customerPrice, loggedCustomer.sfAccount.Customer_Type__c, true));

	            	//region Discounts 
	            	discounts.addAll(Order_Svc.getDiscountPlans(product.PriceInfo.regionPrice, loggedCustomer.sfAccount.Region_formula__c, true));

	            	//Country Discounts
	            	discounts.addAll(Order_Svc.getDiscountPlans(product.PriceInfo.countryPrice, loggedCustomer.sfAccount.BillingCountry, true));
	            }
	        }

	        //Validate Product compliance 
	        validateCountryCompliance();
            if (!bIsProductCompliant) //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, labels.get('msgErrorProductNotCompliant')));
            	addErrorMessage(labels.get('msgErrorProductNotCompliant'));
			//*** get category
			selectedCategory = new SelectOption('', '');
			for(SelectOption so : categories)
				if (so.getValue() == product.megaMenu)
				{
					selectedCategory = so;
					break;
				}

			//*** get topic
			selectedTopic = sfProduct.Display_Ecom_Topic__c;
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
			//Product not found
			addErrorMessage(Label.Product_Not_Found);
		}


		System.debug('selected_mega_menu = publications');

		selected_mega_menu = 'publications';
		return null;
	}

	/**************************************************************************************************************
     *  addToCart: method calls when customer click on “Add To Cart” button 									  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference addToCart()
	{
		System.debug('addToCart()');

		try
		{
			if (!bIsProductCompliant)
	        {
				System.debug('Product Is Not Compliant');

	        	addErrorMessage(labels.get('msgErrorProductNotCompliant'));
				return null;
	        }
	        else 
	        {
				System.debug('Product Is Compliant - invoking addCartToCookie');

				
				// Ecommerce Enhancements R2 - aosantos, do not redirect immediately when creating cookie, it might not be stored
				if (newShoppingCart == false) {
	        		PageReference resultPageRef = IECOrder_Svc.addCartToCookie(product.ProductNumber, product.OrderQuantity,'/IEC_ShoppingCart');
				} else {
					storeCart.addItem(product.ProductNumber, product.OrderQuantity, null);
				}

				return null;
	        }
		}	
		catch(Exception e) {
			System.debug(e.getStackTraceString());

			addErrorMessage(e.getMessage() + ' - ' +e.getStackTraceString());
			return null;
		}
	}

	/**************************************************************************************************************
     *  validateCountryCompliance: method call to validate that the current product is country compliant 		  *
     *  Author: Samy - David Daboué                                                                               *  
     **************************************************************************************************************/
	public void validateCountryCompliance()
	{
		Set<String> countryCodes = new Set<String>();
	    	
		if(loggedCustomer != null)
		{
			if (!String.isBlank(loggedCustomer.sfContact.BillTo_Location__r.ISO_Country_Code__c)) countryCodes.add(loggedCustomer.sfContact.BillTo_Location__r.ISO_Country_Code__c);
			if (!String.isBlank(loggedCustomer.sfContact.ShipTo_Location__r.ISO_Country_Code__c)) countryCodes.add(loggedCustomer.sfContact.ShipTo_Location__r.ISO_Country_Code__c);
		}
        
        bIsProductCompliant = Product_Svc.IsProductAndCountryCompliant(Product.ProductId, countryCodes);
	}
}