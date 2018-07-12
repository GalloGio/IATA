@isTest
private class AMS_TreeViewTest {

    @testSetup static void setup(){
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

		Id standardAccountRt = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = standardAccountRt, Name='Test1 Agency', IATAcode__c = '1234567', Short_Name__c = 'Test1 Agency', /*Legacy_External_ID__c = '12345677',*/ Source_System__c = 'AIMS');
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = standardAccountRt, Name='Test2 Agency', IATAcode__c = '1234565', Short_Name__c = 'Test2 Agency', /*Legacy_External_ID__c = '12345678',*/ Source_System__c = 'AIMS');
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = standardAccountRt, Name='Test3 Agency', IATAcode__c = '1234564', Short_Name__c = 'Test3 Agency', /*Legacy_External_ID__c = '12345679',*/ Source_System__c = 'AIMS');
        List<Account> listOfAgencies = new List<Account>();
        listOfAgencies.add(a1);
        listOfAgencies.add(a2);
        listOfAgencies.add(a3);
        insert listOfAgencies;

        AMS_Agencies_Hierarchy__c ah = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='MAIN');
        insert ah;

        AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Hierarchy__c = ah.id, Parent_Account__c = a1.id, Child_Account__c = a2.id);
        AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Hierarchy__c = ah.id, Parent_Account__c = a2.id, Child_Account__c = a3.id);
        List<AMS_Agencies_relationhip__c> listOfRelationships = new List<AMS_Agencies_relationhip__c>();
        listOfRelationships.add(ar1);
        listOfRelationships.add(ar2);
        insert listOfRelationships;
    }
    
    @isTest static void test_TreeViewChild() {
        PageReference pageRef = Page.AMS_DemoTreeViewPage;
        Test.setCurrentPageReference(pageRef);

        Account ag = [select id from Account where Name = 'Test2 Agency'];

        ApexPages.CurrentPage().getparameters().put('id', ag.id);
        ApexPages.StandardController sc = new ApexPages.standardController(ag);

        Test.startTest();
        AMS_DemoTreeview sic = new AMS_DemoTreeview(sc);
        sic.fetchHierchyParent();
        sic.getHierchyChilds();
        Test.stopTest();
    }

    @isTest static void test_TreeViewParent() {
        PageReference pageRef = Page.AMS_DemoTreeViewPage;
        Test.setCurrentPageReference(pageRef);

        Account ag = [select id from Account where Name = 'Test1 Agency'];

        ApexPages.CurrentPage().getparameters().put('id', ag.id);
        ApexPages.StandardController sc = new ApexPages.standardController(ag);

        Test.startTest();
        AMS_DemoTreeview sic = new AMS_DemoTreeview(sc);
        sic.fetchHierchyParent();
        sic.getHierchyChilds();
        Test.stopTest();
    }
}