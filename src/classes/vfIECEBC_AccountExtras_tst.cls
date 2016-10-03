/**
 * Test class for vfIECEBC_AccountExtras
 *
 * This is part of the eBroadcast feature
 * 
 * History: 
 *  - 20160929-sl: initial version
 *
 */
@isTest
private class vfIECEBC_AccountExtras_tst {

    // ========================================================================
    // basic test: calling batch job, with minimal test data
    // subscription prepaid
    // select the first displayed rate plan
    @isTest (SeeAllData=false)  
    static void test01_BasicTestOnAccountExtras() {
        IECEBC_TestUtility.createEbcSetupAndRelatedData();
        IECEBC_TestUtility.createTestUser(true); // create member community contact
        Date dSubscriptionEndDate = Date.today().addMonths(6);
        IECEBC_TestUtility.createEbcSubscription( IECEBC_TestUtility.lEbcProductRatePlanMember[0], IECEBC_TestUtility.oEbcProductMember, dSubscriptionEndDate);
        
        Test.startTest();
		vfIECEBC_AccountExtras controller = new vfIECEBC_AccountExtras();
		PageReference currentPage = Page.IECEBC_AccountExtras;
        
        // call the flag getters
        Boolean addOnShown = controller.showAddOnSelection;
        Boolean shownPaymentConfirmation =  controller.showPaymentConfirmation;
        Boolean shownPurchaseMessage =  controller.showPurchasedSelectionMessage;
        
        // call the list getters
        List<vfIECEBC_AccountExtras.ProductRatePlanWrapper> productRatePlanWrapperAddonOptionList = controller.productRatePlanWrapperAddonOptionList;
        List<vfIECEBC_AccountExtras.ProductRatePlanWrapper> productRatePlanWrapperAddonCurrentList = controller.productRatePlanWrapperAddonCurrentList;
        
        
        // simulate the click, chose the first one
        controller.selectedRatePlanIndex = 0;
        controller.selectRatePlanAddon();
        
        // verify that the click make the confirmation shown
        shownPaymentConfirmation = controller.showPaymentConfirmation;
        System.assert( shownPaymentConfirmation, 'After selection, payment confirmation should be shown') ;
        
        // simulate the payment click
        PageReference newPage = controller.goToPaymentPage();
            
        Test.stopTest();
        
        System.debug('Unit Test: Finish: test01_BasicTestOnAccountExtra');
    } // test01_BasicTestOnAccountExtras
    

}