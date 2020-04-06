@isTest
private class SAP2SF_BillOfMaterial_Test {
    
    
    @isTest
    static void test_AllMethod() {
    
        //*** get product generated for order item and generate additional product
        List<Product2> lstProduct = new List<Product2>();
        lstProduct.addAll(TestDataGenerator.generateProducts(4, true));

        String BillOfMaterial = lstProduct[0].SAP_Material_Number__c;

        List<String> RelatedProducts = new List<String>();
        RelatedProducts.add(lstProduct[1].SAP_Material_Number__c);
        RelatedProducts.add(lstProduct[2].SAP_Material_Number__c);
        RelatedProducts.add(lstProduct[3].SAP_Material_Number__c);

        Test.startTest();
        List<Product_Component__c> initial = [Select id from Product_Component__c];
    
        SAP2SF_BillOfMaterial.insertBOM('11111', RelatedProducts);
    
        List<Product_Component__c> firtstTest = [Select id from Product_Component__c];
        system.assertEquals(initial.size(), firtstTest.size(), 'products inserted');

        SAP2SF_BillOfMaterial.insertBOM(BillOfMaterial, RelatedProducts);
    
        List<Product_Component__c> secondTest = [Select id from Product_Component__c];
        system.assert(initial.size() >= firtstTest.size(), 'products not inserted');
    
        Test.stopTest();
    }
}
