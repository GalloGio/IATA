@isTest
private class Pardot_API_Test
{
	public static testmethod void getProspect() {
		// Insert credential
		Pardot_API__c pardotSetting = new Pardot_API__c();
		pardotSetting.API_Version__c = '4';
		pardotSetting.Assigned_User__c = '1111111';
		pardotSetting.Pardot_Business_Unit__c = '2222222222222222';
		insert pardotSetting;

		Pardot_API_RequestMock_Test fakeResponse = new Pardot_API_RequestMock_Test('MOCK_AUTHENTIFICATION_ERROR');
		// Wrong credentials
		Test.setMock(HttpCalloutMock.class, fakeResponse);		
		// Good credentials
		fakeResponse = new Pardot_API_RequestMock_Test('MOCK_READ_PROSPECT');
		Test.setMock(HttpCalloutMock.class, fakeResponse);

		// Get prospect by email
		Pardot_API.Pardot_Prospect p = Pardot_API.getProspect('iata.fred.dev+1@gmail.com');

		// Update prospect
		Pardot_API.updateProspect(p);

		// Create prospect
		Pardot_API.createProspect(p);

		// Update prospect interest
		Pardot_API.updateProspectInterest('56308118', 'iata.fred.dev+1@gmail.com', new list<String>{'Cargo','Safety'});

		// Subscription to list 111 and 222
		Pardot_API.createListMembershipBulk('56308118', new list<String>{'111','222'});

		// Unsubscription to list 111 and 222
		Pardot_API.deleteListMembershipBulk('56308118', new list<String>{'111','222'});

		// Opt-out from master list
		Pardot_API.optOut('56308118', true);

	}
}
