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
}
