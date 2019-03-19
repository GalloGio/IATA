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
		}catch(Exception e){
			System.assert(e.getMessage().contains('Parent account with the IATA code 1234567 is not an IATA Agency.'), 'Error Message doesn\'t match: ' +e.getMessage());
		}

		List<AMS_OSCAR__c> oscars = [SELECT id FROM AMS_OSCAR__c];
		System.assertEquals(oscars.size(), 0); 

	}

	@isTest
	public static void testNoAccountFound() {

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
		}catch(Exception e){
			System.assert(e.getMessage().contains('Parent account with the IATA code 111111 not found.'), 'Error Message doesn\'t match: ' +e.getMessage());
		}

		List<AMS_OSCAR__c> oscars = [SELECT id FROM AMS_OSCAR__c];
		System.assertEquals(oscars.size(), 0); 
	}	

	@isTest
	public static void testDiferentIATACode() {

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
			Remote_Invocation__c re = new Remote_Invocation__c(Internal_ID__c = '1234567', 
				Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY,
				status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
			insert re;
            
			Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = re.id, Internal_ID__c = '111111');
			insert artifact;

			//Making the process starting to create the Bank Account Case OSCAR 
			re.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
			update re;
		}catch(Exception e){
			System.assert(e.getMessage().contains('Remote Invocation IATA code (1234567) doesn\'t match the Artifact IATA Code (111111).'), 'Error Message doesn\'t match: ' +e.getMessage());
		}

		List<AMS_OSCAR__c> oscars = [SELECT id FROM AMS_OSCAR__c];
		System.assertEquals(oscars.size(), 0); 
	}	

	@isTest
	public static void testNoArtifact() {

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
			Remote_Invocation__c re = new Remote_Invocation__c(Internal_ID__c = '1234567', 
				Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY,
				status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
			insert re;
            
            //Not Inserting the artifact
			//Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = re.id, Internal_ID__c = '111111');
			//insert artifact;

			//Making the process starting to create the Bank Account Case OSCAR 
			re.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
			update re;
		}catch(Exception e){
			System.assert(e.getMessage().contains('Remote Invocation (1234567) doesn\'t have a artifact.'), 'Error Message doesn\'t match: ' +e.getMessage());
		}

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

	@isTest
	public static void testAutomaticUploadReports() {

		Test.startTest();

		ISSP_External_Reports_Config__c conf = new ISSP_External_Reports_Config__c(
			name = 'bla',
			Portal_Service_ID__c = 'a2w1r000001STdj',
			Report_ID__c = 'TIP_AUTO_REPORTS'
		);

		insert conf;

		Account acc = new Account(name = 'some airline', Sector__c = 'Airline', 
			IATACode__c = '123', recordtypeid = AMS_Utils.RECTYPE_AIRLINE);

		Account acc2 = new Account(name = 'some airline2', Sector__c = 'Airline', 
			IATACode__c = '321', recordtypeid = AMS_Utils.RECTYPE_AIRLINE);

		List<Account> la = new List<Account>();
		la.add(acc);
		la.add(acc2);

		insert la;

		Remote_Invocation__c ri = new Remote_Invocation__c (
			Integration_Transaction_ID__c = 'ABC1',
			Internal_ID__c = '123',
			Request_Type__c = TIP_Utils.REQUEST_TYPE_TIP_AUTO_REPORTS,
			Source__c = 'IFG',
			Status__c = TIP_Utils.REMOTE_INVOCATION_STATUS_INITIALIZING
		);

		Remote_Invocation__c ri2 = new Remote_Invocation__c (
			Integration_Transaction_ID__c = 'ABC2',
			Internal_ID__c = '321',
			Request_Type__c = TIP_Utils.REQUEST_TYPE_TIP_AUTO_REPORTS,
			Source__c = 'IFG',
			Status__c = TIP_Utils.REMOTE_INVOCATION_STATUS_INITIALIZING
		);

		List<Remote_Invocation__c> lri = new List<Remote_Invocation__c>();
		lri.add(ri);
		lri.add(ri2);

		insert lri;

		Remote_Invocation_Artefact__c ria1 = new Remote_Invocation_Artefact__c (
			Name__c = 'some document 1',
			Remote_Invocation__c = lri[0].Id
		);

		Remote_Invocation_Artefact__c ria2 = new Remote_Invocation_Artefact__c (
			Name__c = 'some document 2',
			Remote_Invocation__c = lri[0].Id
		);

		Remote_Invocation_Artefact__c ria3 = new Remote_Invocation_Artefact__c (
			Name__c = 'some document 3',
			Remote_Invocation__c = lri[1].Id
		);

		Remote_Invocation_Artefact__c ria4 = new Remote_Invocation_Artefact__c (
			Name__c = 'some document 4',
			Remote_Invocation__c = lri[1].Id
		);

		List<Remote_Invocation_Artefact__c> lria = new List<Remote_Invocation_Artefact__c>();
		lria.add(ria1);
		lria.add(ria2);
		lria.add(ria3);
		lria.add(ria4);

		insert lria;

		lri = [Select Id, Status__c From Remote_Invocation__c Where Integration_Transaction_ID__c Like 'ABC%'];

		lri[0].Status__c = TIP_Utils.REMOTE_INVOCATION_STATUS_IN_PROGRESS;
		lri[1].Status__c = TIP_Utils.REMOTE_INVOCATION_STATUS_IN_PROGRESS;

		update lri;

		//
		//
		//
		lri = [Select Id, Integration_Transaction_ID__c, Internal_ID__c, Status__c From Remote_Invocation__c Where Integration_Transaction_ID__c Like 'ABC%'];		

		lria = [Select Id, Object_ID_Created__c, Remote_Invocation__c, Status__c From Remote_Invocation_Artefact__c Where Remote_Invocation__r.Integration_Transaction_ID__c Like 'ABC%'];

		List<ISSP_External_Report__c> erl = [Select id, Account__c, Report_ID__c From ISSP_External_Report__c];

		Map<Id, Id> extRepAccountMap = new Map<Id, Id>();

		for(ISSP_External_Report__c auxEr : erl) {
			extRepAccountMap.put(auxEr.Id, auxEr.Account__c);
		}

		//
		//  
		//
		for(Remote_Invocation_Artefact__c auxRia : lria) {
			if(auxRia.Remote_Invocation__c == ri.Id) {
				System.assertEquals(extRepAccountMap.get(auxRia.Object_ID_Created__c), acc.Id); 
			}
			if(auxRia.Remote_Invocation__c == ri2.Id) {
				System.assertEquals(extRepAccountMap.get(auxRia.Object_ID_Created__c), acc2.Id);
			}			
		}

		Remote_Invocation__c ri3 = new Remote_Invocation__c (
			Integration_Transaction_ID__c = 'ABC3',
			Internal_ID__c = '321',
			Request_Type__c = TIP_Utils.REQUEST_TYPE_TIP_AUTO_REPORTS,
			Source__c = 'IFG',
			Status__c = TIP_Utils.REMOTE_INVOCATION_STATUS_INITIALIZING
		);

		insert ri3;

		Remote_Invocation_Artefact__c ria5 = new Remote_Invocation_Artefact__c (
			Name__c = 'some document 5',
			Remote_Invocation__c = ri3.Id
		);

		Remote_Invocation_Artefact__c ria6 = new Remote_Invocation_Artefact__c (
			Name__c = 'some document 6',
			Remote_Invocation__c = ri3.Id
		);		

		List<Remote_Invocation_Artefact__c> lria2 = new List<Remote_Invocation_Artefact__c>();
		lria2.add(ria5);
		lria2.add(ria6);

		insert lria2;

		ri3.Status__c = TIP_Utils.REMOTE_INVOCATION_STATUS_IN_PROGRESS;

		update ri3;

		erl = [Select id, Account__c, Report_ID__c From ISSP_External_Report__c];

		//
		//
		//
		System.assertEquals(erl.size(), 2);

		extRepAccountMap = new Map<Id, Id>();

		for(ISSP_External_Report__c auxEr : erl) {
			extRepAccountMap.put(auxEr.Id, auxEr.Account__c);
		}

		lria = [Select Id, Object_ID_Created__c, Remote_Invocation__c, Status__c From Remote_Invocation_Artefact__c Where Remote_Invocation__r.Integration_Transaction_ID__c Like 'ABC%'];

		//
		//
		//
		for(Remote_Invocation_Artefact__c auxRia : lria) {
			if(auxRia.Remote_Invocation__c == ri.Id) {
				System.assertEquals(extRepAccountMap.get(auxRia.Object_ID_Created__c), acc.Id); 
			}
			if(auxRia.Remote_Invocation__c == ri2.Id) {
				System.assertEquals(extRepAccountMap.get(auxRia.Object_ID_Created__c), acc2.Id); 
			}
			if(auxRia.Remote_Invocation__c == ri3.Id) {
				System.assertEquals(extRepAccountMap.get(auxRia.Object_ID_Created__c), acc2.Id); 
			}			
		}

		Test.stopTest();
	}	
}