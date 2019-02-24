/****************************************************************************************************
    Created by Kevin Ky 2015-09-23
    
****************************************************************************************************/
public without sharing class Order_Svc
{
    public class OrderException extends Exception {}

    /****************************************************************************************************
        Created by David D 2015-12-03
            Function to Update Order Status 
    ****************************************************************************************************/
    public static void updateOrderStatus(Map<Id, String> statusByOrderId, Map<Id, Boolean> paidByOrderId)
    {
        //-- 1. Validate params 
        if(statusByOrderId != null && statusByOrderId.size() > 0)
        {
            List<Order> orders2Update = new List<Order>();
            Set<String> paidStatus = new Set<String>(Utility.getTextSettingToArray('ORDER_PAID_STATUS', ','));

            for(Id orderId : statusByOrderId.keySet())
            {
                String status = statusByOrderId.get(orderId);

                if(orderId != null)
                {
                    Order ord = new Order(Id = orderId, Status = status);
                    if(paidStatus.contains(status) && paidByOrderId.get(orderId) == true){
                        ord.Is_Paid__c = true; 
                        ord.IEC_Payment_Date__c = Date.today();
                    }
                        
                    orders2Update.add(ord);
                }
            } 

            //-- Save Orders 
            if(orders2Update.size() > 0)
            {
                update orders2Update;
            }
        }
    }   

    public static String getSAPPaymentType(String paymentType)
    {
        if(paymentType == null) return paymentType;

        Map<String, String> SAPPaymentMap = new Map<String, String>{
            'creditcard'            =>  '1',
            'banktransfer'          =>  'T',
            'check'                 =>  'C',
            'ich'                   =>  'I',
            'billmelater'           =>  null
        };

        String str = paymentType.toLowerCase().replace(' ', '');

        return (SAPPaymentMap.containsKey(str)) ? SAPPaymentMap.get(str) : paymentType;
    }


    /****************************************************************************************************
        Created by David D 2015-10-09
            This function create SAP SalesOrder Request  
    ****************************************************************************************************/
    public static SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Request createSalesOrderRequestObject(Order ord, List<OrderItem> items, 
        Map<Id, List<Order_Item_Charge__c>> charges, Map<String, SFDC_SAP_Mapping__c> sapTable, Map<Id, Location__c> locationById)
    {
        String key = ord.Type +'_' + ord.Source__c + ord.Order_Channel__c;
        SFDC_SAP_Mapping__c mapEntry = (sapTable.containsKey(key)) ? sapTable.get(key) :null;

        Location__c soldToLocation  =   locationById.get(ord.SoldTo_Location__c);
        Location__c billToLocation  =   locationById.get(ord.BillTo_Location__c);
        Location__c shipToLocation  =   locationById.get(ord.ShipTo_Location__c);

        SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Request request = new SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Request();
            
            //-- Order Information
            request.ECommerceOrderNo    = String.valueOf(ord.Id).left(15); 
            request.CustomerPORefNo     = Utility.truncate(ord.PoNumber,20);
            request.OrderDate           = ord.EffectiveDate;
            request.OrderType           = (mapEntry!=null) ? mapEntry.SAP_Order_Type__c : '';
            request.SalesOrg            = (mapEntry!=null) ? mapEntry.SAP_Sales_Org__c : '';
            request.DistChannel         = (mapEntry!=null) ? mapEntry.SAP_Distribition_Channel__c : '';
            request.Division            = (mapEntry!=null) ? mapEntry.SAP_Division__c : '';
            //request.PaymentMethod       = getSAPPaymentType(ord.Payment_Type__c);
            request.PaymentMethod       = ((ord.Payment_Type__c == 'Credit Card' || ord.Payment_Type__c == 'Credit Card Deferred') ? 'CRC' : ((ord.Payment_Type__c == 'Bill me later') ? null : ord.Payment_Type__c));

            //-- new fields added on 06/09/2016
            request.Email               = ord.ShipToContact_Email__c; 
            request.Company             = ord.ShipToAccount_Name__c;
            request.Attention           = ord.ShipToContact_Name__c;
            request.Phone               = ord.ShipToContact_Phone__c;

            request.Tax                 = ord.Taxes__c;
            request.CurrencyCode        = ord.CurrencyIsoCode;

            //-- Notes
            request.Notes = new SAP_SalesOrder.DT_SFDC_Note();
                request.Notes.InvoiceNote     = ord.Invoice_Text__c;
                request.Notes.PackingListNote = ord.Sales_Order_Remark__c;
                request.Notes.DeliveryNote    = ord.Shipping_Instruction__c;
                request.Notes.WorkflowRemark  = ord.Internal_Remark__c;

            //-- SolTo
            SAP_SalesOrder.DT_SFDC_Partner soldTo = new SAP_SalesOrder.DT_SFDC_Partner();
                soldTo.SAPPartnerID         = Utility.truncate(soldToLocation.SAP_Id__c,10);
                soldTo.SalesForcePartnerID  = String.valueOf(ord.AccountId).left(15);
                soldTo.Company              = Utility.truncate(soldToLocation.Account_Name__c,35);
                soldTo.Name                 = Utility.truncate(soldToLocation.Account_Name__c,35);
                soldTo.AddressLine1         = Utility.truncate(soldToLocation.Street__c,35);
                soldTo.AddressLine2         = Utility.truncate(soldToLocation.Street__c,35,35);
                soldTo.City                 = Utility.truncate(soldToLocation.City__c,35);
                soldTo.PostalCode           = Utility.truncate(soldToLocation.ZipCode__c,9);
                //soldTo.Province             = Utility.truncate(soldToLocation.ISO_State_Code_SAP__c,3);
                soldTo.Province             = ((soldToLocation.IEC_Valid_SAP_State__c != true) ? '' : Utility.truncate(soldToLocation.ISO_State_Code_SAP__c, 3));
                soldTo.Country              = Utility.truncate(soldToLocation.ISO_Country_Code__c,3);
                //soldTo.TaxJurisdictionCode = 
            request.SoldTo = soldTo;

            //-- BillTo 
            SAP_SalesOrder.DT_SFDC_Partner billTo = new SAP_SalesOrder.DT_SFDC_Partner();   
                billTo.SAPPartnerID         = Utility.truncate(billToLocation.SAP_Id__c,10);
                billTo.SalesForcePartnerID  = String.valueOf(ord.BillToContactId).left(15);
                billTo.Company              = Utility.truncate(billToLocation.Account_Name__c,35);
                billTo.Name                 = Utility.truncate(billToLocation.Account_Name__c,35);
                billTo.AddressLine1         = Utility.truncate(billToLocation.Street__c,35);
                billTo.AddressLine2         = Utility.truncate(billToLocation.Street__c,35,35);
                billTo.City                 = Utility.truncate(billToLocation.City__c,35);
                billTo.PostalCode           = Utility.truncate(billToLocation.ZipCode__c,9);
                //billTo.Province             = Utility.truncate(billToLocation.ISO_State_Code_SAP__c,3);
                billTo.Province             = ((billToLocation.IEC_Valid_SAP_State__c != true) ? '' : Utility.truncate(billToLocation.ISO_State_Code_SAP__c, 3));
                billTo.Country              = Utility.truncate(billToLocation.ISO_Country_Code__c,3);
                //billTo.TaxJurisdictionCode = 
            request.BillTo = billTo; 

            //-- Payer = BillTo
            request.Payer = billTo;

            //-- ShipTo
            SAP_SalesOrder.DT_SFDC_Partner shipTo = new SAP_SalesOrder.DT_SFDC_Partner();
                shipTo.SAPPartnerID         = Utility.truncate(shipToLocation.SAP_Id__c,10);
                shipTo.SalesForcePartnerID  = String.valueOf(ord.ShipToContactId).left(15);
                shipTo.Company              = Utility.truncate(shipToLocation.Account_Name__c,35);
                //shipTo.Company              = Utility.truncate(ord.ShipToAccount_Name__c,35);
                shipTo.Name                 = Utility.truncate(shipToLocation.Account_Name__c,35);
                //shipTo.Name                 = Utility.truncate(ord.ShipToContact_Name__c,35);
                //TC: Enhancement
                List<String> addressLines   = Utility.splitAddress(shipToLocation.Street__c, 35);
                shipTo.AddressLine1         = addressLines[0];
                shipTo.AddressLine2         = addressLines[1];
                shipTo.City                 = Utility.truncate(shipToLocation.City__c,35);
                shipTo.PostalCode           = Utility.truncate(shipToLocation.ZipCode__c,9);
                //shipTo.Province             = Utility.truncate(shipToLocation.ISO_State_Code_SAP__c,3);
                shipTo.Province             = ((shipToLocation.IEC_Valid_SAP_State__c != true) ? '' : Utility.truncate(shipToLocation.ISO_State_Code_SAP__c, 3));
                shipTo.Country              = Utility.truncate(shipToLocation.ISO_Country_Code__c,3);
            request.ShipTo = shipTo;

            //-- OrderItem
            request.OrderItem = new List<SAP_SalesOrder.DT_SFDC_OrderItem>();
            for(OrderItem oi : items)
            {
                //-- SalesOrder Interface is Called only for Shippable Products 
                //if(oi.Is_Shippable_Product__c == true)
                if(oi.Use_Contract_when_ordered__c == false)
                {
                    SAP_SalesOrder.DT_SFDC_OrderItem sap_item = new SAP_SalesOrder.DT_SFDC_OrderItem();
                    sap_item.Division      = oi.Division__c;
                    if (oi.SAP_Product_Number__c.isNumeric())
                        sap_item.ProductNumber = Utility.truncate('0'.repeat(18 - oi.SAP_Product_Number__c.length()) + oi.SAP_Product_Number__c,18);
                    else
                        sap_item.ProductNumber = Utility.truncate(oi.SAP_Product_Number__c,18);
                    sap_item.Description   = Utility.truncate(oi.Description,70);
                    sap_item.Quantity      = oi.Quantity;
                    sap_item.UnitPrice     = oi.UnitPrice;

                    //--New field added on 06/09/2016
                    sap_item.FreeShipmentFlag = (!oi.Charge_Shipping__c);

                    //-- Discounts 
                    List<Order_Item_Charge__c> discounts = charges.get(oi.Id);
                    if(discounts != null && discounts.size() > 0)
                    {
                        sap_item.Discounts = new List<SAP_SalesOrder.Discounts_element>();
                        for(Order_Item_Charge__c charge : discounts)
                        {
                            SAP_SalesOrder.Discounts_element discount = new SAP_SalesOrder.Discounts_element();
                            discount.DiscountType = charge.Discount_Type__c + 'discount_' + ((charge.Discount_Amount__c != null) ? 'dollars' : 'percentage');
                            discount.DiscountValue = (charge.Discount_Amount__c != null) ? (charge.Discount_Amount__c / oi.Quantity) : charge.Discount_Percentage__c;
                            if (discount.DiscountValue != null && discount.DiscountValue > 0)
                                sap_item.Discounts.add(discount);
                        }
                        if (sap_item.Discounts.size() == 0)
                            sap_item.Discounts = null;
                    } 
                    request.OrderItem.add(sap_item);
                }   
            }

        return request;
    }

    /****************************************************************************************************
        Created by David D 2015-10-09
            This function Set callout Header
    ****************************************************************************************************/
    public static SAP_SalesOrder.HTTPS_Port setCalloutHeader(SAP_SalesOrder.HTTPS_Port req)
    {
        String authorizationHeader =  Utility.getSAPauthorization();

        if(req.inputHttpHeaders_x == null)
        {
            req.inputHttpHeaders_x = new Map<String,String>(); 
        }
        req.inputHttpHeaders_x.put('Authorization', authorizationHeader);
        req.timeout_x = Utility.getIntegerSetting('SAP_CALL_TIMEOUT');
        req.endpoint_x = Utility.fixEndpointDomain(req.endpoint_x);

        return req;
    }

    /****************************************************************************************************
        Created by David D 2015-10-09
            This function create SalesOrder in SAP 
    ****************************************************************************************************/

    public static void createSapSalesOrders(Set<Id> orderIds)
    {
        Order_Sel orderSelector             = new Order_Sel(); 
        OrderItem_Sel itemSelector          = new OrderItem_Sel();
        OrderItemCharge_Sel chargeSelector  = new OrderItemCharge_Sel();
        Location_Sel locationSelector       = new Location_Sel();

        //-- Errors logging
        List<IEC_Error_Log__c> errorLogs = new List<IEC_Error_Log__c>();

        //-- Request & Response Objects 
        Map<Id, SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Request> requestByOrder = new Map<Id, SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Request>();
        Map<Id, SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Response> responseByOrder = new Map<Id, SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Response>();

        //-- Order Details 
        Map<Id, Order> orderById = new Map<Id, Order>((List<Order>) orderSelector.selectSObjectById(orderIds));
        errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(orderById), null, 'Debug Information - get orderIds to be processed'));

        //-- Order Item Details 
        Map<Id, List<OrderItem>> orderItemsByOrder = itemSelector.getOrderItems(orderIds);
        errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(orderItemsByOrder), null, 'Debug Information - get order items to be processed'));

        //-- Order Locations 
        Map<Id, Location__c> locationById = locationSelector.getOrdersLocations(orderById.values());
        errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(orderById), null, 'Debug Information - get orderIds to be processed'));

        //-- Charge (Discount) Details
        Set<Id> orderItemIds = new Set<Id>();
        for(List<OrderItem> lst : orderItemsByOrder.values())
            for(OrderItem oi : lst)
                orderItemIds.add(oi.Id);
        
        Map<Id, List<Order_Item_Charge__c>> chargesByItem = chargeSelector.getChargesByOrerItem(orderItemIds);
        errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(chargesByItem), 'Charges/Discounts: '+chargesByItem, 'Debug Information - charges for order item ids: '+orderItemIds));

        //-- susana
        //-- Verify if the status of the order is valid before send the order to SAP
        //-- if the order is not paid and status is Payment Failure, the order cannot be created on SAP
        /*for(Order o : orderById.values())
        {   system.debug('Is_Paid__c :: ' + o.Is_Paid__c);
            system.debug('Status :: ' + o.Status);
            if(o.Is_Paid__c == false && o.Status == IECConstants.ORDER_STATUS_PAYMENT_FAILURE) //Payment Failure
            {
                orderById.remove(o.id);
                system.debug('order ' + o.id + ' removed from map');
            }
        }*/

        //-- SFDC <=> SAP Mapping table 
        Map<String, SFDC_SAP_Mapping__c> sapTable = orderSelector.getOrderMapTable();
        errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(sapTable), 'Order Id '+orderById.keySet(), 'Debug Information - sapTable'));

        //-- Build Request object 
        for(Id orderId : orderById.keySet())
        {   Order ord = orderById.get(orderId);

            //validate SO not created yet 
            if(String.isBlank(ord.SAP_Order_Number__c))
            {   errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(ord), 'Order '+ord, 'Debug Information - SAP_Order_Number__c is blank'));
                List<OrderItem> items = (orderItemsByOrder.containsKey(ord.Id)) ? orderItemsByOrder.get(ord.Id) : new List<OrderItem>();
                errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(items), 'Order '+ord, 'Debug Information - SAP_Order_Number__c is blank'));
                requestByOrder.put(ord.Id, createSalesOrderRequestObject(ord, items, chargesByItem, sapTable, locationById));

            }
            else if(!System.isFuture() && !System.isBatch() && !System.isScheduled() && !System.isQueueable())
            {   errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(sapTable), 'Order '+ord, 'Error - SAP_Order_Number__c NOT blank'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING ,Label.Warning_SalesOrder_Already_Created));
            }
        }

        //-- Set Authentication header 
        SAP_SalesOrder.HTTPS_Port req = new SAP_SalesOrder.HTTPS_Port(); 
        req = setCalloutHeader(req);
        errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(req), null, 'Debug Information - Authentication'));
        

        //-- Do Callouts for each Order
        for(Id orderId : orderById.keySet())
        {
            SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Request request = requestByOrder.get(orderId);
            errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(request), 'Order Id '+orderId, 'Debug Information - SI_SFDC_SalesOrderCreate_SYNC Request for Order Id '+orderId));

            try
            {
                //-- Do Callouts only if there are OrderItems 
                if(request !=null && request.OrderItem.size() > 0)
                {
                    SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Response response = req.SI_SFDC_SalesOrderCreate_SYNC(request);
                    System.debug('response for '+orderId+'::'+response);
                    errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(response), 'Order Id '+orderId, 'Debug Information - SI_SFDC_SalesOrderCreate_SYNC Response for Order Id '+orderId));
                    responseByOrder.put(orderId, response);
                }
                else
                {
                    if(!System.isFuture() && !System.isBatch() && !System.isScheduled() && !System.isQueueable())
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING ,Label.Warning_No_Shippable_Product));
                }
            }
            catch(Exception ex) 
            {
                //Send notification to Administrator is the SOAP call faild
                if(!System.isFuture() && !System.isBatch() && !System.isScheduled() && !System.isQueueable())
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,ex.getMessage()));
                    errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(request), 'SOAP Call Failed ' + ex.getMessage(), ex.getStackTraceString()));
                }
                else
                {
                    errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(request), ex.getMessage(), ex.getStackTraceString()));
                }
            }
        }

        if(errorLogs.size() > 0) IECErrorLogger.logErrors(errorLogs, true);
        
        //-- Process responses 
        processSalesOrderResponse(responseByOrder);
    }

    public static void processSalesOrderResponse(Map<Id, SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Response> responseByOrder)
    {
        //-- Errors logging
        List<IEC_Error_Log__c> errorLogs = new List<IEC_Error_Log__c>();

        //-- Process responses 
        List<Order> orders2update = new List<Order>();
        String error_msg;
        for(Id orderId : responseByOrder.keySet())
        {
            SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Response response = responseByOrder.get(orderId);
            errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/processSalesOrderResponse', JSON.serialize(response), 'Order Id '+orderId, 'Debug Information - Response for Order Id '+orderId));
            //If success update SAP_Order_Number__c
            if(response.Error == null)
            {
                errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/processSalesOrderResponse', JSON.serialize(response), 'Order Id '+orderId, 'Debug Information - Updated SAP Order Number for Order Id '+orderId));
                ///-- Update SAP Order Number
                orders2update.add(new Order(
                    Id = orderId, 
                    SAP_Order_Number__c = response.SalesOrderNumber,
                    Status = 'Order Created'
                ));
            }
            else
            {
                //@todo: handle callouts errors
                error_msg = String.format('Order ID: {0}<br/>Error Code: {1}<br/>Error Type: {3}<br/>Message: {2}', new List<String>{
                    orderId, response.Error.Code, response.Error.Message, response.Error.Type_x   
                });

                if(!System.isFuture() && !System.isBatch() && !System.isScheduled() && !System.isQueueable())
                {   errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/processSalesOrderResponse', 'Error Message: ' + error_msg, 'Order Id '+orderId, 'Error - Order Id '+orderId));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,error_msg));
                }
                else
                {
                    errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/processSalesOrderResponse', 'SAP SalesOrder Error for '+orderId, error_msg, null));
                }
            }
        }

        if(orders2update.size() > 0)
        {
            try
            {
                update orders2update;
                errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/processSalesOrderResponse', JSON.serialize(orders2update), 'Orders Updated', 'Debug Information - Updated Order Ids '+orders2update));

            }
            catch(Exception ex)
            {
                if(!System.isFuture() && !System.isBatch() && !System.isScheduled() && !System.isQueueable())
                {   errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/processSalesOrderResponse', JSON.serialize(orders2update), ex.getMessage(), ex.getStackTraceString()));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,ex.getMessage()));
                }
                else
                {
                    errorLogs.add(IECErrorLogger.createErrorLog('Order_Svc/processSalesOrderResponse', JSON.serialize(orders2update), ex.getMessage(), ex.getStackTraceString()));
                }
            }
        }

        if(errorLogs.size() > 0) IECErrorLogger.logErrors(errorLogs, true);
    }

    /****************************************************************************************************
        Created by David D 2015-09-29
            This function update OrderItem
    ****************************************************************************************************/
    public static void saveOrderItem(String orderItemId, Decimal unitPrice, Decimal quantity, String zPlanId, String zChargeId)
    {
        OrderItem orderItem = new OrderItem(
            Id = orderItemId,
            Quantity = quantity,
            UnitPrice = unitPrice,
             //Reset Fret & Tax
            Freight_Charge__c = null,
            Tax__c = null,
            Zuora_Rate_Plan_Id__c = zPlanId,
            Zuora_Rate_Plan_Charge_Id__c = zChargeId
        );

        try
        {
            update orderItem;
        }
        catch(Exception ex)
        {
            if(!System.isFuture() && !System.isBatch() && !System.isScheduled())
            {
                ApexPages.addMessages(ex);
            }
            else
            {
                IECErrorLogger.logApexException('Order_Svc/saveOrderItem', JSON.serialize(orderItem), ex.getMessage(), ex.getStackTraceString());
            }
        }
    }

    public static String saveOrderItem(String orderItemId, Decimal quantity, String coupon, Id idContact, String strProductNumber, PriceInfo_DTO price)
    {
        List<OrderItem> item = [select Id, PricebookEntryId, Quantity, Coupon__c, UnitPrice, Charge_Shipping__c from OrderItem where Id = :orderItemId];
        item[0].Quantity = quantity;
        item[0].Coupon__c = coupon;
        return setPriceToOrderItem(item, new Map<String, PriceInfo_DTO>{strProductNumber => price}, idContact);
    }

    /****************************************************************************************************
        Created by David D 2015-09-29
            Prevent Order deletion with some status
    ****************************************************************************************************/
    public static void addItemsToOrder(List<SalesOrderProduct_DTO> products, Order theOrder)
    {
        List<OrderItem> itemsToSave = new List<OrderItem>();
        Map<String, List<Order_Item_Charge__c>> itemChargesToSave = new Map<String, List<Order_Item_Charge__c>>();

        //-- Order Existing products 
        Set<Id> existingOrderItemIds = new set<Id>();
        Map<Id, Set<Id>> productIdsByOrder = new OrderItem_Sel().getProductIdsByOrder(new set<Id>{theOrder.Id});
        
        if(productIdsByOrder != null && productIdsByOrder.size() > 0){
            existingOrderItemIds.addAll(productIdsByOrder.get(theOrder.Id));
        }
        
        Set<Id> productIds = new Set<Id>(); 

        //*** validate entries
        for(SalesOrderProduct_DTO product : products)
        {
            if (existingOrderItemIds.contains(Id.valueOf(product.ecomProduct.ProductId)))
            {
                String msg = String.format(Label.Warning_OrderItem_Exist, new LIST<String>{ product.ecomProduct.ProductName,  product.ecomProduct.ProductNumber });
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING ,msg));
            }
            else if (product.quantity == null || product.quantity <= 0)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, String.format(Label.Warning_Invalid_Quantity
                                    , new LIST<String>{String.valueOf(product.quantity), product.ecomProduct.ProductName , product.ecomProduct.ProductNumber})));
            else if (product.couponCode == null)
                productIds.add(product.ecomProduct.ProductId);
            else
            {
                product.couponCode = product.couponCode.trim();
                if (product.couponCode != null && product.couponCode != '')
                    if (!Order_Svc.isCouponValid(product.ecomProduct.ProductNumber, product.couponCode, product.ecomProduct.PriceInfo.couponPrice, theOrder.ShipToContactId))
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, String.format(Label.Warning_Invalid_Coupon
                                            , new LIST<String>{product.couponCode, product.ecomProduct.ProductName, product.ecomProduct.ProductNumber})));
                    else
                        productIds.add(product.ecomProduct.ProductId);
                else
                    productIds.add(product.ecomProduct.ProductId);
            }
        }

        //*** remove invalid products
        for (Integer i = products.size() - 1; i >= 0; i--)
            if (!productIds.contains((Id) products[i].ecomProduct.ProductId))
            {
                products[i].selected = false;
                products.remove(i);
            }
        
        Pricebook_Sel pricebookSelector = new Pricebook_Sel();  
        PricebookEntry_Sel pricebookEntrySelector = new PricebookEntry_Sel();  
        
        Pricebook2 stdPriceBook = pricebookSelector.getStandardPriceBook();
        
        Map<Id, PricebookEntry> pricebookEntryByProductId = pricebookEntrySelector.getPricebookEntryByProductId(stdPriceBook.Id, productIds);
        
        String currencyCode = null;
        Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>();
        
        try
        {
            //*** prepare order items
            for(SalesOrderProduct_DTO product : products)
            {
                //*** get price book entry -> create if missing
                PricebookEntry pbe = pricebookEntryByProductId.get((Id) product.ecomProduct.ProductId);
                
                if (pbe == null)
                {
                    //*** get corporate currency code if necessary
                    if (currencyCode == null)
                        currencyCode = Utility.getDefaultCurrency();
                    
                    //*** create price book entry
                    pbe = new PricebookEntry(
                        IsActive = true,
                        Pricebook2Id = stdPriceBook.Id,
                        Product2Id = product.ecomProduct.ProductId,
                        UnitPrice = product.ecomProduct.UnitPrice,
                        CurrencyIsoCode = currencyCode
                    );
                    
                    insert pbe;
                }
                
                //*** create order item and prepare for setting price later
                itemsToSave.add(new OrderItem(OrderId = theOrder.Id, PriceBookEntryId = pbe.Id, Quantity = product.quantity, Coupon__c=product.couponCode));
                mapProductNumber_Price.put(product.ecomProduct.ProductNumber, product.ecomProduct.PriceInfo);
            }
            
            //*** create order items with all prices/discounts
            if (itemsToSave.size() > 0)
            {
                String results = setPriceToOrderItem(itemsToSave, mapProductNumber_Price, theOrder.ShipToContactId);
                if (results != null)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, results));
            }
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
        }   
       
    } //*** end of "addItemsToOrder"

    @future(callout=true)
    public static void createSAPContractsFuture(Set<Id> orderIds){
       if(test.isrunningTest() && trgHndlrIECInvoice_tst.stopCallout <> null && trgHndlrIECInvoice_tst.stopCallout)
       return;
        createSAPContracts(orderIds);
    }
    
    //Create Contract in SAP when Order content no shippable products
    public static void createSAPContracts(Set<Id> orderIds)
    {
        OrderItemCharge_Sel chargeSelector = new OrderItemCharge_Sel();
        Product_Sel productSelector = new Product_Sel();
        Integer i1;
        Order_Svc exe = new Order_Svc();
        Map<Integer, List<Id>> mapContractIdx_OrderItemId = new Map<Integer, List<Id>>();
        List<OrderItem> lstOrderItemToUpdate = new List<OrderItem>();
        Boolean isContractCreated;
        String strContractNumber;
        Map<String, String> mapCountry_ProfitCenter = new Map<String, String>();

        //*** get orders to send to contract interface
        List<Order> lstOrder = Order_Sel.getOrderForContract(orderIds);
        Set<Id> setProductId = new Set<Id>();
        Set<Id> setOrderItemId = new Set<Id>();
        for (i1 = lstOrder.size() -1; i1 >= 0; i1--)
            if (lstOrder[i1].OrderItems.size() == 0)
                //*** no order item -> skip
                lstOrder.remove(i1);
            else
                //*** has order item(s) -> prepare to get product information and discounts
                for (OrderItem oi : lstOrder[i1].OrderItems)
                {
                    setProductId.add(oi.Product__c);
                    setOrderItemId.add(oi.Id);
                    if (oi.IEC_Override_Profit_Center__c == true && lstOrder[i1].BillTo_Location__r.ISO_Country_Code__c != null)
                        mapCountry_ProfitCenter.put(lstOrder[i1].BillTo_Location__r.ISO_Country_Code__c, null);
                }
        if (lstOrder.size() == 0)
            return;

        if (mapCountry_ProfitCenter.size() > 0)
            for (IATA_ISO_Country__c c : IATAIsoCountryDAO.getIsoCountryByIsoCodes(mapCountry_ProfitCenter.keySet()))
                mapCountry_ProfitCenter.put(c.ISO_Code__c, c.Profit_Center__c);

        //*** get product information and discount for order items sending to interface
        Map<Id, Product2> mapProductId_Info = productSelector.getProductById(setProductId);
        Map<Id, List<Order_Item_Charge__c>> mapOrderItemId_Discount = chargeSelector.getChargesByOrerItem(setOrderItemId);
        
        //*** build list of contracts to send
        List<iataComXiSalesforceOtcWid5600Sales3.Contract_element> lstContract = new List<iataComXiSalesforceOtcWid5600Sales3.Contract_element>();
        for (Order ord : lstOrder)
            exe.prepareSAPContracts(lstContract, mapContractIdx_OrderItemId, ord, mapProductId_Info, mapOrderItemId_Discount, mapCountry_ProfitCenter.get(ord.BillTo_Location__r.ISO_Country_Code__c));
//system.debug('lstContract: ' + lstContract);
        //*** send contracts to SAP if applicable
        if (lstContract.size() > 0)
        {
            //*** prepare callout header
            iataComXiSalesforceOtcWid5600Sales3.HTTPS_Port request = new iataComXiSalesforceOtcWid5600Sales3.HTTPS_Port(); 
            if (request.inputHttpHeaders_x == null)
                request.inputHttpHeaders_x = new Map<String,String>(); 
            request.inputHttpHeaders_x.put('Authorization', Utility.getSAPauthorization());
            request.timeout_x = Utility.getIntegerSetting('SAP_CALL_TIMEOUT');
            request.endpoint_x = Utility.fixEndpointDomain(request.endpoint_x);

            //*** callout to create contracts
            List<iataComXiSalesforceOtcWid5600Sales3.Response_element> lstResponse = request.SI_SalesForce_SalesContract_OB(lstContract);
            
            system.debug('Contract Request:: ' + JSON.serialize(lstContract));
            system.debug('Contract Response:: ' + JSON.serialize(lstResponse));

            //*** check results -> lstContract and lstResponse are corresponding each other
            for (i1 = 0; i1 < lstContract.size(); i1++)
            {
                //*** check if contract is created
                isContractCreated = false;
                for (iataComXiSalesforceOtcWid5600Sales3.Return_element responseItem : lstResponse[i1].Return_x)
                    if (responseItem.Type_x == 'S' && responseItem.MsgId == 'V1' && responseItem.Parameter == 'SALES_HEADER_IN' &&
                        responseItem.Message.containsIgnoreCase('has been saved'))
                    {
                        //*** contract is created -> extract contract number
                        strContractNumber = responseItem.Message;
                        strContractNumber = strContractNumber.left(strContractNumber.indexOfIgnoreCase('has been saved')).trim();
                        strContractNumber = strContractNumber.substring(strContractNumber.lastIndexOf(' ') + 1);

                        //*** prepare to update all order items attached to contract
                        for (Id ordItemId : mapContractIdx_OrderItemId.get(i1))
                            lstOrderItemToUpdate.add(new OrderItem(Id=ordItemId, SAP_Contract_Number__c=strContractNumber));
                        
                        //*** indicate contract is created and end of checking for contract
                        isContractCreated = true;
                        break;
                    }
//system.debug(String.valueOf(lstResponse[i1].Return_x));
                
                //*** log error when contract is not created
                if (!isContractCreated)
                    if (!System.isFuture() && !System.isBatch() && !System.isScheduled() && !System.isQueueable())
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(lstResponse[i1].Return_x)));
                    else
                        IECErrorLogger.logApexError('Order_Svc.createSAPContracts'
                                                  , 'Contract is not created for order ' + lstContract[i1].Header.ZuoraInv + '\n\n' + lstContract[i1]
                                                  , String.valueOf(lstResponse[i1].Return_x), true);
            }

            //*** update order items having contracts created
            if (lstOrderItemToUpdate.size() > 0)
                update lstOrderItemToUpdate;
        } //*** end of IF for callout
    } //*** end of "createSAPContracts"


    //Create the SAP Contract for interface
    void prepareSAPContracts(List<iataComXiSalesforceOtcWid5600Sales3.Contract_element> lstContract, Map<Integer, List<Id>> mapContractIdx_OrderItemId
                           , Order ord, Map<Id, Product2> mapProductId_Info, Map<Id, List<Order_Item_Charge__c>> mapOrderItemId_Discount, String strRegionalProfitCenter)
    {
        iataComXiSalesforceOtcWid5600Sales3.Contract_element contract = null;
        iataComXiSalesforceOtcWid5600Sales3.Header_element contractHeader;
        iataComXiSalesforceOtcWid5600Sales3.Address_element contractAddress;
        iataComXiSalesforceOtcWid5600Sales3.Item_element contractItem;
        iataComXiSalesforceOtcWid5600Sales3.Discounts_element itemDiscount;
        Product2 product;
        Integer intContractNumber = 0;

        //*** additional information is to add/change when customer master is implemented
        for (OrderItem ordItem : ord.OrderItems)
        {
            product = mapProductId_Info.get(ordItem.Product__c);
            
            //Validate its contrat product 
            //if(!product.Use_Contract_when_ordered__c) continue;
            
            contract = new iataComXiSalesforceOtcWid5600Sales3.Contract_element();
            lstContract.add(contract);
            mapContractIdx_OrderItemId.put(lstContract.size() - 1, new List<Id>());
            intContractNumber += 1;
            
            contractHeader = new iataComXiSalesforceOtcWid5600Sales3.Header_element();
            contract.Header = contractHeader;
            contractHeader.DocType        = product.IEC_SAP_DocType__c;
            /* Commented as part of ECOM-495: DEV- Modify contract interface for sales area
            contractHeader.SalesOrg       = product.SAP_SalesOrg__c;
            contractHeader.DistChan       = product.SAP_Sales_Channel_Code__c;
            contractHeader.Division       = product.SAP_Division_Code__c;
            */
            contractHeader.OrderReason    = product.SAP_Contract_OrderReason__c;
            contractHeader.EmpResp        = product.IEC_SAP_EmpResp__c;
            //contractHeader.SalesOffice    = ord.Account.Sales_Office__c;
            contractHeader.ContractNumber = ord.OrderNumber + '_' + intContractNumber;
            contractHeader.BillTo         = ord.BillToContact_Partner_Number__c;
            contractHeader.ContactPerson  = ord.BillToContact_Name__c;
            contractHeader.ZuoraInv       = String.valueOf(ord.Id).left(15);
            contractHeader.PODate         = ord.EffectiveDate;
            contractHeader.Name           = ord.BillToContact_Name__c;
            contractHeader.CustomerPO     = ord.PoNumber;
            contractHeader.ContractStart  = (ordItem.IEC_Contract_Start_Date__c != null && ordItem.IEC_Contract_End_Date__c != null ? ordItem.IEC_Contract_Start_Date__c : ord.EffectiveDate);
            contractHeader.ContractEnd    = (ordItem.IEC_Contract_Start_Date__c != null && ordItem.IEC_Contract_End_Date__c != null ? ordItem.IEC_Contract_End_Date__c : ordItem.Effective_End_Date__c);
            contractHeader.DocCurr        = ord.CurrencyIsoCode;
            contractHeader.PayMethod      = getSAPPaymentType(ord.Payment_Type__c);
            contractHeader.PayTerms       = ord.Account.Payment_Term__c;
            contractHeader.TextPrint      = ord.Invoice_Text__c;
            contractHeader.SoldTo         = ord.SoldToAccount_Partner_Number__c;
            contractHeader.ShipTo         = ord.ShipToContact_Partner_Number__c;
            
            contractAddress = new iataComXiSalesforceOtcWid5600Sales3.Address_element();
            contract.Address = contractAddress;
            //contractAddress.BillingAddress      = Utility.truncate(ord.BillingStreet, 35); 
            //contractAddress.BillingCity         = Utility.truncate(ord.BillingCity, 35);
            //contractAddress.BillingPostalCode   = Utility.truncate(ord.BillingPostalCode, 9);
            //contractAddress.BillingCountry      = Utility.truncate(ord.BillingCountryCode__c, 2);
            //contractAddress.BillingState        = Utility.truncate(ord.BillingStateCode_SAP__c, 2);
            //contractAddress.VATRegId            = ord.BillToContact_VAT_Number__c;
            contractAddress.BillingAddress      = Utility.truncate(ord.BillTo_Location__r.Street__c, 35); 
            contractAddress.BillingCity         = Utility.truncate(ord.BillTo_Location__r.City__c, 35);
            contractAddress.BillingPostalCode   = Utility.truncate(ord.BillTo_Location__r.ZipCode__c, 9);
            contractAddress.BillingCountry      = Utility.truncate(ord.BillTo_Location__r.ISO_Country_Code__c, 2);
            contractAddress.BillingState        = ((ord.BillTo_Location__r.IEC_Valid_SAP_State__c != true) ? '' : Utility.truncate(ord.BillTo_Location__r.ISO_State_Code_SAP__c, 3));
            contractAddress.VATRegId            = ord.BillTo_Location__r.VAT_Number__c;
            //contractAddress.ShippingContactName = ord.ShipToContact_Name__c;
            //contractAddress.ShippingAddress     = Utility.truncate(ord.ShippingStreet, 35); 
            //contractAddress.ShippingCity        = Utility.truncate(ord.ShippingCity, 35);
            //contractAddress.ShippingPostalCode  = Utility.truncate(ord.ShippingPostalCode, 9);
            //contractAddress.ShippingCountry     = Utility.truncate(ord.ShippingCountryCode__c, 2);
            //contractAddress.ShippingState       = Utility.truncate(ord.ShippingStateCode_SAP__c, 2);
            
            contract.Item = new List<iataComXiSalesforceOtcWid5600Sales3.Item_element>();

            //*** build link between contract and order item for later update
            mapContractIdx_OrderItemId.get(lstContract.size() - 1).add(ordItem.Id);

            //*** add contract items with discounts
            contractItem = new iataComXiSalesforceOtcWid5600Sales3.Item_element();
            contract.Item.add(contractItem);
            if (ordItem.SAP_Product_Number__c != null && ordItem.SAP_Product_Number__c.isNumeric())
                contractItem.Material  = '0'.repeat(18 - ordItem.SAP_Product_Number__c.length()) + ordItem.SAP_Product_Number__c;
            else
                contractItem.Material  = ordItem.SAP_Product_Number__c;
            contractItem.MatDesc       = product.Name;
            contractItem.PrftCtr       = ((ordItem.IEC_Override_Profit_Center__c == true && strRegionalProfitCenter != null) ? strRegionalProfitCenter : product.IEC_SAP_ProfitCenter__c);
            if (ordItem.Setup_Fee__c != null && ordItem.Setup_Fee__c != 0)
            {
                contractItem.Quantity  = '1';
                contractItem.UnitPrice = String.valueOf(ordItem.SubTotal__c);
                system.debug('contractItem.UnitPrice ' + contractItem.UnitPrice);
            }
            else
            {
                Decimal decNumber = ordItem.UnitPrice.stripTrailingZeros(); //ENHC0011664 start
                if(decNumber.scale() >= 3){
                    contractItem.Quantity = '1';
                    contractItem.UnitPrice = String.valueOf(ordItem.SubTotal__c);  //ENHC0011664 end 
                }
                else{
                    contractItem.Quantity  = String.valueOf(ordItem.Quantity);
                    contractItem.UnitPrice = String.valueOf(ordItem.UnitPrice);
                
                }
                
            }
            contractItem.UnitPriceCurr = ord.CurrencyIsoCode;
            contractItem.DateFrom      = (ordItem.IEC_Contract_Start_Date__c != null && ordItem.IEC_Contract_End_Date__c != null ? ordItem.IEC_Contract_Start_Date__c : ord.EffectiveDate);
            contractItem.DateTo        = (ordItem.IEC_Contract_Start_Date__c != null && ordItem.IEC_Contract_End_Date__c != null ? ordItem.IEC_Contract_End_Date__c : ordItem.Effective_End_Date__c);

            contractItem.Discounts = new List<iataComXiSalesforceOtcWid5600Sales3.Discounts_element>();
            if (mapOrderItemId_Discount.containsKey(ordItem.Id))
            {
                //*** for orders created from portal
                for (Order_Item_Charge__c discount : mapOrderItemId_Discount.get(ordItem.Id))
                {
                    itemDiscount = new iataComXiSalesforceOtcWid5600Sales3.Discounts_element();
                    itemDiscount.DiscountType = discount.Discount_Type__c + 'Discount_' + ((discount.Discount_Amount__c != null) ? 'dollars' : 'percentage');
                    itemDiscount.DiscountValue = (discount.Discount_Amount__c != null) ? (Math.abs(discount.Discount_Amount__c) / ordItem.Quantity) : discount.Discount_Percentage__c;
                    if (itemDiscount.DiscountValue != null && itemDiscount.DiscountValue > 0)
                        contractItem.Discounts.add(itemDiscount);
                }
            }
            else if (ordItem.Discount__c != null && ordItem.Discount__c != 0)
            {
                //*** for orders created from Zuora invoices
                itemDiscount = new iataComXiSalesforceOtcWid5600Sales3.Discounts_element();
                itemDiscount.DiscountType = 'Discount_dollars';
                itemDiscount.DiscountValue = Math.abs(ordItem.Discount__c) / ((ordItem.Setup_Fee__c != null && ordItem.Setup_Fee__c != 0) ? 1 : ordItem.Quantity);
                contractItem.Discounts.add(itemDiscount);
            }
            if (contractItem.Discounts.size() == 0)
                contractItem.Discounts = null;
        } //*** end of FOR
    } //*** end of "prepareSAPContracts"

    
    /****************************************************************************************************
    Created by Kevin Ky 2015-09-23
        Prevent Order deletion with some status
    ****************************************************************************************************/
    public static void preventDeletion(List<Order> oldOrderList){
        for(Order ord : oldOrderList){
            //Get the list of status to prevent the deletion
            List<String> statusList = getStatusToPreventDeletion();
            Set<String> statusSet = new Set<String>(statusList);
            //Show the error message
            if(!statusSet.contains(ord.Status)) ord.AddError(String.format(Label.Order_prevent_deletion_message,new String[]{'Order',ord.Status}));
        }
    }
    
    /****************************************************************************************************
    Created by Kevin Ky 2015-09-30
        Prevent some Order fields modification at some Status
    ****************************************************************************************************/
    public static void preventModification(Map<Id, Order> newMap,Map<Id, Order> oldMap){
        if (System.isFuture() || System.isBatch() || System.isScheduled())
            return;
        
        //Get the list of Status that some modification are not allows
        set<String> orderStatus = new set<String>(getStatusToPreventModification());
        set<String> FieldsToForbidModification = new set<String>();
        
        Set<String> orderFieldsAllowModification = new set<String>();
        List<String> lstFields = Utility.getSeqTextSetting('Order fields to allow modification',',').split(',');
        for(String str : lstFields){
            orderFieldsAllowModification.add(str.toLowerCase());
        }
        

        map<String,String> orderFields = Utility.getOrderLabelByApiName();
        for(String field:orderFields.keySet()){
            if(!orderFieldsAllowModification.contains(field)){
                FieldsToForbidModification.add(field);
            }
        }

        //Get the list of field that do not allows modifications
        //set<String> orderFields = new set<String>(Utility.getOrderFieldsToForbidModification());
        Id profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        for(Order ord : newMap.values()){
            List<String> userProfiles = getUserProfileAllowOrderModification();
            set<String> profiles = new set<String>(userProfiles);
            if(!profiles.contains(profileName)){
                Order oldOrder = oldMap.get(ord.Id);
                if(!orderStatus.contains(oldOrder.Status)){
                    //allows some field to be modified
                    for(String field : FieldsToForbidModification){
                        if(newMap.get(ord.Id).get(field) != oldMap.get(ord.Id).get(field) ){
                            ord.AddError(' ' + Label.Order_prevent_modification_message);
                            break;
                        }
                    }
                }
            }
        }
        
    }

    /**

        Get the Email Template Id by Developer Name.

    */
    public static Id getEmailTemplateByDeveloperName(String emailTemplateDeveloperName) {
        List<EmailTemplate> emailTemplateList = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = :emailTemplateDeveloperName];
        Id emailTemplateId = null;

        if (emailTemplateList != null && emailTemplateList.isEmpty() == false) {
            EmailTemplate emailTemplate = emailTemplateList.get(0);

            if (emailTemplate != null) {
                emailTemplateId = emailTemplate.Id;
            }
        }

        return emailTemplateId;
    }

    /**
        Send email notification when credit card payment has been declined or failed.

    */
    public static void sendEmailWhenPaymentDeclined(Map<Id,Order> newMap, Map<Id,Order> oldMap) {
        Integer maxEmails = Utility.getIntegerSetting('Email batch max value');
        List<Mail_DTO> emailList = new List<Mail_DTO>();
        Mail_DTO clientMail;
        Id emailTemplateId = getEmailTemplateByDeveloperName(Utility.getTextSetting('Order payment err template for client'));

        System.debug('maxEmails: ' + maxEmails);
        System.debug('emailTemplateId: ' + emailTemplateId);

        if (emailTemplateId != null) {
            for (Order order : newMap.values()) {
                Order oldOrder = oldMap.get(order.Id);
                
                System.debug('orderId: ' + order.Id + ', Status: ' + order.Status + ', order.Status[old]: ' + (oldOrder != null ? oldOrder.Status : 'NULL'));

                if (order.Status == 'Payment Failure' && oldOrder != null && oldOrder.Status != order.Status) {
                    Set<String> emails = new Set<String>();

                    clientMail = new Mail_DTO();
                    
                    clientMail.whatId = order.Id;
                    clientMail.templateId = emailTemplateId;
                    clientMail.orgWideEmailAddressId = Utility.getTextSetting('Ecom OrgWideEmailAddressId for notif');
                    clientMail.recipients = new List<String>();

                    if (order.BillToContact_Email__c != null) {
                        emails.add(order.BillToContact_Email__c);
                    }

                    if (order.ShipToContact_Email__c != null) {
                        emails.add(order.ShipToContact_Email__c);
                    }

                    System.debug('Adding recipient email(s): ' + emails);

                    if (emails.size() > 0) {
                        clientMail.recipients.addAll(emails);

                        emailList.add(clientMail);
                    }
                }
            }

            if(emailList.size() > 0){
                if(emailList.size() > maxEmails){
                    //Sending email by batch of maxEmails size
                    List<List<Mail_DTO>> listOfMailsToSend = new List<List<Mail_DTO>>();
                    Integer  i = 0;
                    Integer j = 0;

                    for (Mail_DTO mail : emailList){
                        if (j == 0) {
                            listOfMailsToSend.add(new List<Mail_DTO>{mail});
                        } else if (j < maxEmails) {
                            listOfMailsToSend[i].add(mail);
                        }

                        j++;

                        if (j == maxEmails) {
                            j = 0;
                            i++;
                        }
                    }

                    for (List<Mail_DTO> lstMail : listOfMailsToSend) {
                        System.debug('Sending bulkEmails');

                        Utility.sendBulkEmails(lstMail);
                    }
                } else {
                    System.debug('Sending bulkEmails');

                    Utility.sendBulkEmails(emailList);
                }
            }
        }
    }

    
    /****************************************************************************************************
    Created by Kevin Ky 2015-10-08
        Send an notification when a product is sold
    ****************************************************************************************************/
    public static void sendEmailWhenOrderIsSold(Map<Id, Order> newMap, Map<Id, Order> oldMap)
    {

        set<Id> orderIds = new set<Id>();
        set<String> paymentMethod = new set<String>();
        paymentMethod.add('Bank Transfer');paymentMethod.add('Check');paymentMethod.add('Credit Card');

        //map of Order sold Id
        map<Id,Boolean> orderId_Sold = new map<Id,Boolean>();
        map<Id,List<Product_Email_Notification__c>> productIdByLstEmails;// = new map<Id,List<Product_Email_Notification__c>>();
        Map<Id,List<OrderItem>> orderId_lstOrderItems = new Map<Id,List<OrderItem>>();
        
        for(Order order : newMap.values()){
            if(order.Is_Paid__c && oldMap.get(order.Id).Is_Paid__c != order.Is_Paid__c){ // && !paymentMethod.contains(order.Payment_Type__c)
                orderIds.add(order.Id);
                orderId_Sold.put(order.Id,true);
            }

            //Send notification to Client for bank transfer payment method or Check
            if(paymentMethod.contains(order.Payment_Type__c)){
                if(order.Status != oldMap.get(order.Id).Status && order.Status == IECConstants.ORDER_STATUS_READY_FOR_SAP){
                    orderIds.add(order.Id);
                    orderId_Sold.put(order.Id,false);
                }
            }

        }

        //Get products ids in a order
        set<Id> productIds = new set<Id>();
        Map<Id, Set<Id>> productIdsByOrder = new Map<Id, Set<Id>>();
        if(orderIds.size () > 0){
            productIdsByOrder = new OrderItem_Sel().getProductIdsByOrder(orderIds);
            if(productIdsByOrder != null && productIdsByOrder.size() > 0){
                for(Id orderId : productIdsByOrder.keySet()){
                    productIds.addAll(productIdsByOrder.get(orderId));
                }
            }

            //orderId_lstOrderItems = new OrderItem_Sel().getOrderItemsForContract(orderIds);
            orderId_lstOrderItems = new OrderItem_Sel().getOrderItems(orderIds);
        }
        
        //When a product is sold send notification to the list of related product email notification object records
        //Get Product by Id
        set<Id> userIds = new set<Id>();
        Map<Id,Product2> products = new Map<Id,Product2>();
        if(productIds.size() > 0){
            //Get the related list of internat and external user for a product
            productIdByLstEmails = ProductEmailNotification_Sel.getProdIdByLstEmailNotif(productIds);
            
            products = new product_Sel().getProductById(productIds);
            for(Product2 prd : products.values()){
                //Get Product Manager and Alternate product Manager
                /*userIds.add(prd.Product_Manager_lookup__c);
                if(prd.Alternate_Product_Manager__c != null)
                    userIds.add(prd.Alternate_Product_Manager__c);*/

                //Add the Internal user for notification
                if(productIdByLstEmails.size() > 0){
                    List<Product_Email_Notification__c> lstProdEmailNotif = productIdByLstEmails.get(prd.Id);
                    if(lstProdEmailNotif != null && lstProdEmailNotif.size() > 0){
                        for(Product_Email_Notification__c pen : lstProdEmailNotif){
                            if(pen.Internal_user__c != null){ userIds.add(pen.Internal_user__c); }
                        }
                    }
                    
                }
            }
        }

        

        //get Manager and alternate manager information
        Map<Id,User> userId_User = new Map<Id,User>([SELECT id,Email From User where id in :userIds]);
        
        Integer maxEmails = Utility.getIntegerSetting('Email batch max value');

        List<Mail_DTO> lstmails = new List<Mail_DTO>();
        for(Id orderId : orderIds){
            Order order = newMap.get(orderId);

            //get productIds 
            set<Id> prodIds = productIdsByOrder.get(order.Id);

            String targetObjectId;

            //Check if the Order is sold or not
            Boolean isSold = orderId_Sold.get(order.Id);

            //Send Notification to Client
            Mail_DTO clientMail = new Mail_DTO();
            clientMail.whatId = order.Id;
            
            if(isSold)
            {
                clientMail.templateId = Utility.getTextSetting('Order sold templateId for client');
            }else{
                clientMail.templateId = Utility.getTextSetting('Order in process templateId for client');
            }

            clientMail.orgWideEmailAddressId = Utility.getTextSetting('Ecom OrgWideEmailAddressId for notif');
            clientMail.recipients = new list<String>();
            //clientMail.recipients.add(order.ShipToContact_Email__c);
             set<String> emails = new set<String>();
            if(order.BillToContact_Email__c != null)
                emails.add(order.BillToContact_Email__c);
            if(order.ShipToContact_Email__c != null)
                emails.add(order.ShipToContact_Email__c);
            if(emails.size() > 0){
                clientMail.recipients.addAll(emails);
                lstmails.add(clientMail);
            }

            /*clientMail.recipients.add(order.ShipToContact_Email__c);
            if(order.ShipToContact_Email__c != null)
                lstmails.add(clientMail);*/

            //Send notification for Special instructions for shipping and delivery
            if(order.Has_Shipping_Instruction__c){
                Mail_DTO specialShippingInstruction = new Mail_DTO();
                specialShippingInstruction.whatId = order.Id;
                specialShippingInstruction.templateId = Utility.getTextSetting('Order templateId for special shipping');
                specialShippingInstruction.recipients = new List<String>();
                //Add the email addresses to be notified
                List<String> specialShippingInstructionEmails = Utility.getTextSettingToArray('Special shipping instruction Emails',',');
                specialShippingInstruction.recipients.addAll(specialShippingInstructionEmails);
                lstmails.add(specialShippingInstruction);
            }

            //Send email to the product manager and alternate manager if the product is sold
            if(isSold)
            { 
                
                List<OrderItem> listOrderItem = orderId_lstOrderItems.get(orderId);
                
                //for(Id prdId : prodIds)
                if(listOrderItem != null && listOrderItem.size() > 0){
                    for(OrderItem oi : listOrderItem)
                    {
                        Product2 prod = products.get(oi.Product__c);
                        
                        set<Id> userIdToSendNotif = new set<Id>();
                        set<String> lstRecipients = new set<String>();

                        //Add the Related internal and external users to Notified
                        List<Product_Email_Notification__c> lstprdEmailNotif = productIdByLstEmails.get(prod.Id);
                        if(lstprdEmailNotif != null && lstprdEmailNotif.size() > 0){
                            for(Product_Email_Notification__c pen : lstprdEmailNotif){
                                //Add the the internal users to the list of SFDC users to notified
                                if(pen.Internal_user__c != null){
                                    //userIdToSendNotif.add(pen.Internal_user__c);
                                    User internal = userId_User.get(pen.Internal_user__c);
                                    lstRecipients.add(internal.Email);
                                }
                                //Add the external email address to notified
                                if(pen.External_email_address__c != null){ lstRecipients.add(pen.External_email_address__c); }
                            }
                        }

                        //Add the administrator email
                        /*list<String> adminEmails = Utility.getAdminEmails();
                        lstRecipients.addAll(adminEmails);*/
                        
                        //For external emails
                        if(lstRecipients.size() > 0){
                            List<String> recipients = new List<String>(lstRecipients);
                            Mail_DTO mail = newMailDTO(order.ShipToContactId,oi.Id,recipients);//prdId
                            lstmails.add(mail);
                        }
                        
                    }
                }
                
            }
             
        }

        if(lstmails.size() > 0){
            if(lstmails.size() > maxEmails){
                
                //Sending email by batch of maxEmails size
                List<List<Mail_DTO>> listOfMailsToSend = new List<List<Mail_DTO>>();
                integer  i = 0, j = 0;
                for(Mail_DTO mail : lstmails){
                    if(j == 0)
                        listOfMailsToSend.add(new List<Mail_DTO>{mail});
                    else if(j < maxEmails)
                        listOfMailsToSend[i].add(mail);
                    j++;
                    if(j == maxEmails){
                        j = 0; i++;
                    }
                }

                for(List<Mail_DTO> lstMail : listOfMailsToSend)
                    Utility.sendBulkEmails(lstMail);
                
            }else{
                Utility.sendBulkEmails(lstmails);
            }
        }
         
    }

    public static Mail_DTO newMailDTO(Id targetId, id whatid,list<String> recipients){
        Mail_DTO mail = new Mail_DTO();
        //mail.targetObjectId = targetId; //order.ShipToContactId;
        //WhatId is not available for sending emails to UserIds.
        mail.whatId = whatid;
        mail.templateId = Utility.getTextSetting('Order sold templateId for managers');
        mail.orgWideEmailAddressId = Utility.getTextSetting('Ecom OrgWideEmailAddressId for notif');
        mail.recipients = new List<String>();
        if(recipients != null && recipients.size() > 0){
            mail.recipients.addAll(recipients);
        }
        
        return mail;
    }
    
    /****************************************************************************************************
    Created by Kevin Ky 2015-09-24
        Creates a subscription per order for the a customer and payment method
    ****************************************************************************************************/
    //Zuora Subscribe that return null for success or error message
    public static string orderSubscription(set<Id> orderIds,Map<Id,IECZuoraHelper.PaymentMethod> orderId_paymentMethod,Map<Id,String> orderId_paymentType){
        try{
            Map<Id,Zuora.zApi.SubscribeResult> subscribeResults = subscribe(orderIds,orderId_paymentMethod,orderId_paymentType);
            if (subscribeResults == null)
                return Label.Order_transaction_failed_message;

            Map<String,ZuoraUtil.zAccountPaymentMethod> orderId_zAccountPaymentMethod = new Map<String,ZuoraUtil.zAccountPaymentMethod>();
            
            for(Id orderId : orderId_paymentType.keySet()){
                String paymentType = orderId_paymentType.get(orderId);
                //if (paymentType == IECConstants.PaymentThresholdType_BillMeLater)
                    //paymentType = 'Other';
                ZuoraUtil.zAccountPaymentMethod zapm = new ZuoraUtil.zAccountPaymentMethod();
                zapm.zPaymentMethodName = paymentType;
                zapm.zPaymentMethod = zuoraPaymentId(paymentType);
                orderId_zAccountPaymentMethod.put(orderId,zapm);
            }

            system.debug('subscribeResults ' + subscribeResults);
            system.debug('orderId_zAccountPaymentMethod ' + orderId_zAccountPaymentMethod);
            Map<Id,String> orderItemsResponse = parseSubscribeResult2UpdateItems(subscribeResults,orderId_zAccountPaymentMethod);
            system.debug('orderItemsResponse ' + orderItemsResponse);

            for(Id ordItem : orderItemsResponse.keySet()){
                String msg = orderItemsResponse.get(ordItem);
                if(msg != 'Success'){
                    return Label.Order_transaction_failed_message;
                    break;
                }
            }

        }catch(Exception ex){
            //log Subscription exception
            IEC_Error_Log__c errorLog = IECErrorLogger.createErrorLog('Order_Svc/orderSubscription',JSON.serialize(orderIds),ex.getMessage(),ex.getStackTraceString());
            IECErrorLogger.logErrors(new list<IEC_Error_Log__c>{errorLog});
            return ex.getMessage();
        }
        return null;
    }

    public static String zuoraPaymentId(String paymentType){
        String pType = '';

        if (paymentType == IECConstants.PaymentThresholdType_ICH)
            //pType = Utility.getTextSetting('Zuora ICH PaymentMethod ID');
            pType = IECConstants.PaymentMethod_ICH_ZuoraID;
        else if (paymentType == IECConstants.PaymentThresholdType_BankTransfer)
            //pType = Utility.getTextSetting('Zuora Bank Transfer PaymentMethod ID');
            pType = IECConstants.PaymentMethod_BankTransfer_ZuoraID;
        else if (paymentType == IECConstants.ORDER_STATUS_CHECK)
            //pType = Utility.getTextSetting('Zuora Check PaymentMethod ID');
            pType = IECConstants.PaymentMethod_Check_ZuoraID;
        else if (paymentType == IECConstants.PaymentThresholdType_CreditCard)
            //pType = Utility.getTextSetting('Zuora CreditCard Deferred PaymentMeth');
            pType = IECConstants.PaymentMethod_Other_ZuoraID;
        else if (paymentType == IECConstants.PaymentThresholdType_BillMeLater)
            pType = IECConstants.PaymentMethod_Other_ZuoraID;
            
        /* TODO: Cleanup
        else if(paymentType == IECConstants.ORDER_STATUS_CREDIT_CARD_DEFERRED)
            Utility.getTextSetting('Zuora CreditCard Deferred PaymentMeth');
        */

        return pType;
    }

    public static IECConstants.PaymentType parsePaymentMethodToEnum(String sPmType) {
        if (sPmType == IECConstants.PaymentThresholdType_CreditCard) return IECConstants.PaymentType.CREDIT_CARD;
        else if (sPmType == IECConstants.PaymentThresholdType_BankTransfer) return IECConstants.PaymentType.BANK_TRANSFER;
        else if (sPmType == IECConstants.ORDER_STATUS_CHECK) return IECConstants.PaymentType.CHECK;
        else if (sPmType == IECConstants.PaymentThresholdType_ICH) return IECConstants.PaymentType.ICH;
        else if (sPmType == IECConstants.PaymentThresholdType_BillMeLater) return IECConstants.PaymentType.OTHER;
        else return null;
    }
    
    public static Map<Id,Zuora.zApi.SubscribeResult> subscribe(set<Id> orderIds,Map<Id,IECZuoraHelper.PaymentMethod> orderId_paymentMethod, Map<Id,String> orderId_paymentType){
        /*Map<Id,IECZuoraHelper.PaymentMethod> orderId_paymentMethod 
        Map<Id,String> orderId_paymentType*/
        //Get order by order Id
        list<Order> lstCustomerOrder = Order_Sel.getOrdersById(orderIds);

        Map<Id,Zuora.zApi.SubscribeResult> orderItemId_subscribeResult = new Map<Id,Zuora.zApi.SubscribeResult>();
        
        //Get Order Items
        Map<Id, List<OrderItem>> orderId_orderItems = new OrderItem_Sel().getOrderItems(orderIds);
        
        Map<String,Order> zuoraId_Order = new Map<String,Order>();

        String orderPaymentMethod = '';
        
        //-- Set of AccountIDs
        Set<Id> accountIds = new Set<Id>(); 
        set<Id> orderItemIds = new Set<Id>(); 
        
        //Set of ContactIds
        set<Id> contactIds = new set<Id>();
        set<Id> billToContactIds = new set<Id>();
        
        for(Order customerOrder :lstCustomerOrder)
        {
            accountIds.add(customerOrder.AccountId);
            contactIds.add(customerOrder.BillToContactId);
            contactIds.add(customerOrder.ShipToContactId);

            billToContactIds.add(customerOrder.BillToContactId);
        }
        

        //Get a Map of Bill to account by account Id
        Map<Id,Account> accountId_Account = new Account_Sel().getBillToAndSoldToAccountByAccountId(accountIds);

        //Get a Map of Contact by Id
        Map<Id,Contact> contactId_Contact = Contact_Sel.getContactById(contactIds);

        
        //Get an Order related order items ids
        for(Id orderId : orderId_orderItems.keySet()){
            list<OrderItem> orderItems = orderId_orderItems.get(orderId);
            if(orderItems != null && orderItems.size() > 0){
                for(OrderItem oi : orderItems)
                {
                    
                    //found the order payment metyhod
                    if(orderId_paymentType != null){
                        String payTy = orderId_paymentType.get(orderId);
                        orderPaymentMethod = payTy;
                    }
                    
                    //Don't send to Zuora order items that are not Subscribe to Zuora set to true and payament method is BankTransfer or ICH
                    //if(!oi.IEC_Subscribe_to_Zuora__c && (orderPaymentMethod == IECConstants.PaymentThresholdType_BankTransfer || orderPaymentMethod == IECConstants.PaymentThresholdType_ICH)){
                    //}else{
                    if (oi.IEC_Subscribe_to_Zuora__c == true || orderPaymentMethod == IECConstants.PaymentThresholdType_CreditCard) {
                        orderItemIds.add(oi.Id);
                    }
                }
            }
        }
        
        //Get Product Id Order Item
        Map<Id,Id> orderItemId_ProductId = OrderItem_Sel.getProductIdByOrderItemId(orderItemIds);

        //Get Product by Id
        Map<Id,Product2> productId_product = new Product_Sel().getProductById(new Set<Id>(orderItemId_ProductId.values()));

        //Get the zuora Account information base on the SFDC Account id
        Map<Id,Zuora__CustomerAccount__c> sfAccId_ZcustAccount = CustomerAccount_Sel.getZuoraCustmerAccount(billToContactIds);
        
        //Get the list of discount base on the order items
        Map<Id, List<Order_Item_Charge__c>> orderItemId_listOrderItemCharges = new OrderItemCharge_Sel().getChargesByOrerItem(orderItemIds); 
        
        List<Zuora.zApi.SubscribeRequest> subsRequestLists = new List<Zuora.zApi.SubscribeRequest>();

        //List of Order Item send for Subscribe
        List<OrderItem> OrderItemSend = new list<OrderItem>();

        //Verified in zuora is Account already existe
        map<String,Zuora.zObject> zAccounts = new map<String,Zuora.zObject>();
        Boolean alreadyQueryZAccounts = false;
        
        //Get the List of Zuora Rate Plan Charge Id from orderItem and orderItem charge
        set<String> zRatePlanChargeIds = new set<String>();
        Map<String,String> zRatePlanChargeIds_zModel = new Map<String,String>();
        for(Id orderId : orderId_orderItems.keySet()){
            List<OrderItem> orderItems = orderId_orderItems.get(orderId);
            for(OrderItem oi : orderItems){
                //Add Zuora rate plan charge id from Order ITem level
                zRatePlanChargeIds.add(oi.Zuora_Rate_Plan_Charge_Id__c);

                //Get the list of order item charge
                List<Order_Item_Charge__c> orderITemCharges = orderItemId_listOrderItemCharges.get(oi.Id);
                if(orderITemCharges != null && !orderITemCharges.isEmpty()){
                    for(Order_Item_Charge__c oic : orderITemCharges){
                        zRatePlanChargeIds.add(oi.Zuora_Rate_Plan_Charge_Id__c);
                    }
                }
            }
        }

        //Get the Zuora Pricing model by Zuora Id
        zRatePlanChargeIds_zModel = ProductRatePlanCharge_Sel.getProductRatePlanChargeModelByZuoraId(zRatePlanChargeIds);

        //set Order Items by Order Id that already have subscription and invoices in Zuora
        Map<Id,List<OrderItem>> OrderId_orderItemsExistInZuora;
        Set<Id> setContactIdOfNewZAccount = new Set<Id>(), setOrderItemIdProceeded = new Set<Id>(), setOrderWithTaxSubscription = new Set<Id>();
        Boolean okForStep2 = false, okForSubscription, createNewAccount;
        Product2 product;

        //*** subscribe in 2 possible steps: 1st step for existing ZAccount or create new, 2nd step for subscription requiring new ZAccount in step 1
        for (Integer ixStep = 1; ixStep <= 2; ixStep++)
            if (ixStep == 1 || (ixStep == 2 && okForStep2 == true))
            {
                alreadyQueryZAccounts = false;
                //setContactIdOfNewZAccount.clear();
                OrderItemSend.clear();
                subsRequestLists.clear();
                
                for(Order customerOrder :lstCustomerOrder)
                {
                    List<Zuora.zObject> ratePlanData = new List<Zuora.zObject>(); 
                    list<OrderItem> orderItems = orderId_orderItems.get(customerOrder.Id);
        
                    //Get the Internal Payment type
                    String paymentType = null;
        
                    OrderId_orderItemsExistInZuora = new map<Id,List<OrderItem>>();
                    Decimal totalShipping = 0.00;
                    Decimal totalTax = 0.00;
                    
                    if (ixStep == 1)
                        orderItems.add(null);  //*** to create subscription for shipping & tax
        
                    for(OrderItem orderItem : orderItems)
                    {
                        if (orderItem == null || orderItem.IEC_Subscribe_to_Zuora__c == true || orderPaymentMethod == IECConstants.PaymentThresholdType_CreditCard) {
                            if (orderItem != null)
                            {
                                //*** summarize shipping & tax in order to create a subscription
                                if (orderItem.Handling_charges__c != null)
                                    totalShipping += orderItem.Handling_charges__c;
                                if (orderItem.Freight_Charge__c != null)
                                    totalShipping += orderItem.Freight_Charge__c;
                                if (orderItem.Tax__c != null)
                                    totalTax += orderItem.Tax__c;
                                
                                //*** control to proceed order item only one
                                if (setOrderItemIdProceeded.contains(orderItem.Id))
                                    continue;
                                else
                                    setOrderItemIdProceeded.add(orderItem.Id);
                                
                                product = productId_product.get(orderItemId_ProductId.get(orderItem.Id));
                                
                                OrderItemSend.add(orderItem);
                            }
                            
                            okForSubscription = true;
                            createNewAccount = false;
                            
                            //--- Order Header information          
                            Zuora.zObject acc = new Zuora.zObject('Account');
                            //Set the bill to contact
                            Zuora.zObject billToContact = new Zuora.zObject('Contact');
                            //Set the sold to contact
                            Zuora.zObject soldToContact = new Zuora.zObject('Contact');
                            //Set the payment method
                            Zuora.zObject pm = new Zuora.zObject('PaymentMethod');
                                
                            //Get the Bill to Account and the Sold To Account
                            if(sfAccId_ZcustAccount != null && sfAccId_ZcustAccount.size() > 0 && sfAccId_ZcustAccount.containsKey(customerOrder.BillToContactId))
                            {
                                Zuora__CustomerAccount__c zuoraCustomerAccount = sfAccId_ZcustAccount.get(customerOrder.BillToContactId);
                                
                                acc.setValue('Id',zuoraCustomerAccount.Zuora__Zuora_Id__c);
                                billToContact.setValue('Id', zuoraCustomerAccount.Zuora__BillToId__c);
                                soldToContact.setValue('Id', zuoraCustomerAccount.Zuora__SoldToId__c);   
                                
                                zuoraId_Order.put(zuoraCustomerAccount.Zuora__Zuora_Id__c,customerOrder);
                                
                                if(orderId_paymentType != null && orderId_paymentType.get(customerOrder.Id) != null ){
                                    customerOrder.Payment_Type__c = orderId_paymentType.get(customerOrder.Id);
                                }
            
                                if(customerOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard)
                                {
                                    //For existing payment method
                                    if(orderId_paymentMethod != null && orderId_paymentMethod.containsKey(customerOrder.Id)){
            
                                        IECZuoraHelper.PaymentMethod paymentMethod = orderId_paymentMethod.get(customerOrder.Id);
            
                                        if(paymentMethod != null){
                                            pm = setPaymentMethodWithWrp(paymentMethod);
                                            acc.setValue('DefaultPaymentMethodId',paymentMethod.zId);
                                        }
                                    }
                                    else{
                                        //Set the payment method form zuora customer account
                                        if(String.isNotBlank(zuoraCustomerAccount.Zuora__PaymentMethod_Type__c)){ pm = setPaymentMethod(zuoraCustomerAccount); }
                                    }
                                }
                                else
                                {
                                    if(orderId_paymentMethod != null && orderId_paymentMethod.containsKey(customerOrder.Id)){
                                        IECZuoraHelper.PaymentMethod paymentMethod = orderId_paymentMethod.get(customerOrder.Id);
                                        
                                        if(paymentMethod != null){
                                            pm = setPaymentMethodWithWrp(paymentMethod);
                                            acc.setValue('DefaultPaymentMethodId',paymentMethod.zId);
                                        }
                                    }else if(orderId_paymentType != null && orderId_paymentType.size() > 0){
                                        //Set the payment method from the Order
                                        paymentType = orderId_paymentType.get(customerOrder.Id);
                                        //pm.setValue('Type',paymentType);
                                        if (paymentType == IECConstants.PaymentThresholdType_BillMeLater)
                                            pm.setValue('Type','Other');
                                        else
                                            pm.setValue('Type',paymentType);
                                        // set the default payment method
                                        acc.setValue('DefaultPaymentMethodId', zuoraPaymentId(paymentType));
            
                                    }else{
                                        //pm.setValue('Type',customerOrder.Payment_Type__c);
                                        if (customerOrder.Payment_Type__c == IECConstants.PaymentThresholdType_BillMeLater)
                                            pm.setValue('Type', 'Other');
                                        else
                                            pm.setValue('Type',customerOrder.Payment_Type__c);
                                        acc.setValue('DefaultPaymentMethodId', zuoraPaymentId(customerOrder.Payment_Type__c));
                                    }
                                }
                            }
                            else
                            {
                                //Verified in zuora is Account already existe
                                if(!alreadyQueryZAccounts){
                                    zAccounts = getZuoraAccounts(billToContactIds);
                                    alreadyQueryZAccounts = true;
                                }
            
                                //If the Account existe in Zuora
                                if(zAccounts != null && zAccounts.size() > 0){
                                    
                                    //for(String contactId : zAccounts.keySet()){
                                        
                                        Zuora.zObject zAccount = zAccounts.get(customerOrder.BillToContactId);
                                        
                                        if(zAccount != null){
                                            //Set the Zuora Account, Bill and Sold to Contact
                                            acc.setValue('Id', (String)zAccount.getValue('Id'));
                                            billToContact.setValue('Id', (String)zAccount.getValue('BillToId'));
                                            soldToContact.setValue('Id', (String)zAccount.getValue('SoldToId'));
                                            
                                            //Set the payment method
                                            pm.setValue('Id', (String)zAccount.getValue('DefaultPaymentMethodId'));
                                            createNewAccount = false;
                                            
                                        }else{
                                            createNewAccount = true;
                                        }
                                    //}
                                }
                                else
                                {
                                    //If the Account do not existe in zuora create it
                                    createNewAccount = true;
                                }
            
                                if(createNewAccount && !setContactIdOfNewZAccount.contains(customerOrder.BillToContactId))
                                {
                                    setContactIdOfNewZAccount.add(customerOrder.BillToContactId);
                                    
                                    //Get the Bill To Account
                                    Account billToAccount = accountId_Account.get(customerOrder.AccountId);
                                    
                                    //Get the related Contact for Bill To
                                    Contact contactBillTo = contactId_Contact.get(customerOrder.BillToContactId);
                                    
                                    //Create the PaymentType
                                    //Payment method
                                    String sPaymentMethodId = null;
                                    if(orderId_paymentMethod != null && orderId_paymentMethod.containsKey(customerOrder.Id)){
                                        IECZuoraHelper.PaymentMethod paymentMethod = orderId_paymentMethod.get(customerOrder.Id);
                                        
                                        if(paymentMethod != null){
                                            sPaymentMethodId = paymentMethod.zId;
                                            customerOrder.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;
                                            pm = setPaymentMethodWithWrp(paymentMethod);
                                        }
                                    }
                                    else if(orderId_paymentType != null && orderId_paymentType.size() > 0){
            
                                        customerOrder.Payment_Type__c = orderId_paymentType.get(customerOrder.Id);
    
                                        //For new payment method
                                        pm.setValue('Id',zuoraPaymentId(customerOrder.Payment_Type__c));
                                    }else{} 
                                   
                                    IECConstants.PaymentType ePaymentType = parsePaymentMethodToEnum(customerOrder.Payment_Type__c);
                                    //pm.setValue('Type',customerOrder.Payment_Type__c);
                                    if (customerOrder.Payment_Type__c == IECConstants.PaymentThresholdType_BillMeLater)
                                        pm.setValue('Type', 'Other');
                                    else
                                        pm.setValue('Type',customerOrder.Payment_Type__c);
                                    acc = IECZuoraHelper.createZuoraAccount(billToAccount, contactBillTo, ePaymentType, sPaymentMethodId);
            
                                    //Create new zuora Bill to Contact
                                    billToContact = ZuoraUtil.createZuoraBillToContact(contactBillTo);
                                    
                                    //Get the related Contact for ship To
                                    Contact contactShipTo = contactId_Contact.get(customerOrder.ShipToContactId);
                                    //Create new zuora Ship to Contact
                                    if(contactShipTo != null){
                                        soldToContact = ZuoraUtil.createZuoraSoldToContact(contactShipTo,customerOrder);
                                    }else{
                                        soldToContact = ZuoraUtil.createZuoraBillToContact(contactBillTo);
                                    }
                                }
                                else if(createNewAccount)
                                {
                                    //*** proceed order item in the second step because new customer creation is asked in another order item
                                    if (orderItem != null)
                                    {
                                        setOrderItemIdProceeded.remove(orderItem.Id);
                                        OrderItemSend.remove(OrderItemSend.size() - 1);
                                    }
                                    okForStep2 = true;
                                    okForSubscription = false;
                                }
                            }
                            
                            ratePlanData = new List<Zuora.zObject>();
                            if (okForSubscription)
                            {
                                if (orderItem != null)
                                {
                                    //Get the corresponding charge for the Order Item
                                    List<Order_Item_Charge__c> lstOrderItemCharge = new List<Order_Item_Charge__c>();
                                    if(orderItemId_listOrderItemCharges.containsKey(orderItem.Id)){
                                        lstOrderItemCharge = orderItemId_listOrderItemCharges.get(orderItem.Id);
                                    }
                                    
                                    //Create Rate Plan Data object
                                    ratePlanData = getRatePlanData(orderItem,lstOrderItemCharge,zRatePlanChargeIds_zModel);
                                }
                                else if (!createNewAccount && !setOrderWithTaxSubscription.contains(customerOrder.Id) && (totalShipping > 0 || totalTax > 0))
                                {
                                    setOrderWithTaxSubscription.add(customerOrder.Id);
                                    OrderItemSend.add(new OrderItem(OrderId=customerOrder.Id));
                                    
                                    //*** build rate plan data for shipping & tax
                                    Zuora.zObject rp, rpd, rpc, rpcd;
                                    List<Zuora.zObject> ratePlanCharge = new List<Zuora.zObject>();
                                    if (totalShipping > 0)
                                    {
                                        //*** Shipping rate plan charge
                                        rpc = new Zuora.zObject('RatePlanCharge');
                                        rpc.setValue('ProductRatePlanChargeId', Utility.getTextSetting('Zuora shipping Charge id'));
                                        rpc.setValue('Price', totalShipping);
                                        //rpc.setValue('Quantity', 1);
                                        rpcd = new Zuora.zObject('RatePlanChargeData');
                                        rpcd.setValue('RatePlanCharge', rpc);
                                        //*** Shipping rate plan
                                        rp = new Zuora.zObject('RatePlan');
                                        rp.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora shipping Plan id'));
                                        rpd = new Zuora.zObject('RatePlanData');
                                        rpd.setValue('RatePlan', rp);
                                        rpd.setValue('RatePlanChargeData', new List<Zuora.zObject>{rpcd});
                                        ratePlanData.add(rpd);
                                    }
                                    if (totalTax > 0)
                                    {
                                        //*** Tax rate plan charge
                                        rpc = new Zuora.zObject('RatePlanCharge');
                                        rpc.setValue('ProductRatePlanChargeId', Utility.getTextSetting('Zuora tax Charge id'));
                                        rpc.setValue('Price', totalTax);
                                        //rpc.setValue('Quantity', 1);
                                        rpcd = new Zuora.zObject('RatePlanChargeData');
                                        rpcd.setValue('RatePlanCharge', rpc);
                                        //*** Tax rate plan
                                        rp = new Zuora.zObject('RatePlan');
                                        rp.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora tax Plan id'));
                                        rpd = new Zuora.zObject('RatePlanData');
                                        rpd.setValue('RatePlan', rp);
                                        rpd.setValue('RatePlanChargeData', new List<Zuora.zObject>{rpcd});
                                        ratePlanData.add(rpd);
                                    }
                                }
                                
                                if (ratePlanData != null && ratePlanData.size() > 0)
                                {
                                    //Create subscription for each ORder Item
                                    Zuora.zObject sub = new Zuora.zObject('Subscription');
                                    
                                    //Date activationDate = customerOrder.EffectiveDate;
                                    Date activationDate = Date.today();
                                    
                                    sub.setValue('ContractEffectiveDate', Test.IsRunningTest() ? Zuora.zUtil.getZuoraDate(Date.today()) : Zuora.zUtil.getZuoraDate(activationDate));
                                    sub.setValue('ContractAcceptanceDate', Test.IsRunningTest() ? Zuora.zUtil.getZuoraDate(Date.today()) : Zuora.zUtil.getZuoraDate(activationDate));
                                    //if(customerOrder.Payment_Type__c != IECConstants.PaymentThresholdType_BankTransfer)
                                    if(customerOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard || customerOrder.Payment_Type__c == IECConstants.PaymentThresholdType_ICH)
                                    {
                                        sub.setValue('ServiceActivationDate', Test.IsRunningTest() ? Zuora.zUtil.getZuoraDate(Date.today()) : Zuora.zUtil.getZuoraDate(activationDate));
                                    }
                                    
                                    sub.setValue('InitialTerm', (product.Number_of_months_of_subscription__c != null) ? product.Number_of_months_of_subscription__c : ZuoraUtil.SUBSCRIPTION_TERM);
                                    sub.setValue('RenewalTerm', (product.Number_of_months_of_subscription__c != null) ? product.Number_of_months_of_subscription__c : ZuoraUtil.SUBSCRIPTION_TERM);
                                    
                                    //AutoRenew just for electronic product
                                    //if(orderItem.Is_Electronic_Product__c && !orderItem.IEC_Subscribe_to_Zuora__c){
                                    if(orderItem != null && orderItem.Is_Electronic_Product__c){ sub.setValue('AutoRenew', orderItem.Auto_Renew__c); }
                                    
                                    //Generate a single invoice for all subscriptions.
                                    sub.setValue('IsInvoiceSeparate', false);
                                    
                                    //Set the order Id in Zuora
                                    sub.setValue('OrderId__c', customerOrder.Id);
                                    
                                    //Set the orderItem Id in Zuora
                                    if (orderItem != null)
                                        sub.setValue('OrderItemId__c', orderItem.Id);
                                    
                                    // Set the source of the Subscription Creation
                                    sub.setValue('Source__c', 'Salesforce');
                                    
                                    //subscription data
                                    Zuora.zApi.SubscriptionData sd = new Zuora.zApi.SubscriptionData();
                                    sd.Subscription = sub;
                                    sd.RatePlanData = ratePlanData;
                                    
                                    //subscription options
                                    Zuora.zApi.SubscribeOptions so = new Zuora.zApi.SubscribeOptions();
                                    so.GenerateInvoice = true;
                                    so.ProcessPayments = false;
                                    
                                    so.SubscribeInvoiceProcessingOptions = new Zuora.zApi.SubscribeInvoiceProcessingOptions();
                                    so.SubscribeInvoiceProcessingOptions.InvoiceTargetDate = Zuora.zUtil.getZuoraDate(activationDate); //IECZuoraHelper.getCurrentDate(); customerOrder.EffectiveDate
                                    so.SubscribeInvoiceProcessingOptions.InvoiceDate = Zuora.zUtil.getZuoraDate(activationDate); //IECZuoraHelper.getCurrentDate();
                                    
                                    //subscribe request
                                    Zuora.zApi.SubscribeRequest subsRequest = new Zuora.zApi.SubscribeRequest();
                                    
                                    subsRequest.ZAccount = acc;
                                    subsRequest.BillToContact = billToContact;
                                    subsRequest.SoldToContact = soldToContact;
                                    subsRequest.SubscribeOptions = so;
                                    
                                    subsRequest.SubscriptionData = sd;
                                    
                                    if(customerOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard){
                                        subsRequest.PaymentMethod = pm;
                                    }
                                    
                                    subsRequestLists.add(subsRequest);
                                }
                            }
                            //-- Wait 1 s 
                            //Integer start = System.Now().millisecond();
                            //while(System.Now().millisecond()< start+3000){}
                        }
                    }
                }
                
                try
                {
                    List<Zuora.zApi.SubscribeResult> subscribeResults = new List<Zuora.zApi.SubscribeResult>();
                    //System.debug('KP test - subsRequestLists: ' + subsRequestLists);
                    if(subsRequestLists.size() > 0){
                        //System.debug('Kyle Porter Debug subscribe time: ' + DateTime.now());
                        subscribeResults = ZuoraUtil.zsubscribe(subsRequestLists);
                    }

                    system.debug('##### subscribeResults :: ' + subscribeResults);
                    /*System.debug( 'logger = ' + Zuora.zApi.currentLogger.toString() );
                    if (Zuora.zApi.currentLogger != null) {
                        system.debug('SOAP Request = ' + Zuora.zApi.currentLogger.request );
                        system.debug('SOAP Response = ' + Zuora.zApi.currentLogger.response );
                        System.debug( 'logger = ' + Zuora.zApi.currentLogger.toString() );
                    }*/
                    //-- Process Result 
                    //list<Order> orderToUpdate = new list<Order>();
                    Integer i = 0;
        
                    if(subscribeResults.size() > 0){
                        for (Zuora.zApi.SubscribeResult result : subscribeResults) {
                            OrderItem orderItem = OrderItemSend.get(i);
                            if(orderItem != null){
                                if (orderItem.Id != null)
                                    orderItemId_subscribeResult.put(orderItem.Id,result);
                                else
                                    orderItemId_subscribeResult.put(orderItem.OrderId,result);
                            }
        
                            i++;
                        }
                    }
                }
                catch (Exception ex)
                {
                    /*System.debug( 'logger = ' + Zuora.zApi.currentLogger.toString() );
                    if (Zuora.zApi.currentLogger != null) {
                        system.debug('SOAP Request = ' + Zuora.zApi.currentLogger.request );
                        system.debug('SOAP Response = ' + Zuora.zApi.currentLogger.response );
                        System.debug( 'logger = ' + Zuora.zApi.currentLogger.toString() );
                    }*/
                    //Log the Zuora exception when creating a new Subscription
                    IEC_Error_Log__c errorLog = IECErrorLogger.createErrorLog('Order_Svc/subscribe','subsRequestLists: ' + subsRequestLists,ex.getMessage(),ex.getStackTraceString());
                    IECErrorLogger.logErrors(new list<IEC_Error_Log__c>{errorLog});
                    
                    //Threw an exception when Zuora exception occur
                    //*** do not throw error in order to rollback -> prepare to rollback if having successful subscriptions
                    //throw new OrderException(ex.getMessage() + ' +++ ' + ex.getStackTraceString() + ' +++ ' + ex.getLineNumber());
                    if (orderItemId_subscribeResult.size() == 0)
                        orderItemId_subscribeResult = null;
                    else
                        for (Integer e1 = 0; e1 < OrderItemSend.size(); e1++)
                            if (!orderItemId_subscribeResult.containsKey((OrderItemSend[e1].Id != null) ? OrderItemSend[e1].Id : OrderItemSend[e1].OrderId))
                                orderItemId_subscribeResult.put((OrderItemSend[e1].Id != null) ? OrderItemSend[e1].Id : OrderItemSend[e1].OrderId, null);
                }
            }
        system.debug('##### orderItemId_subscribeResult :: ' + orderItemId_subscribeResult);
        return orderItemId_subscribeResult;
    }

    //Set the Customer payment method
    public static Zuora.zObject setPaymentMethod(Zuora__CustomerAccount__c zuoraCustomerAccount){

        Zuora.zObject pm = new Zuora.zObject('PaymentMethod');

        pm.setValue('Type',zuoraCustomerAccount.Zuora__PaymentMethod_Type__c);
        pm.setValue('CreditCardType', zuoraCustomerAccount.Zuora__CreditCardType__c);
        pm.setValue('CreditCardNumber', zuoraCustomerAccount.Zuora__CreditCard_Number__c);
        if(zuoraCustomerAccount.Zuora__CreditCard_Expiration__c !=null){
            pm.setValue('CreditCardExpirationYear', zuoraCustomerAccount.Zuora__CreditCard_Expiration__c.split('/')[1]);
            pm.setValue('CreditCardExpirationMonth', zuoraCustomerAccount.Zuora__CreditCard_Expiration__c.split('/')[0]);
        }

        return pm;

    }

    public static Zuora.zObject setPaymentMethodWithWrp(IECZuoraHelper.PaymentMethod paymentMethod){

        Zuora.zObject pm = new Zuora.zObject('PaymentMethod');
        pm.setValue('Id',paymentMethod.zId);
        pm.setValue('Type', IECConstants.PaymentThresholdType_CreditCard);
        return pm;

    }

    //Parse the susbscription Result 
    public static Map<Id,String> parseSubscribeResult2UpdateItems(Map<Id,Zuora.zApi.SubscribeResult> orderItemResponse,  Map<String,ZuoraUtil.zAccountPaymentMethod> orderId_zAccountPaymentMethod ){ 
        
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        List<Order> orderToUpdate = new List<Order>();
        Set<Id> orderAlreadyToUpdate = new Set<Id>();

        Map<Id,String> itemsStatus = new Map<Id,String>();
        
        //List Of order that contains at less one subscription that failed
        map<Id,String> orderIdsForFailedSub = new map<Id,String>();

        Boolean errors = false;

        if(orderItemResponse != null && !orderItemResponse.isEmpty()){
            //get orderItem
            set<Id> orderIds = new set<Id>();
            Map<Id,OrderItem> ordItemId_OrderItem = new OrderItem_Sel().getOrderItemById(orderItemResponse.keySet());

            for(OrderItem oi : ordItemId_OrderItem.values()){
                orderIds.add(oi.OrderId);
            }

            //Order Map
            Map<Id,Order> orderMap = new Order_Sel().getOrderByStatus(orderIds);

            //order with list of Items
            Map<Id,List<OrderItem>> orderId_Items = new Map<Id, List<OrderItem>>();

            //Set Zuora account ids for on OnDemandSyncAccounts
            set<String> zAccountIds = new set<String>();

            //Set the Zuora invoice ids
            set<String> zInvoicesIds = new set<String>();

            //Set Invoice Map from Zuora
            Map<String,Zuora.zObject> invoiceMap = new Map<String,Zuora.zObject>();

            ZuoraUtil.zAccountPaymentMethod iecOrderId_paymentMethod = new ZuoraUtil.zAccountPaymentMethod();
            
            for(Id orderItemId : orderItemResponse.keySet()){
                OrderItem ordItem;
                if (ordItemId_OrderItem.containsKey(orderItemId))
                    ordItem = ordItemId_OrderItem.get(orderItemId);
                else
                    ordItem = new OrderItem(OrderId=orderItemId);
                Order order = orderMap.get(ordItem.OrderId);

                if(ordItem != null){
                    
                    Zuora.zApi.SubscribeResult subResponse = orderItemResponse.get(ordItem.Id != null ? ordItem.Id : ordItem.OrderId);
                    system.debug('##### subResponse :: ' + subResponse);
                    iecOrderId_paymentMethod = orderId_zAccountPaymentMethod.get(order.Id);

                    if (subResponse != null && subResponse.Success) {
                        //*** save Zuora subscription information
                        if (ordItem.Id != null)
                        {
                            ordItem.Zuora_InvoiceId__c =  subResponse.InvoiceId;
                            ordItem.Zuora_InvoiceNumber__c = subResponse.InvoiceNumber;
                            ordItem.Zuora_SubscriptionId__c = subResponse.SubscriptionId;
                            ordItem.Zuora_Subscription_Number__c = subResponse.SubscriptionNumber;
                        }
                        else
                        {
                            order.IEC_Zuora_ST_InvoiceId__c =  subResponse.InvoiceId;
                            order.IEC_Zuora_ST_InvoiceNumber__c = subResponse.InvoiceNumber;
                            order.IEC_Zuora_ST_SubscriptionId__c = subResponse.SubscriptionId;
                            order.IEC_Zuora_ST_SubscriptionNumber__c = subResponse.SubscriptionNumber;
                        }
                        //Set Zuora Invoice Ids
                        if(subResponse.InvoiceId != null){
                            if (ordItem.Id != null)
                            {
                                //*** save Zuora information on subscription for an order item
                                //ordItem.Zuora_InvoiceId__c =  subResponse.InvoiceId;
                                //ordItem.Zuora_InvoiceNumber__c = subResponse.InvoiceNumber;
                                //ordItem.Zuora_SubscriptionId__c = subResponse.SubscriptionId;
                                //ordItem.Zuora_Subscription_Number__c = subResponse.SubscriptionNumber;
                                ordItem.Payment_Transaction_Number__c = subResponse.PaymentTransactionNumber;
                                if(iecOrderId_paymentMethod.zPaymentMethodName == IECConstants.PaymentThresholdType_BankTransfer)
                                    ordItem.Zuora_Subscription_Status__c = 'Pending Activation';
    
                                zInvoicesIds.add(subResponse.InvoiceId);
                                zAccountIds.add(subResponse.AccountId);
    
                                if(!orderId_Items.containskey(order.Id)){
                                    orderId_Items.put(order.Id, new List<OrderItem>());
                                }
                                orderId_Items.get(order.Id).add(ordItem);
                            }
                            else
                            {
                                //*** save Zuora information on shipping & tax subscription
                                //order.IEC_Zuora_ST_InvoiceId__c =  subResponse.InvoiceId;
                                //order.IEC_Zuora_ST_InvoiceNumber__c = subResponse.InvoiceNumber;
                                //order.IEC_Zuora_ST_SubscriptionId__c = subResponse.SubscriptionId;
                                //order.IEC_Zuora_ST_SubscriptionNumber__c = subResponse.SubscriptionNumber;
    
                                zInvoicesIds.add(subResponse.InvoiceId);
                                zAccountIds.add(subResponse.AccountId);
                            }
    
                            //Set the Zuora Account Id with payment Method
                            iecOrderId_paymentMethod.zAccountId = subResponse.AccountId;
    
                            itemsStatus.put((ordItem.Id != null ? ordItem.Id : ordItem.OrderId),'Success');

                        }
                        else{
                            String errorText = '';

                            Zuora.zObject[] subErrors = subResponse.errors;
                            for (Zuora.zObject error : subErrors) {
                                errorText += (String)error.getValue('Code') + ': ' + (String)error.getValue('Message');
                            }

                            //Set the invoice error
                            orderIdsForFailedSub.put(ordItem.OrderId,subResponse.SubscriptionId);
                            
                            //itemsStatus.put((ordItem.Id != null ? ordItem.Id : ordItem.OrderId),'Failed');

                            itemsStatus.put((ordItem.Id != null ? ordItem.Id : ordItem.OrderId),'Failed: ' + errorText);
                        }

                    }else{
                        //If one subscription failed
                        String errorText = 'Error';
                        if (subResponse != null)
                        {
                            errorText = '';
                            Zuora.zObject[] subErrors = subResponse.errors;
                            for (Zuora.zObject error : subErrors)
                                errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message');
                        }
                        orderIdsForFailedSub.put(ordItem.OrderId,errorText);
                        errors = true;
                        itemsStatus.put((ordItem.Id != null ? ordItem.Id : ordItem.OrderId),errorText);
                    }
                    if (ordItem.Id != null)
                        orderItemsToUpdate.add(ordItem);
                    else if (!orderAlreadyToUpdate.contains(order.Id))
                    {
                        orderAlreadyToUpdate.add(order.Id);
                        orderToUpdate.add(order);
                    }
                }
            }

            //OnDemandSyncAccounts to add new payment payment method in SFDC
            if(zAccountIds.size() > 0){
                try{
                    IECSubscriptionManager.OnDemandSyncAccounts(zAccountIds);
                }catch(Exception ex){
                    //Log Account OnDemandSync exception
                    IEC_Error_Log__c errorLog = IECErrorLogger.createErrorLog('Order_Svc/parseSubscribeResult2UpdateItems',JSON.serialize(zAccountIds),ex.getMessage(),ex.getStackTraceString());
                    IECErrorLogger.logErrors(new list<IEC_Error_Log__c>{errorLog});
                }
            }

            //Throw exception if at less one subscription have an error
            if(orderIdsForFailedSub.size() > 0){
                //Update order if an error occur
                if(orderToUpdate.size() > 0)
                    update orderToUpdate;
                orderToUpdate.clear();
                //Update the orderItem if an error occur
                if(orderItemsToUpdate.size() > 0){
                    update orderItemsToUpdate;
                }
                orderItemsToUpdate.clear();

/**

    Ecommerce Enhancements R1, do not delete Zuora Subscription. --- reverted comment on 2017-06-19.

*/
                //Delete all of the Subscription on Zuora
                if (system.isBatch() || system.isFuture())
                    deleteZuoraSubscriptionNow(orderIdsForFailedSub.keySet());
                else
                    deleteZuoraSubscription(orderIdsForFailedSub.keySet());


                //*** should not throw exception because no update nor rollback is performed
                //throw Exception
                //throw new OrderException(String.join(orderIdsForFailedSub.values(), ' '));
                system.debug('##### itemsStatus in error :: '+itemsStatus);
                return itemsStatus;
            }

            //Get the Zuora invoices
            if(zInvoicesIds.size() > 0){
               //Get the Zuora invoices
                List<Zuora.zObject> zInvoices = getZuoraInvoices(zInvoicesIds);
                for(Zuora.zObject zInv : zInvoices){
                    invoiceMap.put((String)zInv.getValue('Id'),zInv);
                }
            }

            if(orderId_Items.size() > 0){

                //Make a payment for Credit card
                //List<Zuora.zApi.SaveResult> lstResults; = new List<Zuora.zApi.SaveResult>();
                
                //Make Payment on orders and get a map of Zuora response by order Id
                Map<Id,Zuora.zApi.SaveResult> resultByOrderId;
                try {
                    resultByOrderId = createZuoraPayment(orderMap, orderId_Items, orderId_zAccountPaymentMethod, invoiceMap);
                    system.debug('##### resultByOrderId :: '+resultByOrderId);
                } catch (Exception e) {}
                
                //Parse payment Result
                if(resultByOrderId != null && resultByOrderId.size() > 0){

                    //set<String> paymentIds = parsePaymentResult(resultByOrderId);
                    set<String> paymentIds = new set<String>();
                    set<String> paymentErrors =  new set<String>();

                    //Parse the Zuora payment response and get the Map of Payment Result By orderId
                    Map<Id,String> paymentResultByOrderId = parsePaymentResult(resultByOrderId);
                    system.debug('##### paymentResultByOrderId :: '+paymentResultByOrderId);
                    if(paymentResultByOrderId != null && !paymentResultByOrderId.isEmpty()){
                        for(String orderId : paymentResultByOrderId.keySet()){
                            String zResult = paymentResultByOrderId.get(orderId);
                            if(!zResult.contains('paymentError: ')){
                                paymentIds.add(zResult);
                            }else{
                                orderIdsForFailedSub.put(orderId,zResult);
                                if (itemsStatus.containsKey(orderId))
                                    itemsStatus.put(orderId, 'Failed: ' + zResult);
                                for (OrderItem oi : orderId_Items.get(orderId))
                                    if (oi.Id != null && itemsStatus.containsKey(oi.Id))
                                        itemsStatus.put(oi.Id, 'Failed: ' + zResult);

                                system.debug('##### itemsStatus failed :: '+itemsStatus);
                            }
                        }
                    }
                    
                    if(paymentIds != null && paymentIds.size() > 0){
                        system.debug('##### paymentIds :: '+paymentIds);
                        system.debug('##### orderMap :: '+orderMap);
                        //Get the detail for the payment from Zuora
                        List<Zuora.zObject> zPaymentsDetails = getZuoraPayments(paymentIds,orderMap);
                        system.debug('##### zPaymentsDetails :: '+zPaymentsDetails);
                        //Get the payment details
                        if(zPaymentsDetails != null && zPaymentsDetails.size() > 0){
                            for(Zuora.zObject payment : zPaymentsDetails){
                                
                                String paymentStatus = (String)payment.getValue('Status');
                                String OrderId = (String)payment.getValue('SFDCOrderId__c');

                                system.debug('##### paymentStatus :: '+paymentStatus);
                                system.debug('##### OrderId :: '+OrderId);
                                
                                Order order2Update = orderMap.get(OrderId);
                                ZuoraUtil.zAccountPaymentMethod zapm = orderId_zAccountPaymentMethod.get(OrderId);
                                if(order2Update != null){
                                    order2Update.Payment_Transaction_Number__c = (String)payment.getValue('ReferenceId');
                                    order2Update.Zuora_Transaction_Id__c = (String)payment.getValue('Id');
                                    order2Update.Payment_Type__c = zapm.zPaymentMethodName;
                                    order2Update.Zuora_Credit_Card_Id__c = zapm.zPaymentMethod;
                                }
                                system.debug('###### paymentStatus :: ' + paymentStatus);
                                if(paymentStatus != null && paymentStatus.contains('Error')){
                                    
                                    //Get the payment error message
                                    String GatewayResponse = (String)payment.getValue('GatewayResponse');
                                    String GatewayResponseCode = (String)payment.getValue('GatewayResponseCode');
                                    String GatewayState = (String)payment.getValue('GatewayState');
                                    String paymentError = (String)payment.getValue('GatewayResponse');

                                    //order2Update.Status = 'Payment Failure';
                                    //order2Update.Is_Paid__c = false;

                                    //Delete all of the Subscription on Zuora
                                    orderIdsForFailedSub.put(OrderId,'GatewayResponseCode : ' + GatewayResponseCode + ', GatewayResponse : ' + GatewayResponse);
                                }
                                system.debug('##### orderIdsForFailedSub :: '+orderIdsForFailedSub);
                                if (!orderAlreadyToUpdate.contains(order2Update.Id))
                                {   system.debug('##### orderAlreadyToUpdate :: '+orderAlreadyToUpdate);
                                    orderAlreadyToUpdate.add(order2Update.Id);
                                    orderToUpdate.add(order2Update);
                                }
                            }
                        }
                    }
                }
                else //exception for payment -> delete all subscriptions
                {
                    for (Id idOrder : orderMap.keySet())
                        orderIdsForFailedSub.put(idOrder, 'Exception on payment');
                }
                system.debug('##### orderIdsForFailedSub :: '+orderIdsForFailedSub);
                //Throw exception if the transaction failed
                if(orderIdsForFailedSub.size() > 0){
                    system.debug('Payment Failure - Error on credit card');
                    //Update order if an error occur
                    if(orderToUpdate.size() > 0)
                        update orderToUpdate;
                    orderToUpdate.clear();
                    //Update the orderItem if an error occur
                    if(orderItemsToUpdate.size() > 0){
                        update orderItemsToUpdate;
                    }
                    orderItemsToUpdate.clear();
                    
/**

    Ecommerce Enhancements R1, do not delete Zuora Subscription. --- reverted comment on 2017-06-19.

*/
                    if (system.isBatch() || system.isFuture())
                        deleteZuoraSubscriptionNow(orderIdsForFailedSub.keySet());
                    else
                        deleteZuoraSubscription(orderIdsForFailedSub.keySet());

                    //*** should not throw exception because no update nor rollback is performed
                    //throw Exception
                    //throw new OrderException(String.join(orderIdsForFailedSub.values(), ' ') );
                    system.debug('##### itemsStatus in error 2 :: '+itemsStatus);
                    return itemsStatus;
                }

            }

        }

        //Update Order with the Transaction Number
        if(orderToUpdate.size() > 0){
            update orderToUpdate;
        }

        //Update order Items
        if(orderItemsToUpdate.size() > 0){
            update orderItemsToUpdate;
        }
        system.debug('##### itemsStatus :: '+itemsStatus);
        return itemsStatus;
    }

    //Parse the Payment result and return a map of result by Order Id
    public static Map<Id,String> parsePaymentResult(Map<Id,Zuora.zApi.SaveResult> resultsByOrderId){
        
        Map<Id,String> paymentResultByOrderId = new Map<Id,String>();
        
        for(Id orderId : resultsByOrderId.keySet()){
            Zuora.zApi.SaveResult result = resultsByOrderId.get(orderId);
            if(!result.Success){
                Zuora.zObject[] errors = result.errors;
                String errorText = 'paymentError: ';
                for (Zuora.zObject error : errors) { errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message'); }
                paymentResultByOrderId.put(orderId, errorText);
            }else{
                paymentResultByOrderId.put(orderId, result.Id);
            }
        }

        return paymentResultByOrderId;

    }
    
    //Parse the payment Results
    //public static set<String> parsePaymentResult(List<Zuora.zApi.SaveResult> results){
        
    //    set<String> paymentIds = new set<String>();
        
    //    for (Zuora.zApi.SaveResult result : results){
    //        if (!result.Success){
    //            Zuora.zObject[] errors = result.errors;
    //            String errorText = '';
    //            for (Zuora.zObject error : errors) { errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message'); }
    //            System.debug('errorText ' + errorText);
    //            throw new OrderException('Failure to create Payment.' + errorText);
    //        }else{
    //            paymentIds.add(result.Id);
    //        }
    //    }
    //    return paymentIds;
    //}
    

    //Query Zuora to get Invoice detail
    public static List<Zuora.zObject> getZuoraInvoices(set<String> zuoraInvIds){
        String query = getInvoiceString(zuoraInvIds);
        
        List<Zuora.zObject> lstInvoices;
        if(!Test.isRunningTest()){
            lstInvoices = IECZuoraHelper.queryApiCall(query);
        }else{
            lstInvoices = TestDataGenerator.generateZInvoices(1);
        }
        
        return lstInvoices;
    }

    //Generate the invoice query string
    public static String getInvoiceString(Set<String> zuoraInvIds)
    {
        List<String> whereItems = new List<String>(); 
        for(String i: zuoraInvIds)
            whereItems.add('Id = \'' + i + '\'');
        
        String zoql = 'SELECT Id,AccountID, InvoiceNumber,Amount,CreditBalanceAdjustmentAmount,Balance,RefundAmount FROM Invoice WHERE ' + String.join(whereItems, ' OR ');
        return zoql;
    }

    //Query Zuora Payment for details
    public static List<Zuora.zObject> getZuoraPayments(set<String> paymentIds,Map<Id,Order>orderMap){
        String query = getPaymentString(paymentIds);
        List<Zuora.zObject> lstPayments;
        if(!Test.isRunningTest())
        {
            try{
                lstPayments = IECZuoraHelper.queryApiCall(query);
                system.debug('##### lstPayments :: '+lstPayments);
            }catch(Exception ex){
                //Log the payment exception
                IEC_Error_Log__c errorLog = IECErrorLogger.createErrorLog('Order_Svc/getZuoraPayments',query,ex.getMessage(),ex.getStackTraceString());
                IECErrorLogger.logErrors(new list<IEC_Error_Log__c>{errorLog});

                throw new OrderException(ex.getMessage());
            }
            
        }else{
            lstPayments = TestDataGenerator.generateZPayments(orderMap);
        }
        
        return lstPayments;
    }

    //Generate the payment query string
    public static String getPaymentString(Set<String> zuoraPayIds)
    {
        List<String> whereItems = new List<String>(); 
        for(String i: zuoraPayIds)
            whereItems.add('Id = \'' + i + '\'');
        
        String zoql = 'SELECT Id, ReferenceId,SFDCOrderId__c,GatewayResponse,GatewayResponseCode,GatewayState,Status FROM Payment WHERE ' + String.join(whereItems, ' OR ');
        return zoql;
    }
    
    //Generate a list of Zuora payment Object
    public static Map<Id,Zuora.zApi.SaveResult> createZuoraPayment(Map<Id,Order> orderMap, Map<Id,List<OrderItem>> orderId_Items, Map<String,ZuoraUtil.zAccountPaymentMethod> orderId_zAccountPaymentMethod, Map<String,Zuora.zObject> invoiceMap){
        
        List<Zuora.zObject> lstInvoicePayment = new List<Zuora.zObject>();
        List<Order> lstOrder = new List<Order>();
        List<Zuora.zApi.SaveResult> lstResults = new List<Zuora.zApi.SaveResult>();

        Map<Id,Zuora.zApi.SaveResult> resultByOrderId = new Map<Id,Zuora.zApi.SaveResult>();
        Zuora.zObject ipd, zInvoice;

        for(Order order : orderMap.values()){

            List<Zuora.zObject> lstInvoicePaymentData = new List<Zuora.zObject>();

            Decimal totalToPaid = 0;
            
            if (order.IEC_Zuora_ST_InvoiceId__c != null && invoiceMap.containsKey(order.IEC_Zuora_ST_InvoiceId__c))
            {
                ipd = new Zuora.zObject('InvoicePayment');
                zInvoice = invoiceMap.get(order.IEC_Zuora_ST_InvoiceId__c);
                
                ipd.setValue('Amount',(Decimal)zInvoice.getValue('Balance'));
                ipd.setValue('InvoiceId', order.IEC_Zuora_ST_InvoiceId__c);
                ipd.setValue('RefundAmount', 0);
                lstInvoicePaymentData.add(ipd);

                //Calcul the total amount to paid
                totalToPaid += (Decimal)zInvoice.getValue('Balance');
            }
            
            //Get list of Items
            List<OrderItem> lstOi = orderId_Items.get(order.Id);
            if(lstOi != null && lstOi.size() > 0){
                //set the list of invoice to paid
                for(OrderItem oi : lstOi){
                    ipd = new Zuora.zObject('InvoicePayment');
                    //get OrderItem Amount from Invoice
                    zInvoice = invoiceMap.get(oi.Zuora_InvoiceId__c);

                    ipd.setValue('Amount',(Decimal)zInvoice.getValue('Balance'));
                    ipd.setValue('InvoiceId', oi.Zuora_InvoiceId__c);
                    ipd.setValue('RefundAmount', 0);

                    lstInvoicePaymentData.add(ipd);

                    //Calcul the total amount to paid
                    totalToPaid += (Decimal)zInvoice.getValue('Balance');
                }
            }

            //Set the Payment object
            Zuora.zObject pmt = new Zuora.zObject('Payment');
            ZuoraUtil.zAccountPaymentMethod zAcc_PaymentMethod = orderId_zAccountPaymentMethod.get(order.Id);
            pmt.setValue('AccountId',zAcc_PaymentMethod.zAccountId);
            pmt.setValue('Amount', totalToPaid);
            pmt.setValue('EffectiveDate', Zuora.zUtil.getZuoraDate(Date.today()));
            pmt.setValue('AppliedCreditBalanceAmount', 0);
            
            //Set the Invoice Payment Data
            Zuora.zObject invoicePaymentData = new Zuora.zObject('InvoicePaymentData');
            invoicePaymentData.setValue('InvoicePayment', lstInvoicePaymentData);
            pmt.setValue('InvoicePaymentData', invoicePaymentData);

            //Set payment method Id
            if(zAcc_PaymentMethod.zPaymentMethod != null){
                pmt.setValue('PaymentMethodId',zAcc_PaymentMethod.zPaymentMethod);
            }else{
                //Query the Account Payment Method
                Zuora.zObject zAccount = getZaccountById(zAcc_PaymentMethod.zAccountId);
                if(zAccount != null){ pmt.setValue('PaymentMethodId',(String)zAccount.getValue('DefaultPaymentMethodId')); }
                
            }
            
            pmt.setValue('Status','Processed');// Error, Processed

            String paymentType = 'Electronic';

            if(zAcc_PaymentMethod.zPaymentMethodName != IECConstants.PaymentThresholdType_CreditCard)
            {
                paymentType = 'External';
            }
            
            pmt.setValue('Type',paymentType);

            pmt.setValue('SFDCOrderId__c',order.Id);

            lstInvoicePayment.add(pmt);
            lstOrder.add(order);

        }
        system.debug('##### lstInvoicePayment :: ' + lstInvoicePayment);
        if(lstInvoicePayment.size() > 0){
            if(!Test.isRunningTest()){
                try{
                    lstResults = IECZuoraHelper.createApiCall(lstInvoicePayment);
                    for(Integer i = 0; i < lstResults.size(); i++){
                        resultByOrderId.put(lstOrder[i].Id, lstResults[i]);
                    }
                }catch(Exception ex){
                    //Log Zuora Payment exception
                    IEC_Error_Log__c errorLog = IECErrorLogger.createErrorLog('Order_Svc/createZuoraPayment',JSON.serialize(lstInvoicePayment),ex.getMessage(),ex.getStackTraceString());
                    IECErrorLogger.logErrors(new list<IEC_Error_Log__c>{errorLog});

                    //throw new OrderException(ex.getMessage());
                    lstResults = null;
                }
            }else{
                lstResults = TestDataGenerator.generatePaymentResults(lstInvoicePayment, lstOrder[0].Invoice_Text__c);
                for(Integer i = 0; i < lstResults.size(); i++)
                    resultByOrderId.put(lstOrder[i].Id, lstResults[i]);
            }
        }
        system.debug('##### resultByOrderId :: ' + resultByOrderId);
        return resultByOrderId;
    }

    //Delete zuora Subscription when an error occur
    @future(callout = true)
    public static void deleteZuoraSubscription(set<Id> orderIds){
        system.debug('deleteZuoraSubscription');
        deleteZuoraSubscriptionNow(orderIds);
    }
    public static void deleteZuoraSubscriptionNow(set<Id> orderIds){
        system.debug('deleteZuoraSubscriptionNow');
        map<Id,Order> orderMap = new Order_Sel().getOrderByStatus(orderIds);
        Map<Id, List<OrderItem>> orderId_Items = new OrderItem_Sel().getOrderItems(orderIds);
        system.debug('#### orderMap :: '+orderMap);
        system.debug('#### orderId_Items :: '+orderId_Items);
        //List of Zuora Subscription to delete
        set<String> sub2Delete = new set<String>();
        //
        set<String> inv2Delete = new set<String>();

        list<String> refId = new list<String>();
        Map<Id,String> orderItemIdBySubId = new Map<Id,String>();
        Map<Id,Id> orderItemByOrderId = new Map<Id,Id>();

        //List of errors to log
        List<IEC_Error_Log__c> lstErrors = new List<IEC_Error_Log__c>();

        for(Id orderId:orderId_Items.keySet()){
            
            Order order = orderMap.get(orderId);
            system.debug('#### Zuora_Transaction_Id__c :: '+order.Zuora_Transaction_Id__c);
            system.debug('#### IEC_Zuora_ST_SubscriptionId__c :: '+order.IEC_Zuora_ST_SubscriptionId__c);
            system.debug('#### IEC_Zuora_ST_InvoiceId__c :: '+order.IEC_Zuora_ST_InvoiceId__c);

            if(order.Zuora_Transaction_Id__c != null){ refId.add(order.Zuora_Transaction_Id__c); }

            if(order.IEC_Zuora_ST_SubscriptionId__c != null)
                sub2Delete.add(order.IEC_Zuora_ST_SubscriptionId__c);
            if(order.IEC_Zuora_ST_InvoiceId__c != null)
                inv2Delete.add(order.IEC_Zuora_ST_InvoiceId__c);

            list<OrderItem> ordItems = orderId_Items.get(orderId);
            system.debug('#### ordItems :: '+ordItems);

            if(ordItems != null && ordItems.size() > 0){
                for(OrderItem oi : ordItems){
                    //orderItemIds.add(oi.Id);
                    if(oi.Zuora_SubscriptionId__c != null){
                        system.debug('#### oi.Zuora_SubscriptionId__c :: '+oi.Zuora_SubscriptionId__c);
                        sub2Delete.add(oi.Zuora_SubscriptionId__c);
                        orderItemIdBySubId.put(oi.Id,oi.Zuora_SubscriptionId__c);
                        orderItemByOrderId.put(oi.Id, orderId);
                    }
                    if(oi.Zuora_InvoiceId__c != null){
                        system.debug('#### oi.Zuora_InvoiceId__c :: '+oi.Zuora_InvoiceId__c);
                        inv2Delete.add(oi.Zuora_InvoiceId__c);
                    }
                }
            }        
        }

        system.debug('#### refId :: '+refId);
        system.debug('#### sub2Delete :: '+sub2Delete);
        system.debug('#### inv2Delete :: '+inv2Delete);

        //Change the Payments status to Cancel 
        List<Zuora.zObject> paymentCancel = new List<Zuora.zObject>();
        for(String payId : refId){
            system.debug('#### cancel payment');
            Zuora.zObject payment = new Zuora.zObject('Payment');
            payment.setValue('Id',payId);
            payment.setValue('Status','Canceled');
            paymentCancel.add(payment);
        }
        try{
            if(paymentCancel.size() > 0)
            {   system.debug('paymentCancel' + paymentCancel);
                List<Zuora.zApi.SaveResult> updatePay = ZuoraUtil.zupdate(paymentCancel);
                System.debug('updatePay ' + updatePay);
                /*
                for (Zuora.zApi.SaveResult result : updatePay) {
                    System.debug('updatePay ' + updatePay);
                    if (!result.Success){
                        Zuora.zObject[] errors = result.errors;
                         for (Zuora.zObject error : errors) {
                            String errorCode = (String)error.getValue('Code');
                            String message = (String)error.getValue('Message');
                         }
                    }
                }*/
                
            }
        }catch(Exception ex){
            system.debug('#### exception on payment :: ' + ex.getMessage()+ ' - ' +ex.getStackTraceString());
            lstErrors.add(IECErrorLogger.createErrorLog('Order_Svc/deleteZuoraSubscription',JSON.serialize(paymentCancel),ex.getMessage(),ex.getStackTraceString()));
        }

        //Change the Invoice status to Cancel
        List<String> invIds = new List<String>();
        invIds.addAll(inv2Delete);

        system.debug('###### invIds :: '+invIds);

        List<Zuora.zObject> invoicesCancel = new List<Zuora.zObject>();
        for(String invId : invIds){
            system.debug('#### cancel invoice');
            Zuora.zObject invoice = new Zuora.zObject('Invoice');
            invoice.setValue('Id',invId);
            invoice.setValue('Status','Draft');
            invoicesCancel.add(invoice);
        }

        system.debug('###### invoicesCancel :: '+invoicesCancel);

        try{
            if(invoicesCancel.size() > 0)
            {   system.debug('####### invoicesCancel');
                List<Zuora.zApi.SaveResult> updateInv = ZuoraUtil.zupdate(invoicesCancel);
                System.debug('updateInv ' + updateInv);
                for(Zuora.zObject inv : invoicesCancel)
                    inv.setValue('Status','Canceled');
                updateInv =  ZuoraUtil.zupdate(invoicesCancel);
                system.debug('###### updateInv :: '+updateInv);
            }
        }catch(Exception ex){
            system.debug('#### exception on invoice :: ' + ex.getStackTraceString());
            lstErrors.add(IECErrorLogger.createErrorLog('Order_Svc/deleteZuoraSubscription',JSON.serialize(invoicesCancel),ex.getMessage(),ex.getStackTraceString()));
        }

        /*
        //Remove the 3 last character for OrderId__c and OrderItemId__c for Zuora Subscription
        List<Zuora.zObject> updateZsubOrderId = new List<Zuora.zObject>();
        for(Id orderItem : orderItemIdBySubId.keySet()){

            String subId = orderItemIdBySubId.get(orderItem);
            Id orderId = orderItemByOrderId.get(orderItem);

            Zuora.zObject subscription = new Zuora.zObject('Subscription');
            subscription.setValue('Id',subId);
            subscription.setValue('OrderId__c', String.valueOf(orderId).substring(0, 15) + 'xxx');
            subscription.setValue('OrderItemId__c', String.valueOf(orderItem).substring(0, 15) + 'xxx');
            updateZsubOrderId.add(subscription);
        }
        try{
            if(updateZsubOrderId.size() > 0)
            {
                List<Zuora.zApi.SaveResult> updatePay = ZuoraUtil.zupdate(updateZsubOrderId);
                System.debug('updatePay ' + updatePay);
            }
        }catch(Exception ex){
            lstErrors.add(IECErrorLogger.createErrorLog('Order_Svc/deleteZuoraSubscription',JSON.serialize(updateZsubOrderId),ex.getMessage(),ex.getStackTraceString()));
        }

        //Amand subscriptions to set the Status to Cancel
        List<Zuora.zApi.AmendRequest> amendRequestLists = new List<Zuora.zApi.AmendRequest>();
        for(Id orderItem : orderItemIdBySubId.keySet()){

            String subId = orderItemIdBySubId.get(orderItem);
            //Id orderId = orderItemByOrderId.get(orderItem);
            //create amendment
            Zuora.zObject amend = new Zuora.zObject('Amendment');
            amend.setValue('Name', 'Cancelling Subscription');
            amend.setValue('Type', 'Cancellation');
            amend.setValue('SubscriptionId', subId);
            amend.setValue('Status', 'Completed');
            amend.setValue('CustomerAcceptanceDate', Zuora.zUtil.getZuoraDate(Date.today()));
            amend.setValue('ServiceActivationDate', Zuora.zUtil.getZuoraDate(Date.today()));
            amend.setValue('ContractEffectiveDate', Zuora.zUtil.getZuoraDate(Date.today()));
            amend.setValue('EffectiveDate', Zuora.zUtil.getZuoraDate(Date.today()));


            //create amendment request
            Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
            amendRequest.amendOptions = new Zuora.zApi.AmendOptions();
            amendRequest.amendOptions.GenerateInvoice = false;
            amendRequest.amendOptions.ProcessPayments = false;
            amendRequest.amendments = new List<Zuora.zObject>{ amend };
            amendRequestLists.add(amendRequest);
        }
        
        System.debug('amendRequestLists ' + amendRequestLists);
        Zuora.zApi.AmendResult amendResult = new Zuora.zApi.AmendResult();
        if(amendRequestLists.size() > 0){
            for(Zuora.zApi.AmendRequest ar : amendRequestLists){
                amendResult = IECZuoraHelper.amendApiCall(ar);
            }   
        }
        */

        //Delete Payments
        try{
            if(refId.size() > 0){ List<Zuora.zApi.DeleteResult> deleteTrans = ZuoraUtil.zdelete('Payment',refId); 
            system.debug('#### deleteTrans :: '+deleteTrans);
            }
        }catch(Exception ex){
            system.debug('#### exception on deleteTrans :: ' + ex.getStackTraceString());
            lstErrors.add(IECErrorLogger.createErrorLog('Order_Svc/deleteZuoraSubscription',JSON.serialize(refId),ex.getMessage(),ex.getStackTraceString()));
        }
        
        //Delete the corresponding Invoices first
        try{
            if(invIds.size() > 0){
                List<Zuora.zApi.DeleteResult> deleteInv = ZuoraUtil.zdelete('Invoice',invIds);
                system.debug('#### deleteInv :: '+deleteInv);
            }
        }catch(Exception ex){
            system.debug('#### exception on deleteInv :: ' + ex.getStackTraceString());
            lstErrors.add(IECErrorLogger.createErrorLog('Order_Svc/deleteZuoraSubscription',JSON.serialize(invIds),ex.getMessage(),ex.getStackTraceString()));
        }
        
        List<String> ids = new List<String>();
        ids.addAll(sub2Delete);
        system.debug('#### ids :: '+ids);
        try{
            if(ids.size() > 0){
                List<Zuora.zApi.DeleteResult> deleteSub = ZuoraUtil.zdelete('Subscription',ids);
                system.debug('#### deleteSub :: '+deleteSub);
            }
                
        }catch(Exception ex){
            system.debug('#### exception on deleteSub :: ' + ex.getStackTraceString());
            lstErrors.add(IECErrorLogger.createErrorLog('Order_Svc/deleteZuoraSubscription',JSON.serialize(ids),ex.getMessage(),ex.getStackTraceString()));
        }

        //Log errors
        if(lstErrors.size() > 0) IECErrorLogger.logErrors(lstErrors);
        system.debug('#### lstErrors :: ' + lstErrors);

    }

    //Verify if orderItem is Pending Activation and actived it in Salesforce and Zuora
    public static void orderItemsToUpdateInZuora(Set<Id> orderIds){
        //get the Pending Activation items
        List<OrderItem> pendingOrderItems = new OrderItem_Sel().getOrdersItemsPendingActivation(orderIds);
        system.debug('#### pendingOrderItems :: ' + pendingOrderItems);
        if(pendingOrderItems != null && pendingOrderItems.size() > 0){
            //process the Pending Activation items by batch
            IEC_ZuoraSubscriptionActivation_Batch batch = new IEC_ZuoraSubscriptionActivation_Batch(pendingOrderItems);
            Database.ExecuteBatch(batch, 10);
        }
    }
    //Update a Subscription status
    public static void updateZsubscriptions(list<OrderItem> orderItems){

        if(orderItems == null) return;

        //List of Subscription to Actived
        List<Zuora.zObject> lstZsubscriptionToUpdate = new List<Zuora.zObject>();
        system.debug('#### updateZsubscriptions :: ' + orderItems);
        for(OrderItem oi : orderItems){
            Zuora.zObject zSubscription = new Zuora.zObject('Subscription');
            zSubscription.setValue('Id', oi.Zuora_SubscriptionId__c);
            zSubscription.setValue('ContractEffectiveDate', Zuora.zUtil.getZuoraDate(Date.today()));
            zSubscription.setValue('ServiceActivationDate', Zuora.zUtil.getZuoraDate(Date.today()));
            zSubscription.setValue('ContractAcceptanceDate', Zuora.zUtil.getZuoraDate(Date.today()));
            lstZsubscriptionToUpdate.add(zSubscription);

            //Update the OrderItem Zuora subscription status
            oi.Zuora_Subscription_Status__c = '';
        }
        
        List<Zuora.zApi.SaveResult> zUpdate = (Test.isRunningTest()) ? null : IECZuoraHelper.updateApiCall(lstZsubscriptionToUpdate);

        update orderItems;
    }

    //Generate the invoice query string
    public static String getSubString(Set<String> itemIds)
    {
        List<String> whereItems = new List<String>(); 
        for(String i: itemIds)
            whereItems.add('OrderItemId__c = \'' + i + '\'');
        
        String zoql = 'SELECT Id FROM Subscription WHERE ' + String.join(whereItems, ' OR ');
        return zoql;
    }

    //Query existing Zuora Accounts base on the billing Contact
    public static map<String,Zuora.zObject> getZuoraAccounts(set<Id> ContactIds){
        
        Set<String> billToContactIds = Utility.IdToString(ContactIds);
        map<String,Zuora.zObject> zAccounts = new map<String,Zuora.zObject>();

        String query = getZaccountQuery(billToContactIds);
        List<Zuora.zObject> lstAccounts = new List<Zuora.zObject>();
        if(!Test.isRunningTest()){
            try{
                //Query the existing Account
                lstAccounts = IECZuoraHelper.queryApiCall(query);
            }catch(Exception ex){
                //Log Zuora Payment exception
                IEC_Error_Log__c errorLog = IECErrorLogger.createErrorLog('Order_Svc/getZuoraAccounts',query,ex.getMessage(),ex.getStackTraceString());
                IECErrorLogger.logErrors(new list<IEC_Error_Log__c>{errorLog});

                throw new OrderException(ex.getMessage());
            }
            
        }else{
            //lstAccounts = TestDataGenerator.generateZaccounts(ContactIds);
        }
        if(lstAccounts.size() > 0){
            for(Zuora.zObject zacc : lstAccounts){ zAccounts.put((String)zacc.getValue('CRMContactID__c'),zacc); }
        }
        
        return zAccounts;
    }

    //Generate the Zuora Account Query
    public static string getZaccountQuery(set<String> contactIds){
        List<String> whereItems = new List<String>(); 
        for(String i: contactIds)
            whereItems.add('CRMContactID__c = \'' + i + '\'');
        
        String zoql = 'SELECT Id,BillToId,SoldToId,DefaultPaymentMethodId,CRMContactID__c FROM Account WHERE ' + String.join(whereItems, ' OR ');
        return zoql;
    }

    //Generate the Zuora Account Query
    public static Zuora.zObject getZaccountById(String accountId){
        List<Zuora.zObject> zAccounts = new List<Zuora.zObject>();
        String zoql = 'SELECT Id,DefaultPaymentMethodId FROM Account WHERE Id =\''+ accountId +'\' ';
        if(!Test.isRunningTest()){
            zAccounts = IECZuoraHelper.queryApiCall(zoql);
        }else{
            zAccounts = TestDataGenerator.getZaccounts(accountId);
        }
        return zAccounts[0];
    }

    //Generate rate plan data base on the Order Item and list of Order Item charge
    public static List<Zuora.zObject> getRatePlanData(OrderItem orderItem, List<Order_Item_Charge__c> listOrderItemCharges, Map<String,String> zRatePlanChargeIds_zModel){
    
        List<Zuora.zObject> ratePlanData = new List<Zuora.zObject>();
        
        List<Zuora.zObject> ratePlanCharge = new List<Zuora.zObject>(); 
        
        //-- Unit Price RatePLan & Charge 
        Zuora.zObject rpc = new Zuora.zObject('RatePlanCharge');
        rpc.setValue('ProductRatePlanChargeId', orderItem.Zuora_Rate_Plan_Charge_Id__c);

        //Set the Quantity if the Zuora pricing model is not Flat fee OR Usage
        String zModel = zRatePlanChargeIds_zModel.get(orderItem.Zuora_Rate_Plan_Charge_Id__c);
        if(zModel != null && !zModel.contains('Flat') && !zModel.contains('Usage'))
            rpc.setValue('Quantity', orderItem.Quantity);
        rpc.setValue('Price', orderItem.UnitPrice);
        Zuora.zObject rpcd = new Zuora.zObject('RatePlanChargeData');
        rpcd.setValue('RatePlanCharge', rpc);
        ratePlanCharge.add(rpcd);

        //add the setup fee if applicable
        if (orderItem.Zuora_Setup_Fee_Charge_Id__c != null)
        {
            rpc = new Zuora.zObject('RatePlanCharge');
            rpc.setValue('ProductRatePlanChargeId', orderItem.Zuora_Setup_Fee_Charge_Id__c);
            rpc.setValue('Price', orderItem.Setup_Fee__c);
            rpcd = new Zuora.zObject('RatePlanChargeData');
            rpcd.setValue('RatePlanCharge', rpc);
            ratePlanCharge.add(rpcd);
        }
        
        //Set to zero the orther charges
        list<zqu__ProductRatePlanCharge__c> setValuesToZero = ProductRatePlanCharge_Sel.getChargesToSetToZero(orderItem.Zuora_Rate_Plan_Id__c,orderItem.Zuora_Rate_Plan_Charge_Id__c);
        for(zqu__ProductRatePlanCharge__c prpcZ : setValuesToZero)
            if (prpcZ.zqu__Model__c != null && (prpcZ.zqu__Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_PERCENTAGE) ||
                                                prpcZ.zqu__Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT)))
            {
                Zuora.zObject rpcz = new Zuora.zObject('RatePlanCharge');
                rpcz.setValue('ProductRatePlanChargeId', prpcz.zqu__ZuoraId__c);
                rpcz.setValue('Quantity', 0.00);
                
                if(prpcZ.zqu__Model__c != null && prpcZ.zqu__Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_PERCENTAGE)){
                    rpcz.setValue('DiscountPercentage', 0.00);
                }else if(prpcZ.zqu__Model__c != null && prpcZ.zqu__Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT)){
                    rpcz.setValue('DiscountAmount', 0.00);
                }else{
                    rpcz.setValue('Price', 0.00);
                }
                
                Zuora.zObject rpcdz = new Zuora.zObject('RatePlanChargeData');
                rpcdz.setValue('RatePlanCharge', rpcz);
                ratePlanCharge.add(rpcdz);
            }
        
        Zuora.zObject rp = new Zuora.zObject('RatePlan');
        rp.setValue('ProductRatePlanId', orderItem.Zuora_Rate_Plan_Id__c);
        Zuora.zObject rpd = new Zuora.zObject('RatePlanData');
        rpd.setValue('RatePlan', rp);
        rpd.setValue('RatePlanChargeData', ratePlanCharge);
        
        ratePlanData.add(rpd);

        //-- Set Discounts rate plan & charges 
        if(listOrderItemCharges != null && listOrderItemCharges.size() > 0){

            for(Order_Item_Charge__c c : listOrderItemCharges){

                Zuora.zObject discount_rpc = new Zuora.zObject('RatePlanCharge');
                discount_rpc.setValue('ProductRatePlanChargeId', c.Zuora_Rate_Plan_Charge_Id__c);

                Zuora.zObject discount_rpcd = new Zuora.zObject('RatePlanChargeData');
                discount_rpcd.setValue('RatePlanCharge', discount_rpc);
                
                Zuora.zObject discount_rp = new Zuora.zObject('RatePlan');
                discount_rp.setValue('ProductRatePlanId', c.Zuora_Rate_Plan_Id__c);

                Zuora.zObject discount_rpd = new Zuora.zObject('RatePlanData');
                
                discount_rpd.setValue('RatePlan', discount_rp);
                discount_rpd.setValue('RatePlanChargeData', new List<Zuora.zObject>{rpcd});
                
                ratePlanData.add(discount_rpd);
            }
        }
