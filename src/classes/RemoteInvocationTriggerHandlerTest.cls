@isTest
public class RemoteInvocationTriggerHandlerTest {

	@isTest
	public static void testAssignRecordType() {
		Remote_Invocation__c re = new Remote_Invocation__c(Internal_ID__c = '1234567', 
			Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY,
			status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
		
		insert re;

		List<Remote_Invocation__c> fetchedRe = [SELECT recordtypeid FROM Remote_Invocation__c WHERE ID = :re.id ];
		System.assertEquals(fetchedRe[0].recordtypeid, RemoteInvocationTriggerHandler.RECTYPE_NEWGEN); 

	}

	@isTest
	public static void testCreateOSCARCase() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
		insert ctry;

		Account acc = new Account(name = 'account name', Sector__c = 'Travel Agent', Category__c = 'Cargo only', IATACode__c = '1234567',
			Location_Type__c =AMS_Utils.HE, Location_Class__c = AMS_Utils.LC_PASSENGER, recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY, IATA_ISO_Country__c = ctry.id );
		insert acc;

		Contact c = new Contact(FirstName = 'test', LastName = 'contact', email = 'email@contactmeila.com', AccountId = acc.id);
		insert c;

		Portal_Applications__c pa = new Portal_Applications__c(name = 'IATA EasyPay (EDENRED)');
		insert pa;

		Portal_Application_Right__c par = new Portal_Application_Right__c(Right__c = 'Access Granted', 
			ANG_Portal_Service_Role__c = 'IEP Admin',Contact__c = c.id, Portal_Application__c = pa.id);
		insert par;

		Remote_Invocation__c re = new Remote_Invocation__c(Internal_ID__c = '1234567', 
			Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY,
			status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
		
		insert re;

		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = re.id, Internal_ID__c = '1234567');
		insert artifact;

		//Making the process starting to create the Bank Account Case OSCAR 
		re.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update re;

		List<AMS_OSCAR__c> oscars = [SELECT id FROM AMS_OSCAR__c];		
		System.assertEquals(oscars.size(), 1); 

	}

	@isTest
	public static void testFailingNewGenValidations() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
		insert ctry;

		//not assigning the correct recordtype to the account
		Account acc = new Account(name = 'account name', Sector__c = 'Travel Agent', Category__c = 'Cargo only', IATACode__c = '1234567',
			Location_Type__c =AMS_Utils.HE, Location_Class__c = AMS_Utils.LC_PASSENGER, IATA_ISO_Country__c = ctry.id );
		insert acc;

		Contact c = new Contact(FirstName = 'test', LastName = 'contact', email = 'email@contactmeila.com', AccountId = acc.id);
		insert c;

		Portal_Applications__c pa = new Portal_Applications__c(name = 'IATA EasyPay (EDENRED)');
		insert pa;

		Portal_Application_Right__c par = new Portal_Application_Right__c(Right__c = 'Access Granted', 
			ANG_Portal_Service_Role__c = 'IEP Admin',Contact__c = c.id, Portal_Application__c = pa.id);
		insert par;

		try{
			Remote_Invocation__c re = new Remote_Invocation__c(Internal_ID__c = '1234567', 
				Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY,
				status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
			
			insert re;

			Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = re.id, Internal_ID__c = '1234567');
			insert artifact;

			//Making the process starting to create the Bank Account Case OSCAR 
			re.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
			update re;
		}catch(Exception e){}

		List<AMS_OSCAR__c> oscars = [SELECT id FROM AMS_OSCAR__c];
		System.assertEquals(oscars.size(), 0); 

	}

	@isTest
	public static void testFailingGeneralValidations() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
		insert ctry;

		//not assigning the correct recordtype to the account
		Account acc = new Account(name = 'account name', Sector__c = 'Travel Agent', Category__c = 'Cargo only', IATACode__c = '1234567',
			Location_Type__c =AMS_Utils.HE, Location_Class__c = AMS_Utils.LC_PASSENGER, recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY, IATA_ISO_Country__c = ctry.id );
		insert acc;

		Contact c = new Contact(FirstName = 'test', LastName = 'contact', email = 'email@contactmeila.com', AccountId = acc.id);
		insert c;

		Portal_Applications__c pa = new Portal_Applications__c(name = 'IATA EasyPay (EDENRED)');
		insert pa;

		Portal_Application_Right__c par = new Portal_Application_Right__c(Right__c = 'Access Granted', 
			ANG_Portal_Service_Role__c = 'IEP Admin',Contact__c = c.id, Portal_Application__c = pa.id);
		insert par;
		
		try{
				
			//not assigning the correct iata code, trigger will fail
			Remote_Invocation__c re = new Remote_Invocation__c(Internal_ID__c = '111111', 
				Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY,
				status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
			insert re;
            
			Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = re.id, Internal_ID__c = '111111');
			insert artifact;

			//Making the process starting to create the Bank Account Case OSCAR 
			re.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
			update re;
		}catch(Exception e){}

		List<AMS_OSCAR__c> oscars = [SELECT id FROM AMS_OSCAR__c];
		System.assertEquals(oscars.size(), 0); 
	}

	@isTest
	public static void testFailingCreatingOSCAR() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
		insert ctry;

		Account acc = new Account(name = 'account name', Sector__c = 'Travel Agent', Category__c = 'Cargo only', IATACode__c = '1234567',
			Location_Type__c =AMS_Utils.HE, Location_Class__c = AMS_Utils.LC_PASSENGER, recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY, IATA_ISO_Country__c = ctry.id );
		insert acc;


		Contact c = new Contact(FirstName = 'test', LastName = 'contact', email = 'email@contactmeila.com', AccountId = acc.id);
		insert c;

		Portal_Applications__c pa = new Portal_Applications__c(name = 'IATA EasyPay (EDENRED)');
		insert pa;

		//not assigning access granted to right
		Portal_Application_Right__c par = new Portal_Application_Right__c(Right__c = 'Access Denied', 
			ANG_Portal_Service_Role__c = 'IEP Admin',Contact__c = c.id, Portal_Application__c = pa.id);
		insert par;

		Remote_Invocation__c re = new Remote_Invocation__c(Internal_ID__c = '1234567', 
			Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY,
			status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
		
		insert re;

		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = re.id, Internal_ID__c = '1234567');
		insert artifact;

		//Making the process starting to create the Bank Account Case OSCAR 
		re.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update re;

		List<AMS_OSCAR__c> oscars = [SELECT id FROM AMS_OSCAR__c];
		System.assertEquals(oscars.size(), 0); 
	}
}