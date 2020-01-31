/**
 *
 * @author: Kevin Ky <kyk@iata.org>
 * @date: 2015-09-03
 * This page is to show the pricing model in product layout
 **/
public class ProductPrice_Ext
{
	public List<PriceDetail_DTO> standardPrices { get; set; }
	public List<PriceDetail_DTO> customerPrices { get; set; }
	public List<PriceDetail_DTO> regionPrices { get; set; }
	public List<PriceDetail_DTO> countryPrices { get; set; }
	public List<PriceDetail_DTO> couponPrices { get; set; }
	public List<PriceDetail_DTO> preSalePrices { get; set; }

	public List<PriceDetail_DTO> removeDuplicates(List<PriceDetail_DTO> rows)
	{
		if(rows == null)
			return null;

		Set<PriceDetail_DTO> setItems = new Set<PriceDetail_DTO>();
		for(PriceDetail_DTO p: rows)
			setItems.add(p);

		return new List<PriceDetail_DTO>(setItems);
	}

	public ProductPrice_Ext(ApexPages.StandardController ctrl)
	{
		Product_Sel pSelector = new Product_Sel();
		Id productId = ctrl.getId();
		Product2 product = pSelector.selectById(new Set<Id>{productId})[0];

		Map<String, PriceInfo_DTO> priceMap = pSelector.getProductPriceInfo(new Set<String>{product.SAP_Material_Number__c}, null, null, null, true);

		if(priceMap != null & priceMap.containsKey(product.SAP_Material_Number__c))
		{
			PriceInfo_DTO price = priceMap.get(product.SAP_Material_Number__c);

			standardPrices 	= removeDuplicates(price.standardPrice);
			customerPrices 	= removeDuplicates(price.customerPrice);
			regionPrices 	= removeDuplicates(price.regionPrice);
			countryPrices 	= removeDuplicates(price.countryPrice);
			couponPrices 	= removeDuplicates(price.couponPrice);
			preSalePrices 	= removeDuplicates(price.preSalePrice);
		}
	}
}
