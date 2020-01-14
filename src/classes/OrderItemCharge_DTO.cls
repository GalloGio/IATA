public with sharing class OrderItemCharge_DTO
{
	public String name{get;set;}
	public Decimal discountAmount{get;set;}
	public Decimal discountPercentage{get;set;}
	public String discountType{get;set;}
	public String zuoraChargeId{get;set;}
	public String zuoraPlanId{get;set;}

	public static OrderItemCharge_DTO format2DTO(Order_Item_Charge__c charge)
	{
		OrderItemCharge_DTO ret = new OrderItemCharge_DTO();
			ret.name = charge.Name;
			ret.discountAmount = charge.Discount_Amount__c;
			//ret.discountPercentage = charge.Discount_Percentage__c;
			ret.discountType = charge.Discount_Type__c;
			ret.zuoraChargeId = charge.Zuora_Rate_Plan_Charge_Id__c;
			ret.zuoraPlanId = charge.Zuora_Rate_Plan_Id__c;

		return ret;
	}

	public static List<OrderItemCharge_DTO> format2DTO(List<Order_Item_Charge__c> charges)
	{
		List<OrderItemCharge_DTO> ret = new List<OrderItemCharge_DTO>();
		for(Order_Item_Charge__c c : charges)
			ret.add(format2DTO(c));

		return ret;
	}

	/*public static Decimal calculateDiscountAmount(Decimal subTotal, List<OrderItemCharge_DTO> discounts)
	{
		Decimal discountAmount = 0;
		Decimal discountedAmount = subTotal;

		for (OrderItemCharge_DTO discount : discounts)
		{
			if (discount.discountPercentage != null)
				discountedAmount -= (discountedAmount * discount.discountPercentage / 100);
			else
				discountAmount += discount.discountAmount;
		}

		return subTotal - discountedAmount + discountAmount;
	}*/

}
