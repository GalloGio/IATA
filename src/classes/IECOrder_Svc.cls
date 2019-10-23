public with sharing class IECOrder_Svc {
    /****************************************************************************************************
        Created by CGI, Kevin 2015-10-23
            Add product to Cookie
    ****************************************************************************************************/
    public static PageReference addCartToCookie(String productNumber,Decimal qty, String returnParam){
        System.debug('addCartToCookie CALLED');
        map<String,Decimal> orderITems = Order_Svc.getItemsInCookie();
        
        if(returnParam==null)
            returnParam = '/IEC_ShoppingCart';

        if(orderITems.size() > 0){
            //Add the new product to the cookie
            Integer nbCookies = nbreOfCookies();
            Boolean alreadyExist = addProductToCookie(productNumber, qty);

            System.debug('productNumber: ' + productNumber + ', qty=' + qty + ', alreadyExists: ' + alreadyExist);

            if(alreadyExist){
                returnParam += '?productNumber=' + productNumber;
            }

        }else{
            System.debug('Creating Order Cookie');

            Cookie orderCookie = createOrderCookie(productNumber, qty ,1);
            ApexPages.currentPage().setCookies(new Cookie[]{orderCookie});

            System.debug('Cookie set to: ' + orderCookie);
        }
        //return to view cart
        PageReference pageRef = new PageReference(returnParam);
        pageRef.setRedirect(true);
        return pageRef;        
    }

    public static PageReference addCartToCookie(String productNumber,Decimal qty)
    {
        return addCartToCookie(productNumber, qty, null);
    }

    /****************************************************************************************************
        Created by CGI, Kevin 2015-10-23
            Get the current Cookie
    ****************************************************************************************************/
    public static Cookie getOrderCookie(Integer nb){
        String cookieName = 'IECOrders_' + nb;
        Cookie cookieValue = ApexPages.currentPage().getCookies().get(cookieName);

        System.debug('getOrderCookie(' + nb + '), cookieName: ' + cookieName + ', cookieValue: ' + cookieValue);

        return cookieValue;
    }
    
    /****************************************************************************************************
        Created by CGI, Kevin 2015-10-23
            Create a new order Cookie
    ****************************************************************************************************/
    public static Cookie createOrderCookie(String productNumber,Decimal qty, Integer nb){
        return new Cookie('IECOrders_' + nb, productNumber + '_' + qty, null, Utility.getIntegerSetting('IEC Order Cookie maxAge'), false);
    }

    /****************************************************************************************************
        Created by CGI, Kevin 2015-10-23
            Modified a cookie value
    ****************************************************************************************************/
    public static Cookie modifiedOrderCookie(String value, Integer nb){
        return new Cookie('IECOrders_' + nb, value, null, Utility.getIntegerSetting('IEC Order Cookie maxAge'), false);
    }

    /****************************************************************************************************
        Created by CGI, Kevin 2015-10-23
            Get number of Customer cookies
    ****************************************************************************************************/
    public static Integer nbreOfCookies(){

        try{
            Cookie orderCookie = getOrderCookie(1);
            Integer nbs = 0;
            if(orderCookie != null){
                String allCookiesValues = '';
                String cookieName = orderCookie.getName();
                try{
                    nbs = Integer.valueOf(cookieName.split('_')[1]);
                    Boolean done = false;

                    While(!done){
                        String respVal = cookieValue(nbs);
                        if(respVal != null){
                            nbs++;
                        }else{
                            done = true;
                        }
                    }
                    nbs = nbs - 1;
                }catch(Exception ex){}
            }

            system.debug('Integer nbs ' + nbs);
            return nbs;
        }catch(Exception ex){}

        return null;
    }

    /****************************************************************************************************
    Created by Kevin Ky 2015-10-26
        Return a map of product Id with the Quantity
    ****************************************************************************************************/
    public static Map<String, Decimal> getItemsInCookie()
    {
        map<String,Decimal> prodId_Qty = new map<String,Decimal>();

        //Get the first Cookie
        Cookie orderCookie = getOrderCookie(1);

        if(orderCookie != null){
            String allCookiesValues = '';
            //get the Cookie name
            String cookieName = orderCookie.getName();

            Integer nbs;

            try{
                nbs = Integer.valueOf(cookieName.split('_')[1]);
                Boolean done = false;

                //Get all the product code and quantity in all the cookies
                While(!done){
                    String respVal = cookieValue(nbs);
                    if(respVal != null){
                        if(!allCookiesValues.contains(respVal)){
                            allCookiesValues = (allCookiesValues == '') ? respVal : allCookiesValues + '#' +respVal;
                        }
                        nbs++;
                    }else{
                        done = true;
                    }
                }
                
                if(allCookiesValues != ''){
                    //Get the list of the product code and Quantity
                    List<String> lstProdIdQty = allCookiesValues.split('#');
                    set<String> prodNumQties = new set<String>(lstProdIdQty);
                    if(prodNumQties != null && prodNumQties.size() > 0 ){
                        for(String str : prodNumQties){
                            List<String> prodIdsQties = str.split('_');
                            if(prodIdsQties != null && prodIdsQties.size() > 0){
                                try{
                                    //Put the product code as a key and the quatity as a value
                                    if(prodIdsQties[1].contains(',')){
                                       prodIdsQties[1] = prodIdsQties[1].replace(',','.');
                                    }
                                    Decimal qty = Decimal.valueOf(prodIdsQties[1]);
                                    prodId_Qty.put(prodIdsQties[0],qty);
                                }catch(Exception ex){}
                                
                            }
                        }
                    }
                }

            }catch(Exception ex){}
        }
        return prodId_Qty;
    }

    public static String cookieValue(Integer nb){
        return readCookie('IECOrders_' + nb);
    }

    public static String readCookie(String cookieName)
    {
        String value;
        Cookie cookie = ApexPages.currentPage().getCookies().get(cookieName);
        if(cookie != null){
            value = cookie.getValue();
        }
        return value;
    }

    /****************************************************************************************************
    Created by Kevin Ky 2015-10-26
        Add new product to Cookie
    ****************************************************************************************************/
    public static Boolean addProductToCookie(String productNumber, Decimal qty)
    {
        return addProductToCookie(productNumber, qty, false);
    }

    public static Boolean addProductToCookie(String productNumber, Decimal qty, Boolean overrideQty){
        System.debug('addProductToCookie productNumber: ' + productNumber + ', qty: ' + qty + ', overrideQty: ' + overrideQty);

        //Check if the product is a phase 1 and 2 products
        map<String,Product2> productMap = Product_Sel.getProductsByCode(new set<String>{productNumber});
        if(productMap != null && productMap.containsKey(productNumber) && productMap.get(productNumber).IEC_Static_Cart_Quantity__c != null && productMap.get(productNumber).IEC_Static_Cart_Quantity__c > 0){
            qty = productMap.get(productNumber).IEC_Static_Cart_Quantity__c;
            overrideQty = true;
        }

        Boolean alreadyExist = false;
        try{
            Cookie orderCookie = IECOrder_Svc.getOrderCookie(1);
            Integer nbs = 0;
            if(orderCookie != null){
                String allCookiesValues = '';
                String cookieName = orderCookie.getName();

                System.debug('cookieName: ' + cookieName);

                try{
                    nbs = Integer.valueOf(cookieName.split('_')[1]);
                    Boolean done = false;

                    While(!done){
                        String respVal = cookieValue(nbs);

                        System.debug('nbs: ' + nbs + ', respVal: ' + respVal);

                        if(respVal != null){
                            nbs++;
                        }else{
                            done = true;
                        }
                    }
                    nbs = nbs - 1;
                }catch(Exception ex){
                    System.debug('OrderCookie parse exception: ' + ex.getStackTraceString());
                }
            }
            else{
                //-- Create Cookie 
                orderCookie = createOrderCookie(productNumber,qty, 1);
                ApexPages.currentPage().setCookies(new Cookie[]{orderCookie});
                nbs = 1;

                System.debug('Store orderCookie: ' + orderCookie);
            }

            Cookie cookieToModified = IECOrder_Svc.getOrderCookie(nbs);
            String value = cookieToModified.getValue();

            //2700 char ==> 3k
            if(value.length() < 2700){
                System.debug('checking for productNumber: ' + productNumber);

                //Add the product to the cookie
                //if(!value.contains(productNumber))
                //{
                    if(value.contains(productNumber))
                    {
                        for(String row : value.split('#'))
                        {
                            if(row.contains(productNumber))
                            {
                                //Found the old qty to add to the new
                                List<String> lstProd_qty = row.split('_');
                                Decimal oldQty = 0;
                                try{
                                    if(overrideQty == false){
                                        oldQty = Decimal.valueOf(lstProd_qty[1]);
                                        qty = qty + oldQty;
                                    }
                                        
                                } catch(Exception ex) {
                                    System.debug('decimal parse of ' + lstProd_qty[1] + ' exception: ' + ex.getMessage());
                                }

                                value = value.replace(row, productNumber + '_' + qty);

                                System.debug('value: ' + value);
                            }
                        }
                        alreadyExist = true;
                    }
                    else
                    {
                        value += ((value.length() == 0) ? '' : '#') + productNumber + '_' + qty;    
                    }
                
                    ApexPages.currentPage().setCookies(new Cookie[]{IECOrder_Svc.modifiedOrderCookie(value, nbs)});

                    System.debug('Modify orderCookie');
                //}
            }else{
                //Create a new Cookie and add the product
                ApexPages.currentPage().setCookies(new Cookie[]{IECOrder_Svc.createOrderCookie(productNumber, qty, nbs + 1)});
                
                System.debug('Create new orderCookie nbs=' + (nbs-1));
            }

            

        }catch(Exception ex){
            System.debug('addProductToCookie exception caught: ' + ex.getStackTraceString());
        }

        return alreadyExist;

    }

    /****************************************************************************************************
    Created by Kevin Ky 2015-10-26
        Modified product into Cookie
    ****************************************************************************************************/
    public static void modifiedProductToCookie(String productNumber,Decimal qty){
        
        try{
            //Get the first Cookie
            Cookie orderCookie = IECOrder_Svc.getOrderCookie(1);
            Integer nbs = 0;
            if(orderCookie != null){
                //String allCookiesValues = '';
                //get the first cookie name
                String cookieName = orderCookie.getName();
                try{
                    nbs = Integer.valueOf(cookieName.split('_')[1]);
                    Boolean done = false;

                    //Get the existing product Number and update it with the new Quantity
                    While(!done){

                        String respVal = cookieValue(nbs);
                        Boolean found = false;

                        if(respVal != null){
                            
                            List<String> restValue = new List<String>();
                            //If multiple product in the cookie
                            if(respVal.contains('#') && respVal.contains(productNumber)){
                                List<String> lstPrdNberQty = respVal.split('#');
                                //Avoid duplicate Products
                                set<String> prdNbQties = new set<String>(lstPrdNberQty);
                                for(String str : prdNbQties){
                                    if(!str.contains(productNumber)){
                                        restValue.add(str);
                                    }else{
                                        restValue.add(productNumber + '_' + qty);
                                        found = true;
                                    }
                                }
                            }else{
                                //if one Product in the cookie
                                if(respVal.contains(productNumber)){
                                    restValue.add(productNumber + '_' + qty);
                                    found = true;
                                }
                            }
                            if(found){
                                //Update the cookie with the new value
                                String value = String.join(restValue, '#');
                                ApexPages.currentPage().setCookies(new Cookie[]{IECOrder_Svc.modifiedOrderCookie(value, nbs)});
                                done = true;
                            }
                            nbs++;
                        }else{
                            done = true;
                        }
                    }
                }catch(Exception ex){

                }
            }           

        }catch(Exception ex){}
    }

    /****************************************************************************************************
    Created by Kevin Ky 2015-10-26
        Delete product into Cookie
    ****************************************************************************************************/
    public static void deleteProductToCookie(String productNumber){
        
        try{
            //Get the first Cookie
            Cookie orderCookie = IECOrder_Svc.getOrderCookie(1);
            Integer nbs = 0;
            if(orderCookie != null){
                String allCookiesValues = '';
                String cookieName = orderCookie.getName();
                try{
                    nbs = Integer.valueOf(cookieName.split('_')[1]);
                    Boolean done = false;

                    //Loop on all the order product cookie to delete the product
                    While(!done){

                        String respVal = cookieValue(nbs);
                        Boolean found = false;

                        if(respVal != null){
                            
                            List<String> restValue = new List<String>();
                            //Verified if the value of the cookie contains le product number
                            if(respVal.contains('#') && respVal.contains(productNumber + '_')){
                                List<String> lstPrdNberQty = respVal.split('#');
                                //Found the product number in the product numbers list
                                for(String str : lstPrdNberQty){
                                    if(!str.contains(productNumber)){
                                        restValue.add(str);
                                    }else{
                                        found = true;
                                    }
                                }
                            }else{
                                if(respVal.contains(productNumber)){
                                    restValue.add(' ');
                                    found = true;
                                }
                            }
                            //If the product Number found delete it
                            if(found){
                                String value = String.join(restValue, '#');
                                ApexPages.currentPage().setCookies(new Cookie[]{IECOrder_Svc.modifiedOrderCookie(value, nbs)});
                                done = true;
                            }
                            nbs++;
                        }else{
                            done = true;
                        }
                    }
                    nbs = nbs - 1;
                }catch(Exception ex){

                }
            }           

        }catch(Exception ex){}

    }

    /****************************************************************************************************
    Created by Kevin Ky 2015-10-31
        Delete product into Cookie
    ****************************************************************************************************/
    public static void deleteAllCookies(){

        Cookie orderCookie = getOrderCookie(1);

        if(orderCookie != null){
            String allCookiesValues = '';
            String cookieName = orderCookie.getName();

            Integer nbs;

            List<Cookie> cookiesToDelete = new List<Cookie>();

            try{
                nbs = Integer.valueOf(cookieName.split('_')[1]);
                Boolean done = false;

                While(!done){
                    Cookie cookieToDelete = getOrderCookie(nbs);
                    if(cookieToDelete != null){
                        String name = cookieToDelete.getName();
                        String value = cookieToDelete.getValue();
                        cookieToDelete = new Cookie(name, '', null, 0, false);
                        cookiesToDelete.add(cookieToDelete);
                    }else{
                        done = true;
                    }
                    nbs++;
                }
            }catch(Exception ex){

            }
            System.debug('cookiesToDelete::'+cookiesToDelete);
            if(cookiesToDelete.size() > 0){
                ApexPages.currentPage().setCookies(cookiesToDelete); 
            }
        }

    }

    /****************************************************************************************************
    Created by Kevin Ky 2015-10-26
        Return User to the login page
    ****************************************************************************************************/
    public static PageReference returnToLogin(String returl){

        PageReference pageRef = new PageReference('IEC_Login?returl=' + IECUtil.EncryptEncodeParameter(returl));
        pageRef.setRedirect(true);
        return pageRef;
    }

    /*public static List<OrderItem> saveCookieProducts(Order theOrder, List<OrderItem_DTO> orderItems)
    {
        List<OrderItem> orderItems2Save = new List<OrderItem>();

        //-- Selectors 
        Order_Sel orderSelector = new Order_Sel();
        Pricebook_Sel pricebookSelector = new Pricebook_Sel();  
        PricebookEntry_Sel pricebookEntrySelector = new PricebookEntry_Sel();  

        //-- Remove order previous items 
        orderSelector.cleanOrderItems(theOrder.Id);       


        //-- 1. Validate products in cookie are all valid
        Set<String> productsCode = new Set<String>(); 
        for(OrderItem_DTO oid : orderItems)
        {
            productsCode.add(oid.productCode);
        }

        Map<String,Product2> productByCode = Product_Sel.getProductsByCode(productsCode);

        List<Id> listProductId = new List<Id>();
        for(String pCode : productByCode.keySet())
            listProductId.add(productByCode.get(pCode).Id);

        //-- ecom product in Cookie
        List<EComProduct_DTO> ecomProducts = Product_Sel.getEComProduct(listProductId, false,null,null, false);
        Map<Id, EComProduct_DTO> ecomProductById = new Map<Id, EComProduct_DTO>();
        Map<String, EComProduct_DTO> ecomProductByCode = new Map<String, EComProduct_DTO>();

        for(EComProduct_DTO ep : ecomProducts)
        {
            ecomProductById.put(ep.ProductId, ep);
            ecomProductByCode.put(ep.ProductNumber, ep);
        }

        //-- 2. Find the proper pricebook entry to create the OrderItem 
        Pricebook2 stdPriceBook = pricebookSelector.getStandardPriceBook();
        Map<Id, PricebookEntry> pricebookEntryByProductId = pricebookEntrySelector.getPricebookEntryByProductId(stdPriceBook.Id, ecomProductById.keySet());
        Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>();


        //-- 3. For each valid ecomProduct ...
        for(OrderItem_DTO oid : orderItems)
        {
            // Is is ecomProduct? 
            if(ecomProductByCode.containsKey(oid.productCode))
            {
                EComProduct_DTO ecomProduct = ecomProductByCode.get(oid.productCode);

                if(pricebookEntryByProductId.containsKey(ecomProduct.ProductId))
                {
                    PricebookEntry pbe = pricebookEntryByProductId.get(ecomProduct.ProductId);

                     //-- create the orderitem 
                    orderItems2Save.add(new OrderItem(
                        OrderId = theOrder.Id, 
                        PriceBookEntryId = pbe.Id,
                        Quantity = oid.quantity,
                        Coupon__c = oid.couponCode
                    ));
                    mapProductNumber_Price.put(ecomProduct.ProductNumber, ecomProduct.PriceInfo);
                } 
            }            
        }

        if(orderItems2Save.size() > 0)
        {
            try{
                //insert orderItems2Save;
                Order_Svc.setPriceToOrderItem(orderItems2Save, mapProductNumber_Price, theOrder.ShipToContactId);
            }   
            catch(Exception ex){
                System.debug('ex::'+ex.getMessage());
            }
        }

        return orderItems2Save;

    }*/

    public static List<OrderItem_DTO> getOrderItemsInCookie()
    {
        List<OrderItem_DTO> orderItems = new List<OrderItem_DTO>(); 

        Map<String, Decimal> items = Order_Svc.getItemsInCookie(); // PRODUCT_Rate => QTY
     
        System.debug('getOrderITemsInCookie');
        System.debug('#items: ' + items.size());
        System.debug('items --> ' + items);
   
        if(!items.isEmpty())
        {
            Map<String,Product2> productByCode = Product_Sel.getProductsByCode(items.keySet());
            List<Id> listProductId = new List<Id>();

            System.debug('productByCode.keySet: ' + (productByCode.keySet()));
           
            for(String pCode : productByCode.keySet())
            {
                Product2 p = productByCode.get(pCode);
                listProductId.add(p.Id);
            }

            //Product Swap in case it as swap configured
            doProductSwap(items, listProductId);

            //-- Get product informations 
            List<EComProduct_DTO> ecomProducts = Product_Sel.getEComProduct(listProductId, false,null,null, false, null);
            Map<String, EComProduct_DTO> ecomProductById = new Map<String, EComProduct_DTO>();

            System.debug('#ecomProducts: ' + ecomProducts.size());

            for(EComProduct_DTO ep : ecomProducts)
            {
                ecomProductById.put(ep.ProductId, ep);
            }

            String customerType = User_Sel.getCustomerType(UserInfo.getUserId());

            System.debug('customerType: ' + customerType);

            for(EComProduct_DTO ecomProduct : ecomProducts)
            {
                System.debug('ecomProduct.PriceInfo: ' + (ecomProduct.PriceInfo == null ? 'NULL' : 'defined'));

                if(ecomProduct.PriceInfo == null)
                {
                    deleteProductToCookie(ecomProduct.ProductNumber);
                    continue;  
                } 

                Decimal quantity = items.get(ecomProduct.ProductNumber);
                Decimal setupFee = (ecomProduct.setupFee !=null)
                    ? ecomProduct.setupFee
                    : 0;

                OrderItem_DTO oi_dto = new OrderItem_DTO();

                System.debug('ecomProduct quantity: ' + quantity + ', setupFee: ' + setupFee);

                oi_dto.IECStaticCartQuantity = ecomProduct.IECStaticCartQuantity;
                    if(oi_dto.IECStaticCartQuantity != null && oi_dto.IECStaticCartQuantity > 0)
                    quantity = oi_dto.IECStaticCartQuantity; //Default quantity for phase 1 and 2 products

                    oi_dto.productId = ecomProduct.ProductId;
                    oi_dto.productName  = ecomProduct.ProductName;
                    oi_dto.productCode  = ecomProduct.ProductNumber; 
                    oi_dto.description  = ecomProduct.ProductDesc;
                    oi_dto.imageName    = ecomProduct.ImageName;
                    oi_dto.quantity     = quantity;
                oi_dto.PriceInfo = ecomProduct.PriceInfo;
                oi_dto.IsQuantityInteger = ecomProduct.IsQuantityInteger;
                    oi_dto.setupFee = setupFee;
                    oi_dto.unitPrice    = Order_Svc.getUnitPrice(ecomProduct.PriceInfo, oi_dto.quantity, customerType);
                    oi_dto.subTotal     = (oi_dto.unitPrice != null)? (oi_dto.unitPrice * quantity) + setupFee : setupFee;   
                orderItems.add(oi_dto);                     
            }
        }  

        System.debug('#orderItems: ' + orderItems.size());

        if(orderItems.size() > 0)
            orderItems.sort();

        return orderItems;
    }

    public static void changePenddingOrder(Order newPending)
    {
        //RN-INC421212
        //IEC_Cart cartInstance = IEC_Cart.getInstance();
        IEC_Cart cartInstance = IEC_Cart.initializer();
        cartInstance.setPendingOrder(newPending);
        

        IEC_Functionality functionality = IEC_Functionality.getInstance();
        Boolean newShoppingCart = functionality.isActive('New Shopping Cart');
		
        Order o = getPenddingOrder(true);
        if(String.isBlank(o.IEC_Order_Previous_Type__c))
        {
            try{delete o;}catch(Exception ex){}    
        }
        else
        {
            o.Type = o.IEC_Order_Previous_Type__c;
            try{update o;}catch(Exception ex){}   
        }
        
        if (newShoppingCart == false) {
            IECOrder_Svc.deleteAllCookies();
        } else {
            
        }

        newPending.IEC_Order_Previous_Type__c = newPending.Type;
        newPending.Type = 'Cart';
        newPending.Status = 'New';
        try{update newPending;}catch(Exception ex){}  

        if (newShoppingCart == false) {
            List<OrderItem> pendingOrderItems = new OrderItem_Sel().getOrderItems(newPending.Id);
            for(OrderItem oi : pendingOrderItems)
            {
                IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
            }   
        } else {
            cartInstance.reloadOrder();
        }
    }

    public static Order getPenddingOrder(String orderId)
    {
        if(orderId == null) return getPenddingOrder(true); 

        return Order_Sel.getOrderForVF(orderId);
    }

    public static Order getPenddingOrder(Boolean createOrder)
    {
        Customer_DTO oCurrentCustomer = Customer_DTO.getLoggedCustomer();

        //-- Data Selectors 
        Order_Sel orderSelector = new Order_Sel();
        
        //-- Check if current User has pending Order: if not create one
        System.debug('pendding order for::'+oCurrentCustomer.sfUser.Id);
        Order pendingOrder = orderSelector.getPenddingOrder(oCurrentCustomer.sfUser.Id);

        //if no pending orders where the user is the ownerId it will check if there is orders for the user contact on the billToContactId
        if(pendingOrder == null){
            System.debug('pendding order for::'+oCurrentCustomer.sfUser.ContactId);
            pendingOrder = orderSelector.getPendingOrderByBillToContactId(oCurrentCustomer.sfUser.ContactId);
        }


        //-- Validate Order Locations are valid
        if(pendingOrder != null)
        {
            System.debug('Pending order: ' + pendingOrder);

            Boolean updatePendding= false;
            if(pendingOrder.BillTo_Location__c != oCurrentCustomer.sfContact.BillTo_Location__c){
                
                pendingOrder.BillTo_Location__c = oCurrentCustomer.sfContact.BillTo_Location__c;
                updatePendding = true;
            }

            Map<Id, Location__c> customerActiveShipToLocations = new Map<Id, Location__c>(); 
            for(Location__c loc : Location_Sel.getLocationByContact(oCurrentCustomer.sfContact.Id, IECConstants.SHIPTO))
            {
                customerActiveShipToLocations.put(loc.Id, loc);
            }

            if(pendingOrder.ShipTo_Location__c != null && !customerActiveShipToLocations.containsKey(pendingOrder.ShipTo_Location__c))
            {
                pendingOrder.ShipTo_Location__c = null; 
                updatePendding = true;
            }

            if(updatePendding) update pendingOrder;

            return pendingOrder;
        }
        else 
        {
            System.debug('No pending order, create a new order ?' + (createOrder ? 'Yes' : 'No'));

            if (createOrder)
                return orderSelector.initializeOrder(oCurrentCustomer.sfAccount, oCurrentCustomer.sfContact, oCurrentCustomer.sfUser.Id);
            else
                return new Order(OwnerId = oCurrentCustomer.sfUser.Id);
        }
    }


    public static void createOrderFromCookie()
    {
        //-- This function must be called only if a user ius connected 
        if(IECUserManager.isUserLoggedIn())
        {
            Order pendingOrder;
            Customer_DTO oCurrentCustomer = Customer_DTO.getLoggedCustomer();

            //-- Data Selectors 
            Order_Sel orderSelector = new Order_Sel();
            OrderItem_Sel itemSelector = new OrderItem_Sel();
            OrderItemCharge_Sel chargeSelector = new OrderItemCharge_Sel();
            Pricebook_Sel pricebookSelector = new Pricebook_Sel();  
            PricebookEntry_Sel pricebookEntrySelector = new PricebookEntry_Sel(); 

            //-- Check if current User has pending Order: if not create one
            pendingOrder = orderSelector.getPenddingOrder(oCurrentCustomer.sfUser.Id);
            
            if(pendingOrder == null)
            {
                pendingOrder = orderSelector.initializeOrder(oCurrentCustomer.sfAccount, oCurrentCustomer.sfContact, oCurrentCustomer.sfUser.Id);
            }

            Map<Id, List<OrderItem>> orderItemsByOrder = itemSelector.getOrderItems(new Set<Id>{pendingOrder.Id});

            //-- Sync  Cookie <=> DB
           
            //-- If pendding order has orderItems, add them into the cookie
            Set<String> existingProductCodes = new Set<String>();

            List<OrderItem> orderItems;
            Map<String, OrderItem> orderItemByProductCode = new Map<String, OrderItem>();

            if(orderItemsByOrder.containsKey(pendingOrder.Id))
            {
                orderItems = orderItemsByOrder.get(pendingOrder.Id);
                if(orderItems.size() > 0)
                {
                    for(OrderItem oi : orderItems)
                    {
                        orderItemByProductCode.put(oi.Product_Number__c, oi);
                        existingProductCodes.add(oi.Product_Number__c);
                        //addProductToCookie(oi.Product_Number__c, oi.Quantity);
                    }
                }
            }

            //-- Create/Update OrderItem from Cookie 
            Map<String, Decimal> productsInCookie = Order_Svc.getItemsInCookie(); // PRODUCT_CODE => QTY
            Map<String,Product2> productByCode = Product_Sel.getProductsByCode(productsInCookie.keySet());

            //-- Validate Products in Cookie can be sold 
            List<Id> listProductId = new List<Id>();
            for(String pCode : productByCode.keySet())
                listProductId.add(productByCode.get(pCode).Id);

            List<EComProduct_DTO> ecomProducts = Product_Sel.getEComProduct(listProductId, false,null,null, false, null);
            Map<Id, EComProduct_DTO> ecomProductById = new Map<Id, EComProduct_DTO>();
            Map<String, EComProduct_DTO> ecomProductByCode = new Map<String, EComProduct_DTO>();

            for(EComProduct_DTO ep : ecomProducts)
            {
                ecomProductById.put(ep.ProductId, ep);
                ecomProductByCode.put(ep.ProductNumber, ep);
            }   
            
            //-- 2. Find the proper pricebook entry to create the OrderItem 
            Pricebook2 stdPriceBook = pricebookSelector.getStandardPriceBook();
            Map<Id, PricebookEntry> pricebookEntryByProductId = pricebookEntrySelector.getPricebookEntryByProductId(stdPriceBook.Id, ecomProductById.keySet());
            Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>();

            List<OrderItem> orderItem2Create = new List<OrderItem>(); 
            List<OrderItem> orderItem2Update = new List<OrderItem>(); 
            
            if(productsInCookie != null){
                for(String productCode : productsInCookie.keySet())
                {
                    EComProduct_DTO ecomProduct = ecomProductByCode.get(productCode);
                    if(ecomProduct == null)
                        continue;
                    mapProductNumber_Price.put(productCode, ecomProduct.PriceInfo);
                    //-- Only add new products 
                    if(!existingProductCodes.contains(productCode) && ecomProductByCode.containsKey(productCode))
                    {
                        if(pricebookEntryByProductId.containsKey(ecomProduct.ProductId))
                        {
                            PricebookEntry pbe = pricebookEntryByProductId.get(ecomProduct.ProductId);
                            Decimal quantity = productsInCookie.get(productCode);

                            orderItem2Create.add(new OrderItem(
                                OrderId = pendingOrder.Id, 
                                PriceBookEntryId = pbe.Id,
                                Quantity = quantity,
                                Charge_Shipping__c = ecomProduct.ChargeShipping,
                                UnitPrice = ecomProduct.UnitPrice
                            ));
                        }
                            
                    }
                }
            }
            
            if (orderItems != null) orderItem2Create.addAll(orderItems);

            if(!Test.isRunningTest()) Order_Svc.setPriceToOrderItem(orderItem2Create, mapProductNumber_Price, pendingOrder.ShipToContactId);

        }   
    }

    /****************************************************************************************************
    Created by Kevin Ky 2015-10-28
        Delete OrderItem base on the Id
    ****************************************************************************************************/
    /*public static void deletionOrderItems(set<Id> orderItemIds){
        delete [select id from OrderItem where id in :orderItemIds];
    }*/

    public static Boolean validateQuoteNumberToConvert(String quoteNumber, Id createdBy, Id billToContactId)
    {
        /**Type='Quote' 
                AND 
                */
        List<Order> quotes = [
            SELECT Id 
            FROM Order 
            WHERE ( OwnerId = :createdBy OR BillToContactId = :billToContactId)
                AND OrderNumber = :quoteNumber
            LIMIT 1
        ];

        return (quotes.size() == 1);
    }


    /****************************************************************************************************
        doProductSwap, function that retrieves a list of pricebookEntries for given
                                     pricebook and product
        @Id pricebookId, Id of the pricebook
        @Id productId, Id of the product
        @return, list of priceEntry by ProductId
        
        Author: Angela Lazaro 
    ****************************************************************************************************/
    private static void doProductSwap(Map<String, Decimal> items, List<Id> listProductId){

        List<Swap_Configuration__c> swapConfList = new List<Swap_Configuration__c>();
        swapConfList = [Select Id, Relationship_Type__c, Source_Product_Rate_Plan_Information__c, Target_Product_Rate_Plan_Information__c
                            from Swap_Configuration__c where Source_Product_Rate_Plan_Information__c = :items.keySet()];
        
        for(Swap_Configuration__c swapConf : swapConfList){

            if (swapConf.Relationship_Type__c == IECConstants.SwappingType_Swap){

                Product2 targetProductId = [select Id, IEC_Product_Rate_Plan_Information__c from Product2
                 where IEC_Product_Rate_Plan_Information__c  = :swapConf.Target_Product_Rate_Plan_Information__c limit 1];

                listProductId.add(targetProductId.Id);

                //Format from 18 digits Id to 15 digits Id
                String srcProductPlan = String.valueOf(swapConf.Source_Product_Rate_Plan_Information__c);
                srcProductPlan = srcProductPlan.substring(0, srcProductPlan.length() - 3);

                String trgProductPlan = String.valueOf(swapConf.Target_Product_Rate_Plan_Information__c);
                trgProductPlan = trgProductPlan.substring(0, trgProductPlan.length() - 3);

                items.put(trgProductPlan, items.get(srcProductPlan));
            }

        }

        
    }

/****************************************************************************************************
    Created by blue-infinity, Susana 2017-08-18
        Delete an order
****************************************************************************************************/
public static void deleteOrder(Order order) {
    Savepoint sp = Database.setSavepoint();
    try {
        delete [select Id from Order where Id = :order.id];
    } catch (Exception e) {
        ApexPages.addMessages(e);
        Database.rollback(sp);
    }
} //*** end of "deleteOrderById"

}