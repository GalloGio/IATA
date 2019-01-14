@isTest
private class LiveAgentPostChatControllerTest {

	private static void createTestData() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'United Kingdom';
		country.ISO_Code_Numeric__c = 123;
		country.ISO_Code__c = 'UK';
		country.Region__c = 'Europe';
		country.Case_BSP_Country__c  = 'United Kingdom';
		insert country;

		Id standardAccountRt = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Account a = new Account(IATA_ISO_Country__c = country.id, RecordTypeId = standardAccountRt, Name='Test Agency', IATAcode__c = '1234567', Short_Name__c = 'Test Agency', Source_System__c = 'AIMS');
		insert a;

		Contact c = new Contact(AccountId = a.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com',
							Financial_Assessment_Contact__c = false);
		insert c;

		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User user = new User(Alias = 'tst1', Email='testUser@testorg.com', EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = testProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='test.username@istest.com', License_Cost_Center__c = 'ISF005CH01');
		Insert user;

		Id caseRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
		Case relCase = new Case(RecordTypeId = caseRtId, AccountId = a.Id, ContactId = c.Id, Subject = 'testPostChat', Origin = 'Chat', Status= 'closed', OwnerId = user.Id);
		Insert relCase;
	}

	@isTest static void testPostChat() {
		createTestData();
		Case testCase = [SELECT Id, Subject, OwnerId FROM Case WHERE Subject ='testPostChat'][0];

		Test.startTest();
			PageReference pg = page.LiveAgentPostChatSurvey;
			pg.getParameters().put('attachedRecords','"Case":"'+testCase.Id+'"');

			LiveAgentPostChatController.WrapperCustomDetails cDetails = new LiveAgentPostChatController.WrapperCustomDetails();
			cDetails.value = 'en';
			cDetails.label = 'buttonlanguage';
			List<LiveAgentPostChatController.WrapperCustomDetails> listCDetails = new List<LiveAgentPostChatController.WrapperCustomDetails>();
			listCDetails.add(cDetails);
			LiveAgentPostChatController.WrapperDetailsChatDetails details = new LiveAgentPostChatController.WrapperDetailsChatDetails();
			details.customDetails = listCDetails;
			String js = System.JSON.serialize(details);
			pg.getParameters().put('chatDetails',js);

			Test.setCurrentPage(pg);
			LiveAgentPostChatController ctrl = new LiveAgentPostChatController();

			System.assert(ctrl.lang == 'en');

			System.assert(ctrl.getChannel() != null);
			System.assert(ctrl.getAgentExperience() != null);
			// System.assert(ctrl.commentAnswer != null);

			ctrl.setChannelAnswer('Chat');
			ctrl.commentAnswer = 'testComment';

			ctrl.submit();
			System.assert(!ctrl.isIncomplete);
			System.assert(ctrl.isSubmitted);

			ctrl.setAgentExperienceAnswer('Yes');
			ctrl.submit();
			System.assertEquals(1,[SELECT COUNT() FROM Instant_Surveys__c WHERE Relationship_to_Case__c =:testCase.Id]);

			ctrl.submit();
			System.assert(ctrl.isResubmission);

		Test.stopTest();

	}

}