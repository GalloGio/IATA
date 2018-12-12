@isTest
private class IEC_MyOrdersControllerTest {

 @isTest
 static void testClass() {
     IEC_MyOrdersController i = new IEC_MyOrdersController();
     i.onLoadAction();
     i.loggedCustomer = new Customer_DTO();
     try {
         i.onLoadAction();
         }
      catch (Exception e) {}
 }
 }