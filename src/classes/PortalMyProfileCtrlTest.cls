@IsTest
public class PortalMyProfileCtrlTest {

    @TestSetup
    static void testSetup(){
        Account newAcc = new Account(Name='Account Test CSP Utils');
        insert newAcc;

        Contact newCon = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin');
        insert newCon;

        User newUser = ISSP_ObjectFactory.createPortalUser(newCon);


        ID_Card__c idc= new ID_Card__c();
        idc.recordtypeid= RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');
        idc.Name_on_ID_Card__c='test card 1';
        idc.related_contact__C=newCon.id;
        idc.ver_number__c='123123';
        idc.Valid_From_Date__c=system.today().addDays(-200);
        idc.valid_to_Date__C=system.today().addDays(200);
        
        insert idc;
    }

    @IsTest
    static void testgetContactInfo(){
        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

        PortalMyProfileCtrl.ContactWrapper testContact = new PortalMyProfileCtrl.ContactWrapper();
        System.runAs(usr){
            Test.startTest();
            testContact = PortalMyProfileCtrl.getContactInfo();
            Test.stopTest();

            System.assert( testContact.contact.Name =='John Doe',true);
        }
    }

}