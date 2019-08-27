@isTest
private class ANG_EarlyDetectionSystemTest {

	@testSetup static void setup(){
		
		Test.startTest();

		EDS_Alert_Stakeholders__c edsStakeholder = new EDS_Alert_Stakeholders__c();
		edsStakeholder.Name = 'Bob Stakeholder';
		edsStakeholder.Email__c = 'bob.stakeholder@test.com';
		insert edsStakeholder;

		Map<String, Profile> airlineProfileMap = new Map<String, Profile>(
			[SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Airline%']
		);

		Map<String, Profile> agencyProfileMap = new Map<String, Profile>(
			[SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Agency%']
		);

		List<ISSP_CS__c> listCs = new List<ISSP_CS__c>();

		listCs.add(
			new ISSP_CS__c(
				Name = 'ISS OperationalCalendar Airline Profil',
				Value__c = String.join(new List<string>(airlineProfileMap.keySet()),',')
			)
		);

		listCs.add(
			new ISSP_CS__c(
				Name = 'ISS OperationalCalendar Agency Profile',
				Value__c = String.join(new List<string>(agencyProfileMap.keySet()),',')
			)
		);

		insert listCs;

		AMS_Settlement_System__c bspSG = new AMS_Settlement_System__c(
			Name = 'BSP-SG',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		insert new List<AMS_Settlement_System__c>{bspSG, bspPT};

		Operational_Calendar__c opSG = new Operational_Calendar__c( 
			ISS_Operation__c = bspSG.id, 
			First_Day__c = Date.today().addDays(-30), 
			Last_Day__c = Date.today().addDays(1), 
			Frequency_code__c = 'W', 
			Remittance_Day__c = Date.today()
		);
		
		Operational_Calendar__c opPT = new Operational_Calendar__c( 
			ISS_Operation__c = bspPT.id, 
			First_Day__c = Date.today().addDays(-30), 
			Last_Day__c = Date.today().addDays(1), 
			Frequency_code__c = 'W', 
			Remittance_Day__c = Date.today()
		);

		insert new List<Operational_Calendar__c>{opSG, opPT};

		IATA_ISO_Country__c countryWW = new IATA_ISO_Country__c(
			Name = 'All Countries',
			ISO_Code__c = 'WW'
		);

		IATA_ISO_Country__c countrySG = new IATA_ISO_Country__c (
			Name = 'Singapore', 
			ISO_Code__c = 'SG',
			AMS_Settlement_System__c = bspSG.Id,
			ANG_Enable_NewGen__c = true
		);

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c (
			Name = 'Portugal', 
			ISO_Code__c = 'PT',
			AMS_Settlement_System__c = bspPT.Id,
			ANG_Enable_NewGen__c = false
		);

		insert new List<IATA_ISO_Country__c>{countryWW, countrySG, countryPT};
		
		Account agentSG = new Account(
			Name = 'Agent SG',
			IATACode__c ='999999999',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.HE,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = countrySG.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'W',
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'Singapore'
		);

		Account agentPT = new Account(
			Name = 'Agent PT',
			IATACode__c ='999999998',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.HO,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = countryPT.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'W',
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'Portugal'
		);

		insert new List<Account>{agentSG, agentPT};

		Account agentAeSG = new Account(
			Name = 'Agent AE SG',
			IATACode__c ='999999997',
			ParentId = agentSG.Id,
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.AE,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = countrySG.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'W',
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'Singapore'
		);

		Account agentBrPT = new Account(
			Name = 'Agent BR PT',
			IATACode__c ='999999996',
			ParentId = agentPT.Id,
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.BR,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = countryPT.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'W',
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'Portugal'
		);

		insert new List<Account>{agentAeSG, agentBrPT};

		Contact contSG = new Contact(
			FirstName = 'Agent',
			LastName = 'Singapore',
			AccountId = agentSG.Id,
			Status__c = 'Active',
			Email = 'agent.singapore@test.com',
			Financial_Assessment_Contact__c = true
		);

		Contact contPT = new Contact(
			FirstName = 'Agent',
			LastName = 'Portugal',
			AccountId = agentPT.Id,
			Email = 'agent.portugal@test.com',
			Status__c = 'Active',
			User_Portal_Status__c = ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM
		);
		
		Contact contInactivePT = new Contact(
			FirstName = 'Agent Inactive',
			LastName = 'Portugal',
			AccountId = agentPT.Id,
			Email = 'agent.inactive.portugal@test.com',
			Status__c = 'Inactive',
			User_Portal_Status__c = ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM
		);

		insert new List<Contact>{contSG, contPT, contInactivePT};

		Test.stopTest();

	}

	@isTest static void createSMAPCaseOnEdsAlertHETest(){
		assessSMAPCaseCreationOnEdsAlert(AMS_Utils.HE);
	}

	@isTest static void createSMAPCaseOnEdsAlertHOTest(){
		assessSMAPCaseCreationOnEdsAlert(AMS_Utils.HO);
	}

	@isTest static void doNotcreateSMAPCaseOnEdsAlertTest(){

		Map<Id, Account> acctMap = new Map<Id, Account>( 
			[SELECT 
				Id
			 FROM 
				Account 
			 WHERE 
				Location_Type__c = :AMS_Utils.AE
			 OR
				Location_Type__c = :AMS_Utils.BR
			]
		);

		Id riskAlertEDSRecType = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Risk_Alert__c','Risk_Alert_EDS');

		List<ANG_Risk_Alert__c> raLst = new List<ANG_Risk_Alert__c>();

		for(Account acct : acctMap.values()){
			ANG_Risk_Alert__c ra = new ANG_Risk_Alert__c(
				RecordTypeId = riskAlertEDSRecType, 
				ANG_Account__c = acct.Id,
				ANG_Open_Cash_Position__c = 634.46,
				ANG_Triggered_Rules__c = 'edsRule_cashSales_ratio_L3M;edsRule_ticketsAbroad_ratio_L3M',
				ANG_Agent_current_standing__c = 'Cross Border Sales: 0.5\nCash Sales Shift: 0.6\n'
			);
			raLst.add(ra);
		}

		Test.startTest();

		insert raLst;

		Test.stopTest();

		List<Case> cseLst = new List<Case>(
			[SELECT 
				Id
			 FROM 
				Case 
			 WHERE 
				AccountId IN :acctMap.keySet()
			 AND
				RecordType.DeveloperName = 'sMAP_sales_Monitoring_Alert_Process' 
			]
		);

		system.assert(cseLst.isEmpty(), 'SMAP case must NOT be created for EDS Alert');

	}

	private static void assessSMAPCaseCreationOnEdsAlert(String locationType){
		
		Account acct = 
			[SELECT 
				Id,
				Name,
				IATACode__c,
				Region_Formula__c,
				IATA_ISO_Country__r.Name,
				IATA_ISO_Country__r.ISO_Code__c,
				IATA_ISO_Country__r.AMS_Settlement_System__c,
				(SELECT 
					Id, 
					Name, 
					User_Portal_Status__c,
					Financial_Assessment_Contact__c
				 FROM 
					Contacts 
				 WHERE 
					Status__c = 'Active'
				)
			 FROM 
				Account 
			 WHERE 
				Location_Type__c = :locationType
			 LIMIT 1
			];

		Id riskAlertEDSRecType = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Risk_Alert__c','Risk_Alert_EDS');

		ANG_Risk_Alert__c ra = new ANG_Risk_Alert__c(
			RecordTypeId = riskAlertEDSRecType, 
			ANG_Account__c = acct.Id,
			ANG_Open_Cash_Position__c = 634.46,
			ANG_Triggered_Rules__c = 'edsRule_cashSales_ratio_L3M;edsRule_ticketsAbroad_ratio_L3M ',
			ANG_Agent_current_standing__c = 'Cross Border Sales: 0.5\nCash Sales Shift: 0.6\n'
		);

		Test.startTest();

		insert ra;

		Test.stopTest();

		Case cse = 
			[SELECT 
				Id, 
				Status,
				Reason, 
				Origin,
				Subject,
				Region__c,
				ContactId,
				Contact.Name,
				Reason1__c,
				BSP_CASS__c,
				CaseArea__c,
				BSPCountry__c,
				Next_Remittance_Date__c,
				Visible_on_ISS_Portal__c,
				End_Date_of_Sales_Period__c,
				Start_Date_of_Sales_Period__c
			 FROM 
				Case 
			 WHERE 
				AccountId = :acct.Id
			 AND
				RecordType.DeveloperName = 'sMAP_sales_Monitoring_Alert_Process'
			 LIMIT 1
			];

		Operational_Calendar__c oc = 
			[SELECT 
				Id, 
				First_Day__c, 
				Last_Day__c, 
				Remittance_Day__c,
				Frequency_Code__c
			 FROM 
				Operational_Calendar__c 
			 WHERE 
				ISS_Operation__c = :acct.IATA_ISO_Country__r.AMS_Settlement_System__c
			 LIMIT 1
			];

		String expectedSubject = 'SMAP - EDS - ' + acct.IATA_ISO_Country__r.ISO_Code__c + ' - ' + acct.IATACode__c;

		system.assert(cse.Status == 'Open', 'The SMAP status must be Open');
		system.assert(cse.Reason == 'EDS', 'The SMAP Reason must be \'EDS\'');
		system.assert(cse.Reason1__c == 'EDS', 'The SMAP Reason1 must be \'EDS\'');
		system.assert(cse.Subject == expectedSubject, 'The SMAP Subject must be: \'' + expectedSubject + '\'');
		system.assert(cse.CaseArea__c == 'Agency Risk Management', 'The SMAP Case Area must be \'Agency Risk Management\'');
		system.assert(cse.Origin == 'Risk Monitoring Engine', 'The SMAP Origin must be \'Risk Monitoring Engine\'');
		system.assert(cse.BSPCountry__c == acct.IATA_ISO_Country__r.Name, 'The SMAP BSP Country must be \'' + acct.IATA_ISO_Country__r.Name + '\'');
		system.assert(cse.BSP_CASS__c == 'BSP', 'The SMAP BSP Cass must be \'BSP\'');
		system.assert(cse.Region__c == acct.Region_formula__c, 'The SMAP Region must be \'' + acct.Region_Formula__c + '\'');
		system.assert(cse.Start_Date_of_Sales_Period__c == oc.First_Day__c, 'The SMAP Start Date of Sales Period must be \'' + oc.First_Day__c + '\'');
		system.assert(cse.End_Date_of_Sales_Period__c == oc.Last_Day__c, 'The SMAP End Date of Sales Period must be \'' + oc.Last_Day__c + '\'');
		system.assert(cse.Next_Remittance_Date__c == oc.Remittance_Day__c, 'The SMAP Next Remittance Date must be \'' + oc.Remittance_Day__c + '\'');

		List<Contact> contactLst = acct.Contacts;

		Contact expectedContact = null;

		for(Contact c : contactLst){
			
			if(c.User_Portal_Status__c == ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM){
				expectedContact = c;
				break;
			}
			else if (c.Financial_Assessment_Contact__c){
				expectedContact = c;
			}

		}
		
		system.assert(cse.ContactId == expectedContact.Id, 'The SMAP Contact must be \'' + expectedContact.Name + '\'(' + expectedContact.Id + ')');
	
	}

	@isTest
	private static void putInvalidEDSAlertWithoutTriggeredRulesTest() {

		RestRequest req = new RestRequest();
		req.httpMethod = 'PUT';
		req.requestURI = System.URL.getSalesforceBaseUrl() + '/services/apexrest/RME_ALERT_BALANCEUPDATE/';

		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '999999999';
		message.eventId = 'b1088137-2db8-4c69-a599-98f6f5b84a6f';
		message.eventType = 'EDSAlert';
		message.schemaVersion = 2;
		message.eventTime = System.now();

		req.requestBody = Blob.valueOf(JSON.serialize(message));

		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_Risk_Alert__c> alerts = new List<ANG_Risk_Alert__c>(
			[SELECT 
				Id,
				ANG_Triggered_Rules__c,
				ANG_Open_Cash_Position__c,
				ANG_Agent_current_standing__c 
			 FROM 
			 	ANG_Risk_Alert__c
			]
		);

		System.assertEquals(400, RestContext.response.StatusCode, 'Expected response status: 400');
		System.assertEquals(0, alerts.size(), 'EDS Alert must NOT be created');
		System.assertEquals(result.description.trim(), 'Required values missing: triggeredRules', 'The description must be Required values missing: triggeredRules');

	}

	@isTest
	private static void putInvalidEDSAlertWithoutIATACodeTest() {

		RestRequest req = new RestRequest();
		req.httpMethod = 'PUT';
		req.requestURI = System.URL.getSalesforceBaseUrl() + '/services/apexrest/RME_ALERT_BALANCEUPDATE/';

		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.eventId = 'b1088137-2db8-4c69-a599-98f6f5b84a6f';
		message.eventType = 'EDSAlert';
		message.schemaVersion = 2;
		message.eventTime = System.now();

		req.requestBody = Blob.valueOf(JSON.serialize(message));

		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_Risk_Alert__c> alerts = new List<ANG_Risk_Alert__c>(
			[SELECT 
				Id,
				ANG_Triggered_Rules__c,
				ANG_Open_Cash_Position__c,
				ANG_Agent_current_standing__c 
			 FROM 
			 	ANG_Risk_Alert__c
			]
		);

		System.assertEquals(404, RestContext.response.StatusCode, 'Expected response status: 404');
		System.assertEquals(0, alerts.size(), 'EDS Alert must NOT be created');
		System.assertEquals(result.description.trim(), 'Required value missing: iataCode', 'The description must be Required value missing: iataCode');

	}

	@isTest
	private static void putValidEDSAlertTest() {

		RestRequest req = new RestRequest();
		req.httpMethod = 'PUT';
		req.requestURI = System.URL.getSalesforceBaseUrl() + '/services/apexrest/RME_ALERT_BALANCEUPDATE/';

		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '999999999';
		message.eventId = 'b1088137-2db8-4c69-a599-98f6f5b84a6f';
		message.eventType = 'EDSAlert';
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.triggeredRules = new List<String>{
			'edsRule_fastGrowth_decrease_L12M_P12M', 
			'edsRule_ticketsAbroad_ratio_L3M'
		};

		List<ANG_RME_Alert_Service.AgentStates> agentStateLst = new List<ANG_RME_Alert_Service.AgentStates>();

		ANG_RME_Alert_Service.AgentStates fastGrowthState = new ANG_RME_Alert_Service.AgentStates();
		fastGrowthState.state = 'edsState_fastGrowth_ratio_L12M_P12M';
		fastGrowthState.value = '0.55';

		ANG_RME_Alert_Service.AgentStates ticketsAbroadState = new ANG_RME_Alert_Service.AgentStates();
		ticketsAbroadState.state = 'edsState_ticketsAbroad_ratio_L3M';
		ticketsAbroadState.value = '0.8';

		ANG_RME_Alert_Service.AgentStates marketIntelligence = new ANG_RME_Alert_Service.AgentStates();
		marketIntelligence.state = 'edsState_market_intelligence';
		marketIntelligence.value = 'false';

		ANG_RME_Alert_Service.AgentStates consumedRHC = new ANG_RME_Alert_Service.AgentStates();
		consumedRHC.state = 'consumedRHC_USD';
		consumedRHC.value = '12500.25';

		agentStateLst.add(fastGrowthState);
		agentStateLst.add(ticketsAbroadState);
		agentStateLst.add(marketIntelligence);
		agentStateLst.add(consumedRHC);
		
		system.debug('agentStateLst: ' + agentStateLst);

		message.agentStates = agentStateLst;

		req.requestBody = Blob.valueOf(JSON.serialize(message));

		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_Risk_Alert__c> alerts = new List<ANG_Risk_Alert__c>(
			[SELECT 
				Id,
				ANG_Triggered_Rules__c,
				ANG_Open_Cash_Position__c,
				ANG_Agent_current_standing__c 
			 FROM 
			 	ANG_Risk_Alert__c
			]
		);

		System.assertEquals(202, RestContext.response.StatusCode, 'Expected response status: 202');
		System.assertEquals(1, alerts.size(), 'And EDS Alert must be created');

		ANG_Risk_Alert__c alert = alerts.get(0);

		system.debug('ALERT: ' + alert);

		System.assertEquals(alert.ANG_Open_Cash_Position__c, 12500.25, 'Open cash position must have the value: 12500,25');
		System.assert(alert.ANG_Triggered_Rules__c.contains('edsRule_fastGrowth_decrease_L12M_P12M'), 'EDS Alert triggered rules must contain edsRule_fastGrowth_decrease_L12M_P12M');
		System.assert(alert.ANG_Triggered_Rules__c.contains('edsRule_ticketsAbroad_ratio_L3M'), 'EDS Alert triggered rules must contain edsRule_ticketsAbroad_ratio_L3M');

		System.assert(alert.ANG_Agent_current_standing__c.contains('Fast Growth Last 12m'), 'EDS Alert current standing must contain Fast Growth Last 12m');
		System.assert(alert.ANG_Agent_current_standing__c.contains('Cross Border Sales'), 'EDS Alert current standing must contain Cross Border Sales');
		System.assert(alert.ANG_Agent_current_standing__c.contains('Market Intelligence'), 'EDS Alert current standing must contain Market Intelligence');

	}

}