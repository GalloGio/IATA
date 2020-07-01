/**
 * @description		Test class for CW_NotificationsController
 *
 * Edit Log:
 * @history			2020/05/22  |  sf-553  |  Creation.
 */
@IsTest
public with sharing class CW_NotificationsControllerTest {
 
	@TestSetup
	static void setup(){

		String RT_NOTIFICATION_PRIVATE_AREA = CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA;
		ICG_Notification__c notification = new ICG_Notification__c(RecordTypeId = RT_NOTIFICATION_PRIVATE_AREA, Read__c = true, CreatedDate = Date.today()-32);
		insert notification;

		IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();
		insert isoCode;
		
		Account acc = new Account (Name = 'Account01', IATA_ISO_Country__c = isoCode.Id);
		insert acc;
		
		Contact con1 = new Contact(FirstName = 'Test', LastName='Test', Email = 'Test@Test.com',AccountId = acc.id);
		insert con1;
	}   

	@IsTest
	public static void testSetNotificationCustom(){
		Test.startTest();
		
		List<String> listContactIdsString = new List<String>();
		List<Contact> listContact = [SELECT Id FROM Contact];
			
		for(Contact item : listContact){
			listContactIdsString.add(item.Id);
		}
		
		String RT_NOTIFICATION_PRIVATE_AREA = CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA;
		List<ICG_Notification__c> notifications = CW_NotificationsController.setNotificationCustom('subject', 'body', 'Peending', listContactIdsString, null, RT_NOTIFICATION_PRIVATE_AREA);
		system.assertNotEquals(notifications.size(), 0);

		Test.stopTest();
	}

	@IsTest
	public static void testGetNotificationsFromUser(){
		Test.startTest();
		
		String res = CW_NotificationsController.getNotificationsFromUser(true);
		String resFalse = CW_NotificationsController.getNotificationsFromUser(false);

		system.assertNotEquals(res, '');
		system.assertNotEquals(resFalse, '');
		
		Test.stopTest();
	}

	@IsTest
	public static void testSetDismissNotifications(){
		Test.startTest();
		
		List<String> listNotificationIdsString = new List<String>();
		List<ICG_Notification__c> listNotification = [SELECT Id FROM ICG_Notification__c];
			
		for(ICG_Notification__c item : listNotification){
			listNotificationIdsString.add(item.Id);
		}

		String jsonRes = CW_NotificationsController.setDismissNotifications(listNotificationIdsString);
		CW_NotificationsController.ResponseBody res = (CW_NotificationsController.ResponseBody) JSON.deserialize(jsonRes, CW_NotificationsController.ResponseBody.class);
		system.assertEquals(res.success, true);

		Test.stopTest();
	}
}