//Test method for the ISSP_AssignFinancialAssessmentContact
@isTest(seeAllData=true)
private class Test_ISSP_AssignFinancialAssessment {
    @isTest
    public static void testMyController(){
        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account parent = new Account(Name='parent');
        insert parent;
        Account account = new Account(Name='test',Type='IATA Passenger Sales Agent', ParentId=parent.id, parent=parent, Location_Type__c='AO',RecordTypeId=rtId);
        insert account;
        ISSP_AssignFinancialAssessmentContact ctrl = new ISSP_AssignFinancialAssessmentContact(new ApexPages.Standardcontroller(account));
        ctrl.getReturnPage();
        //ctrl.getCurrentFinContact();
        Contact contact = new Contact(AccountId=account.id, Financial_Assessment_Contact__c=true, firstName = 'Name', lastName='Test');
        insert contact;
        //ctrl.getCurrentFinContact();
    }
}