@isTest
public class CurrencySingletonTest {

	static testMethod void TestOk() {

		Test.StartTest();
		CurrencySingleton cs = CurrencySingleton.getInstance();
		Decimal rate = cs.convertCurrency(1,'EUR','USD');
		Test.StopTest();

		System.assert(rate != null);
	}

	static testMethod void TestError() {

		Test.StartTest();
		CurrencySingleton cs = CurrencySingleton.getInstance();
		Decimal rate = cs.convertCurrency(1,'AAA','BBB');
		Test.StopTest();

		System.assert(rate == null);
	}

}
