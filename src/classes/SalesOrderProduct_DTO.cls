public class SalesOrderProduct_DTO
{
	public EComProduct_DTO ecomProduct{get;set;}
	public Decimal quantity{get;set;}
	public Boolean IsQuantityInteger{get;set;}
	public Boolean selected{get;set;}
	public String orderItemId{get;set;}
	public String couponCode{get;set;}
}
