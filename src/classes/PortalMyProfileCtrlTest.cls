@IsTest
public class PortalMyProfileCtrlTest {

    @TestSetup
    static void testSetup(){
        Account newAcc = new Account(Name='Account Test CSP Utils');
        insert newAcc;

        Contact newCon = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin');
        insert newCon;

        User newUser = ISSP_ObjectFactory.createPortalUser(newCon);
    }

    @IsTest
    static void testgetContactInfo(){
        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

        Contact testContact = new Contact();
        System.runAs(usr){
            Test.startTest();
            testContact = PortalMyProfileCtrl.getContactInfo();
            Test.stopTest();

            System.assert( testContact!=null );
        }
    }

}
