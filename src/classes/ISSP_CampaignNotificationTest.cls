@isTest
private class ISSP_CampaignNotificationTest {
	
	static testMethod void testCampaignNotification() {
		//ISSP_ObjectFactory.fiilIncludedFields();

		NewGenApp_Custom_Settings__c newgenCS = new NewGenApp_Custom_Settings__c();
        newgenCS.Push_Notifications_State__c = true;
        insert newgenCS;
         
        //Campaign camp = (Campaign)ISSP_ObjectFactory.createSObject('Campaign',false,1);
        Campaign camp = new Campaign();    
        camp.Name = 'Test Campaign';
		insert camp;

		Account account = ISSP_ObjectFactory.createNewAccount();
		insert account;
		
        //Contact contact = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.Email = 'Test@test11.com';
        insert contact;

        User newUser = ISSP_ObjectFactory.createPortalUser(contact);
        contact.OwnerId = newUser.Id;
        update contact;
		
		//CampaignMember cm = (CampaignMember)ISSP_ObjectFactory.createSObject('CampaignMember',false,1);//
		CampaignMember cm = new CampaignMember();
		cm.CampaignId = camp.Id;
		cm.ContactId = contact.Id;
		insert cm;
		
		//Notification_template__c notificationTemplate = (Notification_template__c)ISSP_ObjectFactory.createSObject('Notification_template__c',false,1);
		Notification_template__c notificationTemplate = new Notification_template__c();
        notificationTemplate.Subject__c = 'Test 001';
        notificationTemplate.Type__c = 'Action';
        notificationTemplate.Admins_Users__c = 'User';
        notificationTemplate.Message__c = 'test {0}';
        notificationTemplate.Notification_color__c = '#007FFF';
        insert notificationTemplate;
         
		ISSP_CampaignNotification cttr = new ISSP_CampaignNotification();
		cttr.opp.CampaignId = camp.Id;
		cttr.notification.Master_Notification_template__c = notificationTemplate.Id;
		cttr.send();
	}
}