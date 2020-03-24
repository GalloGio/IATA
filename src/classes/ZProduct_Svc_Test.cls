@isTest
public class ZProduct_Svc_Test {

	@isTest (SeeAllData=true)
	static void test_Zprod() {
		//TestDataGenerator.generateUtilitySetting();
		//set the administrator emails
		/*Apex_Setting__c productScope = new Apex_Setting__c();
		productScope.Name = 'Products email notification admin';
		productScope.Text_1__c = 'test@test.com';
		insert productScope;*/

		List<Product2> listProd = new List<Product2>();
		listProd.add(new Product2(Name='Test 1', Product_Section__c='tst111', Division__c='division 1', Sales_Channel__c='channel 1',SAP_Material_Number__c='1245-78'));
		listProd.add(new Product2(Name='Test 2', Product_Section__c='tst222', Division__c='division 2',Status__c='A',SAP_Material_Number__c='7845-12'));
		listProd.add(new Product2(Name='Test 3', Division__c='division 1', Sales_Channel__c='channel 2',Status__c='A',SAP_Material_Number__c='3265-98'));
		insert listProd;

		List<zqu__ZProduct__c> lstZprd = TestDataGenerator.generateZProducts(1,false);
		for(zqu__ZProduct__c zp : lstZprd){
			zp.SAPProductMaterialNo__c = '1245-78';
		}
		insert lstZprd;

		ZProduct_Svc.setZuoraProductField(lstZprd);
		system.assert(lstZprd.size() == 1, 'Wrong number of products: ' + lstZprd.size());
		system.assert(listProd.size() == 3, 'Wrong number of products: ' + listProd.size());

	}


}
