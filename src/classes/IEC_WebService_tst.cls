@isTest(SeeAllData=true)
private class IEC_WebService_tst {

    static testMethod void testAssignOpportunityToQuote() {
        test.startTest();
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        IECCustomer loggedCustomer;
        System.runAs(usr) {
            loggedCustomer = IECCustomer.getCurrentIECCustomer(); 
        }
        
        Opportunity oOpportunity = IECTestUtil.createSampleOpportunity(loggedCustomer.RelatedAccount, 'Sample Opportunity', 100);
        insert oOpportunity;
        zqu__Quote__c oQuote = IECTestUtil.createSampleQuote(oOpportunity, loggedCustomer.RelatedContact, 'Sample Comments', false);
        insert oQuote;
        
        IEC_WebService.assignOpportunityToQuote(oQuote.Id);
        test.stopTest();
    }
    
    static testMethod void testContactUpdate() {
        
        Account oAccount = IECTestUtil.createSampleAccount();
        insert oAccount;
        
        Contact oContact = IECTestUtil.createSampleContact(oAccount);
        insert oContact;
        
        // reselect contact
        oContact = [Select id, FirstName, LastName, Salutation,Email, Title, Phone, Tax_1_ID__c, Tax_2_ID__c,VAT_Country_Code__c, User_IECPortal_Status__c from Contact where Id = :oContact.Id limit 1];
        
        oContact.Title = 'Sith Lord';
        
        // update contact via web service
        Boolean bSuccess = IEC_WebService.updateContact(oContact.Id, 
                                                oContact.FirstName, 
                                                oContact.LastName, 
                                                oContact.Email,
                                                oContact.Salutation, 
                                                oContact.Title, 
                                                oContact.Phone, 
                                                oContact.Tax_1_ID__c, 
                                                oContact.Tax_2_ID__c, 
                                                oContact.VAT_Country_Code__c,        
                                                oContact.User_IECPortal_Status__c);
                                                
        system.assert(bSuccess, 'Contact update should be successful');
        
        // reselect contact
        oContact = [Select id, FirstName, LastName,Email, Salutation, Title, Phone, Tax_1_ID__c, Tax_2_ID__c,VAT_Country_Code__c, User_IECPortal_Status__c from Contact where Id = :oContact.Id limit 1];
        
        // compare Title field
        system.assertEquals('Sith Lord', oContact.Title, 'The field title should be updated accordingly');
    }
}