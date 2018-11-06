@isTest
private class AMP_ReplyToPostFromDigestByTopicTest {

	private static String airportsTopic = '#Airports'; 
	private static String securityTopic = '#Security'; 	
	private static String ndcTopic = '#NDC'; 
	private static String replyMessage = 'Reply Message Contents';
	
	@testSetup static void setup() {
	
		AMP_Account_Topics__c airportsAmpTopic = new AMP_Account_Topics__c(Name = 'Airports');
		AMP_Account_Topics__c ndcAmpTopic = new AMP_Account_Topics__c(Name = 'NDC');
		AMP_Account_Topics__c securityAmpTopic = new AMP_Account_Topics__c(Name = 'Security');
		
		insert new List<AMP_Account_Topics__c>{airportsAmpTopic, ndcAmpTopic, securityAmpTopic};
		
		IATA_ISO_Country__c countryQR = new IATA_ISO_Country__c(
			Name = 'Qatar', 
			ISO_Code__c = 'QR', 
			Region__c = 'Africa & Middle East'
		);
		
		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c(
			Name = 'Portugal', 
			ISO_Code__c = 'PT', 
			Region__c = 'Europe'
		);
		
		insert new List<IATA_ISO_Country__c>{countryQR, countryPT};

		Id airlineHQRectTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');

		Account firstAcctHQ = new Account(
			Name = 'Qatar Airways', 
			Airline_designator__c = 'QR', 
			ICCS_Membership_Status__c = 'Member', 
			Industry='Airline', 
			Type='Passenger',
			RecordTypeId = airlineHQRectTypeId, 
			IATA_ISO_Country__c = countryQR.Id, 
			Membership_status__c = 'IATA member', 
			Sector__c = 'Airline', 
			ACLI_Status__c = 'Active Company'
		);

		Account secondAcctHQ = new Account(
			Name = 'Portugal Airways', 
			Airline_designator__c = 'PT', 
			ICCS_Membership_Status__c = 'Member', 
			Industry='Airline', 
			Type='Passenger',
			RecordTypeId = airlineHQRectTypeId, 
			IATA_ISO_Country__c = countryPT.Id, 
			Membership_status__c = 'IATA member', 
			Sector__c = 'Airline', 
			ACLI_Status__c = 'Active Company'
		);
		
		List<Account> accountLst = new List<Account>{firstAcctHq, secondAcctHQ};
		
		insert accountLst;
		
		AMP_ChatterBroadcastToolController ctrl = new AMP_ChatterBroadcastToolController();
		
		for(AMP_ChatterBroadcastToolController.AccountWrapper aw : ctrl.lstAccounts){
			aw.isSelected = true;
		}

		ctrl.selectWholeRegion = true;

		ctrl.GoToStep2();
		
		ctrl.message = 'New ' + airportsTopic + ' and ' + securityTopic +  ' plus ' + ndcTopic;

		ctrl.BroadcastMessage();
		
		List<FeedItem> feedItemLst = new List<FeedItem>(
			[SELECT 
				Id 
			 FROM 
			 	FeedItem 
			 WHERE 
			 	ParentId IN :accountLst
			]
		);
		
		system.assertEquals(accountLst.size(), feedItemLst.size(), 'Must be created two feed items');
		
	}
	
	@isTest static void multipleFeedItemsReplyTest() {
		
		FeedItem feedItem = [SELECT Id, ParentId, Body FROM FeedItem][0];
		
		PageReference pageRef = Page.AMP_ReplyToPostFromDigestByTopic;
		
		Test.setCurrentPage(pageRef);
		
	 	pageRef.getParameters().put('feedItemId', feedItem.Id);

		AMP_ReplyToPostFromDigestByTopic ctrl = new AMP_ReplyToPostFromDigestByTopic();		
		
		ctrl.nextStep();
		
		findApexMessage('Please select at least one account from the list.', ApexPages.Severity.ERROR);
		
		for(AMP_ReplyToPostFromDigestByTopic.FeedItemWrapper wrap : ctrl.feedItemAccountLst){
			wrap.isSelected = true;
		}
		
		ctrl.nextStep();
		ctrl.previousStep();
		ctrl.nextStep();
		ctrl.postReplyMessages();
		
		findApexMessage('Please insert the comment.', ApexPages.Severity.ERROR);
		
		ctrl.message = replyMessage;
		ctrl.postReplyMessages();
		
		findApexMessage('The comments were successfully posted.', ApexPages.Severity.INFO);
		
		ctrl.restartFromStep1();
		
		List<FeedComment> feedCommentLst = new List<FeedComment>(
			[SELECT 
				Id,
				FeedItemId,
				CommentBody
			 FROM
			 	FeedComment
			]
		);
		
		system.assertEquals(ctrl.feedItemAccountLst.size(), feedCommentLst.size(), 'Must be created two feed comments');
		
		for(FeedComment comment : feedCommentLst){
			system.assertEquals(replyMessage, comment.CommentBody, 'The comment must be the following: ' + replyMessage);
		}
				
	}
	
	@isTest static void multipleFeedItemsReplyErrorTest() {
		
		FeedItem feedItem = [SELECT Id, ParentId, Body FROM FeedItem][0];
		
		PageReference pageRef = Page.AMP_ReplyToPostFromDigestByTopic;
		
		Test.setCurrentPage(pageRef);
		
	 	pageRef.getParameters().put('feedItemId', feedItem.Id);

		AMP_ReplyToPostFromDigestByTopic ctrl = new AMP_ReplyToPostFromDigestByTopic();		
		
		for(AMP_ReplyToPostFromDigestByTopic.FeedItemWrapper wrap : ctrl.feedItemAccountLst){
			wrap.isSelected = true;
		}
		
		ctrl.nextStep();
		
		delete feedItem;
		
		ctrl.message = replyMessage;
		ctrl.postReplyMessages();
		
		findApexMessage('The comments failed to be posted.', ApexPages.Severity.ERROR);
		
	}
	
	@isTest static void replyWithoutParametersTest() {
		
		PageReference pageRef = Page.AMP_ReplyToPostFromDigestByTopic;
		
		Test.setCurrentPage(pageRef);
		
		AMP_ReplyToPostFromDigestByTopic ctrl = new AMP_ReplyToPostFromDigestByTopic();		
		
		findApexMessage('Unable to fetch Feed Item\'s related Accounts.', ApexPages.Severity.ERROR);

	}
	
	public static void findApexMessage(String expectedMessage, ApexPages.Severity severity){
		
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
		
		system.assert(!pageMessages.isEmpty(), 'Apex page messages must have elements.');
		
		Boolean messageFound = false;
		
		for(ApexPages.Message message : pageMessages) {
			
			if(message.getDetail().contains(expectedMessage) && 
				message.getSeverity().equals(severity)) {
				messageFound = true;
				break;   
			}
		}
		
		system.assert(messageFound, 'Must found the expected message.');
		
	}
	
}