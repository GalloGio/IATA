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
        CW_NotificationsController.setNotificationCustom('subject', 'body', 'Peending', listContactIdsString, null, RT_NOTIFICATION_PRIVATE_AREA);

		Test.stopTest();
	}

    @IsTest
    public static void testGetNotificationsFromUser(){
        Test.startTest();
        CW_NotificationsController.getNotificationsFromUser(true);
        CW_NotificationsController.getNotificationsFromUser(false);
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

        CW_NotificationsController.setDismissNotifications(listNotificationIdsString);
		Test.stopTest();
	}
}