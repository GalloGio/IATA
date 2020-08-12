@isTest
public with sharing class TestPortalSupportReachUsCtrl {
@TestSetup
static void setupData(){
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

}

private static testMethod void TestPortalSupportReachUsCtrl(){
	test.startTest();

	User newUser=[SELECT id FROM user WHERE email ='Test@test11.com'];

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

		User usr = PortalSupportReachUsCtrl.getContactInfo();

		myMapRTContry = PortalSupportReachUsCtrl.getCaseTypeAndCountry(usr.contact,'GB');
		List<LiveAgentButtonSettings__c> labstest = PortalSupportReachUsCtrl.getLiveAgentButton('AirportIS','GB',usr.contact,false);
		List<LiveAgentButtonSettings__c> labstests = PortalSupportReachUsCtrl.getLiveAgentButton('AirportIS','',usr.contact, true);
		List<ISSP_FAQ2Case_Emergencies__c> caseEmergencies = PortalSupportReachUsCtrl.getEmergencyDependencies();
		test.stopTest();
	}
}

private static testMethod void testGetTopics(){

	PortalKnowledge__c faqCategory = new PortalKnowledge__c();
	faqCategory.Name = 'Travel';
	faqCategory.FAQsStructure__c = true;
	faqCategory.DataCategoryName__c = 'Travel';
	faqCategory.DataCategoryLabel_en_US__c = 'Travel';
	faqCategory.Order__c = 1;

	PortalKnowledge__c faqTopic = new PortalKnowledge__c();
	faqTopic.Name = 'IATA EasyPay';
	faqTopic.FAQsStructure__c = true;
	faqTopic.DataCategoryName__c = 'Travel';
	faqTopic.DataTopicName__c = 'IATA_EasyPay';
	faqTopic.DataCategoryLabel_en_US__c = 'TravelCategory';
	faqTopic.Order__c = 1;
	faqTopic.Requires_Level2_Registration__c=true;	

	PortalKnowledge__c faqSubtopic = new PortalKnowledge__c();
	faqSubtopic.Name = 'Changes to my Agency';
	faqSubtopic.FAQsStructure__c = true;
	faqSubtopic.DataCategoryName__c = 'Travel';
	faqSubtopic.DataTopicName__c = 'IATA_EasyPay';
	faqSubtopic.DataSubtopicName__c = 'PAX_Changes_to_my_Agency';
	faqSubtopic.DataCategoryLabel_en_US__c = 'Changes to my Agency';
	faqSubtopic.Order__c = 1;
	
	insert new List<PortalKnowledge__c>{ faqCategory, faqTopic, faqSubtopic };

	string result=PortalSupportReachUsCtrl.getTopicsWithL2Dep();
	list<map<string,string>> resultMapList=(list<map<string,string>>) JSON.deserialize(result,list<map<string,string>>.class);
	system.assertNotEquals(0,resultMapList.size());
}
}
