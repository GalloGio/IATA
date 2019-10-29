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
		i.Token__c = l.id;
        
		// update user information in Salesforce
		GDRP_UserInfo_CTRL.updateUserInfo(JSON.serialize(i));

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

	@isTest
    static void retrieveUserInfoContact(){

		// Insert Contact that will create the associated individual object
		Contact c = new Contact(FirstName = 'fred', LastName = 'dev', Salutation = 'Mr.',  Email = 'iata.fred.dev+2@gmail.com');
        INSERT c;

		 Test.startTest();
		// Get user information from Pardot
		Individual i = GDRP_UserInfo_CTRL.retrieveUserInfo(c.Email);
		i.Token__c = c.id;
        
		// update user information in Salesforce
		GDRP_UserInfo_CTRL.updateUserInfo(JSON.serialize(i));
		Test.stopTest();
	}
}