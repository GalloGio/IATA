public class Discount_DTO
{
	public enum eDiscount {CUSTOMER_TYPE, REGION, COUNTRY, COUPON, PRESALE}

	public Boolean isPercentageDiscount{get;set;}
	public Boolean isFreeShipping{get;set;}
	public eDiscount discountType{get;set;}
	public String discountName{get;set;}
	public Decimal discountValue{get;set;}

	public String planId{get;set;} // ZuoraId of the rate plan
	public String chargeId{get;set;} // ZuoraId of the charge

	public Discount_DTO(){}


	public Discount_DTO(zqu__ProductRatePlanChargeTier__c zTier)
	{
		isPercentageDiscount 	= zTier.ZCharge_Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_PERCENTAGE);
		isFreeShipping          = zTier.ZRatePlan_IsFreeShipping__c == 'Yes';
		discountValue 			= zTier.zqu__Price__c;
	 	planId 					= zTier.ZRatePlan_ZuoraId__c;
	 	chargeId 				= zTier.ZCharge_ZuoraId__c;

	 	if(String.isNotBlank(zTier.ZRatePlan_CustomerType__c))
	 	{
	 		discountType = eDiscount.CUSTOMER_TYPE;
	 		discountName = zTier.ZRatePlan_CustomerType__c;
	 	}
	 	else if(String.isNotBlank(zTier.ZRatePlan_Region__c))
	 	{
	 		discountType = eDiscount.REGION;
	 		discountName = zTier.ZRatePlan_Region__c;
	 	}
	 	else if(String.isNotBlank(zTier.ZRatePlan_Country__c))
	 	{
	 		discountType = eDiscount.COUNTRY;
	 		discountName = zTier.ZRatePlan_Country__c;
	 	}
	 	else if(String.isNotBlank(zTier.ZRatePlan_CouponCode__c))
	 	{
	 		discountType = eDiscount.COUPON;
	 		discountName = zTier.ZRatePlan_CouponCode__c;
	 	}
	 	else
	 	{
	 		//-- If no Filter then its presale discount
	 		discountType = eDiscount.PRESALE;
	 		discountName = 'PRESALE';
	 	}
	}

	public static Order_Item_Charge__c createChargeRecord(Discount_DTO dto)
	{
		return new Order_Item_Charge__c(
			Name = dto.discountName,
			//Discount_Amount__c = (dto.discountType.contains(ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT)) ? dto.discountValue : null,
			//Discount_Percentage__c = (dto.discountType.contains(ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_PERCENTAGE)) ? dto.discountValue : null,
			//Discount_Type__c = dto.discountType,
			Zuora_Rate_Plan_Charge_Id__c = dto.chargeId,
			Zuora_Rate_Plan_Id__c = dto.planId
		);
	}
}
