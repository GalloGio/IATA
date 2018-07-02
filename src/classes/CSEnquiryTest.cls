@isTest
public class CSEnquiryTest {

        @isTest static void test_method_one() {

                IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US')  ;
                insert ctry ;
                Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
                Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, Location_Type__c = 'HO', IATACode__c = '1234567', Name = 'Test1 Agency', Short_Name__c = 'Test1 Agency', Status__c = AMS_Utils.ACC_S9_APPROVED);
                insert a1;
                Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname = 'test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
                insert co1;

                CSEnquiry test = new CSEnquiry();

                test.enquiryInfo.CustomerType = 'test';
                test.enquiryInfo.TIESSCode = 'test';
                test.enquiryInfo.IATACode = 'test';
                test.enquiryInfo.Country = 'test';
                test.enquiryInfo.Company = 'test';
                test.enquiryInfo.ContactName = 'test';
                test.enquiryInfo.EmailAddress = 'test@test.com';
                test.enquiryInfo.PhoneNumber = 'test';
                test.enquiryInfo.CaseArea = 'test';
                test.enquiryInfo.Subject = 'test';
                test.enquiryInfo.Description = 'test';
                test.enquiryInfo.ContactID = co1.Id;
                test.enquiryInfo.IPAddress = 'test';
                //test.enquiryInfo.CaseID='test';
                test.enquiryInfo.region = 'test';
                test.enquiryInfo.FilesPerName = new map<String, Blob> {'test' => Blob.valueOf('test')};

                CSEnquiry.CreateEnquiry(test.enquiryInfo);
        }

}