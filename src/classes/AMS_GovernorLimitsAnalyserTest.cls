@isTest
private class AMS_GovernorLimitsAnalyserTest {

	static testMethod void describeLimitsTest() {
		//test describeLimits
		List<String> paramsToPrint = new List<String>();

		Contact c = new Contact(FirstName = 'Test', LastName = 'Contact');
		insert c;

		test.startTest();

		for(Contact con : [select name from contact limit 1])
		{
			paramsToPrint.add(con.name);

		}

	 	AMS_GovernorLimitsAnalyser.describeLimits(paramsToPrint);

		test.stopTest();
	}
}
