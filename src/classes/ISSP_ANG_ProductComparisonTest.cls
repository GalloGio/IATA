@isTest
public class ISSP_ANG_ProductComparisonTest {

	public static testMethod void test1() {
		Product2 pX_1 = new Product2 (
			name = 'Standard Accreditation with no Cash',
			Description = 'ProductX_1',
			ANG_Description_Label__c = '',
			ANG_Tooltip__c = ''
		);

		Product2 pX_2 = new Product2 (
			name = 'Standard Accreditation with Cash',
			Description = 'ProductX_2',
			ANG_Description_Label__c = '',
			ANG_Tooltip__c = ''
		);

		Product2 p1 = new Product2 (
			name = 'Standard Accreditation with no Cash',
			Description = 'Product1',
			ANG_Description_Label__c = '',
			ANG_Tooltip__c = ''
		);

		Product2 p2 = new Product2 (
			name = 'Standard Accreditation with Cash',
			Description = 'Product2',
			ANG_Description_Label__c = '',
			ANG_Tooltip__c = ''
		);

		insert new List<Product2>{p1, p2, pX_1, pX_2};

		Product_Component__c pc1 = new Product_Component__c (
			Product__c = p1.id,
			Related_Product__c = pX_1.id
		);

		Product_Component__c pc2 = new Product_Component__c (
			Product__c = p1.id,
			Related_Product__c = pX_2.id
		);

		insert new List<Product_Component__c>{pc1, pc2};

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

		insert new List<PricebookEntry>{prceST1, prceST2};

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

		insert new List<PricebookEntry>{prce1, prce2};

		test.startTest();

		ISSP_ANG_ProductComparison ctrl = new ISSP_ANG_ProductComparison();

		ctrl.headers = new List<String>();
		String aux = ctrl.communityName;

		//System.debug(LoggingLevel.ERROR, '---->' + ctrl);

		System.assertEquals(ctrl.helper.headers.size(), 3);
		System.assertEquals(ctrl.helper.lines.size(), 5);

		test.stopTest();
	}
}
