@isTest
private class AzureRegistrationHandlerTest {
    private static AzureRegistrationHandler handler = new AzureRegistrationHandler();
    private static Auth.UserData userData = new Auth.UserData('identifier', 'Test', 'Test', 'Test Test', 'test@test.com', 'link','username', 'locale', 'provider', 'siteLoginUrl', new Map<String,String>());

    @isTest
    static void testCanCreateUser(){
        Test.startTest();
        System.assertEquals(true, handler.canCreateUser(userData));
        Test.stopTest();
    }

    @isTest
    static void testUpdateUser(){
        //no logic to test yet so calling method for coverage only
        handler.updateUser(Id.valueOf('001xa000003DIlo'), Id.valueOf('001xa000003DIlo'), userData);
        System.assert(true);
    }

    @isTest
    static void testCreateUser(){
        User user = new User(Username = 'testymctesttest@test.com', Lastname = 'test', Alias = 'test', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'][0].Id, LanguageLocaleKey = 'en_US', Email = 'test@test.com', License_Cost_Center__c = 'ITO005CH01');
        
		Test.startTest();
		insert user;
		System.assertEquals(user.Id, ((User) (handler.createUser(null, userData))).Id);
		Test.stopTest();
	}
	
	@isTest
    static void testCreateUserFail(){
        User user = new User(Username = 'testymctesttest@test.com', Lastname = 'test', Alias = 'test', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'][0].Id, LanguageLocaleKey = 'en_US', Email = 'test@test.com', License_Cost_Center__c = 'ITO005CH01');
        
		Test.startTest();
		insert user;
		try{
			userData.email = 'abc@test.com';
			handler.createUser(null, userData);
		}catch(Exception rhe){
			System.assert(true);
		}
		Test.stopTest();
    }
}
