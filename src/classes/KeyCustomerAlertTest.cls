@isTest(SeeAllData=true)
private class KeyCustomerAlertTest {
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

        Case_RTs_for_Key_Customer_alert__c cs = New Case_RTs_for_Key_Customer_alert__c();
        cs.Record_Type__c = 'sMAP_sales_Monitoring_Alert_Process';
        cs.Name = 'Test';
        insert cs;

        Test.startTest(); 
            KeyCustomerAlertCtrl.KeyCustomerAlertInfo kcai = KeyCustomerAlertCtrl.getKeyCustomerAlertInfo(ca.Id);
            System.assertEquals(ca.id, kcai.CaseDetail.id);
            Case testCase = EscalatewithinIATAKeyCustomerAlertCtrl.getCaseInfo(ca.Id);
            System.assertEquals(ca.id, testCase.id);
        Test.stopTest();     
        
           
    }
}