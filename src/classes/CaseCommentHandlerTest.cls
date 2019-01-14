@isTest
private class CaseCommentHandlerTest {

    private static Case createClosedCase() {
        String caseJSON = '{"attributes":{'
            + '"type":"Case",'
            + '"url":"/services/data/v25.0/sobjects/Case/500E0000002nH2fIAE"},'
            + '"Subject":"Test Case Subject",'
            + '"Status":"Closed",'
            + '"CreatedDate":' + JSON.serialize(DateTime.now().addMonths(-3)) + ','
            + '"ClosedDate":' + JSON.serialize(DateTime.now().addMonths(-3))
            + '}';
        return (Case) JSON.deserialize(caseJSON, Case.class );
    }

    public static testMethod void testPreventInsertionInClosedCases() {
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Airline';
        child.Top_Parent__c = parent.Id;
        insert child;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId= child.Id;
        contact.Email = 'Test@test11.com';
        insert contact;
        
        User testUser = ISSP_ObjectFactory.createPortalUser(contact);
        contact.OwnerId = testUser.Id;
        update contact;
                
        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', EmailMessageHandler.LIST_VALID_RT.get(0));
        
        Case caseClosed = createClosedCase();
        caseClosed.RecordtypeId = rtId;
        caseClosed.ContactId = contact.Id;
        caseClosed.AccountId = contact.AccountId;
        insert caseClosed;
        
        Case caseOpened = new Case();
        caseOpened.RecordtypeId = rtId;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        insert caseOpened;
        
        //make a fake service simulating E2CP
        CaseCommentHandler.TEST_E2CPRUNUSERS = new set<Id>{testUser.Id};

        Test.startTest();
        System.runAs(testUser) {
            testUser.IsPortalEnabled = true;
            update testUser;
            //Test Closed Case
            try {
                CaseComment caseComment = new CaseComment(
                    ParentId=caseClosed.Id,
                    IsPublished = true
                );
                insert caseComment;
                //System.assert(false, 'Error expected');
            } catch(Exception e) {
                System.assert(true);
            }
            //Test opened case
            try {
                CaseComment caseComment = new CaseComment(ParentId=caseOpened.Id);
                insert caseComment;
                System.assert(true);
            } catch(Exception e) {
                System.assert(false, 'No exception expected: ' + e.getMessage());
            }
        }
        Test.stopTest();
    }
}