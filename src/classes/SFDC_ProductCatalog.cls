/****************************************************************************************************
    Created by David D 2016/02
        SOAP web service to be called by iata.org to get product catalog
****************************************************************************************************/
@RestResource(urlMapping = '/ProductCatalog/*')
global class SFDC_ProductCatalog {
	global class Error {
		String Code;
		String Message;
		global Error(String c, String m) {
			Code = c;
			Message = m;
		}
	}

	global class ProductCatalog {
		List<Error> Errors;
		List<ProductGroup> ProductGroup;
		Integer NB_Products; //Number of products founded
		Integer NB_Pages; // Number of available pages if some limit is specified
		Integer PageNumber; //Specified Page Number
		Integer PageSize; // Specified limit
	}

	global class ProductGroup {
		String PageTitle;
		String PageURL;

		List<ProductInfo> ProductInfo;
	}

	global class ProductInfo {
		String 	ProductTitle;
		String 	ProductName;
		String 	ProductNumber;
		String 	ProductEdition;
		String 	ProductDescription;
		String 	ProductNotes;
		Decimal ProductPrice;
		String 	ProductLink;
		String 	ProductLanguage;
		String 	ProductCategory;
		String 	ProductMedia;
		Date 	ProductAvailabilityDate;
		String 	ProductSampleLink;
		Integer ProductOrder;
		String 	PageAreaOfActivityLevel;
		String 	PageContentTypes;
		Boolean UseOnIATA;
	}

	@HttpGet
	global static ProductCatalog getProducts() {
		Map<String, String> params = RestContext.request.params;

		ProductCatalog response = new ProductCatalog();
		response.Errors = new List<Error>();


		Product_Sel pSelector = new Product_Sel();
		String searchCondition = 'SAP_Material_Number__c != null AND (Display_to_ECommerce__c = true OR Display_to_Direct_Sales__c = true) '; // Basic filter

		//-- If Date filter is specified
		if (params.containsKey('date')) {
			String strDate = params.get('date');
			if (isValidDate(strDate)) {
				Date dt = Date.valueOf(strDate);
				searchCondition += ' AND LastModifiedDate >= ' + DateTime.newInstance(dt.year(), dt.month(), dt.day(), 23, 59, 59).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
			} else {
				response.Errors.add(new Error('INVALID_DATE', 'The Date parameter specified is invalid. The valid date format is yyyy-mm-dd'));
			}
		}

		//-- If limit is specified
		if (params.containsKey('limit')) {
			String strLimit = params.get('limit');
			if (isValidInteger(strLimit)) {
				response.PageSize = Integer.valueOf(strLimit);

				//-- If page number is specified
				if (params.containsKey('page')) {
					String strPageNumber = params.get('page');
					if (isValidInteger(strPageNumber)) {
						response.PageNumber =  Integer.valueOf(strPageNumber);
					} else {
						response.Errors.add(new Error('INVALID_INTEGER', 'The Page number parameter specified is invalid. You must specified an integer'));
					}
				} else {
					//-- Page 1 is the default page
					response.PageNumber = 1;
				}
			} else {
				response.Errors.add(new Error('INVALID_INTEGER', 'The Limit parameter specified is invalid. You must specified an integer'));
			}
		}

		//-- Validate there is no error
		if (response.Errors.size() == 0) {
			//-- No Error
			response.Errors = null;

			//-- Perform query
			List<ProductGroup> groups = new List<ProductGroup>();

			Integer queryLimit = response.PageSize;
			Integer queryOffset = (response.PageNumber >= 1) ? (response.PageNumber - 1) * response.PageSize : 0;

			//-- Available products
			List<Product2> products = pSelector.getProducts(searchCondition, 'Name', queryLimit, queryOffset);

			//-- Products Price
			Set<String> productNumbers = new Set<String>();
			for (Product2 p : products)
				productNumbers.add(p.SAP_Material_Number__c);

			Map<String, PriceInfo_DTO> productPrices =  pSelector.getProductPriceInfo(productNumbers, null, null, null, true);

			//-- Group Products
			Map<String, List<Product2>> productsByGroup = new Map<String, List<Product2>>();
			for (Product2 p : products) {
				String g = (p.IATA_ORG_Group__c != null) ? p.IATA_ORG_Group__c : '-';
				List<Product2> tmp = (productsByGroup.containsKey(g))
				                     ?	productsByGroup.get(g)
				                     : 	new List<Product2>();
				tmp.add(p);
				productsByGroup.put(g, tmp);
			}

			//-- Build Response
			for (String groupName : productsByGroup.keySet()) {
				List<Product2> prods = productsByGroup.get(groupName);

				ProductGroup pg = new ProductGroup();
				pg.PageTitle = groupName;
				pg.PageURL = '/' + groupName.toLowerCase().replace(' ', '-') + '.aspx';

				pg.ProductInfo = new List<ProductInfo>();
				for (Product2 p : productsByGroup.get(groupName)) {
					pg.ProductInfo.add(formatToProductInfo(p, productPrices.get(p.SAP_Material_Number__c)));
				}

				groups.add(pg);
			}

			response.ProductGroup = groups;

			List<Product2> availableProducts = pSelector.getProducts(searchCondition, 'Name', null, null);

			response.NB_Products = availableProducts.size();

			if (response.PageSize != null) {
				response.NB_Pages = Integer.valueOf(Math.round(response.NB_Products / response.PageSize));
			}

		}

		return response;
	}

	private static ProductInfo formatToProductInfo(Product2 p, PriceInfo_DTO price) {
		ProductInfo ws = new ProductInfo();
		ws.ProductTitle 			= p.Short_Title__c;
		ws.ProductName 				= p.Name;
		ws.ProductNumber 			= p.SAP_Material_Number__c;
		ws.ProductEdition 			= p.Edition__c;
		ws.ProductDescription 		= p.Short_Description__c;
		ws.ProductNotes 			= p.Notes__c;
		ws.ProductLink 				= '/IEC_ProductDetails?id=' + p.SAP_Material_Number__c;
		ws.ProductLanguage 			= p.Refinement_Language__c;
		ws.ProductCategory 			= p.Line_of_Business__c;
		ws.ProductMedia 			= p.Media__c;
		//ws.ProductAvailabilityDate 	= p.Effective_From__c;
		ws.ProductAvailabilityDate 	= p.Expected_Availability_Date__c;
		ws.ProductSampleLink 		= p.IEC_Sample_Link__c;
		ws.ProductOrder 			= Integer.valueOf(p.IEC_OrderBy__c);
		ws.PageAreaOfActivityLevel	= p.IEC_Page_Areas_of_Activity__c;
		ws.PageContentTypes 		= p.IEC_Page_Content_Types__c;
		ws.UseOnIATA 				= p.IEC_Use_on_IATA_org__c;

		if (price != null) {
			ws.ProductPrice = Order_Svc.getRegularPrice(price, 1);
		}

		return ws;
	}

	private static Boolean isValidDate(String sDate) {
		try {
			Date dt = Date.valueOf(sDate);
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	private static Boolean isValidInteger(String sInteger) {
		try {
			Integer i = Integer.valueOf(sInteger);
			return true;
		} catch (Exception e) {
			return false;
		}
	}

}