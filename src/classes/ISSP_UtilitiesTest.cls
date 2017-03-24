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
		Id agencyRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='IATA_Agency'].Id;
		String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC' LIMIT 1].Id;
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.CNS_Account__c = true;
		acc.RecordTypeId = agencyRecordTypeId;
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
}