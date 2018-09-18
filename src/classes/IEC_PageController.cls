public virtual class IEC_PageController 
{
	// Ecommerce Enhancements
	public IEC_Cart storeCart {
		get {
			IEC_Cart cartInstance = IEC_Cart.getInstance();

			return cartInstance;
		}
	}

	public Boolean newShoppingCart {
		get {
			return functionality.isActive('New Shopping Cart');
		}
	}

	private static IEC_Functionality functionality = IEC_Functionality.getInstance();

	// Ecommerce Enhancements end

	public class CartWrapper
	{
		public String productCode{get;set;}
		public String productName{get;set;}
		public Decimal quantity{get;set;}

		public CartWrapper(String code, String name, Decimal qty)
		{
			productCode = code;
			productName = name;
			quantity = qty;
		}
	}

	public IEC_User_Utils userDetails {get;set;}

	public Boolean hasError { get; protected set; }
	public Boolean hasConfirm { get; protected set; } 
	public Boolean hasWarning { get; protected set; }
	public String paramReturnURL {get; set;}
	public String currentPageName{get{
		String pageName = ApexPages.CurrentPage().getUrl();  
		pageName = pageName.replaceFirst('/apex/','');         
		/*pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');  
		string[] pageNameExtra = pageName.split('%3F',0);   
		pageName = pageNameExtra[0]; */

		return pageName;
	}set;}  


	//-- Portal Logged Customer
	public Customer_DTO loggedCustomer { get; set; }

	//-- Customer Language 
	public String language { get{
		if(language == null) language = UserInfo.getLanguage().split('_')[0];
		return language;
	} set; }

	private void cleanupCookies()
    {
		System.debug('cleanupCookies');

        //-- If products in cookie Sync with SFDC & ensure that they can be paid by current user 
        Map<String, Decimal> cookieContent =  IECOrder_Svc.getItemsInCookie();

		System.debug('cookieContent:');
		for (String key : cookieContent.keySet()) {
			System.debug('###    ' + key + ': ' + cookieContent.get(key));
		}

        if(!cookieContent.isEmpty())
        {
            //-- Available products
            String customerType = loggedCustomer.sfAccount.Customer_Type__c; 
            if (String.isBlank(customerType))
                customerType = IECConstants.PARAM_CUSTOMERTYPE_DEFAULT;
            List<Product2> lst_products =[
                SELECT Id, Restricted_Customer_Type__c, SAP_Material_Number__c
                FROM Product2 
                WHERE  SAP_Material_Number__c IN :cookieContent.keySet() 
                    AND (
                        Restricted_Customer_Type__c = null 
                        OR Restricted_Customer_Type__c INCLUDES (:customerType)
                    )
            ];

            Map<String, Id> availableProducts = new Map<String, Id>();
            for(Product2 p : lst_products)
                availableProducts.put(p.SAP_Material_Number__c, p.Id);

            for(String productCode : cookieContent.keySet())
            {
				System.debug('checking productCode: ' + productCode);

                if(!availableProducts.containsKey(productCode))
                {
					System.debug('availableProducts doesnt contains productCode: ' + productCode + ', removing from cookie');

                    //-- remove product from cookie 
                    IECOrder_Svc.deleteProductToCookie(productCode);
                }
            }
        }
    }

	//-- Customer Cart content
	public List<CartWrapper> cartContent { get{
		cartContent = new List<CartWrapper>();

		if(ApexPages.currentPage().getParameters().containsKey('doLogout'))
		{
			IECOrder_Svc.deleteAllCookies();
            Cookie Cookie_Sync = new Cookie('Cookie_Sync', '', null, 0, false);
            ApexPages.currentPage().setCookies(new Cookie[]{Cookie_Sync});
            return cartContent;
		}

		Map<String, Decimal> cookieContent = Order_Svc.getItemsInCookie();
		
		//-- If customer is logged-in sync cookie with pendding order if not syncked yet
		String cookie_Sync = IECOrder_Svc.readCookie('Cookie_Sync');

		System.debug('cookie_Sync: ' + cookie_Sync);

		if(loggedCustomer !=null /*&& cookie_Sync != 'true'*/)
		{
			cleanupCookies();


			System.debug('User Logged IN');
			OrderItem_Sel oiSelector = new OrderItem_Sel();
			Order pendingOrder = IECOrder_Svc.getPenddingOrder(false); 
			List<OrderItem> pendingOrderItems = oiSelector.getOrderItems(pendingOrder.Id);
			
			for(OrderItem oi : pendingOrderItems)
			{
				//-- Product already in cookie (Cookie win)
				if(cookieContent.containsKey(oi.Product_Number__c)) {
					System.debug('Product ' + oi.Product_Number__c + ' already in cookie: modify');

					IECOrder_Svc.modifiedProductToCookie(oi.Product_Number__c, cookieContent.get(oi.Product_Number__c));
				//-- New product 
				} else {
					System.debug('Product: ' + oi.Product_Number__c + ' is new: add');

					IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true); 
				}
			}

			cookieContent = Order_Svc.getItemsInCookie();

			System.debug('cookieContent: ' + cookieContent);
			
			//-- Create Cookie_Sync entry
			Cookie c = new Cookie('Cookie_Sync','true', null, Utility.getIntegerSetting('IEC Order Cookie maxAge'), false);
			ApexPages.currentPage().setCookies(new Cookie[]{c});
		}
		
		for(Product2 p : [SELECT Name, SAP_Material_Number__c FROM Product2 WHERE SAP_Material_Number__c != null AND Display_to_ECommerce__c = true AND SAP_Material_Number__c IN :cookieContent.keySet()]) {
			System.debug('Adding Product ' + p.SAP_Material_Number__c + ' to Cart Content');

			cartContent.add(new CartWrapper(p.SAP_Material_Number__c, p.Name, cookieContent.get(p.SAP_Material_Number__c)));
		}
		
		System.debug('cartContent: ' + cartContent);

		return cartContent;
	} set; }

	//MEGA MENU Categorie : publications=>Publication, data-and-statistics=>Data & Statistics ....
	public List<SelectOption> categories{get{
		if(categories == null) categories = Utility.getPicklistSelectOptions('Product2', 'Mega_Menu__c', false);
		return categories;
	}set;}

	public String selected_category{get;set;}
	public SelectOption selectedCategory{get;set;}

	//mega menu topics
	public Map<String, List<SelectOption>> subCategories{get{
		if(subCategories == null)  subCategories = Utility.getDependentOptions('Product2','Mega_Menu__c', 'Display_Ecom_Topic__c');
		return subCategories;
	}set;}

	
	//-- Mega Menu Items 
	public Map<String, String> mega_menus{get{
		//if(mega_menus == null) mega_menus = Utility.getPicklistValue_Label('Product2', 'Mega_Menu__c');
		return mega_menus;
	}set;}
	public String selected_mega_menu{get;set;}

	//-- Page custom links 
	public Map<String, List<Ecommerce_Site_Link__c>> customLinks{get{
		if(customLinks == null)
		{
			customLinks = new Map<String, List<Ecommerce_Site_Link__c>>(); 
			for(Ecommerce_Site_Link__c link : [SELECT Id, Name, Page_Section__c, URL__c FROM Ecommerce_Site_Link__c WHERE IsActive__c = true ORDER BY Order_By__c])
			{
				List<Ecommerce_Site_Link__c> tmp = (customLinks.containsKey(link.Page_Section__c))  ? customLinks.get(link.Page_Section__c) : new List<Ecommerce_Site_Link__c>();
					tmp.add(link);
				customLinks.put(link.Page_Section__c,tmp);
			}
		}
		return customLinks;			
	}set;}

	//-- Copyright
	public String copyright{get{
		if(copyright == null) copyright = Label.copyright.replace('{Y}',Date.today().year()+'');
		return copyright;
	}set;}
	
	public List<String> topics{ get{
		if(topics == null) topics = Utility.getPicklistValues('Product2', 'Display_Ecom_Topic__c');
		return topics;
	} set; }

	public List<String> customerTypes{ get{
		if(customerTypes == null) customerTypes = Utility.getPicklistValues('Product2', 'Display_Ecom_Customer_Type__c');
		return customerTypes;
	} set; }

	public Boolean bHasAnyProdAccess{get{
		if(bHasAnyProdAccess==null){
			if(loggedCustomer == null) 
				bHasAnyProdAccess = false; 	
			else {
				Boolean bProdAccessCACPro 	= (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.sfContact.Id, IECConstants.ProductCategory_SF_CACPRO) != -1);
				Boolean bProdAccessGAD 		= (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.sfContact.Id, IECConstants.ProductCategory_SF_GAD) != -1);
				Boolean bProdAccessGSS 		= (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.sfContact.Id, IECConstants.ProductCategory_SF_GSS) != -1); 
				Boolean bProdAccessMDP 		= (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.sfContact.Id, IECConstants.ProductCategory_SF_MDP) != -1);
				Boolean bProdAccessEBro 	= (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.sfContact.Id, IECConstants.ProductCategory_SF_EBROADCAST) != -1);
			  	Boolean bProdAccessCACWeb 	= (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.sfContact.Id, IECConstants.ProductCategory_SF_CACWEB) != -1);
			  	Boolean bProdAccessPAL 		= (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.sfContact.Id, IECConstants.ProductCategory_SF_PAL) != -1);
			  	Boolean bProdAccessCAL 		= (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.sfContact.Id, IECConstants.ProductCategory_SF_CAL) != -1);
			  	Boolean bProdAccessASL 		= (IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.sfContact.Id, IECConstants.ProductCategory_SF_ASL) != -1);

			  	bHasAnyProdAccess =  bProdAccessCACPro || bProdAccessGAD || bProdAccessGSS || bProdAccessMDP || bProdAccessEBro
	        		|| bProdAccessCACWeb || bProdAccessPAL || bProdAccessCAL || bProdAccessASL;
			}			
		}
		return bHasAnyProdAccess;
	}set;}


	public IEC_PageController() 
	{
		//-- Init Logged Customer 
		system.debug('IEC_PageController');
		loggedCustomer = Customer_DTO.getLoggedCustomer();	
		String url = Site.getBaseUrl();	

		userDetails = IEC_User_Utils.getInstance();

		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
	}

	public void addErrorMessage(String message)
	{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
		hasError = true;
		hasConfirm = false;
		hasWarning = false;
	}

	public void addErrorMessage(String message, String additionalDebugMessage) {
		addErrorMessage(message);

		if (IEC_Trace.isDebugActive) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, additionalDebugMessage));
		}
	}

	public void addErrorMessage(String message, Exception e) {
		addErrorMessage(message);

		if (IEC_Trace.isDebugActive) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getStackTraceString()));
		}
	}

	public void addConfirmMessage(String message) 
	{
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
    	hasConfirm = true;
    	hasError = false;
		hasWarning = false;
  	}

	public void addWarningMessage(String message) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
		hasError = false;
		hasConfirm = false;
		hasWarning = true;
	}

	public void addWarningMessage(String message, String additionalDebugMessage) {
		addWarningMessage(message);

		if (IEC_Trace.isDebugActive) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, additionalDebugMessage));
		}
	}

	public void addWarningMessage(String message, Exception e) {
		addWarningMessage(message);

		if (IEC_Trace.isDebugActive) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getStackTraceString()));
		}
	}

	public Pagereference logout() 
    {
        PageReference pr;

        try {
            IECOrder_Svc.deleteAllCookies();
            Cookie Cookie_Sync = new Cookie('Cookie_Sync', '', null, 0, false);
            ApexPages.currentPage().setCookies(new Cookie[]{Cookie_Sync});
            cartContent = new List<CartWrapper>();

			if (newShoppingCart) {
				storeCart.clearCart();
			}

            //pr = Page.IECLogout; 
            pr = Page.IEC_Logout;
            pr.setRedirect(true);
        }
        catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}

		// Ecommerce Enhancements - do not redirect too fast, do it by Javascript so that
		// cookies get erased.

		return null;
        //return pr;
    }

    /** 
     * Redirects to the Registration page
     */
    public Pagereference miniRegister() {
        try {
            system.debug('on register ');
            //Pagereference pr = Page.IECUserRegistration;
            //MM: I have changed the target registration page to the ISS registration page and added a parameter to identify from which portal customer is coming from: "IEC".
            /*Pagereference pr = Page.ISSP_Registration;
            pr.getParameters().put('sRefererCommunity','iec');*/

            //String commingFromUrl = (paramReturnURL != null && paramReturnURL != '') ? 'IEC_Login?' + IECConstants.PARAM_RETURN_URL + '=' + paramReturnURL : 'IEC_Login';
            //Pagereference pr = Page.IECUserRegistration;
            //MM: I have changed the target registration page to the ISS registration page and added a parameter with the name of the initial call.
            Pagereference pr = Page.ISSP_Registration;
            pr.getParameters().put('sRefererCommunity', 'IEC_Login');
            pr.getParameters().put('CommunityName','IEC');


            // add return URL as parameter if one was provided
            //if (retURL != null && retURL != '') {
            pr.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter('IEC_Login'));
            //}
            
            pr.setRedirect(true);

            return pr;
        }
        catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));

			return null;
		}
    }


    public PageReference redirectToPage(String initialUrl){

    	//get params from page and include
    	Map<String,String> mapPageParameters = System.currentPageReference().getParameters();
        String extraParamsStr = '';
        if(mapPageParameters != null && mapPageParameters.keySet() != null && !mapPageParameters.keySet().isEmpty()){
	        for(String pageParam : mapPageParameters.keySet()){
	            if(pageParam.startsWith(IECConstants.PARAM_UTM)){
	                extraParamsStr += '&' + pageParam + '=' + mapPageParameters.get(pageParam);
	            }
	        }
	    }

	    String finalURL = initialUrl + EncodingUtil.urlEncode(extraParamsStr, 'UTF-8');
		PageReference pgRef = new PageReference(finalURL);
		pgRef.setRedirect(true);
    	return pgRef;


    }

}