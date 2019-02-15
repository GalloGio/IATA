@isTest 
public class ANG_SAP_PPA_RemoveInvocation_Test {


	@testSetup
	static void setup() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
        insert ctry;

		Account acc = new Account(name = 'account name', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Passenger Agent', IATACode__c = '1234567',
            Location_Type__c =AMS_Utils.GE, Location_Class__c = AMS_Utils.LC_PASSENGER, recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY, IATA_ISO_Country__c = ctry.id );
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

        System.debug('JR debug OSCAR: ' + [SELECT ID, Oscar_Communication_Case_Id__c, Billing_Document_Number__c FROM AMS_Oscar__c limit 1]);

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
	}


	@isTest static void testRemoteInvocationPaymentType_PPA(){

		Remote_Invocation__c ri = [SELECT Status__c, Internal_ID__c FROM Remote_Invocation__c limit 1];

        Remote_Invocation_Artefact__c artifact = [SELECT Payment_type__c,External_ID__c FROM Remote_Invocation_Artefact__c limit 1 ];

		test.StartTest();

		artifact.Payment_type__c = 'PPA';
		artifact.External_ID__c = '123456';
		update artifact;

		//This will trigger the interface 
        ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
        update ri;

		test.StopTest();

		AMS_Oscar__c updatedOscar = [SELECT Billing_Document_Number__c FROM AMS_Oscar__c limit 1];

		//Check assert Equals
		System.assertEquals(artifact.External_ID__c, updatedOscar.Billing_Document_Number__c);
	}


	@isTest static void testRemoteInvocationPaymentType_SPDR(){
		Remote_Invocation__c ri = [SELECT Status__c, Internal_ID__c FROM Remote_Invocation__c limit 1];

        Remote_Invocation_Artefact__c artifact = [SELECT Payment_type__c,External_ID__c FROM Remote_Invocation_Artefact__c limit 1 ];

		test.StartTest();

		artifact.Payment_type__c = 'SPDR';
		update artifact;

		//This will trigger the interface 
        ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
        update ri;

		test.StopTest();

		AMS_Oscar__c updatedOscar = [SELECT Endorsement_Requested__c, Endorsement_requested_date__c, STEP47__c, STEP48__c, STEP49__c FROM AMS_Oscar__c limit 1];

		//Check assert Equals
		System.assert(updatedOscar.Endorsement_Requested__c);
		System.assertEquals(Date.today(), updatedOscar.Endorsement_requested_date__c);
		System.assertEquals('Passed', updatedOscar.STEP49__c);
		System.assertEquals('Not Applicable', updatedOscar.STEP47__c);
		System.assertEquals('Not Applicable', updatedOscar.STEP48__c);

	}

}