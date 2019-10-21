@isTest
public class CustomerInvoiceTriggerHandlerTest {

    @TestSetup
    static void testSetup(){
        Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account newAcc = new Account(Name='Account Test Headquarter', Site = 'Site Test', Sector__c = 'Airline', 
                                    IATACode__c = '123', Field_Head_Office__c = 'Headquarter', SIS_ID__c = '12345', Accounting_Code__c = 'xx', 
                                    RecordTypeId = accountAgencyRT);
        insert newAcc;

        //Contact newCon1 = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin');
        //insert newCon1;

        //User newUser = ISSP_ObjectFactory.createPortalUser(newCon1);

        Customer_Invoice__c newInv = new Customer_Invoice__c(Invoice_ID__c = 'id-123', Billed_Member_Id__c = '12345', 
                                                             Billing_Member_IS_Sub_Status__c = 'IATA OFFICE', Invoice_Status__c = 'Unpaid Invoice');
        insert newInv;
    }

    @isTest
    public static void createCustomerInvoiceTest() {
        Customer_Invoice__c inv = [SELECT Id, AccountId__c, Billed_Member_Accounting_Code__c FROM Customer_Invoice__c LIMIT 1];
        Account acc = [SELECT Id, Accounting_Code__c FROM Account LIMIT 1];

        System.AssertEquals(inv.AccountId__c, acc.Id);
        System.AssertEquals(inv.Billed_Member_Accounting_Code__c, acc.Accounting_Code__c);
    }

}
