@isTest (seeAllData=true)
public class vfIECEBC_TestPayment {
	public static testMethod void testPagePaymentS1() {
		vfIECEBC_TestPaymentSuite.CreateOrderPayment(1);
	}
	public static testMethod void testPagePaymentS2() {
		vfIECEBC_TestPaymentSuite.CreateOrderPayment(2);
	}
	public static testMethod void testPagePaymentS3() {
		vfIECEBC_TestPaymentSuite.CreateOrderPayment(3);
	}
	public static testMethod void testPagePaymentS4() {
		vfIECEBC_TestPaymentSuite.CreateOrderPayment(4);
	}
	public static testMethod void testPagePaymentS5() {
		vfIECEBC_TestPaymentSuite.CreateOrderPayment(5);
	}
	public static testMethod void testPagePaymentS10() {
		vfIECEBC_TestPaymentSuite.CreateOrderPayment(10);
	}
	public static testMethod void testPagePayment() {
		vfIECEBC_TestPaymentSuite.CreatePayment();
	}
}
