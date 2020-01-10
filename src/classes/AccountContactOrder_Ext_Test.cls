/****************************************************************************************************
	Created by CGI, Thai 2015-10-05
		Cover code of controller class "AccountContactOrder_Ext"
****************************************************************************************************/
@isTest(seeAllData=false)
public class AccountContactOrder_Ext_Test {


/****************************************************************************************************
	Created by CGI, Thai 2015-09-04
		Cover code all methods in class
		Indirectly cover
			Method "getOrderForAccountOrContact" of class "Order_Sel"
****************************************************************************************************/
static testMethod void test_AllMethod() {
	//*** generate data
	TestDataGenerator.generateApexSetting();
	List<Account> listAccount = TestDataGenerator.generateAccounts(1, true);
	List<Contact> listContact = TestDataGenerator.generateContacts(listAccount[0].id, 2, true);
	List<Order> listOrder = TestDataGenerator.generateOrder(1, listAccount[0].Id, listContact[0].Id, listContact[1].Id, false);
	listOrder.addAll(TestDataGenerator.generateOrder(1, listAccount[0].Id, listContact[1].Id, listContact[1].Id, false));
	insert listOrder;

	//*** controller part for no object
	Test.setCurrentPageReference(new PageReference('/apex/AccountOrder'));
	AccountContactOrder_Ext cls = new AccountContactOrder_Ext(new ApexPages.standardController(new Account()));
	system.assert(cls.vfOrder.size() == 0, 'Incorrect number of orders for no object: ' + cls.vfOrder);

	//*** controller part for account
	Test.setCurrentPageReference(new PageReference('/apex/AccountOrder'));
	cls = new AccountContactOrder_Ext(new ApexPages.standardController(listAccount[0]));
	system.assert(cls.vfOrder.size() == 2, 'Incorrect number of orders for account: ' + cls.vfOrder);

	//*** controller part for contact
	Test.setCurrentPageReference(new PageReference('/apex/ContactOrder'));
	cls = new AccountContactOrder_Ext(new ApexPages.standardController(listContact[0]));
	system.assert(cls.vfOrder.size() == 1, 'Incorrect number of orders for contact: ' + cls.vfOrder);
	Test.setCurrentPageReference(new PageReference('/apex/ContactOrder'));
	cls = new AccountContactOrder_Ext(new ApexPages.standardController(listContact[1]));
	system.assert(cls.vfOrder.size() == 2, 'Incorrect number of orders for contact: ' + cls.vfOrder);

	//*** deleteOrder method
	cls.orderIdToDelete = listOrder[0].Id;
	cls.deleteOrder();
	system.assert(cls.vfOrder.size() == 1, 'Incorrect number of orders after delete: ' + cls.vfOrder);
} //*** end of "test_AllMethod"


} //*** end of class
