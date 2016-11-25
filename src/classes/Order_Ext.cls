/****************************************************************************************************
    Created by CGI, Thai 2015-09-28
        Extension for VF page "Order"
****************************************************************************************************/
global class Order_Ext 
{
    public Order vfOrder { get; set; }

    public Boolean isEdit { get; set; }
    public Boolean isNew { get; set; }
    public Boolean isCancelling { get; set; }
    public Boolean isPaying { get; set; }
    public Boolean isInlineEditing { get; set; }
    public Boolean isPending { get; set; }
    public Boolean allowEditSave { get; set; }
    public Boolean allowDelete { get; set; }
    public Boolean allowPay { get; set; }
    public Boolean allowCancel { get; set; }
    public Boolean allowNewCustomer { get; set; }
    public String attentionMsg { get; set; }

    //--- Selectors for Database query
    private OrderItem_Sel itemsSelector;
    private Order_Sel orderSelector;
    private OrderItemCharge_Sel chargeSelector;
    private Product_Sel productSelector;

    //--- Order & OrderItems 
    public List<OrderItem_DTO> orderProducts{get;set;}
    public List<SAPInvoice_DTO> orderInvoices{get;set;}
    public List<SalesOrderProduct_DTO> availableProducts{get;set;}
    public List<SalesOrderProduct_DTO> selectedProducts{get;set;}
    public String selectedProductsIdsStr{get;set;}
    public String selectedProductsNumbers{get;set;}
    public OrderItem_DTO orderItemToEdit{get;set;}

    //-- UI interraction var
    public Boolean showAddProducts{get;set;}
    public Boolean showProductSelection{get;set;}
    public Boolean showButtonCreateSalesOrder{get;set;}

    //--- Country & States
    public List<SelectOption> listCountry { get; set; }
    public List<SelectOption> listBillingState { get; set; }
    public List<SelectOption> listShippingState { get; set; }
    List<ISO_Country_State_DTO> listCountryState;

    public List<SelectOption> listPaymentType { get; set; }
    public String paymentType { get; set; }
    public Boolean overridePaymentType{get;set;}
    
    public Map<Id, Boolean> mapProduct2Id_Compliance { get; set; }
    public Boolean bAreProductsCompliant { get; set; }
        
    public Map<String, String> labels { get; set; }  //*** labels & error messages
    
    Id bkSoldToAccountId, bkBillToContactId, bkShipToContactId;  // backup of values when user checks Is New...
    String bkCoupon;
    Decimal bkQuantity;
    String returnURL;

    Contact billToContact ;
    Account billToContactAccount;

    public Location__c billToLocation{get;set;}
    public Location__c shipToLocation{get;set;}
    public string selectedBillToLocation{get;set;}
    public String selectedShipToLocation{get;set;}
    public Boolean editMod{get;set;}
    public Boolean shipToEditMod{get;set;}
    public Boolean editModShp{get;set;}

    public string street {get;set;}
    public string city {get;set;}
    public string country {get;set;}
    public string state {get;set;}
    public string zipCode {get;set;}

    public string shipStreet {get;set;}
    public string shipCity {get;set;}
    public string shipCountry {get;set;}
    public string shipState {get;set;}
    public string shipZipCode {get;set;}
    
    //Address information
    public String existingBillingCountryIsoCode;
    public String existingBillingIsoCode;
    public String existingBillingStreet = '';
    public String existingBillingCity = '';
    public String existingBillingZipCode = '';
    public String existingEmail;
    public String existingPhone;
    public String existingBillToVatNumber;

    public String existingShippingCountryIsoCode = '';
    public String existingShippingStateIsoCode = '';
    public String existingShippingStreet = '';
    public String existingShippingCity = '';
    public String existingShippingZipCode = '';
    public String existingShippingVATNumber = '';
    public String existingShippingEmail;
    public String existingShippingPhone;

    public String selectedCountryIsoCode{get;set;}
    public String selectedStateIsoCode{get;set;}

    public String selectedShipCountryIsoCode{get;set;}
    public String selectedShipStateIsoCode{get;set;}

    Id existingBillToLocationId;
    public Boolean vATNumberRequired {get;set;}
    public Boolean vATNumberRequiredBillTo {get;set;}
    public String vatNumber{get;set;}
    public String vatNumberBillTo {get;set;}
    public string fullAddress{get;set;}
    public Boolean billToZipCodeRequired{get;set;}
    public Boolean shipToZipCodeRequired{get;set;}
    public Boolean countryAndStateEditable{get;set;}

    
    /****************************************************************************************************
        Created by CGI, Thai 2015-09-28
            Constructor
    ****************************************************************************************************/
    public Order_Ext(ApexPages.StandardController controller) {
        
        labels = Utility.buildMapFromString(Label.LabelsVF_Order + '\n' + Label.LabelsVF_Order2, '\n', ':');
        
        //*** get order's record
        vfOrder = (Order) controller.getRecord();

        
        //if Set as default payment method is checked, update the Account with the new payment method
        if(vfOrder.Id != null)
            vfOrder = Order_Sel.getOrderForVF(vfOrder.Id);

      String strTemp1;
        
        //*** initialize some control variables
        returnURL = ApexPages.currentPage().getParameters().get('retURL');
        isEdit = (returnURL != null);
        isNew = (vfOrder.Id == null || ApexPages.currentPage().getParameters().get('save_new') == '1');
        if (isEdit) {
            //buildCountryStatePicklist();
            if (isNew) {
                allowEditSave = true;
                vfOrder.Type = Utility.getTextSetting('vfOrder-DefaultType');
                vfOrder.EffectiveDate = system.today();
                vfOrder.Status = Utility.getTextSetting('vfOrder-DefaultStatus');
                vfOrder.Source__c = Utility.getTextSetting('vfOrder-DefaultSource');
                vfOrder.Order_Channel__c = Utility.getTextSetting('vfOrder-DefaultChannel');
                vfOrder.Pricebook2Id = new Pricebook_Sel().getStandardPriceBook().Id;
                vfOrder.BillToContactId = ApexPages.currentPage().getParameters().get('contactID');

                if (vfOrder.BillToContactId != null) {
                    vfOrder.ShipToContactId = vfOrder.BillToContactId;
                } else {
                    vfOrder.AccountId = ApexPages.currentPage().getParameters().get('accountID');
                }
            } else {
                strTemp1 = ',' + Utility.getTextSetting('Order status allows order modification') + ',';
                allowEditSave = !vfOrder.Is_Paid__c && (((vfOrder.Status == null) || strTemp1.containsIgnoreCase(',' + vfOrder.Status + ',')));
            }
            allowDelete = false;
            allowPay = false;
            allowCancel = false;
            strTemp1 = ',' + Utility.getTextSetting('vfOrder-StatusAllowingNewCustomer') + ',';
            allowNewCustomer = ((vfOrder.Status == null) || strTemp1.containsIgnoreCase(',' + vfOrder.Status + ','));
        } else {
            if (isNew) {
                allowEditSave = true;
                allowDelete = false;
                allowPay = false;
                allowCancel = false;
            } else {
                strTemp1 = ',' + Utility.getTextSetting('Order status allows order modification') + ',';
                allowEditSave = !vfOrder.Is_Paid__c && (((vfOrder.Status == null) || strTemp1.containsIgnoreCase(',' + vfOrder.Status + ',')));
                strTemp1 = ',' + Utility.getTextSetting('Order status allows order deletion') + ',';
                allowDelete = !vfOrder.Is_Paid__c && (((vfOrder.Status == null) || strTemp1.containsIgnoreCase(',' + vfOrder.Status + ',')));
                strTemp1 = ',' + Utility.getTextSetting('Order status allows payment') + ',';
                allowPay = strTemp1.containsIgnoreCase(',' + vfOrder.Status + ',') && vfOrder.Type.containsIgnoreCase('Order');
                strTemp1 = ',' + Utility.getTextSetting('Order status allows cancel') + ',';
                allowCancel = strTemp1.containsIgnoreCase(',' + vfOrder.Status + ',');
            }
        }
        isCancelling = false;
        isPaying = false;
        isInlineEditing = false;
        isPending = (vfOrder.Status == 'New');
        
        //*** build attention message
        attentionMsg = '';
        if (vfOrder.Has_Shipping_Instruction__c){ attentionMsg += labels.get('msgWarnShipping'); }

        //Message for handling charges 
        if(vfOrder.Total_handling_charges__c > 0){ attentionMsg += labels.get('msgWarnHandling'); }

        //-- Init OrderItem Stuff
        initOrderItems();

        //-- Init OrderInvoices 
        initOrderInvoices();


        //-- Create SAP SalesORder Button 
        if(vfOrder.SAP_Order_Number__c == null && (vfOrder.Status == IECConstants.ORDER_STATUS_READY_FOR_SAP || vfOrder.Status == IECConstants.ORDER_STATUS_PAID))
        {
            showButtonCreateSalesOrder = true;
        }
        else
        {
            showButtonCreateSalesOrder = false;
        }

        //get the Account defautl payment method from the BillToContactId
        if(vfOrder.BillToContactId != null){
            billToContact = new Contact_Sel().getContactById(vfOrder.BillToContactId);
            billToContactAccount = new Account_Sel().getAccountById(billToContact.AccountId);
            if(billToContactAccount.Default_Payment_Type__c != null && billToContactAccount.Default_Payment_Type__c.contains('Credit')){
                paymentType = IECConstants.ORDER_STATUS_CREDIT_CARD_DEFERRED;
            }else{
                paymentType = billToContactAccount.Default_Payment_Type__c;
            }

            String orderPaymentMethod = vfOrder.Payment_Type__c;
            String accountPaymentMethode = billToContactAccount.Default_Payment_Type__c;
            if(accountPaymentMethode != null && accountPaymentMethode.startsWith('Credit')){
                accountPaymentMethode = IECConstants.ORDER_STATUS_CREDIT_CARD_DEFERRED;
            }

            if(orderPaymentMethod != accountPaymentMethode && orderPaymentMethod != null){ attentionMsg += labels.get('msgWarnDefaultPayment'); }

        }

    } //*** end of "Order_Ext"

    public PageReference pageLoad(){

        //Initialize all variables
        billToLocation              =   new Location__c();
        shipToLocation              =   new Location__c();
        editMod                     =   false;
        shipToEditMod               =   false;
        editModShp                  =   false;
        vATNumberRequired           =   false;
        vATNumberRequiredBillTo     =   false;  
        billToZipCodeRequired       =   false;
        shipToZipCodeRequired       =   false;  
        countryAndStateEditable     =   false;  

        Id billToAddressId;
        
        //set the new BillTo_Location__c and ShipTo_Location__c when the order is create from a Contact
        String contactId = ApexPages.currentPage().getParameters().get('contactID');
        Id myContactId;
        if((contactId != null && contactId != '') || vfOrder.Id != null){

            if(vfOrder.Id != null){
                //vfOrder = Order_Sel.getOrderForVF(vfOrder.Id);
                myContactId = vfOrder.ShipToContactId;
                //get the related iecAddress
                billToAddressId = vfOrder.BillTo_Address__c;
                selectedShipToLocation = vfOrder.ShipTo_Location__c;
            }else{

                //Create a new BillTo and ShipTo Location if the Contact don't have one
                Contact selectedContact = new Contact_Sel().getContactById(contactId);
                if(selectedContact.BillTo_Location__c == null || selectedContact.ShipTo_Location__c == null){
                    Boolean initializeLocations = Location_Svc.InitializeContactLocations(contactId);
                    if(!initializeLocations){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Address_creation_error));
                        return null;
                    }
                }

                //set billTo and ShipTo location related to the Contact
                myContactId = contactId;
                map<Id,Location__c> contactMap = new Location_Sel().getContactsLocations(new set<Id>{contactId});
                if(contactMap != null && contactMap.size() > 0){
                    for(Location__c locat : contactMap.values()){
                        if(locat.Type__c == IECConstants.BILLTO){
                            vfOrder.BillTo_Location__c = locat.Id;
                            //get the related iecAddress
                            billToAddressId = locat.Address__c;
                            selectedBillToLocation   =  vfOrder.BillTo_Location__c;
                        }

                        if(locat.Type__c == IECConstants.SHIPTO){
                            vfOrder.ShipTo_Location__c = locat.Id;
                            selectedShipToLocation = vfOrder.ShipTo_Location__c;
                        }
                    }
                }
            }

            Contact shipToContact = new Contact_Sel().getContactById(myContactId);
            if(shipToContact != null && shipToContact.ShipTo_Location__c != null && vfOrder.ShipTo_Location__c == null){
                vfOrder.ShipTo_Location__c = shipToContact.ShipTo_Location__c;
                selectedShipToLocation = shipToContact.ShipTo_Location__c;
            }
            
            //set the default billTo and ShipTo
            map<Id,Location__c> locationMap = new Location_Sel().getLocationById(new set<Id>{vfOrder.BillTo_Location__c,vfOrder.ShipTo_Location__c});
            
            billToLocation = locationMap.get(vfOrder.BillTo_Location__c);
            shipToLocation = (locationMap.get(vfOrder.ShipTo_Location__c) != null) ? locationMap.get(vfOrder.ShipTo_Location__c) : new Location__c();
            
            if(billToLocation != null){
                //Set the selected country and State for Billing
                selectedCountryIsoCode          =   billToLocation.Address__r.ISO_Country__r.ISO_Code__c;
                selectedStateIsoCode            =   (billToLocation.Address__r != null && billToLocation.Address__r.get('ISO_State__c') != null ) ? billToLocation.Address__r.ISO_State__r.ISO_Code__c : '';

                //set the existing address
                existingBillingCountryIsoCode   =   selectedCountryIsoCode;
                existingBillingIsoCode          =   selectedStateIsoCode;
                existingBillingStreet           =   billToLocation.Address__r.Street__c;
                existingBillingCity             =   billToLocation.Address__r.City__c;
                existingBillingZipCode          =   billToLocation.Address__r.ZipCode__c;
                existingBillToLocationId        =   vfOrder.BillTo_Location__c;
                existingEmail                   =   billToLocation.Email__c;
                existingPhone                   =   billToLocation.Phone__c;
                existingBillToVatNumber         =   billToLocation.VAT_Number__c;

                //Set the current Address
                street                          =   existingBillingStreet;
                city                            =   existingBillingCity;
                country                         =   billToLocation.Address__r.ISO_Country__r.Name;
                state                           =   (billToLocation.Address__r != null && billToLocation.Address__r.get('ISO_State__c') != null ) ? billToLocation.Address__r.ISO_State__r.Name : '';
                zipCode                         =   existingBillingZipCode;

                //set the VAT number
                vatNumberBillTo                 =   billToLocation.VAT_Number__c;

                vATNumberRequiredBillTo         =   billToLocation.Address__r.ISO_Country__r.VAT_Validation_Required__c;

                //verified if the billTo zip code is required
                billToZipCodeRequired           =   billToLocation.Address__r.IEC_Zip_Postal_Code_required__c;

                //refresh billing information
                refreshBillingInfo(billToLocation);
            }

            if(shipToLocation != null){

                //Set the selected country and State for shipping
                existingShippingCountryIsoCode  =   shipToLocation.Address__r.ISO_Country__r.ISO_Code__c;
                existingShippingStateIsoCode    =   (shipToLocation.Address__r != null && shipToLocation.Address__r.get('ISO_State__c') != null ) ? shipToLocation.Address__r.ISO_State__r.ISO_Code__c : '';

                selectedShipCountryIsoCode      =   existingShippingCountryIsoCode;
                selectedShipStateIsoCode        =   existingShippingStateIsoCode;

                existingShippingStreet          =   shipToLocation.Address__r.Street__c;
                existingShippingCity            =   shipToLocation.Address__r.City__c;
                existingShippingZipCode         =   shipToLocation.Address__r.ZipCode__c;
                existingShippingVATNumber       =   shipToLocation.VAT_Number__c;

                vatNumber                       =   shipToLocation.VAT_Number__c;
                vATNumberRequired               =   shipToLocation.Address__r.ISO_Country__r.VAT_Validation_Required__c;

                //verified if the billTo zip code is required
                shipToZipCodeRequired           =   shipToLocation.Address__r.IEC_Zip_Postal_Code_required__c;

                //refresh Shipping information
                if(vfOrder.Id != null){
                    refreshShippingInfo(shipToLocation, false);
                }
                else{
                    refreshShippingInfo(shipToLocation, true);
                }
            }

        }
        
        system.debug('vfOrder.Type ' + vfOrder.Type);
        
        return null;
    }

    public void initOrderItems()
    {
        if (vfOrder.Id == null)
            return;

        //-- Init Selectors 
        if(orderSelector == null)   orderSelector   = new Order_Sel();
        if(itemsSelector == null)   itemsSelector   = new OrderItem_Sel();
        if(chargeSelector == null)  chargeSelector  = new OrderItemCharge_Sel();
        if(productSelector == null) productSelector = new Product_Sel();

        //-- Fetch Available Products
        availableProducts = new List<SalesOrderProduct_DTO>();
        
        //Get Direct Sles Products 
        String customerType = User_Sel.getCustomerType(vfOrder.ShipToContactId);
        List<EComProduct_DTO> directSaleProducts = productSelector.getDirectSaleProducts(customerType);
        Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>();

        for(EComProduct_DTO ep : directSaleProducts)
        {
            if(ep.PriceInfo != null)
            {
                //*** empty useless fields to fix issue of "Maximum view state size"
                ep.AvailabilityDate = null;
                ep.Edition = null;
                ep.EffectiveFrom = null;
                ep.EffectiveTo = null;
                ep.ImageName = null;
                ep.InventoryStatus = null;
                ep.Keywords = null;
                ep.megaMenu = null;
                ep.Portfolio = null;
                ep.ProductCategory = null;
                ep.ProductComponent = null;
                ep.ProductDesc = null;
                ep.ProductShortDesc = null;
                ep.ShortTitle = null;
                if (!Test.isRunningTest())
                    ep.PriceInfo = null;
                
                SalesOrderProduct_DTO ap = new SalesOrderProduct_DTO();
                    ap.ecomProduct = ep; 
                    ap.selected = false; //-- De-select by default 
                    ap.quantity = 1;
                    ap.IsQuantityInteger = ep.IsQuantityInteger;
                    ap.couponCode = '';
                availableProducts.add(ap);

                mapProductNumber_Price.put(ep.ProductNumber, ep.PriceInfo);
            }
        }

        //*** get order items
        Map<Id, List<OrderItem>> itemsByOrder =  itemsSelector.getOrderItems(new Set<Id>{vfOrder.Id});
        if (itemsByOrder.containsKey(vfOrder.Id))
        {
            orderProducts = OrderItem_DTO.format2DTO(itemsByOrder.get(vfOrder.Id), mapProductNumber_Price);
            CheckOrderCompliance();
        }
        else
        {
            orderProducts = new List<OrderItem_DTO>();
        }

        //-- Remove orderProducts from available products 
        if(orderProducts.size() > 0)
        {
            Set<String> orderProductNumbers = new Set<String>(); 
            for(OrderItem_DTO oi_dto : orderProducts)
                orderProductNumbers.add(oi_dto.productCode);

            for(Integer x = 0; x < availableProducts.size(); x++)
            {
                SalesOrderProduct_DTO sop_dto = availableProducts[x];
                if(orderProductNumbers.contains(sop_dto.ecomProduct.ProductNumber)){ availableProducts.remove(x); }
            }
        }

        //-- Reset selected products 
        selectedProductsIdsStr = '';
        selectedProducts = new List<SalesOrderProduct_DTO>();
    }

    public void initOrderInvoices()
    {
        orderInvoices = new List<SAPInvoice_DTO>();
        Map<String, List<SAP_Invoice__c>> invoicesByOrder = new SAPInvoice_Sel().getOrderInvoices(new Set<String>{vfOrder.Id});

        if(invoicesByOrder.containsKey(vfOrder.Id))
        {
            for(SAP_Invoice__c inv : invoicesByOrder.get(vfOrder.Id))
            {
                orderInvoices.add(new SAPInvoice_DTO(inv));
            }
        }        
    }

    public void addProductsToOrder()
    {
        String productsNumbers = ApexPages.currentPage().getParameters().get('productsNumbers');

        if(String.isNotBlank(productsNumbers))
        {
            Set<String> setSelectedProducts = new Set<String>(productsNumbers.split('_'));

            if(selectedProducts == null){ selectedProducts = new List<SalesOrderProduct_DTO>(); }
            
            List<SalesOrderProduct_DTO> newAvailableProducts = new List<SalesOrderProduct_DTO>();

            for(SalesOrderProduct_DTO ap : availableProducts)
            {
                ap.quantity = 1;
                ap.couponCode = '';
                if(setSelectedProducts.contains(ap.ecomProduct.ProductNumber))
                    selectedProducts.add(ap);
                else
                    newAvailableProducts.add(ap);
            }

            availableProducts = newAvailableProducts;
        }
    }
    
    public void removeProductsFromOrder()
    {
        String productsNumbers = ApexPages.currentPage().getParameters().get('productsNumbers');

        if(String.isNotBlank(productsNumbers))
        {
            Set<String> setSelectedProducts = new Set<String>(productsNumbers.split('_'));

            List<SalesOrderProduct_DTO> newSelectedProducts = new List<SalesOrderProduct_DTO>();

            for(SalesOrderProduct_DTO ap : selectedProducts)
            {
                ap.quantity = 1;
                ap.couponCode = '';
                
                if(setSelectedProducts.contains(ap.ecomProduct.ProductNumber))
                    availableProducts.add(ap);
                else
                    newSelectedProducts.add(ap);
            }

            selectedProducts = newSelectedProducts;
        }
    }

    public PageReference addProducts()
    {
        initOrderItems();

        showAddProducts = true; 
        return null;
    }

    public void hideAddProductsSection()
    {
        initOrderItems();
        showAddProducts = false; 
    }

    public void showAddProductsSection()
    {
        initOrderItems();
        showAddProducts = true; 
    }

    public PageReference addSelectedProducts()
    {
        if(String.isNotBlank(selectedProductsIdsStr))
        {
            Set<String> selectedProductsIds = new Set<String>(selectedProductsIdsStr.split('_'));

            selectedProducts = new List<SalesOrderProduct_DTO>();
            for(SalesOrderProduct_DTO ap : availableProducts)
            {
                if(selectedProductsIds.contains(ap.ecomProduct.ProductId))
                {
                    selectedProducts.add(ap);
                    ap.selected = true;
                }
            }
        }

        showProductSelection = (selectedProducts.size() > 0)? true : false;

        return null; 
    }

    public PageReference selectMore()
    {
        showProductSelection = false;
        return null;
    }

    public PageReference deleteProduct()
    {
        String orderItemId = ApexPages.currentPage().getParameters().get('orderItemId');
        OrderItem_Sel.deleteOrderItem(orderItemId);
        initOrderItems();

        return null;
    }

    public void saveProduct()
    {    
        system.debug('in saveProduct');
        Boolean refreshItems = false;
        String result = null;

        //*** get price info
        if (!Test.isRunningTest()) {
            Map<String, PriceInfo_DTO> mapProductInfo = new Product_Sel().getProductPriceInfo(new Set<String>{orderItemToEdit.productCode}, User_Sel.getCustomerType(vfOrder.ShipToContactId), null, null, true);
            orderItemToEdit.PriceInfo = mapProductInfo.get(orderItemToEdit.productCode);
        }

        //*** validate quantity and coupon
        if (orderItemToEdit.quantity <= 0)
            result = String.format(labels.get('errQuantity'), new List<String>{String.valueOf(orderItemToEdit.quantity)});
        else if (orderItemToEdit.couponCode != null && orderItemToEdit.couponCode != bkCoupon)
        {
            orderItemToEdit.couponCode = orderItemToEdit.couponCode.trim();
            if (orderItemToEdit.couponCode != null && orderItemToEdit.couponCode != '' && orderItemToEdit.couponCode != bkCoupon)
                if (!Order_Svc.isCouponValid(orderItemToEdit.productId, orderItemToEdit.couponCode, orderItemToEdit.PriceInfo.couponPrice, vfOrder.ShipToContactId))
                    result = String.format(labels.get('errInvalidCoupon'), new List<String>{orderItemToEdit.couponCode});
        }
        if (result != null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result));
            orderItemToEdit.quantity = bkQuantity;
            orderItemToEdit.couponCode = bkCoupon;
            if (!Test.isRunningTest())
                orderItemToEdit.PriceInfo = null;
            return;
        }
        
        //*** save data
        result = Order_Svc.saveOrderItem(orderItemToEdit.orderItemId, orderItemToEdit.quantity, orderItemToEdit.couponCode, vfOrder.ShipToContactId , orderItemToEdit.productCode, orderItemToEdit.PriceInfo);
        if (result != null){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result)); }
        if (!Test.isRunningTest())
            orderItemToEdit.PriceInfo = null;

        //*** refresh display
        initOrderItems();
    } //*** end of "saveProduct"

    public PageReference selectOrderItemToEdit()
    {
        String orderItemId = ApexPages.currentPage().getParameters().get('orderItemId');
        for(OrderItem_DTO item : orderProducts)
        {
            if(item.orderItemId == orderItemId)
            {
                orderItemToEdit = item;
                bkQuantity = item.quantity;
                bkCoupon = item.couponCode;
            }
        }

        return null;
    }

    public PageReference saveSelectedProducts()
    {
        system.debug('selectedProducts ' + selectedProducts);
        system.debug('vfOrder ' + vfOrder);
        
        //*** get price info for selected products in order to save them to order
        if (!Test.isRunningTest()) {
            Set<String> setProductCode = new Set<String>();
            for(SalesOrderProduct_DTO p : selectedProducts)
                setProductCode.add(p.ecomProduct.ProductNumber);
            Map<String, PriceInfo_DTO> mapProductInfo = new Product_Sel().getProductPriceInfo(setProductCode, User_Sel.getCustomerType(vfOrder.ShipToContactId), null, null, true);
            for(SalesOrderProduct_DTO p : selectedProducts)
                p.ecomProduct.PriceInfo = mapProductInfo.get(p.ecomProduct.ProductNumber);
        }
        
        Order_Svc.addItemsToOrder(selectedProducts, vfOrder);
        initOrderItems();

        //*** remove price info in order to save view state
        if (!Test.isRunningTest())
            for(SalesOrderProduct_DTO p : selectedProducts)
                p.ecomProduct.PriceInfo = null;

        selectedProducts = new List<SalesOrderProduct_DTO>();
        showProductSelection = false;
        showAddProducts = false;

        return null; 
    }



