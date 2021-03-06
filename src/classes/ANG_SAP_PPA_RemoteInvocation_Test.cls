@isTest 
public class ANG_SAP_PPA_RemoteInvocation_Test {


	@testSetup
	static void setup() {

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
		insert ctry;

		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'ENDORS_CERT', Integration_System__c='Mulesoft',
		Action__c = 'GET' , CalloutClass__c = 'ANG_RME_Alert_Service', Event_Type__C = 'WebService', Change_code__c = 
		'GDIEN' ,Credential__c = '/v1/agencies/{agencyId}/offer/{offerId}/endorsement' , Named_Credential__c = 'Mulesoft_Credential_Masterdata',Type__c='Button',Field__c='' ));

		insert customsettings;
		
		Account acc = new Account(name = 'account name', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Passenger Agent', IATACode__c = '1234567',
			Location_Type__c = AMS_Utils.HE, Location_Class__c = AMS_Utils.LC_PASSENGER, recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY, IATA_ISO_Country__c = ctry.id );
		insert acc;

		//Create Oscar - 
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(STEP1__c = 'In Progress',  Account__c = acc.id, Process__c = AMS_Utils.NGGDI);
		insert oscar;

		Contact contact = new Contact(AccountId = acc.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert contact;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
		oscarCase.AccountId = acc.Id;
		oscarCase.ContactId = contact.Id;
		insert oscarCase;

		oscar.Oscar_Communication_Case_Id__c = oscarCase.id;
		update oscar;

		ID oppRecordtype = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'GDI_FinancialSecurity'); 
		Opportunity opp = new Opportunity(AccountId = acc.id, CloseDate = Date.today(), CurrencyIsoCode = 'USD', Name ='OPP - ' , RecordTypeId = oppRecordtype, 
										StageName = 'Pending', Related_Oscar__c = oscar.id, GDI_Offer_Id__c='001',  Offer_exchange_rate_date__c = Date.today());        
		insert opp;

		//create Remote Invocation 
		Remote_Invocation__c ri = new Remote_Invocation__c(Internal_ID__c = oscarCase.id,
								//RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_SAP_PPA,
								Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_SAP_PPA,
								Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
		insert ri;

		//create Remote Invocation Artifact 
		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = ri.id, 
			Internal_ID__c = oscarCase.id, External_ID__c='', Valid_From__c=system.Today(), AMOUNT__C = 1000);

		insert artifact;

		Test.stopTest();

	}


	@isTest static void testRemoteInvocationPaymentType_PPA(){

		Remote_Invocation__c ri = [SELECT Status__c, Internal_ID__c FROM Remote_Invocation__c limit 1];

		Remote_Invocation_Artefact__c artifact = [SELECT Payment_type__c,External_ID__c, Internal_ID__c FROM Remote_Invocation_Artefact__c limit 1 ];

		test.StartTest();

		artifact.Payment_type__c = AMS_Utils.SAP_PAYMENT_TYPE_PPA;
		update artifact;

		//This will trigger the interface 
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;

		Remote_Invocation_Artefact__c updatedRmtInvArt = [SELECT Status_Detail__c FROM Remote_Invocation_Artefact__c limit 1];

		System.assertEquals(updatedRmtInvArt.Status_Detail__c, 'Remote Invocation Artefact must have an External ID');

		artifact.Payment_type__c = AMS_Utils.SAP_PAYMENT_TYPE_PPA;
		artifact.External_ID__c = '123456';
		update artifact;

		//This will trigger the interface 
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING;
		update ri;

		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;

		test.StopTest();

		Case updatedCase = [SELECT OSCAR__r.Billing_Document_Number__c, New_interaction__c FROM Case limit 1];

		//Check External_ID be copied to oscar field Billing_Document_Number__c
		System.assertEquals(artifact.External_ID__c, updatedCase.oscar__r.Billing_Document_Number__c);
		System.assertEquals(AMS_Utils.NEW_INTERACTION_ATTACHMENT, updatedCase.New_interaction__c);

		updatedRmtInvArt = [SELECT Payment_type__c, Object_Id_Created__c FROM Remote_Invocation_Artefact__c limit 1];

		System.assertEquals(artifact.Internal_ID__c, updatedRmtInvArt.Object_Id_Created__c);
	}

	@isTest static void testRemoteInvocationWithoutPaymentType(){

		Remote_Invocation__c ri = [SELECT Status__c, Internal_ID__c FROM Remote_Invocation__c limit 1];

		test.StartTest();

	
		//This will trigger the interface 
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;

		Remote_Invocation__c ri_AfterUpdate = [SELECT Internal_ID__c, Status__c, Status_Detail__c FROM Remote_Invocation__c limit 1];

		Boolean expectedExceptionThrown = ri_AfterUpdate.Status_Detail__c.contains('Remote Invocation Artefact IATA code (' + ri_AfterUpdate.Internal_ID__c +') must have a Payment Type');
		System.assert(expectedExceptionThrown);

		test.StopTest();
	}

	@isTest static void testRemoteInvocationWithoutArtifact(){

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='PT',ISO_Code__c='PT', ANG_Enable_NewGen__c = true);
		insert ctry;

		Account acc = new Account(name = 'account name 2', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Passenger Agent', IATACode__c = '1234568',
			Location_Type__c =AMS_Utils.HE, Location_Class__c = AMS_Utils.LC_PASSENGER, recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY, IATA_ISO_Country__c = ctry.id );
		insert acc;

		//Create Oscar - 
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(STEP1__c = 'In Progress',  Account__c = acc.id, Process__c = AMS_Utils.NGGDI);
		insert oscar;

		Contact contact = new Contact(AccountId = acc.id, Firstname = 'teste2', Lastname='test2', Phone = '911111111', MobilePhone = '911111111', Email = 'test1@test.com', Financial_Assessment_Contact__c = false);
		insert contact;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
		oscarCase.AccountId = acc.Id;
		oscarCase.ContactId = contact.Id;
		insert oscarCase;

		oscar.Oscar_Communication_Case_Id__c = oscarCase.id;
		update oscar;

		//create Remote Invocation 
		Remote_Invocation__c ri = new Remote_Invocation__c(Internal_ID__c = oscarCase.id,
								//RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_SAP_PPA,
								Integration_Transaction_ID__c = 'idFromMulesoft2', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_SAP_PPA,
								Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
		insert ri;

		test.StartTest();

		//This will trigger the interface 
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;

		Remote_Invocation__c ri_AfterUpdate = [SELECT Internal_ID__c, Status__c, Status_Detail__c FROM Remote_Invocation__c Where ID = :ri.ID];

	   	Boolean expectedExceptionThrown =  ri_AfterUpdate.Status_Detail__c.contains('Remote Invocation IATA code (' + ri_AfterUpdate.Internal_ID__c + ') doesn\'t have a artifact');
		System.assert(expectedExceptionThrown);

		test.StopTest();
	}

	@isTest static void testRemoteInvocationDoesntMatchIds(){

		Remote_Invocation__c ri = [SELECT Status__c, Internal_ID__c FROM Remote_Invocation__c limit 1];

		Remote_Invocation_Artefact__c artifact = [SELECT Payment_type__c,External_ID__c, Internal_ID__c FROM Remote_Invocation_Artefact__c limit 1 ];

		Test.StartTest();

		artifact.Payment_type__c = AMS_Utils.SAP_PAYMENT_TYPE_PPA;
		artifact.Internal_ID__c = 'FAKE_ID';
		update artifact;

		//This will trigger the interface 
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;

		Test.stopTest();

		Remote_Invocation__c ri_AfterUpdate = [SELECT Internal_ID__c, Status__c, Status_Detail__c FROM Remote_Invocation__c Where ID = :ri.ID];

		system.assertEquals(ri_AfterUpdate.Status__c, AMS_Utils.FAILED);

	}

}