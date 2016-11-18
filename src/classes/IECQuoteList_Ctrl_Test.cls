/****************************************************************************************************
    Created by CGI, Thai 2015-11-17
        Cover code of controller class "IECQuoteList_Ctrl"
****************************************************************************************************/

@isTest(seeAllData=true)
public without sharing class IECQuoteList_Ctrl_Test {


/****************************************************************************************************
    Created by CGI, Thai 2015-11-17
        Cover code all methods in class
        Indirectly cover
            Method "getQuotesList" of class "Order_Sel"
****************************************************************************************************/
@isTest
static void test_AllMethod() {
    /*TestDataGenerator.generateApexSetting();
    TestDataGenerator.generateISOCountryState();
    
    //*** generate accounts
    String strClientType = IECConstants.Account_ClientType_MemberAirline;
    List<Account> lstAccount = TestDataGenerator.generateAccounts(1, false);
    lstAccount[0].RecordTypeId = IECUserManager.getAccountRecordTypeForIEC(strClientType);
    insert lstAccount;

    //*** generate contacts
    List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 1, true);

    //*** generate portal contacts
    List<User> lstUser = new List<User> {TestDataGenerator.generatePortalUser('ISS Portal', lstContact[0].Id, true)};

    //*** generate products
    List<zqu__ZProduct__c> lstZProduct = TestDataGenerator.generateZProducts(1, true);
    List<zqu__ProductRatePlan__c> lstZRatePlan = TestDataGenerator.generateZRatePlans(lstZProduct[0].Id, 1, true);
    List<zqu__ProductRatePlanCharge__c> lstZRatePlanCharge = TestDataGenerator.generateZCharges(lstZRatePlan[0].Id, 1, false);
    lstZRatePlanCharge[0].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
    insert lstZRatePlanCharge;
    List<Product2> lstProduct = TestDataGenerator.generateProducts(1, false);
    lstProduct[0].SAP_Status_Code__c = 'A';
    lstProduct[0].Post_to_Ecommerce_Date__c = System.today().addDays(-7);
    lstProduct[0].ZProduct__c = lstZProduct[0].Id;
    insert lstProduct;
    List<PricebookEntry> lstPriceBook = new List<PricebookEntry>{new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=lstProduct[0].Id, UnitPrice=10)};
    insert lstPriceBook;

    //*** generate order
    List<Order> lstOrder = TestDataGenerator.generateOrder(1, lstAccount[0].Id, lstContact[0].Id, lstContact[0].Id, false);
    lstOrder[0].Type = 'Quote';
    lstOrder[0].EffectiveDate = system.today().addDays(-3);
    lstOrder[0].EndDate = system.today().addDays(-2);
    insert lstOrder;
    List<OrderItem> lstOrderItem = TestDataGenerator.generateOrderItem(lstOrder[0].Id, 1, true);

    //*** test
    system.runAs(lstUser[0]) {
        Test.setCurrentPageReference(new PageReference('/apex/IECQuoteList'));
        IECQuoteList_Ctrl cls = new IECQuoteList_Ctrl();
        //system.Assert(cls.lstQuotes[0].isExpired, 'Wrong data: ' + cls.lstQuotes);
    }*/

    IECQuoteList_Ctrl clsBeforeLog = new IECQuoteList_Ctrl();
    clsBeforeLog.pageLoad();

    User usr = IECTestUtil.createSampleGuestUserAndLogin();

    //set all Custom setting
    TestDataGenerator.generateApexSetting();
    List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
    List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
    
    system.debug('usr.ContactId ' + usr.ContactId);

    List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, usr.ContactId, contacts[1].Id,false); // 1 Order
    orders[0].Type = 'Quote';
    orders[0].EffectiveDate = system.today().addDays(-3);
    orders[0].EndDate = system.today().addDays(2);
    insert orders;
    List<OrderItem> orderItems = TestDataGenerator.generateWebDownloadOrderItem(orders[0].Id, 3,true);// 3 lineItems for Order

    system.runAs(usr){
        
        IECQuoteList_Ctrl cls = new IECQuoteList_Ctrl();

        //Cover the page load method
        cls.pageLoad();

        //cover the reset Email and cancel send quote methodes
        cls.cancelSendQuote();

        //Cover the send email method
        PageReference pageRef = Page.IEC_ViewQuotes;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('quoteShipToEmail','test@test.com');
        ApexPages.currentPage().getParameters().put('quoteNumber', orders[0].OrderNumber);  
        cls.sendEmail();

        cls.sendQuote();

        ApexPages.currentPage().getParameters().put('emailSubject','emailSubject');
        ApexPages.currentPage().getParameters().put('emailTo','test@test.com');
        ApexPages.currentPage().getParameters().put('emailCC','test1@test.com');
        ApexPages.currentPage().getParameters().put('emailBCC','test2@test.com');
        cls.sendQuote();

        system.Assert(!cls.lstQuotes[0].isExpired, 'Wrong data: ' + cls.lstQuotes);

    }
    



} //*** end of "test_AllMethod"


} //*** end of class