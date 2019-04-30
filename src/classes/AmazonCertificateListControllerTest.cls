@isTest
private class AmazonCertificateListControllerTest {

    @testSetup
    public static void loadTestCredentials() {
        WrapperAttachTest.loadTestCredentials();
    }

    @isTest static void testController_Error() {
        Test.startTest();
        AmazonCertificateListController controller = new AmazonCertificateListController(null);
        Test.stopTest();
    }

    @isTest static void testController_OK() {
        Account account = new Account(Name = 'test account');
        insert account;
        ApexPages.StandardController stdController = new ApexPages.StandardController(account);
        
        Test.startTest();
        AmazonCertificateListController controller = new AmazonCertificateListController(stdController);
        System.assert(controller.amazonFileToUpload!=null);
        Test.stopTest();
    }

    @isTest static void testRemoteCreateUploadFile() {
        Account account = new Account(Name = 'test account');
        insert account;
        
        Test.startTest();
        AmazonCertificateListController.WrapperCredential wrapper = AmazonCertificateListController.createUploadFile(account.Id, 'testfilename.txt', 'plain/text', 1);
        System.assert(wrapper!=null);
        Test.stopTest();
    }
    
    @isTest static void testRemoteCreateAmazonFileObject_Error() {
        Account account = new Account(Name = 'test account');
        insert account;
        
        Test.startTest();
        String amazonKey = 'key';
        Long filesize = 1;
        String parentId = account.Id;
        String expiryDate = null;
        String datatype = 'type';
        Boolean result = AmazonCertificateListController.createAmazonFileObject(amazonKey,filesize,parentId,expiryDate,datatype);
        System.assert(result==false);
        Test.stopTest();
    }
    
    @isTest static void testRemoteGetS3Url_Error() {
        Test.startTest();
        AmazonCertificateListController.TEST_RESULT = 'OK';
        String result = AmazonCertificateListController.getS3Url(null);
        System.assert(result=='');
        Test.stopTest();
    }
    
    @isTest static void testRemoteGetS3Url_Ok() {
        Account account = new Account(Name = 'test account');
        insert account;
        
        AmazonFile__c file = new AmazonFile__c(
            RecordtypeId = AmazonCertificateListController.RT_CERTIFICATE_ID,
            Full_Name_Unique__c = 'filename'
        );
        insert file;

        Test.startTest();
        AmazonCertificateListController.TEST_RESULT = 'OK';
        String result = AmazonCertificateListController.getS3Url(file.Id);
        System.assert(result=='OK');
        Test.stopTest();
    }
}