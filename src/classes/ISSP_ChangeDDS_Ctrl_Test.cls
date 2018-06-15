@isTest
private class ISSP_ChangeDDS_Ctrl_Test {
    
    @testSetup
    static void PrepareTestData() {
        list<Account> lsAccnt = new list<Account>();
        map<Id, Id> mapAccntUser = new map<id,id>();
        
        //Agency Account
        Account acc = new Account();
        acc.Name = 'TestAgency';
        acc.IATACode__c = '123';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        lsAccnt.add(acc);
        
        //Standard Account
        acc = new Account();
        acc.Name = 'TestStdAccnt';
        acc.IATACode__c = '456';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        lsAccnt.add(acc);
        
        insert lsAccnt;
        
        list<Contact> lsCon = new list<Contact>();
        
        for(Account a:[select Id, Name from Account]){
	        lsCon.add(new Contact(FirstName = a.Name, LastName = a.Name, Email = a.Name + '@admin.test', User_Portal_Status__c = 'Administrator', AccountId = a.ID));
	        lsCon.add(new Contact(FirstName = a.Name+'2', LastName = a.Name+'2', Email = a.Name +'2' + '@notAdmin.test', User_Portal_Status__c = 'Approved User', AccountId = a.ID));
        }

	    insert lsCon;
	    
	    list<AccountShare> lsShare = new list<AccountShare>();
	    
	    system.debug('DTULLO. TeamMem. NDO CASSU STO?!?!');
		
	    for(Contact c:lsCon){
        	User thisUser = ISSP_ObjectFactory.createPortalUser(c);
        	c.OwnerId = thisUser.Id;
        	
        	if(c.User_Portal_Status__c == 'Administrator'){
        		lsShare.add(new AccountShare(AccountId = c.AccountId, AccountAccessLevel='Edit', UserOrGroupId=thisUser.Id, RowCause='Manual', CaseAccessLevel='Read', ContactAccessLevel='Edit', OpportunityAccessLevel = 'Read'));
        	}
	    }
        
        insert lsShare;

        update lsCon;
        	
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'TestCntr',ISO_Code__c ='TS', DDS_Enabled__c = false);
        insert isoCountry;
    }
    
    
    //Test user not admin
    static testMethod void testNotAdminUser() {
        User u = [Select Id, ContactId, Contact.AccountId, Contact.User_Portal_Status__c from user where email = 'TestAgency2@notAdmin.test'].get(0);
        
        if(u!=null){
        	test.StartTest();
        	system.runas(u){
        		Test.setCurrentPage(Page.ISSP_ChangeDDS);
        		
        		ISSP_ChangeDDS_Ctrl ctrl = new ISSP_ChangeDDS_Ctrl();
        		
        		system.assert(!ctrl.bIsAdmin);
        	}
        	test.stopTest();
        }
    }
    
    //Test account not agency. User is admin
    static testMethod void testAdminUserNoAgencyAccnt() {
        User u = [Select Id, ContactId, Contact.AccountId, Contact.User_Portal_Status__c from user where email = 'TestStdAccnt@admin.test'].get(0);
        
        if(u!=null){
        	
        	test.StartTest();
        	
        	system.runas(u){
        		
        		Test.setCurrentPage(Page.ISSP_ChangeDDS);
        		ISSP_ChangeDDS_Ctrl ctrl = new ISSP_ChangeDDS_Ctrl();
        		
        		system.assert(ctrl.bIsAdmin);
        		system.assert(!ctrl.bAccntValid);
        	}
        	test.stopTest();
        }
    }
    
    //Test account agency, but is not HO. User is admin
    static testMethod void testAdminUserAgencyAccntNoHO() {
        User u = [Select Id, ContactId, Contact.AccountId, Contact.User_Portal_Status__c from user where email = 'TestAgency@admin.test'].get(0);
        
        if(u!=null){
        	test.StartTest();
        	system.runas(u){
        		Test.setCurrentPage(Page.ISSP_ChangeDDS);
        		ISSP_ChangeDDS_Ctrl ctrl = new ISSP_ChangeDDS_Ctrl();
        		
        		system.assert(ctrl.bIsAdmin);
        		system.assert(!ctrl.bAccntValid);
        	}
        	test.stopTest();
        }
    }
    
    //Test account agency, HO, but category is not correect. User is admin
    static testMethod void testAdminUserAgencyAccntHOWrongCategory() {
        User u = [Select Id, ContactId, Contact.AccountId, Contact.User_Portal_Status__c from user where email = 'TestAgency@admin.test'].get(0);
        
        if(u!=null){
        	Account a = [select id, Category__c, Location_Type__c from Account where id =:u.contact.AccountID];
        	
        	a.Location_Type__c = 'HO';
        	
        	update a;
        	
        	test.StartTest();
        	system.runas(u){
        		Test.setCurrentPage(Page.ISSP_ChangeDDS);
        		ISSP_ChangeDDS_Ctrl ctrl = new ISSP_ChangeDDS_Ctrl();
        		
        		system.assert(ctrl.bIsAdmin);
        		system.assert(!ctrl.bAccntValid);
        	}
        	test.stopTest();
        }
    }
    
    
    //Test account agency valid. User is admin. country not enabled (not set)
    static testMethod void testAdminUserAgencyOkNoCountryNotSet() {
        User u = [Select Id, ContactId, Contact.AccountId, Contact.User_Portal_Status__c from user where email = 'TestAgency@admin.test'].get(0);
        
        if(u!=null){
        	Account a = [select id, Category__c, Location_Type__c from Account where id =:u.contact.AccountID];
        	
        	a.Location_Type__c = 'HO';
        	a.Category__c = 'IATA Passenger Sales Agent';
        	update a;
        	
        	test.StartTest();
        	system.runas(u){
        		Test.setCurrentPage(Page.ISSP_ChangeDDS);
        		ISSP_ChangeDDS_Ctrl ctrl = new ISSP_ChangeDDS_Ctrl();
        		
        		system.assert(ctrl.bIsAdmin);
        		system.assert(ctrl.bAccntValid);
        		system.assert(!ctrl.bCountryEnabled);
        	}
        	test.stopTest();
        }
    }
    
    
    //Test account agency valid. User is admin. country set but NOT enabled
    static testMethod void testAdminUserAgencyOkNoCountryEnabled() {
        User u = [Select Id, ContactId, Contact.AccountId, Contact.User_Portal_Status__c from user where email = 'TestAgency@admin.test'].get(0);
        IATA_iso_country__c cntr = [select id from IATA_ISO_Country__c limit 1];
        
        if(u!=null){
        	Account a = [select id, Category__c, Location_Type__c from Account where id =:u.contact.AccountID];
        	
        	a.Location_Type__c = 'HO';
        	a.Category__c = 'IATA Passenger Sales Agent';
        	a.IATA_ISO_Country__c = cntr.id;
        	update a;
        	
        	test.StartTest();
        	system.runas(u){
        		Test.setCurrentPage(Page.ISSP_ChangeDDS);
        		ISSP_ChangeDDS_Ctrl ctrl = new ISSP_ChangeDDS_Ctrl();
        		
        		system.assert(ctrl.bIsAdmin);
        		system.assert(ctrl.bAccntValid);
        		system.assert(!ctrl.bCountryEnabled);
        	}
        	test.stopTest();
        }
    }
    
    //Test account agency valid. User is admin. country enabled. Everything will work
    static testMethod void testOk() {
        User u = [Select Id, ContactId, Contact.AccountId, Contact.User_Portal_Status__c from user where email = 'TestAgency@admin.test'].get(0);
        IATA_iso_country__c cntr = [select id, DDS_Enabled__c from IATA_ISO_Country__c limit 1];
        
        cntr.DDS_Enabled__c = true;
        update cntr;
        
        if(u!=null){
        	Account a = [select id, Category__c, Location_Type__c from Account where id =:u.contact.AccountID];
        	
        	a.Location_Type__c = 'HO';
        	a.Sector__c = 'Travel Agent';
        	a.Category__c = 'IATA Passenger Sales Agent';
        	a.IATA_ISO_Country__c = cntr.id;
        	update a;
        	
        	test.StartTest();
        	system.runas(u){
        		Test.setCurrentPage(Page.ISSP_ChangeDDS);
        		ISSP_ChangeDDS_Ctrl ctrl = new ISSP_ChangeDDS_Ctrl();
        		
        		system.assert(ctrl.bIsAdmin);
        		system.assert(ctrl.bAccntValid);
        		system.assert(ctrl.bCountryEnabled);
        		
        		PageReference pf = ctrl.SaveAccnt();
        		
        		//Save: From null to optOut
        		system.assert(ctrl.bSaved);
        		system.assert([Select DDS_status__c from Account where id=:a.Id].get(0).DDS_status__c == 'Opt-Out');
        		
        		//Reopen page.
        		ISSP_ChangeDDS_Ctrl ctrl2 = new ISSP_ChangeDDS_Ctrl();
        		system.assert(ctrl2.bIsAdmin);
        		system.assert(ctrl2.bAccntValid);
        		system.assert(ctrl2.bCountryEnabled);
        		system.assert(ctrl2.bHasOptOut);
        		system.assert(!ctrl2.bHasOptIn);
        		
        		PageReference pf2 = ctrl2.SaveAccnt();
        		
        		//Save: From null to optin
        		system.assert([Select DDS_status__c from Account where id=:a.Id].get(0).DDS_status__c == 'Opt-In');
        		system.assert(ctrl2.bSaved);
        		
        		
        		ISSP_ChangeDDS_Ctrl ctrl3 = new ISSP_ChangeDDS_Ctrl();
        		
        		PageReference pf3 = ctrl3.goToHP();	
        	}
        	test.stopTest();
        }
    }
}