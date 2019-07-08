@IsTest
public class PortalMyProfileCtrlTest {

    @TestSetup
    static void testSetup(){
        Account newAcc = new Account(Name='Account Test CSP Utils');
        insert newAcc;

        Contact newCon = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin');
        insert newCon;

        User newUser = ISSP_ObjectFactory.createPortalUser(newCon);

        Date validTo = Date.today().addYears(2);

        ID_Card__c card = new ID_Card__c(Related_Contact__c =newCon.Id, Valid_To_Date__c =validTo, VER_Number__c='123321', Valid_From_Date__c =Date.today().addDays(-2), Name_on_ID_Card__c='TestCard123');
        insert card;
    }

    @IsTest
    static void testgetContactInfo(){
        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

        Contact testContact = new Contact();
        System.runAs(usr){
            Test.startTest();
            testContact = PortalMyProfileCtrl.getContactInfo().contact;
            Test.stopTest();

            System.assert( testContact!=null );
        }
    }

}
