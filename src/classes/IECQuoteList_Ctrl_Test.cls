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
