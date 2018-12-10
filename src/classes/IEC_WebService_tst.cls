@isTest(SeeAllData=true)
private class IEC_WebService_tst {

    @isTest
    static void testAssignOpportunityToQuote() {

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        IECCustomer loggedCustomer;

        System.runAs(usr) {
            loggedCustomer = IECCustomer.getCurrentIECCustomer();
        }
        Opportunity oOpportunity = IECTestUtil.createSampleOpportunity(loggedCustomer.RelatedAccount, 'Sample Opportunity', 100);
        insert oOpportunity;

        //create quote template
        Zqu__Quote_Template__c quoteTemplate = new Zqu__Quote_Template__c(name = 'Test Quote Template', zqu__Quote_Type__c = 'New Subscription', zqu__Template_Id__c = 'TestID');
        insert quoteTemplate;

        //create settings for template id
        IEC_Settings__c iecSettings = IEC_Settings__c.getOrgDefaults();
        iecSettings.Quote_Template_ID_New_Subscription__c = quoteTemplate.Id;
        iecSettings.IEC_User_Portal_URL__c = 'https://iec-customer-portal-iata.cs17.force.com/iec';
        iecSettings.PaymentMethod_ICH_Zuora_ID__c = 'testPaymentMethod';
        update iecSettings;

        zqu__Quote__c oQuote = IECTestUtil.createSampleQuote(oOpportunity, loggedCustomer.RelatedContact, 'Sample Comments', false);
        insert oQuote;

        test.startTest();

        IEC_WebService.assignOpportunityToQuote(oQuote.Id);

        zqu__Quote__c updatedQuote = [SELECT Id, IEC_Opportunity_Id__c, zqu__Opportunity__c, zqu__Number__c, name FROM zqu__Quote__c WHERE Id = :oQuote.Id];
        //assert quote was updated
        System.assertEquals(updatedQuote.IEC_Opportunity_Id__c, updatedQuote.zqu__Opportunity__c);
        System.assertEquals(updatedQuote.zqu__Number__c, updatedQuote.name);

        test.stopTest();
    }

    @isTest
    static void testContactUpdate() {

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