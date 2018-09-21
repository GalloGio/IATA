public with sharing class EComProduct_DTO 
{
    public String ProductId { get; set; }
    public String ProductInfoId{get;set;}
    public String ProductRatePlanInfoId{get;set;}
    public String ProductName { get; set; }
    public String ProductNumber { get; set; }
    public String ProductCategory { get; set; }
    public String ProductDesc { get; set; }
    public String ProductShortDesc { get; set; }
    public String Edition { get; set; }
    public String Media { get; set; }
    public String Portfolio{get;set;}
    public String Language { get; set; }
    public String ImageName { get; set; }  //*** name of image in static resource
    public String ImageFile { get; set; }  //*** image in product
    public Date EffectiveFrom { get; set; }
    public Date EffectiveTo { get; set; }
    public Boolean DisplayEffectiveTo { get; set; }
    public String ShortTitle{get;set;}
    public String Keywords{get;set;}
    public Decimal IECStaticCartQuantity {get;set;}

    public String megaMenu{get;set;}


    public PriceInfo_DTO PriceInfo { get; set; }
    public Decimal UnitPrice { get; set; }
    
    public Decimal RegularPrice {get; set; }
    public Decimal CustomerPrice { get; set; }

    public Decimal setupFee {get;set;}

    public String Discount { get; set; }

    // Fix to avoid having trailing zeros in the UI
    public Decimal OrderQuantity { get; set; }
    public Decimal OrderQuantityStripped {
        get {
                return decimal.valueOf(OrderQuantity.stripTrailingZeros().toPlainString());
        }
        set {
            OrderQuantity = value;
        }
    }
    
    public Boolean IsQuantityInteger { get; set; }
    public String InventoryStatus { get; set; }
    public Date AvailabilityDate { get; set; }
    public Boolean displayPrice { get; set; }
    public Boolean ChargeShipping{get;set;}
    public List<EComProduct_DTO> ProductComponent { get; set; }
    public Boolean Is_Electronic_Product{get;set;}
    public Boolean Sell_Through_eCommerce{get;set;}

    public String productNameAnalytic {get; set;}
    
    //*** constructor
    public EComProduct_DTO() 
    {
        this.OrderQuantity = 1;
        this.ProductComponent = new List<EComProduct_DTO>();
    }

    public EComProduct_DTO(Product2 prod, Map<String, PriceInfo_DTO> mapProductInfo, Map<String, Map<String, String>> mapPickList_Label, Boolean includeBOM, String customerType)
    {   
        EComProduct_DTO component;
        ImageFile = prod.imageFile__c;
        ProductId = String.valueOf(prod.Id).left(15); 
        Is_Electronic_Product = prod.Is_Electronic_Product__c;
        ProductName = prod.Name;
        productNameAnalytic = JSON.serialize(prod.Name);
        ProductNumber = prod.SAP_Material_Number__c;
        ProductCategory = mapPickList_Label.get('Category').get(prod.Line_of_Business__c);
        // Special handling required for the GDP products to retrieve information from different location
        ProductDesc = (prod.IEC_Product_Information__c == null) ? prod.Description : prod.IEC_Product_Information__r.Related_Product_Category__r.Long_Description__c;
        ProductShortDesc = (prod.IEC_Product_Information__c == null) ? prod.Short_Description__c : prod.IEC_Product_Information__r.Related_Product_Category__r.Short_Description__c;
        ProductInfoId = prod.IEC_Product_Information__c;
        ProductRatePlanInfoId = prod.IEC_Product_Rate_Plan_Information__c;

        megaMenu = prod.Mega_Menu__c;

        ShortTitle = prod.Short_Title__c;
        Keywords = prod.Keywords__c;
        Edition = prod.Edition__c;
        Portfolio = prod.Product_Segment__c;
        Media = mapPickList_Label.get('Media').get(prod.Media__c);
        ImageName = ((prod.Image__c == null) ? ((prod.Media__c == null) ? Utility.getTextSetting('Default Product Image Name') : (prod.Media__c + '.gif')) : (prod.Image__c + '.gif')).toLowerCase().replace(' ', '-');
        
        Language = mapPickList_Label.get('Language').get(prod.Refinement_Language__c);
        InventoryStatus = mapPickList_Label.get('InvStatus').get(prod.Inventory_Status__c);
        AvailabilityDate = prod.Expected_Availability_Date__c;
        EffectiveFrom = prod.Effective_From__c;
        EffectiveTo = prod.Effective_To__c;
        DisplayEffectiveTo = (prod.Hide_Effective_To_Date_in_eCommerce__c != true);
        Sell_Through_eCommerce = prod.Sell_through_eCommerce__c;

        //-- Product Prices
        OrderQuantity = 1;  //*** default quantity to order

        IECStaticCartQuantity = prod.IEC_Static_Cart_Quantity__c; //For phase 1 and 2 product quantity
        if(IECStaticCartQuantity != null && IECStaticCartQuantity > 0)
            OrderQuantity = prod.IEC_Static_Cart_Quantity__c;

        PriceInfo = mapProductInfo.get(prod.SAP_Material_Number__c);
        UnitPrice = Order_Svc.getUnitPrice(PriceInfo, customerType);
        RegularPrice = Order_Svc.getRegularPrice(PriceInfo, OrderQuantity);
        CustomerPrice = Order_Svc.getCustomerPrice(PriceInfo, OrderQuantity, customerType);

        //set the setup fee for Customer and Standard Price
        if(PriceInfo != null){
            
            Boolean found = false;
            Boolean foundUnitPrice = false;
            //if(PriceInfo.customerPrice != null){
            if(CustomerPrice != null && CustomerPrice > 0 && PriceInfo.customerPrice != null){
                for(PriceDetail_DTO setupFeecp : PriceInfo.customerPrice){
                    if(setupFeecp.setupFee != null){
                        setupFee = setupFeecp.setupFee;
                        found = true;
                    }
                    if (setupFeecp.unitPrice != null)
                        foundUnitPrice = true;
                }
            }
            
            if(!found && PriceInfo.standardPrice != null){
                for(PriceDetail_DTO setupFeesp : PriceInfo.standardPrice){
                    if(setupFeesp.setupFee != null){
                        setupFee = setupFeesp.setupFee;
                    }
                    if (setupFeesp.unitPrice != null)
                        foundUnitPrice = true;
                }
            }

            //*** reset setup fee when no unit price because setup fee is moved to unit price
            if (!foundUnitPrice)
                setupFee = 0;
        }
        
        IsQuantityInteger = prod.Is_Quantity_Integer__c;
        ChargeShipping = prod.Charge_Shipping__c;
        displayPrice = ((prod.Display_Price__c == true) && UnitPrice != null);
        
        ProductComponent = new List<EComProduct_DTO>();
        if (includeBOM)
            for (Product_Component__c pc : prod.Product_BOM__r) 
            {
                component = new EComProduct_DTO();
                    component.ProductNumber = pc.Related_Product__r.SAP_Material_Number__c;
                    component.ProductId = String.valueOf(pc.Related_Product__c).left(15);  
                    component.ProductName = pc.Related_Product__r.Name;
                    component.Media = mapPickList_Label.get('Media').get(pc.Related_Product__r.Media__c);
                    component.Edition = pc.Related_Product__r.Edition__c;
                    component.EffectiveFrom = pc.Related_Product__r.Effective_From__c;
                    component.EffectiveTo = pc.Related_Product__r.Effective_To__c;
                    component.ProductShortDesc =pc.Related_Product__r.Short_Description__c;
                ProductComponent.add(component);
            }
    }
}