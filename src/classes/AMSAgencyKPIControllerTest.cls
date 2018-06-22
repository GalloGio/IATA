@isTest
    private class AMSAgencyKPIControllerTest {

    @testSetup static void setup(){
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account', Sector__c='Travel Agent', IATAcode__c = '12345677', IATA_ISO_Country__c=isoc.id);
        Account acc2 = new Account(Name='Test2 Account', Sector__c='Travel Agent', IATAcode__c = '12345678', IATA_ISO_Country__c=isoc.id);
        Account acc3 = new Account(Name='Test3 Account', Sector__c='Travel Agent', IATAcode__c = '12345679', IATA_ISO_Country__c=isoc.id);
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        insert accountList;

        AMS_Agencies_Hierarchy__c ah = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='MAIN');
        insert ah;

        AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Hierarchy__c = ah.id, Parent_Account__c = acc1.id, Child_Account__c = acc2.id);
        AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Hierarchy__c = ah.id, Parent_Account__c = acc1.id, Child_Account__c = acc3.id);
        List<AMS_Agencies_relationhip__c> listOfRelationships = new List<AMS_Agencies_relationhip__c>();
        listOfRelationships.add(ar1);
        listOfRelationships.add(ar2);
        insert listOfRelationships;
    }

    @isTest static void test_AMSAgencyKPIControllerChild() {
        PageReference pageRef = Page.AMS_DemoTreeViewPage;
        Test.setCurrentPageReference(pageRef);
        Account acc = [select id from Account where Name = 'Test2 Account'];

        ApexPages.CurrentPage().getparameters().put('id', acc.id);
        ApexPages.StandardController sc = new ApexPages.standardController(acc);

        Test.startTest();
        AMSAgencyKPIController sic = new AMSAgencyKPIController(sc);
        Test.stopTest();
    }  
}