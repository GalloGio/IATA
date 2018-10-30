/****************************************************************************************************
    Created by Kevin Ky 2015-09-23
****************************************************************************************************/
public without sharing class Order_Sel extends Selector{

    public static final Integer SIX_MONTHS_DAYS = 180;
    public static final Integer THREE_YEARS = 3;
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> 
        {
            Order.Id,
            Order.Name, 
            Order.PoNumber,
            Order.Type,
            Order.OrderNumber,
            Order.Status,
            Order.Is_Paid__c,
            Order.IEC_Order_Previous_Type__c, //To handle order conversion
            Order.EffectiveDate,
            Order.EndDate,
            Order.AccountId,
            Order.CurrencyIsoCode,
            Order.Order_Channel__c,
            Order.Source__c,
            Order.Payment_Type__c,
            Order.Taxes__c,
            Order.Invoice_Text__c,
            Order.Sales_Order_Remark__c,
            Order.Shipping_Instruction__c,
            Order.Internal_Remark__c,
            Order.Total_Freight_Charge__c,
            Order.Total_handling_charges__c,
            Order.Discount_Amount__c,
            Order.SubTotal_Amount__c,
            Order.Total_Amount__c,
            Order.TotalAmount,
            Order.SAP_Order_Number__c,

            Order.BillToContactId,
            Order.BillingStreet,
            Order.BillingCity, 
            Order.BillingPostalCode,
            Order.BillingState, 
            Order.BillingCountry,  
            Order.BillToAccount__c,
            Order.BillToAccount_Name__c,
            Order.BillToContact_Email__c,
            Order.BillToContact_First_Name__c,
            Order.BillToContact_Last_Name__c,
            Order.BillToContact_Name__c,
            Order.BillToContact_Phone__c,
            Order.BillToContact_Salutation__c,
            Order.BillToContact_Partner_Number__c,
            Order.BillingStateCode_SAP__c,
            Order.BillingStateCode__c,
            Order.BillingCountryCode__c,
            //Order.BillTo_VAT_Number__c,
            Order.BillToContact_VAT_Number__c,


            Order.SoldToAccount_Name__c,            
            Order.SoldToAccount_Partner_Number__c, 
            
            Order.ShipToContactId,
            Order.ShippingStreet,
            Order.ShippingCity, 
            Order.ShippingPostalCode,
            Order.ShippingState, 
            Order.ShippingCountry,
            Order.ShipToAccount__c,
            Order.ShipToAccount_Name__c,
            Order.ShipToContact_Email__c,
            Order.ShipToContact_First_Name__c,
            Order.ShipToContact_Last_Name__c,
            Order.ShipToContact_Name__c,
            Order.ShipToContact_Phone__c,
            Order.ShipToContact_Salutation__c,
            Order.ShipToContact_Partner_Number__c,
            Order.ShipTo_same_BillTo__c,
            Order.ShippingStateCode_SAP__c,
            Order.ShippingStateCode__c,
            Order.ShippingCountryCode__c,
            //Order.ShipTo_VAT_Number__c,
            Order.ShipToContact_VAT_Number__c,

            Order.Zuora_Credit_Card_Id__c,
            Order.Payment_Transaction_Number__c,
            Order.Zuora_Transaction_Id__c,
            Order.PoDate,
            Order.Status_Reason__c,
            Order.SoldTo_Location__c,
            Order.BillTo_Location__c,
            Order.ShipTo_Location__c,
            //Order.BillTo_Street__c,
            Order.BillTo_Address__c,
            Order.ShipTo_Address__c,
            Order.IEC_Event_Subscription__c,
            //Order.IEC_Shipping_Instruction_attention__c,
            //Order.IEC_Shipping_Instruction_phone__c,
            //Order.IEC_Shipping_Instruction_email__c,
            Order.IEC_Credit_Card_Expiration__c,
            Order.IEC_Credit_Card_Holder_Name__c,
            Order.IEC_Credit_Card_Mask_Number__c,
            Order.IEC_Credit_Card_Type__c,
            Order.IEC_Zuora_ST_InvoiceId__c,
            Order.IEC_Zuora_ST_InvoiceNumber__c,
            Order.IEC_Zuora_ST_SubscriptionId__c,
            Order.IEC_Zuora_ST_SubscriptionNumber__c,
            Order.Payment_Gateway_Response__c,
            Order.Accepted_Payment_Methods__c
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Order.sObjectType;
    }

    public List<Order> getQuotesOlderThan3Months()
    {
        String qType = 'Quote';
        Set<String> qStatus2Clean = new Set<String>{'New'};
        Date threeMonthsAgo = Date.today().addMonths(-1 * Utility.getIntegerSetting('Quote Cleanup Window'));

        String query = String.format(
            'SELECT {0}  ' + 
            'FROM {1} ' + 
            'WHERE Type = :qType AND Status IN :qStatus2Clean  AND  EffectiveDate < :threeMonthsAgo' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        
        return Database.query(query);
    }


    /****************************************************************************************************
    Created by Kevin Ky 2015-09-23
        return an order status by order Id
    ****************************************************************************************************/
    public static map<Id,String> getOrderStatusById(set<Id> orderIds){
        
        map<Id,String> orderId_Status = new map<Id,String>();
        list<Order> lstOrder;
        if(!Test.isRunningTest()){
            lstOrder = [SELECT id, Status From Order where id in :orderIds];
        }else{
            lstOrder = [SELECT id, Status From Order where id in :orderIds limit 10];
        }
        
        if(lstOrder != null && lstOrder.size() > 0){
            for(Order ord : lstOrder){
                orderId_Status.put(ord.Id,ord.Status);
            }
        }
        return orderId_Status;
    }
    
    /****************************************************************************************************
    Created by Kevin Ky 2015-09-23
        return an order status by order Id
    ****************************************************************************************************/
    public map<Id,Order> getOrderByStatus(set<Id> orderIds){
        return new map<Id,Order>((List<Order>) selectSObjectById(orderIds));
    }

    /**
     * Returns a list of payment threshold by payment type
     */
    public static map<String,IEC_Payment_Threshold__c> getPaymentMethodThresholdByType() {
        
        map<String,IEC_Payment_Threshold__c> paymentMethodNameByThreshold = new map<String,IEC_Payment_Threshold__c>();
        List<IEC_Payment_Threshold__c> lstPaymentThreshold = [SELECT Name, Min_amount__c, Max_amount__c, Payment_Type__c 
                 FROM IEC_Payment_Threshold__c ];
        for(IEC_Payment_Threshold__c paymentThreshold : lstPaymentThreshold){
            paymentMethodNameByThreshold.put(paymentThreshold.Payment_Type__c,paymentThreshold);
        }

        return paymentMethodNameByThreshold;

    }


    /****************************************************************************************************
    Created by Kevin Ky 2015-09-25
        return an order by order Id
    ****************************************************************************************************/
    public static list<Order> getOrdersById(set<Id> orderIds){
        return [SELECT 
                    Id,Name, AccountId,Status,ShipToContact_Name__c,
                    BillToContact.FirstName,BillToContact.LastName,BillToContact.Email,BillToContact.Country__c,BillToContactId,
                    BillToContact_First_Name__c,BillToContact_Last_Name__c,BillToContact_Email__c,BillToContact_Phone__c,
                    BillingCountryCode__c,BillingStateCode__c,BillingCity,BillingPostalCode,BillingStreet,
                    ShipToContact.FirstName,ShipToContact.LastName,ShipToContact.Email,ShipToContact.Country__c,ShipToContactId,
                    ShipToContact_First_Name__c,ShipToContact_Last_Name__c,ShipToContact_Email__c,ShipToContact_Phone__c,ShippingCountryCode__c,
                    ShippingCountry,ShippingState,Campaign__c, //IEC_Shipping_Instruction_attention__c,
                    ShippingStateCode__c,ShippingCity,ShippingPostalCode,ShippingStreet,
                    ActivatedDate,EffectiveDate, IEC_Event_Subscription__c,ShipToAccount_Name__c,
                    Payment_Type__c,Nb_Payment_Failure__c
                    , BillToAccount_Name__c, BillToContact_Name__c, OrderNumber, Is_Paid__c
                    ,SubTotal_Amount__c, Discount_Amount__c, Taxes__c, Total_Freight_Charge__c, Total_handling_charges__c, Total_Amount__c,
                    Payment_Gateway_Response__c, Accepted_Payment_Methods__c
                From Order 
                Where id in :orderIds
               ];
    }
    
    /****************************************************************************************************
        Created by Thai 2015-10-04
            Return orders for accounts or for billed to or shippinged to contacts
    ****************************************************************************************************/
    public static List<Order> getOrderForAccountOrContact(List<Id> accountIds, List<Id> contactIds) {
        String SOQL = ' select Id, OrderNumber, EffectiveDate, Order_Channel__c, Source__c, Status, AccountId, BillToContactId, ShipToContactId'
                    + ' from Order where ';
        if (accountIds != null)
            SOQL += 'AccountId in :accountIds';
        else if (contactIds != null)
            SOQL += 'BillToContactId in :contactIds or ShipToContactId in :contactIds';
        SOQL += ' order by EffectiveDate desc, CreatedDate desc limit 1000';

        return Database.query(SOQL);
    } //*** end of "getOrderForAccountOrContact"
    
    /****************************************************************************************************
        Created by Thai 2015-10-04
            Return 1 order for Visualforce page
    ****************************************************************************************************/
    public static Order getOrderForVF(String orderId){
        return [select Id, EffectiveDate, Order_Channel__c, OrderNumber, Source__c, Status_Reason__c, Status, Type, IEC_Order_Previous_Type__c, Internal_Remark__c, Sales_Order_Remark__c, Bulk_Order_Info__c
                     , Payment_Type__c, Name, SAP_Order_Number__c,Nb_Payment_Failure__c,Total_handling_charges__c 
                     , Taxes__c, Total_Freight_Charge__c, TotalAmount, Total_Amount__c, Discount_Amount__c, SubTotal_Amount__c
                     , AccountId, SoldToAccount_Name__c, SoldToAccount_Partner_Number__c, PoNumber
                     , BillToContactId, BillToAccount__c, BillToAccount_Name__c, BillToContact_Email__c
                     , BillToContact_First_Name__c, BillToContact_Last_Name__c, BillToContact_Salutation__c
                     , BillToContact_Name__c, BillToContact_Partner_Number__c, BillToContact_Phone__c, BillToContact_VAT_Number__c
                     , BillingStreet, BillingCity, BillingState, BillingStateCode__c, BillingPostalCode, BillingCountry, BillingCountryCode__c, Invoice_Text__c
                     , ShipToContactId, ShipToAccount__c, ShipToAccount_Name__c, ShipToContact_Email__c
                     , ShipToContact_First_Name__c, ShipToContact_Last_Name__c, ShipToContact_Salutation__c
                     , ShipToContact_Name__c, ShipToContact_Partner_Number__c, ShipToContact_Phone__c, ShipToContact_VAT_Number__c
                     , ShippingStreet, ShippingCity, ShippingState, ShippingStateCode__c, ShippingPostalCode, ShippingCountry, ShippingCountryCode__c
                     //, IEC_Shipping_Instruction_attention__c, IEC_Shipping_Instruction_email__c, IEC_Shipping_Instruction_phone__c
                     , ShipTo_same_BillTo__c, Shipping_Instruction__c, Has_Shipping_Instruction__c
                     , Pricebook2Id
                     , Payment_Transaction_Number__c, Zuora_Transaction_Id__c, Zuora_GatewayResponse__c, Zuora_Credit_Card_Id__c, Is_Paid__c
                     , CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, StatusCode
                     , Campaign__c,SoldTo_Location__c,BillTo_Location__c,ShipTo_Location__c,BillTo_Location__r.VAT_Number__c, ShipTo_Location__r.VAT_Number__c
                     , BillTo_Location__r.Is_Postal_Code_Required__c, ShipTo_Location__r.Is_Postal_Code_Required__c
                     , BillTo_Address__r.Street__c, BillTo_Address__r.City__c, BillTo_Address__r.Country__c,BillTo_Address__r.ISO_Country_Code__c, BillTo_Address__c 
                     , BillTo_Address__r.State__c,BillTo_Address__r.ISO_State_Code__c, BillTo_Address__r.ZipCode__c, BillTo_Address__r.ISO_Country__r.Name
                     , BillTo_Address__r.ISO_State_Name__c, BillTo_Address__r.ISO_Country__r.ISO_Code__c,BillTo_Address__r.ISO_State__r.ISO_Code__c
                     , BillTo_Address__r.ISO_Country__c,BillTo_Address__r.ISO_Country_Name__c, BillTo_Address__r.ISO_State__r.Name, BillTo_Address__r.ISO_State__c
                     , ShipTo_Address__r.Street__c, ShipTo_Address__r.City__c, ShipTo_Address__r.Country__c,ShipTo_Address__r.ISO_Country_Code__c, ShipTo_Address__c 
                     , ShipTo_Address__r.State__c,ShipTo_Address__r.ISO_State_Code__c, ShipTo_Address__r.ZipCode__c, ShipTo_Address__r.ISO_Country__r.Name
                     , ShipTo_Address__r.ISO_Country_Name__c,ShipTo_Address__r.ISO_Country__r.ISO_Code__c,ShipTo_Address__r.ISO_State__r.ISO_Code__c
                     , ShipTo_Address__r.ISO_Country__c, ShipTo_Address__r.ISO_State__r.Name,ShipTo_Address__r.ISO_State_Name__c, ShipTo_Address__r.ISO_State__c
                     , Payment_Gateway_Response__c, Accepted_Payment_Methods__c
                     //, BillTo_VAT_Number__c, ShipTo_VAT_Number__c
                from Order 
                where Id = :orderId limit 1];
    } //*** end of "getOrderForVF"

    public static Order getOrderWithItems(String orderId)
    {
        return [
            Select  Id,OrderNumber,PoNumber,Sales_Order_Remark__c, SAP_Order_Number__c,Invoice_Text__c, Internal_Remark__c,Status,StatusCode, 
                BillTo_Location__c, BillToContactId,BillingStreet,BillingCity,BillingPostalCode,BillingState,BillingStateCode__c,BillingStateCode_SAP__c,BillingCountry,BillingCountryCode__c,
                ShipTo_Location__c,ShipToContactId,ShippingStreet,ShippingCity,ShippingPostalCode,ShippingState,ShippingStateCode__c,ShippingStateCode_SAP__c,ShippingCountry,ShippingCountryCode__c,
                SoldTo_Location__c, SoldToAccount_Partner_Number__c, SoldToAccount_Name__c,
                // IEC_Shipping_Instruction_attention__c, IEC_Shipping_Instruction_email__c, IEC_Shipping_Instruction_phone__c,
                TotalAmount,Total_Amount__c,SubTotal_Amount__c,Taxes__c,Total_Freight_Charge__c,Total_handling_charges__c,Sales_Volume__c, 
                Payment_Type__c, Payment_Transaction_Number__c,Zuora_Transaction_Id__c, Zuora_GatewayResponse__c, Zuora_Credit_Card_Id__c, Payment_Gateway_Response__c,
                Accepted_Payment_Methods__c, 
                (
                    Select Id, Quantity, UnitPrice, ListPrice, OrderItemNumber, 
                        Zuora_InvoiceId__c, Accepted_Term_Condition__c, Charge_Shipping__c, Division__c, Zuora_InvoiceNumber__c, 
                        Total__c,Freight_Charge__c, Tax__c, SubTotal__c,  
                        Zuora_Rate_Plan_Id__c, Zuora_Rate_Plan_Charge_Id__c, 
                        Is_Electronic_Product__c, Product_Number__c, Product_Name__c, Product_Availability__c, Status__c, 
                        TC_Accepted__c, Zuora_SubscriptionId__c, Auto_Renew__c, Product__c, Payment_Transaction_Number__c, Zuora_Subscription_Number__c, Is_Shippable_Product__c, Handling_charges__c, Confirmed_Quantity__c, Scheduled_Delivery_Date__c, Shipped_Quantity__c, Shipped_Date__c, Carrier_Tracking_Number__c, Carrier_Tracking_URL__c, Discount__c, Coupon__c, Carrier_Name__c, Delivery_Number__c, Invoice_Number__c, Invoice_Date__c, Invoice_Amount__c, Credit_Debit__c, Effective_End_Date__c, SAP_Contract_Number__c, Is_SAP_Editable__c, Use_Contract_when_ordered__c, Invoice_Number_URL__c, Is_Quantity_Integer__c, Setup_Fee__c, Zuora_Setup_Fee_Plan_Id__c, Zuora_Setup_Fee_Charge_Id__c, Sales_Volume__c, Number_of_download__c, Product_Manager__c, Is_Web_Download__c, AWS_download_link__c, Days_available_for_download_1__c, File_Path__c, Available_for_Subscription__c, Subscription_End_Date__c, SAP_Product_Number__c, IEC_Static_Cart_Quantity__c, IEC_Subscribe_to_Zuora__c 
                    From OrderItems
                ) 
            From Order 
            WHERE Id = :orderId 
            LIMIT 1
        ];
    }

    /****************************************************************************************************
        Created by David D 2015-10-09
            Return SAP Mapping table value for an order
    ****************************************************************************************************/
    public  Map<String, SFDC_SAP_Mapping__c> getOrderMapTable()
    {
        List<SFDC_SAP_Mapping__c> table = [
            SELECT SAP_Distribition_Channel__c,
                SAP_Division__c,
                SAP_Order_Type__c,
                SAP_Sales_Org__c,
                SFDC_Order_Channel__c,
                SFDC_Order_Source__c,
                SFDC_ORDER_TYPE__c
            FROM SFDC_SAP_Mapping__c            
        ];

        Map<String, SFDC_SAP_Mapping__c> ret = new Map<String, SFDC_SAP_Mapping__c>();
        String key;
        for(SFDC_SAP_Mapping__c t :table)
        {
            key = t.SFDC_ORDER_TYPE__c +'_' + t.SFDC_Order_Source__c + t.SFDC_Order_Channel__c;
            ret.put(key, t);
        }

        return ret;
    }

    /****************************************************************************************************
        Created by Thai 2015-10-13
            Return a record of SFDC-SAP conversion based on SFDC values
    ****************************************************************************************************/
    public static SFDC_SAP_Mapping__c getConversionSFDC_SAP(String OrderType, String OrderSource, String OrderChannel) {
        List<SFDC_SAP_Mapping__c> data = [select SAP_Order_Type__c, SAP_Sales_Org__c, SAP_Distribition_Channel__c, SAP_Division__c
                                          from SFDC_SAP_Mapping__c
                                          where SFDC_Order_Type__c = :OrderType
                                            and SFDC_Order_Source__c = :OrderSource
                                            and SFDC_Order_Channel__c = :OrderChannel
                                          limit 1];
        return (data.size() == 0 ? null : data[0]);
    } //*** end of "getConversionSFDC_SAP"

    
    /****************************************************************************************************
        Created by Thai 2015-10-13
            Return order with order items to update freight charges and taxes
    ****************************************************************************************************/
    public static Order getOrderForFreightAndTax(Id idOrder, Id idOrderItem) {
        List<Order> listOrder = Database.query(' select Id, CurrencyIsoCode, Type, Source__c, Order_Channel__c, SoldToAccount_Partner_Number__c, ShipToContact_Partner_Number__c, BillToContact_Partner_Number__c'
                                             //+ '       , ShipTo_Street__c, ShipTo_City__c, ShipTo_PostalCode__c, ShipTo_State_SAP__c, ShipTo_Country__c'
                                             + '       , (select Id, Product_Number__c, Quantity, Charge_Shipping__c, SubTotal__c, Discount__c, CurrencyIsoCode, SAP_Product_Number__c, Use_Contract_when_ordered__c'
                                             + '         from OrderItems' + ((idOrderItem == null) ? '' : ' where Id = :idOrderItem') + ')'
                                             + ' from Order where Id = :idOrder limit 1');
        return listOrder[0];
    } //*** end of "getOrderForFreightAndTax"
    
    
    /****************************************************************************************************
        Created by Thai 2015-12-15
            Return orders to send to contract interface
    ****************************************************************************************************/
    public static List<Order> getOrderForContract(Set<Id> orderIds) {
        List<Order> listOrder = [select Id, OrderNumber, CurrencyIsoCode, PoNumber, EffectiveDate, Type, Source__c, Order_Channel__c, Payment_Type__c, Invoice_Text__c
                                      , BillToContact_Name__c, BillToContact_Partner_Number__c
                                      , BillingStreet, BillingCity, BillingStateCode_SAP__c, BillingPostalCode, BillingCountryCode__c, BillToContact_VAT_Number__c
                                      , ShipToContact_Name__c, ShipToContact_Partner_Number__c
                                      , ShippingStreet, ShippingCity, ShippingStateCode_SAP__c, ShippingPostalCode, ShippingCountryCode__c, ShipToContact_VAT_Number__c
                                      , Account.Payment_Term__c, Account.Sales_Office__c, SoldToAccount_Partner_Number__c
                                      , BillTo_Location__r.Street__c, BillTo_Location__r.City__c, BillTo_Location__r.ZipCode__c, BillTo_Location__r.ISO_State_Code_SAP__c
                                      , BillTo_Location__r.ISO_Country_Code__c, BillTo_Location__r.IEC_Valid_SAP_State__c, BillTo_Location__r.VAT_Number__c
                                      , (select Id, Product__c, Quantity, UnitPrice, Setup_Fee__c, SubTotal__c, Discount__c, Effective_End_Date__c, SAP_Product_Number__c
                                              , IEC_Override_Profit_Center__c, IEC_Contract_Start_Date__c, IEC_Contract_End_Date__c
                                         from OrderItems
                                         where Use_Contract_when_ordered__c = true and SAP_Contract_Number__c = null and Total__c != null and Total__c != 0
                                         order by PricebookEntry.Product2.SAP_Media_Code__c, PricebookEntry.Product2.SAP_SalesOrg__c, PricebookEntry.Product2.SAP_Sales_Channel_Code__c
                                                , PricebookEntry.Product2.SAP_Division_Code__c, PricebookEntry.Product2.SAP_Contract_OrderReason__c)
                                from Order where Id in :orderIds];
        return listOrder;
    } //*** end of "getOrderForContract"

   
    public Order getPenddingOrder(Id userId)
    {
        String typ = 'Cart';
        String stat = 'New';

        String query = String.format(
            'SELECT {0}  ' + 
            '   , BillTo_Address__r.Street__c, BillTo_Address__r.City__c, BillTo_Address__r.ZipCode__c ' +
            '   , BillTo_Address__r.ISO_State_Name__c, BillTo_Address__r.ISO_State_Code__c ' +
            '   , BillTo_Address__r.ISO_Country_Name__c, BillTo_Address__r.ISO_Country_Code__c ' +
            '   , ShipTo_Address__r.Street__c, ShipTo_Address__r.City__c, ShipTo_Address__r.ZipCode__c ' +
            '   , ShipTo_Address__r.ISO_State_Name__c, ShipTo_Address__r.ISO_State_Code__c ' +
            '   , ShipTo_Address__r.ISO_Country_Name__c, ShipTo_Address__r.ISO_Country_Code__c ' +
            'FROM {1} ' + 
            'WHERE OwnerId = :userId AND Type = :typ AND status = :stat  ORDER BY LastModifiedDate DESC LIMIT 1 ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        System.debug('query::'+query);
        System.debug('typ::'+typ);
        System.debug('stat::'+stat);

        List<Order> orders = Database.query(query);

        return (orders.isEmpty()) ? null : orders[0];
    }

    /**
        Retrieves the orders in status New and type of Cart and to the BillToContactId
    */
    public Order getPendingOrderByBillToContactId(Id billToContactId)
    {
        String typ = 'Cart';
        String stat = 'New';

        String query = String.format(
            'SELECT {0}  ' + 
            '   , BillTo_Address__r.Street__c, BillTo_Address__r.City__c, BillTo_Address__r.ZipCode__c ' +
            '   , BillTo_Address__r.ISO_State_Name__c, BillTo_Address__r.ISO_State_Code__c ' +
            '   , BillTo_Address__r.ISO_Country_Name__c, BillTo_Address__r.ISO_Country_Code__c ' +
            '   , ShipTo_Address__r.Street__c, ShipTo_Address__r.City__c, ShipTo_Address__r.ZipCode__c ' +
            '   , ShipTo_Address__r.ISO_State_Name__c, ShipTo_Address__r.ISO_State_Code__c ' +
            '   , ShipTo_Address__r.ISO_Country_Name__c, ShipTo_Address__r.ISO_Country_Code__c ' +
            'FROM {1} ' + 
            'WHERE BillToContactId = :billToContactId AND Type = :typ AND status = :stat  ORDER BY LastModifiedDate DESC LIMIT 1 ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        System.debug('query::'+query);
        System.debug('typ::'+typ);
        System.debug('stat::'+stat);

        List<Order> orders = Database.query(query);

        return (orders.isEmpty()) ? null : orders[0];
    }

    public Order initializeOrder(Account a, Contact c, Id ownerId)
    {
        return initializeOrder(a, c, ownerId, true); 
    }

    public Order initializeOrder(Account a, Contact c, Boolean doInsert)
    {
        return initializeOrder(a, c, null, doInsert); 
    }

    public Order initializeOrder(Account a, Contact c, Id ownerId, Boolean doInsert)
    {
        Pricebook_Sel pricebookSelector = new Pricebook_Sel();  
        Pricebook2 stdPriceBook = pricebookSelector.getStandardPriceBook();

        Map<String, String> countryCodeByName =  ISO_Country_State_Helper.getCountryCodeFromName(new List<String>{
            c.Account.ShippingCountry,
            c.Account.BillingCountry
        });

        Map<String, String> stateCodeByName =  ISO_Country_State_Helper.getStateCodeFromName(new Map<String, String>{
            c.Account.ShippingState => (countryCodeByName.containsKey(c.Account.ShippingCountry)) ? countryCodeByName.get(c.Account.ShippingCountry) : null ,
            c.Account.BillingState => (countryCodeByName.containsKey(c.Account.BillingCountry)) ? countryCodeByName.get(c.Account.BillingCountry) : null
        });
        
        Map<Id, Location__c> mapId_Location;
        Location__c location;
        Id idBillToAddress;
        Location_Sel locationSelector = new Location_Sel();

        //*** ensure Sold To, Bill To, Ship To location records are created
        //*** -> same method was called from controller but somehow data is not found in this method
        Location_Svc.initializeDefaultLocations(new List<Id>{c.Id});

        //--@todo: make sure contact has billTo and shipTo 

        Order newOrder = new Order(
            Type            = 'Cart',
            Status          = 'New',
            EffectiveDate   = Date.today(),
            Pricebook2Id    = stdPriceBook.Id,  
            Source__c       = 'eCommerce',
            Order_Channel__c= 'eCommerce',

            AccountId             = (a.ParentId == null ? a.Id : a.ParentId),
            SoldTo_Location__c    = (a.ParentId == null ? a.SoldTo_Location__c : a.Parent.SoldTo_Location__c),
            SoldToAccount_Name__c = (a.ParentId == null ? a.Name : a.Parent.Name),
            
            BillToContactId         = c.Id,
            BillTo_Location__c      = c.BillTo_Location__c,
            BillToAccount__c        = a.Id,
            BillToAccount_Name__c   = a.Name,
            BillToContact_Name__c   = c.Name,
            BillToContact_Salutation__c = c.Salutation,
            BillToContact_First_Name__c = c.FirstName,
            BillToContact_Last_Name__c  = c.LastName,
            BillToContact_Phone__c  = c.BillTo_Location__r.Phone__c,
            BillToContact_Email__c  = c.BillTo_Location__r.Email__c,
            
            ShipToContactId         = c.Id,
            ShipTo_Location__c      = c.ShipTo_Location__c,
            ShipToAccount__c        = a.Id,
            ShipToAccount_Name__c   = a.Name,
            ShipToContact_Name__c   = c.Name,
            ShipToContact_Salutation__c = c.Salutation,
            ShipToContact_First_Name__c = c.FirstName,
            ShipToContact_Last_Name__c  = c.LastName,
            OwnerId = ownerId
        );
        
        //*** get all locations for subsequent treatment/verification
        mapId_Location = locationSelector.getSoldToAccountLocation(new Set<Id>{newOrder.AccountId});
        mapId_Location.putAll(locationSelector.getContactsLocations(new Set<Id>{newOrder.ShipToContactId}));
        
        //*** set Sold To location if no default on account level
        if (newOrder.SoldTo_Location__c == null || mapId_Location.get(newOrder.SoldTo_Location__c) == null)
        {
            for (Id idLocation : mapId_Location.keySet())
            {
                location = mapId_Location.get(idLocation);
                if (location.Type__c == IECConstants.SOLDTO && location.Active__c == true)
                {
                    newOrder.SoldTo_Location__c = location.Id;
                    break;
                }
            }
        }
        
        //*** set Bill To address information
        //if (newOrder.BillTo_Location__c == null || mapId_Location.get(newOrder.BillTo_Location__c) == null)
        location = mapId_Location.get(newOrder.BillTo_Location__c);
        if (location == null || location.Active__c != true)
        {
            //*** set Bill To address based on Bill To location
            for (Id idLocation : mapId_Location.keySet())
            {
                location = mapId_Location.get(idLocation);
                if (location.Type__c == IECConstants.BILLTO && location.Active__c == true)
                {
                    newOrder.BillTo_Location__c    = location.Id;
                    newOrder.BillingStreet         = Utility.removeNewline(location.Street__c);
                    newOrder.BillingCity           = location.City__c;
                    newOrder.BillingPostalCode     = location.ZipCode__c;
                    newOrder.BillingCountry        = location.ISO_Country_Name__c;
                    newOrder.BillingCountryCode__c = location.ISO_Country_Code__c;
                    newOrder.BillingState          = location.ISO_State_Name__c;
                    newOrder.BillingStateCode__c   = location.ISO_State_Code__c;
                    newOrder.BillToContact_VAT_Number__c = location.VAT_Number__c;
                    
                    newOrder.BillToContact_Phone__c  = location.Phone__c;
                    newOrder.BillToContact_Email__c  = location.Email__c;

                    idBillToAddress                = location.Address__c;


                    break;
                }
            }
            
        }
        else
        {
            //*** set Bill To address based on default Bill To location
            newOrder.BillingStreet         = c.BillTo_Location__r.Street__c;
            newOrder.BillingCity           = c.BillTo_Location__r.City__c;
            newOrder.BillingPostalCode     = c.BillTo_Location__r.ZipCode__c;
            newOrder.BillingCountry        = c.BillTo_Location__r.ISO_Country_Name__c;
            newOrder.BillingCountryCode__c = c.BillTo_Location__r.ISO_Country_Code__c;
            newOrder.BillingState          = c.BillTo_Location__r.ISO_State_Name__c;
            newOrder.BillingStateCode__c   = c.BillTo_Location__r.ISO_State_Code__c;
            newOrder.BillToContact_VAT_Number__c = c.BillTo_Location__r.VAT_Number__c;
            
            newOrder.BillToContact_Phone__c  = c.BillTo_Location__r.Phone__c;
            newOrder.BillToContact_Email__c  = c.BillTo_Location__r.Email__c;


            idBillToAddress                = c.BillTo_Location__r.Address__c;
        }
        
        //*** set Ship To address information
        //if (newOrder.ShipTo_Location__c == null || mapId_Location.get(newOrder.ShipTo_Location__c) == null)
        location = mapId_Location.get(newOrder.ShipTo_Location__c);
        if (location == null || location.Active__c != true)
        {
            //*** set Ship To address based on Ship To location
            for (Id idLocation : mapId_Location.keySet())
            {
                location = mapId_Location.get(idLocation);
                if (location.Type__c == IECConstants.SHIPTO && location.Active__c == true)
                {
                    newOrder.ShipTo_Location__c     = location.Id;
                    newOrder.ShippingStreet         = Utility.removeNewline(location.Street__c);
                    newOrder.ShippingCity           = location.City__c;
                    newOrder.ShippingPostalCode     = location.ZipCode__c;
                    newOrder.ShippingCountry        = location.ISO_Country_Name__c;
                    newOrder.ShippingCountryCode__c = location.ISO_Country_Code__c;
                    newOrder.ShippingState          = location.ISO_State_Name__c;
                    newOrder.ShippingStateCode__c   = location.ISO_State_Code__c;
                    newOrder.ShipToContact_VAT_Number__c = location.VAT_Number__c;

                    newOrder.ShipToContact_Phone__c  = location.Phone__c;
                    newOrder.ShipToContact_Email__c  = location.Email__c;

                    if (location.Address__c == idBillToAddress)
                        newOrder.ShipTo_same_BillTo__c = true;
                    break;
                }
            }
            
        }
        else
        {
            //*** set Ship To address based on default Ship To location
            newOrder.ShippingStreet         = c.ShipTo_Location__r.Street__c;
            newOrder.ShippingCity           = c.ShipTo_Location__r.City__c;
            newOrder.ShippingPostalCode     = c.ShipTo_Location__r.ZipCode__c;
            newOrder.ShippingCountry        = c.ShipTo_Location__r.ISO_Country_Name__c;
            newOrder.ShippingCountryCode__c = c.ShipTo_Location__r.ISO_Country_Code__c;
            newOrder.ShippingState          = c.ShipTo_Location__r.ISO_State_Name__c;
            newOrder.ShippingStateCode__c   = c.ShipTo_Location__r.ISO_State_Code__c;
            newOrder.ShipToContact_VAT_Number__c = c.ShipTo_Location__r.VAT_Number__c;

            newOrder.ShipToContact_Phone__c  = c.ShipTo_Location__r.Phone__c;
            newOrder.ShipToContact_Email__c  = c.ShipTo_Location__r.Email__c;

                    
            if (c.ShipTo_Location__r.Address__c == idBillToAddress)
                newOrder.ShipTo_same_BillTo__c = true;
        }

        System.debug('Initialize Order: doInsert ? ' + (doInsert ? 'Yes' : 'No') + ', newOrder: ' + newOrder);

        if (doInsert)
            insert newOrder; 
        
        //return newOrder;
        return (doInsert) ? getOrderForVF(newOrder.Id) : newOrder;
    }

    public void cleanOrderItems(Id orderId)
    {
        delete [SELECT Id from OrderItem WHERE OrderId = :orderId];
    }

    public Set<Id> findOrders4SAP(List<Order> newList, List<Order> oldList)
    {
        Set<Id> orderIds = new Set<Id>();
        for(Integer x=0; x < newList.size(); x++)
        {
            Order newOrd = newList[x];
            Order oldOrd = oldList[x]; 

            if((newOrd.Status != oldOrd.Status) && (newOrd.Status == IECConstants.ORDER_STATUS_READY_FOR_SAP || newOrd.Status == IECConstants.ORDER_STATUS_PAID))
            {
                orderIds.add(newOrd.Id);
            }
        }

        return orderIds;
    }

    public List<Order> getOrdersReady4SAP()
    {
        List<Order> result = new List<Order>(); 

        Set<String> status = new Set<String>{IECConstants.ORDER_STATUS_READY_FOR_SAP, IECConstants.ORDER_STATUS_PAID};
        String query = String.format(
            'SELECT {0}  ' + 
            'FROM {1} ' + 
            'WHERE Status IN :status  AND SAP_Order_Number__c = null' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        List<Order> orders = Database.query(query);
        Map<Id, Order> orderById = new Map<Id, Order>(orders);

        OrderItem_Sel oiSelector = new OrderItem_Sel();
        Map<Id, List<OrderItem>> itemsByOrderId =  oiSelector.getOrderItems(orderById.keySet());

        for(Id orderId : itemsByOrderId.keySet())
        {
            for(OrderItem oi : itemsByOrderId.get(orderId))
            {
                if(oi.Is_Shippable_Product__c)
                {
                    //orderId has shippable product: take it 
                    result.add(orderById.get(orderId));
                    break;
                }
            }
        }
       
        return  result;
    }
    
    
    /****************************************************************************************************
        Created by Thai 2015-11-12
            Return list of quotes for Visualforce page
    ****************************************************************************************************/
    public static List<Order> getQuotesList(Id idContact) {
        return getOrdersByContact(IECConstants.ORDER_TYPE_QUOTE, idContact); 
    } //*** end of "getQuotesList"

    public static List<Order> getCustomerRenewalNotices(Id idContact)
    {
        String type = IECConstants.ORDER_TYPE_RENEWAL_NOTIFICATION;
        Date dateToCompare = Date.today().addDays(-SIX_MONTHS_DAYS);
        return [SELECT Id, OrderNumber, EffectiveDate, EndDate, Total_Amount__c, CreatedDate
            FROM Order
            WHERE Type = :type 
            AND ((Status NOT IN :IECConstants.expiredStatus AND EffectiveDate > :dateToCompare) )
            AND BillToContactId = :idContact
            ORDER BY EffectiveDate DESC, OrderNumber DESC
        ];

    }

    public static List<Order> getOrdersByContact(String sType, Id idContact)
    {
        return [SELECT Id, OrderNumber, EffectiveDate, EndDate, Total_Amount__c, CreatedDate
            FROM Order
            WHERE Type = :sType
                AND BillToContactId = :idContact
            ORDER BY EffectiveDate DESC, OrderNumber DESC
        ];
    }

    public List<Order> getQuotes(Id idContact){

        String type = IECConstants.ORDER_TYPE_QUOTE;
        List<String> expiredStatus = IECConstants.expiredStatus;
        Date dateToCompare = Date.today().addDays(-SIX_MONTHS_DAYS);
        
        String query = String.format(
            'SELECT {0}' + 
            ', (select Product_Name__c, Product_Number__c, Quantity, UnitPrice, Freight_Charge__c, Tax__c, Total__c, ' +
            'Carrier_Tracking_Number__c,Carrier_Tracking_URL__c, Coupon__c, Invoice_Number__c, Discount__c, Setup_Fee__c ' + 
            ' from Orderitems) ' + 
            'FROM {1} ' +  

            'WHERE Type = :type ' +
            'AND ((Status NOT IN :expiredStatus AND EffectiveDate > :dateToCompare) ) '+ 
            'AND BillToContactId = :idContact ORDER BY EffectiveDate DESC, OrderNumber DESC ' , 

            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        
        return Database.query(query);
    }

    public Order getQuoteDetails(Id quoteId)
    {
        String type = IECConstants.ORDER_TYPE_QUOTE;
        String query = String.format(
            'SELECT {0}' + 
            ', (select Product_Name__c, Product_Number__c, Quantity, UnitPrice, Freight_Charge__c, Tax__c, Total__c, ' +
            'Carrier_Tracking_Number__c,Carrier_Tracking_URL__c, Coupon__c, Invoice_Number__c, Discount__c ' + 
            ' from Orderitems) ' + 
            'FROM {1} ' +  
            'WHERE Type = :type AND Id = :quoteId ORDER BY EffectiveDate DESC, OrderNumber DESC ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        List<Order> orders = Database.query(query);
        return (!orders.isEmpty()) ? orders[0] : null;
    }
    
    /****************************************************************************************************
        Created by Thai 2015-11-13
            Return list of quotes for Visualforce page
    ****************************************************************************************************/
    public static Order getQuoteDetail(Id idContact, String strQuoteNumber){
        return getOrderDetail(idContact,strQuoteNumber,'Quote');
    }

    
    /****************************************************************************************************
        Created by Thai 2015-11-13
            Return list of quotes for Visualforce page
    ****************************************************************************************************/
    public static Order getOrderDetail(Id idContact, String strQuoteNumber,String orderType) {
        List<Order> data = [select Id, EffectiveDate, EndDate, OrderNumber, BillToContactId
                                 , Taxes__c, Total_Freight_Charge__c, TotalAmount, Total_Amount__c
                                 , BillToContact_Name__c, BillToContact_Email__c, BillToContact_Phone__c
                                 , BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, PONumber
                                 , ShipToContact_Name__c, ShipToContact_Email__c, ShipToContact_Phone__c
                                 , ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Shipping_Instruction__c
                                 , CreatedDate
                                 , (select Product_Name__c, Product_Number__c, Quantity, UnitPrice, Freight_Charge__c, Tax__c, Total__c from Orderitems)
                            from Order
                            where Type = :orderType
                              and BillToContactId = :idContact
                              and OrderNumber = :strQuoteNumber limit 1];
        return (data.isEmpty() ? null : data[0]);
    } //*** end of "getQuoteDetail"

    public Order getCustomerQuoteDetails(Id idContact, String strQuoteNumber)
    {
        String typ = 'Quote';
        String query = String.format(
            'SELECT {0}  ' + 
            '   , BillTo_Address__r.Street__c, BillTo_Address__r.City__c, BillTo_Address__r.ZipCode__c ' +
            '   , BillTo_Address__r.ISO_State_Name__c, BillTo_Address__r.ISO_State_Code__c ' +
            '   , BillTo_Address__r.ISO_Country_Name__c, BillTo_Address__r.ISO_Country_Code__c ' +
            '   , ShipTo_Address__r.Street__c, ShipTo_Address__r.City__c, ShipTo_Address__r.ZipCode__c ' +
            '   , ShipTo_Address__r.ISO_State_Name__c, ShipTo_Address__r.ISO_State_Code__c ' +
            '   , ShipTo_Address__r.ISO_Country_Name__c, ShipTo_Address__r.ISO_Country_Code__c ' +
            'FROM {1} ' + 
            'WHERE Type = :typ AND BillToContactId = :idContact AND OrderNumber = :strQuoteNumber  ' + 
            'LIMIT 1' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        List<Order> data = Database.query(query);

        return (data.isEmpty() ? null : data[0]);
    }

    /****************************************************************************************************
        Created by Samy 2016-01-18
            Return list of order renewal notifications for scheduled cleanup
    ****************************************************************************************************/
    public List<Order> getRenewalNotificationsForCleanUp()
    {
        String sType = 'Renewal Notification';
        Set<String> setStatus2Clean = new Set<String>{'New'};
        Date dCleanUpWindow = Date.today().addMonths(-1 * Utility.getIntegerSetting('Order Renewal Cleanup Window'));

        String query = String.format(
            'SELECT {0}  ' + 
            'FROM {1} ' + 
            'WHERE Type = :sType AND Status IN :setStatus2Clean AND EffectiveDate < :dCleanUpWindow' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        System.debug('query::'+query);
        
        return Database.query(query);
    }

    /****************************************************************************************************
        Created by Samy 2016-02-23
            Return list of orders that has the specified location in them
    ****************************************************************************************************/
    public static List<Order> getNewOrdersByLocation(Set<Id> setLocId)
    {
        return [SELECT Id, BillTo_Address__c, BillTo_Location__c
                , ShipTo_Address__c, ShipTo_Location__c
            FROM Order
            WHERE Status = 'New'
                AND (BillTo_Location__c IN :setLocId
                    OR ShipTo_Location__c IN :setLocId)];
    }

    /****************************************************************************************************
        Created by David D 2016/02
            Return list of orders of a specific contact
    ****************************************************************************************************/
    public List<Order> getMyOrders(Id contactId)
    {
        List<String> expiredStatus = IECConstants.expiredStatus;
        Date dateToCompare = Date.today().addDays(-SIX_MONTHS_DAYS);
        String historyType = 'History';

            // 'AND SAP_Order_Number__c != null  AND SAP_Invoice__r.Contract_Number__c != null ' +
            // 'AND ((type NOT IN :expiredType OR Status NOT IN :expiredStatus OR EffectiveDate > :dateToCompare) AND type != :historyType) ' +
         String query = String.format(
            'SELECT {0}' + 
            ', (select Product_Name__c, Product_Number__c, Quantity, UnitPrice, Freight_Charge__c, Tax__c, Total__c, ' +
            'Carrier_Tracking_Number__c,Carrier_Tracking_URL__c, Coupon__c, Invoice_Number__c,Discount__c, Setup_Fee__c ' +
            ' from Orderitems) ' +
            'FROM {1} ' +
            'WHERE BillToContactId = :contactId ' +
           
            'AND ((Status NOT IN :expiredStatus OR EffectiveDate > :dateToCompare) ) AND type != :historyType ' +

            'ORDER BY Type,  CreatedDate DESC', 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
         system.debug('### query: ' + query);
        return Database.query(query);
    }

    /****************************************************************************************************
        Created 2018/08
            Return list of orders of a specific contact for the order history page
    ****************************************************************************************************/
    public List<Order> getMyOrdersForOrderHistory(Id contactId) {

        List<String> expiredStatus = IECConstants.expiredStatusForOrderHistory;
        List<String> expiredTypes = IECConstants.expiredTypes;
        Date dateToCompare = Date.today().addYears(-THREE_YEARS);
        String query = String.format(
            'SELECT {0}' + 
            ', (select Product_Name__c, Product_Number__c, Quantity, UnitPrice, Freight_Charge__c, Tax__c, Total__c, ' +
            'Carrier_Tracking_Number__c,Carrier_Tracking_URL__c, Coupon__c, Invoice_Number__c,Discount__c, Setup_Fee__c ' +
            ' from Orderitems) ' +
            'FROM {1} ' +
            'WHERE BillToContactId = :contactId ' +
           
            'AND Status NOT IN :expiredStatus AND EffectiveDate > :dateToCompare AND Type NOT IN :expiredTypes ' +

            'ORDER BY Type,  CreatedDate DESC', 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
         
        system.debug('### query: ' + query);
        return Database.query(query);
    }

    /****************************************************************************************************
        Created by Kevin Ky 2016/03
            Return list of orders of a specific contact and Order number
    ****************************************************************************************************/
    public List<Order> getMyOrders(Id contactId, String orderNumber)
    {
         String query = String.format(
            'SELECT {0}, ' + 
            'BillTo_Address__r.Street__c, BillTo_Address__r.City__c, BillTo_Address__r.ISO_Country_Name__c, BillTo_Location__r.Contact_First_Name__c,' +
            'BillTo_Location__r.Contact_Last_Name__c, BillTo_Address__r.ZipCode__c, BillTo_Address__r.ISO_Country__r.Name,BillTo_Address__r.ISO_State_Name__c' + 
            ', (select Product_Name__c, Product_Number__c, Quantity, UnitPrice, Freight_Charge__c, Tax__c,Setup_Fee__c, Total__c from Orderitems) ' + 
            'FROM {1} ' + 
            'WHERE BillToContactId = :contactId and OrderNumber = :orderNumber ' +
            'ORDER BY Type,  CreatedDate DESC', 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        return Database.query(query);
    }

} //*** end of class