@isTest(SeeAllData=true)
public class EmailMessageViewConTest{
    
    @isTest
    static void testEmailMessageViewCon()
    {
        Account account1 = new Account();
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.Location_Type__c = 'HO';
        insert account1;
        
        // create test contact
        Contact contact1 = new Contact();
        contact1.FirstName = 'Dummy';
        contact1.LastName = 'Contact';
        contact1.Type_of_Contact__c = 'IFAP Contact';
        contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        insert contact1;
        
        Case ca = new Case();
        ca.BounceEmailSubject__c = 'Test';
        ca.BounceEmailCounter__c = 0;
        ca.Status = 'Action Needed';
        ca.accountId = account1.Id;
        ca.contactId = contact1.Id;
        ca.Region__c = 'Europe';
        Id sMapRt = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'sMAP_sales_Monitoring_Alert_Process');
        ca.RecordTypeId = sMapRt;
        Insert ca;
        
        EmailMessage em = new EmailMessage();
        em.ParentId = ca.Id;
        em.ToAddress = 'im.remon@gmail.com';
        em.CcAddress = 'im.remon@gmail.com';
        em.TextBody = 'hello';
        em.Subject= 'Test';      
        em.MessageDate = datetime.now();
    insert em;
        
        Tracked_Email__c te = new Tracked_Email__c();
        te.Case__c = ca.Id;
        
        insert te;
        
        EmailMessage am = new EmailMessage();
        am.ParentId = ca.Id;
        am.ToAddress = 'im.remon@gmail.com';
        am.CcAddress = 'im.remon@gmail.com';
        am.TextBody = 'hello';
        am.Subject= 'Test';      
        am.MessageDate = datetime.now();
        insert am;
        
        Archived_Message__c archived = new Archived_Message__c(name = 'archived message 1', EmailMessage__c = am.Id, Case__c = ca.Id);
        insert archived;
        
        Case ca1 = new Case();
        ca1.BounceEmailSubject__c = 'Test';
        ca1.BounceEmailCounter__c = 0;
        ca1.Status = 'Action Needed';
        Insert ca1;
        
        EmailMessage em1 = new EmailMessage();
        em1.ParentId = ca1.Id;
        em1.ToAddress = 'im.remon@gmail.com';
        em1.CcAddress = 'im.remon@gmail.com';
        em1.TextBody = 'hello';
        em1.Subject= 'Test';
        em1.MessageDate = datetime.now().addHours(-8);
        Insert em1;
        
        Case ca2 = new Case();
        ca2.BounceEmailSubject__c = 'Test';
        ca2.BounceEmailCounter__c = 3;
        ca2.Status = 'Action Needed';
        Insert ca2;
        
        EmailMessage em2 = new EmailMessage();
        em2.ParentId = ca2.Id;
        em2.ToAddress = 'im.remon@gmail.com';
        em2.CcAddress = 'im.remon@gmail.com';
        em2.TextBody = 'hello';
        em2.Subject= 'Test';
        em2.MessageDate = datetime.now().addHours(-8);
        Insert em2;
        
        
        
        Case ca3 = new Case();
        ca3.BounceEmailSubject__c = 'Test';
        ca3.BounceEmailCounter__c = 3;
        ca3.Status = 'Action Needed';
        Insert ca3;
        
        EmailMessage em3 = new EmailMessage();
        em3.ParentId = ca3.Id;
        em3.ToAddress = 'im.remon@gmail.com';
        em3.CcAddress = 'im.remon@gmail.com';
        em3.TextBody = 'hello';
        em3.Subject= 'Test';
        em3.MessageDate = datetime.now();
        Insert em3;
        
       
        Case testCase = [SELECT id, CaseNumber FROM Case where id =:ca.Id];
        Test.startTest(); 
        System.debug('************ Case for Standard Controller ' + testCase.Id);
        PageReference pageRef = Page.EmailMessagesView;        
        Test.setCurrentPage(pageRef); 
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
        
        EmailMessagesViewCon controller = new EmailMessagesViewCon(sc);          
        controller.cse = ca;
        controller.getEmails();
        controller.getCse();
        
        controller.getShowSendTrackedEmailButton();
        
        List<EmailMessagesViewCon.EmailWrapper> unifiedList = controller.unifiedList;
        
        System.assert(unifiedList.size() > 0);
        EmailMessagesViewCon.EmailWrapper wrappedEmail = unifiedList.get(0);
        String s = wrappedEmail.displayEmailActions;
        s = wrappedEmail.displayArchivedActions;
        s = wrappedEmail.displayTrackedActions;
        s = wrappedEmail.displayEmailAddress;
        
        //Generate an exception
        PageReference pageRef1 = Page.EmailMessagesView;   
        pageRef1.getParameters().put('fieldValue',ca.Id);
        Test.setCurrentPage(pageRef1); 
        sc = new ApexPages.StandardController(account1);
        EmailMessagesViewCon controller1 = new EmailMessagesViewCon(sc);
        
        String emai = IDFS_Util.getIATACountryEmail('Canada');
        emai = IDFS_Util.getIATACountryEmail('caseBSPCountry');
        IDFS_Util.DeleteEmail(em3.Id);
        IDFS_Util.DeleteEmail('NoId');
        Test.stopTest();     
        
           
    }
}