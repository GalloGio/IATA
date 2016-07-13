public without sharing class Order_Svc
{
    
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
            if (UnitPrice == null) UnitPrice = exe.getUnitPriceFromFlatFee(price.customerPrice);
            if (UnitPrice == null) UnitPrice = exe.getUnitPriceFromFlatFee(price.standardPrice);
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
            if (UnitPrice == null) UnitPrice = srv.getUnitPriceFromFlatFee(price.standardPrice);   //*** try to get unit price from flat fee
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
            if (UnitPrice == null) UnitPrice = srv.getUnitPriceFromFlatFee(price.customerPrice);   //*** try to get unit price from flat fee
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
    Decimal getUnitPriceFromFlatFee(List<PriceDetail_DTO> lstPrice)
    {
        //*** safety check
        if (lstPrice == null || lstPrice.size() == 0)
            return null;
        
        for (PriceDetail_DTO price : lstPrice)
        {
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
}