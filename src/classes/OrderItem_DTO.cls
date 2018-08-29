public class OrderItem_DTO implements Comparable
{
    public String orderItemId{get;set;}
	public String productId{get;set;}
    public String productName{get;set;}
    public String productCode{get;set;}
    public string sapProductCode{get;set;}
    public String description{get;set;}
    public String imageName{get;set;}
    public String subscription{get;set;}
    public Boolean isContractProduct { get; set; }

    // Fix to avoid having trailing zeros in the UI
    public Decimal quantity{get;set;}
    public Decimal quantityStripped {
    	get {
    			return decimal.valueOf(quantity.stripTrailingZeros().toPlainString());
    	}
    	set {
    		quantity = value;
    	}
	}
	
    public Boolean IsQuantityInteger{get;set;}
    public Decimal unitPrice{get;set;}
    public Decimal subTotal{get;set;}
    public Decimal discountAmount{get;set;}
    public Decimal shippingAmount{get;set;}
    public Decimal setupFee{get;set;}
    public Decimal taxAmount{get;set;}
    public Decimal totalAmount{get;set;}
    public Decimal handlingCharges{get;set;}
    public Boolean chargeShipping{get;set;}
    public String status{get;set;}
    public Decimal confirmedQuantity{get;set;}
    public Date scheduledDate{get;set;}
    public Decimal shippedQuantity{get;set;}
    public Date shippedDate{get;set;}
    public String trackingNumber { get; set; }
    public String invoiceNumber { get; set; }
    public Date invoiceDate { get; set; }
    public Decimal invoiceAmount { get; set; }
    public Decimal CreditDebitAmount { get; set; }
    public String contractNumber { get; set; }
    public Decimal IECStaticCartQuantity { get; set; }
    
    // Used for showing/hiding the edit fields for order items that has been submitted to SAP
    public Boolean IsSAPEditable { get; set; }

    public PriceInfo_DTO PriceInfo { get; set; }

    public String couponCode{get;set;}

    public String message{get;set;}

    public TermAndCondition_DTO acceptedTnC{get;set;}
    
    public String zuoraChargeId{get;set;}
    public String zuoraPlanId{get;set;}

    public List<OrderItemCharge_DTO> charges{get;set;}
    
    // Used for disabling/hiding controls for non-compliant orderitem
    public Boolean IsCompliant {get;set;}
    
    // Used to show/hide the resend download link button
    public Boolean IsWebDownload {get;set;}

    //Used for Auto renew
    public Boolean isAutoRenew {get;set;}
    public Boolean availableForSubscription {get;set;}

    //used for google analytics
    public String productNameAnalytic {get; set;}
    public String productNumber {get;set;}
    public String productCategory {get;set;}
    public String productBrand {get;set;}
    public String productEdition {get;set;}
    public String productLanguage {get;set;}
    public String productInventoryStatus {get;set;}
    public Date productAvailabilityDate {get;set;}
    public String productMedia {get;set;}
    public Date productEffectiveTo {get;set;}


    public Integer compareTo(Object compareTo)
    {
        OrderItem_DTO objWrap = (OrderItem_DTO) compareTo;

        return productName.compareTo(objWrap.productName);
    }

    public static OrderItem_DTO format2DTO(OrderItem orderItem, Map<String, PriceInfo_DTO> mapProductNumber_Price)
    {
        OrderItem_DTO ret = new OrderItem_DTO();

        ret.orderItemId = orderItem.Id;
        ret.productId   = orderItem.Product__c;
        ret.productName = orderItem.Product_Name__c;
        ret.productCode = orderItem.Product_Number__c;
        ret.sapProductCode = orderItem.SAP_Product_Number__c;
        ret.description = orderItem.Description;
        ret.status      = orderItem.Status__c;
        //ret.imageName   = orderItem.Product_Image__c;  
        ret.isContractProduct = orderItem.Use_Contract_when_ordered__c;
        
        ret.quantity  = orderItem.Quantity;
        
        ret.IECStaticCartQuantity = orderItem.IEC_Static_Cart_Quantity__c; //Default quantity for phase 1 and 2 products
        if(ret.IECStaticCartQuantity != null && ret.IECStaticCartQuantity > 0 && orderItem.Quantity == null)  ret.quantity = ret.IECStaticCartQuantity;

        ret.IsQuantityInteger = orderItem.Is_Quantity_Integer__c;
        ret.unitPrice = orderItem.UnitPrice;
        ret.subTotal  = orderItem.SubTotal__c;

        ret.shippingAmount  = orderItem.Freight_Charge__c;
        ret.taxAmount       = orderItem.Tax__c;
        ret.handlingCharges = orderItem.Handling_charges__c;
        ret.totalAmount     = orderItem.Total__c;
        ret.chargeShipping  = orderItem.Charge_Shipping__c;
        ret.discountAmount  = orderItem.Discount__c;
        ret.setupFee        = orderItem.Setup_Fee__c;

        ret.zuoraChargeId   = orderItem.Zuora_Rate_Plan_Charge_Id__c;
        ret.zuoraPlanId     = orderItem.Zuora_Rate_Plan_Id__c;
        ret.subscription    = orderItem.Zuora_Subscription_Number__c;
        
        ret.confirmedQuantity   = orderItem.Confirmed_Quantity__c;
        ret.scheduledDate       = orderItem.Scheduled_Delivery_Date__c;
        ret.shippedQuantity     = orderItem.Shipped_Quantity__c;
        ret.shippedDate         = orderItem.Shipped_Date__c;
        ret.trackingNumber      = orderItem.Carrier_Tracking_URL__c;
        ret.invoiceNumber       = orderItem.Invoice_Number__c;
        ret.invoiceDate         = orderItem.Invoice_Date__c;
        ret.invoiceAmount       = orderItem.Invoice_Amount__c;
        ret.CreditDebitAmount   = orderItem.Credit_Debit__c;
        ret.contractNumber      = orderItem.SAP_Contract_Number__c;

        ret.PriceInfo = mapProductNumber_Price.get(orderItem.Product_Number__c);    
        ret.couponCode = orderItem.Coupon__c;

        ret.charges = OrderItemCharge_DTO.format2DTO(orderItem.Order_Item_Charges__r);
        
        // Check whether the order item can be edited after being submitted to SAP
        ret.IsSAPEditable = orderItem.Is_SAP_Editable__c;
        
        ret.IsWebDownload = orderItem.Is_Web_Download__c;

        ret.isAutoRenew = orderItem.Auto_Renew__c;
        ret.availableForSubscription = orderItem.Available_for_Subscription__c;

        
        return ret;
    }

    public static List<OrderItem_DTO> format2DTO(List<OrderItem> orderItems, Map<String, PriceInfo_DTO> mapProductNumber_Price)
    {
        List<OrderItem_DTO> ret = new List<OrderItem_DTO>();

        for(OrderItem orderItem : orderItems)
            ret.add(format2DTO(orderItem, mapProductNumber_Price));

        return ret;
    }

    public static OrderItem_DTO format2DTO(OrderItem orderItem, List<Order_Item_Charge__c> charges)
    {
        OrderItem_DTO ret = new OrderItem_DTO();
            ret.orderItemId = orderItem.Id;
            ret.productId   = orderItem.Product__c;
            ret.productName = orderItem.Product_Name__c;
            ret.productCode = orderItem.Product_Number__c;
            ret.sapProductCode = orderItem.SAP_Product_Number__c;
            ret.description = orderItem.Description;
            ret.status      = orderItem.Status__c;
            //ret.imageName   = orderItem.Product_Image__c;  
            
            ret.quantity  = orderItem.Quantity;
            
            ret.IECStaticCartQuantity = orderItem.IEC_Static_Cart_Quantity__c; //Default quantity for phase 1 and 2 products
            if(ret.IECStaticCartQuantity != null && ret.IECStaticCartQuantity > 0 && orderItem.Quantity == null)
                ret.quantity = ret.IECStaticCartQuantity;

            ret.IsQuantityInteger = orderItem.Is_Quantity_Integer__c;
            ret.unitPrice = orderItem.UnitPrice;
            ret.subTotal  = orderItem.SubTotal__c;

            ret.shippingAmount  = orderItem.Freight_Charge__c;
            ret.taxAmount       = orderItem.Tax__c;
            ret.totalAmount     = orderItem.Total__c;
            ret.chargeShipping  = orderItem.Charge_Shipping__c;
            ret.discountAmount  = orderItem.Discount__c;

            ret.zuoraChargeId   = orderItem.Zuora_Rate_Plan_Charge_Id__c;
            ret.zuoraPlanId     = orderItem.Zuora_Rate_Plan_Id__c;
            ret.subscription    = orderItem.Zuora_Subscription_Number__c;
            
            ret.confirmedQuantity   = orderItem.Confirmed_Quantity__c;
            ret.scheduledDate       = orderItem.Scheduled_Delivery_Date__c;
            ret.shippedQuantity     = orderItem.Shipped_Quantity__c;
            ret.shippedDate         = orderItem.Shipped_Date__c;
        
	        // Check whether the order item can be edited after being submitted to SAP
	        ret.IsSAPEditable		= orderItem.Is_SAP_Editable__c;

            ret.isAutoRenew = orderItem.Auto_Renew__c;
            

            if(charges != null)
            {
                ret.charges = OrderItemCharge_DTO.format2DTO(charges);    

                //-- Calculate Total Discount 
                //ret.discountAmount = OrderItemCharge_DTO.calculateDiscountAmount(ret.subTotal, ret.charges); 
            }

        return ret;
    }

    public static List<OrderItem_DTO> format2DTO(List<OrderItem> orderItems, Map<Id, List<Order_Item_Charge__c>> chargesByItem)
    {
        List<OrderItem_DTO> ret = new List<OrderItem_DTO>();

        for(OrderItem orderItem : orderItems)
        {
            List<Order_Item_Charge__c> charges = (chargesByItem.containsKey(orderItem.Id)) 
                ? chargesByItem.get(orderItem.Id) 
                : new List<Order_Item_Charge__c>();

            ret.add(format2DTO(orderItem, charges));
        }

        return ret;
    }

    public static List<OrderItem_DTO> setTermAndConditions(List<OrderItem_DTO> dtos, String customerType)
    {
        Set<Id> productIds = new Set<Id>();
        Set<Id> tncIds = new Set<Id>();

        for(OrderItem_DTO dto : dtos)
        {
            productIds.add(dto.productId);
        }

        /*if(String.isBlank(customerType))
            customerType = 'Non-member';*/
            
        Map<Id, List<Product_Term_Condition__c>> tncByProduct = new Term_And_Condition_Sel().getActiveTermsAndConditions(customerType, productIds);

        for(Id pId : tncByProduct.keySet())
        {
            List<Product_Term_Condition__c> tncs = tncByProduct.get(pId);
            tncIds.add(tncs[0].Term_Condition__c);
        }

        Map<Id, Attachment> attachmentByTnCId = new Attachment_sel().getAttachmentByTnC(tncIds);

        for(OrderItem_DTO dto : dtos)
        {
            if(tncByProduct.containsKey(dto.productId))
            {
                List<Product_Term_Condition__c> tncs = tncByProduct.get(dto.productId);
                
                TermAndCondition_DTO tnc_dto = new TermAndCondition_DTO(tncs[0]);
                if(attachmentByTnCId.containsKey(tnc_dto.tncId))
                {
                    Attachment att = attachmentByTnCId.get(tnc_dto.tncId);
                    tnc_dto.attachmentURL = '/servlet/servlet.FileDownload?file=' + att.Id; 
                    dto.acceptedTnC = tnc_dto;
                }
            }
        }

        return dtos;
    }

    public static List<OrderItem_DTO> format2DTO(List<OrderItem> orderItems)
    {
        List<OrderItem_DTO> ret = new List<OrderItem_DTO>();


        for(OrderItem orderItem : orderItems)
        {
            ret.add(format2DTO(orderItem, new Map<String, PriceInfo_DTO>()));
        }

        return ret;
    }
}