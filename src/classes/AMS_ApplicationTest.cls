/*
*  Unit test the AMS-42 story
*/

@isTest
public class AMS_ApplicationTest {

	@isTest static void userWithPermissionSet() {
			Profile pro = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'];
				User u = new User();
				u.FirstName = 'Test';
				u.LastName = 'User';
				u.Alias = 'tuser';
				u.Email = 'tuser@test.com';
				u.Username = 'tuser@test.com.AMS_ApplicationTest';
				u.CommunityNickname = 'tuser2';
				u.ProfileId = pro.Id;
				u.TimeZoneSidKey = 'America/Mexico_City';
				u.LocaleSidKey = 'en_US';
				u.EmailEncodingKey = 'ISO-8859-1';
				u.License_Cost_Center__c = 'SMX008CA01';
				u.LanguageLocaleKey = 'en_US';
				insert u;

			PermissionSet pset = [SELECT id FROM PermissionSet where Name = 'AMS_FullAccess'];

				PermissionSetAssignment psetass = new PermissionSetAssignment(PermissionSetId = pset.id, AssigneeId = u.id);
				insert psetass;

				System.runAs(u) {
					Test.startTest();
					system.assertEquals(true,schema.sObjectType.Account.isCreateable());
					system.assertEquals(true,schema.sObjectType.Account.isAccessible());
					system.assertEquals(true,schema.sObjectType.Account.isUpdateable());
					//system.assertEquals(true,schema.sObjectType.AMS_Agency__c.isDeletable());
					Test.stopTest();
				}
	}

	/*AMSFTS @isTest static void userWithoutPermissionSet() {
		Profile pro = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'];
				User u = new User();
				u.FirstName = 'Test';
				u.LastName = 'User';
				u.Alias = 'tuser';
				u.Email = 'tuser@test.com';
				u.Username = 'tuser@test.com.AMS_ApplicationTest';
				u.CommunityNickname = 'tuser2';
				u.ProfileId = pro.Id;
				u.TimeZoneSidKey = 'America/Mexico_City';
				u.LocaleSidKey = 'en_US';
				u.EmailEncodingKey = 'ISO-8859-1';
				u.License_Cost_Center__c = 'SMX008CA01';
				u.LanguageLocaleKey = 'en_US';
				insert u;

				System.runAs(u) {
					Test.startTest();
					system.assertEquals(false,schema.sObjectType.Account.isCreateable());
					system.assertEquals(false,schema.sObjectType.Account.isAccessible());
					system.assertEquals(false,schema.sObjectType.Account.isUpdateable());
					//system.assertEquals(false,schema.sObjectType.AMS_Agency__c.isDeletable());
					Test.stopTest();

				}
	}*/
}
