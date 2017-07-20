/**

		Project: eCommerce Enhancements
	       File: IEC_Functionality_Test.cls
	Description: Test class for Functionality Management through Custom Setting.
	     Author: blue-infinity sa
	    History: aosantos, 2017-07-04, Initial Release.


*/
@isTest
private class IEC_Functionality_Test {
	static void setup() {
		List<IEC_Functionality__c> configList = new List<IEC_Functionality__c>{
			new IEC_Functionality__c(
				Name = 'Test Functionality [1]',
				Functionality_Name__c = 'Test Functionality',
				Order__c = 1,
				Is_Active__c = true,
				Audience__c = 'userId=X'
			),
			new IEC_Functionality__c(
				Name = 'Test Functionality [2]',
				Functionality_Name__c = 'Test Functionality',
				Order__c = 2,
				Is_Active__c = true,
				Audience__c = 'userName=X'
			),
			new IEC_Functionality__c(
				Name = 'Test Functionality [3]',
				Functionality_Name__c = 'Test Functionality',
				Order__c = 3,
				Is_Active__c = true,
				Audience__c = 'userEmail=X'
			),
			new IEC_Functionality__c(
				Name = 'Test Functionality [4]',
				Functionality_Name__c = 'Test Functionality',
				Order__c = 4,
				Is_Active__c = true,
				Audience__c = 'userType=X'
			),
			new IEC_Functionality__c(
				Name = 'Test Functionality [5]',
				Functionality_Name__c = 'Test Functionality',
				Order__c = 5,
				Is_Active__c = true,
				Audience__c = 'profileId=X'
			),
			new IEC_Functionality__c(
				Name = 'Test Functionality [6]',
				Functionality_Name__c = 'Test Functionality',
				Order__c = 6,
				Is_Active__c = true,
				Audience__c = 'organizationId=X'
			),
			new IEC_Functionality__c(
				Name = 'Test Functionality [7]',
				Functionality_Name__c = 'Test Functionality',
				Order__c = 7,
				Is_Active__c = true,
				Audience__c = 'cookie=X'
			),
			new IEC_Functionality__c(
				Name = 'Test Functionality [8]',
				Functionality_Name__c = 'Test Functionality',
				Order__c = 8,
				Is_Active__c = true,
				Audience__c = 'all=true'
			)
		};

		insert configList;
	}

	@isTest
	static void test1() {
		User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		IEC_Functionality functionality;
		Cookie cookie = new Cookie('xpto', '1', null, -1, false);
		ApexPages.currentPage().setCookies(new Cookie[] { cookie });

		setup();

		System.runAs(oUser) {
			Test.startTest();

			functionality = IEC_Functionality.getInstance();

			System.assert(true == functionality.isActive('Test Functionality'));
			System.assert(null == functionality.getValue('Test Functionality'));

			Test.stopTest();
		}
	}
}