@IsTest
public class PortalMyProfileCtrlTest {

    @TestSetup
    static void testSetup(){
        Account newAcc = new Account(Name='Account Test CSP Utils');
        insert newAcc;

        Contact newCon = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin');
        insert newCon;
        
        String RECTYPE_Master_AccRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
        Account_Role__c accRole = new Account_Role__c(Account__c = newAcc.Id, Account_Role_Name__c = 'Training',Functional_Role__c = 'Training', RecordTypeId = RECTYPE_Master_AccRole );
        insert accRole;

        Id accContactRole_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Master');
        Account_Contact_Role__c acr = new Account_Contact_Role__c(Account_Role__c = accRole.Id, Contact__c = newCon.Id, Service_Rendered__c = 'Other', RecordTypeId = accContactRole_RT, Contact_Role_Name__c = 'Trainee', Functional_Role__c =  'Training');
        insert acr;

        String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Training_Contact_Role_Details__c', 'Yardstick_Trainee');
        Training_Contact_Role_Details__c tcrd = new Training_Contact_Role_Details__c(Account_Contact_Role__c = acr.Id, RecordTypeId = RECTYPE_Trainee_YASContDet);
        insert tcrd;

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