public class PriceDetail_DTO
{
	public Boolean               isFreeShipping { get; set; }
	public Decimal               unitPrice { get; set; }
	public String                unitPricePlanId;
	public String                unitPriceChargeId;
	public Decimal               setupFee { get; set; }
	public String                setupFeePlanId;
	public String                setupFeeChargeId;
	public List<VolumePrice_DTO> volumePrice{get;set;}
	public String                discountName { get; set; }
	public Decimal               discountAmount { get; set; }
	public Decimal               discountPercentage { get; set; }
	public String                discountPlanId;
	public String                discountChargeId;

	public PriceDetail_DTO(){}

	/*public PriceDetail_DTO(Decimal unit, String planId, String chargeId)
	{
		unitPrice = unit;
		unitPricePlanId = planId;
		unitPriceChargeId = chargeId;
	}*/
}
