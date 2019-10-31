@isTest
private class TestSendEmailToPortalAdmin {

    static testMethod void test001() {
    	
    	//ISSP_ObjectFactory.fiilIncludedFields();
		//Account parent =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
		Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
       
        //Account child =  (Account)ISSP_ObjectFactory.createSObject('Account',false,2);
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        insert child;
		//Contact con1 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
		Contact con1 = ISSP_ObjectFactory.createNewContact();
		con1.AccountId= child.Id;
		con1.User_Portal_Status__c = 'Regional Administrator';
		con1.Senior_Contact_Email__c = 'senior@dev.com';
		con1.Email = 'test1@test.test';
		con1.CNS_Contact__c=false;
		
		//Contact con2 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,2);
		Contact con2 = ISSP_ObjectFactory.createNewContact();
		con2.AccountId= child.Id;
		con2.Email = 'test2@test.test';
		con2.CNS_Contact__c=false;

		insert new Contact[] {con1, con2};
		
		User adminUser = ISSP_ObjectFactory.createPortalUser(con1);
		User newUser = ISSP_ObjectFactory.createPortalUser(con2);
		
		con1.OwnerId = adminUser.Id;
		update con1;
		
		AccountTeamMember member1 = new AccountTeamMember();
		//member1.AccountAccessLevel = 'Edit';
		member1.TeamMemberRole = 'Portal Administrator';
		member1.UserId = adminUser.Id;
		member1.AccountId = child.Id;
		insert member1; 
		
		ISSP_HierarchyAccountTeamAccounts.HierarchyAccountTeamMemberAccounts(new set<ID>{adminUser.Id, newUser.Id});
    	
    	list<Portal_Applications__c> appList  = new list<Portal_Applications__c> {
    									TestObjectCreator.buildPortalApplications2(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED)
    								   ,TestObjectCreator.buildPortalApplications2(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED)
    	};
    	Database.insert(appList);
    	ID applicationId1 = appList[0].Id;
    	ID applicationId2 = appList[1].Id;
    	list<Portal_Application_Right__c> lpar = new list<Portal_Application_Right__c> { 
    				 TestObjectCreator.buildPortalApplicationRight(con1.Id, applicationId1)
    				,TestObjectCreator.buildPortalApplicationRight(con1.Id, applicationId2)
    				//,TestObjectCreator.buildPortalApplicationRight(con2.Id, applicationId2, 'Granted')
    	};

		Test.startTest(); 
		Boolean stopTrigger = PortalServiceAccessTriggerHandler.privetTrigger;
		PortalServiceAccessTriggerHandler.privetTrigger = true;
		Database.insert(lpar);
		PortalServiceAccessTriggerHandler.privetTrigger = stopTrigger;
		Test.stopTest();
    }
    
    static testMethod void test002() {
		Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
       
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        insert child;

		Contact con1 = ISSP_ObjectFactory.createNewContact();
		con1.AccountId= child.Id;
		con1.User_Portal_Status__c = 'Regional Administrator';
		con1.Senior_Contact_Email__c = 'senior@dev.com';
		con1.Email = 'test1@test.test';
		
		Contact con2 = ISSP_ObjectFactory.createNewContact();
		con2.AccountId= child.Id;
		con2.Email = 'test2@test.test';
		
		insert new Contact[] {con1, con2};
		
		User adminUser = ISSP_ObjectFactory.createPortalUser(con1);
		User newUser = ISSP_ObjectFactory.createPortalUser(con2);
		
		con1.OwnerId = adminUser.Id;
		update con1;
		
		AccountTeamMember member1 = new AccountTeamMember();
		//member1.AccountAccessLevel = 'Edit';
		member1.TeamMemberRole = 'Portal Administrator';
		member1.UserId = adminUser.Id;
		member1.AccountId = child.Id;
		insert member1; 
		
			
		ISSP_HierarchyAccountTeamAccounts.HierarchyAccountTeamMemberAccounts(new set<ID>{adminUser.Id, newUser.Id});
    	
    	list<Portal_Applications__c> appList  = new list<Portal_Applications__c> {
    									TestObjectCreator.buildPortalApplications('Test Method App 001')
    								   ,TestObjectCreator.buildPortalApplications('Test Method App 002')
    	};
    	Database.insert(appList);
    	ID applicationId1 = appList[0].Id;
    	ID applicationId2 = appList[1].Id;
    	list<Portal_Application_Right__c> lpar = new list<Portal_Application_Right__c> { 
    				 TestObjectCreator.buildPortalApplicationRight(con1.Id, applicationId1)
    				,TestObjectCreator.buildPortalApplicationRight(con1.Id, applicationId2)
    	};
    	
		Boolean stopTrigger = ISSP_CreateNotification.privetTrigger;
		ISSP_CreateNotification.privetTrigger = true;
		Database.insert(lpar);
		ISSP_CreateNotification.privetTrigger = stopTrigger;
    }
}