//Set the default Billing values
public void setDefaultAddress(){
    street                  =   billToLocation.Street__c;
    city                    =   billToLocation.City__c;
    country                 =   billToLocation.Address__r.ISO_Country__r.Name;
    state                   =   billToLocation.Address__r.ISO_State__r.Name;
    selectedCountryIsoCode  =   billToLocation.ISO_Country_Code__c;
    selectedStateIsoCode    =   billToLocation.ISO_State_Code__c;
    zipCode                 =   billToLocation.ZipCode__c;
}

//Get the BillTo Default location value and Set the order Account
public void getContactLocations(){

    if(vfOrder.BillToContactId == null){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact cannot be null')); return; }

    //Create a new BillTo and ShipTo Location if the Contact don't have one
    Contact billToContact = new Contact_Sel().getContactById(vfOrder.BillToContactId);
    if(billToContact.BillTo_Location__c == null || billToContact.ShipTo_Location__c == null){
        Boolean initializeLocations = Location_Svc.InitializeContactLocations(vfOrder.BillToContactId);
        if(!initializeLocations){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Address_creation_error)); return;
        }
    }

    map<Id,Location__c> locationMap = new Location_Sel().getContactsBillToLocations(new set<Id>{vfOrder.BillToContactId});
    //Map Sold to section
    if(locationMap != null && locationMap.size() > 0){
        vfOrder.AccountId               =   locationMap.values()[0].Account__c; 
        vfOrder.SoldToAccount_Name__c   =   locationMap.values()[0].Account_Name__c;
        
        //Get the SoldTo VAT number
        Id billToAccountId              =   vfOrder.AccountId;
        map<Id,Location__c> soldLocationMap = new Location_Sel().getSoldToAccountLocation(new set<Id>{billToAccountId});
        
        billToLocation                  =   locationMap.values()[0];
        selectedBillToLocation          =   billToLocation.Id;
        
    }else{ billToLocation = new Location__c(); }
    
    //set the default billTo
    List<SelectOption> billToLocationSel = getBillToLocations();
    if(billToLocationSel != null && billToLocationSel.size() > 0)
    {
        //Set the default selected billTo value
        if(billToContact.BillTo_Location__c != null){
            selectedBillToLocation  =   billToContact.BillTo_Location__c;
            billToLocation          =   getLocationById(selectedBillToLocation);
        }
    }

    setDefaultAddress();

    existingBillToLocationId        =  vfOrder.BillTo_Location__c;
    existingBillingCountryIsoCode   =   billToLocation.ISO_Country_Code__c;
    existingBillingIsoCode          =   billToLocation.ISO_State_Code__c;
    existingEmail                   =   billToLocation.Email__c;
    existingPhone                   =   billToLocation.Phone__c;
    existingBillToVatNumber         =   billToLocation.VAT_Number__c;
    
    vATNumberRequiredBillTo  =  billToLocation.Address__r.ISO_Country__r.VAT_Validation_Required__c;

    vfOrder.BillTo_Location__c      =   billToLocation.Id;
    vfOrder.BillToContact_VAT_Number__c = existingBillToVatNumber;
    vatNumberBillTo = existingBillToVatNumber;

    User user = [select id, contactId from User where contactId=:vfOrder.BillToContactId];
    if(vfOrder.BillToContactId != null && user != null)
        vfOrder.OwnerId = user.Id;

}

