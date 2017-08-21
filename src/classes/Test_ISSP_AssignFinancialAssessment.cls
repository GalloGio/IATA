//Test method for the ISSP_AssignFinancialAssessmentContact
@isTest(seeAllData=true)
private class Test_ISSP_AssignFinancialAssessment {
    public static testMethod void testMyController(){
        RecordType rt = [Select id From RecordType Where DeveloperName = 'IATA_Airline' AND sObjectType='Account' limit 1];
        Account parent = new Account(Name='parent');
        insert parent;
        Account account = new Account(Name='test',Type='IATA Passenger Sales Agent', ParentId=parent.id, parent=parent, Location_Type__c='AO',RecordTypeId=rt.id);
        insert account;
        ISSP_AssignFinancialAssessmentContact ctrl = new ISSP_AssignFinancialAssessmentContact(new ApexPages.Standardcontroller(account));
        ctrl.getReturnPage();
        //ctrl.getCurrentFinContact();
        Contact contact = new Contact(AccountId=account.id, Financial_Assessment_Contact__c=true, firstName = 'Name', lastName='Test');
        insert contact;
        //ctrl.getCurrentFinContact();
    }
}