@isTest
private class AMS_PCI_WizardNotificationTest {

	static testMethod void runStartTest() {		
		User adminWithRole = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' AND UserRoleId <> null LIMIT 1];

		System.runAs(adminWithRole) {
			Test.startTest();
			Account parent = ISSP_ObjectFactory.createNewAccount();
	        parent.BillingCity = 'test';
	        parent.Name = 'test';
	        insert parent;
	        System.debug('parent Id: ' + parent.Id);

	        Account child = ISSP_ObjectFactory.createNewAccount();
	        child.BillingCity = 'test2';
	        child.Name = 'test2';
	        child.Site = 'headSite';
	        child.sector__c = 'Airline';
	        child.Top_Parent__c = parent.Id;
	        insert child;
	        
	        Contact contact = ISSP_ObjectFactory.createNewContact();
	        contact.AccountId= child.Id;
	        contact.Email = 'Test@test11.com';
	        insert contact;
	        
	        User testUser = ISSP_ObjectFactory.createPortalUser(contact);
	        contact.OwnerId = testUser.Id;
	        update contact;
	                
	        RecordType RT = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = :EmailMessageHandler.LIST_VALID_RT.get(0)];
	        
	        Case caseOpened = new Case();
	        caseOpened.RecordtypeId = RT.Id;
	        caseOpened.ContactId = contact.Id;
	        caseOpened.AccountId = contact.AccountId;
	        insert caseOpened;
			
			AMS_PCI_WizardNotification.sendNotification(new List<Id> {caseOpened.Id});
			AMS_PCI_WizardNotification.getAttachmentsLst(new List<Attachment> {new Attachment(Name= 'ABC')});
			Test.stopTest();
		}
	}
	
}