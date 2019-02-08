@isTest
public class GDRP_UserInfo_CTRL_Test {
	@isTest
    static void retrieveUserInfo(){
		
       // Insert lead that will create the associated individual object
		Lead l = new Lead(FirstName = 'fred', LastName = 'dev', Salutation = 'Mr.',  Email = 'iata.fred.dev+1@gmail.com', Company='iatatest');
        INSERT l;

       // Simulate Pardot prospect respons
	   // Insert credential
        Pardot_API__c pardotSetting = new Pardot_API__c();
        pardotSetting.API_Version__c = '4';
        pardotSetting.Password__c = 'fakePassword';
        pardotSetting.User_Key__c = '111111111';
        pardotSetting.Email__c = 'fake@fake.com';
        pardotSetting.Assigned_User__c = '1111111';
        insert pardotSetting;

		Pardot_API_RequestMock_Test fakeResponse =  new Pardot_API_RequestMock_Test('MOCK_READ_PROSPECT');
		Test.setMock(HttpCalloutMock.class, fakeResponse);

		 Test.startTest();
		// Get user information from Pardot
		Individual i = GDRP_UserInfo_CTRL.retrieveUserInfo(l.Email);
		Pardot_API.Pardot_Prospect prospect = new Pardot_API.Pardot_Prospect();
		prospect.salutation = 'Mr';
		prospect.first_name = l.FirstName;
		prospect.last_name = l.LastName;
		prospect.email = l.Email;
		prospect.company = 'Test';
		prospect.job_title = 'Test';
		prospect.industry = 'Test';
		prospect.phone = 'Test';
		prospect.country = 'Test';
        
		// update user information from Pardot
		GDRP_UserInfo_CTRL.updateUserInfo(JSON.serialize(prospect));

		// Check token validity
		String encryptedToken = Comm_User_Helper.EncryptString(''+String.valueOf(System.TODAY()).left(10)+l.Email);
        GDRP_UserInfo_CTRL.checkIfValidToken(encryptedToken);
		System.debug(i);
		GDRP_UserInfo_CTRL.grantAccessToPortal(JSON.serialize(i));
		Test.stopTest();
	}
	@isTest
	static void getPicklist(){
		// Get picklist value from individual object
		GDRP_UserInfo_CTRL.getPickListValues();
	}
}