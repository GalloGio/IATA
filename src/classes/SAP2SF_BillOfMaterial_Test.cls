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
        SAP2SF_BillOfMaterial.insertBOM('11111', RelatedProducts);
        SAP2SF_BillOfMaterial.insertBOM(BillOfMaterial, RelatedProducts);
        Test.stopTest();
    }
}
