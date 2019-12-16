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
		Account_Contact_Role__c acr = new Account_Contact_Role__c(Account_Role__c = accRole.Id, Contact__c = c2.Id, Service_Rendered__c = 'Other', RecordTypeId = accContactRole_RT, Contact_Role_Name__c = 'Trainee');
		insert acr;

		Training_Contact_Role_Details__c tcrd = new Training_Contact_Role_Details__c(Account_Contact_Role__c = acr.Id);
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

			PortalRegistrationThirdLevelLMSCtrl.completeRegistration(paramsJSON3);
			PortalRegistrationThirdLevelLMSCtrl.RegistrationResult res = PortalRegistrationThirdLevelLMSCtrl.completeRegistration(paramsJSON3);

			system.assert(res.isSuccess);
			system.assert(res.message == 'Regitration Completed!');


			PortalRegistrationThirdLevelLMSCtrl.sendSingleEmail(c.Name, c.Email, 'flow3', paramsJSON3);

			Boolean valid = PortalRegistrationThirdLevelLMSCtrl.validateYasUserId(UserInfo.getUserId());
			system.assert(valid);

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

}