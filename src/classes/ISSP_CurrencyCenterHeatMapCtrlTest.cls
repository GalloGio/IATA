@isTest
private class ISSP_CurrencyCenterHeatMapCtrlTest {
    
    @isTest static void testCtrlWithParam() {
    	Test.startTest();
		PageReference pageRef = Page.ISSP_CurrencyCenterHeatMap;
  		Test.setCurrentPage(pageRef);
  		ApexPages.currentPage().getParameters().put('search', 'France');
    	ISSP_CurrencyCenterHeatMapCtrl ctrl = new ISSP_CurrencyCenterHeatMapCtrl();
    	Test.stopTest();
    }

    @isTest static void testCtrlWithoutParam() {
    	Test.startTest();
    	ISSP_CurrencyCenterHeatMapCtrl ctrl = new ISSP_CurrencyCenterHeatMapCtrl();
    	Test.stopTest();
    }

}