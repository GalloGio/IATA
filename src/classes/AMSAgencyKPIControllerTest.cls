@isTest
private class AMSAgencyKPIControllerTest {

	@testSetup static void setup(){
        //Account acc = new Account(Name='Test Account1', IATAcode__c = '12345678');
        //insert acc;
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        insert accountList;
        
        AMS_Agency__c a1 = new AMS_Agency__c(Account__c= acc1.Id, RecordTypeId=agenciesRT.get('PASSENGER'), Name='Test1 Agency', IATAcode__c = '1234567', Chk_dgt__c = '7', Legal_Name_1__c = 'Test1 Agency', Legacy_External_ID__c = '12345677', Legacy_System__c = 'AIMS', Country__c=isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Account__c= acc2.Id,RecordTypeId=agenciesRT.get('PASSENGER'), Name='Test2 Agency', IATAcode__c = '1234567', Chk_dgt__c = '8', Legal_Name_1__c = 'Test2 Agency', Legacy_External_ID__c = '12345678', Legacy_System__c = 'AIMS', Country__c=isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Account__c= acc3.Id,RecordTypeId=agenciesRT.get('PASSENGER'), Name='Test3 Agency', IATAcode__c = '1234567', Chk_dgt__c = '9', Legal_Name_1__c = 'Test3 Agency', Legacy_External_ID__c = '12345679', Legacy_System__c = 'AIMS', Country__c=isoc.id);
        List<AMS_Agency__c> listOfAgencies = new List<AMS_Agency__c>();
        listOfAgencies.add(a1);
        listOfAgencies.add(a2);
        listOfAgencies.add(a3);
        insert listOfAgencies;

        AMS_Agencies_Hierarchy__c ah = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='MAIN');
        insert ah;

        AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Hierarchy__c = ah.id, Parent_agency__c = a1.id, Child_Agency__c = a2.id);
        AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Hierarchy__c = ah.id, Parent_agency__c = a2.id, Child_Agency__c = a3.id);
        List<AMS_Agencies_relationhip__c> listOfRelationships = new List<AMS_Agencies_relationhip__c>();
        listOfRelationships.add(ar1);
        listOfRelationships.add(ar2);
        insert listOfRelationships;
    }
	
	@isTest static void test_AMSAgencyKPIControllerChild() {
		PageReference pageRef = Page.AMS_DemoTreeViewPage;
    	Test.setCurrentPageReference(pageRef);

    	AMS_Agency__c ag = [select id from AMS_Agency__c where Name = 'Test2 Agency'];

        ApexPages.CurrentPage().getparameters().put('pid', ag.id);
        ApexPages.StandardController sc = new ApexPages.standardController(ag);

        Test.startTest();
        AMSAgencyKPIController sic = new AMSAgencyKPIController(sc);
        Test.stopTest();
	}	
}