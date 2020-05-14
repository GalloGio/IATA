/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SCIMMessageEnhancerTest {

	static testMethod void test_generic_SCIMMessage() {

		Map<String,Object> inputParams = new Map<String,Object>();
		inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'givenName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'familyName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'email');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_USERNAME, 'userName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, 'externalid');

		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		SCIMMessageEnhancer message = new SCIMMessageEnhancer('SCIMMessageEnhancer');
		SCIMMessageEnhancer message_noConstructor = new SCIMMessageEnhancer();

		Test.startTest();
		message.enhanceMessage(request);
		Test.stopTest();
	}

	static testMethod void test_CopaMessage() {

		Map<String,Object> inputParams = new Map<String,Object>();
		inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'givenName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'familyName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'email');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_USERNAME, 'userName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, 'externalid');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_ENTITLEMENT, 'COPAMessage');

		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		COPASCIMMessageEnhancer cE = new COPASCIMMessageEnhancer('test');
		COPASCIMMessageEnhancer cE1 = new COPASCIMMessageEnhancer();

		Test.startTest();
		cE.enhanceMessage(request);
		Test.stopTest();
	}

	static testMethod void test_ANG_IEPSCIMMessage() {

		Map<String,Object> inputParams = new Map<String,Object>();
		inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'givenName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'familyName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'email');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_USERNAME, 'userName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, 'externalid');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_ENTITLEMENT, 'COPAMessage');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_PROPERTIES, '{"language" : "EN" , "IATA Code" : "90786"}');

		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		ANG_IEPSCIMMessage message = new ANG_IEPSCIMMessage('ANG_IEPSCIMMessage');
		ANG_IEPSCIMMessage message_noConstructor = new ANG_IEPSCIMMessage();

		Test.startTest();
		message.enhanceMessage(request);
		Test.stopTest();
	}

	static testMethod void test_GDISCIMMessage() {

		Map<String,Object> inputParams = new Map<String,Object>();
		inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'givenName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'familyName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'email');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_USERNAME, 'userName');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, 'externalid');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_ENTITLEMENT, 'COPAMessage');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_PROPERTIES, '{"language" : "EN" , "IATA Code" : "90786" , "Phone" : "12312313"}');

		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		GDI_SCIMMessageEnhancer message = new GDI_SCIMMessageEnhancer('GDI_SCIMMessageEnhancer');
		GDI_SCIMMessageEnhancer message_noConstructor = new GDI_SCIMMessageEnhancer();

		Test.startTest();
		message.enhanceMessage(request);
		Test.stopTest();
	}

	@isTest
	static void test_EF_APPS_SCIMMessageEnhancer() {

		Account acc = new Account();
		acc.Name = 'test_EF_APPS_SCIMMessageEnhancer';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		insert acc;

		Account_Role__c accRole = new Account_Role__c();
		accRole.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
		accRole.Functional_Role__c = 'E&F';
		accRole.Account__c = acc.Id;
		insert accRole;

		E_and_F_Account_Role_Detail__c efAccRoleDet = new E_and_F_Account_Role_Detail__c();
		efAccRoleDet.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('E_and_F_Account_Role_Detail__c', 'Client');
		efAccRoleDet.Account_Role__c = accRole.Id;
		insert efAccRoleDet;

		Contact con = new Contact();
		con.FirstName = 'efapps';
		con.LastName = 'scim';
		con.Email = 'efappsscim@message.enhancer';
		con.Salutation = 'Ms.';
		con.AccountId = acc.Id;
		insert con;

		User usr = TestDataGenerator.generatePortalUser('ISS Portal Airline Delegated Admin User', con.Id, false);
		usr.Email = 'efappsscim@message.enhancer';
		usr.Phone = '9999999999';
		usr.MobilePhone = '8888888888';
		insert usr;

		Account_Contact_Role__c accConRole = new Account_Contact_Role__c();
		accConRole.Account_Role__c = accRole.Id;
		accConRole.Contact__c = con.Id;
		accConRole.Functional_Role__c = 'E&F';
		accConRole.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		insert accConRole;

		E_and_F_Contact_Role_Detail__c efConRoleDet = new E_and_F_Contact_Role_Detail__c();
		efConRoleDet.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('E_and_F_Contact_Role_Detail__c', 'Standard_User');
		efConRoleDet.Contact_Role__c = accConRole.Id;
		efConRoleDet.E_F_Account_Role_Detail__c = efAccRoleDet.Id;
		insert efConRoleDet;

		Map<String,Object> inputParams = new Map<String,Object>();
		inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'efapps');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'scim');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_DISPLAYNAME, 'efapps scim');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, 'externalId');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'efappsscim@message.enhancer');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_PREFERREDLANGUAGE, 'EN');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_TITLE, 'Manager');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_ACTIVE, true);

		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		EF_APPS_SCIMMessageEnhancer message = new EF_APPS_SCIMMessageEnhancer('EF_APPS_SCIMMessageEnhancer');
		EF_APPS_SCIMMessageEnhancer message_noConstructor = new EF_APPS_SCIMMessageEnhancer();

		Test.startTest();
		message.enhanceMessage(request);
		Test.stopTest();
	}
}