//Set the ShipTo location default value
public void getContactShipToLocations(){
    //Set the default selected billTo value
    Contact shipToContact = new Contact_Sel().getContactById(vfOrder.ShipToContactId);
    if(shipToContact != null && shipToContact.ShipTo_Location__c != null){
        selectedShipToLocation = shipToContact.ShipTo_Location__c;
        shipToLocation = getLocationById(selectedShipToLocation);

        //set the existing values
        existingShippingCountryIsoCode  =   shipToLocation.Address__r.ISO_Country__r.ISO_Code__c;
        existingShippingStateIsoCode    =   shipToLocation.Address__r.ISO_State__r.ISO_Code__c;

        existingShippingStreet          =   shipToLocation.Address__r.Street__c;
        existingShippingCity            =   shipToLocation.Address__r.City__c;
        existingShippingZipCode         =   shipToLocation.Address__r.ZipCode__c;
        existingShippingEmail           =   shipToLocation.Email__c;
        existingShippingPhone           =   shipToLocation.Phone__c;
        
        vfOrder.ShipToAccount_Name__c   =   shipToLocation.Account_Name__c;
        vfOrder.ShipToContact_Name__c   =   shipToLocation.Contact_First_Name__c + ' ' + shipToLocation.Contact_Last_Name__c;
        vfOrder.ShipToContact_Phone__c  =   shipToLocation.Phone__c;
        vfOrder.ShipToContact_Email__c  =   shipToLocation.Email__c;

        vatNumber                       =   shipToLocation.VAT_Number__c;
        vATNumberRequired               =   shipToLocation.Address__r.ISO_Country__r.VAT_Validation_Required__c;

        //verified if the billTo zip code is required
        shipToZipCodeRequired           =   shipToLocation.Address__r.IEC_Zip_Postal_Code_required__c;

    }
}

//Get Location by Id
public static Location__c getLocationById(String locationId){
    Location__c location = new Location__c();
    List<Location__c> locations = new Location_Sel().getLocations(new set<Id>{locationId});
    if(locations != null && locations.size() > 0){
        location = locations[0];
    }
    return location;
}


//Get the billTo location addresses
public List<SelectOption> getBillToLocations(){
    List<SelectOption> locations = new List<SelectOption>();
    if(vfOrder!= null && vfOrder.BillToContactId != null)
        locations = getLocationItems(vfOrder.BillToContactId,IECConstants.BILLTO);

    if(locations.isEmpty()){ billToLocation = new Location__c(); }
    return locations;
}

//Get the shipTo location addresses
public List<SelectOption> getShipToLocations(){
    List<SelectOption> locations = new List<SelectOption>();
    if(vfOrder!= null && vfOrder.ShipToContactId != null)
        locations = getLocationItems(vfOrder.ShipToContactId, IECConstants.SHIPTO);

    if(locations.isEmpty()){ shipToLocation = new Location__c(); }
    return locations;
}

