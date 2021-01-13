/****************************************************************************************************
	Created by CGI, Kevin ky 2015-08-24
		Cover trigger "ZProducts" of object "Product2"
		Cover code of class "ZProduct_Dom"
****************************************************************************************************/
@isTest
public class ZProduct_Dom_Test {

	@isTest(seeAllData=true)
	static void testSetZuoraProductField(){
		TestDataGenerator.generateUtilitySetting();

		//set the administrator emails
		/*Apex_Setting__c productScope = new Apex_Setting__c();
		productScope.Name = 'Products email notification admin';
		productScope.Text_1__c = 'test@test.com';
		insert productScope;*/

		List<Product2> lstProds = TestDataGenerator.generateProducts(3, true);

		lstProds[0].Line_of_Business__c = 'Training';
		update lstProds[0];

		lstProds = [SELECT id,Line_of_Business__c From Product2 where Name like 'Product %' order by Name ];
		//system.assert(lstProds.size() == 3, 'Wrong number of products: ' + lstProds.size());
		//system.assert(lstProds[0].Line_of_Business__c == 'Training', 'Wrong line of business name ' + lstProds[0].Line_of_Business__c);

		List<zqu__ZProduct__c> lstZProducts =  TestDataGenerator.generateZProducts(3,true);
		lstZProducts[0].zqu__SKU__c = 'SKU-007';
		update lstZProducts[0];

		delete lstZProducts;
	}

}
