global class Product_Soap
{
	webservice static String send2Zuora(Id productId)
	{
		return Product_Svc.saveZProducts(new Set<Id>{
			productId
		});
	}
}