//Get the locations base on the contactId and Type
public List<SelectOption> getLocationItems(String contactId,String type){
    List<SelectOption> options = new List<SelectOption>();
    //get locations form values for billToContact
    map<Id,Location__c> locationMap = new Location_Sel().getContactsLocations(new set<Id>{contactId});
    if(locationMap != null && locationMap.size() > 0){
        options.add(new SelectOption('',''));
        for(Location__c location : locationMap.values()){
            if(location.Type__c == type && location.Active__c){
                String selectValue = location.Street__c + ' ' + location.City__c;
                selectValue += (location.ZipCode__c != null) ? + ' ' + location.ZipCode__c : '';
                options.add(new SelectOption(location.Id, selectValue ));
            }
        }
    }

    return options;
}

//Map Shipping address details
public void shipToContactDetails(){
    if(String.isNotEmpty(selectedShipToLocation)){
        shipToLocation      =   getLocationById(selectedShipToLocation);
        
        if(shipToLocation != null){
            selectedShipCountryIsoCode  =   shipToLocation.ISO_Country_Code__c;
            selectedShipStateIsoCode    =   shipToLocation.ISO_State_Code__c;
            vatNumber                   =   shipToLocation.VAT_Number__c;
            vATNumberRequired           =   shipToLocation.Address__r.ISO_Country__r.VAT_Validation_Required__c;
            //refresh Shipping information
            refreshShippingInfo(shipToLocation, true);
        }
        
    }else{
        shipToLocation = new Location__c();
    }

}

//AutoComplete query
@remoteAction
global static list<String> getAddresses(string str){
    return IECAddress_Sel.getAutocompleteAddresses(str);
}


//Autocomplete the BillTo address
public void autoCompleteBillToAddresses(){
    //
    List<IECAddress__c> addresses =  new IECAddress_Sel().getFullAddress(fullAddress);
    if(addresses != null && addresses.size() > 0){
        street                  =   addresses[0].Street__c;
        city                    =   addresses[0].City__c;
        selectedCountryIsoCode  =   addresses[0].ISO_Country_Code__c;
        selectedStateIsoCode    =   addresses[0].ISO_State_Code__c;
        zipCode                 =   addresses[0].ZipCode__c;

        buildCountryStatePicklistFromIECAddress();
    }

}

//Autocomplete the ShipTo address
public void autoCompleteShipToAddresses(){
    List<IECAddress__c> addresses =  new IECAddress_Sel().getFullAddress(fullAddress);
    if(addresses != null && addresses.size() > 0){
        shipStreet                  =   addresses[0].Street__c;
        shipCity                    =   addresses[0].City__c;
        selectedShipCountryIsoCode  =   addresses[0].ISO_Country_Code__c;
        selectedShipStateIsoCode    =   addresses[0].ISO_State_Code__c;
        shipZipCode                 =   addresses[0].ZipCode__c;

        buildCountryStatePicklistFromIECAddress();
    }
}


//Edit Address on order readonly page
public void editAddressOrderReadOnly(){

    editMod = true;
    buildCountryStatePicklistFromIECAddress();
    vatNumberBillTo                 =   billToLocation.VAT_Number__c;

    vATNumberRequiredBillTo         =   billToLocation.Address__r.ISO_Country__r.VAT_Validation_Required__c; 

    //verified if the zipCode is required
    billToZipCodeRequired           =   billToLocation.Address__r.IEC_Zip_Postal_Code_required__c;

    changeBillToCountry();
}

public void editShipToAddressOrderReadOnly(){
    shipToEditMod = true;
    buildCountryStatePicklistFromIECAddress();
}

//Cancel
public void CancelAddressOrderReadOnly(){
    setDefaultAddress();
    editMod = false;

    if(billToLocation != null){
        vatNumberBillTo                 =   billToLocation.VAT_Number__c;
        vATNumberRequiredBillTo         =   billToLocation.Address__r.ISO_Country__r.VAT_Validation_Required__c;
    }

}

//Verified if a VAT number is valid
public String verifiedVATNumer(String currentVatNumber, String selectedCountryIsoCode){

    String returnVal = 'true';

    //Check if the VAT number is valid
    IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();

    try {
        //IECVATUtil.VATResponse res = ws.ValidateVAT(selectedCountryIsoCode, currentVatNumber);
        IECVATUtil.VATResponse res = ws.ValidateVAT(selectedCountryIsoCode, ((currentVatNumber.startsWithIgnoreCase(selectedCountryIsoCode)) ? currentVatNumber.substring(selectedCountryIsoCode.length()) : currentVatNumber));
        if (!res.valid){ returnVal = 'Invalid VAT number'; }
    }
    catch (System.CalloutException ex) { returnVal = Label.IEC_Error_VATWSBusy; }

    return returnVal;
}

//Save Billing Address
public void saveAddressOrderReadOnly(){

    //Verified if here is a VAT number 
    String currentVatNumber = ApexPages.currentPage().getParameters().get('vatNumberBillTo');
    
    vatNumberBillTo     =   currentVatNumber;

    if(currentVatNumber != null && currentVatNumber != '' && selectedCountryIsoCode != null){
        String resp = verifiedVATNumer(currentVatNumber, selectedCountryIsoCode);
        if(resp != 'true'){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, resp)); return; }
    }

    Boolean error= false;
    if(selectedCountryIsoCode == null || selectedCountryIsoCode == ''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Country_cannot_be_empty)); error = true; }

    //Validate State
    if(listBillingState != null && listBillingState.size() > 0 && selectedStateIsoCode == null){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.State_cannot_be_empty)); error = true; }

    if(street == null || street == ''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.Street_cannot_be_empty)); error = true; }
    
    if(city == null || city == ''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.City_cannot_be_empty)); error = true; }

    if(billToZipCodeRequired && (zipCode == null || zipCode == '')){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Zip_code_cannot_be_empty)); error = true; }

    if(billToLocation.Email__c == null || billToLocation.Email__c == ''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Email_cannot_be_empty)); error = true; }
    

    if(error){ editMod = true; return; }

    editMod = false;

    street = ApexPages.currentPage().getParameters().get('billToautocomplete');

    Boolean addresschanged = false;

    //Verified if the country changed
    if(selectedCountryIsoCode != existingBillingCountryIsoCode){ addresschanged = true; }
    if(selectedStateIsoCode != existingBillingIsoCode){ addresschanged = true; }
    if(street != existingBillingStreet){ addresschanged = true; }
    if(city != existingBillingCity){ addresschanged = true; }
    if(zipCode != existingBillingZipCode){ addresschanged = true; }
    if(billToLocation.Email__c != existingEmail){ addresschanged = true; }
    if(billToLocation.Phone__c != existingPhone){ addresschanged = true; }
    if(vatNumberBillTo != existingBillToVatNumber){ addresschanged = true; }

    if(!addresschanged) return;

    //Get the Country
    IATA_ISO_Country__c selectedCountry; 
    List<IATA_ISO_Country__c> isoCountries = ISO_Country_State_Helper.getIsoCountryByIsoCode(selectedCountryIsoCode); 
    if(isoCountries != null && isoCountries.size() > 0){
        selectedCountry = isoCountries[0];
        country = isoCountries[0].Name;
    }

    String stateCode = selectedStateIsoCode;

    //get State
    IATA_ISO_State__c selectedState;
    List<IATA_ISO_State__c> isoStates = ISO_Country_State_Helper.getIsoStateByIsoCode(selectedCountryIsoCode, stateCode);  
    if(isoStates != null && isoStates.size() > 0){
        selectedState = isoStates[0];
        state = isoStates[0].Name;
    }

    List<IECAddress__c> existingAddresses = new IECAddress_Sel().getAddress(street,city,selectedCountryIsoCode, stateCode, zipCode);
    
    Id newAddressId;

    if(existingAddresses == null || existingAddresses.isEmpty()){

        //Create a new IECAddress
        IECAddress__c iecAddress = new IECAddress__c();
        iecAddress.Street__c = street;
        iecAddress.City__c = city;
        if(selectedCountry != null) iecAddress.ISO_Country__c = selectedCountry.Id;
        if(selectedState != null) iecAddress.ISO_State__c = selectedState.Id;
        iecAddress.ZipCode__c = zipCode;

        try{
            insert iecAddress;
            vfOrder.BillTo_Address__c = iecAddress.Id;
            newAddressId = iecAddress.Id;
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Address_creation_error)); return;
        }

    }else{
        //change the VfOrder location reference
        vfOrder.BillTo_Address__c = newAddressId = existingAddresses[0].Id;
        //newAddressId = existingAddresses[0].Id;
    }

    List<Location__c> locations = new Location_Sel().getLocations(new set<Id>{vfOrder.BillTo_Location__c});
    
    if(locations != null && locations.size() > 0){

        Location__c location = locations[0];
        Boolean createNewBillToLocation = false;
        
        if(selectedCountryIsoCode != existingBillingCountryIsoCode || selectedStateIsoCode != existingBillingIsoCode){
            //Update the location before create a new location to avoid the Validation of having just one active billing location
            location.Active__c = false;
            createNewBillToLocation = true;
        }else{
            //Update the existing location
            location.Address__c = newAddressId;
            location.VAT_Number__c = currentVatNumber;
        }
        update location;
        System.debug('location::'+location);
        System.debug('vfOrder.BillTo_Location__c::'+vfOrder.BillTo_Location__c);

        //If the Customer modified his country and state, Create a new Location and disable the old one
        if(createNewBillToLocation){

            Location__c newlocation = Location_Svc.createLocation(newAddressId,location.Contact__c,billToLocation.Email__c,billToLocation.Phone__c,currentVatNumber, IECConstants.BILLTO /*location.Type__c*/);
            //Update the Contact default billTo
            Contact billToContact = new Contact_Sel().getContactById(location.Contact__c);
            System.debug('vfOrder::'+vfOrder);
            System.debug('billToContact::'+billToContact);
            System.debug('newlocation::'+newlocation);
            billToContact.BillTo_Location__c    =   vfOrder.BillTo_Location__c = newlocation.Id;
            //vfOrder.BillTo_Location__c          =   newlocation.Id;
            update billToContact;
        }

    }
    
    vfOrder.BillToContact_VAT_Number__c = currentVatNumber;
    //Update the current Order
    if(vfOrder.Id != null){
        vfOrder.BillTo_Address__c = newAddressId;
        update vfOrder;
        vfOrder = Order_Sel.getOrderForVF(vfOrder.Id);
    }
    vatNumberBillTo     =   currentVatNumber;

}

//Add a new ShipTo address
public void addShpAddressOrder(){
    //Set the Shipping details to null
    selectedShipToLocation      =   '';
    //Clear the address
    shipStreet                  =   '';
    shipCity                    =   '';
    shipCountry                 =   '';
    shipState                   =   '';
    selectedShipCountryIsoCode  =   '';
    selectedShipStateIsoCode    =   '';
    shipZipCode                 =   '';
    vatNumber                   =   '';

    countryAndStateEditable     =   true;
    vATNumberRequired           =   false;
    editModShp                  =   true;

    buildCountryStatePicklistFromIECAddress();
}

