@isTest
private class AMS_CaseListTest {
    
    @testSetup static void setup(){
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        TransformationHelper.triggerOnCaseNSerRen = true;
		Id standardAccountRt = AMS_Utils.getId('Account', 'Standard_Account');

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;
		
        Account a = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = standardAccountRt, Name='Test Agency', IATAcode__c = '1234567', Short_Name__c = 'Test Agency', Source_System__c = 'AIMS');
        insert a;

        Account acc = [select id from Account];

        Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

        Contact co1 = new Contact(AccountId = acc.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com',
                                    Financial_Assessment_Contact__c = false);
        insert co1;

        Case c1 = new Case(recordTypeId = caseRT.get('ProcessEuropeSCE'), accountid = acc.id, ContactId = co1.id, CaseArea__c = 'Accreditation Process',Late_Payment_Date__c = Date.today());
        Case c2 = new Case(recordTypeId = caseRT.get('ProcessEuropeSCE'), accountid = acc.id, ContactId = co1.id, CaseArea__c = 'Accreditation Process',Late_Payment_Date__c = Date.today());
        Case c3 = new Case(recordTypeId = caseRT.get('ProcessEuropeSCE'), accountid = acc.id, ContactId = co1.id, CaseArea__c = 'Risk Management Process',Late_Payment_Date__c = Date.today());
        Case c4 = new Case(recordTypeId = caseRT.get('ProcessEuropeSCE'), accountid = acc.id, ContactId = co1.id, CaseArea__c = 'Risk Management Process',Late_Payment_Date__c = Date.today());
        Case c5 = new Case(recordTypeId = caseRT.get('SIDRA'), ContactId = co1.id, accountid = acc.id,Late_Payment_Date__c = Date.today());
        Case c6 = new Case(recordTypeId = caseRT.get('SIDRA'), ContactId = co1.id, accountid = acc.id,Late_Payment_Date__c = Date.today());
        Case c7 = new Case(recordTypeId = caseRT.get('CasesMENA'), ContactId = co1.id, accountid = acc.id,Late_Payment_Date__c = Date.today());
        Case c8 = new Case(recordTypeId = caseRT.get('CasesMENA'), ContactId = co1.id, accountid = acc.id,Late_Payment_Date__c = Date.today());
        Case c9 = new Case(recordTypeId = caseRT.get('InternalCasesEuropeSCE'), ContactId = co1.id, accountid = acc.id,Late_Payment_Date__c = Date.today());
        Case c10 = new Case(recordTypeId = caseRT.get('InternalCasesEuropeSCE'), ContactId = co1.id, accountid = acc.id,Late_Payment_Date__c = Date.today());

        List<Case> listOfCases = new List<Case>();
        listOfCases.add(c1);
        listOfCases.add(c2);
        listOfCases.add(c3);
        listOfCases.add(c4);
        listOfCases.add(c5);
        listOfCases.add(c6);
        listOfCases.add(c7);
        listOfCases.add(c8);
        listOfCases.add(c9);
        listOfCases.add(c10);

        insert listOfCases;

        c2.Status = 'Closed';
        c4.Status = 'Closed';
        c6.Status = 'Closed';
        c8.Status = 'Closed';
        c9.Status = 'Closed';
        c10.Status = 'Closed';

        c2.OwnerId = UserInfo.getUserId();
        c4.OwnerId = UserInfo.getUserId();
        c6.OwnerId = UserInfo.getUserId();
        c8.OwnerId = UserInfo.getUserId();
        c9.OwnerId = UserInfo.getUserId();
        c10.OwnerId = UserInfo.getUserId();
        
        update listOfCases;

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
        TransformationHelper.triggerOnCaseNSerRen = false;
    }

    @isTest static void test_CaseList() {
    	Id standardAccountRt = AMS_Utils.getId('Account', 'Standard_Account');
        PageReference pageRef = Page.AMS_DemoCaseListPage;
        Test.setCurrentPageReference(pageRef);

        Account ag = [select id from Account where RecordTypeId = :standardAccountRt];

        ApexPages.CurrentPage().getparameters().put('id', ag.id);
        ApexPages.StandardController sc = new ApexPages.standardController(ag);
		
        Test.startTest();
        AMS_DemoCaseList sic = new AMS_DemoCaseList(sc);
        sic.getItems();
        sic.radioSelectAction();
        List<Case> cases = new List<Case>();
        cases = sic.getSIDRACases();
        system.assertEquals(1,cases.size());
        cases = sic.getAccreditationCases();
        system.assertEquals(1,cases.size());
        cases = sic.getCustomerServiceCases();
        system.assertEquals(1,cases.size());
        cases = sic.getAgencyRiskManagementCases();
        system.assertEquals(1,cases.size());

        sic.filterAccreditation = 'Closed';
        sic.filterSidra = 'Closed';
        sic.filterCustomerService = 'Closed';
        sic.filterAgencyRiskManagement = 'Closed';
        cases = sic.getSIDRACases();
        system.assertEquals(1,cases.size());
        cases = sic.getAccreditationCases();
        system.assertEquals(1,cases.size());
        cases = sic.getCustomerServiceCases();
        system.assertEquals(1,cases.size());
        cases = sic.getAgencyRiskManagementCases();
        system.assertEquals(1,cases.size());

        sic.filterAccreditation = 'All';
        sic.filterSidra = 'All';
        sic.filterCustomerService = 'All';
        sic.filterAgencyRiskManagement = 'All';
        cases = sic.getSIDRACases();
        system.assertEquals(2,cases.size());
        cases = sic.getAccreditationCases();
        system.assertEquals(2,cases.size());
        cases = sic.getCustomerServiceCases();
        system.assertEquals(2,cases.size());
        cases = sic.getAgencyRiskManagementCases();
        system.assertEquals(2,cases.size());
        Test.stopTest();
    }
}