@isTest
private class Pardot_API_Test
{
	public static testmethod void getProspect() {
        Pardot_API_RequestMock_Test fakeResponse = new Pardot_API_RequestMock_Test('MOCK_AUTHENTIFICATION_ERROR');
        // Wrong credentials
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        String apiKey = Pardot_API.getAPIToken();
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
        Pardot_API.updateProspectInterestAsync('56308118', 'iata.fred.dev+1@gmail.com', new list<String>{'Cargo','Safety'});
        
        // Subscription to list 111 and 222
        Pardot_API.createListMembershipBulk('56308118', new list<String>{'111','222'});
        
        // Unsubscription to list 111 and 222
        Pardot_API.deleteListMembershipBulk('56308118', new list<String>{'111','222'});
        
        // Opt-out from master list
        Pardot_API.optOut('56308118', true);
        
    }
}