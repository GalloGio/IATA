@isTest
public with sharing class TestPortalSupportReachUsCtrl {

public static testMethod void TestPortalSupportReachUsCtrl(){
	IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
	                                                      IATA_COUNTRY_EN__c = 'testEN', IATA_Country_FR__c = 'testFR', IATA_Country_ZH__c = 'testZH',
	                                                      IATA_Country_IT__c = 'testIT', IATA_Country_JP__c = 'testJP', ISO_Code__c = 'tq',
	                                                      IATA_Country_PT__c = 'testPT', IATA_Country_SP__c = 'testSP', Case_BSP_Country__c = 'test' );
	insert country;
	IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'GB', ISO_Code__c = 'GB', Case_BSP_Country__c = 'GB', CASS_Import__c = 'Yes');
	insert country2;

	Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

	Account parent = ISSP_ObjectFactory.createNewAccount();
	parent.BillingCity = 'test';
	parent.Name = 'test';
	parent.sector__c = 'Travel Agent';
	parent.Location_Type__c = 'HO';
	parent.RecordTypeId = rtIdBr; 
	parent.IATACode__c = '100';

	insert parent;
	Account child = ISSP_ObjectFactory.createNewAccount();
	child.BillingCity = 'GB';
	child.Name = 'GB';
	child.Site = 'headSite';
	child.sector__c = 'Travel Agent';
	child.Top_Parent__c = parent.Id;
	child.IATA_ISO_Country__c = country.Id;
	child.RecordTypeId = rtIdBr;
	insert child;

	Contact con = ISSP_ObjectFactory.createNewContact();
	con.AccountId = child.Id;
	con.Email = 'Test@test11.com';
	insert con;

	User newUser = ISSP_ObjectFactory.createPortalUser(con);
	System.debug('newUser Id: ' + newUser.Id);
	con.OwnerId = newUser.Id;
	update con;

	LiveAgentButtonSettings__c labs = new LiveAgentButtonSettings__c();
	labs.Name = 'AgencyEnglishEurope';
	labs.ButtonId__c = '5731r00000003vK';
	labs.Button_Per_Topic__c = false;
	labs.DeploymentId__c = '572w0000000CdgF';
	labs.Language__c = 'en';
	labs.Region__c = 'Europe';
	labs.Sectors__c = 'Cargo Agent, Travel Agent';
	insert labs;

	LiveAgentButtonSettings__c labsWTopic = new LiveAgentButtonSettings__c();
	labsWTopic.Name = 'BIS - AirportIS';
	labsWTopic.ButtonId__c = '5731r0000004GMG';
	labsWTopic.Button_Per_Topic__c = true;
	labsWTopic.DeploymentId__c = '572w0000000CdgF';
	labsWTopic.Language__c = 'en';
	labsWTopic.Topic__c = 'AirportIS__c';
	insert labsWTopic;

	test.startTest();

	System.runAs(newUser) {

        Map<String,String> myMapRTContry = new Map<String,String>();

		Map<String,String> myMapEs = new Map<String,String>();
		Map<String,String> myMapKo = new Map<String,String>();
		Map<String,String> myMapZHCN = new Map<String,String>();

		Map<String,String> myMapPTBR = new Map<String,String>();
		Map<String,String> myMapFR = new Map<String,String>();
		Map<String,String> myMapJA = new Map<String,String>();
		Map<String,String> myMapIT = new Map<String,String>();

		newUser.LanguageLocaleKey ='es';
		update newUser;
		myMapEs = PortalSupportReachUsCtrl.getCountryList();
		newUser.LanguageLocaleKey ='ko';
		update newUser;
		myMapKo = PortalSupportReachUsCtrl.getCountryList();
		newUser.LanguageLocaleKey ='zh_CN';
		update newUser;
		myMapZHCN = PortalSupportReachUsCtrl.getCountryList();
		newUser.LanguageLocaleKey ='pt_BR';
		update newUser;
		myMapPTBR = PortalSupportReachUsCtrl.getCountryList();
		newUser.LanguageLocaleKey ='fr';
		update newUser;
		myMapFR = PortalSupportReachUsCtrl.getCountryList();
		newUser.LanguageLocaleKey ='ja';
		update newUser;
		myMapJA = PortalSupportReachUsCtrl.getCountryList();
		newUser.LanguageLocaleKey ='it';
		update newUser;
		myMapIT = PortalSupportReachUsCtrl.getCountryList();
        
        List<PortalSupportReachUsCtrl.LVA_CallUsConfigClass> phoneNumbers = PortalSupportReachUsCtrl.getCallUsPhoneNumber();

        Contact cont = PortalSupportReachUsCtrl.getContactInfo();

        myMapRTContry = PortalSupportReachUsCtrl.getCaseTypeAndCountry(cont,'GB');
		List<LiveAgentButtonSettings__c> labstest = PortalSupportReachUsCtrl.getLiveAgentButton('AirportIS','GB',cont,false);
		List<LiveAgentButtonSettings__c> labstests = PortalSupportReachUsCtrl.getLiveAgentButton('AirportIS','',cont, true);
		List<ISSP_FAQ2Case_Emergencies__c> caseEmergencies = PortalSupportReachUsCtrl.getEmergencyDependencies();
		test.stopTest();
	}
}
}