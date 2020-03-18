public class VolumePrice_DTO
{
	public Decimal qtyFrom{get;set;}
	public Decimal qtyTo{get;set;}
	public Decimal price{get;set;}
	public String chargeId{get;set;} // ZuoraId of the charge
	public String planId{get;set;} // ZuoraId of the rate plan
	public String uom{get;set;}
	public String priceFormat{get;set;}

	public VolumePrice_DTO(){}

	/*public VolumePrice_DTO(RatePlanChargeTier_DTO tier)
	{

		qtyFrom = tier.startingUnit;
		qtyTo = tier.endingUnit;
		price = tier.price;
	}*/

	public VolumePrice_DTO(zqu__ProductRatePlanChargeTier__c zTier)
	{
		qtyFrom 	= 	zTier.zqu__StartingUnit__c;
		qtyTo 		=	zTier.zqu__EndingUnit__c;
		price 		=	zTier.zqu__Price__c;
		planId 		= 	zTier.ZRatePlan_ZuoraId__c;
		chargeId 	=	zTier.ZCharge_ZuoraId__c;
		uom 		=	zTier.ZCharge_UOM__c;
		priceFormat	=	zTier.zqu__PriceFormat__c;
	}
}
