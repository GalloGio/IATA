@isTest
private  class ISSP_UtilitiesTest {
	static testMethod void ISSP_UtilitiesTest() {
	    	//ISSP_ObjectFactory.fiilIncludedFields();
	    	//Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
	    	Account acc = ISSP_ObjectFactory.createNewAccount();
	        insert acc;
			//Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
			Contact con = ISSP_ObjectFactory.createNewContact();
			con.AccountId= acc.Id;
			insert con;
	    	Case testCase = ISSP_ObjectFactory.createNewCase();
	            //(Case)ISSP_ObjectFactory.createSObject('Case',false,3);
	         insert testCase;
	    	ISSP_Utilities.SendErrorNotificationEMail('test');
	    	ISSP_Utilities.getContactTypeById(con.Id);
	    	ISSP_Utilities.sendEmailToAdmins(Con.Id);
	    	ISSP_Utilities.DMLOpt(new set<string>{testCase.Id});
			ISSP_Utilities.isCNS();
	    }

	static testMethod void ISSP_UtilitiesTest2() {
		Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Id standardRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.Name = 'test Account';
		acc.CNS_Account__c = true;
		acc.RecordTypeId = standardRecordTypeId;
		insert acc;
		//Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId= acc.Id;
		insert con;
		Case testCase = ISSP_ObjectFactory.createNewCase();
		//(Case)ISSP_ObjectFactory.createSObject('Case',false,3);
		insert testCase;
		User u = new User(FirstName='Ángel',
 						   Division='UnitTest',
 						   License_Cost_Center__c='AAA000AA00',
 						   Username='test1@iata.org.amsdev1',
 						   LastName='Peña', Email='test1@iata.org',
 						   Alias='Test1', CommunityNickname='Test1',
 						   TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US',
 						   EmailEncodingKey='UTF-8', ProfileId=profileId,
 						   LanguageLocaleKey='en_US',
						   ContactId = con.Id);

        insert u;
		System.runAs(u) {
	    	//ISSP_ObjectFactory.fiilIncludedFields();
	    	//Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
	    	ISSP_Utilities.SendErrorNotificationEMail('test');
	    	ISSP_Utilities.getContactTypeById(con.Id);
	    	ISSP_Utilities.sendEmailToAdmins(Con.Id);
	    	ISSP_Utilities.DMLOpt(new set<string>{testCase.Id});
			ISSP_Utilities.isCNS();


		}
		}

	static testMethod void ISSP_UtilitiesTest3() {

		try {
			List<Account> a = new List<Account>();
			a.add(new Account());
			Boolean b = ISSP_Utilities.isEmpty(a);
			Boolean b2 = ISSP_Utilities.isNotEmpty(a);
			Boolean b3 = ISSP_Utilities.isNumeric('1');
			Contact c = new Contact();
			ISSP_Utilities.log(c);
			update a;
		} catch (Exception e) {

			ISSP_Utilities.exceptionTrace(e);
			ISSP_Utilities.exceptionDump(e);
			ISSP_Utilities.addErrorMessage(e);
		}


	    }

    static testMethod void test_grantAccessToSIS() {
        // Create portal App
        Portal_Applications__c app = new Portal_Applications__c(Name = ISSP_Ctrl_SISMembershipApplication.APP_NAME);
        insert app;
        //test account
        Account account = ISSP_ObjectFactory.createNewAccount();
        insert account;
        // test contacts
        Contact contact1 = ISSP_ObjectFactory.createNewContact();
        contact1.AccountId= account.Id;
        Contact contact2 = ISSP_ObjectFactory.createNewContact();
        contact2.AccountId= account.Id;
        insert new list<Contact>{contact1,contact2};
        // create portal right as denied to test the change to granted
        insert new Portal_Application_Right__c(
            Portal_Application__c = app.Id,
            Contact__c = contact2.Id,
            Right__c = 'Access Denied'
        );
        
        Test.StartTest();
        ISSP_WS_Utilities.grantAccessToSIS(new list<Id>{contact1.Id,contact2.Id});
        Test.stopTest();
        
        list<Portal_Application_Right__c> listResult = [
            SELECT Id
            FROM Portal_Application_Right__c
            WHERE Right__c = 'Access Granted'];
        System.assertEquals(2,listResult.size());
    }
}
