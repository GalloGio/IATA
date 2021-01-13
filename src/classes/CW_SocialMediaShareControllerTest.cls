@isTest
public with sharing class CW_SocialMediaShareControllerTest {

	static testMethod void CW_SocialMediaShareControllerTest() {
		Account accOne = new Account(Name = 'Test testersen');
		insert new List<Account>{ accOne };

		Account_Role__c accRoleOne = new Account_Role__c(Account__c = accOne.Id);
		insert new List<Account_Role__c>{ accRoleOne};

		ICG_Account_Role_Detail__c accRoleDetailOne = new ICG_Account_Role_Detail__c(
			name = accOne.name,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Account_Role_Detail__c', 'Cargo_Handling_Facility'),
			Account_Role__c = accRoleOne.Id,
			logoUrl__c = 'https://i.imgur.com/WUFOpNW.png'
		);
		
		Test.StartTest(); 
		ApexPages.StandardController sc = new ApexPages.StandardController(accRoleDetailOne);
		CW_SocialMediaShareController smsc = new CW_SocialMediaShareController();

		PageReference pageRef = Page.CW_SocialMediaShare; 
		pageRef.getParameters().put('stationId', String.valueOf(accRoleDetailOne.Id));
		pageRef.getParameters().put('title', String.valueOf(accRoleDetailOne.name));
		pageRef.getParameters().put('imageUrl', String.valueOf(accRoleDetailOne.logoUrl__c));
		Test.setCurrentPage(pageRef);
		String vfphtl = smsc.getStationDetails();
		system.assertNotEquals(vfphtl, '');

		Test.StopTest();
	}
}