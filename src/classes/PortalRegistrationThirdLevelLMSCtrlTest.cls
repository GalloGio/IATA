@isTest
public class PortalRegistrationThirdLevelLMSCtrlTest{

	@testSetup
	static void setup(){

		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'United States', ISO_Code__c = 'US');
		insert isoc;

		IATA_ISO_State__c isoState = new IATA_ISO_State__c(Name = 'New York', IATA_ISO_Country__c = isoc.Id, ISO_Code__c = 'NY');
		insert isoState;

		Account acc = new Account(Name = 'Test Account');
		insert acc;

		Contact c = new Contact(LastName = 'Doe', AccountId = acc.Id, Email = 'doetest@test.com');
		insert c;

		Contact c2 = new Contact(LastName = 'Don', AccountId = acc.Id, Email = 'dontest@test.com');
		insert c2;

		Account_Role__c accRole = new Account_Role__c(Account__c = acc.Id);
		insert accRole;

		Id accContactRole_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Master');
		Account_Contact_Role__c acr = new Account_Contact_Role__c(Account_Role__c = accRole.Id, Contact__c = c2.Id, Service_Rendered__c = 'Other', RecordTypeId = accContactRole_RT, Contact_Role_Name__c = 'Trainee', Functional_Role__c =  'Training');
		insert acr;

		String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Training_Contact_Role_Details__c', 'Yardstick_Trainee');
		Training_Contact_Role_Details__c tcrd = new Training_Contact_Role_Details__c(Account_Contact_Role__c = acr.Id, RecordTypeId = RECTYPE_Trainee_YASContDet);
		insert tcrd;

		Portal_Applications__c pa = new Portal_Applications__c(Name = 'Training Platform (LMS)');
		insert pa;

		Term_and_Condition__c tos = new Term_and_Condition__c(NewGenApp_PortalService__c = pa.Id, Is_Latest__c = true, Status__c = 'Final', Effective_Start_Date__c = Date.today());
		insert tos;

	}

	@isTest
	static void testCompleteRegistrationFlow3(){

		List<Contact> contacts = [SELECT Id, Name, Email FROM Contact];
		Contact c;
		Contact c2;
		for(Contact con: contacts){
			if(con.Name == 'Doe')
				c = con;
			else if(con.Name == 'Don'){
				c2 = con;
			}

		}

		List<IATA_ISO_State__c> isoState = [SELECT Id, Name FROM IATA_ISO_State__c];

		Test.startTest();

			String paramsJSON3= '{"flow":"flow3","Id":"' + c.Id + '","Birthdate":"2019-11-04","stateId":"' + isoState[0].Id + '","existingContactId":"' + c2.Id + '","hasExistingContact":"true","Phone":"21212121"}}';

			PortalRegistrationThirdLevelLMSCtrl.RegistrationResult res = PortalRegistrationThirdLevelLMSCtrl.completeRegistration(paramsJSON3);

			system.assert(res.isSuccess);
			system.assert(res.message == 'Regitration Completed!');

			PortalRegistrationThirdLevelLMSCtrl.sendSingleEmail(c.Name, c.Email, 'flow3', paramsJSON3);

			String result = PortalRegistrationThirdLevelLMSCtrl.validateYasUserId(UserInfo.getUserId(), UserInfo.getUserName(), UserInfo.getFirstName(), UserInfo.getLastName());
			system.assert(result == 'not_existing');

		test.stopTest();
	}

	@isTest
	static void testCompleteRegistrationFlow4(){

		List<Contact> contacts = [SELECT Id, Name, Email FROM Contact];
		Contact c;
		Contact c2;
		for(Contact con: contacts){
			if(con.Name == 'Doe')
				c = con;
			else if(con.Name == 'Don'){
				c2 = con;
			}

		}

		List<IATA_ISO_State__c> isoState = [SELECT Id, Name FROM IATA_ISO_State__c];

		Test.startTest();

		String paramsJSON4 = '{"flow":"flow4","Id":"' + c.Id + '","Birthdate":"2019-11-04","stateId":"' + isoState[0].Id + '","existingContactId":"' + c2.Id + '","Phone":"21212121"}}';
		PortalRegistrationThirdLevelLMSCtrl.RegistrationResult res = PortalRegistrationThirdLevelLMSCtrl.completeRegistration(paramsJSON4);

		system.assert(res.isSuccess);
		system.assert(res.message == 'Regitration Completed!');

		test.stopTest();
	}

	@isTest
	static void testCompleteRegistrationFlow5(){

		List<Contact> contacts = [SELECT Id, Name, Email FROM Contact];
		Contact c;
		Contact c2;
		for(Contact con: contacts){
			if(con.Name == 'Doe')
				c = con;
			else if(con.Name == 'Don'){
				c2 = con;
			}

		}

		List<IATA_ISO_State__c> isoState = [SELECT Id, Name FROM IATA_ISO_State__c];

		Test.startTest();

		String paramsJSON5 = '{"flow":"flow5","Id":"' + c.Id + '","Birthdate":"2019-11-04","stateId":"' + isoState[0].Id + '","existingContactId":"' + c2.Id + '","Phone":"21212121"}';
		PortalRegistrationThirdLevelLMSCtrl.RegistrationResult res = PortalRegistrationThirdLevelLMSCtrl.completeRegistration(paramsJSON5);

		system.assert(res.isSuccess);
		system.assert(res.message == 'Regitration Completed!');

		test.stopTest();
	}

	@isTest
	static void testCompleteRegistrationFlow6(){

		List<Contact> contacts = [SELECT Id, Name, Email FROM Contact];
		Contact c;
		Contact c2;
		for(Contact con: contacts){
			if(con.Name == 'Doe')
				c = con;
			else if(con.Name == 'Don'){
				c2 = con;
			}

		}

		List<IATA_ISO_State__c> isoState = [SELECT Id, Name FROM IATA_ISO_State__c];

		Test.startTest();

		String paramsJSON6 = '{"flow":"flow6","Id":"' + c.Id + '","Birthdate":"2019-11-04","stateId":"' + isoState[0].Id + '","existingContactId":"' + c2.Id + '","Phone":"21212121"}';
		PortalRegistrationThirdLevelLMSCtrl.RegistrationResult res = PortalRegistrationThirdLevelLMSCtrl.completeRegistration(paramsJSON6);

		system.assert(res.isSuccess);
		system.assert(res.message == 'Regitration Completed!');

		test.stopTest();
	}

	@isTest
	static void testGetLmsContactInfo(){

		Test.startTest();

		PortalRegistrationThirdLevelLMSCtrl.getLMSContactInfo('yas');

		Test.stopTest();
	}

	@isTest
	static void testGetParameters(){

		Test.startTest();

		String paramsJSON = '{"Additional_Email":"ad@test.test","Email":"em@test.test"}';
		string encryptedStr = PortalPasswordHandler.EncryptString(paramsJSON);
		String encodedPart = 'c=' + EncodingUtil.urlEncode(encryptedStr, 'UTF-8');
		PortalRegistrationThirdLevelLMSCtrl.returnWrapper result = PortalRegistrationThirdLevelLMSCtrl.getParameters('apex/TestPage?'+encodedPart);
		Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(result.userInfo);
		system.assert(res.get('Additional_Email') == 'ad@test.test');
		system.assert(res.get('Email') == 'em@test.test');

		Test.stopTest();
	}

}