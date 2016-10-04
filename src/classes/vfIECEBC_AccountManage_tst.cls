/**
 * Test class for AccountManage
 *
 * This is part of the eBroadcast feature
 * 
 * History: 
 *  - 20160929-sl: initial version
 *
 */
@isTest
private class vfIECEBC_AccountManage_tst {

    // ========================================================================
    // basic test: calling batch job, with minimal test data
    // subscription PAY AS YOU GO
    // select the first displayed rate plan
    @isTest (SeeAllData=false)  
    static void test01_BasicTestOnAccountManage() {
        IECEBC_TestUtility.createEbcSetupAndRelatedData();
        IECEBC_TestUtility.createTestUser(true); // create member community contact
        Date dSubscriptionEndDate = Date.today().addMonths(6);
        IECEBC_TestUtility.createEbcSubscription( IECEBC_TestUtility.oEbcPayAsYouGoProductRatePlanMember, IECEBC_TestUtility.oEbcProductMember, dSubscriptionEndDate);
        
        Test.startTest();
		vfIECEBC_AccountManage controller = new vfIECEBC_AccountManage();
		PageReference currentPage = Page.IECEBC_AccountManage;
        
            
        Test.stopTest();
        
        System.debug('Unit Test: Finish: test03_BasicTestOnBatchJobWithTestData');
    } // test03_BasicTestOnBatchJobWithTestData
    

}