//Edit a new ShipTo address
public void editShpAddressOrder(){

    editModShp                      =   true;
    countryAndStateEditable         =   false;
    
    //Set the Shipping address
    shipStreet                      =   shipToLocation.Street__c;
    shipCity                        =   shipToLocation.City__c;
    shipCountry                     =   shipToLocation.Address__r.ISO_Country__r.Name;
    shipState                       =   shipToLocation.Address__r.ISO_State__r.Name;
    selectedShipCountryIsoCode      =   shipToLocation.ISO_Country_Code__c;
    selectedShipStateIsoCode        =   shipToLocation.ISO_State_Code__c;
    shipZipCode                     =   shipToLocation.ZipCode__c;
    vatNumber                       =   shipToLocation.VAT_Number__c;
    vATNumberRequired               =   shipToLocation.Address__r.ISO_Country__r.VAT_Validation_Required__c;

    //Set the existing address
    existingShippingCountryIsoCode  =   shipToLocation.Address__r.ISO_Country__r.ISO_Code__c;
    existingShippingStateIsoCode    =   shipToLocation.Address__r.ISO_State__r.ISO_Code__c;
    existingShippingStreet          =   shipToLocation.Address__r.Street__c;
    existingShippingCity            =   shipToLocation.Address__r.City__c;
    existingShippingZipCode         =   shipToLocation.Address__r.ZipCode__c;
    existingShippingVATNumber       =   shipToLocation.VAT_Number__c;

    //verified if the billTo zip code is required
    shipToZipCodeRequired       =   shipToLocation.Address__r.IEC_Zip_Postal_Code_required__c;

    buildCountryStatePicklistFromIECAddress();

}

//Cancel ShipTo address
public void CancelAddressOrder(){
    editModShp = false;
    //reset the default selectedShipToLocation
    getContactShipToLocations();
    if(shipToLocation != null){
        vatNumber           =   shipToLocation.VAT_Number__c;
        vATNumberRequired   =   shipToLocation.Address__r.ISO_Country__r.VAT_Validation_Required__c;
    }
    
}

//Create a new IECAddress
public static IECAddress__c newIecAddress(String street, String city, String zipCode,Id isoCountryId,Id isoStateId){
    
    IECAddress__c iecAddress    =   new IECAddress__c();
    iecAddress.Street__c        =   street;
    iecAddress.City__c          =   city;
    iecAddress.ISO_Country__c   =   isoCountryId;
    iecAddress.ISO_State__c     =   isoStateId;
    iecAddress.ZipCode__c       =   zipCode;

    try{
        insert iecAddress;
    }catch(Exception ex){
        IECErrorLogger.logApexException('Order_Ext/newIecAddress', JSON.serialize(iecAddress), ex.getMessage(), ex.getStackTraceString()); return null;
    }

    return iecAddress;
}


//Save ShipTo address
public void saveAddressOrder(){

    Boolean errors = false;

    //verified if the new Address exist in IECAddress
    if(shipStreet == '' || shipStreet == null)
        shipStreet = ApexPages.currentPage().getParameters().get('autoCompShipToLoading');

    String hiddenShipToautocomplete = ApexPages.currentPage().getParameters().get('hiddenShipToautocomplete');
    if(hiddenShipToautocomplete != null && hiddenShipToautocomplete != ''){ shipStreet = hiddenShipToautocomplete; }

    //Verified if here is a VAT number 
    String currentVatNumber = ApexPages.currentPage().getParameters().get('vatNumber');
    vatNumber = currentVatNumber;

    if(currentVatNumber != null && currentVatNumber != '' && selectedShipCountryIsoCode != null){
        
        String resp = verifiedVATNumer(currentVatNumber, selectedShipCountryIsoCode);
        if(resp != 'true'){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, resp)); errors = true; }
    }

    if(selectedShipCountryIsoCode == null || selectedShipCountryIsoCode == ''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Country_cannot_be_empty)); errors = true; }
    
    if(shipStreet == null || shipStreet == ''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.Street_cannot_be_empty)); errors = true; }
    
    if(shipCity == null || shipCity == ''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.City_cannot_be_empty)); errors = true; }

    if(shipToZipCodeRequired && (shipZipCode == null || shipZipCode == '')){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Zip_code_cannot_be_empty)); errors = true; }
    
    if(vfOrder.ShipToContact_Email__c == null || vfOrder.ShipToContact_Email__c == ''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Email_cannot_be_empty)); errors = true; }

    if(vfOrder.ShipToAccount_Name__c == null || vfOrder.ShipToAccount_Name__c == ''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company name cannot be empty')); errors = true; }
    
    if(vfOrder.ShipToContact_Name__c == null || vfOrder.ShipToContact_Name__c == ''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Attention field cannot be empty')); errors = true; }

    if(errors){ return; }

    //Get the Country
    IATA_ISO_Country__c selectedCountry; 
    List<IATA_ISO_Country__c> isoCountries = ISO_Country_State_Helper.getIsoCountryByIsoCode(selectedShipCountryIsoCode);
    if(isoCountries != null && isoCountries.size() > 0){
        selectedCountry = isoCountries[0];
        country = isoCountries[0].Name;
    }

    String stateCode = selectedShipStateIsoCode;

    //get State
    Id stateId;
    IATA_ISO_State__c selectedState;
    List<IATA_ISO_State__c> isoStates = ISO_Country_State_Helper.getIsoStateByIsoCode(selectedShipCountryIsoCode,stateCode);  

    if(isoStates != null && isoStates.size() > 0){
        selectedState = isoStates[0];
        state = isoStates[0].Name; stateId = isoStates[0].Id;
    }

    //get the existing IECAddress
    List<IECAddress__c> existingAddresses = new IECAddress_Sel().getAddress(shipStreet,shipCity,selectedShipCountryIsoCode, stateCode, shipZipCode);
    
    //Add a new Address
    if(selectedShipToLocation == null || selectedShipToLocation == ''){
        
        //Create a new IECAddress and Location
        IECAddress__c iecAddress = new IECAddress__c();
        //Create a new IECAddress
        if(existingAddresses != null && existingAddresses.size() > 0){
            iecAddress = existingAddresses[0];
        }else{
            Id selectedCountryId = (selectedCountry != null) ? selectedCountry.Id : null;
            iecAddress = newIecAddress(shipStreet,shipCity,shipZipCode,selectedCountryId,stateId);
        }
        
        //Create shipTo Location
        Location__c newLocation = Location_Svc.createLocation(iecAddress.Id,vfOrder.ShipToContactId,vfOrder.ShipToContact_Email__c, vfOrder.ShipToContact_Phone__c, currentVatNumber,IECConstants.SHIPTO);
        
        //If the location is null show a message to the CSR
        if(newLocation == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.Address_edition_error)); return;
        } 

        //ShipToLocations
        vfOrder.ShipTo_Location__c = newLocation.Id;
        getShipToLocations();
        selectedShipToLocation = vfOrder.ShipTo_Location__c;
        shipToLocation = getLocationById(newLocation.Id);

    }else{

        //Create new IECAddress or User and existing one
        Boolean shippingAddressChanged = false;
        if(existingShippingCountryIsoCode != selectedShipCountryIsoCode){ shippingAddressChanged = true; }
        //if(existingShippingStateIsoCode != selectedShipStateIsoCode)
        if(selectedShipStateIsoCode != null && existingShippingStateIsoCode!= null && !existingShippingStateIsoCode.endsWithIgnoreCase('-' + selectedShipStateIsoCode)){ shippingAddressChanged = true; }
        
        if(existingShippingStreet != shipStreet){ shippingAddressChanged = true; }

        if(existingShippingCity != shipCity){ shippingAddressChanged = true; }

        if(existingShippingZipCode != shipZipCode){ shippingAddressChanged = true; }

        if(existingShippingVATNumber != currentVatNumber){ shippingAddressChanged = true; }

        //if nothing changed return && !nameEmailAndPhoneChanged && vfOrder.Id != null
        if(!shippingAddressChanged){ editModShp = false; return; }

        Id newAddressId;
        
        if(existingAddresses == null || existingAddresses.isEmpty()){
            //Create a new IECAddress
            Id selectedCountryId = (selectedCountry != null) ? selectedCountry.Id : null;
            IECAddress__c iecAddress = newIecAddress(shipStreet,shipCity,shipZipCode,selectedCountryId,stateId);
            if(iecAddress != null){
                vfOrder.ShipTo_Address__c = newAddressId = iecAddress.Id;
                //newAddressId = iecAddress.Id;
            }
        }else{
            //change the VfOrder location reference
            vfOrder.ShipTo_Address__c = newAddressId = existingAddresses[0].Id;
            //newAddressId = existingAddresses[0].Id;
        }

        List<Location__c> locations = new Location_Sel().getLocations(new set<Id>{selectedShipToLocation});
        
        //update the Location 92384753760
        if(locations != null && locations.size() > 0){
            Location__c location = locations[0];
            location.Address__c = newAddressId;
            location.VAT_Number__c = currentVatNumber;

            try{
                update location;  
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())); return;
            }
            
            shipToLocation = getLocationById(location.Id);
        }

        //Update the Order
        if(vfOrder.Id != null){
            vfOrder.ShipTo_Address__c = newAddressId;
            update vfOrder;
            vfOrder = Order_Sel.getOrderForVF(vfOrder.Id);
        }

    }

    editModShp = false;

}


void buildCountryStatePicklistFromIECAddress() {
    Integer ixCountry, ixState;
    
    //*** reset countries and states picklists
    listCountry = new List<SelectOption>();
    listBillingState = new List<SelectOption>();
    listShippingState = new List<SelectOption>();
    
    //*** get list of ISO countries/states
    listCountryState = ISO_Country_State_Helper.getCountry_State();
    
    //*** action depending of having ISO countries/states
    if (listCountryState.size() >  0) {
        //*** build countries picklist
        listCountry.add(new SelectOption('', ''));
        for (ixCountry = 0; ixCountry < listCountryState.size(); ixCountry++)
            listCountry.add(new SelectOption(listCountryState[ixCountry].CountryCode, listCountryState[ixCountry].CountryName));
        
        String countryCode = (selectedShipCountryIsoCode != null && selectedShipCountryIsoCode != '') ? selectedShipCountryIsoCode : selectedCountryIsoCode;

        ixCountry = Utility.findItemInSelectList(listCountry, countryCode , null);//selectedCountryIsoCode

        if (ixCountry >= 0) {
            
            
            //*** action depending of having ISO states
            ixCountry -= 1;   // because of the empty value in the picklist
            if (listBillingState.size() == 0 && listCountryState[ixCountry].StateCode.size() > 0) {
                //*** build states picklist
                buildStatePicklist(ixCountry, listBillingState);
                
                //*** action depending on finding billing state from picklist
                if (isEdit) {
                    ixState = Utility.findItemInSelectList(listBillingState, vfOrder.BillTo_Address__r.ISO_State__r.ISO_Code__c, vfOrder.BillTo_Address__r.ISO_State__r.Name);
                    
                }
            }
        } else if (isEdit) {
            //*** not found -> empty all codes
            vfOrder.BillingCountryCode__c = null;
            vfOrder.BillingStateCode__c = null;
        }
        
        ixCountry = Utility.findItemInSelectList(listCountry, selectedShipCountryIsoCode, null);
        
        if (ixCountry >= 0) {
            //*** found -> set country information
            if (isEdit) {
                vfOrder.ShippingCountry = listCountry[ixCountry].getLabel();
                vfOrder.ShippingCountryCode__c = listCountry[ixCountry].getValue();
            }
            
            //*** action depending of having ISO states
            ixCountry -= 1;   // because of the empty value in the picklist
            if (listShippingState.size() == 0 && listCountryState[ixCountry].StateCode.size() > 0) {
                //*** build states picklist
                buildStatePicklist(ixCountry, listShippingState);
                
                //*** action depending on finding shipping state from picklist
                if (isEdit) {
                    ixState = Utility.findItemInSelectList(listShippingState, vfOrder.ShipTo_Address__r.ISO_State__r.ISO_Code__c, vfOrder.ShipTo_Address__r.ISO_State__r.Name);
                    if (ixState >= 0) {
                        vfOrder.ShippingState = listShippingState[ixState].getLabel();
                        vfOrder.ShippingStateCode__c = listShippingState[ixState].getValue();
                    } else
                        vfOrder.ShippingStateCode__c = null;
                }
            }
        } else if (isEdit) {
            //*** not found -> empty all codes
            vfOrder.ShippingCountryCode__c = null;
            vfOrder.ShippingStateCode__c = null;
        }
    } else if (isEdit) {
        //*** no ISO countries/states -> empty all codes
        vfOrder.BillingCountryCode__c = vfOrder.BillingStateCode__c = vfOrder.ShippingCountryCode__c = vfOrder.ShippingStateCode__c = null;
        //vfOrder.BillingStateCode__c = null;
        //vfOrder.ShippingCountryCode__c = null;
        //vfOrder.ShippingStateCode__c = null;
    }
} //*** end of "buildCountryStatePicklist"

