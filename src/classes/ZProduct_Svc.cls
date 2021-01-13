/**
 *
 * @author: Kevin Ky <kevin.ky@cgi.com>
 * @date: 2015-08-18
 *
 *
 **/
public without sharing class ZProduct_Svc {

	/****************************************************************************************************
	Created by Kevin Ky 2015-08-18
		Linked Zproduct with Product2 base on the SAP Product Material No
	****************************************************************************************************/
	public static void setZuoraProductField(List<zqu__ZProduct__c> zproducts){

		list<Product2> productsToUpdate = new list<Product2>();
		map<String,Id> ProductCode_ZProductId = new map<String,Id>();

		//set a map of product material no by product Id
		for(zqu__ZProduct__c zproduct : zproducts){
			ProductCode_ZProductId.put(zproduct.SAPProductMaterialNo__c,zproduct.Id);
		}

		if(ProductCode_ZProductId.size() > 0){

			//Get product2 by SAP Product Material No
			map<String,Product2> productCode_Product;
			if (!Test.isRunningTest()) productCode_Product = Product_Sel.getProductsByCode(ProductCode_ZProductId.keySet());
			else productCode_Product = new map<String,Product2>();

			if(productCode_Product != null && productCode_Product.size() > 0){
				for(String code : productCode_Product.keySet()){
					Id zproductId = ProductCode_ZProductId.get(code);
					if(zproductId != null){
						//Set the ZProduct__c field value for Product2 object
						Product2 product = productCode_Product.get(code);
						product.ZProduct__c = zproductId;
						productsToUpdate.add(product);
					}
				}
			}
		}

		//Update list of Product2
		if(productsToUpdate.size() > 0){
			update productsToUpdate;
		}

	}

}
