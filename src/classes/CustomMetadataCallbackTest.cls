@isTest
public class CustomMetadataCallbackTest {

     @TestSetup
    static void testSetup(){
        Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account newAcc = new Account(Name='Account Test Headquarter', Site = 'Site Test', Sector__c = 'Airline', 
                                    IATACode__c = '123', Field_Head_Office__c = 'Headquarter', 
                                    RecordTypeId = accountAgencyRT);
        insert newAcc;

        Contact newCon1 = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin');
        insert new List<Contact>{newCon1};

        User newUser = ISSP_ObjectFactory.createPortalUser(newCon1);
    }

    @IsTest
    static void testHandleResult(){
        User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
              
        System.runAs(usr) {
            Test.startTest();
            List<CustomMetadataCallback.CustomMetadataType> cmdtDTLIST = new List<CustomMetadataCallback.CustomMetadataType>();
            CustomMetadataCallback.CustomMetadataType cmdtDT = new CustomMetadataCallback.CustomMetadataType();
            cmdtDT.strMDTAndRecord = 'PortalFAQs__mdt.' + 'x' + 'NameTest';
            cmdtDT.strMasterLabel = '' + 'x' + 'NameTest';
            cmdtDT.fieldLIST = new List<String>{'DataCategoryName__c', 'FAQsStructure__c', 'DataCategoryLabel_en_US__c'};
            cmdtDT.valueLIST = new List<Object>{'' + 'NameTest', true, '' + 'Name Test'};
            cmdtDTLIST.add(cmdtDT);
            
            CustomMetadataCallback.Upsert_MDT_Value(cmdtDTLIST);
            Test.stopTest();
        }

    }
}
