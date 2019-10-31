@isTest
public class GDPR_Helper_TEST {

    @isTest
    static void knownUserWithoutIndividualTest(){

        //Do not let Leads and Contacts Triggers to execute

        AMS_Trigger_Execution_Manager__c manager = new AMS_Trigger_Execution_Manager__c(SetupOwnerId = Userinfo.getOrganizationId(), Lead_Triggers__c = 'LeadTrigger', 	Contact_Triggers__c = 'GlobalContactTrigger');
        INSERT manager;

        //Create a Lead without Individual  
        Lead l = new Lead(FirstName = 'Marc', LastName = 'Spector', Salutation = 'Mr.',  Email = 'marc.spector@marvel.com', Company='Marvel');
        INSERT l;
        
        //Check if a Lead exists with the provided email. A Lead should be found and an Individual created because there will be no Individual with the provided email.
        GDPR_Helper.UserType ut1 = GDPR_Helper.doUserExists('marc.spector@marvel.com');
        
        //Remove the connection between Lead and Individual
        l.IndividualId = null;

        UPDATE l;

        //Check if a Lead exists with the provided email. A Lead should be found and an Individual should also be found and connected with the Lead.
        ut1 = GDPR_Helper.doUserExists('marc.spector@marvel.com');

        //Create a Contact without Individual
        Contact c = new Contact(FirstName = 'Jake', LastName = 'Lockley', Salutation = 'Mr.',  Email = 'jake.lockley@marvel.com');
        INSERT c;

        //Check if a Contact exists with the provided email. A Contact should be found and an Individual created because there will be no Individual with the provided email.
        ut1 = GDPR_Helper.doUserExists('jake.lockley@marvel.com');

        //Remove the connection between Contact and Individual
        c.IndividualId = null;
        UPDATE c;

        //Check if a Contact exists with the provided email. A Contact should be found and an Individual should also be found and connected with the Contact.
        ut1 = GDPR_Helper.doUserExists('jake.lockley@marvel.com');

        //Check if a User exists with the provided email.
        ut1 = GDPR_Helper.doUserExists(Userinfo.getUserEmail());
        
    }

    @isTest
    static void knownUserWithIndividualTest(){
        
        //Test for Leads

        Lead l = new Lead(FirstName = 'Marc', LastName = 'Spector', Salutation = 'Mr.',  Email = 'marc.spector@marvel.com', Company='Marvel');
        INSERT l;
        GDPR_Helper.UserType ut1 = GDPR_Helper.doUserExists('marc.spector@marvel.com');
        
        
        //Test for Contacts
        Contact c = new Contact(FirstName = 'Jake', LastName = 'Lockley', Salutation = 'Mr.',  Email = 'jake.lockley@marvel.com');
        INSERT c;
        ut1 = GDPR_Helper.doUserExists('jake.lockley@marvel.com');

    }

    @isTest
    static void unknownUserTest(){
        GDPR_Helper.UserType ut1 = GDPR_Helper.doUserExists('marc.spector@iatatestfakeemail.com');
    }

    @isTest
    static void retrieveInofTest(){
         Lead l = new Lead(FirstName = 'Marc', LastName = 'Spector', Salutation = 'Mr.',  Email = 'marc.spector@marvel.com', Company='Marvel');
        INSERT l;

        // Simulate Pardot prospect respons
	   // Insert credential
        Pardot_API__c pardotSetting = new Pardot_API__c();
        pardotSetting.API_Version__c = '4';
        pardotSetting.Password__c = 'fakePassword';
        pardotSetting.User_Key__c = '111111111';
        pardotSetting.Email__c = 'fake@fake.com';
        pardotSetting.Assigned_User__c = '1111111';
        insert pardotSetting;
        Pardot_API_RequestMock_Test fakeResponse =  new Pardot_API_RequestMock_Test('MOCK_READ_PROSPECT');
		Test.setMock(HttpCalloutMock.class, fakeResponse);

		Test.startTest();
        Individual i = [SELECT id FROM Individual LIMIT 1];

        GDPR_Helper.retrieveUserInfo('', false);
        GDPR_Helper.retrieveUserInfo(Comm_User_Helper.EncryptString(i.id), true);
        Test.stopTest();

    }
}