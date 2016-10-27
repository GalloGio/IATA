@isTest
private class EF_AttachmentListControllerTest {

    @testSetup
    public static void setupTest() {

        //     Case cse = new Case();
        //     insert cse;
        //
        //     Attachment att = new Attachment(
        //         ParentId = cse.Id,
        //         Name = 'testname',
        //         Body = Blob.ValueOf('')
        //         ParentId = cse.id;
        //     );
        //     insert att;

        List<Amazon_Cred__c> listAmazonCred =  new List<Amazon_Cred__c>{
            new Amazon_Cred__c(
                name = 'GenericAttach',
                Prod_Configuration__c = 'GenericAttach-prod' ,
                Dev_Configuration__c = 'GenericAttach-dev'
            ),
            new Amazon_Cred__c(
                name = 'RecycleBin',
                Prod_Configuration__c = 'RecycleBin-prod' ,
                Dev_Configuration__c = 'RecycleBin-dev'
            )
        };
        insert listAmazonCred;

        list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
            new AWSKey__c(
                name = 'GenericAttach-prod',
                Key__c = 'asd',
                Secret__c = 'asd',
                IAS_configuration_name__c = 'asdas',
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd'
            ),
            new AWSKey__c(
                name = 'GenericAttach-dev' ,
                Key__c = 'asd',
                Secret__c = 'asd',
                IAS_configuration_name__c = 'asdas',
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd'
            ),
            new AWSKey__c(
                name = 'RecycleBin-prod',
                Key__c = 'asd',
                Secret__c = 'asd',
                IAS_configuration_name__c = 'asdas',
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd'
            ),
            new AWSKey__c(
                name = 'RecycleBin-dev' ,
                Key__c = 'asd',
                Secret__c = 'asd',
                IAS_configuration_name__c = 'asdas',
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd'
            ),
            new AWSKey__c(
                name = 'production',
                Key__c = 'asd',
                Secret__c = 'asd',
                IAS_configuration_name__c = 'asdas',
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd'
            ),
            new AWSKey__c(
                name = 'sandbox',
                Key__c = 'asd',
                Secret__c = 'asd',
                IAS_configuration_name__c = 'asdas',
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd'
            )
        };
        insert AWS_KEYs;
    }

    static testMethod void testEF_AttachmentListController() {

        Case cse = new Case();
        insert cse;

        Attachment att = new Attachment(
            ParentId = cse.Id,
            Name = 'testname',
            Body = Blob.ValueOf('')
        );
        insert att;

        EF_AttachmentListController controller = new EF_AttachmentListController();

        controller.id = cse.Id;

        System.assert(controller.isAdminUser);

        PageReference pgNull = controller.refreshList();

        System.assert(controller.listAttachments.size() > 0);

    }

    static testMethod void testRemoteActions() {

        Case cse = new Case();
        insert cse;

        Attachment att = new Attachment(
            ParentId = cse.Id,
            Name = 'testNameSFA',
            Body = Blob.ValueOf('')
        );
        insert att;

        Archived_Message__c mess = new Archived_Message__c();
        mess.Case__c = cse.Id;
        mess.EmailMessage__c = '1234';
        insert mess;

        Archived_Attachment__c arch = new Archived_Attachment__c();
        arch.ArchivedMessage__c = mess.Id;
        arch.Case__c = cse.Id;
        arch.Bucket__c = 'testNameAA';
        arch.AWS_S3_URL__c = 'testurl';
        insert arch;

        AmazonFile__c aFile = new AmazonFile__c(
            Full_Name_Unique__c = 'testnameAMZ',
            Case__c = cse.Id
        );
        insert aFile;

        System.assert(EF_AttachmentListController.getExpiringLink('testName') != null);

        EF_AttachmentListController.deleteAttachment(String.valueOf(att.Id), null);
        EF_AttachmentListController.deleteAttachment(String.valueOf(arch.Id), null);
        EF_AttachmentListController.deleteAttachment(String.valueOf(aFile.Id), 'asd');
    }
    
}