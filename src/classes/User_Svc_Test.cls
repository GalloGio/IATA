/****************************************************************************************************
	Created by CGI, Thai 2016-02-12
		Cover code in class "User_Svc"
****************************************************************************************************/
@isTest
public without sharing class User_Svc_Test
{


/****************************************************************************************************
	Created by CGI, Thai 2016-02-12
		Cover method "deactivateUser"
****************************************************************************************************/
@isTest static void test_deactivateUser()
{
	TestDataGenerator.generateApexSetting();

	//*** generate accounts, contacts, users
	List<Account> lstAccount = TestDataGenerator.generateAccounts(1, true);
	List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 1, true);
	List<User> lstUser = new List<User>{TestDataGenerator.generatePortalUser('ISS Portal', lstContact[0].Id, true)};

	system.assert(1 == [select count()
						from User
						where ContactId = :lstContact[0].Id
						  and IsActive = true], 'Wrong user data before deactivation');
	system.runAs([select Id from User where Id = :UserInfo.getUserId() limit 1][0])
	{
		Test.startTest();
			User_Svc.deactivateUser(JSON.serialize(lstUser));
		Test.stopTest();
	}
	system.assert(0 == [select count()
						from User
						where ContactId = :lstContact[0].Id
						  and IsActive = true], 'Wrong user data after deactivation');
} //*** end of "test_deactivateUser"


} //*** end of class