/****************************************************************************************************
    Created by CGI, Thai 2015-10-20
        Add options to states picklist
****************************************************************************************************/
void buildStatePicklist(Integer ixCountry, List<SelectOption> picklist) {
    picklist.clear();
    if (listCountryState[ixCountry].StateCode.size() > 0) {
        picklist.add(new SelectOption('', ''));
        for (Integer ixState = 0; ixState < listCountryState[ixCountry].StateCode.size(); ixState++)
            picklist.add(new SelectOption(listCountryState[ixCountry].StateCode[ixState], listCountryState[ixCountry].StateName[ixState]));
    }
} //*** end of "buildStatePicklist"


/****************************************************************************************************
    Created by CGI, Thai 2015-10-20
        Set country name and refresh state picklist when billing country picklist is changed
****************************************************************************************************/
public void changeBillToCountry() { changeBillToCountry(false); }
public void changeBillToCountry(Boolean checkWithCountryName) {
    Integer ixCountry, ixState;
    
    listBillingState.clear();
    
    //*** find country from picklist
    ixCountry = Utility.findItemInSelectList(listCountry, vfOrder.BillingCountryCode__c, (checkWithCountryName ? vfOrder.BillingCountry : null));
    
    //*** reset country data depending on matched status
    if (ixCountry >= 0) {
        //*** matched
        vfOrder.BillingCountry = listCountry[ixCountry].getLabel();
        vfOrder.BillingCountryCode__c = listCountry[ixCountry].getValue();
        
        //*** refresh state picklist
        buildStatePicklist(ixCountry - 1, listBillingState);
    } else {
        vfOrder.BillingCountry = null;
        vfOrder.BillingCountryCode__c = null;
    }
    
    //*** reset state information
    if (!checkWithCountryName) {
        vfOrder.BillingState = null;
        vfOrder.BillingStateCode__c = null;
    } else if (listBillingState.size() > 0) {
        ixState = Utility.findItemInSelectList(listBillingState, vfOrder.BillingStateCode__c, vfOrder.BillingState);
        if (ixState >= 0) {
            vfOrder.BillingState = listBillingState[ixState].getLabel();
            vfOrder.BillingStateCode__c = listBillingState[ixState].getValue();
        }
    } else
        vfOrder.BillingStateCode__c = null;
} //*** end of "changeBillToCountry"

public void changeBillToCountryUsingLocation() { changeBillToCountryUsingLocation(false); }
public void changeBillToCountryUsingLocation(Boolean checkWithCountryName) {
    Integer ixCountry, ixState;
    
    listBillingState.clear();
    
    //*** find country from picklist
    ixCountry = Utility.findItemInSelectList(listCountry, selectedCountryIsoCode, null);
    
    //*** reset country data depending on matched status
    if (ixCountry >= 0) {
        //*** matched
        vfOrder.BillingCountry = listCountry[ixCountry].getLabel();
        vfOrder.BillingCountryCode__c = listCountry[ixCountry].getValue();
        
        //*** refresh state picklist
        buildStatePicklist(ixCountry - 1, listBillingState);
    } else {
        vfOrder.BillingCountry = null;
        vfOrder.BillingCountryCode__c = null;
    }
    
    //*** reset state information
    if (!checkWithCountryName) {
        vfOrder.BillingState = null;
        vfOrder.BillingStateCode__c = null;
    } else if (listBillingState.size() > 0) {
        ixState = Utility.findItemInSelectList(listBillingState, selectedStateIsoCode, null);
    } else
        vfOrder.BillingStateCode__c = null;

    //verified if the VAT Number is required for this Country
    List<IATA_ISO_Country__c> isoCountry = ISO_Country_State_Helper.getIsoCountryByIsoCode(selectedCountryIsoCode);
    if(isoCountry != null && isoCountry.size() > 0){
        IECVATUtil.VATConfiguration vatConfig = IECVATUtil.GetVATConfiguration(isoCountry[0].Name);
        vATNumberRequiredBillTo = (vatConfig != null) ? vatConfig.VATValidationRequired : false;
    }

    //Verified if the ZipCode is required
    List<IATA_ISO_Country__c> lstISOCountries = ISO_Country_State_Helper.getIsoCountryByIsoCode(selectedCountryIsoCode);
    if(lstISOCountries != null && lstISOCountries.size() > 0){
        billToZipCodeRequired = lstISOCountries[0].IEC_Zip_Postal_Code_required__c;
    }
    
    selectedStateIsoCode = '';
    state = '';

} //*** end of "chan

public void changeShipToCountryUsingLocation() { changeShipToCountryUsingLocation(false); }
public void changeShipToCountryUsingLocation(Boolean checkWithCountryName) {
    
    Integer ixCountry, ixState;
    
    listShippingState.clear();
    
    //*** find country from picklist
    ixCountry = Utility.findItemInSelectList(listCountry, selectedShipCountryIsoCode, null);
    
    //*** reset country data depending on matched status
    if (ixCountry >= 0) {
        //*** matched
        vfOrder.ShippingCountry = listCountry[ixCountry].getLabel();
        vfOrder.ShippingCountryCode__c = listCountry[ixCountry].getValue();
        
        //*** refresh state picklist
        buildStatePicklist(ixCountry - 1, listShippingState);
    } else {
        vfOrder.ShippingCountry = null;
        vfOrder.ShippingCountryCode__c = null;
    }
    
    //*** reset state information
    if (!checkWithCountryName) {
        vfOrder.ShippingState = null;
        vfOrder.ShippingStateCode__c = null;
    } else if (listShippingState.size() > 0) {
        ixState = Utility.findItemInSelectList(listShippingState, vfOrder.ShippingStateCode__c, vfOrder.ShippingState);
        if (ixState >= 0) {
            vfOrder.ShippingState = listShippingState[ixState].getLabel();
            vfOrder.ShippingStateCode__c = listShippingState[ixState].getValue();
        }
    } else
        vfOrder.ShippingStateCode__c = null;

    //verified if the VAT Number is required for this Country 
    vATNumberRequired = ISO_Country_State_Helper.requiredVATNumber(selectedShipCountryIsoCode);
    List<IATA_ISO_Country__c> isoCountry = ISO_Country_State_Helper.getIsoCountryByIsoCode(selectedShipCountryIsoCode);
    if(isoCountry != null && isoCountry.size() > 0){
        IECVATUtil.VATConfiguration vatConfig = IECVATUtil.GetVATConfiguration(isoCountry[0].Name);
        vATNumberRequired = (vatConfig != null) ? vatConfig.VATValidationRequired : false;
    }

    //Check if the Zip code is required
    List<IATA_ISO_Country__c> lstISOCountries = ISO_Country_State_Helper.getIsoCountryByIsoCode(selectedShipCountryIsoCode);
    if(lstISOCountries != null && lstISOCountries.size() > 0){
        shipToZipCodeRequired = lstISOCountries[0].IEC_Zip_Postal_Code_required__c;
    }

    selectedShipStateIsoCode = '';

}


/****************************************************************************************************
    Created by CGI, Thai 2015-10-20
        Set state name when billing state picklist is changed
****************************************************************************************************/
public void changeBillToState() {
    try {
        Integer ixState = Utility.findItemInSelectList(listBillingState, vfOrder.BillingStateCode__c, null);
        vfOrder.BillingState = listBillingState[ixState].getLabel();
    } catch (Exception e) {
        vfOrder.BillingState = null;
    }
} //*** end of "changeBillToState"


/****************************************************************************************************
    Created by CGI, Thai 2015-11-06
        Check if allow payment and prepare for payment
****************************************************************************************************/
public void payOrder_Prepare() {
    
    //Validate BillToLocation & ShipToLocation are valid in SAP 
    List<Location__c> locations = new Location_Sel().getLocations(new Set<Id>{
        vfOrder.BillTo_Location__c,
        vfOrder.ShipTo_Location__c  
    });
    
    if (orderProducts == null || orderProducts.size() == 0)
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, labels.get('errNoProduct')));
    else if (Order_Svc.needToGetSAP_Freight_Tax(vfOrder.Id))
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, labels.get('errMissShipTax')));
    else if(locations == null || locations.size() != 2)
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your Billing or Shipping are not properly set. Please update your customer informations'));
    else if(locations != null && locations.size() > 0)
        for(Location__c loc : locations)
            if(String.isBlank(loc.SAP_Id__c))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occur when trying to process your payment. Please call the customer service'));
    
    else {
        isPaying = true;
        isInlineEditing = true;
        buildPaymentTypePicklist();
    }
} //*** end of "payOrder_Prepare"


/****************************************************************************************************
    Created by CGI, Thai 2015-11-09
        Pay order
****************************************************************************************************/
public PageReference payOrder() {
    String callOutMsg;
    Boolean proceedPayment = (!paymentType.startsWith('Credit'));

    if (proceedPayment)
    {
        callOutMsg = Order_Svc.orderSubscription(new Set<Id>{vfOrder.Id}, null, new Map<Id, String>{vfOrder.Id => paymentType} );
        
        if (callOutMsg == null) {
            vfOrder.Payment_Type__c = paymentType;
            vfOrder.Status = Order_Svc.getOrderStatusByPaymentType(paymentType);
            vfOrder.Is_Paid__c = Order_Svc.isOrderPaidByPaymentType(paymentType);
            //set the Payment date
            vfOrder.IEC_Payment_Date__c = (Order_Svc.isOrderPaidByPaymentType(paymentType)) ? Date.today() : null;
            update vfOrder;
            Order_Svc.saveCouponUsed(vfOrder.Id, vfOrder.ShipToContactId);
            return new PageReference('/' + String.valueOf(vfOrder.Id).left(15));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, callOutMsg)); return null;
        }
    }
    else
    {
        vfOrder.Payment_Type__c = paymentType;
        update vfOrder;
        
        return new PageReference('/' + String.valueOf(vfOrder.Id).left(15));
    }
} //*** end of "payOrder"


