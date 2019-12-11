@IsTest
public class TreasuryDashboardPowerBiPageCtrlTest {

    @IsTest
    private static void getPageParams() {
        Test.startTest();
        PageReference pageRef = Page.TreasuryDashboardPowerBiPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('tokenType', 'tokenType');
        ApexPages.currentPage().getParameters().put('embedUrl', 'embedUrl');
        ApexPages.currentPage().getParameters().put('accessToken', 'accessToken');
        ApexPages.currentPage().getParameters().put('objectId', 'objectId');

        TreasuryDashboardPowerBiPageCtrl pageController = new TreasuryDashboardPowerBiPageCtrl();


        System.assertEquals(pageController.tokenType, 'tokenType');
        System.assertEquals(pageController.embedUrl, 'embedUrl');
        System.assertEquals(pageController.accessToken, 'accessToken');
        System.assertEquals(pageController.objectId, 'objectId');
        System.assertEquals(pageController.redirect(), null);
        Test.stopTest();
    }

}