@isTest
public class ISSP_ANG_ProductComparisonTest {

    public static testMethod void test1() {
        Product2 pX_1 = new Product2 (
            name = 'ProductX_1',
            Description = 'ProductX_1',
            ANG_Description_Label__c = '',
            ANG_Tooltip__c = ''
        );

        Product2 pX_2 = new Product2 (
            name = 'ProductX_2',
            Description = 'ProductX_2',
            ANG_Description_Label__c = '',
            ANG_Tooltip__c = ''
        );

        Product2 pX_3 = new Product2 (
            name = 'ProductX_3',
            Description = 'ProductX_3',
            ANG_Description_Label__c = '',
            ANG_Tooltip__c = ''
        );

        Product2 p1 = new Product2 (
            name = 'Product1',
            Description = 'Product1',
            ANG_Description_Label__c = '',
            ANG_Tooltip__c = ''
        );

        Product2 p2 = new Product2 (
            name = 'Product2',
            Description = 'Product2',
            ANG_Description_Label__c = '',
            ANG_Tooltip__c = ''
        );

        Product2 p3 = new Product2 (
            name = 'Product3',
            Description = 'Product3',
            ANG_Description_Label__c = '',
            ANG_Tooltip__c = ''
        );

        insert new List<Product2>{p1, p2, p3, pX_1, pX_2, pX_3};

        Product_Component__c pc1 = new Product_Component__c (
            Product__c = p1.id,
            Related_Product__c = pX_1.id
        );

        Product_Component__c pc2 = new Product_Component__c (
            Product__c = p1.id,
            Related_Product__c = pX_2.id
        );

        Product_Component__c pc3 = new Product_Component__c (
            Product__c = p1.id,
            Related_Product__c = pX_3.id
        );

        insert new List<Product_Component__c>{pc1, pc2, pc3};

        Pricebook2 prcb1 = new Pricebook2 (
            name = 'NewGen Accreditation Models test'
        );

        insert prcb1;

        Pricebook2 standard = new Pricebook2(Id = Test.getStandardPricebookId(), isActive=true);

        update standard;

        PricebookEntry prceST1 = new PricebookEntry (
            Pricebook2Id = standard.id,
            Product2Id = p1.id,
            UnitPrice = 1,
            IsActive = true
        );

        PricebookEntry prceST2 = new PricebookEntry (
            Pricebook2Id = standard.id,
            Product2Id = p2.id,
            UnitPrice = 1,
            IsActive = true
        );

        PricebookEntry prceST3 = new PricebookEntry (
            Pricebook2Id = standard.id,
            Product2Id = p3.id,
            UnitPrice = 1,
            IsActive = true
        );

        insert new List<PricebookEntry>{prceST1, prceST2, prceST3};

        PricebookEntry prce1 = new PricebookEntry (
            Pricebook2Id = prcb1.id,
            Product2Id = p1.id,
            UnitPrice = 1,
            IsActive = true,
            UseStandardPrice = false
        );

        PricebookEntry prce2 = new PricebookEntry (
            Pricebook2Id = prcb1.id,
            Product2Id = p2.id,
            UnitPrice = 1,
            IsActive = true,
            UseStandardPrice = false
        );

        PricebookEntry prce3 = new PricebookEntry (
            Pricebook2Id = prcb1.id,
            Product2Id = p3.id,
            UnitPrice = 1,
            IsActive = true,
            UseStandardPrice = false
        );

        insert new List<PricebookEntry>{prce1, prce2, prce3};

        test.startTest();

        ISSP_ANG_ProductComparison ctrl = new ISSP_ANG_ProductComparison();

        ctrl.headers = new List<String>();
        String aux = ctrl.communityName;

        //System.debug(LoggingLevel.ERROR, '---->' + ctrl);

        System.assertEquals(ctrl.helper.headers.size(), 4);
        System.assertEquals(ctrl.helper.lines.size(), 6);

        test.stopTest();
    }
}