/****************************************************************************************************
	Created by CGI, Thai 2016-05-06
		Cover code of class "OrderItem_Svc"
****************************************************************************************************/

@isTest
public class OrderItem_Svc_Test
{


/****************************************************************************************************
	Created by CGI, Thai 2016-05-06
		Cover code of method "setOrderToPaid"
****************************************************************************************************/
@isTest(seeAllData=true) static void test_setOrderToPaid()
{
	//*** generate data
	List<Account> lstAccount = TestDataGenerator.generateAccounts(1, true);
	List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 1, true);
	List<Order> lstOrder = TestDataGenerator.generateOrder(1, lstAccount[0].Id, lstContact[0].Id, lstContact[0].Id, true);
	List<OrderItem> lstOrderItem = TestDataGenerator.generateOrderItem(lstOrder[0].Id, 2, true);

	//*** test
	lstOrderItem[0].IEC_Is_Paid__c = true;
	update lstOrderItem[0];
	system.assert(1 ==[select count() from Order where Id = :lstOrder[0].Id and Is_Paid__c = false], 'Order should NOT be paid');
	lstOrderItem[1].IEC_Is_Paid__c = true;
	update lstOrderItem[1];
	system.assert(1 ==[select count() from Order where Id = :lstOrder[0].Id and Is_Paid__c = true], 'Order should be paid');
} //*** end of "test_setOrderToPaid"


} //*** end of class
