@isTest
public class ISSP_CaseAttachList_Test {
    @testSetup
    public static void loadTestCredentials() {
        WrapperAttachTest.loadTestCredentials();
    }
    
    public static testMethod void myTest_1() {
        //Account account = (Account)ISSP_ObjectFactory.createSObject('Account');
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        //Contact contact = (Contact)ISSP_ObjectFactory.createSObject('Contact');
        Contact contact = ISSP_ObjectFactory.createNewContact();
        insert contact;
        Case c=new Case(Subject='test 1',Status='Open', AccountId=account.id, ContactId=contact.id,Region__c = 'Europe');
        insert c;
        
        Attachment attach = new Attachment();     
        attach.Name='[UNITTEST][FILE][SMALL]';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = c.Id;
        insert attach;
        
        Archived_Message__c mess = new Archived_Message__c();
        mess.Case__c = c.Id;
        mess.EmailMessage__c = '1234';
        insert mess;
        
        Archived_Attachment__c arch = new Archived_Attachment__c();
        arch.ArchivedMessage__c = mess.Id;
        arch.Case__c = c.Id;
        arch.Bucket__c = 'test';
        insert arch;
        
        AWSKey__c key = new AWSKey__c();
        key.Bucket__c = 'test';
        insert key;
        
        ISSPAttachmentPermission__c perm = new ISSPAttachmentPermission__c();
        perm.AttachmentId__c = attach.Id;
        perm.ShowToPortalUsers__c = false;
        insert perm;
        
        ArchiveAttachmentListController ctrl = new ArchiveAttachmentListController();
        ctrl.setACaseId(c.Id);
        String myCaseId = ctrl.getACaseId();
        system.assertEquals(myCaseId, c.Id);
        ctrl.loadAttachmentFromCaseId();
        ctrl.refreshList();
        
        ctrl.setAMessageId(mess.Id);
        String myMessageId = ctrl.getAMessageId();
        system.assertEquals(myMessageId, mess.Id);
        ctrl.loadAttachmentsFromEmailMessage();
        ctrl.getArchivedAttachments();
        
        ctrl.attId = attach.Id;
        ctrl.makePrivate = true;
        
        ctrl.actionAttachmentPermission();
        List <ISSPAttachmentPermission__c> permList = [SELECT Id, ShowToPortalUsers__c
                                                    FROM ISSPAttachmentPermission__c
                                                    WHERE AttachmentId__c = :attach.Id];
        system.assertEquals(permList[0].ShowToPortalUsers__c, false);
        
        perm.ShowToPortalUsers__c = true;
        update perm;
        ctrl.actionAttachmentPermission();
        permList = [SELECT Id, ShowToPortalUsers__c FROM ISSPAttachmentPermission__c
                    WHERE AttachmentId__c = :attach.Id];
        system.assertEquals(permList[0].ShowToPortalUsers__c, false);
        
        perm.ShowToPortalUsers__c = false;
        update perm;
        ctrl.actionAttachmentPermission();
        ctrl.makePrivate = false;
        ctrl.actionAttachmentPermission();
        permList = [SELECT Id, ShowToPortalUsers__c FROM ISSPAttachmentPermission__c
                    WHERE AttachmentId__c = :attach.Id];
        system.assertEquals(permList[0].ShowToPortalUsers__c, true);
        System.assert(ctrl.getTransferAttachmentsUrl() != null);
        ArchiveAttachmentListController.getAttachmentByCase(c.Id, true);
        
    }
    
    static testMethod void testGetExpiringLink() {
        Test.startTest();
        ArchiveAttachmentListController.getExpiringLink('testname');
        Test.stopTest();
    }
    
