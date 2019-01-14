@isTest
private class SFDC_ProductCatalog_Test 
{
	
	@isTest /*(SeeAllData=true)*/
	static void test_GET() 
	{
		//-- Generate Products with Prices 
		List<Product2> products = TestDataGenerator.generateProductsWithPrice(10);

		//-- Update Product Properties 
		Integer x =0;
		for(Product2 prod : products)
		{
			prod.Display_Ecom_Topic__c = (Math.mod(x, 2) == 0) ? 'Finance' : 'Economics';
			prod.Keywords__c = '***-xxxx '+x;
			prod.IATA_ORG_Group__c = (Math.mod(x, 2) == 0) ? 'The Financial Times' : 'The Economics';

			x++;
		}

		update products;

		//-- Call the service 
		Date dt = Date.today().addDays(-1);
		RestRequest req = new RestRequest();
			req.httpMethod = 'GET';
			req.requestURI = URL.getSalesforceBaseUrl() . toExternalForm() + '/services/apexrest/ProductCatalog';
			req.addParameter('date', dt.year() + '-' + dt.month() + '-' + dt.day());
			req.addParameter('limit', '2'); // 2 per page
			req.addParameter('page', '1'); // query 1st page

		RestContext.request = req;

		RestResponse res = new RestResponse();	

		RestContext.response = res;

		SFDC_ProductCatalog.ProductCatalog catalog = SFDC_ProductCatalog.getProducts();
	}	
}