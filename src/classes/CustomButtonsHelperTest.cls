/*
	* This is a test class for the CustomButtonsHelper class
	*/

@isTest
private class CustomButtonsHelperTest {
		testMethod static void WebserviceMethodsTest() {
				CustomButtonsHelper.getFieldLabels( 'Airline_Input__c', new list<String>{'Parent_Case__c'});
		}
}
