@isTest
public class ISSP_IFAPCasesTest {

    public static testMethod void testISSP_IFAPCases() {
        
        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c();
        ISO_Country.ISO_Code__c = '12';
        ISO_Country.Name = 'Canada';
        ISO_Country.AIMS_Area_Name__c = 'Canada';
        ISO_Country.AIMS_Area_ID__c = '1';
        insert ISO_Country;
        
        Id recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.Type = 'IATA Passenger Sales Agent';
        account.IATACode__c = '12345678';
        account.Name = 'Account1';
        account.BillingCountry = 'Canada';
        account.IATA_ISO_Country__c = ISO_Country.Id;
        account.Location_Type__c = 'HO';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.Financial_Assessment_Contact__c = true;
        insert contact;
        Case c = new Case(
        			Subject='test 1',
        			Status='Open',
        			AccountId=account.id,
        			ContactId=contact.id,
        			Region__c = 'Europe',
        			RecordTypeId = recordtypeid,
        			IFAP_Financial_Year__c = '2022');
        insert c;
        try
        {
            ISSP_IFAPCases controller = new ISSP_IFAPCases();
            String pr = ApexPages.currentPage().getURL();
            controller.getIsEmpty();
    		controller.checkRedirect();
    		ApexPages.currentPage().getParameters().put('id', c.Id);
    		controller.getIsEmpty();
            controller = new ISSP_IFAPCases();
            controller.getIFAPCasesOnly();
            controller.con = 'Test con';
            controller.thisCase = c;
            List<String> testList = new List<String>();
            testList.add('Test Error');
            testList.add('Test Success');
            controller.errorMessage = testList;
            controller.successMessage = testList;
            controller.redirect(pr);
        } catch (Exception e) {}
    }
    
    public static testMethod void testISSP_IFAPCases_2() {

        ISSP_IFAPCases controller = new ISSP_IFAPCases();
        controller.getIsEmpty();
        controller.checkRedirect();
    }
}