    public static testMethod void myTest_2() {
        //ISSP_ObjectFactory.fiilIncludedFields();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
        //Account acc = (Account)ISSP_ObjectFactory.createSObject('Account',false,4);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact contact = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;
        insert contact;
        User newUser = new User(alias = 'dsfsdfds', 
                                email = contact.email, 
                                emailencodingkey = 'UTF-8', 
                                firstname = contact.firstName, 
                                lastname = contact.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                contactId = contact.Id,
                                timezonesidkey = 'Asia/Dubai',
                                username = contact.email+'dfgdf',
                                PortalRole = 'Manager',
                                CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = profileId,
                                IsActive = true);
        insert newUser;
        
        AttachmentListLimitedAccess__c access = new AttachmentListLimitedAccess__c();
        access.SetupOwnerId = profileId;
        insert access;
        
        Test.startTest();
        system.runAs(newUser){
            Case c=new Case(Subject='test 1',Status='Open', AccountId=acc.id, ContactId=contact.id,Region__c = 'Europe');
            insert c;
            
            Attachment attach=new Attachment();     
            attach.Name='[UNITTEST][FILE][SMALL]';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=c.Id;
            insert attach;
            
            ArchiveAttachmentListController ctrl = new ArchiveAttachmentListController();
            ctrl.setACaseId(c.Id);
            String myCaseId = ctrl.getACaseId();
            system.assertEquals(myCaseId, c.Id);
            ctrl.loadAttachmentFromCaseId();
            
            ctrl.attId = attach.Id;
            ctrl.makePrivate = true;
            
            ctrl.actionAttachmentPermission();
            List <ISSPAttachmentPermission__c> permList = [SELECT Id, ShowToPortalUsers__c
                                                        FROM ISSPAttachmentPermission__c
                                                        WHERE AttachmentId__c = :attach.Id];
            system.assertEquals(permList[0].ShowToPortalUsers__c, false);                
        }
        Test.stopTest() ;
    }
    
    public static testMethod void myTest_3() {
        //ISSP_ObjectFactory.fiilIncludedFields();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
        //Account acc = (Account)ISSP_ObjectFactory.createSObject('Account',false,4);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact contact = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;
        insert contact;
        User newUser = new User(alias = 'dsfsdfds', 
                                email = contact.email, 
                                emailencodingkey = 'UTF-8', 
                                firstname = contact.firstName, 
                                lastname = contact.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                contactId = contact.Id,
                                timezonesidkey = 'Asia/Dubai',
                                username = contact.email+'dfgdf',
                                PortalRole = 'Manager',
                                CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = profileId,
                                IsActive = true);
        insert newUser;
        
        AttachmentListLimitedAccess__c access = new AttachmentListLimitedAccess__c();
        access.SetupOwnerId = profileId;
        insert access;
        
        Test.startTest();
        system.runAs(newUser){
            Case c=new Case(Subject='test 1',Status='Open', AccountId=acc.id, ContactId=contact.id,Region__c = 'Europe');
            insert c;
            
            Attachment attach=new Attachment();     
            attach.Name='[UNITTEST][FILE][SMALL]';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=c.Id;
            insert attach;
            
            ArchiveAttachmentListController ctrl = new ArchiveAttachmentListController();
            ctrl.setACaseId(c.Id);
            String myCaseId = ctrl.getACaseId();
            system.assertEquals(myCaseId, c.Id);
            ctrl.loadAttachmentFromCaseId();
            
            ctrl.attId = attach.Id;
            ctrl.makePrivate = false;
            
            ctrl.actionAttachmentPermission();
            List <ISSPAttachmentPermission__c> permList = [SELECT Id, ShowToPortalUsers__c
                                                        FROM ISSPAttachmentPermission__c
                                                        WHERE AttachmentId__c = :attach.Id];
            system.assertEquals(permList[0].ShowToPortalUsers__c, true);
        }
        Test.stopTest() ;
    }
    
    public static testMethod void myTest_4() {
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc = (Account)ISSP_ObjectFactory.createSObject('Account',false,4);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact contact = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;
        insert contact;
        
        Test.startTest();

        Case c=new Case(Subject='test 1',Status='Open', AccountId=acc.id, ContactId=contact.id,Region__c = 'Europe');
        insert c;
//        WrapperAttachTest.createAmazonFile(c);
        
        List<EmailMessage> emails = new List<EmailMessage>();
        emails.add(new EmailMessage(ParentId=c.Id,FromAddress='yo@yo.com',FromName='Yo',Subject='Subject',TextBody='TextBody',ToAddress=Label.ISSP_CaseCommentEmail));
        emails.add(new EmailMessage(ParentId=c.Id,FromAddress='yo@yo.com',FromName='Yo',Subject='Subject',HtmlBody='<b>HtmlBody</b><i>more</i>',ToAddress=Label.ISSP_CaseCommentEmail));
        insert emails;
        
        Attachment attach=new Attachment();     
        attach.Name='[UNITTEST][FILE][SMALL]';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=emails[0].Id;
        insert attach;
        
        ArchiveAttachmentListController ctrl = new ArchiveAttachmentListController();
        ctrl.setACaseId(c.Id);
        String myCaseId = ctrl.getACaseId();
        system.assertEquals(myCaseId, c.Id);
        ctrl.loadAttachmentFromCaseId();
                           Boolean resulterror = ArchiveAttachmentListController.deleteAttachmentAmazon(c.Id,'testname');
        System.assert(!resultError);
        Test.stopTest() ;
    }

    
}