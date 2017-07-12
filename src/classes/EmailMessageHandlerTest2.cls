@isTest
private class EmailMessageHandlerTest2 {
    
    private static Case createClosedCase() {
        String caseJSON = '{"attributes":{'
            + '"type":"Case",'
            + '"url":"/services/data/v25.0/sobjects/Case/500E0000002nH2fIAE"},'
            + '"CreatedDate":' + JSON.serialize(DateTime.now().addMonths(-3)) + ','
            + '"Subject":"Test Case Subject",'
            + '"Status":"Closed",'
            + '"ClosedDate":' + JSON.serialize(DateTime.now().addMonths(-3)) + ','
            + '"RecordTypeId":"' + RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get(EmailMessageHandler.LIST_VALID_RT.get(0)) + '"'
            + '}';
            //+ '"ContactId":"' + contact.id + '",'
            //+ '"AccountId":"' + account.id + '",'
        return (Case) JSON.deserialize(caseJSON, Case.class );
    }
    
    static testMethod void test_sendEmailToSenderWhenCaseClosed_OK() {
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        EmailTemplate template = new EmailTemplate(
            Name = 'Test_Template',
            DeveloperName = 'Test_Template',
            Subject = 'test template',
            HtmlValue = '<html></html>',
            TemplateType = 'text',
            isActive = true,
            FolderId = USerInfo.getUSerId());
        System.RunAs(usr) {
            insert template;
        }
        
        Case_Closed_Templates__c customSetting = new Case_Closed_Templates__c();
        customSetting.Name = 'test';
        customSetting.Template_Id__c = template.id;
        insert customSetting;

        // create a SIDRA case
        Contact contact = new Contact();
        contact.FirstName = 'test contact';
        contact.LastName = 'last name';
        contact.Email = 'test1@example.com';
        insert contact;
        
        Account account = new Account(Name='test Account');
        insert account;
        
        Case aCase = createClosedCase();
        aCase.accountId = account.Id;
        aCase.contactId = contact.Id;
        insert aCase;
        
        test.startTest();
            // simulate the creation of an email message
            EmailMessage em = new EmailMessage();
            em.parentId = acase.Id;
            em.FromAddress = 'test2@example.com';
            insert em;
        test.stopTest();
        
        // assert that the case NOI Sent was set
        list<EmailMessage> listEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :aCase.Id];
        //System.assertEquals(2,listEmails.size());
        System.debug('*** Assert 2 == ' + listEmails.size());
    }
}