/****************************************************************************************************
    Created by CGI, Thai 2015-09-28
        Cancel order
****************************************************************************************************/
public void cancelOrder_Prepare() {
    vfOrder.Status = Utility.getTextSetting('Order Cancel status');
    isCancelling = true;
    isInlineEditing = true;
} //*** end of "cancelOrder_Prepare"


/****************************************************************************************************
    Created by CGI, Thai 2015-09-28
        Cancel order
****************************************************************************************************/
public PageReference cancelOrder() {
    update vfOrder;
    return new PageReference('/' + String.valueOf(vfOrder.Id).left(15));
} //*** end of "cancelOrder"


    //Refresh the Billing information
    public void refreshBillingInfo(Location__c billToLoca){

        vfOrder.BillTo_Location__c      =   billToLoca.Id;
        vfOrder.BillTo_Address__c       =   billToLoca.Address__c;

        Account vfAccount = new Account_Sel().getAccountById(billToLoca.Account__c);
        vfOrder.SoldTo_Location__c      = vfAccount.SoldTo_Location__c;

        //Order contact information
        vfOrder.BillToAccount__c                =   billToLoca.Account__c;
        vfOrder.BillToAccount_Name__c           =   billToLoca.Account_Name__c;
        vfOrder.BillToContact_Salutation__c     =   billToLoca.Contact_Salutation__c;
        vfOrder.BillToContact_First_Name__c     =   billToLoca.Contact_First_Name__c;
        vfOrder.BillToContact_Last_Name__c      =   billToLoca.Contact_Last_Name__c;
        vfOrder.BillToContact_Name__c           =   billToLoca.Contact_First_Name__c + ' ' + billToLoca.Contact_Last_Name__c;
        vfOrder.BillToContact_Phone__c          =   billToLoca.Phone__c;
        vfOrder.BillToContact_Email__c          =   billToLoca.Email__c;
        vfOrder.BillToContact_Job_Title__c      =   billToLoca.Contact_Title__c;
        vfOrder.BillToContact_VAT_Number__c     =   billToLoca.VAT_Number__c;

        //Map the order Billing Address
        vfOrder.BillingStreet           =   billToLoca.Address__r.Street__c;
        vfOrder.BillingCity             =   billToLoca.Address__r.City__c;
        vfOrder.BillingCountry          =   billToLoca.Address__r.ISO_Country__r.Name;
        vfOrder.BillingCountryCode__c   =   billToLoca.Address__r.ISO_Country__r.ISO_Code__c;
        vfOrder.BillingState            =   (billToLoca.Address__r != null && billToLoca.Address__r.get('ISO_State__c') != null ) ? billToLoca.Address__r.ISO_State__r.Name : '';
        vfOrder.BillingStateCode__c     =   (billToLoca.Address__r != null && billToLoca.Address__r.get('ISO_State__c') != null ) ? billToLoca.Address__r.ISO_State__r.ISO_Code__c : '';
        vfOrder.BillingPostalCode       =   billToLoca.Address__r.ZipCode__c;

        vfOrder.AccountId               =   billToLoca.Account__c; 
        vfOrder.SoldToAccount_Name__c   =   billToLoca.Account_Name__c;

    }

    //Refresh Shipping information
    public void refreshShippingInfo(Location__c shipToLoca, Boolean mapEmailAndPhone){

        vfOrder.ShipTo_location__c      =   shipToLoca.Id;
        vfOrder.ShipTo_Address__c       =   shipToLoca.Address__c;

        if(mapEmailAndPhone){
            //Order contact information
            vfOrder.ShipToAccount__c            =   shipToLoca.Account__c;
            vfOrder.ShipToAccount_Name__c       =   shipToLoca.Account_Name__c;
            vfOrder.ShipToContact_Salutation__c =   shipToLoca.Contact_Salutation__c;
            vfOrder.ShipToContact_First_Name__c =   shipToLoca.Contact_First_Name__c;
            vfOrder.ShipToContact_Last_Name__c  =   shipToLoca.Contact_Last_Name__c;
            vfOrder.ShipToContact_Name__c       =   shipToLoca.Contact_First_Name__c + ' ' + shipToLoca.Contact_Last_Name__c;
            vfOrder.ShipToContact_Phone__c      =   shipToLoca.Phone__c;
            vfOrder.ShipToContact_Email__c      =   shipToLoca.Email__c;
        }

        vfOrder.ShipToContact_Job_Title__c      =   shipToLoca.Contact_Title__c;
        vfOrder.ShipToContact_VAT_Number__c     =   shipToLoca.VAT_Number__c;

        //Map the order Shipping Address
        vfOrder.ShippingStreet          =   shipToLoca.Address__r.Street__c;
        vfOrder.ShippingCity            =   shipToLoca.Address__r.City__c;
        vfOrder.ShippingCountry         =   shipToLoca.Address__r.ISO_Country__r.Name;
        vfOrder.ShippingCountryCode__c  =   shipToLoca.Address__r.ISO_Country__r.ISO_Code__c;
        
        vfOrder.ShippingState           =   (shipToLoca.Address__r != null && shipToLoca.Address__r.get('ISO_State__c') != null ) ? shipToLoca.Address__r.ISO_State__r.Name : '';
        vfOrder.ShippingStateCode__c    =   (shipToLoca.Address__r != null && shipToLoca.Address__r.get('ISO_State__c') != null ) ? shipToLoca.Address__r.ISO_State__r.ISO_Code__c : '';
        vfOrder.ShippingPostalCode      =   shipToLoca.Address__r.ZipCode__c;
    }

    
/****************************************************************************************************
    Created by CGI, Thai 2015-09-28
        Save order
****************************************************************************************************/
public PageReference saveOrder() {
    PageReference retPage;
    String errorMsg = '', retURL;
    
    retURL = ((vfOrder.Id == null) ? null : returnURL);
    
    //*** validate sold to information
    if (vfOrder.AccountId == null)
        errorMsg += labels.get('errMissSoldTo');

    //selectedBillToLocation =   vfOrder.BillTo_Location__c;
    system.debug('vfOrder.BillTo_Location__c ' + vfOrder.BillTo_Location__c);
    if(vfOrder.BillTo_Location__c == null){ errorMsg += labels.get('errMissBillTo'); }
    //-- Added by David D: Validate Billing Address 
    else{
        Location__c billTo_loc = new Location_sel().getLocations(new Set<Id>{vfOrder.BillTo_Location__c})[0];
        if(String.isBlank(billTo_loc.Street__c)){
            errorMsg += '<br> Invalid Billing Address';
        }
    }
    

    if(!vfOrder.ShipTo_same_BillTo__c && (selectedShipToLocation == null || selectedShipToLocation == '')){ errorMsg += labels.get('errMissShipTo'); }
    else if(!vfOrder.ShipTo_same_BillTo__c && String.isNotBlank(selectedShipToLocation))
    {
        //-- Validate ShipTo Location 
        Location__c shipTo_loc = new Location_sel().getLocations(new Set<Id>{selectedShipToLocation})[0];
        if(String.isBlank(shipTo_loc.Street__c)){
            errorMsg += '<br> Invalid Shipping Address';
        }
    }
    
    //*** display error if any
    if (errorMsg != '') { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg.substring(5))); return null; }

    Location__c billToLocation  = new Location__c();
    Location__c shipToLocation = new Location__c();

    //get the BillTo Location
    List<Location__c> locations = new Location_Sel().getLocations(new set<Id>{vfOrder.BillTo_Location__c});
    System.debug('vfOrder.BillTo_Location__c::'+vfOrder.BillTo_Location__c);
    
    system.debug('locations ' + locations);
    if(locations != null && locations.size() > 0)
        billToLocation = locations[0];
        
    system.debug('billToLocation ' + billToLocation);

    system.debug('vfOrder.ShipTo_same_BillTo__c ' + vfOrder.ShipTo_same_BillTo__c);
    //*** copy bill to information to ship to if applicable
    if (vfOrder.ShipTo_same_BillTo__c) {
        
        //Get the ShipTo Location related to the billToAddressId
        Boolean createNewLocation = true;

        if(vfOrder.ShipTo_Location__c != null ){
            if(String.isEmpty(selectedShipStateIsoCode)){
                selectedShipStateIsoCode = vfOrder.ShippingStateCode__c;
            }
        }
        if(vfOrder.ShipTo_Location__c  != null && vfOrder.ShippingCountry == vfOrder.BillingCountry && selectedShipStateIsoCode == selectedStateIsoCode){
            List<Location__c> lstExistingShipToLocation = new Location_sel().getLocations(new set<Id>{vfOrder.ShipTo_Location__c});
            
            if(lstExistingShipToLocation != null && lstExistingShipToLocation.size() > 0){
                lstExistingShipToLocation[0].Address__c = vfOrder.BillTo_Address__c;
                vfOrder.ShipTo_Address__c = vfOrder.BillTo_Address__c;
                createNewLocation = false;
                update lstExistingShipToLocation[0];
            }
        }

        if(createNewLocation){
            List<Location__c> shipToLocations = new Location_Sel().getLocationByAddressId(billToLocation.Address__c);// [select id,Address__c from Location__c where Address__c =:billToAddressId and Type__c = :IECConstants.SHIPTO ];
            if(shipToLocations != null && shipToLocations.size() > 0){
                //-- Ensure the location bellongs to customer 
                for(Location__c loc: shipToLocations)
                {
                    if(billToLocation.Contact__c == loc.Contact__c)
                    {
                        shipToLocation = loc;
                        shipToLocation.Phone__c = vfOrder.BillToContact_Phone__c;
                        shipToLocation.Email__c = vfOrder.BillToContact_Email__c;
                        shipToLocation.VAT_Number__c = billToLocation.VAT_Number__c;
                        update shipToLocation;
                        createNewLocation = false;
                        break;
                    }    
                }
            }
        }
        

        if(createNewLocation){
            //Create a new Shipping location
            Location__c newLocation =   new Location__c();
            newLocation.Type__c     =   IECConstants.SHIPTO;
            newLocation.Address__c  =   billToLocation.Address__c;
            newLocation.Active__c   =   true;
            newLocation.Account__c  =   billToLocation.Account__c;
            newLocation.Contact__c  =   billToLocation.Contact__c;
            newLocation.Phone__c    =   billToLocation.Phone__c;
            newLocation.Email__c    =   billToLocation.Email__c;
            newLocation.VAT_Number__c = billToLocation.VAT_Number__c;

            //Insert the new Shiping location
            try{
                Insert newLocation;
                shipToLocation = newLocation;
            }catch(Exception ex){}
            
        }

        selectedShipToLocation = shipToLocation.Id;
        vfOrder.ShipToContactId = vfOrder.BillToContactId;

    }else{
        //get ShipTo Location
        List<Location__c> shipLocations = new Location_Sel().getLocations(new set<Id>{selectedShipToLocation});
        if(shipLocations != null && shipLocations.size() > 0)
            shipToLocation = shipLocations[0];
    }    

    //Refresh the billing information
    refreshBillingInfo(billToLocation);
    
    //Refresh Shipping information
    refreshShippingInfo(shipToLocation, false);

    if (vfOrder.ShipTo_same_BillTo__c){
        //Map the Phone and Email
        if(vfOrder.ShipToContact_Phone__c == null || vfOrder.ShipToContact_Phone__c == '')
            vfOrder.ShipToContact_Phone__c      =   vfOrder.BillToContact_Phone__c;
        if(vfOrder.ShipToContact_Email__c == null || vfOrder.ShipToContact_Email__c == '')
            vfOrder.ShipToContact_Email__c      =   vfOrder.BillToContact_Email__c;
        if(vfOrder.ShipToAccount_Name__c == null || vfOrder.ShipToAccount_Name__c == '')
            vfOrder.ShipToAccount_Name__c       =   vfOrder.BillToAccount_Name__c;
        if(vfOrder.ShipToContact_Name__c == null || vfOrder.ShipToContact_Name__c == '')
            vfOrder.ShipToContact_Name__c       =   vfOrder.BillToContact_Name__c;
            
        //Map the order Shipping Address
        vfOrder.ShippingStreet          =   vfOrder.BillingStreet;
        vfOrder.ShippingCity            =   vfOrder.BillingCity;
        vfOrder.ShippingCountry         =   vfOrder.BillingCountry;
        vfOrder.ShippingCountryCode__c  =   vfOrder.BillingCountryCode__c;
        
        vfOrder.ShippingState           =   vfOrder.BillingState;
        vfOrder.ShippingStateCode__c    =   vfOrder.BillingStateCode__c;
        vfOrder.ShippingPostalCode      =   vfOrder.BillingPostalCode;
        
        vfOrder.ShipToContact_VAT_Number__c = vfOrder.BillToContact_VAT_Number__c;
        
    }


    //Add the sold to location in the Order
    if(vfOrder.AccountId != null){
        map<Id,Location__c> soldToLocationMap = new Location_Sel().getSoldToAccountLocation(new set<Id>{vfOrder.AccountId});
        if(soldToLocationMap != null && soldToLocationMap.size() >0){
            vfOrder.SoldTo_Location__c = soldToLocationMap.values()[0].Id;
        }
    }
    
    //*** set end date for quote
    if (vfOrder.Type.containsIgnoreCase('Quote')){
        vfOrder.EndDate = vfOrder.EffectiveDate.addDays(Utility.getIntegerSetting('Quote Nb Days Valid'));
    }
    
    //*** no error -> save data
    Savepoint sp = Database.setSavepoint();
    try {
        upsert vfOrder;
    } catch (Exception e) {
        ApexPages.addMessages(e);
        Database.rollback(sp);
        return null;
    }

    retPage = new PageReference(((retURL == null) ? '/' + String.valueOf(vfOrder.Id).left(15) : retURL));
    retPage.setRedirect(true);
    return retPage;
} //*** end of "saveOrder"


