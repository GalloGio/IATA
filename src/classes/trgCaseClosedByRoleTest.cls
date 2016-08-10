@isTest
private class trgCaseClosedByRoleTest {

    /**
        Return an active user with input profile
    **/
    public static User getUserWithProfile(String strProfile) {
        String searchText = '%' + strProfile + '%';
        try {
            User user = [Select id from User where Profile.Name like :searchText and isActive=true limit 1];
            //System.assert(user!=null, 'There is no user with profile like ' + strProfile);
            return user;
        } catch(Exception e) {
            return null;
        }
    }

    /**
        do a complete test with a user running the process with input profile
        and expectig Closed_by_Role__c  equal to second input parameter
    **/
    public static  void doTestWithProfile(String profileName, String expectedCloseByRole) {
        // get user with input profile
        User usr = getUserWithProfile(profileName);
        // if there is no active user ignore the test
        if (usr==null) return;

        // insert a closed case running with input user
        Case cse;
        Test.startTest();
        System.runAs(usr) {
            Account account = new Account(Name='testAccount');
            insert account;
            Contact contact = new Contact(FirstName='testContact',LastName='lastname', Phone='12345678', email='test@iata.com');
            insert contact;
            cse = new Case(Status='Closed', AccountId=account.id, contactId=contact.id);
            insert cse;
        }
        Test.stopTest();

        // check expected value for Closed_by_Role__c field
        cse = [Select Id, isClosed, Closed_by_Role__c from Case where id = :cse.Id];
        System.assertEquals(true,cse.isClosed);
        System.assertEquals(expectedCloseByRole, cse.Closed_by_Role__c);
    }

    public static testMethod void testISSPortal() {
        doTestWithProfile('ISS Portal','IATA Partner');
    }

    public static testMethod void testPortal1389712205152() {
        doTestWithProfile('IATA Portal1389712205152 Profile','IATA Partner');
    }

    public static testMethod void testHubCsManagement() {
        doTestWithProfile('Hub CS Management','Customer Service');
    }

    public static testMethod void testHubStuffAM() {
        doTestWithProfile('Hub Staff AM','Agency Management');
    }

}
