@isTest
public with sharing class ISSP_ChangeLanguageTest {
	public static testMethod void testISSP_ChangeLanguageTest() {
	 	//ISSP_ObjectFactory.fiilIncludedFields();
		//Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.IATACode__c = '132';
		insert acc;
		//Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.Email = 'test2@test.test';
		con.AccountId= acc.Id;
		insert con;

		User newUser = new User(alias = 'dsfsdfds',
								email = con.email,
								emailencodingkey = 'UTF-8',
								firstname = con.firstName,
								lastname = con.lastname,
								languagelocalekey = 'en_US',
								localesidkey = 'en_US',
								contactId = con.Id,
								timezonesidkey = 'Asia/Dubai',
								username = con.email+'dfgdf',
								PortalRole = 'Manager',
								CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
								ProfileId = ISSP_Constant.TEST_User_ProfileID,
								IsActive = true);
		insert newUser;
		con.OwnerId = newUser.Id;
		update con;
		 ApexPages.currentPage().getParameters().put('lang','en_US');
		 ApexPages.currentPage().getParameters().put('retUrl','retUrl');
	 	 system.runAs(newUser){
	 	 	Test.startTest();
	 		ISSP_ChangeLanguage cttr = new ISSP_ChangeLanguage();
		 	cttr.changeUserLanguage();
		 	Test.stopTest();
	 	 }
	 }
}