/*
        //Add Shipping charge if Charge_Shipping__c is true
        if(orderItem.Charge_Shipping__c || orderItem.Handling_charges__c != null){
            //Set Shipping rate plan charge
            Decimal orderItemShipAndHandling = 0.00;
            if(orderItem.Freight_Charge__c != null){
                orderItemShipAndHandling = orderItem.Freight_Charge__c;
            }

            //set the Handling amount
            if(orderItem.Handling_charges__c != null){ orderItemShipAndHandling = orderItemShipAndHandling + orderItem.Handling_charges__c; }

            Zuora.zObject rpcShip = new Zuora.zObject('RatePlanCharge');
            rpcShip.setValue('ProductRatePlanChargeId', Utility.getTextSetting('Zuora shipping Charge id'));
            rpcShip.setValue('Price', orderItemShipAndHandling);
            Zuora.zObject rpcdShip = new Zuora.zObject('RatePlanChargeData');
            rpcdShip.setValue('RatePlanCharge', rpcShip);
            ratePlanCharge.add(rpcdShip);

            //Set Shipping Rate plan
            Zuora.zObject rpShip = new Zuora.zObject('RatePlan');
            rpShip.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora shipping Plan id'));
            Zuora.zObject rpdShip = new Zuora.zObject('RatePlanData');
            rpdShip.setValue('RatePlan', rpShip);
            rpdShip.setValue('RatePlanChargeData', ratePlanCharge);

            ratePlanData.add(rpdShip);
        }

        //Set Tax rate plan charge
        Decimal orderItemTax = 0.00;
        if(orderItem.Tax__c != null){
            orderItemTax = orderItem.Tax__c;
        }
        Zuora.zObject rpcTax = new Zuora.zObject('RatePlanCharge');
        rpcTax.setValue('ProductRatePlanChargeId', Utility.getTextSetting('Zuora tax Charge id'));
        rpcTax.setValue('Price', orderItemTax);
        Zuora.zObject rpcdTax = new Zuora.zObject('RatePlanChargeData');
        rpcdTax.setValue('RatePlanCharge', rpcTax);
        ratePlanCharge.add(rpcdTax);

        //Set Shipping Rate plan
        Zuora.zObject rpTax = new Zuora.zObject('RatePlan');
        rpTax.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora tax Plan id'));
        Zuora.zObject rpdTax = new Zuora.zObject('RatePlanData');
        rpdTax.setValue('RatePlan', rpTax);
        rpdTax.setValue('RatePlanChargeData', ratePlanCharge);

        ratePlanData.add(rpdTax);
*/

        return ratePlanData;
    }


    /****************************************************************************************************
    Created by Kevin Ky 2015-10-01
        Return the list of Order status allows for order deletion
    ****************************************************************************************************/
    public static list<String> getStatusToPreventDeletion(){
        return Utility.getTextSettingToArray('Order status allows order deletion',',');
    }
    
    /****************************************************************************************************
    Created by Kevin Ky 2015-10-01
        Return the list of Order status allows for order modification
    ****************************************************************************************************/
    public static list<String> getStatusToPreventModification(){
        return Utility.getTextSettingToArray('Order status allows order modification',',');
    }
    
    /****************************************************************************************************
    Created by Kevin Ky 2015-10-01
        Return the list of Order fields to forbid modification
    ****************************************************************************************************/
    public static list<String> getOrderFieldsToForbidModification(){
        return Utility.getSeqTextSetting('Order fields to forbid modification',',').split(',');
    }
    

    /****************************************************************************************************
    Created by Kevin Ky 2015-10-05
        Return the list of profile that allows Order modification
    ****************************************************************************************************/
    public static list<String> getUserProfileAllowOrderModification(){
        return Utility.getTextSetting('Order User profile allows modification').split(',');
    }
    
    
    /****************************************************************************************************
        Created by Thai 2015-10-19
            Determine if to calculate shipping charges and taxes for an order
    ****************************************************************************************************/
    public static Boolean needToGetSAP_Freight_Tax(Id idOrder) {
        return (0 < [select count() from OrderItem where OrderId = :idOrder and (Freight_Charge__c = null or Tax__c = null) limit 1]);
    } //*** end of "needToGetSAP_Freight_Tax"
    
    
    /****************************************************************************************************
        Created by Thai 2015-10-13
            This function calls SAP to get freight charges and taxes for an order saved in database
    ****************************************************************************************************/
    public static String getSAP_Freight_Tax(Id idOrder) { return getSAP_Freight_Tax(idOrder, null); }
    public static String getSAP_Freight_Tax(Id idOrder, Id idOrderItem) {
        SAP_Freight_and_Tax.HTTPS_Port request = new SAP_Freight_and_Tax.HTTPS_Port();
        SAP_Freight_and_Tax.DT_SFDC_TaxShippingCalc_Response response;
        List<SAP_Freight_and_Tax.DT_SFDC_TaxShippingCalc_Response> lstResponse = new List<SAP_Freight_and_Tax.DT_SFDC_TaxShippingCalc_Response>();
        Map<String, List<SAP_Freight_and_Tax.Product_element>> outProductList = new Map<String, List<SAP_Freight_and_Tax.Product_element>>();
        SAP_Freight_and_Tax.Product_element outProduct;
        SAP_Freight_and_Tax.DT_SFDC_Partner soldToPartner, billToPartner, shipToPartner;
        Map<String, OrderItem> mapProduct_OrderItem = new Map<String, OrderItem>();
        OrderItem updOrderItem;
        
        //*** get order to update freight & tax
        Order updOrder = Order_Sel.getOrderForFreightAndTax(idOrder, idOrderItem);
        
        //*** get conversion information
        //SFDC_SAP_Mapping__c conversion = Order_Sel.getConversionSFDC_SAP(((updOrder.Type == 'Cart') ? 'Order' : updOrder.Type), updOrder.Source__c, updOrder.Order_Channel__c);
        SFDC_SAP_Mapping__c conversion = Order_Sel.getConversionSFDC_SAP(updOrder.Type, updOrder.Source__c, updOrder.Order_Channel__c);
        if (conversion == null)
            return Label.ErrMsg_Shipping_Tax_No_Conversion;
        
        system.debug('conversion ' + conversion);
        
        //*** build outbound products list
        outProductList.put('Order', new List<SAP_Freight_and_Tax.Product_element>());
        for (OrderItem item : updOrder.OrderItems) {
            //*** build outbound product
            outProduct = new SAP_Freight_and_Tax.Product_element();
            if (item.SAP_Product_Number__c.isNumeric())
                outProduct.ProductNumber = '0'.repeat(18 - item.SAP_Product_Number__c.length()) + item.SAP_Product_Number__c;
            else
                outProduct.ProductNumber = item.SAP_Product_Number__c;
            outProduct.Quantity = 0.00 + item.Quantity;   //*** force to have 2 decimals
            outProduct.TotalCost = item.SubTotal__c - (item.Discount__c == null ? 0 : item.Discount__c);
            outProduct.Currency_x = item.CurrencyIsoCode;
            outProduct.FreeShippingFlag = (item.Charge_Shipping__c != true);
            if (item.Use_Contract_when_ordered__c == true)
                outProductList.put(item.Id, new List<SAP_Freight_and_Tax.Product_element>{outProduct});
            else
                outProductList.get('Order').add(outProduct);
            
            //*** prepare for update later
            mapProduct_OrderItem.put(outProduct.ProductNumber, item);
        }
        if (outProductList.get('Order').size() == 0)
            outProductList.remove('Order');
        if (outProductList.size() == 0)
            return null;
        
        //*** callout to get freight & tax
        try {
            //*** prepare callout header
            if (request.inputHttpHeaders_x == null)
                request.inputHttpHeaders_x = new Map<String,String>(); 
            request.inputHttpHeaders_x.put('Authorization', Utility.getSAPauthorization());
            request.timeout_x = Utility.getIntegerSetting('SAP_CALL_TIMEOUT');
            request.endpoint_x = Utility.fixEndpointDomain(request.endpoint_x);
            
            //*** prepare partners
            soldToPartner = new SAP_Freight_and_Tax.DT_SFDC_Partner();
            soldToPartner.SAPPartnerID = updOrder.SoldToAccount_Partner_Number__c;
            billToPartner = new SAP_Freight_and_Tax.DT_SFDC_Partner();
            billToPartner.SAPPartnerID = updOrder.BillToContact_Partner_Number__c;
            shipToPartner = new SAP_Freight_and_Tax.DT_SFDC_Partner();
            //if (updOrder.ShipToContact_Partner_Number__c == null) {
            //    shipToPartner.AddressLine1 = Utility.truncate(updOrder.ShipTo_Street__c, 35);
            //    shipToPartner.City = Utility.truncate(updOrder.ShipTo_City__c, 35);
            //    shipToPartner.PostalCode = Utility.truncate(updOrder.ShipTo_PostalCode__c, 9);
            //    shipToPartner.Province = updOrder.ShipTo_State_SAP__c;
            //    shipToPartner.Country = updOrder.ShipTo_Country__c;
            //} else
                shipToPartner.SAPPartnerID = updOrder.ShipToContact_Partner_Number__c;

            //*** call out
            for (String outType : outProductList.keySet())
            {
                system.debug('outType ' + outType);
                system.debug('outProductList.get(outType) ' + outProductList.get(outType));
                
                system.debug('soldToPartner ' + soldToPartner);
                system.debug('shipToPartner ' + shipToPartner);
                system.debug('soldToPartner ' + soldToPartner);
                
                response = request.SI_SFDC_TaxShippingCalculation_SYNC((outType == 'Order' ? conversion.SAP_Order_Type__c : 'Contract')
                                                                     , (outType == 'Order' ? conversion.SAP_Sales_Org__c : '')
                                                                     , (outType == 'Order' ? conversion.SAP_Division__c : '')
                                                                     , (outType == 'Order' ? conversion.SAP_Distribition_Channel__c : '')
//                                                                     , conversion.SAP_Sales_Org__c, conversion.SAP_Division__c, conversion.SAP_Distribition_Channel__c
                                                                     , soldToPartner, shipToPartner, billToPartner, outProductList.get(outType));
                system.debug('response ' + response);
                if (response.Error != null)
                    break;
                lstResponse.add(response);
            }
            
            //*** return error message if applicable
            if (response.Error != null)
                return String.format(Label.ErrMsg_Shipping_Tax_SAP_Error, new List<String>{response.Error.Type_x, response.Error.Code, response.Error.Message});
            
            //*** set tax and freight on order item and update at the end
            for (Integer i1 = 0; i1 < lstResponse.size(); i1++)
                for (SAP_Freight_and_Tax.CalculationResult_element calc : lstResponse[i1].CalculationResult) {
                    updOrderItem = mapProduct_OrderItem.get(calc.ProductNumber);
                    if (updOrderItem != null) {
                        updOrderItem.Freight_Charge__c = ((calc.ShippingCharge == null) ? 0 : calc.ShippingCharge);
                        updOrderItem.Tax__c = ((calc.Tax == null) ? 0 : calc.Tax);
                        updOrderItem.Handling_charges__c = calc.SpecialHandlingCharge;
                    }

                }
            update mapProduct_OrderItem.values();

            //*** return success indicator: null if call is for whole order OR a JSON string of order item record if call is for a specific order item
            if (idOrderItem != null)
                return JSON.serialize([select Id, Freight_Charge__c, Tax__c,Handling_charges__c, Total__c from OrderItem where Id = :updOrderItem.id limit 1][0]);
            else
                return JSON.serialize(mapProduct_OrderItem.values());
        } catch (Exception e) {
            return String.format(Label.ErrMsg_Shipping_Tax_General_Error, new List<String>{String.valueOf(e)});
        } //*** end of call out
    } //*** end of "getSAP_Freight_Tax"


    /****************************************************************************************************
        Created by Thai 2015-10-13
            This function calls SAP to get freight charges and taxes for shopping cart
    ****************************************************************************************************/
    public static String getSAP_Freight_Tax_for_DTO(String orderType, String orderSource, String orderChannel, String soldToPartnerId, String billToPartnerId, String shipToPartnerId, List<OrderItem_DTO> listItem) {
     
        SAP_Freight_and_Tax.HTTPS_Port request = new SAP_Freight_and_Tax.HTTPS_Port();
        SAP_Freight_and_Tax.DT_SFDC_TaxShippingCalc_Response response;
        List<SAP_Freight_and_Tax.DT_SFDC_TaxShippingCalc_Response> lstResponse = new List<SAP_Freight_and_Tax.DT_SFDC_TaxShippingCalc_Response>();
        Map<String, List<SAP_Freight_and_Tax.Product_element>> outProductList = new Map<String, List<SAP_Freight_and_Tax.Product_element>>();
        SAP_Freight_and_Tax.Product_element outProduct;
        SAP_Freight_and_Tax.DT_SFDC_Partner soldToPartner, billToPartner, shipToPartner;
        Map<String, OrderItem_DTO> mapProduct_OrderItem = new Map<String, OrderItem_DTO>();
        OrderItem_DTO updOrderItem;
        
        //*** get conversion information
        //SFDC_SAP_Mapping__c conversion = Order_Sel.getConversionSFDC_SAP(((orderType == 'Cart') ? 'Order' : orderType), orderSource, orderChannel);
        SFDC_SAP_Mapping__c conversion = Order_Sel.getConversionSFDC_SAP(orderType, orderSource, orderChannel);
        
        if (conversion == null)
            return Label.ErrMsg_Shipping_Tax_No_Conversion;
    
        
        //*** build outbound products list
        outProductList.put('Order', new List<SAP_Freight_and_Tax.Product_element>());
        for (OrderItem_DTO item : listItem) {
            //*** build outbound product
            outProduct = new SAP_Freight_and_Tax.Product_element();
            if (item.sapProductCode.isNumeric())
                outProduct.ProductNumber = '0'.repeat(18 - item.sapProductCode.length()) + item.sapProductCode;
            else
                outProduct.ProductNumber = item.sapProductCode;
            outProduct.Quantity = 0.00 + item.quantity;   //*** force to have 2 decimals
            outProduct.TotalCost = item.subTotal - ((item.discountAmount == null) ? 0 : item.discountAmount);
            outProduct.Currency_x = UserInfo.getDefaultCurrency();
            outProduct.FreeShippingFlag = (item.chargeShipping != true); 
            if (item.isContractProduct == true) outProductList.put(item.orderItemId, new List<SAP_Freight_and_Tax.Product_element>{outProduct});
            else outProductList.get('Order').add(outProduct);
            
            
            //*** prepare for update later
            mapProduct_OrderItem.put(outProduct.ProductNumber, item);
        }
        if (outProductList.get('Order').size() == 0)
            outProductList.remove('Order');
        if (outProductList.size() == 0)
            return null;
        
        //*** callout to get freight & tax
        try {
            //*** prepare callout header
            if (request.inputHttpHeaders_x == null)
                request.inputHttpHeaders_x = new Map<String,String>(); 
            request.inputHttpHeaders_x.put('Authorization', Utility.getSAPauthorization());
            request.timeout_x = Utility.getIntegerSetting('SAP_CALL_TIMEOUT');
            request.endpoint_x = Utility.fixEndpointDomain(request.endpoint_x);
            
            //*** prepare partners
            soldToPartner = new SAP_Freight_and_Tax.DT_SFDC_Partner();
            soldToPartner.SAPPartnerID = soldToPartnerId;
            billToPartner = new SAP_Freight_and_Tax.DT_SFDC_Partner();
            billToPartner.SAPPartnerID = billToPartnerId;
            shipToPartner = new SAP_Freight_and_Tax.DT_SFDC_Partner();
            shipToPartner.SAPPartnerID = shipToPartnerId;
            
            //*** call out
            for (String outType : outProductList.keySet())
            {
                
                response = request.SI_SFDC_TaxShippingCalculation_SYNC((outType == 'Order' ? conversion.SAP_Order_Type__c : 'Contract')
                                                                     , (outType == 'Order' ? conversion.SAP_Sales_Org__c : '')
                                                                     , (outType == 'Order' ? conversion.SAP_Division__c : '')
                                                                     , (outType == 'Order' ? conversion.SAP_Distribition_Channel__c : '')
//                                                                     , conversion.SAP_Sales_Org__c, conversion.SAP_Division__c, conversion.SAP_Distribition_Channel__c
                                                                     , soldToPartner, shipToPartner, billToPartner, outProductList.get(outType));
                
                if (response.Error != null)
                    break;
                lstResponse.add(response);
            }
            
            //*** return error message if applicable
            if (response.Error != null)
                return String.format(Label.ErrMsg_Shipping_Tax_SAP_Error, new List<String>{response.Error.Type_x, response.Error.Code, response.Error.Message});
            
            //*** set tax and freight on order item and update at the end
            for (Integer i1 = 0; i1 < lstResponse.size(); i1++)
                for (SAP_Freight_and_Tax.CalculationResult_element calc : lstResponse[i1].CalculationResult) {
                    updOrderItem = mapProduct_OrderItem.get(calc.ProductNumber);
                    if (updOrderItem != null) {
                        updOrderItem.shippingAmount = ((calc.ShippingCharge == null) ? 0 : calc.ShippingCharge);
                        updOrderItem.taxAmount = ((calc.Tax == null) ? 0 : calc.Tax);
                        updOrderItem.HandlingCharges = calc.SpecialHandlingCharge;
                        
                        updOrderItem.totalAmount = updOrderItem.subTotal - ((updOrderItem.discountAmount == null) ? 0 : updOrderItem.discountAmount) + updOrderItem.shippingAmount + updOrderItem.taxAmount + ((updOrderItem.HandlingCharges == null) ? 0 : updOrderItem.HandlingCharges);
                    }
                }
            
            //*** return null for success indicator
            return null;
        } catch (Exception e) {
            return String.format(Label.ErrMsg_Shipping_Tax_General_Error, new List<String>{String.valueOf(e)});
        } //*** end of call out
    } //*** end of "getSAP_Freight_Tax_for_DTO"


    /****************************************************************************************************
    Created by Kevin Ky 2015-10-26
        Return a Map of product Id with the Quantity
    ****************************************************************************************************/
    public static Map<String, Decimal> getItemsInCookie()
    {
        Map<String,Decimal> prodId_Qty = new Map<String,Decimal>();

        //get the frist Cookie
        Cookie orderCookie = IECOrder_Svc.getOrderCookie(1);

        if(orderCookie != null){
            String allCookiesValues = '';
            //Get the cookie name
            String cookieName = orderCookie.getName();

            Integer nbs;

            try{
                nbs = Integer.valueOf(cookieName.split('_')[1]);
                Boolean done = false;

                //Get all the product code by Quantity in all Cookies
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
                                    
                                    if(prodIdsQties[1].contains(',')){ prodIdsQties[1] = prodIdsQties[1].replace(',','.'); }
                                    //Put the product code as a key and the quatity as a value
                                    Decimal qty = Decimal.valueOf(prodIdsQties[1]);
                                    prodId_Qty.put(prodIdsQties[0],qty);
                                }catch(Exception ex){}
                                
                            }
                        }
                    }
                }

            }catch(Exception ex){
                System.debug(ex.getStackTraceString());
            }
        }
        return prodId_Qty;
    }

    //Return cookie value by Name
    public static String cookieValue(Integer nb){
        String value;
        Cookie cookie = ApexPages.currentPage().getCookies().get('IECOrders_' + nb);
        if(cookie != null){
            value = cookie.getValue();
        }
        return value;
    }


    /****************************************************************************************************
        Created by CGI, Thai 2015-11-06
            Return order status corresponding to a payment type
    ****************************************************************************************************/
    public static String getOrderStatusByPaymentType(String paymentType) {
        String paidStatusForPaymentType = ',' + Utility.getTextSetting('Order Paid Status for Payment Types') + ',';
        return (paymentType == null ? 'New' : (!paidStatusForPaymentType.containsIgnoreCase(',' + paymentType + ',') ? 'Ready for SAP' : 'Paid'));
    } //*** end of "getOrderStatusByPaymentType"


    /****************************************************************************************************
        Created by CGI, Thai 2015-11-09
            Determine if an order is paid based on payment type
    ****************************************************************************************************/
    public static Boolean isOrderPaidByPaymentType(String paymentType) {
        String paidStatusForPaymentType = ',' + Utility.getTextSetting('Order Paid Status for Payment Types') + ',';
        return (paymentType == null ? false : paidStatusForPaymentType.containsIgnoreCase(',' + paymentType + ','));
    } //*** end of "isOrderPaidByPaymentType"


    //public static PriceDetail_DTO getCouponPriceDetail(String couponCode, PriceInfo_DTO priceModel)
    //{
    //    for(PriceDetail_DTO pd: priceModel.couponPrice)
    //    {
    //        if(pd.discountName == couponCode)
    //        {
    //            return pd;
    //        }
    //    }
        
    //    return null;
    //}




    /****************************************************************************************************
        Created by Thai 2015-11-20
            Calculate price & discounts for an order or order items in order
    ****************************************************************************************************/
    public static String setPriceToOrder(Order updOrder, Map<String, PriceInfo_DTO> mapProductNumber_Price)
    {
        return setPriceToOrder(updOrder, mapProductNumber_Price, true);
    }
    public static String setPriceToOrder(Order updOrder, Map<String, PriceInfo_DTO> mapProductNumber_Price, Boolean resetShippingAndTax)
    {
        return setPriceToOrderItem([select Id, PricebookEntryId, Quantity, Coupon__c, UnitPrice, Charge_Shipping__c
                                    from OrderItem
                                    where OrderId = :updOrder.Id], mapProductNumber_Price, updOrder.ShipToContactId, resetShippingAndTax);
    }
    public static String setPriceToOrderItem(List<OrderItem> lstOrderItem, Map<String, PriceInfo_DTO> mapProductNumber_Price, Id idContact)
    {
        return setPriceToOrderItem(lstOrderItem, mapProductNumber_Price, idContact, true);
    }
    public static String setPriceToOrderItem(List<OrderItem> lstOrderItem, Map<String, PriceInfo_DTO> mapProductNumber_Price, Id idContact, Boolean resetShippingAndTax)
    {
         System.debug('idContact::'+idContact);
        List<Order_Item_Charge__c> lstZDiscountCharge = new List<Order_Item_Charge__c>();
        List<Id> lstOrderItemToDeleteZCharge = new List<Id>();
        PriceInfo_DTO price;
        Decimal discountAmount, runningTotal, oldUnitPrice;
        Boolean oldChargeShippingFlag, donotChargeFlatFee;
        Map<Id, PricebookEntry> mapId_PBE = new Map<Id, PricebookEntry>();
        Order_Svc exe = new Order_Svc();
        
        //*** safety check
        if (lstOrderItem == null || lstOrderItem.size() == 0){ return null; }

        //*** get product information from price book entry
        for (OrderItem oi : lstOrderItem)
            mapId_PBE.put(oi.PricebookEntryId, null);
        for (PricebookEntry pbe : [select Id, Product2Id, Product2.SAP_Material_Number__c, Product2.Charge_Shipping__c
                                   from PricebookEntry
                                   where Id in :mapId_PBE.keySet()])
            mapId_PBE.put(pbe.Id, pbe);
        
        
        //*** get information for region/country/coupon discounts
        Contact contactInfo = User_Sel.getContactDiscountInfo(idContact);
        String customerType = User_Sel.getCustomerType(idContact);
        
        system.debug('lstOrderItem ' + lstOrderItem);
        //*** calculate price & discounts
        for (OrderItem oi : lstOrderItem)
        {
            //*** prepare to delete existing Zuora charges for order item
            if (oi.Id != null)
                lstOrderItemToDeleteZCharge.add(oi.Id);
            
            //*** get price plans for product
            price = mapProductNumber_Price.get(mapId_PBE.get(oi.PricebookEntryId).Product2.SAP_Material_Number__c);
            if (price == null) break;
            
            //*** reset detail of order item to default
            oldUnitPrice = oi.UnitPrice;
            oldChargeShippingFlag = oi.Charge_Shipping__c;
            oi.UnitPrice = null;
            oi.Charge_Shipping__c = mapId_PBE.get(oi.PricebookEntryId).Product2.Charge_Shipping__c;
            donotChargeFlatFee = false;
            
            //*** set unit price based on customer type volume price
            exe.setUnitPriceFromPlan(oi, price.customerPrice, customerType, true);
            //if (oi.UnitPrice == null) exe.setUnitPriceFromPlan(oi, price.preSalePrice, null, false);
            //if (oi.UnitPrice == null) exe.setUnitPriceFromPlan(oi, price.countryPrice, null, false);
            //if (oi.UnitPrice == null) exe.setUnitPriceFromPlan(oi, price.regionPrice, null, false);
            if (oi.UnitPrice == null) exe.setUnitPriceFromPlan(oi, price.standardPrice, null, false);
            if (oi.UnitPrice == null)
            {
                //*** try to set unit price from flat fee
                exe.setUnitPriceFromFlatFee(oi, price.customerPrice);
                if (oi.UnitPrice == null) exe.setUnitPriceFromFlatFee(oi, price.standardPrice);
                if (oi.UnitPrice != null) donotChargeFlatFee = true;
            }
            if (oi.UnitPrice == null)
            {
                //*** stop further calculation if no unit price -> should not happen
                oi.UnitPrice = oldUnitPrice;
                oi.Charge_Shipping__c = oldChargeShippingFlag;
                break;
            }
            
            //*** get all discounts -> beware the type of discount should match with prefix of discount type for SAP
            System.debug('contactInfo::'+contactInfo);
            oi.Discount__c = 0;
            exe.setDiscountFromPlan(oi, price.customerPrice, 'CustomerType', lstZDiscountCharge, customerType, true);
            exe.setDiscountFromPlan(oi, price.regionPrice, 'Region', lstZDiscountCharge, contactInfo.Account.Region_formula__c, true);
            exe.setDiscountFromPlan(oi, price.countryPrice, 'Country', lstZDiscountCharge, contactInfo.Account.ShippingCountry, true);
            exe.setDiscountFromPlan(oi, price.preSalePrice, 'PreSales', lstZDiscountCharge, null, false);
            exe.setDiscountFromPlan(oi, exe.getCouponPlan(oi.Coupon__c, price.couponPrice), 'Coupon', lstZDiscountCharge, null, false);
            exe.setDiscountFromPlan(oi, price.standardPrice, 'Discount', lstZDiscountCharge, null, false);
            
            //-- Setup Fee : search first in customer price then in standard
            if (!donotChargeFlatFee && oi.UnitPrice == null)
            {
                exe.setFlatFeeFromPlan(oi, price.standardPrice, null);
                exe.setFlatFeeFromPlan(oi, price.customerPrice, customerType);
            }
            
            
            //*** apply discounts
            //discountAmount = 0;
            //runningTotal = oi.UnitPrice * oi.Quantity;
            //for (Order_Item_Charge__c discount : lstZDiscountCharge)
            //    if (discount.Name == oi.PricebookEntryId)
            //        if (discount.Discount_Percentage__c != null)
            //            runningTotal -= (runningTotal * discount.Discount_Percentage__c / 100);
            //        else
            //            discountAmount += discount.Discount_Amount__c;
            //oi.Discount__c = (oi.UnitPrice * oi.Quantity) - runningTotal + discountAmount;
            oi.Discount__c = 0;
            for (Order_Item_Charge__c discount : lstZDiscountCharge)
                if (discount.Name == oi.PricebookEntryId){ oi.Discount__c += discount.Discount_Amount__c; }
            if (oi.Discount__c == 0){ oi.Discount__c = null; }
            
            //*** reset shipping & tax
            if (resetShippingAndTax)
            {
                oi.Freight_Charge__c = null;
                oi.Handling_charges__c = null;
                oi.Tax__c = null;
            }
        }
        
        //*** save changes
        Savepoint sp = Database.setSavepoint();
        try
        {
            upsert lstOrderItem;
            delete [select Id from Order_Item_Charge__c where Order_Item__c in :lstOrderItemToDeleteZCharge];
            //*** link discount charges to new order items via price book entry
            for (Order_Item_Charge__c discount : lstZDiscountCharge)
                if (discount.Order_Item__c == null)
                    for (OrderItem oi : lstOrderItem)
                        if (discount.Name == oi.PricebookEntryId) { discount.Order_Item__c = oi.Id; break; }

            insert lstZDiscountCharge;
            return null;  //*** success
        } catch (Exception e)
        {
            system.debug('Exception ' + e.getStackTraceString());
            Database.rollback(sp);
            return String.valueOf(e);
        }
    } //*** end of "setPriceToOrder"
    
    void setFlatFeeFromPlan(OrderItem item, List<PriceDetail_DTO> lstPrice, String strDiscountType)
    {
        //*** safety check
        if (lstPrice == null || lstPrice.size() == 0)
            return;

        for (PriceDetail_DTO price : lstPrice)
        {
            if(price.setupFee != null && (strDiscountType == null || (strDiscountType !=null && price.discountName ==strDiscountType)))
            {
                item.Setup_Fee__c = price.setupFee;
                item.Zuora_Setup_Fee_Plan_Id__c = price.setupFeePlanId;
                item.Zuora_Setup_Fee_Charge_Id__c = price.setupFeeChargeId;
                break;
            }
        }
    }
    
    
    /****************************************************************************************************
        Created by Thai 2015-11-20
            Set unit price to an order item
    ****************************************************************************************************/
    void setUnitPriceFromPlan(OrderItem item, List<PriceDetail_DTO> lstPrice, String strDiscountName, Boolean shouldCheckDiscountName)
    {
        //*** safety check
        if (lstPrice == null || lstPrice.size() == 0)
            return;
        //PriceDetail_DTO price = lstPrice[0];  //*** only consider the first price
        
        for (PriceDetail_DTO price : lstPrice)
        {
            if (!shouldCheckDiscountName || (shouldCheckDiscountName && price.discountName != null && strDiscountName != null && price.discountName.equalsIgnoreCase(strDiscountName)))
            {
                //*** try to set unit price from volume price in plan
                //*** when FIRST volume quantity FROM is greater than 1 then Zuora adds a record with 0 quantity FROM and price -> to exclude
                if (price.VolumePrice != null)
                {
                    for (VolumePrice_DTO vp : price.VolumePrice)
                    {
                        if (vp.qtyFrom != 0 && vp.price != 0 && vp.qtyFrom <= item.Quantity && (vp.qtyTo == null || item.Quantity <= vp.qtyTo))
                        {
                            item.UnitPrice = vp.price;
                            item.Zuora_Rate_Plan_Id__c = vp.planId;
                            item.Zuora_Rate_Plan_Charge_Id__c = vp.chargeId;
                            break;
                        }
                    }
                }

                //*** try to set unit price from unit price in plan if not set yet
                if (item.UnitPrice == null && price.UnitPrice != null)
                {
                    item.UnitPrice = price.UnitPrice;
                    item.Zuora_Rate_Plan_Id__c = price.UnitPricePlanId;
                    item.Zuora_Rate_Plan_Charge_Id__c = price.UnitPriceChargeId;
                }
            }
            
            if (item.UnitPrice != null)
            {
                if (!String.isBlank(price.setupFeeChargeId) && price.setupFee != null && price.setupFee > 0)
                {
                    item.Setup_Fee__c = price.setupFee;
                    item.Zuora_Setup_Fee_Plan_Id__c = price.setupFeePlanId;
                    item.Zuora_Setup_Fee_Charge_Id__c = price.setupFeeChargeId;
                }
                break;
            }
        }
    } //*** end of "setUnitPriceFromPlan"
    
    
    /****************************************************************************************************
        Created by Thai 2016-03-29
            Set unit price from flat fee to an order item
    ****************************************************************************************************/
    void setUnitPriceFromFlatFee(OrderItem item, List<PriceDetail_DTO> lstPrice)
    {
        //*** safety check
        if (lstPrice == null || lstPrice.size() == 0)
            return;
        
        for (PriceDetail_DTO price : lstPrice)
        {
            if (price.setupFee != null)
            {
                item.UnitPrice = price.setupFee;
                item.Zuora_Rate_Plan_Id__c = price.setupFeePlanId;
                item.Zuora_Rate_Plan_Charge_Id__c = price.setupFeeChargeId;
                break;
            }
        }
    } //*** end of "setUnitPriceFromPlanFee"
    
    
    /****************************************************************************************************
        Created by Thai 2015-11-20
            Prepare Zuora discount charge record and free shipping
            Input discount type must match with prefix of discount type for SAP interface
    ****************************************************************************************************/
    void setDiscountFromPlan(OrderItem item, List<PriceDetail_DTO> lstPrice, String strDiscountType, List<Order_Item_Charge__c> lstZDiscountCharge
                           , String strDiscountName, Boolean shouldCheckDiscountName)
    {
        //*** safety check
        if (lstPrice == null || lstPrice.size() == 0)
            return;
        //PriceDetail_DTO price = lstPrice[0];  //*** only consider the first price
        
        for (PriceDetail_DTO price : lstPrice)
            if (!shouldCheckDiscountName || (shouldCheckDiscountName && price.discountName != null && strDiscountName != null && price.discountName.equalsIgnoreCase(strDiscountName)))
            {
                //*** free shipping
                if (price.isFreeShipping != null && price.isFreeShipping){ item.Charge_Shipping__c = false; }

                //if(item.Discount__c == null)
                //    item.Discount__c= 0;
                
                //*** try to set unit price from volume price in plan
                if (price.discountPercentage != null)
                {
                    Decimal discount = ((item.UnitPrice * item.Quantity) - item.Discount__c) * price.discountPercentage / 100;
                    item.Discount__c += discount;
                    lstZDiscountCharge.add(new Order_Item_Charge__c(Name=item.PricebookEntryId, Order_Item__c=item.Id, Discount_Type__c=strDiscountType
                                                                  , Discount_Amount__c=discount
                                                                  , Zuora_Rate_Plan_Id__c=price.discountPlanId, Zuora_Rate_Plan_Charge_Id__c=price.discountChargeId));
                }
                else if (price.discountAmount != null)
                {
                    lstZDiscountCharge.add(new Order_Item_Charge__c(Name=item.PricebookEntryId, Order_Item__c=item.Id, Discount_Type__c=strDiscountType
                                                                  , Discount_Amount__c=price.discountAmount
                                                                  , Zuora_Rate_Plan_Id__c=price.discountPlanId, Zuora_Rate_Plan_Charge_Id__c=price.discountChargeId));
                }
            }
    } //*** end of "setDiscountFromPlan"
    
    
    /****************************************************************************************************
        Created by Thai 2015-11-20
            Get the coupon plan corresponding for specified coupon
    ****************************************************************************************************/
    List<PriceDetail_DTO> getCouponPlan(String strCoupon, List<PriceDetail_DTO> couponPrice)
    {
        //*** safety check
        if (strCoupon == null || couponPrice == null || couponPrice.size() == 0)
            return null;
        
        //*** find coupon in the list of discount coupons
        for (PriceDetail_DTO price : couponPrice)
            if (price.discountName != null && strCoupon != null && price.discountName.equalsIgnoreCase(strCoupon))
                return new List<PriceDetail_DTO>{price};
        
        //*** no coupon found
        return null;
    } //*** end of "getCouponPlan"
    

    /****************************************************************************************************
        Created by Thai 2015-11-20
            Determine if a coupon is valid to use
    ****************************************************************************************************/
    public static Boolean isCouponValid(String idProduct, String strCoupon, List<PriceDetail_DTO> couponPrice, Id idContact)
    {
        System.debug('Coupon Code Validation:');
        System.debug('idProduct='+idProduct+' strCoupon='+strCoupon + ' idContact='+idContact);
        System.debug('couponPrice::'+couponPrice);

        //*** safety check
        if (strCoupon == null || couponPrice == null || couponPrice.size() == 0)
            return false;

        //*** find coupon in the list of discount coupons
        Integer maxUsage = Utility.getIntegerSetting('Order Limit Coupon Used');
        if (maxUsage <= 0)
            maxUsage = 1;
        for (PriceDetail_DTO price : couponPrice)
            if (price.discountName != null && strCoupon != null && price.discountName.equalsIgnoreCase(strCoupon))
                //*** coupon found -> allow to use only if not used yet
                try
                {
                    return (maxUsage > [select count()
                                        from Coupon_Used__c
                                        where Account__c in (select AccountId from Contact where Id = :idContact)
                                          and Product__c = :idProduct
                                          and Coupon__c = :strCoupon]);
                }
                catch (Exception e){ return false; }

        //*** no coupon found
        return false;
    } //*** end of "isCouponValid"

    

    /****************************************************************************************************
        Created by Thai 2015-11-24
            Get unit price from rate plans for a product
    ****************************************************************************************************/
    /*public static Decimal getUnitPrice(PriceInfo_DTO price)
    {
        return getUnitPrice(price, 1);
    }*/

    public static Decimal getUnitPrice(PriceInfo_DTO price, String customerType)
    {
        return getUnitPrice(price, 1, customerType);
    }

    public static Decimal getUnitPrice(PriceInfo_DTO price, Decimal quantity, String customerType)
    {
        Decimal UnitPrice = null;
        Order_Svc exe = new Order_Svc();

        if (price != null)
        {
            UnitPrice = exe.getUnitPriceFromPlan(price.customerPrice, quantity,customerType, true); 
            if (UnitPrice == null) UnitPrice = exe.getUnitPriceFromPlan(price.standardPrice, quantity, null, false);
            
            //*** try to get unit price from flat fee
            if (UnitPrice == null) UnitPrice = exe.getUnitPriceFromFlatFee(price.customerPrice, customerType, true);
            if (UnitPrice == null) UnitPrice = exe.getUnitPriceFromFlatFee(price.standardPrice, null, false);
        }
        return UnitPrice;
    } 



    /*public static Decimal getUnitPrice(PriceInfo_DTO price, Decimal quantity)
    {
        Decimal UnitPrice = null;
        Order_Svc exe = new Order_Svc();

        if (price != null)
        {
            UnitPrice = exe.getUnitPriceFromPlan(price.customerPrice, quantity,'Member', true); // User_Sel.getCustomerType(UserInfo.getUserId())
            //if (UnitPrice == null) UnitPrice = exe.getUnitPriceFromPlan(price.preSalePrice, quantity, null, false);
            //if (UnitPrice == null) UnitPrice = exe.getUnitPriceFromPlan(price.countryPrice, quantity, null, false);
            //if (UnitPrice == null) UnitPrice = exe.getUnitPriceFromPlan(price.regionPrice, quantity, null, false);
            if (UnitPrice == null) UnitPrice = exe.getUnitPriceFromPlan(price.standardPrice, quantity, null, false);
        }
        return UnitPrice;
    } //*** end of "getUnitPrice"*/

    public static Decimal getRegularPrice(PriceInfo_DTO price, Decimal quantity)
    {
        Decimal UnitPrice = null;
        Order_Svc srv = new Order_Svc();

        if (price != null)
        {
            UnitPrice = srv.getUnitPriceFromPlan(price.standardPrice, quantity, null, false); 
            if (UnitPrice == null) UnitPrice = srv.getUnitPriceFromFlatFee(price.standardPrice, null, false);   //*** try to get unit price from flat fee
        }
        return UnitPrice;
        //return (price != null)? srv.getUnitPriceFromPlan(price.standardPrice, quantity, null, false) : null;
    }

    public static Decimal getCustomerPrice(PriceInfo_DTO price, Decimal quantity, String customerType)
    {
        Decimal UnitPrice = null;
        Order_Svc srv = new Order_Svc();

        if (price != null)
        {
            UnitPrice = srv.getUnitPriceFromPlan(price.customerPrice, quantity, customerType, true); 
            if (UnitPrice == null) UnitPrice = srv.getUnitPriceFromFlatFee(price.customerPrice, customerType, true);   //*** try to get unit price from flat fee
        }
        return UnitPrice;
        //return (price != null)? srv.getUnitPriceFromPlan(price.customerPrice, quantity,customerType, true): null; 
    }

    //public static Decimal getDiscountedPrice(PriceInfo_DTO priceData, Decimal quantity, Customer_DTO customer)
    //{
    //    Decimal discountedPrice; 


    //    return discountedPrice;
    //}


    /****************************************************************************************************
        Created by Thai 2015-11-24
            Get unit price from a rate plan
    ****************************************************************************************************/
    Decimal getUnitPriceFromPlan(List<PriceDetail_DTO> lstPrice, Decimal quantity, String strDiscountName, Boolean shouldCheckDiscountName)
    {
        //*** safety check
        if (lstPrice == null || lstPrice.size() == 0)
            return null;
        //PriceDetail_DTO price = lstPrice[0];  //*** only consider the first price
        
        for (PriceDetail_DTO price : lstPrice)
        {
            if (!shouldCheckDiscountName || (shouldCheckDiscountName && price.discountName != null && strDiscountName != null && price.discountName.equalsIgnoreCase(strDiscountName)))
            {
                //*** get unit price from volume price in plan
                //*** when FIRST volume quantity FROM is greater than 1 then Zuora adds a record with 0 quantity FROM and price -> to exclude
                if (price.VolumePrice != null)
                    for (VolumePrice_DTO vp : price.VolumePrice)
                        if (vp.qtyFrom != 0 && vp.price != 0 && vp.qtyFrom <= quantity && (vp.qtyTo == null || quantity <= vp.qtyTo))
                            return vp.price;
                
                //*** get unit price from plan
                if (price.UnitPrice != null)
                    return price.UnitPrice;
            }
        }

        //*** no unit price found
        return null;
    } //*** end of "getUnitPriceFromPlan"


    /****************************************************************************************************
        Created by Thai 2016-03-29
            Get unit price from flat fee plan
    ****************************************************************************************************/
    Decimal getUnitPriceFromFlatFee(List<PriceDetail_DTO> lstPrice, String strDiscountName, Boolean shouldCheckDiscountName)
    {
        //*** safety check
        if (lstPrice == null || lstPrice.size() == 0)
            return null;
        
        for (PriceDetail_DTO price : lstPrice)
        {
            if (!shouldCheckDiscountName || (shouldCheckDiscountName && price.discountName != null && strDiscountName != null && price.discountName.equalsIgnoreCase(strDiscountName)))
                if (price.setupFee != null)
                    return price.setupFee;
        }

        //*** no unit price found
        return null;
    } //*** end of "getUnitPriceFromFlatFee"
    
    
    /****************************************************************************************************
        Created by Thai 2015-11-27
            Get list of discount plans
    ****************************************************************************************************/
    public static List<PriceDetail_DTO> getDiscountPlans(List<PriceDetail_DTO> lstPrice, String strDiscountName, Boolean shouldCheckDiscountName)
    {
        List<PriceDetail_DTO> lstDiscount = new List<PriceDetail_DTO>();
        
        if (lstPrice != null && lstPrice.size() > 0)
            for (PriceDetail_DTO price : lstPrice)
                if (!shouldCheckDiscountName || (shouldCheckDiscountName && price.discountName != null && strDiscountName != null && price.discountName.equalsIgnoreCase(strDiscountName)))
                    if (price.discountAmount != null || price.discountPercentage != null)
                        lstDiscount.add(price);
        
        return lstDiscount;
    } //*** end of "getDiscountPlans"
    
    
    /****************************************************************************************************
        Created by Thai 2015-11-20
            Get all discounts for a type of price for a DTO -> no checking of discount type
    ****************************************************************************************************/
    void getDiscountFromPlanDTO(OrderItem_DTO item, List<Decimal> calc, List<PriceDetail_DTO> lstPrice)
    {
        if (lstPrice != null && lstPrice.size() > 0)
            for (PriceDetail_DTO price : lstPrice)
            {
                //*** free shipping
                if (price.isFreeShipping != null && price.isFreeShipping)
                    item.chargeShipping = false;
                
                //*** discount
                if (price.discountPercentage != null)
                    calc.add(price.discountPercentage);
                else if (price.discountAmount != null)
                    calc[0] += price.discountAmount;
            }
    } //*** end of "getDiscountFromPlanDTO"


    /****************************************************************************************************
        Created by Thai 2015-11-20
            Calculate price & discounts for an order item DTO
    ****************************************************************************************************/
    
    public static void setPriceToOrderItemDTO(OrderItem_DTO item)
    {
        setPriceToOrderItemDTO(item, User_Sel.getCustomerType(UserInfo.getUserId()));
    }
    
    public static void setPriceToOrderItemDTO(OrderItem_DTO item, String sCustomerType)
    {
        
        Order_Svc exe = new Order_Svc();
        Decimal runningTotal;
        List<Decimal> calc = new List<Decimal>();
        
        item.unitPrice = getUnitPrice(item.PriceInfo, item.quantity, sCustomerType);

        System.debug('item.UnitPrice: ' + item.unitPrice);
        System.debug('item.quantity: ' + item.quantity);

        item.subTotal = item.quantity * item.unitPrice;
        calc.add(0);   //*** item 0 contains discount amount, items after are percentages
        exe.getDiscountFromPlanDTO(item, calc, item.PriceInfo.customerPrice);
        exe.getDiscountFromPlanDTO(item, calc, item.PriceInfo.regionPrice);
        exe.getDiscountFromPlanDTO(item, calc, item.PriceInfo.countryPrice);
        exe.getDiscountFromPlanDTO(item, calc, item.PriceInfo.preSalePrice);
        exe.getDiscountFromPlanDTO(item, calc, exe.getCouponPlan(item.couponCode, item.PriceInfo.couponPrice));
        exe.getDiscountFromPlanDTO(item, calc, item.PriceInfo.standardPrice);
        runningTotal = item.subTotal;
        for (Integer i = 1; i < calc.size(); i++)
            runningTotal -= (runningTotal * calc[i] / 100);
            
        item.discountAmount = item.subTotal - runningTotal + calc[0];

            
    } //*** end of "setPriceToOrderItemDTO"


    /****************************************************************************************************
        Created by Thai 2015-11-20
            Save coupons used for an order
    ****************************************************************************************************/
    public static void saveCouponUsed(Id idOrder, Id idContact)
    {
        List<Coupon_Used__c> lstCoupon = new List<Coupon_Used__c>();
        Id idAccount = [select AccountId from Contact where Id = :idContact limit 1][0].AccountId;

        for (OrderItem oi : [select Id, Product__c, Coupon__c from OrderItem where OrderId = :idOrder and Coupon__c != null]) {
            String uniqueKey = oi.Id + '_' + oi.Coupon__c;

            lstCoupon.add(
                new Coupon_Used__c(
                    Account__c = idAccount,
                    Product__c = oi.Product__c,
                    Coupon__c  = oi.Coupon__c,
                    Order__c   = idOrder,
                    Order_Product__c = oi.Id,
                    Unique_Key__c = uniqueKey
                )
            );
        }

        if (lstCoupon.size() > 0) {
            //insert lstCoupon;
            upsert lstCoupon Unique_Key__c;
        }
    } //*** end of "saveCouponUsed"


    /****************************************************************************************************
        Created by Thai 2015-12-04
            Set SAP order number to orders without this number
    ****************************************************************************************************/
    public static void updateOrderNumber(Map<Id, String> mapOrderId_OrderNumber)
    {
        if (mapOrderId_OrderNumber != null && mapOrderId_OrderNumber.size() > 0)
        {
            List<Order> lstOrder = [select Id, (select id, SAP_Contract_Number__c from OrderItems where SAP_Contract_Number__c != null) from Order where Id in :mapOrderId_OrderNumber.keySet() and SAP_Order_Number__c = null];
            if (lstOrder.size() > 0)
            {
                List<Order> toUpdate = new List<Order>();
                for (Order o : lstOrder){
                    o.SAP_Order_Number__c = mapOrderId_OrderNumber.get(o.Id);
                    if (!String.isBlank(o.SAP_Order_Number__c)) {
                        toUpdate.add(o);
                        //Verified if the SAP order number is not a orderItem contract number before update the Order
                        if(o.OrderItems != null && o.OrderItems.size() > 0){
                            for(OrderItem oi : o.OrderItems){
                                if(o.SAP_Order_Number__c.contains(oi.SAP_Contract_Number__c)){
                                    toUpdate.remove(toUpdate.size() - 1);
                                    break;
                                }
                            }
                        }
                    }
                }
                update toUpdate;
                //update lstOrder;
            }
        }
    } //*** end of "updateOrderNumber"

    /****************************************************************************************************
    Created by Kevin 2015-4-06
        Create order and order items for auto renewal
    ****************************************************************************************************/
    public static List<OrderItem> createAutoRenewalOrders(IEC_Event_Release__c eventRelease, List<IEC_Event_Subscription__c> subscriptions){
        system.debug('##### createAutoRenewalOrders :: ');
        List<Order> lstOrder = new List<Order>();
        map<Id,Contact> contactMap = new map<Id,Contact>();
        map<Id,Id> userIdByContactId = new map<Id,Id>();
        map<Id,List<IEC_Event_Subscription__c>> contactId_EventSubscription = new map<Id,List<IEC_Event_Subscription__c>>();
        List<IEC_Event_Release_Log__c> lstErrors = new List<IEC_Event_Release_Log__c>();

        List<OrderItem> orderItems = new List<OrderItem>();

        system.debug('##### eventRelease :: '+eventRelease);
        system.debug('##### subscriptions :: '+subscriptions);

        //Get a map of Event subscription by subscriber
        for(IEC_Event_Subscription__c subscription : subscriptions){
            if(!contactId_EventSubscription.containsKey(subscription.Subscriber__c)){
                contactId_EventSubscription.put(subscription.Subscriber__c, new List<IEC_Event_Subscription__c>());
            }
            contactId_EventSubscription.get(subscription.Subscriber__c).add(subscription);
        }
        
        //Get the details about contacts
        if(contactId_EventSubscription.size() > 0)
            contactMap = Contact_Sel.getContactById(contactId_EventSubscription.keySet());

        //get the related contact user Id
        userIdByContactId = new User_Sel().getUserByContact(contactId_EventSubscription.keySet());

        Set<String> paidStatus = new Set<String>(Utility.getTextSettingToArray('Order Paid Status for Payment Types', ','));

        for(IEC_Event_Subscription__c subscription : subscriptions){
            //Make sure that the Customer is allowd to auto renew
            if(paidStatus.contains(subscription.Default_Payment_Type__c)){
                //get the order owner id
                Id orderOwnerId;
                if(userIdByContactId.containsKey(subscription.Subscriber__c)){ orderOwnerId =  userIdByContactId.get(subscription.Subscriber__c); }

                //Create new order for customer
                Order order = createNewOrder(IECConstants.ORDER_TYPE_AUTORENEWAL, null, eventRelease.Id, subscription.Id, contactMap.get(subscription.Subscriber__c), orderOwnerId);
                if(order != null)
                    lstOrder.add(order);
                else
                    lstErrors.add(IEC_EventReleaseLog_Svc.logError('Customer do not have billing or shipping address', '', null, eventRelease.Id, 'Create order', subscription.Subscriber__c, subscription.Id, false));
            }else{
                String msg = null;
                if(subscription.Default_Payment_Type__c == null) msg = 'Customer do not have a payment type';
                else msg = 'Customer not allowed for rewal for ' + subscription.Default_Payment_Type__c;
                
                lstErrors.add(IEC_EventReleaseLog_Svc.logError(msg, '', null, eventRelease.Id, 'Create order', subscription.Subscriber__c, subscription.Id, false));
            }
        }
        system.debug('##### lstOrder :: '+lstOrder);
        system.debug('##### lstErrors :: '+lstErrors); 
        if(lstOrder.size() > 0){

            set<Id> orderIds = new set<Id>();
            //Insert the new orders
            Database.SaveResult[] srList = Database.insert(lstOrder, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                // Operation was successful, so get the ID of the record that was processed
                if (sr.isSuccess()) { orderIds.add(sr.getId()); }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        lstErrors.add(IEC_EventReleaseLog_Svc.logError('The following error has occurred when creating a new order. ' + err.getMessage(), String.valueOf(err.getStatusCode()), null, eventRelease.Id, 'Create order', null, false));
                    }
                }
            }

            //Get the inserted orders
            list<Order> insertedOrders = Order_Sel.getOrdersById(orderIds);
            system.debug('##### insertedOrders :: '+insertedOrders);
            //Create orderItem for each order
            set<Id> orderItemIds = new set<Id>();
            if(insertedOrders != null && insertedOrders.size() > 0){
                orderItemIds = createOrderItemsForAutoRenewal(eventRelease, insertedOrders, contactId_EventSubscription);
            }
            system.debug('##### orderItemIds :: '+orderItemIds);
            //Set the event release Sales amount and quatity
            Map<Id,OrderItem> orderItemsById = new OrderItem_Sel().getOrdersItemsById(orderItemIds);
            orderItems.addAll(orderItemsById.values());
        }

        //Log errors
        if(lstErrors.size() > 0) insert lstErrors;
        system.debug('##### orderItems :: '+orderItems);
        system.debug('##### lstErrors :: '+lstErrors); 
        return orderItems;

    }

    //Create a new Order
    public static Order createNewOrder(String type, Id campaignId, Id eventReleaseId, Id subscriptionId, Contact contact, Id userId){

        //Get the contact billto location
        Id billToLocationId = contact.BillTo_Location__c;

        //Get the Contact shipTo location
        Id shipToLocationId = contact.ShipTo_Location__c;

        //Be sure that locations are not null
        if(billToLocationId == null || shipToLocationId == null){ return null; }

        Order order = new Order();
        order.AccountId                             =   contact.BillTo_Location__r.Account__c;
        order.SoldToAccount_Name__c                 =   contact.BillTo_Location__r.Account_Name__c;
        order.SoldTo_Location__c                    =   contact.BillTo_Location__r.Account__r.SoldTo_Location__c;
        order.Type                                  =   type;
        order.EffectiveDate                         =   system.today();
        order.Status                                =   Utility.getTextSetting('vfOrder-DefaultStatus');
        order.Source__c                             =   (campaignId != null) ? Utility.getTextSetting('Campaign-DefaultSource') : Utility.getTextSetting('Event Renewal Source');
        order.Order_Channel__c                      =   (campaignId != null) ? Utility.getTextSetting('vfOrder-DefaultChannel') : Utility.getTextSetting('Event Renewal Channel');
        order.Pricebook2Id                          =   new Pricebook_Sel().getStandardPriceBook().Id;
        order.BillToContactId                       =   contact.Id;
        order.ShipToContactId                       =   contact.Id;
        order.Campaign__c                           =   campaignId;
        order.IEC_Event_Release__c                  =   eventReleaseId;
        order.IEC_Event_Subscription__c             =   subscriptionId;

        //BillTo informations
        order.BillTo_Location__c                    =   billToLocationId;
        order.BillToAccount__c                      =   contact.AccountId;
        order.BillToAccount_Name__c                 =   contact.Account.Name;
        order.BillToContact_Name__c                 =   contact.Name;
        order.BillToContact_Phone__c                =   contact.BillTo_Location__r.Phone__c;
        order.BillToContact_Email__c                =   contact.BillTo_Location__r.Email__c;
        order.BillingStreet                         =   contact.BillTo_Location__r.Street__c;
        order.BillingCity                           =   contact.BillTo_Location__r.City__c;
        order.BillingPostalCode                     =   contact.BillTo_Location__r.ZipCode__c;
        order.BillingCountry                        =   contact.BillTo_Location__r.Country__c;
        order.BillingCountryCode__c                 =   contact.BillTo_Location__r.ISO_Country_Code__c;
        order.BillingState                          =   contact.BillTo_Location__r.State__c;
        order.BillingStateCode__c                   =   contact.BillTo_Location__r.ISO_State_Code__c;
        order.BillToContact_VAT_Number__c           =   contact.BillTo_Location__r.VAT_Number__c;

        order.BillToContact_Salutation__c           =   contact.Salutation;
        order.BillToContact_First_Name__c           =   contact.FirstName;
        order.BillToContact_Last_Name__c            =   contact.LastName;

        //Ship To informations
        order.ShipTo_Location__c                    =   shipToLocationId;
        order.ShipToAccount__c                      =   contact.AccountId;
        order.ShipToAccount_Name__c                 =   contact.Account.Name;
        order.ShipToContact_Name__c                 =   contact.Name;
        order.ShipToContact_Phone__c                =   contact.ShipTo_Location__r.Phone__c;
        order.ShipToContact_Email__c                =   contact.ShipTo_Location__r.Email__c;
        order.ShippingStreet                        =   contact.ShipTo_Location__r.Street__c;
        order.ShippingCity                          =   contact.ShipTo_Location__r.City__c;
        order.ShippingPostalCode                    =   contact.ShipTo_Location__r.ZipCode__c;
        order.ShippingCountry                       =   contact.ShipTo_Location__r.Country__c;
        order.ShippingCountryCode__c                =   contact.ShipTo_Location__r.ISO_Country_Code__c;
        order.ShippingState                         =   contact.ShipTo_Location__r.State__c;
        order.ShippingStateCode__c                  =   contact.ShipTo_Location__r.ISO_State_Code__c;

        order.ShipToContact_Salutation__c           =   contact.Salutation;
        order.ShipToContact_First_Name__c           =   contact.FirstName;
        order.ShipToContact_Last_Name__c            =   contact.LastName;

        if(userId != null)
            order.OwnerId = userId;
        
        return order;
    }

    //Create Order items for Auto renewal
    public static set<Id> createOrderItemsForAutoRenewal(IEC_Event_Release__c eventRelease, List<Order> lstOrder, map<Id,List<IEC_Event_Subscription__c>> contactId_EventSubscription){

        set<Id> orderItemsId = new set<Id>();

        //Set the product id
        Id prodId = (eventRelease.Swapped_Product__c != null) ? eventRelease.Swapped_Product__c : eventRelease.Last_Version__c;

        //Get product details
        Product2 product = new Product_Sel().getProductById(new set<Id>{prodId}).values()[0];

        //Set the pricebookEntry
        Pricebook2 stdPriceBook = new Pricebook_Sel().getStandardPriceBook();
        Map<Id, PricebookEntry> pricebookEntryByProductId = new PricebookEntry_Sel().getPricebookEntryByProductId(stdPriceBook.Id, new set<Id>{prodId});

        //get Item by order
        List<OrderItem> itemsToInsert = new List<OrderItem>();

        //Create the Order Items
        for(Order order : lstOrder){
            //Get the Event subscription
            List<IEC_Event_Subscription__c> subscriptions = contactId_EventSubscription.get(order.BillToContactId);

            for(IEC_Event_Subscription__c subscription : subscriptions){
                if(subscription.id == order.IEC_Event_Subscription__c){
                    PricebookEntry pbe = pricebookEntryByProductId.get(prodId);
                    if(pbe == null) continue;
                    itemsToInsert.add(
                        new OrderItem(
                            OrderId = order.Id, PriceBookEntryId = pbe.Id, Quantity = subscription.Quantity__c, UnitPrice = pbe.UnitPrice,
                            Charge_Shipping__c = product.Charge_Shipping__c
                        )
                    );
                }
            }
            
        }

        //insert orderITems
        if(itemsToInsert.size() > 0)
            orderItemsId =  OrderItem_Svc.insertOrderItems(itemsToInsert);

        //Get Product price info
        Map<String, PriceInfo_DTO> productCode_priceInfo = new Product_Sel().getProductPriceInfo(new Set<String>{eventRelease.Product_Number__c}, null, null, null, true);
        
        //Set the orderItems price
        for(Order order : lstOrder){
            setPriceToOrder(order,productCode_priceInfo);
        }

        return orderItemsId;
    }

    //Update IEC Event Subscription for Event renewal
    public static void updateEventSubcriptions(List<Order> lstOrder, map<Id,Order> oldOrderMap){
        
        //set<Id> subscriptionId = new set<Id>();
        //set<Id> releaseId = new set<Id>();
        Map<Id,IEC_Event_Release__c> eventReleaseMap = new Map<Id,IEC_Event_Release__c>();
        Map<Id,IEC_Event_Subscription__c> eventSubscriptionMap = new Map<Id,IEC_Event_Subscription__c>();
        List<IEC_Event_Subscription__c> lstEventSubscriptionToUpdate = new List<IEC_Event_Subscription__c>();

        for(Order cOrder : lstOrder){
            if(cOrder.IEC_Event_Subscription__c != null && cOrder.IEC_Event_Release__c != null && cOrder.Is_Paid__c 
                && cOrder.Is_Paid__c != oldOrderMap.get(cOrder.Id).Is_Paid__c)
            {
                //subscriptionId.add(cOrder.IEC_Event_Subscription__c);
                eventReleaseMap.put(cOrder.IEC_Event_Release__c, new IEC_Event_Release__c());
                eventSubscriptionMap.put(cOrder.IEC_Event_Subscription__c, new IEC_Event_Subscription__c());
            }
        }

        //Get the Release record
        if(!eventReleaseMap.isEmpty()){ eventReleaseMap = new IEC_EventRelease_Sel().getEventReleaseById(eventReleaseMap.keySet()); }

        if(!eventSubscriptionMap.isEmpty()){ eventSubscriptionMap = new IEC_EventSubscription_Sel().getEventSubscriptionById(eventSubscriptionMap.keySet()); }

        for(Order cOrder : lstOrder){
            if(cOrder.IEC_Event_Subscription__c != null && cOrder.IEC_Event_Release__c != null && cOrder.Is_Paid__c 
                && cOrder.Is_Paid__c != oldOrderMap.get(cOrder.Id).Is_Paid__c)
            {
                IEC_Event_Release__c eventRelease;
                IEC_Event_Subscription__c eventSubscription;

                if(eventReleaseMap.size() > 0)
                    eventRelease = eventReleaseMap.get(cOrder.IEC_Event_Release__c);
                if(eventSubscriptionMap.size() > 0)
                    eventSubscription = eventSubscriptionMap.get(cOrder.IEC_Event_Subscription__c);
                
                //Set the Event Subscription product with the latest one and the subscriber
                if(eventRelease != null && eventSubscription != null){
                    eventSubscription.Product__c = (eventRelease.Swapped_Product__c != null) ? eventRelease.Swapped_Product__c : eventRelease.Last_Version__c;
                    eventSubscription.Subscriber__c = cOrder.BillToContactId;
                    lstEventSubscriptionToUpdate.add(eventSubscription);
                }

            }
        }

        if(!lstEventSubscriptionToUpdate.isEmpty()){ update lstEventSubscriptionToUpdate; }

    }


    /****************************************************************************************************
        Created by CGI, Thai 2016-05-06
            Set order items to paid if order is paid
    ****************************************************************************************************/
    public static void setOrderItemToPaid(List<Order> newList, List<Order> oldList)
    {
        Set<Id> setPaidOrderId = new Set<Id>();
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        Integer i1;

        //*** prepare to update order item to paid
        for (i1 = 0; i1 < newList.size(); i1++)
            if (oldList[i1].Is_Paid__c == false && newList[i1].Is_Paid__c == true)
                setPaidOrderId.add(oldList[i1].Id);
        
        //*** update
        if (setPaidOrderId.size() > 0)
        {
            lstOrderItem = [select Id from OrderItem where OrderId in :setPaidOrderId and IEC_Is_Paid__c = false];
            if (lstOrderItem.size() > 0)
            {
                for (i1 = 0; i1 < lstOrderItem.size(); i1++)
                    lstOrderItem[i1].IEC_Is_Paid__c = true;
                update lstOrderItem;
            }
        }
    } //*** end of "setOrderItemToPaid"


    /** Ecommerce Enhancements R2 **/
    public static void setOrderAcceptedPaymentMethods(List<Order> newList, Map<Id,Order> oldList) {
        Map<Id,Order> orderMap = new Map<Id,Order>();
        Set<Id> orderIdSet = new Set<Id>();
        Map<Id,Set<String>> orderAcceptedPaymentMethodsMap = new Map<Id,Set<String>>();
        Map<Id,List<OrderItem>> orderItemMap = new Map<Id,List<OrderItem>>();

        for (Order order : newList) {
            orderIdSet.add(order.Id);
            orderMap.put(order.Id, order);
        }

        for (OrderItem orderItem : [SELECT Id, OrderId, Accepted_Payment_Methods__c FROM OrderItem WHERE OrderId IN :orderIdset]) {
            List<OrderItem> orderItemList;

            if (orderItemMap.containsKey(orderItem.OrderId) == false) {
                orderItemMap.put(orderItem.OrderId, new List<OrderItem>());
            }

            orderItemList = orderItemMap.get(orderItem.OrderId);

            orderItemList.add(orderItem);
        }

        for (Id orderId : orderIdSet) {
            Order order = orderMap.get(orderId);
            Set<String> orderPaymentMethodSet = new Set<String>();
            List<OrderItem> orderItemList = orderItemMap.get(orderId);

            if (orderItemList != null) {
                Integer counter = 0;

                for (OrderItem orderItem : orderItemList) {
                    Set<String> orderItemPaymentMethodSet;

                    if (orderItem.Accepted_Payment_Methods__c != null && orderItem.Accepted_Payment_Methods__c.trim().equals('') == false) {
                        orderItemPaymentMethodSet = new Set<String>(orderItem.Accepted_Payment_Methods__c.split(';'));
                    } else {
                        orderItemPaymentMethodSet = new Set<String>();
                    }

                    if (counter == 0) {
                        orderPaymentMethodSet.addAll(orderItemPaymentMethodSet);
                    } else {
                        orderPaymentMethodSet.retainAll(orderItemPaymentMethodSet);
                    }

                    counter++;
                }
            }

            if (orderPaymentMethodSet.isEmpty() == false) {
                List<String> orderPaymentMethodsList = new List<String>();

                orderPaymentMethodsList.addAll(orderPaymentMethodSet);

                order.Accepted_Payment_Methods__c = String.join(orderPaymentMethodsList, ';');
            } else {
                order.Accepted_Payment_Methods__c = null;
            }
        }
    }

     /*******************************************************************
        Updating IEC SAP INVOICE when ORDER Status is Payment Confirmed
        
        INC295559
         checking if all the orders related to the Invoice are with status Payment Confirmed.
         IF Yes :
            - we will change the IEC SAP Invoice status to Zuora Ready
         IF No:
            - nothing happens with the IEC SAP Invoice Status
        
      *******************************************************************/
    public static void sapInvoiceStatusUpdate(Map<Id, Order> newMap, Map<Id, Order> oldMap){
        system.debug('sap invoice status update starting...');
     
        Set<Id> orderId = new Set<Id>();
        List<IEC_SAP_Invoice__c> sapInvoice = new List<IEC_SAP_Invoice__c>();
        List<IEC_SAP_Invoice__c> sapInvoiceToUpdate = new List<IEC_SAP_Invoice__c>();

        Set<Id> sapInvoiceId = new Set<Id>();
        List<Order> orderList = new List<Order>();
        Boolean stopSapInvoiceUpdate = false;

        for (Order order : newMap.values()) {
                Order oldOrder = oldMap.get(order.Id);

                if(order.Status == IECConstants.ORDER_PAYMENT_CONFIRMED
                    && oldOrder != null && oldOrder.Status != order.Status 
                    && (Order.Payment_Type__c == IECConstants.PaymentThresholdType_BankTransfer || Order.Payment_Type__c == IECConstants.PaymentThresholdType_ICH)){
                    
                    if(order.SAP_Invoice__c != null)
                        sapInvoiceId.add(order.SAP_Invoice__c);
                }
        }

        system.debug('##### orderItems :: '+sapInvoiceId);
        
        if(sapInvoiceId.size() > 0){
            orderList = [SELECT id, SAP_Invoice__c, Status FROM Order where SAP_Invoice__c IN :sapInvoiceId];
            system.debug('##### orderList :: '+orderList); 
            if(!orderList.isEmpty()){
                for(Order o : orderList){
                    if(o.Status != IECConstants.ORDER_PAYMENT_CONFIRMED){
                        stopSapInvoiceUpdate = true;
                    }
                }
            }
            
            system.debug('stopSapInvoiceUpdate ' + stopSapInvoiceUpdate);
            
            if(!stopSapInvoiceUpdate){ // all the related orders have the status Payment Confirmed
                sapInvoice = [SELECT id, Order__c, Billing_Account__r.Zuora__External_Id__c FROM IEC_SAP_Invoice__c where Id IN :sapInvoiceId];

                if(!sapInvoice.isEmpty()){
                    for(IEC_SAP_Invoice__c sapInv : sapInvoice){
                        sapInv.Status__c = IECConstants.IECSAPInvoice_Status_ZuoraReady;
                        sapInv.Payment_Date__c = Date.today();
                        sapInv.Zuora_Billing_Account_ID__c = sapInv.Billing_Account__r.Zuora__External_Id__c;
                        sapInvoiceToUpdate.add(sapInv);
                    }
                }
                if(!sapInvoiceToUpdate.isEmpty())
                    update sapInvoiceToUpdate;
            }
        }
        system.debug('##### sapInvoiceToUpdate ' + sapInvoiceToUpdate);

    }

}