/****************************************************************************************************
    Created by CGI, Thai 2015-10-21
        Calculate shipping charge and tax
****************************************************************************************************/
public void getFreight_Tax() {
    String errorMsg = callSAP_Freight_Tax();
    if (errorMsg == null)
        initOrderItems();
    else
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));

    //Get the new handling charge from the order and display an message if Total_handling_charges__c > 0
    Order o = Order_Sel.getOrderForVF(vfOrder.Id);
    if(o.Total_handling_charges__c > 0){
        if (!attentionMsg.contains(labels.get('msgWarnHandling'))){ attentionMsg += labels.get('msgWarnHandling'); }       
    }else{
        if (attentionMsg.contains(labels.get('msgWarnHandling'))){ attentionMsg = attentionMsg.replace(labels.get('msgWarnHandling'), ''); }
    }
} //*** end of "get_Freight_Tax"


/****************************************************************************************************
    Created by CGI, Thai 2015-11-06
        Call SAP to get shipping charge and tax
****************************************************************************************************/
public String callSAP_Freight_Tax() {
    String errorMsg = Order_Svc.getSAP_Freight_Tax(vfOrder.Id);

    if (errorMsg != null)
        try {
            List<OrderItem> check = (List<OrderItem>) JSON.deserializeStrict(errorMsg, List<OrderItem>.class);
            errorMsg = null;
        } catch (Exception e) {}
    return errorMsg;
} //*** end of "callSAP_Freight_Tax"


/****************************************************************************************************
    Created by CGI, Thai 2015-11-05
        Build list of available payment methods
****************************************************************************************************/
void buildPaymentTypePicklist() {
    //if (listPaymentType == null) {
    if (isPaying) {
        List<String> allowedPaymentType = Utility.getTextSettingToArray('Order Payment Types allowed for CSR', ',');
        Map<String, String> mapPaymentType = Utility.getPicklistValue_Label('Order', 'Payment_Type__c');
        //String paymentType = '';
        Decimal TotalAmount = 0;
        
        if (listPaymentType == null)
            listPaymentType = new List<SelectOption>();
        else
            listPaymentType.clear();
        
        //*** get the amount to pay for validation of payment types
        for (OrderItem oi : [select Total__c from OrderItem where OrderId = :vfOrder.Id])
            TotalAmount += oi.Total__c;

        //*** determine list of payment types allowed
        for (String payType : allowedPaymentType)
            if (mapPaymentType.containsKey(payType)) {
                if (payType == 'Credit Card Deferred') {
                    if (IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, TotalAmount))
                        listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType)));
                    else
                        listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType) + labels.get('msgPayTypeThreshold'), true));
                }
                else if (payType == 'Bank Transfer' || payType == 'Check') {
                    if (IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_BankTransfer, TotalAmount))
                        listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType)));
                    else
                        listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType) + labels.get('msgPayTypeThreshold'), true));
                }
                else if (payType == 'ICH') {
                    try { //*** try-catch because error may happen sometime mostly new customer
                        //IECCustomer customer = new IECCustomer(vfOrder.BillToContactId);

                        //Get the Ecom user base on the order BillTocontactId
                        User iecCustomer = new User_sel().getUserByContactId(vfOrder.BillToContactId);
                        Customer_DTO customerDto;
                        if(iecCustomer != null)
                            customerDto = Customer_DTO.getCustomerByUser(iecCustomer.Id);

                        //if (customerDto != null && customerDto.canPayByICH())   //*** (Thai) relax this rule in production in waiting of final rule
                        if (customerDto != null)
                        {
                            if (IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_ICH, TotalAmount))
                                listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType)));
                            else
                                listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType) + labels.get('msgPayTypeThreshold'), true));
                        }
                        else
                            listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType) + labels.get('msgPayTypeNotAllowed'), true));
                    } catch (Exception e) {}
                }
                else if (payType == 'Bill me later') {
                    Account soldToAccount = [select Payment_Term__c from Account where Id = :vfOrder.AccountId limit 1][0];
                    Set<String> BillLaterPaymentTerm = new Set<String>(Utility.getTextSettingToArray('Payment Terms for Bill me later', ','));
                    if (BillLaterPaymentTerm.contains(soldToAccount.Payment_Term__c))
                    {
                        if ([select count() from OrderItem where OrderId = :vfOrder.Id and PricebookEntry.Product2.IEC_Parent_Product__c != null] > 0)
                            listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType) + labels.get('msgPayTypeBlock'), true));
                        else if (IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_BillMeLater, TotalAmount))
                            listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType)));
                        else
                            listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType) + labels.get('msgPayTypeNotAllowed'), true));
                    }
                    else
                        listPaymentType.add(new SelectOption(payType, mapPaymentType.get(payType) + labels.get('msgPayTypeNotAllowed'), true));
                }
            }
        listPaymentType.sort();
        listPaymentType.add(0, new SelectOption('', ''));
        paymentType = listPaymentType[0].getValue();

    }
} //*** end of "buildPaymentTypePicklist"


    public void createSalesOrder()
    {
        Order_Svc.createSapSalesOrders(new Set<Id>{
            vfOrder.Id
        }); 
    }


    public void createSalesContract()
    {
        Order_Svc.createSAPContracts(new Set<Id>{ vfOrder.Id }); 
        initOrderItems();
    }
    
    /****************************************************************************************************
        Created by CGI, Samy Saied 2016-01-11
            Checks Order for compliance with countries
    ****************************************************************************************************/
    void CheckOrderCompliance() {
         // Determine product compliance with countries
        if (!orderProducts.isEmpty()) {
            // Build list of product Ids
            List<Id> lstProduct2Id = new List<Id>();
            for (OrderItem_DTO oi : orderProducts) {
                lstProduct2Id.add(oi.productId);
            }
            
            // Build list of order countries
            Set<String> setOrderCountryCode = new Set<String>();

            if (!String.isBlank(vfOrder.BillingCountryCode__c)) setOrderCountryCode.add(vfOrder.BillingCountryCode__c);
            if (!String.isBlank(vfOrder.ShippingCountryCode__c)) setOrderCountryCode.add(vfOrder.ShippingCountryCode__c);

            // Check compliance
            mapProduct2Id_Compliance = Product_Svc.IsProductAndCountryCompliant(lstProduct2Id, setOrderCountryCode);
            
            bAreProductsCompliant = true;
            
            if (!mapProduct2Id_Compliance.isEmpty()) {
                for (Id idProduct : mapProduct2Id_Compliance.keySet()) {
                    // display error message with product name/number
                    for (OrderItem_DTO oi : orderProducts) {
                        if (idProduct == oi.productId) {
                            if (!mapProduct2Id_Compliance.get(idProduct)) {
                                bAreProductsCompliant = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, String.format(labels.get('msgWarnProductNotCompliant'), new String[]{oi.productName, oi.productCode})));
                            }
                            break;
                        }
                    }
                }
            }
        }
    } //*** end of "CheckOrderCompliance"
    
    // Allows CSR to resend download link for a specific order item to the customer
    public PageReference resendOrderItemLink()
    {
        // Retrieve the OrderItemId to regenerate the link for
        String orderItemId = ApexPages.currentPage().getParameters().get('orderItemId');

        // Create a save point to be able to rollback in case of failure
        Savepoint sp = Database.setSavepoint();

        try {
            if (!String.isBlank(orderItemId)) {
                // First reset the download counter
                update new OrderItem(Id = orderItemId, AWS_download_link__c = null);
                
                // Now send the email
                Mail_DTO clientMail = new Mail_DTO();
                clientMail.whatId = orderItemId;
                clientMail.templateId = Utility.getTextSetting('OrderItem sold templateId for client');
                clientMail.recipients = new list<String> {vfOrder.ShipToContact_Email__c};
                Utility.sendBulkEmails(new List<Mail_DTO> {clientMail});

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.IEC_Confirm_EmailSent));
            }
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return null;
        }

        return null;
    }

} //*** end of class