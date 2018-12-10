@isTest
private class CountryProfileTriggerHandlerTest {
	
	@isTest static void checkIfHistoryRecordWasCreated() {
		Test.startTest();

		IATA_ISO_Country__c iso = new IATA_ISO_Country__c(ISO_Code__c='FR');
		insert iso;

		Country_Profile__c cp1 = new Country_Profile__c(Name='France', Country_Name__c=iso.Id, ISO_Code__c='');
		cp1.Actual_Amount_Blocked__c = '123';		
		Country_Profile_History_Tracking__c cpht = new Country_Profile_History_Tracking__c(Name='Actual_Amount_Blocked__c');
		insert cpht;
		insert cp1;

		//for some reason, the excecution of trigger method is reversed during test run... need to reset the firstExec var 
		CountryProfileTriggerHandler.firstExec = true;
		cp1.Actual_Amount_Blocked__c = '999';
		update cp1;
		
		Test.stopTest();
		List<Country_Profile_History__c> histories = [SELECT Id,OldValue__c,NewValue__c,Field__c FROM Country_Profile_History__c WHERE Country_Profile__c =: cp1.Id];

		system.assertEquals('123',histories[0].OldValue__c);
		system.assertEquals('999',histories[0].NewValue__c);
		system.assertEquals('Actual_Amount_Blocked__c',histories[0].Field__c);

	}

	@isTest static void checkNonExistingField() {
		Country_Profile__c cp1 = new Country_Profile__c();
		cp1.Actual_Amount_Blocked__c = '123';		
		Country_Profile_History_Tracking__c cpht = new Country_Profile_History_Tracking__c(Name='somerandomfield');

		Test.startTest();
		insert cpht;
		insert cp1;
		//for some reason, the excecution of trigger method is reversed during test run... need to reset the firstExec var 
		CountryProfileTriggerHandler.firstExec = true;
		cp1.Actual_Amount_Blocked__c = '999';
		update cp1;
		Test.stopTest();
		List<Country_Profile_History__c> histories = [SELECT Id,OldValue__c,NewValue__c,Field__c FROM Country_Profile_History__c WHERE Country_Profile__c =: cp1.Id];
	}

	@isTest static void checkValidations() {
		Country_Profile__c cp1 = new Country_Profile__c();

		Test.startTest();
		insert cp1;
		try{
			cp1.Publish_News__c = 'Yes';
			update cp1;
		} catch (Exception e) {
		}
		try{
			cp1.Send_Notifications__c = 'Yes';
			update cp1;
		} catch (Exception e) {
		}
		
		Test.stopTest();
	}

	@isTest static void checkSubscribeUsersToNewCountryProfile() {
		Test.startTest();

		Id conRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Id accRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

        //Set<String> customerUserTypes = new Set<String> {'CSPLiteUser','PowerPartner','PowerCustomerSuccess','CustomerSuccess'};
        Account acc = new Account (
        RecordTypeId = accRtId, 
        Name = 'testAcc'
        );  
        insert acc;

        Contact con = new Contact (
        AccountId = acc.id,
        RecordTypeId = conRtId, 
        LastName = 'portalUser',
        FirstName = 'Name',
        User_Portal_Status__c = 'Approved User'
        );
        insert con;

        Id communityId = [SELECT Id FROM Network WHERE Name = 'IATA Portal'].Id;
        //Id nmgId = [SELECT Id,ParentId FROM NetworkMemberGroup WHERE NetworkId =: communityId LIMIT 1].ParentId;
        Profile p = [select Id,name from Profile where Name = 'ISS Portal Airline User (Partner)' limit 1];
         
        User newUser = new User(
        profileId = p.id,
        username = 'someuser@iata.org',
        email = 'someuser@iata.org',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = con.id,
        License_Cost_Center__c = 'ISF005CH01'
        );
        insert newUser;

        Portal_Applications__c app = new Portal_Applications__c(Application_URL__c='/ISSP_CurrencyCenterHome');
        insert app;

        Portal_Application_Right__c par = 
            new Portal_Application_Right__c(Contact__c=newUser.ContactId,Right__c = 'Access Granted',Portal_Application__c=app.Id);
        insert par;

        Country_Profile__c cp1 = new Country_Profile__c();
        insert cp1;

        Test.stopTest();
	}


	/***
	no way to insert network through API ?
	@isTest static void checkNotifications() {
		Country_Profile__c cp1 = new Country_Profile__c();

		Test.startTest();
		Network n = new Network(Name = 'IATA Portal');
		insert n;
		EntitySubscription es = new EntitySubscription(ParentId=cp1.Id,NetworkId=n.Id);

		cp1.Send_Notifications__c = 'Yes';
		cp1.Notification_Message__c = 'Some notification';
		insert cp1;

		Test.stopTest();
	}
	***/
	
}